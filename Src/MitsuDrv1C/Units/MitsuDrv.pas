unit MitsuDrv;

interface

uses
  // VCL
  Windows, Classes, SysUtils, ActiveX, Variants, XMLDoc, MSXML, XMLIntf,
  Math, DateUtils,
  // This
  PrinterPort, SerialPort, SocketPort, LogFile, StringUtils, DriverError,
  ByteUtils;

type
  TBaudRates = array [0 .. 8] of Integer;
  TConnectionTypes = array [0 .. 1] of Integer;

const
  CRLF = #13#10;

  /// //////////////////////////////////////////////////////////////////////////
  // Separator line type constants

  MTS_LINE_SINGLE = 1; // одинарная тонкая
  MTS_LINE_DOUBLE = 2; // двойная
  MTS_LINE_THICK = 3; // толстая

  /// //////////////////////////////////////////////////////////////////////////
  // Barcode type constants

  MTS_BARCODE_UPC_A = 0;
  MTS_BARCODE_UPC_E = 1;
  MTS_BARCODE_EAN13 = 2;
  MTS_BARCODE_EAN8 = 3;
  MTS_BARCODE_CODE39 = 4;
  MTS_BARCODE_ITF = 5;
  MTS_BARCODE_CODABAR = 6;
  MTS_BARCODE_CODE93 = 7;
  MTS_BARCODE_CODE128 = 8;
  MTS_BARCODE_QRCODE = 9;

  /// //////////////////////////////////////////////////////////////////////////
  // Text inversion constants

  MTS_TEXT_NO_INVERSION = 0; // нет инверсии: черный текст на белом фоне
  MTS_TEXT_INVERSION = 1; // инверсия: белый текст на черном фоне

  /// //////////////////////////////////////////////////////////////////////////
  // Font constants

  MTS_FONT_DEFAULT = 0;
  // шрифт, заданный настройкой Установка настроек принтера
  MTS_FONT_A = 1; // шрифт "А" (стандартный)
  MTS_FONT_B = 2; // шрифт "B" (компактный)

  /// //////////////////////////////////////////////////////////////////////////
  // Underline constants

  MTS_UNDERLINE_NONE = 0; // нет
  MTS_UNDERLINE_TEXT = 1; // подчеркнут только печатаемый текст
  MTS_UNDERLINE_LINE = 2; // подчеркивание всей строки от левого поля до правого

  /// //////////////////////////////////////////////////////////////////////////
  // Alignment constants

  MTS_ALIGN_LEFT = 0; // по левому краю
  MTS_ALIGN_CENTER = 1; // по центру
  MTS_ALIGN_RIGHT = 2; // по правому краю

  /// //////////////////////////////////////////////////////////////////////////
  // VAT rate constants

  MTS_VAT_RATE_20 = 1; // 1 ставка НДС 20%
  MTS_VAT_RATE_10 = 2; // 2 ставка НДС 10%
  MTS_VAT_RATE_20_120 = 3; // 3 ставка НДС расч. 20/120
  MTS_VAT_RATE_10_110 = 4; // 4 ставка НДС расч. 10/110
  MTS_VAT_RATE_0 = 5; // 5 ставка НДС 0%
  MTS_VAT_RATE_NONE = 6; // 6 НДС не облагается

  /// //////////////////////////////////////////////////////////////////////////
  // Document type constants

  MTS_DOC_TYPE_NONFISCAL = 0; // 0 – Нефискальный документ
  MTS_DOC_TYPE_REG_REPORT = 1; // 1 – Отчёт о регистрации
  MTS_DOC_TYPE_DAY_OPEN = 2; // 2 – Отчёт об открытии смены
  MTS_DOC_TYPE_RECEIPT = 3; // 3 – Кассовый чек
  MTS_DOC_TYPE_BLANK = 4; // 4 – Бланк строкой отчетности (БСО)
  MTS_DOC_TYPE_DAY_CLOSE = 5; // 5 – Отчёт о закрытии смены
  MTS_DOC_TYPE_FD_CLOSE = 6; // 6 – Отчёт о закрытии ФН
  MTS_DOC_TYPE_OPERATOR = 7; // 7 – Подтверждение оператора
  MTS_DOC_TYPE_REREG_REPORT = 11; // 11 – Отчет о (пере) регистрации
  MTS_DOC_TYPE_PAYMENTS = 21; // 21 – Отчет о текущем состоянии расчетов
  MTS_DOC_TYPE_RECEIPT_CORRECTION = 31; // 31 – Кассовый чек коррекции
  MTS_DOC_TYPE_BLANK_CORRECTION = 41; // 41 – БСО коррекции

  /// //////////////////////////////////////////////////////////////////////////
  // Document status constants

  MTS_DOC_STATUS_OPENED = 1;
  MTS_DOC_STATUS_CLOSED = 2;

  /// //////////////////////////////////////////////////////////////////////////
  // Receipt type constants

  MTS_RT_SALE = 1;
  MTS_RT_RETSALE = 2;
  MTS_RT_BUY = 3;
  MTS_RT_RETBUY = 4;

  /// //////////////////////////////////////////////////////////////////////////
  // Tax system type constants

  MTS_TS_GENERAL = 0;
  MTS_TS_SIMPLIFIED_PROFIT = 1; // упрощенная доход (УСН доход)
  MTS_TS_SIMPLIFIED = 2; // упрощенная доход минус расход (УСН доход-расход)
  MTS_TS_AGRICULTURAL = 4; // единый сельскохозяйственный налог (ЕСХН)
  MTS_TS_PATENT = 5; // патентная система налогообложения.

  /// //////////////////////////////////////////////////////////////////////////
  // Options constants

  // b0 Разделительные линии в чеке нет ---- или === графика – 0
  MTS_OP_RECEIPT_SEPARATOR = 0;

  // b1 QR код в кассовом чеке слева по центру справа – 0
  MTS_OP_RECEIPT_QRCODE_ALIGNMENT = 1;

  // b2 Округление итога чека нет до 0,10 до 0,50 до 1,00 0
  MTS_OP_RECEIPT_TOTAL_ROUNDING = 2;

  // b3 Авто-резак нет включен – – 1
  MTS_OP_AUTO_CUTTER = 3;

  // b4 Авто-тест при включении кассы не печат. печатать – – 1
  MTS_OP_PRINT_TEST_ON_START = 4;

  // b5 Открыть денежный ящик при оплате не откр. нал. б/н нал. и б/н 1
  MTS_OP_OPEN_CASH_DRAWER = 5;

  // b6 Звуковой сигнал «близок конец бумаги» выкл. включен – – 0
  MTS_OP_BEEP_ON_PAPER_NEAR_END = 6;

  // b7 Совмещение текстовой строки с QR кодом нет совместить – – 0
  MTS_OP_COMBINE_TEXT_QRCODE = 7;

  // b8 Печатать количество покупок в чеке нет печатать – – 0
  MTS_OP_PRINT_ITEM_COUNT = 8;

  /// //////////////////////////////////////////////////////////////////////////
  // Day status constants

  MTS_DAY_STATUS_CLOSED = 0; // Day is closed
  MTS_DAY_STATUS_OPENED = 1; // Day is opened
  MTS_DAY_STATUS_EXPIRED = 9; // Day is expired (24 hours left)

  /// //////////////////////////////////////////////////////////////////////////
  //

  STX = #02;
  ETX = #03;

  /// //////////////////////////////////////////////////////////////////////////
  // ConnectionType constants

  ConnectionTypeSerial = 0;
  ConnectionTypeSocket = 1;

  ConnectionTypes: TConnectionTypes = (ConnectionTypeSerial,
    ConnectionTypeSocket);

  BaudRates: TBaudRates = (CBR_2400, CBR_4800, CBR_9600, CBR_14400, CBR_19200,
    CBR_38400, CBR_56000, CBR_57600, CBR_115200);

  /// //////////////////////////////////////////////////////////////////////////
  // Notification status constants

  MTS_NS_NO_ACTIVE_TRANSFER = 0; // нет активного обмена
  MTS_NS_READ_STARTED = 1; // начато чтение уведомления;
  MTS_NS_WAIT_FOR_TICKET = 2; // начато чтение уведомления;

  /// //////////////////////////////////////////////////////////////////////////
  // Document type constants

  MTS_DT_NONFISCAL = 0; // Нефискальный документ
  MTS_DT_REG_REPORT = 1; // Отчёт о регистрации
  MTS_DT_DAY_OPEN = 2; // Отчёт об открытии смены
  MTS_DT_RECEIPT = 3; // Кассовый чек
  MTS_DT_BLANK = 4; // Бланк строкой отчетности (БСО);
  MTS_DT_DAY_CLOSE = 5; // Отчёт о закрытии смены
  MTS_DT_FD_CLOSE = 6; // Отчёт о закрытии ФН
  MTS_DT_CASHIER_CONF = 7; // Подтверждение оператора
  MTS_DT_REREG_REPORT = 11; // Отчет о (пере) регистрации
  MTS_DT_CALC_REPORT = 21; // Отчет о текущем состоянии расчетов
  MTS_DT_CORRECTION_REC = 31; // Кассовый чек коррекции
  MTS_DT_CORRECTION_BSO = 41; // БСО коррекции

type
  { TMTSVersion }

  TMTSVersion = record
    Version: AnsiString;
    Size: AnsiString;
    CRC32: AnsiString;
    Serial: AnsiString;
    MAC: AnsiString;
    STS: AnsiString;
  end;

  { TMTSCashier }

  TMTSCashier = record
    Name: WideString;
    INN: WideString;
  end;

  { TMTSPrinterParams }

  TMTSPrinterParams = record
    Printer: WideString;
    BaudRate: Integer;
    PaperWidth: Integer;
    FontType: Integer;
    PrintWidth: Integer;
    CharWidth: Integer;
  end;

  { TMTSDrawerParams }

  TMTSDrawerParams = record
    Pin: Integer;
    Rise: Integer;
    Fall: Integer;
  end;

  { TMTSText }

  TMTSText = record
    Number: Integer;
    Lines: array [0 .. 9] of WideString;
  end;

  { TMTSLANParams }

  TMTSLANParams = record
    Address: AnsiString;
    Port: Integer;
    Mask: AnsiString;
    DNS: AnsiString;
    Gateway: AnsiString;
  end;

  { TMTSFDOParams }

  TMTSFDOParams = record
    Address: AnsiString;
    Port: Integer;
    Client: Integer;
    FNPollPeriod: Integer;
    FDOPollPeriod: Integer;
  end;

  { TMTSOISMParams }

  TMTSOISMParams = record
    Address: AnsiString;
    Port: Integer;
  end;

  { TMTSOKPParams }

  TMTSOKPParams = record
    Address: AnsiString;
    Port: Integer;
  end;

  { TMTSVATNames }

  TMTSVATNames = array [1 .. 6] of WideString;

  { TTagValue }

  TTagValue = record
    ID: Integer;
    Value: AnsiString;
  end;

  { TFNParams }

  TFNParams = record
    Base: Integer;
    IsMarking: Boolean; // признак работы с маркированными товарами
    IsPawnshop: Boolean; // признак осуществления ломбардной деятельности
    IsInsurance: Boolean; // признак осуществления страховой деятельности
    IsCatering: Boolean;
    // признак примененияпри оказании услуг общественного питания
    IsWholesale: Boolean;
    // признак применения в оптовой торговле с организациями и ИП
    IsAutomaticPrinter: Boolean;
    // признак применения с автоматическим устройством
    IsAutomatic: Boolean; // признак автоматического режима
    IsOffline: Boolean; // Признак автономного режима
    IsEncrypted: Boolean; // признак шифрования
    IsOnline: Boolean; // Признак ККТ для расчетов в Интернет
    IsService: Boolean; // Признак расчетов за услуги
    IsBlank: Boolean; // признак режима БСО
    IsLottery: Boolean; // Признак проведения лотереи
    IsGambling: Boolean; // Признак проведения азартных игр
    IsExcisable: Boolean; // Продажа подакцизного товара
    IsVendingMachine: Boolean;
    // Признак применения в автоматическом торговом автомате

    SaleAddress: WideString; // Адрес проведения расчетов
    SaleLocation: WideString; // Место проведения расчетов
    OFDCompany: WideString; // Название организации ОФД
    OFDCompanyINN: WideString; // ИНН организации ОФД
    FNSURL: WideString;
    // Адрес сайта уполномоченного органа (ФНС) в сети «Интернет»
    CompanyName: WideString; // Название организации
    CompanyINN: WideString; // ИНН организация
    SenderEmail: WideString; // Адрес электронной почты отправителя чека
    AutomaticNumber: WideString; // Номер автомата для автоматического режима
    ExtendedProperty: WideString; // дополнительный реквизит ОР
    ExtendedData: WideString; // дополнительные данные ОР
    TaxSystems: AnsiString;
    RegNumber: WideString; // Регистрационный номер ККТ
  end;

  { TMTSRegParams }

  TMTSRegParams = record
    RegNumber: Integer;
    FDocNumber: Integer;
    DateTime: TDateTime;
    Base: AnsiString;

    SerialNumber: AnsiString;
    ModelVersion: AnsiString;
    FFDVersionFP: AnsiString;
    FFDVersionFD: AnsiString;
    FFDVersion: AnsiString;
    FDSerial: AnsiString;

    FNParams: TFNParams;
  end;

  { TMTSDayStatus }

  TMTSDayStatus = record
    DayNumber: Integer;
    DayStatus: Integer;
    RecNumber: Integer;
    KeyExpDays: Integer;
  end;

  { TMTSError }

  TMTSError = record
    Code: Integer;
    FSError: AnsiString;
    Tag: AnsiString;
    Par: AnsiString;
  end;

  { TMTSTotals }

  TMTSTotals = record
    Count: Integer;
    Total: Int64;
    T1136: Int64;
    T1138: Int64;
    T1218: Int64;
    T1219: Int64;
    T1220: Int64;
    T1139: Int64;
    T1140: Int64;
    T1141: Int64;
    T1142: Int64;
    T1143: Int64;
    T1183: Int64;
  end;

  { TMTSDayTotals }

  TMTSDayTotals = record
    DayNumber: Integer;
    Sale: TMTSTotals;
    RetSale: TMTSTotals;
    Buy: TMTSTotals;
    RetBuy: TMTSTotals;
  end;

  { TMTSFDStatus }

  TMTSFDStatus = record
    Serial: AnsiString;
    FFDVersion: AnsiString;
    Phase: Integer;
    RegCount: Integer;
    RegLeft: Integer;
    ValidDate: TDateTime;
    LastDoc: Integer;
    DocDate: TDateTime;
    Flags: Integer;
  end;

  { TMTSFDOStatus }

  TMTSFDOStatus = record
    Serial: AnsiString;
    DocCount: Integer;
    FirstDoc: Integer;
    FirstDate: TDateTime;
  end;

  { TMTSMCStatus }

  TMTSMCStatus = record
    MCStatus: Integer; // состояние по проверке КМ
    MCCount: Integer; // количество сохранённых результатов проверки КМ
    MCFlags: Integer; // флаг разрешения команд работы с КМ (маска)
    MCNStatus: Integer;
    // состояние уведомления о реализации маркированного товара
    MCNCount: Integer; // количество КМ, включенных в уведомление
    NCount: Integer; // количество уведомлений в очереди
    FillStatus: Integer; // состояние заполнения области хранения уведомлений
  end;

  { TOISMStatus }

  TOISMStatus = record
    Status: Integer; // состояние по передаче уведомлений
    QueueCount: Integer; // количество уведомлений в очереди
    FirstNumber: Integer; // номер первого неподтвержденного уведомления
    FirstDate: TDateTime; // дата и время первого неподтвержденного уведомления
    FillPercent: Integer; // процент заполнения области хранения уведомлений
  end;

  { TKeysStatus }

  TKeysStatus = record
    ExtClient: Boolean; // признак работы через внешний клиент обмена
    UpdateNeeded: Boolean; // признак необходимости обновления ключей
    CapD7Command: Boolean; // признак поддержки ФН выполнения команды D7
    OkpURL: AnsiString; // адрес и порт ОКП
    DateTime: TDateTime;
    // дата и время последнего обновления ключей проверки КМ
  end;

  { TDocStatus }

  TDocStatus = record
    Number: Integer; // порядковый номер фискального документа
    DocType: Integer; // тип документа
    Status: Integer; // состояние документа
    Size: Integer; // размер открытого документа
  end;

  { TFDParams }

  TFDParams = record
    Offset: Integer;
    Size: Integer;
  end;

  { TMitsuParams }

  TMitsuParams = record
    ConnectionType: Integer;
    PortName: AnsiString;
    BaudRate: Integer;
    ByteTimeout: Integer;
    RemoteHost: AnsiString;
    RemotePort: Integer;
    LogPath: WideString;
    LogEnabled: Boolean;
  end;

  { TMTSDayParams }

  TMTSDayParams = record
    SaleAddress: WideString; // Адрес проведения расчетов
    SaleLocation: WideString; // Место проведения расчетов
    ExtendedProperty: WideString; // дополнительный реквизит ОР
    ExtendedData: WideString; // дополнительные данные ОР
    PrintRequired: Boolean;
  end;

  { TMTSCorrection }

  TMTSCorrection = record
    Date: TDateTime;
    Document: AnsiString;
  end;

  { TMTSOpenReceipt }

  TMTSOpenReceipt = record
    ReceiptType: Integer; // Тип чека
    TaxSystem: Integer; // Система налогообложения
    SaleAddress: WideString; // Адрес проведения расчетов
    SaleLocation: WideString; // Место проведения расчетов
    AutomaticNumber: WideString; // Номер автомата для автоматического режима
    SenderEmail: WideString; // Адрес электронной почты отправителя чека
    Correction: TMTSCorrection;
  end;

  { TMTSAgentData }

  TMTSAgentData = record
    Enabled: Boolean;
    AgentOperation: WideString; // 1044, операция платежного агента
    AgentPhone: WideString; // 1073, телефон платежного агента
    PaymentProcessorPhone: WideString;
    // Телефон оператора по приему платежей 1074
    AcquirerOperatorPhone: WideString; // Телефон оператора перевода 1075
    AcquirerOperatorName: WideString; // Наименование оператора перевода 1026
    AcquirerOperatorAddress: WideString; // Адрес оператора перевода 1005
    AcquirerOperatorINN: WideString; // ИНН оператора перевода 1016
  end;

  { TMTSIndustryAttribute }

  TMTSIndustryAttribute = record
    Enabled: Boolean;
    IdentifierFOIV: AnsiString; // <T1262>идентификатор ФОИВ</T1262>
    DocumentDate: TDateTime; // <T1263>дата документа основания</T1263>
    DocumentNumber: AnsiString; // <T1264>номер документа основания</T1264>
    AttributeValue: AnsiString; // <T1265>значение отраслевого реквизита</T1265>
  end;

  { TVendorData }

  TMTSVendorData = record
    Enabled: Boolean;
    Phone: WideString; // Телефон поставщика 1171
    Name: WideString; // Наименование поставщика 1225
    INN: WideString; // ИНН поставщика 1226
  end;

  { TMTSPosition }

  TMTSPosition = record
    Quantity: Double;
    TaxRate: Integer;
    UnitValue: Integer;
    Price: Int64;
    Total: Int64;
    ItemType: Integer;
    PaymentType: Integer;
    ExciseTaxTotal: Int64;
    CountryCode: WideString;
    CustomsDeclaration: WideString;
    Name: WideString;
    Numerator: Integer;
    Denominator: Integer;
    MarkingCode: AnsiString;
    AddAttribute: AnsiString;
    AgentType: Integer;
    AgentData: TMTSAgentData;
    VendorData: TMTSVendorData;
    IndustryAttribute: TMTSIndustryAttribute;
  end;

  { TMTSCustomerDetail }

  TMTSCustomerDetail = record
    Enabled: Boolean;
    Name: WideString; // <T1227>ФИО или наименование покупателя</T1227>
    INN: WideString; // <T1228>ИНН покупателя</T1228>
    BirthDate: TDateTime; // <T1243>дата рождения покупателя</T1243>
    CountryCode: Integer; // <T1244>гражданство покупателя</T1244>
    DocumentCode: Integer;
    // <T1245>код вида документа, удостоверяющего личность</T1245>
    DocumentData: WideString;
    // <T1246>данные документа, удостоверяющего личность</T1246>
    Address: WideString; // <T1254>адрес покупателя</T1254>
  end;

  { TMTSOperationInfo }

  TMTSOperationInfo = record
    Enabled: Boolean;
    ID: Byte;
    Data: AnsiString;
    Date: TDateTime;
  end;

  { TMTSUserAttribute }

  TMTSUserAttribute = record
    Enabled: Boolean;
    Name: AnsiString;
    Value: AnsiString;
  end;

  { TMTSAttributes }

  TMTSAttributes = record
    ExtraAttribute: WideString;
    CustomerPhone: WideString;
    CustomerDetail: TMTSCustomerDetail;
    IndustryAttribute: TMTSIndustryAttribute;
    OperationInfo: TMTSOperationInfo;
    UserAttribute: TMTSUserAttribute;
  end;

  { TMTSReceiptTotal }

  TMTSReceiptTotal = record
    Total: Int64; // итог чека
    RoundedTotal: Int64; // округленный итог чека
    RoundAmount: Int64; // сумма округления
    ItemsCount: Integer; // количество предметов расчета
  end;

  { TMTSReceiptPayment }

  TMTSReceiptPayment = record
    CashAmount: Int64; // сумма оплаты наличными
    CardAmount: Int64; // сумма оплаты безналичными
    AdvanceAmount: Int64; // сумма оплаты в зачет аванса
    CreditAmount: Int64; // сумма оплаты в кредит
    OtherAmount: Int64; // сумма оплаты иная
    DiscountAmount: Int64; // сумма произвольной скидки
    CommentType: Integer; // тип оплаты безналичными от 1 до 5
    CommentText: WideString; // текстовый комментарий до 168 символов
    AmountType1: Int64; // сумма оплаты безналичными тип 1
    AmountType2: Int64; // сумма оплаты безналичными тип 2
    AmountType3: Int64; // сумма оплаты безналичными тип 3
    AmountType4: Int64; // сумма оплаты безналичными тип 4
    AmountType5: Int64; // сумма оплаты безналичными тип 5
  end;

  { TMTSEndPositions }

  TMTSEndPositions = record
    RecNumber: Integer; // номер чека за смену
    DocNumber: Integer; // номер фискального документа
    FiscalSign: AnsiString; // фискальный признак документа
    Date: TDateTime; // дата
    Total: Int64; // итог чека
    AutomaticNumber: Integer; // номер автомата
    SaleAddress: WideString; // Адрес проведения расчетов
    SaleLocation: WideString; // Место проведения расчетов
  end;

  { TMTSCorrection }

  TMTSCorrectionReason = record
    Date: TDateTime;
    Document: AnsiString;
  end;

  { TMTSPrintText }

  TMTSPrintText = record
    Text: WideString;
    IsInversion: Boolean;
    HorizontalFactor: Integer;
    VerticalFactor: Integer;
    FontType: Integer;
    UnderlineMode: Integer;
    Alignment: Integer;
  end;

  { TMTSBarcode }

  TMTSBarcode = record
    BarcodeType: Integer; // тип кода
    ModuleWidth: Integer; // ширина штриха кода в пикселях (от 1 до 6)
    BarcodeHeight: Integer; // высота кода в пикселях (от 1 до 255)
    Data: AnsiString; // значение (должно соответствовать стандартам кода)
  end;

  { TMTSQRCode }

  TMTSQRCode = record
    Data: AnsiString;
    Text: AnsiString;
    Alignment: Integer;
    ModuleWidth: Integer;
    CorrectionLevel: Integer;
  end;

  { TMTSPicture }

  TMTSPicture = record
    PicNumber: Integer;
    Alignment: Integer;
  end;

  { TMTSMarkCheck }

  TMTSMarkCheck = record
    Status: Integer; // T2004 : результат проверки КМ в ФН
    Reason: Integer; // RES : код причины отказа в проверке КМ в ФН
  end;

  { TMTSCalcReport }

  TMTSCalcReport = record
    PendingCount: Integer;
    FirstDocDate: TDateTime;
    FDocNumber: Integer;
    FiscalSign: Integer;
  end;

  { TMTSTestMark }

  TMTSTestMark = record
    Quantity: Double;
    MeasureOfQuantity: Integer;
    PlannedStatus: Integer;
    Numerator: Integer;
    Denominator: Integer;
    MarkingCode: AnsiString;
  end;

  { TMTSTestMarkResponse }

  TMTSTestMarkResponse = record
    Mode: Integer;
    TestResult: Integer;
    Reason: Integer;
    Length: Integer;
    Data: AnsiString;
  end;

  { TMTSTestMarkResponse2 }

  TMTSTestMarkResponse2 = record
    Mode: Integer;
    TestResult: Integer;
    Reason: Integer;
    MarCheckStatus: Integer;
    RequestProcessCode: Integer;
    ItemCodeStatus: Integer;
    ItemStatusResponse: Integer;
  end;

  { TMitsuDrv }

  TMitsuDrv = class
  private
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FAnswerDoc: IXMLDocument;
    FAnswer: AnsiString;
    FCommand: AnsiString;
    FLastError: TMTSError;
    FParams: TMitsuParams;
    FPrintDocument: Boolean;
    function FNParamsToXml(const Params: TFNParams): AnsiString;
    procedure AddAgentData(Node: IXmlNode; const P: TMTSAgentData);
  public
    function GetPort: IPrinterPort;
    function CreatePort: IPrinterPort;
    function EncodeCommand(const Data: AnsiString): AnsiString;
    function GetCRC(const Data: AnsiString): Byte;
    function GetRequest(const Request: AnsiString): Integer;
    function GetAttribute(const Attribute: AnsiString): AnsiString;
    function GetHexAttribute(const Attribute: AnsiString): Integer;
    function GetIntAttribute(const Attribute: AnsiString): Integer;
    function GetIntAttribute3(const Attribute: AnsiString; N: Integer): Integer;
    function GetDateAttribute(const Attribute: AnsiString): TDateTime;
    function GetTimeAttribute(const Attribute: AnsiString): TDateTime;
    function GetChildAttribute(const Child, Attribute: AnsiString): AnsiString;
    function GetChildText(const Child: AnsiString): AnsiString;
    function HasAttribute(const Attribute: AnsiString): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LockPort;
    procedure UnlockPort;
    procedure Check(Code: Integer);

    function Reset: Integer;
    function Connect: Integer;
    function Disconnect: Integer;
    function WaitForPrinting: Integer;
    class function ValidBaudRates: TBaudRates;
    class function ValidConnectionTypes: TConnectionTypes;
    function Send(const Command: AnsiString): Integer; overload;
    function Send(const Command: AnsiString; var Answer: AnsiString)
      : Integer; overload;

    function Succeeded(rc: Integer): Boolean;
    function ReadDeviceName(var DeviceName: WideString): Integer;
    function ReadDeviceVersion(var R: TMTSVersion): Integer;
    function ReadDateTime(var R: TDateTime): Integer;
    function ReadCashier(var R: TMTSCashier): Integer;
    function ReadPrinterParams(var R: TMTSPrinterParams): Integer;
    function ReadDrawerParams(var R: TMTSDrawerParams): Integer;
    function ReadBaudRate(var BaudRate: Integer): Integer;
    function ReadText(var Text: TMTSText): Integer;
    function ReadLANParams(var R: TMTSLANParams): Integer;
    function ReadFDOParams(var R: TMTSFDOParams): Integer;
    function ReadOISMParams(var R: TMTSOISMParams): Integer;
    function ReadOKPParams(var R: TMTSOKPParams): Integer;
    function ReadVATNames(var R: TMTSVATNames): Integer;
    function ReadRegParams(var R: TMTSRegParams): Integer;
    function ReadDayStatus(var R: TMTSDayStatus): Integer;
    function ReadDayTotalsReceipts(var R: TMTSDayTotals): Integer;
    function ReadDayTotalsCorrection(var R: TMTSDayTotals): Integer;
    function ReadDayTotals(RequestType: Integer; var R: TMTSDayTotals): Integer;
    function ReadFDTotalReceipts(var R: TMTSDayTotals): Integer;
    function ReadFDTotalCorrection(var R: TMTSDayTotals): Integer;
    function ReadFDStatus(var R: TMTSFDStatus): Integer;
    function ReadFDOStatus(var R: TMTSFDOStatus): Integer;
    function ReadMCStatus(var R: TMTSMCStatus): Integer;
    function ReadOISMStatus(var R: TOISMStatus): Integer;
    function ReadKeysStatus(var R: TKeysStatus): Integer;
    function ReadLastDocStatus(var R: TDocStatus): Integer;
    function ReadDocStatus(N: Integer; var R: TDocStatus): Integer;
    function ReadFDDoc(N: Integer; var R: TFDParams): Integer;
    function ReadFDDocPrint(N: Integer; var R: TFDParams): Integer;
    function ReadFDData(Offset, Length: Integer; var Data: AnsiString): Integer;
    function ReadFD(N: Integer; var Data: AnsiString): Integer;
    function ReadPowerLost(var Flag: Boolean): Integer;
    function ReadOptions(var Options: Integer): Integer;
    function WriteDate(const Date: TDateTime): Integer;
    function WriteCashier(const Cashier: TMTSCashier): Integer;
    function WriteBaudRate(const BaudRate: Integer): Integer;
    function FNOpen(const Params: TFNParams): Integer;
    function FNChange(const Params: TFNParams): Integer;
    function FNPrintReg(N: Integer): Integer;
    function FNClose(const Params: TFNParams): Integer;

    function OpenFiscalDay(const Params: TMTSDayParams): Integer;
    function CloseFiscalDay(const Params: TMTSDayParams): Integer;

    function OpenReceipt(const Params: TMTSOpenReceipt): Integer;
    function CancelReceipt: Integer;
    function BeginRecPositions: Integer;
    function AddRecPosition(const P: TMTSPosition): Integer;
    function AddRecAttributes(const P: TMTSAttributes): Integer;
    function ReadReceiptTotal(var R: TMTSReceiptTotal): Integer;
    function PayReceipt(const P: TMTSReceiptPayment): Integer;
    function EndPositions(var R: TMTSEndPositions): Integer;
    function CloseReceipt(Print: Boolean): Integer;
    function OpenCorrection(const P: TMTSOpenReceipt): Integer;
    function PayCorrection(const P: TMTSReceiptPayment): Integer;
    function OpenNonfiscal: Integer;
    function CloseNonfiscal(Print: Boolean): Integer;
    function Print: Integer;
    function AddText(const P: TMTSPrintText): Integer; overload;
    function AddText(const Text: WideString): Integer; overload;
    function AddBarcode(const P: TMTSBarcode): Integer;
    function AddQRCode(const P: TMTSQRCode): Integer;
    function AddPicture(const P: TMTSPicture): Integer;
    function AddSeparatorLine(LineType: Integer): Integer;
    function AddBlankPixels(PixelCount: Integer): Integer;
    function AddBlankLines(LineCount: Integer): Integer;
    function FeedPixels(PixelCount: Integer): Integer;
    function CutPaper: Integer;
    function RestartFD: Integer;
    function InitPrinter: Integer;
    function ReadPrinterStatus: Integer;
    function OpenCashDrawer: Integer;
    function ReadCashDrawerStatus(var Status: Integer): Integer;
    function MakeXReport(var R: TMTSDayStatus): Integer;
    function MakeCalcReport(var R: TMTSCalcReport): Integer;
    function MCCheckMarkingCode(const MarkingCode: AnsiString;
      var R: TMTSMarkCheck): Integer;
    function MCReadRequest(const P: TMTSTestMark;
      var R: TMTSTestMarkResponse): Integer;
    function MCReadRequestRec(const P: TMTSTestMark;
      var R: TMTSTestMarkResponse2): Integer;
    function MCReadRequestData(const P: TMTSTestMark;
      var R: TMTSTestMarkResponse): Integer;
    function MCWriteResponse(const Response: AnsiString;
      var R: TMTSTestMarkResponse): Integer;

    property Logger: ILogFile read FLogger;
    property Port: IPrinterPort read GetPort;
    property Answer: AnsiString read FAnswer;
    property Command: AnsiString read FCommand;
    property Params: TMitsuParams read FParams write FParams;
    property PrintDocument: Boolean read FPrintDocument write FPrintDocument;
  end;

function ConnectionTypeToStr(AConnectionType: Integer): string;

implementation

procedure AddChild(Node: IXmlNode; const TagName, Text: WideString);
begin
  Node.AddChild(TagName).Text := Text;
end;

const
  BoolToStr: array [Boolean] of string = ('0', '1');

function ConnectionTypeToStr(AConnectionType: Integer): string;
begin
  case AConnectionType of
    0:
      Result := 'COM порт';
    1:
      Result := 'TCP подключение';
  else
    Result := 'Неизвестно';
  end
end;

function GetAttribute2(Root: IXmlNode; const Attribute: AnsiString; N: Integer)
  : AnsiString;
var
  Node: IXmlNode;
begin
  Result := '';
  Node := Root.AttributeNodes.FindNode(Attribute);
  if Node <> nil then
  begin
    if not VarIsNull(Node.NodeValue) then
    begin
      Result := GetString(Node.NodeValue, N, ['|']);
    end;
  end;
end;

function GetIntAttribute2(Node: IXmlNode; const Attribute: AnsiString;
  N: Integer): Integer;
begin
  Result := StrToIntDef(GetAttribute2(Node, Attribute, N), 0);
end;

function getErrorMessage(Code: Integer): WideString;
begin
  Result := '';
  case Code of
    0:
      Result := 'нет ошибок';
    1:
      Result := 'неизвестная операция';
    2:
      Result := 'недостаточно памяти для выполнения операции';
    3:
      Result := 'операция не задана';
    4:
      Result := 'не задана структура хранения ошибки операции ФН';
    5:
      Result := 'не задана структура для результатов операции ФН';
    6:
      Result := 'не задана структура входящих параметров операции ФН';
    7:
      Result := 'превышен максимальный размер данных для команды ФН';
    8:
      Result := 'внутренняя ошибка ПО (не задан параметр в классификаторе команд)';
    10:
      Result := 'ошибка исходного состояния ФН перед (пере-)регистрацией';
    11:
      Result := 'ошибка ФН при получении статуса';
    12:
      Result := 'ошибка ФН при выдаче команды "Начать отчет о регистрации"';
    13:
      Result := 'ошибка ФН при выдаче команды "Передать данные документа"';
    14:
      Result := 'ошибка ФН при выдаче команды "Сформировать отчет о регистрации (перерегистрации)"';
    15:
      Result := 'ошибка ФН при выдаче команды "Начать закрытие фискального режима ФН"';
    16:
      Result := 'ошибка ФН при выдаче команды "Закрыть фискальный режим ФН"';
    17:
      Result := 'ошибка при попытке захвата ФН';
    18:
      Result := 'ошибка ФН при выдаче команды "Начать формирование отчета о текущем состоянии расчетов"';
    19:
      Result := 'ошибка ФН при выдаче команды "Сформировать отчет о текущем состоянии расчетов"';
    20:
      Result := 'ошибка ФН: смена открыта';
    21:
      Result := 'ошибка ФН: смена закрыта';
    22:
      Result := 'ошибка ФН: имеется незакрытый документ';
    23:
      Result := 'ошибка ФН при выдаче команды "Запрос количества ФД, на которые нет квитанции"';
    24:
      Result := 'ошибка ФН при выдаче команды "Запрос срока действия ФН"';
    25:
      Result := 'ошибка ФН при выдаче команды "Запрос итогов фискализации ФН"';
    26:
      Result := 'ошибка ФН: есть неподтвержденные в ОФД документы';
    27:
      Result := 'ошибка ФН при выдаче команды "Начать открытие смены"';
    28:
      Result := 'ошибка ФН при выдаче команды "Открыть смену"';
    29:
      Result := 'ошибка ФН при выдаче команды "Начать закрытие смены"';
    30:
      Result := 'ошибка ФН при выдаче команды "Закрыть смену"';
    31:
      Result := 'ошибка ФН при выдаче команды "Начать формирование чека (БСО)"';
    32:
      Result := 'ошибка определения типа: чек или БСО';
    33:
      Result := 'ошибка ФН: чек (БСО) не открыт';
    34:
      Result := 'ошибка преобразования данных';
    35:
      Result := 'ошибка ФН при выдаче команды "Сформировать чек"';
    36:
      Result := 'ошибка ФН при выдаче команды "Отменить текущий документ"';
    37:
      Result := 'ошибка: незакрытый документ отсутствует';
    38:
      Result := 'ошибка: время смены истекло';
    39:
      Result := 'ошибка: чек коррекции (БСО коррекции) не открыт';
    40:
      Result := 'ошибка ФН при получении счетчиков';
    41:
      Result := 'ошибка ФН при получении состояния смены';
    42:
      Result := 'ошибка: чек пустой (нет предметов расчета)';
    43:
      Result := 'ошибка: стадия формирования чека не соответствует операции';
    44:
      Result := 'ошибка ФН при выдаче команды "Запрос номера и типа версии ПО ФН"';
    45:
      Result := 'ошибка: нужна отладочная версия ФН для выполнения операции';
    46:
      Result := 'ошибка ФН при выдаче команды "Сброс ФН"';
    47:
      Result := 'ошибка ФН при получении статуса информационного обмена с ОФД';
    48:
      Result := 'ошибка ФН: чтение сообщения для ОФД уже начато';
    49:
      Result := 'ошибка ФН: нет сообщений для ОФД';
    50:
      Result := 'ошибка ФН при выдаче команды "Передать статус транспортного соединения с сервером ОФД"';
    51:
      Result := 'ошибка ФН при выдаче команды "Начать чтение сообщения для сервера ОФД"';
    52:
      Result := 'ошибка ФН: чтение сообщения для ОФД еще не начато';
    53:
      Result := 'ошибка ФН при выдаче команды "Отменить чтение сообщения для сервера ОФД"';
    54:
      Result := 'ошибка ФН при выдаче команды "Прочитать блок сообщения для сервера ОФД"';
    55:
      Result := 'ошибка ФН: нет готовности к принятию квитанции от ОФД';
    56:
      Result := 'ошибка ФН при выдаче команды "Передать квитанцию от сервера ОФД"';
    57:
      Result := 'ошибка ФН: неверный фискальный признак';
    58:
      Result := 'ошибка ФН: неверный формат квитанции';
    59:
      Result := 'ошибка ФН: неверный номер ФД';
    60:
      Result := 'ошибка ФН: неверный номер ФН';
    61:
      Result := 'ошибка ФН: неверный CRC';
    62:
      Result := 'ошибка ФН при выдаче команды "Запрос фискального документа в TLV формате"';
    63:
      Result := 'ошибка ФН при выдаче команды "Чтение TLV фискального документа"';
    64:
      Result := 'ошибка ФН: отсутствуют необходимые данные документа в архиве';
    65:
      Result := 'ошибка ФН: запрошенный из архива документ не является чеком';
    66:
      Result := 'ошибка ФН при выдаче команды "Запрос общего размера данных переданных командой 07h"';
    67:
      Result := 'ошибка ФН при выдаче команды "Запрос формата ФН"';
    68:
      Result := 'ошибка ФН: получены ошибочные данные от ФН';
    69:
      Result := 'ошибка ФН: ФН не готов или отсутствует';
    70:
      Result := 'ошибка ФН: превышено время ожидания ответа от ФН';
    71:
      Result := 'ошибка ФН: Не удалось получить запрос на проверку кода маркировки';
    72:
      Result := 'ошибка ФН: операция не поддерживается в автономном режиме';
    73:
      Result := 'ошибка ФН: чтение уведомления уже начато';
    74:
      Result := 'ошибка ФН: нет уведомлений для передачи';
    75:
      Result := 'ошибка ФН при выдаче команды "Начать чтение уведомления"';
    76:
      Result := 'ошибка ФН: чтение уведомления еще не начато';
    77:
      Result := 'ошибка ФН: нет готовности к принятию квитанции по уведомлениям';
    78:
      Result := 'ошибка ФН: неверный номер уведомления';
    79:
      Result := 'ошибка ФН: неверная длина ответа';
    80:
      Result := 'операция поддерживается только в автономном режиме';
    81:
      Result := 'запрос на обновление ключей проверки КМ не был сформирован';
    82:
      Result := 'ошибка ФН: неверный номер запроса в ответе';
    83:
      Result := 'ошибка ФН: для выполнения команды необходимо обновить ключи проверки кодов маркировки';
    84:
      Result := 'необходимо выгрузить уведомления';
    94:
      Result := 'Таймаут приема команды';
    95:
      Result := 'Устройство печати занято…';
    96:
      Result := 'В команде заданы неизвестные параметры';
    97:
      Result := 'В команде отсутствуют обязательные параметры';
    98:
      Result := 'Команда содержит параметры, а их не должно быть';
    99:
      Result := 'Неверный формат команды или неизвестная команда';
    100:
      Result := 'ошибка задания версии ФФД';
    101:
      Result := 'ошибка задания заводского номера';
    102:
      Result := 'ошибка задания версии';
    103:
      Result := 'ошибка задания регистрационного номера';
    104:
      Result := 'ошибка задания ИНН';
    105:
      Result := 'ошибка задания ИНН ОФД';
    106:
      Result := 'ошибка задания причины перерегистрации';
    107:
      Result := 'ошибка: заданная система налогообложения не поддерживается';
    108:
      Result := 'ошибка задания признака расчета';
    109:
      Result := 'ошибка задания признака способа расчета';
    110:
      Result := 'ошибка задания признака предмета расчета';
    111:
      Result := 'ошибка задания наименования предмета расчета';
    112:
      Result := 'ошибка задания единицы измерения предмета расчета';
    113:
      Result := 'ошибка задания кода товарной номенклатуры предмета расчета';
    114:
      Result := 'ошибка задания количества единиц предмета расчета';
    115:
      Result := 'ошибка задания цены за единицу предмета расчета';
    116:
      Result := 'ошибка задания стоимости предмета расчета';
    117:
      Result := 'ошибка задания ставки НДС предмета расчета';
    118:
      Result := 'ошибка расчета размера НДС за единицу предмета расчета';
    119:
      Result := 'ошибка расчета размера НДС предмета расчета';
    120:
      Result := 'ошибка: расчет стоимости по позициям чека превысил максимально допустимое значение';
    121:
      Result := 'ошибка: расчет стоимости по чеку превысил сумму оплат';
    122:
      Result := 'ошибка задания количества принятых наличных денег в оплату чека';
    123:
      Result := 'ошибка: расчет стоимости по видам оплаты чека превысил максимально допустимое значение';
    124:
      Result := 'ошибка получения текущего времени от внутренних часов';
    125:
      Result := 'ошибка: в чеке с оплатой кредита может быть только один предмет расчета';
    126:
      Result := 'ошибка: кассир не установлен';
    127:
      Result := 'ошибка задания признака агента';
    128:
      Result := 'ошибка: документ в электронной форме не сформирован';
    129:
      Result := 'ошибка: превышено максимальное количество предметов с кодом товарной номенклатуры';
    130:
      Result := 'ошибка: попытка повторного задания уникального параметра';
    131:
      Result := 'ошибка: не задан ИНН поставщика';
    132:
      Result := 'ошибка: попытка задания количества уникального товара';
    133:
      Result := 'ошибка: сбой принтера';
    134:
      Result := 'неудача при записи на флэш-память';
    135:
      Result := 'файл обновления не был загружен';
    136:
      Result := 'текущая версия ФФД ФН не поддерживает операцию';
    137:
      Result := 'текущая версия ФФД ФН не поддерживается';
    138:
      Result := 'ошибочная последовательность команд';
    139:
      Result := 'работа с подакцизными товарами запрещена';
    140:
      Result := 'позиции с маркированными товарами в чеках расхода запрещены';
    141:
      Result := 'сумма оплат видов безналичного расчета не равна размеру оплаты электронными';
    142:
      Result := 'размер округления не должен превышать 99 копеек';
    143:
      Result := 'сумма расчета по чеку в рублях не должна изменяться после округления';
    200:
      Result := 'у команды есть неправильно заданные операнды';
    201:
      Result := 'у команды есть не заданные операнды';
    202:
      Result := 'ошибка задания режимов работы';
    203:
      Result := 'ошибка задания расширенных режимов работы';
    204:
      Result := 'ошибка задания параметра с датой/временем';
    205:
      Result := 'ошибка задания параметра с ИНН';
    206:
      Result := 'ошибка задания параметра с битовой маской';
    207:
      Result := 'длина строки слишком большая';
    208:
      Result := 'некорректные данные';
    209:
      Result := 'команда допустима только при использовании внешнего клиента обмена';
    401:
      Result := 'неизвестная команда ФН';
    402:
      Result := 'некорректное состояние ФН';
    403:
      Result := 'отказ ФН';
    404:
      Result := 'отказ КС';
    405:
      Result := 'параметры команды не соответствуют сроку жизни ФН';
    407:
      Result := 'некорректная дата и/или время';
    408:
      Result := 'нет запрошенных данных';
    409:
      Result := 'некорректное значение параметров команды';
    410:
      Result := 'некорректная команда.';
    411:
      Result := 'неразрешенные реквизиты.';
    412:
      Result := 'дублирование данных';
    413:
      Result := 'отсутствуют данные, необходимые для корректного учета в ФН';
    414:
      Result := 'количество позиций в документе превысило допустимый предел';
    416:
      Result := 'превышение размеров TLV данных';
    417:
      Result := 'нет транспортного соединения';
    418:
      Result := 'исчерпан ресурс ФН';
    420:
      Result := 'ограничение ресурса ФН';
    422:
      Result := 'продолжительность смены превышена';
    423:
      Result := 'некорректные данные о промежутке времени между фискальными документами';
    424:
      Result := 'некорректный реквизит, переданный в ФН';
    425:
      Result := 'реквизит не соответствует установкам при регистрации';
    432:
      Result := 'сообщение ОФД не может быть принято';
    435:
      Result := 'ошибка сервиса обновления ключей проверки КМ';
    436:
      Result := 'неизвестный ответ сервиса обновления ключей проверки кодов проверки';
    448:
      Result := 'ошибка: требуется повтор процедуры обновления ключей проверки КМ';
    450:
      Result := 'запрещена работа с маркированным товарами';
    451:
      Result := 'неверная последовательность подачи команд для обработки маркированных товаров';
    452:
      Result := 'работа с маркированными товарами временно заблокирована';
    453:
      Result := 'переполнена таблица проверки кодов маркировки';
    454:
      Result := 'превышен период 90 дня со времени последнего обновления ключей проверки';
    460:
      Result := 'в блоке TLV отсутствуют необходимые реквизиты';
    462:
      Result := 'в реквизите 2007 содержится КМ, который ранее не проверялся в ФН';
    500:
      Result := 'нет бумаги в принтере';
    501:
      Result := 'крышка принтера открыта';
    502:
      Result := 'состояние принтера не рабочее (OFFLINE)';
    503:
      Result := 'сбой отрезчика';
    504:
      Result := 'есть другая ошибка принтера';
    505:
      Result := 'принтер выключен';
    506:
      Result := 'бумага заканчивается';
    509:
      Result := 'принтер занят, идет печать';
    510:
      Result := 'печатная форма документа не была завершена (сбой принтера)';
    511:
      Result := 'нажата кнопка прогона бумаги';
    600:
      Result := 'ошибка RTC при выдаче команды "Прочитать дату/время"';
    601:
      Result := 'ошибка RTC при выдаче команды "Установить дату/время"';
    602:
      Result := 'новые дата и время меньше даты и времени последнего оформленного фискального документа';
    604:
      Result := 'ошибка: не удалось связаться с сервером ОИСМ';
    605:
      Result := 'ошибка: получен пустой ответ от ОИСМ';
    606:
      Result := 'ошибка: не удалось связаться с сервером ОКП';
    607:
      Result := 'ошибка: получен пустой ответ от ОКП';
    608:
      Result := 'общая ошибка работы с ОКП';
  else
    Result := 'неизвестная ошибка';
  end;
  Result := Format('%d, %s', [Code, Result]);
end;

function MTSDateToStr(const Date: TDateTime): AnsiString;
begin
  Result := FormatDateTime('yyyy-mm-dd', Date);
end;

function MTSTimeToStr(const Date: TDateTime): AnsiString;
begin
  Result := FormatDateTime('hh:nn:ss', Date);
end;

// ДД.ММ.ГГГГ
function DateToFDStr(const Date: TDateTime): AnsiString;
begin
  Result := FormatDateTime('dd.mm.yyyy', Date);
end;

{ TMitsuDrv }

constructor TMitsuDrv.Create;
begin
  inherited Create;
  FLogger := TLogFile.Create;
  FLogger.MaxCount := 10;
  FLogger.Enabled := True;
  FLogger.FilePath := 'Logs';
  FLogger.DeviceName := 'DeviceName';
  FParams.ConnectionType := ConnectionTypeSerial;
  FParams.PortName := 'COM8';
  FParams.BaudRate := 115200;
  FParams.ByteTimeout := 100;
  // FPort := CreatePort;
end;

destructor TMitsuDrv.Destroy;
begin
  FPort := nil;
  FLogger := nil;
  inherited Destroy;
end;

function TMitsuDrv.Connect: Integer;
begin
  Result := 0;
end;

function TMitsuDrv.Disconnect: Integer;
begin
  Result := 0;
end;

function TMitsuDrv.WaitForPrinting: Integer;
begin
  Result := 0;
end;

function TMitsuDrv.Reset: Integer;
var
  Doc: TDocStatus;
begin
  Result := ReadLastDocStatus(Doc);
  if Failed(Result) then
    Exit;
  if Doc.Status <> MTS_DOC_STATUS_OPENED then
    Exit;

  case Doc.DocType of
    MTS_DOC_TYPE_RECEIPT, MTS_DOC_TYPE_BLANK, MTS_DOC_TYPE_RECEIPT_CORRECTION,
      MTS_DOC_TYPE_BLANK_CORRECTION:
      begin
        Result := CancelReceipt;
      end;
    MTS_DOC_TYPE_NONFISCAL:
      begin
        Result := CloseNonfiscal(False);
      end;
  end;
end;

class function TMitsuDrv.ValidBaudRates: TBaudRates;
begin
  Result := BaudRates;
end;

class function TMitsuDrv.ValidConnectionTypes: TConnectionTypes;
begin
  Result := ConnectionTypes;
end;

procedure TMitsuDrv.LockPort;
begin
  Port.Lock;
end;

procedure TMitsuDrv.UnlockPort;
begin
  Port.Unlock;
end;

(*
  Команды запроса данных: GET
  Формат: <GET ATTR='X'/>
  <GET ATTR1='X' ATTR2='Y'… />
  или
  или
  <GET ATTR=X />
  <GET ATTR1=X ATTR2=Y… />
  Ответ: <OK ATTR='данные'… />
  или
  <OK ATTR='данные'…>
  <TAG> данные </TAG>
  …
  </ANS>
  Примеры: <GET DATE= '?' /> или <GET DATE=? />
  <GET DATE= '?' TIME='?' /> или <GET DATE=? TIME=? />
  <GET SHIFT= '1' /> или <GET SHIFT=1 />
  • В запрос можно включать один атрибут ATTR или несколько, исходя из целесообразности и размера
  данных, получаемых (ожидаемых) в ответе.
  Например, дату и время можно запрашивать одной командой, содержащей обаатрибута DATE и TIME,
  а данные итогов (отчетов) – по одному.
  • Значения атрибутов X (Y…) в запросе задают вид (тип, состав) запрашиваемой информации.
  • Если получаемые данные не имеют вариантов, то в запросе в качестве значений атрибутов можно задать любой символ, например, знак '?'.
  3.2. Перечень атрибутов в запросах GET
  № Имя атрибута Значение Возвращаемые данные
  3.3 DEV ‘?’ Наименование модели
  3.4 VER ‘?’ Сведения о версии модели
  3.5 DATE ‘?’ Текущая дата
  3.5 TIME ‘?’ Текущее время
  3.6 CASHIER ‘?’ Кассир
  3.7 PRINTER ‘?’ Принтер
  3.8 CD ‘?’ Денежный ящик
  3.9 COM ‘?’ Скорость COM порта
  3.10 HEADER ‘1’, ‘2’, ‘3’, ‘4’ Клише и подвал (текст в заголовке и внизу чека)
  3.11 LAN ‘?’ Сетевые параметры кассы
  3.12 OFD ‘?’ Сетевые параметры ОФД
  3.13 OISM ‘?’ Сетевые параметры ОИСМ
  3.14 OKP ‘?’ Сетевые параметры ОКП
  3.15 TAX ‘?’ Налоговые ставки
  3.16 REG ‘?’
  ‘номер’
  Текущие регистрационные данные
  Регистрационные данные по номеру перерегистр.
  3.17
  INFO
  ‘0’ Состояние смены
  3.18 ‘1’ Итоги смены по кассовым чекам (БСО)
  3.19 ‘2’ Итоги смены по чекам (БСО) коррекции
  3.20 ‘3’ Итоги ФН по кассовым чекам (БСО)
  3.21 ‘4’ Итоги ФН по чекам (БСО) коррекции
  3.22 ‘F' или ‘FN’ Состояние ФН
  3.23 ‘O’ или ‘OFD’ Статус по передаче документов в ОФД
  3.24 ‘M’ или ‘MRK’ Статус по работе с кодами маркировки
  3.25 ‘N’ или ‘NOT’ Статус по передаче уведомлений
  3.26 ‘K’ или ‘KEY’ Статус по обновлению ключей проверки
  3.27
  DOC
  ‘?’ Статус текущего ФД (номер, тип, размер…)
  3.28 ‘номер’ Печать документа из ФН по номеру (ФД, ФП…)
  3.29 ‘A:номер’ Печать документа из архива ФН
  3.30 ‘X:номер’ Состав реквизитов документа в XML формате
  3.32 POWER ‘?’ Состояние флага сбоя питания
*)

function TMitsuDrv.GetPort: IPrinterPort;
begin
  if FPort = nil then
    FPort := CreatePort;
  Result := FPort;
end;

function TMitsuDrv.CreatePort: IPrinterPort;
var
  SerialParams: TSerialParams;
  SocketParams: TSocketParams;
begin
  case Params.ConnectionType of
    ConnectionTypeSerial:
      begin
        SerialParams.PortName := Params.PortName;
        SerialParams.BaudRate := Params.BaudRate;
        SerialParams.DataBits := DATABITS_8;
        SerialParams.StopBits := ONESTOPBIT;
        SerialParams.Parity := NOPARITY;
        SerialParams.FlowControl := FLOW_CONTROL_NONE;
        SerialParams.ReconnectPort := True;
        SerialParams.ByteTimeout := 10000; // !!!
        Result := TSerialPort.Create(SerialParams, Logger);
      end;
    ConnectionTypeSocket:
      begin
        SocketParams.RemoteHost := '192.168.1.100';
        SocketParams.RemotePort := 8200;
        SocketParams.ByteTimeout := 100;
        SocketParams.MaxRetryCount := 1;
        Result := TSocketPort.Create(SocketParams, Logger);
      end;
  else
    raise Exception.Create('Invalid ConnectionType value');
  end;
end;

(*
  byte 1 02h (STX)
  short 2 длина команды (количест
  char[] до 2040 команда и данные (XML-ст
  byte 1 03h (ETX)
  byte 1 контрольный байт (LRC)
*)

function TMitsuDrv.GetCRC(const Data: AnsiString): Byte;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(Data) do
    Result := Result xor Ord(Data[i]);
end;

function TMitsuDrv.EncodeCommand(const Data: AnsiString): AnsiString;
var
  L: Word;
begin
  L := Length(Data);
  Result := STX + Chr(Lo(L)) + Chr(Hi(L)) + Data + ETX;
  Result := Result + Chr(GetCRC(Result));
end;

function TMitsuDrv.GetRequest(const Request: AnsiString): Integer;
begin
  FCommand := '<GET ' + Request + ' />';
  Result := Send(FCommand, FAnswer);
end;

function TMitsuDrv.Send(const Command: AnsiString): Integer;
var
  Answer: AnsiString;
begin
  Result := Send(Command, Answer);
end;

function TMitsuDrv.Send(const Command: AnsiString;
  var Answer: AnsiString): Integer;
var
  B: AnsiChar;
  CRC: AnsiChar;
  S: AnsiString;
begin
  Logger.Debug(Logger.Separator);
  Logger.Debug('-> ' + Command);

  Port.Open;
  Port.Write(EncodeCommand(Command));

  Answer := '';
  repeat
    B := Port.Read(1)[1];
    Answer := Answer + B;
    if B = ETX then
      Break;
  until False;
  CRC := Port.Read(1)[1];
  if Ord(CRC) <> Ord(GetCRC(Answer)) then
    raise Exception.Create('Invalid CRC');
  Answer := Copy(Answer, 1, Length(Answer) - 1);
  Logger.Debug('<- ' + Answer);

  FAnswerDoc := LoadXMLData(AnsiStringToWideString(1251, Answer));

  // <ERROR No='40' FSE='0x02' PAR='INFO'/>
  if FAnswerDoc.DocumentElement.NodeName = 'ERROR' then
  begin
    FLastError.Code := GetIntAttribute('No');
    FLastError.FSError := GetAttribute('FSE');
    FLastError.Tag := GetAttribute('TAG');
    FLastError.Par := GetAttribute('PAR');
    Result := FLastError.Code;
  end;
end;

procedure TMitsuDrv.Check(Code: Integer);
begin
  if Code <> 0 then
  begin
    RaiseError(Code, getErrorMessage(Code));
  end;
end;

function TMitsuDrv.Succeeded(rc: Integer): Boolean;
begin
  Result := rc = 0;
end;

function TMitsuDrv.GetAttribute(const Attribute: AnsiString): AnsiString;
var
  Node: IXmlNode;
begin
  Result := '';
  Node := FAnswerDoc.DocumentElement.AttributeNodes.FindNode(Attribute);
  if Node <> nil then
  begin
    if not VarIsNull(Node.NodeValue) then
      Result := Node.NodeValue;
  end;
end;

function TMitsuDrv.HasAttribute(const Attribute: AnsiString): Boolean;
begin
  Result := FAnswerDoc.DocumentElement.AttributeNodes.FindNode
    (Attribute) <> nil;
end;

function TMitsuDrv.GetChildAttribute(const Child, Attribute: AnsiString)
  : AnsiString;
var
  Node: IXmlNode;
begin
  Result := '';
  Node := FAnswerDoc.DocumentElement.ChildNodes[Child];
  if Node <> nil then
  begin
    if Node.HasAttribute(Attribute) then
      Result := Node.Attributes[Attribute];
  end;
end;

function TMitsuDrv.GetChildText(const Child: AnsiString): AnsiString;
var
  Node: IXmlNode;
begin
  Result := '';
  Node := FAnswerDoc.DocumentElement.ChildNodes[Child];
  if Node <> nil then
  begin
    Result := Node.Text;
  end;
end;

function TMitsuDrv.GetIntAttribute(const Attribute: AnsiString): Integer;
begin
  Result := StrToIntDef(GetAttribute(Attribute), 0);
end;

function TMitsuDrv.GetIntAttribute3(const Attribute: AnsiString;
  N: Integer): Integer;
var
  S: AnsiString;
begin
  S := GetAttribute(Attribute);
  S := GetString(S, N, ['|']);
  Result := StrToInt(S);
end;

function TMitsuDrv.GetHexAttribute(const Attribute: AnsiString): Integer;
var
  S: AnsiString;
begin
  S := GetAttribute(Attribute);
  S := StringReplace(S, '0x', '$', []);
  Result := StrToInt(S);
end;

// DATE='2000-00-00'
function TMitsuDrv.GetDateAttribute(const Attribute: AnsiString): TDateTime;
var
  S: AnsiString;
  Year, Month, Day: Word;
begin
  S := GetAttribute(Attribute);
  Year := StrToInt(Copy(S, 1, 4));
  Month := StrToInt(Copy(S, 6, 2));
  Day := StrToInt(Copy(S, 9, 2));
  Result := EncodeDate(Year, Month, Day);
end;

// TIME='00:00'
function TMitsuDrv.GetTimeAttribute(const Attribute: AnsiString): TDateTime;
var
  S: AnsiString;
  Hour, Min: Word;
begin
  S := GetAttribute(Attribute);
  Hour := StrToInt(Copy(S, 1, 2));
  Min := StrToInt(Copy(S, 4, 2));
  Result := EncodeTime(Hour, Min, 0, 0);
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.3. Наименование модели
// Формат: <GET DEV='?' /> или <GET/>
// Ответ: <OK DEV='MITSU-1-F' />
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadDeviceName(var DeviceName: WideString): Integer;
begin
  Result := GetRequest('DEV="?"');
  if Succeeded(Result) then
  begin
    DeviceName := GetAttribute('DEV');
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.4. Сведения о модели
// Формат: <GET VER='?' />
// Ответ: <OK VER='версия' SIZE='размер' CRC32='контрольное число' SERIAL='заводской номер'
// MAC='mac-адрес' STS='статус'/>
// Пример: <OK VER='1.1.06' SIZE='295771' CRC32='7E714C76' SERIAL='065001234567890'
// MAC='00-22-00-48-00-51' STS='00000000'/>
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadDeviceVersion(var R: TMTSVersion): Integer;
begin
  Result := GetRequest('VER=''?''');
  if Succeeded(Result) then
  begin
    R.Version := GetAttribute('VER');
    R.Size := GetAttribute('SIZE');
    R.CRC32 := GetAttribute('CRC32');
    R.Serial := GetAttribute('SERIAL');
    R.MAC := GetAttribute('MAC');
    R.STS := GetAttribute('STS');
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.5. Дата и время
// Формат:
// или
// или
// <GET DATE='?' TIME='?' />
// <GET DATE='?' />
// <GET TIME='?' />
// Ответ: <OK DATE='гггг-мм-дд' TIME='чч:мм:сс' />
// <OK DATE='гггг-мм-дд' />
// <OK TIME='чч:мм:сс' />
// Пример: <OK DATE='2023-02-06' TIME='08:32:18' />
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadDateTime(var R: TDateTime): Integer;
begin
  Result := GetRequest('DATE=''?'' TIME=''?''');
  if Succeeded(Result) then
  begin
    R := GetDateAttribute('DATE') + GetTimeAttribute('TIME');
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.6. Кассир
// Формат: <GET CASHIER='?' />
// Ответ: <OK CASHIER='идентификатор' INN='инн' />
// Пример: <OK CASHIER=’Апполинарий Полуэктович' INN='771901532574' />
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadCashier(var R: TMTSCashier): Integer;
begin
  Result := GetRequest('CASHIER=''?''');
  if Succeeded(Result) then
  begin
    R.Name := GetAttribute('CASHIER');
    R.INN := GetAttribute('INN');
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.7. Настройки принтера
// Формат: <GET PRINTER='?'/>
// Ответ: <OK PRINTER='модель печатающего устройства'
// BAUDRATE='скорость COM порта принтера'
// PAPER='ширина ленты'
// FONT='тип шрифта'
// WIDTH='число пикселей по горизонтали'
// LENGTH='число символов в строке' />
// Пример: <OKPRINTER='2' BAUDRATE='115200' PAPER='80' FONT='0' WIDTH='576' LENGTH='48' />
// • PRINTER – модель печатающего устройства:
// 2 – Mitsu TP80,символов в строке 48 (шрифт А) или 64 (шрифт В);
// • BAUDRATE – скорость COM порта принтера от 4800 до 115200 бит/сек;
// • PAPER – ширина ленты в мм (57 или 80);
// • FONT – тип шрифта: 0 – шрифт A (стандартный), 1 – шрифт B (мелкий).
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadPrinterParams(var R: TMTSPrinterParams): Integer;
begin
  Result := GetRequest('PRINTER=''?''');
  if Succeeded(Result) then
  begin
    R.Printer := GetAttribute('PRINTER');
    R.BaudRate := GetIntAttribute('BAUDRATE');
    R.PaperWidth := GetIntAttribute('PAPER');
    R.FontType := GetIntAttribute('FONT');
    R.PrintWidth := GetIntAttribute('WIDTH');
    R.CharWidth := GetIntAttribute('LENGTH');
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.8. Денежный ящик
// Формат: <GET CD='?' />
// Ответ: <OK CD='контакт' RISE='фронт' FALL='спад' />
// Пример: <OK CD:PIN='5' RISE='110' FALL='110' />
// • PIN – номер контакта в разъеме подключения соленоида денежного ящика.
// • RISE – время нарастания импульса открывания в миллисекундах.
// • FALL – время спада импульса в миллисекундах.
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadDrawerParams(var R: TMTSDrawerParams): Integer;
begin
  Result := GetRequest('CD=''?''');
  if Succeeded(Result) then
  begin
    R.Pin := GetIntAttribute('CD');
    R.Rise := GetIntAttribute('RISE');
    R.Fall := GetIntAttribute('FALL');
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.9. Скорость СОМ порта
// Формат: <GET COM='?' />
// Ответ: <OK COM='скорость' />
// Пример: <OK COM='115200' />
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadBaudRate(var BaudRate: Integer): Integer;
begin
  Result := GetRequest('COM=''?''');
  if Succeeded(Result) then
  begin
    BaudRate := GetIntAttribute('COM');
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.10. Клише и подвал
// Формат: <GET HEADER='n' />
// Ответ: <OK HEADER='n'>
// <L0 F='xxxxxx'> Текст </L0>
// . . . . . . . . . . . . . . . . . . . . . . . . . .
// </OK>
// Пример: <OK HEADER='1'><L0 F='000011'> Добро пожаловать!!!</L0>
// <L1 F='000000'>Звони 111-11-11 с 9 до 20</L1></OK>
// 9
// • n = 1, 2, 3, 4 – номер клише (подвала), в каждом – до 10 строк.
// • L0 – L9 – номера строк.
// • В ответе содержатся только установленные (непустые) строки клише.
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadText(var Text: TMTSText): Integer;
var
  i: Integer;
begin
  Result := GetRequest(Format('HEADER=''%d''', [Text.Number]));
  if Succeeded(Result) then
  begin
    for i := Low(Text.Lines) to High(Text.Lines) do
    begin
      Text.Lines[i] := GetChildAttribute('L' + IntToStr(i), 'F');
    end;
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.11. Сетевые параметры
// Формат: <GET LAN='?'/>
// Ответ: <OK ADDR='IP-адрес кассы'
// PORT='порт'
// MASK='маска подсети'
// DNS='адрес сервера доменных имен'
// GW='IP-адрес шлюза' />
// Пример: <OKADDR='192.168.1.101' PORT='8200' MASK='255.255.255.0' DNS='8.8.8.8'GW='192.168.1.1'/>
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadLANParams(var R: TMTSLANParams): Integer;
begin
  Result := GetRequest('LAN=''?''');
  if Succeeded(Result) then
  begin
    R.Address := GetAttribute('LAN');
    R.Port := GetIntAttribute('PORT');
    R.Mask := GetAttribute('MASK');
    R.DNS := GetAttribute('DNS');
    R.Gateway := GetAttribute('GW');
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.12. Сетевые параметры ОФД
// Формат: <GET OFD='?'/>
// Ответ: <OK OFD='IP/URL сервера ОФД'
// PORT='порт'
// CLIENT='способ обмена с ОФД'
// TimerFN='период опроса ФН'
// TimerOFD='период опроса ОФД' />
// Пример: <OK ADDR='109.73.43.4' PORT='19086' CLIENT='1' TimerFN='60' TimerOFD='10' />
// • CLIENT: определяет способ обмена с ОФД:
// ‘1' – через внешний клиент (кассовое ПО или служба на POS компьютере),
// ‘0' – работает внутренний клиент KKT (требуется доступ в Интернет через LAN).
// • TimerFN: интервал опросов ФН на наличие неотправленных документов.
// • TimerOFD: интервал (таймаут) между попытками отправить документ в ОФД
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadFDOParams(var R: TMTSFDOParams): Integer;
begin
  Result := GetRequest('OFD=''?''');
  if Succeeded(Result) then
  begin
    R.Address := GetAttribute('OFD');
    R.Port := GetIntAttribute('PORT');
    R.Client := GetIntAttribute('CLIENT');
    R.FNPollPeriod := GetIntAttribute('TimerFN');
    R.FDOPollPeriod := GetIntAttribute('TimerOFD');
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.13. Сетевые параметры ОИСМ
// Формат: <GET OISM='?' />
// Ответ: <OK ADDR='IP/URL сервера ОИСМ' PORT='порт' />
// Пример: <OK ADDR='f1test.taxcom.ru' PORT='7903' />
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadOISMParams(var R: TMTSOISMParams): Integer;
begin
  Result := GetRequest('OISM=''?''');
  if Succeeded(Result) then
  begin
    R.Address := GetAttribute('OISM');
    R.Port := GetIntAttribute('PORT');
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.14. Сетевые параметры ОКП
// Формат: <GET OKP='?' />
// Ответ: <OK OKP='IP/URL сервера ОКП' PORT='порт' />
// Пример: <OK OKP='prod01.okp-fn.ru' PORT='26101' />
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadOKPParams(var R: TMTSOKPParams): Integer;
begin
  Result := GetRequest('OKP=''?''');
  if Succeeded(Result) then
  begin
    R.Address := GetAttribute('OKP');
    R.Port := GetIntAttribute('PORT');
  end;
end;

/// ////////////////////////////////////////////////////////////////////////////
// 3.15. Налоговые ставки
// Формат: <GET TAX='?' />
// Ответ: <OK TAX='T1:20%, T2:10%, T3:20/120, T4:10/110, T5:0%, T6:БЕЗ НДС' />
/// ////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadVATNames(var R: TMTSVATNames): Integer;
var
  i: Integer;
  VATNames: WideString;
begin
  Result := GetRequest('TAX=''?''');
  if Succeeded(Result) then
  begin
    VATNames := GetAttribute('TAX');
    for i := 1 to 6 do
    begin
      R[i] := Copy(GetString(VATNames, i, [',']), 4, 100);
    end;
  end;
end;

(* *****************************************************************************
  3.16. Регистрационные данные
  Формат: <GET REG='?'/>
  <GET REG='номер'/>
  Ответ: <OK REG='порядковый номер регистрации (пере-регистрации)'
  FD='номер фискального документа'
  DATE='гггг-мм-дд' TIME='hh:mm'
  BASE='коды причин изменения сведений о регистрации'
  T1013='заводской номер кассы'
  T1188='версия модели' T1189='версия ФФД кассы' T1190='версия ФФД ФН'
  T1209='номер версии ФФД'
  T1037='регистрационный номер'
  T1018='ИНН пользователя'
  T1017='ИНН ОФД'
  T1036='номер автомата'
  T1062='системы налогообложения'
  MODE=‘маска режимов работы'
  ExtMODE='маска расширенных режимов работы'10
  T1041='заводской номер ФН' >
  <T1048> наименование пользователя </T1048>
  <T1009> адрес расчетов </T1009>
  <T1187> место расчетов </T1187>
  <T1046> наименование ОФД </T1046>
  <T1117> адрес электронной почты отправителя чеков </T1117>
  <T1060> адрес сайта ФНС </T1060>
  </OK>
  ***************************************************************************** *)

// <OK REG='0' FD='0' DATE='2000-00-00' TIME='00:00' BASE='' T1013='065001000000008' T1188='001' T1189='4' T1190='0' T1209='0' T1037='' T1018='' T1017='' T1036='' T1062='' MODE='0' ExtMODE='0' T1041='9999078902007739'><T1048></T1048><T1009></T1009><T1187></T1187><T1046></T1046><T1117></T1117><T1060></T1060></OK>
function TMitsuDrv.ReadRegParams(var R: TMTSRegParams): Integer;
var
  i: Integer;
  Mode: Integer;
  ExtMode: Integer;
  Tag: TTagValue;
begin
  Result := GetRequest('REG=''?''');
  if Succeeded(Result) then
  begin
    R.RegNumber := GetIntAttribute('REG');
    R.FDocNumber := GetIntAttribute('FD');
    R.DateTime := GetDateAttribute('DATE') + GetTimeAttribute('TIME');
    R.Base := GetAttribute('BASE');
    R.SerialNumber := GetAttribute('T1013');
    R.ModelVersion := GetAttribute('T1188');
    R.FFDVersionFP := GetAttribute('T1189');
    R.FFDVersionFD := GetAttribute('T1190');
    R.FFDVersion := GetAttribute('T1209');
    R.FDSerial := GetAttribute('T1041');

    Mode := GetIntAttribute('MODE');
    R.FNParams.IsEncrypted := TestBit(Mode, 0);
    R.FNParams.IsOffline := TestBit(Mode, 1);
    R.FNParams.IsAutomatic := TestBit(Mode, 2);
    R.FNParams.IsService := TestBit(Mode, 3);
    R.FNParams.IsBlank := TestBit(Mode, 4);
    R.FNParams.IsOnline := TestBit(Mode, 5);
    R.FNParams.IsCatering := TestBit(Mode, 6);
    R.FNParams.IsWholesale := TestBit(Mode, 7);

    ExtMode := GetIntAttribute('ExtMODE');
    R.FNParams.IsExcisable := TestBit(ExtMode, 0);
    R.FNParams.IsGambling := TestBit(ExtMode, 1);
    R.FNParams.IsLottery := TestBit(ExtMode, 2);
    R.FNParams.IsAutomaticPrinter := TestBit(ExtMode, 3);
    R.FNParams.IsMarking := TestBit(ExtMode, 4);
    R.FNParams.IsPawnshop := TestBit(ExtMode, 5);
    R.FNParams.IsInsurance := TestBit(ExtMode, 6);
    R.FNParams.IsVendingMachine := TestBit(ExtMode, 7);

    R.FNParams.RegNumber := GetAttribute('T1037');
    R.FNParams.CompanyINN := GetAttribute('T1018');
    R.FNParams.CompanyName := GetChildText('T1048');
    R.FNParams.OFDCompanyINN := GetAttribute('T1017');
    R.FNParams.AutomaticNumber := GetAttribute('T1036');
    R.FNParams.TaxSystems := GetAttribute('T1062');

    R.FNParams.SaleAddress := GetChildText('T1009');
    R.FNParams.SaleLocation := GetChildText('T1187');
    R.FNParams.OFDCompany := GetChildText('T1046');
    R.FNParams.SenderEmail := GetChildText('T1117');
    R.FNParams.FNSURL := GetChildText('T1060');
  end;
end;

(*
  3.17. Состояние смены
  Формат: <GET INFO='0' />, где ‘0’ – цифра "ноль".
  Ответ: <OK SHIFT=' номер смены '
  STATE='состояние смены'
  COUNT='количество чеков за смену'
  KeyValid=’срок действия ключей’>
  </OK>
  Пример <OK SHIFT='16' STATE='1' COUNT='7' KeyValid='445'></OK>
  • SHIFT – номер текущей открытой, либо последней закрытой смены.
  • STATE – состояние смены:
  0 – смена закрыта,
  1 – смена открыта,
  9 – смена истекла (превышение 24 часов).
  • KeyValid: количество дней, оставшихся до истечения срока действия ключей проверки кодов маркировки.
*)

// <ERROR No='40' FSE='0x02' PAR='INFO'/>
function TMitsuDrv.ReadDayStatus(var R: TMTSDayStatus): Integer;
begin
  Result := GetRequest('INFO=''0''');
  if Succeeded(Result) then
  begin
    R.DayNumber := GetIntAttribute('SHIFT');
    R.DayStatus := GetIntAttribute('STATE');
    R.RecNumber := GetIntAttribute('COUNT');
    R.KeyExpDays := GetIntAttribute('KeyValid');
  end;
end;

(*
  3.18. Итоги смены по кассовым чекам (БСО)
  Формат: <GET INFO='1'/>
  Ответ: <OK SHIFT='номер смены'>
  <INCOME COUNT='приход | возврат прихода'
  TOTAL ='приход | возврат прихода '
  T1136='приход | возврат прихода '
  T1138='приход | возврат прихода '
  T1218='приход | возврат прихода '
  T1219='приход | возврат прихода '
  T1220='приход | возврат прихода '
  T1139='приход | возврат прихода '
  T1140='приход | возврат прихода '
  T1141='приход | возврат прихода '
  T1142='приход | возврат прихода '
  T1143='приход | возврат прихода '
  T1183='приход | возврат прихода '/>
  <PAYOUT COUNT='расход | возврат расхода'
  TOTAL ='расход | возврат расхода '
  T1136='расход | возврат расхода '
  T1138='расход | возврат расхода '
  T1218='расход | возврат расхода '
  T1219='расход | возврат расхода '
  T1220='расход | возврат расхода '
  T1139='расход | возврат расхода '
  T1140='расход | возврат расхода '
  T1141='расход | возврат расхода '
  T1142='расход | возврат расхода '
  T1143='расход | возврат расхода '
  T1183='расход | возврат расхода '/>
  </OK>
  Пример <OK SHIFT='16'><INCOME COUNT='7|0' TOTAL='59000|0' T1136='59000|0' T1138='0|0'
  T1218='0|0' T1219='0|0' T1220='0|0' T1139='9838|0' T1140='0|0' T1141='0|0' T1142='0|0'
  T1143='0|0' T1183='0|0'/><PAYOUT COUNT='0|0'/></OK>
  • Возвращает итоги текущей (если открыта), либо последней закрытой смены.
  • INCOME – итоги операций прихода и возврата прихода.
  • PAYOUT – итоги операций расхода и возврата расхода.
  • Итоговые суммы (денежные средства) возвращаются в копейках;
  COUNT – количество чеков (БСО) по соответсвующему признаку расчета
  TOTAL - итоговые суммы чеков по соответсвующему признаку расчета
  T1136 - суммы наличными
  T1138 - суммы электронными
  T1218 - суммы авансами
  T1219 - суммы кредитами
  T1220 - суммы иными средствами оплаты12
  T1139 - суммы НДС по ставке 20%
  T1140 - суммы НДС по ставке 10%
  T1141 - суммы НДС по ставке 20/120
  T1142 - суммы НДС по ставке 10/110
  T1143 - суммы расчетов по ставке 0%
  T1183 - суммы расчетов без НДС'.
  • Структуры, содержащие счетчики итогов чеков по всем признакам расчета имеют одинаковый формат.
  Если чеков по какому-либо признаку расчета не было в смене, то соответствующий счетчик будет содержать только количество чеков, равное 0, без вложенных итогов и налогов, например:
  <PAYOUT COUNT='0 | 0'/>
*)

function TMitsuDrv.ReadDayTotals(RequestType: Integer;
  var R: TMTSDayTotals): Integer;

  function NodeToTotals(Node: IXmlNode; N: Integer): TMTSTotals;
  begin
    Result.Count := GetIntAttribute2(Node, 'COUNT', N);
    if Result.Count > 0 then
    begin
      Result.Total := GetIntAttribute2(Node, 'TOTAL', N);
      Result.T1136 := GetIntAttribute2(Node, 'T1136', N);
      Result.T1138 := GetIntAttribute2(Node, 'T1138', N);
      Result.T1218 := GetIntAttribute2(Node, 'T1218', N);
      Result.T1219 := GetIntAttribute2(Node, 'T1219', N);
      Result.T1220 := GetIntAttribute2(Node, 'T1220', N);
      Result.T1139 := GetIntAttribute2(Node, 'T1139', N);
      Result.T1140 := GetIntAttribute2(Node, 'T1140', N);
      Result.T1141 := GetIntAttribute2(Node, 'T1141', N);
      Result.T1142 := GetIntAttribute2(Node, 'T1142', N);
      Result.T1143 := GetIntAttribute2(Node, 'T1143', N);
      Result.T1183 := GetIntAttribute2(Node, 'T1183', N);
    end;
  end;

var
  Node: IXmlNode;
begin
  Result := GetRequest(Format('INFO=''%d''', [RequestType]));
  if Succeeded(Result) then
  begin
    R.DayNumber := GetIntAttribute('SHIFT');
    Node := FAnswerDoc.DocumentElement.ChildNodes['INCOME'];
    R.Sale := NodeToTotals(Node, 1);
    R.RetSale := NodeToTotals(Node, 2);

    Node := FAnswerDoc.DocumentElement.ChildNodes['PAYOUT'];
    R.Buy := NodeToTotals(Node, 1);
    R.RetBuy := NodeToTotals(Node, 2);
  end;
end;

function TMitsuDrv.ReadDayTotalsReceipts(var R: TMTSDayTotals): Integer;
begin
  Result := ReadDayTotals(1, R);
end;

function TMitsuDrv.ReadDayTotalsCorrection(var R: TMTSDayTotals): Integer;
begin
  Result := ReadDayTotals(2, R);
end;

(*
  3.20. Итоги ФН по кассовым чекам (БСО)
  Формат: <GET INFO='3'/>
  Ответ: См. п.3.20 (Итоги смены)
  Пример <OK SHIFT='16'><INCOME COUNT='41|0' TOTAL='99200|0' T1136='93100|0' T1138='6100|0'
  T1218='0|0' T1219='0|0' T1220='0|0' T1139='16558|0' T1140='0|0' T1141='0|0' T1142='0|0'
  T1143='0|0' T1183='0|0'/><PAYOUT COUNT='0|0'/><GT>99200</GT></OK>
  • Возвращает данные итогов кассовых чеков с момента установки данного экземпляра ФН.
  • Структура возвращаемых данных идентична итогам смены.
  • В состав итогов по кассовым чекам (БСО) добавляется тег с накопленным итогом чеков с момента
  установки первого ФН.
  <GT>Накопленный итог</GT>
*)

function TMitsuDrv.ReadFDTotalReceipts(var R: TMTSDayTotals): Integer;
begin
  Result := ReadDayTotals(3, R);
end;

function TMitsuDrv.ReadFDTotalCorrection(var R: TMTSDayTotals): Integer;
begin
  Result := ReadDayTotals(4, R);
end;

(*
  3.22. Состояние ФН
  Формат: <GET INFO='F'/> или <GET INFO='FN'/>
  Ответ: <OK FN=’заводской номер ФН’
  FFD='версия ФФД ФН’
  PHASE=’этап применения ФН’
  REG='номер последней (пере)регистрации | число оставшихся перерегистраций'
  VALID='срок действия ФН'
  LAST=’номер последнего фискального документа’
  DATE=’дата последнего фискального документа’
  TIME=’время последнего фискального документа’
  FLAG=’флаги предупреждения (маска)’ >
  </OK>
  Пример: <OK FN='9999078902014447' FFD='1.2' PHASE='0x03' REG='3|27' VALID='2024-07-17'
  LAST='80' DATE='2023-04-27' TIME='23:00' FLAG='0x08'> </OK>
  • Возвращает состояние фискального накопителя.
  • PHASE: маска, определяющая этап применения ФН:
  0x01 .... 1-й этап: готовность к регистрации ККТ, до активизации ФН;
  0x03 .... 2-й этап: эксплуатация ФН с формированием ФД, до закрытия ФН;
  0x07 .... 3-й этап: информационный обмен с ОФД, до подтверждения оператором закрытия ФН;
  0x0F .... 4-й этап: получение данных из архива ФН, до истечения 5 лет от перехода на 4-й этап.
  •  ФН в ККТ, применяемой в автономном режиме, переходит от 2-го этапа на 4-й, минуя 3-й этап
*)

function TMitsuDrv.ReadFDStatus(var R: TMTSFDStatus): Integer;
begin
  Result := GetRequest('INFO=''F''');
  if Succeeded(Result) then
  begin
    R.Serial := GetAttribute('FN');
    R.FFDVersion := GetAttribute('FFD');
    R.Phase := GetHexAttribute('PHASE');
    R.RegCount := GetIntAttribute3('REG', 1);
    R.RegLeft := GetIntAttribute3('REG', 2);
    R.ValidDate := GetDateAttribute('VALID');
    R.LastDoc := GetIntAttribute('LAST');
    R.DocDate := GetDateAttribute('DATE') + GetTimeAttribute('TIME');
    R.Flags := GetHexAttribute('FLAG');
  end;
end;

(*
  3.23. Статус по передаче документов в ОФД
  Формат: <GET INFO=’O’/> или <GET INFO=’OFD’/>
  Ответ: <OK FN=’заводской номер ФН’
  COUNT=’количество непереданных документов'
  FIRST=’номер первого непереданного документа’
  DATE=’дата первого непереданного документа’
  TIME=’время первого непереданного документа’ />
  Пример: <OK FN='9999078902014447' COUNT='63' FIRST='18' DATE='2023-01-11' TIME='18:15'></OK>
  • Возвращает количество непереданных документов, а также номер, дату и время документа, первого в
  очереди на передачу в ОФД.
*)

function TMitsuDrv.ReadFDOStatus(var R: TMTSFDOStatus): Integer;
begin
  Result := GetRequest('INFO=''OFD''');
  if Succeeded(Result) then
  begin
    R.Serial := GetAttribute('FN');
    R.DocCount := GetIntAttribute('COUNT');
    R.FirstDoc := GetIntAttribute('FIRST');
    R.FirstDate := GetDateAttribute('DATE') + GetTimeAttribute('TIME');
  end;
end;

(*
  3.24. Статус по работе с кодами маркировки
  Формат: <GET INFO=’M’/> или <GET INFO=’MRK’/>
  Ответ: <OK MARK= ‘состояние по проверке КМ’
  KEEP=’количество сохранённых результатов проверки КМ'
  FLAG=’флаг разрешения команд работы с КМ (маска)'
  NOTICE=’состояние уведомления о реализации маркированного товара‘
  HOLDS=’количество КМ, включенных в уведомление‘
  PENDING=’количество уведомлений в очереди’
  WARNING=’состояние заполнения области хранения уведомлений’ />
  Пример: <OK MARK='1' KEEP='0' FLAG='0x05' NOTICE='0' HOLDS='0'PENDING='1' WARNING='0'/>
*)

function TMitsuDrv.ReadMCStatus(var R: TMTSMCStatus): Integer;
begin
  Result := GetRequest('INFO=''MRK''');
  if Succeeded(Result) then
  begin
    R.MCStatus := GetIntAttribute('MARK');
    R.MCCount := GetIntAttribute('KEEP');
    R.MCFlags := GetIntAttribute('FLAG');
    R.MCNStatus := GetIntAttribute('NOTICE');
    R.MCNCount := GetIntAttribute('HOLDS');
    R.NCount := GetIntAttribute('PENDING');
    R.FillStatus := GetIntAttribute('WARNING');
  end;
end;

(*

  3.25. Статус по передаче уведомлений в ОИСМ
  Формат: <GET INFO=’N’/> или <GET INFO=’NOT’/>
  Ответ: Режим работы с передачей данных:
  <OK NOTICE= ’состояние по передаче уведомлений’
  PENDING='количество уведомлений в очереди’
  CURRENT= ’номер первого неподтвержденного уведомления’
  DATE='дата первого неподтвержденного уведомления’
  TIME='время первого неподтвержденного уведомления’
  STORAGE=’процент заполнения области хранения уведомлений’/>
  Автономный режим:
  <OK PENDING=’общее число уведомлений, выгрузка которых не подтверждена’
  FIRST='номер первого неподтвержденного уведомления'
  CURRENT=’количество уведомлений для выгрузки в этой сессии’
  No=’номер текущего уведомления’ />
  Пример: <OK NOTICE='0' PENDING='1' CURRENT='6' DATE='2023-01-11' TIME='13:41' STORAGE='1'/>
  • Возвращает состояние фискального накопителя по работе с уведомлениями.
  • NOTICE – состояние по передаче уведомлений(режим работы с передачей данных):
  0 – нет активного обмена;
  1 – начато чтение уведомления;
  2 – ожидание квитанции на уведомление.
*)

function TMitsuDrv.ReadOISMStatus(var R: TOISMStatus): Integer;
begin
  Result := GetRequest('INFO=''N''');
  if Succeeded(Result) then
  begin
    R.Status := GetIntAttribute('NOTICE');
    R.QueueCount := GetIntAttribute('PENDING');
    R.FirstNumber := GetIntAttribute('CURRENT');
    R.FirstDate := GetDateAttribute('DATE') + GetTimeAttribute('TIME');
    R.FillPercent := GetIntAttribute('STORAGE');
  end;
end;

(*
  3.26. Статус по обновлению ключей в ОКП
  Формат: <GET INFO=’K’/> или <GET INFO=’KEY’/>
  Ответ (А): <OK Ext='признак работы через внешний клиент обмена'
  NeedUpdate= 'признак необходимости обновления ключей'
  D7='признак поддержки ФН выполнения команды D7'>
  <URL>адрес и порт ОКП</URL>
  </OK>
  Ответ (Б): <OK Ext='признак работы через внешний клиент обмена'
  DATE= 'дата последнего обновления ключей проверки КМ'
  TIME='время последнего обновления ключей проверки КМ'/>
  Пример: <OK Ext='1' NeedUpdate='0' D7='1'><URL>tcp://test.okp.atlas-kard.ru:31101</URL></OK>
*)

function TMitsuDrv.ReadKeysStatus(var R: TKeysStatus): Integer;
begin
  Result := GetRequest('INFO=''K''');
  if Succeeded(Result) then
  begin
    R.ExtClient := GetIntAttribute('Ext') = 1;
    R.UpdateNeeded := GetIntAttribute('NeedUpdate') = 1;
    R.CapD7Command := GetIntAttribute('D7') = 1;
    R.OkpURL := GetChildText('URL');
    R.DateTime := GetDateAttribute('DATE') + GetTimeAttribute('TIME');
  end;
end;

(*
  3.27. Статус текущего документа
  Формат: <GET DOC=’0’/>
  Ответ: <OK FD='порядковый номер фискального документа'
  TYPE=’тип документа’
  STATE=’состояние документа’
  SIZE=’размер открытого документа’/>
  или: <OK TXT='порядковый номер нефискального (текстового) документа'
  TYPE=’тип документа’
  STATE=’состояние документа’/>
  Пример: <OK FD='82' TYPE='3' STATE='1' SIZE='101'/>
*)

function TMitsuDrv.ReadLastDocStatus(var R: TDocStatus): Integer;
begin
  Result := ReadDocStatus(0, R);
end;

(*
  3.28. Статус и печать документа из ФН
  Формат: <GET DOC='номер'/>
  Ответ: <OK DOC='номер' TYPE='тип' STATE=’0’/>
  Пример: <OK FD='81' TYPE='2' STATE='0'/>
*)

function TMitsuDrv.ReadDocStatus(N: Integer; var R: TDocStatus): Integer;
begin
  Result := GetRequest(Format('DOC=''%d''', [N]));
  if Succeeded(Result) then
  begin
    if HasAttribute('FD') then
      R.Number := GetIntAttribute('FD')
    else
      R.Number := GetIntAttribute('TXT');
    R.DocType := GetIntAttribute('TYPE');
    R.Status := GetIntAttribute('STATE');
    R.Size := GetIntAttribute('SIZE');
  end;
end;

(*
  3.30. XML форма документа из ФН
  Формат: <GET DOC='X:номер' />
  Ответ: <OK OFFSET='60010000' LENGTH='размер'/>
*)

function TMitsuDrv.ReadFDDoc(N: Integer; var R: TFDParams): Integer;
begin
  Result := GetRequest(Format('DOC=''X:%d''', [N]));
  if Succeeded(Result) then
  begin
    R.Offset := StrToInt('$' + GetAttribute('OFFSET'));
    R.Size := GetIntAttribute('LENGTH');
  end;
end;

(*
  3.31. XML форма и печать подтверждения оператора
  Формат: <GET DOC='C:номер' />
  Ответ: <OK OFFSET='60010000' LENGTH='размер'/>
*)

function TMitsuDrv.ReadFDDocPrint(N: Integer; var R: TFDParams): Integer;
begin
  Result := GetRequest(Format('DOC=''С:%d''', [N]));
  if Succeeded(Result) then
  begin
    R.Offset := StrToInt('$' + GetAttribute('OFFSET'));
    R.Size := GetIntAttribute('LENGTH');
  end;
end;

(*
  3.32. Считывание блока XML формы
  Формат: <READ OFFSET='адрес' LENGTH='размер'/>
  Ответ: <OK LENGTH='размер'> данные </OK>
*)

function TMitsuDrv.ReadFDData(Offset, Length: Integer;
  var Data: AnsiString): Integer;
var
  Answer: AnsiString;
  Command: AnsiString;
begin
  Command := Format('<READ OFFSET=''%.8x'' LENGTH=''%d''/>', [Offset, Length]);
  Result := Send(Command, Answer);
  if Succeeded(Result) then
  begin
    Data := HexToStr(FAnswerDoc.DocumentElement.Text);
  end;
end;

function TMitsuDrv.ReadFD(N: Integer; var Data: AnsiString): Integer;
var
  i: Integer;
  R: TFDParams;
  Count: Integer;
  BlockData: AnsiString;
const
  BlockSize = 512;
begin
  Data := '';
  Result := ReadFDDoc(N, R);
  if Failed(Result) then
    Exit;

  if R.Size > 0 then
  begin
    Count := (R.Size + BlockSize - 1) div BlockSize;
    for i := 0 to Count - 1 do
    begin
      Result := ReadFDData(R.Offset, Min(R.Size, BlockSize), BlockData);
      if Failed(Result) then
        Exit;

      Data := Data + BlockData;
      Inc(R.Offset, BlockSize);
      Dec(R.Size, BlockSize);
    end;
  end;
end;

(*
  3.33. Флаг сбоя питания
  Формат: <GET POWER='?'/>
  Ответ: <OK POWER='состояние флага'/>
  Пример: <OK POWER='0'/>
  • POWER='1', если был установлен и не сбросился из-за выключения питания.
  • POWER='0', если не был установлен или сбросился из-за выключения питания
*)

function TMitsuDrv.ReadPowerLost(var Flag: Boolean): Integer;
begin
  Result := GetRequest('POWER=''?''');
  if Succeeded(Result) then
  begin
    Flag := GetIntAttribute('POWER') = 1;
  end;
end;

(*
  3.34. Другие настройки (опции)
  Формат: <OPTION/> - получить значения всех оций
  <OPTION b0=’?’/> выборочно получить значение одной или нескольких опций
  Ответ: <OK b0='опция' b1='опция'. . . b8='опция'/>
  Пример: <OK b0='0' b1='0' b2='3' b3='1' b4='0' b5='0' b6='0' b7='0' b8='0'/>
  См. описание параметров в разделе УСТАНОВКА НАСТРОЕК, п.4.13.
*)

function TMitsuDrv.ReadOptions(var Options: Integer): Integer;
var
  i: Integer;
  Answer: AnsiString;
begin
  Result := Send('<OPTION/>', Answer);
  if Succeeded(Result) then
  begin
    Options := 0;
    for i := 0 to 8 do
    begin
      if GetIntAttribute('b' + IntToStr(i)) = 1 then
        Options := Options or (1 shl i);
    end;
  end;
end;

(*
  4.3. Дата и время
  Формат: <SET DATE = 'гггг-мм-дд' TIME='чч:мм:сс' />
  Пример: <SET DATE='2023-02-07' TIME='09:00:00' />
  Ответ: <OK DATE='2023-02-07' TIME='09:00:00'/>
  • Оба атрибута DATE и TIME – обязательные.
  • Задаваемые дата и время не должны быть ранее даты и времени последнего фискального документа.
  • АтрибутыDATE иTIME в ответе возвращают новые дату и время внутренних часов кассы,
  установленные по выполнении этой команды, в том же формате.
*)

function TMitsuDrv.WriteDate(const Date: TDateTime): Integer;
var
  Command: AnsiString;
begin
  Command := Format('<SET DATE=''%s'' TIME=''%s''/>',
    [MTSDateToStr(Date), MTSTimeToStr(Date)]);
  Result := Send(Command);
end;

(*
  4.4. Кассир
  Формат: <SET CASHIER= 'идентификатор' INN='инн'/>
  Пример: <SET CASHIER= 'Петр Иванов' INN='9876543210'/>
*)

function TMitsuDrv.WriteCashier(const Cashier: TMTSCashier): Integer;
var
  Command: AnsiString;
begin
  Command := Format('<SET CASHIER=''%s'' INN=''%s''/>',
    [Cashier.Name, Cashier.INN]);
  Result := Send(Command);
end;

(*
  4.5. Скорость COM порта
  Формат: <SET COM='скорость' />
  Пример: <SET COM='115200'/>
  COM – скорость порта RS232: от 2400 до 115200 бит/сек
*)

function TMitsuDrv.WriteBaudRate(const BaudRate: Integer): Integer;
begin
  Result := Send(Format('<SET COM=''%d''/>', [BaudRate]));
end;

(*
  5.1. Регистрация
  Формат: <REG BASE=’0’ ATTR='данные'… ><TAG>данные</TAG>…</REG>
  Ответ: <OK FD='номер фискального документа' FP='фискальный признак'/>
  Атрибуты: * BASE=’0’ (цифра ноль)
  MARK='признак работы с маркированными товарами'
  PAWN='признак осуществления ломбардной деятельности'
  INS='признак осуществления страховой деятельности'
  DINE='признак примененияпри оказании услуг общественного питания'
  OPT='признак применения в оптовой торговле с организациями и ИП'
  VEND='признак применения с автоматическим устройством'
  T1001='признак автоматического режима'
  T1002=‘признак автономного режима'
  T1056='признак шифрования'
  * T1062='системы налогообложения'
  T1108='признак касса для расчетов только в Интернет'
  T1109='признак расчетов за услуги'
  T1110='признак режима БСО'
  T1126='признак проведения лотереи'
  T1193='признак проведения азартных игр'
  T1207='признак торговли подакцизными товарами'
  T1221='признак установки принтера в автомате'
  Теги: <T1009> адрес расчетов </T1009>
  * <T1017> ИНН ОФД </T1017>
  * <T1018> ИНН пользователя </T1018>
  <T1036> номер автомата </T1036>
  * <T1037> регистрационный номер</T1037>
  <T1046> наименование ОФД </T1046>
  * <T1048> наименование пользователя </T1048>
  * <T1060> адрес сайта ФНС </T1060>
  <T1117> адрес электронной почты отправителя чека </T1117>
  <T1187> место расчетов </T1187>
  <T1274> дополнительный реквизит ОР </T1274>
  <T1275> дополнительные данные ОР </T1275>
  Пример: <REG BASE='0' T1062='0,1,2,5' DINE='1' MARK='1'>
  <T1037>0000123456029024</T1037>
  <T1018>7700112233</T1018>
  <T1048> ООО "АБВГД"</T1048>
  <T1009>123456, г.Москва, Красная площадь д.1</T1009>
  <T1017>7714731464</T1017>
  <T1046> Атлас-Карт </T1046>
  <T1060>www.nalog.gov.ru</T1060>
  <T1117> noreply@ofd.com </T1117>
  </REG>
*)

// Формат: <REG BASE=’0’ ATTR='данные'… ><TAG>данные</TAG>…</REG>
// Ответ: <OK FD='номер фискального документа' FP='фискальный признак'/>

function TMitsuDrv.FNParamsToXml(const Params: TFNParams): AnsiString;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('REG', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('BASE', Params.Base);
  Node.SetAttribute('MARK', BoolToStr[Params.IsMarking]);
  Node.SetAttribute('PAWN', BoolToStr[Params.IsPawnshop]);
  Node.SetAttribute('INS', BoolToStr[Params.IsInsurance]);
  Node.SetAttribute('DINE', BoolToStr[Params.IsCatering]);
  Node.SetAttribute('OPT', BoolToStr[Params.IsWholesale]);
  Node.SetAttribute('VEND', BoolToStr[Params.IsVendingMachine]);
  Node.SetAttribute('T1001', BoolToStr[Params.IsAutomatic]);
  Node.SetAttribute('T1002', BoolToStr[Params.IsOffline]);
  Node.SetAttribute('T1056', BoolToStr[Params.IsEncrypted]);
  Node.SetAttribute('T1108', BoolToStr[Params.IsOnline]);
  Node.SetAttribute('T1109', BoolToStr[Params.IsService]);
  Node.SetAttribute('T1110', BoolToStr[Params.IsBlank]);
  Node.SetAttribute('T1126', BoolToStr[Params.IsLottery]);
  Node.SetAttribute('T1193', BoolToStr[Params.IsGambling]);
  Node.SetAttribute('T1207', BoolToStr[Params.IsExcisable]);
  Node.SetAttribute('T1221', BoolToStr[Params.IsAutomaticPrinter]);
  Node.SetAttribute('T1062', Params.TaxSystems);
  AddChild(Node, 'T1009', Params.SaleAddress);
  AddChild(Node, 'T1017', Params.OFDCompanyINN);
  AddChild(Node, 'T1018', Params.CompanyINN);
  AddChild(Node, 'T1036', Params.AutomaticNumber);
  AddChild(Node, 'T1037', Params.RegNumber);
  AddChild(Node, 'T1037', Params.RegNumber);
  AddChild(Node, 'T1046', Params.OFDCompany);
  AddChild(Node, 'T1048', Params.CompanyName);
  AddChild(Node, 'T1060', Params.FNSURL);
  AddChild(Node, 'T1117', Params.SenderEmail);
  AddChild(Node, 'T1187', Params.SaleLocation);
  AddChild(Node, 'T1274', Params.ExtendedProperty);
  AddChild(Node, 'T1275', Params.ExtendedData);
  Result := Trim(Xml.Xml.Text);
end;

function TMitsuDrv.FNOpen(const Params: TFNParams): Integer;
var
  Command: AnsiString;
begin
  Command := FNParamsToXml(Params);
  Result := Send(Command);
end;

function TMitsuDrv.FNChange(const Params: TFNParams): Integer;
var
  Command: AnsiString;
begin
  Command := FNParamsToXml(Params);
  Result := Send(Command);
end;

(*
  5.3. Печать отчета о (пере-) регистрации по номеру
  Формат: <GET REG='номер'/>
  <PRINT/>
*)

function TMitsuDrv.FNPrintReg(N: Integer): Integer;
begin
  Result := Send(Format('<GET REG=''%d''/><PRINT/>', [N]));
end;

(*
  5.4. Закрытие фискального накопителя
  Формат: <MAKE FISCAL=’CLOSE’/>
  <T1009>адрес расчетов</T1009>
  <T1187>место расчетов</T1187>
  <T1282> дополнительный реквизит ОЗФН </T1282>
  <T1283> дополнительные данные ОЗФН </T1283>
  </MAKE>
  Ответ: <OK FD='номер фискального документа'
  FP='фискальный признак документа'/>
*)

function TMitsuDrv.FNClose(const Params: TFNParams): Integer;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('MAKE', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('FISCAL', 'CLOSE');
  Node.SetAttribute('T1009', Params.SaleAddress);
  Node.SetAttribute('T1187', Params.SaleLocation);
  Node.SetAttribute('T1282', Params.ExtendedProperty);
  Node.SetAttribute('T1283', Params.ExtendedData);
  if FPrintDocument then
    Result := Send(Trim(Xml.Xml.Text));
end;

(*
  6.1. Открытие смены
  Формат: <Do SHIFT='OPEN'/>
  или: <Do SHIFT='OPEN'>
  <T1009> адрес расчетов </T1009>
  <T1187> место расчетов </T1187>
  <T1276> дополнительный реквизит ООС</T1276>
  <T1277> дополнительные данные ООС </T1277>
  </Do>
  Ответ: <OK
  SHIFT='номер открытой смены'
  FD='номер фискального документа'
  FP='фискальный признак документа'
  MsgOFD='маска сообщения оператора'
  OKP='маска состояния обновления ключей проверки КМ' />
  Пример: <OK SHIFT='18' FD='86' FP='0899945832' MsgOFD='0' OKP='0'/>
*)

function TMitsuDrv.OpenFiscalDay(const Params: TMTSDayParams): Integer;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
  Command: AnsiString;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('Do', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('SHIFT', 'OPEN');
  if Params.SaleAddress <> '' then
    AddChild(Node, 'T1009', Params.SaleAddress);
  if Params.SaleLocation <> '' then
    AddChild(Node, 'T1187', Params.SaleLocation);
  if Params.ExtendedProperty <> '' then
    AddChild(Node, 'T1276', Params.ExtendedProperty);
  if Params.ExtendedData <> '' then
    AddChild(Node, 'T1277', Params.ExtendedData);
  Command := Trim(Xml.Xml.Text);
  Result := Send(Command);
  if Succeeded(Result) and Params.PrintRequired then
    Result := Print;
end;

(*
  6.2. Закрытие смены
  Формат: <Do SHIFT='CLOSE'/>
  или: <Do SHIFT='CLOSE'>
  <T1009> адрес расчетов </T1009>
  <T1187> место расчетов </T1187>
  <T1278> дополнительный реквизит ОЗС </T1278>
  <T1279> дополнительные данные ОЗС </T1279>
  </Do>
  Ответ: <OK
  SHIFT='номер закрытой смены'
  FD='номер фискального документа'
  FP='фискальный признак документа'
  MsgOFD='маска сообщения оператора'/>
*)

function TMitsuDrv.CloseFiscalDay(const Params: TMTSDayParams): Integer;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
  Command: AnsiString;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('Do', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('SHIFT', 'CLOSE');
  if Params.SaleAddress <> '' then
    AddChild(Node, 'T1009', Params.SaleAddress);
  if Params.SaleLocation <> '' then
    AddChild(Node, 'T1187', Params.SaleLocation);
  if Params.ExtendedProperty <> '' then
    AddChild(Node, 'T1278', Params.ExtendedProperty);
  if Params.ExtendedData <> '' then
    AddChild(Node, 'T1279', Params.ExtendedData);
  Command := Xml.XML.Text;
  //Xml.SaveToXML(Command);
  Result := Send(Command);
  if Succeeded(Result) and Params.PrintRequired then
    Result := Print;
end;

(*
  7.1. Открытие чека
  Формат: <Do CHECK=’OPEN’ TYPE=’признак расчета’ TAX=’система налогообложения’/>
  или: <Do CHECK=’OPEN’ TYPE=’признак расчета’ TAX=’ система налогообложения’>
  <T1009> адрес расчетов </T1009>
  <T1187> место расчетов </T1187>
  <T1036> номер автомата </T1036>
  <T1117> адрес электронной почты отправителя чека </T1117>
  <Do/>
*)

function TMitsuDrv.OpenReceipt(const Params: TMTSOpenReceipt): Integer;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
  Command: AnsiString;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('Do', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('CHECK', 'OPEN');
  Node.SetAttribute('TYPE', Params.ReceiptType);
  Node.SetAttribute('TAX', Params.TaxSystem);
  if Params.SaleAddress <> '' then
    AddChild(Node, 'T1009', Params.SaleAddress);
  if Params.SaleLocation <> '' then
    AddChild(Node, 'T1187', Params.SaleLocation);
  if Params.AutomaticNumber <> '' then
    AddChild(Node, 'T1036', Params.AutomaticNumber);
  if Params.SenderEmail <> '' then
    AddChild(Node, 'T1117', Params.SenderEmail);
  Result := Send(Trim(Xml.Xml.Text));
end;

(*
  7.11. Отмена открытого чека
  Формат:
*)

function TMitsuDrv.CancelReceipt: Integer;
begin
  Result := Send('<Do CHECK=''CANCEL''/>');
end;

(*
  7.2. Начало ввода предметов расчета
  Формат:
  • Команда разрешает ввод предметов расчета (товарных позиций) и дополнительных реквизитов чека.
  • Команда выполняется, если чек открыт (см. Открытие чека).
  • Разрешен ввод текстовых и графических элементов.
  • Разрешена команда Отмена открытого чека.
*)

function TMitsuDrv.BeginRecPositions: Integer;
begin
  Result := Send('<Do CHECK=''BEGIN''/>');
end;

(*
  7.3. Предметы расчета (товарные позиции)
  Формат: <ADD ITEM= 'количество предмета расчета'
  TAX= 'ставка НДС по предмету расчета'
  UNIT= 'мера количества предмета расчета'
  PRICE= 'цена за единицу предмета расчета'
  TOTAL= 'стоимость предмета расчета'
  TYPE= 'признак предмета расчета'
  MODE= 'признак способа расчета'
  T1229= 'сумма акцизного сбора по предмету расчета'
  T1230= 'код страны происхождения'
  T1231= 'номер таможенной декларации' >
  <NAME>наименование предмета расчета</NAME>
  <QTY PART=’числитель’ OF=’знаменатель’ />
  <KM Тxxxx= ’код товара‘ />
  <T1191>дополнительный реквизит предмета расчета</T1191>
  <T1222>признак агента по предмету расчета</T1222>
  <T1223>
  <T1044>операция платежного агента</T1044>
  <T1073>телефон платежного агента</T1073>
  <T1074>телефон оператора по приему платежей</T1074>
  <T1075>телефон оператора перевода</T1075>
  <T1026>наименование оператора перевода</T1026>
  <T1005>адрес оператора перевода</T1005>
  <T1016>ИНН оператора перевода</T1016>
  </T1223>
  <T1224>
  <T1225>наименование поставщика</T1225>
  <T1171>телефон поставщика</T1171>
  </T1224>
  <T1260>
  <T1262>идентификатор ФОИВ</T1262>
  <T1263>дата документа основания</T1263>
  <T1264>номер документа основания</T1264>
  <T1265>значение отраслевого реквизита</T1265>
  </T1260>
  <T1226>ИНН поставщика</T1226>
  </ADD>
  Ответ: <OK TOTAL=’итог чека’
  ROUND=’округленный итог чека’
  OFF=’сумма округления’
  ITEMS=’количество предметов расчета’/>
*)

function QuantityToStr(Quantity: Double): AnsiString;
begin
  FormatSettings.DecimalSeparator := '.';
  Result := Format('%.6f', [Quantity]);
end;

function TMitsuDrv.AddRecPosition(const P: TMTSPosition): Integer;

  procedure AddIndustryAttribute(Node: IXmlNode;
    const P: TMTSIndustryAttribute);
  begin
    if not P.Enabled then
      Exit;

    Node := Node.AddChild('T1260');
    Node.SetAttribute('T1262', P.IdentifierFOIV);
    Node.SetAttribute('T1263', DateToFDStr(P.DocumentDate));
    Node.SetAttribute('T1264', P.DocumentNumber);
    Node.SetAttribute('T1265', P.AttributeValue);
  end;

  procedure AddVendorData(Node: IXmlNode; const Vendor: TMTSVendorData);
  begin
    if not Vendor.Enabled then
      Exit;

    Node.SetAttribute('T1226', Vendor.INN);
    Node := Node.AddChild('T1224');
    Node.SetAttribute('T1225', Vendor.Name);
    Node.SetAttribute('T1171', Vendor.Phone);
  end;

var
  Node: IXmlNode;
  Node2: IXmlNode;
  Xml: IXMLDocument;
  Command: WideString;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('ADD', '');
  Xml.DocumentElement := Node;
  // Required
  Node.SetAttribute('ITEM', QuantityToStr(P.Quantity));
  Node.SetAttribute('UNIT', IntToStr(P.UnitValue));
  Node.SetAttribute('PRICE', IntToStr(P.Price));
  Node.SetAttribute('TAX', IntToStr(P.TaxRate));
  AddChild(Node, 'NAME', P.Name);
  // Optional
  if P.Total <> 0 then
    Node.SetAttribute('TOTAL', IntToStr(P.Total));
  Node.SetAttribute('TYPE', IntToStr(P.ItemType));
  Node.SetAttribute('MODE', IntToStr(P.PaymentType));
  Node.SetAttribute('T1229', IntToStr(P.ExciseTaxTotal));
  Node.SetAttribute('T1230', P.CountryCode);
  Node.SetAttribute('T1231', P.CustomsDeclaration);;
  if P.MarkingCode <> '' then
    AddChild(Node, 'KM', P.MarkingCode);
  if P.AddAttribute <> '' then
    AddChild(Node, 'T1191', P.AddAttribute);
  if P.AgentType > 0 then
    AddChild(Node, 'T1222', IntToStr(P.AgentType));
  if P.Numerator <> 0 then
    AddChild(Node, 'QTY', Format('PART=''%d'' OF=''%d''',
      [P.Numerator, P.Denominator]));

  AddAgentData(Node, P.AgentData);
  AddVendorData(Node, P.VendorData);
  AddIndustryAttribute(Node, P.IndustryAttribute);
  Xml.SaveToXML(Command);
  Result := Send(Command);
end;

procedure TMitsuDrv.AddAgentData(Node: IXmlNode; const P: TMTSAgentData);
begin
  if not P.Enabled then
    Exit;

  Node := Node.AddChild('<T1223>');
  if P.AgentOperation <> '' then
    AddChild(Node, '<T1044>', P.AgentOperation);
  if P.AgentPhone <> '' then
    AddChild(Node, '<T1073>', P.AgentPhone);
  if P.PaymentProcessorPhone <> '' then
    AddChild(Node, '<T1074>', P.PaymentProcessorPhone);
  if P.AcquirerOperatorPhone <> '' then
    AddChild(Node, '<T1075>', P.AcquirerOperatorPhone);
  if P.AcquirerOperatorName <> '' then
    AddChild(Node, '<T1026>', P.AcquirerOperatorName);
  if P.AcquirerOperatorAddress <> '' then
    AddChild(Node, '<T1005>', P.AcquirerOperatorAddress);
  if P.AcquirerOperatorINN <> '' then
    AddChild(Node, '<T1016>', P.AcquirerOperatorINN);
end;

(*
  7.4. Дополнительные реквизиты чека
  Формат: <ADD DATA=’ ’>
  <T1192> дополнительный реквизит чека </T1192>
  <T1008>почта или телефон покупателя</T1008>
  <T1256>
  <T1227>ФИО или наименование покупателя</T1227>
  <T1228>ИНН покупателя</T1228>
  <T1243>дата рождения покупателя</T1243>
  <T1244>гражданство покупателя</T1244>
  <T1245>код вида документа, удостоверяющего личность</T1245>
  <T1246>данные документа, удостоверяющего личность</T1246>
  <T1254>адрес покупателя</T1254>
  </T1256>

  <T1261>
  <T1262>идентификатор ФОИВ</T1262>
  <T1263>дата документа основания</T1263>
  <T1264>номер документа основания</T1264>
  <T1265>значение отраслевого реквизита</T1265>
  </T1261>

  <T1270>
  <T1271>идентификатор операции</T1271>
  <T1272>данные операции</T1272>
  <T1273>дата, время операции</T1273>
  </T1270>

  <T1084>
  <T1085>наименование доп. реквизита пользователя</T1085>
  <T1086>значение доп. реквизита пользователя</T1086>
  </T1084>
  </ADD>
*)

function TMitsuDrv.AddRecAttributes(const P: TMTSAttributes): Integer;

  procedure AddCustomerDetail(Node: IXmlNode; const P: TMTSCustomerDetail);
  begin
    if not P.Enabled then
      Exit;

    Node := Node.AddChild('<T1256>');
    Node.SetAttribute('<T1227>', P.Name);
    Node.SetAttribute('<T1228>', P.INN);
    Node.SetAttribute('<T1243>', DateToFDStr(P.BirthDate));
    Node.SetAttribute('<T1244>', Format('%3d', [P.CountryCode]));
    Node.SetAttribute('<T1245>', Format('%2d', [P.DocumentCode]));
    Node.SetAttribute('<T1246>', P.DocumentData);
    Node.SetAttribute('<T1254>', P.Address);
  end;

  procedure AddIndustryAttribute(Node: IXmlNode;
    const P: TMTSIndustryAttribute);
  begin
    if not P.Enabled then
      Exit;

    Node := Node.AddChild('<T1261>');
    Node.SetAttribute('<T1262>', P.IdentifierFOIV);
    Node.SetAttribute('<T1263>', DateToFDStr(P.DocumentDate));
    Node.SetAttribute('<T1264>', P.DocumentNumber);
    Node.SetAttribute('<T1265>', P.AttributeValue);
  end;

  procedure AddOperationInfo(Node: IXmlNode; const P: TMTSOperationInfo);
  begin
    if not P.Enabled then
      Exit;

    Node := Node.AddChild('<T1270>');
    Node.SetAttribute('<T1271>', P.ID);
    Node.SetAttribute('<T1272>', P.Data);
    Node.SetAttribute('<T1273>', DateTimeToUnix(P.Date));
  end;

  procedure AddUserAttribute(Node: IXmlNode; const P: TMTSUserAttribute);
  begin
    if not P.Enabled then
      Exit;

    Node := Node.AddChild('<T1084>');
    Node.SetAttribute('<T1085>', P.Name);
    Node.SetAttribute('<T1086>', P.Value);
  end;

var
  Node: IXmlNode;
  Node2: IXmlNode;
  Xml: IXMLDocument;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('ADD', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('DATA', '');
  Node.SetAttribute('T1192', P.ExtraAttribute);
  Node.SetAttribute('T1008', P.CustomerPhone);
  AddCustomerDetail(Node, P.CustomerDetail);
  AddIndustryAttribute(Node, P.IndustryAttribute);
  AddOperationInfo(Node, P.OperationInfo);
  AddUserAttribute(Node, P.UserAttribute);
  Result := Send(Trim(Xml.Xml.Text));
end;

(*
  7.7. Итоги чека
  Формат: <Do CHECK=’TOTAL’/>
  Ответ: <OK TOTAL=’итог чека’
  ROUND=’округленный итог чека’
  OFF=’сумма округления’
  ITEMS=’количество предметов расчета’/>
*)

function TMitsuDrv.ReadReceiptTotal(var R: TMTSReceiptTotal): Integer;
begin
  Result := Send('<Do CHECK=''TOTAL''/>');
  if Succeeded(Result) then
  begin
    R.Total := GetIntAttribute('TOTAL');
    R.RoundedTotal := GetIntAttribute('ROUND');
    R.RoundAmount := GetIntAttribute('OFF');
    R.ItemsCount := GetIntAttribute('ITEMS');
  end;
end;

(*
  7.8. Ввод оплаты
  Формат: <Do CHECK=’PAY’
  PA = 'сумма оплаты наличными'
  PB = 'сумма оплаты безналичными'
  PC = ' сумма оплаты в зачет аванса'
  PD = ' сумма оплаты в кредит'
  PE = 'сумма оплаты иная'
  ROUND='сумма произвольной скидки'>
  <CMT TYPE='тип' Type1='сумма'. . .Type5='сумма'>текст</CMT>
  </Do>
*)

function TMitsuDrv.PayReceipt(const P: TMTSReceiptPayment): Integer;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('Do', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('CHECK', 'PAY');
  Node.SetAttribute('PA', P.CashAmount);
  Node.SetAttribute('PB', P.CardAmount);
  Node.SetAttribute('PC', P.AdvanceAmount);
  Node.SetAttribute('PD', P.CreditAmount);
  Node.SetAttribute('PE', P.OtherAmount);
  Node.SetAttribute('ROUND', P.DiscountAmount);

  Node := Node.AddChild('CMT');
  Node.Text := P.CommentText;
  Node.SetAttribute('TYPE', P.CommentType);
  Node.SetAttribute('Type1', P.AmountType1);
  Node.SetAttribute('Type2', P.AmountType2);
  Node.SetAttribute('Type3', P.AmountType3);
  Node.SetAttribute('Type4', P.AmountType4);
  Node.SetAttribute('Type5', P.AmountType5);
  Result := Send(Trim(Xml.Xml.Text));
end;

(*
  7.9. Завершение формирование чека
  Формат: <Do CHECK=’END’/>
  Ответ: <OK CHECK='номер чека за смену'
  FD='номер фискального документа'
  FP='фискальный признак документа'>

  TOTAL=’итог чека’
  AUTOMAT=’номер автомата’ >
  <ADDRESS>адрес расчетов</ADDRESS>
  <PLACE>место расчетов</PLACE>
  </OK>
*)

function TMitsuDrv.EndPositions(var R: TMTSEndPositions): Integer;
begin
  Result := Send('<Do CHECK=''END''/>');
  if Succeeded(Result) then
  begin
    R.RecNumber := GetIntAttribute('CHECK');
    R.DocNumber := GetIntAttribute('FD');
    R.FiscalSign := GetAttribute('FP');
    R.Date := GetDateAttribute('DATE') + GetTimeAttribute('TIME');
    R.Total := GetIntAttribute('TOTAL');
    R.AutomaticNumber := GetIntAttribute('AUTOMAT');
    R.SaleAddress := GetAttribute('ADDRESS');
    R.SaleLocation := GetAttribute('PLACE');
  end;
end;

(*
  7.10. Закрытие и печать чека
  Формат:
  • Закрывает чек. Завершает формирование печатной формы чека.
  • Для печати чека надо дополнительно подать команду <PRINT/>.
*)

function TMitsuDrv.CloseReceipt(Print: Boolean): Integer;
var
  Command: AnsiString;
begin
  Command := '<Do CHECK=''CLOSE''/>';
  if Print then
    Command := Command + '<PRINT/>';
  Result := Send(Command);
end;

(*
  8.1. Открытие чека коррекции
  Формат: <Do CHECK =’CORR’
  TYPE=’признак расчета’
  TAX=’система налогообложения’>
  <T1009> адрес расчетов </T1009>
  <T1187> место расчетов </T1187>
  <T1036> номер автомата </T1036>
  <T1117> адрес электронной почты отправителя чека </T1117>
  <T1173> тип коррекции </T1173>
  <T1174>
  <T1178> дата совершения корректируемого расчета </T1178>
  <T1179> номер предписания </T1179>
  </T1174>
  </Do>
*)

function TMitsuDrv.OpenCorrection(const P: TMTSOpenReceipt): Integer;

  procedure AddCorrection(Node: IXmlNode; const P: TMTSCorrection);
  begin
    Node := Node.AddChild('T1174');
    Node.SetAttribute('T1178', DateTimeToUnix(P.Date));
    Node.SetAttribute('T1179', P.Document);
  end;

var
  Node: IXmlNode;
  Xml: IXMLDocument;
  Command: AnsiString;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('Do', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('CHECK', 'CORR');
  Node.SetAttribute('TYPE', P.ReceiptType);
  Node.SetAttribute('TAX', P.TaxSystem);
  if P.SaleAddress <> '' then
    AddChild(Node, 'T1009', P.SaleAddress);
  if P.SaleLocation <> '' then
    AddChild(Node, 'T1187', P.SaleLocation);
  if P.AutomaticNumber <> '' then
    AddChild(Node, 'T1036', P.AutomaticNumber);
  if P.SenderEmail <> '' then
    AddChild(Node, 'T1117', P.SenderEmail);
  AddCorrection(Node, P.Correction);
  Result := Send(Trim(Xml.Xml.Text));
end;

(*
  8.2. Закрытие и печать чека коррекции
  Формат: <Do CHECK=’PAY’
  PA=’сумма оплаты наличными’
  PB=’сумма оплаты безналичными’
  PC=’сумма оплаты в зачет аванса’
  PD=’сумма оплаты в кредит’
  PE=’сумма оплаты встречным предоставлением’ >
  </Do>
*)

function TMitsuDrv.PayCorrection(const P: TMTSReceiptPayment): Integer;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('Do', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('CHECK', 'PAY');
  Node.SetAttribute('PA', P.CashAmount);
  Node.SetAttribute('PB', P.CardAmount);
  Node.SetAttribute('PC', P.AdvanceAmount);
  Node.SetAttribute('PD', P.CreditAmount);
  Node.SetAttribute('PE', P.OtherAmount);
  Result := Send(Trim(Xml.Xml.Text));
end;

(*
  9.1. Открытие нефискального документа
  Формат: <Do CHECK=’TXT’/>
*)

function TMitsuDrv.OpenNonfiscal: Integer;
begin
  Result := Send('<Do CHECK=''TXT''/>');
end;

(*
  9.2. Закрытие нефискального документа
  Формат: <Do CHECK=’CLOSE’/>
  <PRINT/>
*)

function TMitsuDrv.CloseNonfiscal(Print: Boolean): Integer;
var
  Command: AnsiString;
begin
  Command := '<Do CHECK=''CLOSE''/>';
  if Print then
    Command := Command + '<PRINT/>';
  Result := Send(Command);
end;

(*
  10.1. Текст
  Формат: <ADD FORM = 'формат'> <TEXT>текст</TEXT></ADD>
  • FORM: формат текста, задается последовательностью 6-ти цифр, по умолчанию '000000':
  1-я цифра – инверсия ч/б:
  0 – нет инверсии: черный текст на белом фоне;
  1 – инверсия: белый текст на черном фоне;
  2-я цифра – размер текста по горизонтали (ширина):
  3-я цифра – размер текста по вертикали (высота):
  0 или 1 – обычный размер;
  от 2 до 8 – масштаб от 2-х до 8-кратного;

  4-я цифра – тип шрифта:
  0 – шрифт, заданный настройкой Установка настроек принтера;
  1 – шрифт "А" (стандартный);
  2 – шрифт "B" (компактный);
  5-я цифра – подчеркивание:
  0 – нет;
  1 – подчеркнут только печатаемый текст;
  2 – подчеркивание всей строки от левого поля до правого;
  6-я цифра – выравнивание:
  0 – по левому краю;
  1 – по центру;
  2 – по правому краю.
  • TEXT: текст длиной до 2000 символов в кодировке Windiws-1251. При печати текст разбивается на
  строки с переносами по словам.
*)

function TMitsuDrv.AddText(const P: TMTSPrintText): Integer;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
  Format: AnsiString;
const
  Inversion: array [Boolean] of string = ('0', '1');
begin
  Format := Inversion[P.IsInversion] + IntToStr(P.HorizontalFactor) +
    IntToStr(P.VerticalFactor) + IntToStr(P.FontType) +
    IntToStr(P.UnderlineMode) + IntToStr(P.Alignment);

  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('ADD', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('FORM', Format);
  AddChild(Node, 'TEXT', P.Text);
  Result := Send(Trim(Xml.Xml.Text));
end;

function TMitsuDrv.AddText(const Text: WideString): Integer;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('ADD', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('FORM', '000000');
  AddChild(Node, 'TEXT', Text);
  Result := Send(Trim(Xml.Xml.Text));
end;

(*
  10.2. Штрих-код
  Формат: <ADD BAR='тип кода' X = 'ширина штриха' Y = 'высота кода'>
  <VAL> значение </VAL>
  </ADD>
  • BAR : тип кода, одно из следующих значений:
  0 – UPC-A 3 – EAN8/JAN8 6 – CODABAR
  1 – UPC-E 4 – CODE39 7 – CODE93
  2 – EAN13/JAN13 5 – ITF 8 – CODE128
  • X : ширина штриха кода в пикселях (от 1 до 6);
  • Y : высота кода в пикселях (от 1 до 255);
  • VAL : значение (должно соответствовать стандартам кода)
*)

function TMitsuDrv.AddBarcode(const P: TMTSBarcode): Integer;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('ADD', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('BAR', P.BarcodeType);
  Node.SetAttribute('X', P.ModuleWidth);
  Node.SetAttribute('Y', P.BarcodeHeight);
  AddChild(Node, 'VAL', P.Data);
  Result := Send(Trim(Xml.Xml.Text));
end;

function TMitsuDrv.Print: Integer;
begin
  Result := Send('<PRINT/>');
end;

(*
  10.3. QR код
  Формат: <ADD BAR='9' X='уровень коррекции' Y='размер точек' ALIGN = 'выравнивание'>
  <VAL> значение </VAL>
  <TEXT> текст для печати рядом с QR-кодом </TEXT>
  </ADD>
  • VAL : значение QR кода, обязательный параметр.
  • X : уровень коррекции ошибок: 0 (L), 1 (M), 2 (Q), 3 (H), по умолчанию 2 (Q);
  • Y : размер точек: от 1 до 4, по умолчанию 3;
  • ALIGN : расположение, по умолчанию – как задано в настройке Установка других настроек (опции):
  0 – QR код слева, текст справа;
  1 – QR код по центру, текст отдельно;
  2 – QR код справа, текст слева.
  • TEXT : текст для печати рядом с QR кодом
*)

function TMitsuDrv.AddQRCode(const P: TMTSQRCode): Integer;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('ADD', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('BAR', 9);
  Node.SetAttribute('ALIGN', P.Alignment);
  Node.SetAttribute('X', P.CorrectionLevel);
  Node.SetAttribute('Y', P.ModuleWidth);
  AddChild(Node, 'VAL', P.Data);
  AddChild(Node, 'TEXT', P.Text);
  Result := Send(Trim(Xml.Xml.Text));
end;

(*
  10.4. Рисунок
  Формат: <ADD PIC='номер рисунка' POS = 'выравнивание'/>
  • PIC: номер рисунка (0-22), из числа ранее загруженных в память кассы.
  • POS: расположение рисунка в строке:31
  0 – по левому краю;
  1 – по центру;
  2 – по правому краю.
*)

function TMitsuDrv.AddPicture(const P: TMTSPicture): Integer;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('ADD', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('PIC', P.PicNumber);
  Node.SetAttribute('POS', P.Alignment);
  Result := Send(Trim(Xml.Xml.Text));
end;

(*
  10.5. Разделительная линия в чеке
  Формат: <ADD LINE='тип линии'/>
  • LINE : тип линии:
  1 – одинарная тонкая;
  2 – двойная;
  3 – толстая. *)

function TMitsuDrv.AddSeparatorLine(LineType: Integer): Integer;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('ADD', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('LINE', LineType);
  Result := Send(Trim(Xml.Xml.Text));
end;

(*
  10.6. Прогон бумаги в чеке
  Формат: <ADD FEED='количество пикселей'/>
  • FEED: размер прогона чековой ленты в пикселях (0–255).
  Добавляется в печатную форму чека или текстового документа.
*)

function TMitsuDrv.AddBlankPixels(PixelCount: Integer): Integer;
begin
  Result := Send(Format('<ADD FEED=''%d''/>', [PixelCount]));
end;

(*
  10.7. Пустые строки в чеке
  Формат: <ADD BLANK='число строк'/>
  • BLANK: число пустых строк (0–255).
  Добавляются в печатную форму чека или текстового документа.
*)

function TMitsuDrv.AddBlankLines(LineCount: Integer): Integer;
begin
  Result := Send(Format('<ADD BLANK=''%d''/>', [LineCount]));
end;

(*
  10.8. Прогон бумаги
  Формат: < FEED n='количество пикселей'/>
  • FEED: размер прогона чековой ленты в пикселях (0–255), в режиме реального времени
*)

function TMitsuDrv.FeedPixels(PixelCount: Integer): Integer;
begin
  Result := Send(Format('<FEED n=''%d''/>', [PixelCount]));
end;

(*
  10.9. Отрезка ленты
  Формат: <CUT/>
  • Отрезка бумаги в режиме реального времени.
*)

function TMitsuDrv.CutPaper: Integer;
begin
  Result := Send('<CUT/>');
end;

(*
  10.11. Перезапуск фискального накопителя
  Формат: <DEVICE JOB='1'/>
  • Инициализация ФН по питанию, если произошел таймаут ответа ФН.
*)

function TMitsuDrv.RestartFD: Integer;
begin
  Result := Send('<DEVICE JOB=''1''/>');
end;

(*
  10.12. Инициализация принтера
  Формат: <DEVICE JOB='2'/>
  • Инициализация печатающего устройства после «зависания»
*)

function TMitsuDrv.InitPrinter: Integer;
begin
  Result := Send('<DEVICE JOB=''2''/>');
end;

(*
  10.13. Состояние принтера
  Формат: <DEVICE JOB='3'/>
  • Ответ <OK/>, если состояние принтера в норме.
  • Ответ <ERROR No='код ошибки'/> с кодом от 500 до 511
*)

function TMitsuDrv.ReadPrinterStatus: Integer;
begin
  Result := Send('<DEVICE JOB=''3''/>');
end;

(*
  10.14. Открыть денежный ящик
  Формат: <DEVICE JOB='4'/>
*)

function TMitsuDrv.OpenCashDrawer: Integer;
begin
  Result := Send('<DEVICE JOB=''4''/>');
end;

(*
  10.15. Состояние денежного ящика
  Формат: <DEVICE JOB='5'/>
  Ответ: <OK DRAWER='код состояния'/>
  • Код состояния = '0' – закрыт, '1' – открыт (зависит от подключения сенсора).
*)

function TMitsuDrv.ReadCashDrawerStatus(var Status: Integer): Integer;
begin
  Result := Send('<DEVICE JOB=''5''/>');
  if Succeeded(Result) then
  begin
    Status := GetIntAttribute('DRAWER');
  end;
end;

(*
  12.1. Отчет о текущем состоянии расчетов
  Формат: <MAKE REPORT='Z'/>
  или: <MAKE REPORT='Z'>
  <T1009>адрес расчетов</T1009>
  <T1187>место расчетов</T1187>
  <T1280> дополнительный реквизит ОТР </T1280>
  <T1281> дополнительные данные ОТР </T1281>
  </Make>
  Ответ: <OK
  PENDING='количество неотправленных в ОФД документов'
  FIRST='дата первого неотправленного в ОФД документа'
  FD='номер фискального документа'
  FP='фискальный признак документа'/>
*)

function TMitsuDrv.MakeCalcReport(var R: TMTSCalcReport): Integer;
begin
  Result := Send('<MAKE REPORT=''Z''/>');
  if Succeeded(Result) then
  begin
    R.PendingCount := GetIntAttribute('PENDING');
    R.FirstDocDate := GetDateAttribute('FIRST');
    R.FDocNumber := GetIntAttribute('FD');
    R.FiscalSign := GetIntAttribute('FP');
  end;
end;

(*
  12.2. Отчет об итогах смены (X-отчет)
  Формат: <MAKE REPORT='X'/>
  Ответ: <OK SHIFT=' номер смены '
  STATE='состояние смены'
  COUNT='количество чеков за смену'
  KeyValid=’срок действия ключей’>
  </OK>
*)

function TMitsuDrv.MakeXReport(var R: TMTSDayStatus): Integer;
begin
  Result := Send('<MAKE REPORT=''X''/>');
  if Succeeded(Result) then
  begin
    R.DayNumber := GetIntAttribute('SHIFT');
    R.DayStatus := GetIntAttribute('STATE');
    R.RecNumber := GetIntAttribute('COUNT');
    R.KeyExpDays := GetIntAttribute('KeyValid');
  end;
end;

(*
  11.1. Проверка кода маркировки в ФН
  Формат: <Do Mark=’TRY’><KM>КОД</KM></Do>
  Ответ: <OK T2004='результат' RES='причина' />
  • KM : код маркировки в шестнадцатеричном виде, обязательный параметр.
  • T2004 : результат проверки КМ в ФН – число в 16-ричном представлении, битовая маска:
  0x00 – КМ не может быть проверен в ФН с использованием ключа проверки КП
  0x01 – КМ проверен, результат отрицательный
  0x03 – КМ проверен, результат положительный
  Бит Значение 0 1
  0 КМ проверен в ФН с использованием ключа проверки КП? нет да
  1 КМ проверен, результат положительный? нет да
  • RES : код причины отказа в проверке КМ в ФН, возможные значения:
  0 – КМ проверен в ФН
  1 – КМ данного типа не подлежит проверки в ФН
  2 – ФН не содержит ключ проверки кода проверки этого КМ
  3 – Проверка невозможна, отсутствуют идентификаторы применения GS1 91 и / или 92 или их формат неверный.
  4 – Проверка КМ в ФН невозможна по иной причине.
*)

function TMitsuDrv.MCCheckMarkingCode(const MarkingCode: AnsiString;
  var R: TMTSMarkCheck): Integer;
begin
  Result := Send(Format('<Do Mark=''TRY''><KM>%s</KM></Do>', [MarkingCode]));
  if Succeeded(Result) then
  begin
    R.Status := GetIntAttribute('T2004');
    R.Reason := GetIntAttribute('RES');
  end;
end;

(*
  11.2. Получение запроса для проверки КМ в ОИСМ, до открытия чека
  Формат: <Do Mark=’TEST’ ITEM='количество' UNIT= ‘мера ' ST= 'планируемый статус' >
  <QTY PART='числитель' OF='знаменатель'/>
  <KM>КОД</KM>
  </Do>
  Ответ (А): В автономном режиме, либо при отрицательном результате пров
  <OK Ext='режим' T2004='результат' RES='причина' />
  Ответ (Б): В режиме передачи данных, при положительном результате про
  <OK Ext='режим' T2004='результат' RES='причина'> ЗАПРОС </OK>
*)

function TMitsuDrv.MCReadRequest(const P: TMTSTestMark;
  var R: TMTSTestMarkResponse): Integer;
var
  Node: IXmlNode;
  Node2: IXmlNode;
  Xml: IXMLDocument;
  Command: AnsiString;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('Do', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('Mark', 'TEST');
  Node.SetAttribute('ITEM', QuantityToStr(P.Quantity));
  Node.SetAttribute('UNIT', P.MeasureOfQuantity);
  Node.SetAttribute('ST', P.PlannedStatus);
  Node2 := Node.AddChild('QTY');
  Node2.SetAttribute('PART', P.Numerator);
  Node2.SetAttribute('OF', P.Denominator);
  Node2 := Node.AddChild('KM');
  Node2.Text := P.MarkingCode;
  //Xml.SaveToXML(Command);
  Command := Xml.XML.Text;
  Result := Send(Trim(Command));
  if Succeeded(Result) then
  begin
    R.Mode := GetIntAttribute('Ext');
    R.TestResult := GetIntAttribute('T2004');
    R.Reason := GetIntAttribute('RES');
  end;
end;

(*
  11.3. Получение запроса на проверку КМ в ОИСМ, в открытом чеке
  Формат: <Do Mark=’GET’ ITEM='количество' UNIT= ‘мера ' ST= 'планируемый статус' >
  <QTY PART='числитель' OF='знаменатель'/><KM>КОД</KM></Do>
  Ответ (А): В автономном режиме, либо при отрицательном результате проверки:
  <OK Ext='режим' T2004='результат' RES='причина' />
  Ответ (Б): В режиме передачи данных, для внешнего клиента обмена с ОИСМ:
  <OK Ext='режим' T2004='результат' RES='причина'> ЗАПРОС </OK>
  Ответ (В): В режиме передачи данных, для внутреннего клиента обмена с ОИСМ:
  <OK Ext='режим' T2004='результат' RES='причина'
  T2005='результат проверки КМ и статуса товара'
  T2105='код обработки запроса '
  T2106='результат проверки сведений о товаре'
  T2109='ответ ОИСМ о статусе товара' >
*)

function TMitsuDrv.MCReadRequestRec(const P: TMTSTestMark;
  var R: TMTSTestMarkResponse2): Integer;
var
  Node: IXmlNode;
  Node2: IXmlNode;
  Xml: IXMLDocument;
  Command: AnsiString;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('Do', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('Mark', 'GET');
  Node.SetAttribute('ITEM', QuantityToStr(P.Quantity));
  Node.SetAttribute('UNIT', P.MeasureOfQuantity);
  Node.SetAttribute('ST', P.PlannedStatus);
  Node2 := Node.AddChild('QTY');
  Node2.SetAttribute('PART', P.Numerator);
  Node2.SetAttribute('OF', P.Denominator);
  Node2 := Node.AddChild('KM');
  Node2.Text := P.MarkingCode;
  //Xml.SaveToXML(Command);
  Command := Xml.XML.Text;
  Result := Send(Trim(Command));
  if Succeeded(Result) then
  begin
    R.Mode := GetIntAttribute('Ext');
    R.TestResult := GetIntAttribute('T2004');
    R.Reason := GetIntAttribute('RES');
    R.MarCheckStatus := GetIntAttribute('T2005');
    R.RequestProcessCode := GetIntAttribute('T2105');
    R.ItemCodeStatus := GetIntAttribute('T2106');
    R.ItemStatusResponse := GetIntAttribute('T2109');
  end;
end;

(*
  11.4. Повторное получение запроса (для внешнего клиента обмена с ОИСМ)
  Формат: <Do Mark=’REQ’ ITEM=’количество’ UNIT=’мера‘ ST= ‘планируемый статус’ >
  <QTY PART=’числитель’ OF=’знаменатель’/>
  </Do>
  Ответ: <OK Ext='режим' T2004='результат' RES='причина' LENGTH='длина'> ЗАПРОС </OK>
*)

function TMitsuDrv.MCReadRequestData(const P: TMTSTestMark;
  var R: TMTSTestMarkResponse): Integer;
var
  Node: IXmlNode;
  Node2: IXmlNode;
  Xml: IXMLDocument;
  Command: AnsiString;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('Do', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('Mark', 'REQ');
  Node.SetAttribute('ITEM', QuantityToStr(P.Quantity));
  Node.SetAttribute('UNIT', P.MeasureOfQuantity);
  Node.SetAttribute('ST', P.PlannedStatus);
  Node2 := Node.AddChild('QTY');
  Node2.SetAttribute('PART', P.Numerator);
  Node2.SetAttribute('OF', P.Denominator);
  //Xml.SaveToXML(Command);
  Command := Xml.XML.Text;
  Result := Send(Trim(Command));
  if Succeeded(Result) then
  begin
    R.Mode := GetIntAttribute('Ext');
    R.TestResult := GetIntAttribute('T2004');
    R.Reason := GetIntAttribute('RES');
    R.Length := GetIntAttribute('LENGTH');
    R.Data := FAnswerDoc.DocumentElement.Text;
  end;
end;

(*
  11.6. Результат проверки в ОИСМ (внешний клиент)
  Формат: <Do Mark=’LOAD’>ОТВЕТ ОИСМ</Do>
  Ответ: <OK T2005='результат проверки КМ и статуса товара'
  T2105='код обработки запроса '
  T2106='результат проверки сведений о товаре'
  T2109='ответ ОИСМ о статусе товара'
  T2100='тип кода маркировки' >
*)

function TMitsuDrv.MCWriteResponse(const Response: AnsiString;
  var R: TMTSTestMarkResponse): Integer;
var
  Node: IXmlNode;
  Node2: IXmlNode;
  Xml: IXMLDocument;
  Command: AnsiString;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('Do', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('Mark', 'LOAD');
  Node.Text := StrToHexText(Response);
  //Xml.SaveToXML(Command);
  Command := Xml.XML.Text;
  Result := Send(Trim(Command));
  if Succeeded(Result) then
  begin
    (*
      R.CheckStatus := GetIntAttribute('T2005');
      R.RequestProcessCode := GetIntAttribute('T2105');
      R.ItemCheckStatus := GetIntAttribute('T2106');
      R.ItemStatusResponse := GetIntAttribute('T2109');
      R.MarkingCodeType := GetIntAttribute('T2100');
    *)
  end;
end;

end.
