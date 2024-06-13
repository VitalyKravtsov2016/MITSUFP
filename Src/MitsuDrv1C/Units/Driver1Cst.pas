unit Driver1Cst;

interface

uses
  // VCL
  Classes, SysUtils, Variants,
  // This
  LogFile, VersionInfo, DriverError, DriverTypes, Types1C,
  StringUtils, TextEncoding, LangUtils, MitsuDrv, Params1C;

const
  IdxConnectionType = 0;
  IdxPortName = 1;
  IdxBaudRate = 2;
  IdxByteTimeout = 3;
  IdxRemoteHost = 4;
  IdxRemotePort = 5;
  IdxLogPath = 6;
  IdxLogEnabled = 7;
  IdxCashierName = 8;
  IdxCashierINN = 9;
  IdxPrintRequired = 10;
  IdxSaleAddress = 11;
  IdxSaleLocation = 12;
  IdxExtendedProperty = 13;
  IdxExtendedData = 14;
  IdxTaxSystem = 15;
  IdxAutomaticNumber = 16;
  IdxSenderEmail = 17;

type
  { TDriverParams }

  TDriverParams = record
    DriverParams: TMitsuParams;
    CashierName: WideString;
    CashierINN: WideString;
    PrintRequired: Boolean;
    SaleAddress: WideString; // Адрес проведения расчетов
    SaleLocation: WideString; // Место проведения расчетов
    ExtendedProperty: WideString; // дополнительный реквизит ОР
    ExtendedData: WideString; // дополнительные данные ОР
    TaxSystem: Integer; // Система налогообложения
    AutomaticNumber: WideString; // Номер автомата для автоматического режима
    SenderEmail: WideString; // Адрес электронной почты отправителя чека
    Correction: TMTSCorrection;

    (*
    AdminPassword: Integer;
    CloseSession: Boolean;
    BarcodeFirstLine: Integer;
    QRCodeHeight: Integer;
    EnablePaymentSignPrint: Boolean;
    QRCodeDotWidth: Integer;
    ItemNameLength: Integer;
    CheckFontNumber: Integer;
    EnableNonFiscalHeader: Boolean;
    EnableNonFiscalFooter: Boolean;
    FormatVersion: Integer;
    DisablePrintReports: Boolean;
    CheckClock: Boolean;
    UseRepeatDocument: Boolean;
    *)
  end;

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


  { TDriver1Cst }

  TDriver1Cst = class
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
    function PrintFiscalString2(const DeviceID, AName: WideString; AQuantity,
      APrice, AAmount: Double; ADepartment: Integer; ATax1: Integer; ATax2: Integer; ATax3: Integer; ATax4: Integer): WordBool;
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

function GetParamName(Index: Integer): string;
function GetParamValue(V: Variant; Index: Integer): Variant;
function GetStrParamValue(V: Variant; Index: Integer): string;
function GetIntParamValue(V: Variant; Index: Integer): Integer;
function GetBoolParamValue(V: Variant; Index: Integer): Boolean;
procedure SetParamValue(V: Variant; Index: Integer; Value: Variant);

function ReadDriverParams(V: Variant): TDriverParams;
procedure WriteDriverParams(V: Variant; const Params: TDriverParams);

implementation

function ReadDriverParams(V: Variant): TDriverParams;
begin
  Result.DriverParams.ConnectionType := GetIntParamValue(V, IdxConnectionType);
  Result.DriverParams.PortName := GetStrParamValue(V, IdxPortName);
  Result.DriverParams.BaudRate := GetIntParamValue(V, IdxBaudRate);
  Result.DriverParams.ByteTimeout := GetIntParamValue(V, IdxByteTimeout);
  Result.DriverParams.RemoteHost := GetStrParamValue(V, IdxRemoteHost);
  Result.DriverParams.RemotePort := GetIntParamValue(V, IdxRemotePort);
  Result.DriverParams.LogPath := GetStrParamValue(V, IdxLogPath);
  Result.DriverParams.LogEnabled := GetBoolParamValue(V, IdxLogEnabled);
  Result.CashierName := GetStrParamValue(V, IdxCashierName);
  Result.CashierINN := GetStrParamValue(V, IdxCashierINN);
  Result.PrintRequired := GetBoolParamValue(V, IdxPrintRequired);
  Result.SaleAddress := GetParamValue(V, IdxSaleAddress);
  Result.SaleLocation := GetParamValue(V, IdxSaleLocation);
  Result.ExtendedProperty := GetParamValue(V, IdxExtendedProperty);
  Result.ExtendedData := GetParamValue(V, IdxExtendedData);
  Result.TaxSystem := GetParamValue(V, IdxTaxSystem);
  Result.AutomaticNumber := GetParamValue(V, IdxAutomaticNumber);
  Result.SenderEmail := GetParamValue(V, IdxSenderEmail);
end;

procedure WriteDriverParams(V: Variant; const Params: TDriverParams);
begin
  SetParamValue(V, IdxConnectionType, Params.DriverParams.ConnectionType);
  SetParamValue(V, IdxPortName, Params.DriverParams.PortName);
  SetParamValue(V, IdxBaudRate, Params.DriverParams.BaudRate);
  SetParamValue(V, IdxByteTimeout, Params.DriverParams.ByteTimeout);
  SetParamValue(V, IdxRemoteHost, Params.DriverParams.RemoteHost);
  SetParamValue(V, IdxRemotePort, Params.DriverParams.RemotePort);
  SetParamValue(V, IdxLogPath, Params.DriverParams.LogPath);
  SetParamValue(V, IdxLogEnabled, Params.DriverParams.LogEnabled);
  SetParamValue(V, IdxCashierName, Params.CashierName);
  SetParamValue(V, IdxCashierINN, Params.CashierINN);
  SetParamValue(V, IdxPrintRequired, Params.PrintRequired);
  SetParamValue(V, IdxSaleAddress, Params.SaleAddress);
  SetParamValue(V, IdxSaleLocation, Params.SaleLocation);
  SetParamValue(V, IdxExtendedProperty, Params.ExtendedProperty);
  SetParamValue(V, IdxExtendedData, Params.ExtendedData);
  SetParamValue(V, IdxTaxSystem, Params.TaxSystem);
  SetParamValue(V, IdxAutomaticNumber, Params.AutomaticNumber);
  SetParamValue(V, IdxSenderEmail, Params.SenderEmail);
end;

function GetParamName(Index: Integer): string;
begin
  case Index of
    IdxConnectionType: Result := 'ConnectionType';
    IdxPortName: Result := 'PortName';
    IdxBaudRate: Result := 'BaudRate';
    IdxByteTimeout: Result := 'ByteTimeout';
    IdxRemoteHost: Result := 'RemoteHost';
    IdxRemotePort: Result := 'RemotePort';
    IdxLogPath: Result := 'LogPath';
    IdxLogEnabled: Result := 'LogEnabled';
    IdxCashierName: Result := 'CashierName';
    IdxCashierINN: Result := 'CashierINN';
    IdxPrintRequired: Result := 'PrintRequired';
  else
    Result := 'Unknown'
  end;
end;

function GetIntParamValue(V: Variant; Index: Integer): Integer;
begin
  Result := Integer(GetParamValue(V, Index));
end;

function GetStrParamValue(V: Variant; Index: Integer): string;
begin
  Result := String(GetParamValue(V, Index));
end;

function GetBoolParamValue(V: Variant; Index: Integer): Boolean;
begin
  Result := Boolean(GetParamValue(V, Index));
end;

function GetParamValue(V: Variant; Index: Integer): Variant;
var
  Msg: string;
begin
  try
    Result := V.Get(Index);
  except
    on E: Exception do
    begin
      Msg := Format('Failed to get value, name=%s', [GetParamName(Index)]);
      E.Message := Msg + E.Message;
      raise;
    end;
  end;
end;

procedure SetParamValue(V: Variant; Index: Integer; Value: Variant);
var
  Msg: string;
begin
  try
    V.Set(Index, Value);
  except
    on E: Exception do
    begin
      Msg := Format('Failed to set value, name=%s', [GetParamName(Index)]);
      E.Message := Msg + E.Message;
      raise;
    end;
  end;
end;

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

{ TDriver1CSt }

constructor TDriver1Cst.Create(ALogger: ILogFile);
begin
  inherited Create;
  FLogger := ALogger;
  FDriver := TMitsuDrv.Create;
  FDevices := TDevices1C.Create(TDevice1C);
  ClearError;
end;

destructor TDriver1Cst.Destroy;
begin
  FDriver.Free;
  FDevices.Free;
  FLogger := nil;
  inherited Destroy;
end;

function TDriver1Cst.GetDevice: TDevice1C;
begin
  if FDevice = nil then
    FDevice := Devices.Add;
  Result := FDevice;
end;

function TDriver1Cst.GetAdditionalDescription: WideString;
begin
  Result := Format('%.2xh, %s', [FResultCode, FResultDescription]);
end;

procedure TDriver1Cst.HandleException(E: Exception);
var
  DriverError: EDriverError;
begin
  if E is EDriverError then
  begin
    DriverError := E as EDriverError;
    FResultCode := DriverError.Code;
    FResultDescription := EDriverError(E).Message;
  end
  else
  begin
    FResultCode := E_UNKNOWN;
    FResultDescription := E.Message;
  end;
  Logger.Debug('HandleException: ' + IntToStr(FResultCode) + ', ' + FResultDescription);
end;

function TDriver1Cst.CancelCheck(const DeviceID: WideString): WordBool;
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

procedure TDriver1Cst.SelectDevice(const DeviceID: string);
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

procedure TDriver1Cst.SetDevice(const Value: TDevice1C);
begin
  if Value <> FDevice then
  begin
    Driver.Disconnect;
    FDevice := Value;
    if FDevice <> nil then
    begin
      Driver.Params := FDevice.Params.DriverParams;
    end;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
//  Печатает чек внесения/ выемки (зависит от переданной суммы).
//  Сумма >= 0 - внесение, Сумма < 0 - выемка.

function TDriver1Cst.CashInOutcome(const DeviceID: WideString;
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

function TDriver1Cst.Close(const DeviceID: WideString): WordBool;
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

function TDriver1Cst.CloseCheck(const DeviceID: WideString; Cash,
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

function TDriver1Cst.DeviceTest(const ValuesArray: IDispatch;
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
    Driver.Params := Params.DriverParams;
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
function TDriver1Cst.GetLastError(
  var ErrorDescription: WideString): Integer;
begin
  ErrorDescription := Format('%d, %s', [FResultCode, FResultDescription]);
  Result := FResultCode;
  Logger.Debug('GetLastError ' + ErrorDescription);
end;

// Возвращает номер версии драйвера }
function TDriver1Cst.GetVersion: WideString;
begin
  ClearError;
  Result := GetModuleVersion;
end;

// Подключает фискальный регистратор
function TDriver1Cst.Open(const ValuesArray: IDispatch;
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
    Driver.Params := Params.DriverParams;
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

function TDriver1Cst.OpenCheck(const DeviceID: WideString;
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

function TDriver1Cst.PrintFiscalString(const DeviceID, AName: WideString;
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

function TDriver1Cst.PrintNonFiscalString(const DeviceID,
  TextString: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Driver.PrintDocument
    //Device.PrintNonFiscalString(TextString);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst.PrintXReport(const DeviceID: WideString): WordBool;
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


function TDriver1Cst.PrintZReport(const DeviceID: WideString): WordBool;
var
  Cashier: TMTSCashier;
  DayParams: TMTSDayParams;
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
    // Z report
    DayParams.SaleAddress := Device.Params.SaleAddress;
    DayParams.SaleLocation := Device.Params.SaleLocation;
    DayParams.ExtendedProperty := Device.Params.ExtendedProperty;
    DayParams.ExtendedData := Device.Params.ExtendedData;
    DayParams.PrintRequired := Device.Params.PrintRequired;
    Driver.Check(Driver.CloseFiscalDay(DayParams));
    (*
    if Device.Params.PrintRequired then
    begin
      Driver.Check(Driver.Print);
    end;
    *)
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

function TDriver1Cst.CheckPrintingStatus(const DeviceID: WideString): WordBool;
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

function TDriver1Cst.ContinuePrinting(const DeviceID: WideString): WordBool;
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

function TDriver1Cst.OpenCashDrawer(const DeviceID: WideString;
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

function TDriver1Cst.LoadLogo(const ValuesArray: IDispatch;
  const LogoFileName: WideString; CenterLogo: WordBool; var LogoSize: Integer;
  var AdditionalDescription: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    Params := ReadDriverParams(ValuesArray);
    Driver.Params := Params.DriverParams;
    // !!!
  except
    on E: Exception do
    begin
      Result := False;
      AdditionalDescription := GetAdditionalDescription;
    end;
  end;
end;

function TDriver1Cst.DeviceControl(const DeviceID: WideString;
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

function TDriver1Cst.DeviceControlHex(const DeviceID: WideString;
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

function TDriver1Cst.OpenSession(const DeviceID: WideString): WordBool;
var
  Cashier: TMTSCashier;
  DayParams: TMTSDayParams;
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
    // Z report
    DayParams.SaleAddress := Device.Params.SaleAddress;
    DayParams.SaleLocation := Device.Params.SaleLocation;
    DayParams.ExtendedProperty := Device.Params.ExtendedProperty;
    DayParams.ExtendedData := Device.Params.ExtendedData;
    DayParams.PrintRequired := Device.Params.PrintRequired;
    Driver.Check(Driver.OpenFiscalDay(DayParams));
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

procedure TDriver1Cst.ClearError;
begin
  FResultCode := 0;
  FResultDescription := 'Ошибок нет';
end;


end.

