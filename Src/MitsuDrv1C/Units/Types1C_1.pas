unit Types1C_1;

interface

uses
  // VCL
  Classes, SysUtils, XMLDoc, XMLIntf,
  // This
  XmlUtils;

const
///////////////////////////////////////////////////////////////////////////////
// OperationType constants for method OperationFN

  D1C_FNOT_OPEN   = 1; // Регистрация
  D1C_FNOT_CHANGE = 2; // Изменение параметров регистрации
  D1C_FNOT_CLOSE  = 3; // Закрытие ФН

type
  IDrvFR1C30 = interface(IDispatch)
    ['{E390D34B-02C3-46C8-803C-DB8131AC5331}']
    function GetInterfaceRevision: Integer; safecall;
    function GetDescription(out DriverDescription: WideString): WordBool; safecall;
    function GetLastError(out ErrorDescription: WideString): Integer; safecall;
    function GetParameters(out TableParameters: WideString): WordBool; safecall;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool; safecall;
    function Open(out DeviceID: WideString): WordBool; safecall;
    function Close(const DeviceID: WideString): WordBool; safecall;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool; safecall;
    function GetAdditionalActions(out TableActions: WideString): WordBool; safecall;
    function DoAdditionalAction(const ActionName: WideString): WordBool; safecall;
    function GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool; safecall;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
                         const ParametersFiscal: WideString): WordBool; safecall;
    function OpenShift(const DeviceID: WideString; const InputParameters: WideString;
                       out OutputParameters: WideString): WordBool; safecall;
    function CloseShift(const DeviceID: WideString; const InputParameters: WideString;
                        out OutputParameters: WideString): WordBool; safecall;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool;
                          const CheckPackage: WideString; out DocumentOutputParameters: WideString): WordBool; safecall;
    function ProcessCorrectionCheck(const DeviceID: WideString; const CheckPackage: WideString;
                                    out DocumentOutputParameters: WideString): WordBool; safecall;
    function CashInOutcome(const DeviceID: WideString; const InputParameters: WideString;
                           Amount: Double): WordBool; safecall;
    function PrintXReport(const DeviceID: WideString; const InputParameters: WideString): WordBool; safecall;
    function GetCurrentStatus(const DeviceID: WideString; const InputParameters: WideString;
                              out OutputParameters: WideString): WordBool; safecall;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString;
                                              const InputParameters: WideString;
                                              out OutputParameters: WideString): WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; safecall;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool; safecall;
    function PrintCheckCopy(const DeviceID: WideString; const CheckNumber: WideString): WordBool; safecall;
    function PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool; safecall;
    function Get_sm_FormatVersion: Integer; safecall;
    procedure Set_sm_FormatVersion(Value: Integer); safecall;
    function OpenSessionRegistrationKM(const DeviceID: WideString): WordBool; safecall;
    function CloseSessionRegistrationKM(const DeviceID: WideString): WordBool; safecall;
    function RequestKM(const DeviceID: WideString; const RequestKM: WideString;
                       out RequestKMResult: WideString): WordBool; safecall;
    function GetProcessingKMResult(const DeviceID: WideString; out ProcessingKMResult: WideString;
                                   out RequestStatus: Integer): WordBool; safecall;
    function ConfirmKM(const DeviceID: WideString; const RequestGUID: WideString;
                       ConfirmationType: Integer): WordBool; safecall;
    function GetLocalizationPattern(out LocalizationPattern: WideString): WordBool; safecall;
    function SetLocalization(const LanguageCode: WideString; const LocalizationPattern: WideString): WordBool; safecall;
    property sm_FormatVersion: Integer read Get_sm_FormatVersion write Set_sm_FormatVersion;
  end;

  { TParametersKKT }

  TParametersKKT = class
    // 3.3
    KKTNumber: WideString; // Регистрационный номер ККТ
    KKTSerialNumber: WideString; // Заводской номер ККТ
    FirmwareVersion: WideString; // Версия прошивки
    Fiscal: Boolean; // Признак регистрации фискального накопителя
    FFDVersionFN: WideString; // Версия ФФД ФН (одно из следующих значений "1.0","1.1")
    FFDVersionKKT: WideString; // Версия ФФД ККТ (одно из следующих значений "1.0","1.0.5","1.1")
    FNSerialNumber: WideString; // Заводской номер ФН
    DocumentNumber: WideString; // Номер документа регистрация фискального накопителя
    DateTime: TDateTime; // Дата и время операции регистрации фискального накопителя
    CompanyName: WideString; // Название организации
    CompanyINN: WideString; // ИНН организация
    SaleAddress: WideString; // Адрес проведения расчетов
    SaleLocation: WideString; // Место проведения расчетов
    TaxationSystems: WideString; // Коды системы налогообложения через разделитель ",".
    IsOffline: Boolean; // Признак автономного режима
    IsEncrypted: Boolean; // Признак шифрование данных
    IsService: Boolean; // Признак расчетов за услуги
    IsExcisable: Boolean; // Продажа подакцизного товара
    IsGambling: Boolean; // Признак проведения азартных игр
    IsLottery: Boolean; // Признак проведения лотереи
    AgentTypes: WideString; // Коды признаков агента через разделитель ",".
    BSOSing: Boolean; // Признак формирования АС БСО
    IsAutomaticPrinter: Boolean; // Признак установки принтера в автомате
    IsAutomatic: Boolean; // Признак автоматического режима
    AutomaticNumber: WideString; // Номер автомата для автоматического режима
    OFDCompany: WideString; // Название организации ОФД
    OFDCompanyINN: WideString; // ИНН организации ОФД
    FNSURL: WideString; // Адрес сайта уполномоченного органа (ФНС) в сети «Интернет»
    SenderEmail: WideString; // Адрес электронной почты отправителя чека
    // 3.4
    IsOnline: Boolean;  // Признак ККТ для расчетов в Интернет
    IsMarking: Boolean; // Признак применения при осуществлении торговли товарами, подлежащими обязательной маркировке средствами идентификации
    IsPawnshop: Boolean; // Признак применения при осуществлении ломбардами кредитования граждан
    IsInsurance: Boolean; // Признак применения при осуществлении деятельности по страхованию
    // 4.1
    IsVendingMachine: Boolean; // Признак применения в автоматическом торговом автомате
    IsCatering: Boolean; // Признак применения при оказании услуг общественного питания
    IsWholesaleTrade: Boolean; // Признак применения о оптовой торговле с организациями и ИП
  end;

  { TParametersFiscal }

  TParametersFiscal = class(TParametersKKT)
  public
    CashierName: WideString; // ФИО и должность уполномоченного лица для проведения операции
    CashierINN: WideString; // ИНН уполномоченного лица для проведения операции
    FFDVersion: WideString; // Версия ФФД на который регистрируется ФН (одно из следующих значений "1.0","1.0.5","1.1", "1.2")
    RegistrationLabelCodes: WideString; // Коды причин изменения сведений о ККТ через разделитель ".
  end;

  { T1CXmlReaderWriter }

  T1CXmlReaderWriter = class
  public
    procedure Read(const Xml: WideString; Params: TParametersKKT); overload;
    procedure Read(const Xml: WideString; Params: TParametersFiscal); overload;
    procedure Write(var Xml: WideString; Params: TParametersKKT); overload;
    procedure Write(var Xml: WideString; Params: TParametersFiscal); overload;
  end;

implementation

function DateTimeToXML(AValue: TDateTime): WideString;
begin
  Result := FormatDateTime('yyyy-mm-dd"T"hh:mm:ss', AValue);
end;

function To1Cbool(AValue: Boolean): WideString;
begin
  if AValue then
    Result := 'true'
  else
    Result := 'false';
end;

{ T1CXmlReaderWriter }

procedure T1CXmlReaderWriter.Read(const Xml: WideString;
  Params: TParametersFiscal);
var
  Node: IXMLNode;
  XmlDoc: IXMLDocument;
begin
  XmlDoc := TXMLDocument.Create(nil);
  try
    XmlDoc.Active := True;
    XmlDoc.Version := '1.0';
    XmlDoc.Encoding := 'UTF-8';
    XmlDoc.Options := XmlDoc.Options + [doNodeAutoIndent];
    XmlDoc.LoadFromXML(Xml);
    Node := XmlDoc.ChildNodes.FindNode('ParametersFiscal');
    if Node = nil then
      raise Exception.Create('Wrong XML parameters Table');

    Params.KKTNumber := LoadString(Node, 'KKTNumber', False);
    Params.KKTSerialNumber := LoadString(Node, 'KKTSerialNumber', False);
    Params.FirmwareVersion := LoadString(Node, 'FirmwareVersion', False);
    Params.Fiscal := LoadBool(Node, 'Fiscal', False);
    Params.FFDVersionFN := LoadString(Node, 'FFDVersionFN', False);
    Params.FFDVersionKKT := LoadString(Node, 'FFDVersionKKT', False);
    Params.FNSerialNumber := LoadString(Node, 'FNSerialNumber', False);
    Params.DocumentNumber := LoadString(Node, 'DocumentNumber', False);
    Params.DateTime := LoadDateTime(Node, 'DateTime', False);
    Params.CompanyName := LoadString(Node, 'CompanyName', False);
    Params.CompanyINN := LoadString(Node, 'INN', False);
    Params.SaleAddress := LoadString(Node, 'SaleAddress', False);
    Params.SaleLocation := LoadString(Node, 'SaleLocation', False);
    Params.TaxationSystems := LoadString(Node, 'TaxationSystems', False);
    Params.IsOffline := LoadBool(Node, 'IsOffline', False);
    Params.IsEncrypted := LoadBool(Node, 'IsEncrypted', False);
    Params.IsService := LoadBool(Node, 'IsService', False);
    Params.IsExcisable := LoadBool(Node, 'IsExcisable', False);
    Params.IsGambling := LoadBool(Node, 'IsGambling', False);
    Params.IsLottery := LoadBool(Node, 'IsLottery', False);
    Params.AgentTypes := LoadString(Node, 'AgentTypes', False);
    Params.BSOSing := LoadBool(Node, 'BSOSing', False);
    Params.IsAutomaticPrinter := LoadBool(Node, 'IsAutomaticPrinter', False);
    Params.IsAutomatic := LoadBool(Node, 'IsAutomatic', False);
    Params.AutomaticNumber := LoadString(Node, 'AutomaticNumber', False);
    Params.OFDCompany := LoadString(Node, 'OFDCompany', False);
    Params.OFDCompanyINN := LoadString(Node, 'OFDCompanyINN', False);
    Params.FNSURL := LoadString(Node, 'FNSURL', False);
    Params.SenderEmail := LoadString(Node, 'SenderEmail', False);

    Params.CashierName := LoadString(Node, 'CashierName', False);
    Params.CashierINN := LoadString(Node, 'CashierINN', False);
    Params.FFDVersion := LoadString(Node, 'FFDVersion', False);
    Params.RegistrationLabelCodes := LoadString(Node, 'RegistrationLabelCodes', False);
  finally
    XmlDoc := nil;
  end;
end;

procedure T1CXmlReaderWriter.Read(const Xml: WideString;
  Params: TParametersKKT);
var
  Node: IXMLNode;
  XmlDoc: IXMLDocument;
begin
  XmlDoc := TXMLDocument.Create(nil);
  try
    XmlDoc.Active := True;
    XmlDoc.Version := '1.0';
    XmlDoc.Encoding := 'UTF-8';
    XmlDoc.Options := XmlDoc.Options + [doNodeAutoIndent];
    XmlDoc.LoadFromXML(Xml);
    Node := XmlDoc.ChildNodes.FindNode('Parameters');
    if Node = nil then
      raise Exception.Create('Wrong XML parameters Table');

    Params.KKTNumber := LoadString(Node, 'KKTNumber', False);
    Params.KKTSerialNumber := LoadString(Node, 'KKTSerialNumber', False);
    Params.FirmwareVersion := LoadString(Node, 'FirmwareVersion', False);
    Params.Fiscal := LoadBool(Node, 'Fiscal', False);
    Params.FFDVersionFN := LoadString(Node, 'FFDVersionFN', False);
    Params.FFDVersionKKT := LoadString(Node, 'FFDVersionKKT', False);
    Params.FNSerialNumber := LoadString(Node, 'FNSerialNumber', False);
    Params.DocumentNumber := LoadString(Node, 'DocumentNumber', False);
    Params.DateTime := LoadDateTime(Node, 'DateTime', False);
    Params.CompanyName := LoadString(Node, 'CompanyName', False);
    Params.CompanyINN := LoadString(Node, 'INN', False);
    Params.SaleAddress := LoadString(Node, 'SaleAddress', False);
    Params.SaleLocation := LoadString(Node, 'SaleLocation', False);
    Params.TaxationSystems := LoadString(Node, 'TaxationSystems', False);
    Params.IsOffline := LoadBool(Node, 'IsOffline', False);
    Params.IsEncrypted := LoadBool(Node, 'IsEncrypted', False);
    Params.IsService := LoadBool(Node, 'IsService', False);
    Params.IsExcisable := LoadBool(Node, 'IsExcisable', False);
    Params.IsGambling := LoadBool(Node, 'IsGambling', False);
    Params.IsLottery := LoadBool(Node, 'IsLottery', False);
    Params.AgentTypes := LoadString(Node, 'AgentTypes', False);
    Params.BSOSing := LoadBool(Node, 'BSOSing', False);
    Params.IsAutomaticPrinter := LoadBool(Node, 'IsAutomaticPrinter', False);
    Params.IsAutomaticMode := LoadBool(Node, 'IsAutomatic', False);
    Params.AutomaticNumber := LoadString(Node, 'AutomaticNumber', False);
    Params.OFDCompany := LoadString(Node, 'OFDCompany', False);
    Params.OFDCompanyINN := LoadString(Node, 'OFDCompanyINN', False);
    Params.FNSURL := LoadString(Node, 'FNSURL', False);
    Params.SenderEmail := LoadString(Node, 'SenderEmail', False);
  finally
    XmlDoc := nil;
  end;
end;

procedure T1CXmlReaderWriter.Write(var Xml: WideString;
  Params: TParametersFiscal);
begin

end;

procedure T1CXmlReaderWriter.Write(var Xml: WideString;
  Params: TParametersKKT);
var
  i: Integer;
  Node: IXMLNode;
  XmlDoc: IXMLDocument;
begin
  XmlDoc := TXMLDocument.Create(nil);
  try
    XmlDoc.Active := True;
    XmlDoc.Version := '1.0';
    XmlDoc.Encoding := 'UTF-8';
    XmlDoc.Options := XmlDoc.Options + [doNodeAutoIndent];
    Node := XmlDoc.AddChild('Parameters');

    Node.Attributes['KKTNumber'] := Params.KKTNumber;
    Node.Attributes['KKTSerialNumber'] := Params.KKTSerialNumber;
    Node.Attributes['FirmwareVersion'] := Params.FirmwareVersion;
    Node.Attributes['Fiscal'] := To1Cbool(Params.Fiscal);
    Node.Attributes['FFDVersionFN'] := Params.FFDVersionFN;
    Node.Attributes['FFDVersionKKT'] := Params.FFDVersionKKT;
    Node.Attributes['FNSerialNumber'] := Params.FNSerialNumber;
    Node.Attributes['DocumentNumber'] := Params.DocumentNumber;
    Node.Attributes['DateTime'] := DateTimeToXML(Params.DateTime);
    Node.Attributes['CompanyName'] := Params.CompanyName;
    Node.Attributes['INN'] := Params.CompanyINN;
    Node.Attributes['SaleAddress'] := Params.SaleAddress;
    Node.Attributes['SaleLocation'] := Params.SaleLocation;
    Node.Attributes['TaxationSystems'] := Params.TaxationSystems;
    Node.Attributes['IsOffline'] := To1Cbool(Params.IsOffline);
    Node.Attributes['IsEncrypted'] := To1Cbool(Params.IsEncrypted);
    Node.Attributes['IsService'] := To1Cbool(Params.IsService);
    Node.Attributes['IsExcisable'] := To1Cbool(Params.IsExcisable);
    Node.Attributes['IsGambling'] := To1Cbool(Params.IsGambling);
    Node.Attributes['IsLottery'] := To1Cbool(Params.IsLottery);
    Node.Attributes['AgentTypes'] := Params.AgentTypes;
    Node.Attributes['BSOSing'] := To1Cbool(Params.BSOSing);
    Node.Attributes['IsOnline'] := To1Cbool(Params.IsOnline);
    Node.Attributes['IsMarking'] := To1Cbool(Params.IsMarking);
    Node.Attributes['IsPawnshop'] := To1Cbool(Params.IsPawnshop);
    Node.Attributes['IsAssurance'] := To1Cbool(Params.IsInsurance);
    Node.Attributes['IsVendingMachine'] := To1Cbool(Params.IsVendingMachine);
    Node.Attributes['IsCateringServices'] := To1Cbool(Params.IsCatering);
    Node.Attributes['IsWholesaleTrade'] := To1Cbool(Params.IsWholesaleTrade);
    Node.Attributes['IsAutomaticPrinter'] := To1Cbool(Params.IsAutomaticPrinter);
    Node.Attributes['IsAutomatic'] := To1Cbool(Params.IsAutomaticMode);
    Node.Attributes['AutomaticNumber'] := Params.AutomaticNumber;
    Node.Attributes['OFDCompany'] := Params.OFDCompany;
    Node.Attributes['OFDCompanyINN'] := Params.OFDCompanyINN;
    Node.Attributes['FNSURL'] := Params.FNSURL;
    Node.Attributes['SenderEmail'] := Params.SenderEmail;
    Xml := XmlDoc.XML.Text;
  finally
    XmlDoc := nil;
  end;
end;

end.
