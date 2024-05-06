unit MitsuDrv;

interface

uses
  // VCL
  Windows, Classes, SysUtils, ActiveX, Variants, XMLDoc, MSXML, XMLIntf,
  Math,
  // This
  PrinterPort, SerialPort, SocketPort, LogFile, StringUtils, DriverError,
  ByteUtils;

const
  /////////////////////////////////////////////////////////////////////////////
  //

  STX = #02;
  ETX = #03;

  /////////////////////////////////////////////////////////////////////////////
  // ConnectionType constants

  ConnectionTypeSerial   = 0;
  ConnectionTypeSocket   = 1;

  /////////////////////////////////////////////////////////////////////////////
  // Notification status constants

  MTS_NS_NO_ACTIVE_TRANSFER = 0; // нет активного обмена
  MTS_NS_READ_STARTED       = 1; // начато чтение уведомления;
  MTS_NS_WAIT_FOR_TICKET    = 2; // начато чтение уведомления;

  /////////////////////////////////////////////////////////////////////////////
  // Document type constants

  MTS_DT_NONFISCAL        = 0; // Нефискальный документ
  MTS_DT_REG_REPORT       = 1; // Отчёт о регистрации
  MTS_DT_DAY_OPEN         = 2; // Отчёт об открытии смены
  MTS_DT_RECEIPT          = 3; // Кассовый чек
  MTS_DT_BLANK            = 4; // Бланк строкой отчетности (БСО);
  MTS_DT_DAY_CLOSE        = 5; // Отчёт о закрытии смены
  MTS_DT_FD_CLOSE         = 6; // Отчёт о закрытии ФН
  MTS_DT_CASHIER_CONF     = 7; // Подтверждение оператора
  MTS_DT_REREG_REPORT     = 11; // Отчет о (пере) регистрации
  MTS_DT_CALC_REPORT      = 21; // Отчет о текущем состоянии расчетов
  MTS_DT_CORRECTION_REC   = 31; // Кассовый чек коррекции
  MTS_DT_CORRECTION_BSO   = 41; // БСО коррекции

type
  { TMTSDate }

  TMTSDate = record
    Year: Word;
    Month: Word;
    Day: Word;
  end;

  { TMTSTime }

  TMTSTime = record
    Hour: Word;
    Min: Word;
  end;

  { TMTSDateTime }

  TMTSDateTime = record
    Date: TMTSDate;
    Time: TMTSTime;
  end;

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
    Lines: array [0..9] of WideString;
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

  TMTSVATNames = array [1..6] of WideString;

  { TTagValue }

  TTagValue = record
    ID: Integer;
    Value: AnsiString;
  end;

  { TMTSRegParams }

  TMTSRegParams = record
    RegNumber: Integer;
    FDocNumber: Integer;
    Date: TMTSDate;
    Time: TMTSTime;
    Base: AnsiString;

    IsMarking: Boolean; // признак работы с маркированными товарами
    IsPawnshop: Boolean; // признак осуществления ломбардной деятельности
    IsInsurance: Boolean; // признак осуществления страховой деятельности
    IsCatering: Boolean; // признак примененияпри оказании услуг общественного питания
    IsWholesaleTrade: Boolean; // признак применения в оптовой торговле с организациями и ИП
    IsAutomaticPrinter: Boolean; // признак применения с автоматическим устройством
    IsAutomatic: Boolean; // признак автоматического режима
    IsOffline: Boolean; // Признак автономного режима
    IsEncrypted: Boolean; // признак шифрования
    TaxationSystems: AnsiString; // системы налогообложения
    IsOnline: Boolean;  // Признак ККТ для расчетов в Интернет
    IsService: Boolean; // Признак расчетов за услуги
    IsBlank: Boolean; // признак режима БСО
    IsLottery: Boolean; // Признак проведения лотереи
    IsGambling: Boolean; // Признак проведения азартных игр
    IsExcisable: Boolean; // Продажа подакцизного товара
    IsVendingMachine: Boolean; // Признак применения в автоматическом торговом автомате
    SaleAddress: WideString; // Адрес проведения расчетов
    SaleLocation: WideString; // Место проведения расчетов
    OFDCompany: WideString; // Название организации ОФД
    OFDCompanyINN: WideString; // ИНН организации ОФД
    FNSURL: WideString; // Адрес сайта уполномоченного органа (ФНС) в сети «Интернет»
    CompanyName: WideString; // Название организации
    CompanyINN: WideString; // ИНН организация
    SenderEmail: WideString; // Адрес электронной почты отправителя чека
    KKTNumber: WideString; // Регистрационный номер ККТ
    AutomaticNumber: WideString; // Номер автомата для автоматического режима
    ExtendedProperty: WideString; // дополнительный реквизит ОР
    ExtendedData: WideString; // дополнительные данные ОР
(*

    Mode: Integer;
    IsEncrypted: Boolean;   // Шифрование
    IsOffline: Boolean;     // Автономный режим
    IsAutomatic: Boolean;   // Автоматический режим
    IsService: Boolean;     // Применение в сфере услуг
    IsBlank: Boolean;       // Режим БСО (1), Режим чеков (0)
    IsInternet: Boolean;    // Применение в Интернет
    IsCatering: Boolean;    // Применение для оказания услуг общественного питания
    IsWholesale: Boolean;   // Применение в оптовой торговле с органиязациями и ИП

    ExtMode: Integer;
    IsExcisable: Boolean;   // Продажа подакцизного товара
    IsGambling: Boolean;    // Признак проведения азартных игр
    IsLottery: Boolean;     // Признак проведения лотереи
    IsAutomat: Boolean;     // Признак установки принтера в автомате
    IsMarking: Boolean;     // Признак применения при осуществлении торговли товарами, подлежащими обязательной маркировке средствами идентификации
    IsPawnshop: Boolean;    // Признак применения при осуществлении ломбардами кредитования граждан
    IsInsurance: Boolean;   // Признак применения при осуществлении деятельности по страхованию
    IsVendingMachine: Boolean; // Признак применения с торговым автоматом

    SerialNumber: AnsiString;
    DeviceVersion: AnsiString;
    T1189: AnsiString;
    T1190: AnsiString;
    T1209: AnsiString;
    T1037: AnsiString;
    T1018: AnsiString;
    T1017: AnsiString;
    T1036: AnsiString;
    T1062: AnsiString;
    T1041: AnsiString;
    T1048: AnsiString;
    SaleAddress: AnsiString;
    T1187: AnsiString;
    T1046: AnsiString;
    T1117: AnsiString;
    T1060: AnsiString;
*)
  end;

  { TFNParams }

  TFNParams = record
    IsMarking: Boolean; // признак работы с маркированными товарами
    IsPawnshop: Boolean; // признак осуществления ломбардной деятельности
    IsInsurance: Boolean; // признак осуществления страховой деятельности
    IsCatering: Boolean; // признак примененияпри оказании услуг общественного питания
    IsWholesaleTrade: Boolean; // признак применения в оптовой торговле с организациями и ИП
    IsAutomaticPrinter: Boolean; // признак применения с автоматическим устройством
    IsAutomatic: Boolean; // признак автоматического режима
    IsOffline: Boolean; // Признак автономного режима
    IsEncrypted: Boolean; // признак шифрования
    TaxationSystems: AnsiString; // системы налогообложения
    IsOnline: Boolean;  // Признак ККТ для расчетов в Интернет
    IsService: Boolean; // Признак расчетов за услуги
    IsBlank: Boolean; // признак режима БСО
    IsLottery: Boolean; // Признак проведения лотереи
    IsGambling: Boolean; // Признак проведения азартных игр
    IsExcisable: Boolean; // Продажа подакцизного товара
    IsVendingMachine: Boolean; // Признак применения в автоматическом торговом автомате
    SaleAddress: WideString; // Адрес проведения расчетов
    SaleLocation: WideString; // Место проведения расчетов
    OFDCompany: WideString; // Название организации ОФД
    OFDCompanyINN: WideString; // ИНН организации ОФД
    FNSURL: WideString; // Адрес сайта уполномоченного органа (ФНС) в сети «Интернет»
    CompanyName: WideString; // Название организации
    CompanyINN: WideString; // ИНН организация
    SenderEmail: WideString; // Адрес электронной почты отправителя чека
    KKTNumber: WideString; // Регистрационный номер ККТ
    AutomaticNumber: WideString; // Номер автомата для автоматического режима
    ExtendedProperty: WideString; // дополнительный реквизит ОР
    ExtendedData: WideString; // дополнительные данные ОР
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
    Total: Integer;
    T1136: AnsiString;
    T1138: AnsiString;
    T1218: AnsiString;
    T1219: AnsiString;
    T1220: AnsiString;
    T1139: AnsiString;
    T1140: AnsiString;
    T1141: AnsiString;
    T1142: AnsiString;
    T1143: AnsiString;
    T1183: AnsiString;
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
    Valid: TMTSDate;
    LastDoc: Integer;
    DocDate: TMTSDate;
    DocTime: TMTSTime;
    Flags: Integer;
  end;

  { TMTSFDOStatus }

  TMTSFDOStatus = record
    Serial: AnsiString;
    DocCount: Integer;
    FirstDoc: Integer;
    FirstDate: TMTSDate;
    FirstTime: TMTSTime;
  end;

  { TMTSMCStatus }

  TMTSMCStatus = record
    MCStatus: Integer; // состояние по проверке КМ
    MCCount: Integer; // количество сохранённых результатов проверки КМ
    MCFlags: Integer; // флаг разрешения команд работы с КМ (маска)
    MCNStatus: Integer; // состояние уведомления о реализации маркированного товара
    MCNCount: Integer; // количество КМ, включенных в уведомление
    NCount: Integer; // количество уведомлений в очереди
    FillStatus: Integer; // состояние заполнения области хранения уведомлений
  end;

  { TOISMStatus }

  TOISMStatus = record
    Status: Integer;      // состояние по передаче уведомлений
    QueueCount: Integer;  // количество уведомлений в очереди
    FirstNumber: Integer; // номер первого неподтвержденного уведомления
    FirstDate: TMTSDate;  // дата первого неподтвержденного уведомления
    FirstTime: TMTSTime;  // время первого неподтвержденного уведомления
    FillPercent: Integer; // процент заполнения области хранения уведомлений
  end;

  { TKeysStatus }

  TKeysStatus = record
    ExtClient: Boolean; // признак работы через внешний клиент обмена
    UpdateNeeded: Boolean; // признак необходимости обновления ключей
    CapD7Command: Boolean; // признак поддержки ФН выполнения команды D7
    OkpURL: AnsiString; // адрес и порт ОКП
    Date: TMTSDate; // дата последнего обновления ключей проверки КМ
    Time: TMTSTime; // время последнего обновления ключей проверки КМ
  end;

  { TDocStatus }

  TDocStatus = record
    DocNumber: Integer; // порядковый номер фискального документа
    DocType: Integer;  // тип документа
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
    function GetDateAttribute(const Attribute: AnsiString): TMTSDate;
    function GetTimeAttribute(const Attribute: AnsiString): TMTSTime;
    function GetChildAttribute(const Child, Attribute: AnsiString): AnsiString;
    function GetChildText(const Child: AnsiString): AnsiString;
    function HasAttribute(const Attribute: AnsiString): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    procedure Check(Code: Integer);
    function Send(const Command: AnsiString): Integer; overload;
    function Send(const Command: AnsiString; var Answer: AnsiString): Integer; overload;

    function Succeeded(rc: Integer): Boolean;
    function ReadDeviceName(var DeviceName: WideString): Integer;
    function ReadDeviceVersion(var R: TMTSVersion): Integer;
    function ReadDateTime(var R: TMTSDateTime): Integer;
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


    property Logger: ILogFile read FLogger;
    property Port: IPrinterPort read GetPort;
    property Answer: AnsiString read FAnswer;
    property Command: AnsiString read FCommand;
    property Params: TMitsuParams read FParams write FParams;
  end;

function MTSDateTimeToDateTime(const Date: TMTSDate; const Time: TMTSTime): TDateTime;

implementation

const
  BoolToStr: array [Boolean] of string = ('0', '1');

function MTSDateTimeToDateTime(const Date: TMTSDate; const Time: TMTSTime): TDateTime;
begin
  Result := EncodeDate(Date.Year, Date.Month, Date.Day) +
    EncodeTime(Time.Hour, Time.Min, 0, 0);
end;

function MTSDateToStr(const Date: TDateTime): AnsiString;
begin
  Result := FormatDateTime('yyyy-mm-dd', Date);
end;

function MTSTimeToStr(const Date: TDateTime): AnsiString;
begin
  Result := FormatDateTime('hh:nn:ss', Date);
end;

function GetAttribute2(Root: IXMLNode; const Attribute: AnsiString; N: Integer): AnsiString;
var
  Node: IXMLNode;
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

function GetIntAttribute2(Node: IXMLNode; const Attribute: AnsiString; N: Integer): Integer;
begin
  Result := StrToIntDef(GetAttribute2(Node, Attribute, N), 0);
end;

function getErrorMessage(Code: Integer): WideString;
begin
  Result := '';
  case Code of
    0: Result := 'нет ошибок';
    1: Result := 'неизвестная операция';
    2: Result := 'недостаточно памяти для выполнения операции';
    3: Result := 'операция не задана';
    4: Result := 'не задана структура хранения ошибки операции ФН';
    5: Result := 'не задана структура для результатов операции ФН';
    6: Result := 'не задана структура входящих параметров операции ФН';
    7: Result := 'превышен максимальный размер данных для команды ФН';
    8: Result := 'внутренняя ошибка ПО (не задан параметр в классификаторе команд)';
    10: Result := 'ошибка исходного состояния ФН перед (пере-)регистрацией';
    11: Result := 'ошибка ФН при получении статуса';
    12: Result := 'ошибка ФН при выдаче команды "Начать отчет о регистрации"';
    13: Result := 'ошибка ФН при выдаче команды "Передать данные документа"';
    14: Result := 'ошибка ФН при выдаче команды "Сформировать отчет о регистрации (перерегистрации)"';
    15: Result := 'ошибка ФН при выдаче команды "Начать закрытие фискального режима ФН"';
    16: Result := 'ошибка ФН при выдаче команды "Закрыть фискальный режим ФН"';
    17: Result := 'ошибка при попытке захвата ФН';
    18: Result := 'ошибка ФН при выдаче команды "Начать формирование отчета о текущем состоянии расчетов"';
    19: Result := 'ошибка ФН при выдаче команды "Сформировать отчет о текущем состоянии расчетов"';
    20: Result := 'ошибка ФН: смена открыта';
    21: Result := 'ошибка ФН: смена закрыта';
    22: Result := 'ошибка ФН: имеется незакрытый документ';
    23: Result := 'ошибка ФН при выдаче команды "Запрос количества ФД, на которые нет квитанции"';
    24: Result := 'ошибка ФН при выдаче команды "Запрос срока действия ФН"';
    25: Result := 'ошибка ФН при выдаче команды "Запрос итогов фискализации ФН"';
    26: Result := 'ошибка ФН: есть неподтвержденные в ОФД документы';
    27: Result := 'ошибка ФН при выдаче команды "Начать открытие смены"';
    28: Result := 'ошибка ФН при выдаче команды "Открыть смену"';
    29: Result := 'ошибка ФН при выдаче команды "Начать закрытие смены"';
    30: Result := 'ошибка ФН при выдаче команды "Закрыть смену"';
    31: Result := 'ошибка ФН при выдаче команды "Начать формирование чека (БСО)"';
    32: Result := 'ошибка определения типа: чек или БСО';
    33: Result := 'ошибка ФН: чек (БСО) не открыт';
    34: Result := 'ошибка преобразования данных';
    35: Result := 'ошибка ФН при выдаче команды "Сформировать чек"';
    36: Result := 'ошибка ФН при выдаче команды "Отменить текущий документ"';
    37: Result := 'ошибка: незакрытый документ отсутствует';
    38: Result := 'ошибка: время смены истекло';
    39: Result := 'ошибка: чек коррекции (БСО коррекции) не открыт';
    40: Result := 'ошибка ФН при получении счетчиков';
    41: Result := 'ошибка ФН при получении состояния смены';
    42: Result := 'ошибка: чек пустой (нет предметов расчета)';
    43: Result := 'ошибка: стадия формирования чека не соответствует операции';
    44: Result := 'ошибка ФН при выдаче команды "Запрос номера и типа версии ПО ФН"';
    45: Result := 'ошибка: нужна отладочная версия ФН для выполнения операции';
    46: Result := 'ошибка ФН при выдаче команды "Сброс ФН"';
    47: Result := 'ошибка ФН при получении статуса информационного обмена с ОФД';
    48: Result := 'ошибка ФН: чтение сообщения для ОФД уже начато';
    49: Result := 'ошибка ФН: нет сообщений для ОФД';
    50: Result := 'ошибка ФН при выдаче команды "Передать статус транспортного соединения с сервером ОФД"';
    51: Result := 'ошибка ФН при выдаче команды "Начать чтение сообщения для сервера ОФД"';
    52: Result := 'ошибка ФН: чтение сообщения для ОФД еще не начато';
    53: Result := 'ошибка ФН при выдаче команды "Отменить чтение сообщения для сервера ОФД"';
    54: Result := 'ошибка ФН при выдаче команды "Прочитать блок сообщения для сервера ОФД"';
    55: Result := 'ошибка ФН: нет готовности к принятию квитанции от ОФД';
    56: Result := 'ошибка ФН при выдаче команды "Передать квитанцию от сервера ОФД"';
    57: Result := 'ошибка ФН: неверный фискальный признак';
    58: Result := 'ошибка ФН: неверный формат квитанции';
    59: Result := 'ошибка ФН: неверный номер ФД';
    60: Result := 'ошибка ФН: неверный номер ФН';
    61: Result := 'ошибка ФН: неверный CRC';
    62: Result := 'ошибка ФН при выдаче команды "Запрос фискального документа в TLV формате"';
    63: Result := 'ошибка ФН при выдаче команды "Чтение TLV фискального документа"';
    64: Result := 'ошибка ФН: отсутствуют необходимые данные документа в архиве';
    65: Result := 'ошибка ФН: запрошенный из архива документ не является чеком';
    66: Result := 'ошибка ФН при выдаче команды "Запрос общего размера данных переданных командой 07h"';
    67: Result := 'ошибка ФН при выдаче команды "Запрос формата ФН"';
    68: Result := 'ошибка ФН: получены ошибочные данные от ФН';
    69: Result := 'ошибка ФН: ФН не готов или отсутствует';
    70: Result := 'ошибка ФН: превышено время ожидания ответа от ФН';
    71: Result := 'ошибка ФН: Не удалось получить запрос на проверку кода маркировки';
    72: Result := 'ошибка ФН: операция не поддерживается в автономном режиме';
    73: Result := 'ошибка ФН: чтение уведомления уже начато';
    74: Result := 'ошибка ФН: нет уведомлений для передачи';
    75: Result := 'ошибка ФН при выдаче команды "Начать чтение уведомления"';
    76: Result := 'ошибка ФН: чтение уведомления еще не начато';
    77: Result := 'ошибка ФН: нет готовности к принятию квитанции по уведомлениям';
    78: Result := 'ошибка ФН: неверный номер уведомления';
    79: Result := 'ошибка ФН: неверная длина ответа';
    80: Result := 'операция поддерживается только в автономном режиме';
    81: Result := 'запрос на обновление ключей проверки КМ не был сформирован';
    82: Result := 'ошибка ФН: неверный номер запроса в ответе';
    83: Result := 'ошибка ФН: для выполнения команды необходимо обновить ключи проверки кодов маркировки';
    84: Result := 'необходимо выгрузить уведомления';
    94: Result := 'Таймаут приема команды';
    95: Result := 'Устройство печати занято…';
    96: Result := 'В команде заданы неизвестные параметры';
    97: Result := 'В команде отсутствуют обязательные параметры';
    98: Result := 'Команда содержит параметры, а их не должно быть';
    99: Result := 'Неверный формат команды или неизвестная команда';
    100: Result := 'ошибка задания версии ФФД';
    101: Result := 'ошибка задания заводского номера';
    102: Result := 'ошибка задания версии';
    103: Result := 'ошибка задания регистрационного номера';
    104: Result := 'ошибка задания ИНН';
    105: Result := 'ошибка задания ИНН ОФД';
    106: Result := 'ошибка задания причины перерегистрации';
    107: Result := 'ошибка: заданная система налогообложения не поддерживается';
    108: Result := 'ошибка задания признака расчета';
    109: Result := 'ошибка задания признака способа расчета';
    110: Result := 'ошибка задания признака предмета расчета';
    111: Result := 'ошибка задания наименования предмета расчета';
    112: Result := 'ошибка задания единицы измерения предмета расчета';
    113: Result := 'ошибка задания кода товарной номенклатуры предмета расчета';
    114: Result := 'ошибка задания количества единиц предмета расчета';
    115: Result := 'ошибка задания цены за единицу предмета расчета';
    116: Result := 'ошибка задания стоимости предмета расчета';
    117: Result := 'ошибка задания ставки НДС предмета расчета';
    118: Result := 'ошибка расчета размера НДС за единицу предмета расчета';
    119: Result := 'ошибка расчета размера НДС предмета расчета';
    120: Result := 'ошибка: расчет стоимости по позициям чека превысил максимально допустимое значение';
    121: Result := 'ошибка: расчет стоимости по чеку превысил сумму оплат';
    122: Result := 'ошибка задания количества принятых наличных денег в оплату чека';
    123: Result := 'ошибка: расчет стоимости по видам оплаты чека превысил максимально допустимое значение';
    124: Result := 'ошибка получения текущего времени от внутренних часов';
    125: Result := 'ошибка: в чеке с оплатой кредита может быть только один предмет расчета';
    126: Result := 'ошибка: кассир не установлен';
    127: Result := 'ошибка задания признака агента';
    128: Result := 'ошибка: документ в электронной форме не сформирован';
    129: Result := 'ошибка: превышено максимальное количество предметов с кодом товарной номенклатуры';
    130: Result := 'ошибка: попытка повторного задания уникального параметра';
    131: Result := 'ошибка: не задан ИНН поставщика';
    132: Result := 'ошибка: попытка задания количества уникального товара';
    133: Result := 'ошибка: сбой принтера';
    134: Result := 'неудача при записи на флэш-память';
    135: Result := 'файл обновления не был загружен';
    136: Result := 'текущая версия ФФД ФН не поддерживает операцию';
    137: Result := 'текущая версия ФФД ФН не поддерживается';
    138: Result := 'ошибочная последовательность команд';
    139: Result := 'работа с подакцизными товарами запрещена';
    140: Result := 'позиции с маркированными товарами в чеках расхода запрещены';
    141: Result := 'сумма оплат видов безналичного расчета не равна размеру оплаты электронными';
    142: Result := 'размер округления не должен превышать 99 копеек';
    143: Result := 'сумма расчета по чеку в рублях не должна изменяться после округления';
    200: Result := 'у команды есть неправильно заданные операнды';
    201: Result := 'у команды есть не заданные операнды';
    202: Result := 'ошибка задания режимов работы';
    203: Result := 'ошибка задания расширенных режимов работы';
    204: Result := 'ошибка задания параметра с датой/временем';
    205: Result := 'ошибка задания параметра с ИНН';
    206: Result := 'ошибка задания параметра с битовой маской';
    207: Result := 'длина строки слишком большая';
    208: Result := 'некорректные данные';
    209: Result := 'команда допустима только при использовании внешнего клиента обмена';
    401: Result := 'неизвестная команда ФН';
    402: Result := 'некорректное состояние ФН';
    403: Result := 'отказ ФН';
    404: Result := 'отказ КС';
    405: Result := 'параметры команды не соответствуют сроку жизни ФН';
    407: Result := 'некорректная дата и/или время';
    408: Result := 'нет запрошенных данных';
    409: Result := 'некорректное значение параметров команды';
    410: Result := 'некорректная команда.';
    411: Result := 'неразрешенные реквизиты.';
    412: Result := 'дублирование данных';
    413: Result := 'отсутствуют данные, необходимые для корректного учета в ФН';
    414: Result := 'количество позиций в документе превысило допустимый предел';
    416: Result := 'превышение размеров TLV данных';
    417: Result := 'нет транспортного соединения';
    418: Result := 'исчерпан ресурс ФН';
    420: Result := 'ограничение ресурса ФН';
    422: Result := 'продолжительность смены превышена';
    423: Result := 'некорректные данные о промежутке времени между фискальными документами';
    424: Result := 'некорректный реквизит, переданный в ФН';
    425: Result := 'реквизит не соответствует установкам при регистрации';
    432: Result := 'сообщение ОФД не может быть принято';
    435: Result := 'ошибка сервиса обновления ключей проверки КМ';
    436: Result := 'неизвестный ответ сервиса обновления ключей проверки кодов проверки';
    448: Result := 'ошибка: требуется повтор процедуры обновления ключей проверки КМ';
    450: Result := 'запрещена работа с маркированным товарами';
    451: Result := 'неверная последовательность подачи команд для обработки маркированных товаров';
    452: Result := 'работа с маркированными товарами временно заблокирована';
    453: Result := 'переполнена таблица проверки кодов маркировки';
    454: Result := 'превышен период 90 дня со времени последнего обновления ключей проверки';
    460: Result := 'в блоке TLV отсутствуют необходимые реквизиты';
    462: Result := 'в реквизите 2007 содержится КМ, который ранее не проверялся в ФН';
    500: Result := 'нет бумаги в принтере';
    501: Result := 'крышка принтера открыта';
    502: Result := 'состояние принтера не рабочее (OFFLINE)';
    503: Result := 'сбой отрезчика';
    504: Result := 'есть другая ошибка принтера';
    505: Result := 'принтер выключен';
    506: Result := 'бумага заканчивается';
    509: Result := 'принтер занят, идет печать';
    510: Result := 'печатная форма документа не была завершена (сбой принтера)';
    511: Result := 'нажата кнопка прогона бумаги';
    600: Result := 'ошибка RTC при выдаче команды "Прочитать дату/время"';
    601: Result := 'ошибка RTC при выдаче команды "Установить дату/время"';
    602: Result := 'новые дата и время меньше даты и времени последнего оформленного фискального документа';
    604: Result := 'ошибка: не удалось связаться с сервером ОИСМ';
    605: Result := 'ошибка: получен пустой ответ от ОИСМ';
    606: Result := 'ошибка: не удалось связаться с сервером ОКП';
    607: Result := 'ошибка: получен пустой ответ от ОКП';
    608: Result := 'общая ошибка работы с ОКП';
  else
    Result := 'неизвестная ошибка';
  end;
  Result := Format('%d, %s', [Code, Result]);
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
  //FPort := CreatePort;
end;

destructor TMitsuDrv.Destroy;
begin
  FPort := nil;
  FLogger := nil;
  inherited Destroy;
end;

procedure TMitsuDrv.Connect;
begin

end;

procedure TMitsuDrv.Disconnect;
begin

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
      SerialParams.ByteTimeout := 1000;
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

function TMitsuDrv.Send(const Command: AnsiString; var Answer: AnsiString): Integer;
var
  B: Char;
  CRC: Char;
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
    if B = ETX then Break;
  until False;
  CRC := Port.Read(1)[1];
  if Ord(CRC) <> Ord(GetCRC(Answer)) then
    raise Exception.Create('Invalid CRC');
  Answer := Copy(Answer, 1, Length(Answer)-1);
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
  Node: IXMLNode;
begin
  Result := '';
  Node := FAnswerDoc.documentElement.AttributeNodes.FindNode(Attribute);
  if Node <> nil then
  begin
    if not VarIsNull(Node.NodeValue) then
      Result := Node.NodeValue;
  end;
end;

function TMitsuDrv.HasAttribute(const Attribute: AnsiString): Boolean;
begin
  Result := FAnswerDoc.documentElement.AttributeNodes.FindNode(Attribute) <> nil;
end;

function TMitsuDrv.GetChildAttribute(const Child, Attribute: AnsiString): AnsiString;
var
  Node: IXMLNode;
begin
  Result := '';
  Node := FAnswerDoc.documentElement.ChildNodes[Child];
  if Node <> nil then
  begin
    if Node.HasAttribute(Attribute) then
      Result := Node.Attributes[Attribute];
  end;
end;

function TMitsuDrv.GetChildText(const Child: AnsiString): AnsiString;
var
  Node: IXMLNode;
begin
  Result := '';
  Node := FAnswerDoc.documentElement.ChildNodes[Child];
  if Node <> nil then
  begin
    Result := Node.Text;
  end;
end;

function TMitsuDrv.GetIntAttribute(const Attribute: AnsiString): Integer;
begin
  Result := StrToIntDef(GetAttribute(Attribute), 0);
end;

function TMitsuDrv.GetIntAttribute3(const Attribute: AnsiString; N: Integer): Integer;
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
function TMitsuDrv.GetDateAttribute(const Attribute: AnsiString): TMTSDate;
var
  S: AnsiString;
begin
  S := GetAttribute(Attribute);
  Result.Year := StrToInt(Copy(S, 1, 4));
  Result.Month := StrToInt(Copy(S, 6, 2));
  Result.Day := StrToInt(Copy(S, 8, 2));
end;

// TIME='00:00'
function TMitsuDrv.GetTimeAttribute(const Attribute: AnsiString): TMTSTime;
var
  S: AnsiString;
begin
  S := GetAttribute(Attribute);
  Result.Hour := StrToInt(Copy(S, 1, 2));
  Result.Min := StrToInt(Copy(S, 4, 2));
end;

///////////////////////////////////////////////////////////////////////////////
// 3.3. Наименование модели
// Формат: <GET DEV='?' /> или <GET/>
// Ответ: <OK DEV='MITSU-1-F' />
///////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadDeviceName(var DeviceName: WideString): Integer;
begin
  Result := GetRequest('DEV="?"');
  if Succeeded(Result) then
  begin
    DeviceName := GetAttribute('DEV');
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// 3.4. Сведения о модели
// Формат: <GET VER='?' />
// Ответ: <OK VER='версия' SIZE='размер' CRC32='контрольное число' SERIAL='заводской номер'
// MAC='mac-адрес' STS='статус'/>
// Пример: <OK VER='1.1.06' SIZE='295771' CRC32='7E714C76' SERIAL='065001234567890'
// MAC='00-22-00-48-00-51' STS='00000000'/>
///////////////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadDateTime(var R: TMTSDateTime): Integer;
begin
  Result := GetRequest('DATE=''?'' TIME=''?''');
  if Succeeded(Result) then
  begin
    R.Date := GetDateAttribute('DATE');
    R.Time := GetTimeAttribute('TIME');
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// 3.6. Кассир
// Формат: <GET CASHIER='?' />
// Ответ: <OK CASHIER='идентификатор' INN='инн' />
// Пример: <OK CASHIER=’Апполинарий Полуэктович' INN='771901532574' />
///////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadCashier(var R: TMTSCashier): Integer;
begin
  Result := GetRequest('CASHIER=''?''');
  if Succeeded(Result) then
  begin
    R.Name := GetAttribute('CASHIER');
    R.INN := GetAttribute('INN');
  end;
end;

///////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////////
// 3.8. Денежный ящик
// Формат: <GET CD='?' />
// Ответ: <OK CD='контакт' RISE='фронт' FALL='спад' />
// Пример: <OK CD:PIN='5' RISE='110' FALL='110' />
// • PIN – номер контакта в разъеме подключения соленоида денежного ящика.
// • RISE – время нарастания импульса открывания в миллисекундах.
// • FALL – время спада импульса в миллисекундах.
///////////////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////////
// 3.9. Скорость СОМ порта
// Формат: <GET COM='?' />
// Ответ: <OK COM='скорость' />
// Пример: <OK COM='115200' />///////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadBaudRate(var BaudRate: Integer): Integer;
begin
  Result := GetRequest('COM=''?''');
  if Succeeded(Result) then
  begin
    BaudRate := GetIntAttribute('COM');
  end;
end;

///////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////////
// 3.11. Сетевые параметры
// Формат: <GET LAN='?'/>
// Ответ: <OK ADDR='IP-адрес кассы'
// PORT='порт'
// MASK='маска подсети'
// DNS='адрес сервера доменных имен'
// GW='IP-адрес шлюза' />
// Пример: <OKADDR='192.168.1.101' PORT='8200' MASK='255.255.255.0' DNS='8.8.8.8'GW='192.168.1.1'/>
///////////////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////////
// 3.13. Сетевые параметры ОИСМ
// Формат: <GET OISM='?' />
// Ответ: <OK ADDR='IP/URL сервера ОИСМ' PORT='порт' />
// Пример: <OK ADDR='f1test.taxcom.ru' PORT='7903' />
///////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadOISMParams(var R: TMTSOISMParams): Integer;
begin
  Result := GetRequest('OISM=''?''');
  if Succeeded(Result) then
  begin
    R.Address := GetAttribute('OISM');
    R.Port := GetIntAttribute('PORT');
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// 3.14. Сетевые параметры ОКП
// Формат: <GET OKP='?' />
// Ответ: <OK OKP='IP/URL сервера ОКП' PORT='порт' />
// Пример: <OK OKP='prod01.okp-fn.ru' PORT='26101' />
///////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadOKPParams(var R: TMTSOKPParams): Integer;
begin
  Result := GetRequest('OKP=''?''');
  if Succeeded(Result) then
  begin
    R.Address := GetAttribute('OKP');
    R.Port := GetIntAttribute('PORT');
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// 3.15. Налоговые ставки
// Формат: <GET TAX='?' />
// Ответ: <OK TAX='T1:20%, T2:10%, T3:20/120, T4:10/110, T5:0%, T6:БЕЗ НДС' />
///////////////////////////////////////////////////////////////////////////////

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

(******************************************************************************
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
******************************************************************************)

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
    R.Date := GetDateAttribute('DATE');
    R.Time := GetTimeAttribute('TIME');
    R.Base := GetAttribute('BASE');

    Mode := GetIntAttribute('MODE');
    R.IsEncrypted := TestBit(Mode, 0);
    R.IsOffline := TestBit(Mode, 1);
    R.IsAutomatic := TestBit(Mode, 2);
    R.IsService := TestBit(Mode, 3);
    R.IsBlank := TestBit(Mode, 4);
    R.IsInternet := TestBit(Mode, 5);
    R.IsCatering := TestBit(Mode, 6);
    R.IsWholesale := TestBit(Mode, 7);

    R.ExtMode := GetIntAttribute('ExtMODE');
    R.IsExcisable := TestBit(R.ExtMode, 0);
    R.IsGambling := TestBit(R.ExtMode, 1);
    R.IsLottery := TestBit(R.ExtMode, 2);
    R.IsAutomat := TestBit(R.ExtMode, 3);
    R.IsMarking := TestBit(R.ExtMode, 4);
    R.IsPawnshop := TestBit(R.ExtMode, 5);
    R.IsInsurance := TestBit(R.ExtMode, 6);
    R.IsVendingMachine := TestBit(R.ExtMode, 7);

    R.SerialNumber := GetAttribute('T1013');
    R.DeviceVersion := GetAttribute('T1188');
    R.T1189 := GetAttribute('T1189');
    R.T1190 := GetAttribute('T1190');
    R.T1209 := GetAttribute('T1209');
    R.T1037 := GetAttribute('T1037');
    R.T1018 := GetAttribute('T1018');
    R.T1017 := GetAttribute('T1017');
    R.T1036 := GetAttribute('T1036');
    R.T1062 := GetAttribute('T1062');
    R.T1041 := GetAttribute('T1041');

    R.T1048 := GetChildText('T1048');
    R.SaleAddress := GetChildText('T1009');
    R.T1187 := GetChildText('T1187');
    R.T1046 := GetChildText('T1046');
    R.T1117 := GetChildText('T1117');
    R.T1060 := GetChildText('T1060');
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

function TMitsuDrv.ReadDayTotals(RequestType: Integer; var R: TMTSDayTotals): Integer;

  function NodeToTotals(Node: IXMLNode; N: Integer): TMTSTotals;
  begin
    Result.Count := GetIntAttribute2(Node, 'COUNT', N);
    if Result.Count > 0 then
    begin
      Result.Total := GetIntAttribute2(Node, 'TOTAL', N);
      Result.T1136 := GetAttribute2(Node, 'T1136', N);
      Result.T1138 := GetAttribute2(Node, 'T1138', N);
      Result.T1218 := GetAttribute2(Node, 'T1218', N);
      Result.T1219 := GetAttribute2(Node, 'T1219', N);
      Result.T1220 := GetAttribute2(Node, 'T1220', N);
      Result.T1139 := GetAttribute2(Node, 'T1139', N);
      Result.T1140 := GetAttribute2(Node, 'T1140', N);
      Result.T1141 := GetAttribute2(Node, 'T1141', N);
      Result.T1142 := GetAttribute2(Node, 'T1142', N);
      Result.T1143 := GetAttribute2(Node, 'T1143', N);
      Result.T1183 := GetAttribute2(Node, 'T1183', N);
    end;
  end;

var
  Node: IXMLNode;
begin
  Result := GetRequest(Format('INFO=''%d''', [RequestType]));
  if Succeeded(Result) then
  begin
    R.DayNumber := GetIntAttribute('SHIFT');
    Node := FAnswerDoc.documentElement.ChildNodes['INCOME'];
    R.Sale := NodeToTotals(Node, 1);
    R.RetSale := NodeToTotals(Node, 2);

    Node := FAnswerDoc.documentElement.ChildNodes['PAYOUT'];
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
    R.Valid := GetDateAttribute('VALID');
    R.LastDoc := GetIntAttribute('LAST');
    R.DocDate := GetDateAttribute('DATE');
    R.DocTime := GetTimeAttribute('TIME');
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
    R.FirstDate := GetDateAttribute('DATE');
    R.FirstTime := GetTimeAttribute('TIME');
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
    R.FirstDate := GetDateAttribute('DATE');
    R.FirstTime := GetTimeAttribute('TIME');
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
    R.Date := GetDateAttribute('DATE');
    R.Time := GetTimeAttribute('TIME');
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
  Result := GetRequest('DOC=''0''');
  if Succeeded(Result) then
  begin
    if HasAttribute('FD') then
      R.DocNumber := GetIntAttribute('FD')
    else
      R.DocNumber := GetIntAttribute('TXT');
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

function TMitsuDrv.ReadFDData(Offset, Length: Integer; var Data: AnsiString): Integer;
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
  if Failed(Result) then Exit;

  if R.Size > 0 then
  begin
    Count := (R.Size + BlockSize-1) div BlockSize;
    for i := 0 to Count-1 do
    begin
      Result := ReadFDData(R.Offset, Min(R.Size, BlockSize), BlockData);
      if Failed(Result) then Exit;

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
  Command := Format('<SET DATE=''%s'' TIME=''%s''/>', [MTSDateToStr(Date), MTSTimeToStr(Date)]);
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
  Command := Format('<SET CASHIER=''%s'' INN=''%s''/>', [Cashier.Name, Cashier.INN]);
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

//Формат: <REG BASE=’0’ ATTR='данные'… ><TAG>данные</TAG>…</REG>
//Ответ: <OK FD='номер фискального документа' FP='фискальный признак'/>

function TMitsuDrv.FNOpen(const Params: TFNParams): Integer;
var
  Node: IXMLNode;
  Xml: IXMLDocument;
  Command: AnsiString;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('REG', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('BASE', 0);
  Node.SetAttribute('MARK', BoolToStr[Params.IsMarking]);
  Node.SetAttribute('PAWN', BoolToStr[Params.IsPawnshop]);
  Node.SetAttribute('INS', BoolToStr[Params.IsInsurance]);
  Node.SetAttribute('DINE', BoolToStr[Params.IsCatering]);
  Node.SetAttribute('OPT', BoolToStr[Params.IsWholesaleTrade]);
  Node.SetAttribute('VEND', BoolToStr[Params.IsVendingMachine]);
  Node.SetAttribute('T1001', BoolToStr[Params.IsAutomaticMode]);
  Node.SetAttribute('T1002', BoolToStr[Params.IsOffline]);
  Node.SetAttribute('T1056', BoolToStr[Params.IsEncrypted]);
  Node.SetAttribute('T1062', Params.TaxationSystems);
  Node.SetAttribute('T1108', BoolToStr[Params.IsOnline]);
  Node.SetAttribute('T1109', BoolToStr[Params.IsService]);
  Node.SetAttribute('T1110', BoolToStr[Params.IsBlank]);
  Node.SetAttribute('T1126', BoolToStr[Params.IsLottery]);
  Node.SetAttribute('T1193', BoolToStr[Params.IsGambling]);
  Node.SetAttribute('T1207', BoolToStr[Params.IsExcisable]);
  Node.SetAttribute('T1221', BoolToStr[Params.IsAutomat]);
  Node.AddChild('T1009', )


(*
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

  Result := Send(Format('<SET COM=''%d''/>', [BaudRate]));
*)
end;

end.


