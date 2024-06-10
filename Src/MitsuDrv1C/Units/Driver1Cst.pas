unit Driver1Cst;

interface

uses
  // VCL
  Classes, SysUtils,
  // This
  LogFile, VersionInfo, DriverError, DriverTypes, Types1C,
  StringUtils, TextEncoding, LangUtils, MitsuDrv;

type
  { TDeviceParams }

  TDeviceParams = record
    ConnectionType: Integer;
    Port: Integer;
    BaudRate: Integer;
    Timeout: Integer;
    IPAddress: WideString;
    TCPPort: Integer;
    AdminPassword: Integer;
    LogEnabled: Boolean;
    LogFileName: WideSTring;
    CloseSession: Boolean;
    //Paynames: T1CPayNames;
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
  end;

  { TDevice }

  TDevice1C = class(TCollectionItem)
  private
    FID: Integer;
    FParams: TMitsuParams;
  public
    property ID: Integer read FID;
    property Params: TMitsuParams read FParams;
  end;

  { TDevices1C }

  TDevices1C = class(TCollection)
  private
    function GetFreeID: Integer;
    function ItemByID(ID: Integer): TDevice1C;
    function GetItem(Index: Integer): TDevice1C;
  public
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
  protected
    procedure ClearError;
    procedure HandleException(E: Exception);
    procedure SelectDevice(const DeviceID: string);
    function GetAdditionalDescription: WideString;

    property Driver: TMitsuDrv read FDriver;
    property Device: TDevice1C read GetDevice;
    property Devices: TDevices1C read FDevices;
  public
    constructor Create(ALogger: ILogFile);
    destructor Destroy; override;

    function GetLogPath: string;
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
    function OpenShift(const DeviceID: WideString): WordBool;
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

{ TDevices1C }

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
  //FDevice := FDevices.Add; !!!
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
    //FDevice := Devices.Add; !!!
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
    RaiseError(E_INVALIDPARAM, Format('%s %s', [GetRes(@SInvalidParam),
      '"DeviceID"']));
  end;

  Device := FDevices.ItemByID(ID);
  if Device = nil then
  begin
    Logger.Error(Format('Device "%s"  not found', [DeviceID]));
    RaiseError(E_INVALIDPARAM, GetRes(@SDeviceNotActive));
  end;

  if Device <> FDevice then
  begin
    Driver.Disconnect;
    Driver.Params := Device.Params;
    FDevice := Device;
  end;
  Logger.Debug('SelectDevice.end');
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
    Device.CashInOutcome(Amount);
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
    Device.Close;
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
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.CloseCheck(Cash, PayByCard, PayByCredit,
      PayBySertificate, DiscountOnCheck);
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
  Device: TDevice1C;
begin
  ClearError;
  Result := True;
  try
    Device := Devices.Add;
    try
      Device.DeviceTest(ValuesArray, AdditionalDescription, DemoModeIsActivated);
    finally
      Device.Free;
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
  ErrorDescription := Format('%.2xh, %s', [FResultCode, FResultDescription]);
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
begin
  ClearError;
  Result := True;
  ADevice := nil;
  try
    ADevice := Devices.Add;
    ADevice.Open(ValuesArray);
    DeviceID := IntToStr(ADevice.ID);
    SelectDevice(DeviceID);
  except
    on E: Exception do
    begin
      ADevice.Free;
      Result := False;
      HandleException(E);
    end;
  end;
end;

{	Открывает новый чек }

function TDriver1Cst.OpenCheck(
  const DeviceID: WideString;
  IsFiscalCheck, IsReturnCheck, CancelOpenedCheck: WordBool;
  var ACheckNumber, ASessionNumber: Integer): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OpenCheck(IsFiscalCheck, IsReturnCheck,
      CancelOpenedCheck, ACheckNumber, ASessionNumber);
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
    Device.PrintFiscalString(AName, AQuantity, APrice,
      AAmount, ADepartment, ATax);
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
    Device.PrintNonFiscalString(TextString);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst.PrintXReport(const DeviceID: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.PrintXReport;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst.PrintZReport(const DeviceID: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.PrintZReport;
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
    Device.CheckPrintingStatus;
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
    Device.ContinuePrinting;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

// Установка пароля администратора
// Установка пароля пользователя
function TDriver1Cst.OpenCashDrawer(const DeviceID: WideString;
  CashDrawerID: Integer): WordBool;
begin
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OpenCashDrawer(CashDrawerID);
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
var
  ADevice: TDevice1C;
begin
  ClearError;
  Result := True;
  try
    ADevice := Devices.Add;
    try
      ADevice.LoadLogo(ValuesArray, LogoFileName, CenterLogo,
        LogoSize, AdditionalDescription);
    finally
      ADevice.Free;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      AdditionalDescription := GetAdditionalDescription;
    end;
  end;
end;

function TDriver1Cst.OpenSession(const DeviceID: WideString): WordBool;
begin
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OpenSession;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst.DeviceControl(const DeviceID: WideString;
  const TxData: WideString; var RxData: WideString): WordBool;
begin
  ClearError;
  RxData := '';
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.DeviceControl(TxData, RxData);
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
  Tx, Rx: WideString;
begin
  ClearError;
  RxData := '';
  try
    Tx := HexToStr(TxData);
    Result := DeviceControl(DeviceID, Tx, Rx);
    if not Result then Exit;
    RxData := StrToHex(Rx);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst.OpenShift(const DeviceID: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OpenShift;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst.PrintFiscalString2(const DeviceID, AName: WideString;
  AQuantity, APrice, AAmount: Double; ADepartment, ATax1, ATax2, ATax3,
  ATax4: Integer): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.PrintFiscalString2(AName, AQuantity, APrice,
      AAmount, ADepartment, ATax1, ATax2, ATax3, ATax4);
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

function TDriver1Cst.GetLogPath: string;
begin
  Result := FDriver.ComLogFile;
end;

end.

