unit MitsuDrv;

interface

uses
  // VCL
  Windows, Classes, SysUtils, ActiveX, Variants, XMLDoc, MSXML, XMLIntf,
  Math,
  // This
  PrinterPort, SerialPort, SocketPort, LogFile, StringUtils, DriverError,
  ByteUtils;

type
  TBaudRates = array [0..8] of Integer;
  TConnectionTypes = array[0..1] of Integer;

const
  /////////////////////////////////////////////////////////////////////////////
  // VAT rate constants

  MTS_VAT_RATE_20       = 1; // 1 ������ ��� 20%
  MTS_VAT_RATE_10       = 2; // 2 ������ ��� 10%
  MTS_VAT_RATE_20_120   = 3; // 3 ������ ��� ����. 20/120
  MTS_VAT_RATE_10_110   = 4; // 4 ������ ��� ����. 10/110
  MTS_VAT_RATE_0        = 5; // 5 ������ ��� 0%
  MTS_VAT_RATE_NONE     = 6; // 6 ��� �� ����������

  /////////////////////////////////////////////////////////////////////////////
  // Document type constants

  MTS_DOC_TYPE_NONFISCAL    = 0; // 0 � ������������ ��������
  MTS_DOC_TYPE_REG_REPORT   = 1; // 1 � ����� � �����������
  MTS_DOC_TYPE_DAY_OPEN     = 2; // 2 � ����� �� �������� �����
  MTS_DOC_TYPE_RECEIPT      = 3; // 3 � �������� ���
  MTS_DOC_TYPE_BLANK        = 4; // 4 � ����� ������� ���������� (���)
  MTS_DOC_TYPE_DAY_CLOSE    = 5; // 5 � ����� � �������� �����
  MTS_DOC_TYPE_FD_CLOSE     = 6; // 6 � ����� � �������� ��
  MTS_DOC_TYPE_OPERATOR     = 7; // 7 � ������������� ���������
  MTS_DOC_TYPE_REREG_REPORT = 11; // 11 � ����� � (����) �����������
  MTS_DOC_TYPE_PAYMENTS     = 21; // 21 � ����� � ������� ��������� ��������
  MTS_DOC_TYPE_RECEIPT_CORRECTION = 31; // 31 � �������� ��� ���������
  MTS_DOC_TYPE_BLANK_CORRECTION   = 41; // 41 � ��� ���������

  /////////////////////////////////////////////////////////////////////////////
  // Document status constants

  MTS_DOC_STATUS_OPENED  = 1;
  MTS_DOC_STATUS_CLOSED  = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Receipt type constants

  MTS_RT_SALE     = 1;
  MTS_RT_RETSALE  = 2;
  MTS_RT_BUY      = 3;
  MTS_RT_RETBUY   = 4;

  /////////////////////////////////////////////////////////////////////////////
  // Tax system type constants

  MTS_TS_GENERAL   = 0;
  MTS_TS_SIMPLIFIED_PROFIT  = 1; // ���������� ����� (��� �����)
  MTS_TS_SIMPLIFIED         = 2; // ���������� ����� ����� ������ (��� �����-������)
  MTS_TS_AGRICULTURAL       = 4; // ������ �������������������� ����� (����)
  MTS_TS_PATENT             = 5; // ��������� ������� ���������������.

  /////////////////////////////////////////////////////////////////////////////
  // Options constants

  // b0 �������������� ����� � ���� ��� ---- ��� === ������� � 0
  MTS_OP_RECEIPT_SEPARATOR        = 0;

  // b1 QR ��� � �������� ���� ����� �� ������ ������ � 0
  MTS_OP_RECEIPT_QRCODE_ALIGNMENT = 1;

  // b2 ���������� ����� ���� ��� �� 0,10 �� 0,50 �� 1,00 0
  MTS_OP_RECEIPT_TOTAL_ROUNDING = 2;

  // b3 ����-����� ��� ������� � � 1
  MTS_OP_AUTO_CUTTER = 3;

  // b4 ����-���� ��� ��������� ����� �� �����. �������� � � 1
  MTS_OP_PRINT_TEST_ON_START = 4;

  // b5 ������� �������� ���� ��� ������ �� ����. ���. �/� ���. � �/� 1
  MTS_OP_OPEN_CASH_DRAWER = 5;

  // b6 �������� ������ ������� ����� ������ ����. ������� � � 0
  MTS_OP_BEEP_ON_PAPER_NEAR_END = 6;

  // b7 ���������� ��������� ������ � QR ����� ��� ���������� � � 0
  MTS_OP_COMBINE_TEXT_QRCODE = 7;

  // b8 �������� ���������� ������� � ���� ��� �������� � � 0
  MTS_OP_PRINT_ITEM_COUNT = 8;


  /////////////////////////////////////////////////////////////////////////////
  // Day status constants

  MTS_DAY_STATUS_CLOSED   = 0; // Day is closed
  MTS_DAY_STATUS_OPENED   = 1; // Day is opened
  MTS_DAY_STATUS_EXPIRED  = 9; // Day is expired (24 hours left)

  /////////////////////////////////////////////////////////////////////////////
  //

  STX = #02;
  ETX = #03;

  /////////////////////////////////////////////////////////////////////////////
  // ConnectionType constants

  ConnectionTypeSerial   = 0;
  ConnectionTypeSocket   = 1;

  ConnectionTypes: TConnectiontypes = (
    ConnectionTypeSerial,
    ConnectionTypeSocket);

  BaudRates: TBaudRates = (
    CBR_2400, CBR_4800, CBR_9600, CBR_14400, CBR_19200,
    CBR_38400, CBR_56000, CBR_57600, CBR_115200);


  /////////////////////////////////////////////////////////////////////////////
  // Notification status constants

  MTS_NS_NO_ACTIVE_TRANSFER = 0; // ��� ��������� ������
  MTS_NS_READ_STARTED       = 1; // ������ ������ �����������;
  MTS_NS_WAIT_FOR_TICKET    = 2; // ������ ������ �����������;

  /////////////////////////////////////////////////////////////////////////////
  // Document type constants

  MTS_DT_NONFISCAL        = 0; // ������������ ��������
  MTS_DT_REG_REPORT       = 1; // ����� � �����������
  MTS_DT_DAY_OPEN         = 2; // ����� �� �������� �����
  MTS_DT_RECEIPT          = 3; // �������� ���
  MTS_DT_BLANK            = 4; // ����� ������� ���������� (���);
  MTS_DT_DAY_CLOSE        = 5; // ����� � �������� �����
  MTS_DT_FD_CLOSE         = 6; // ����� � �������� ��
  MTS_DT_CASHIER_CONF     = 7; // ������������� ���������
  MTS_DT_REREG_REPORT     = 11; // ����� � (����) �����������
  MTS_DT_CALC_REPORT      = 21; // ����� � ������� ��������� ��������
  MTS_DT_CORRECTION_REC   = 31; // �������� ��� ���������
  MTS_DT_CORRECTION_BSO   = 41; // ��� ���������

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

  { TFNParams }

  TFNParams = record
    Base: Integer;
    IsMarking: Boolean; // ������� ������ � �������������� ��������
    IsPawnshop: Boolean; // ������� ������������� ���������� ������������
    IsInsurance: Boolean; // ������� ������������� ��������� ������������
    IsCatering: Boolean; // ������� ������������� �������� ����� ������������� �������
    IsWholesale: Boolean; // ������� ���������� � ������� �������� � ������������� � ��
    IsAutomaticPrinter: Boolean; // ������� ���������� � �������������� �����������
    IsAutomatic: Boolean; // ������� ��������������� ������
    IsOffline: Boolean; // ������� ����������� ������
    IsEncrypted: Boolean; // ������� ����������
    IsOnline: Boolean;  // ������� ��� ��� �������� � ��������
    IsService: Boolean; // ������� �������� �� ������
    IsBlank: Boolean; // ������� ������ ���
    IsLottery: Boolean; // ������� ���������� �������
    IsGambling: Boolean; // ������� ���������� �������� ���
    IsExcisable: Boolean; // ������� ������������ ������
    IsVendingMachine: Boolean; // ������� ���������� � �������������� �������� ��������

    SaleAddress: WideString; // ����� ���������� ��������
    SaleLocation: WideString; // ����� ���������� ��������
    OFDCompany: WideString; // �������� ����������� ���
    OFDCompanyINN: WideString; // ��� ����������� ���
    FNSURL: WideString; // ����� ����� ��������������� ������ (���) � ���� ���������
    CompanyName: WideString; // �������� �����������
    CompanyINN: WideString; // ��� �����������
    SenderEmail: WideString; // ����� ����������� ����� ����������� ����
    AutomaticNumber: WideString; // ����� �������� ��� ��������������� ������
    ExtendedProperty: WideString; // �������������� �������� ��
    ExtendedData: WideString; // �������������� ������ ��
    TaxSystems: AnsiString;
    RegNumber: WideString; // ��������������� ����� ���
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
    MCStatus: Integer; // ��������� �� �������� ��
    MCCount: Integer; // ���������� ���������� ����������� �������� ��
    MCFlags: Integer; // ���� ���������� ������ ������ � �� (�����)
    MCNStatus: Integer; // ��������� ����������� � ���������� �������������� ������
    MCNCount: Integer; // ���������� ��, ���������� � �����������
    NCount: Integer; // ���������� ����������� � �������
    FillStatus: Integer; // ��������� ���������� ������� �������� �����������
  end;

  { TOISMStatus }

  TOISMStatus = record
    Status: Integer;      // ��������� �� �������� �����������
    QueueCount: Integer;  // ���������� ����������� � �������
    FirstNumber: Integer; // ����� ������� ����������������� �����������
    FirstDate: TDateTime;  // ���� � ����� ������� ����������������� �����������
    FillPercent: Integer; // ������� ���������� ������� �������� �����������
  end;

  { TKeysStatus }

  TKeysStatus = record
    ExtClient: Boolean; // ������� ������ ����� ������� ������ ������
    UpdateNeeded: Boolean; // ������� ������������� ���������� ������
    CapD7Command: Boolean; // ������� ��������� �� ���������� ������� D7
    OkpURL: AnsiString; // ����� � ���� ���
    DateTime: TDateTime; // ���� � ����� ���������� ���������� ������ �������� ��
  end;

  { TDocStatus }

  TDocStatus = record
    Number: Integer; // ���������� ����� ����������� ���������
    DocType: Integer;  // ��� ���������
    Status: Integer; // ��������� ���������
    Size: Integer; // ������ ��������� ���������
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

  { TMTSDayParams }

  TMTSDayParams = record
    SaleAddress: WideString; // ����� ���������� ��������
    SaleLocation: WideString; // ����� ���������� ��������
    ExtendedProperty: WideString; // �������������� �������� ��
    ExtendedData: WideString; // �������������� ������ ��
    PrintRequired: Boolean;
  end;

  { TMTSReceiptParams }

  TMTSReceiptParams = record
    ReceiptType: Integer; // ��� ����
    TaxSystem: Integer; // ������� ���������������
    SaleAddress: WideString; // ����� ���������� ��������
    SaleLocation: WideString; // ����� ���������� ��������
    AutomaticNumber: WideString; // ����� �������� ��� ��������������� ������
    SenderEmail: WideString; // ����� ����������� ����� ����������� ����
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
    CountryCode: Integer;
    DeclarationNumber: Integer;
    Name: WideString;
    Numerator: Integer;
    Denominator: Integer;
    MarkCode: AnsiString;
    AddAttribute: AnsiString;
    AgentType: Integer;
    //Agent;
    //Supplier;
    //IndustryAttribute;
    SupplierINN: AnsiString;
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
    function Send(const Command: AnsiString; var Answer: AnsiString): Integer; overload;

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

    function BeginFiscalReceipt(const Params: TMTSReceiptParams): Integer;
    function CancelFiscalReceipt: Integer;
    function BeginPositions: Integer;
    function AddPosition(const P: TMTSPosition): Integer;


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
    0: Result := 'COM ����';
    1: Result := 'TCP �����������';
  else
    Result := '����������';
  end
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
    0: Result := '��� ������';
    1: Result := '����������� ��������';
    2: Result := '������������ ������ ��� ���������� ��������';
    3: Result := '�������� �� ������';
    4: Result := '�� ������ ��������� �������� ������ �������� ��';
    5: Result := '�� ������ ��������� ��� ����������� �������� ��';
    6: Result := '�� ������ ��������� �������� ���������� �������� ��';
    7: Result := '�������� ������������ ������ ������ ��� ������� ��';
    8: Result := '���������� ������ �� (�� ����� �������� � �������������� ������)';
    10: Result := '������ ��������� ��������� �� ����� (����-)������������';
    11: Result := '������ �� ��� ��������� �������';
    12: Result := '������ �� ��� ������ ������� "������ ����� � �����������"';
    13: Result := '������ �� ��� ������ ������� "�������� ������ ���������"';
    14: Result := '������ �� ��� ������ ������� "������������ ����� � ����������� (���������������)"';
    15: Result := '������ �� ��� ������ ������� "������ �������� ����������� ������ ��"';
    16: Result := '������ �� ��� ������ ������� "������� ���������� ����� ��"';
    17: Result := '������ ��� ������� ������� ��';
    18: Result := '������ �� ��� ������ ������� "������ ������������ ������ � ������� ��������� ��������"';
    19: Result := '������ �� ��� ������ ������� "������������ ����� � ������� ��������� ��������"';
    20: Result := '������ ��: ����� �������';
    21: Result := '������ ��: ����� �������';
    22: Result := '������ ��: ������� ���������� ��������';
    23: Result := '������ �� ��� ������ ������� "������ ���������� ��, �� ������� ��� ���������"';
    24: Result := '������ �� ��� ������ ������� "������ ����� �������� ��"';
    25: Result := '������ �� ��� ������ ������� "������ ������ ������������ ��"';
    26: Result := '������ ��: ���� ���������������� � ��� ���������';
    27: Result := '������ �� ��� ������ ������� "������ �������� �����"';
    28: Result := '������ �� ��� ������ ������� "������� �����"';
    29: Result := '������ �� ��� ������ ������� "������ �������� �����"';
    30: Result := '������ �� ��� ������ ������� "������� �����"';
    31: Result := '������ �� ��� ������ ������� "������ ������������ ���� (���)"';
    32: Result := '������ ����������� ����: ��� ��� ���';
    33: Result := '������ ��: ��� (���) �� ������';
    34: Result := '������ �������������� ������';
    35: Result := '������ �� ��� ������ ������� "������������ ���"';
    36: Result := '������ �� ��� ������ ������� "�������� ������� ��������"';
    37: Result := '������: ���������� �������� �����������';
    38: Result := '������: ����� ����� �������';
    39: Result := '������: ��� ��������� (��� ���������) �� ������';
    40: Result := '������ �� ��� ��������� ���������';
    41: Result := '������ �� ��� ��������� ��������� �����';
    42: Result := '������: ��� ������ (��� ��������� �������)';
    43: Result := '������: ������ ������������ ���� �� ������������� ��������';
    44: Result := '������ �� ��� ������ ������� "������ ������ � ���� ������ �� ��"';
    45: Result := '������: ����� ���������� ������ �� ��� ���������� ��������';
    46: Result := '������ �� ��� ������ ������� "����� ��"';
    47: Result := '������ �� ��� ��������� ������� ��������������� ������ � ���';
    48: Result := '������ ��: ������ ��������� ��� ��� ��� ������';
    49: Result := '������ ��: ��� ��������� ��� ���';
    50: Result := '������ �� ��� ������ ������� "�������� ������ ������������� ���������� � �������� ���"';
    51: Result := '������ �� ��� ������ ������� "������ ������ ��������� ��� ������� ���"';
    52: Result := '������ ��: ������ ��������� ��� ��� ��� �� ������';
    53: Result := '������ �� ��� ������ ������� "�������� ������ ��������� ��� ������� ���"';
    54: Result := '������ �� ��� ������ ������� "��������� ���� ��������� ��� ������� ���"';
    55: Result := '������ ��: ��� ���������� � �������� ��������� �� ���';
    56: Result := '������ �� ��� ������ ������� "�������� ��������� �� ������� ���"';
    57: Result := '������ ��: �������� ���������� �������';
    58: Result := '������ ��: �������� ������ ���������';
    59: Result := '������ ��: �������� ����� ��';
    60: Result := '������ ��: �������� ����� ��';
    61: Result := '������ ��: �������� CRC';
    62: Result := '������ �� ��� ������ ������� "������ ����������� ��������� � TLV �������"';
    63: Result := '������ �� ��� ������ ������� "������ TLV ����������� ���������"';
    64: Result := '������ ��: ����������� ����������� ������ ��������� � ������';
    65: Result := '������ ��: ����������� �� ������ �������� �� �������� �����';
    66: Result := '������ �� ��� ������ ������� "������ ������ ������� ������ ���������� �������� 07h"';
    67: Result := '������ �� ��� ������ ������� "������ ������� ��"';
    68: Result := '������ ��: �������� ��������� ������ �� ��';
    69: Result := '������ ��: �� �� ����� ��� �����������';
    70: Result := '������ ��: ��������� ����� �������� ������ �� ��';
    71: Result := '������ ��: �� ������� �������� ������ �� �������� ���� ����������';
    72: Result := '������ ��: �������� �� �������������� � ���������� ������';
    73: Result := '������ ��: ������ ����������� ��� ������';
    74: Result := '������ ��: ��� ����������� ��� ��������';
    75: Result := '������ �� ��� ������ ������� "������ ������ �����������"';
    76: Result := '������ ��: ������ ����������� ��� �� ������';
    77: Result := '������ ��: ��� ���������� � �������� ��������� �� ������������';
    78: Result := '������ ��: �������� ����� �����������';
    79: Result := '������ ��: �������� ����� ������';
    80: Result := '�������� �������������� ������ � ���������� ������';
    81: Result := '������ �� ���������� ������ �������� �� �� ��� �����������';
    82: Result := '������ ��: �������� ����� ������� � ������';
    83: Result := '������ ��: ��� ���������� ������� ���������� �������� ����� �������� ����� ����������';
    84: Result := '���������� ��������� �����������';
    94: Result := '������� ������ �������';
    95: Result := '���������� ������ ������';
    96: Result := '� ������� ������ ����������� ���������';
    97: Result := '� ������� ����������� ������������ ���������';
    98: Result := '������� �������� ���������, � �� �� ������ ����';
    99: Result := '�������� ������ ������� ��� ����������� �������';
    100: Result := '������ ������� ������ ���';
    101: Result := '������ ������� ���������� ������';
    102: Result := '������ ������� ������';
    103: Result := '������ ������� ���������������� ������';
    104: Result := '������ ������� ���';
    105: Result := '������ ������� ��� ���';
    106: Result := '������ ������� ������� ���������������';
    107: Result := '������: �������� ������� ��������������� �� ��������������';
    108: Result := '������ ������� �������� �������';
    109: Result := '������ ������� �������� ������� �������';
    110: Result := '������ ������� �������� �������� �������';
    111: Result := '������ ������� ������������ �������� �������';
    112: Result := '������ ������� ������� ��������� �������� �������';
    113: Result := '������ ������� ���� �������� ������������ �������� �������';
    114: Result := '������ ������� ���������� ������ �������� �������';
    115: Result := '������ ������� ���� �� ������� �������� �������';
    116: Result := '������ ������� ��������� �������� �������';
    117: Result := '������ ������� ������ ��� �������� �������';
    118: Result := '������ ������� ������� ��� �� ������� �������� �������';
    119: Result := '������ ������� ������� ��� �������� �������';
    120: Result := '������: ������ ��������� �� �������� ���� �������� ����������� ���������� ��������';
    121: Result := '������: ������ ��������� �� ���� �������� ����� �����';
    122: Result := '������ ������� ���������� �������� �������� ����� � ������ ����';
    123: Result := '������: ������ ��������� �� ����� ������ ���� �������� ����������� ���������� ��������';
    124: Result := '������ ��������� �������� ������� �� ���������� �����';
    125: Result := '������: � ���� � ������� ������� ����� ���� ������ ���� ������� �������';
    126: Result := '������: ������ �� ����������';
    127: Result := '������ ������� �������� ������';
    128: Result := '������: �������� � ����������� ����� �� �����������';
    129: Result := '������: ��������� ������������ ���������� ��������� � ����� �������� ������������';
    130: Result := '������: ������� ���������� ������� ����������� ���������';
    131: Result := '������: �� ����� ��� ����������';
    132: Result := '������: ������� ������� ���������� ����������� ������';
    133: Result := '������: ���� ��������';
    134: Result := '������� ��� ������ �� ����-������';
    135: Result := '���� ���������� �� ��� ��������';
    136: Result := '������� ������ ��� �� �� ������������ ��������';
    137: Result := '������� ������ ��� �� �� ��������������';
    138: Result := '��������� ������������������ ������';
    139: Result := '������ � ������������ �������� ���������';
    140: Result := '������� � �������������� �������� � ����� ������� ���������';
    141: Result := '����� ����� ����� ������������ ������� �� ����� ������� ������ ������������';
    142: Result := '������ ���������� �� ������ ��������� 99 ������';
    143: Result := '����� ������� �� ���� � ������ �� ������ ���������� ����� ����������';
    200: Result := '� ������� ���� ����������� �������� ��������';
    201: Result := '� ������� ���� �� �������� ��������';
    202: Result := '������ ������� ������� ������';
    203: Result := '������ ������� ����������� ������� ������';
    204: Result := '������ ������� ��������� � �����/��������';
    205: Result := '������ ������� ��������� � ���';
    206: Result := '������ ������� ��������� � ������� ������';
    207: Result := '����� ������ ������� �������';
    208: Result := '������������ ������';
    209: Result := '������� ��������� ������ ��� ������������� �������� ������� ������';
    401: Result := '����������� ������� ��';
    402: Result := '������������ ��������� ��';
    403: Result := '����� ��';
    404: Result := '����� ��';
    405: Result := '��������� ������� �� ������������� ����� ����� ��';
    407: Result := '������������ ���� �/��� �����';
    408: Result := '��� ����������� ������';
    409: Result := '������������ �������� ���������� �������';
    410: Result := '������������ �������.';
    411: Result := '������������� ���������.';
    412: Result := '������������ ������';
    413: Result := '����������� ������, ����������� ��� ����������� ����� � ��';
    414: Result := '���������� ������� � ��������� ��������� ���������� ������';
    416: Result := '���������� �������� TLV ������';
    417: Result := '��� ������������� ����������';
    418: Result := '�������� ������ ��';
    420: Result := '����������� ������� ��';
    422: Result := '����������������� ����� ���������';
    423: Result := '������������ ������ � ���������� ������� ����� ����������� �����������';
    424: Result := '������������ ��������, ���������� � ��';
    425: Result := '�������� �� ������������� ���������� ��� �����������';
    432: Result := '��������� ��� �� ����� ���� �������';
    435: Result := '������ ������� ���������� ������ �������� ��';
    436: Result := '����������� ����� ������� ���������� ������ �������� ����� ��������';
    448: Result := '������: ��������� ������ ��������� ���������� ������ �������� ��';
    450: Result := '��������� ������ � ������������� ��������';
    451: Result := '�������� ������������������ ������ ������ ��� ��������� ������������� �������';
    452: Result := '������ � �������������� �������� �������� �������������';
    453: Result := '����������� ������� �������� ����� ����������';
    454: Result := '�������� ������ 90 ��� �� ������� ���������� ���������� ������ ��������';
    460: Result := '� ����� TLV ����������� ����������� ���������';
    462: Result := '� ��������� 2007 ���������� ��, ������� ����� �� ���������� � ��';
    500: Result := '��� ������ � ��������';
    501: Result := '������ �������� �������';
    502: Result := '��������� �������� �� ������� (OFFLINE)';
    503: Result := '���� ���������';
    504: Result := '���� ������ ������ ��������';
    505: Result := '������� ��������';
    506: Result := '������ �������������';
    509: Result := '������� �����, ���� ������';
    510: Result := '�������� ����� ��������� �� ���� ��������� (���� ��������)';
    511: Result := '������ ������ ������� ������';
    600: Result := '������ RTC ��� ������ ������� "��������� ����/�����"';
    601: Result := '������ RTC ��� ������ ������� "���������� ����/�����"';
    602: Result := '����� ���� � ����� ������ ���� � ������� ���������� ������������ ����������� ���������';
    604: Result := '������: �� ������� ��������� � �������� ����';
    605: Result := '������: ������� ������ ����� �� ����';
    606: Result := '������: �� ������� ��������� � �������� ���';
    607: Result := '������: ������� ������ ����� �� ���';
    608: Result := '����� ������ ������ � ���';
  else
    Result := '����������� ������';
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
  if Failed(Result) then Exit;

  case Doc.DocType of
    MTS_DOC_TYPE_RECEIPT,
    MTS_DOC_TYPE_BLANK,
    MTS_DOC_TYPE_RECEIPT_CORRECTION,
    MTS_DOC_TYPE_BLANK_CORRECTION:
    begin
      if Doc.Status = MTS_DOC_STATUS_OPENED then
      begin
        Result := CancelFiscalReceipt;
      end;
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
������� ������� ������: GET
������: <GET ATTR='X'/>
<GET ATTR1='X' ATTR2='Y'� />
���
���
<GET ATTR=X />
<GET ATTR1=X ATTR2=Y� />
�����: <OK ATTR='������'� />
���
<OK ATTR='������'�>
<TAG> ������ </TAG>
�
</ANS>
�������: <GET DATE= '?' /> ��� <GET DATE=? />
<GET DATE= '?' TIME='?' /> ��� <GET DATE=? TIME=? />
<GET SHIFT= '1' /> ��� <GET SHIFT=1 />
� � ������ ����� �������� ���� ������� ATTR ��� ���������, ������ �� ���������������� � �������
������, ���������� (���������) � ������.
��������, ���� � ����� ����� ����������� ����� ��������, ���������� ����������� DATE � TIME,
� ������ ������ (�������) � �� ������.
� �������� ��������� X (Y�) � ������� ������ ��� (���, ������) ������������� ����������.
� ���� ���������� ������ �� ����� ���������, �� � ������� � �������� �������� ��������� ����� ������ ����� ������, ��������, ���� '?'.
3.2. �������� ��������� � �������� GET
� ��� �������� �������� ������������ ������
3.3 DEV �?� ������������ ������
3.4 VER �?� �������� � ������ ������
3.5 DATE �?� ������� ����
3.5 TIME �?� ������� �����
3.6 CASHIER �?� ������
3.7 PRINTER �?� �������
3.8 CD �?� �������� ����
3.9 COM �?� �������� COM �����
3.10 HEADER �1�, �2�, �3�, �4� ����� � ������ (����� � ��������� � ����� ����)
3.11 LAN �?� ������� ��������� �����
3.12 OFD �?� ������� ��������� ���
3.13 OISM �?� ������� ��������� ����
3.14 OKP �?� ������� ��������� ���
3.15 TAX �?� ��������� ������
3.16 REG �?�
������
������� ��������������� ������
��������������� ������ �� ������ �����������.
3.17
INFO
�0� ��������� �����
3.18 �1� ����� ����� �� �������� ����� (���)
3.19 �2� ����� ����� �� ����� (���) ���������
3.20 �3� ����� �� �� �������� ����� (���)
3.21 �4� ����� �� �� ����� (���) ���������
3.22 �F' ��� �FN� ��������� ��
3.23 �O� ��� �OFD� ������ �� �������� ���������� � ���
3.24 �M� ��� �MRK� ������ �� ������ � ������ ����������
3.25 �N� ��� �NOT� ������ �� �������� �����������
3.26 �K� ��� �KEY� ������ �� ���������� ������ ��������
3.27
DOC
�?� ������ �������� �� (�����, ���, �������)
3.28 ������ ������ ��������� �� �� �� ������ (��, �υ)
3.29 �A:����� ������ ��������� �� ������ ��
3.30 �X:����� ������ ���������� ��������� � XML �������
3.32 POWER �?� ��������� ����� ���� �������
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
short 2 ����� ������� (��������
char[] �� 2040 ������� � ������ (XML-��
byte 1 03h (ETX)
byte 1 ����������� ���� (LRC)
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
function TMitsuDrv.GetDateAttribute(const Attribute: AnsiString): TDateTime;
var
  S: AnsiString;
  Year, Month, Day: Word;
begin
  S := GetAttribute(Attribute);
  Year := StrToInt(Copy(S, 1, 4));
  Month := StrToInt(Copy(S, 6, 2));
  Day := StrToInt(Copy(S, 8, 2));
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

///////////////////////////////////////////////////////////////////////////////
// 3.3. ������������ ������
// ������: <GET DEV='?' /> ��� <GET/>
// �����: <OK DEV='MITSU-1-F' />
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
// 3.4. �������� � ������
// ������: <GET VER='?' />
// �����: <OK VER='������' SIZE='������' CRC32='����������� �����' SERIAL='��������� �����'
// MAC='mac-�����' STS='������'/>
// ������: <OK VER='1.1.06' SIZE='295771' CRC32='7E714C76' SERIAL='065001234567890'
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
// 3.5. ���� � �����
// ������:
// ���
// ���
// <GET DATE='?' TIME='?' />
// <GET DATE='?' />
// <GET TIME='?' />
// �����: <OK DATE='����-��-��' TIME='��:��:��' />
// <OK DATE='����-��-��' />
// <OK TIME='��:��:��' />
// ������: <OK DATE='2023-02-06' TIME='08:32:18' />
///////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadDateTime(var R: TDateTime): Integer;
begin
  Result := GetRequest('DATE=''?'' TIME=''?''');
  if Succeeded(Result) then
  begin
    R := GetDateAttribute('DATE') + GetTimeAttribute('TIME');
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// 3.6. ������
// ������: <GET CASHIER='?' />
// �����: <OK CASHIER='�������������' INN='���' />
// ������: <OK CASHIER=������������ �����������' INN='771901532574' />
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
// 3.7. ��������� ��������
// ������: <GET PRINTER='?'/>
// �����: <OK PRINTER='������ ����������� ����������'
// BAUDRATE='�������� COM ����� ��������'
// PAPER='������ �����'
// FONT='��� ������'
// WIDTH='����� �������� �� �����������'
// LENGTH='����� �������� � ������' />
// ������: <OKPRINTER='2' BAUDRATE='115200' PAPER='80' FONT='0' WIDTH='576' LENGTH='48' />
// � PRINTER � ������ ����������� ����������:
// 2 � Mitsu TP80,�������� � ������ 48 (����� �) ��� 64 (����� �);
// � BAUDRATE � �������� COM ����� �������� �� 4800 �� 115200 ���/���;
// � PAPER � ������ ����� � �� (57 ��� 80);
// � FONT � ��� ������: 0 � ����� A (�����������), 1 � ����� B (������).
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
// 3.8. �������� ����
// ������: <GET CD='?' />
// �����: <OK CD='�������' RISE='�����' FALL='����' />
// ������: <OK CD:PIN='5' RISE='110' FALL='110' />
// � PIN � ����� �������� � ������� ����������� ��������� ��������� �����.
// � RISE � ����� ���������� �������� ���������� � �������������.
// � FALL � ����� ����� �������� � �������������.
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
// 3.9. �������� ��� �����
// ������: <GET COM='?' />
// �����: <OK COM='��������' />
// ������: <OK COM='115200' />///////////////////////////////////////////////////////////////////////////////

function TMitsuDrv.ReadBaudRate(var BaudRate: Integer): Integer;
begin
  Result := GetRequest('COM=''?''');
  if Succeeded(Result) then
  begin
    BaudRate := GetIntAttribute('COM');
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// 3.10. ����� � ������
// ������: <GET HEADER='n' />
// �����: <OK HEADER='n'>
// <L0 F='xxxxxx'> ����� </L0>
// . . . . . . . . . . . . . . . . . . . . . . . . . .
// </OK>
// ������: <OK HEADER='1'><L0 F='000011'> ����� ����������!!!</L0>
// <L1 F='000000'>����� 111-11-11 � 9 �� 20</L1></OK>
// 9
// � n = 1, 2, 3, 4 � ����� ����� (�������), � ������ � �� 10 �����.
// � L0 � L9 � ������ �����.
// � � ������ ���������� ������ ������������� (��������) ������ �����.
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
// 3.11. ������� ���������
// ������: <GET LAN='?'/>
// �����: <OK ADDR='IP-����� �����'
// PORT='����'
// MASK='����� �������'
// DNS='����� ������� �������� ����'
// GW='IP-����� �����' />
// ������: <OKADDR='192.168.1.101' PORT='8200' MASK='255.255.255.0' DNS='8.8.8.8'GW='192.168.1.1'/>
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
// 3.12. ������� ��������� ���
// ������: <GET OFD='?'/>
// �����: <OK OFD='IP/URL ������� ���'
// PORT='����'
// CLIENT='������ ������ � ���'
// TimerFN='������ ������ ��'
// TimerOFD='������ ������ ���' />
// ������: <OK ADDR='109.73.43.4' PORT='19086' CLIENT='1' TimerFN='60' TimerOFD='10' />
// � CLIENT: ���������� ������ ������ � ���:
// �1' � ����� ������� ������ (�������� �� ��� ������ �� POS ����������),
// �0' � �������� ���������� ������ KKT (��������� ������ � �������� ����� LAN).
// � TimerFN: �������� ������� �� �� ������� �������������� ����������.
// � TimerOFD: �������� (�������) ����� ��������� ��������� �������� � ���
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
// 3.13. ������� ��������� ����
// ������: <GET OISM='?' />
// �����: <OK ADDR='IP/URL ������� ����' PORT='����' />
// ������: <OK ADDR='f1test.taxcom.ru' PORT='7903' />
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
// 3.14. ������� ��������� ���
// ������: <GET OKP='?' />
// �����: <OK OKP='IP/URL ������� ���' PORT='����' />
// ������: <OK OKP='prod01.okp-fn.ru' PORT='26101' />
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
// 3.15. ��������� ������
// ������: <GET TAX='?' />
// �����: <OK TAX='T1:20%, T2:10%, T3:20/120, T4:10/110, T5:0%, T6:��� ���' />
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
  3.16. ��������������� ������
  ������: <GET REG='?'/>
  <GET REG='�����'/>
  �����: <OK REG='���������� ����� ����������� (����-�����������)'
  FD='����� ����������� ���������'
  DATE='����-��-��' TIME='hh:mm'
  BASE='���� ������ ��������� �������� � �����������'
  T1013='��������� ����� �����'
  T1188='������ ������' T1189='������ ��� �����' T1190='������ ��� ��'
  T1209='����� ������ ���'
  T1037='��������������� �����'
  T1018='��� ������������'
  T1017='��� ���'
  T1036='����� ��������'
  T1062='������� ���������������'
  MODE=������ ������� ������'
  ExtMODE='����� ����������� ������� ������'10
  T1041='��������� ����� ��' >
  <T1048> ������������ ������������ </T1048>
  <T1009> ����� �������� </T1009>
  <T1187> ����� �������� </T1187>
  <T1046> ������������ ��� </T1046>
  <T1117> ����� ����������� ����� ����������� ����� </T1117>
  <T1060> ����� ����� ��� </T1060>
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
3.17. ��������� �����
������: <GET INFO='0' />, ��� �0� � ����� "����".
�����: <OK SHIFT=' ����� ����� '
STATE='��������� �����'
COUNT='���������� ����� �� �����'
KeyValid=����� �������� ������>
</OK>
������ <OK SHIFT='16' STATE='1' COUNT='7' KeyValid='445'></OK>
� SHIFT � ����� ������� ��������, ���� ��������� �������� �����.
� STATE � ��������� �����:
0 � ����� �������,
1 � ����� �������,
9 � ����� ������� (���������� 24 �����).
� KeyValid: ���������� ����, ���������� �� ��������� ����� �������� ������ �������� ����� ����������.
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
3.18. ����� ����� �� �������� ����� (���)
������: <GET INFO='1'/>
�����: <OK SHIFT='����� �����'>
<INCOME COUNT='������ | ������� �������'
TOTAL ='������ | ������� ������� '
T1136='������ | ������� ������� '
T1138='������ | ������� ������� '
T1218='������ | ������� ������� '
T1219='������ | ������� ������� '
T1220='������ | ������� ������� '
T1139='������ | ������� ������� '
T1140='������ | ������� ������� '
T1141='������ | ������� ������� '
T1142='������ | ������� ������� '
T1143='������ | ������� ������� '
T1183='������ | ������� ������� '/>
<PAYOUT COUNT='������ | ������� �������'
TOTAL ='������ | ������� ������� '
T1136='������ | ������� ������� '
T1138='������ | ������� ������� '
T1218='������ | ������� ������� '
T1219='������ | ������� ������� '
T1220='������ | ������� ������� '
T1139='������ | ������� ������� '
T1140='������ | ������� ������� '
T1141='������ | ������� ������� '
T1142='������ | ������� ������� '
T1143='������ | ������� ������� '
T1183='������ | ������� ������� '/>
</OK>
������ <OK SHIFT='16'><INCOME COUNT='7|0' TOTAL='59000|0' T1136='59000|0' T1138='0|0'
T1218='0|0' T1219='0|0' T1220='0|0' T1139='9838|0' T1140='0|0' T1141='0|0' T1142='0|0'
T1143='0|0' T1183='0|0'/><PAYOUT COUNT='0|0'/></OK>
� ���������� ����� ������� (���� �������), ���� ��������� �������� �����.
� INCOME � ����� �������� ������� � �������� �������.
� PAYOUT � ����� �������� ������� � �������� �������.
� �������� ����� (�������� ��������) ������������ � ��������;
COUNT � ���������� ����� (���) �� ��������������� �������� �������
TOTAL - �������� ����� ����� �� ��������������� �������� �������
T1136 - ����� ���������
T1138 - ����� ������������
T1218 - ����� ��������
T1219 - ����� ���������
T1220 - ����� ����� ���������� ������12
T1139 - ����� ��� �� ������ 20%
T1140 - ����� ��� �� ������ 10%
T1141 - ����� ��� �� ������ 20/120
T1142 - ����� ��� �� ������ 10/110
T1143 - ����� �������� �� ������ 0%
T1183 - ����� �������� ��� ���'.
� ���������, ���������� �������� ������ ����� �� ���� ��������� ������� ����� ���������� ������.
���� ����� �� ������-���� �������� ������� �� ���� � �����, �� ��������������� ������� ����� ��������� ������ ���������� �����, ������ 0, ��� ��������� ������ � �������, ��������:
<PAYOUT COUNT='0 | 0'/>
*)

function TMitsuDrv.ReadDayTotals(RequestType: Integer; var R: TMTSDayTotals): Integer;

  function NodeToTotals(Node: IXMLNode; N: Integer): TMTSTotals;
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
3.20. ����� �� �� �������� ����� (���)
������: <GET INFO='3'/>
�����: ��. �.3.20 (����� �����)
������ <OK SHIFT='16'><INCOME COUNT='41|0' TOTAL='99200|0' T1136='93100|0' T1138='6100|0'
T1218='0|0' T1219='0|0' T1220='0|0' T1139='16558|0' T1140='0|0' T1141='0|0' T1142='0|0'
T1143='0|0' T1183='0|0'/><PAYOUT COUNT='0|0'/><GT>99200</GT></OK>
� ���������� ������ ������ �������� ����� � ������� ��������� ������� ���������� ��.
� ��������� ������������ ������ ��������� ������ �����.
� � ������ ������ �� �������� ����� (���) ����������� ��� � ����������� ������ ����� � �������
��������� ������� ��.
<GT>����������� ����</GT>
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
3.22. ��������� ��
������: <GET INFO='F'/> ��� <GET INFO='FN'/>
�����: <OK FN=���������� ����� �͒
FFD='������ ��� �͒
PHASE=����� ���������� �͒
REG='����� ��������� (����)����������� | ����� ���������� ���������������'
VALID='���� �������� ��'
LAST=������ ���������� ����������� ����������
DATE=����� ���������� ����������� ����������
TIME=������ ���������� ����������� ����������
FLAG=������ �������������� (�����)� >
</OK>
������: <OK FN='9999078902014447' FFD='1.2' PHASE='0x03' REG='3|27' VALID='2024-07-17'
LAST='80' DATE='2023-04-27' TIME='23:00' FLAG='0x08'> </OK>
� ���������� ��������� ����������� ����������.
� PHASE: �����, ������������ ���� ���������� ��:
0x01 .... 1-� ����: ���������� � ����������� ���, �� ����������� ��;
0x03 .... 2-� ����: ������������ �� � ������������� ��, �� �������� ��;
0x07 .... 3-� ����: �������������� ����� � ���, �� ������������� ���������� �������� ��;
0x0F .... 4-� ����: ��������� ������ �� ������ ��, �� ��������� 5 ��� �� �������� �� 4-� ����.
�  �� � ���, ����������� � ���������� ������, ��������� �� 2-�� ����� �� 4-�, ����� 3-� ����
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
3.23. ������ �� �������� ���������� � ���
������: <GET INFO=�O�/> ��� <GET INFO=�OFD�/>
�����: <OK FN=���������� ����� �͒
COUNT=����������� ������������ ����������'
FIRST=������ ������� ������������� ����������
DATE=����� ������� ������������� ����������
TIME=������ ������� ������������� ���������� />
������: <OK FN='9999078902014447' COUNT='63' FIRST='18' DATE='2023-01-11' TIME='18:15'></OK>
� ���������� ���������� ������������ ����������, � ����� �����, ���� � ����� ���������, ������� �
������� �� �������� � ���.
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
3.24. ������ �� ������ � ������ ����������
������: <GET INFO=�M�/> ��� <GET INFO=�MRK�/>
�����: <OK MARK= ���������� �� �������� �̒
KEEP=����������� ���������� ����������� �������� ��'
FLAG=����� ���������� ������ ������ � �� (�����)'
NOTICE=���������� ����������� � ���������� �������������� �������
HOLDS=����������� ��, ���������� � �����������
PENDING=����������� ����������� � �������
WARNING=���������� ���������� ������� �������� ����������� />
������: <OK MARK='1' KEEP='0' FLAG='0x05' NOTICE='0' HOLDS='0'PENDING='1' WARNING='0'/>
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

3.25. ������ �� �������� ����������� � ����
������: <GET INFO=�N�/> ��� <GET INFO=�NOT�/>
�����: ����� ������ � ��������� ������:
<OK NOTICE= ���������� �� �������� �����������
PENDING='���������� ����������� � �������
CURRENT= ������ ������� ����������������� ������������
DATE='���� ������� ����������������� ������������
TIME='����� ������� ����������������� ������������
STORAGE=�������� ���������� ������� �������� �����������/>
���������� �����:
<OK PENDING=������ ����� �����������, �������� ������� �� �������������
FIRST='����� ������� ����������������� �����������'
CURRENT=����������� ����������� ��� �������� � ���� ������
No=������ �������� ������������ />
������: <OK NOTICE='0' PENDING='1' CURRENT='6' DATE='2023-01-11' TIME='13:41' STORAGE='1'/>
� ���������� ��������� ����������� ���������� �� ������ � �������������.
� NOTICE � ��������� �� �������� �����������(����� ������ � ��������� ������):
0 � ��� ��������� ������;
1 � ������ ������ �����������;
2 � �������� ��������� �� �����������.
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
3.26. ������ �� ���������� ������ � ���
������: <GET INFO=�K�/> ��� <GET INFO=�KEY�/>
����� (�): <OK Ext='������� ������ ����� ������� ������ ������'
NeedUpdate= '������� ������������� ���������� ������'
D7='������� ��������� �� ���������� ������� D7'>
<URL>����� � ���� ���</URL>
</OK>
����� (�): <OK Ext='������� ������ ����� ������� ������ ������'
DATE= '���� ���������� ���������� ������ �������� ��'
TIME='����� ���������� ���������� ������ �������� ��'/>
������: <OK Ext='1' NeedUpdate='0' D7='1'><URL>tcp://test.okp.atlas-kard.ru:31101</URL></OK>
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
3.27. ������ �������� ���������
������: <GET DOC=�0�/>
�����: <OK FD='���������� ����� ����������� ���������'
TYPE=���� ����������
STATE=���������� ����������
SIZE=������� ��������� ����������/>
���: <OK TXT='���������� ����� ������������� (����������) ���������'
TYPE=���� ����������
STATE=���������� ����������/>
������: <OK FD='82' TYPE='3' STATE='1' SIZE='101'/>
*)

function TMitsuDrv.ReadLastDocStatus(var R: TDocStatus): Integer;
begin
  Result := ReadDocStatus(0, R);
end;

(*
3.28. ������ � ������ ��������� �� ��
������: <GET DOC='�����'/>
�����: <OK DOC='�����' TYPE='���' STATE=�0�/>
������: <OK FD='81' TYPE='2' STATE='0'/>
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
3.30. XML ����� ��������� �� ��
������: <GET DOC='X:�����' />
�����: <OK OFFSET='60010000' LENGTH='������'/>
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
3.31. XML ����� � ������ ������������� ���������
������: <GET DOC='C:�����' />
�����: <OK OFFSET='60010000' LENGTH='������'/>
*)

function TMitsuDrv.ReadFDDocPrint(N: Integer; var R: TFDParams): Integer;
begin
  Result := GetRequest(Format('DOC=''�:%d''', [N]));
  if Succeeded(Result) then
  begin
    R.Offset := StrToInt('$' + GetAttribute('OFFSET'));
    R.Size := GetIntAttribute('LENGTH');
  end;
end;

(*
3.32. ���������� ����� XML �����
������: <READ OFFSET='�����' LENGTH='������'/>
�����: <OK LENGTH='������'> ������ </OK>
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
3.33. ���� ���� �������
������: <GET POWER='?'/>
�����: <OK POWER='��������� �����'/>
������: <OK POWER='0'/>
� POWER='1', ���� ��� ���������� � �� ��������� ��-�� ���������� �������.
� POWER='0', ���� �� ��� ���������� ��� ��������� ��-�� ���������� �������
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
3.34. ������ ��������� (�����)
������: <OPTION/> - �������� �������� ���� ����
<OPTION b0=�?�/> ��������� �������� �������� ����� ��� ���������� �����
�����: <OK b0='�����' b1='�����'. . . b8='�����'/>
������: <OK b0='0' b1='0' b2='3' b3='1' b4='0' b5='0' b6='0' b7='0' b8='0'/>
��. �������� ���������� � ������� ��������� ��������, �.4.13.
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
4.3. ���� � �����
������: <SET DATE = '����-��-��' TIME='��:��:��' />
������: <SET DATE='2023-02-07' TIME='09:00:00' />
�����: <OK DATE='2023-02-07' TIME='09:00:00'/>
� ��� �������� DATE � TIME � ������������.
� ���������� ���� � ����� �� ������ ���� ����� ���� � ������� ���������� ����������� ���������.
� ��������DATE �TIME � ������ ���������� ����� ���� � ����� ���������� ����� �����,
������������� �� ���������� ���� �������, � ��� �� �������.
*)

function TMitsuDrv.WriteDate(const Date: TDateTime): Integer;
var
  Command: AnsiString;
begin
  Command := Format('<SET DATE=''%s'' TIME=''%s''/>', [MTSDateToStr(Date), MTSTimeToStr(Date)]);
  Result := Send(Command);
end;

(*
4.4. ������
������: <SET CASHIER= '�������������' INN='���'/>
������: <SET CASHIER= '���� ������' INN='9876543210'/>
*)

function TMitsuDrv.WriteCashier(const Cashier: TMTSCashier): Integer;
var
  Command: AnsiString;
begin
  Command := Format('<SET CASHIER=''%s'' INN=''%s''/>', [Cashier.Name, Cashier.INN]);
  Result := Send(Command);
end;

(*
4.5. �������� COM �����
������: <SET COM='��������' />
������: <SET COM='115200'/>
COM � �������� ����� RS232: �� 2400 �� 115200 ���/���
*)

function TMitsuDrv.WriteBaudRate(const BaudRate: Integer): Integer;
begin
  Result := Send(Format('<SET COM=''%d''/>', [BaudRate]));
end;

(*
5.1. �����������
������: <REG BASE=�0� ATTR='������'� ><TAG>������</TAG>�</REG>
�����: <OK FD='����� ����������� ���������' FP='���������� �������'/>
��������: * BASE=�0� (����� ����)
MARK='������� ������ � �������������� ��������'
PAWN='������� ������������� ���������� ������������'
INS='������� ������������� ��������� ������������'
DINE='������� ������������� �������� ����� ������������� �������'
OPT='������� ���������� � ������� �������� � ������������� � ��'
VEND='������� ���������� � �������������� �����������'
T1001='������� ��������������� ������'
T1002=�������� ����������� ������'
T1056='������� ����������'
* T1062='������� ���������������'
T1108='������� ����� ��� �������� ������ � ��������'
T1109='������� �������� �� ������'
T1110='������� ������ ���'
T1126='������� ���������� �������'
T1193='������� ���������� �������� ���'
T1207='������� �������� ������������ ��������'
T1221='������� ��������� �������� � ��������'
����: <T1009> ����� �������� </T1009>
* <T1017> ��� ��� </T1017>
* <T1018> ��� ������������ </T1018>
<T1036> ����� �������� </T1036>
* <T1037> ��������������� �����</T1037>
<T1046> ������������ ��� </T1046>
* <T1048> ������������ ������������ </T1048>
* <T1060> ����� ����� ��� </T1060>
<T1117> ����� ����������� ����� ����������� ���� </T1117>
<T1187> ����� �������� </T1187>
<T1274> �������������� �������� �� </T1274>
<T1275> �������������� ������ �� </T1275>
������: <REG BASE='0' T1062='0,1,2,5' DINE='1' MARK='1'>
<T1037>0000123456029024</T1037>
<T1018>7700112233</T1018>
<T1048> ��� "�����"</T1048>
<T1009>123456, �.������, ������� ������� �.1</T1009>
<T1017>7714731464</T1017>
<T1046> �����-���� </T1046>
<T1060>www.nalog.gov.ru</T1060>
<T1117> noreply@ofd.com </T1117>
</REG>
*)

//������: <REG BASE=�0� ATTR='������'� ><TAG>������</TAG>�</REG>
//�����: <OK FD='����� ����������� ���������' FP='���������� �������'/>

function TMitsuDrv.FNParamsToXml(const Params: TFNParams): AnsiString;
var
  Node: IXMLNode;
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
5.3. ������ ������ � (����-) ����������� �� ������
������: <GET REG='�����'/>
<PRINT/>
*)

function TMitsuDrv.FNPrintReg(N: Integer): Integer;
begin
  Result := Send(Format('<GET REG=''%d''/><PRINT/>', [N]));
end;

(*
5.4. �������� ����������� ����������
������: <MAKE FISCAL=�CLOSE�/>
<T1009>����� ��������</T1009>
<T1187>����� ��������</T1187>
<T1282> �������������� �������� ���� </T1282>
<T1283> �������������� ������ ���� </T1283>
</MAKE>
�����: <OK FD='����� ����������� ���������'
FP='���������� ������� ���������'/>
*)

function TMitsuDrv.FNClose(const Params: TFNParams): Integer;
var
  Node: IXMLNode;
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
6.1. �������� �����
������: <Do SHIFT='OPEN'/>
���: <Do SHIFT='OPEN'>
<T1009> ����� �������� </T1009>
<T1187> ����� �������� </T1187>
<T1276> �������������� �������� ���</T1276>
<T1277> �������������� ������ ��� </T1277>
</Do>
�����: <OK
SHIFT='����� �������� �����'
FD='����� ����������� ���������'
FP='���������� ������� ���������'
MsgOFD='����� ��������� ���������'
OKP='����� ��������� ���������� ������ �������� ��' />
������: <OK SHIFT='18' FD='86' FP='0899945832' MsgOFD='0' OKP='0'/>
*)

function TMitsuDrv.OpenFiscalDay(const Params: TMTSDayParams): Integer;
var
  Node: IXMLNode;
  Xml: IXMLDocument;
  Command: AnsiString;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('Do', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('SHIFT', 'OPEN');
  Node.SetAttribute('T1009', Params.SaleAddress);
  Node.SetAttribute('T1187', Params.SaleLocation);
  Node.SetAttribute('T1276', Params.ExtendedProperty);
  Node.SetAttribute('T1277', Params.ExtendedData);
  Command := Trim(Xml.Xml.Text);
  if Params.PrintRequired then
    Command := Command + '<PRINT/>';
  Result := Send(Command);
end;

(*
6.2. �������� �����
������: <Do SHIFT='CLOSE'/>
���: <Do SHIFT='CLOSE'>
<T1009> ����� �������� </T1009>
<T1187> ����� �������� </T1187>
<T1278> �������������� �������� ��� </T1278>
<T1279> �������������� ������ ��� </T1279>
</Do>
�����: <OK
SHIFT='����� �������� �����'
FD='����� ����������� ���������'
FP='���������� ������� ���������'
MsgOFD='����� ��������� ���������'/>
*)

function TMitsuDrv.CloseFiscalDay(const Params: TMTSDayParams): Integer;
var
  Node: IXMLNode;
  Xml: IXMLDocument;
  Command: AnsiString;
begin
  Xml := NewXMLDocument('');
  Node := Xml.CreateElement('Do', '');
  Xml.DocumentElement := Node;
  Node.SetAttribute('SHIFT', 'CLOSE');
  Node.SetAttribute('T1009', Params.SaleAddress);
  Node.SetAttribute('T1187', Params.SaleLocation);
  Node.SetAttribute('T1278', Params.ExtendedProperty);
  Node.SetAttribute('T1279', Params.ExtendedData);
  Command := Trim(Xml.Xml.Text);
  if Params.PrintRequired then
    Command := Command + '<PRINT/>';
  Result := Send(Command);
end;

(*
7.1. �������� ����
������: <Do CHECK=�OPEN� TYPE=�������� �������� TAX=�������� ����������������/>
���: <Do CHECK=�OPEN� TYPE=�������� �������� TAX=� ������� ����������������>
<T1009> ����� �������� </T1009>
<T1187> ����� �������� </T1187>
<T1036> ����� �������� </T1036>
<T1117> ����� ����������� ����� ����������� ���� </T1117>
<Do/>
*)

function TMitsuDrv.BeginFiscalReceipt(const Params: TMTSReceiptParams): Integer;
var
  Node: IXMLNode;
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
7.11. ������ ��������� ����
������:
*)

function TMitsuDrv.CancelFiscalReceipt: Integer;
begin
  Result := Send('<Do CHECK=''CANCEL''/>');
end;

(*
7.2. ������ ����� ��������� �������
������:
� ������� ��������� ���� ��������� ������� (�������� �������) � �������������� ���������� ����.
� ������� �����������, ���� ��� ������ (��. �������� ����).
� �������� ���� ��������� � ����������� ���������.
� ��������� ������� ������ ��������� ����.
*)

function TMitsuDrv.BeginPositions: Integer;
begin
  Result := Send('<Do CHECK=''BEGIN''/>');
end;

(*
7.3. �������� ������� (�������� �������)
������: <ADD ITEM= '���������� �������� �������'
TAX= '������ ��� �� �������� �������'
UNIT= '���� ���������� �������� �������'
PRICE= '���� �� ������� �������� �������'
TOTAL= '��������� �������� �������'
TYPE= '������� �������� �������'
MODE= '������� ������� �������'
T1229= '����� ��������� ����� �� �������� �������'
T1230= '��� ������ �������������'
T1231= '����� ���������� ����������' >
<NAME>������������ �������� �������</NAME>
<QTY PART=����������� OF=������������� />
<KM �xxxx= ���� ������� />
<T1191>�������������� �������� �������� �������</T1191>
<T1222>������� ������ �� �������� �������</T1222>
<T1223>
<T1044>�������� ���������� ������</T1044>
<T1073>������� ���������� ������</T1073>
<T1074>������� ��������� �� ������ ��������</T1074>
<T1075>������� ��������� ��������</T1075>
<T1026>������������ ��������� ��������</T1026>
<T1005>����� ��������� ��������</T1005>
<T1016>��� ��������� ��������</T1016>
</T1223>
<T1224>
<T1225>������������ ����������</T1225>
<T1171>������� ����������</T1171>
</T1224>
<T1260>
<T1262>������������� ����</T1262>
<T1263>���� ��������� ���������</T1263>
<T1264>����� ��������� ���������</T1264>
<T1265>�������� ����������� ���������</T1265>
</T1260>
<T1226>��� ����������</T1226>
</ADD>
�����: <OK TOTAL=����� �����
ROUND=������������ ���� �����
OFF=������ �����������
ITEMS=����������� ��������� ��������/>
*)

function QuantityToStr(Quantity: Double): AnsiString;
begin
  DecimalSeparator := '.';
  Result := Format('%.6f', [Quantity]);
end;

function TMitsuDrv.AddPosition(const P: TMTSPosition): Integer;
var
  Node: IXMLNode;
  Node2: IXMLNode;
  Xml: IXMLDocument;
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
  Node.SetAttribute('T1230', IntToStr(P.CountryCode));
  Node.SetAttribute('T1231', IntToStr(P.DeclarationNumber));
  if P.MarkCode <> '' then
    AddChild(Node, 'KM', P.MarkCode);
  if P.AddAttribute <> '' then
    AddChild(Node, 'T1191', P.AddAttribute);
  if P.AgentType > 0 then
    AddChild(Node, 'T1222', IntToStr(P.AgentType));
  if P.SupplierINN <> '' then
    AddChild(Node, 'T1226', P.SupplierINN);
  if P.Numerator <> 0 then
    AddChild(Node, 'QTY', Format('PART=''%d'' OF=''%d''', [P.Numerator, P.Denominator]));
(*
  AgentToNode(Node, P.AgentInfo);
  SupplierToNode(Node, P.supplier);
  IndustryAttributeToNode(Node, P.IndustryAttribute);
*)

  Result := Send(Trim(Xml.Xml.Text));
end;

end.


