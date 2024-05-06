unit Driver1Cst30;

interface

uses
  // VCL
  SysUtils,
  // This
  Driver1Cst11, ParamList1C, ParamList1CPage, ParamList1CGroup, ParamList1CItem,
  Param1CChoiceList, PrinterTypes, DriverError, DriverTypes, Devices1C,
  untLogger, Types1C, LogFile, AdditionalAction, TextEncoding, DrvFRLib_TLB,
  VersionInfo, LangUtils, XMLDoc, XMLIntf, untLogFile, Devices1C3, untDrvFR;

type
  { TDriver1Cst30 }

  TDriver1Cst30 = class
  private
    FAdditionalActions: TAdditionalActions;
    FFormatVersion: Integer;
    FDriver: IDrvFR49;
    FDevices: TDevices1C;
    FResultCode: Integer;
    FResultDescription: string;
    FLogger: TLogger;
    FDevice: TDevice1C3;
    FParamList: TParamList1C;
    FParams: TDeviceParams17;
    procedure CreateParamList;
    property Logger: TLogger read FLogger;
    procedure ClearError;
    procedure HandleException(E: Exception);
    procedure SelectDevice(const DeviceID: string);
    function GetDriverVersion: string;
    function GetLogState(var AEnabled: Boolean): string;
    property Device: TDevice1C3 read FDevice;
    property Devices: TDevices1C read FDevices;
    function GetAdditionalDescription: WideString;
    function GetVersion: WideString;
    procedure SetError(const AErrorCode: Integer; const AErrorDescription: WideString);
  public
    constructor Create;
    destructor Destroy; override;

    function GetInterfaceRevision: Integer;
    function GetDescription(var DriverDescription: WideString): WordBool;
    function GetLastError(var ErrorDescription: WideString): Integer;
    function GetParameters(var TableParameters: WideString): WordBool;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool;
    function Open(var DeviceID: WideString): WordBool;
    function Close(const DeviceID: WideString): WordBool;
    function DeviceTest(var Description: WideString; var DemoModeIsActivated: WideString): WordBool;
    function GetAdditionalActions(var TableActions: WideString): WordBool;
    function DoAdditionalAction(const ActionName: WideString): WordBool;
    function GetDataKKT(const DeviceID: WideString; var TableParametersKKT: WideString): WordBool;
    function OperationFN(const DeviceID: WideString; OperationType: Integer; const ParametersFiscal: WideString): WordBool;
    function OpenShift(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): WordBool;
    function CloseShift(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): WordBool;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool; const CheckPackage: WideString; var DocumentOutputParameters: WideString): WordBool;
    function ProcessCorrectionCheck(const DeviceID: WideString; const CheckPackage: WideString; var DocumentOutputParameters: WideString): WordBool;
    function PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): WordBool;
    function CashInOutcome(const DeviceID: WideString; const InputParameters: WideString; Amount: Double): WordBool;
    function PrintXReport(const DeviceID: WideString; const InputParameters: WideString): WordBool;
    function GetCurrentStatus(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): WordBool;
    function OpenCashDrawer(const DeviceID: WideString): WordBool;
    function GetLineLength(const DeviceID: WideString; var LineLength: Integer): WordBool;
    function PrintCheckCopy(const DeviceID: WideString; const CheckNumber: WideString): WordBool;
    //34
    function OpenSessionRegistrationKM(const DeviceID: WideString): WordBool;
    function CloseSessionRegistrationKM(const DeviceID: WideString): WordBool;
    function ConfirmKM(const DeviceID, RequestGUID: WideString; ConfirmationType: Integer): WordBool;
    function GetProcessingKMResult(const DeviceID: WideString; var ProcessingKMResult: WideString; out RequestStatus: Integer): WordBool;
    function RequestKM(const DeviceID, RequestKM: WideString; var RequestKMResult: WideString): WordBool;
    property FormatVersion: Integer read FFormatVersion write FFormatVersion;
    // 40
    function GetLocalizationPattern(var LocalizationPattern: WideString): WordBool;
    function SetLocalization(const LanguageCode, LocalizationPattern: WideString): WordBool;
  end;

implementation

uses
  Driver1Cst;

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

var
  ConnectionTypes: array[1..6] of Integer = (CT_LOCAL, CT_TCP, CT_DCOM, CT_ESCAPE, CT_EMULATOR, CT_TCPSOCKET);

resourcestring
  SInvalidParam = 'Некорректное значение параметра';

function BaudRateToStr(BaudRate: Integer): WideString;
begin
  case BaudRate of
    BAUD_RATE_CODE_2400:
      Result := '2400';
    BAUD_RATE_CODE_4800:
      Result := '4800';
    BAUD_RATE_CODE_9600:
      Result := '9600';
    BAUD_RATE_CODE_19200:
      Result := '19200';
    BAUD_RATE_CODE_38400:
      Result := '38400';
    BAUD_RATE_CODE_57600:
      Result := '57600';
    BAUD_RATE_CODE_115200:
      Result := '115200';
    BAUD_RATE_CODE_230400:
      Result := '230400';
    BAUD_RATE_CODE_460800:
      Result := '460800';
    BAUD_RATE_CODE_921600:
      Result := '921600';
  else
    RaiseError(E_INVALIDPARAM, Format('%s %s', [GetRes(@SInvalidParam), '"Baudrate"']));
  end;
end;

function ConnectionTypeToStr(ConnectionType: Integer): WideString;
begin
  case ConnectionType of
    CT_LOCAL:
      Result := 'Локально';
    CT_TCP:
      Result := 'TCP (сервер ФР)';
    CT_DCOM:
      Result := 'DCOM (сервер ФР)';
    CT_ESCAPE:
      Result := 'Escape';
    CT_EMULATOR:
      Result := 'Эмулятор';
    CT_TCPSOCKET:
      Result := 'TCP socket'   else
    RaiseError(E_INVALIDPARAM, Format('%s %s', [GetRes(@SInvalidParam), '"ConnectionType"']));
  end;
end;


{ TDriver1Cst30 }

constructor TDriver1Cst30.Create;
begin
  inherited Create;
  FLogger := TLogger.Create(Self.ClassName);
  FDriver := DrvFR_create;
  Logger.Debug('Create');
  FParamList := TParamList1C.Create;
  CreateParamList;
  FAdditionalActions := TAdditionalActions.Create;
  TPrintTaxReportAdditionalAction.Create(FAdditionalActions);
  TPrintDepartmentReportAdditionalAction.Create(FAdditionalActions);
  FDevices := TDevices1C.Create(FDriver);
  FDevices.BPOVersion := 32;
  FFormatVersion := 30;
end;

destructor TDriver1Cst30.Destroy;
begin
  FLogger.Free;
  FAdditionalActions.Free;
  FParamList.Free;
  FDevices.Free;
  FDriver := nil;
  inherited Destroy;
end;

procedure TDriver1Cst30.CreateParamList;
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
  for i := Low(ConnectionTypes) to High(ConnectionTypes) do
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
  for i := BAUD_RATE_CODE_MIN to BAUD_RATE_CODE_MAX do
  begin
    ChoiceListItem := Item.ChoiceList.Add;
    ChoiceListItem.Name := BaudRateToStr(i);
    ChoiceListItem.Value := BaudRateToStr(i);
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

///////////////////////////////////////////////////////////
// Возвращает номер версии драйвера }
function TDriver1Cst30.GetVersion: WideString;
begin
  ClearError;
  Result := GetModuleVersion;
end;

function TDriver1Cst30.GetLastError(var ErrorDescription: WideString): Integer;
begin
  ErrorDescription := Format('%.2xh, %s', [FResultCode, FResultDescription]);
  Result := FResultCode;
  Logger.Debug('GetLastError ' + ErrorDescription);
end;

function TDriver1Cst30.GetParameters(var TableParameters: WideString): WordBool;
begin
  Logger.Debug('GetParameters');
  TableParameters := FParamList.ToString;
  Result := True;
end;

procedure TDriver1Cst30.SetError(const AErrorCode: Integer; const AErrorDescription: WideString);
begin
  FResultCode := AErrorCode;
  FResultDescription := AErrorDescription;
end;

function TDriver1Cst30.SetLocalization(const LanguageCode, LocalizationPattern: WideString): WordBool;
begin
  Logger.Debug('SetLocalization');
  Result := False;
  SetError(E_NOTSUPPORTED, SDrivernotSupported);
end;

function TDriver1Cst30.SetParameter(const Name: WideString; Value: OleVariant): WordBool;
begin
  //GlobalLogger.FileName := 'c:\Users\User\AppData\Roaming\SHTRIH-M\log2.txt';
//  GlobalLogger.Enabled := True;
  Logger.Debug('SetParameter  ' + Name + ' ' + Value);
  Result := True;
  try
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

function TDriver1Cst30.Open(var DeviceID: WideString): WordBool;
var
  ADevice: TDevice1C3;
  i: Integer;
  mDev: TDevice1C;
begin
  //GlobalLogger.FileName := 'c:\Users\User\AppData\Roaming\SHTRIH-M\log2.txt';
//  GlobalLogger.Enabled := True;
 // GlobalLogger.Debug('Open');
  Logger.Debug('Open');
  Result := True;
  ADevice := nil;
  try
    ADevice := TDevice1C3.Create(Devices);
    FParams.FormatVersion := FFormatVersion;
    ADevice.Params := FParams;

    ADevice.Open3;
    DeviceID := IntToStr(ADevice.ID);
    Logger.Debug('Open DeviceID = ' + DeviceID);
    SelectDevice(DeviceID);
  except
    on E: Exception do
    begin
      ADevice.Free;
      Result := False;
      Logger.Error('Open Error ' + E.Message);
      HandleException(E);
    end;
  end;
  Logger.Debug('Open.end Device ' + DeviceID + ' Added. Devices list: ' + Devices.Count.ToString + ' Items');
  for i := 0 to Devices.Count - 1 do
    Logger.Debug('ID ' + Devices.Items[i].ID.ToString);
end;

function TDriver1Cst30.Close(const DeviceID: WideString): WordBool;
var
  i: Integer;
  mDev: TDevice1C;
begin
  Logger.Debug('Close DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.Close;
    FDevice.Free;
    FDevice := nil;
    Logger.Debug('Device ' + DeviceID + ' Deleted. Devices list: ' + Devices.Count.ToString + ' Items');
    for i := 0 to Devices.Count - 1 do
      Logger.Debug('ID ' + Devices.Items[i].ID.ToString);
  except
    on E: Exception do
    begin
      Logger.Error('Close Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('Close.end');
end;

function TDriver1Cst30.DeviceTest(var Description: WideString; var DemoModeIsActivated: WideString): WordBool;
var
  ADevice: TDevice1C3;
begin
  Logger.Debug('DeviceTest');
  ClearError;
  Result := True;
  try
    ADevice := TDevice1C3.Create(Devices);
    try
      ADevice.Params := FParams;
      ADevice.DeviceTest2(nil, Description, DemoModeIsActivated);
    finally
      ADevice.Free;
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

function TDriver1Cst30.GetAdditionalActions(var TableActions: WideString): WordBool;
begin
  Logger.Debug('GetAdditionalActions');
  ClearError;
  Result := True;
  try
    TableActions := FAdditionalActions.ToString;
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

function TDriver1Cst30.DoAdditionalAction(const ActionName: WideString): WordBool;
var
  Action: TAdditionalAction;
  ADevice: TDevice1C3;
begin
  Logger.Debug('DoAdditionalAction ActionName = ' + ActionName);
  ClearError;
  Result := True;
  ADevice := TDevice1C3.Create(Devices);
  try
    ADevice.Params := FParams;
    try
      Action := FAdditionalActions.ItemByName(ActionName);
      if Action <> nil then
        Action.Execute(ADevice);
    finally
      ADevice.Free;
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

function TDriver1Cst30.GetDataKKT(const DeviceID: WideString;
  var TableParametersKKT: WideString): WordBool;
begin
  Logger.Debug('GetDataKKT DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.GetDataKKT32(TableParametersKKT);
    Logger.Debug('TableParametersKKT  ' + TableParametersKKT);
  except
    on E: Exception do
    begin
      Logger.Error('GetDataKKT Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('GetDataKKT.end');
end;

function TDriver1Cst30.OperationFN(const DeviceID: WideString; OperationType: Integer; const ParametersFiscal: WideString): WordBool;
begin
  Logger.Debug('OperationFN');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OperationFN32(OperationType, ParametersFiscal);
  except
    on E: Exception do
    begin
      Logger.Error('OperationFN Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('OperationFN.end');
end;

function TDriver1Cst30.CloseShift(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): WordBool;
begin
  Logger.Debug('CloseShift DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.CloseShiftFN32(InputParameters, OutputParameters);
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

function TDriver1Cst30.GetCurrentStatus(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): WordBool;
begin
  Logger.Debug('GetCurrentStatus DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.GetCurrentStatus32(InputParameters, OutputParameters);
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

function TDriver1Cst30.OpenShift(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): WordBool;
begin
  Logger.Debug('OpenShift DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OpenShift32(InputParameters, OutputParameters);
  except
    on E: Exception do
    begin
      Logger.Error('OpenShift Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('OpenShift.end');
end;

function TDriver1Cst30.ProcessCheck(const DeviceID: WideString; Electronically: WordBool; const CheckPackage: WideString; var DocumentOutputParameters: WideString): WordBool;
begin
  Logger.Debug('ProcessCheck DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.ProcessCheck32(Electronically, CheckPackage, DocumentOutputParameters, False);
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

function TDriver1Cst30.ProcessCorrectionCheck(const DeviceID: WideString; const CheckPackage: WideString; var DocumentOutputParameters: WideString): WordBool;
begin
  Logger.Debug('ProcessCorrectionCheck DeviceID = ' + DeviceID);
  Logger.Debug('Package: ' + CheckPackage);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.ProcessCheck32(False, CheckPackage, DocumentOutputParameters, True);
  except
    on E: Exception do
    begin
      Logger.Error('ProcessCorrectionCheck Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('ProcessCorrectionCheck.end');
end;

function TDriver1Cst30.ReportCurrentStatusOfSettlements(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): WordBool;
begin
  Logger.Debug('ReportCurrentStatusOfSettlements DeviceID =' + DeviceID + ' ' + InputParameters);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.ReportCurrentStatusOfSettlements32(InputParameters, OutputParameters);
  except
    on E: Exception do
    begin
      Logger.Error('ReportCurrentStatusOfSettlements Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('ReportCurrentStatusOfSettlements.end');
end;

function TDriver1Cst30.PrintTextDocument(const DeviceID, DocumentPackage: WideString): WordBool;
begin
  Logger.Debug('PrintTextDocument DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.PrintTextDocument32(DocumentPackage);
  except
    on E: Exception do
    begin
      Logger.Error('PrintTextDocument Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('PrintTextDocument.end');
end;

procedure TDriver1Cst30.ClearError;
begin
  FResultCode := 0;
  FResultDescription := 'Ошибок нет';
end;

procedure TDriver1Cst30.HandleException(E: Exception);
var
  DriverError: EDriverError;
begin
  if E is EDriverError then
  begin
    DriverError := E as EDriverError;
    FResultCode := DriverError.ErrorCode;
    FResultDescription := EDriverError(E).Message;
  end
  else
  begin
    FResultCode := E_UNKNOWN;
    FResultDescription := E.Message;
  end;
  Logger.Error('HandleException: ' + IntToStr(FResultCode) + ', ' + FResultDescription);
end;

procedure TDriver1Cst30.SelectDevice(const DeviceID: string);
var
  ID: Integer;
  ADevice: TDevice1C;
  mDev: TDevice1C;
  i: Integer;
begin
  Logger.Debug('SelectDevice DeviceID = ' + DeviceID);
  ID := 0;
  try
    ID := StrToInt(DeviceID);
  except
    RaiseError(E_INVALIDPARAM, Format('%s %s', [GetRes(@SInvalidParam), '"DeviceID"']));
  end;
  ADevice := Devices.ItemByID(ID);
  if ADevice = nil then
  begin
    Logger.Debug('Device ' + ID.ToString + '  not found. Devices list: ' + Devices.Count.ToString + ' Items');
    for i := 0 to Devices.Count - 1 do
      Logger.Debug('ID ' + Devices.Items[i].ID.ToString);
    RaiseError(E_INVALIDPARAM, GetRes(@SDeviceNotActive));
  end;
  if ADevice <> FDevice then
  begin
    if FDevice <> nil then
    begin
      FDevice.Disconnect;
    end;
  end;
  FDevice := TDevice1C3(ADevice);
  FDevice.ApplyDeviceParams;
  Logger.Debug('SelectDevice.end');
end;

function TDriver1Cst30.GetLineLength(const DeviceID: WideString; var LineLength: Integer): WordBool;
begin
  Logger.Debug('GetLineLength DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    Logger.Debug('GetLineLength DeviceID = ' + DeviceID);
    SelectDevice(DeviceID);
    LineLength := Device.GetLineLength;
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

function TDriver1Cst30.GetAdditionalDescription: WideString;
begin
  Result := Format('%.2xh, %s', [FResultCode, FResultDescription]);
end;

function TDriver1Cst30.CashInOutcome(const DeviceID: WideString; const InputParameters: WideString; Amount: Double): WordBool;
begin
  Logger.Debug('CashInOutcome DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.CashInOutcome32(Amount, InputParameters);
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

function TDriver1Cst30.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin
  Logger.Debug('OpenCashDrawer DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OpenCashDrawer(0);
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

function TDriver1Cst30.PrintXReport(const DeviceID: WideString; const InputParameters: WideString): WordBool;
begin
  Logger.Debug('PrintXReport DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.PrintXReport32(InputParameters);
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

function to1CBool(AValue: Boolean): WideString;
begin
  if AValue then
    Result := 'true'
  else
    Result := 'false';
end;

function TDriver1Cst30.GetDescription(var DriverDescription: WideString): WordBool;
var
  Xml: IXMLDocument;
  Node: IXMLNode;
  LogEnabled: Boolean;
  ver: string;
begin
  Logger.Debug('GetDescription');
  if FFormatVersion >= 34 then
    ver := '4.1'
  else
    ver := '3.2';

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
    Node.Attributes['DriverVersion'] := GetDriverVersion;
    Node.Attributes['IntegrationComponentVersion'] := GetDriverVersion;
    Node.Attributes['DownloadURL'] := 'http://www.shtrih-m.ru/support/download/?section_id=76&product_id=all&type_id=156';
    Node.Attributes['LogPath'] := GetLogState(LogEnabled);
    Node.Attributes['LogIsEnabled'] := to1CBool(LogEnabled);
    DriverDescription := Xml.XML.Text;
  finally
    Xml := nil;
  end;
  Logger.Debug('GetDescription.end');
end;

function TDriver1Cst30.GetDriverVersion: string;
var
  Drv: IDrvFR49;
begin
  Drv := DrvFR_create;
  Result := Drv.DriverVersion;
  Drv := nil;
end;

function TDriver1Cst30.GetLocalizationPattern(var LocalizationPattern: WideString): WordBool;
begin
  Result := False;
  SetError(E_NOTSUPPORTED, SDrivernotSupported);
end;

function TDriver1Cst30.GetLogState(var AEnabled: Boolean): string;
var
  Drv: IDrvFR48;
begin
  Drv := DrvFR_create;
  Result := ExtractFilePath(Drv.ComLogFile);
  AEnabled := Drv.LogOn;
  Drv := nil;
end;

function TDriver1Cst30.GetInterfaceRevision: Integer;
begin
  if FFormatVersion >= 34 then
    Result := 4001
  else
    Result := 3002;
end;

function TDriver1Cst30.PrintCheckCopy(const DeviceID, CheckNumber: WideString): WordBool;
begin
  Logger.Debug('PrintCheckCopy DeviceID = ' + DeviceID + '; CheckNumber = ' + CheckNumber);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.PrintCheckCopy(CheckNumber);
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

// 34

function TDriver1Cst30.OpenSessionRegistrationKM(const DeviceID: WideString): WordBool;
begin
  Logger.Debug('OpenSessionRegistrationKM DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OpenSessionRegistrationKM3;
  except
    on E: Exception do
    begin
      Logger.Error('OpenSessionRegistrationKM Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('OpenSessionRegistrationKM.end');
end;

function TDriver1Cst30.CloseSessionRegistrationKM(const DeviceID: WideString): WordBool;
begin
  Logger.Debug('CloseSessionRegistrationKM DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.CloseSessionRegistrationKM3;
  except
    on E: Exception do
    begin
      Logger.Error('CloseSessionRegistrationKM Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('CloseSessionRegistrationKM.end');
end;

function TDriver1Cst30.ConfirmKM(const DeviceID, RequestGUID: WideString; ConfirmationType: Integer): WordBool;
begin
  Logger.Debug('ConfirmKM DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.ConfirmKM(RequestGUID, ConfirmationType);
  except
    on E: Exception do
    begin
      Logger.Error('ConfirmKM Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('ConfirmKM.end');
end;

function TDriver1Cst30.GetProcessingKMResult(const DeviceID: WideString; var ProcessingKMResult: WideString; out RequestStatus: Integer): WordBool;
begin
  Logger.Debug('GetProcessingKMResult DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.GetProcessingKMResult(ProcessingKMResult, RequestStatus);
  except
    on E: Exception do
    begin
      Logger.Error('GetProcessingKMResult Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('GetProcessingKMResult.end');
end;

function TDriver1Cst30.RequestKM(const DeviceID, RequestKM: WideString; var RequestKMResult: WideString): WordBool;
begin
  Logger.Debug('RequestKM DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.RequestKM(RequestKM, RequestKMResult);
  except
    on E: Exception do
    begin
      Logger.Error('RequestKM Error ' + E.Message);
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('RequestKM.end');
end;

end.

