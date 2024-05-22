unit Devices1C3;

interface

uses
  // VCL
  Windows, Classes, SysUtils, XMLDoc, XMLIntf,
  // This
  untLogger, DrvFRLib_TLB, PrinterTypes, DriverError, DriverTypes, Types1C,
  Params1C, Driver1CParams, BinUtils, StringUtils, TextEncoding, logfile,
  Positions1C, Positions1C3, FormatTLV, variants, Math, LangUtils, ODClient,
  ODClient2, XmlUtils, ControlMark, Devices1C, TLVParser, TLVTag, untJsonOD,
  Optional, System.DateUtils, System.Generics.Collections;

const
  // ����� ������
  C_ERR_CHECKCLOSED = 2000; // ��� ������ - �������� ����������
  C_ERR_CHECKOPENED = 2001; // ��� ������ - �������� ����������

  ECRMODE_RECOPENED = 8;

  // ���� �����������
  ctLocal = 0;
  ctTCP = 1;
  ctDCOM = 2;

  // �������� �� ���������
  DEF_PRINTLOGO = False;
  DEF_LOGOSIZE = 0;
  DEF_CONNECTION_TYPE = ctLocal;
  DEF_COMPUTERNAME = '';
  DEF_IPADDRESS = '';
  DEF_TCPPORT = 211;
  DEF_PROTOCOLTYPE = 0;
  DEF_BUFFERSTRINGS = False;
  StatusTimeout = 30000; // 30 ������

type
  TDeviceParams3Rec = record
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

  TTableParametersRec = record
    KKTNumber: string;            //��������������� ����� ���
    KKTSerialNumber: string;      // ��������� ����� ���
    FirmwareVersion: string;      //������ ��������
    Fiscal: boolean;              // ������� ����������� ����������� ����������
    FFDVersionFN: string;         // ������ ��� �� (���� �� ��������� �������� "1.0","1.1")
    FFDVersionKKT: string;        // ������ ��� ��� (���� �� ��������� �������� "1.0","1.0.5","1.1")
    FNSerialNumber: string;       // ��������� ����� ��
    DocumentNumber: string;       // ����� ��������� ����������� ����������� ����������
    DateTime: TDateTime;          // ���� � ����� �������� ����������� ����������� ����������
    CompanyName: string;          // �������� �����������
    INN: string;                  // ��� �����������
    SaleAddress: string;          // ����� ���������� ��������
    SaleLocation: string;         // ����� ���������� ��������
    TaxationSystems: string;      // ���� ������� ��������������� ����� ����������� ",".
    IsOffline: boolean;           // ������� ����������� ������
    IsEncrypted: boolean;         // ������� ���������� ������
    IsService: boolean;           // ������� �������� �� ������
    IsExcisable: boolean;         // ������� ������������ ������
    IsGambling: boolean;          // ������� ���������� �������� ���
    IsLottery: boolean;           // ������� ���������� �������
    AgentTypes: WideString;          // ���� ��������� ������ ����� ����������� ",".
    BSOSing: boolean;             // ������� ������������ �� ���
    IsOnlineOnly: boolean;        // ������� ��� ��� �������� ������ � ��������
    IsAutomaticPrinter: boolean;  // ������� ��������� �������� � ��������
    IsAutomatic: boolean;         // ������� ��������������� ������
    AutomaticNumber: string;      // ����� �������� ��� ��������������� ������
    OFDCompany: string;           // �������� ����������� ���
    OFDCompanyINN: string;        // ��� ����������� ���
    FNSURL: string;               // ����� ����� ��������������� ������ (���) � ���� ���������
    SenderEmail: string;          // ����� ����������� ����� ����������� ����
    //=== ParametersFiscal ===
    CashierName: string;          // ��� � ��������� ��������������� ���� ��� ���������� ��������
    CashierINN: string;           // ��� ��������������� ���� ��� ���������� ��������
    RegistrationReasonCode: Integer; // ��� ������� ���������������; // ����������� ������ ��� �������� "��������� ���������� �����������"
    RegistrationLabelCodes: string;	// ���� ������ ��������� �������� � ��� ����� �����������.
    RegistrationReasonCodeEx: Integer;	// ���� ������ ��������� �������� � ��� ����� �����������.

    //
    Tax: Integer;
    WorkMode: Byte;
    WorkModeEx: Byte;
    Agent: Integer;

    // 34
    IsOnline: Boolean; //������� ��� ��� �������� � ��������
    IsMarking: Boolean;  //������� ���������� ��� ������������� �������� ��������, ����������� ������������ ���������� ���������� �������������
    IsPawnshop: Boolean;  //������� ���������� ��� ������������� ���������� ������������ �������
    IsAssurance: Boolean; //������� ���������� ��� ������������� ������������ �� �����������
    // 41
    IsVendingMachine: Boolean;   // ������� ���������� � �������������� �������� ��������
    IsCateringServices: Boolean;  // ������� ���������� ��� �������� ����� ������������� �������
    IsWholesaleTrade: Boolean;    // ������� ���������� � ������� �������� � ������������� � ��
  end;

  TInputParametersRec = record
    CashierName: WideString;
    CashierVATIN: WideString;
    SaleAddress: WideString;
    SaleLocation: WideString;
    PrintRequired: Boolean;
    PrintRequiredPresented: Boolean;
  end;

  TOperationCountersRec = record
    CheckCount: Integer; // ���������� ����� �� �������� ������� ����
    TotalChecksAmount: Double; // �������� ����� ����� �� ��������� ������� ����
    CorrectionCheckCount: Integer; // ���������� ����� ��������� �� �������� ������� ����
    TotalCorrectionChecksAmount: Double; //	�������� ����� ����� ��������� �� ��������� ������� ����
  end;

  TOutputParametersRec = record
    ShiftNumber: Integer; //����� �������� �����/����� �������� �����
    CheckNumber: Integer; // ����� ���������� ����������� ���������
    ShiftClosingCheckNumber: Integer; // ����� ���������� ���� �� �����
    DateTime: TDateTime; // ���� � ����� ������������ ����������� ���������
    ShiftState: Integer; //	��������� ����� 1 - �������, 2 - �������, 3 - �������
    CountersOperationType1: TOperationCountersRec; // OperationCounters	�������� �������� �� ���� "������"
    CountersOperationType2: TOperationCountersRec; // �������� �������� �� ���� "������� �������"
    CountersOperationType3: TOperationCountersRec; // �������� �������� �� ���� "������"
    CountersOperationType4: TOperationCountersRec; // �������� �������� �� ���� "������� �������"
    CashBalance: Double; // ������� �������� �������� ������� � �����
    BacklogDocumentsCounter: Integer; // ���������� ������������ ����������
    BacklogDocumentFirstNumber: Integer; // ����� ������� ������������� ���������
    BacklogDocumentFirstDateTime: TDateTime; // ���� � ����� ������� �� ������������ ����������
    FNError: Boolean; // ������� ������������� ������� ������ ��
    FNOverflow: Boolean; // ������� ������������ ������ ��
    FNFail: Boolean; // ������� ���������� ������� ��
    FNValidityDate: TDateTime; // ���� �������� ��
  end;

  TDocumentOutputParametersRec = record
    ShiftNumber: Integer; // ����� �������� �����/����� �������� �����
    CheckNumber: Integer; // ����� ����������� ���������
    ShiftClosingCheckNumber: Integer; // ����� ���� �� �����
    AddressSiteInspections: string; // ����� ����� ��������
    FiscalSign: string; // ���������� �������
    DateTime: TDateTime; // ���� � ����� ������������ ���������
    MTNumber: Integer;  // ����� ��������� "����������� � ���������� ��" � ������� ���������� ������ ����.
    PrintError: Boolean; //������ ��� ������ �������� ����� ����
  end;

  TCorrectionDataRec = record
    AType: Integer; // ��� ��������� 0 - ��������������, 1 - �� �����������
    Description: string; // �������� ���������
    Date: TDateTime; // ���� ���������� ��������������� �������
    Number: string; // ����� ����������� ���������� ������
  end;

  TAgentDataRec = record
    AgentOperation: string; // �������� ���������� ������
    AgentPhone: string; // ������� ���������� ������. ��������� ��������� �������� ����� ����������� ",".
    PaymentProcessorPhone: string; // ������� ��������� �� ������ ��������. ��������� ��������� �������� ����� ����������� ",".
    AcquirerOperatorPhone: string; // ������� ��������� ��������. ��������� ��������� �������� ����� ����������� ",".
    AcquirerOperatorName: string; // ������������ ��������� ��������
    AcquirerOperatorAddress: string; // ����� ��������� ��������
    AcquirerOperatorINN: string; // ��� ��������� ��������
  end;

  TVendorDataRec = record
    VendorPhone: string; // ������� ����������  ��������� ��������� �������� ����� ����������� ",".
    VendorName: string; // ������������ ����������
    VendorINN: string; // ��� ����������
  end;

  TUserAttributeRec = record
    Name: string; // ��� ���������
    Value: string; // �������� ���������
  end;

  TProcessingKMResult = record
    RequestStatus: Integer;
    GUID: string;
    Res: Boolean;
    ResultCode: Integer;
    HasStatusInfo: Boolean;
    StatusInfo: Integer;
    HandleCode: Integer;
    isOSU: Boolean;
    MarkingType2: Integer;
    function ToXML: string;
  end;

  TDriverFunc = function: Integer of object;

  TDevice1C3 = class;

  TDevice1C3 = class(TDevice1C)
  private
    FPrintedOK: Boolean;
    FSaveTaxMode: Integer;
    FOSUCodes: TList<AnsiString>;
    FODCheckKMStatus: TOptional<TKmCheckDocStatus>;
    FProcessingKMResult: TProcessingKMResult;
    TaxValues: array[1..6] of Currency;
    FSavePrintStatus: Integer;
    function IsASPDMOdel(AECRSoftVersion: string): Boolean;
    function ReadOutputParametersOD: TOutputParametersRec;
    function DocStatusToDocumentOutputParameters(const ADocStatus: TODDocStatus2): WideString;
    procedure doProcessCheckOD2(const CheckPackage: WideString; var DocStatus: TODDocStatus2);
    procedure doProcessCheckCorrectionOD2(const CheckCorrectionPackage: WideString; var DocStatus: TODDocStatus2);
    procedure doProcessCheckCorrectionOD2_ffd12(const CheckCorrectionPackage: WideString; var DocStatus: TODDocStatus2);
    procedure ParseCheckCorrection3(const AXML: WideString; var Params: TCheckCorrectionParamsRec3);
    function ParseReasonCodes(const AValue: WideString): Integer;
    function EncodeReasonCodes(const AValue: Integer): WideString;
    function ReadTableParameters: TTableParametersRec;
    function ReadTableParametersOD: TTableParametersRec;
    function TableParametersToXML(const AValue: TTableParametersRec; AFiscal: Boolean): WideString;
    function XMLToTableParameters(const AValue: WideString): TTableParametersRec;
    function ReadTableStr(ATable, ARow, AField: Integer): string;
    function ReadTableInt(ATable, ARow, AField: Integer): Integer;
    function ReadOutputParameters: TOutputParametersRec;
    function OutputParametersToXML(const AValue: TOutputParametersRec): WideString;
    function XMLToInputParameters(const AValue: WideString): TInputParametersRec;
    function ReadDocumentOutputParameters: TDocumentOutputParametersRec;
    function DocumentOutputParametersToXML(const AValue: TDocumentOutputParametersRec): WideString;
    procedure doProcessCheck32(Electronically: Boolean; const CheckPackage: WideString; IsCorrection: Boolean);
    procedure doProcessCheckCorrectionOld(const CheckPackage: WideString);
    procedure CancelCheckIfOpened;
    procedure CloseCheckFN32(Cash, ElectronicPayment, AdvancePayment, Credit, CashProvision: Double; ATaxType: Integer; TotalSumm: Double; AUseTaxSum: Boolean);
    procedure SendTags32(APositions: TPositions1C3; isCorrection: Boolean);
    procedure BeginSTLVTag(ATag: Integer);
    procedure AddTagStr(ATag: Integer; const AValue: string);
    procedure SetAgentData32(const Data: TAgentData);
    procedure SendSTLVTag(ATag: Integer);
    procedure AddTagUnixTime(ATag: Integer; const AValue: TDateTime);
    procedure AddTagByte(ATag: Integer; const AValue: Byte);
    procedure SendTagStrOperation(ATag: Integer; const AValue: string);
    procedure SetPurveyorData32(const Data: TVendorData);
    procedure PrintFiscalString32(AFiscalString: TFiscalString32; AUseTaxSum: Boolean);
    procedure PrintFiscalLineFN32(const AName: WideString; AQuantity, APrice, ATotal, ADiscount: Double; ADepartment, ATax: Integer; ItemCodeData: string; AgentData: TAgentData; PurveyorData: TVendorData; AgentSign: WideString; APaymentTypeSign: Integer; APaymentItemSign: Integer; ACountryOfOrigin: WideString; ACustomsDeclaration: WideString; AExciseAmount: WideString; AAdditionalAttribute: WideString; AMeasurementUnit: WideString; ATaxValue: Currency; MeasureOfQuantity: Integer; FractionalQuantity: TFractionalQuantity; GoodCodeData: TGoodCodeData; MarkingCode: AnsiString; IndustryAttribute: TIndustryAttribute; AUseTaxSum: Boolean);
    procedure SendAgentDataOperation(AgentData: TAgentData; PurveyorData: TVendorData; AgentSign: WideString);
    procedure SendMarkingCode(const AMarkingCode: AnsiString; AOSU: Boolean = False);
    procedure SuppressNextDocumentPrintIfNeeded(AInputParams: TInputParametersRec);
    procedure RestoreNextDocumentPrintIfNeeded(AInputParams: TInputParametersRec);
    procedure CheckClock;
    function IsOSUCode(const ACode: AnsiString): Boolean;
    function GetOSUCodes: TList<AnsiString>;
    property OSUCodes: TList<AnsiString> read GetOSUCodes;
  public
    procedure GetCurrentStatus32(const InputParameters: WideString; var OutputParameters: WideString);
    procedure GetDataKKT32(var TableParameters: WideString);
    procedure OpenShift32(const InputParameters: WideString; var OutputParameters: WideString);
    procedure ProcessCheck32(Electronically: WordBool; const CheckPackage: WideString; var DocumentOutputParameters: WideString; IsCorrection: Boolean);
    procedure ReportCurrentStatusOfSettlements32(const InputParameters: WideString; var OutputParameters: WideString);
    procedure PrintXReport32(const InputParameters: WideString);
    procedure CloseShiftFN32(const InputParameters: WideString; var OutputParameters: WideString);
    procedure PrintTextDocument32(const TextPackage: WideString);
    function OperationFN32(OperationType: Integer; const ParametersFiscal: WideString): WordBool;
    procedure CashInOutcome32(Amount: Double; const InputParameters: WideString);

//    34

    procedure OpenSessionRegistrationKM3;
    procedure CloseSessionRegistrationKM3;
    procedure ConfirmKM(RequestGUID: WideString; ConfirmationType: Integer);
    procedure GetProcessingKMResult(var ProcessingKMResult: WideString; var RequestStatus: Integer);
    procedure ODRequestKM(ARequestKM: TRequestKM; var AChecking: Boolean; var ACheckingResult: Boolean);
    procedure RequestKM(ARequestKM: WideString; var ARequestKMResult: WideString);
    procedure PrintCheckCopy(ACheckNumber: WideString);

  end;

implementation

uses
  Types;

procedure TDevice1C3.GetDataKKT32(var TableParameters: WideString);
begin
  Logger.Debug('GetDataKKT');
  if FParams.KgKKTEnabled then
  begin
    Logger.Debug('KgKKT GetDataKKT32');
    // !!! TableParameters := TableParametersToXML(ReadTableParametersOD, False);
    Exit;
  end;

  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data GetDataKKT32');
    TableParameters := TableParametersToXML(ReadTableParametersOD, False);
    Exit;
  end;
  TableParameters := TableParametersToXML(ReadTableParameters, False);
  Logger.Debug(TableParameters);

/////////////////////////////
{

  PrintTextDocument32('<?xml version="1.0" encoding="UTF-8"?>'+
'<Document>'+
'	<Positions>'+
'		<TextString Text="                                                "/>'+
'		<TextString Text="                                                "/>'+
'		<TextString Text="W THE FORESTER (10516) 993, 7                   "/>'+
'		<TextString Text="                                                "/>'+
'		<Barcode Type="QR" Value="010704005656711221xlm2)FhNta3Ty"/>'+
'		<TextString Text="                                                "/>'+
'		<TextString Text="                                                "/>'+
'		<TextString Text="                                                "/>'+
'		<TextString Text="                                                "/>'+
'		<TextString Text="W THE FORESTER (10516) 193, 8                   "/>'+
'		<TextString Text="                                                "/>'+
'		<Barcode Type="QR" Value="0107040055563962217Zdj(agu8Y.x-"/>'+
'		<TextString Text="                                                "/>'+
'		<TextString Text="                                                "/>'+
'		<Barcode Type="QR" Value="555040055563962217Zdj(agu8Y.x-"/>'+
'		<TextString Text="                                                "/>'+
'		<TextString Text="                                                "/>'+
'		<Barcode Type="QR" Value="777040055563962217Zdj(agu8Y.x-"/>'+

'	</Positions>'+
'</Document>');

 }
end;

function TDevice1C3.GetOSUCodes: TList<AnsiString>;
begin
  if FOSUCodes = nil then
    FOSUCodes := TList<AnsiString>.Create;
  Result := FOSUCodes;
end;

function TDevice1C3.ReadTableParametersOD: TTableParametersRec;
begin
  Result.KKTNumber := FParams.ODKKTRNM; // ��� ���
  Result.KKTSerialNumber := FParams.ODKKTSerialNumber;      // ��������� ����� ���
  Result.FirmwareVersion := '';      //������ ��������
  Result.Fiscal := False;              // ������� ����������� ����������� ����������
  Result.FFDVersionFN := GetODFFDVersion;         // ������ ��� �� (���� �� ��������� �������� "1.0","1.1")
  Result.FFDVersionKKT := GetODFFDVersion;        // ������ ��� ��� (���� �� ��������� �������� "1.0","1.0.5","1.1")
  Result.FNSerialNumber := FParams.ODKKTFNSerialNumber;       // ��������� ����� ��
  Result.DocumentNumber := '';       // ����� ��������� ����������� ����������� ����������
  Result.DateTime := Now;          // ���� � ����� �������� ����������� ����������� ����������
  Result.CompanyName := '';          // �������� �����������
  Result.INN := FParams.ODINN;                  // ��� �����������
  Result.SaleAddress := FParams.ODSaleAddress;          // ����� ���������� ��������
  Result.SaleLocation := FParams.ODSaleLocation;         // ����� ���������� ��������
  Result.TaxationSystems := GetODTaxSystems;      // ���� ������� ��������������� ����� ����������� ",".
  Result.IsOffline := FParams.ODIsOffline;           // ������� ����������� ������
  Result.IsEncrypted := FParams.ODIsEncrypted;         // ������� ���������� ������
  Result.IsService := FParams.ODIsService;           // ������� �������� �� ������
  Result.IsExcisable := FParams.ODIsExcisable;         // ������� ������������ ������
  Result.IsGambling := FParams.ODIsGambling;          // ������� ���������� �������� ���
  Result.IsLottery := FParams.ODIsLottery;           // ������� ���������� �������
  Result.AgentTypes := '';          // ���� ��������� ������ ����� ����������� ",".
  Result.BSOSing := FParams.ODBSOSing;             // ������� ������������ �� ���
  Result.IsOnlineOnly := FParams.ODIsOnline;        // ������� ��� ��� �������� ������ � ��������
  Result.IsAutomaticPrinter := FParams.ODIsAutomaticPrinter;  // ������� ��������� �������� � ��������
  Result.IsAutomatic := FParams.ODIsAutomatic;         // ������� ��������������� ������
  Result.AutomaticNumber := FParams.ODAutomaticNumber;      // ����� �������� ��� ��������������� ������
  Result.OFDCompany := '';           // �������� ����������� ���
  Result.OFDCompanyINN := '';        // ��� ����������� ���
  Result.FNSURL := '';               // ����� ����� ��������������� ������ (���) � ���� ���������
  Result.SenderEmail := '';          // ����� ����������� ����� ����������� ����
  //=== ParametersFiscal ===
  Result.CashierName := '';          // ��� � ��������� ��������������� ���� ��� ���������� ��������
  Result.CashierINN := '';           // ��� ��������������� ���� ��� ���������� ��������
  Result.RegistrationReasonCode := 0; // ��� ������� ���������������; // ����������� ������ ��� �������� "��������� ���������� �����������"
  Result.RegistrationLabelCodes := '';	// ���� ������ ��������� �������� � ��� ����� �����������.
end;

function TDevice1C3.ReadTableParameters: TTableParametersRec;
var
  Model: Integer;
  Table: Integer;
  WMode: Integer;
  Res: Integer;
  WmodeEx: Integer;
  IsASPD: Boolean;
begin
  SetAdminPassword;
  Driver.ModelParamNumber := mpModelID;
  Check(Driver.ReadModelParamValue);
  Model := Driver.ModelParamValue;
  Check(Driver.FNGetStatus);
  Result.Fiscal := TestBit(Driver.FNLifeState, 1);
  Driver.ModelParamNumber := mpFSTableNumber;
  Driver.ReadModelParamValue;
  Table := Driver.ModelParamValue;

  Check(Driver.GetECRStatus);
  IsASPD := IsASPDMOdel(Driver.ECRSoftVersion);
  Result.FirmwareVersion := DateTimeToStr(Driver.ECRSoftDate);
  Result.KKTSerialNumber := ReadTableStr(Table, 1, 1);
  Result.INN := ReadTableStr(Table, 1, 2);
  Result.KKTNumber := ReadTableStr(Table, 1, 3);
  Result.FNSerialNumber := ReadTableStr(Table, 1, 4);
//  Result.TaxationSystems := GetTaxVariant(ReadTableInt(Table, 1, 5)); ///!!!
  Result.FNSURL := ReadTableStr(Table, 1, 13);
  Result.SaleLocation := ReadTableStr(Table, 1, 14);
  Result.SenderEmail := ReadTableStr(Table, 1, 15);
  Result.CompanyName := ReadTableStr(Table, 1, 7);
  Result.SaleAddress := ReadTableStr(Table, 1, 9);
  Result.OFDCompany := ReadTableStr(Table, 1, 10);
  Logger.Debug('OFDCOMpany ' + IntToStr(Table) + '  ' + Result.OFDCompany);
  Result.OFDCompanyINN := ReadTableStr(Table, 1, 12);
  Result.RegistrationLabelCodes := EncodeReasonCodes(ReadTableInt(Table, 1, 22));

  if Model <> 16 then // ����
    Result.AgentTypes := EncodeAgentSign(ReadTableInt(Table, 1, 16))
  else
    Result.AgentTypes := '';


  //WorkMode
{��� 0 - ����������
��� 1 - ���������� �����
��� 2 - �������������� �����
��� 3 - ����� �����
��� 4 - ���
��� 5 - ��������


WorkModeEx
��� 0 - ����������� ������
��� 1 - �������� ����
��� 2 - �������
��� 3 - ��������� � ��������
��� 4 - ������������� ������
��� 5 - ���������� ������������
��� 6 - ��������� ������������}

  WMode := ReadTableInt(Table, 1, 6);
  Result.IsEncrypted := TestBit(WMode, 0);
  Result.IsOffline := testbit(WMode, 1);
  Result.IsAutomatic := testbit(WMode, 2);
  Result.IsService := testbit(WMode, 3);
  Result.BSOSing := testbit(WMode, 4);
  Result.IsOnlineOnly := TestBit(WMode, 5);
  Result.IsOnline := TestBit(WMode, 5);

  WmodeEx := ReadTableInt(Table, 1, 21);

  Result.IsExcisable := TestBit(WmodeEx, 0);
  Result.IsGambling := TestBit(WmodeEx, 1);
  Result.IsLottery := TestBit(WmodeEx, 2);
  Result.IsAutomaticPrinter := TestBit(WmodeEx, 3);
  Result.IsMarking := TestBit(WmodeEx, 4);
  Result.IsPawnshop := TestBit(WmodeEx, 5);
  Result.IsAssurance := TestBit(WmodeEx, 6);
  Result.IsVendingMachine := TestBit(WmodeEx, 7);   // ������� ���������� � �������������� �������� ��������
  Result.IsCateringServices := TestBit(WMode, 6);  // ������� ���������� ��� �������� ����� ������������� �������
  Result.IsWholesaleTrade := TestBit(WMode, 7);  //// ������� ���������� � ������� �������� � ������������� � ��

  if Result.IsAutomatic then
  begin
    Driver.ModelParamNumber := mpEmbeddedTableNumber;
    Check(Driver.ReadModelParamValue);
    Result.AutomaticNumber := ReadTableStr(Driver.ModelParamValue, 1, 1);
  end;

  Res := Driver.FNGetFiscalizationResult;
  if (Res <> 2) and (Res <> 1) then
    Check(Res);
  Result.RegistrationReasonCode := Driver.RegistrationReasonCode;

  if IsASPD then
    Result.TaxationSystems := GetTaxVariant($3F)
  else
    Result.TaxationSystems := GetTaxVariant(Driver.TaxType); //GetTaxVariant(ReadTableInt(Table, 1, 5)); ///!!!

  Result.DocumentNumber := IntToStr(Driver.DocumentNumber);
  Result.DateTime := Driver.Date + driver.Time;
  Result.FFDVersionFN := GetFFDVersion;
  Result.FFDVersionKKT := GetFFDVersion;

  Result.CashierName := ReadTableStr(Table, 1, 8);

  if Model <> 152 then      // ����
    Result.CashierINN := ReadTableStr(Table, 1, 23)
  else
    Result.CashierINN := '';
end;

function To1Cbool(AValue: Boolean): WideString;
begin
  if AValue then
    Result := 'true'
  else
    Result := 'false';
end;

function TDevice1C3.TableParametersToXML(const AValue: TTableParametersRec; AFiscal: Boolean): WideString;
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
    Node := Xml.AddChild('Parameters');

    Node.Attributes['KKTNumber'] := AValue.KKTNumber;            //��������������� ����� ���
    Node.Attributes['KKTSerialNumber'] := AValue.KKTSerialNumber;      // ��������� ����� ���
    Node.Attributes['FirmwareVersion'] := AValue.FirmwareVersion;      //������ ��������
    Node.Attributes['Fiscal'] := To1Cbool(AValue.Fiscal);              // ������� ����������� ����������� ����������
    Node.Attributes['FFDVersionFN'] := AValue.FFDVersionFN;         // ������ ��� �� (���� �� ��������� �������� "1.0","1.1")
    Node.Attributes['FFDVersionKKT'] := AValue.FFDVersionKKT;        // ������ ��� ��� (���� �� ��������� �������� "1.0","1.0.5","1.1")
    Node.Attributes['FNSerialNumber'] := AValue.FNSerialNumber;       // ��������� ����� ��
    Node.Attributes['DocumentNumber'] := AValue.DocumentNumber;       // ����� ��������� ����������� ����������� ����������
    Node.Attributes['DateTime'] := DateTimeToXML(AValue.DateTime);          // ���� � ����� �������� ����������� ����������� ����������
    Node.Attributes['CompanyName'] := AValue.CompanyName;          // �������� �����������
    Node.Attributes['INN'] := AValue.INN;                  // ��� �����������
    Node.Attributes['SaleAddress'] := AValue.SaleAddress;          // ����� ���������� ��������
    Node.Attributes['SaleLocation'] := AValue.SaleLocation;         // ����� ���������� ��������
    Node.Attributes['TaxationSystems'] := AValue.TaxationSystems;      // ���� ������� ��������������� ����� ����������� ",".
    Node.Attributes['IsOffline'] := To1Cbool(AValue.IsOffline);           // ������� ����������� ������
    Node.Attributes['IsEncrypted'] := To1Cbool(AValue.IsEncrypted);         // ������� ���������� ������
    Node.Attributes['IsService'] := To1Cbool(AValue.IsService);           // ������� �������� �� ������
    Node.Attributes['IsExcisable'] := To1Cbool(AValue.IsExcisable);         // ������� ������������ ������
    Node.Attributes['IsGambling'] := To1Cbool(AValue.IsGambling);          // ������� ���������� �������� ���
    Node.Attributes['IsLottery'] := To1Cbool(AValue.IsLottery);           // ������� ���������� �������
    Node.Attributes['AgentTypes'] := AValue.AgentTypes;          // ���� ��������� ������ ����� ����������� ",".
    Node.Attributes['BSOSing'] := To1Cbool(AValue.BSOSing);             // ������� ������������ �� ���
    Node.Attributes['IsOnlineOnly'] := To1Cbool(AValue.IsOnlineOnly);        // ������� ��� ��� �������� ������ � ��������
    Node.Attributes['IsAutomaticPrinter'] := To1Cbool(AValue.IsAutomaticPrinter);  // ������� ��������� �������� � ��������
    Node.Attributes['IsAutomatic'] := To1Cbool(AValue.IsAutomatic);         // ������� ��������������� ������
    Node.Attributes['AutomaticNumber'] := AValue.AutomaticNumber;      // ����� �������� ��� ��������������� ������
    Node.Attributes['OFDCompany'] := AValue.OFDCompany;           // �������� ����������� ���
    Node.Attributes['OFDCompanyINN'] := AValue.OFDCompanyINN;        // ��� ����������� ���
    Node.Attributes['FNSURL'] := AValue.FNSURL;               // ����� ����� ��������������� ������ (���) � ���� ���������
    Node.Attributes['SenderEmail'] := AValue.SenderEmail;          // ����� ����������� ����� ����������� ����

    if FParams.FormatVersion >= 34 then
    begin
      Node.Attributes['IsOnline'] := To1Cbool(AValue.IsOnline);
      Node.Attributes['IsMarking'] := To1Cbool(AValue.IsMarking);
      Node.Attributes['IsPawnshop'] := To1Cbool(AValue.IsPawnshop);
      Node.Attributes['IsAssurance'] := To1Cbool(AValue.IsAssurance);

      Node.Attributes['IsVendingMachine'] := To1Cbool(AValue.IsVendingMachine);
      Node.Attributes['IsCateringServices'] := To1Cbool(AValue.IsCateringServices);
      Node.Attributes['IsWholesaleTrade'] := To1Cbool(AValue.IsWholesaleTrade);
    end;

    //=== ParametersFiscal ===
    if AFiscal then
    begin
      Node.Attributes['CashierName'] := AValue.CashierName;          // ��� � ��������� ��������������� ���� ��� ���������� ��������
      Node.Attributes['CashierINN'] := AValue.CashierINN;           // ��� ��������������� ���� ��� ���������� ��������
      Node.Attributes['RegistrationReasonCode'] := IntToStr(AValue.RegistrationReasonCode); // ��� ������� ���������������; // ����������� ������ ��� �������� "��������� ���������� �����������"
      Node.Attributes['RegistrationLabelCodes'] := AValue.RegistrationLabelCodes;		// ���� ������ ��������� �������� � ��� ����� �����������.
    end;
    Result := Xml.XML.Text;
  finally
    Xml := nil;
  end;
  Logger.Debug('Result');
end;

function TDevice1C3.ReadTableStr(ATable, ARow, AField: Integer): string;
begin
  Driver.TableNumber := ATable;
  Driver.RowNumber := ARow;
  Driver.FieldNumber := AField;
  Check(Driver.ReadTable);
  Result := Driver.ValueOfFieldString;
end;

function TDevice1C3.ReadTableInt(ATable, ARow, AField: Integer): Integer;
begin
  Driver.TableNumber := ATable;
  Driver.RowNumber := ARow;
  Driver.FieldNumber := AField;
  Check(Driver.ReadTable);
  Result := Driver.ValueOfFieldInteger;
end;

function TDevice1C3.OutputParametersToXML(const AValue: TOutputParametersRec): WideString;
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

    Node.Attributes['ShiftNumber'] := IntToStr(AValue.ShiftNumber); // Integer; //����� �������� �����/����� �������� �����
    Node.Attributes['CheckNumber'] := IntToStr(AValue.CheckNumber); // Integer; // ����� ���������� ����������� ���������
    Node.Attributes['ShiftClosingCheckNumber'] := IntToStr(AValue.ShiftClosingCheckNumber); // Integer; // ����� ���������� ���� �� �����
    Node.Attributes['DateTime'] := DateTimeToXML(AValue.DateTime); // TDateTime; // ���� � ����� ������������ ����������� ���������
    Node.Attributes['ShiftState'] := IntToStr(AValue.ShiftState); // Integer; //	��������� ����� 1 - �������, 2 - �������, 3 - �������
{   Node.Attributes['CountersOperationType1'] := AValue.; // TOperationCountersRec; // OperationCounters	�������� �������� �� ���� "������"
    Node.Attributes['CountersOperationType2'] := AValue.; // TOperationCountersRec; // �������� �������� �� ���� "������� �������"
    Node.Attributes['CountersOperationType3'] := AValue.; // TOperationCountersRec; // �������� �������� �� ���� "������"
    Node.Attributes['CountersOperationType4'] := AValue.; // TOperationCountersRec; // �������� �������� �� ���� "������� �������"}
    Node.Attributes['CashBalance'] := AValue.CashBalance; // Double; // ������� �������� �������� ������� � �����
    Node.Attributes['BacklogDocumentsCounter'] := IntToStr(AValue.BacklogDocumentsCounter); // Integer; // ���������� ������������ ����������
    Node.Attributes['BacklogDocumentFirstNumber'] := AValue.BacklogDocumentFirstNumber; // Integer; // ����� ������� ������������� ���������
    Node.Attributes['BacklogDocumentFirstDateTime'] := DateTimeToXML(AValue.BacklogDocumentFirstDateTime); // TDateTime; // ���� � ����� ������� �� ������������ ����������
    Node.Attributes['FNError'] := To1Cbool(AValue.FNError); // Boolean; // ������� ������������� ������� ������ ��
    Node.Attributes['FNOverflow'] := To1Cbool(AValue.FNOverflow); // Boolean; // ������� ������������ ������ ��
    Node.Attributes['FNFail'] := To1Cbool(AValue.FNFail); // Boolean; // ������� ���������� ������� ��
    Node.Attributes['FNValidityDate'] := DateTimeToXML(AValue.FNValidityDate); // TDateTime;
    Result := Xml.XML.Text;
  finally
    Xml := nil;
  end;
end;

function TDevice1C3.ReadOutputParameters: TOutputParametersRec;
var
  IsASPD: Boolean;
begin
  SetAdminPassword;
  Check(Driver.GetECRStatus);
  case Driver.ECRMode of
    4:
      Result.ShiftState := 1;
    2, 8, 13, 14:
      Result.ShiftState := 2;
    3:
      Result.ShiftState := 3;
  else
    Result.ShiftState := 1;
  end;
  IsASPD := IsASPDMOdel(Driver.ECRSoftVersion);
  if IsASPD then
    Result.DateTime := Driver.Date + Driver.Time;

  Check(Driver.FNGetCurrentSessionParams);
  Result.ShiftNumber := Driver.SessionNumber;
  Result.ShiftClosingCheckNumber := Driver.ReceiptNumber;
  Check(Driver.FNGetStatus);
  Result.CheckNumber := Driver.DocumentNumber;
  if not IsASPD then
  begin
    Check(Driver.FNFindDocument);
    Result.DateTime := Driver.Date + Driver.Time;
    Check(Driver.FNGetInfoExchangeStatus);
    Result.BacklogDocumentsCounter := Driver.MessageCount;
    Result.BacklogDocumentFirstNumber := Driver.DocumentNumber;
    Result.BacklogDocumentFirstDateTime := Driver.Date + Driver.Time;
  end
  else
  begin
    Result.BacklogDocumentsCounter := 0;
    Result.BacklogDocumentFirstNumber := 0;
    Result.BacklogDocumentFirstDateTime := Result.DateTime;
  end;

  Result.FNError := False; //!!!
  Result.FNOverflow := False; //!!!
  Result.FNFail := False; //!!!

  Check(Driver.FNGetExpirationTime);
  Result.FNValidityDate := Driver.Date;

  Driver.RegisterNumber := 241;
  Check(Driver.GetCashReg);
  Result.CashBalance := Driver.ContentsOfCashRegister;

  {Result.CountersOperationType1
  Result.CountersOperationType2
  Result.CountersOperationType3
  Result.CountersOperationType4}
end;

function TDevice1C3.XMLToInputParameters(const AValue: WideString): TInputParametersRec;
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
    Xml.LoadFromXML(AValue);
    Node := Xml.ChildNodes.FindNode('InputParameters');
    if Node = nil then
      raise Exception.Create('Wrong XML input parameters Table');
    Node := Node.ChildNodes.FindNode('Parameters');
    if Node = nil then
      raise Exception.Create('Wrong XML input parameters Table');
    Result.CashierName := LoadString(Node, 'CashierName', True);
    Result.CashierVATIN := LoadString(Node, 'CashierINN', False);
    Result.SaleAddress := LoadString(Node, 'SaleAddress', False);
    Result.SaleLocation := LoadString(Node, 'SaleLocation', False);
    Result.PrintRequired := LoadBool(Node, 'PrintRequired', False);
    Result.PrintRequiredPresented := not VarIsNull(Node.Attributes['PrintRequired']);
  finally
    Xml := nil;
  end;
end;

procedure TDevice1C3.OpenShift32(const InputParameters: WideString; var OutputParameters: WideString);
var
  InParams: TInputParametersRec;
begin
  if FParams.KgKKTEnabled then
  begin
    Logger.Debug('KgKKT OpenSession32');
    // !!! OutputParameters := OutputParametersToXML(ReadOutputParametersOD);
    Exit;
  end;

  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data OpenSession');
    OutputParameters := OutputParametersToXML(ReadOutputParametersOD);
    Exit;
  end;
  Logger.Debug('OpenShift');
  Logger.Debug(InputParameters);
  InParams := XMLToInputParameters(InputParameters);
  CancelCheckIfOpened;
  CheckClock;
  SetCashierPassword(InParams.CashierName);
  SuppressNextDocumentPrintIfNeeded(InParams);
  try
    Check(Driver.OpenSession);
    WaitForPrinting;
  finally
    RestoreNextDocumentPrintIfNeeded(InParams);
  end;
  OutputParameters := OutputParametersToXML(ReadOutputParameters);
  Logger.Debug(OutputParameters);
end;

procedure TDevice1C3.ProcessCheck32(Electronically: WordBool; const CheckPackage: WideString; var DocumentOutputParameters: WideString; IsCorrection: Boolean);
var
  DocStatus: TODDocStatus2;
begin
  if FParams.KgKKTEnabled then
  begin
    Logger.Debug('KgKKT ProcessCheck32');
    // !!!
    {if IsCorrection then
      doProcessCheckCorrectionOD2(CheckPackage, DocStatus)
    else
      doProcessCheckOD2(CheckPackage, DocStatus);
    DocumentOutputParameters := DocStatusToDocumentOutputParameters(DocStatus);
    Logger.Debug('DocumentOutputParameters: ' + DocumentOutputParameters);}
    Exit
  end;

  if FParams.ODEnabled then
  begin
    Logger.Debug('OD ProcessCheck32');
    if IsCorrection then
    begin
      Logger.Debug('OD ProcessCheck32 Correction ffd = ' + FParams.ODFFDVersion.ToString);
      if FParams.ODFFDVersion >= 4 then
        doProcessCheckCorrectionOD2_ffd12(CheckPackage, DocStatus)
      else
        doProcessCheckCorrectionOD2(CheckPackage, DocStatus)
    end
    else
      doProcessCheckOD2(CheckPackage, DocStatus);
    DocumentOutputParameters := DocStatusToDocumentOutputParameters(DocStatus);
    Logger.Debug('DocumentOutputParameters: ' + DocumentOutputParameters);
    Exit
  end;

  CancelCheckIfOpened;
  try
    FPrintedOK := False;
    if IsCorrection and (GetFFDVersion = '1.0.5') then
      doProcessCheckCorrectionOld(CheckPackage)
    else
      DoProcessCheck32(Electronically, CheckPackage, IsCorrection);
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
          DoProcessCheck32(Electronically, CheckPackage, IsCorrection);
        end;
      end
      else
        raise;
    end
    else
      raise;
  end;

  DocumentOutputParameters := DocumentOutputParametersToXML(ReadDocumentOutputParameters);
  Logger.Debug('DocumentOutputParameters: ' + DocumentOutputParameters);
end;

function TDevice1C3.DocumentOutputParametersToXML(const AValue: TDocumentOutputParametersRec): WideString;
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
    Node := Xml.AddChild('DocumentOutputParameters').AddChild('Parameters');

    Node.Attributes['ShiftNumber'] := IntToStr(AValue.ShiftNumber);
    Node.Attributes['CheckNumber'] := IntToStr(AValue.CheckNumber); // Integer; // ����� ����������� ���������
    Node.Attributes['ShiftClosingCheckNumber'] := IntToStr(AValue.ShiftClosingCheckNumber); // Integer; // ����� ���� �� �����
    Node.Attributes['AddressSiteInspections'] := AValue.AddressSiteInspections; // string; // ����� ����� ��������
    Node.Attributes['FiscalSign'] := AValue.FiscalSign; // string; // ���������� �������
    Node.Attributes['DateTime'] := DateTimeToXML(AValue.DateTime); // TDateTime; // ���� � ����� ������������ ���������
    Node.Attributes['PrintError'] := To1Cbool(AValue.PrintError);
    Result := Xml.XML.Text;
  finally
    Xml := nil;
  end;
end;

function TDevice1C3.ReadDocumentOutputParameters: TDocumentOutputParametersRec;
var
  Table: Integer;
  IsASPD: Boolean;
  mDocNumber: Integer;
begin
  mDocNumber := Driver.DocumentNumber;

  Driver.ModelParamNumber := mpFSTableNumber;
  Check(Driver.ReadModelParamValue);
  Table := Driver.ModelParamValue;
  Result.AddressSiteInspections := ReadTableStr(Table, 1, 13);
  Check(Driver.GetECRStatus);
  IsASPD := IsASPDMOdel(Driver.ECRSoftVersion);
  if IsASPD then
  begin
    Result.DateTime := Driver.Date + Driver.Time;
    Result.CheckNumber := Driver.DocumentNumber;
  end;

  Check(Driver.FNGetCurrentSessionParams);
  Result.ShiftNumber := Driver.SessionNumber;
  Result.ShiftClosingCheckNumber := Driver.ReceiptNumber;

  if not IsASPD then
  begin
    Driver.DocumentNumber := mDocNumber;
    Check(Driver.FNFindDocument);
    Result.DateTime := Driver.Date + Driver.Time;
    Result.CheckNumber := Driver.DocumentNumber;
  end;
  Result.FiscalSign := Driver.FiscalSignAsString;
  Result.PrintError := not FPrintedOK;
end;

procedure TDevice1C3.doProcessCheck32(Electronically: Boolean; const CheckPackage: WideString; IsCorrection: Boolean);
var
  Positions: TPositions1C3;
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
begin
  Logger.Debug('ProcessCheck32 Electronically = ' + Bool1C(Electronically) + '; IsCorrection = ' + Bool1C(IsCorrection));
  Logger.Debug('CheckPackage: ' + CheckPackage);
  LockPort;
  try
    SetAdminPassword;
    TotalSumm := 0;
{//    AddressSiteInspections := FAddressSiteInspections;
    if not IsModelType2(GetModelID) then
    begin
      RequisitePrint := ReadTableInt(17, 1, 12);
      if not TestBit(RequisitePrint, 5) then
        SetBit(RequisitePrint, 5);
      WriteTableInt(17, 1, 12, RequisitePrint);
    end;}

    GetFFDVersion;

    Positions := TPositions1C3.Create;
    try
      Positions.FFDversion := FFFDVersion;
      Positions.BPOVersion := BPOVersion;
      Positions.ItemNameLength := Params.ItemNameLength;
      Positions.ReadFromXML(CheckPackage, False);

      // ����� ���������� �������

      if Positions.TotalTaxSum > 0 then
        TaxMode := 1
      else
        TaxMode := 0;
      Logger.Debug('Positions.TotalTaxSum = ' + CurrToStr(Positions.TotalTaxSum));
      Logger.Debug('set Check Taxation type ' + TaxMode.ToString);

      if IsModelType2(GetModelID) then
      begin
        FSaveTaxMode := ReadTableInt(1, 1, 6);
        if FSaveTaxMode <> TaxMode then
          WriteTableInt(1, 1, 6, TaxMode);
      end
      else
      begin
        FSaveTaxMode := ReadTableInt(1, 1, 14);
        if FSaveTaxMode <> TaxMode then
          WriteTableInt(1, 1, 14, TaxMode);
      end;
      try
        for i := 1 to 6 do
          TaxValues[i] := 0;

      // ���������� ������ ���������� ���������
        if (Electronically) and not (IsModelType2(GetModelID)) then
        begin
          SavePrintingStatus := ReadTableInt(17, 1, 7);
          WriteTableInt(17, 1, 7, 1);
        end;
        try

          OpenCheckFN(Positions.CashierName, Positions.OperationType, True, RecNumber, SessionNumber, IsCorrection);
          try
            if Positions.CustomerPhone <> '' then
            begin
              Driver.CustomerEmail := Positions.CustomerPhone;
              Check(Driver.FNSendCustomerEmail, '������ �������� CustomerPhone');
            end;

            if Positions.CustomerEmail <> '' then
            begin
              Driver.CustomerEmail := Positions.CustomerEmail;
              Check(Driver.FNSendCustomerEmail, '������ �������� CustomerEmail');
            end;

          // ���� �������� ������, ���������� �� ���������� ������������
            if Positions.SenderEmail <> '' then
              SetSenderEmail(Positions.SenderEmail)
            else
            begin
            // �������� ������ � ������ ���� ������ ����� ����������
              if (Positions.CustomerPhone <> '') or (Positions.CustomerEmail <> '') then
                SetSenderEmail(FSenderEmail);
            end;

            SendTags32(Positions, IsCorrection); // �������� �������������� �����

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
         // ����������� �������� ���������� ������ ���������� ���������
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
            // ����������� �������� ���� ���������� �������
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
      Positions.Free;
    end;
{    finally
      try
        if IsModelType2(GetModelID) then
        begin
          if saveTaxationType <> 1 then ;
            WriteTableInt(1, 1, 6, saveTaxationType)
        end
        else
        begin
          if saveTaxationType <> 1 then ;
          WriteTableInt(1, 1, 14, saveTaxationType);
        end;
      except
        on E: Exception do
          Logger.Error(E.Message);
      end;
    end;  }
  finally
    FSessionRegOpened := False;
    UnlockPort;
  end;
end;

procedure TDevice1C3.CloseCheckFN32(Cash, ElectronicPayment, AdvancePayment, Credit, CashProvision: Double; ATaxType: Integer; TotalSumm: Double; AUseTaxSum: Boolean);
var
  Res: Integer;
  ResultDesc: WideString;
begin
  Logger.Debug(Format('CloseCheckFN32: Cash=%.2f, ElectronicPayment=%.2f, AdvancePayment=%.2f, Credit=%.2f, CashProvision=%.2f, ATaxType=%d, TotalSumm=%.2f, TaxValues[1]=%.2f, TaxValues[2]=%.2f, TaxValues[3]=%.2f, TaxValues[4]=%.2f, TaxValues[5]=%.2f, TaxValues[6]=%.2f,' + ' UseTaxSum = %s', [Cash, ElectronicPayment, AdvancePayment, Credit, CashProvision, ATaxType, TotalSumm, TaxValues[1], TaxValues[2], TaxValues[3], TaxValues[4], TaxValues[5], TaxValues[6], BoolToStr(AUseTaxSum)]));
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
    if AUseTaxSum then
    begin
      Driver.TaxValue1 := TaxValues[1];
      Driver.TaxValue2 := TaxValues[2];
      Driver.TaxValue3 := TaxValues[3];
      Driver.TaxValue4 := TaxValues[4];
      Driver.TaxValue5 := TaxValues[5];
      Driver.TaxValue6 := TaxValues[6];
    end
    else
    begin
      Driver.TaxValue1 := 0;
      Driver.TaxValue2 := 0;
      Driver.TaxValue3 := 0;
      Driver.TaxValue4 := 0;
      Driver.TaxValue5 := 0;
      Driver.TaxValue6 := 0;
    end;
    Driver.TaxType := ATaxType;
    Driver.StringForPrinting := '';
    Driver.DiscountOnCheck := 0;
    Driver.Tax1 := 0;
    Driver.Tax2 := 0;
    Driver.Tax3 := 0;
    Driver.Tax4 := 0;
    Res := Driver.FNCloseCheckEx;
    FPrintedOK := Res = 0;

    ResultDesc := Driver.ResultCodeDescription;
    if Res <> 0 then
    begin
      Driver.CancelCheck;
      CheckCustom(Res, ResultDesc, '������ �������� ����');
    end;
    WaitForPrinting;
  end
  else
  begin
    FeedAndCut;
    if FNonFiscalCheckNumber = 9999 then
      FNonFiscalCheckNumber := 1
    else
      FNonFiscalCheckNumber := FNonFiscalCheckNumber + 1;
    SaveToReg; // ��������� ����� ������������� ���� � ������
  end;
  FIsOpenedCheck := False;
end;

procedure TDevice1C3.BeginSTLVTag(ATag: Integer);
begin
  Driver.TagNumber := ATag;
  Check(Driver.FNBeginSTLVTag);
end;

procedure TDevice1C3.AddTagStr(ATag: Integer; const AValue: string);
begin
  if AValue = '' then
    Exit;

  Driver.TagNumber := ATag;
  Driver.TagType := ttString;
  Driver.TagValueStr := AValue;
  Check(Driver.FNAddTag);
end;

procedure TDevice1C3.SendSTLVTag(ATag: Integer);
begin
  Driver.TagNumber := ATag;
  Check(Driver.FNSendSTLVTag, '������ �������� ���� ' + ATag.ToString);
end;

procedure TDevice1C3.AddTagUnixTime(ATag: Integer; const AValue: TDateTime);
begin
  Driver.TagNumber := ATag;
  Driver.TagType := ttUnixTime;
  Driver.TagValueDateTime := AValue;
  Check(Driver.FNAddTag);
end;

procedure TDevice1C3.AddTagByte(ATag: Integer; const AValue: Byte);
begin
  Driver.TagNumber := ATag;
  Driver.TagType := ttByte;
  Driver.TagValueInt := AValue;
  Check(Driver.FNAddTag);
end;

procedure TDevice1C3.SendTagStrOperation(ATag: Integer; const AValue: string);
begin
  Driver.TagNumber := ATag;
  Driver.TagType := ttString;
  Driver.TagValueStr := AValue;
  Check(Driver.FNSendTagOperation, '������ �������� ���� ' + ATag.ToString);
end;

procedure TDevice1C3.SendTags32(APositions: TPositions1C3; isCorrection: Boolean);
var
  AgSign: Byte;
  Dat: TDateTime;
begin
  SendStrTag(1192, APositions.AdditionalAttribute);
  if APositions.AdditionalAttribute <> '' then
    PrintPair('���.����.', APositions.AdditionalAttribute);

  if APositions.AgentData.Enabled then
  begin
    SendStrTag(1044, APositions.AgentData.AgentOperation);
    SendStrTag(1073, APositions.AgentData.AgentPhone);
    SendStrTag(1074, APositions.AgentData.PaymentProcessorPhone);
    SendStrTag(1075, APositions.AgentData.AcquirerOperatorPhone);
    SendStrTag(1026, APositions.AgentData.AcquirerOperatorName);
    SendStrTag(1005, APositions.AgentData.AcquirerOperatorAddress);
    SendStrTag(1016, APositions.AgentData.AcquirerOperatorINN);
  end;

  if APositions.VendorData.Enabled then
  begin
    SendStrTag(1171, APositions.VendorData.VendorPhone);
  end;

  if APositions.AgentSign <> '' then
  begin
    AgSign := 0;
    SetBit(AgSign, StrToInt(Trim(APositions.AgentSign)));

    Driver.TagNumber := 1057; // ������� ������
    Driver.TagType := ttByte;
    Driver.TagValueInt := AgSign;
    Check(Driver.FNSendTag, '������ �������� ���� 1057'); // ��������� ��� 1057
  end;

  if APositions.UserAttribute.Enabled then
  begin
    Driver.TagNumber := 1084;
    Check(Driver.FNBeginSTLVTag);
    AddStrTag(1085, Copy(APositions.UserAttribute.Name, 1, 64));
    AddStrTag(1086, Copy(APositions.UserAttribute.Value, 1, 255));
    Check(Driver.FNSendSTLVTag, '������ �������� ���� 1084');
  end;

  if APositions.CorrectionData.Enabled and isCorrection then
  begin
//    SendStrTag(1177, APositions.CorrectionData.Description);
    SendStrTag(1179, APositions.CorrectionData.Number);

    Driver.TagNumber := 1173;
    Driver.TagType := ttByte;
    Driver.TagValueInt := APositions.CorrectionData.AType;
    Check(Driver.FNSendTag, '������ �������� ���� 1173');
  end;

  if (APositions.CorrectionData.Date <> 0) and (isCorrection) then
  begin
    Driver.TagNumber := 1178;
    Driver.TagType := ttUnixTime;
    Dat := APositions.CorrectionData.Date;
    ReplaceTime(Dat, EncodeTime(0, 0, 0, 0)); // ������� ������������ �������
    Driver.TagValueDateTime := Dat;
    Check(Driver.FNSendTag, '������ �������� ���� 1178');
  end;

  if APositions.CustomerDetail.Enabled then
  begin
    if FFFDVersion = FFD_VERSION_1_05 then
    begin
      SendStrTag(1227, APositions.CustomerDetail.Info);
      SendStrTag(1228, APositions.CustomerDetail.INN);
    end
    else if FFFDVersion >= FFD_VERSION_1_2 then
    begin
      BeginSTLVTag(1256);
      AddTagStr(1227, APositions.CustomerDetail.Info);
      AddTagStr(1228, APositions.CustomerDetail.INN);
      if APositions.CustomerDetail.DateOfBirthEnabled then
        AddTagStr(1243, FormatDateTime('dd.mm.yyyy', APositions.CustomerDetail.DateOfBirth));
      AddTagStr(1244, APositions.CustomerDetail.Citizenship);
      if APositions.CustomerDetail.DocumentTypeCodeEnabled then
        AddTagStr(1245, APositions.CustomerDetail.DocumentTypeCode.ToString);
      AddTagStr(1246, APositions.CustomerDetail.DocumentData);
      AddTagStr(1254, APositions.CustomerDetail.Address);
      SendSTLVTag(1256);
    end;
  end;

  if APositions.OperationalAttribute.Enabled then
  begin
    BeginSTLVTag(1270);
    AddTagByte(1271, APositions.OperationalAttribute.OperationID);
    AddTagStr(1272, APositions.OperationalAttribute.OperationData);
    AddTagUnixTime(1273, APositions.OperationalAttribute.DateTime);
    SendSTLVTag(1270);
  end;

  if APositions.IndustryAttribute.Enabled then
  begin
    BeginSTLVTag(1261);
    AddTagStr(1262, APositions.IndustryAttribute.IdentifierFOIV);
    AddTagStr(1263, APositions.IndustryAttribute.DocumentDate); // FormatDateTime('dd.mm.yyyy', APositions.IndustryAttribute.DocumentDate));
    AddTagStr(1264, APositions.IndustryAttribute.DocumentNumber);
    AddTagStr(1265, APositions.IndustryAttribute.AttributeValue);
    SendSTLVTag(1261)
  end;
end;

procedure TDevice1C3.SetAgentData32(const Data: TAgentData);
begin

    {PayingAgentOperation: WideString ; // 	�������� ���������� ������ 1044
    PayingAgentPhone: WideString ; //������� ���������� ������ 1073
    ReceivePaymentsOperatorPhone: WideString ; //������� ��������� �� ������ �������� 1074
    MoneyTransferOperatorPhone: WideString ; //	������� ��������� �������� 1075
    MoneyTransferOperatorName: WideString ; // 	������������ ��������� �������� 1026
    MoneyTransferOperatorAddress: WideString ; //	����� ��������� �������� 1005
    MoneyTransferOperatorVATIN: WideString ; //	��� ��������� �������� 1016}
{  if not Data.Enabled then
    Exit;
  SendStrTag(1044, Copy(Data.PayingAgentOperation, 1, 24));
//  PrintTag('����.����.��. ', Data.PayingAgentOperation);

  SendStrTag(1073, Copy(Data.PayingAgentPhone, 1, 19));
//  PrintTag('���.����.��. ', Data.PayingAgentPhone);

  SendStrTag(1074, Copy(Data.ReceivePaymentsOperatorPhone, 1, 19));
//  PrintTag('���.����.�� ������ ����. ', Data.ReceivePaymentsOperatorPhone);

  SendStrTag(1075, Copy(Data.MoneyTransferOperatorPhone, 1, 19));
//  PrintTag('���.����.�����. ', Data.MoneyTransferOperatorPhone);

  SendStrTag(1026, Copy(Data.MoneyTransferOperatorName, 1, 64));
//  PrintTag('����.����.�����. ', Data.MoneyTransferOperatorName);

  SendStrTag(1005, Copy(Data.MoneyTransferOperatorAddress, 1, 247));
//  PrintTag('���.����.�����. ', Data.MoneyTransferOperatorAddress);

  SendStrTag(1016, Copy(Data.MoneyTransferOperatorVATIN, 1, 12));
//  PrintTag('��� ����.�����. ', Data.MoneyTransferOperatorVATIN);}
end;

procedure TDevice1C3.SetPurveyorData32(const Data: TVendorData);
begin
    {PurveyorPhone: WideString ; //	������� ���������� 1171
    PurveyorName: WideString ; //������������ ���������� 1225
    PurveyorVATIN: WideString ; //��� ���������� 1226}
{  if not Data.Enabled then
    Exit;
  SendStrTag(1171, Copy(Data.PurveyorPhone, 1, 19));}
//  PrintTag('���.���������� ', Data.PurveyorPhone);
{  SendStrTag2(1225, Data.PurveyorName);
  SendStrTag2(1226, Data.PurveyorVATIN);}
end;

procedure TDevice1C3.PrintFiscalString32(AFiscalString: TFiscalString32; AUseTaxSum: Boolean);
begin
  CheckReceiptOpened;
  SetAdminPassword;

  if not FIsFiscalCheck then
    RaiseError(C_ERR_CHECKOPENED, GetRes(@SInvalidOperationInNonfiscalDocument));

  PrintFiscalLineFN32(AFiscalString.Name, AFiscalString.Quantity, AFiscalString.PriceWithDiscount, AFiscalString.SumWithDiscount, AFiscalString.DiscountSum, AFiscalString.Department, AFiscalString.Tax, AFiscalString.Marking, AFiscalString.AgentData, AFiscalString.VendorData, AFiscalString.AgentSign, AFiscalString.SignMethodCalculation, AFiscalString.SignCalculationObject, AFiscalString.CountryOfOfigin, AFiscalString.CustomsDeclaration, AFiscalString.ExciseAmount, AFiscalString.AdditionalAttribute, AFiscalString.MeasurementUnit, AFiscalString.TaxSumm, AFiscalString.MeasureOfQuantity, AFiscalString.FractionalQuantity, AFiscalString.GoodCodeData, AFiscalString.MarkingCode, AFiscalString.IndustryAttribute, AUseTaxSum);
end;

function QuantityToStr(AQuantity: Double): string;
var
  C: Char;
begin
  C := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  Result := FloatToStr(AQuantity);
  FormatSettings.DecimalSeparator := C;
end;

function NeedToPrintMark(const ItemCodeData: string): boolean;
var
  s: string;
begin
  s := Copy(ItemCodeData, 1, 2);
  Result := (s = #$44#$4D) or (s = #$52#$46) or (s = #$C5#$14) or (s = #$C5#$1E);
end;

procedure TDevice1C3.PrintCheckCopy(ACheckNumber: WideString);
var
  DocNumber: Int64;
begin
  Logger.Debug('PrintCheckCopy (' + ACheckNumber + ')');
  try
    DocNumber := StrToInt64(ACheckNumber);
  except
    raise Exception.Create('������������ ������ ������ ���������');
  end;

  if FParams.UseRepeatDocument then
  begin
    Logger.Debug('Use repeat document');
    Check(Driver.FNGetStatus);
    if Driver.DocumentNumber = DocNumber then
    begin
      Check(Driver.RepeatDocument);
      Driver.WaitForPrinting;
    end;
  end
  else
  begin
    Driver.DocumentNumber := DocNumber;
    Driver.SerialNumber := '';
    Driver.DBFilePath := '';
    Check(Driver.DBPrintDocument);
  end;
end;

procedure TDevice1C3.PrintFiscalLine32(Item: );

  function PaymentTypeSignToStr(AValue: Integer): string;
  begin
    case AValue of
      1:
        Result := '���������� 100%';
      2:
        Result := '����������';
      3:
        Result := '�����';
      4:
        Result := '������ ������';
      5:
        Result := '��������� ������ � ������';
      6:
        Result := '�������� � ������';
      7:
        Result := '������ �������';
    else
      Result := '�����.';
    end;
  end;

  function PaymentItemSignToStr(AValue: Integer): string;
  begin
    case AValue of
      1:
        Result := '�����';
      2:
        Result := '��';
      3:
        Result := '������';
      4:
        Result := '������';
      5:
        Result := '������ ����';
      6:
        Result := '������� ��';
      7:
        Result := '������ �������';
      8:
        Result := '������� �������';
      9:
        Result := '���';
      10:
        Result := '������';
      11:
        Result := '��';
      12:
        Result := '�������';
      13:
        Result := '���';
      14:
        Result := '������������� �����';
      15:
        Result := '������������������� �����';
      16:
        Result := '���� ������� � ������';
      17:
        Result := '�������� ����';
      18:
        Result := '��������� ����';
      19:
        Result := '�����';
      20:
        Result := '������';
      21:
        Result := '������ �� ��� ��';
      22:
        Result := '������ �� ���';
      23:
        Result := '������ �� ��� ��';
      24:
        Result := '������ �� ���';
      25:
        Result := '������ �� ���';
      26:
        Result := '��';
    else
      Result := '�����.';

    end;
  end;

var
  SaveSeparator: Char;
  Excise: Int64;
const
  MUL = #$0B;
  EQU = #$1F;

  procedure PrintTextLines;
  begin
    if (APaymentItemSign <> 15) and (APaymentItemSign <> 16) then
    begin
      PrintText(AName, True);
      SaveSeparator := FormatSettings.DecimalSeparator;
      FormatSettings.DecimalSeparator := '.';
      try
        PrintPair('', Format('%s ' + MUL + ' %.2f', [QuantityToStr(AQuantity), APrice]));
        if ADepartment > 16 then
          raise Exception.Create('Invalid Department value');
        if ADepartment = 0 then
          PrintPair(' ', Format(EQU + '%.2f', [ATotal]))
        else
          PrintPair(FDepartments[ADepartment], Format(EQU + '%.2f', [ATotal]));

        if (ItemCodeData <> '') and (ItemCodeData <> #$00#$00) then
        begin
          if NeedToPrintMark(ItemCodeData) then
            PrintPair('', '[M]');
        end;

        if (FFFDVersion = 2) and (EnablePaymentSignPrint) then
        begin
          if APaymentTypeSign = 4 then
            PrintPair('', PaymentItemSignToStr(APaymentItemSign))
          else
            PrintPair(PaymentTypeSignToStr(APaymentTypeSign), PaymentItemSignToStr(APaymentItemSign));
        end;

      finally
        FormatSettings.DecimalSeparator := SaveSeparator;
      end;
    end;

    PrintText(FTaxNames[ATax], False);

    SaveSeparator := FormatSettings.DecimalSeparator;
    FormatSettings.DecimalSeparator := '.';
    try
      if CompareValue(ADiscount, 0, C_DOUBLE_PREC) = GreaterThanValue then
        PrintPair('������', Format('%.2f', [ADiscount]))
      else if CompareValue(ADiscount, 0, C_DOUBLE_PREC) = LessThanValue then
        PrintPair('��������', Format('%.2f', [-ADiscount]));
    finally
      FormatSettings.DecimalSeparator := SaveSeparator;
    end;

  end;

  procedure BindTags;
  begin
{  if not IsModelType2(GetModelID) then
  begin
    if (ItemCodeData'') and (FSessionRegOpened) then
    begin
      Driver.BarCode := ItemCodeData.MarkingCode;
      Check(Driver.FNBindMarkingItem);
    end;
  end;  }
    Logger.Debug('BindTags');
    Logger.Debug('FFFDVersion = ' + FFFdVersion.ToString);

    if (FFFDVersion = 3) or (FFFDVersion = 2) then
    begin
      Logger.Debug('Marking = ' + StrToHex(ItemCodeData));
      if (ItemCodeData <> '') and (ItemCodeData <> #$00#$00) then
      begin
        Driver.TagNumber := 1162;
        Driver.TagType := ttByteArray;
        Driver.TagValueBin := ItemCodeData;
        Check(Driver.FNSendTagOperation, '������ �������� ���� 1162');
      end
      else
      begin
        GoodCodeData.GetItemCodeData;
        if GoodCodeData.ItemCodeData.MarkingType >= 0 then
        begin
          Driver.MarkingType := GoodCodeData.ItemCodeData.MarkingType;
          Driver.GTIN := GoodCodeData.ItemCodeData.GTIN;
          Driver.SerialNumber := GoodCodeData.ItemCodeData.SerialNumber;
          Driver.BarCode := GoodCodeData.ItemCodeData.Barcode;
          Check(Driver.FNSendItemCodeData, '������ �������� ���� 1162');
        end;
      end;
    end
    else if FFFDVersion = 4 then
    begin
      SendMarkingCode(MarkingCode, IsOSUCode(MarkingCode));

      if GoodCodeData.Enabled then
      begin
        SendMarkingCode(GoodCodeData.NotIdentified);
        SendMarkingCode(GoodCodeData.EAN8); //��� ������ � ������� EAN-8 � Base64
        SendMarkingCode(GoodCodeData.EAN13); //��� ������ � ������� EAN-13 � Base64
        SendMarkingCode(GoodCodeData.ITF14); //��� ������ � ������� ITF-14 � Base64
        SendMarkingCode(GoodCodeData.GS1_0); //��� ������ � ������� GS1, ���������� �� �����, �� ���������� ���������� ���������� ������������� � Base64
        SendMarkingCode(GoodCodeData.GS1_M); //��� ������ � ������� GS1, ���������� �� �����, ���������� ���������� ���������� ������������� � Base64
        SendMarkingCode(GoodCodeData.KMK); //��� ������ � ������� ��������� ���� ����������, ���������� �� �����, ���������� ���������� ���������� ������������� � Base64
        SendMarkingCode(GoodCodeData.MI); //����������-����������������� ���� �������� �������
        SendMarkingCode(GoodCodeData.EGAIS20); //��� ������ � ������� �����-2.0 � Base64
        SendMarkingCode(GoodCodeData.EGAIS30); //��� ������ � ������� �����-3.0 � Base64
        SendMarkingCode(GoodCodeData.F1); //��� ������ � ������� �.1 � Base64
        SendMarkingCode(GoodCodeData.F2); //��� ������ � ������� �.2 � Base64
        SendMarkingCode(GoodCodeData.F3); //��� ������ � ������� �.3 � Base64
        SendMarkingCode(GoodCodeData.F4); //��� ������ � ������� �.4 � Base64
        SendMarkingCode(GoodCodeData.F5); //��� ������ � ������� �.5 � Base64
        SendMarkingCode(GoodCodeData.F6); //��� ������ � ������� �.6 � Base64
      end;

      if IndustryAttribute.Enabled then
      begin
        SendTagStrOperation(1262, IndustryAttribute.IdentifierFOIV);
        SendTagStrOperation(1263, IndustryAttribute.DocumentDate); //FormatDateTime('dd.mm.yyyy', IndustryAttribute.DocumentDate));
        SendTagStrOperation(1264, IndustryAttribute.DocumentNumber);
        SendTagStrOperation(1265, IndustryAttribute.AttributeValue);
      end;

    end;

    SendStrTagOperation(1230, ACountryOfOrigin);
    SendStrTagOperation(1231, ACustomsDeclaration);
    SendStrTagOperation(1191, AAdditionalAttribute);

    if FFFDVersion < 4 then
      SendStrTagOperation(1197, AMeasurementUnit);

    if AExciseAmount <> '' then
    begin

      SaveSeparator := FormatSettings.DecimalSeparator;
      try
        FormatSettings.DecimalSeparator := '.';
        try
          Excise := Trunc(StrToFloat(AExciseAmount) * 100);
          Driver.TagNumber := 1229;
          Driver.TagType := ttVLN;
          Driver.TagValueVLN := Int64ToStr(Excise);
          Check(Driver.FNSendTagOperation, '������ �������� ���� 1229');
        except
          on E: Exception do
            Logger.Error(E.Message);
        end;
      finally
        FormatSettings.DecimalSeparator := SaveSeparator;
      end;
    end;

    SendAgentDataOperation(AgentData, PurveyorData, AgentSign);
  end;

  procedure DoOperation;
  begin
// �������
    Driver.Tax1 := ATax;
    Driver.Tax2 := 0;
    Driver.Tax3 := 0;
    Driver.Tax4 := 0;
//  if (APaymentItemSign <> 15) and (APaymentItemSign <> 16) then
//    Driver.StringForPrinting := '//' + AName
//  else
    Driver.StringForPrinting := AName;
    Driver.Price := APrice;
    Driver.Quantity := AQuantity;
    Driver.Summ1Enabled := True;
    Driver.Summ1 := ATotal;
    Driver.Department := ADepartment;
    FStringForPrinting := '';
    Driver.BarCode := '0';
    Driver.DiscountName := '';
    Driver.TaxValueEnabled := AUseTaxSum;
    if AUseTaxSum then
      Driver.TaxValue := ATaxValue
    else
      Driver.TaxValue := 0;
    Driver.PaymentTypeSign := APaymentTypeSign;
    Driver.PaymentItemSign := APaymentItemSign;

    if FFFDVersion < 4 then
    begin
      Driver.MeasureUnit := 0;
      Driver.DivisionalQuantity := False;
    end
    else
    begin
      Driver.MeasureUnit := MeasureOfQuantity;
      Driver.DivisionalQuantity := FractionalQuantity.Enabled;
      Driver.Numerator := FractionalQuantity.Numerator.ToString;
      Driver.Denominator := FractionalQuantity.Denominator.ToString;
    end;

    Logger.Debug(Format('TaxValue = %.2f', [ATaxValue]));
    Driver.CheckType := fRecType;
    Check(Driver.FNOperation, '������ FNOperation');
    if not ATax in [1..6] then
      raise Exception.Create('Invalid Tax type');

    if (ATax = 3) or (ATax = 4) then
      TaxValues[ATax] := TaxValues[ATax] + ATotal
    else
      TaxValues[ATax] := TaxValues[ATax] + ATaxValue;
  end;

begin
  Logger.Debug(Format('PrintFiscalLine Name=%s, Q=%.6f,  P=%.2f, T=%.2f, D=%.2f, Dep=%d,' + ' Tax=%d, TaxValue=%.2f, ItemCodeData=%s, AgentSign=%s, PayType=%d, PayItem=%d,' + ' CountryOrigin=%s, CustomsDeclaration=%s, ExciseAmount=%s, AdditionalAttribute=%s, ' + 'MeasurementUnit=%s, UseTaxSum = %s', [AName, AQuantity, APrice, ATotal, ADiscount, ADepartment, ATax, ATaxValue, ItemCodeData, AgentSign, APaymentTypeSign, APaymentItemSign, ACountryOfOrigin, ACustomsDeclaration, AExciseAmount, AAdditionalAttribute, AMeasurementUnit, BoolToStr(AUseTaxSum)]));
  Logger.Debug('MarkingCode = ' + MarkingCode);
  CheckReceiptOpened;
  SetAdminPassword;
  if not FIsFiscalCheck then
    RaiseError(C_ERR_CHECKOPENED, GetRes(@SInvalidOperationInNonfiscalDocument));

//  PrintTextLines;
  if GetModelType(GetModelID) = mtCashCore then
  begin
    BindTags;
    DoOperation;
  end
  else
  begin
    DoOperation;
    BindTags;
  end;

  // ������ ������ � ��������
  SaveSeparator := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    if CompareValue(ADiscount, 0, C_DOUBLE_PREC) = GreaterThanValue then
      PrintPair('������', Format('%.2f', [ADiscount]))
    else if CompareValue(ADiscount, 0, C_DOUBLE_PREC) = LessThanValue then
      PrintPair('��������', Format('%.2f', [-ADiscount]));
  finally
    FormatSettings.DecimalSeparator := SaveSeparator;
  end;
end;

procedure TDevice1C3.SendAgentDataOperation(AgentData: TAgentData; PurveyorData: TVendorData; AgentSign: WideString);
var
  AgSign: Byte;
begin
  if AgentData.Enabled then
  begin
    Logger.Debug('SendAgentDataOperation');
    Driver.TagNumber := 1223; // ������ ������
    Check(Driver.FNBeginSTLVTag); // �������� ������������ ���������� ����

    AddStrTag(1044, AgentData.AgentOperation);
    AddStrTag(1073, AgentData.AgentPhone);
    AddStrTag(1074, AgentData.PaymentProcessorPhone);
    AddStrTag(1075, AgentData.AcquirerOperatorPhone);
    AddStrTag(1026, AgentData.AcquirerOperatorName);
    AddStrTag(1005, AgentData.AcquirerOperatorAddress);
    AddStrTag(1016, AgentData.AcquirerOperatorINN);
    Check(Driver.FNSendSTLVTagOperation, '������ �������� ���� 1223 � ��������'); // ���������� ��������� ��� 1223, ����������� � ��������
  end;

  if PurveyorData.Enabled then
  begin
    Driver.TagNumber := 1224; // ������ ����������
    Check(Driver.FNBeginSTLVTag); // �������� ������������ ���������� ����

    Logger.Debug('PurveyorPhone: ' + PurveyorData.VendorPhone);
    AddStrTag(1171, PurveyorData.VendorPhone);
    Logger.Debug('PurveyorName: ' + PurveyorData.VendorName);
    AddStrTag(1225, PurveyorData.VendorName);
    Check(Driver.FNSendSTLVTagOperation, '������ �������� ���� 1224 � ��������');
  end;

  if PurveyorData.VendorINN <> '' then
  begin
    // �������� ��� ���������� � ��������
    Driver.TagNumber := 1226;
    Driver.TagType := ttString;
    Driver.TagValueStr := PurveyorData.VendorINN; // ��� ����������
    Check(Driver.FNSendTagOperation, '������ �������� ���� 1226 � ��������'); // ��������� ��� 1226, ����������� � ��������
  end;

  Logger.Debug('AgentSign: ' + AgentSign);
  // ������� ������
  if AgentSign <> '' then
  begin
    AgSign := 0;
    SetBit(AgSign, StrToInt(Trim(AgentSign)));

    Driver.TagNumber := 1222; // ������� ������
    Driver.TagType := ttByte;
    Driver.TagValueInt := AgSign;
    Check(Driver.FNSendTagOperation, '������ �������� ���� 1222 � ��������'); // ��������� ��� 1222, ����������� � ��������}
  end;

end;

procedure TDevice1C3.SendMarkingCode(const AMarkingCode: AnsiString; AOSU: Boolean = False);
begin
  Logger.Debug('SendMarkingCode Code: ' + AMarkingCode + ' OSU: ' + SysUtils.BoolToStr(AOSU, True));

  if AMarkingCode = '' then
    Exit;

  if Length(AMarkingCode) < 8 then
  begin
    Logger.Debug('����� �� < 8, �������� ���� 1300');
    Driver.TagNumber := 1300;
    Driver.TagType := ttString;
    Driver.TagValueStr := AMarkingCode;
    Check(Driver.FNSendTagOperation, '������ �������� ���� 1300 � ��������');
  end
  else
  begin
    Logger.Debug('SendMarkingCode. OSU = ' + SysUtils.BoolToStr(AOSU, True));
    Driver.BarcodeHex := StrToHex(AMarkingCode);
    Driver.MCOSUSign := AOSU;
    Check(Driver.FNSendItemBarcode, '������ �������� ��');
  end;
end;

procedure TDevice1C3.GetCurrentStatus32(const InputParameters: WideString; var OutputParameters: WideString);
var
  InParams: TInputParametersRec;
begin
  if FParams.KgKKTEnabled then
  begin
    Logger.Debug('KgKKT Get current status');
    // !!! OutputParameters := OutputParametersToXML(ReadOutputParametersOD);
    Exit;
  end;

  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data Get current status');
    OutputParameters := OutputParametersToXML(ReadOutputParametersOD);
    Exit;
  end;

  Logger.Debug('GetCurrentStatus32');
  Logger.Debug(InputParameters);
  InParams := XMLToInputParameters(InputParameters);

  OutputParameters := OutputParametersToXML(ReadOutputParameters);
  Logger.Debug(OutputParameters);
end;

procedure TDevice1C3.ReportCurrentStatusOfSettlements32(const InputParameters: WideString; var OutputParameters: WideString);
var
  InParams: TInputParametersRec;
begin
  if FParams.KgKKTEnabled then
  begin
    Logger.Debug('KgKKT ReportCurrentStatusOfSettlements32');
    //!! OutputParameters := OutputParametersToXML(ReadOutputParametersOD);
    Exit;
  end;

  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data ReportCurrentStatusOfSettlements32');
    OutputParameters := OutputParametersToXML(ReadOutputParametersOD);
    Exit;
  end;
  Logger.Debug('ReportCurrentStatusOfSettlements32');
  Logger.Debug(InputParameters);
  CancelCheckIfOpened;
  InParams := XMLToInputParameters(InputParameters);

  SetCashierPassword(InParams.CashierName);
  SuppressNextDocumentPrintIfNeeded(InParams);
  try
    Check(Driver.FNBuildCalculationStateReport);
    WaitForPrinting;
  finally
    RestoreNextDocumentPrintIfNeeded(InParams);
  end;
  OutputParameters := OutputParametersToXML(ReadOutputParameters);
  Logger.Debug(OutputParameters);
end;

procedure TDevice1C3.PrintXReport32(const InputParameters: WideString);
var
  InParams: TInputParametersRec;
begin
  if FParams.KgKKTEnabled then
  begin
    Logger.Debug('KgKKT PrintXReport32');
    // !!!
    Exit;
  end;

  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data PrintXReport32');
    Exit;
  end;
  Logger.Debug('PrintXReport');
  Logger.Debug(InputParameters);
  InParams := XMLToInputParameters(InputParameters);
  SetCashierPassword(InParams.CashierName);
  Check(Driver.PrintReportWithoutCleaning);
  WaitForPrinting;
end;

procedure TDevice1C3.CloseShiftFN32(const InputParameters: WideString; var OutputParameters: WideString);
var
  InParams: TInputParametersRec;
begin
  if FParams.KgKKTEnabled then
  begin
    Logger.Debug('KgKKT CloseShiftFN32');
    // !!! OutputParameters := OutputParametersToXML(ReadOutputParametersOD);
    Exit;
  end;

  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data CloseShiftFN32');
    OutputParameters := OutputParametersToXML(ReadOutputParametersOD);
    Exit;
  end;
  Logger.Debug('CloseShiftFN32');
  Logger.Debug(InputParameters);
  InParams := XMLToInputParameters(InputParameters);
  CancelCheckIfOpened;
  SetCashierPassword(InParams.CashierName);
  Check(Driver.FNBeginCloseSession);
  SetCashierVATIN(InParams.CashierVATIN);
  SuppressNextDocumentPrintIfNeeded(InParams);
  try
    Check(Driver.PrintReportWithCleaning);
  //Check(Driver.WaitForPrinting);
    WaitForPrinting;
  finally
    RestoreNextDocumentPrintIfNeeded(InParams);
  end;
  OutputParameters := OutputParametersToXML(ReadOutputParameters);
  Logger.Debug(OutputParameters);
end;

procedure TDevice1C3.PrintTextDocument32(const TextPackage: WideString);
var
  Positions: TPositions1C3;
  i: Integer;
  NonFiscalString: TNonFiscalString32;
  Barcode: TBarcode32;
  Num: Integer;
  SN: Integer;
begin
  if FParams.KgKKTEnabled then
  begin
    Logger.Debug('KgKKT PrintTextDocument');
    Exit;
  end;

  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data PrintTextDocument');
    Exit;
  end;

  Logger.Debug('PrintTextDocument: ' + TextPackage);
  LockPort;
  try
    SetAdminPassword;
    OpenCheck(False, False, True, Num, SN, Params.EnableNonFiscalHeader);
    Positions := TPositions1C3.Create;
    try
      Positions.ReadFromXML(TextPackage, True);
      for i := 0 to Positions.Count - 1 do
      begin
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
    finally
      Positions.Free;
    end;
    CloseCheck(0, 0, 0, 0, 0, Params.EnableNonFiscalFooter);
  finally
    UnlockPort;
  end;
end;

function TDevice1C3.OperationFN32(OperationType: Integer; const ParametersFiscal: WideString): WordBool;

  procedure WriteFiscalParams(const Params: TTableParametersRec);
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
    Driver.ValueOfFieldString := Params.SaleAddress;
    Check(Driver.WriteTable);
    Driver.FieldNumber := 10;
    Driver.ValueOfFieldString := Params.OFDCompany;
    Check(Driver.WriteTable);
    Driver.FieldNumber := 12;
    Driver.ValueOfFieldString := Params.OFDCompanyINN;
    Check(Driver.WriteTable);
    Driver.FieldNumber := 7;
    Driver.ValueOfFieldString := Params.CompanyName;
    Check(Driver.WriteTable);

    Driver.FieldNumber := 13;
    Driver.ValueOfFieldString := Params.FNSURL;
    Check(Driver.WriteTable);

    Driver.FieldNumber := 14;
    Driver.ValueOfFieldString := Params.SaleLocation;
    Check(Driver.WriteTable);

    Driver.FieldNumber := 15;
    Driver.ValueOfFieldString := Params.SenderEmail;
    Check(Driver.WriteTable);

    if Model <> 16 then // ����
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

    Driver.INN := Params.INN;
    Driver.KKTRegistrationNumber := Params.KKTNumber;
    Driver.TaxType := Params.Tax;
    Driver.WorkMode := Params.WorkMode;
    Driver.WorkModeEx := Params.WorkModeEx;
  end;

  procedure WriteFiscalTags(const Params: TTableParametersRec);
  var
    Model: Integer;
  begin
    Driver.ModelParamNumber := mpModelID;
    Check(Driver.ReadModelParamValue);
    Model := Driver.ModelParamValue;

    if Model = 16 then // ����
    begin
      Driver.TagNumber := 1057;
      Driver.TagType := ttByte;
      Driver.TagValueInt := Params.Agent;
      Check(Driver.FNSendTag);
    end;

{  // ������� ������������ ������
    if Params.IsExcisable then
    begin
      Driver.TagNumber := 1207;
      Driver.TagType := ttByte;
      Driver.TagValueInt := 1;
      Check(Driver.FNSendTag);
    end;

  // ������� ���������� �������� ���
    if Params.IsGambling then
    begin
      Driver.TagNumber := 1193;
      Driver.TagType := ttByte;
      Driver.TagValueInt := 1;
      Check(Driver.FNSendTag);
    end;

  // ������� ���������� �������
    if Params.IsLottery then
    begin
      Driver.TagNumber := 1126;
      Driver.TagType := ttByte;
      Driver.TagValueInt := 1;
      Check(Driver.FNSendTag);
    end;}

    if not IsModelType2(Model) then
    begin
      WriteTableInt(18, 1, 22, Params.RegistrationReasonCodeEx);
    end;

    SetCashierVATIN(Params.CashierINN);
    SendStrTag(1117, Params.SenderEmail);
  end;

var
  Params: TTableParametersRec;
begin
  if FParams.KgKKTEnabled then
  begin
    Result := True;
    Logger.Debug('KgKKT OperationFN22');
    Exit;
  end;

  if FParams.ODEnabled then
  begin
    Result := True;
    Logger.Debug('Orange data OperationFN22');
    Exit;
  end;
  Logger.Debug('OperationFN');
  Logger.Debug(ParametersFiscal);

  SetAdminPassword;
  Result := True;
  Params := XMLToTableParameters(ParametersFiscal);
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
          Driver.RegistrationReasonCode := Params.RegistrationReasonCode;
          Driver.RegistrationReasonCodeEx := Params.RegistrationReasonCodeEx;
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
        SetCashierVATIN(Params.CashierINN);
        Check(Driver.FNCloseFiscalMode);
        WaitForPrinting;
      end;
  end;
end;

function TDevice1C3.ParseReasonCodes(const AValue: WideString): Integer;
var
  S: TStringList;
  i: Integer;
begin
  Result := 0;
  S := TStringList.Create;
  try
    S.Delimiter := ',';
    S.DelimitedText := AValue;
    for i := 0 to S.Count - 1 do
      SetBitInt(Result, StrToIntDef(S[i], 0));
  finally
    S.Free;
  end;
end;

(*
<?xml version="1.0" encoding="UTF-8"?>
<ParametersFiscal CashierName="�������������" CashierINN="" RegistrationReasonCode="4"
KKTNumber="1222277788051166" CompanyName="��� �������� ������ N1" INN="6449013711"
SaleAddress="109097, ������, ��. �������, 9" SaleLocation="�������� ���" TaxationSystems="0"
IsOffline="false" IsEncrypted="true" IsService="false" IsExcisable="true" IsGambling="true"
IsLottery="true" AgentTypes="0,1,2,3,4,5,6" BSOSing="false" IsOnlineOnly="false"
IsAutomaticPrinter="false" IsAutomatic="false" AutomaticNumber=""
OFDCompany="��� &quot;����&quot; (&quot;���-�&quot;)" OFDCompanyINN="7728699517"
SenderEmail="example@example.org"/>
*)
function TDevice1C3.XMLToTableParameters(const AValue: WideString): TTableParametersRec;
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
    Xml.LoadFromXML(AValue);
    Node := Xml.ChildNodes.FindNode('ParametersFiscal');
    if Node = nil then
      raise Exception.Create('Wrong XML parameters Table');

    Result.KKTNumber := LoadString(Node, 'KKTNumber', False); // string;            //��������������� ����� ���
    Result.KKTSerialNumber := LoadString(Node, 'KKTSerialNumber', False); // string;      // ��������� ����� ���
    Result.FirmwareVersion := LoadString(Node, 'FirmwareVersion', False); // string;      //������ ��������
    Result.Fiscal := LoadBool(Node, 'Fiscal', False); // boolean;              // ������� ����������� ����������� ����������
    Result.FFDVersionFN := LoadString(Node, 'FFDVersionFN', False); // string;         // ������ ��� �� (���� �� ��������� �������� "1.0","1.1")
    Result.FFDVersionKKT := LoadString(Node, 'FFDVersionKKT', False); // string;        // ������ ��� ��� (���� �� ��������� �������� "1.0","1.0.5","1.1")
    Result.FNSerialNumber := LoadString(Node, 'FNSerialNumber', False); // string;       // ��������� ����� ��
    Result.DocumentNumber := LoadString(Node, 'DocumentNumber', False); // string;       // ����� ��������� ����������� ����������� ����������
    Result.DateTime := LoadDateTime(Node, 'DateTime', False); // TDateTime;          // ���� � ����� �������� ����������� ����������� ����������
    Result.CompanyName := LoadString(Node, 'CompanyName', False); // string;          // �������� �����������
    Result.INN := LoadString(Node, 'INN', False); // string;                  // ��� �����������
    Result.SaleAddress := LoadString(Node, 'SaleAddress', False); // string;          // ����� ���������� ��������
    Result.SaleLocation := LoadString(Node, 'SaleLocation', False); // string;         // ����� ���������� ��������
    Result.TaxationSystems := LoadString(Node, 'TaxationSystems', False); // string;      // ���� ������� ��������������� ����� ����������� ",".
    Result.IsOffline := LoadBool(Node, 'IsOffline', False); // boolean;           // ������� ����������� ������
    Result.IsEncrypted := LoadBool(Node, 'IsEncrypted', False); // boolean;         // ������� ���������� ������
    Result.IsService := LoadBool(Node, 'IsService', False); // boolean;           // ������� �������� �� ������
    Result.IsExcisable := LoadBool(Node, 'IsExcisable', False); // boolean;         // ������� ������������ ������
    Result.IsGambling := LoadBool(Node, 'IsGambling', False); // boolean;          // ������� ���������� �������� ���
    Result.IsLottery := LoadBool(Node, 'IsLottery', False); // boolean;           // ������� ���������� �������
    Result.AgentTypes := LoadString(Node, 'AgentTypes', False); // Integer;          // ���� ��������� ������ ����� ����������� ",".
    Result.BSOSing := LoadBool(Node, 'BSOSing', False); // boolean;             // ������� ������������ �� ���
    Result.IsOnlineOnly := LoadBool(Node, 'IsOnlineOnly', False); // boolean;        // ������� ��� ��� �������� ������ � ��������
    Result.IsAutomaticPrinter := LoadBool(Node, 'IsAutomaticPrinter', False); // boolean;  // ������� ��������� �������� � ��������
    Result.IsAutomatic := LoadBool(Node, 'IsAutomatic', False); // boolean;         // ������� ��������������� ������
    Result.AutomaticNumber := LoadString(Node, 'AutomaticNumber', False); // string;      // ����� �������� ��� ��������������� ������
    Result.OFDCompany := LoadString(Node, 'OFDCompany', False); // string;           // �������� ����������� ���
    Result.OFDCompanyINN := LoadString(Node, 'OFDCompanyINN', False); // string;        // ��� ����������� ���
    Result.FNSURL := LoadString(Node, 'FNSURL', False); // string;               // ����� ����� ��������������� ������ (���) � ���� ���������
    Result.SenderEmail := LoadString(Node, 'SenderEmail', False); // string;          // ����� ����������� ����� ����������� ����
    //=== ParametersFiscal ===
    Result.CashierName := LoadString(Node, 'CashierName', False); // string;          // ��� � ��������� ��������������� ���� ��� ���������� ��������
    Result.CashierINN := LoadString(Node, 'CashierINN', False); // string;           // ��� ��������������� ���� ��� ���������� ��������
    Result.RegistrationReasonCode := LoadInteger(Node, 'RegistrationReasonCode', False); // Integer; // ��� ������� ���������������; // ����������� ������ ��� �������� "��������� ���������� �����������"
    Result.RegistrationLabelCodes := LoadString(Node, 'RegistrationLabelCodes', False); //	string;	// ���� ������ ��������� �������� � ��� ����� �����������.

    Result.RegistrationReasonCodeEx := ParseReasonCodes(Result.RegistrationLabelCodes);

    Result.Tax := ParseTaxSystem(Result.TaxationSystems);
    Result.WorkMode := 0;

    if Result.IsEncrypted then
      SetBit(Result.WorkMode, 0);

    if Result.IsOffline then
      SetBit(Result.WorkMode, 1);

    if Result.IsAutomatic then
      SetBit(Result.WorkMode, 2);

    if Result.IsService then
      SetBit(Result.WorkMode, 3);

    if Result.BSOSing then
      SetBit(Result.WorkMode, 4);

    if Result.IsOnlineOnly or Result.IsOnline then
      SetBit(Result.WorkMode, 5);

    Result.WorkModeEx := 0;

    if Result.IsExcisable then
      SetBit(Result.WorkModeEx, 0);

    if Result.IsGambling then
      SetBit(Result.WorkModeEx, 1);

    if Result.IsLottery then
      SetBit(Result.WorkModeEx, 2);

    if Result.IsAutomaticPrinter then
      SetBit(Result.WorkModeEx, 3);

    if Result.IsMarking then
      SetBit(Result.WorkModeEx, 4);

    if Result.IsPawnshop then
      SetBit(Result.WorkModeEx, 5);

    if Result.IsAssurance then
      SetBit(Result.WorkModeEx, 6);

    Result.Agent := ParseAgent(Result.AgentTypes);
  finally
    Xml := nil;
  end;
end;

function TDevice1C3.EncodeReasonCodes(const AValue: Integer): WideString;
var
  i: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Delimiter := ',';
    for i := 0 to 31 do
    begin
      if TestBit(AValue, i) then
        SL.Add(IntToStr(i));
    end;
    Result := SL.DelimitedText;
  finally
    SL.Free;
  end;
end;

procedure TDevice1C3.doProcessCheckCorrectionOld(const CheckPackage: WideString);
var
  Positions: TPositions1C3;
  TaxV: array[1..6] of Currency;
  Dat: TDateTime;
  i: Integer;
  Res: Integer;
begin
  LockPort;
  try
    Logger.Debug('ProcessCheckCorrectionOld: ' + CheckPackage);
    Positions := TPositions1C3.Create;
    try
      Positions.FFDversion := FFFDVersion;
      Positions.BPOVersion := BPOVersion;
      Positions.ItemNameLength := Params.ItemNameLength;
      Positions.ReadFromXML(CheckPackage, False);
      for i := 1 to 6 do
        TaxV[i] := 0;

      for i := 0 to Positions.Count - 1 do
      begin
        if Positions.Items[i] is TFiscalString32 then
        begin
          TaxV[TFiscalString32(Positions.Items[i]).Tax] := TaxV[TFiscalString32(Positions.Items[i]).Tax] + TFiscalString32(Positions.Items[i]).TaxSumm;
        end;
      end;

      SetCashierPassword(Positions.CashierName);

      Check(Driver.FNBeginCorrectionReceipt);
      try
        SetCashierVATIN(Positions.CashierVATIN);

        Logger.Debug('Correction description: ' + Positions.CorrectionData.Description);
        SendStrTag(1177, Positions.CorrectionData.Description);
        SendStrTag(1179, Positions.CorrectionData.Number);

        if Positions.CorrectionData.Enabled then
        begin
          Driver.TagNumber := 1178;
          Driver.TagType := ttUnixTime;
          Dat := Positions.Correctiondata.Date;
          ReplaceTime(Dat, EncodeTime(0, 0, 0, 0)); // ������� ������������ �������
          Driver.TagValueDateTime := Dat;
          Check(Driver.FNSendTag);
        end;

        Driver.CorrectionType := Positions.CorrectionData.AType;
        Driver.CalculationSign := Positions.OperationType;

        Driver.Summ1 := Positions.Payments.Cash + Positions.Payments.ElectronicPayment + Positions.Payments.PrePayment + Positions.Payments.PostPayment + Positions.Payments.Barter;
        Driver.Summ2 := Positions.Payments.Cash;
        Driver.Summ3 := Positions.Payments.ElectronicPayment;
        Driver.Summ4 := Positions.Payments.PrePayment;
        Driver.Summ5 := Positions.Payments.PostPayment;
        Driver.Summ6 := Positions.Payments.Barter;
        Driver.Summ7 := TaxV[1];
        Driver.Summ8 := TaxV[2];
        Driver.Summ9 := TaxV[3];
        Driver.Summ10 := TaxV[4];
        Driver.Summ11 := TaxV[5];
        Driver.Summ12 := TaxV[6];

        Driver.TaxType := TaxToBin(Positions.TaxVariant);
        Res := Driver.FNBuildCorrectionReceipt2;
        FPrintedOK := Res = 0;

        Check(Res);

      finally
        Positions.Free;
      end

    except
      on E: Exception do
      begin
        Driver.FNCancelDocument;
        raise
      end;
    end;
    WaitForPrinting;
  finally
    UnlockPort;
  end;
end;

procedure TDevice1C3.CancelCheckIfOpened;
begin
  Check(Driver.GetECRStatus);
  if Driver.ECRMode = 8 then
  begin
    SetAdminPassword;
    Check(Driver.SysAdminCancelCheck);
  end;
  Check(Driver.FNGetStatus);
  if (Driver.FNCurrentDocument <> $04) and (Driver.FNCurrentDocument <> 0) then
    Check(Driver.FNCancelDocument);
end;

procedure TDevice1C3.CashInOutcome32(Amount: Double; const InputParameters: WideString);
var
  Params: TInputParametersRec;
begin
  if FParams.KgKKTEnabled then
  begin
    Logger.Debug('KgKKT CashInOutcome');
    Exit;
  end;

  if FParams.ODEnabled then
  begin
    Logger.Debug('Orange data CashInOutcome');
    Exit;
  end;
  Logger.Debug(InputParameters);
  Params := XMLToInputParameters(InputParameters);
  SetAdminPassword;
  LockPort;
  try
    WaitForPrinting;
    CheckReceiptClosed;
    SetCashierPassword(Params.CashierName);
    Driver.Summ1 := Abs(Amount);
    SuppressNextDocumentPrintIfNeeded(Params);
    try
      if Amount >= 0 then
        PrintAndWait(DrvCashIncome)
      else
        PrintAndWait(DrvCashOutcome);
      WaitForPrinting;
    finally
      RestoreNextDocumentPrintIfNeeded(Params);
    end;
    {// �� ���������� 1� ����� ����� ��������� ������������� ����� ��������
    //��������/������
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

procedure TDevice1C3.CheckClock;
var
  Dat: TDateTime;
  sec: UInt64;
begin
  if FParams.CheckClock then
  begin
    Logger.Debug('�������� ������� � ���');
    Check(Driver.GetECRStatus);
    Logger.Debug(Format('������� �����: %s; ����� � ���: %s', [DateTimeToStr(Now), DateTimeToStr(Driver.ECRDate + Driver.ECRTime)]));
    sec := SecondsBetween(Now, Driver.ECRDate + Driver.ECRTime);
    if (sec >= 60) and (sec < 86400) then
    begin
      FLogger.Debug('��������� ���� � �������');
      Dat := Date;
      Driver.Date := Dat;
      Check(Driver.SetDate);
      Driver.Date := Dat;
      Check(Driver.ConfirmDate);
      Driver.Time := Time;
      Check(Driver.SetTime);
    end;
  end;
end;

function TDevice1C3.ReadOutputParametersOD: TOutputParametersRec;
begin
  Result.ShiftNumber := 1; //����� �������� �����/����� �������� �����
  Result.CheckNumber := 1; // ����� ���������� ����������� ���������
  Result.ShiftClosingCheckNumber := 1; // ����� ���������� ���� �� �����
  Result.DateTime := Now; // ���� � ����� ������������ ����������� ���������
  Result.ShiftState := 2; //	��������� ����� 1 - �������, 2 - �������, 3 - �������
  {Result.CountersOperationType1 :=TOperationCountersRec; // OperationCounters	�������� �������� �� ���� "������"
  Result.CountersOperationType2 :=TOperationCountersRec; // �������� �������� �� ���� "������� �������"
  Result.CountersOperationType3 :=TOperationCountersRec; // �������� �������� �� ���� "������"
  Result.CountersOperationType4 :=TOperationCountersRec; // �������� �������� �� ���� "������� �������"}
  Result.CashBalance := 0; // ������� �������� �������� ������� � �����
  Result.BacklogDocumentsCounter := 0; // ���������� ������������ ����������
  Result.BacklogDocumentFirstNumber := 0; // ����� ������� ������������� ���������
  Result.BacklogDocumentFirstDateTime := Now; // ���� � ����� ������� �� ������������ ����������
  Result.FNError := False; // ������� ������������� ������� ������ ��
  Result.FNOverflow := False; // ������� ������������ ������ ��
  Result.FNFail := False; // ������� ���������� ������� ��
end;

procedure TDevice1C3.doProcessCheckOD2(const CheckPackage: WideString; var DocStatus: TODDocStatus2);
var
  Positions: TPositions1C3;
begin
  Logger.Debug('ProcessCheck (OD) ffd v.' + FParams.ODFFDVersion.ToString + ': ' + CheckPackage);
  ODSetParams;
  Positions := TPositions1C3.Create;
  try
    Positions.FFDversion := FParams.ODFFDVersion;
    Positions.BPOVersion := BPOVersion;
    Positions.DeliveryRetail := Params.ODKKTRetailDelivery;
    Positions.ItemNameLength := Params.ItemNameLength;
    Positions.ReadFromXML(CheckPackage, False);
    FODClient2.SendDocument1C(Positions, FParams.ODIsAutomatic, DocStatus);
  finally
    Positions.Free;
  end;
end;

procedure TDevice1C3.doProcessCheckCorrectionOD2(const CheckCorrectionPackage: WideString; var DocStatus: TODDocStatus2);
var
  Params: TCheckCorrectionParamsRec3;
begin
  Logger.Debug('ProcessCheckCorrection (OD): ' + CheckCorrectionPackage);
  ODSetParams;
  ParseCheckCorrection3(CheckCorrectionPackage, Params);
  FODClient2.SendCorrection1C(Params, FParams.ODIsAutomatic, DocStatus);
end;

procedure TDevice1C3.doProcessCheckCorrectionOD2_ffd12(const CheckCorrectionPackage: WideString; var DocStatus: TODDocStatus2);
var
  Positions: TPositions1C3;
begin
  Logger.Debug('ProcessCheckCorrection (OD) ffd v.' + FParams.ODFFDVersion.ToString + ': ' + CheckCorrectionPackage);
  ODSetParams;
  Positions := TPositions1C3.Create;
  try
    Positions.FFDversion := FParams.ODFFDVersion;
    Positions.BPOVersion := BPOVersion;
    Positions.DeliveryRetail := Params.ODKKTRetailDelivery;
    Positions.ItemNameLength := Params.ItemNameLength;
    Positions.ReadFromXML(CheckCorrectionPackage, False);
    FODClient2.SendCorrection1C_ffd12(Positions, FParams.ODIsAutomatic, DocStatus);
  finally
    Positions.Free;
  end;
end;

procedure TDevice1C3.ParseCheckCorrection3(const AXML: WideString; var Params: TCheckCorrectionParamsRec3);
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

function JSToDateTime(ADateTime: WideString): TDateTime;
var
  y, m, d: Integer;
  h, min, sec: Integer;
begin
//  Delete(ADateTime, 1, 1);
  y := StrToIntDef(Copy(ADateTime, 1, 4), 1900);
  m := StrToIntDef(Copy(ADateTime, 6, 2), 1);
  d := StrToIntDef(Copy(ADateTime, 9, 2), 1);
  h := StrToIntDef(Copy(ADateTime, 12, 2), 1);
  min := StrToIntDef(Copy(ADateTime, 15, 2), 1);
  sec := StrToIntDef(Copy(ADateTime, 18, 2), 1);
  Result := EncodeTime(h, min, sec, 0);
  Result := Result + EncodeDate(y, m, d);
end;

function TDevice1C3.DocStatusToDocumentOutputParameters(const ADocStatus: TODDocStatus2): WideString;
var
  Document: TDocumentOutputParametersRec;
begin
  Document.ShiftNumber := StrToInt(ADocStatus.shiftNumber);
  Document.CheckNumber := StrToInt(ADocStatus.documentNumber);
  Document.ShiftClosingCheckNumber := StrToInt(ADocStatus.documentIndex);
  Document.AddressSiteInspections := ADocStatus.fnsWebsite;
  Document.FiscalSign := ADocStatus.fp;
  Document.DateTime := JSTodateTime(ADocStatus.processedAt);
  Result := DocumentOutputParametersToXML(Document);
end;

//	����� ����������� ���������� �������� ���� ���������� � ����.
//  ������������� (RequestStatus ) 	LONG [OUT] 	������ �������:
//  0 � ��������� �������
//  1 � ��������� ��� �� �������
//  2 � ���������� �� ����� ���� �������

//  GUID 	�� 	string 	���������� ������������� �������.
//  Result 	�� 	bool 	True - ��������� �������� �� �� ������������� //False- ��������� �������� �� �� �������������
//  ResultCode 	�� 	int 	��������� �������� �������� � ������, ��� 2106, ������� 110
//  StatusInfo 	��� 	int 	�������� �� 1 �� 3 �� ������� 106 (���)//  ������ ������ ��������� ���� ������� ����� �������� 1.
//  HandleCode 	�� 	int 	��� ��������� �������. //�������� �� 0 �� 2 �� ������� 132 (���)

procedure TDevice1C3.GetProcessingKMResult(var ProcessingKMResult: WideString; var RequestStatus: Integer);
var
  AGUID: string;
  AResult: Boolean;
  AResultCode: Integer;
  AStatusInfo: Integer;
  AHandleCode: Integer;
  KMResult: TProcessingKMResult;
begin
  if FParams.KgKKTEnabled then
  begin
    Logger.Debug('KgKKT GetProcessingKMResult');
    Exit;
  end;

  if FParams.ODEnabled then
  begin
    Logger.Debug('OD GetProcessingKMResult');
    ODSetParams;
    RequestStatus := FProcessingKMResult.RequestStatus;
    if not FODCheckKMStatus.HasValue then
      raise Exception.Create('�� ���� ����������� �������� ��');

    if FODCheckKMStatus.Value.oismCheckResultCode >= 0 then
      KMResult.RequestStatus := 0
    else
      KMResult.RequestStatus := 2;

    KMResult.res := TestBit(FODCheckKMStatus.Value.checkResult, 1); // ��������� �������� �� ��
    KMResult.ResultCode := FODCheckKMStatus.Value.checkResult;
    KMResult.GUID := FODCheckKMStatus.Value.GUID;
    KMResult.HasStatusInfo := False;
    if FODCheckKMStatus.Value.oismResponse.HasValue then
      if FODCheckKMStatus.Value.oismResponse.Value.resultCode.HasValue then
        KMResult.HandleCode := FODCheckKMStatus.Value.oismResponse.Value.resultCode.Value
      else
        KMResult.HandleCode := 0;
    FODCheckKMStatus.SetEmpty;
    ProcessingKMResult := KMResult.ToXML;
    Logger.Debug('OD RequestStatus: ' + RequestStatus.ToString);
    Logger.Debug('OD GetProcessingKMResult: ' + ProcessingKMResult);
    Exit;
  end;

  Logger.Debug('GetProcessingKMResult');
  RequestStatus := FProcessingKMResult.RequestStatus;
  ProcessingKMResult := FProcessingKMResult.ToXML;
  Logger.Debug('RequestStatus: ' + RequestStatus.ToString);
  Logger.Debug('GetProcessingKMResult: ' + ProcessingKMResult);
end;

function TDevice1C3.IsASPDMOdel(AECRSoftVersion: string): Boolean;
begin
  Result := (Trim(AECRSoftVersion) = 'B.3') or (Trim(AECRSoftVersion) = 'D.2');
end;

function TDevice1C3.IsOSUCode(const ACode: AnsiString): Boolean;
var
  Code: AnsiString;
begin
  Result := False;
  for Code in OSUCodes do
    if AnsiSameStr(ACode, Code) then
    begin
      Result := True;
      Break;
    end;
end;

procedure TDevice1C3.ODRequestKM(ARequestKM: TRequestKM; var AChecking: Boolean; var ACheckingResult: Boolean);
var
  KMData: TKMCheckQueryRec;
  DocStatus: TKmCheckDocStatus;
  FracQuantity: TFractionalQuantityRec;
  Guid: TGUID;
begin
  CreateGUID(Guid);
  KMData.id := GUIDToString(Guid);
  KMData.GUID := ARequestKM.GUID;
  KMData.plannedStatus := ARequestKM.PlannedStatus;
  KMData.ItemCode := ARequestKM.MarkingCode;
  if (ARequestKM.HasMeasureOfQuantity) and ((KMData.plannedStatus = 2) or (KMData.plannedStatus = 4)) then
    KMData.quantityMeasurementUnit.Value := ARequestKM.MeasureOfQuantity;

  if (ARequestKM.HasQuantity) and ((KMData.plannedStatus = 2) or (KMData.plannedStatus = 4)) then
    KMData.quantity.Value := ARequestKM.Quantity;

  if ARequestKM.FractionalQuantity then
  begin
    FracQuantity.Numerator := ARequestKM.Numerator;
    FracQuantity.Denominator := ARequestKM.Denominator;
    KMData.fractionalQuantity.Value := FracQuantity;
  end;

  FODClient2.SendKMCheck(KMData, DocStatus);
  AChecking := TestBit(DocStatus.fsCheckStatus, 0);
  ACheckingResult := TestBit(DocStatus.fsCheckStatus, 1);
  FODCheckKMStatus.Value := DocStatus;
end;

//
// 	����� ���������� ��������� �������� �� ���������� ����������� � ������������
//  ������� � ���� ���������� � ����.
//  ����� ���������� ���������� ��������� �������� �� ���������� �����������.

// RequestKM
// GUID 	�� 	string 	���������� ������������� �������. ��������� 1�.
// WaitForResult 	�� 	 bool 	����� �� ��������� ��������� ������ �� ����.
// True-�����, False-�� ���������� ������
// MarkingCode 	�� 	string 	��� ����������� ����� // ���������� ������� � ��������� Base64.
// PlannedStatus 	�� 	int 	����������� ������ ������. // �������� �� 1 �� 5 �� ������� 105 (���)
// Quantity 	�� 	double 	����������
// MeasureOfQuantity 	��� 	string 	���� ���������� �������� �������. // �������� �� ������� 114 (���)
// FractionalQuantity
//   Numerator 	��� 	int 	������� ���������� �������������� ������
//   Denominator 	��� 	int

//RequestKMResult
//   Checking 	�� 	bool 	True - ��� ���������� �������� ���������� ����������� �
//                               �������������� ����� �������� ��.
//                        False - ��� ���������� �� ����� ���� �������� ����������
//                               ����������� � �������������� ����� �������� ��.
//  CheckingResult 	�� 	bool 	True - ��������� �������� �� �� ���������� �����������
//                               � �������������� ����� �������� �� �������������
//                          False - ��������� �������� �� �� ����������
//                               ����������� � �������������� ����� �������� �� �������������.

procedure TDevice1C3.RequestKM(ARequestKM: WideString; var ARequestKMResult: WideString);
var
  RequestKM: TRequestKM;
  Checking: Boolean;
  CheckingResult: Boolean;
  TLVData: string;
  Parser: TTlvParser;
  Tag: TTlvTag;
  KMServerTimeout: Integer;
begin
  if FParams.KgKKTEnabled then
  begin
    Logger.Debug('KgKKT RequestKM');
    Exit;
  end;

  RequestKM.Load(ARequestKM);

  if FParams.ODEnabled then
  begin
    Logger.Debug('OD RequestKM ' + ARequestKM);
    ODSetParams;
    ODRequestKM(RequestKM, Checking, CheckingResult);
    ARequestKMResult := RequestKMResultToXML(Checking, CheckingResult);
    Logger.Debug('RequestKM: ' + ARequestKMResult);
    Exit;
  end;

  Logger.Debug('RequestKM ' + ARequestKM);
  RequestKM.Load(ARequestKM);

  FProcessingKMResult.isOSU := RequestKM.NotSendToServer;

  if RequestKM.NotSendToServer then // ���
  begin
    Logger.Debug('������� ��� ' + RequestKM.MarkingCode);
   // KMServerTimeout := ReadTableInt(19, 1, 8);
   // WriteTableInt(19, 1, 8, 0);
    OSUCodes.Add(RequestKM.MarkingCode);
    FProcessingKMResult.GUID := RequestKM.GUID;
    FProcessingKMResult.Res := True;
    FProcessingKMResult.ResultCode := 0;
    FProcessingKMResult.HasStatusInfo := False;
    FProcessingKMResult.HandleCode := 0;
    FProcessingKMResult.MarkingType2 := 255;
    Exit;
  end;

  Driver.MeasureUnit := RequestKM.MeasureOfQuantity;
  if RequestKM.HasQuantity then
    Driver.Quantity := RequestKM.Quantity
  else
    Driver.Quantity := 1;
  if RequestKM.HasMeasureOfQuantity then
    Driver.MeasureUnit := RequestKM.MeasureOfQuantity
  else
    Driver.MeasureUnit := 0;
  Driver.DivisionalQuantity := RequestKM.FractionalQuantity;
  if RequestKM.FractionalQuantity then
  begin
    Driver.Numerator := RequestKM.Numerator.ToString;
    Driver.Denominator := RequestKM.Denominator.ToString;
  end;

  Driver.ItemStatus := RequestKM.PlannedStatus;
  Driver.BarcodeHex := StrToHex(RequestKM.MarkingCode);


{  try
    Driver.BarcodeHex := StrToHex(RequestKM.MarkingCode);
    Driver.ItemStatus := RequestKM.PlannedStatus;
    Driver.TLVDataHex := '';
    if (Driver.ItemStatus = 4) or (Driver.ItemStatus = 2) then
    begin
      Driver.TagNumber := 2108;
      Driver.TagType := ttByte;
      Driver.TagValueInt := RequestKM.MeasureOfQuantity;
      Check(Driver.GetTagAsTLV);
      TLVData := Driver.TLVDataHEX;

      Driver.TagNumber := 1023;
      Driver.TagType := ttFVLND;
      if RequestKM.FractionalQuantity then
        Driver.TagValueFVLND := 1
      else
        Driver.TagValueFVLND := RequestKM.Quantity;
      Check(Driver.GetTagAsTLV);
      TLVData := TLVData + Driver.TLVDataHex;

      if RequestKM.FractionalQuantity then
      begin
        Driver.TagNumber := 1291;
        Driver.TagType := ttSTLV;
        Driver.FNBeginSTLVTag;
        Driver.TagNumber := 1293;
        Driver.TagType := ttVLN;
        Driver.TagValueVLN := RequestKM.Numerator.ToString;
        Driver.FNAddTag;
        Driver.TagNumber := 1294;
        Driver.TagType := ttVLN;
        Driver.TagValueVLN := RequestKM.Denominator.ToString;
        Driver.FNAddTag;
        Driver.TagNumber := 1291;
        Driver.TagType := ttSTLV;
        Check(Driver.GetTagAsTLV);
        TLVData := TLVData + Driver.TLVDataHex;
      end;
      Driver.TLVDataHex := TLVData;
    end;                      }
  try
    Driver.CheckItemMode := 0;
    Check(Driver.FNCheckItemBarcode2);
    FProcessingKMResult.MarkingType2 := Driver.MarkingType2;
    Checking := TestBit(Driver.CheckItemLocalResult, 0);
    CheckingResult := TestBit(Driver.CheckItemLocalResult, 1);

    FProcessingKMResult.GUID := RequestKM.GUID;
    FProcessingKMResult.Res := TestBit(Driver.KMServerCheckingStatus, 1); // ��������� �������� �� ��

    FProcessingKMResult.ResultCode := Driver.KMServerCheckingStatus;

    if Driver.KMServerCheckingStatus >= 0 then
      FProcessingKMResult.RequestStatus := 0
    else
      FProcessingKMResult.RequestStatus := 2;

    Parser := TTLVParser.Create;
    try
      Parser.ParseTLVAsHex(Driver.TLVDataHex);
      Tag := Parser.Items.FindTag(2109);
      if Tag <> nil then
      begin
        FProcessingKMResult.HasStatusInfo := True;
        FProcessingKMResult.StatusInfo := Tag.AsInteger;
      end
      else
        FProcessingKMResult.HasStatusInfo := False;
    finally
      Parser.Free;
    end;
  finally
    //if RequestKM.NotSendToServer then
    //  WriteTableInt(19, 1, 8, KMServerTimeout);
  end;
  ARequestKMResult := RequestKMResultToXML(Checking, CheckingResult);
  Logger.Debug('RequestKM: ' + ARequestKMResult);
end;


procedure TDevice1C3.SuppressNextDocumentPrintIfNeeded(AInputParams: TInputParametersRec);
begin
   Logger.Debug('SuppressNextDocumentPrintIfNeeded');
   FSavePrintStatus := ReadTableInt(17, 1, 7);

  if AInputParams.PrintRequired then
  begin
    Logger.Debug('Print required');
    if not (IsModelType2(GetModelID)) then
    begin
      Logger.Debug('Enable Document Print');

      if FSavePrintStatus <> 0 then
        WriteTableInt(17, 1, 7, 0);
    end;
    Exit;
  end;

  // ���������� ������ ���������� ���������
  if (FParams.DisablePrintReports) and not (IsModelType2(GetModelID)) then
  begin
     Logger.Debug('Suppress Document Print');
    if FSavePrintStatus <> 2 then
      WriteTableInt(17, 1, 7, 1);
  end;
end;


procedure TDevice1C3.RestoreNextDocumentPrintIfNeeded(AInputParams: TInputParametersRec);
var
  CurrPrintStatus: Integer;
begin
  Logger.Debug('RestoreNextDocumentPrintIfNeeded');

  CurrPrintStatus := ReadTableInt(17, 1, 7);

  if AInputParams.PrintRequired then
  begin
    Logger.Debug('Print required');
    if CurrPrintStatus <> FSavePrintStatus then
      try
        WriteTableInt(17, 1, 7, FSavePrintStatus);
      except

      end;
    Exit;
  end;
  // �������������� ������ ���������� ���������
  if (FParams.DisablePrintReports) and not (IsModelType2(GetModelID)) then
  begin
    try
      if CurrPrintStatus <> FSavePrintStatus then
        WriteTableInt(17, 1, 7, FSavePrintStatus);
    except

    end;
  end;
end;

procedure TDevice1C3.ConfirmKM(RequestGUID: WideString; ConfirmationType: Integer);
begin
  if FParams.ODEnabled then
  begin
    Logger.Debug('OD ConfirmKM ' + ConfirmationType.ToString);
    Exit;
  end;

  Logger.Debug('ConfirmKM ' + ConfirmationType.ToString);

  if FProcessingKMResult.isOSU then
  begin
    Logger.Debug('OSU, skip');
    Exit;
  end;

  if FProcessingKMResult.MarkingType2 = 255 then
  begin
    Logger.Debug('MarkingType2 = 255, skip');
    Exit;
  end;

  if ConfirmationType = 0 then
    Check(Driver.FNAcceptMakringCode)
  else
    Check(Driver.FNDeclineMarkingCode);
end;

procedure TDevice1C3.CloseSessionRegistrationKM3;
begin
  Logger.Debug('CloseSessionRegistrationKM')
end;

procedure TDevice1C3.OpenSessionRegistrationKM3;
begin
  Logger.Debug('OpenSessionRegistrationKM');
  OSUCodes.Clear;
end;

{ TProcessingKMResult }

function TProcessingKMResult.ToXML: string;
begin
  Result := ProcessingKMResultToXML(Guid, Res, ResultCode, HasStatusInfo, StatusInfo, HandleCode);
end;

end.

