unit MitsuDrv1C;

interface

uses
  // VCL
  Classes, SysUtils, XMLDoc, XMLIntf,
  // This
  MitsuDrv, ByteUtils, Types1C_1, DriverError, VersionInfo,
  ParamList1C, ParamList1CPage, ParamList1CGroup, ParamList1CItem,
  Param1CChoiceList, LangUtils, FDTypes, Params1C, Positions1C3,
  LogFile;

const
  // Праметры по умолчанию
  DEF_PRINTLOGO = False;
  DEF_LOGOSIZE = 0;
  DEF_CONNECTION_TYPE = 0;
  DEF_COMPUTERNAME = '';
  DEF_IPADDRESS = '';
  DEF_TCPPORT = 211;
  DEF_PROTOCOLTYPE = 0;
  DEF_BUFFERSTRINGS = False;
  StatusTimeout = 30000; // 30 секунд

type
  { TDevice }

  TDevice = class(TCollectionItem)
  private
    FID: Integer;
    FParams: TMitsuParams;
  public
    property ID: Integer read FID;
    property Params: TMitsuParams read FParams;
  end;

  { TDevices }

  TDevices = class(TCollection)
  private
    function GetFreeID: Integer;
    function ItemByID(ID: Integer): TDevice;
    function GetItem(Index: Integer): TDevice;
  public
    property Items[Index: Integer]: TDevice read GetItem; default;
  end;

  { T1CTax }

  T1CTax = array[1..4] of Single;
  TTaxNames = array[1..6] of string;

  { T1CPayNames }

  T1CPayNames = array[1..3] of string;

  TCashierRec = record
    CashierName: WideString;
    CashierPass: Integer;
  end;

  { TCashiers }

  TCashiers = array[1..30] of TCashierRec;

  { T1CDriverParams }

  T1CDriverParams = record
    Port: Integer;
    Speed: Integer;
    UserPassword: string;
    AdminPassword: string;
    Timeout: Integer;
    RegNumber: string;
    SerialNumber: string;
    Tax: T1CTax;
    CloseSession: Boolean;
    EnableLog: Boolean;
    PayNames: T1CPayNames;
    Cashiers: TCashiers;
    PrintLogo: Boolean;
    LogoSize: Integer;
    ConnectionType: Integer;
    ComputerName: string;
    IPAddress: string;
    TCPPort: Integer;
    ProtocolType: Integer;
    BufferStrings: Boolean;
    Codepage: Integer;
    BarcodeFirstLine: Integer;
    QRCodeHeight: Integer;
  end;

  { TMitsuDrv1C }

  TMitsuDrv1C = class
  private
    FDevice: TDevice;
    FDevices: TDevices;
    FDriver: TMitsuDrv;
    FLogger: TLogFile;
    FParams: TMitsuParams;
    FParamList: TParamList1C;
    FReader: T1CXmlReaderWriter;

    FResultCode: Integer;
    FResultDescription: string;

    procedure ClearError;
    procedure HandleException(E: Exception);
    procedure SelectDevice(const DeviceID: string);
    procedure ReadParametersKKT(Params: TParametersKKT);
    procedure CreateParamList;

    function ReadOutputParameters: AnsiString;
    function ReadValuesArray(const AValuesArray: IDispatch): T1CDriverParams;
    function GetAdditionalDescription: WideString;
    (*
    procedure doProcessCheck(Electronically: Boolean;
      const CheckPackage: WideString; IsCorrection: Boolean);
    *)

    property Device: TDevice read FDevice;
    property Devices: TDevices read FDevices;
  public
    constructor Create;
    destructor Destroy; override;

    function GetInterfaceRevision: Integer;
    function GetDescription(out DriverDescription: WideString): WordBool;
    function GetLastError(out ErrorDescription: WideString): Integer;
    function GetParameters(out TableParameters: WideString): WordBool;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool;
    function Open(out DeviceID: WideString): WordBool;
    function Close(const DeviceID: WideString): WordBool;

    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool;
    function GetAdditionalActions(out TableActions: WideString): WordBool;
    function DoAdditionalAction(const ActionName: WideString): WordBool;
    function GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
                         const ParametersFiscal: WideString): WordBool;
    function OpenShift(const DeviceID: WideString; const InputParameters: WideString;
                       out OutputParameters: WideString): WordBool;
    function CloseShift(const DeviceID: WideString; const InputParameters: WideString;
                        out OutputParameters: WideString): WordBool;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool;
                          const CheckPackage: WideString; out DocumentOutputParameters: WideString): WordBool;
    function ProcessCorrectionCheck(const DeviceID: WideString; const CheckPackage: WideString;
                                    out DocumentOutputParameters: WideString): WordBool;
    function CashInOutcome(const DeviceID: WideString; const InputParameters: WideString;
                           Amount: Double): WordBool;
    function PrintXReport(const DeviceID: WideString; const InputParameters: WideString): WordBool;
    function GetCurrentStatus(const DeviceID: WideString; const InputParameters: WideString;
                              out OutputParameters: WideString): WordBool;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString;
                                              const InputParameters: WideString;
                                              out OutputParameters: WideString): WordBool;
    function OpenCashDrawer(const DeviceID: WideString): WordBool;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool;
    function PrintCheckCopy(const DeviceID: WideString; const CheckNumber: WideString): WordBool;
    function PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool;
    function OpenSessionRegistrationKM(const DeviceID: WideString): WordBool;
    function CloseSessionRegistrationKM(const DeviceID: WideString): WordBool;
    function RequestKM(const DeviceID: WideString; const RequestKM: WideString;
                       out RequestKMResult: WideString): WordBool; 
    function GetProcessingKMResult(const DeviceID: WideString; out ProcessingKMResult: WideString;
                                   out RequestStatus: Integer): WordBool; 
    function ConfirmKM(const DeviceID: WideString; const RequestGUID: WideString;
                       ConfirmationType: Integer): WordBool; 
    function GetLocalizationPattern(out LocalizationPattern: WideString): WordBool;
    function SetLocalization(const LanguageCode: WideString; const LocalizationPattern: WideString): WordBool;

    property Logger: TLogFile read FLogger;
    property Driver: TMitsuDrv read FDriver;
  end;

implementation

function Bool1C(AValue: Boolean): WideString;
begin
  if AValue then
    Result := 'true'
  else
    Result := 'false';
end;

resourcestring
  SConnectionParams = 'Параметры связи';
  SConnectionType = 'Тип подключения';
  SProtocolType = 'Тип протокола';
  SStandard = 'Стандартный';
  SProtocol2 = 'Протокол ККТ 2.0';
  SPort = 'Порт';
  SBaudrate = 'Скорость';
  STimeout = 'Таймаут';
  SComputerName = 'Имя компьютера';
  SIPAddress = 'IP адрес';
  STCPPort = 'TCP порт';
  SDeviceParams = 'Параметры устройства';
  SAdminPassword = 'Пароль администратора';
  SCloseSession = 'Закрывать смену для программирования налоговых ставок (в случае некорректных значений)';
  SBufferStrings = 'Буферизировать строки';
  SBarcodeFirstLine = 'Номер линии для загрузки QR Code';
  SQRCodeHeight = 'Высота QR Code, точек';
  SQRCodeDotWidth = 'Толщина точки QR Code (3-8)';
  SReceiptFormat = 'Формат чека';
  SEnablePaymentSignPrint = 'Печатать признак и способ расчета (ФФД 1.05)';
  SLogParams = 'Настройка лога';
  SEnableLog = 'Вести лог';
  SLogPath = 'Путь к файлу лога';
  STaxRates = 'Налоговые ставки и типы оплат';
  STax1 = 'Наименование ставки НДС 18 %';
  STax2 = 'Наименование ставки НДС 10%';
  STax3 = 'Наименование ставки НДС 0%';
  STax4 = 'Наименование ставки БЕЗ НДС';
  STax5 = 'Наименование ставки НДС 18/118';
  STax6 = 'Наименование ставки НДС 10/110';
  SPayName1 = 'Тип безнал. оплаты 1';
  SPayName2 = 'Тип безнал. оплаты 2';
  SPayName3 = 'Тип безнал. оплаты 3';
  SCashiers = 'Кассиры';
  SCashier = 'Кассир';
  SPassword = 'Пароль кассира';
  SPayName1DefaultValue = 'ПЛАТ.КАРТОЙ';
  SPayName2DefaultValue = 'КРЕДИТОМ';
  SPayName3DefaultValue = 'СЕРТИФИКАТОМ';
  SCodepage = 'Кодировка';
  SCodepageDef = 'Нет перекодировки';
  SCodepageRussian = 'Русская';
  SCodepageArmenianUnicode = 'Армянская UNICODE';
  SCodepageArmenianAnsi = 'Армянская ANSI';
  SCodePageKazakhUnicode = 'Казахская UNICODE';
  SCodepageTurkmenUnicode = 'Туркменская UNICODE';
  SOrangeData = 'Orange Data';
  SODEnabled = 'Включить передачу данных в Orange Data';
  SODTaxOSN = 'ОСН';
  SODTaxUSND = 'УСН доход';
  SODTaxUSNDMR = 'УСН доход минус расход';
  SODTaxENVD = 'ЕНВД';
  SODTaxESN = 'ЕСН';
  SODTaxPSN = 'ПСН';
  SODTax = 'Системы налогообложения';
  SODServerURL = 'URL сервера';
  SODINN = 'ИНН';
  SODGroup = 'Группа';
  SODCertFileName = 'Путь к файлу клиентского сертификата (.crt)';
  SODKeyFileName = 'Путь к файлу клиентского ключа (.key)';
  SODSignKeyFileName = 'Путь к файлу ключа для подписи запросов (.pem)';
  SODKeyName = 'Название ключа для проверки подписи (опционально)';
  SODRetryCount = 'Количество попыток подтверждения документа';
  SODRetryTimeout = 'Время между попытками подтверждения документа, сек.';
  SItemnameLength = 'Кол-во используемых символов наименования товара (0 - использовать целиком)';
  SCheckFontNumber = 'Номер шрифта тела чека';
  SEnableNonFiscalHeader = 'Печатать заголовок нефиск. документа';
  SEnableNonFiscalFooter = 'Печатать окончание нефиск. документа';
  SFFD = 'ФФД';
  SKKTParams = 'Параметры ККТ';
  SKKTRetailDelivery = 'ККТ для развозной торговли';
  SFFDVersion = 'Версия ФФД';
  SODKKTSerialNumber = 'Заводской номер ККТ';
  SODKKTFNSerialNumber = 'Заводской номер ФН';
  SODKKTRNM = 'РНМ ККТ';
  SODSaleAddress = 'Адрес проведения расчетов';
  SODSaleLocation = 'Место проведения расчетов';
  SUseRepeatDocument = 'Для печати копии последнего документа использовать команду повтора документа';

{ TDevices }

function TDevices.GetFreeID: Integer;
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

function TDevices.GetItem(Index: Integer): TDevice;
begin
  Result := inherited Items[Index] as TDevice;
end;

function TDevices.ItemByID(ID: Integer): TDevice;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    Result := Items[i];
    if Result.ID = ID then Exit;
  end;
  Result := nil;
end;

{ TMitsuDrv1C }

constructor TMitsuDrv1C.Create;
begin
  inherited Create;
  FDriver := TMitsuDrv.Create;
  FReader := T1CXmlReaderWriter.Create;
  FParamList := TParamList1C.Create;
  CreateParamList;
end;

destructor TMitsuDrv1C.Destroy;
begin
  FReader.Free;
  FDriver.Free;
  FParamList.Free;
  inherited Destroy;
end;

procedure TMitsuDrv1C.ClearError;
begin
  FResultCode := 0;
  FResultDescription := 'Ошибок нет';
end;

procedure TMitsuDrv1C.HandleException(E: Exception);
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
    //FResultCode := E_UNKNOWN; !!!
    FResultDescription := E.Message;
  end;
  Logger.Error('HandleException: ' + IntToStr(FResultCode) + ', ' + FResultDescription);
end;

function TMitsuDrv1C.GetAdditionalDescription: WideString;
begin
  Result := Format('%.2xh, %s', [FResultCode, FResultDescription]);
end;

function TMitsuDrv1C.ReadValuesArray(const AValuesArray: IDispatch): T1CDriverParams;
var
  V: Variant;
begin
  V := AValuesArray;

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_PORT, Result.Port) then
    RaiseInvalidValue('Port');

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_SPEED, Result.Speed) then
    RaiseInvalidValue('Speed');

  if not GetStrParamValue(V, DRVFR_VALUE_INDEX_USERPASSWORD, Result.UserPassword) then
    RaiseInvalidValue('UserPassword');

  if not GetStrParamValue(V, DRVFR_VALUE_INDEX_ADMINPASSWORD, Result.AdminPassword) then
    RaiseInvalidValue('AdminPassword)');

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_TIMEOUT, Result.Timeout) then
    RaiseInvalidValue('Timeout');

  if not GetSingleParamValue(V, DRVFR_VALUE_INDEX_TAX1, Result.Tax[1]) then
    RaiseInvalidValue('Tax1');

  if not GetSingleParamValue(V, DRVFR_VALUE_INDEX_TAX2, Result.Tax[2]) then
    RaiseInvalidValue('Tax2');

  if not GetSingleParamValue(V, DRVFR_VALUE_INDEX_TAX3, Result.Tax[3]) then
    RaiseInvalidValue('Tax3');

  if not GetSingleParamValue(V, DRVFR_VALUE_INDEX_TAX4, Result.Tax[4]) then
    RaiseInvalidValue('Tax4');

  if not GetBoolParamValue(V, DRVFR_VALUE_INDEX_CLOSESESSION, Result.CloseSession) then
    RaiseInvalidValue('CloseSession');

  if not GetBoolParamValue(V, DRVFR_VALUE_INDEX_ENABLELOG, Result.EnableLog) then
    RaiseInvalidValue('EnableLog');

  if not GetStrParamValue(V, DRVFR_VALUE_INDEX_PAYNAME1, Result.PayNames[1]) then
    RaiseInvalidValue('PayName1');

  if not GetStrParamValue(V, DRVFR_VALUE_INDEX_PAYNAME2, Result.PayNames[2]) then
    RaiseInvalidValue('PayName2');

  if not GetBoolParamValue(V, DRVFR_VALUE_INDEX_PRINTLOGO, Result.PrintLogo) then
    Result.PrintLogo := DEF_PRINTLOGO;

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_LOGOSIZE, Result.LogoSize) then
    Result.LogoSize := DEF_LOGOSIZE;

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_CONNECTION_TYPE, Result.ConnectionType) then
    Result.ConnectionType := DEF_CONNECTION_TYPE;

  if not GetStrParamValue(V, DRVFR_VALUE_INDEX_COMPUTERNAME, Result.ComputerName) then
    Result.ComputerName := DEF_COMPUTERNAME;

  if not GetStrParamValue(V, DRVFR_VALUE_INDEX_IPADDRESS, Result.IPAddress) then
    Result.IPAddress := DEF_IPADDRESS;

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_TCPPORT, Result.TCPPort) then
    Result.TCPPort := DEF_TCPPORT;

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_PROTOCOLTYPE, Result.ProtocolType) then
    Result.ProtocolType := DEF_PROTOCOLTYPE;

  if not GetBoolParamValue(V, DRVFR_VALUE_INDEX_BUFFERSTRINGS, Result.BufferStrings) then
    Result.BufferStrings := DEF_BUFFERSTRINGS;
end;

function TMitsuDrv1C.ReadOutputParameters: AnsiString;

  function MTSDayStatusTo1C(DayStatus: Integer): Integer;
  begin
    case DayStatus of
      MTS_DAY_STATUS_CLOSED: Result := D1C_DS_CLOSED;
      MTS_DAY_STATUS_OPENED: Result := D1C_DS_OPENED;
      MTS_DAY_STATUS_EXPIRED: Result := D1C_DS_EXPIRED;
    else
      raise Exception.CreateFmt('Invalid day status value, %d', [DayStatus]);
    end;
  end;

var
  XmlText: WideString;
  FDStatus: TMTSFDStatus;
  DayStatus: TMTSDayStatus;
  Params: TOutputParametersRec;
  FDOStatus: TMTSFDOStatus;
  ReceiptTotals: TMTSDayTotals;
  CorrectionTotals: TMTSDayTotals;
begin
  Driver.Check(Driver.ReadFDStatus(FDStatus));
  Driver.Check(Driver.ReadDayStatus(DayStatus));
  Driver.Check(Driver.ReadFDOStatus(FDOStatus));
  Driver.Check(Driver.ReadDayTotalsReceipts(ReceiptTotals));
  Driver.Check(Driver.ReadDayTotalsCorrection(CorrectionTotals));

  Params.ShiftNumber := DayStatus.DayNumber;
  Params.CheckNumber := FDStatus.LastDoc;
  Params.ShiftState := MTSDayStatusTo1C(DayStatus.DayStatus);
  Params.DateTime := FDStatus.DocDate;
  Params.CashBalance :=
    ReceiptTotals.Sale.T1136 +
    ReceiptTotals.RetBuy.T1136 -
    ReceiptTotals.RetSale.T1136 -
    ReceiptTotals.Buy.T1136;

  Params.ShiftClosingCheckNumber := DayStatus.RecNumber;
  // Счетчики операций по типу "приход"
  Params.CountersOperationType1.CheckCount := ReceiptTotals.Sale.Count;
  Params.CountersOperationType1.TotalChecksAmount := ReceiptTotals.Sale.Total;
  Params.CountersOperationType1.CorrectionCheckCount := CorrectionTotals.Sale.Count;
  Params.CountersOperationType1.TotalCorrectionChecksAmount := CorrectionTotals.Sale.Total;
  // Счетчики операций по типу "возврат прихода"
  Params.CountersOperationType2.CheckCount := ReceiptTotals.RetSale.Count;
  Params.CountersOperationType2.TotalChecksAmount := ReceiptTotals.RetSale.Total;
  Params.CountersOperationType2.CorrectionCheckCount := CorrectionTotals.RetSale.Count;
  Params.CountersOperationType2.TotalCorrectionChecksAmount := CorrectionTotals.RetSale.Total;
  // Счетчики операций по типу "расход"
  Params.CountersOperationType3.CheckCount := ReceiptTotals.Buy.Count;
  Params.CountersOperationType3.TotalChecksAmount := ReceiptTotals.Buy.Total;
  Params.CountersOperationType3.CorrectionCheckCount := CorrectionTotals.Buy.Count;
  Params.CountersOperationType3.TotalCorrectionChecksAmount := CorrectionTotals.Buy.Total;
  // Счетчики операций по типу "возврат расхода"
  Params.CountersOperationType4.CheckCount := ReceiptTotals.RetBuy.Count;
  Params.CountersOperationType4.TotalChecksAmount := ReceiptTotals.RetBuy.Total;
  Params.CountersOperationType4.CorrectionCheckCount := CorrectionTotals.RetBuy.Count;
  Params.CountersOperationType4.TotalCorrectionChecksAmount := CorrectionTotals.RetBuy.Total;

  Params.BacklogDocumentsCounter := FDOStatus.DocCount;
  Params.BacklogDocumentFirstNumber := FDOStatus.FirstDoc;
  Params.BacklogDocumentFirstDateTime := FDOStatus.FirstDate;

  Params.FNError := TestBit(FDStatus.Flags, FD_NF_3_DAY_LEFT);
  Params.FNOverflow := TestBit(FDStatus.Flags, FD_NF_ALMOST_FULL);
  Params.FNFail := TestBit(FDStatus.Flags, FD_NF_30_DAYS_LEFT);
  Params.FNValidityDate := FDStatus.ValidDate;

  FReader.Write(XmlText, Params);
  Result := XmlText;
end;

procedure TMitsuDrv1C.SelectDevice(const DeviceID: string);
var
  ID: Integer;
  Device: TDevice;
begin
  Logger.Debug('SelectDevice DeviceID = ' + DeviceID);
  ID := 0;
  try
    ID := StrToInt(DeviceID);
  except
    //RaiseError(E_INVALIDPARAM, Format('%s %s', [GetRes(@SInvalidParam), '"DeviceID"'])); !!!
  end;

  Device := FDevices.ItemByID(ID);
  if Device = nil then
  begin
    Logger.Error(Format('Device "%s"  not found', [DeviceID]));
    //RaiseError(E_INVALIDPARAM, GetRes(@SDeviceNotActive));
  end;

  if Device <> FDevice then
  begin
    Driver.Disconnect;
    Driver.Params := Device.Params;
    FDevice := Device;
  end;
  Logger.Debug('SelectDevice.end');
end;

procedure TMitsuDrv1C.ReadParametersKKT(Params: TParametersKKT);
var
  Version: TMTSVersion;
  RegParams: TMTSRegParams;
begin
  Driver.Check(Driver.ReadRegParams(RegParams));
  Driver.Check(Driver.ReadDeviceVersion(Version));

  // //Регистрационный номер ККТ
  Params.KKTNumber := RegParams.FNParams.RegNumber;
  // Заводской номер ККТ
  Params.KKTSerialNumber := RegParams.SerialNumber;
  // Версия прошивки
  Params.FirmwareVersion := Version.Version;
  // Признак регистрации фискального накопителя
  Params.Fiscal := RegParams.RegNumber > 0;
  // Версия ФФД ФН (одно из следующих значений "1.0","1.1"
  Params.FFDVersionFN := RegParams.FFDVersionFD;
  // Версия ФФД ККТ (одно из следующих значений "1.0","1.0.5","1.1")
  Params.FFDVersionKKT := RegParams.FFDVersionFP;
  // Заводской номер ФН
  Params.FNSerialNumber := RegParams.FDSerial;
  // Номер документа регистрация фискального накопителя
  Params.DocumentNumber := IntToStr(RegParams.FDocNumber);
  // Дата и время операции регистрации фискального накопителя
  Params.DateTime := RegParams.DateTime;
  // Название организации
  Params.CompanyName := RegParams.FNParams.CompanyName;
  // ИНН организация
  Params.CompanyINN := RegParams.FNParams.CompanyINN;
  // Адрес проведения расчетов
  Params.SaleAddress := RegParams.FNParams.SaleAddress;
  // Место проведения расчетов
  Params.SaleLocation := RegParams.FNParams.SaleLocation;
  // Коды системы налогообложения через разделитель ",".
  Params.TaxSystems := RegParams.FNParams.TaxSystems;
  // Признак автономного режима
  Params.IsOffline := RegParams.FNParams.IsOffline;
  // Признак шифрование данных
  Params.IsEncrypted := RegParams.FNParams.IsEncrypted;
  // Признак расчетов за услуги
  Params.IsService := RegParams.FNParams.IsService;
  // Продажа подакцизного товара
  Params.IsExcisable := RegParams.FNParams.IsExcisable;
  // Признак проведения азартных игр
  Params.IsGambling := RegParams.FNParams.IsGambling;
  // Признак проведения лотереи
  Params.IsLottery := RegParams.FNParams.IsLottery;
  // Признак формирования АС БСО
  Params.IsBlank := RegParams.FNParams.IsBlank;
  // Признак установки принтера в автомате
  Params.IsAutomaticPrinter := RegParams.FNParams.IsAutomaticPrinter;
  // Признак автоматического режима
  Params.IsAutomatic := RegParams.FNParams.IsAutomatic;
  // Номер автомата для автоматического режима
  Params.AutomaticNumber := RegParams.FNParams.AutomaticNumber;
  // Название организации ОФД
  Params.OFDCompany := RegParams.FNParams.OFDCompany;
  // ИНН организации ОФД
  Params.OFDCompanyINN := RegParams.FNParams.OFDCompanyINN;
  // Адрес сайта уполномоченного органа (ФНС) в сети «Интернет»
  Params.FNSURL := RegParams.FNParams.FNSURL;
  // Адрес электронной почты отправителя чека
  Params.SenderEmail := RegParams.FNParams.SenderEmail;
  // Признак ККТ для расчетов в Интернет
  Params.IsOnline := RegParams.FNParams.IsOnline;
  // Признак применения при осуществлении торговли товарами, подлежащими обязательной маркировке средствами идентификации
  Params.IsMarking := RegParams.FNParams.IsMarking;
  // Признак применения при осуществлении ломбардами кредитования граждан
  Params.IsPawnshop := RegParams.FNParams.IsPawnshop;
  // Признак применения при осуществлении деятельности по страхованию
  Params.IsInsurance := RegParams.FNParams.IsInsurance;
  // Признак применения в автоматическом торговом автомате
  Params.IsVendingMachine := RegParams.FNParams.IsVendingMachine;
  // Признак применения при оказании услуг общественного питания
  Params.IsCatering := RegParams.FNParams.IsCatering;
  // Признак применения о оптовой торговле с организациями и ИП
  Params.IsWholesale := RegParams.FNParams.IsWholesale;
  // Коды признаков агента через разделитель ",".
  Params.AgentTypes := '';
end;

function TMitsuDrv1C.GetDataKKT(const DeviceID: WideString;
  out TableParametersKKT: WideString): WordBool;
var
  Params: TParametersKKT;
begin
  Logger.Debug('GetDataKKT DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  Params := TParametersKKT.Create;
  try
    SelectDevice(DeviceID);
    ReadParametersKKT(Params);
    FReader.Write(TableParametersKKT, Params);
    Logger.Debug('TableParametersKKT  ' + TableParametersKKT);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
      Logger.Error('GetDataKKT, ' + E.Message);
    end;
  end;
  Logger.Debug('GetDataKKT.end');
  Params.Free;
end;

function TMitsuDrv1C.OperationFN(const DeviceID: WideString;
  OperationType: Integer; const ParametersFiscal: WideString): WordBool;
var
  FNParams: TFNParams;
  Params: TParametersFiscal;
begin
  Logger.Debug('OperationFN');
  ClearError;
  Result := True;
  Params := TParametersFiscal.Create;
  try
    SelectDevice(DeviceID);
    FReader.Read(ParametersFiscal, Params);

    FNParams.IsMarking := Params.IsMarking;
    FNParams.IsPawnshop := Params.IsPawnshop;
    FNParams.IsInsurance := Params.IsInsurance;
    FNParams.IsCatering := Params.IsCatering;
    FNParams.IsWholesale := Params.IsWholesale;
    FNParams.IsAutomaticPrinter := Params.IsAutomaticPrinter;
    FNParams.IsAutomatic := Params.IsAutomatic;
    FNParams.IsOffline := Params.IsOffline;
    FNParams.IsEncrypted := Params.IsEncrypted;
    FNParams.IsOnline := Params.IsOnline;
    FNParams.IsService := Params.IsService;
    FNParams.IsBlank := Params.IsBlank;
    FNParams.IsLottery := Params.IsLottery;
    FNParams.IsGambling := Params.IsGambling;
    FNParams.IsExcisable := Params.IsExcisable;
    FNParams.IsVendingMachine := Params.IsVendingMachine;
    FNParams.SaleAddress := Params.SaleAddress;
    FNParams.SaleLocation := Params.SaleLocation;
    FNParams.OFDCompany := Params.OFDCompany;
    FNParams.OFDCompanyINN := Params.OFDCompanyINN;
    FNParams.FNSURL := Params.FNSURL;
    FNParams.CompanyName := Params.CompanyName;
    FNParams.CompanyINN := Params.CompanyINN;
    FNParams.SenderEmail := Params.SenderEmail;
    FNParams.AutomaticNumber := Params.AutomaticNumber;
    FNParams.ExtendedProperty := '';
    FNParams.ExtendedData := '';
    FNParams.TaxSystems := Params.TaxSystems;
    //FNParams.RegNumber := Params.RegNumber; !!!

    case OperationType of
      D1C_FNOT_OPEN: Driver.Check(Driver.FNOpen(FNParams));
      D1C_FNOT_CHANGE: Driver.Check(Driver.FNChange(FNParams));
      D1C_FNOT_CLOSE: Driver.Check(Driver.FNClose(FNParams));
    else
      raise Exception.CreateFmt('Invalid OperationType parameter value, %d', [OperationType]);
    end;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
      Logger.Error('OperationFN Error ' + E.Message);
    end;
  end;
  Params.Free;
  Logger.Debug('OperationFN.end');
end;

function TMitsuDrv1C.GetInterfaceRevision: Integer;
begin
  Result := 4001;
end;

function TMitsuDrv1C.GetDescription(
  out DriverDescription: WideString): WordBool;
var
  Xml: IXMLDocument;
  Node: IXMLNode;
  LogEnabled: Boolean;
  ver: string;
begin
  Logger.Debug('GetDescription');
  ver := '4.1';

  Result := True;
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('DriverDescription');
    {$IFDEF WIN64}
    Node.Attributes['Name'] := 'Штрих-М: Драйвер ККТ с передачей данных в ОФД ' + ver + ' (Win64)';
    Node.Attributes['Description'] := 'Штрих-М: Драйвер ККТ с передачей данных в ОФД ' + ver + ' (Win64)';
    {$ELSE}
    Node.Attributes['Name'] := 'Штрих-М: Драйвер ККТ с передачей данных в ОФД ' + ver + ' (Win32)';
    Node.Attributes['Description'] := 'Штрих-М: Драйвер ККТ с передачей данных в ОФД ' + ver + ' (Win32)';
    {$ENDIF}
    Node.Attributes['EquipmentType'] := 'ККТ';
    Node.Attributes['IntegrationComponent'] := 'true';
    Node.Attributes['MainDriverInstalled'] := 'true';
    Node.Attributes['DriverVersion'] := GetFileVersionInfoStr;
    Node.Attributes['IntegrationComponentVersion'] := GetFileVersionInfoStr;
    Node.Attributes['DownloadURL'] := 'http://www.shtrih-m.ru/support/download/?section_id=76&product_id=all&type_id=156';
    //Node.Attributes['LogPath'] := Driver.Params.LogPath;
    //Node.Attributes['LogIsEnabled'] := to1CBool(Driver.Params.LogEnabled); !!!
    DriverDescription := Xml.XML.Text;
  finally
    Xml := nil;
  end;
  Logger.Debug('GetDescription.end');
end;


function TMitsuDrv1C.GetLastError(
  out ErrorDescription: WideString): Integer;
begin
  ErrorDescription := Format('%.2xh, %s', [FResultCode, FResultDescription]);
  Result := FResultCode;
  Logger.Debug('GetLastError ' + ErrorDescription);
end;

function TMitsuDrv1C.GetParameters(
  out TableParameters: WideString): WordBool;
begin
  Logger.Debug('GetParameters');
  TableParameters := FParamList.ToString;
  Result := True;
end;

procedure TMitsuDrv1C.CreateParamList;
var
  Page: TParamList1CPage;
  Group: TParamList1CGroup;
  Item: TParamList1CItem;
  ChoiceListItem: TParam1CChoiceListItem;
  i: Integer;
resourcestring
  SConnectionParams = 'Параметры связи';
  SConnectionType = 'Тип подключения';
  SProtocolType = 'Тип протокола';
  SStandard = 'Стандартный';
  SProtocol2 = 'Протокол ККТ 2.0';
  SPort = 'Порт';
  SBaudrate = 'Скорость';
  STimevar = 'Таймаут';
  SComputerName = 'Имя компьютера';
  SIPAddress = 'IP адрес';
  STCPPort = 'TCP порт';
  SDeviceParams = 'Параметры устройства';
  SAdminPassword = 'Пароль администратора';
  SCloseSession = 'Закрывать смену для программирования налоговых ставок (в случае некорректных значений)';
  SBufferStrings = 'Буферизировать строки';
  SBarcodeFirstLine = 'Номер линии для загрузки QR Code';
  SQRCodeHeight = 'Высота QR Code, точек';
  SQRCodeDotWidth = 'Толщина точки QR Code (3-8)';
  SCheckClock = 'Синхронизировать часы ККТ перед открытием смены';
  SReceiptFormat = 'Формат чека';
  SEnablePaymentSignPrint = 'Печатать признак и способ расчета (ФФД 1.05)';
  SDisablePrintReports = 'Не печатать фискальные отчеты и чеки внесения/выемки на бумаге';
  SLogParams = 'Настройка лога';
  SEnableLog = 'Вести лог (путь к логу настраивается через тест драйвера)';
  SLogPath = 'Путь к файлу лога';
  STaxRates = 'Налоговые ставки и типы оплат';
  STax1 = 'Наименование ставки НДС 18 %';
  STax2 = 'Наименование ставки НДС 10%';
  STax3 = 'Наименование ставки НДС 0%';
  STax4 = 'Наименование ставки БЕЗ НДС';
  STax5 = 'Наименование ставки НДС 18/118';
  STax6 = 'Наименование ставки НДС 10/110';
  SPayName1 = 'Тип безнал. оплаты 1';
  SPayName2 = 'Тип безнал. оплаты 2';
  SPayName3 = 'Тип безнал. оплаты 3';
  SCashiers = 'Кассиры';
  SCashier = 'Кассир';
  SPassword = 'Пароль кассира';
  SPayName1DefaultValue = 'ПЛАТ.КАРТОЙ';
  SPayName2DefaultValue = 'КРЕДИТОМ';
  SPayName3DefaultValue = 'СЕРТИФИКАТОМ';
  SCodepage = 'Кодировка';
  SCodepageDef = 'Нет перекодировки';
  SCodepageRussian = 'Русская';
  SCodepageArmenianUnicode = 'Армянская UNICODE';
  SCodepageArmenianAnsi = 'Армянская ANSI';
  SCodePageKazakhUnicode = 'Казахская UNICODE';
  SCodepageTurkmenUnicode = 'Туркменская UNICODE';
  SOrangeData = 'Orange Data';
  SOrangeData2 = 'Orange Data 2';
  SOrangeDataConnection = 'Параметры подключения';
  SODEnabled = 'Включить передачу данных в Orange Data';
  SODTaxOSN = 'ОСН';
  SODTaxUSND = 'УСН доход';
  SODTaxUSNDMR = 'УСН доход минус расход';
  SODTaxENVD = 'ЕНВД';
  SODTaxESN = 'ЕСН';
  SODTaxPSN = 'ПСН';
  SODTax = 'Системы налогообложения';
  SODServerURL = 'URL сервера';
  SODINN = 'ИНН';
  SODGroup = 'Группа';
  SODCertFileName = 'Путь к файлу клиентского сертификата (.crt)';
  SODKeyFileName = 'Путь к файлу клиентского ключа (.key)';
  SODSignKeyFileName = 'Путь к файлу ключа для подписи запросов (.pem)';
  SODKeyName = 'Название ключа для проверки подписи (опционально)';
  SODRetryCount = 'Количество попыток подтверждения документа';
  SODRetryTimevar = 'Время между попытками подтверждения документа, сек.';
  SODWorkMode = 'Режим работы ККТ';
  SODIsOffline = 'Признак автономного режима';
  SODIsEncrypted = 'Признак шифрование данных';
  SODIsService = 'Признак расчетов за услуги';
  SODIsExcisable = 'Признак продажи подакцизного товара';
  SODIsGambling = 'Признак проведения азартных игр';
  SODIsLottery = 'Признак проведения лотереи';
  SODBSOSing = 'Признак формирования АС БСО';
  SODIsOnline = 'Признак ККТ для расчетов в Интернет';
  SODIsAutomaticPrinter = 'Признак установки принтера в автомате';
  SODAutomaticNumber = 'Номер автомата для автоматического режима';
  SODIsAutomatic = 'Признак автоматического режима';
  SODIsMarking = 'Признак торговли маркированными товарами';
  SODIsPawnshop = 'Признак ломбардной деятельности';
  SODIsAssurance = 'Признак страховой деятельности';
  SItemnameLength = 'Кол-во используемых символов наименования товара (0 - использовать целиком)';
  SCheckFontNumber = 'Номер шрифта тела чека';
  SKgKKT = 'Kg ККТ';
  SKgKKTEnabled = 'Работать с Kg KKT';
  SKgKKTUrl = 'URL ККТ в формате http://192.168.137.111:80';
begin
  // СТРАНИЦА Параметры связи
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SConnectionParams);
  { --- Параметры связи --- }
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SConnectionParams); // 'Параметры связи';
  // Тип подключения
  Item := Group.Items.Add;
  Item.Name := 'ConnectionType';
  Item.Caption := GetRes(@SConnectionType);
  Item.Description := GetRes(@SConnectionType);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';
  for i := Low(Driver.ValidConnectionTypes) to High(Driver.ValidConnectionTypes) do
    Item.AddChoiceListItem(ConnectionTypeToStr(ConnectionTypes[i]), IntToSTr(ConnectionTypes[i]));
  // Тип протокола
  Item := Group.Items.Add;
  Item.Name := 'ProtocolType';
  Item.Caption := GetRes(@SProtocolType);
  Item.Description := GetRes(@SProtocolType);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';
  Item.AddChoiceListItem(GetRes(@SStandard), '0');
  Item.AddChoiceListItem(GetRes(@SProtocol2), '1');
  // Порт
  Item := Group.Items.Add;
  Item.Name := 'Port';
  Item.Caption := GetRes(@SPort);
  Item.Description := GetRes(@SPort);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '1';
  for i := 1 to 256 do
    Item.AddChoiceListItem('COM' + IntToStr(i), IntToStr(i));
  // Baudrate
  Item := Group.Items.Add;
  Item.Name := 'Baudrate';
  Item.Caption := GetRes(@SBaudrate);
  Item.Description := GetRes(@SBaudrate);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '115200';
  for i := Low(Driver.ValidBaudRates) to High(Driver.ValidBaudRates) do
  begin
    ChoiceListItem := Item.ChoiceList.Add;
    ChoiceListItem.Name := IntToStr(i);
    ChoiceListItem.Value := IntToStr(i);
  end;
  //Таймаут
  Item := Group.Items.Add;
  Item.Name := 'Timeout';
  Item.Caption := GetRes(@STimeout);
  Item.Description := GetRes(@STimeout);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '10000';
  //Computer name
  Item := Group.Items.Add;
  Item.Name := 'ComputerName';
  Item.Caption := GetRes(@SComputerName);
  Item.Description := GetRes(@SComputerName);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';
  //IP адрес
  Item := Group.Items.Add;
  Item.Name := 'IPAddress';
  Item.Caption := GetRes(@SIPAddress);
  Item.Description := GetRes(@SIPAddress);
  Item.TypeValue := 'String';
  Item.DefaultValue := '192.168.137.111';
  //TCP Port
  Item := Group.Items.Add;
  Item.Name := 'TCPPort';
  Item.Caption := GetRes(@STCPPort);
  Item.Description := GetRes(@STCPPort);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '7778';

  // СТРАНИЦА Параметры Устройства
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SDeviceParams);
  { --- Параметры устройства --- }
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SDeviceParams);
  // Пароль администратора
  Item := Group.Items.Add;
  Item.Name := 'AdminPassword';
  Item.Caption := GetRes(@SAdminPassword);
  Item.Description := GetRes(@SAdminPassword);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '30';
{  // Буферизировать строки
  Item := Group.Items.Add;
  Item.Name := 'BufferStrings';
  Item.Caption := GetRes(@SBufferStrings);
  Item.Description := GetRes(@SBufferStrings);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'True';}

  // Печать QR
{  Item := Group.Items.Add;
  Item.Name := 'BarcodeFirstLine';
  Item.Caption := GetRes(@SBarcodeFirstLine);
  Item.Description := GetRes(@SBarcodeFirstLine);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '1';}
  //
  {Item := Group.Items.Add;
  Item.Name := 'QRCodeHeight';
  Item.Caption := GetRes(@SQRCodeHeight);
  Item.Description := GetRes(@SQRCodeHeight);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '200';}
  Item := Group.Items.Add;
  Item.Name := 'QRCodeDotWidth';
  Item.Caption := GetRes(@SQRCodeDotWidth);
  Item.Description := GetRes(@SQRCodeDotWidth);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '5';

  Item := Group.Items.Add;
  Item.Name := 'CheckClock';
  Item.Caption := GetRes(@SCheckClock);
  Item.Description := GetRes(@SCheckClock);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

(*
  // СТРАНИЦА Налоговые ставки и типы оплат
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@STaxRates);

  { --- Налоговые ставки и типы оплат --- }
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@STaxRates);
  // Закрывать смену
  Item := Group.Items.Add;
  Item.Name := 'CloseSession';
  Item.Caption := GetRes(@SCloseSession);
  Item.Description := GetRes(@SCloseSession);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'True';
  // Наименование типа оплаты 1
  Item := Group.Items.Add;
  Item.Name := 'PayName1';
  Item.Caption := GetRes(@SPayName1);
  Item.Description := GetRes(@SPayName1);
  Item.TypeValue := 'String';
  Item.DefaultValue := GetRes(@SPayName1DefaultValue);
  // Наименование типа оплаты 2
  Item := Group.Items.Add;
  Item.Name := 'PayName2';
  Item.Caption := GetRes(@SPayName2);
  Item.Description := GetRes(@SPayName2);
  Item.TypeValue := 'String';
  Item.DefaultValue := GetRes(@SPayName2DefaultValue);
  // Наименование типа оплаты 3
  Item := Group.Items.Add;
  Item.Name := 'PayName3';
  Item.Caption := GetRes(@SPayName3);
  Item.Description := GetRes(@SPayName3);
  Item.TypeValue := 'String';
  Item.DefaultValue := GetRes(@SPayName3DefaultValue);

*)

(*  // СТРАНИЦА Настройка лога
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SLogParams);
  { --- Настройка лога --- }
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SLogParams);
  // Лог
  Item := Group.Items.Add;
  Item.Name := 'EnableLog';
  Item.Caption := GetRes(@SEnableLog);
  Item.Description := GetRes(@SEnableLog);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';*)

{  Item := Group.Items.Add;
  Item.Name := 'LogFileName';
  Item.Caption := GetRes(@SLogPath);
  Item.Description := GetRes(@SLogPath);
  Item.TypeValue := 'String';
  Item.DefaultValue := FDriver.ComLogFile;}

  // СТРАНИЦА ФОРМАТ ЧЕКА
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SReceiptFormat);
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SReceiptFormat);

  Item := Group.Items.Add;
  Item.Name := 'DisablePrintReports';
  Item.Caption := GetRes(@SDisablePrintReports);
  Item.Description := GetRes(@SDisablePrintReports);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'EnablePaymentSignPrint';
  Item.Caption := GetRes(@SEnablePaymentSignPrint);
  Item.Description := GetRes(@SEnablePaymentSignPrint);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'True';

  Item := Group.Items.Add;
  Item.Name := 'ItemNameLength';
  Item.Caption := GetRes(@SItemNameLength);
  Item.Description := GetRes(@SItemNameLength);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';

  Item := Group.Items.Add;
  Item.Name := 'CheckFontNumber';
  Item.Caption := GetRes(@SCheckFontNumber);
  Item.Description := GetRes(@SCheckFontNumber);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '1';

  Item := Group.Items.Add;
  Item.Name := 'EnableNonFiscalHeader';
  Item.Caption := GetRes(@SEnableNonFiscalHeader);
  Item.Description := GetRes(@SEnableNonFiscalHeader);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'True';

  Item := Group.Items.Add;
  Item.Name := 'EnableNonFiscalFooter';
  Item.Caption := GetRes(@SEnableNonFiscalFooter);
  Item.Description := GetRes(@SEnableNonFiscalFooter);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'True';

  Item := Group.Items.Add;
  Item.Name := 'UseRepeatDocument';
  Item.Caption := GetRes(@SUseRepeatDocument);
  Item.Description := GetRes(@SUseRepeatDocument);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  {  ORANGE DATA  }
  // Orange data
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SOrangeData);
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SOrangeDataConnection);

  Item := Group.Items.Add;
  Item.Name := 'ODEnabled';
  Item.Caption := GetRes(@SODEnabled);
  Item.Description := GetRes(@SODEnabled);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'ODServerURL';
  Item.Caption := GetRes(@SODServerURL);
  Item.Description := GetRes(@SODServerURL);
  Item.TypeValue := 'String';
  Item.DefaultValue := 'https://apip.orangedata.ru:2443/api/v2/';

  Item := Group.Items.Add;
  Item.Name := 'ODINN';
  Item.Caption := GetRes(@SODINN);
  Item.Description := GetRes(@SODINN);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODGroup';
  Item.Caption := GetRes(@SODGroup);
  Item.Description := GetRes(@SODGroup);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODCertFileName';
  Item.Caption := GetRes(@SODCertFileName);
  Item.Description := GetRes(@SODCertFileName);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODKeyFileName';
  Item.Caption := GetRes(@SODKeyFileName);
  Item.Description := GetRes(@SODKeyFileName);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODSignKeyFileName';
  Item.Caption := GetRes(@SODSignKeyFileName);
  Item.Description := GetRes(@SODSignKeyFileName);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODKeyName';
  Item.Caption := GetRes(@SODKeyName);
  Item.Description := GetRes(@SODKeyName);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODRetryCount';
  Item.Caption := GetRes(@SODRetryCount);
  Item.Description := GetRes(@SODRetryCount);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '10';

  Item := Group.Items.Add;
  Item.Name := 'ODRetryTimeout';
  Item.Caption := GetRes(@SODRetryTimeout);
  Item.Description := GetRes(@SODRetryTimeout);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '2';

  {  ORANGE DATA 2  }
  // Orange data
 { Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SOrangeData2);
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SOrangeData2);}

  Item := Group.Items.Add;
  Item.Name := 'ODFFDVersion';
  Item.Caption := GetRes(@SFFDVersion);
  Item.Description := GetRes(@SFFDVersion);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '4';
  Item.AddChoiceListItem('ФФД 1.05', '2');
  Item.AddChoiceListItem('ФФД 1.2', '4');

  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SKKTParams);

  Item := Group.Items.Add;
  Item.Name := 'ODFFDVersion';
  Item.Caption := GetRes(@SFFDVersion);
  Item.Description := GetRes(@SFFDVersion);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '4';
  Item.AddChoiceListItem('ФФД 1.05', '2');
  Item.AddChoiceListItem('ФФД 1.2', '4');

  Item := Group.Items.Add;
  Item.Name := 'ODKKTRetailDelivery';
  Item.Caption := GetRes(@SKKTRetailDelivery);
  Item.Description := GetRes(@SKKTRetailDelivery);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'ODKKTSerialNumber';
  Item.Caption := GetRes(@SODKKTSerialNumber);
  Item.Description := GetRes(@SODKKTSerialNumber);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODKKTRNM';
  Item.Caption := GetRes(@SODKKTRNM);
  Item.Description := GetRes(@SODKKTRNM);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODKKTFNSerialNumber';
  Item.Caption := GetRes(@SODKKTFNSerialNumber);
  Item.Description := GetRes(@SODKKTFNSerialNumber);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODSaleAddress';
  Item.Caption := GetRes(@SODSaleAddress);
  Item.Description := GetRes(@SODSaleAddress);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODSaleLocation';
  Item.Caption := GetRes(@SODSaleLocation);
  Item.Description := GetRes(@SODSaleLocation);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SODTax);

  Item := Group.Items.Add;
  Item.Name := 'ODTaxOSN';
  Item.Caption := GetRes(@SODTaxOSN);
  Item.Description := GetRes(@SODTaxOSN);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'True';

  Item := Group.Items.Add;
  Item.Name := 'ODTaxUSND';
  Item.Caption := GetRes(@SODTaxUSND);
  Item.Description := GetRes(@SODTaxUSND);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'ODTaxUSNDMR';
  Item.Caption := GetRes(@SODTaxUSNDMR);
  Item.Description := GetRes(@SODTaxUSNDMR);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'ODTaxENVD';
  Item.Caption := GetRes(@SODTaxENVD);
  Item.Description := GetRes(@SODTaxENVD);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'ODTaxESN';
  Item.Caption := GetRes(@SODTaxESN);
  Item.Description := GetRes(@SODTaxESN);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'ODTaxPSN';
  Item.Caption := GetRes(@SODTaxPSN);
  Item.Description := GetRes(@SODTaxPSN);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  {OD Режим работы}
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SODWorkMode);

  // Признак автономного режима
  Item := Group.Items.Add;
  Item.Name := 'ODIsOffline';
  Item.Caption := GetRes(@SODIsOffline);
  Item.Description := GetRes(@SODIsOffline);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  // Признак шифрование данных
  Item := Group.Items.Add;
  Item.Name := 'ODIsEncrypted';
  Item.Caption := GetRes(@SODIsEncrypted);
  Item.Description := GetRes(@SODIsEncrypted);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  // Признак расчетов за услуги
  Item := Group.Items.Add;
  Item.Name := 'ODIsService';
  Item.Caption := GetRes(@SODIsService);
  Item.Description := GetRes(@SODIsService);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  // Признак продажи подакцизного товара
  Item := Group.Items.Add;
  Item.Name := 'ODIsExcisable';
  Item.Caption := GetRes(@SODIsExcisable);
  Item.Description := GetRes(@SODIsExcisable);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  // Признак проведения азартных игр
  Item := Group.Items.Add;
  Item.Name := 'ODIsGambling';
  Item.Caption := GetRes(@SODIsGambling);
  Item.Description := GetRes(@SODIsGambling);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  // Признак Признак проведения лотереи
  Item := Group.Items.Add;
  Item.Name := 'ODIsLottery';
  Item.Caption := GetRes(@SODIsLottery);
  Item.Description := GetRes(@SODIsLottery);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  // Признак формирования АС БСО
  Item := Group.Items.Add;
  Item.Name := 'ODBSOSing';
  Item.Caption := GetRes(@SODBSOSing);
  Item.Description := GetRes(@SODBSOSing);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  // Признак ККТ для расчетов в Интернет
  Item := Group.Items.Add;
  Item.Name := 'ODIsOnline';
  Item.Caption := GetRes(@SODIsOnline);
  Item.Description := GetRes(@SODIsOnline);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  // Признак установки принтера в автомате
  Item := Group.Items.Add;
  Item.Name := 'ODIsAutomaticPrinter';
  Item.Caption := GetRes(@SODIsAutomaticPrinter);
  Item.Description := GetRes(@SODIsAutomaticPrinter);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  // Признак автоматического режима
  Item := Group.Items.Add;
  Item.Name := 'ODIsAutomatic';
  Item.Caption := GetRes(@SODIsAutomatic);
  Item.Description := GetRes(@SODIsAutomatic);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  // Номер автомата автоматического режима
  Item := Group.Items.Add;
  Item.Name := 'ODAutomaticNumber';
  Item.Caption := GetRes(@SODAutomaticNumber);
  Item.Description := GetRes(@SODAutomaticNumber);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  // Признак применения при осуществлении торговли товарами, подлежащими обязательной маркировке средствами идентификации
  Item := Group.Items.Add;
  Item.Name := 'ODIsMarking';
  Item.Caption := GetRes(@SODIsMarking);
  Item.Description := GetRes(@SODIsMarking);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  // Признак применения при осуществлении ломбардами кредитования граждан
  Item := Group.Items.Add;
  Item.Name := 'ODIsPawnshop';
  Item.Caption := GetRes(@SODIsPawnshop);
  Item.Description := GetRes(@SODIsPawnshop);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  // Признак применения при осуществлении деятельности по страхованию
  Item := Group.Items.Add;
  Item.Name := 'ODIsAssurance';
  Item.Caption := GetRes(@SODIsAssurance);
  Item.Description := GetRes(@SODIsAssurance);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

 { KG KKT  }

//  if FFormatVersion < 34 then
//  begin
    // Kg
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SKgKKT);
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SKgKKT);

  Item := Group.Items.Add;
  Item.Name := 'KgKKTEnabled';
  Item.Caption := GetRes(@SKgKKTEnabled);
  Item.Description := GetRes(@SKgKKTEnabled);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'KgKKTUrl';
  Item.Caption := GetRes(@SKgKKTUrl);
  Item.Description := GetRes(@SKgKKTUrl);
  Item.TypeValue := 'String';
  Item.DefaultValue := 'http://192.168.137.111:80';
//  end;
end;

function TMitsuDrv1C.SetParameter(const Name: WideString; Value: OleVariant): WordBool;
begin
  //GlobalLogger.FileName := 'c:\Users\User\AppData\Roaming\SHTRIH-M\log2.txt';
//  GlobalLogger.Enabled := True;
  Logger.Debug('SetParameter  ' + Name + ' ' + Value);
  Result := True;
  try
  (*
    if WideSameStr('ConnectionType', Name) then
      FParams.ConnectionType := Value;
    if WideSameStr('ProtocolType', Name) then
      FParams.ProtocolType := Value;
    if WideSameStr('Port', Name) then
      FParams.Port := Value;
    if WideSameStr('Baudrate', Name) then
      FParams.Baudrate := Value;
    if WideSameStr('Timeout', Name) then
      FParams.Timeout := Value;
    if WideSameStr('IPAddress', Name) then
      FParams.IPAddress := Value;
    if WideSameStr('ComputerName', Name) then
      FParams.ComputerName := Value;
    if WideSameStr('TCPPort', Name) then
      FParams.TCPPort := Value;
    if WideSameStr('AdminPassword', Name) then
      FParams.AdminPassword := Value;
    if WideSameStr('QRCodeDotWidth', Name) then
      FParams.QRCodeDotWidth := Value;

    if WideSameStr('EnablePaymentSignPrint', Name) then
      FParams.EnablePaymentSignPrint := (WideSameText('True', Value)) or (WideSameText('1', Value));

    if WideSameStr('ODEnabled', Name) then
      FParams.ODEnabled := (WideSameText('True', Value)) or (WideSameText('1', Value));

    if WideSameStr('ODServerURL', Name) then
      FParams.ODServerURL := Value;

    if WideSameStr('ODINN', Name) then
      FParams.ODINN := Value;

    if WideSameStr('ODGroup', Name) then
      FParams.ODGroup := Value;

    if WideSameStr('ODCertFileName', Name) then
      FParams.ODCertFileName := Value;

    if WideSameStr('ODKeyFileName', Name) then
      FParams.ODKeyFileName := Value;

    if WideSameStr('ODSignKeyFileName', Name) then
      FParams.ODSignKeyFileName := Value;

    if WideSameStr('ODKeyName', Name) then
      FParams.ODKeyName := Value;

    if WideSameStr('ODRetryCount', Name) then
      FParams.ODRetryCount := Value;

    if WideSameStr('ODRetryTimeout', Name) then
      FParams.ODRetryTimeout := Value;

    if WideSameStr('ItemNameLength', Name) then
      FParams.ItemNameLength := Value;

    if WideSameStr('CheckFontNumber', Name) then
      FParams.CheckFontNumber := Value;

    if WideSameStr('ODFFDVersion', Name) then
      FParams.ODFFDVersion := StrToInt(Value);

    if WideSameStr('ODTaxOSN', Name) then
      FParams.ODTaxOSN := Value;

    if WideSameStr('ODTaxUSND', Name) then
      FParams.ODTaxUSND := Value;

    if WideSameStr('ODTaxUSNDMR', Name) then
      FParams.ODTaxUSNDMR := Value;

    if WideSameStr('ODTaxENVD', Name) then
      FParams.ODTaxENVD := Value;

    if WideSameStr('ODTaxESN', Name) then
      FParams.ODTaxESN := Value;

    if WideSameStr('ODTaxPSN', Name) then
      FParams.ODTaxPSN := Value;

    if WideSameStr('EnableNonFiscalHeader', Name) then
      FParams.EnableNonFiscalHeader := Value;

    if WideSameStr('EnableNonFiscalFooter', Name) then
      FParams.EnableNonFiscalFooter := Value;

    if WideSameStr('DisablePrintReports', Name) then
      FParams.DisablePrintReports := Value;

    if WideSameStr('CheckClock', Name) then
      FParams.CheckClock := Value;

    if WideSameStr('ODKKTRetailDelivery', Name) then
      FParams.ODKKTRetailDelivery := Value;

    if WideSameStr('ODKKTSerialNumber', Name) then
      FParams.ODKKTSerialNumber := Value;

    if WideSameStr('ODKKTRNM', Name) then
      FParams.ODKKTRNM := Value;

    if WideSameStr('ODKKTFNSerialNumber', Name) then
      FParams.ODKKTFNSerialNumber := Value;

    if WideSameStr('ODAutomaticNumber', Name) then
      FParams.ODAutomaticNumber := Value;

    if WideSameStr('ODIsOffline', Name) then
      FParams.ODIsOffline := Value;

    if WideSameStr('ODIsEncrypted', Name) then
      FParams.ODIsEncrypted := Value;

    if WideSameStr('ODIsService', Name) then
      FParams.ODIsService := Value;

    if WideSameStr('ODIsExcisable', Name) then
      FParams.ODIsExcisable := Value;

    if WideSameStr('ODIsGambling', Name) then
      FParams.ODIsGambling := Value;

    if WideSameStr('ODIsLottery', Name) then
      FParams.ODIsLottery := Value;

    if WideSameStr('ODBSOSing', Name) then
      FParams.ODBSOSing := Value;

    if WideSameStr('ODIsOnline', Name) then
      FParams.ODIsOnline := Value;

    if WideSameStr('ODIsAutomaticPrinter', Name) then
      FParams.ODIsAutomaticPrinter := Value;

    if WideSameStr('ODIsAutomatic', Name) then
      FParams.ODIsAutomatic := Value;

    if WideSameStr('ODIsMarking', Name) then
      FParams.ODIsMarking := Value;

    if WideSameStr('ODIsPawnshop', Name) then
      FParams.ODIsPawnshop := Value;

    if WideSameStr('ODIsAssurance', Name) then
      FParams.ODIsAssurance := Value;

    if WideSameStr('ODSaleAddress', Name) then
      FParams.ODSaleAddress := Value;

    if WideSameStr('ODSaleLocation', Name) then
      FParams.ODSaleLocation := Value;

    if WideSameStr('KgKKTEnabled', Name) then
      FParams.KgKKTEnabled := Value;

    if WideSameStr('KgKKTUrl', Name) then
      FParams.KgKKTUrl := Value;

    if WideSameStr('UseRepeatDocument', Name) then
      FParams.UseRepeatDocument := Value;
  *)
  except
    on E: Exception do
    begin
      Logger.Error('SetParameter Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('SetParameter.end');
end;

function TMitsuDrv1C.Open(out DeviceID: WideString): WordBool;
var
  ADevice: TDevice;
begin
  Logger.Debug('Open');
  Result := True;
  ADevice := nil;
  try
    Driver.Disconnect;
    ADevice := TDevice.Create(Devices);
    ADevice.FParams := FParams;
    DeviceID := IntToStr(ADevice.ID);
    Logger.Debug('Open DeviceID = ' + DeviceID);
    Driver.Params := FParams;
    Driver.Check(Driver.Connect);
    FDevice := ADevice;
  except
    on E: Exception do
    begin
      ADevice.Free;
      Result := False;
      Logger.Error('Open Error ' + E.Message);
      HandleException(E);
    end;
  end;
  Logger.Debug('Open.end');
end;

function TMitsuDrv1C.Close(const DeviceID: WideString): WordBool;
var
  i: Integer;
begin
  Logger.Debug('Close DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    FDevice.Free;
    FDevice := nil;
    Logger.Debug('Device deleted');
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
      Logger.Error('Close Error ' + E.Message);
    end;
  end;
  Logger.Debug('Close.end');
end;

function TMitsuDrv1C.CashInOutcome(const DeviceID,
  InputParameters: WideString; Amount: Double): WordBool;
var
  Params: TInputParametersRec;
begin
  Logger.Debug('CashInOutcome DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Params := FReader.Read(InputParameters);

    Driver.LockPort;
    try
      //Driver.PrintCashOperation(Amount, Params);
      Driver.WaitForPrinting;
    finally
      Driver.UnlockPort;
    end;


  except
    on E: Exception do
    begin
      Logger.Error('CashInOutcome Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('CashInOutcome.end');
end;

function TMitsuDrv1C.CloseSessionRegistrationKM(
  const DeviceID: WideString): WordBool;
begin

end;

function TMitsuDrv1C.CloseShift(const DeviceID,
  InputParameters: WideString; out OutputParameters: WideString): WordBool;
var
  Cashier: TMTSCashier;
  Status: TMTSDayStatus;
  DayParams: TMTSDayParams;
  InParams: TInputParametersRec;
begin
  Logger.Debug('CloseShift DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    InParams := FReader.Read(InputParameters);
    Driver.Check(Driver.ReadDayStatus(Status));
    case Status.DayStatus of
      MTS_DAY_STATUS_CLOSED: ;
      MTS_DAY_STATUS_OPENED,
      MTS_DAY_STATUS_EXPIRED:
      begin
        // Set cashier
        Cashier.Name := InParams.CashierName;
        Cashier.INN := InParams.CashierINN;
        Driver.Check(Driver.WriteCashier(Cashier));
        // Close fiscal day
        DayParams.SaleAddress := InParams.SaleAddress;
        DayParams.SaleLocation := InParams.SaleLocation;
        DayParams.PrintRequired := InParams.PrintRequired;
        DayParams.ExtendedProperty := '';
        DayParams.ExtendedData := '';
        Driver.Check(Driver.CloseFiscalDay(DayParams));
        // Wait print complete
        Driver.Check(Driver.WaitForPrinting);
      end;
    else
      raise Exception.CreateFmt('Invalid day status value, %d', [Status.DayStatus]);
    end;
    OutputParameters := ReadOutputParameters;
  except
    on E: Exception do
    begin
      Logger.Error('CloseShift Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('CloseShiftFN.end');
end;

function TMitsuDrv1C.ConfirmKM(const DeviceID, RequestGUID: WideString;
  ConfirmationType: Integer): WordBool;
begin

end;

function TMitsuDrv1C.DeviceTest(out Description,
  DemoModeIsActivated: WideString): WordBool;
var
  Version: TMTSVersion;
  DeviceName: WideString;
begin
  Logger.Debug('DeviceTest');
  ClearError;
  Result := True;
  try
    Driver.LockPort;
    try
      Driver.Check(Driver.ReadDeviceName(DeviceName));
      Driver.Check(Driver.ReadDeviceVersion(Version));
      Description := WideFormat('%s №%s', [DeviceName, Version.Serial]);
    finally
      Driver.UnlockPort;
    end;
  except
    on E: Exception do
    begin
      Logger.Error('DeviceTest Error ' + E.Message);
      Result := False;
      HandleException(E);
      Description := GetAdditionalDescription;
    end;
  end;
  Logger.Debug('DeviceTest.end');
end;

function TMitsuDrv1C.DoAdditionalAction(
  const ActionName: WideString): WordBool;
begin
  Logger.Debug('DoAdditionalAction ActionName = ' + ActionName);
  ClearError;
  Result := True;
  try
    if WideSameText(ActionName, 'TaxReport') then
    begin

    end;
    if WideSameText(ActionName, 'DepartmentReport') then
    begin

    end;
  except
    on E: Exception do
    begin
      Logger.Error('DoAdditionalAction Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('DoAdditionalAction.end');
end;

function TMitsuDrv1C.GetAdditionalActions(
  out TableActions: WideString): WordBool;

  function GetXmlActions: WideString;
  var
    Node: IXMLNode;
    Root: IXMLNode;
    Xml: IXMLDocument;
  begin
    Result := '';
    Xml := TXMLDocument.Create(nil);
    try
      Xml.Active := True;
      Xml.Version := '1.0';
      Xml.Encoding := 'UTF-8';
      Xml.Options := Xml.Options + [doNodeAutoIndent];
      Root := Xml.AddChild('Actions');
      // TaxReport
      Node := Root.AddChild('Action');
      Node.Attributes['Name'] := 'TaxReport';
      Node.Attributes['Caption'] := 'Отчет по налогам';
      // DepartmentReport
      Node := Root.AddChild('Action');
      Node.Attributes['Name'] := 'DepartmentReport';
      Node.Attributes['Caption'] := 'Отчет по отделам';

      Result := XML.XML.Text;
    finally
      Xml := nil;
    end;
  end;

begin
  Logger.Debug('GetAdditionalActions');
  ClearError;
  Result := True;
  try
    TableActions := GetXmlActions;
  except
    on E: Exception do
    begin
      Logger.Error('GetAdditionalActions Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('GetAdditionalActions.end');
end;

function TMitsuDrv1C.GetCurrentStatus(const DeviceID,
  InputParameters: WideString; out OutputParameters: WideString): WordBool;
begin

end;

function TMitsuDrv1C.GetLineLength(const DeviceID: WideString;
  out LineLength: Integer): WordBool;
begin

end;

function TMitsuDrv1C.GetLocalizationPattern(
  out LocalizationPattern: WideString): WordBool;
begin

end;

function TMitsuDrv1C.GetProcessingKMResult(const DeviceID: WideString;
  out ProcessingKMResult: WideString;
  out RequestStatus: Integer): WordBool;
begin

end;

function TMitsuDrv1C.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin

end;

function TMitsuDrv1C.OpenSessionRegistrationKM(
  const DeviceID: WideString): WordBool;
begin

end;

function TMitsuDrv1C.OpenShift(const DeviceID, InputParameters: WideString;
  out OutputParameters: WideString): WordBool;
var
  Cashier: TMTSCashier;
  Status: TMTSDayStatus;
  DayParams: TMTSDayParams;
  InParams: TInputParametersRec;
begin
  Logger.Debug('OpenShift DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    InParams := FReader.Read(InputParameters);
    Driver.Check(Driver.ReadDayStatus(Status));
    case Status.DayStatus of
      MTS_DAY_STATUS_OPENED: ;
      MTS_DAY_STATUS_CLOSED:
      begin
        // Set cashier
        Cashier.Name := InParams.CashierName;
        Cashier.INN := InParams.CashierINN;
        Driver.Check(Driver.WriteCashier(Cashier));
        // Open fiscal day
        DayParams.SaleAddress := InParams.SaleAddress;
        DayParams.SaleLocation := InParams.SaleLocation;
        DayParams.PrintRequired := InParams.PrintRequired;
        DayParams.ExtendedProperty := '';
        DayParams.ExtendedData := '';
        Driver.Check(Driver.OpenFiscalDay(DayParams));
        // Wait print complete
        Driver.Check(Driver.WaitForPrinting);
      end;
      MTS_DAY_STATUS_EXPIRED:
      begin
        raise Exception.Create('Day expired');
      end;
    else
      raise Exception.CreateFmt('Invalid day status value, %d', [Status.DayStatus]);
    end;
    OutputParameters := ReadOutputParameters;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
      Logger.Error('OpenShift Error ' + E.Message);
    end;
  end;
  Logger.Debug('OpenShift.end');
end;


function TMitsuDrv1C.PrintCheckCopy(const DeviceID,
  CheckNumber: WideString): WordBool;
begin

end;

function TMitsuDrv1C.PrintTextDocument(const DeviceID,
  DocumentPackage: WideString): WordBool;
begin

end;

function TMitsuDrv1C.PrintXReport(const DeviceID,
  InputParameters: WideString): WordBool;
begin

end;

function TMitsuDrv1C.ProcessCheck(const DeviceID: WideString;
  Electronically: WordBool; const CheckPackage: WideString;
  out DocumentOutputParameters: WideString): WordBool;
begin
  Logger.Debug('ProcessCheck DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    //doProcessCheck(Electronically, CheckPackage, DocumentOutputParameters, False);
  except
    on E: Exception do
    begin
      Logger.Error('ProcessCheck Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('ProcessCheck.end');
end;

(*
procedure TMitsuDrv1C.doProcessCheck(Electronically: Boolean;
  const CheckPackage: WideString; IsCorrection: Boolean);
var
  i: Integer;
  NonFiscalString: TNonFiscalString32;
  Barcode: TBarcode32;
  RecNumber: Integer;
  TotalSumm: Double;
  RequisitePrint: Byte;
  SessionNumber: Integer;
  saveTaxationType: Integer;
  TaxMode: Integer;
  SavePrintingStatus: Integer;
  Positions: TPositions1C3;
begin
  Logger.Debug('ProcessCheck32 Electronically = ' + Bool1C(Electronically) + '; IsCorrection = ' + Bool1C(IsCorrection));
  Logger.Debug('CheckPackage: ' + CheckPackage);

  Driver.LockPort;
  Positions := TPositions1C3.Create;
  try
    //Positions.FFDversion := FFFDVersion; !!!
    //Positions.BPOVersion := BPOVersion;
    //Positions.ItemNameLength := Params.ItemNameLength;
    LoadFromXml(Positions, Logger, CheckPackage, False);

    Logger.Debug('Positions.TotalTaxSum = ' + CurrToStr(Positions.TotalTaxSum));
    Logger.Debug('set Check Taxation type ' + IntToStr(TaxMode));

    // Electronically

      OpenCheckFN(Positions.CashierName, Positions.OperationType, True, RecNumber, SessionNumber, IsCorrection);

          try
            if Positions.CustomerPhone <> '' then
            begin
              Driver.CustomerEmail := Positions.CustomerPhone;
              Check(Driver.FNSendCustomerEmail, 'Ошибка передачи CustomerPhone');
            end;

            if Positions.CustomerEmail <> '' then
            begin
              Driver.CustomerEmail := Positions.CustomerEmail;
              Check(Driver.FNSendCustomerEmail, 'Ошибка передачи CustomerEmail');
            end;

          // Если передали пустой, установить из параметров фискализации
            if Positions.SenderEmail <> '' then
              SetSenderEmail(Positions.SenderEmail)
            else
            begin
            // Передаем только в случае если указан адрес покупателя
              if (Positions.CustomerPhone <> '') or (Positions.CustomerEmail <> '') then
                SetSenderEmail(FSenderEmail);
            end;

            SendTags32(Positions, IsCorrection); // Отправка дополнительных тэгов

            SetCashierVATIN(Positions.CashierVATIN);
            SetAgentData32(Positions.AgentData);
            SetPurveyorData32(Positions.VendorData);

            for i := 0 to Positions.Count - 1 do
            begin
              if Positions.Items[i] is TFiscalString32 then
              begin
                TotalSumm := TotalSumm + TFiscalString32(Positions.Items[i]).SumWithDiscount;
                PrintFiscalString32(TFiscalString32(Positions.Items[i]), Positions.TotalTaxSum > 0);
              end;
              if Positions.Items[i] is TNonFiscalString32 then
              begin
                NonFiscalString := TNonFiscalString32(Positions[i]);
                PrintNonFiscalString(NonFiscalString.Text);
              end;
              if Positions.Items[i] is TBarcode32 then
              begin
                Barcode := TBarcode32(Positions[i]);
                PrintBarcode(Barcode.BarcodeType, Barcode.Barcode);
              end;
            end;
          except
            on E: Exception do
            begin
              Logger.Debug('Cancelling check');
              try
                if IsPrinterRecOpened then
                begin
                  if Driver.ECRMode = 8 then
                  begin
                    Check(Driver.CancelCheck);
                    WaitForPrinting;
                  end;
                end;
              except
                on E: Exception do
                  Logger.Debug('Error cancelling check: ' + E.Message);
              end;
              raise;
            end;
          end;
          CloseCheckFN32(Positions.Payments.Cash, Positions.Payments.ElectronicPayment, Positions.Payments.PrePayment, Positions.Payments.PostPayment, Positions.Payments.Barter, TaxToBin(Positions.TaxVariant), TotalSumm, Positions.TotalTaxSum > 0)

        finally
         // возвращение значения Подавления печати следующего документа
          if (Electronically) and (not (IsModelType2(GetModelID))) then
          begin
            try
              Logger.Debug('Restore printing option');
              WriteTableInt(17, 1, 7, SavePrintingStatus);
            except

            end;
          end;
        end;
      finally
        try
          if (FSaveTaxMode <> TaxMode) and (not FParams.UseRepeatDocument) then
          begin
            // Возвращение значения поля начисления налогов
            if IsModelType2(GetModelID) then
            begin
              WriteTableInt(1, 1, 6, FSaveTaxMode);
            end
            else
            begin
              WriteTableInt(1, 1, 14, FSaveTaxMode);
            end;
          end;
        except
          on E: Exception do
            Logger.Error('Error restoring taxation mode: ' + E.Message);
        end;
      end;
    finally
    end;
  finally
    Positions.Free;
    Driver.UnlockPort;
  end;
end;
*)

function TMitsuDrv1C.ProcessCorrectionCheck(const DeviceID,
  CheckPackage: WideString;
  out DocumentOutputParameters: WideString): WordBool;
begin

end;

function TMitsuDrv1C.ReportCurrentStatusOfSettlements(const DeviceID,
  InputParameters: WideString; out OutputParameters: WideString): WordBool;
begin

end;

function TMitsuDrv1C.RequestKM(const DeviceID, RequestKM: WideString;
  out RequestKMResult: WideString): WordBool;
begin

end;

function TMitsuDrv1C.SetLocalization(const LanguageCode,
  LocalizationPattern: WideString): WordBool;
begin

end;

end.
