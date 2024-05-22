unit Positions1C3;

interface

uses
  // VCL
  SysUtils, Classes, XMLDoc, XMLIntf, DateUtils, Variants,
  // This
  XmlUtils, StringUtils, LogFile, GS1Util;

type
  { TRequestKM }

  TRequestKM = record
    GUID: string;
    WaitForResult: Boolean;
    MarkingCode: AnsiString;
    PlannedStatus: Integer;
    HasQuantity: Boolean;
    Quantity: Double;
    HasMeasureOfQuantity: Boolean;
    MeasureOfQuantity: Integer;
    FractionalQuantity: Boolean;
    Numerator: Integer;
    Denominator: Integer;
    NotSendToServer: Boolean;
  end;

  { TPayments }

  TPayments = record
    Cash: Currency;
    ElectronicPayment: Currency;
    PrePayment: Currency;
    PostPayment: Currency;
    Barter: Currency;
  end;

  { TCorrectionData }

  TCorrectionData = record
    Enabled: Boolean;
    AType: Integer;  // Тип коррекции 0 - самостоятельно 1 - по предписанию
    Description: WideString; // Описание коррекции
    Date: TDateTime; // Дата совершения корректируемого расчета
    Number: WideString; // Номер предписания налогового органа
  end;

  { TAgentData }

  TAgentData = record
    Enabled: Boolean;
    AgentOperation: WideString; // 	Операция платежного агента 1044
    AgentPhone: WideString; //Телефон платежного агента 1073
    PaymentProcessorPhone: WideString; //Телефон оператора по приему платежей 1074
    AcquirerOperatorPhone: WideString; //	Телефон оператора перевода 1075
    AcquirerOperatorName: WideString; // 	Наименование оператора перевода 1026
    AcquirerOperatorAddress: WideString; //	Адрес оператора перевода 1005
    AcquirerOperatorINN: WideString; //	ИНН оператора перевода 1016
  end;

  { TVendorData }

  TVendorData = record
    Enabled: Boolean;
    VendorPhone: WideString; //	Телефон поставщика 1171
    VendorName: WideString; //Наименование поставщика 1225
    VendorINN: WideString; //ИНН поставщика 1226
  end;

  { TUserAttribute }

  TUserAttribute = record
    Enabled: Boolean;
    Name: string;
    Value: string;
  end;

  { TCheckCorrectionParamsRec3 }

  TCheckCorrectionParamsRec3 = record
    Id: string;
    CashierName: WideString; //ФИО уполномоченного лица для проведения операции 	Формирование нового чека с заданным атрибутами
    CashierVATIN: WideString; //  	ИНН уполномоченного лица для проведения операции
    CorrectionType: Integer; //	Тип коррекции
      // 0 - самостоятельно
      // 1 - по предписанию
    TaxVariant: Integer; // Код системы налогообложения
    PaymentType: Integer; //	Тип расчета
      //1 - Приход
      //2 - Возврат прихода
      //3 - Расход
      //4 - Возврат расхода
    CorrectionBaseName: WideString; // 	Наименование основания для коррекции
    CorrectionBaseDate: TDateTime; //	Дата документа основания для коррекции
    CorrectionBaseNumber: WideString; // Номер документа основания для коррекции
    Sum: Currency; // Сумма расчета, указанного в чеке
    SumTAX18: Currency; // Сумма НДС чека по ставке 18%
    SumTAX10: Currency; // Сумма НДС чека по ставке 10%
    SumTAX0: Currency; // Сумма НДС чека по ставке 0%
    SumTAXNone: Currency; //Сумма НДС чека по без НДС
    SumTAX110: Currency; // Сумма НДС чека по расч. ставке 10/110
    SumTAX118: Currency; // Сумма НДС чека по расч. ставке 18/118
    Cash: Currency; //Сумма наличной оплаты 	Параметры закрытия чека. Чек коррекции может быть оплачен только одним видом оплаты и без сдачи.
    ElectronicPayment: Currency; //Сумма электронной оплаты
    AdvancePayment: Currency; // Сумма предоплатой (зачетом аванса)
    Credit: Currency; // Сумма постоплатой (в кредит)
    CashProvision: Currency; // Сумма встречным предоставлением
    SettlementsAddress: WideString;
    SettlementPlace: WideString;
  end;

  { TCustomerDetail }

  TCustomerDetail = record
    Enabled: Boolean;
    Info: string;   // Наименование организации или фамилия, имя, отчество (при наличии)
    INN: string;    // ИНН организации или покупателя (клиента)
    DateOfBirthEnabled: Boolean;
    DateOfBirth: TDateTime;  // Дата рождения покупателя (клиента) в формате "DD.MM.YYYY"
    Citizenship: string;  // Числовой код страны, гражданином которой является покупатель (клиент).
                          //Код страны указывается в соответствии с Общероссийским классификатором стран мира ОКСМ.
    DocumentTypeCodeEnabled: Boolean;
    DocumentTypeCode: Integer; // Числовой код вида документа, удостоверяющего личность (ФФД, Таблица 116)
    DocumentData: string;      // Данные документа, удостоверяющего личность
    Address: string;           // Адрес покупателя (клиента)
  end;

  { TOperationalAttribute }

  TOperationalAttribute = record
    Enabled: Boolean;
    DateTime: TDateTime;  // Дата, время операции
    OperationID: Integer;  // Идентификатор операции
    OperationData: string;  // Данные операции
  end;

  { TIndustryAttribute }

  TIndustryAttribute = record
    Enabled: Boolean;
    IdentifierFOIV: string; // Идентификатор ФОИВ
    DocumentDate: TDateTime;   // Дата документа основания в формате "DD.MM.YYYY"
    DocumentNumber: string;  // Номер документа основания
    AttributeValue: string; // Значение отраслевого реквизита
  end;

  { TFractionalQuantity }

  TFractionalQuantity = record
    Enabled: Boolean;
    Numerator: Integer;
    Denominator: Integer;
  end;

  { TItemCodeData }

  TItemCodeData = record
    MarkingType: Integer;
    GTIN: AnsiString;
    SerialNumber: AnsiString;
    Barcode: AnsiString;
  end;

  { TGoodCodeData }

  TGoodCodeData = record
    Enabled: Boolean;
    ItemCodeData: TItemCodeData;
    NotIdentified: AnsiString; //Код товара, формат которого не идентифицирован в Base64
    EAN8: AnsiString; //Код товара в формате EAN-8 в Base64
    EAN13: AnsiString; //Код товара в формате EAN-13 в Base64
    ITF14: AnsiString; //Код товара в формате ITF-14 в Base64
    GS1_0: AnsiString; //Код товара в формате GS1, нанесенный на товар, не подлежащий маркировке средствами идентификации в Base64
    GS1_M: AnsiString; //Код товара в формате GS1, нанесенный на товар, подлежащий маркировке средствами идентификации в Base64
    KMK: AnsiString; //Код товара в формате короткого кода маркировки, нанесенный на товар, подлежащий маркировке средствами идентификации в Base64
    MI: AnsiString; //Контрольно-идентификационный знак мехового изделия
    EGAIS20: AnsiString; //Код товара в формате ЕГАИС-2.0 в Base64
    EGAIS30: AnsiString; //Код товара в формате ЕГАИС-3.0 в Base64
    F1: AnsiString; //Код товара в формате Ф.1 в Base64
    F2: AnsiString; //Код товара в формате Ф.2 в Base64
    F3: AnsiString; //Код товара в формате Ф.3 в Base64
    F4: AnsiString; //Код товара в формате Ф.4 в Base64
    F5: AnsiString; //Код товара в формате Ф.5 в Base64
    F6: AnsiString; //Код товара в формате Ф.6 в Base64
    GTIN: AnsiString; // GTIN для формирования кода маркировки при продаже товаров в объемно-сортовом учете. При передаче этого поля формируется тег 2000 в Base64.
  end;

  TPosition1C3 = class;

  { TReceipt1C }

  TReceipt1C = class
  private
    FID: string;
    FBPOVersion: Integer;
    FList: TList;
    FPayments: TPayments;
    FDeliveryRetail: Boolean;
    FSenderEmail: WideString;
    FSaleAddress: WideString;
    FSaleLocation: WideString;
    FCustomerEmail: WideString;
    FCustomerPhone: WideString;
    FCustomerInfo: WideString;
    FCustomerINN: WideString;
    //FAgentCompensation: Double;
    FCorrectionData: TCorrectionData;
    FAgentData: TAgentData;
    FVendorData: TVendorData;
    FUserAttribute: TUserAttribute;
    FAgentPhone: WideString;
    FCashierINN: WideString;
    FAdditionalAttribute: WideString;
    FCashierName: WideString;
    FOperationType: Integer;
    FTaxationSystem: Integer;
    FFFDVersion: Integer;

    FCustomerDetail: TCustomerDetail;
    FAutomatNumber: string;
    FOperationalAttribute: TOperationalAttribute;
    FIndustryAttribute: TIndustryAttribute;

    FItemNameLength: Integer;
    FAgentType: WideString;
    function GetCount: Integer;
    function GetItem(Index: Integer): TPosition1C3;
    procedure InsertItem(AItem: TPosition1C3);
    procedure RemoveItem(AItem: TPosition1C3);
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TPosition1C3;
    function TotalTaxSum: Currency;

    procedure Clear;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPosition1C3 read GetItem; default;
    property SenderEmail: WideString read FSenderEmail;
    property Payments: TPayments read FPayments;
    property CustomerEmail: WideString read FCustomerEmail;
    property CustomerPhone: WideString read FCustomerPhone;
    property AgentPhone: WideString read FAgentPhone;
    property TaxationSystem: Integer read FTaxationSystem;
    property CashierVATIN: Widestring read FCashierINN;
    property CashierName: Widestring read FCashierName;
    property AgentData: TAgentData read FAgentData;
    property VendorData: TVendorData read FVendorData;
    property FFDversion: Integer read FFFDVersion write FFFDVersion;
    property BPOVersion: Integer read FBPOVersion write FBPOVersion;
    property ItemNameLength: Integer read FItemNameLength write FItemNameLength;
    property AdditionalAttribute: WideString read FAdditionalAttribute write FAdditionalAttribute;
    property AgentSign: Widestring read FAgentType write FAgentType;
    property Id: string read FId write FId;
    property UserAttribute: TUserAttribute read FUserAttribute write FUserAttribute;
    property CustomerInfo: WideString read FCustomerInfo write FCustomerInfo;
    property CustomerINN: WideString read FCustomerINN write FCustomerINN;
    property OperationType: Integer read FOperationType write FOperationType;
    property CorrectionData: TCorrectionData read FCorrectionData;
    property SaleAddress: WideString read FSaleAddress write FSaleAddress;
    property SaleLocation: WideString read FSaleLocation write FSaleLocation;
    property CustomerDetail: TCustomerDetail read FCustomerDetail;
    property AutomatNumber: string read FAutomatNumber;
    property OperationalAttribute: TOperationalAttribute read FOperationalAttribute;
    property IndustryAttribute: TIndustryAttribute read FIndustryAttribute;
    property DeliveryRetail: Boolean read FDeliveryRetail write FDeliveryRetail;
  end;

  { TPosition1C }

  TPosition1C3 = class
  private
    FOwner: TReceipt1C;
    procedure SetOwner(AOwner: TReceipt1C);
  public
    constructor Create(AOwner: TReceipt1C);
    destructor Destroy; override;
  end;

  { TFiscalString }

  TFiscalString = class(TPosition1C3)
  private
    FAmount: Double;
    FQuantity: Double;
    FTax: Integer;
    FPrice: Double;
    FName: WideString;
    FBarcode: WideString;
    FDepartment: Integer;
  public
    property Name: WideString read FName;
    property Barcode: WideString read FBarcode;
    property Quantity: Double read FQuantity;
    property Price: Double read FPrice;
    property Amount: Double read FAmount;
    property Tax: Integer read FTax;
    property Department: Integer read FDepartment;
  end;

  { TFiscalString32 }

  TFiscalString32 = class(TPosition1C3)
  private
    FName: WideString;
    FQuantity: Double;
    FPriceWithDiscount: Double;
    FSumWithDiscount: Double;
    FDiscountSum: Double;
    FDepartment: Integer;
    FTax: Integer;
    FTaxSumm: Double;
    FSignMethodCalculation: Integer;
    FSignCalculationObject: Integer;
    FMarking: AnsiString;
    FMarkingRaw: string;
    FAgentData: TAgentData;
    FVendorData: TVendorData;
    FAgentType: WideString;
    FCountryOfOfigin: WideString;
    FCustomsDeclaration: WideString;
    FExciseAmount: WideString;
    FAdditionalAttribute: WideString;
    FMeasurementUnit: WideString;
    FIndustryAttribute: TIndustryAttribute;
    FMeasureQuantity: Integer;
    FFractionalQuantity: TFractionalQuantity;
    FGoodCodeData: TGoodCodeData;
    FMarkingCode: AnsiString;
    FMeasureOfQuantity: Integer;
  public
    property Name: WideString read FName;
    property Quantity: Double read FQuantity;
    property PriceWithDiscount: Double read FPriceWithDiscount;
    property SumWithDiscount: Double read FSumWithDiscount;
    property Tax: Integer read FTax;
    property Department: Integer read FDepartment;
    property SignMethodCalculation: Integer read FSignMethodCalculation;
    property SignCalculationObject: Integer read FSignCalculationObject;
    property DiscountSum: Double read FDiscountSum;
    property Marking: AnsiString read FMarking;
    property AgentData: TAgentData read FAgentData write FAgentData;
    property VendorData: TVendorData read FVendorData write FVendorData;
    property AgentSign: WideString read FAgentType write FAgentType;
    property CountryOfOfigin: WideString read FCountryOfOfigin write FCountryOfOfigin;
    property CustomsDeclaration: WideString read FCustomsDeclaration write FCustomsDeclaration;
    property ExciseAmount: WideString read FExciseAmount write FExciseAmount;
    property AdditionalAttribute: WideString read FAdditionalAttribute write FAdditionalAttribute;
    property MeasurementUnit: WideString read FMeasurementUnit write FMeasurementUnit;
    property TaxSumm: Double read FTaxSumm;
    property MarkingRaw: string read FMarkingRaw write FMarkingRaw;

    property MeasureOfQuantity: Integer read FMeasureOfQuantity write FMeasureOfQuantity;
    property FractionalQuantity: TFractionalQuantity read FFractionalQuantity write FFractionalQuantity;
    property GoodCodeData: TGoodCodeData read FGoodCodeData write FGoodCodeData;
    property MarkingCode: AnsiString read FMarkingCode write FMarkingCode;
    property IndustryAttribute: TIndustryAttribute read FIndustryAttribute write FIndustryAttribute;
  end;

  TNonFiscalString32 = class(TPosition1C3)
  private
    FText: WideString;
  public
    property Text: WideString read FText;
  end;

  TBarcode32 = class(TPosition1C3)
  private
    FBarcode: AnsiString;
    FBarcodeType: WideString;
  public
    property BarcodeType: WideString read FBarcodeType;
    property Barcode: AnsiString read FBarcode;
  end;

  { TPositionsXmlReader }

  TPositionsXmlReader = class
  private
    FLogger: ILogFile;
    FItems: TReceipt1C;

    procedure LoadParameters(ANode: IXMLNode);
    procedure LoadPositions(ANode: IXMLNode; ANonFiscal: Boolean);
    procedure LoadFiscalString32(ANode: IXMLNode);
    procedure LoadNonFiscalString32(ANode: IXMLNode);
    procedure LoadBarcode32(ANode: IXMLNode);
  public
    constructor Create(AItems: TReceipt1C; ALogger: ILogFile);
    procedure ReadFromXML(const AXML: WideString; ANonFiscal: Boolean);

    class procedure Load(ANode: IXMLNode; var R: TAgentData); overload;
    class procedure Load(ANode: IXMLNode; var R: TVendorData); overload;
    class procedure Load(ANode: IXMLNode; var R: TUserAttribute); overload;
    class procedure Load(ANode: IXMLNode; var R: TCorrectionData); overload;
    class procedure Load(ANode: IXMLNode; var R: TCustomerDetail); overload;
    class procedure Load(ANode: IXMLNode; var R: TOperationalAttribute); overload;
    class procedure Load(ANode: IXMLNode; var R: TIndustryAttribute); overload;
    class procedure Load(ANode: IXMLNode; var R: TFractionalQuantity); overload;
    class procedure Load(ANode: IXMLNode; var R: TGoodCodeData); overload;
    class procedure Load(ANode: IXMLNode; var R: TPayments); overload;
    class procedure Load(const XmlText: WideString; var R: TRequestKM); overload;

    property Logger: ILogFile read FLogger;
    property Items: TReceipt1C read FItems;
  end;

procedure LoadFromXml(Positions: TReceipt1C; Logger: ILogFile;
  const Xml: WideString; ANonFiscal: Boolean);

implementation

function To1Cbool(AValue: Boolean): WideString;
begin
  if AValue then
    Result := 'true'
  else
    Result := 'false';
end;

function QuantityToStr(AValue: Double): string;
var
  SaveSeparator: Char;
begin
  SaveSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  try
    Result := SysUtils.Format('%.*f', [6, AValue]);
  finally
    DecimalSeparator := SaveSeparator;
  end;
end;


procedure LoadFromXml(Positions: TReceipt1C; Logger: ILogFile;
  const Xml: WideString; ANonFiscal: Boolean);
var
  Reader: TPositionsXmlReader;
begin
  Reader := TPositionsXmlReader.Create(Positions, Logger);
  try
    Reader.ReadFromXML(Xml, ANonFiscal);
  finally
    Reader.Free;
  end;
end;

{ TGoodCodeData }

function GetItemCodeData(const P: TGoodCodeData): TItemCodeData;
begin
  Result.MarkingType := -1;
  Result.GTIN := '';
  Result.SerialNumber := '';
  Result.Barcode := '';

  if P.EAN8 <> '' then
  begin
    Result.MarkingType := $4508;
    Result.Barcode := P.EAN8;
    Exit;
  end;

  if P.EAN13 <> '' then
  begin
    Result.MarkingType := $450D;
    Result.Barcode := P.EAN13;
    Exit;
  end;

  if P.ITF14 <> '' then
  begin
    Result.MarkingType := $490E;
    Result.Barcode := P.ITF14;
    Exit;
  end;

  if P.GS1_M <> '' then
  begin
    Result.MarkingType := $444D;
    DecodeGS1_full(P.GS1_M, Result.GTIN, Result.SerialNumber);
    AddTrailingSpaces(Result.SerialNumber, 13);
    Exit;
  end;

  if P.MI <> '' then
  begin
    Result.MarkingType := $5246;
    Result.Barcode := P.MI;
    Exit;
  end;

  if P.EGAIS20 <> '' then
  begin
    Result.MarkingType := $C514;
    Result.Barcode := P.EGAIS20;
    Exit;
  end;

  if P.EGAIS30 <> '' then
  begin
    Result.MarkingType := $C51E;
    Result.Barcode := P.EGAIS30;
    Exit;
  end;

  if P.KMK <> '' then
  begin
    Result.MarkingType := 0;
    Result.Barcode := P.KMK;
    Exit;
  end;

  if P.NotIdentified <> '' then
  begin
    Result.MarkingType := 0;
    Result.Barcode := P.NotIdentified;
    Exit;
  end;
end;

{ TPositions1C }

constructor TReceipt1C.Create;
var
  Guid: TGUID;
begin
  inherited Create;
  FList := TList.Create;
  FFFDVersion := 0;
  CreateGUID(Guid);
  FID := GUIDToString(Guid);
  FDeliveryRetail := False;
end;

destructor TReceipt1C.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TReceipt1C.Clear;
begin
  while Count > 0 do
    Items[0].Free;
end;

function TReceipt1C.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TReceipt1C.GetItem(Index: Integer): TPosition1C3;
begin
  Result := FList[Index];
end;

procedure TReceipt1C.InsertItem(AItem: TPosition1C3);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TReceipt1C.RemoveItem(AItem: TPosition1C3);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TReceipt1C.Add: TPosition1C3;
begin
  Result := TPosition1C3.Create(Self);
end;

function TReceipt1C.TotalTaxSum: Currency;
var
  Position: TPosition1C3;
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
  begin
    if Items[i] is TFiscalString32 then
      Result := Result + TFiscalString32(Items[i]).FTaxSumm;
  end;
end;

{ TPosition1C }

constructor TPosition1C3.Create(AOwner: TReceipt1C);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TPosition1C3.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TPosition1C3.SetOwner(AOwner: TReceipt1C);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then
      FOwner.RemoveItem(Self);
    if AOwner <> nil then
      AOwner.InsertItem(Self);
  end;
end;

{ TPositionsXmlReader }

constructor TPositionsXmlReader.Create(AItems: TReceipt1C; ALogger: ILogFile);
begin
  inherited Create;
  FItems := AItems;
  FLogger := ALogger;
end;

procedure TPositionsXmlReader.ReadFromXML(const AXML: WideString; ANonFiscal: Boolean);
var
  Xml: IXMLDocument;
  Node: IXMLNode;
  i: Integer;
  Doc: IXMLNode;
begin
  Logger.Debug('TReceipt1C.ReadFromXML');
  Logger.Debug('ANonFiscal = ' + BoolToStr(ANonFiscal));
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXML(AXML);
    if ANonFiscal then
      Doc := Xml.ChildNodes.FindNode('Document')
    else
      Doc := Xml.ChildNodes.FindNode('CheckPackage');
    if Doc = nil then
      Exit;

    for i := 0 to Doc.ChildNodes.Count - 1 do
    begin
      Node := Doc.ChildNodes.Nodes[i];
      if Node = nil then
        Continue;
      if Node.NodeName = 'Parameters' then
      begin
        LoadParameters(Node);
        Continue;
      end;
      if Node.NodeName = 'Positions' then
      begin
        LoadPositions(Node, ANonFiscal);
        Continue;
      end;
      if Node.NodeName = 'Payments' then
      begin
        Load(Node, Items.FPayments);
        Continue;
      end;
    end;
  finally
    Xml := nil;
  end;
end;

(*
<Parameters PaymentType="1" TaxVariant="0" CashierName="Казакова Н.А."
  SenderEmail="info@1c.ru" CustomerEmail="" CustomerPhone="" AgentSign="2"
  AddressSettle="г.Москва, Дмитровское ш. д.9">
  <AgentData PayingAgentOperation="operation" PayingAgentPhone="tel"
  ReceivePaymentsOperatorPhone="tel" MoneyTransferOperatorPhone="tel"
  MoneyTransferOperatorName="name" MoneyTransferOperatorAddress="addr"/>
  <PurveyorData PurveyorPhone="12343332" PurveyorName="123fffff" PurveyorVATIN="123456789"/>
	</Parameters>
*)

procedure TPositionsXmlReader.LoadParameters(ANode: IXMLNode);
var
  Node: IXMLNode;
begin
  FItems.FCashierName := LoadString(ANode, 'CashierName', False);
  FItems.FCashierINN := LoadString(ANode, 'CashierINN', False);
  FItems.FOperationType := LoadInteger(ANode, 'OperationType', True);
  FItems.FTaxationSystem := LoadInteger(ANode, 'TaxationSystem', True);
  FItems.FCustomerInfo := LoadString(ANode, 'CustomerInfo', False);
  FItems.FCustomerINN := LoadString(ANode, 'CustomerINN', False);
  FItems.FCustomerEmail := LoadString(ANode, 'CustomerEmail', False);
  FItems.FCustomerPhone := LoadString(ANode, 'CustomerPhone', False);
  FItems.FSenderEmail := LoadString(ANode, 'SenderEmail', False);
  FItems.FSaleAddress := LoadString(ANode, 'SaleAddress', False);
  FItems.FSaleLocation := LoadString(ANode, 'SaleLocation', False);
  FItems.FAgentType := LoadString(ANode, 'AgentType', False);
  FItems.FAdditionalAttribute := LoadString(ANode, 'AdditionalAttribute', False);
  //FAutomaticNumber := LoadString(ANode, 'AutomatNumber', False);
  Load(ANode, FItems.FCorrectionData);
  Load(ANode, FItems.FAgentData);
  Load(ANode, FItems.FVendorData);
  Load(ANode, FItems.FUserAttribute);
  Load(ANode, FItems.FCustomerDetail);
  Load(ANode, FItems.FOperationalAttribute);
  Load(ANode, FItems.FIndustryAttribute);
end;

procedure TPositionsXmlReader.LoadPositions(ANode: IXMLNode; ANonFiscal: Boolean);
var
  i: Integer;
  Node: IXMLNode;
begin
  for i := 0 to ANode.ChildNodes.Count - 1 do
  begin
    Node := ANode.ChildNodes.Nodes[i];
    if Node = nil then
      Continue;
    if not ANonFiscal then
    begin
      if Node.NodeName = 'FiscalString' then
      begin
        LoadFiscalString32(Node);
        Continue;
      end;
    end;
    if Node.NodeName = 'TextString' then
    begin
      LoadNonFiscalString32(Node);
      Continue;
    end;
    if Node.NodeName = 'Barcode' then
    begin
      LoadBarcode32(Node);
      Continue;
    end;
  end;
end;

function DecodeBase64(const AData: string): AnsiString;
//var
//  Data: TBytes;
begin
(*
  if AData = '' then
  begin
    Result := '';
    Exit;
  end;
  // Data := TNetEncoding.Base64.DecodeStringToBytes(AData); !!!
  SetString(Result, PAnsiChar(Data), Length(Data));
*)
end;

procedure TPositionsXmlReader.LoadBarcode32(ANode: IXMLNode);
var
  Item: TBarcode32;
begin
  Item := TBarcode32.Create(FItems);
  Item.FBarcodeType := LoadString(ANode, 'Type', True);
  if HasAttribute(ANode, 'Value') then
    Item.FBarcode := LoadString(ANode, 'Value', True);
  if HasAttribute(ANode, 'ValueBase64') then
    Item.FBarcode := DecodeBase64(LoadString(ANode, 'ValueBase64', True));
  Logger.Debug('FBARCODE ' + Item.FBarcode);
end;

procedure TPositionsXmlReader.LoadNonFiscalString32(ANode: IXMLNode);
begin
  TNonFiscalString32.Create(FItems).FText := LoadString(ANode, 'Text', True);
end;

function TaxToInt(const ATax: WideString): Integer;
begin
  if (ATax = '18') or (ATax = '20') then
    Result := 1
  else if ATax = '10' then
    Result := 2
  else if ATax = '0' then
    Result := 3
  else if ATax = 'none' then
    Result := 4
  else if (ATax = '18/118') or (ATax = '20/120') then
    Result := 5
  else if ATax = '10/110' then
    Result := 6
  else
    raise Exception.Create('Invalid Tax Value: ' + ATax);
end;

procedure TPositionsXmlReader.LoadFiscalString32(ANode: IXMLNode);
var
  Item: TFiscalString32;
  T: WideString;
  Node: IXMLNode;
begin
  Item := TFiscalString32.Create(FItems);
  Item.FName := LoadString(ANode, 'Name', True);
  if Items.ItemNameLength > 0 then
    Item.FName := Copy(Item.FName, 1, Items.ItemNameLength);

  Item.FQuantity := LoadDouble(ANode, 'Quantity', True);
  Item.FPriceWithDiscount := LoadDouble(ANode, 'PriceWithDiscount', True);
  Item.FSumWithDiscount := LoadDouble(ANode, 'AmountWithDiscount', True);
  if ANode.Attributes['DiscountAmount'] = '' then
    Item.FDiscountSum := 0
  else
    Item.FDiscountSum := LoadDouble(ANode, 'DiscountAmount', True);

  Item.FSignMethodCalculation := LoadIntegerDef(ANode, 'PaymentMethod', False, 4);
  Item.FSignCalculationObject := LoadIntegerDef(ANode, 'CalculationSubject', False, 1);
  T := LoadString(ANode, 'VATRate', True);
  Item.FTax := TaxToInt(T);
  Item.FTaxSumm := LoadDouble(ANode, 'VATAmount', False);
  Item.FDepartment := LoadIntegerDef(ANode, 'Department', False, 0);
  Item.AgentSign := LoadString(ANode, 'CalculationAgent', False);
  Item.ExciseAmount := LoadString(ANode, 'ExciseAmount', False);
  Item.FCountryOfOfigin := LoadString(ANode, 'CountryOfOrigin', False);
  Item.FCustomsDeclaration := LoadString(ANode, 'CustomsDeclaration', False);
  Item.FAdditionalAttribute := LoadString(ANode, 'AdditionalAttribute', False);
  Item.FMeasurementUnit := LoadString(ANode, 'MeasurementUnit', False);
  Load(ANode, Item.FIndustryAttribute);
  Item.FMeasureOfQuantity := LoadInteger(ANode, 'MeasureOfQuantity', False);
  Load(ANode, Item.FFractionalQuantity);
  Load(ANode, Item.FGoodCodeData);
  Item.FMarkingCode := DecodeBase64(LoadString(ANode, 'MarkingCode', False));
  Load(ANode, Item.FIndustryAttribute);

  // Код маркировки
  Item.FMarking := '';
  Item.FMarkingRaw := '';
  Node := ANode.ChildNodes.FindNode('GoodCodeData');
  if Node <> nil then
  begin
    Item.FMarking := DecodeBase64(LoadString(Node, 'MarkingCode', False));
    Item.FMarkingRaw := LoadString(Node, 'MarkingCode', False);
  end;
  Logger.Debug('LoadFiscalString32.2');
  // Данные агента
  Item.FAgentData.Enabled := False;
  Node := ANode.ChildNodes.FindNode('AgentData');
  if Node <> nil then
  begin
    if Node.AttributeNodes.Count > 0 then
    begin
      Item.FAgentData.Enabled := True;
      Item.FAgentData.AgentOperation := LoadString(Node, 'AgentOperation', False);
      Item.FAgentData.AgentPhone := LoadString(Node, 'AgentPhone', False);
      Item.FAgentData.PaymentProcessorPhone := LoadString(Node, 'PaymentProcessorPhone', False);
      Item.FAgentData.AcquirerOperatorPhone := LoadString(Node, 'AcquirerOperatorPhone', False);
      Item.FAgentData.AcquirerOperatorName := LoadString(Node, 'AcquirerOperatorName', False);
      Item.FAgentData.AcquirerOperatorAddress := LoadString(Node, 'AcquirerOperatorAddress', False);
      Item.FAgentData.AcquirerOperatorINN := LoadString(Node, 'AcquirerOperatorINN', False);

      if (Item.FAgentData.AgentOperation = '') and
        (Item.FAgentData.AgentPhone = '') and
        (Item.FAgentData.PaymentProcessorPhone = '') and
        (Item.FAgentData.AcquirerOperatorPhone = '') and
        (Item.FAgentData.AcquirerOperatorName = '') and
        (Item.FAgentData.AcquirerOperatorAddress = '') and
        (Item.FAgentData.AcquirerOperatorINN = '') then
        Item.FAgentData.Enabled := False;
    end;
  end;
  Logger.Debug('LoadFiscalString32.3');
  // Данные поставщика
  Item.FVendorData.Enabled := False;
  Node := ANode.ChildNodes.FindNode('VendorData');
  if Node <> nil then
  begin
    if Node.AttributeNodes.Count > 0 then
    begin
      Item.FVendorData.Enabled := True;
      Item.FVendorData.VendorPhone := LoadString(Node, 'VendorPhone', False);
      Item.FVendorData.VendorName := LoadString(Node, 'VendorName', False);
      Item.FVendorData.VendorINN := LoadString(Node, 'VendorINN', False);
      if (Item.FVendorData.VendorPhone = '') and (Item.FVendorData.VendorName = '') and (Item.FVendorData.VendorINN = '') then
        Item.FVendorData.Enabled := False;
    end;
  end;
  Logger.Debug('LoadFiscalString32.4');
end;

class procedure TPositionsXmlReader.Load(ANode: IXMLNode; var R: TCorrectionData);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('CorrectionData');
  if Node = nil then
    Exit;

  R.Enabled := True;
  R.AType := LoadInteger(Node, 'Type', False);
  R.Description := LoadString(Node, 'Description', False);
  R.Date := LoadDateTime(Node, 'Date', False);
  R.Number := LoadString(Node, 'Number', False);
end;

class procedure TPositionsXmlReader.Load(ANode: IXMLNode; var R: TAgentData);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('AgentData');
  if Node = nil then
    Exit;

  R.Enabled := True;
  R.AgentOperation := LoadString(Node, 'AgentOperation', False);
  R.AgentPhone := LoadString(Node, 'AgentPhone', False);
  R.PaymentProcessorPhone := LoadString(Node, 'PaymentProcessorPhone', False);
  R.AcquirerOperatorPhone := LoadString(Node, 'AcquirerOperatorPhone', False);
  R.AcquirerOperatorName := LoadString(Node, 'AcquirerOperatorName', False);
  R.AcquirerOperatorAddress := LoadString(Node, 'AcquirerOperatorAddress', False);
  R.AcquirerOperatorINN := LoadString(Node, 'AcquirerOperatorINN', False);
  if (R.AgentOperation = '') and
    (R.AgentPhone = '') and
    (R.PaymentProcessorPhone = '') and
    (R.AcquirerOperatorPhone = '') and
    (R.AcquirerOperatorName = '') and
    (R.AcquirerOperatorAddress = '') and
    (R.AcquirerOperatorINN = '') then
    R.Enabled := False;
end;

class procedure TPositionsXmlReader.Load(ANode: IXMLNode; var R: TVendorData);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('VendorData');
  if Node = nil then
    Exit;

  R.Enabled := True;
  R.VendorPhone := LoadString(Node, 'VendorPhone', False);
  R.VendorName := LoadString(Node, 'VendorName', False);
  R.VendorINN := LoadString(Node, 'VendorINN', False);
  if (R.VendorPhone = '') and (R.VendorName = '') and (R.VendorINN = '') then
    R.Enabled := False;
end;

class procedure TPositionsXmlReader.Load(ANode: IXMLNode; var R: TUserAttribute);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('UserAttribute');
  if Node = nil then
    Exit;

  R.Enabled := True;
  R.Name := LoadString(Node, 'Name', True);
  R.Value := LoadString(Node, 'Value', True);
  if (R.Name = '') and (R.Value = '') then
    R.Enabled := False;
end;

class procedure TPositionsXmlReader.Load(ANode: IXMLNode; var R: TCustomerDetail);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('CustomerDetail');
  if Node = nil then
    Exit;

  R.Enabled := HasAttribute(Node, 'Info') or HasAttribute(Node, 'INN') or
    HasAttribute(Node, 'DateOfBirth') or HasAttribute(Node, 'Citizenship') or
    HasAttribute(Node, 'DocumentTypeCode') or HasAttribute(Node, 'DocumentData')
    or HasAttribute(Node, 'Address');
  if not R.Enabled then
    Exit;

  R.Info := LoadString(Node, 'Info', False);
  R.INN := LoadString(Node, 'INN', False);
  R.DateOfBirthEnabled := HasAttribute(Node, 'DateOfBirth');
  if R.DateOfBirthEnabled then
    R.DateOfBirth := LoadDateTime(Node, 'DateOfBirth', False);
  R.Citizenship := LoadString(Node, 'Citizenship', False);
  R.DocumentTypeCodeEnabled := HasAttribute(Node, 'DocumentTypeCode');
  if R.DocumentTypeCodeEnabled then
    R.DocumentTypeCode := LoadInteger(Node, 'DocumentTypeCode', False);
  R.DocumentData := LoadString(Node, 'DocumentData', False);
  R.Address := LoadString(Node, 'Address', False);
end;

class procedure TPositionsXmlReader.Load(ANode: IXMLNode; var R: TOperationalAttribute);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('OperationalAttribute');
  if Node = nil then
    Exit;

  R.Enabled := HasAttribute(Node, 'DateTime') or
    HasAttribute(Node, 'OperationID') or HasAttribute(Node, 'OperationData');
  if not R.Enabled then
    Exit;

  R.DateTime := LoadDateTime(Node, 'DateTime', False);
  R.OperationID := LoadInteger(Node, 'OperationID', False);
  R.OperationData := LoadString(Node, 'OperationData', False);
end;

class procedure TPositionsXmlReader.Load(ANode: IXMLNode; var R: TIndustryAttribute);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('IndustryAttribute');
  if Node = nil then
    Exit;

  R.Enabled := HasAttribute(Node, 'IdentifierFOIV') or
    HasAttribute(Node, 'DocumentDate') or
    HasAttribute(Node, 'DocumentNumber') or
    HasAttribute(Node, 'AttributeValue');

  if not R.Enabled then
    Exit;

  R.IdentifierFOIV := LoadString(Node, 'IdentifierFOIV', False);
  R.DocumentDate := LoadDateTime(Node, 'DocumentDate', False);
  R.DocumentNumber := LoadString(Node, 'DocumentNumber', False);
  R.AttributeValue := LoadString(Node, 'AttributeValue', False);
  if (R.IdentifierFOIV = '') and (R.DocumentNumber = '') and (R.AttributeValue = '') then
    R.Enabled := False;
end;

class procedure TPositionsXmlReader.Load(ANode: IXMLNode; var R: TFractionalQuantity);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('FractionalQuantity');
  if Node = nil then
    Exit;

  R.Enabled := True;
  R.Numerator := LoadInteger(Node, 'Numerator', False);
  R.Denominator := LoadInteger(Node, 'Denominator', False);
end;

class procedure TPositionsXmlReader.Load(ANode: IXMLNode; var R: TGoodCodeData);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('GoodCodeData');
  if Node = nil then
    Exit;

  R.Enabled := True;
  R.NotIdentified := DecodeBase64(LoadString(Node, 'NotIdentified', False));
  R.EAN8 := DecodeBase64(LoadString(Node, 'EAN8', False));
  R.EAN13 := DecodeBase64(LoadString(Node, 'EAN13', False));
  R.ITF14 := DecodeBase64(LoadString(Node, 'ITF14', False));
  R.GS1_0 := DecodeBase64(LoadString(Node, 'GS1.0', False));
  R.GS1_M := DecodeBase64(LoadString(Node, 'GS1.M', False));
  R.KMK := DecodeBase64(LoadString(Node, 'KMK', False));
  R.MI := LoadString(Node, 'MI', False);
  R.EGAIS20 := DecodeBase64(LoadString(Node, 'EGAIS20', False));
  R.EGAIS30 := DecodeBase64(LoadString(Node, 'EGAIS30', False));
  R.F1 := DecodeBase64(LoadString(Node, 'F1', False));
  R.F2 := DecodeBase64(LoadString(Node, 'F2', False));
  R.F3 := DecodeBase64(LoadString(Node, 'F3', False));
  R.F4 := DecodeBase64(LoadString(Node, 'F4', False));
  R.F5 := DecodeBase64(LoadString(Node, 'F5', False));
  R.F6 := DecodeBase64(LoadString(Node, 'F6', False));
  R.GTIN := DecodeBase64(LoadString(Node, 'GTIN', False));
end;

class procedure TPositionsXmlReader.Load(const XmlText: WideString; var R: TRequestKM);
var
  Node: IXMLNode;
  Xml: IXMLDocument;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXML(XmlText);
    Node := Xml.ChildNodes.FindNode('RequestKM');
    if Node = nil then
      raise Exception.Create('Wrong XML RequestKM Table');

    R.GUID := LoadString(Node, 'GUID', False);
    R.WaitForResult := LoadBool(Node, 'WaitForResult', False);
    R.MarkingCode := DecodeBase64(LoadString(Node, 'MarkingCode', True));
    R.PlannedStatus := LoadInteger(Node, 'PlannedStatus', True);
    R.HasQuantity := HasAttribute(Node, 'Quantity');
    R.Quantity := LoadDouble(Node, 'Quantity', False);
    R.HasQuantity := HasAttribute(Node, 'MeasureOfQuantity');
    R.HasMeasureOfQuantity := HasAttribute(Node, 'MeasureOfQuantity');
    R.MeasureOfQuantity := LoadInteger(Node, 'MeasureOfQuantity', False);
    R.NotSendToServer := LoadBool(Node, 'NotSendToServer', False);
    R.FractionalQuantity := False;
    Node := Node.ChildNodes.FindNode('FractionalQuantity');
    if Node <> nil then
    begin
      R.FractionalQuantity := True;
      R.Numerator := LoadInteger(Node, 'Numerator', False);
      R.Denominator := LoadInteger(Node, 'Denominator', False);
    end;
  finally
    Xml := nil;
  end;
end;

class procedure TPositionsXmlReader.Load(ANode: IXMLNode; var R: TPayments);
begin
  R.Cash := LoadDecimal(ANode, 'Cash', False);
  R.ElectronicPayment := LoadDecimal(ANode, 'ElectronicPayment', True);
  R.PrePayment := LoadDecimal(ANode, 'PrePayment', True);
  R.PostPayment := LoadDecimal(ANode, 'PostPayment', True);
  R.Barter := LoadDecimal(ANode, 'Barter', True);
end;

(*

function RequestKMToXML(const AGUID: string; const AWaitForResult: Boolean; const AMarkingCode: AnsiString; const APlannedStatus: Integer; const AQuantity: Double; const AMeasureOfQuantity: string; const AFractionalQuantity: Boolean; const ANumerator: Integer; const ADenominator: Integer): string;
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

    Node.Attributes['GUID'] := AGUID;
    Node.Attributes['WaitForResult'] := To1Cbool(AWaitForResult);
    Node.Attributes['MarkingCode'] := AMarkingCode;
    Node.Attributes['PlannedStatus'] := APlannedStatus.ToString;
    Node.Attributes['Quantity'] := QuantityToStr(AQuantity);
    if AMeasureOfQuantity <> '' then
      Node.Attributes['MeasureOfQuantity'] := AMeasureOfQuantity;
    if AFractionalQuantity then
    begin
      Node := Node.AddChild('FractionalQuantity');
      Node.Attributes['Numerator'] := ANumerator.ToString;
      Node.Attributes['Denominator'] := ADenominator.ToString;
    end;
    Result := Xml.XML.Text;
  finally
    Xml := nil;
  end;
end;

function RequestKMResultToXML(const AChecking: Boolean; const ACheckingResult: Boolean): string;
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
    Node := Xml.AddChild('RequestKMResult');
    Node.Attributes['Checking'] := To1Cbool(AChecking);
    Node.Attributes['CheckingResult'] := To1Cbool(ACheckingResult);
    Result := Xml.XML.Text;
  finally
    Xml := nil;
  end;
end;

function ProcessingKMResultToXML(const AGUID: string; const AResult: Boolean; const AResultCode: Integer; const AHasStatusInfo: Boolean; const AStatusInfo: Integer; const AHandleCode: Integer): string;
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
    Node := Xml.AddChild('ProcessingKMResult');
    Node.Attributes['GUID'] := AGUID;
    Node.Attributes['Result'] := To1Cbool(AResult);
    Node.Attributes['ResultCode'] := AResultCode.ToString;
    if AHasStatusInfo then
      Node.Attributes['StatusInfo'] := AStatusInfo.ToString;
    Node.Attributes['HandleCode'] := AHandleCode.ToString;
    Result := Xml.XML.Text;
  finally
    Xml := nil;
  end;
end;

{ TRequestKM }

*)



end.


