unit Devices3;

interface

uses
  // VCL
  Windows, Classes, SysUtils, XMLDoc, XMLIntf,
  // This
  untLogger, DrvFRLib_TLB, PrinterTypes, DriverError, DriverTypes, Types1C,
  Params1C, Driver1CParams, BinUtils, StringUtils, TntSysUtils, TntClasses,
  TextEncoding, logfile, Positions1C, FormatTLV, variants, Math, LangUtils,
  ODClient, XmlUtils, ControlMark;

const
  // Новые ошибки
  C_ERR_CHECKCLOSED = 2000; // Чек закрыт - операция невозможна
  C_ERR_CHECKOPENED = 2001; // Чек открыт - операция невозможна

  ECRMODE_RECOPENED = 8;

  // Типы подключения
  ctLocal = 0;
  ctTCP = 1;
  ctDCOM = 2;

  // Праметры по умолчанию
  DEF_PRINTLOGO = False;
  DEF_LOGOSIZE = 0;
  DEF_CONNECTION_TYPE = ctLocal;
  DEF_COMPUTERNAME = '';
  DEF_IPADDRESS = '';
  DEF_TCPPORT = 211;
  DEF_PROTOCOLTYPE = 0;
  DEF_BUFFERSTRINGS = False;
  StatusTimeout = 30000; // 30 секунд

type
  TDiscountRec = record
    Amount: Currency;
    Tax1: Integer;
    Tax2: Integer;
    Tax3: Integer;
    Tax4: Integer;
    Text: WideString;
  end;

  TDeviceParams17 = record
    ConnectionType: Integer;
    ProtocolType: Integer;
    Port: Integer;
    Baudrate: Integer;
    Timeout: Integer;
    IPAddress: WideString;
    ComputerName: WideString;
    TCPPort: Integer;
    AdminPassword: Integer;
    LogEnabled: Boolean;
    LogFileName: WideSTring;
    CloseSession: Boolean;
    Paynames: T1CPayNames;
    BarcodeFirstLine: Integer;
    QRCodeHeight: Integer;
    EnablePaymentSignPrint: Boolean;
    QRCodeDotWidth: Integer;

    ODEnabled: Boolean;
    ODServerURL: string;
    ODINN: string;
    ODGroup: string;
    ODCertFileName: string;
    ODKeyFileName: string;
    ODSignKeyFileName: string;
    ODKeyName: string;
    ODRetryCount: Integer;
    ODRetryTimeout: Integer;
    ItemNameLength: Integer;
    CheckFontNumber: Integer;
    ODTaxOSN: Boolean;
    ODTaxUSND: Boolean;
    ODTaxUSNDMR: Boolean;
    ODTaxENVD: Boolean;
    ODTaxESN: Boolean;
    ODTaxPSN: Boolean;
  end;

  TFiscalParametersRec = record
    CashierName: WideString;
    CashierVATIN: WideString;
    KKTNumber: WideString;
    KKTSerialNumber: WideString;
    Fiscal: Boolean;
    DocumentNumber: WideString;
    DateTime: TDateTime;
    INN: WideString;
    Tax: Byte;
    WorkMode: Byte;
    ReasonCode: Byte;
    ServiceSign: Boolean;
    BSOSign: Boolean;
    CalcOnlineSign: Boolean;
    OFDOrganizationName: WideString;
    OrganizationName: WideString;
    AddressSettle: WideString;
    PlaceSettle: WideString;
    OFDVATIN: WideString;
    AutomatNumber: WideString;
  end;

  TFiscalParametersRec22 = record
    CashierName: string; // 	Да 	string 	ФИО и должность уполномоченного лица для проведения операции
    CashierVATIN: string; // 	Да 	string 	ИНН уполномоченного лица для проведения операции
    KKTNumber: string; // 	Да 	string 	Регистрационный номер ККТ
    OrganizationName: string; // 	Да 	string 	Название организации
    VATIN: string; // 	Да 	string 	ИНН организация
    AddressSettle: string; // 	Да 	string 	Адрес проведения расчетов
    PlaceSettle: string; // 	Да 	string 	Место проведения расчетов
    Tax: Byte;
    WorkMode: Byte;
    Agent: Byte;
    SaleExcisableGoods: Boolean; // 	Да 	boolean 	продажа подакцизного товара
    SignOfGambling: Boolean; // 	Да 	boolean 	признак проведения азартных игр
    SignOfLottery: Boolean; // 	Да 	boolean 	признак проведения лотереи
    SignOfAgent: string; // 	Да 	string 	Коды признаков агента через разделитель ",".
//    (Коды приведены в таблице 10 форматов фискальных данных)
    PrinterAutomatic: Boolean; // 	Да 	boolean 	Признак установки принтера в автомате
    AutomaticMode: Boolean; // 	Да 	boolean 	Признак автоматического режима
    AutomaticNumber: string; // 	Да 	string 	Номер автомата для автоматического режима
    ReasonCode: Integer; // 	Нет* 	long 	Код причины перерегистрации указывается только для операции "Изменение параметров регистрации")
    InfoChangesReasonsCodes: string; // 	Нет* 	string 	Коды причин изменения сведений о ККТ через разделитель ",".
    //(Коды приведены в таблице 15 форматов фискальных данных)
    OFDOrganizationName: string; // 	Да 	string 	Название организации ОФД
    OFDVATIN: string; // 	Да 	string 	ИНН организации ОФД
    FNSWebSite: string;
    SenderEmail: string;
  end;

  TInputParametersRec = record
    CashierName: WideString;
    CashierVATIN: WideString;
  end;

  TCheckCorrectionParamsRec = record
    PaymentType: Integer;
    TaxType: Integer;
    Cash: Currency;
    CashLessType1: Currency;
    CashLessType2: Currency;
    CashLessType3: Currency;
  end;

  TOpenSessionOutputParamsRec = record
    UrgentReplacementFN: Boolean; //Признак необходимости срочной замены ФН
    MemoryOverflowFN: Boolean; // 	Признак переполнения памяти ФН
    ResourcesExhaustionFN: Boolean; // 	Признак исчерпания ресурса ФН
    OFDtimeout: Boolean; // Признак того, что подтверждение оператора для переданного фискального документа отсутствует более двух дней. Для ФД с версией ФФД 1.0 более 5 дней.
  end;

  TCloseSessionOutputParamsRec = record
    NumberOfChecks: Integer; // 	  	+ 	+ 	long 	Количество кассовых чеков за смену
    NumberOfDocuments: Integer; //  	  	+ 	+ 	long 	Количество общее ФД за смену
    BacklogDocumentsCounter: Integer; // 	+ 	+ 	+ 	long 	Количество непереданных документов
    BacklogDocumentFirstNumber: Cardinal; // 	- 	- 	- 	long 	Номер первого непереданного документа
    BacklogDocumentFirstDateTime: TDateTime; // 	+ 	+ 	+ 	datetime 	Дата и время первого из непереданных документов
    UrgentReplacementFN: Boolean; // 	  	  	+ 	bool 	Признак необходимости срочной замены ФН
    MemoryOverflowFN: Boolean; // 	  	  	+ 	bool 	Признак переполнения памяти ФН
    ResourcesExhaustionFN: Boolean; // 	  	  	+ 	bool 	Признак исчерпания ресурса ФН
    OFDTimeout: Boolean; // 	  	  	+ 	bool 	Признак того, что подтверждение оператора для переданного фискального документа отсутствует более двух дней. Для ФД с версией ФФД 1.0 более 5 дней.
  end;

  TSessionRegParametersRec = record
    CashierName: string;
    CashierINN: string;
    OperationType: Integer;
    SaleAddres: string;
    SaleLocation: string;
  end;

  TDriverFunc = function: Integer of object;

  TDevice1C = class;

  { TDevices1C }

  TDevices1C = class
  private
    FBPOVersion: Integer;
    FList: TList;
    FDriver: TDrvFR;
    function GetCount: Integer;
    procedure InsertItem(AItem: TDevice1C);
    procedure RemoveItem(AItem: TDevice1C);
    function GetItem(Index: Integer): TDevice1C;
    function IsFreeID(ID: Integer): Boolean;
  public
    constructor Create(ADriver: TDrvFR);
    destructor Destroy; override;
    procedure Clear;
    function Add: TDevice1C;
    function GetFreeID: Integer;
    function ItemByID(ID: Integer): TDevice1C;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TDevice1C read GetItem; default;
    property BPOVersion: Integer read FBPOVersion write FBPOVersion;
  end;

  { TDevice1C11 }

  TDevice1C = class
  private
    function GetBPOVersion: Integer;
  private
    FSessionRegOpened: Boolean;
    FODClient: TODClient;
    FID: Integer;
    FLogger: TLogger;
    FOwner: TDevices1C;
    FParamsReg: TDriver1CParams;
    FParams: TDeviceParams17;
    FFFDVersion: Integer;
    fRecType: Integer;
    FLineLength: Integer;
    FIsOpenedCheck: Boolean;
    FIsFiscalCheck: Boolean;
    FIsReturnCheck: Boolean;
    FCapGetShortECRStatus: Boolean;
    FPayProgrammed: Boolean;
    FCapOpenCheck: Boolean;
    FPrintLogo: Boolean;
    FTaxProgrammed: Boolean;
    FPrintCloseCheck: Boolean;
    FNonFiscalCheckNumber: Integer;
    FUserPassword: Integer;
    FLogoSize: Integer;
    FSerialNumber: WideString;
    FAddressSiteInspections: WideString;
    FSenderEmail: WideString;
    FTaxNames: TTaxNames;
    FUseIPAddress: Boolean;
    FUseAdminPassword: Boolean;
    FBufferStrings: Boolean;
    FStringForPrinting: WideString;
    FTaxCount: Integer;
    FTax: T1CTax;
    FOldKKT: Boolean;
    FDepartments: array[1..16] of string;
    function ReplaceDelimeter(const AStr: WideString): WideString;
    function GetLogger: TLogger;
    function GetStatus: Integer;
    function GetName: WideString;
    function GetDriver: TDrvFR;
    function IsSessionOpened: Boolean;
    function IsPrinterRecOpened: Boolean;
    //function CheckTax(ATax: Single): Integer;
    function CheckTaxOld(ATax: Single): Integer;
    function CheckGetPassword(APassword, AMessage: string): Integer;
    function ReadValuesArray(const AValuesArray: IDispatch): T1CDriverParams;
    function ReadLogoValuesArray(const AValuesArray: IDispatch): T1CDriverParams;
    function DateTimeToXML(AValue: TDateTime): WideString;
    procedure LockPort;
    procedure SaveToReg;
    procedure UnlockPort;
    procedure ReadTaxNames;
    procedure FeedAndCut;
    procedure CheckStatus;
    procedure LoadFromReg;
    procedure CancelReceipt;
    procedure CancelAnyCheck;
    procedure SetUserPassword;
    procedure SetCashierPassword(const ACashierName: WideString);
    procedure SetCashierVATIN(const ACashierVATIN: WideString);
    procedure SetSenderEmail(const ASenderEmail: WideString);
    procedure SetAgentData(const Data: TAgentData);
    procedure SetPurveyorData(const Data: TPurveyorData);
    procedure SendStrTag(ATag: Integer; const AValue: WideString);
    procedure SendStrTagOperation(ATag: Integer; const AValue: WideString);
    procedure ProgramPayNames;
    procedure SetAdminPassword;
    procedure CheckReceiptOpened;
    procedure CheckReceiptClosed;
    procedure CheckPrinterRecOpened;
    procedure PrintText(const Text: WideString; AWrapString: Boolean = False);
    procedure Check(AResultCode: Integer);
    procedure SetOwner(AOwner: TDevices1C);
    procedure WaitForPrinting;
    property Driver: TDrvFR read GetDriver;
    function GetResultCodeDescription(ResultCode: Integer): WideString;
    function CapCashCore: Boolean;
    function CapCut: Boolean;
    procedure RebootECR;
    procedure WaitForConnect;
    procedure PrintText2(const AStr: WideString; AWrapString: Boolean = False);
    function PrintCharge(const Text: WideString): Boolean;
    function PrintDiscount(const Text: WideString): Boolean;
    procedure PrintStringWithWrap(const AStr: WideString);
    procedure ReadDepartments;
    function ReadTableStr(ANumber: Integer; ARow: Integer; AField: Integer): string;
    function ReadTableInt(ANumber: Integer; ARow: Integer; AField: Integer): Integer;
    function CorrectTableNumber(ANumber: Integer): Integer;
    function GetModelID: Integer;
    function GetFFDVersion: WideString;
    function IsModelType2(Value: Integer): Boolean;
    function CapNonFiscalDocument: Boolean;
    function EncodeOutputParametersOpenSession22(Params: TOpenSessionOutputParamsRec): WideString;
    function EncodeOutputParametersCloseSession22(Params: TCloseSessionOutputParamsRec): WideString;
    procedure ParseFiscalParameters(const AXML: WideString; var Params: TFiscalParametersRec);
    procedure ParseFiscalParameters22(const AXML: WideString; var Params: TFiscalParametersRec22);
    procedure ParseCheckCorrection(const AXML: WideString; var Params: TCheckCorrectionParamsRec);
    procedure ParseCheckCorrection22(const AXML: WideString; var Params: TCheckCorrectionParamsRec22);
    procedure ParseSessionRegParameters(const AXML: WideString; var Params: TSessionRegParametersRec);
    procedure ParseInputParameters(const AXML: WideString; var Params: TInputParametersRec);
    function ParseTaxSystem(const ATax: WideString): Byte;
    function ParseAgent(const AAgent: WideString): Byte;
    procedure SendTags(APositions: TPositions1C);
    procedure SendAgentDataOperation(AgentData: TAgentData; PurveyorData: TPurveyorData; AgentSign: WideString);
    procedure AddStrTag(ATagNumber: Integer; const AValue: string);
//    procedure SendDoubleTag(ATag: Integer; const AValue: Double);
    function TaxToBin(const ATax: Integer): Byte;
    function IsTrue(const AStr: WideString): Boolean;
    function Bool1C(AValue: Boolean): WideString;
    property BPOVersion: Integer read GetBPOVersion;
    function EncodeAgentSign(ASign: Integer): string;
  public
    constructor Create(AOwner: TDevices1C);
    destructor Destroy; override;
    procedure ProgramPrintCloseCheck;
    function GetLineLength: Integer;
    procedure Close;
    procedure Disconnect;
    procedure OpenSession;
    procedure PrintXReport;
    procedure PrintZReport;
    procedure ContinuePrinting;
    procedure ApplyDeviceParams;
    procedure CheckPrintingStatus;
    procedure Open(const ValuesArray: IDispatch);
    procedure Open2;
    procedure Open3;
    procedure Assign(const Device: TDevice1C);
    procedure OpenCashDrawer(CashDrawerID: Integer);
    procedure SetParam(const Name: WideString; Value: Variant);
    procedure SetParams(const Params: T1CDriverParams);
    procedure CashInOutcome(Amount: Double);
    procedure CashInOutcome22(Amount: Double; const InputParameters: WideString);
    procedure CancelCheck;
    procedure CloseCheck(Cash, PayByCard, PayByCredit, PayBySertificate, DiscountOnCheck: Double);
    procedure CloseCheckFN(Cash, PayByCard, PayByCredit, PayBySertificate: Double; ATaxType: Integer; TotalSumm: Double);
    procedure CloseCheckFN22(Cash, ElectronicPayment, AdvancePayment, Credit, CashProvision: Double; ATaxType: Integer; TotalSumm: Double);
    procedure OpenCheck(IsFiscalCheck, IsReturnCheck, CancelOpenedCheck: WordBool; var ACheckNumber, ASessionNumber: Integer);
    procedure OpenCheckFN(const ACashierName: WideString; CheckType: Integer; CancelOpenedCheck: WordBool; var ACheckNumber, ASessionNumber: Integer);
    procedure PrintFiscalString(const AName: WideString; AQuantity, APrice, AAmount: Double; ADepartment: Integer; ATax: Single);
    procedure PrintFiscalLineFN(const AName: WideString; AQuantity, APrice,
                                ATotal, ADiscount: Double; ADepartment,
                                ATax: Integer; ItemCodeData: TItemCodeData;
                                AgentData: TAgentData;PurveyorData: TPurveyorData;
                                AgentSign: WideString; APaymentTypeSign: Integer = 4;
                                APaymentItemSign: Integer = 1;
                                ACountryOfOrigin: WideString = '';
                                ACustomsDeclaration: WideString = '';
                                AExciseAmount: WideString = '';
                                AAdditionalAttribute: WideString = '';
                                AMeasurementUnit: WideString = ''
                                );
    procedure PrintFiscalStringFN2(const AName: WideString; AQuantity, APrice, AAmount: Double; ADepartment: Integer; ATax: Integer);
    procedure PrintFiscalString2(const AName: WideString; AQuantity, APrice, AAmount: Double; ADepartment: Integer; ATax1: Integer; ATax2: Integer; ATax3: Integer; ATax4: Integer);
    procedure PrintFiscalString22(AFiscalString: TFiscalString22);
    procedure PrintNonFiscalString(const TextString: WideString);
    procedure DeviceControl(const TxData: WideString; var RxData: WideString);
    procedure PrintBarCode(const BarcodeType, Barcode: WideString);
    procedure DeviceTest(const ValuesArray: IDispatch; var AdditionalDescription, DemoModeIsActivated: WideString);
    procedure LoadLogo(const ValuesArray: IDispatch; const LogoFileName: WideString; CenterLogo: WordBool; var LogoSize: Integer; var AdditionalDescription: WideString);
    procedure DeviceTest2(const ValuesArray: IDispatch; var AdditionalDescription, DemoModeIsActivated: WideString);
    procedure SetPayName(Number: Integer; const Name: WideString);
    procedure OpenShift;
    procedure WriteTableStr(ANumber: Integer; ARow: Integer; AField: Integer; const AValue: string);
    procedure WriteTableInt(TableNumber: Integer; Row: Integer; Field: Integer; Value: Integer);
    function GetPlaceSettle: WideString;


    // 1.7

    procedure GetDataKKT(var TableParameters: WideString);
    procedure OperationFN(OperationType: Integer; const Cashiername: WideString; const FiscalParameters: WideString);
    procedure OpenShift17(const CashierName: WideString; var SessionNumber: Integer; var DocumentNumber: Integer);
    procedure CloseShift17(const CashierName: WideString; var SessionNumber: Integer; var DocumentNumber: Integer);
    procedure ProcessCheck(const CashierName: WideString; Electronically: Boolean; const CheckPackage: WideString; var CheckNumber: Integer; var SessionNumber: Integer; var FiscalSign: WideString; var AddressSiteInspections: WideString);
    procedure doProcessCheck(const CashierName: WideString; Electronically: Boolean; const CheckPackage: WideString; var CheckNumber: Integer; var SessionNumber: Integer; var FiscalSign: WideString; var AddressSiteInspections: WideString);
    procedure ProcessCheckCorrection(const CashierName: WideString; const CheckCorrectionPackage: WideString; var CheckNumber: Integer; var SessionNumber: Integer; var FiscalSign: WideString; var AddressSiteInspections: WideString);
    procedure ProcessCheckCorrection22(const CheckCorrectionPackage: WideString; var CheckNumber: Integer; var SessionNumber: Integer; var FiscalSign: WideString; var AddressSiteInspections: WideString);
    procedure GetCurrentStatus(var CheckNumber: Integer; var SessionNumber: Integer; var SessionState: Integer; var StatusParameters: WideString);
    function GetXMLStatusParameters: WideString;
    function StrToDouble(const AValue: WideString): Double;
    procedure ReportCurrentStatusOfSettelements;
    procedure CloseShiftFN(const CashierName: WideString; var SessionNumber, DocumentNumber: Integer);
    procedure OpenShiftFN(const CashierName: WideString; var SessionNumber, DocumentNumber: Integer);
    procedure PrintTextDocument(const TextPackage: WideString);
    procedure PrintPair(const AStr1, AStr2: string);
    procedure PrintTag(const AStr1, AStr2: string);


///////////////////////////////////////////////////////////////////////
//                           2.2                                     //
///////////////////////////////////////////////////////////////////////

    procedure ReportCurrentStatusOfSettelements22(const InputParameters: WideString; var OutputParameters: WideString);
    procedure GetDataKKT22(var TableParameters: WideString);
    function OperationFN22(OperationType: Integer; const ParametersFiscal: WideString): WordBool;
    procedure CloseShiftFN22(InputParameters: WideString; var OutputParameters: WideString; var SessionNumber, DocumentNumber: Integer);
    procedure OpenShiftFN22(InputParameters: WideString; var OutputParameters: WideString; var SessionNumber, DocumentNumber: Integer);
    procedure doProcessCheckOD(const CashierName: WideString; Electronically: Boolean; const CheckPackage: WideString; var CheckNumber: Integer; var SessionNumber: Integer; var FiscalSign: WideString; var AddressSiteInspections: WideString);
    procedure doProcessCheckCorrectionOD(const CheckCorrectionPackage: WideString; var CheckNumber: Integer; var SessionNumber: Integer; var FiscalSign: WideString; var AddressSiteInspections: WideString);
    procedure ODSetParams;
    function GetODTaxSystems: WideString;


///////////////////////////////////////////////////////////////////////
//          Marking
//////////////////////////////////////////////////////////////////////
    procedure CloseSessionRegistrationKM;
    procedure ExecuteCheckKM(ControlMarks: WideString;
      var CheckResults: WideString);
    procedure OpenSessionRegistrationKM(SessionRegistrationParameters: WideString);

//////////////////////////////////////////////////////////////////////////
    function DrvSale: Integer;
    function DrvReturnSale: Integer;
    function DrvCharge: Integer;
    function DrvDiscount: Integer;
    function DrvCloseCheck: Integer;
    function DrvCashIncome: Integer;
    function DrvCashOutcome: Integer;
    function DrvSysAdminCancelCheck: Integer;
    function DrvPrintXReport: Integer;
    function DrvPrintZReport: Integer;
    function DrvPrintDocumentTitle: Integer;
    function DrvFinishDocument: Integer;
    function DrvOpenShift: Integer;
    function DrvFNOpenShift: Integer;
    function DrvFNCloseShift: Integer;
    function DrvPrintString: Integer;
    function DrvFNCloseCheck: Integer;
    function DrvFNBuildCalculationStateReport: Integer;
    function DrvDiscountTaxOperation: Integer;
    procedure SafeOpenCheck;
    procedure PrintAndWait(Method: TDriverFunc; AWaitError: Boolean = False);
    procedure PrintTaxReport;
    procedure PrintDepartmentReport;
    property Logger: TLogger read GetLogger;
    property ID: Integer read FID;
    property Name: WideString read GetName;
    property Port: Integer read FParams.Port;
    property BaudRate: Integer read FParams.BaudRate;
    property Timeout: Integer read FParams.Timeout;
    property IPAddress: WideString read FParams.IPAddress;
    property TCPPort: Integer read FParams.TCPPort;
    property LogEnabled: Boolean read FParams.LogEnabled;
    property UserPassword: Integer read FUserPassword;
    property AdminPassword: Integer read FParams.AdminPassword;
    property IsFiscalCheck: Boolean read FIsFiscalCheck;
    property IsReturnCheck: Boolean read FIsReturnCheck;
    property IsOpenedCheck: Boolean read FIsOpenedCheck;
    property CloseSession: Boolean read FParams.CloseSession;
    property EnablePaymentSignPrint: Boolean read FParams.EnablePaymentSignPrint;
    property Tax: T1CTax read FTax;
    property NonFiscalCheckNumber: Integer read FNonFiscalCheckNumber;
    property SerialNumber: WideString read FSerialNumber;
    property LineLength: Integer read FLineLength;
    property TaxProgrammed: Boolean read FTaxProgrammed;
    property PrintCloseCheck: Boolean read FPrintCloseCheck;
    property Paynames: T1CPayNames read FParams.Paynames;
    property PayProgrammed: Boolean read FPayProgrammed;
    property CapOpenCheck: Boolean read FCapOpenCheck;
    property CapGetShortECRStatus: Boolean read FCapGetShortECRStatus;
    property PrintLogo: Boolean read FPrintLogo;
    property LogoSize: Integer read FLogoSize;
    property ConnectionType: Integer read FParams.ConnectionType;
    property ComputerName: WideString read FParams.ComputerName;
    property UseIPAddress: Boolean read FUseIPAddress;
    property ProtocolType: Integer read FParams.ProtocolType;
    property BufferStrings: Boolean read FBufferStrings;
    property LogFileName: WideString read FParams.LogFileName;
    property BarcodeFirstLine: Integer read FParams.BarcodeFirstLine;
    property QRCodeHeight: Integer read FParams.QRCodeHeight;
    property QRCodeDotWidth: Integer read FParams.QRCodeDotWidth;
    property TaxCount: Integer read FTaxCount write FTaxCount;
    property Params: TDeviceParams17 read FParams write FParams;
  end;

implementation

uses
  Types;

const
  MUL = #$0B;
  EQU = #$1F;
  TaxRatesTable: array[1..6] of Integer = (2000, 1000, 0, 0, 2000, 1000);

function SpeedToBaudrate(ABaudrate: Integer): Integer;
begin
  Result := 0;
  case ABaudrate of
    2400:
      Result := 0;
    4800:
      Result := 1;
    9600:
      Result := 2;
    19200:
      Result := 3;
    38400:
      Result := 4;
    57600:
      Result := 5;
    115200:
      Result := 6;
    230400:
      Result := 7;
    460800:
      Result := 8;
    921600:
      Result := 9;
  else
    RaiseError(E_INVALIDPARAM, Tnt_WideFormat('%s %s', [GetRes(@SInvalidParam), '"Speed"']));
  end;
end;

{ TDevices1C }

constructor TDevices1C.Create(ADriver: TDrvFR);
begin
  inherited Create;
  FList := TList.Create;
  FDriver := ADriver;
end;

destructor TDevices1C.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TDevices1C.Clear;
begin
  while Count > 0 do
    Items[0].Free;
end;

function TDevices1C.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TDevices1C.GetItem(Index: Integer): TDevice1C;
begin
  Result := FList[Index];
end;

procedure TDevices1C.InsertItem(AItem: TDevice1C);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TDevices1C.RemoveItem(AItem: TDevice1C);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TDevices1C.Add: TDevice1C;
begin
  Result := TDevice1C.Create(Self);
end;

function TDevices1C.GetFreeID: Integer;
begin
  Result := 1;
  while True do
  begin
    if IsFreeID(Result) then
      Exit;
    Inc(Result);
  end;
end;

function TDevices1C.IsFreeID(ID: Integer): Boolean;
begin
  Result := ItemByID(ID) = nil;
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

{ TDevice1C }

constructor TDevice1C.Create(AOwner: TDevices1C);
begin
  inherited Create;
  FID := 0;
  SetOwner(AOwner);
  if AOwner <> nil then
    FID := AOwner.GetFreeID;
  FParamsReg := TDriver1CParams.Create;
  FODClient := TODClient.Create;
end;

destructor TDevice1C.Destroy;
begin
  Driver.Disconnect;
  SetOwner(nil);
  FParamsReg.Free;
  FODClient.Free;
  FLogger.Free;
//  FDriver.Free;
  inherited Destroy;
end;

procedure TDevice1C.SetOwner(AOwner: TDevices1C);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then
      FOwner.RemoveItem(Self);
    if AOwner <> nil then
      AOwner.InsertItem(Self);
  end;
end;

procedure TDevice1C.LockPort;
begin
  Logger.Debug('LockPort');
  Logger.Debug(Format('LockTimeout=%d', [Driver.LockTimeout]));

//  Driver.LockTimeout := 10000;
//  Logger.Debug(Format('Set LockTimeout=%d', [Driver.LockTimeout]));
  Check(Driver.LockPortTimeout);
end;

procedure TDevice1C.UnlockPort;
begin
  if not FIsOpenedCheck then
    Driver.UnlockPort;
end;

procedure TDevice1C.SaveToReg;
begin
  FParamsReg.WriteCheckNumber(FSerialNumber, FNonFiscalCheckNumber);
end;

function TDevice1C.GetLogger: TLogger;
begin
  if FLogger = nil then
    FLogger := TLogger.Create(Self.ClassName);
  Result := FLogger;
end;

function TDevice1C.GetDriver: TDrvFR;
begin
  Result := FOwner.FDriver;
end;

function TDevice1C.GetName: WideString;
begin
  Result := IntToStr(ID);
end;

function TDevice1C.CheckGetPassword(APassword, AMessage: string): Integer;
begin
  Result := 0;
  try
    Result := StrToInt(APassword);
  except
    RaiseError(E_INVALIDPARAM, Tnt_WideFormat(SINvalidPropValue, [AMessage]));
  end;
end;

procedure TDevice1C.Assign(const Device: TDevice1C);
begin
  FIsFiscalCheck := Device.IsFiscalCheck;
  FIsReturnCheck := Device.IsReturnCheck;
  FCapGetShortECRStatus := Device.CapGetShortECRStatus;
  FPayProgrammed := Device.PayProgrammed;
  FCapOpenCheck := Device.CapOpenCheck;
  FParams.CloseSession := Device.CloseSession;
  FPrintLogo := Device.PrintLogo;
  FIsOpenedCheck := Device.IsOpenedCheck;
  FTaxProgrammed := Device.TaxProgrammed;
  FPrintCloseCheck := Device.PrintCloseCheck;
  FLineLength := Device.LineLength;
  FNonFiscalCheckNumber := Device.NonFiscalCheckNumber;
  FParams.AdminPassword := Device.AdminPassword;
  FUserPassword := Device.UserPassword;
  FLogoSize := Device.LogoSize;
  FSerialNumber := Device.SerialNumber;
  FParams.Paynames := Device.Paynames;
  FTax := Device.Tax;
  FParams.LogEnabled := Device.LogEnabled;
  FParams.LogFileName := Device.LogFileName;
  FParams.Timeout := Device.Timeout;
  FParams.Port := Device.Port;
  FParams.BaudRate := Device.BaudRate;
  FParams.TCPPort := Device.TCPPort;
  FParams.IPAddress := Device.IPAddress;
  FParams.ConnectionType := Device.ConnectionType;
  FBufferStrings := Device.BufferStrings;
  FParams.ComputerName := Device.ComputerName;
  FUseIPAddress := Device.UseIPAddress;
  FParams.ProtocolType := Device.ProtocolType;
  FParams.BarcodeFirstLine := Device.BarcodeFirstLine;
  FParams.QRCodeHeight := Device.QRCodeHeight;
  FParams.QRCodeDotWidth := Device.QRCodeDotWidth;
end;

procedure TDevice1C.SetParam(const Name: WideString; Value: Variant);
begin
  Logger.Debug('SetParam ' + Name + VarToStr(Value));
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
  if WideSameStr('EnableLog', Name) then
    FParams.LogEnabled := (WideSameText('True', Value)) or (WideSameText('1', Value));
  if WideSameStr('LogFileName', Name) then
  begin
    Logger.Debug('LogFName = ' + Value);
    FParams.LogFileName := Value;
  end;

  if WideSameStr('CloseSession', Name) then
    FParams.CloseSession := WideSameText(Value, 'True');
  if WideSameStr('PayName1', Name) then
    FParams.Paynames[1] := Value;
  if WideSameStr('PayName2', Name) then
    FParams.Paynames[2] := Value;
  if WideSameStr('PayName3', Name) then
    FParams.Paynames[3] := Value;



  if WideSameStr('Tax1', Name) then
    FTax[1] := Value;
  if WideSameStr('Tax2', Name) then
    FTax[2] := Value;
  if WideSameStr('Tax3', Name) then
    FTax[3] := Value;
  if WideSameStr('Tax4', Name) then
    FTax[4] := Value;

  //if WideSameStr('Codepage', Name) then
  //FCodepage := Value;
  if WideSameStr('BarcodeFirstLine', Name) then
    FParams.BarcodeFirstLine := Value;
  if WideSameStr('QRCodeHeight', Name) then
    FParams.QRCodeHeight := Value;
  //FCodepage := 1; //Russian
end;

procedure TDevice1C.SetParams(const Params: T1CDriverParams);
begin
  if not Params.ConnectionType in [0..6] then
    RaiseError(E_INVALIDPARAM, Tnt_WideFormat('%s %s', [GetRes(@SInvalidParam), '"ConnectionType"']));

  if (Params.TCPPort < 0) then
    RaiseError(E_INVALIDPARAM, Tnt_WideFormat('%s %s', [GetRes(@SInvalidParam), '"TCPPort"']));
  FParams.Port := Params.Port;
  FParams.BaudRate := Params.Speed;
  FParams.Timeout := Params.Timeout;
  FParams.IPAddress := Params.IPAddress;
  FUseIPAddress := Params.IPAddress <> '';
  FParams.TCPPort := Params.TCPPort;
  FParams.LogEnabled := Params.EnableLog;
  FUserPassword := CheckGetPassword(Params.UserPassword, 'UserPassword');
  FParams.AdminPassword := CheckGetPassword(Params.AdminPassword, 'AdminPassword');
  FParams.CloseSession := Params.CloseSession;
  FTax := Params.Tax;
  FParams.Paynames := Params.PayNames;
  FSerialNumber := Params.SerialNumber;
  FPrintLogo := Params.PrintLogo;
  FLogoSize := Params.LogoSize;
  FParams.ConnectionType := Params.ConnectionType;
  FParams.ProtocolType := Params.ProtocolType;
  FBufferStrings := Params.BufferStrings;
//  FCodepage := Params.Codepage;
  FTaxProgrammed := False;
  FPrintCloseCheck := False;
  FPayProgrammed := False;
  FParams.BarcodeFirstLine := Params.BarcodeFirstLine;
  FParams.QRCodeHeight := Params.QRCodeHeight;
  if Params.PrintLogo then
    if (Params.LogoSize < 1) or (Params.LogoSize > 1200) then
      RaiseError(E_INVALIDPARAM, GetRes(@SInvalidLogoHeight));

end;

procedure TDevice1C.Check(AResultCode: Integer);
begin
  if AResultCode <> 0 then
  begin
    RaiseError(AResultCode, GetResultCodeDescription(AResultCode));
  end;
end;

function TDevice1C.GetResultCodeDescription(ResultCode: Integer): WideString;
begin
  Result := Driver.ResultCodeDescription;
  case ResultCode of
    E_NOPAPER:
      Result := SNoPaper;
    $73, $C7:
      if GetStatus = 0 then
        Result := Tnt_WideFormat('%s (%s)', [Result, Driver.ECRModeDescription]);
    $72:
      if GetStatus = 0 then
        Result := Tnt_WideFormat('%s (%s)', [Result, Driver.ECRAdvancedModeDescription]);

    $4F:
      if FUseAdminPassword then
        Result := SInvalidAdminPassword
      else
        Result := SInvalidUserPassword;
  end;
end;

procedure TDevice1C.SetAdminPassword;
begin
  Driver.Password := FParams.AdminPassword;
  FUseAdminPassword := True;
end;

procedure TDevice1C.CancelAnyCheck;
begin
  SetAdminPassword;
  if FIsOpenedCheck and (not FIsFiscalCheck) then
  begin
    Check(Driver.GetECRStatus);
    if (Driver.ECRMode = 8) and (Driver.ECRMode8Status = 4) then
    begin
      CancelReceipt;
    end
    else
    begin
      // Opened nonfiscal receipt
      Driver.UseReceiptRibbon := True;
      Driver.UseJournalRibbon := True;
      Driver.StringForPrinting := SReceiptCancelled;
      PrintAndWait(DrvPrintString, True);
      FeedAndCut;
      Check(Driver.GetShortECRStatus);
    end;
  end
  else
  begin
    CancelReceipt;
  end;
  // Установили флаг
  FIsOpenedCheck := False;
end;

procedure TDevice1C.CancelCheck;
begin
  LockPort;
  try
    CancelAnyCheck;
  finally
    UnlockPort;
  end;
end;

function TDevice1C.GetStatus: Integer;
begin
  Result := Driver.GetShortECRStatus;
end;

procedure TDevice1C.FeedAndCut;
var
  Res: Integer;
begin
  SetAdminPassword;
  Driver.StringQuantity := 8;
  Driver.UseSlipDocument := False;
  Driver.UseJournalRibbon := True;
  Driver.UseReceiptRibbon := True;
  Driver.CarryStrings := True;
  Driver.DelayedPrint := False;
  Check(Driver.FeedDocument);
  if CapCut then
  begin
    Driver.CutType := True;
    Res := Driver.CutCheck;
    if Res <> $37 then // Если не поддерживается - ничего не делаем
      Check(Res);
  end;
end;

function TDevice1C.IsPrinterRecOpened: Boolean;
begin
  Check(GetStatus);
  Result := Driver.ECRMode = ECRMODE_RECOPENED;
end;

procedure TDevice1C.SetUserPassword;
begin
  Driver.Password := FParams.AdminPassword; //FUserPassword;
//  FUseAdminPassword := False;
end;

procedure TDevice1C.CancelReceipt;
begin
  if IsPrinterRecOpened then
  begin
    if Driver.ECRMode = 8 then
    begin
      SetAdminPassword;
      Check(DrvSysAdminCancelCheck);
      WaitForPrinting;
    end;
  end;
end;

procedure TDevice1C.ApplyDeviceParams;
begin
  Logger.Debug('Baudrate =' + IntToStr(SpeedToBaudrate(FParams.BaudRate)));
  Logger.Debug('ApplyDeviceParams11');

//  Driver.CodePage := FCodepage;
  Driver.ConnectionType := FParams.ConnectionType;
  Driver.ProtocolType := FParams.ProtocolType;
  Driver.ComNumber := FParams.Port;

  Driver.Baudrate := SpeedToBaudrate(FParams.BaudRate);

  Driver.TimeOut := FParams.Timeout;
  Driver.IPAddress := FParams.IPAddress;
  Driver.TCPPort := FParams.TCPPort;
  Driver.TCPConnectionTimeout := FParams.Timeout;
  Driver.UseIPAddress := FParams.IPAddress <> '';
  Driver.ComputerName := FParams.ComputerName;
  Logger.Debug('LogFileName: ' + FParams.LogFileName);
  if FParams.LogFileName <> '' then
    Driver.ComLogFile := FParams.LogFileName;
  Logger.Debug('Driver ComLogFile: ' + Driver.ComLogFile);
  Driver.LogOn := FParams.LogEnabled;
end;

procedure TDevice1C.Close;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data Close');
    Exit;
  end;
  SetAdminPassword;
  Driver.Disconnect;
end;

procedure TDevice1C.Disconnect;
begin
  if FParams.ODEnabled then Exit;
  Driver.Disconnect;
end;

procedure TDevice1C.CheckReceiptOpened;
begin
  if not FIsOpenedCheck then
    RaiseError(C_ERR_CHECKCLOSED, GetRes(@SReceiptClosedOperationInvalid));
end;

procedure TDevice1C.CloseCheck(Cash, PayByCard, PayByCredit, PayBySertificate, DiscountOnCheck: Double);
begin
  LockPort;
  try
    SetUserPassword;
    CheckReceiptOpened;
    if FIsFiscalCheck then
    begin
      CheckPrinterRecOpened;
      Driver.Summ1 := Cash;
      Driver.Summ2 := PayByCard;
      Driver.Summ3 := PayByCredit;
      Driver.Summ4 := PayBySertificate;
{      if CapCashCore and FBufferStrings then
        Driver.StringForPrinting := FStringForPrinting
      else}
      Driver.StringForPrinting := '';
      Driver.DiscountOnCheck := DiscountOnCheck;
      Driver.Tax1 := 0;
      Driver.Tax2 := 0;
      Driver.Tax3 := 0;
      Driver.Tax4 := 0;
      PrintAndWait(DrvCloseCheck);
    end
    else
    begin
      if CapNonFiscalDocument then
        Check(Driver.CloseNonFiscalDocument);
      PrintAndWait(DrvFinishDocument);

      if FNonFiscalCheckNumber = 9999 then
        FNonFiscalCheckNumber := 1
      else
        FNonFiscalCheckNumber := FNonFiscalCheckNumber + 1;
      SaveToReg; // Сохраняем номер нефискального чека в реестр
    end;
    FIsOpenedCheck := False;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.CheckPrinterRecOpened;
begin
  if not IsPrinterRecOpened then
    RaiseError(C_ERR_CHECKCLOSED, GetRes(@SReceiptClosedOperationInvalid));
end;

procedure TDevice1C.CheckReceiptClosed;
begin
  if FIsOpenedCheck then
    RaiseError(C_ERR_CHECKOPENED, GetRes(@SReceiptOpenedOperationInvalid));

  if IsPrinterRecOpened then
    RaiseError(C_ERR_CHECKOPENED, GetRes(@SReceiptOpenedOperationInvalid));
end;

procedure TDevice1C.CashInOutcome(Amount: Double);
//var
//  Res: Integer;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data CashInOutcome');
    Exit;
  end;

  SetAdminPassword;
  LockPort;
  try
    WaitForPrinting;
    CheckReceiptClosed;
    Driver.Summ1 := Abs(Amount);
    if Amount >= 0 then
      PrintAndWait(DrvCashIncome)
    else
      PrintAndWait(DrvCashOutcome);
    WaitForPrinting;
    {// По требованию 1С смену нужно открывать принудительно после операций
    //внесения/выемки
    if not IsSessionOpened then
    begin
      Res := Driver.OpenSession;
      if Res <> $37 then
        Check(Res);
    end;}
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.CashInOutcome22(Amount: Double;
  const InputParameters: WideString);
var
  Params: TInputParametersRec;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data CashInOutcome');
    Exit;
  end;
  Logger.Debug(InputParameters);
  ParseInputParameters(InputParameters, Params);
  SetAdminPassword;
  LockPort;
  try
    WaitForPrinting;
    CheckReceiptClosed;
    SetCashierPassword(Params.CashierName);
    Driver.Summ1 := Abs(Amount);
    if Amount >= 0 then
      PrintAndWait(DrvCashIncome)
    else
      PrintAndWait(DrvCashOutcome);
    WaitForPrinting;
    {// По требованию 1С смену нужно открывать принудительно после операций
    //внесения/выемки
    if not IsSessionOpened then
    begin
      Res := Driver.OpenSession;
      if Res <> $37 then
        Check(Res);
    end;}
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.OpenCheck(IsFiscalCheck, IsReturnCheck, CancelOpenedCheck: WordBool; var ACheckNumber, ASessionNumber: Integer);
var
  Res: Integer;
begin
  LockPort;
  try
    FStringForPrinting := '';
    SetUserPassword;
    WaitForPrinting;

    if CancelOpenedCheck then
    begin
      CancelAnyCheck;
    end;

    CheckReceiptClosed;

    SetUserPassword;

    if FPrintLogo then
    begin
      if (FLogoSize < 1) or (FLogoSize > 1200) then
        RaiseError(E_INVALIDPARAM, GetRes(@SInvalidLogoHeight));

      Driver.ModelParamNumber := mpFirstDrawLine;
      Check(Driver.ReadModelParamValue);
      Driver.FirstLineNumber := Driver.ModelParamValue;
      Driver.LastLineNumber := FLogoSize + Driver.FirstLineNumber - 1;
      Res := Driver.DrawEx;
      if Res = $37 then
        RaiseError(E_NOTSUPPORTED, GetRes(@SInvalidLogoNotSupported))
      else
        Check(Res);
    end;

    if IsFiscalCheck then
    begin
      // Фискальный чек
      if IsReturnCheck then
        Driver.CheckType := 2
      else
        Driver.CheckType := 0;
      SafeOpenCheck;
      WaitForPrinting;
    end
    else
    begin
        // Нефискальный чек
      Driver.DocumentName := GetRes(@SNonfiscalDocumentName);
      Driver.DocumentNumber := FNonFiscalCheckNumber;
      PrintAndWait(DrvPrintDocumentTitle);
    end;
    FIsFiscalCheck := IsFiscalCheck;
    FIsReturnCheck := IsReturnCheck;
    FIsOpenedCheck := True;
    Check(Driver.GetECRStatus);
    ACheckNumber := Driver.OpenDocumentNumber + 1;
    ASessionNumber := Driver.SessionNumber + 1;
    if CapNonFiscalDocument then
      Check(Driver.OpenNonfiscalDocument);
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.OpenCheckFN(const ACashierName: WideString; CheckType: Integer; CancelOpenedCheck: WordBool; var ACheckNumber, ASessionNumber: Integer);
begin
  LockPort;
  try
    if FSessionRegOpened then Exit;
    FStringForPrinting := '';

    Check(Driver.GetShortECRStatus);

    if CancelOpenedCheck then
    begin
      if Driver.ECRAdvancedMode = 3 then
        CheckStatus;
      if Driver.ECRMode = ECRMODE_RECOPENED then
      begin
        Check(DrvSysAdminCancelCheck);
        WaitForPrinting;
      end;
      FIsOpenedCheck := False;
    end
    else
      CheckReceiptClosed;

    SetCashierPassword(ACashierName);

    case CheckType of
      1:
        Driver.CheckType := 0;
      2:
        Driver.CheckType := 2;
      3:
        Driver.CheckType := 1;
      4:
        Driver.CheckType := 3;
    end;
    FRecType := CheckType;
    SafeOpenCheck;
    FIsFiscalCheck := True;
    FIsOpenedCheck := True;
    Check(Driver.GetECRStatus);
    ACheckNumber := Driver.OpenDocumentNumber + 1;
    ASessionNumber := Driver.SessionNumber + 1;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.ProgramPayNames;

  { Программирвоание поля таблицы }

  function WritePayName(AIndex: Integer): Integer;
  var
    Name: string;
  begin
    Driver.TableNumber := 5;
    Name := FParams.PayNames[AIndex];
    Driver.RowNumber := AIndex + 1;
    Driver.FieldNumber := 1;
    Driver.ValueOfFieldString := Name;
    Result := Driver.WriteTable;
  end;

var
  i: Integer;
  Name: string;
  s: string;
begin
  if FPayProgrammed then
    Exit;
  SetAdminPassword;
  // Сравниваем значения наименований
  Driver.TableNumber := 5;
  for i := 1 to 3 do
  begin
    Name := FParams.PayNames[i];
    // Если пустое - оставляем как было
    if Name = '' then
      Continue;
    Driver.RowNumber := i + 1;
    Driver.FieldNumber := 1;
    Check(Driver.ReadTable);
    s := Driver.ValueOfFieldString;
    if s <> Name then
      Check(WritePayName(i));
  end;
  FPayProgrammed := True;
end;

function TDevice1C.IsSessionOpened: Boolean;
begin
  Check(GetStatus);
  Result := Driver.ECRMode <> 4;
end;

procedure TDevice1C.PrintFiscalString(const AName: WideString; AQuantity, APrice, AAmount: Double; ADepartment: Integer; ATax: Single);
var
  Summ: Int64;
  ItemQuantity, ItemPrice, ItemAmount: Int64;
begin
  CheckReceiptOpened;
  LockPort;
  try
    SetAdminPassword;
    // Сумма скидки или надбавки
    ItemQuantity := Round2(Abs(AQuantity * 1000));
    ItemPrice := Round2(Abs(APrice * 100));
    ItemAmount := Round2(Abs(AAmount * 100));

    Summ := ItemAmount - Round2(ItemPrice * ItemQuantity / 1000);

    // Открыт нефискальный чек
    if not FIsFiscalCheck then
      RaiseError(C_ERR_CHECKOPENED, GetRes(@SInvalidOperationInNonfiscalDocument));

    //WaitForPrinting;
    // Продажа
    Driver.Tax1 := CheckTaxOld(ATax);
    Driver.Tax2 := 0;
    Driver.Tax3 := 0;
    Driver.Tax4 := 0;
//    PrintText(AName, True);
{    if CapCashCore and FBufferStrings then
      Driver.StringForPrinting := FStringForPrinting
    else}
    Driver.StringForPrinting := AName;
    Driver.Price := ItemPrice / 100;
    Driver.Quantity := ItemQuantity / 1000;
    Driver.Department := ADepartment;
    if FIsReturnCheck then
      PrintAndWait(DrvReturnSale)
    else
      PrintAndWait(DrvSale);
    FStringForPrinting := '';
    // Назначаем скидку или надбавку
    Logger.Debug(Format('Summ = %d', [Summ]));
    if Abs(Summ) > 0 then
    begin
      SetUserPassword;
      Driver.Summ1 := Abs(Summ / 100);
      Driver.Tax1 := CheckTaxOld(ATax);
      Driver.Tax2 := 0;
      Driver.Tax3 := 0;
      Driver.Tax4 := 0;
      Driver.StringForPrinting := '';
      if Summ < 0 then
        PrintAndWait(DrvDiscount)
      else
        PrintAndWait(DrvCharge);
    end;
  finally
    UnlockPort;
  end;
end;


function TDevice1C.CheckTaxOld(ATax: Single): Integer;
var
  Tax: Integer;
  i: Integer;
begin
  Logger.Debug('CheckTaxOld');
  Tax := Round2(ATax * 100);
  Logger.Debug('ATax = ' + IntToStr(Tax));
  Result := 0;
  if Tax = 0 then
    Exit;
  for i := 1 to 4 do
  begin
    Logger.Debug('FTax[' + IntToStr(i) + '] ' + IntToStr(Round2(FTax[i] * 100)));
    if Tax = Round2(FTax[i] * 100) then
    begin
      Result := i;
      Exit;
    end;
  end;
  RaiseError(E_INVALIDPARAM, Format('%s (%.2f%%)', [SInvalidTaxRate, ATax]));
end;

{function TDevice1C.CheckTax(ATax: Single): Integer;
var
  Tax: Integer;
  i: Integer;
begin
  Tax := Round2(ATax * 100);
  Result := 0;
  if Tax = 0 then
    Exit;
  for i := 1 to 4 do
  begin
    if Tax = TaxRatesTable[i] then
    begin
      Result := i;
      Exit;
    end;
  end;
  RaiseError(E_INVALIDPARAM, Tnt_WideFormat('%s (%.2f%%)', [GetRes(@SInvalidTaxRate), ATax]));
end;}

procedure TDevice1C.PrintText(const Text: WideString; AWrapString: Boolean = False);
begin
  if PrintCharge(Text) then
    Exit;
  if PrintDiscount(Text) then
    Exit;
  PrintText2(Text, AWrapString);
end;

function TDevice1C.PrintDiscount(const Text: WideString): Boolean;
const
  TagDiscount = '&discount;';
  Delimiters =[';'];
var
  S: string;
  Discount: TDiscountRec;
begin
  Result := False;
  if Pos(TagDiscount, Text) = 1 then
  begin
    S := Copy(Text, Length(TagDiscount) + 1, Length(Text));
    Discount.Amount := StrToCurrency(GetString(S, 1, Delimiters));
    Discount.Tax1 := GetInteger(S, 2, Delimiters);
    Discount.Tax2 := GetInteger(S, 3, Delimiters);
    Discount.Tax3 := GetInteger(S, 4, Delimiters);
    Discount.Tax4 := GetInteger(S, 5, Delimiters);
    Discount.Text := GetString(S, 6, Delimiters);

    Driver.Summ1 := Discount.Amount;
    Driver.Tax1 := Discount.Tax1;
    Driver.Tax2 := Discount.Tax2;
    Driver.Tax3 := Discount.Tax3;
    Driver.Tax4 := Discount.Tax4;
    Driver.StringForPrinting := Discount.Text;
    PrintAndWait(DrvDiscount);
    Result := True;
  end;
end;

function TDevice1C.PrintCharge(const Text: WideString): Boolean;
const
  TagCharge = '&charge;';
  Delimiters =[';'];
var
  S: string;
  Discount: TDiscountRec;
begin
  Result := False;
  if Pos(TagCharge, Text) = 1 then
  begin
    S := Copy(Text, Length(TagCharge) + 1, Length(Text));
    Discount.Amount := StrToCurrency(GetString(S, 1, Delimiters));
    Discount.Tax1 := GetInteger(S, 2, Delimiters);
    Discount.Tax2 := GetInteger(S, 3, Delimiters);
    Discount.Tax3 := GetInteger(S, 4, Delimiters);
    Discount.Tax4 := GetInteger(S, 5, Delimiters);
    Discount.Text := GetString(S, 6, Delimiters);

    Driver.Summ1 := Discount.Amount;
    Driver.Tax1 := Discount.Tax1;
    Driver.Tax2 := Discount.Tax2;
    Driver.Tax3 := Discount.Tax3;
    Driver.Tax4 := Discount.Tax4;
    Driver.StringForPrinting := Discount.Text;
    PrintAndWait(DrvCharge);
    Result := True;
  end;
end;

procedure TDevice1C.PrintText2(const AStr: WideString; AWrapString: Boolean = False);
var
  i: Integer;
  SL: TStringList;
  Str: WideString;
begin
  Str := ReplaceDelimeter(AStr);
  Driver.CarryStrings := False;
  Driver.DelayedPrint := False;
  Driver.UseReceiptRibbon := True;
  Driver.UseJournalRibbon := True;
{  if FIsOpenedCheck and CapCashCore and FBufferStrings then
  begin
    if Length(FStringForPrinting) + Length(Str) > 240 then
    begin
      Driver.StringForPrinting := FStringForPrinting;
      PrintAndWait(DrvPrintString, True);
      FStringForPrinting := Str;
    end
    else
    begin
      if FStringForPrinting <> '' then
        FStringForPrinting := FStringForPrinting + #$0A + Str
      else FStringForPrinting := Str;
    end;
  end
  else
  if CapCashCore then
  begin
    Driver.StringForPrinting := Str;
    PrintAndWait(DrvPrintString, True);
  end
  else }
  begin
    SL := TStringList.Create;
    try
      if Str = '' then
        SL.Text := ' '
      else
        SL.Text := Str;
      for i := 0 to SL.Count - 1 do
      begin
        if AWrapString then
          PrintStringWithWrap(SL[i])
        else
          PrintStringWithWrap(Copy(SL[i], 1, FLineLength));
      end;
    finally
      SL.Free;
    end;
  end;
end;

procedure TDevice1C.PrintNonFiscalString(const TextString: WideString);
begin
  PrintText(TextString, True);
end;

procedure TDevice1C.PrintXReport;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data PrintXReport');
    Exit;
  end;
  Logger.Debug('PrintXReport');
  CheckReceiptClosed;
  LockPort;
  try
    SetAdminPassword;
    PrintAndWait(DrvPrintXReport);
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.PrintZReport;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data PrintZReport');
    Exit;
  end;
  Logger.Debug('PrintZReport');
  CheckReceiptClosed;
  LockPort;
  try
    SetAdminPassword;
    PrintAndWait(DrvPrintZReport);
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.CheckPrintingStatus;
begin
  LockPort;
  try
    SetUserPassword;
    Check(GetStatus);
    case Driver.ECRAdvancedMode of
      1, 2:
        RaiseError($6B, GetRes(@SNoPaper));
      3:
        RaiseError($6B, GetRes(@SPrintInProgress));
    end;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.ContinuePrinting;
begin
  LockPort;
  try
    SetUserPassword;
    Check(GetStatus);
    if Driver.ECRAdvancedMode = 3 then
    begin
      Check(Driver.ContinuePrint);
      WaitForPrinting;
    end;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.OpenCashDrawer(CashDrawerID: Integer);
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data OpenCashDrawer');
    Exit;
  end;

  LockPort;
  try
    SetUserPassword;
    Driver.DrawerNumber := CashDrawerID;
    Check(Driver.OpenDrawer)
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.OpenSession;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data OpenSession');
    Exit;
  end;

  LockPort;
  try

{    // Убираем "Печать по закрытию чека"
    if not FPrintCloseCheck then
      ProgramPrintCloseCheck;}

    // Программируем налоговые ставки
//    if not FTaxProgrammed then
//      ProgramTax;

    // Программируем наименования типов оплат
//    if not FPayProgrammed then
//      ProgramPayNames;

    SetUserPassword;

    Driver.ModelParamNumber := mpModelID;
    Check(Driver.ReadModelParamValue);
    if Driver.ModelParamValue <> 6 then //ЭЛВЕС-ФР-К
      Check(Driver.OpenSession);
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.DeviceControl(const TxData: WideString; var RxData: WideString);
begin
  LockPort;
  try
    RxData := '';
    Driver.TransferBytes := TxData;
    Check(Driver.ExchangeBytes);
    RxData := Driver.TransferBytes;
  finally
    UnlockPort;
  end;
end;

function TDevice1C.GetLineLength: Integer;
begin
  Result := 40;
  if FParams.ODEnabled then Exit;
  LockPort;
  try
    SetAdminPassword;
    Driver.FontType := FParams.CheckFontNumber;
    if Driver.FontType = 0 then
      Driver.FontType := 1;
    Check(Driver.GetFontMetrics);
    Result := 0;
    if Driver.CharWidth <> 0 then
      Result := Trunc(Driver.PrintWidth / Driver.CharWidth);
  finally
    UnlockPort;
  end;
end;

resourcestring
  SBarcodeUnsupported = 'Тип штрихкода не поддерживается';

procedure TDevice1C.PrintBarCode(const BarcodeType, Barcode: WideString);
var
  res: Integer;
begin
  LockPort;
  try
    if BarcodeType = WideString('EAN13') then
    begin
      Driver.BarCode := Barcode;
      res := Driver.PrintBarCode;
      if res <> 55 then
        Check(res);
    end
    else if BarcodeType = WideString('QR') then
    begin
      Logger.Debug('QRCodeDotWidth: ' + IntToStr(FParams.QRCodeDotWidth));
      if (FParams.QRCodeDotWidth < 3) or (FParams.QRCodeDotWidth > 8) then
        FParams.QRCodeDotWidth := 5;
      Driver.BarcodeFirstLine := FParams.BarcodeFirstLine;
      Driver.LineNumber := FParams.QRCodeHeight;
      Driver.BarcodeType := 3;
      Driver.Barcode := Barcode;
      Driver.BarcodeParameter1 := 0;
      Driver.BarcodeParameter2 := 0;
      Driver.BarcodeParameter3 := FParams.QRCodeDotWidth;
      Driver.BarcodeParameter4 := 0;
      Driver.BarcodeParameter5 := 0;
      Driver.DelayedPrint := False;
      Check(Driver.LoadAndPrint2DBarcode);
    end
    else
    begin
      Driver.StringForPrinting := 'Ошибка печати штрихкода';
      Driver.FontType := FParams.CheckFontNumber;
      Check(Driver.PrintString);
      Check(Driver.WaitForPrinting);
        //raise Exception.Create(SBarcodeUnsupported);
    end;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.Open(const ValuesArray: IDispatch);
var
  V: Variant;
  Params: T1CDriverParams;
begin
  Params := ReadValuesArray(ValuesArray);
  Logger.Debug('TCPPort: ' + IntToStr(Params.TCPPort));
  SetParams(Params);

  Check(Driver.Disconnect);
  ApplyDeviceParams;
  FParams.Paynames[3] := '';
  SetUserPassword;
  LockPort;
  try
    CheckStatus;
    FLineLength := 40;
    // Получаем длину строки
    SetAdminPassword;
    Driver.FontType := 1;

    Check(Driver.GetFontMetrics);
    if Driver.CharWidth <> 0 then
      FLineLength := Trunc(Driver.PrintWidth / Driver.CharWidth);
    FCapOpenCheck := Driver.CapOpenCheck;
    FCapGetShortECRStatus := Driver.CapGetShortECRStatus;
    Driver.ModelParamNumber := mpCapFN;
    Check(Driver.ReadModelParamValue);
    FOldKKT := not Driver.ModelParamValue;
    ProgramPayNames;
    SetUserPassword;
    Check(Driver.GetECRStatus);
    FSerialNumber := Driver.SerialNumber;
    LoadFromReg;
    try
      V := ValuesArray;
      V.set(DRVFR_VALUE_INDEX_SERIALNUMBER, string(Driver.SerialNumber));
    except
      RaiseError(E_UNKNOWN, Tnt_WideFormat('%s "%s"', [GetRes(@SValuesArrayWriteError), 'SerialNumber']));
    end;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.Open2;
begin
  Check(Driver.Disconnect);
  ApplyDeviceParams;
  SetUserPassword;
  LockPort;
  try
    CheckStatus;
    FLineLength := 40;
    // Получаем длину строки
    SetAdminPassword;
    Driver.FontType := 1;
    Check(Driver.GetFontMetrics);
    if Driver.CharWidth <> 0 then
      FLineLength := Trunc(Driver.PrintWidth / Driver.CharWidth);
    FCapOpenCheck := Driver.CapOpenCheck;
    FCapGetShortECRStatus := Driver.CapGetShortECRStatus;
    Driver.ModelParamNumber := mpCapFN;
    Check(Driver.ReadModelParamValue);
    FOldKKT := not Driver.ModelParamValue;
    ProgramPayNames;
    SetUserPassword;
    Check(Driver.GetECRStatus);
    FSerialNumber := Driver.SerialNumber;
    LoadFromReg;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.Open3;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data Open');
    Exit;
  end;
  LockPort;
  try
    Logger.Debug('Open3');
    FOldKKT := False;
    Check(Driver.Disconnect);
    ApplyDeviceParams;
    SetAdminPassword;
    CheckStatus;
    if Driver.ECRMode = ECRMODE_RECOPENED then
    begin
      if Driver.ECRMode8Status = 4 then
        Check(Driver.CloseNonFiscalDocument)
      else
        Check(DrvSysAdminCancelCheck);
//      WaitForPrinting;
    end;
    FIsOpenedCheck := False;
    FLineLength := 40;
    // Получаем длину строки
    SetAdminPassword;
    Driver.FontType := FParams.CheckFontNumber;
    if Driver.FontType = 0 then
      Driver.FontType := 1;
    Check(Driver.GetFontMetrics);
    if Driver.CharWidth <> 0 then
      FLineLength := Trunc(Driver.PrintWidth / Driver.CharWidth);
    FCapOpenCheck := Driver.CapOpenCheck;
    FCapGetShortECRStatus := Driver.CapGetShortECRStatus;
    ReadTaxNames;
    ReadDepartments;
    ProgramPayNames;
    SetUserPassword;
    Check(Driver.GetECRStatus);
    FSerialNumber := Driver.SerialNumber;
    FAddressSiteInspections := ReadTableStr(18, 1, 13);
    FSenderEmail := ReadTableStr(18, 1, 15);
    GetFFDVersion;
    LoadFromReg;
  finally
    UnlockPort;
  end;
end;

function TDevice1C.ReadValuesArray(const AValuesArray: IDispatch): T1CDriverParams;
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

procedure TDevice1C.CheckStatus;
var
  TickCount: Integer;
begin
  TickCount := GetTickCount;
  repeat
    if (Integer(GetTickCount) - TickCount) > StatusTimeout then
      raise Exception.Create('Таймаут ожидания готовности ФР');

    // Запрос состояния
    Check(GetStatus);
    // 0. Если ничего не печатает, то проверяем режимы
    case Driver.ECRAdvancedMode of
      0:
        begin
          case Driver.ECRMode of
            1:
              Check(Driver.InterruptDataStream);
            5:
              RaiseError($05, GetRes(@SLockedInvalidTaxPassword));
            9:
              RaiseError($09, GetRes(@STechnologicalResetMode));
            10:
              Check(Driver.InterruptTest);
            11, 12:
              Sleep(1000);
          else
            Exit;
          end;
        end;
      3:
        Check(Driver.ContinuePrint);
      4, 5:
        Sleep(1000);
    else
      Break;
    end;
  until false;
end;

procedure TDevice1C.LoadFromReg;
begin
  FNonFiscalCheckNumber := FParamsReg.ReadCheckNumber(FSerialNumber);
end;

procedure TDevice1C.DeviceTest(const ValuesArray: IDispatch; var AdditionalDescription, DemoModeIsActivated: WideString);
var
  V: Variant;
  Params: T1CDriverParams;
begin
  AdditionalDescription := WideString('OK');
  Params := ReadValuesArray(ValuesArray);
  SetParams(Params);
  Check(Driver.Disconnect);
  ApplyDeviceParams;
  SetUserPassword;
  LockPort;
  try
    CheckStatus;
    Check(Driver.GetDeviceMetrics);
    AdditionalDescription := Tnt_WideFormat('%s №', [Trim(Driver.UDescription)]);
    Check(Driver.GetECRStatus);
    AdditionalDescription := Tnt_WideFormat('%s %s', [AdditionalDescription, Driver.SerialNumber]);
    try
      V := ValuesArray;
      V.set(DRVFR_VALUE_INDEX_SERIALNUMBER, Driver.SerialNumber);
    except
      RaiseError(E_UNKNOWN, Tnt_WideFormat('%s "%s"', [GetRes(@SValuesArrayWriteError), 'SerialNumber']));
    end;
    // Проверяем корректность пароля админа
    SetAdminPassword;
    Driver.FontType := 1;
    Check(Driver.GetFontMetrics);
  finally
    UnlockPort;
    Driver.Disconnect;
  end;
end;

procedure TDevice1C.LoadLogo(const ValuesArray: IDispatch; const LogoFileName: WideString; CenterLogo: WordBool; var LogoSize: Integer; var AdditionalDescription: WideString);
var
  Params: T1CDriverParams;
begin
  AdditionalDescription := SLogoLoadSuccessful;
  Params := ReadLogoValuesArray(ValuesArray);
  SetParams(Params);
  Check(Driver.Disconnect);
  ApplyDeviceParams;
  SetUserPassword;
  LockPort;
  try
    Driver.FileName := LogoFileName;
    Driver.CenterImage := CenterLogo;
    Check(Driver.LoadImage);
    LogoSize := Driver.LastLineNumber - Driver.FirstLineNumber + 1;
  finally
    UnlockPort;
    Driver.Disconnect;
  end;
end;

function TDevice1C.ReadLogoValuesArray(const AValuesArray: IDispatch): T1CDriverParams;
var
  V: Variant;
begin
  V := AValuesArray;
  if not GetIntParamValue(V, 0, Result.Port) then
    RaiseInvalidValue('Port');
  if not GetIntParamValue(V, 1, Result.Speed) then
    RaiseInvalidValue('Speed');
  if not GetStrParamValue(V, 2, Result.UserPassword) then
    RaiseInvalidValue('UserPassword');
  if not GetIntParamValue(V, 3, Result.Timeout) then
    RaiseInvalidValue('Timeout');
  if not GetIntParamValue(V, 4, Result.ConnectionType) then
    Result.ConnectionType := DEF_CONNECTION_TYPE;
  if not GetStrParamValue(V, 5, Result.ComputerName) then
    Result.ComputerName := DEF_COMPUTERNAME;
  if not GetStrParamValue(V, 6, Result.IPAddress) then
    Result.IPAddress := DEF_IPADDRESS;
  if not GetIntParamValue(V, 7, Result.TCPPort) then
    Result.TCPPort := DEF_TCPPORT;
  if not GetIntParamValue(V, 8, Result.ProtocolType) then
    Result.ProtocolType := DEF_PROTOCOLTYPE;
end;

procedure TDevice1C.DeviceTest2(const ValuesArray: IDispatch; var AdditionalDescription, DemoModeIsActivated: WideString);
begin
  AdditionalDescription := WideString('OK');
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data DeviceTest2');
    Exit;
  end;

  try
    Check(Driver.Disconnect);
    ApplyDeviceParams;
    SetAdminPassword;
    LockPort;
    CheckStatus;
    Check(Driver.GetDeviceMetrics);
    AdditionalDescription := Tnt_WideFormat('%s №', [Trim(Driver.UDescription)]);
    Check(Driver.GetECRStatus);
    AdditionalDescription := Tnt_WideFormat('%s %s', [AdditionalDescription, Driver.SerialNumber]);
    // Проверяем корректность пароля админа
    SetAdminPassword;
    Driver.FontType := 1;
    Check(Driver.GetFontMetrics);
  finally
    UnlockPort;
    Driver.Disconnect;
  end;
end;

procedure TDevice1C.SetPayName(Number: Integer; const Name: WideString);
begin
  FParams.Paynames[Number] := Name;
end;

{procedure TDevice1C.PrintBufferedStrings;
begin
  if FIsOpenedCheck and FBufferStrings and CapCashCore then
  begin
    Driver.CarryStrings := True;
    Driver.DelayedPrint := True;
    Driver.UseReceiptRibbon := True;
    Driver.UseJournalRibbon := True;
    Driver.StringForPrinting := FStringForPrinting;
    PrintAndWait(DrvPrintString);
    FStringForPrinting := '';
  end;
end;}

function TDevice1C.DrvCharge: Integer;
begin
  Result := Driver.Charge;
end;

function TDevice1C.DrvCloseCheck: Integer;
begin
  Result := Driver.CloseCheck;
end;

function TDevice1C.DrvDiscount: Integer;
begin
  Result := Driver.Discount;
end;

procedure TDevice1C.SafeOpenCheck;
var
  Res: Integer;
begin
  if not FCapOpenCheck then
    Exit;
  if CapCashCore then
  begin
    repeat
      Res := Driver.OpenCheck;
    until Res <> $50;
    Check(Res);
  end
  else
  begin
    Res := Driver.OpenCheck;
  end;
  if Res <> $37 then
    Check(Res)
  else
  begin
    FCapOpenCheck := False;
  end
end;

function TDevice1C.DrvReturnSale: Integer;
begin
  Result := Driver.ReturnSale;
end;

function TDevice1C.DrvSale: Integer;
begin
  Result := Driver.Sale;
end;

function TDevice1C.DrvCashIncome: Integer;
begin
  Result := Driver.CashIncome;
end;

function TDevice1C.DrvCashOutcome: Integer;
begin
  Result := Driver.CashOutcome;
end;

function TDevice1C.DrvSysAdminCancelCheck: Integer;
begin
  Result := Driver.SysAdminCancelCheck;
end;

function TDevice1C.DrvPrintDocumentTitle: Integer;
begin
  Result := Driver.PrintDocumentTitle;
end;

function TDevice1C.DrvPrintZReport: Integer;
begin
  Result := Driver.PrintReportWithCleaning;
end;

procedure TDevice1C.PrintAndWait(Method: TDriverFunc; AWaitError: Boolean = False);
var
  Res: Integer;
begin
  if CapCashCore or AWaitError then
  begin
    repeat
//      Logger.Debug('===PrintAndWait.try');
      Res := Method;
    until (Res <> $50) and (Res <> $4B);
    Check(Res);
  end
  else
  begin
    Res := Method;
    Check(Res);
   // if (Res = 107) or (Res = -34) then
    begin
//      Logger.Debug('wait');
      WaitForPrinting;
    end
//    else
//      Check(Res);
  end;
end;

function TDevice1C.CapCashCore: Boolean;
begin
  Driver.ModelParamNumber := mpCapCashCore;
  Check(Driver.ReadModelParamValue);
  Result := Driver.ModelParamValue;
end;

function TDevice1C.CapCut: Boolean;
begin
  Driver.ModelParamNumber := mpCapCutterPresent;
  Check(Driver.ReadModelParamValue);
  Result := Driver.ModelParamValue;
end;

function TDevice1C.DrvPrintXReport: Integer;
begin
  Result := Driver.PrintReportWithoutCleaning;
end;

function TDevice1C.ReplaceDelimeter(const AStr: WideString): WideString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(AStr) do
  begin
    if Byte(AStr[i]) = $A0 then
      Result := Result + ' '
    else
      Result := Result + AStr[i];
  end;
end;

procedure TDevice1C.ProgramPrintCloseCheck;
var
  Res: Integer;
begin
  SetAdminPassword;
  Driver.TableNumber := 1;
  Driver.RowNumber := 1;
  Driver.FieldNumber := 20;
  Driver.ValueOfFieldInteger := 0;
  Res := Driver.WriteTable;
  if Res <> 0 then
    Logger.Debug('ProgramPringCloseCheck: ' + IntToStr(Res) + ' ' + Driver.ResultCodeDescription);
  FPrintCloseCheck := True;
end;

procedure TDevice1C.OpenShift;
begin
  CheckReceiptClosed;
  LockPort;
  try
    // Убираем "Печать по закрытию чека"
    //if not FPrintCloseCheck then
    //  ProgramPrintCloseCheck;
    // !!! Надо сделать только для моделей, у которых нет буферизации текста чека

    // Программируем налоговые ставки
//    if not FTaxProgrammed then
//      ProgramTax;

    // Программируем наименования типов оплат
//    if not FPayProgrammed then
//      ProgramPayNames;

    SetUserPassword;
    Driver.ModelParamNumber := mpModelID;
    Check(Driver.ReadModelParamValue);
    if Driver.ModelParamValue <> 6 then //ЭЛВЕС-ФР-К
      PrintAndWait(DrvOpenShift);
  finally
    UnlockPort;
  end;
end;

function TDevice1C.DrvOpenShift: Integer;
begin
  Result := Driver.OpenSession;
end;

procedure TDevice1C.PrintStringWithWrap(const AStr: WideString);
var
  S: WideString;
  M: WideString;
begin
  S := AStr;
  if S = '' then
    S := ' ';
  repeat
    M := Copy(S, 1, FLineLength);
    Driver.StringForPrinting := M;
    Driver.FontType := FParams.CheckFontNumber;
    PrintAndWait(DrvPrintString, True);
    Delete(S, 1, FLineLength);
  until Length(S) = 0;
end;

procedure TDevice1C.PrintFiscalString2(const AName: WideString; AQuantity, APrice, AAmount: Double; ADepartment, ATax1, ATax2, ATax3, ATax4: Integer);
var
  Summ: Int64;
  ItemQuantity, ItemPrice, ItemAmount: Int64;
begin
  CheckReceiptOpened;
  LockPort;
  try
    SetUserPassword;
    // Сумма скидки или надбавки
    ItemQuantity := Round2(Abs(AQuantity * 1000));
    ItemPrice := Round2(Abs(APrice * 100));
    ItemAmount := Round2(Abs(AAmount * 100));

    Summ := ItemAmount - Round2(ItemPrice * ItemQuantity / 1000);

    // Открыт нефискальный чек
    if not FIsFiscalCheck then
      RaiseError(C_ERR_CHECKOPENED, GetRes(@SInvalidOperationInNonfiscalDocument));

    //WaitForPrinting;
    // Продажа
    Driver.Tax1 := ATax1;
    Driver.Tax2 := ATax2;
    Driver.Tax3 := ATax3;
    Driver.Tax4 := ATax4;
//    PrintText(AName, True);
    Driver.StringForPrinting := AName;
    Driver.Price := ItemPrice / 100;
    Driver.Quantity := ItemQuantity / 1000;
    Driver.Department := ADepartment;
    if FIsReturnCheck then
      PrintAndWait(DrvReturnSale)
    else
      PrintAndWait(DrvSale);
    FStringForPrinting := '';
    // Назначаем скидку или надбавку
    Logger.Debug(Format('Summ = %d', [Summ]));
    if Abs(Summ) > 0 then
    begin
      SetUserPassword;
      Driver.Summ1 := Abs(Summ / 100);
      Driver.Tax1 := ATax1;
      Driver.Tax2 := ATax2;
      Driver.Tax3 := ATax3;
      Driver.Tax4 := ATax4;
      Driver.StringForPrinting := '';
      if Summ < 0 then
        PrintAndWait(DrvDiscount)
      else
        PrintAndWait(DrvCharge);
    end;
  finally
    UnlockPort;
  end;
end;

function TDevice1C.DrvPrintString: Integer;
begin
  if Driver.FontType = 0 then
    Driver.FontType := 1;
  Result := Driver.PrintStringWithFont;
end;

procedure TDevice1C.CloseShift17(const CashierName: WideString; var SessionNumber, DocumentNumber: Integer);
begin
  CheckReceiptClosed;
  LockPort;
  try
    SetCashierPassword(CashierName);
    PrintAndWait(DrvFNCloseShift);
    SessionNumber := Driver.SessionNumber;
    DocumentNumber := Driver.DocumentNumber;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.GetCurrentStatus(var CheckNumber, SessionNumber, SessionState: Integer; var StatusParameters: WideString);
var
  Xml: IXMLDocument;
  Node: IXMLNode;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data Get current status');
    SessionState := 2;
    SessionNumber := 1;
    Xml := TXMLDocument.Create(nil);
    try
      Xml.Active := True;
      Xml.Version := '1.0';
      Xml.Encoding := 'UTF-8';
      Xml.Options := Xml.Options + [doNodeAutoIndent];
      Node := Xml.AddChild('StatusParameters');
      Node := Node.AddChild('Parameters');
      Node.Attributes['BacklogDocumentsCounter'] := '0';
      Node.Attributes['BacklogDocumentFirstNumber'] := '0';
      Node.Attributes['BacklogDocumentFirstDateTime'] := DateTimeToXML(Now);
      StatusParameters := XMLStringToWideString(Xml.XML.Text);
    finally
      Xml := nil;
    end;
    Exit;
  end;

  //CheckReceiptClosed;
  LockPort;
  try
    SetAdminPassword;
    Check(Driver.GetECRStatus);
    case Driver.ECRMode of
      4:
        SessionState := 1;
      2, 8, 13, 14:
        SessionState := 2;
      3:
        SessionState := 3;
    else
      SessionState := 1;
    end;
    Check(Driver.FNGetStatus);
    CheckNumber := Driver.DocumentNumber;
    Check(Driver.FNGetCurrentSessionParams);
    SessionNumber := Driver.SessionNumber;
    Check(Driver.FNGetInfoExchangeStatus);
    StatusParameters := GetXMLStatusParameters;
  finally
    UnlockPort;
  end;
end;

function GetTaxVariant(Tax: Integer): WideString;
var
  i: Integer;
begin
  if Tax = 0 then
  begin
    Result := '0';
    Exit;
  end;
  Result := '';
  for i := 0 to 5 do
  begin
    if testbit(Tax, i) then
      Result := Result + IntTostr(i) + ',';
  end;
  Delete(Result, Length(Result), 1);
end;

procedure TDevice1C.GetDataKKT(var TableParameters: WideString);
var
  Xml: IXMLDocument;
  KKTNumber: WideString; // 	Регистрационный номер ККТ
  KKTSerialNumber: WideString; //  	Заводской номер ККТ
  Fiscal: Boolean; // 	Да 	boolean 	Признак регистрация фискального накопителя
  FNSerialNumber: WideString; // 	Да 	string 	Заводской номер ФН
  DocumentNumber: WideString; // 	Нет 	string 	Номер документа регистрация фискального накопителя
  FNDateTime: WideString; // 	Нет 	datetime 	Дата и время операции регистрация фискального накопителя
  OrganizationName: WideString; // 	Нет 	string 	Название организации
  VATIN: WideString; // 	Нет 	string 	ИНН организация
  AddressSettle: WideString; // 	Нет 	string 	Адрес установки ККТ для проведения расчетов
  TaxVariant: WideString; // 	Нет 	string 	Коды системы налогообложения через разделитель
  OfflineMode: Boolean; // 	Нет 	boolean 	Признак автономного режима
  AutomaticMode: Boolean; // 	Нет 	boolean 	Признак автоматического режима
  AutomaticNumber: WideString; // 	Нет 	string 	Номер автомата для автоматического режима
  OFDOrganizationName: WideString; // 	Нет 	string 	Название организации ОФД
  OFDVATIN: WideString; //ИНН организация ОФД
  ServiceSign: Boolean;
  BSOSign: Boolean;
  FFDVersion: WideString;
  Node: IXMLNode;
  WMode: Integer;
  Res: Integer;
begin
  SetAdminPassword;
  Check(Driver.FNGetStatus);
  Fiscal := TestBit(Driver.FNLifeState, 1);
  Driver.ModelParamNumber := mpFSTableNumber;
  Driver.ReadModelParamValue;
  Driver.TableNumber := Driver.ModelParamValue;
  Driver.RowNumber := 1;

  Driver.FieldNumber := 1;
  Check(Driver.ReadTable);
  KKTSerialNumber := Driver.ValueOfFieldString;

  Driver.FieldNumber := 2;
  Check(Driver.ReadTable);
  VATIN := Driver.ValueOfFieldString;

  Driver.FieldNumber := 3;
  Check(Driver.ReadTable);
  KKTNumber := Driver.ValueOfFieldString;

  Driver.FieldNumber := 4;
  Check(Driver.ReadTable);
  FNSerialNumber := Driver.ValueOfFieldString;

  Driver.FieldNumber := 5;
  Check(Driver.ReadTable);
  TaxVariant := GetTaxVariant(Driver.ValueOfFieldInteger); ///!!!

  Driver.FieldNumber := 6;
  Check(Driver.ReadTable);
  WMode := Driver.ValueOfFieldInteger; ///!!!
  OfflineMode := testbit(WMode, 1);
  AutomaticMode := testbit(WMode, 2);
  ServiceSign := testbit(WMode, 3);
  BSOSign := testbit(WMode, 4);

  Driver.FieldNumber := 7;
  Check(Driver.ReadTable);
  OrganizationName := Driver.ValueOfFieldString;

  Driver.FieldNumber := 9;
  Check(Driver.ReadTable);
  AddressSettle := Driver.ValueOfFieldString;

  Driver.FieldNumber := 10;
  Check(Driver.ReadTable);
  OFDOrganizationName := Driver.ValueOfFieldString;

  Driver.FieldNumber := 12;
  Check(Driver.ReadTable);
  OFDVATIN := Driver.ValueOfFieldString;

  if AutomaticMode then
  begin
    Driver.TableNumber := 24;
    Driver.RowNumber := 1;
    Driver.FieldNumber := 1;
    Driver.ReadTable;
    Driver.ReadTable;
    AutomaticNumber := Driver.ValueOfFieldString;
  end;

  Res := Driver.FNGetFiscalizationResult;
  if (Res <> 2) and (Res <> 1) then
    Check(Res);
  DocumentNumber := IntToStr(Driver.DocumentNumber);
  FNDateTime := DateTimeToStr(Driver.Date + driver.Time);
  FFDVersion := GetFFDVersion;
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('Parameters');
    Node.Attributes['KKTNumber'] := KKTNumber;
    Node.Attributes['KKTSerialNumber'] := KKTSerialNumber;
    if Fiscal then
      Node.Attributes['Fiscal'] := 'true'
    else
      Node.Attributes['Fiscal'] := 'false';

    Node.Attributes['DocumentNumber'] := DocumentNumber;
    Node.Attributes['DateTime'] := FNDateTime;
    Node.Attributes['FNSerialNumber'] := FNSerialNumber;
    Node.Attributes['OrganizationName'] := OrganizationName;
    Node.Attributes['VATIN'] := VATIN;
    Node.Attributes['AddressSettle'] := AddressSettle;
    Node.Attributes['TaxVariant'] := TaxVariant;
    Node.Attributes['FFDVersionFN'] := FFDVersion; //'1.0';
    Node.Attributes['FFDVersionKKT'] := FFDVersion;
    Node.Attributes['AutomaticNumber'] := AutomaticNumber;

    if OfflineMode then
      Node.Attributes['OfflineMode'] := 'true'
    else
      Node.Attributes['OfflineMode'] := 'false';

    if AutomaticMode then
      Node.Attributes['AutomaticMode'] := 'true'
    else
      Node.Attributes['AutomaticMode'] := 'false';

    if ServiceSign then
      Node.Attributes['ServiceSign'] := 'true'
    else
      Node.Attributes['ServiceSign'] := 'false';

    if BSOSign then
      Node.Attributes['BSOSign'] := 'true'
    else
      Node.Attributes['BSOSign'] := 'false';

    Node.Attributes['OFDOrganizationName'] := OFDOrganizationName;
    Node.Attributes['OFDVATIN'] := OFDVATIN;

    TableParameters := XMLStringToWideString(Xml.XML.Text);
  finally
    Xml := nil;
  end;
end;

procedure TDevice1C.OpenShift17(const CashierName: WideString; var SessionNumber, DocumentNumber: Integer);
begin
  CheckReceiptClosed;
  LockPort;
  try
    SetCashierPassword(CashierName);
    // Убираем "Печать по закрытию чека"
    //if not FPrintCloseCheck then
    //  ProgramPrintCloseCheck;
    // !!! Надо сделать только для моделей, у которых нет буферизации текста чека

    // Программируем налоговые ставки
//    if not FTaxProgrammed then
//      ProgramTax;

    // Программируем наименования типов оплат
//    if not FPayProgrammed then
//      ProgramPayNames;
//    SetCashierPassword(CashierName);
    PrintAndWait(DrvFNOpenShift);
    WaitForPrinting;
    SessionNumber := Driver.SessionNumber;
    DocumentNumber := Driver.DocumentNumber;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.OperationFN(OperationType: Integer; const CashierName: WideString; const FiscalParameters: WideString);
var
  Params: TFiscalParametersRec;
  Res: Integer;
  sErrorText: WideString;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data OperationFN');
    Exit;
  end;

  SetAdminPassword;
  //SetCashierPassword(CashierName);
  ParseFiscalParameters(FiscalParameters, Params);
  case OperationType of
    1: // Registration
      begin
        Driver.ModelParamNumber := mpFSTableNumber;
        Driver.ReadModelParamValue;
        Driver.TableNumber := Driver.ModelParamValue;
        Driver.RowNumber := 1;
        Driver.FieldNumber := 9;
        Driver.ValueOfFieldString := Params.AddressSettle;
        Check(Driver.WriteTable);
        Driver.FieldNumber := 10;
        Driver.ValueOfFieldString := Params.OFDOrganizationName;
        Check(Driver.WriteTable);
        Driver.FieldNumber := 12;
        Driver.ValueOfFieldString := Params.OFDVATIN;
        Check(Driver.WriteTable);
        Driver.FieldNumber := 7;
        Driver.ValueOfFieldString := Params.OrganizationName;
        Check(Driver.WriteTable);

        Driver.INN := Params.INN;
        Driver.KKTRegistrationNumber := Params.KKTNumber;
        Driver.TaxType := Params.Tax;
        Driver.WorkMode := Params.WorkMode;

        if testbit(Params.WorkMode, 2) then // Automatic mode
        begin
          Driver.TableNumber := 24;
          Driver.RowNumber := 1;
          Driver.FieldNumber := 1;
          Driver.ValueOfFieldString := Params.AutomatNumber;
          Check(Driver.WriteTable);
        end;
        Res := Driver.FNBuildRegistrationReport;
        sErrorText := Driver.ResultCodeDescription;
        if Res > 0 then
        begin
          Check(Driver.FNCancelDocument);
          RaiseError(Res, sErrorText);
        end
        else
          Check(Res);
        WaitForPrinting;
      end;
    2: // ReRegistration
      begin
        Driver.ModelParamNumber := mpFSTableNumber;
        Driver.ReadModelParamValue;
        Driver.TableNumber := Driver.ModelParamValue;
        Driver.RowNumber := 1;
        Driver.FieldNumber := 9;
        Driver.ValueOfFieldString := Params.AddressSettle;
        Check(Driver.WriteTable);
        Driver.FieldNumber := 10;
        Driver.ValueOfFieldString := Params.OFDOrganizationName;
        Check(Driver.WriteTable);
        Driver.FieldNumber := 12;
        Driver.ValueOfFieldString := Params.OFDVATIN;
        Check(Driver.WriteTable);
        Driver.FieldNumber := 7;
        Driver.ValueOfFieldString := Params.OrganizationName;
        Check(Driver.WriteTable);

        Driver.INN := Params.INN;
        Driver.KKTRegistrationNumber := Params.KKTNumber;
        Driver.TaxType := Params.Tax;
        Driver.WorkMode := Params.WorkMode;
        Driver.RegistrationReasonCode := Params.ReasonCode;

        if testbit(Params.WorkMode, 2) then // Automatic mode
        begin
          Driver.TableNumber := 24;
          Driver.RowNumber := 1;
          Driver.FieldNumber := 1;
          Driver.ValueOfFieldString := Params.AutomatNumber;
          Check(Driver.WriteTable);
        end;
        Res := Driver.FNBuildReregistrationReport;
        sErrorText := Driver.ResultCodeDescription;
        if Res > 0 then
        begin
          Check(Driver.FNCancelDocument);
          RaiseError(Res, sErrorText);
        end
        else
          Check(Res);
        WaitForPrinting;
      end;
    3: // Close FN
      begin
        Check(Driver.FNCloseFiscalMode);
        WaitForPrinting;
      end;
  end;
end;

procedure TDevice1C.ParseCheckCorrection(const AXML: WideString; var Params: TCheckCorrectionParamsRec);
var
  Xml: IXMLDocument;
  Node: IXMLNode;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXmL(AXML);
    //Xml.XML.Text := AXML;
    Node := Xml.ChildNodes.FindNode('CheckCorrectionPackage');
    if Node = nil then
      raise Exception.Create('Error XML CheckCorrectionPackage node ');
    Node := Node.ChildNodes.FindNode('Parameters');
    if Node = nil then
      raise Exception.Create('Error XML Parameters node ');
    Params.PaymentType := LoadInteger(Node, 'PaymentType', True);
    Params.TaxType := LoadInteger(Node, 'TaxVariant', True);
    Node := Node.ParentNode;
    Node := Node.ChildNodes.FindNode('Payments');
    if Node = nil then
      raise Exception.Create('Error XML Payments node ');

    Params.Cash := LoadDecimal(Node, 'Cash', False);
    Params.CashLessType1 := LoadDecimal(Node, 'CashLessType1', False);
    Params.CashLessType2 := LoadDecimal(Node, 'CashLessType2', False);
    Params.CashLessType3 := LoadDecimal(Node, 'CashLessType3', False);
  finally
    Xml := nil;
  end;
end;

procedure TDevice1C.ParseCheckCorrection22(const AXML: WideString; var Params: TCheckCorrectionParamsRec22);
var
  Xml: IXMLDocument;
  Node: IXMLNode;
  Guid: TGUID;
  t18, t20, t118, t120: Currency;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXmL(AXML);
    //Xml.XML.Text := AXML;
    Node := Xml.ChildNodes.FindNode('CheckCorrectionPackage');
    if Node = nil then
      raise Exception.Create('Error XML CheckCorrectionPackage node ');
    Node := Node.ChildNodes.FindNode('Parameters');
    if Node = nil then
      raise Exception.Create('Error XML Parameters node ');
    Params.CashierName := LoadString(Node, 'CashierName', True);
    Params.CashierVATIN := LoadString(Node, 'CashierVATIN', False);
    Params.CorrectionType := LoadInteger(Node, 'CorrectionType', True);
    Params.TaxVariant := LoadInteger(Node, 'TaxVariant', True);
    Params.PaymentType := LoadInteger(Node, 'PaymentType', True);
    Params.CorrectionBaseName := LoadString(Node, 'CorrectionBaseName', False);
    Params.CorrectionBaseNumber := LoadString(Node, 'CorrectionBaseNumber', False);
    Params.CorrectionBaseDate := LoadDateTime(Node, 'CorrectionBaseDate', False);
    Params.Sum := LoadDecimal(Node, 'Sum', True);
    t18 := LoadDecimal(Node, 'SumTAX18', False);
    t20 := LoadDecimal(Node, 'SumTAX20', False);
    t118 := LoadDecimal(Node, 'SumTAX118', False);
    t120 := LoadDecimal(Node, 'SumTAX120', False);
    if ((t20 <> 0) and (t18 <> 0)) or ((t118 <> 0) and (t120 <> 0)) then
      raise Exception.Create('Error in tax sums');
    if t20 = 0 then
      Params.SumTAX18 := t18
    else
      Params.SumTAX18 := t20;
    if t120 = 0 then
      Params.SumTAX118 := t118
    else
      Params.SumTAX118 := t120;
    Params.SumTAX10 := LoadDecimal(Node, 'SumTAX10', False);
    Params.SumTAX0 := LoadDecimal(Node, 'SumTAX0', False);
    Params.SumTAXNone := LoadDecimal(Node, 'SumTAXNone', False);
    Params.SumTAX110 := LoadDecimal(Node, 'SumTAX110', False);
    Node := Node.ParentNode;
    Node := Node.ChildNodes.FindNode('Payments');
    if Node = nil then
      raise Exception.Create('Error XML Payments node ');
    Params.Cash := LoadDecimal(Node, 'Cash', True);
    Params.ElectronicPayment := LoadDecimal(Node, 'ElectronicPayment', True);
    Params.AdvancePayment := LoadDecimal(Node, 'AdvancePayment', True);
    Params.Credit := LoadDecimal(Node, 'Credit', True);
    Params.CashProvision := LoadDecimal(Node, 'CashProvision', True);
    CreateGUID(Guid);
    Params.Id := GUIDToString(Guid);
  finally
    Xml := nil;
  end;
end;

procedure TDevice1C.ParseFiscalParameters(const AXML: WideString; var Params: TFiscalParametersRec);
var
  Xml: IXMLDocument;
  Node: IXMLNode;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXML(AXML);
    Node := Xml.ChildNodes.FindNode('Parameters');
    if Node = nil then
      raise Exception.Create('Wrong XML parameters Table');
    Params.INN := LoadString(Node, 'VATIN', True);
    Params.KKTNumber := LoadString(Node, 'KKTNumber', True);
//    Params.KKTSerialNumber := //LoadString(Node, 'KKTSerialNumber', True);
//    Params.DocumentNumber := LoadString(Node, 'DocumentNumber', True);
    Params.Tax := ParseTaxSystem(LoadString(Node, 'TaxVariant', True));
    Params.AddressSettle := LoadString(Node, 'AddressSettle', True);
    Params.OFDOrganizationName := LoadString(Node, 'OFDOrganizationName', True);
    Params.OrganizationName := LoadString(Node, 'OrganizationName', True);
    Params.OFDVATIN := LoadString(Node, 'OFDVATIN', True);
    Params.AutomatNumber := LoadString(Node, 'AutomaticNumber', False);
    Params.WorkMode := 0;
    if IsTrue(LoadString(Node, 'OfflineMode', False)) then
      SetBit(Params.WorkMode, 1);
    if IsTrue(LoadString(Node, 'AutomaticMode', False)) then
      SetBit(Params.WorkMode, 2);
    if IsTrue(LoadString(Node, 'ServiceSign', False)) then
      SetBit(Params.WorkMode, 3);
    if IsTrue(LoadString(Node, 'DataEncryption', False)) then
      SetBit(Params.WorkMode, 0);

    Params.ReasonCode := LoadInteger(Node, 'ReasonCode', True);
  finally
    Xml := nil;
  end;
end;

function TDevice1C.IsTrue(const AStr: WideString): Boolean;
begin
  if AStr = '' then
  begin
    Result := False;
    Exit;
  end;
  Result := (AStr <> '0') and (UpperCase(AStr) <> 'FALSE');
end;

function TDevice1C.ParseTaxSystem(const ATax: WideString): Byte;
var
  S: TStringList;
  i: Integer;
begin
  Result := 0;
  S := TStringList.Create;
  try
    S.Delimiter := ',';
    S.DelimitedText := ATax;
    for i := 0 to S.Count - 1 do
    begin
      case StrToIntDef(S[i], 0) of
        0:
          setbit(Result, 0);
        1:
          setbit(Result, 1);
        2:
          setbit(Result, 2);
        3:
          setbit(Result, 3);
        4:
          setbit(Result, 4);
        5:
          setbit(Result, 5);
        6:
          setbit(Result, 6);
      end;
    end;
  finally
    S.Free;
  end;
end;

procedure TDevice1C.ProcessCheck(const CashierName: WideString; Electronically: Boolean; const CheckPackage: WideString; var CheckNumber, SessionNumber: Integer; var FiscalSign: WideString; var AddressSiteInspections: WideString);
//var
//  cp: WideString;
begin
  if FParams.ODEnabled then
  begin
    DoProcessCheckOD(CashierName, Electronically, CheckPackage, CheckNumber, SessionNumber, FiscalSign, AddressSiteInspections);
    Exit
  end;
(*Cp :=  '<?xml version="1.0" encoding="UTF-8"?>' +
'<CheckPackage>' +
'	<Parameters PaymentType="1" TaxVariant="0" CashierName="Кужелева Ольга Сергеевна" SenderEmail="true"/>' +
'	<Positions>' +
'		<TextString Text="Накладная № 614176 от 18.10.18:     "/>' +
'		<TextString Text="                                    "/>' +
'		<FiscalString Name="1) Плитка 25*35 Jungle белый  (C-JUM051R) уп.1,4м2 (м2)" Quantity="0.087123" Price="32" Amount="3.21" Department="1" Tax="18"/>' +
'	</Positions>' +
'	<Payments Cash="1110" CashLessType1="0" CashLessType2="0" CashLessType3="0"/>' +
'</CheckPackage>';*)


  try
    DoProcessCheck(CashierName, Electronically, CheckPackage, CheckNumber, SessionNumber, FiscalSign, AddressSiteInspections);
  except
    on E: EDriverError do
    begin
      if EDriverError(E).ErrorCode = $2F then
      begin
        Logger.Debug('2F error handling');
        RebootECR;
        Logger.Debug('2F error handling - Waiting for connect');
        WaitForConnect;
        Logger.Debug('2F error handling - Checking state');
        CheckStatus;
        if IsPrinterRecOpened then
        begin
          Logger.Debug('2F error handling - Cancelling receipt');
          Check(Driver.SysAdminCancelCheck);
          Logger.Debug('2F error handling - repeat receipt');
          DoProcessCheck(CashierName, Electronically, CheckPackage, CheckNumber, SessionNumber, FiscalSign, AddressSiteInspections);
        end;
      end
      else
        raise;
    end
    else
      raise;
  end;
end;

procedure TDevice1C.ProcessCheckCorrection(const CashierName, CheckCorrectionPackage: WideString; var CheckNumber, SessionNumber: Integer; var FiscalSign: WideString; var AddressSiteInspections: WideString);
var
  Params: TCheckCorrectionParamsRec;
begin
  LockPort;
  try
    Logger.Debug('ProcessCheckCorrection: ' + CheckCorrectionPackage);
    SetCashierPassword(CashierName);
    ParseCheckCorrection(CheckCorrectionPackage, Params);
    Driver.CorrectionType := 0;
    Driver.CalculationSign := Params.PaymentType;
    Driver.Summ1 := Params.Cash + Params.CashLessType1 + Params.CashLessType2 + Params.CashLessType3;
    Driver.Summ2 := Params.Cash;
    Driver.Summ3 := Params.CashLessType1 + Params.CashLessType2 + Params.CashLessType3;
    Driver.Summ4 := 0;
    Driver.Summ5 := 0;
    Driver.Summ6 := 0;
    Driver.Summ7 := 0;
    Driver.Summ8 := 0;
    Driver.Summ9 := 0;
    Driver.Summ10 := 0;
    Driver.Summ11 := 0;
    Driver.Summ12 := 0;
    Driver.TaxType := TaxToBin(Params.TaxType);
   // Driver.TaxType := 0;
    Check(Driver.FNBuildCorrectionReceipt2);
    WaitForPrinting;
    SessionNumber := Driver.SessionNumber;
    CheckNumber := Driver.DocumentNumber;
    FiscalSign := IntToStr(Cardinal(Driver.FiscalSign));
    AddressSiteInspections := '';
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.ReportCurrentStatusOfSettelements;
begin
  LockPort;
  try
    Logger.Debug('ReportCurrentStatusOfSettelements');
    SetAdminPassword;
    PrintAndWait(DrvFNBuildCalculationStateReport);
    WaitForPrinting;
  finally
    UnlockPort;
  end;
end;

function TDevice1C.DrvFNCloseShift: Integer;
begin
  Result := Driver.PrintReportWithCleaning;
end;

function TDevice1C.DrvFNOpenShift: Integer;
begin
  Result := Driver.OpenSession;
end;

function TDevice1C.DrvFNBuildCalculationStateReport: Integer;
begin
  Result := Driver.FNBuildCalculationStateReport;
end;

procedure TDevice1C.CloseShiftFN(const CashierName: WideString; var SessionNumber, DocumentNumber: Integer);
begin
  LockPort;
  try
    SetAdminPassword;
    Check(Driver.PrintReportWithCleaning);
    WaitForPrinting;
    Check(Driver.GetECRStatus);
    SessionNumber := Driver.SessionNumber;
    Check(Driver.FNGetStatus);
    DocumentNumber := Driver.DocumentNumber;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.OpenShiftFN(const CashierName: WideString; var SessionNumber, DocumentNumber: Integer);
begin
  LockPort;
  try
    SetCashierPassword(CashierName);
    Check(Driver.OpenSession);
    WaitForPrinting;
    Check(Driver.GetECRStatus);
    SessionNumber := Driver.SessionNumber + 1;
    Check(Driver.FNGetStatus);
    DocumentNumber := Driver.DocumentNumber;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.PrintTextDocument(const TextPackage: WideString);
var
  Positions: TPositions1C;
  i: Integer;
  NonFiscalString: TNonFiscalString;
  Barcode: TBarcode;
  Num: Integer;
  SN: Integer;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data PrintTextDocument');
    Exit;
  end;

  Logger.Debug('PrintTextDocument: ' + TextPackage);
  LockPort;
  try
    SetAdminPassword;
    OpenCheck(False, False, False, Num, SN);
    Positions := TPositions1C.Create;
    try
      Positions.ReadFromXML(TextPackage, True);
      for i := 0 to Positions.Count - 1 do
      begin
        if Positions.Items[i] is TNonFiscalString then
        begin
          NonFiscalString := TNonFiscalString(Positions[i]);
          PrintNonFiscalString(NonFiscalString.Text);
        end;
        if Positions.Items[i] is TBarcode then
        begin
          Barcode := TBarcode(Positions[i]);
          PrintBarcode(Barcode.BarcodeType, Barcode.Barcode);
        end;
      end;
    finally
      Positions.Free;
    end;
    CloseCheck(0, 0, 0, 0, 0);
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.CloseCheckFN(Cash, PayByCard, PayByCredit, PayBySertificate: Double; ATaxType: Integer; TotalSumm: Double);
begin
  SetAdminPassword;
  CheckReceiptOpened;
  if FIsFiscalCheck then
  begin
    Driver.RoundingSumm := 0; //RoundSumm;
    Driver.Summ1 := Cash;
    Driver.Summ2 := PayByCard;
    Driver.Summ3 := PayByCredit;
    Driver.Summ4 := PayBySertificate;
    Driver.Summ5 := 0;
    Driver.Summ6 := 0;
    Driver.Summ7 := 0;
    Driver.Summ8 := 0;
    Driver.Summ9 := 0;
    Driver.Summ10 := 0;
    Driver.Summ11 := 0;
    Driver.Summ12 := 0;
    Driver.Summ13 := 0;
    Driver.Summ14 := 0;
    Driver.Summ15 := 0;
    Driver.Summ16 := 0;
    Driver.TaxValue1 := 0;
    Driver.TaxValue2 := 0;
    Driver.TaxValue3 := 0;
    Driver.TaxValue4 := 0;
    Driver.TaxValue5 := 0;
    Driver.TaxValue6 := 0;
    Driver.TaxType := ATaxType;
    Driver.StringForPrinting := '';
    Driver.DiscountOnCheck := 0;
    Driver.Tax1 := 0;
    Driver.Tax2 := 0;
    Driver.Tax3 := 0;
    Driver.Tax4 := 0;
    Check(Driver.FNCloseCheckEx);
    WaitForPrinting;
  end
  else
  begin
    FeedAndCut;
    if FNonFiscalCheckNumber = 9999 then
      FNonFiscalCheckNumber := 1
    else
      FNonFiscalCheckNumber := FNonFiscalCheckNumber + 1;
    SaveToReg; // Сохраняем номер нефискального чека в реестр
  end;
  FIsOpenedCheck := False;
end;

procedure TDevice1C.CloseCheckFN22(Cash, ElectronicPayment, AdvancePayment, Credit, CashProvision: Double; ATaxType: Integer; TotalSumm: Double);
begin
  SetAdminPassword;
  CheckReceiptOpened;
  if FIsFiscalCheck then
  begin
    Driver.RoundingSumm := 0; //RoundSumm;
    Driver.Summ1 := Cash;
    Driver.Summ2 := ElectronicPayment;
    Driver.Summ3 := 0;
    Driver.Summ4 := 0;
    Driver.Summ5 := 0;
    Driver.Summ6 := 0;
    Driver.Summ7 := 0;
    Driver.Summ8 := 0;
    Driver.Summ9 := 0;
    Driver.Summ10 := 0;
    Driver.Summ11 := 0;
    Driver.Summ12 := 0;
    Driver.Summ13 := 0;
    Driver.Summ14 := AdvancePayment;
    Driver.Summ15 := Credit;
    Driver.Summ16 := CashProvision;
    Driver.TaxValue1 := 0;
    Driver.TaxValue2 := 0;
    Driver.TaxValue3 := 0;
    Driver.TaxValue4 := 0;
    Driver.TaxValue5 := 0;
    Driver.TaxValue6 := 0;
    Driver.TaxType := ATaxType;
    Driver.StringForPrinting := '';
    Driver.DiscountOnCheck := 0;
    Driver.Tax1 := 0;
    Driver.Tax2 := 0;
    Driver.Tax3 := 0;
    Driver.Tax4 := 0;
    Check(Driver.FNCloseCheckEx);
    WaitForPrinting;
  end
  else
  begin
    FeedAndCut;
    if FNonFiscalCheckNumber = 9999 then
      FNonFiscalCheckNumber := 1
    else
      FNonFiscalCheckNumber := FNonFiscalCheckNumber + 1;
    SaveToReg; // Сохраняем номер нефискального чека в реестр
  end;
  FIsOpenedCheck := False;
end;

function TDevice1C.DrvFNCloseCheck: Integer;
begin
  Result := Driver.FNCloseCheckEx;
end;

function TDevice1C.DrvDiscountTaxOperation: Integer;
begin
  Result := Driver.FNDiscountOperation;
{  case fRecType of
    0: Result := Driver.Sale;
    1: Result := Driver.Buy;
    2: Result := Driver.ReturnSale;
    3: Result := Driver.ReturnBuy;
  end;}
end;

procedure TDevice1C.SetCashierPassword(const ACashierName: WideString);
var
  CashierRowNumber: Integer;
begin
  Logger.Debug('SetCashierPassword ' + ACashierName);
  SetAdminPassword;
  Driver.TableNumber := 2;

  CashierRowNumber := 30;
{  for i := 30 downto 1 do
  begin
    Driver.RowNumber := i;
    Driver.FieldNumber := 1;
    Check(Driver.ReadTable);
    if Driver.ValueOfFieldInteger = FAdminPassword then
    begin
      CashierRowNumber := i;
      Break;
    end;
  end;}
  Driver.RowNumber := CashierRowNumber;
{  Driver.FieldNumber := 1;
  Driver.ValueOfFieldInteger := FAdminPassword;
  Check(Driver.WriteTable);}
  Driver.FieldNumber := 2;
  if ACashierName = '' then
    Driver.ValueOfFieldString := ' '
  else
    Driver.ValueOfFieldString := ACashierName;
  Check(Driver.WriteTable);

  SetAdminPassword;
end;

procedure TDevice1C.WaitForPrinting;
var
  Res: Integer;
begin
  repeat
    Res := Driver.WaitForPrinting;
  until (Res <> 107) and (Res <> -34);
  Check(Res);

end;

function TDevice1C.TaxToBin(const ATax: Integer): Byte;
begin
  Result := 0;
  case ATax of
    0:
      setbit(Result, 0);
    1:
      setbit(Result, 1);
    2:
      setbit(Result, 2);
    3:
      setbit(Result, 3);
    4:
      setbit(Result, 4);
    5:
      setbit(Result, 5);
    6:
      setbit(Result, 6);
  end;
end;

function TDevice1C.GetXMLStatusParameters: WideString;
var
  Xml: IXMLDocument;
  Node: IXMLNode;
begin
  Result := '';
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('StatusParameters');
    Node := Node.AddChild('Parameters');
    Node.Attributes['BacklogDocumentsCounter'] := IntToStr(Driver.MessageCount);
    Node.Attributes['BacklogDocumentFirstNumber'] := IntToStr(Driver.DocumentNumber);
    Node.Attributes['BacklogDocumentFirstDateTime'] := DateTimeToXML(Driver.Date + Driver.Time);
    Result := XMLStringToWideString(Xml.XML.Text);
  finally
    Xml := nil;
  end;
end;

procedure TDevice1C.SendTags(APositions: TPositions1C);
var
  AgSign: Byte;
begin
  SendStrTag(1192, APositions.AdditionalAttribute);
  if APositions.AdditionalAttribute <> '' then
    PrintPair('ДОП.РЕКВ.', APositions.AdditionalAttribute);

  if APositions.AgentData.Enabled then
  begin
    SendStrTag(1044, APositions.AgentData.PayingAgentOperation);
    SendStrTag(1073, APositions.AgentData.PayingAgentPhone);
    SendStrTag(1074, APositions.AgentData.ReceivePaymentsOperatorPhone);
    SendStrTag(1075, APositions.AgentData.MoneyTransferOperatorPhone);
    SendStrTag(1026, APositions.AgentData.MoneyTransferOperatorName);
    SendStrTag(1005, APositions.AgentData.MoneyTransferOperatorAddress);
    SendStrTag(1016, APositions.AgentData.MoneyTransferOperatorVATIN);
  end;

  if APositions.PurveyorData.Enabled then
  begin
    SendStrTag(1171, APositions.PurveyorData.PurveyorPhone);
  end;

  if APositions.AgentSign <> '' then
  begin
    AgSign := 0;
    SetBit(AgSign, StrToInt(Trim(APositions.AgentSign)));

    Driver.TagNumber := 1057; // Признак агента
    Driver.TagType := ttByte;
    Driver.TagValueInt := AgSign;
    Check(Driver.FNSendTag); // Отправить тег 1057
  end;

  if APositions.UserAttribute.Enabled then
  begin
    Driver.TagNumber := 1084;
    Check(Driver.FNBeginSTLVTag);
    AddStrTag(1085, Copy(APositions.UserAttribute.Name, 1, 64));
    AddStrTag(1086, Copy(APositions.UserAttribute.Value, 1, 255));
    Check(Driver.FNSendSTLVTag);
  end;

  if APositions.CustomerInfo <> '' then
  begin
    Driver.TagNumber := 1227;
    Driver.TagType := ttString;
    Driver.TagValueStr := APositions.CustomerInfo;
    Check(Driver.FNSendTag);
  end;

  if APositions.CustomerINN <> '' then
  begin
    Driver.TagNumber := 1228;
    Driver.TagType := ttString;
    Driver.TagValueStr := APositions.CustomerINN;
    Check(Driver.FNSendTag);
  end;
end;

procedure TDevice1C.AddStrTag(ATagNumber: Integer; const AValue: string);
begin
  if AValue = '' then Exit;
  Driver.TagNumber := ATagNumber;
  Driver.TagType := ttString;
  Driver.TagValueStr := AValue;
  Check(Driver.FNAddTag);
end;

procedure TDevice1C.SendAgentDataOperation(
    AgentData: TAgentData;
    PurveyorData: TPurveyorData;
    AgentSign: WideString);
var
  AgSign: Byte;
begin
  if AgentData.Enabled then
  begin
    Driver.TagNumber := 1223; // Данные агента
    Check(Driver.FNBeginSTLVTag); // Начинаем формирование составного тега

    AddStrTag(1044, AgentData.PayingAgentOperation);
    AddStrTag(1073, AgentData.PayingAgentPhone);
    AddStrTag(1074, AgentData.ReceivePaymentsOperatorPhone);
    AddStrTag(1075, AgentData.MoneyTransferOperatorPhone);
    AddStrTag(1026, AgentData.MoneyTransferOperatorName);
    AddStrTag(1005, AgentData.MoneyTransferOperatorAddress);
    AddStrTag(1016, AgentData.MoneyTransferOperatorVATIN);
    Check(Driver.FNSendSTLVTagOperation); // Отправляем составной тег 1223, привязанный к операции
  end;

  if PurveyorData.Enabled then
  begin
    Driver.TagNumber := 1224; // Данные поставщика
    Check(Driver.FNBeginSTLVTag); // Начинаем формирование составного тега

    Logger.Debug('PurveyorPhone: ' + PurveyorData.PurveyorPhone);
    AddStrTag(1171, PurveyorData.PurveyorPhone);
    Logger.Debug('PurveyorName: ' + PurveyorData.PurveyorName);
    AddStrTag(1225, PurveyorData.PurveyorName);
    Check(Driver.FNSendSTLVTagOperation);
  end;

  if PurveyorData.PurveyorVATIN <> '' then
  begin
    // Привязка ИНН поставщика к операции
    Driver.TagNumber := 1226;
    Driver.TagType := ttString;
    Driver.TagValueStr := PurveyorData.PurveyorVATIN; // ИНН поставщика
    Check(Driver.FNSendTagOperation); // Отправить тег 1226, привязанный к операции
  end;

  Logger.Debug('AgentSign: ' + AgentSign);
  // Признак агента
  if AgentSign <> '' then
  begin
    AgSign := 0;
    SetBit(AgSign, StrToInt(Trim(AgentSign)));

    Driver.TagNumber := 1222; // Признак агента
    Driver.TagType := ttByte;
    Driver.TagValueInt := AgSign;
    Check(Driver.FNSendTagOperation); // Отправить тег 1222, привязанный к операции}
  end;

end;


{procedure TDevice1C.SendDoubleTag(ATag: Integer; const AValue: Double);
begin
  if AValue < 0 then
    Exit;
  Driver.TLVData := TFormatTLV.Int2ValueTLV(ATag, 2) + TFormatTLV.Int2ValueTLV(6, 2) + TFormatTLV.Int2ValueTLV(Trunc(AValue * 100), 6);
  Check(Driver.FNSendTLV);
end;}

procedure TDevice1C.SendStrTag(ATag: Integer; const AValue: WideString);
begin
  if AValue = '' then
    Exit;
  Driver.TagNumber := ATag;
  Driver.TagType := ttString;
  Driver.TagValueStr := AValue;
  Check(Driver.FNSendTag);
end;

procedure TDevice1C.SendStrTagOperation(ATag: Integer; const AValue: WideString);
begin
  if AValue = '' then
    Exit;
  Driver.TagNumber := ATag;
  Driver.TagType := ttString;
  Driver.TagValueStr := AValue;
  Check(Driver.FNSendTagOperation);
end;

function TDevice1C.DateTimeToXML(AValue: TDateTime): WideString;
begin
  Result := FormatDateTime('yyyy-mm-dd"T"hh:mm:ss', AValue);
end;

function TDevice1C.StrToDouble(const AValue: WideString): Double;
var
  saveSeparator: Char;
begin
  saveSeparator := DecimalSeparator;
  try
    try
      DecimalSeparator := '.';
      Result := StrToFloat(AValue);
    except
      Result := -1;
    end;
  finally
    DecimalSeparator := saveSeparator;
  end;
end;

procedure TDevice1C.PrintPair(const AStr1, AStr2: string);
var
  S: string;
begin
  S := AStr1 + StringOfChar(' ', FLineLength - (Length(AStr1) + Length(AStr2))) + AStr2;
  Logger.Debug('>>' + S);
  PrintStringWithWrap(S);
end;

procedure TDevice1C.PrintTag(const AStr1, AStr2: string);
begin
  if AStr2 <> '' then
    PrintPair(AStr1, AStr2);
end;

procedure TDevice1C.PrintFiscalString22(AFiscalString: TFiscalString22);
begin
  CheckReceiptOpened;
  SetAdminPassword;

  if not FIsFiscalCheck then
    RaiseError(C_ERR_CHECKOPENED, GetRes(@SInvalidOperationInNonfiscalDocument));


  PrintFiscalLineFN(AFiscalString.Name, AFiscalString.Quantity,
                      AFiscalString.PriceWithDiscount,
                      AFiscalString.SumWithDiscount,
                      AFiscalString.DiscountSum,
                      AFiscalString.Department,
                      AFiscalString.Tax,
                      AFiscalString.ItemCodeData,
                      AFiscalString.AgentData,
                      AFiscalString.PurveyorData,
                      AFiscalString.AgentSign,
                      AFiscalString.SignMethodCalculation,
                      AFiscalString.SignCalculationObject,
                      AFiscalString.CountryOfOfigin,
                      AFiscalString.CustomsDeclaration,
                      AFiscalString.ExciseAmount,
                      AFiscalString.AdditionalAttribute,
                      AFiscalString.MeasurementUnit
                      );
end;

procedure TDevice1C.PrintFiscalStringFN2(const AName: WideString; AQuantity, APrice, AAmount: Double; ADepartment, ATax: Integer);
var
  Q1: Double;
  P1: Double;
  Discount: Double;
  Total: Double;
  Diff: Double;
  CalculatedPrice: Double;
  NewAmount: Double;
//  QStart: Double;
  QNew: Double;
  PNew: Double;
  Marking: TItemCodeData;
  AgentData: TAgentData;
  PurveyorData: TPurveyorData;
  AgentSign: WideString;
begin
  Marking.StampType := '';
  Marking.MarkingCode := '';
  Marking.SerialNumber :='';
  AgentData.Enabled := False;
  PurveyorData.Enabled := False;
  PurveyorData.PurveyorVATIN := '';
  AgentSign := '';

  CheckReceiptOpened;
  SetAdminPassword;

  if not FIsFiscalCheck then
    RaiseError(C_ERR_CHECKOPENED, GetRes(@SInvalidOperationInNonfiscalDocument));

  if (AQuantity = 0) or (AQuantity = 1) then
  begin
    Q1 := 1;
    P1 := ExRound(AAmount, 0.01);
    Total := ExRound(AAmount, 0.01);
    Discount := ExRound(APrice - AAmount, 0.01);
    PrintFiscalLineFN(AName, Q1, P1, Total, Discount, ADepartment, ATax, Marking, AgentData, PurveyorData, AgentSign);
    Exit;
  end;

  CalculatedPrice := ExRound(AAmount / AQuantity, 0.01);
  NewAmount := ExRound(AQuantity * CalculatedPrice, 0.01);
  Diff := NewAmount - AAmount;
  // Если разница не выходит за пределы одной копейки, то пробиваем одну позицию
  //if (Diff >= -0.01) and (Diff <= 0.01) then

  Logger.Debug(Format('Calc price %.2f', [CalculatedPrice]));
  Logger.Debug(Format('New amount %.2f', [NewAmount]));
  Logger.Debug(Format('Diff %.2f', [Diff]));


  if ((CompareValue(Diff, -0.01, C_DOUBLE_PREC) = GreaterThanValue) or
     (CompareValue(Diff, -0.01, C_DOUBLE_PREC) = EqualsValue)) and
     ((CompareValue(Diff, 0.01, C_DOUBLE_PREC) = LessThanValue) or
     (CompareValue(Diff, 0.01, C_DOUBLE_PREC) = EqualsValue)) then
  begin
    Q1 := ExRound(AQuantity, 0.000001);
    P1 := CalculatedPrice;
    Total := ExRound(AAmount, 0.01);
    Discount := ExRound(APrice * AQuantity - AAmount, 0.01);
    PrintFiscalLineFN(AName, Q1, P1, Total, Discount, ADepartment, ATax, Marking, AgentData, PurveyorData, AgentSign);
    Exit;
  end;
  // Иначе разбиваем на две позиции
//  QStart := AQuantity;
  QNew := Abs(ExRound(Diff / 0.01, 0.000001));
  PNew := CalculatedPrice - ExRound(Diff / QNew, 0.01);
  Q1 := AQuantity - QNew;
  P1 := CalculatedPrice;
  Total := ExRound(Q1 * CalculatedPrice, 0.01);
  Discount := 0;
  PrintFiscalLineFN(AName, Q1, P1, Total, Discount, ADepartment, ATax, Marking, AgentData, PurveyorData, AgentSign);
  // Вторая позиция
  Q1 := QNew;
  P1 := PNew;
  Total := ExRound(QNew * PNew, 0.01);
  Discount := ExRound(APrice * AQuantity - AAmount, 0.01);
  PrintFiscalLineFN(AName, Q1, P1, Total, Discount, ADepartment, ATax, Marking, AgentData, PurveyorData, AgentSign);
end;

function QuantityToStr(AQuantity: Double): string;
var
  C: Char;
begin
  C := DecimalSeparator;
  DecimalSeparator := '.';
  Result := FloatToStr(AQuantity);
  DecimalSeparator := C;
end;

procedure TDevice1C.PrintFiscalLineFN(const AName: WideString; AQuantity, APrice,
                                       ATotal, ADiscount: Double; ADepartment,
                                       ATax: Integer;
                                       ItemCodeData: TItemCodeData;
                                       AgentData: TAgentData;
                                       PurveyorData: TPurveyorData;
                                       AgentSign: WideString;
                                       APaymentTypeSign: Integer;
                                       APaymentItemSign: Integer;
                                       ACountryOfOrigin: WideString;
                                       ACustomsDeclaration: WideString;
                                       AExciseAmount: WideString;
                                       AAdditionalAttribute: WideString;
                                       AMeasurementUnit: WideString
                                       );

  function PaymentTypeSignToStr(AValue: Integer): string;
  begin
    case AValue of
      1:
        Result := 'ПРЕДОПЛАТА 100%';
      2:
        Result := 'ПРЕДОПЛАТА';
      3:
        Result := 'АВАНС';
      4:
        Result := 'ПОЛНЫЙ РАСЧЕТ';
      5:
        Result := 'ЧАСТИЧНЫЙ РАСЧЕТ И КРЕДИТ';
      6:
        Result := 'ПЕРЕДАЧА В КРЕДИТ';
      7:
        Result := 'ОПЛАТА КРЕДИТА';
    else
      Result := 'НЕИЗВ.';
    end;
  end;

  function PaymentItemSignToStr(AValue: Integer): string;
  begin
    case AValue of
      1:
        Result := 'ТОВАР';
      2:
        Result := 'ПОДАКЦИЗНЫЙ ТОВАР';
      3:
        Result := 'РАБОТА';
      4:
        Result := 'УСЛУГА';
      5:
        Result := 'СТАВКА ИГРЫ';
      6:
        Result := 'ВЫИГРЫШ АИ';
      7:
        Result := 'СТАВКА ЛОТЕРЕИ';
      8:
        Result := 'ВЫИГРЫШ ЛОТЕРЕИ';
      9:
        Result := 'РИД';
      10:
        Result := 'ПЛАТЕЖ';
      11:
        Result := 'АВ';
      12:
        Result := 'СПР';
      13:
        Result := 'ИПР';
      14:
        Result := 'ИМУЩЕСТВЕННОЕ ПРАВО';
      15:
        Result := 'ВНЕРЕЛЕАЛИЗАЦИОННЫЙ ДОХОД';
      16:
        Result := 'СТРАХОВЫЕ ВЗНОСЫ';
      17:
        Result := 'ТОРГОВЫЙ СБОР';
      18:
        Result := 'КУРОРТНЫЙ СБОР';
      19:
        Result := 'ЗАЛОГ';

    else
      Result := 'НЕИЗВ.';

    end;
  end;

var
  SaveSeparator: Char;
  Excise: Int64;
  MC: Integer;


procedure PrintTextLines;
begin
  if (APaymentItemSign <> 15) and (APaymentItemSign <> 16) then
  begin
    PrintText(AName, True);
    SaveSeparator := DecimalSeparator;
    DecimalSeparator := '.';
    try
      PrintPair('', Format('%s ' + MUL + ' %.2f', [QuantityToStr(AQuantity), APrice]));
      if ADepartment > 16 then
        raise Exception.Create('Invalid Department value');
      if ADepartment = 0 then
        PrintPair(' ', Format(EQU + '%.2f', [ATotal]))
      else
        PrintPair(FDepartments[ADepartment], Format(EQU + '%.2f', [ATotal]));

      if (ItemCodeData.StampType <> '') and (ItemCodeData.GTIN <> '') then
        PrintPair('', '[M]');

      if (FFFDVersion = 2) and (EnablePaymentSignPrint) then
      begin
        if APaymentTypeSign = 4 then
          PrintPair('', PaymentItemSignToStr(APaymentItemSign))
        else
          PrintPair(PaymentTypeSignToStr(APaymentTypeSign), PaymentItemSignToStr(APaymentItemSign));

        {  PrintPair('СП.РАСЧ.', PaymentTypeSignToStr(APaymentTypeSign));
        PrintPair('ПРЕДМ.РАСЧ.', PaymentItemSignToStr(APaymentItemSign));}
      end;

    finally
      DecimalSeparator := SaveSeparator;
    end;
  end;

  PrintText(FTaxNames[ATax], False);

  SaveSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  try
    if CompareValue(ADiscount, 0, C_DOUBLE_PREC) = GreaterThanValue then
      PrintPair('СКИДКА', Format('%.2f', [ADiscount]))
    else
    if CompareValue(ADiscount, 0, C_DOUBLE_PREC) = LessThanValue then
      PrintPair('НАДБАВКА', Format('%.2f', [-ADiscount]));
  finally
    DecimalSeparator := SaveSeparator;
  end;

end;

procedure BindTags;
begin
  if not IsModelType2(GetModelID) then
  begin
    if (ItemCodeData.MarkingCode <> '') and (FSessionRegOpened) then
    begin
      Driver.BarCode := ItemCodeData.MarkingCode;
      Check(Driver.FNBindMarkingItem);
    end;
  end;

  Logger.Debug('M StampType = ' + ItemCodeData.StampType);
  Logger.Debug('M Stamp = ' + ItemCodeData.Stamp);
  Logger.Debug('M SerialNumber = ' + ItemCodeData.SerialNumber);
  Logger.Debug('M GTIN = ' + ItemCodeData.GTIN);

  if ItemCodeData.StampType <> '' then
  begin
    try
      MC := StrToInt(ItemCodeData.StampType);
      case MC of
        1520: Driver.MarkingType := 5408;
      else
        Driver.MarkingType := MC;
      end;
    except
      raise Exception.Create('Invalid Stamp Type value ' + ItemCodeData.StampType);
    end;
    if Driver.MarkingType = 2 then
      Driver.SerialNumber := ItemCodeData.Stamp
    else
      Driver.SerialNumber := ItemCodeData.SerialNumber;

    Driver.GTIN := ItemCodeData.GTIN;
    Check(Driver.FNSendItemCodeData);
  end;

  SendStrTagOperation(1230, ACountryOfOrigin);
  SendStrTagOperation(1231, ACustomsDeclaration);
  SendStrTagOperation(1191, AAdditionalAttribute);
  SendStrTagOperation(1197, AMeasurementUnit);


  if AExciseAmount <> '' then
  begin

    saveSeparator := DecimalSeparator;
    try
      DecimalSeparator := '.';
      try
        Excise := Trunc(StrToFloat(AExciseAmount) * 100);
        Driver.TagNumber := 1229;
        Driver.TagType := ttVLN;
        Driver.TagValueVLN := Int64ToStr(Excise);
        Check(Driver.FNSendTagOperation);
      except
        on E: Exception do
          Logger.Error(E.Message);
      end;
    finally
      DecimalSeparator := saveSeparator;
    end;
  end;

  SendAgentDataOperation(AgentData, PurveyorData, AgentSign);
end;

procedure DoOperation;
begin
// Продажа
  Driver.Tax1 := ATax;
  Driver.Tax2 := 0;
  Driver.Tax3 := 0;
  Driver.Tax4 := 0;
  if (APaymentItemSign <> 15) and (APaymentItemSign <> 16) then
    Driver.StringForPrinting := '//' + AName
  else
    Driver.StringForPrinting := AName;
  Driver.Price := APrice;
  Driver.Quantity := AQuantity;
  Driver.Summ1Enabled := True;
  Driver.Summ1 := ATotal;
  Driver.Department := ADepartment;
  FStringForPrinting := '';
  Driver.BarCode := '0';
  Driver.DiscountName := '';
  Driver.TaxValueEnabled := False;
  Driver.PaymentTypeSign := APaymentTypeSign;
  Driver.PaymentItemSign := APaymentItemSign;

  Driver.CheckType := fRecType;
  Check(Driver.FNOperation);
end;

begin
  Logger.Debug(Format('PrintFiscalLine Name=%s, Q=%.6f, P=%.2f, T=%.2f, D=%.2f, Dep=%d, Tax=%d', [AName, AQuantity, APrice, ATotal, ADiscount, ADepartment, ATax]));
  CheckReceiptOpened;
  SetAdminPassword;
  if not FIsFiscalCheck then
    RaiseError(C_ERR_CHECKOPENED, GetRes(@SInvalidOperationInNonfiscalDocument));

  PrintTextLines;
  if IsModelType2(GetModelID) then
  begin
    BindTags;
    DoOperation;
  end
  else
  begin
    DoOperation;
    BindTags;
  end;
end;

function TDevice1C.DrvFinishDocument: Integer;
begin
  Result := Driver.FinishDocument;
end;

procedure TDevice1C.ReadTaxNames;
var
  i: Integer;
  TaxRateCount: Integer;
begin
  if FOldKKT then
    TaxRateCount := 4
  else
    TaxRateCount := 6;

  Driver.TableNumber := 6;
  for i := 1 to TaxRateCount do
  begin
    Driver.RowNumber := i;
    Driver.FieldNumber := 2;
    Check(Driver.ReadTable);
    FTaxNames[i] := Driver.ValueOfFieldString;
  end;
end;

procedure TDevice1C.doProcessCheck(const CashierName: WideString; Electronically: Boolean; const CheckPackage: WideString; var CheckNumber, SessionNumber: Integer; var FiscalSign, AddressSiteInspections: WideString);
var
  Positions: TPositions1C;
  i: Integer;
  FiscalString: TFiscalString;
  NonFiscalString: TNonFiscalString;
  Barcode: TBarcode;
  RecNumber: Integer;
  TotalSumm: Double;
  RequisitePrint: Byte;
begin
  Logger.Debug('ProcessCheck( ' + 'Cashier ' + CashierName + ')');
  Logger.Debug('CheckPackage: ' + CheckPackage);
  LockPort;
  try
    SetAdminPassword;
    TotalSumm := 0;
    AddressSiteInspections := FAddressSiteInspections;
    if not IsModelType2(GetModelID) then
    begin
      RequisitePrint := ReadTableInt(17, 1, 12);
      if not TestBit(RequisitePrint, 5) then
        SetBit(RequisitePrint, 5);
      WriteTableInt(17, 1, 12, RequisitePrint);
    end;
    // Подавление печати следующего документа
    if (Electronically) and not (IsModelType2(GetModelID)) then
      WriteTableInt(17, 1, 7, 1);
    Positions := TPositions1C.Create;
    try
      Positions.FFDversion := FFFDVersion;
      Positions.BPOVersion := BPOVersion;
      Positions.ItemNameLength := Params.ItemNameLength;
      Positions.ReadFromXML(CheckPackage);
      if BPOVersion = 22 then
        OpenCheckFN(Positions.CashierName, Positions.PaymentType, True, RecNumber, SessionNumber)
      else
        OpenCheckFN(CashierName, Positions.PaymentType, True, RecNumber, SessionNumber);

      try
        if Positions.CustomerPhone <> '' then
        begin
          Driver.CustomerEmail := Positions.CustomerPhone;
          Check(Driver.FNSendCustomerEmail);
        end;

        if Positions.CustomerEmail <> '' then
        begin
          Driver.CustomerEmail := Positions.CustomerEmail;
          Check(Driver.FNSendCustomerEmail);
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

        SendTags(Positions); // Отправка дополнительных тэгов

        if GetBPOVersion = 22 then
        begin
          SetCashierVATIN(Positions.CashierVATIN);
          SetAgentData(Positions.AgentData);
          SetPurveyorData(Positions.PurveyorData);
        end;
        for i := 0 to Positions.Count - 1 do
        begin
          if Positions.Items[i] is TFiscalString then
          begin
            FiscalString := TFiscalString(Positions[i]);
            TotalSumm := TotalSumm + FiscalString.Amount;
            PrintFiscalStringFN2(FiscalString.Name, FiscalString.Quantity, FiscalString.Price, FiscalString.Amount, FiscalString.Department, FiscalString.Tax);
          end;
          if Positions.Items[i] is TFiscalString22 then
          begin
            TotalSumm := TotalSumm + TFiscalString22(Positions.Items[i]).SumWithDiscount;
            PrintFiscalString22(TFiscalString22(Positions.Items[i]));
          end;
          if Positions.Items[i] is TNonFiscalString then
          begin
            NonFiscalString := TNonFiscalString(Positions[i]);
            PrintNonFiscalString(NonFiscalString.Text);
          end;
          if Positions.Items[i] is TBarcode then
          begin
            Barcode := TBarcode(Positions[i]);
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
      if BPOVersion = 22 then
        CloseCheckFN22(Positions.Cash, Positions.ElectronicPayment, Positions.AdvancePayment, Positions.Credit, Positions.CashProvision, TaxToBin(Positions.TaxVariant), TotalSumm)
      else
        CloseCheckFN(Positions.Cash, Positions.Payment1, Positions.Payment2, Positions.Payment3, TaxToBin(Positions.TaxVariant), TotalSumm);
    finally
      Positions.Free;
    end;
    CheckNumber := Cardinal(Driver.DocumentNumber);
    FiscalSign := IntToStr(Cardinal(Driver.FiscalSign));
    Logger.Debug('Fd FS ' + IntToStr(CheckNumber) + ' ' + FiscalSign);
  finally
    FSessionRegOpened := False;
    UnlockPort;
  end;
end;

procedure TDevice1C.WaitForConnect;
var
  T: Cardinal;
  Res: Integer;
begin
  T := GetTickCount;
  while True do
  begin
    Driver.Disconnect;
    Res := Driver.Connect;
    if Res = 0 then
      Break;
    if Abs(GetTickCount - T) >= 25000 then
    begin
      Check(Res);
      Break;
    end;
    Sleep(20);
  end;
end;

procedure TDevice1C.RebootECR;
begin
  Check(Driver.RebootKKT);
end;

procedure TDevice1C.CloseShiftFN22(InputParameters: WideString; var OutputParameters: WideString; var SessionNumber, DocumentNumber: Integer);
var
  InParams: TInputParametersRec;
  OutParams: TCloseSessionOutputParamsRec;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data CloseShiftFN22');
    SessionNumber := 1;
    DocumentNumber := 1;
    ZeroMemory(@OutParams, SizeOf(OutParams));
    OutputParameters := EncodeOutputParametersCloseSession22(OutParams);
    Exit;
  end;

  LockPort;
  try
    ParseInputParameters(InputParameters, InParams);
    SetCashierPassword(InParams.CashierName);
    Check(Driver.FNGetCurrentSessionParams);
    SessionNumber := Driver.SessionNumber;
    OutParams.NumberOfChecks := Driver.ReceiptNumber;
    OutParams.NumberOfDocuments := Driver.ReceiptNumber + 1;
    Check(Driver.FNGetInfoExchangeStatus);
    OutParams.BacklogDocumentsCounter := Driver.MessageCount;
    OutParams.BacklogDocumentFirstNumber := Driver.DocumentNumber;
    OutParams.BacklogDocumentFirstDateTime := Driver.Date + Driver.Time;
    Check(Driver.FNBeginCloseSession);

    SetCashierVATIN(InParams.CashierVATIN);
    Check(Driver.PrintReportWithCleaning);
    Check(Driver.WaitForPrinting);
    Check(Driver.FNGetStatus);
    OutParams.OFDtimeout := TestBit(Driver.FNWarningFlags, 3);
    DocumentNumber := Driver.DocumentNumber;
    Check(Driver.FNGetCurrentSessionParams);
    OutputParameters := EncodeOutputParametersCloseSession22(OutParams);
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.OpenShiftFN22(InputParameters: WideString; var OutputParameters: WideString; var SessionNumber, DocumentNumber: Integer);
var
  InParams: TInputParametersRec;
  OutParams: TOpenSessionOutputParamsRec;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data CloseShiftFN22');
    SessionNumber := 1;
    DocumentNumber := 1;
    ZeroMemory(@OutParams, SizeOf(OutParams));
    OutputParameters := EncodeOutputParametersOpenSession22(OutParams);
    Exit;
  end;

  LockPort;
  try
    if IsSessionOpened then
      raise Exception.Create('Смена уже открыта');
    Logger.Debug('OpenSession input params: ' + InputParameters);
    ParseInputParameters(InputParameters, InParams);
    SetCashierPassword(InParams.CashierName);
    Check(Driver.FNBeginOpenSession);
    SetCashierVATIN(InParams.CashierVATIN);
    Check(Driver.OpenSession);
    Check(Driver.WaitForPrinting);
    Check(Driver.FNGetStatus);
    OutParams.OFDtimeout := TestBit(Driver.FNWarningFlags, 3);
    OutputParameters := EncodeOutputParametersOpenSession22(OutParams);
    DocumentNumber := Driver.DocumentNumber;
    Check(Driver.FNGetCurrentSessionParams);
    SessionNumber := Driver.SessionNumber;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.ParseInputParameters(const AXML: WideString; var Params: TInputParametersRec);
var
  Xml: IXMLDocument;
  Node: IXMLNode;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXML(AXML);
    Node := Xml.ChildNodes.FindNode('InputParameters');
    if Node = nil then
      raise Exception.Create('Wrong XML input parameters Table');
    Node := Node.ChildNodes.FindNode('Parameters');
    if Node = nil then
      raise Exception.Create('Wrong XML input parameters Table');
    Params.CashierName := Node.Attributes['CashierName'];
    Params.CashierVATIN := Node.Attributes['CashierVATIN'];
  finally
    Xml := nil;
  end;
end;

procedure TDevice1C.PrintDepartmentReport;
begin
  try
    Check(Driver.Disconnect);
    ApplyDeviceParams;
    SetAdminPassword;
    LockPort;
    Check(Driver.PrintDepartmentReport);
  finally
    UnlockPort;
    Driver.Disconnect;
  end;
end;

procedure TDevice1C.PrintTaxReport;
begin
  try
    Check(Driver.Disconnect);
    ApplyDeviceParams;
    SetAdminPassword;
    LockPort;
    Check(Driver.PrintTaxReport);
  finally
    UnlockPort;
    Driver.Disconnect;
  end;
end;

procedure TDevice1C.GetDataKKT22(var TableParameters: WideString);
var
  Xml: IXMLDocument;
  KKTNumber: WideString; // 	Регистрационный номер ККТ
  KKTSerialNumber: WideString; //  	Заводской номер ККТ
  Fiscal: Boolean; // 	Да 	boolean 	Признак регистрация фискального накопителя
  FNSerialNumber: WideString; // 	Да 	string 	Заводской номер ФН
  DocumentNumber: WideString; // 	Нет 	string 	Номер документа регистрация фискального накопителя
  FNDateTime: WideString; // 	Нет 	datetime 	Дата и время операции регистрация фискального накопителя
  OrganizationName: WideString; // 	Нет 	string 	Название организации
  VATIN: WideString; // 	Нет 	string 	ИНН организация
  AddressSettle: WideString; // 	Нет 	string 	Адрес установки ККТ для проведения расчетов
  TaxVariant: WideString; // 	Нет 	string 	Коды системы налогообложения через разделитель
  OfflineMode: Boolean; // 	Нет 	boolean 	Признак автономного режима
  AutomaticMode: Boolean; // 	Нет 	boolean 	Признак автоматического режима
  AutomaticNumber: WideString; // 	Нет 	string 	Номер автомата для автоматического режима
  OFDOrganizationName: WideString; // 	Нет 	string 	Название организации ОФД
  OFDVATIN: WideString; //ИНН организация ОФД
  ServiceSign: Boolean;
  CalcOnlineSign: Boolean;
  BSOSign: Boolean;
  FFDVersion: WideString;
  Node: IXMLNode;
  WMode: Integer;
  Res: Integer;
  PlaceSettle: WideString;
  DataEncryption: Boolean;
  FNSWebSite: WideString;
  SenderEmail: WideString;
  AgentSign: Integer;
  Model: Integer;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data GetDataKKT22');
    Xml := TXMLDocument.Create(nil);
    try
      Xml.Active := True;
      Xml.Version := '1.0';
      Xml.Encoding := 'UTF-8';
      Xml.Options := Xml.Options + [doNodeAutoIndent];
      Node := Xml.AddChild('Parameters');
      Node.Attributes['KKTNumber'] := '';
      Node.Attributes['KKTSerialNumber'] := '';
      Node.Attributes['Fiscal'] := 'true';
      Node.Attributes['DocumentNumber'] := '1';
      Node.Attributes['DateTime'] := DateTimeToXML(Now);
      Node.Attributes['FNSerialNumber'] := '';
      Node.Attributes['OrganizationName'] := '';
      Node.Attributes['VATIN'] := '';
      Node.Attributes['AddressSettle'] := '';
      Node.Attributes['TaxVariant'] := GetODTaxSystems;
      Node.Attributes['FFDVersionFN'] := '1.0.5';
      Node.Attributes['FFDVersionKKT'] := '1.0.5';
      Node.Attributes['AutomaticNumber'] := '';
      Node.Attributes['OfflineMode'] := 'false';
      Node.Attributes['AutomaticMode'] := 'false';
      Node.Attributes['ServiceSign'] := 'false';
      Node.Attributes['BSOSign'] := 'false';
      Node.Attributes['DataEncryption'] := 'false';
      Node.Attributes['CalcOnlineSign'] := 'false';
      Node.Attributes['OFDOrganizationName'] := '';
      Node.Attributes['OFDVATIN'] := '';
      Node.Attributes['FNSWebSite'] := '';
      Node.Attributes['SenderEmail'] := '';
      Node.Attributes['PlaceSettle'] := '';
      Node.Attributes['SignOfAgent'] := '0';

      TableParameters := XMLStringToWideString(Xml.XML.Text);
    finally
      Xml := nil;
    end;
    Exit;
  end;

  SetAdminPassword;
  Driver.ModelParamNumber := mpModelID;
  Check(Driver.ReadModelParamValue);
  Model := Driver.ModelParamValue;
  Check(Driver.FNGetStatus);
  Fiscal := TestBit(Driver.FNLifeState, 1);
  Driver.ModelParamNumber := mpFSTableNumber;
  Driver.ReadModelParamValue;
  Driver.TableNumber := Driver.ModelParamValue;
  Driver.RowNumber := 1;

  Driver.FieldNumber := 1;
  Check(Driver.ReadTable);
  KKTSerialNumber := Driver.ValueOfFieldString;

  Driver.FieldNumber := 2;
  Check(Driver.ReadTable);
  VATIN := Driver.ValueOfFieldString;

  Driver.FieldNumber := 3;
  Check(Driver.ReadTable);
  KKTNumber := Driver.ValueOfFieldString;

  Driver.FieldNumber := 4;
  Check(Driver.ReadTable);
  FNSerialNumber := Driver.ValueOfFieldString;

  Driver.FieldNumber := 5;
  Check(Driver.ReadTable);
  TaxVariant := GetTaxVariant(Driver.ValueOfFieldInteger); ///!!!

  Driver.FieldNumber := 13;
  Check(Driver.ReadTable);
  FNSWebSite := Driver.ValueOfFieldString;

  Driver.FieldNumber := 14;
  Check(Driver.ReadTable);
  PlaceSettle := Driver.ValueOfFieldString;

  Driver.FieldNumber := 15;
  Check(Driver.ReadTable);
  SenderEmail := Driver.ValueOfFieldString;

  if Model <> 16 then // Мпей
  begin
    Driver.FieldNumber := 16;
    Check(Driver.ReadTable);
    AgentSign := Driver.ValueOfFieldInteger;
  end
  else
    AgentSign := 0;

  Driver.FieldNumber := 6;
  Check(Driver.ReadTable);
  WMode := Driver.ValueOfFieldInteger; ///!!!
  DataEncryption := TestBit(WMode, 0);
  OfflineMode := testbit(WMode, 1);
  AutomaticMode := testbit(WMode, 2);
  ServiceSign := testbit(WMode, 3);
  BSOSign := testbit(WMode, 4);
  CalcOnlineSign := TestBit(WMode, 5);

  Driver.FieldNumber := 7;
  Check(Driver.ReadTable);
  OrganizationName := Driver.ValueOfFieldString;

  Driver.FieldNumber := 9;
  Check(Driver.ReadTable);
  AddressSettle := Driver.ValueOfFieldString;

  Driver.FieldNumber := 10;
  Check(Driver.ReadTable);
  OFDOrganizationName := Driver.ValueOfFieldString;

  Driver.FieldNumber := 12;
  Check(Driver.ReadTable);
  OFDVATIN := Driver.ValueOfFieldString;

  if AutomaticMode then
  begin
    Driver.ModelParamNumber := mpEmbeddedTableNumber;
    Check(Driver.ReadModelParamValue);
    Driver.TableNumber := Driver.ModelParamValue;
    Driver.RowNumber := 1;
    Driver.FieldNumber := 1;
    Driver.ReadTable;
    Driver.ReadTable;
    AutomaticNumber := Driver.ValueOfFieldString;
  end;

  Res := Driver.FNGetFiscalizationResult;
  if (Res <> 2) and (Res <> 1) then
    Check(Res);
  DocumentNumber := IntToStr(Driver.DocumentNumber);
  FNDateTime := DateTimeToStr(Driver.Date + driver.Time);

  FFDVersion := GetFFDVersion;

  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('Parameters');
    Node.Attributes['KKTNumber'] := KKTNumber;
    Node.Attributes['KKTSerialNumber'] := KKTSerialNumber;
    if Fiscal then
      Node.Attributes['Fiscal'] := 'true'
    else
      Node.Attributes['Fiscal'] := 'false';

    Node.Attributes['DocumentNumber'] := DocumentNumber;
    Node.Attributes['DateTime'] := FNDateTime;
    Node.Attributes['FNSerialNumber'] := FNSerialNumber;
    Node.Attributes['OrganizationName'] := OrganizationName;
    Node.Attributes['VATIN'] := VATIN;
    Node.Attributes['AddressSettle'] := AddressSettle;
    Node.Attributes['TaxVariant'] := TaxVariant;
    Node.Attributes['FFDVersionFN'] := FFDVersion; //'1.0';
    Node.Attributes['FFDVersionKKT'] := FFDVersion;
    Node.Attributes['AutomaticNumber'] := AutomaticNumber;

    if OfflineMode then
      Node.Attributes['OfflineMode'] := 'true'
    else
      Node.Attributes['OfflineMode'] := 'false';

    if AutomaticMode then
      Node.Attributes['AutomaticMode'] := 'true'
    else
      Node.Attributes['AutomaticMode'] := 'false';

    if ServiceSign then
      Node.Attributes['ServiceSign'] := 'true'
    else
      Node.Attributes['ServiceSign'] := 'false';

    if BSOSign then
      Node.Attributes['BSOSign'] := 'true'
    else
      Node.Attributes['BSOSign'] := 'false';

    if DataEncryption then
      Node.Attributes['DataEncryption'] := 'true'
    else
      Node.Attributes['DataEncryption'] := 'false';

    if CalcOnlineSign then
      Node.Attributes['CalcOnlineSign'] := 'true'
    else
      Node.Attributes['CalcOnlineSign'] := 'false';

    Node.Attributes['OFDOrganizationName'] := OFDOrganizationName;
    Node.Attributes['OFDVATIN'] := OFDVATIN;

    Node.Attributes['FNSWebSite'] := FNSWebSite;
    Node.Attributes['SenderEmail'] := SenderEmail;
    Node.Attributes['PlaceSettle'] := PlaceSettle;
    Node.Attributes['SignOfAgent'] := EncodeAgentSign(AgentSign);

    TableParameters := XMLStringToWideString(Xml.XML.Text);
  finally
    Xml := nil;
  end;
end;

function TDevice1C.OperationFN22(OperationType: Integer; const ParametersFiscal: WideString): WordBool;

  procedure WriteFiscalParams(const Params: TFiscalParametersRec22);
  var
    Model: Integer;
  begin
    Driver.ModelParamNumber := mpModelID;
    Check(Driver.ReadModelParamValue);
    Model := Driver.ModelParamValue;
    Driver.ModelParamNumber := mpFSTableNumber;
    Driver.ReadModelParamValue;
    Driver.TableNumber := Driver.ModelParamValue;
    Driver.RowNumber := 1;
    Driver.FieldNumber := 9;
    Driver.ValueOfFieldString := Params.AddressSettle;
    Check(Driver.WriteTable);
    Driver.FieldNumber := 10;
    Driver.ValueOfFieldString := Params.OFDOrganizationName;
    Check(Driver.WriteTable);
    Driver.FieldNumber := 12;
    Driver.ValueOfFieldString := Params.OFDVATIN;
    Check(Driver.WriteTable);
    Driver.FieldNumber := 7;
    Driver.ValueOfFieldString := Params.OrganizationName;
    Check(Driver.WriteTable);

    Driver.FieldNumber := 13;
    Driver.ValueOfFieldString := Params.FNSWebSite;
    Check(Driver.WriteTable);

    Driver.FieldNumber := 14;
    Driver.ValueOfFieldString := Params.PlaceSettle;
    Check(Driver.WriteTable);

    Driver.FieldNumber := 15;
    Driver.ValueOfFieldString := Params.SenderEmail;
    Check(Driver.WriteTable);

    if Model <> 16 then // Мпей
    begin
      Driver.FieldNumber := 16;
      Driver.ValueOfFieldInteger := Params.Agent;
      Check(Driver.WriteTable);
    end;

    if testbit(Params.WorkMode, 2) then // Automatic mode
    begin
      Driver.TableNumber := 24;
      Driver.RowNumber := 1;
      Driver.FieldNumber := 1;
      Driver.ValueOfFieldString := Params.AutomaticNumber;
      Check(Driver.WriteTable);
    end;

    Driver.INN := Params.VATIN;
    Driver.KKTRegistrationNumber := Params.KKTNumber;
    Driver.TaxType := Params.Tax;
    Driver.WorkMode := Params.WorkMode;
  end;

  procedure WriteFiscalTags(const Params: TFiscalParametersRec22);
  var
    Model: Integer;
  begin
    Driver.ModelParamNumber := mpModelID;
    Check(Driver.ReadModelParamValue);
    Model := Driver.ModelParamValue;

    if Model = 16 then // Мпей
    begin
      Driver.TagNumber := 1057;
      Driver.TagType := ttByte;
      Driver.TagValueInt := Params.Agent;
      Check(Driver.FNSendTag);
    end;

  // продажа подакцизного товара
    if Params.SaleExcisableGoods then
    begin
      Driver.TagNumber := 1207;
      Driver.TagType := ttByte;
      Driver.TagValueInt := 1;
      Check(Driver.FNSendTag);
    end;

  // признак проведения азартных игр
    if Params.SignOfGambling then
    begin
      Driver.TagNumber := 1193;
      Driver.TagType := ttByte;
      Driver.TagValueInt := 1;
      Check(Driver.FNSendTag);
    end;

  // признак проведения лотереи
    if Params.SignOfLottery then
    begin
      Driver.TagNumber := 1126;
      Driver.TagType := ttByte;
      Driver.TagValueInt := 1;
      Check(Driver.FNSendTag);
    end;

    SetCashierVATIN(Params.CashierVATIN);
    SendStrTag(1117, Params.SenderEmail);
  end;

var
  Params: TFiscalParametersRec22;
begin
  if FParams.ODEnabled then
  begin
    Result := False;
    Logger.Debug('Orange data OperationFN22');
    Exit;
  end;


  SetAdminPassword;
  Result := True;
  ParseFiscalParameters22(ParametersFiscal, Params);
  SetCashierPassword(Params.CashierName);
  case OperationType of
    1: // Registration
      begin
        try
          WriteFiscalParams(Params);
          Driver.ReportTypeInt := 0;
          Check(Driver.FNBeginRegistrationReport);
          WriteFiscalTags(Params);
          Check(Driver.FNBuildRegistrationReport);
          WaitForPrinting;
        except
          if Driver.FNCancelDocument <> 0 then
            Logger.Error('Cancel document error');
          raise;
        end;
      end;
    2: // ReRegistration
      begin
        try
          WriteFiscalParams(Params);
          Driver.ReportTypeInt := 2;
          Check(Driver.FNBeginRegistrationReport);
          WriteFiscalTags(Params);
          Driver.RegistrationReasonCode := Params.ReasonCode;
          Check(Driver.FNBuildReRegistrationReport);
          WaitForPrinting;
        except
          if Driver.FNCancelDocument <> 0 then
            Logger.Error('Cancel document error');
          raise;
        end;
      end;
    3: // Close FN
      begin
        Check(Driver.FNBeginCloseFiscalMode);
        SetCashierVATIN(Params.CashierVATIN);
        Check(Driver.FNCloseFiscalMode);
        WaitForPrinting;
      end;
  end;
end;

procedure TDevice1C.SetCashierVATIN(const ACashierVATIN: WideString);
begin
  if ACashierVATIN = '' then
    Exit;
  Driver.TagNumber := 1203;
  Driver.TagType := ttString;
  Driver.TagValueStr := ACashierVATIN;
  Check(Driver.FNSendTag);
end;

function TDevice1C.GetFFDVersion: WideString;
var
  id: Integer;

begin
  id := GetModelID;
  if id = 19 then
    FFFDVersion := ReadTableInt(10, 1, 4)
  else
    if IsModelType2(GetModelID) then
      FFFDVersion := ReadTableInt(10, 1, 29)
    else
      FFFDversion := ReadTableInt(17, 1, 17);

  case FFFDVersion of
    0, 1:
      Result := '1.0';
  else
    Result := '1.0.5'
  end;
end;

function TDevice1C.GetPlaceSettle: WideString;
begin
  Result := ReadTableStr(18, 1, 14);
end;

procedure TDevice1C.WriteTableStr(ANumber: Integer; ARow: Integer; AField: Integer; const AValue: string);
begin
  Driver.TableNumber := CorrectTableNumber(ANumber);
  Driver.RowNumber := 1;
  Driver.FieldNumber := AField;
  Driver.ValueOfFieldString := AValue;
  Check(Driver.WriteTable);
end;

procedure TDevice1C.WriteTableInt(TableNumber: Integer; Row: Integer; Field: Integer; Value: Integer);
begin
  Driver.TableNumber := CorrectTableNumber(TableNumber);
  Driver.RowNumber := Row;
  Driver.FieldNumber := Field;
  Check(Driver.GetFieldStruct);
  if Driver.FieldType then
    Driver.ValueOfFieldString := IntToStr(Value)
  else
    Driver.ValueOfFieldInteger := Value;
  Check(Driver.WriteTable);
end;

function TDevice1C.ReadTableStr(ANumber: Integer; ARow: Integer; AField: Integer): string;
begin
  Driver.TableNumber := CorrectTableNumber(ANumber);
  Driver.RowNumber := ARow;
  Driver.FieldNumber := AField;
  Check(Driver.ReadTable);
  Result := Driver.ValueOfFieldString;
end;

function TDevice1C.ReadTableInt(ANumber: Integer; ARow: Integer; AField: Integer): Integer;
begin
  Driver.TableNumber := CorrectTableNumber(ANumber);
  Driver.RowNumber := ARow;
  Driver.FieldNumber := AField;
  Check(Driver.ReadTable);
  Result := Driver.ValueOfFieldInteger;
end;

function TDevice1C.CorrectTableNumber(ANumber: Integer): Integer;
begin
  if ANumber = 18 then
  begin
    Driver.ModelParamNumber := mpFSTableNumber;
    Check(Driver.ReadModelParamValue);
    Result := Driver.ModelParamValue;
  end
  else if ANumber = 19 then
  begin
    Driver.ModelParamNumber := mpOFDTableNumber;
    Check(Driver.ReadModelParamValue);
    Result := Driver.ModelParamValue;
  end
  else
    Result := ANumber;
end;

function TDevice1C.GetModelID: Integer;
begin
  Driver.ModelParamNumber := mpModelID;
  Check(Driver.ReadModelParamValue);
  Result := Driver.ModelParamValue;
end;

function TDevice1C.IsModelType2(Value: Integer): Boolean;
begin
  Result := Value in [16, 19, 20, 21, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37,
                      38, 39, 40, 41, 42, 45, 45, 45, 46, 152];
  // Мобайл, мпей, ярусы, нано
end;

function TDevice1C.EncodeOutputParametersOpenSession22(Params: TOpenSessionOutputParamsRec): WideString;
var
  Xml: IXMLDocument;
  Node: IXMLNode;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('OutputParameters').AddChild('Parameters');

    {   Будет в ФФД 1.1

    Node.Attributes['UrgentReplacementFN'] := Params.UrgentReplacementFN;
    Node.Attributes['MemoryOverflowFN'] := Params.MemoryOverflowFN;
    Node.Attributes['ResourcesExhaustionFN'] := Params.ResourcesExhaustionFN;}
    Node.Attributes['OFDtimeout'] := Bool1C(Params.OFDtimeout);
    Result := XMLStringToWideString(Xml.XML.Text);
  finally
    Xml := nil;
  end;
end;

function TDevice1C.EncodeOutputParametersCloseSession22(Params: TCloseSessionOutputParamsRec): WideString;
var
  Xml: IXMLDocument;
  Node: IXMLNode;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('OutputParameters').AddChild('Parameters');
    Node.Attributes['NumberOfChecks'] := IntToStr(Params.NumberOfChecks);
    Node.Attributes['NumberOfDocuments'] := IntToStr(Params.NumberOfDocuments);
    Node.Attributes['BacklogDocumentsCounter'] := IntToStr(Params.BacklogDocumentsCounter);
    Node.Attributes['BacklogDocumentFirstDateTime'] := DateTimeToXML(Params.BacklogDocumentFirstDateTime);

{   Будет в ФФД 1.1

    Node.Attributes['UrgentReplacementFN'] := Bool1C(Params.UrgentReplacementFN);
    Node.Attributes['MemoryOverflowFN'] := Bool1C(Params.MemoryOverflowFN);
    Node.Attributes['ResourcesExhaustionFN'] := Bool1C(Params.ResourcesExhaustionFN);}

    Node.Attributes['OFDtimeout'] := Bool1C(Params.OFDtimeout);
    Result := XMLStringToWideString(Xml.XML.Text);
  finally
    Xml := nil;
  end;
end;

function TDevice1C.Bool1C(AValue: Boolean): WideString;
begin
  if AValue then
    Result := 'true'
  else
    Result := 'false';
end;

procedure TDevice1C.SetSenderEmail(const ASenderEmail: WideString);
begin
  Driver.TagNumber := 1117;
  Driver.TagType := ttString;
  Driver.TagValueStr := ASenderEmail;
  Check(Driver.FNSendTag);
end;

function TDevice1C.GetBPOVersion: Integer;
begin
  Result := FOwner.FBPOVersion;
end;

procedure TDevice1C.ProcessCheckCorrection22(const CheckCorrectionPackage: WideString; var CheckNumber, SessionNumber: Integer; var FiscalSign, AddressSiteInspections: WideString);
var
  Params: TCheckCorrectionParamsRec22;
  Dat: TDateTime;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('ProcessCheckCorrection Orange Data: ' + CheckCorrectionPackage);
    DoProcessCheckCorrectionOD(CheckCorrectionPackage, CheckNumber, SessionNumber, FiscalSign, AddressSiteInspections);
    Exit
  end;

  LockPort;
  try
    Logger.Debug('ProcessCheckCorrection: ' + CheckCorrectionPackage);
    ParseCheckCorrection22(CheckCorrectionPackage, Params);
    SetCashierPassword(Params.CashierName);
    Check(Driver.FNBeginCorrectionReceipt);
    try
      SetCashierVATIN(Params.CashierVATIN);
       // 1177	описание коррекции
       // 1178	дата документа основания для коррекции
       // 1179	номер документа основания для коррекции

      if Params.CorrectionBaseName <> '' then
      begin
        Driver.TagNumber := 1177;
        Driver.TagType := ttString;
        Driver.TagValueStr := Params.CorrectionBaseName;
        Check(Driver.FNSendTag);
      end;
      if Params.CorrectionBaseNumber <> '' then
      begin
        Driver.TagNumber := 1179;
        Driver.TagType := ttString;
        Driver.TagValueStr := Params.CorrectionBaseNumber;
        Check(Driver.FNSendTag);
      end;
      if Params.CorrectionBaseDate <> 0 then
      begin
        Driver.TagNumber := 1178;
        Driver.TagType := ttUnixTime;
        Dat := Params.CorrectionBaseDate;
        ReplaceTime(Dat, EncodeTime(0, 0, 0, 0)); // Убираем составляющую времени
        Driver.TagValueDateTime := Dat;
        Check(Driver.FNSendTag);
      end;
      Driver.CorrectionType := Params.CorrectionType;
      Driver.CalculationSign := Params.PaymentType;

      Driver.Summ1 := Params.Sum;
      Driver.Summ2 := Params.Cash;
      Driver.Summ3 := Params.ElectronicPayment;
      Driver.Summ4 := Params.AdvancePayment;
      Driver.Summ5 := Params.Credit;
      Driver.Summ6 := Params.CashProvision;
      Driver.Summ7 := Params.SumTAX18;
      Driver.Summ8 := Params.SumTAX10;
      Driver.Summ9 := Params.SumTAX0;
      Driver.Summ10 := Params.SumTAXNone;
      Driver.Summ11 := Params.SumTAX118;
      Driver.Summ12 := Params.SumTAX110;

      Driver.TaxType := TaxToBin(Params.TaxVariant);
      Check(Driver.FNBuildCorrectionReceipt2);
    except
      on E: Exception do
      begin
        Driver.FNCancelDocument;
        raise
      end;
    end;
    WaitForPrinting;
    SessionNumber := Driver.SessionNumber;
    CheckNumber := Driver.DocumentNumber;
    FiscalSign := IntToStr(Cardinal(Driver.FiscalSign));
    AddressSiteInspections := FAddressSiteInspections;
  finally
    UnlockPort;
  end;

end;

procedure TDevice1C.ReportCurrentStatusOfSettelements22(const InputParameters: WideString; var OutputParameters: WideString);
var
  InParams: TInputParametersRec;
  OutParams: TCloseSessionOutputParamsRec;
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data ReportCurrentStatusOfSettelements22');
    ZeroMemory(@OutParams, SizeOf(OutParams));
    OutputParameters := EncodeOutputParametersCloseSession22(OutParams);
    Exit;
  end;

  LockPort;
  try
    ParseInputParameters(InputParameters, InParams);
    SetCashierPassword(InParams.CashierName);
    Check(Driver.FNGetCurrentSessionParams);
    OutParams.NumberOfChecks := Driver.ReceiptNumber;
    OutParams.NumberOfDocuments := Driver.ReceiptNumber + 1;
    Check(Driver.FNGetInfoExchangeStatus);
    OutParams.BacklogDocumentsCounter := Driver.MessageCount;
    OutParams.BacklogDocumentFirstNumber := Driver.DocumentNumber;
    OutParams.BacklogDocumentFirstDateTime := Driver.Date + Driver.Time;
//    Check(Driver.FNBeginCalculationStateReport);
//    SetCashierVATIN(InParams.CashierVATIN);
    Check(Driver.FNBuildCalculationStateReport);
    Check(Driver.WaitForPrinting);
    Check(Driver.FNGetStatus);
    OutParams.OFDtimeout := TestBit(Driver.FNWarningFlags, 3);
    OutputParameters := EncodeOutputParametersCloseSession22(OutParams);
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C.ParseFiscalParameters22(const AXML: WideString; var Params: TFiscalParametersRec22);
var
  Xml: IXMLDocument;
  Node: IXMLNode;
begin
{    CashierName: string;// 	Да 	string 	ФИО и должность уполномоченного лица для проведения операции
    CashierVATIN: string;// 	Да 	string 	ИНН уполномоченного лица для проведения операции
    KKTNumber: string;// 	Да 	string 	Регистрационный номер ККТ
    OrganizationName: string;// 	Да 	string 	Название организации
    VATIN: string;// 	Да 	string 	ИНН организация
    AddressSettle: string;// 	Да 	string 	Адрес проведения расчетов
    PlaceSettle: string;// 	Да 	string 	Место проведения расчетов
    TaxVariant: string;// 	Да 	string 	Коды системы налогообложения через разделитель ",". Коды системы налогообложения приведены в таблице "Системы налогообложения".
    OfflineMode: Boolean;// 	Да 	boolean 	Признак автономного режима
    DataEncryption: Boolean;// 	Да 	boolean 	Признак шифрование данных
    ServiceSign: Boolean;// 	Да 	boolean 	Признак расчетов за услуги
    SaleExcisableGoods: Boolean;// 	Да 	boolean 	продажа подакцизного товара
    SignOfGambling: Boolean;// 	Да 	boolean 	признак проведения азартных игр
    SignOfLottery: Boolean;// 	Да 	boolean 	признак проведения лотереи
    SignOfAgent: string;// 	Да 	string 	Коды признаков агента через разделитель ",".
//    (Коды приведены в таблице 10 форматов фискальных данных)
    BSOSing: Boolean;// 	Да 	boolean 	Признак формирования АС БСО
    CalcOnlineSign: Boolean;// 	Да 	boolean 	Признак ККТ для расчетов только в Интернет
    PrinterAutomatic: Boolean;// 	Да 	boolean 	Признак установки принтера в автомате
    AutomaticMode: Boolean;// 	Да 	boolean 	Признак автоматического режима
    AutomaticNumber: string;// 	Да 	string 	Номер автомата для автоматического режима
    ReasonCode: Integer;// 	Нет* 	long 	Код причины перерегистрации указывается только для операции "Изменение параметров регистрации")
    InfoChangesReasonsCodes: string;// 	Нет* 	string 	Коды причин изменения сведений о ККТ через разделитель ",".
    //(Коды приведены в таблице 15 форматов фискальных данных)
    OFDOrganizationName: string;// 	Да 	string 	Название организации ОФД
    OFDVATIN: string;// 	Да 	string 	ИНН организации ОФД    }
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXML(AXML);
    Node := Xml.ChildNodes.FindNode('Parameters');
    if Node = nil then
      raise Exception.Create('Wrong XML parameters Table');
    Params.CashierName := LoadString(Node, 'CashierName', True);
    Params.CashierVATIN := LoadString(Node, 'CashierVATIN', True);
    Params.KKTNumber := LoadString(Node, 'KKTNumber', True);
    Params.OFDOrganizationName := LoadString(Node, 'OFDOrganizationName', True);
    Params.VATIN := LoadString(Node, 'VATIN', True);
    Params.AddressSettle := LoadString(Node, 'AddressSettle', True);
    Params.PlaceSettle := LoadString(Node, 'PlaceSettle', True);
    Params.Tax := ParseTaxSystem(LoadString(Node, 'TaxVariant', True));
    Params.WorkMode := 0;

    if IsTrue(LoadString(Node, 'OfflineMode', False)) then
      SetBit(Params.WorkMode, 1);
    if IsTrue(LoadString(Node, 'AutomaticMode', False)) then
      SetBit(Params.WorkMode, 2);
    if IsTrue(LoadString(Node, 'ServiceSign', False)) then
      SetBit(Params.WorkMode, 3);
    if IsTrue(LoadString(Node, 'DataEncryption', False)) then
      SetBit(Params.WorkMode, 0);
    if IsTrue(LoadString(Node, 'BSOSing', False)) then
      SetBit(Params.WorkMode, 4);
    if IsTrue(LoadString(Node, 'CalcOnlineSign', False)) then
      SetBit(Params.WorkMode, 5);
    Params.Agent := ParseAgent(LoadString(Node, 'SignOfAgent', True));
    Params.AutomaticNumber := LoadString(Node, 'AutomaticNumber', False);
    Params.ReasonCode := LoadInteger(Node, 'ReasonCode', False);
    Params.OrganizationName := LoadString(Node, 'OrganizationName', True);
    Params.OFDVATIN := LoadString(Node, 'OFDVATIN', True);
    Params.FNSWebSite := LoadString(Node, 'FNSWebSite', False);
    Params.SenderEmail := LoadString(Node, 'SenderEmail', False);
    Params.SaleExcisableGoods := IsTrue(LoadString(Node, 'SaleExcisableGoods', False));
    Params.SignOfGambling := IsTrue(LoadString(Node, 'SignOfGambling', False));
    Params.SignOfLottery := IsTrue(LoadString(Node, 'SignOfLottery', False));
    Logger.Debug('SaleExcisableGoods ' + BoolToStr(Params.SaleExcisableGoods));
    Logger.Debug('SignOfGambling ' + BoolToStr(Params.SignOfGambling));
    Logger.Debug('SignOfLottery ' + BoolToStr(Params.SignOfLottery));

  finally
    Xml := nil;
  end;
end;

function TDevice1C.ParseAgent(const AAgent: WideString): Byte;
var
  S: TStringList;
  i: Integer;
begin
  Result := 0;
  S := TStringList.Create;
  try
    S.Delimiter := ',';
    S.DelimitedText := AAgent;
    for i := 0 to S.Count - 1 do
    begin
      case StrToIntDef(S[i], 0) of
        0:
          setbit(Result, 0);
        1:
          setbit(Result, 1);
        2:
          setbit(Result, 2);
        3:
          setbit(Result, 3);
        4:
          setbit(Result, 4);
        5:
          setbit(Result, 5);
        6:
          setbit(Result, 6);
      end;
    end;
  finally
    S.Free;
  end;

end;

function TDevice1C.EncodeAgentSign(ASign: Integer): string;
var
  i: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Delimiter := ',';
    for i := 0 to 7 do
    begin
      if TestBit(ASign, i) then
        SL.Add(IntToStr(i));
    end;
    Result := SL.DelimitedText;
  finally
    SL.Free;
  end;
end;

procedure TDevice1C.SetAgentData(const Data: TAgentData);
begin

    {PayingAgentOperation: WideString ; // 	Операция платежного агента 1044
    PayingAgentPhone: WideString ; //Телефон платежного агента 1073
    ReceivePaymentsOperatorPhone: WideString ; //Телефон оператора по приему платежей 1074
    MoneyTransferOperatorPhone: WideString ; //	Телефон оператора перевода 1075
    MoneyTransferOperatorName: WideString ; // 	Наименование оператора перевода 1026
    MoneyTransferOperatorAddress: WideString ; //	Адрес оператора перевода 1005
    MoneyTransferOperatorVATIN: WideString ; //	ИНН оператора перевода 1016}

{  if not Data.Enabled then
    Exit;
  SendStrTag(1044, Copy(Data.PayingAgentOperation, 1, 24));
//  PrintTag('ОПЕР.ПЛАТ.АГ. ', Data.PayingAgentOperation);

  SendStrTag(1073, Copy(Data.PayingAgentPhone, 1, 19));
//  PrintTag('ТЕЛ.ПЛАТ.АГ. ', Data.PayingAgentPhone);

  SendStrTag(1074, Copy(Data.ReceivePaymentsOperatorPhone, 1, 19));
//  PrintTag('ТЕЛ.ОПЕР.ПО ПРИЕМУ ПЛАТ. ', Data.ReceivePaymentsOperatorPhone);

  SendStrTag(1075, Copy(Data.MoneyTransferOperatorPhone, 1, 19));
//  PrintTag('ТЕЛ.ОПЕР.ПЕРЕВ. ', Data.MoneyTransferOperatorPhone);

  SendStrTag(1026, Copy(Data.MoneyTransferOperatorName, 1, 64));
//  PrintTag('НАИМ.ОПЕР.ПЕРЕВ. ', Data.MoneyTransferOperatorName);

  SendStrTag(1005, Copy(Data.MoneyTransferOperatorAddress, 1, 247));
//  PrintTag('АДР.ОПЕР.ПЕРЕВ. ', Data.MoneyTransferOperatorAddress);

  SendStrTag(1016, Copy(Data.MoneyTransferOperatorVATIN, 1, 12));
//  PrintTag('ИНН ОПЕР.ПЕРЕВ. ', Data.MoneyTransferOperatorVATIN);}
end;

procedure TDevice1C.SetPurveyorData(const Data: TPurveyorData);
begin
    {PurveyorPhone: WideString ; //	Телефон поставщика 1171
    PurveyorName: WideString ; //Наименование поставщика 1225
    PurveyorVATIN: WideString ; //ИНН поставщика 1226}
{  if not Data.Enabled then
    Exit;
  SendStrTag(1171, Copy(Data.PurveyorPhone, 1, 19));}
//  PrintTag('ТЕЛ.ПОСТАВЩИКА ', Data.PurveyorPhone);
{  SendStrTag2(1225, Data.PurveyorName);
  SendStrTag2(1226, Data.PurveyorVATIN);}
end;

procedure TDevice1C.ReadDepartments;
var
  i: Integer;
begin
  for i := 1 to 16 do
    FDepartments[i] := ReadTableStr(7, i, 1);
end;

function TDevice1C.CapNonFiscalDocument: Boolean;
begin
  Result := False;
  Exit;
  // Пока непонятно, нужно ли этот функционал включать, т.к. тормозит
{  Driver.ModelParamNumber := mpModelID;
  Check(Driver.ReadModelParamValue);
  Result := Byte(Driver.ModelParamValue) in [16, 20, 21, 27, 28, 29, 30, 32, 33, 34, 35, 36,
                                37, 38, 39, 40, 41, 42, 45, 46];
 }
end;

procedure TDevice1C.doProcessCheckOD(const CashierName: WideString;
  Electronically: Boolean; const CheckPackage: WideString; var CheckNumber,
  SessionNumber: Integer; var FiscalSign,
  AddressSiteInspections: WideString);
var
  Positions: TPositions1C;
  DocStatus: TODDocStatus;
begin
  Logger.Debug('ProcessCheck (OD): ' + CheckPackage);
  ODSetParams;
  Positions := TPositions1C.Create;
  try
    Positions.FFDversion := FFFDVersion;
    Positions.BPOVersion := BPOVersion;
    Positions.ItemNameLength := Params.ItemNameLength;
    Positions.ReadFromXML(CheckPackage);
    FODClient.SendDocument1C(Positions, DocStatus);
    SessionNumber := StrToIntDef(DocStatus.shiftNumber, 1);
    FiscalSign := DocStatus.fp;
    AddressSiteInspections := DocStatus.fnsWebsite;
    CheckNumber := StrToIntDef(DocStatus.documentNumber, 1);
  finally
    Positions.Free;
  end;
end;

procedure TDevice1C.ODSetParams;
begin
  FODClient.Server := FParams.ODServerURL;
  FODClient.CertFileName := FParams.ODCertFileName;
  FODClient.KeyFileName := FParams.ODKeyFileName;
  FODClient.SignKeyFileName := FParams.ODSignKeyFileName;
  FODClient.KeyName := FParams.ODKeyName;
  FODClient.Inn := FParams.ODINN;
  FODClient.Group := FParams.ODGroup;
  FODClient.RetryCount := FParams.ODRetryCount;
  FODClient.RetryTimeout := FParams.ODRetryCount;
end;

procedure TDevice1C.doProcessCheckCorrectionOD(
  const CheckCorrectionPackage: WideString; var CheckNumber,
  SessionNumber: Integer; var FiscalSign,
  AddressSiteInspections: WideString);
var
  Params: TCheckCorrectionParamsRec22;
  DocStatus: TODDocStatus;
begin
  Logger.Debug('ProcessCheckCorrection (OD): ' + CheckCorrectionPackage);
  ODSetParams;
  ParseCheckCorrection22(CheckCorrectionPackage, Params);
  FODClient.SendCorrection1C(Params, DocStatus);
  SessionNumber := StrToIntDef(DocStatus.shiftNumber, 1);
  FiscalSign := DocStatus.fp;
  AddressSiteInspections := DocStatus.fnsWebsite;
  CheckNumber := StrToIntDef(DocStatus.documentNumber, 1);
end;

procedure TDevice1C.CloseSessionRegistrationKM;
begin

end;

procedure TDevice1C.ExecuteCheckKM(ControlMarks: WideString; var CheckResults: WideString);
var
  Marks: TControlMarks;
  Mark: TControlMark;
  Results: TCheckResults;
  i: Integer;
begin
  Marks := TControlMarks.Create;
  Results := TCheckResults.Create;
  try
    Marks.Load(ControlMarks);
    for i := 0 to Marks.Count - 1 do
    begin
      Mark := Marks.Items[i];
      Driver.CheckItemMode := 0; // Полная проверка
      Driver.ItemStatus := Mark.State;
      Driver.BarCode := Mark.MarkingCode;
      Check(Driver.FNCheckItemBarcode);
      Results.Add(Mark.GUID, (Driver.ProcessingCode = 0) and (Driver.ItemSaleServerAllowed = 0),
         Driver.ItemStatus, Driver.KMServerErrorCode <> 0, IntToStr(Driver.KMServerErrorCode));
      if (Driver.ProcessingCode = 0) and (Driver.ItemSaleServerAllowed = 0) then
        Check(Driver.FNAcceptMakringCode)
      else
        Check(Driver.FNDeclineMarkingCode);
    end;
    CheckResults := Results.GetXML;
  finally
    Marks.Free;
    Results.Free;
  end;
end;

procedure TDevice1C.OpenSessionRegistrationKM(SessionRegistrationParameters: WideString);
var
  Params: TSessionRegParametersRec;
  Num: Integer;
  SNum: Integer;
begin
  FSessionRegOpened := False;
  ParseSessionRegParameters(SessionRegistrationParameters, Params);
  OpenCheckFN(Params.CashierName, Params.OperationType, True, Num, SNum);
  FSessionRegOpened := True;
end;

procedure TDevice1C.ParseSessionRegParameters(const AXML: WideString;
  var Params: TSessionRegParametersRec);
var
  Xml: IXMLDocument;
  Node: IXMLNode;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXmL(AXML);
    Node := Xml.ChildNodes.FindNode('SessionRegistrationParameters');
    if Node = nil then
      raise Exception.Create('Error XML SessionRegistrationParameters node ');
    Node := Node.ChildNodes.FindNode('Parameters');
    if Node = nil then
      raise Exception.Create('Error XML Parameters node ');
    Params.CashierName := LoadString(Node, 'CashierName', True);
    Params.CashierINN := LoadString(Node, 'CashierINN', False);
    Params.OperationType := LoadInteger(Node, 'PaymentType', True);
    Params.SaleAddres := LoadString(Node, 'SaleAddress', False);
    Params.SaleLocation := LoadString(Node, 'SaleLocation', False);
  finally
    Xml := nil;
  end;
end;

const
  bitOSN    = 0;
  bitUSND   = 1;
  bitUSNDMR = 2;
  bitENVD   = 3;
  bitESN    = 4;
  bitPSN    = 5;

function TDevice1C.GetODTaxSystems: WideString;
var
  T: Byte;
begin
   T := 0;
   if FParams.ODTaxOSN then
     SetBit(T, BitOSN);
   if FParams.ODTaxUSND then
     SetBit(T, BitUSND);
   if FParams.ODTaxUSNDMR then
     SetBit(T, bitUSNDMR);
   if FParams.ODTaxENVD then
     SetBit(T, BitENVD);
   if FParams.ODTaxESN then
     SetBit(T, BitESN);
   if FParams.ODTaxPSN then
     SetBit(T, BitPSN);
   Result := GetTaxVariant(T);
end;

end.

