unit Driver1C10;

interface

uses
  // VCL
  Classes, SysUtils, Variants,
  // This
  LogFile, VersionInfo, DriverError, DriverTypes, Types1C,
  StringUtils, TextEncoding, LangUtils, MitsuDrv, Params1C,
  DriverParams1C;

type
  { TDevice }

  TDevice1C = class(TCollectionItem)
  private
    FID: Integer;
    FParams: TDriverParams;
  public
    property ID: Integer read FID;
    property Params: TDriverParams read FParams write FParams;
  end;

  { TDevices1C }

  TDevices1C = class(TCollection)
  private
    function GetFreeID: Integer;
    function ItemByID(ID: Integer): TDevice1C;
    function GetItem(Index: Integer): TDevice1C;
  public
    function Add: TDevice1C;
    property Items[Index: Integer]: TDevice1C read GetItem; default;
  end;


  { TDriver1C10 }

  TDriver1C10 = class
  private
    FLogger: ILogFile;
    FDevice: TDevice1C;
    FDriver: TMitsuDrv;
    FDevices: TDevices1C;
    FDiscountOnCheck: Double;
    FResultCode: Integer;
    FResultDescription: WideString;
    function GetDevice: TDevice1C;
    procedure SetDevice(const Value: TDevice1C);
    procedure SetDriverParams(AParams: TDriverParams);
  protected
    procedure ClearError;
    procedure HandleException(E: Exception);
    procedure SelectDevice(const DeviceID: string);
    function GetAdditionalDescription: WideString;

    property Driver: TMitsuDrv read FDriver;
    property Device: TDevice1C read GetDevice write SetDevice;
    property Devices: TDevices1C read FDevices;
  public
    constructor Create(ALogger: ILogFile);
    destructor Destroy; override;

    function Open(const ValuesArray: IDispatch; var DeviceID: WideString): WordBool; virtual;
    function CashInOutcome(const DeviceID: WideString;
      Amount: Double): WordBool;
    function Close(const DeviceID: WideString): WordBool;
    function CloseCheck(const DeviceID: WideString; Cash, PayByCard,
      PayByCredit, PayBySertificate: Double): WordBool;
    function DeviceTest(const ValuesArray: IDispatch;
      var AdditionalDescription, DemoModeIsActivated: WideString): WordBool; virtual;
    function GetLastError(var ErrorDescription: WideString): Integer;
    function GetVersion: WideString;
    function OpenCheck(const DeviceID: WideString; IsFiscalCheck,
      IsReturnCheck, CancelOpenedCheck: WordBool; var ACheckNumber,
      ASessionNumber: Integer): WordBool;
    function PrintFiscalString(const DeviceID, AName: WideString; AQuantity,
      APrice, AAmount: Double; ADepartment: Integer; ATax: Single): WordBool;
    function PrintNonFiscalString(const DeviceID,
      TextString: WideString): WordBool;
    function PrintXReport(const DeviceID: WideString): WordBool;
    function PrintZReport(const DeviceID: WideString): WordBool;
    function CancelCheck(const DeviceID: WideString): WordBool;
    function CheckPrintingStatus(const DeviceID: WideString): WordBool;
    function ContinuePrinting(const DeviceID: WideString): WordBool;
    function OpenCashDrawer(const DeviceID: WideString;
      CashDrawerID: Integer): WordBool;
    function LoadLogo(const ValuesArray: IDispatch;
      const LogoFileName: WideString; CenterLogo: WordBool;
      var LogoSize: Integer; var AdditionalDescription: WideString): WordBool;
    function OpenSession(const DeviceID: WideString): WordBool;
    function DeviceControl(const DeviceID: WideString; const TxData: WideString; var RxData: WideString): WordBool;
    function DeviceControlHex(const DeviceID: WideString; const TxData: WideString; var RxData: WideString): WordBool;

    property Logger: ILogFile read FLogger;
    property DiscountOnCheck: Double read FDiscountOnCheck write FDiscountOnCheck;
  end;

implementation


function AmountToInt(Amount: Currency): Int64;
begin
  Result := Round(Amount * 100);
end;

{ TDevices1C }

function TDevices1C.Add: TDevice1C;
var
  ID: Integer;
begin
  ID := GetFreeID;
  Result := TDevice1C.Create(Self);
  Result.FID := ID;
end;

function TDevices1C.GetFreeID: Integer;
var
  ID: Integer;
begin
  ID := 1;
  while True do
  begin
    if ItemByID(ID) = nil then
    begin
      Result := ID;
      Exit;
    end;
    Inc(ID);
  end;
end;

function TDevices1C.GetItem(Index: Integer): TDevice1C;
begin
  Result := inherited Items[Index] as TDevice1C;
end;

function TDevices1C.ItemByID(ID: Integer): TDevice1C;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := Items[i];
    if Result.ID = ID then
      Exit;
  end;
  Result := nil;
end;

{ TDriver1C10 }

constructor TDriver1C10.Create(ALogger: ILogFile);
begin
  inherited Create;
  FLogger := ALogger;
  FDriver := TMitsuDrv.Create(ALogger);
  FDevices := TDevices1C.Create(TDevice1C);
  ClearError;
end;

destructor TDriver1C10.Destroy;
begin
  FDriver.Free;
  FDevices.Free;
  FLogger := nil;
  inherited Destroy;
end;

function TDriver1C10.GetDevice: TDevice1C;
begin
  if FDevice = nil then
    FDevice := Devices.Add;
  Result := FDevice;
end;

function TDriver1C10.GetAdditionalDescription: WideString;
begin
  Result := Format('%d, %s', [FResultCode, FResultDescription]);
end;

procedure TDriver1C10.HandleException(E: Exception);
var
  DriverError: EDriverError;
begin
  if E is EDriverError then
  begin
    DriverError := E as EDriverError;

    FResultCode := DriverError.Code;
    FResultDescription := DriverError.Message;
  end
  else
  begin
    FResultCode := E_UNKNOWN;
    FResultDescription := E.Message;
  end;
  Logger.Debug(Format('HandleException: %d, %s', [FResultCode, FResultDescription]));
end;

function TDriver1C10.CancelCheck(const DeviceID: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Driver.Check(Driver.Reset);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

procedure TDriver1C10.SelectDevice(const DeviceID: string);
var
  ID: Integer;
  Device: TDevice1C;
begin
  Logger.Debug('SelectDevice DeviceID = ' + DeviceID);
  ID := 0;
  try
    ID := StrToInt(DeviceID);
  except
    RaiseError(E_INVALIDPARAM, Format('%s %s', [SInvalidParam,
      '"DeviceID"']));
  end;

  Device := FDevices.ItemByID(ID);
  if Device = nil then
  begin
    Logger.Error(Format('Device "%s"  not found', [DeviceID]));
    RaiseError(E_INVALIDPARAM, SDeviceNotActive);
  end;
  SetDevice(Device);
  Logger.Debug('SelectDevice.end');
end;

procedure TDriver1C10.SetDevice(const Value: TDevice1C);
begin
  if Value <> FDevice then
  begin
    Driver.Disconnect;
    FDevice := Value;
    if FDevice <> nil then
    begin
      SetDriverParams(FDevice.Params);
    end;
  end;
end;

procedure TDriver1C10.SetDriverParams(AParams: TDriverParams);
var
  Params: TMitsuParams;
begin
  Params.ConnectionType := AParams.ConnectionType;
  Params.PortName := AParams.PortName;
  Params.BaudRate := AParams.BaudRate;
  Params.ByteTimeout := AParams.ByteTimeout;
  Params.RemoteHost := AParams.RemoteHost;
  Params.RemotePort := AParams.RemotePort;
  Params.LogPath := AParams.LogPath;
  Params.LogEnabled := AParams.LogEnabled;
  Driver.Params := Params;
end;

///////////////////////////////////////////////////////////////////////////////
//  Печатает чек внесения/ выемки (зависит от переданной суммы).
//  Сумма >= 0 - внесение, Сумма < 0 - выемка.

function TDriver1C10.CashInOutcome(const DeviceID: WideString;
  Amount: Double): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    //Driver.CashInOutcome(Amount);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Отключает фискальный регистратор

function TDriver1C10.Close(const DeviceID: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Driver.Disconnect;
    FDevice.Free;
    FDevice := nil;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1C10.CloseCheck(const DeviceID: WideString; Cash,
  PayByCard, PayByCredit, PayBySertificate: Double): WordBool;
var
  Payment: TMTSReceiptPayment;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);

    Payment.CashAmount := AmountToInt(Cash);
    Payment.CardAmount := AmountToInt(PayByCard);
    Payment.AdvanceAmount := AmountToInt(PayBySertificate);
    Payment.CreditAmount := AmountToInt(PayByCredit);
    Payment.OtherAmount := 0;
    Payment.DiscountAmount := 0;
    Payment.CommentType := 0;
    Payment.CommentText := '';
    Payment.AmountType1 := 0;
    Payment.AmountType2 := 0;
    Payment.AmountType3 := 0;
    Payment.AmountType4 := 0;
    Payment.AmountType5 := 0;
    Driver.Check(Driver.PayReceipt(Payment));
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

(*******************************************************************************

  Выполняет пробное подключение и опрос устройства.
  При успешном выполнении подключения в описании возвращается
  описание устройства. При отрицательном результате возвращается
  описание возникшей проблемы при подключении.

*******************************************************************************)

function TDriver1C10.DeviceTest(const ValuesArray: IDispatch;
      var AdditionalDescription, DemoModeIsActivated: WideString): WordBool;
var
  Params: TDriverParams;
  DeviceName: WideString;
  DeviceVersion: TMTSVersion;
begin
  ClearError;
  Result := True;
  AdditionalDescription := 'OK';
  try
    Params := ReadDriverParams(ValuesArray);
    SetDriverParams(Params);
    Driver.LockPort;
    try
      Driver.Check(Driver.Connect);
      Driver.Check(Driver.ReadDeviceName(DeviceName));
      Driver.Check(Driver.ReadDeviceVersion(DeviceVersion));
      AdditionalDescription := Format('%s № %s', [DeviceName, DeviceVersion.Serial]);
    finally
      Driver.UnlockPort;
      Driver.Disconnect;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
      AdditionalDescription := GetAdditionalDescription;
    end;
  end;
end;

// Возвращает код и описание последней произошедшей ошибки
function TDriver1C10.GetLastError(
  var ErrorDescription: WideString): Integer;
begin
  ErrorDescription := FResultDescription;
  Result := FResultCode;
  Logger.Debug('GetLastError ' + ErrorDescription);
end;

// Возвращает номер версии драйвера }
function TDriver1C10.GetVersion: WideString;
begin
  ClearError;
  Result := GetModuleVersion;
end;

// Подключает фискальный регистратор
function TDriver1C10.Open(const ValuesArray: IDispatch;
  var DeviceID: WideString): WordBool;
var
  ADevice: TDevice1C;
  Params: TDriverParams;
  DeviceVersion: TMTSVersion;
begin
  ClearError;
  Result := True;
  try
    Params := ReadDriverParams(ValuesArray);
    Driver.Disconnect;
    SetDriverParams(Params);
    Driver.LockPort;
    try
      //ProgramPayNames;
      //SetUserPassword;
      Driver.Check(Driver.ReadDeviceVersion(DeviceVersion));

      ADevice := Devices.Add;
      ADevice.Params := Params;
      DeviceID := IntToStr(ADevice.ID);
      SetDevice(ADevice);
    finally
      Driver.UnlockPort;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

{	Открывает новый чек }

function TDriver1C10.OpenCheck(const DeviceID: WideString;
  IsFiscalCheck, IsReturnCheck, CancelOpenedCheck: WordBool;
  var ACheckNumber, ASessionNumber: Integer): WordBool;
var
  Params: TMTSOpenReceipt;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);

  //CancelOpenedCheck: WordBool; var ACheckNumber, ASessionNumber

    if IsFiscalCheck then
    begin
      Params.ReceiptType := MTS_RT_SALE;
      if IsReturnCheck then
        Params.ReceiptType := MTS_RT_RETSALE;

    end;
    Params.TaxSystem := Device.Params.TaxSystem;
    Params.SaleAddress := Device.Params.SaleAddress;
    Params.SaleLocation := Device.Params.SaleLocation;
    Params.AutomaticNumber := Device.Params.AutomaticNumber;
    Params.SenderEmail := Device.Params.SenderEmail;
    Driver.Check(Driver.OpenReceipt(Params));
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

(******************************************************************************

  Печатает строку товарной позиции с переданными реквизитами.
  Скидки/наценки по строке рассчитываются по следующему алгоритму:
  Если  (Сумма - Цена*Количество) < 0, то в чеке печатается денежная скидка,
  если (Сумма - Цена*Количество) > 0, то в чеке печатается денежная надбавка.
  Размер скидки / надбавки равен абсолютной величине |Сумма - Цена*Количество|.

******************************************************************************)

function TDriver1C10.PrintFiscalString(const DeviceID, AName: WideString;
  AQuantity, APrice, AAmount: Double; ADepartment: Integer; ATax: Single):
  WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    (*
    Device.PrintFiscalString(AName, AQuantity, APrice,
      AAmount, ADepartment, ATax);
    *)
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

// Выводит произвольную строку на чековую ленту

function TDriver1C10.PrintNonFiscalString(const DeviceID,
  TextString: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    //Driver.PrintDocument
    //Device.PrintNonFiscalString(TextString);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1C10.PrintXReport(const DeviceID: WideString): WordBool;
var
  Cashier: TMTSCashier;
  DayStatus: TMTSDayStatus;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    // Set cashier
    Cashier.Name := Device.Params.CashierName;
    Cashier.INN := Device.Params.CashierINN;
    if (Cashier.Name <> '')and(Cashier.INN <> '') then
    begin
      Driver.Check(Driver.WriteCashier(Cashier));
    end;
    // X report
    Driver.Check(Driver.MakeXReport(DayStatus));
    if Device.Params.PrintRequired then
    begin
      Driver.Check(Driver.Print);
    end;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;


function TDriver1C10.PrintZReport(const DeviceID: WideString): WordBool;
var
  Cashier: TMTSCashier;
  DayStatus: TMTSDayStatus;
  DayParams: TMTSDayParams;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    // Check day not closed
    Driver.Check(Driver.ReadDayStatus(DayStatus));
    if DayStatus.DayStatus = MTS_DAY_STATUS_CLOSED then
      raise Exception.Create('Day is closed');
    // Set cashier
    Cashier.Name := Device.Params.CashierName;
    Cashier.INN := Device.Params.CashierINN;
    if (Cashier.Name <> '')and(Cashier.INN <> '') then
    begin
      Driver.Check(Driver.WriteCashier(Cashier));
    end;
    // Z report
    DayParams.SaleAddress := Device.Params.SaleAddress;
    DayParams.SaleLocation := Device.Params.SaleLocation;
    DayParams.ExtendedProperty := Device.Params.ExtendedProperty;
    DayParams.ExtendedData := Device.Params.ExtendedData;
    DayParams.PrintRequired := False;
    Driver.Check(Driver.CloseFiscalDay(DayParams));
    if Device.Params.PrintRequired then
    begin
      Driver.Check(Driver.Print);
    end;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

(******************************************************************************

Проверка состояния печати.
В 1С будет примерно такая обработка

Функция ПроверкаСостоянияПечати(Объект)
  Результат = мНетОшибки;
    Пока Истина Цикл
      Если Не Объект.Драйвер. ПроверитьСостояниеПечати () Тогда
        Объект.Драйвер.ПолучитьОшибку(Объект.ОписаниеОшибки);
        Ответ = Вопрос(Объект.ОписаниеОшибки + Символы.ПС
        + "Продолжить печать?", РежимДиалогаВопрос.ДаНет, 0, КодВозвратаДиалога.Да);
        Если Ответ = КодВозвратаДиалога.Нет Тогда
          Результат = мОшибкаНеизвестно;
        Прервать;
      Иначе
        Объект.Драйвер.ПродолжитьПечать();
      КонецЕсли;
    Иначе
      Прервать;
    КонецЕсли;
  КонецЦикла;
  Возврат Результат;
КонецФункции

*******************************************************************************)

function TDriver1C10.CheckPrintingStatus(const DeviceID: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    //Device.CheckPrintingStatus;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1C10.ContinuePrinting(const DeviceID: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    //Device.ContinuePrinting; !!!
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1C10.OpenCashDrawer(const DeviceID: WideString;
  CashDrawerID: Integer): WordBool;
begin
  Result := True;
  try
    SelectDevice(DeviceID);
    Driver.Check(Driver.OpenCashDrawer);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1C10.LoadLogo(const ValuesArray: IDispatch;
  const LogoFileName: WideString; CenterLogo: WordBool; var LogoSize: Integer;
  var AdditionalDescription: WideString): WordBool;
var
  Params: TDriverParams;
begin
  ClearError;
  Result := True;
  try
    Params := ReadDriverParams(ValuesArray);
    SetDriverParams(Params);
    // !!!
  except
    on E: Exception do
    begin
      Result := False;
      AdditionalDescription := GetAdditionalDescription;
    end;
  end;
end;

function TDriver1C10.DeviceControl(const DeviceID: WideString;
  const TxData: WideString; var RxData: WideString): WordBool;
var
  Tx, Rx: AnsiString;
begin
  ClearError;
  RxData := '';
  Result := True;
  try
    SelectDevice(DeviceID);
    SelectDevice(DeviceID);
    Tx := TxData;
    Driver.Check(Driver.Send(Tx, Rx));
    RxData := Rx;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1C10.DeviceControlHex(const DeviceID: WideString;
  const TxData: WideString; var RxData: WideString): WordBool;
var
  Tx, Rx: AnsiString;
begin
  ClearError;
  RxData := '';
  try
    SelectDevice(DeviceID);
    Tx := HexToStr(TxData);
    Driver.Check(Driver.Send(Tx, Rx));
    RxData := StrToHex(Rx);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1C10.OpenSession(const DeviceID: WideString): WordBool;

  procedure CheckDayNotExpired(DayStatus: Integer);
  begin
    if DayStatus = MTS_DAY_STATUS_EXPIRED then
      raise Exception.Create('Day is expired');
  end;

var
  Cashier: TMTSCashier;
  DayParams: TMTSDayParams;
  DayStatus: TMTSDayStatus;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);

    Driver.Check(Driver.ReadDayStatus(DayStatus));
    CheckDayNotExpired(DayStatus.DayStatus);
    if DayStatus.DayStatus = MTS_DAY_STATUS_OPENED then Exit;

    // Set cashier
    Cashier.Name := Device.Params.CashierName;
    Cashier.INN := Device.Params.CashierINN;
    if (Cashier.Name <> '')and(Cashier.INN <> '') then
    begin
      Driver.Check(Driver.WriteCashier(Cashier));
    end;
    // OpenFiscalDay
    DayParams.SaleAddress := Device.Params.SaleAddress;
    DayParams.SaleLocation := Device.Params.SaleLocation;
    DayParams.ExtendedProperty := Device.Params.ExtendedProperty;
    DayParams.ExtendedData := Device.Params.ExtendedData;
    DayParams.PrintRequired := False;
    Driver.Check(Driver.OpenFiscalDay(DayParams));
    // Print
    if Device.Params.PrintRequired then
    begin
      Driver.Check(Driver.Print);
    end;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

procedure TDriver1C10.ClearError;
begin
  FResultCode := 0;
  FResultDescription := 'Ошибок нет';
end;


end.

