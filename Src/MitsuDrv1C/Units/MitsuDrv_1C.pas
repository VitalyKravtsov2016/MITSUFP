unit MitsuDrv_1C;

interface

uses
  // VCL
  Classes, SysUtils, Variants, XMLDoc, XMLIntf,
  // DCP
  DCPbase64,
  // This
  MitsuDrv, ByteUtils, XmlDoc1C, DriverError, VersionInfo,
  ParamList1C, ParamList1CPage, ParamList1CGroup, ParamList1CItem,
  Param1CChoiceList, LangUtils, FDTypes, Params1C,
  LogFile, StringUtils, DriverTypes, Types1C;

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

  T1CTax = array [1 .. 4] of Single;
  TTaxNames = array [1 .. 6] of string;

  { T1CPayNames }

  T1CPayNames = array [1 .. 3] of string;

  TCashierRec = record
    CashierName: WideString;
    CashierPass: Integer;
  end;

  { TCashiers }

  TCashiers = array [1 .. 30] of TCashierRec;

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
    FLogger: ILogFile;
    FDevices: TDevices;
    FDriver: TMitsuDrv;
    FParams: TMitsuParams;
    FParamList: TParamList1C;
    FXmlDocument: TXmlDoc1C;

    FResultCode: Integer;
    FResultDescription: string;

    procedure ClearError;
    procedure HandleException(E: Exception);
    procedure SelectDevice(const DeviceID: string);
    procedure ReadParametersKKT(Params: TParametersKKT);
    procedure CreateParamList;
    procedure PrinTFiscalItem(Receipt: TReceipt; Item: TFiscalItem);
    procedure PrintReceipt(Electronically: Boolean; const InXml: WideString;
      out OutXml: WideString; IsCorrection: Boolean);
    procedure PrintBarcode(const BarcodeType, Barcode: WideString);

    function ReadOutputParameters: AnsiString;
    function GetAdditionalDescription: WideString;

    property Device: TDevice read FDevice;
    property Devices: TDevices read FDevices;
    procedure PrintDocument(Document: TTextDocument);
  public
    constructor Create(ALogger: ILogFile);
    destructor Destroy; override;

    function GetInterfaceRevision: Integer;
    function GetDescription(out DriverDescription: WideString): WordBool;
    function GetLastError(out ErrorDescription: WideString): Integer;
    function GetParameters(out TableParameters: WideString): WordBool;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool;
    function Open(out DeviceID: WideString): WordBool;
    function Close(const DeviceID: WideString): WordBool;

    function DeviceTest(out Description: WideString;
      out DemoModeIsActivated: WideString): WordBool;
    function GetAdditionalActions(out TableActions: WideString): WordBool;
    function DoAdditionalAction(const ActionName: WideString): WordBool;
    function GetDataKKT(const DeviceID: WideString;
      out TableParametersKKT: WideString): WordBool;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
      const ParametersFiscal: WideString): WordBool;
    function OpenShift(const DeviceID: WideString;
      const InputParameters: WideString; out OutputParameters: WideString)
      : WordBool;
    function CloseShift(const DeviceID: WideString;
      const InputParameters: WideString; out OutputParameters: WideString)
      : WordBool;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool;
      const CheckPackage: WideString; out DocumentOutputParameters: WideString)
      : WordBool;
    function ProcessCorrectionCheck(const DeviceID: WideString;
      const CheckPackage: WideString; out DocumentOutputParameters: WideString)
      : WordBool;
    function CashInOutcome(const DeviceID: WideString;
      const InputParameters: WideString; Amount: Double): WordBool;
    function PrintXReport(const DeviceID: WideString;
      const InputParameters: WideString): WordBool;
    function GetCurrentStatus(const DeviceID: WideString;
      const InputParameters: WideString; out OutputParameters: WideString)
      : WordBool;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString;
      const InputParameters: WideString; out OutputParameters: WideString)
      : WordBool;
    function OpenCashDrawer(const DeviceID: WideString): WordBool;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer)
      : WordBool;
    function PrintCheckCopy(const DeviceID: WideString;
      const CheckNumber: WideString): WordBool;
    function PrintTextDocument(const DeviceID: WideString;
      const DocumentPackage: WideString): WordBool;
    function OpenSessionRegistrationKM(const DeviceID: WideString): WordBool;
    function CloseSessionRegistrationKM(const DeviceID: WideString): WordBool;
    function RequestKM(const DeviceID: WideString;
      const RequestKMXml: WideString; out RequestKMResultXml: WideString)
      : WordBool;
    function GetProcessingKMResult(const DeviceID: WideString;
      out ProcessingKMResult: WideString; out RequestStatus: Integer): WordBool;
    function ConfirmKM(const DeviceID: WideString;
      const RequestGUID: WideString; ConfirmationType: Integer): WordBool;
    function GetLocalizationPattern(out LocalizationPattern: WideString)
      : WordBool;
    function SetLocalization(const LanguageCode: WideString;
      const LocalizationPattern: WideString): WordBool;

    property Logger: ILogFile read FLogger;
    property Driver: TMitsuDrv read FDriver;
    property ResultCode: Integer read FResultCode write FResultCode;
    property ResultDescription: string read FResultDescription
      write FResultDescription;
  end;

implementation

function AmountToInt64(Value: Double): Int64;
begin
  Result := Round(Value * 100);
end;

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
  SPort = 'Порт';
  SBaudrate = 'Скорость';
  SByteTimeout = 'Таймаут байта';
  SCommandTimeout = 'Таймаут команды';
  SIPAddress = 'IP адрес';
  STCPPort = 'TCP порт';
  SDeviceParams = 'Параметры устройства';
  SAdminPassword = 'Пароль администратора';
  SCloseSession =
    'Закрывать смену для программирования налоговых ставок (в случае некорректных значений)';
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
  SItemnameLength =
    'Кол-во используемых символов наименования товара (0 - использовать целиком)';
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
  SUseRepeatDocument =
    'Для печати копии последнего документа использовать команду повтора документа';

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
  for i := 0 to Count - 1 do
  begin
    Result := Items[i];
    if Result.ID = ID then
      Exit;
  end;
  Result := nil;
end;

{ TMitsuDrv1C }

constructor TMitsuDrv1C.Create(ALogger: ILogFile);
begin
  inherited Create;
  FLogger := ALogger;
  FDriver := TMitsuDrv.Create(ALogger);
  FDevices := TDevices.Create(TDevice);
  FXmlDocument := TXmlDoc1C.Create;
  FParamList := TParamList1C.Create;
  CreateParamList;
  ClearError;
end;

destructor TMitsuDrv1C.Destroy;
begin
  FDriver.Free;
  FDevices.Free;
  FParamList.Free;
  FXmlDocument.Free;
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
    // FResultCode := E_UNKNOWN; !!!
    FResultDescription := E.Message;
  end;
  Logger.Error('HandleException: ' + IntToStr(FResultCode) + ', ' +
    FResultDescription);
end;

function TMitsuDrv1C.GetAdditionalDescription: WideString;
begin
  Result := Format('%d, %s', [FResultCode, FResultDescription]);
end;

function TMitsuDrv1C.ReadOutputParameters: AnsiString;

  function MTSDayStatusTo1C(DayStatus: Integer): Integer;
  begin
    case DayStatus of
      MTS_DAY_STATUS_CLOSED:
        Result := D1C_DS_CLOSED;
      MTS_DAY_STATUS_OPENED:
        Result := D1C_DS_OPENED;
      MTS_DAY_STATUS_EXPIRED:
        Result := D1C_DS_EXPIRED;
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
  Params.CashBalance := ReceiptTotals.Sale.T1136 + ReceiptTotals.RetBuy.T1136 -
    ReceiptTotals.RetSale.T1136 - ReceiptTotals.Buy.T1136;

  Params.ShiftClosingCheckNumber := DayStatus.RecNumber;
  // Счетчики операций по типу "приход"
  Params.CountersOperationType1.CheckCount := ReceiptTotals.Sale.Count;
  Params.CountersOperationType1.TotalChecksAmount := ReceiptTotals.Sale.Total;
  Params.CountersOperationType1.CorrectionCheckCount :=
    CorrectionTotals.Sale.Count;
  Params.CountersOperationType1.TotalCorrectionChecksAmount :=
    CorrectionTotals.Sale.Total;
  // Счетчики операций по типу "возврат прихода"
  Params.CountersOperationType2.CheckCount := ReceiptTotals.RetSale.Count;
  Params.CountersOperationType2.TotalChecksAmount :=
    ReceiptTotals.RetSale.Total;
  Params.CountersOperationType2.CorrectionCheckCount :=
    CorrectionTotals.RetSale.Count;
  Params.CountersOperationType2.TotalCorrectionChecksAmount :=
    CorrectionTotals.RetSale.Total;
  // Счетчики операций по типу "расход"
  Params.CountersOperationType3.CheckCount := ReceiptTotals.Buy.Count;
  Params.CountersOperationType3.TotalChecksAmount := ReceiptTotals.Buy.Total;
  Params.CountersOperationType3.CorrectionCheckCount :=
    CorrectionTotals.Buy.Count;
  Params.CountersOperationType3.TotalCorrectionChecksAmount :=
    CorrectionTotals.Buy.Total;
  // Счетчики операций по типу "возврат расхода"
  Params.CountersOperationType4.CheckCount := ReceiptTotals.RetBuy.Count;
  Params.CountersOperationType4.TotalChecksAmount := ReceiptTotals.RetBuy.Total;
  Params.CountersOperationType4.CorrectionCheckCount :=
    CorrectionTotals.RetBuy.Count;
  Params.CountersOperationType4.TotalCorrectionChecksAmount :=
    CorrectionTotals.RetBuy.Total;

  Params.BacklogDocumentsCounter := FDOStatus.DocCount;
  Params.BacklogDocumentFirstNumber := FDOStatus.FirstDoc;
  Params.BacklogDocumentFirstDateTime := FDOStatus.FirstDate;

  Params.FNError := TestBit(FDStatus.Flags, FD_NF_3_DAY_LEFT);
  Params.FNOverflow := TestBit(FDStatus.Flags, FD_NF_ALMOST_FULL);
  Params.FNFail := TestBit(FDStatus.Flags, FD_NF_30_DAYS_LEFT);
  Params.FNValidityDate := FDStatus.ValidDate;

  FXmlDocument.Write(XmlText, Params);
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
    RaiseError(E_INVALIDPARAM, Format('%s %s', [SInvalidParam,
      '"DeviceID"']));
  end;

  Device := FDevices.ItemByID(ID);
  if Device = nil then
  begin
    Logger.Error(Format('Device "%s"  not found', [DeviceID]));
    RaiseError(E_INVALIDPARAM, SDeviceNotActive);
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
    FXmlDocument.Write(TableParametersKKT, Params);
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
    FXmlDocument.Read(ParametersFiscal, Params);

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
    // FNParams.RegNumber := Params.RegNumber; !!!

    case OperationType of
      D1C_FNOT_OPEN:
        Driver.Check(Driver.FNOpen(FNParams));
      D1C_FNOT_CHANGE:
        Driver.Check(Driver.FNChange(FNParams));
      D1C_FNOT_CLOSE:
        Driver.Check(Driver.FNClose(FNParams));
    else
      raise Exception.CreateFmt('Invalid OperationType parameter value, %d',
        [OperationType]);
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

function TMitsuDrv1C.GetDescription(out DriverDescription: WideString)
  : WordBool;
var
  Node: IXMLNode;
  Xml: IXMLDocument;
const
  Version = '4.1';
begin
  Logger.Debug('GetDescription');

  Result := True;
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('DriverDescription');
{$IFDEF WIN64}
    Node.Attributes['Name'] := 'ВиЭйВи: Драйвер ККТ с передачей данных в ОФД ' + Version
      + ' (Win64)';
    Node.Attributes['Description'] := 'ВиЭйВи: Драйвер ККТ с передачей данных в ОФД ' +
      Version + ' (Win64)';
{$ELSE}
    Node.Attributes['Name'] := 'ВиЭйВи: Драйвер ККТ с передачей данных в ОФД ' + Version
      + ' (Win32)';
    Node.Attributes['Description'] := 'ВиЭйВи: Драйвер ККТ с передачей данных в ОФД ' +
      Version + ' (Win32)';
{$ENDIF}
    Node.Attributes['EquipmentType'] := 'ККТ';
    Node.Attributes['IntegrationComponent'] := 'true';
    Node.Attributes['MainDriverInstalled'] := 'true';
    Node.Attributes['DriverVersion'] := GetFileVersionInfoStr;
    Node.Attributes['IntegrationComponentVersion'] := GetFileVersionInfoStr;
    Node.Attributes['DownloadURL'] := 'http://www.vav.ru/support/download';
    Node.Attributes['LogPath'] := Driver.Params.LogPath;
    Node.Attributes['LogIsEnabled'] := to1CBool(Driver.Params.LogEnabled);
    Xml.SaveToXML(DriverDescription);
  finally
    Xml := nil;
  end;
  Logger.Debug('GetDescription.end');
end;

function TMitsuDrv1C.GetLastError(out ErrorDescription: WideString): Integer;
begin
  ErrorDescription := FResultDescription;
  Result := FResultCode;
  Logger.Debug('GetLastError ' + ErrorDescription);
end;

function TMitsuDrv1C.GetParameters(out TableParameters: WideString): WordBool;
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
  SSerialPort = 'ИмяПорта';
  SBaudRate = 'Скорость';
  SByteTimeout = 'Таймаут';
  SRemoteHost = 'IP адрес';
  SRemotePort = 'TCP порт';
begin
  // СТРАНИЦА Параметры связи
  Page := FParamList.Pages.Add;
  Page.Caption := SConnectionParams;
  { --- Параметры связи --- }
  Group := Page.Groups.Add;
  Group.Caption := SConnectionParams; // 'Параметры связи';
  // Тип подключения
  Item := Group.Items.Add;
  Item.Name := 'ConnectionType';
  Item.Caption := SConnectionType;
  Item.Description := SConnectionType;
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';
  for i := Low(Driver.ValidConnectionTypes)
    to High(Driver.ValidConnectionTypes) do
    Item.AddChoiceListItem(ConnectionTypeToStr(ConnectionTypes[i]),
      IntToStr(ConnectionTypes[i]));
  // Порт
  Item := Group.Items.Add;
  Item.Name := 'SerialPort';
  Item.Caption := SSerialPort;
  Item.Description := SSerialPort;
  Item.TypeValue := 'String';
  Item.DefaultValue := 'COM1';
  for i := 1 to 16 do
  begin
    Item.AddChoiceListItem('COM' + IntToStr(i), 'COM' + IntToStr(i));
  end;
  // Baudrate
  Item := Group.Items.Add;
  Item.Name := 'BaudRate';
  Item.Caption := SBaudrate;
  Item.Description := SBaudrate;
  Item.TypeValue := 'Number';
  Item.DefaultValue := '115200';
  for i := Low(Driver.ValidBaudRates) to High(Driver.ValidBaudRates) do
  begin
    ChoiceListItem := Item.ChoiceList.Add;
    ChoiceListItem.Name := IntToStr(BaudRates[i]);
    ChoiceListItem.Value := IntToStr(BaudRates[i]);
  end;
  // Таймаут приема байта
  Item := Group.Items.Add;
  Item.Name := 'ByteTimeout';
  Item.Caption := SByteTimeout;
  Item.Description := SByteTimeout;
  Item.TypeValue := 'Number';
  Item.DefaultValue := '100';
  // Таймаут команды
  Item := Group.Items.Add;
  Item.Name := 'CommandTimeout';
  Item.Caption := SCommandTimeout;
  Item.Description := SCommandTimeout;
  Item.TypeValue := 'Number';
  Item.DefaultValue := '1000';
  // IP адрес
  Item := Group.Items.Add;
  Item.Name := 'IPAddress';
  Item.Caption := SIPAddress;
  Item.Description := SIPAddress;
  Item.TypeValue := 'String';
  Item.DefaultValue := '192.168.137.111';
  // TCP Port
  Item := Group.Items.Add;
  Item.Name := 'TCPPort';
  Item.Caption := STCPPort;
  Item.Description := STCPPort;
  Item.TypeValue := 'Number';
  Item.DefaultValue := '7778';
end;

function TMitsuDrv1C.SetParameter(const Name: WideString; Value: OleVariant)
  : WordBool;
begin
  Logger.Debug('SetParameter  ' + Name + ' ' + VarToWideStr(Value));
  Result := True;
  try
    if WideSameStr('ConnectionType', Name) then
      FParams.ConnectionType := Value;
    if WideSameStr('SerialPort', Name) then
      FParams.PortName := Value;
    if WideSameStr('Baudrate', Name) then
      FParams.Baudrate := Value;
    if WideSameStr('ByteTimeout', Name) then
      FParams.ByteTimeout := Value;
    if WideSameStr('CommandTimeout', Name) then
      FParams.CommandTimeout := Value;
    if WideSameStr('IPAddress', Name) then
      FParams.RemoteHost := Value;
    if WideSameStr('TCPPort', Name) then
      FParams.RemotePort := Value;
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

function TMitsuDrv1C.CashInOutcome(const DeviceID, InputParameters: WideString;
  Amount: Double): WordBool;
var
  Params: TInputParametersRec;
begin
  Logger.Debug('CashInOutcome DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Params := FXmlDocument.Read(InputParameters);
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

function TMitsuDrv1C.CloseShift(const DeviceID, InputParameters: WideString;
  out OutputParameters: WideString): WordBool;
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
    InParams := FXmlDocument.Read(InputParameters);
    Driver.Check(Driver.ReadDayStatus(Status));
    case Status.DayStatus of
      MTS_DAY_STATUS_CLOSED:
        ;
      MTS_DAY_STATUS_OPENED, MTS_DAY_STATUS_EXPIRED:
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
      raise Exception.CreateFmt('Invalid day status value, %d',
        [Status.DayStatus]);
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

function TMitsuDrv1C.DeviceTest(out Description, DemoModeIsActivated
  : WideString): WordBool;
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

function TMitsuDrv1C.DoAdditionalAction(const ActionName: WideString): WordBool;
begin
  Logger.Debug('DoAdditionalAction ActionName = ' + ActionName);
  ClearError;
  Result := True;
  try
    repeat
      if WideSameText(ActionName, 'TaxReport') then
      begin

        Break;
      end;
      if WideSameText(ActionName, 'DepartmentReport') then
      begin
        Break;
      end;
      Result := False;
    until True;
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

function TMitsuDrv1C.GetAdditionalActions(out TableActions: WideString)
  : WordBool;

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

      Result := Xml.Xml.Text;
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

function TMitsuDrv1C.GetCurrentStatus(const DeviceID, InputParameters
  : WideString; out OutputParameters: WideString): WordBool;
var
  InParams: TInputParametersRec;
begin
  Logger.Debug('GetCurrentStatus');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    InParams := FXmlDocument.Read(InputParameters);
    OutputParameters := ReadOutputParameters;
  except
    on E: Exception do
    begin
      Logger.Error('GetCurrentStatus Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('GetCurrentStatus.end');
end;

function TMitsuDrv1C.GetLineLength(const DeviceID: WideString;
  out LineLength: Integer): WordBool;
var
  PrinterParams: TMTSPrinterParams;
begin
  Logger.Debug('GetLineLength');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Driver.Check(Driver.ReadPrinterParams(PrinterParams));
    LineLength := PrinterParams.CharWidth;
  except
    on E: Exception do
    begin
      Logger.Error('GetLineLength Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('GetLineLength.end');
end;

function TMitsuDrv1C.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin
  Logger.Debug('OpenCashDrawer DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Driver.Check(Driver.OpenCashDrawer);
  except
    on E: Exception do
    begin
      Logger.Error('OpenCashDrawer Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('OpenCashDrawer.end');
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
    InParams := FXmlDocument.Read(InputParameters);
    Driver.Check(Driver.ReadDayStatus(Status));
    case Status.DayStatus of
      MTS_DAY_STATUS_OPENED:
        ;
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
      raise Exception.CreateFmt('Invalid day status value, %d',
        [Status.DayStatus]);
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

function TMitsuDrv1C.PrintCheckCopy(const DeviceID, CheckNumber: WideString)
  : WordBool;
var
  RecNumber: Integer;
  DocStatus: TDocStatus;
begin
  Logger.Debug('PrintCheckCopy DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    if CheckNumber = '' then
    begin
      Driver.Check(Driver.Print);
    end
    else
    begin
      RecNumber := StrToInt(CheckNumber);
      Driver.Check(Driver.ReadDocStatus(RecNumber, DocStatus));
      Driver.Check(Driver.Print);
    end;
  except
    on E: Exception do
    begin
      Logger.Error('PrintCheckCopy Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('PrintCheckCopy.end');
end;

function TMitsuDrv1C.PrintTextDocument(const DeviceID, DocumentPackage
  : WideString): WordBool;
var
  Document: TTextDocument;
begin
  Logger.Debug('PrintTextDocument DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  Document := TTextDocument.Create;
  try
    SelectDevice(DeviceID);
    FXmlDocument.Read(DocumentPackage, Document);
    PrintDocument(Document);
  except
    on E: Exception do
    begin
      Logger.Error('PrintTextDocument Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Document.Free;
  Logger.Debug('PrintTextDocument.end');
end;

function TMitsuDrv1C.PrintXReport(const DeviceID, InputParameters: WideString)
  : WordBool;
var
  Cashier: TMTSCashier;
  DayStatus: TMTSDayStatus;
  InParams: TInputParametersRec;
begin
  Logger.Debug('PrintXReport DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    InParams := FXmlDocument.Read(InputParameters);
    // Set cashier
    Cashier.Name := InParams.CashierName;
    Cashier.INN := InParams.CashierINN;
    Driver.Check(Driver.WriteCashier(Cashier));
    // X report
    Driver.Check(Driver.MakeXReport(DayStatus));
    if InParams.PrintRequired then
      Driver.Check(Driver.Print);
  except
    on E: Exception do
    begin
      Logger.Error('PrintXReport Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('PrintXReport.end');
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
    PrintReceipt(Electronically, CheckPackage, DocumentOutputParameters, False);
  except
    on E: Exception do
    begin
      Logger.Error('ProcessCheck Error ' + E.Message);
      Result := False;
      HandleException(E);
      Driver.Reset;
    end;
  end;
  Logger.Debug('ProcessCheck.end');
end;

procedure TMitsuDrv1C.PrintReceipt(Electronically: Boolean;
  const InXml: WideString; out OutXml: WideString; IsCorrection: Boolean);
var
  i: Integer;
  Receipt: TReceipt;
  Barcode: TBarcodeItem;
  Attributes: TMTSAttributes;
  OpenReceipt: TMTSOpenReceipt;
  FiscalString: TFiscalItem;
  EndPositions: TMTSEndPositions;
  NonFiscalString: TTextItem;
begin
  Logger.Debug('ProcessCheck32 Electronically = ' + Bool1C(Electronically));
  Logger.Debug('CheckPackage: ' + InXml);

  Driver.LockPort;
  Receipt := TReceipt.Create;
  try
    FXmlDocument.Read(InXml, Receipt);
    // Open receipt
    OpenReceipt.ReceiptType := Receipt.Params.OperationType;
    OpenReceipt.TaxSystem := Receipt.Params.TaxationSystem;
    OpenReceipt.SaleAddress := Receipt.Params.SaleAddress;
    OpenReceipt.SaleLocation := Receipt.Params.SaleLocation;
    OpenReceipt.AutomaticNumber := Receipt.Params.AutomatNumber;
    OpenReceipt.SenderEmail := Receipt.Params.SenderEmail;
    OpenReceipt.Correction.Date := Receipt.CorrectionData.Date;
    OpenReceipt.Correction.Document := Receipt.CorrectionData.Number;
    if IsCorrection then
    begin
      Driver.Check(Driver.OpenCorrection(OpenReceipt));
    end
    else
    begin
      Driver.Check(Driver.OpenReceipt(OpenReceipt));
    end;
    // Add receipt tags
    Attributes.CustomerPhone := Receipt.Params.CustomerPhone;
    // IndustryAttribute
    Attributes.IndustryAttribute.Enabled := Receipt.IndustryAttribute.Enabled;
    Attributes.IndustryAttribute.IdentifierFOIV :=
      Receipt.IndustryAttribute.IdentifierFOIV;
    Attributes.IndustryAttribute.DocumentDate :=
      Receipt.IndustryAttribute.DocumentDate;
    Attributes.IndustryAttribute.DocumentNumber :=
      Receipt.IndustryAttribute.DocumentNumber;
    Attributes.IndustryAttribute.AttributeValue :=
      Receipt.IndustryAttribute.AttributeValue;
    // CustomerDetail
    Attributes.CustomerDetail.Enabled := Receipt.CustomerDetail.Enabled;
    Attributes.CustomerDetail.Name := Receipt.CustomerDetail.Info;
    Attributes.CustomerDetail.INN := Receipt.CustomerDetail.INN;
    Attributes.CustomerDetail.BirthDate := Receipt.CustomerDetail.DateOfBirth;
    Attributes.CustomerDetail.CountryCode :=
      StrToInt(Receipt.CustomerDetail.Citizenship);
    Attributes.CustomerDetail.DocumentCode :=
      Receipt.CustomerDetail.DocumentTypeCode;
    Attributes.CustomerDetail.DocumentData :=
      Receipt.CustomerDetail.DocumentData;
    Attributes.CustomerDetail.Address := Receipt.CustomerDetail.Address;
    // OperationInfo
    Attributes.OperationInfo.Enabled := Receipt.OperationalAttribute.Enabled;
    Attributes.OperationInfo.ID := Receipt.OperationalAttribute.OperationID;
    Attributes.OperationInfo.Data := Receipt.OperationalAttribute.OperationData;
    Attributes.OperationInfo.Date := Receipt.OperationalAttribute.DateTime;
    // UserAttribute
    Attributes.UserAttribute.Enabled := Receipt.UserAttribute.Enabled;
    Attributes.UserAttribute.Name := Receipt.UserAttribute.Name;
    Attributes.UserAttribute.Value := Receipt.UserAttribute.Value;
    Driver.Check(Driver.AddRecAttributes(Attributes));
    // Begin positions
    Driver.Check(Driver.BeginRecPositions);
    for i := 0 to Receipt.Items.Count - 1 do
    begin
      if Receipt.Items[i] is TFiscalItem then
      begin
        FiscalString := Receipt.Items[i] as TFiscalItem;
        PrinTFiscalItem(Receipt, FiscalString);
      end;
      if Receipt.Items[i] is TTextItem then
      begin
        NonFiscalString := Receipt.Items[i] as TTextItem;
        Driver.Check(Driver.AddText(NonFiscalString.Text));
      end;
      if Receipt.Items[i] is TBarcodeItem then
      begin
        Barcode := Receipt.Items[i] as TBarcodeItem;
        PrintBarcode(Barcode.BarcodeType, Barcode.Barcode);
      end;
    end;
    // Payments
    // !!!
    // End positions
    Driver.Check(Driver.EndPositions(EndPositions));
    // Close receipt
    Driver.Check(Driver.CloseReceipt(False));
    // Print
    Driver.Check(Driver.Print);
  finally
    Receipt.Free;
    Driver.UnlockPort;
  end;
end;

procedure TMitsuDrv1C.PrintDocument(Document: TTextDocument);
var
  i: Integer;
  Item: TDocItem;
  TextItem: TTextItem;
  Barcode: TBarcodeItem;
begin
  Driver.LockPort;
  try
    Driver.Check(Driver.OpenNonfiscal);
    for i := 0 to Document.Items.Count - 1 do
    begin
      Item := Document.Items[i];
      if Item is TTextItem then
      begin
        TextItem := Item as TTextItem;
        Driver.Check(Driver.AddText(TextItem.Text));
      end;
      if Item is TBarcodeItem then
      begin
        Barcode := Item as TBarcodeItem;
        PrintBarcode(Barcode.BarcodeType, Barcode.Barcode);
      end;
    end;
    Driver.Check(Driver.CloseNonfiscal(False));
    Driver.Check(Driver.Print);
  finally
    Driver.UnlockPort;
  end;
end;

procedure TMitsuDrv1C.PrintBarcode(const BarcodeType, Barcode: WideString);

  function StrToBarcodeType(const BarcodeType: WideString): Integer;
  begin
    if AnsiCompareText(BarcodeType, 'EAN8') = 0 then
    begin
      Result := MTS_BARCODE_EAN8;
      Exit;
    end;
    if AnsiCompareText(BarcodeType, 'EAN13') = 0 then
    begin
      Result := MTS_BARCODE_EAN13;
      Exit;
    end;
    if AnsiCompareText(BarcodeType, 'CODE39') = 0 then
    begin
      Result := MTS_BARCODE_CODE39;
      Exit;
    end;
    if AnsiCompareText(BarcodeType, 'QR') = 0 then
    begin
      Result := MTS_BARCODE_QRCODE;
      Exit;
    end;
    if AnsiCompareText(BarcodeType, 'Code128') = 0 then
    begin
      Result := MTS_BARCODE_CODE128;
      Exit;
    end;
    if AnsiCompareText(BarcodeType, 'Code93') = 0 then
    begin
      Result := MTS_BARCODE_CODE93;
      Exit;
    end;
    if AnsiCompareText(BarcodeType, 'ITF14') = 0 then
    begin
      Result := MTS_BARCODE_ITF;
      Exit;
    end;
    raise Exception.CreateFmt('Barcode type not supported,  %s', [BarcodeType]);
  end;

var
  BC: TMTSBarcode;
begin
  BC.BarcodeType := StrToBarcodeType(BarcodeType);
  BC.ModuleWidth := 3;
  BC.BarcodeHeight := 0;
  BC.Data := Base64DecodeStr(Barcode);

  Driver.Check(Driver.AddBarcode(BC));
end;

procedure TMitsuDrv1C.PrinTFiscalItem(Receipt: TReceipt; Item: TFiscalItem);
var
  Position: TMTSPosition;
begin
  Position.Name := Item.Name;
  Position.TaxRate := Item.Tax;
  Position.Quantity := Item.Quantity;
  Position.Price := AmountToInt64(Item.PriceWithDiscount);
  Position.Total := AmountToInt64(Item.SumWithDiscount);
  Position.ItemType := Item.SignCalculationObject;
  Position.PaymentType := Item.SignMethodCalculation;
  Position.ExciseTaxTotal := AmountToInt64(Item.ExciseAmount);
  Position.CountryCode := Item.CountryOfOfigin;
  Position.CustomsDeclaration := Item.CustomsDeclaration;
  Position.MarkingCode := Item.Marking;
  Position.AddAttribute := Item.AdditionalAttribute;
  // Position.AgentType := Item. !!!
  // AgentData
  Position.AgentData.Enabled := Item.AgentData.Enabled;
  Position.AgentData.AgentOperation := Item.AgentData.AgentOperation;
  Position.AgentData.AgentPhone := Item.AgentData.AgentPhone;
  Position.AgentData.PaymentProcessorPhone :=
    Item.AgentData.PaymentProcessorPhone;
  Position.AgentData.AcquirerOperatorPhone :=
    Item.AgentData.AcquirerOperatorPhone;
  Position.AgentData.AcquirerOperatorName :=
    Item.AgentData.AcquirerOperatorName;
  Position.AgentData.AcquirerOperatorAddress :=
    Item.AgentData.AcquirerOperatorAddress;
  Position.AgentData.AcquirerOperatorINN := Item.AgentData.AcquirerOperatorINN;
  // Vendor
  Position.VendorData.Enabled := Item.VendorData.Enabled;
  Position.VendorData.Phone := Item.VendorData.VendorPhone;
  Position.VendorData.Name := Item.VendorData.VendorName;
  Position.VendorData.INN := Item.VendorData.VendorINN;
  // IndustryAttribute
  Position.IndustryAttribute.Enabled := Item.IndustryAttribute.Enabled;
  Position.IndustryAttribute.IdentifierFOIV :=
    Item.IndustryAttribute.IdentifierFOIV;
  Position.IndustryAttribute.DocumentDate :=
    Item.IndustryAttribute.DocumentDate;
  Position.IndustryAttribute.DocumentNumber :=
    Item.IndustryAttribute.DocumentNumber;
  Position.IndustryAttribute.AttributeValue :=
    Item.IndustryAttribute.AttributeValue;
  Driver.Check(Driver.AddRecPosition(Position));
end;

function TMitsuDrv1C.ProcessCorrectionCheck(const DeviceID,
  CheckPackage: WideString; out DocumentOutputParameters: WideString): WordBool;
begin
  Logger.Debug('ProcessCorrectionCheck DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    PrintReceipt(False, CheckPackage, DocumentOutputParameters, True);
  except
    on E: Exception do
    begin
      Logger.Error('ProcessCorrectionCheck Error ' + E.Message);
      Result := False;
      HandleException(E);
      Driver.Reset;
    end;
  end;
  Logger.Debug('ProcessCorrectionCheck.end');
end;

function TMitsuDrv1C.ReportCurrentStatusOfSettlements(const DeviceID,
  InputParameters: WideString; out OutputParameters: WideString): WordBool;
var
  Cashier: TMTSCashier;
  Report: TMTSCalcReport;
  InParams: TInputParametersRec;
begin
  Logger.Debug('ReportCurrentStatusOfSettlements DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    InParams := FXmlDocument.Read(InputParameters);
    // Set cashier
    Cashier.Name := InParams.CashierName;
    Cashier.INN := InParams.CashierINN;
    Driver.Check(Driver.WriteCashier(Cashier));
    // Calc report
    Driver.Check(Driver.MakeCalcReport(Report));
    Driver.Check(Driver.Print);
  except
    on E: Exception do
    begin
      Logger.Error('ReportCurrentStatusOfSettlements Error ' + E.Message);
      Result := False;
      HandleException(E);
      Driver.Reset;
    end;
  end;
  Logger.Debug('ReportCurrentStatusOfSettlements.end');
end;

function TMitsuDrv1C.OpenSessionRegistrationKM(const DeviceID: WideString)
  : WordBool;
begin
  Logger.Debug('OpenSessionRegistrationKM DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
  except
    on E: Exception do
    begin
      Logger.Error('OpenSessionRegistrationKM Error ' + E.Message);
      Result := False;
      HandleException(E);
      Driver.Reset;
    end;
  end;
  Logger.Debug('OpenSessionRegistrationKM.end');
end;

function TMitsuDrv1C.CloseSessionRegistrationKM(const DeviceID: WideString)
  : WordBool;
begin
  Logger.Debug('CloseSessionRegistrationKM DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
  except
    on E: Exception do
    begin
      Logger.Error('CloseSessionRegistrationKM Error ' + E.Message);
      Result := False;
      HandleException(E);
      Driver.Reset;
    end;
  end;
  Logger.Debug('CloseSessionRegistrationKM.end');
end;

function TMitsuDrv1C.RequestKM(const DeviceID, RequestKMXml: WideString;
  out RequestKMResultXml: WideString): WordBool;
var
  P: TMTSTestMark;
  R: TMTSTestMarkResponse;
  RequestKM: TRequestKM;
  RequestKMResult: TRequestKMResult;
begin
  Logger.Debug('RequestKM DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    FXmlDocument.Load(RequestKMXml, RequestKM);
    //
    P.MarkingCode := RequestKM.MarkingCode;
    P.Quantity := RequestKM.Quantity;
    P.MeasureOfQuantity := RequestKM.MeasureOfQuantity;
    P.PlannedStatus := RequestKM.PlannedStatus;
    P.Numerator := RequestKM.Numerator;
    P.Denominator := RequestKM.Denominator;
    Driver.Check(Driver.MCReadRequest(P, R));
    // !!!
    RequestKMResult.Checking := False;
    RequestKMResult.CheckingResult := False;
    FXmlDocument.Write(RequestKMResultXml, RequestKMResult);
  except
    on E: Exception do
    begin
      Logger.Error('RequestKM Error ' + E.Message);
      Result := False;
      HandleException(E);
      Driver.Reset;
    end;
  end;
  Logger.Debug('RequestKM.end');
end;

function TMitsuDrv1C.ConfirmKM(const DeviceID, RequestGUID: WideString;
  ConfirmationType: Integer): WordBool;
begin
  Logger.Debug('ConfirmKM DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);

  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
      Logger.Error('ConfirmKM Error ' + E.Message);
    end;
  end;
  Logger.Debug('ConfirmKM.end');
end;

function TMitsuDrv1C.GetProcessingKMResult(const DeviceID: WideString;
  out ProcessingKMResult: WideString; out RequestStatus: Integer): WordBool;
begin
  Result := True;
end;

function TMitsuDrv1C.SetLocalization(const LanguageCode, LocalizationPattern
  : WideString): WordBool;
begin
  Result := True;
end;

function TMitsuDrv1C.GetLocalizationPattern(out LocalizationPattern: WideString)
  : WordBool;
begin
  Result := True;
end;

(*

function TMitsuDrv1C.ReadValuesArray(const AValuesArray: IDispatch)
  : T1CDriverParams;
var
  V: Variant;
begin
  V := AValuesArray;

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_PORT, Result.Port) then
    RaiseInvalidValue('Port');

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_BAUDRATE, Result.Speed) then
    RaiseInvalidValue('Speed');

  if not GetStrParamValue(V, DRVFR_VALUE_INDEX_USERPASSWORD, Result.UserPassword)
  then
    RaiseInvalidValue('UserPassword');

  if not GetStrParamValue(V, DRVFR_VALUE_INDEX_ADMINPASSWORD,
    Result.AdminPassword) then
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

  if not GetBoolParamValue(V, DRVFR_VALUE_INDEX_CLOSESESSION,
    Result.CloseSession) then
    RaiseInvalidValue('CloseSession');

  if not GetBoolParamValue(V, DRVFR_VALUE_INDEX_ENABLELOG, Result.EnableLog)
  then
    RaiseInvalidValue('EnableLog');

  if not GetStrParamValue(V, DRVFR_VALUE_INDEX_PAYNAME1, Result.PayNames[1])
  then
    RaiseInvalidValue('PayName1');

  if not GetStrParamValue(V, DRVFR_VALUE_INDEX_PAYNAME2, Result.PayNames[2])
  then
    RaiseInvalidValue('PayName2');

  if not GetBoolParamValue(V, DRVFR_VALUE_INDEX_PRINTLOGO, Result.PrintLogo)
  then
    Result.PrintLogo := DEF_PRINTLOGO;

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_LOGOSIZE, Result.LogoSize) then
    Result.LogoSize := DEF_LOGOSIZE;

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_CONNECTION_TYPE,
    Result.ConnectionType) then
    Result.ConnectionType := DEF_CONNECTION_TYPE;

  if not GetStrParamValue(V, DRVFR_VALUE_INDEX_COMPUTERNAME, Result.ComputerName)
  then
    Result.ComputerName := DEF_COMPUTERNAME;

  if not GetStrParamValue(V, DRVFR_VALUE_INDEX_IPADDRESS, Result.IPAddress) then
    Result.IPAddress := DEF_IPADDRESS;

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_TCPPORT, Result.TCPPort) then
    Result.TCPPort := DEF_TCPPORT;

  if not GetIntParamValue(V, DRVFR_VALUE_INDEX_PROTOCOLTYPE, Result.ProtocolType)
  then
    Result.ProtocolType := DEF_PROTOCOLTYPE;

  if not GetBoolParamValue(V, DRVFR_VALUE_INDEX_BUFFERSTRINGS,
    Result.BufferStrings) then
    Result.BufferStrings := DEF_BUFFERSTRINGS;
end;


*)
end.
