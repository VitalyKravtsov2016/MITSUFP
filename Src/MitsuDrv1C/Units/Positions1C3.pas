unit Positions1C3;

interface

uses
  // VCL
  SysUtils, Classes, XMLDoc, XMLIntf, DateUtils,
  //NetEncoding,
  // This
  XmlUtils, stringutils, LogFile, GS1Util, Optional, BinUtils;

type
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
    //procedure Load(AValue: WideString);
  end;

  TPayments = record
    Cash: Currency;
    ElectronicPayment: Currency;
    PrePayment: Currency;
    PostPayment: Currency;
    Barter: Currency;
    //procedure Load(ANode: IXMLNode);
  end;

  TCorrectionData = record
    Enabled: Boolean;
    AType: Integer;  // Тип коррекции 0 - самостоятельно 1 - по предписанию
    Description: WideString; // Описание коррекции
    Date: TDateTime; // Дата совершения корректируемого расчета
    Number: WideString; // Номер предписания налогового органа
    //procedure Load(ANode: IXMLNode);
  end;

  TAgentData = record
    Enabled: Boolean;
    AgentOperation: WideString; // 	Операция платежного агента 1044
    AgentPhone: WideString; //Телефон платежного агента 1073
    PaymentProcessorPhone: WideString; //Телефон оператора по приему платежей 1074
    AcquirerOperatorPhone: WideString; //	Телефон оператора перевода 1075
    AcquirerOperatorName: WideString; // 	Наименование оператора перевода 1026
    AcquirerOperatorAddress: WideString; //	Адрес оператора перевода 1005
    AcquirerOperatorINN: WideString; //	ИНН оператора перевода 1016
    //procedure Load(ANode: IXMLNode);
  end;

  TVendorData = record
    Enabled: Boolean;
    VendorPhone: WideString; //	Телефон поставщика 1171
    VendorName: WideString; //Наименование поставщика 1225
    VendorINN: WideString; //ИНН поставщика 1226
    //procedure Load(ANode: IXMLNode);
  end;

  TUserAttribute = record
    Enabled: Boolean;
    Name: string;
    Value: string;
    //procedure Load(ANode: IXMLNode);
  end;

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
    //procedure Load(const ANode: IXMLNode);
  end;

  TOperationalAttribute = record
    Enabled: Boolean;
    DateTime: TDateTime;  // Дата, время операции
    OperationID: Integer;  // Идентификатор операции
    OperationData: string;  // Данные операции
    //procedure Load(const ANode: IXMLNode);
  end;

  TIndustryAttribute = record
    Enabled: Boolean;
    IdentifierFOIV: string; // Идентификатор ФОИВ
    DocumentDate: string;   // Дата документа основания в формате "DD.MM.YYYY"
    DocumentNumber: string;  // Номер документа основания
    AttributeValue: string; // Значение отраслевого реквизита
    //procedure Load(const ANode: IXMLNode);
  end;

  TFractionalQuantity = record
    Enabled: Boolean;
    Numerator: Integer;
    Denominator: Integer;
    //procedure Load(const ANode: IXMLNode);
  end;

  TItemCodeData = record
    MarkingType: Integer;
    GTIN: AnsiString;
    SerialNumber: AnsiString;
    Barcode: AnsiString;
  end;

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
    //procedure Load(const ANode: IXMLNode);
    //procedure GetItemCodeData;
  end;

  TPosition1C3 = class;

  { TPositions1C }

  TPositions1C3 = class
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
    function TaxToInt(const ATax: WideString): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TPosition1C3;
    procedure ReadFromXML(AXML: WideString; ANonFiscal: Boolean);
    procedure LoadParameters(ANode: IXMLNode);
    procedure LoadPositions(ANode: IXMLNode; ANonFiscal: Boolean);
    procedure LoadFiscalString32(ANode: IXMLNode);
    procedure LoadNonFiscalString32(ANode: IXMLNode);
    function TotalTaxSum: Currency;
    procedure LoadBarcode32(ANode: IXMLNode);

    procedure Clear;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPosition1C3 read GetItem; default;
    property SenderEmail: WideString read FSenderEmail;
    property Payments: TPayments read FPayments;
    property CustomerEmail: WideString read FCustomerEmail;
    property CustomerPhone: WideString read FCustomerPhone;
    property AgentPhone: WideString read FAgentPhone;
    property TaxVariant: Integer read FTaxationSystem;
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
    FOwner: TPositions1C3;
    procedure SetOwner(AOwner: TPositions1C3);
  public
    constructor Create(AOwner: TPositions1C3);
    destructor Destroy; override;
  end;

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

//function RequestKMToXML(const AGUID: string; const AWaitForResult: Boolean; const AMarkingCode: AnsiString; const APlannedStatus: Integer; const AQuantity: Double; const AMeasureOfQuantity: string; const AFractionalQuantity: Boolean; const ANumerator: Integer; const ADenominator: Integer): string;
//function RequestKMResultToXML(const AChecking: Boolean; const ACheckingResult: Boolean): string;
//function ProcessingKMResultToXML(const AGUID: string; const AResult: Boolean; const AResultCode: Integer; const AHasStatusInfo: Boolean; const AStatusInfo: Integer; const AHandleCode: Integer): string;

implementation

uses
  Variants;



{ TPositions1C }

constructor TPositions1C3.Create;
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

destructor TPositions1C3.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TPositions1C3.Clear;
begin
  while Count > 0 do
    Items[0].Free;
end;

function TPositions1C3.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPositions1C3.GetItem(Index: Integer): TPosition1C3;
begin
  Result := FList[Index];
end;

procedure TPositions1C3.InsertItem(AItem: TPosition1C3);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TPositions1C3.RemoveItem(AItem: TPosition1C3);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TPositions1C3.Add: TPosition1C3;
begin
  Result := TPosition1C3.Create(Self);
end;

procedure TPositions1C3.ReadFromXML(AXML: WideString; ANonFiscal: Boolean);
var
  Xml: IXMLDocument;
  Node: IXMLNode;
  i: Integer;
  Doc: IXMLNode;
begin
  Logger.Debug('TPositions1C3.ReadFromXML');
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
        //FPayments.Load(Node); !!
        Continue;
      end;
    end;
  finally
    Xml := nil;
  end;
end;


(*

<Parameters PaymentType="1" TaxVariant="0" CashierName="Казакова Н.А." SenderEmail="info@1c.ru" CustomerEmail="" CustomerPhone="" AgentSign="2" AddressSettle="г.Москва, Дмитровское ш. д.9">
		<AgentData PayingAgentOperation="operation" PayingAgentPhone="tel" ReceivePaymentsOperatorPhone="tel" MoneyTransferOperatorPhone="tel" MoneyTransferOperatorName="name" MoneyTransferOperatorAddress="addr"/>
		<PurveyorData PurveyorPhone="12343332" PurveyorName="123fffff" PurveyorVATIN="123456789"/>
	</Parameters>
*)

procedure TPositions1C3.LoadParameters(ANode: IXMLNode);
var
  Node: IXMLNode;
begin
  FCashierName := LoadString(ANode, 'CashierName', False);
  FCashierINN := LoadString(ANode, 'CashierINN', False);
  FOperationType := LoadInteger(ANode, 'OperationType', True);
  FTaxationSystem := LoadInteger(ANode, 'TaxationSystem', True);
  FCustomerInfo := LoadString(ANode, 'CustomerInfo', False);
  FCustomerINN := LoadString(ANode, 'CustomerINN', False);
  FCustomerEmail := LoadString(ANode, 'CustomerEmail', False);
  FCustomerPhone := LoadString(ANode, 'CustomerPhone', False);
  FSenderEmail := LoadString(ANode, 'SenderEmail', False);
  FSaleAddress := LoadString(ANode, 'SaleAddress', False);
  FSaleLocation := LoadString(ANode, 'SaleLocation', False);
  FAgentType := LoadString(ANode, 'AgentType', False);
  FAdditionalAttribute := LoadString(ANode, 'AdditionalAttribute', False);
  //FCorrectionData.Load(ANode); !!
  //FAgentData.Load(ANode);
  //FVendorData.Load(ANode);
  //FUserAttribute.Load(ANode);

  // 34
  //FCustomerDetail.Load(ANode);
  //FOperationalAttribute.Load(ANode);
  //FIndustryAttribute.Load(ANode);
  //FAutomatNumber := LoadString(ANode, 'AutomatNumber', False);
end;

procedure TPositions1C3.LoadPositions(ANode: IXMLNode; ANonFiscal: Boolean);
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
var
  Data: TBytes;
begin
  if AData = '' then
  begin
    Result := '';
    Exit;
  end;
  // Data := TNetEncoding.Base64.DecodeStringToBytes(AData); !!!
  SetString(Result, PAnsiChar(Data), Length(Data));
end;

procedure TPositions1C3.LoadBarcode32(ANode: IXMLNode);
var
  Item: TBarcode32;
begin
  Item := TBarcode32.Create(Self);
  Item.FBarcodeType := LoadString(ANode, 'Type', True);
  if HasAttribute(ANode, 'Value') then
    Item.FBarcode := LoadString(ANode, 'Value', True);
  if HasAttribute(ANode, 'ValueBase64') then
    Item.FBarcode := DecodeBase64(LoadString(ANode, 'ValueBase64', True));
  Logger.Debug('FBARCODE ' + Item.FBarcode);
end;

procedure TPositions1C3.LoadNonFiscalString32(ANode: IXMLNode);
begin
  TNonFiscalString32.Create(Self).FText := LoadString(ANode, 'Text', True);
end;

procedure TPositions1C3.LoadFiscalString32(ANode: IXMLNode);
var
  Item: TFiscalString32;
  T: WideString;
  Node: IXMLNode;
begin
  Item := TFiscalString32.Create(Self);
  Item.FName := LoadString(ANode, 'Name', True);
  if ItemNameLength > 0 then
    Item.FName := Copy(Item.FName, 1, ItemNameLength);

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

(*
  Item.FIndustryAttribute.Load(ANode); !!
  Item.FMeasureOfQuantity := LoadInteger(ANode, 'MeasureOfQuantity', False);
  Item.FFractionalQuantity.Load(ANode);
  Item.FGoodCodeData.Load(ANode);
  Item.FMarkingCode := DecodeBase64(LoadString(ANode, 'MarkingCode', False));
  Item.FIndustryAttribute.Load(ANode);

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

      if (Item.FAgentData.AgentOperation = '') and (Item.FAgentData.AgentPhone = '') and (Item.FAgentData.PaymentProcessorPhone = '') and (Item.FAgentData.AcquirerOperatorPhone = '') and (Item.FAgentData.AcquirerOperatorName = '') and (Item.FAgentData.AcquirerOperatorAddress = '') and (Item.FAgentData.AcquirerOperatorINN = '') then
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
*)
  Logger.Debug('LoadFiscalString32.4');
end;

function TPositions1C3.TaxToInt(const ATax: WideString): Integer;
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

function TPositions1C3.TotalTaxSum: Currency;
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

constructor TPosition1C3.Create(AOwner: TPositions1C3);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TPosition1C3.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TPosition1C3.SetOwner(AOwner: TPositions1C3);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then
      FOwner.RemoveItem(Self);
    if AOwner <> nil then
      AOwner.InsertItem(Self);
  end;
end;


(*
{ TCustomerDetail }

procedure TCustomerDetail.Load(const ANode: IXMLNode);
var
  Node: IXMLNode;
begin
  Enabled := False;
  Node := ANode.ChildNodes.FindNode('CustomerDetail');
  if Node = nil then
    Exit;

  Enabled := HasAttribute(Node, 'Info') or HasAttribute(Node, 'INN') or HasAttribute(Node, 'DateOfBirth') or HasAttribute(Node, 'Citizenship') or HasAttribute(Node, 'DocumentTypeCode') or HasAttribute(Node, 'DocumentData') or HasAttribute(Node, 'Address');
  if not Enabled then
    Exit;
  Info := LoadString(Node, 'Info', False);
  INN := LoadString(Node, 'INN', False);
  DateOfBirthEnabled := HasAttribute(Node, 'DateOfBirth');
  if DateOfBirthEnabled then
    DateOfBirth := LoadDateTime(Node, 'DateOfBirth', False);
  Citizenship := LoadString(Node, 'Citizenship', False);
  DocumentTypeCodeEnabled := HasAttribute(Node, 'DocumentTypeCode');
  if DocumentTypeCodeEnabled then
    DocumentTypeCode := LoadInteger(Node, 'DocumentTypeCode', False);
  DocumentData := LoadString(Node, 'DocumentData', False);
  Address := LoadString(Node, 'Address', False);
end;

{ TOperationalAttribute }

procedure TOperationalAttribute.Load(const ANode: IXMLNode);
var
  Node: IXMLNode;
begin
  Enabled := False;
  Node := ANode.ChildNodes.FindNode('OperationalAttribute');
  if Node = nil then
    Exit;
  Enabled := HasAttribute(Node, 'DateTime') or HasAttribute(Node, 'OperationID') or HasAttribute(Node, 'OperationData');
  if not Enabled then
    Exit;
  DateTime := LoadDateTime(Node, 'DateTime', False);
  OperationID := LoadInteger(Node, 'OperationID', False);
  OperationData := LoadString(Node, 'OperationData', False);
end;

{ TIndustryAttribute }

procedure TIndustryAttribute.Load(const ANode: IXMLNode);
var
  Node: IXMLNode;
begin
  Enabled := False;
  Node := ANode.ChildNodes.FindNode('IndustryAttribute');
  if Node = nil then
    Exit;
  Enabled := HasAttribute(Node, 'IdentifierFOIV') or HasAttribute(Node, 'DocumentDate') or HasAttribute(Node, 'DocumentNumber') or HasAttribute(Node, 'AttributeValue');
  if not Enabled then
    Exit;

  IdentifierFOIV := LoadString(Node, 'IdentifierFOIV', False);
  DocumentDate := LoadString(Node, 'DocumentDate', False); //LoadDateTime(Node, 'DocumentDate', False);
  DocumentNumber := LoadString(Node, 'DocumentNumber', False);
  AttributeValue := LoadString(Node, 'AttributeValue', False);

  if (IdentifierFOIV = '') and (DocumentNumber = '') and (AttributeValue = '') then
    Enabled := False;
end;

{ TUserAttribute }

procedure TUserAttribute.Load(ANode: IXMLNode);
var
  Node: IXMLNode;
begin
  Enabled := False;
  Node := ANode.ChildNodes.FindNode('UserAttribute');
  if Node = nil then
    Exit;
  Enabled := True;
  Name := LoadString(Node, 'Name', True);
  Value := LoadString(Node, 'Value', True);
  if (Name = '') and (Value = '') then
    Enabled := False;
end;

{ TVendorData }

procedure TVendorData.Load(ANode: IXMLNode);
var
  Node: IXMLNode;
begin
  Enabled := False;
  Node := ANode.ChildNodes.FindNode('VendorData');
  if Node = nil then
    Exit;
  Enabled := True;

  VendorPhone := LoadString(Node, 'VendorPhone', False);
  VendorName := LoadString(Node, 'VendorName', False);
  VendorINN := LoadString(Node, 'VendorINN', False);
  if (VendorPhone = '') and (VendorName = '') and (VendorINN = '') then
    Enabled := False;
end;


{ TAgentData }

procedure TAgentData.Load(ANode: IXMLNode);
var
  Node: IXMLNode;
begin
  Enabled := False;
  Node := ANode.ChildNodes.FindNode('AgentData');
  if Node = nil then
    Exit;
  Enabled := True;

  AgentOperation := LoadString(Node, 'AgentOperation', False);
  AgentPhone := LoadString(Node, 'AgentPhone', False);
  PaymentProcessorPhone := LoadString(Node, 'PaymentProcessorPhone', False);
  AcquirerOperatorPhone := LoadString(Node, 'AcquirerOperatorPhone', False);
  AcquirerOperatorName := LoadString(Node, 'AcquirerOperatorName', False);
  AcquirerOperatorAddress := LoadString(Node, 'AcquirerOperatorAddress', False);
  AcquirerOperatorINN := LoadString(Node, 'AcquirerOperatorINN', False);
  if (AgentOperation = '') and (AgentPhone = '') and (PaymentProcessorPhone = '') and (AcquirerOperatorPhone = '') and (AcquirerOperatorName = '') and (AcquirerOperatorAddress = '') and (AcquirerOperatorINN = '') then
    Enabled := False;
end;

{ TCorrectionData }

procedure TCorrectionData.Load(ANode: IXMLNode);
var
  Node: IXMLNode;
begin
  Enabled := False;
  Node := ANode.ChildNodes.FindNode('CorrectionData');
  if Node = nil then
    Exit;
  Enabled := True;

  AType := LoadInteger(Node, 'Type', False);
  Description := LoadString(Node, 'Description', False);
  Date := LoadDateTime(Node, 'Date', False);
  Number := LoadString(Node, 'Number', False);
end;

{ TPayments }

procedure TPayments.Load(ANode: IXMLNode);
begin
  GlobalLogger.Debug('LoadPayments');
  Cash := LoadDecimal(ANode, 'Cash', False);
  GlobalLogger.Debug(Format('Cash %.2f', [Cash]));
  ElectronicPayment := LoadDecimal(ANode, 'ElectronicPayment', True);
  GlobalLogger.Debug(Format('ElectronicPayment %.2f', [ElectronicPayment]));
  PrePayment := LoadDecimal(ANode, 'PrePayment', True);
  PostPayment := LoadDecimal(ANode, 'PostPayment', True);
  Barter := LoadDecimal(ANode, 'Barter', True);
end;





(*

Driver.FNOperation;
Driver.MarkingType := $4508; //EAN-8
Driver.BarCode := '46198488';
Driver.FNSendItemCodeData;
//...
Driver.FNOperation;
Driver.MarkingType := $450D; //EAN-13
Driver.BarCode := '4606203090785';
Driver.FNSendItemCodeData;
//...
Driver.FNOperation;
Driver.MarkingType := $490E; //ITF-14
Driver.BarCode := '14601234567890';
Driver.FNSendItemCodeData;
//...
Driver.FNOperation;
Driver.MarkingType := $444D; //Data Matrix
Driver.GTIN := '04600439931256';
Driver.SerialNumber := 'JgXJ5.T112000';
Driver.FNSendItemCodeData;
//...
Driver.FNOperation;
Driver.MarkingType := $444D; //Data Matrix 2
Driver.GTIN := '04604060006000';
Driver.SerialNumber := 'N4N57RSCBUZTQ';
Driver.FNSendItemCodeData;
//...
Driver.FNOperation;
Driver.MarkingType := $444D; //Data Matrix 3
Driver.GTIN := '00000046198488';
Driver.SerialNumber := 'X?io+qCABm8 '; // два пробела в конце (до 13 симв.)
Driver.FNSendItemCodeData;
//...
Driver.FNOperation;
Driver.MarkingType := $5246; //Мех
Driver.BarCode := 'RU-401301-AAA0277031';
Driver.FNSendItemCodeData;
//...
Driver.FNOperation;
Driver.MarkingType := $C514; //ЕГАИС 2.0
Driver.BarCode := 'NU5DBKYDOT17ID980726019';
Driver.FNSendItemCodeData;
//...
Driver.FNOperation;
Driver.MarkingType := $C51E; //ЕГАИС 3.0
Driver.BarCode := '13622200005881;
Driver.FNSendItemCodeData;

*)

(*
{ TGoodCodeData }

procedure TGoodCodeData.GetItemCodeData;
begin
  ItemCodeData.MarkingType := -1;
  ItemCodeData.GTIN := '';
  ItemCodeData.SerialNumber := '';
  ItemCodeData.Barcode := '';

  if EAN8 <> '' then
  begin
    ItemCodeData.MarkingType := $4508;
    ItemCodeData.Barcode := EAN8;
    Exit;
  end;

  if EAN13 <> '' then
  begin
    ItemCodeData.MarkingType := $450D;
    ItemCodeData.Barcode := EAN13;
    Exit;
  end;

  if ITF14 <> '' then
  begin
    ItemCodeData.MarkingType := $490E;
    ItemCodeData.Barcode := ITF14;
    Exit;
  end;

  if GS1_M <> '' then
  begin
    ItemCodeData.MarkingType := $444D;
    DecodeGS1_full(GS1_M, ItemCodeData.GTIN, ItemCodeData.SerialNumber);
    AddFinalSpaces(ItemCodeData.SerialNumber, 13);
    Exit;
  end;

  if MI <> '' then
  begin
    ItemCodeData.MarkingType := $5246;
    ItemCodeData.Barcode := MI;
    Exit;
  end;

  if EGAIS20 <> '' then
  begin
    ItemCodeData.MarkingType := $C514;
    ItemCodeData.Barcode := EGAIS20;
    Exit;
  end;

  if EGAIS30 <> '' then
  begin
    ItemCodeData.MarkingType := $C51E;
    ItemCodeData.Barcode := EGAIS30;
    Exit;
  end;

  if KMK <> '' then
  begin
    ItemCodeData.MarkingType := 0;
    ItemCodeData.Barcode := KMK;
    Exit;
  end;

  if NotIdentified <> '' then
  begin
    ItemCodeData.MarkingType := 0;
    ItemCodeData.Barcode := NotIdentified;
    Exit;
  end;
end;

procedure TGoodCodeData.Load(const ANode: IXMLNode);
var
  Node: IXMLNode;
begin
  Enabled := False;
  Node := ANode.ChildNodes.FindNode('GoodCodeData');
  if Node = nil then
    Exit;
  Enabled := True;

  NotIdentified := DecodeBase64(LoadString(Node, 'NotIdentified', False));
  EAN8 := DecodeBase64(LoadString(Node, 'EAN8', False));
  EAN13 := DecodeBase64(LoadString(Node, 'EAN13', False));
  ITF14 := DecodeBase64(LoadString(Node, 'ITF14', False));
  GS1_0 := DecodeBase64(LoadString(Node, 'GS1.0', False));
  GS1_M := DecodeBase64(LoadString(Node, 'GS1.M', False));
  KMK := DecodeBase64(LoadString(Node, 'KMK', False));
  MI := LoadString(Node, 'MI', False);
  EGAIS20 := DecodeBase64(LoadString(Node, 'EGAIS20', False));
  EGAIS30 := DecodeBase64(LoadString(Node, 'EGAIS30', False));
  F1 := DecodeBase64(LoadString(Node, 'F1', False));
  F2 := DecodeBase64(LoadString(Node, 'F2', False));
  F3 := DecodeBase64(LoadString(Node, 'F3', False));
  F4 := DecodeBase64(LoadString(Node, 'F4', False));
  F5 := DecodeBase64(LoadString(Node, 'F5', False));
  F6 := DecodeBase64(LoadString(Node, 'F6', False));
  GTIN := DecodeBase64(LoadString(Node, 'GTIN', False));
end;

{ TFractionalQuantity }

procedure TFractionalQuantity.Load(const ANode: IXMLNode);
var
  Node: IXMLNode;
begin
  Enabled := False;
  Node := ANode.ChildNodes.FindNode('FractionalQuantity');
  if Node = nil then
    Exit;
  Enabled := True;

  Numerator := LoadInteger(Node, 'Numerator', False);
  Denominator := LoadInteger(Node, 'Denominator', False);
end;

function To1Cbool(AValue: Boolean): WideString;
begin
  if AValue then
    Result := 'true'
  else
    Result := 'false';
end;

function QuantityToStr(AValue: Double): string;
var
  saveSeparator: Char;
begin
  saveSeparator := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    Result := System.SysUtils.Format('%.*f', [6, AValue]);
  finally
    FormatSettings.DecimalSeparator := saveSeparator;
  end;
end;

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

procedure TRequestKM.Load(AValue: WideString);
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
    Node := Xml.ChildNodes.FindNode('RequestKM');
    if Node = nil then
      raise Exception.Create('Wrong XML RequestKM Table');
    GUID := LoadString(Node, 'GUID', False);
    WaitForResult := LoadBool(Node, 'WaitForResult', False);
    MarkingCode := DecodeBase64(LoadString(Node, 'MarkingCode', True));
    PlannedStatus := LoadInteger(Node, 'PlannedStatus', True);
    HasQuantity := HasAttribute(Node, 'Quantity');
    Quantity := LoadDouble(Node, 'Quantity', False);
    HasQuantity := HasAttribute(Node, 'MeasureOfQuantity');
    HasMeasureOfQuantity := HasAttribute(Node, 'MeasureOfQuantity');
    MeasureOfQuantity := LoadInteger(Node, 'MeasureOfQuantity', False);
    NotSendToServer := LoadBool(Node, 'NotSendToServer', False);
    FractionalQuantity := False;
    Node := Node.ChildNodes.FindNode('FractionalQuantity');
    if Node <> nil then
    begin
      FractionalQuantity := True;
      Numerator := LoadInteger(Node, 'Numerator', False);
      Denominator := LoadInteger(Node, 'Denominator', False);
    end;
  finally
    Xml := nil;
  end;
end;
*)

end.


