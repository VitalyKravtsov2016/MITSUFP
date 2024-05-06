unit Positions1C;

interface

Uses
  // VCL
  SysUtils, Classes, XMLDoc, XMLIntf, DateUtils,
  //This
  XmlUtils, stringutils, LogFile;

type

  TAgentData = record
    Enabled: Boolean;
    PayingAgentOperation: WideString ; // 	Операция платежного агента 1044
    PayingAgentPhone: WideString ; //Телефон платежного агента 1073
    ReceivePaymentsOperatorPhone: WideString ; //Телефон оператора по приему платежей 1074
    MoneyTransferOperatorPhone: WideString ; //	Телефон оператора перевода 1075
    MoneyTransferOperatorName: WideString ; // 	Наименование оператора перевода 1026
    MoneyTransferOperatorAddress: WideString ; //	Адрес оператора перевода 1005
    MoneyTransferOperatorVATIN: WideString ; //	ИНН оператора перевода 1016
  end;

  TPurveyorData = record
    Enabled: Boolean;
    PurveyorPhone: WideString ; //	Телефон поставщика 1171
    PurveyorName: WideString ; //Наименование поставщика 1225
    PurveyorVATIN: WideString ; //ИНН поставщика 1226
  end;

  TUserAttribute = record
    Enabled: Boolean;
    Name: string;
    Value: string;
  end;

  TItemCodeData = record
    StampType: WideString;
    Stamp: WideString;
    SerialNumber: WideString;
    GTIN: WideString;
    MarkingCode: string;
    State: Integer;
  end;

  TCheckCorrectionParamsRec22 = record
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
  end;


  TPosition1C = class;

  { TPositions1C }

  TPositions1C = class
  private
    FID: string;
    FBPOVersion: Integer;
    FList: TList;
    FPayment1: Currency;
    FCash: Currency;
    FPayment3: Currency;
    FPayment2: Currency;
    FPaymentType: Integer;
    FSenderEmail: WideString;
    FCustomerEmail: WideString;
    FCustomerPhone: WideString;
    FCustomerInfo: WideString;
    FCustomerINN: WideString;
    //FAgentCompensation: Double;
    FAgentData: TAgentData;
    FPurveyorData: TPurveyorData;
    FUserAttribute: TUserAttribute;
    FAgentPhone: WideString;
    FCashierVATIN: WideString;
    FAdditionalAttribute: WideString;
    FCashierName: WideString;
    FTaxVariant: Integer;
    FFFDVersion: Integer;
    FCashProvision: Currency;
    FAdvancePayment: Currency;
    FElectronicPayment: Currency;
    FCredit: Currency;
    FItemNameLength: Integer;
    FAgentSign: WideString;
    function GetCount: Integer;
    function GetItem(Index: Integer): TPosition1C;
    procedure InsertItem(AItem: TPosition1C);
    procedure RemoveItem(AItem: TPosition1C);
    function TaxToInt(const ATax: WideString): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TPosition1C;
    procedure ReadFromXML(AXML: WideString; ANonFiscal: Boolean);
    procedure LoadParameters(ANode: IXMLNode);
    procedure LoadPositions(ANode: IXMLNode; ANonFiscal: Boolean);
    procedure LoadPayments(ANode: IXMLNode);
    procedure LoadFiscalString(ANode: IXMLNode);
    procedure LoadFiscalString22(ANode: IXMLNode);
    procedure LoadNonFiscalString(ANode: IXMLNode);

    procedure LoadBarcode(ANode: IXMLNode);

    procedure Clear;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPosition1C read GetItem; default;
    property PaymentType: Integer read FPaymentType;
    property SenderEmail: WideString read FSenderEmail;
    property Cash: Currency read FCash;
    property Payment1: Currency read FPayment1;
    property Payment2: Currency read FPayment2;
    property Payment3: Currency read FPayment3;
    property CustomerEmail: WideString read FCustomerEmail;
    property CustomerPhone: WideString read FCustomerPhone;
    property AgentPhone: WideString read FAgentPhone;
    property TaxVariant: Integer read FTaxVariant;
    property CashierVATIN: Widestring read FCashierVATIN;
    property CashierName: Widestring read FCashierName;
    property AgentData: TAgentData read FAgentData;
    property PurveyorData: TPurveyorData read FPurveyorData;
    property FFDversion: Integer read FFFDVersion write FFFDVersion;
    property BPOVersion: Integer read FBPOVersion write FBPOVersion;
    property ItemNameLength: Integer read FItemNameLength write FItemNameLength;
    property AdditionalAttribute: WideString read FAdditionalAttribute write FAdditionalAttribute;
    property ElectronicPayment: Currency read FElectronicPayment;
    property AdvancePayment: Currency read FAdvancePayment;
    property Credit: Currency read FCredit;
    property CashProvision: Currency read FCashProvision;
    property AgentSign: Widestring read FAgentSign write FAgentSign;
    property Id: string read FId write FId;
    property UserAttribute: TUserAttribute read FUserAttribute write FUserAttribute;
    property CustomerInfo: WideString read FCustomerInfo write FCustomerInfo;
    property CustomerINN: WideString read FCustomerINN write FCustomerINN;
  end;

  { TPosition1C }

  TPosition1C = class
  private
    FOwner: TPositions1C;
    procedure SetOwner(AOwner: TPositions1C);
  public
    constructor Create(AOwner: TPositions1C);
    destructor Destroy; override;
  end;

  TFiscalString = class(TPosition1C)
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

  TFiscalString22 = class(TPosition1C)
  private
    FName: WideString;
    FQuantity: Double;
    FPriceWithDiscount: Double;
    FSumWithDiscount: Double;
    FDiscountSum: Double;
    FDepartment: Integer;
    FTax: Integer;
    FSignMethodCalculation: Integer;
    FSignCalculationObject: Integer;
    FItemCodeData: TItemCodeData;
    FAgentData: TAgentData;
    FPurveyorData: TPurveyorData;
    FAgentSign: WideString;
    FCountryOfOfigin: WideString;
    FCustomsDeclaration: WideString;
    FExciseAmount: WideString;
    FAdditionalAttribute: WideString;
    FMeasurementUnit: WideString;
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
    property ItemCodeData: TItemCodeData read FItemCodeData;
    property AgentData: TAgentData read FAgentData write FAgentData;
    property PurveyorData: TPurveyorData read FPurveyorData write FPurveyorData;
    property AgentSign: WideString read FAgentSign write FAgentSign;
    property CountryOfOfigin: WideString read FCountryOfOfigin write FCountryOfOfigin;
    property CustomsDeclaration: WideString read FCustomsDeclaration write FCustomsDeclaration;
    property ExciseAmount: WideString read FExciseAmount write FExciseAmount;
    property AdditionalAttribute: WideString read FAdditionalAttribute write FAdditionalAttribute;
    property MeasurementUnit: WideString read FMeasurementUnit write FMeasurementUnit;
  end;

  TNonFiscalString = class(TPosition1C)
  private
    FText: WideString;
  public
    property Text: WideString read FText;
  end;

  TBarcode = class(TPosition1C)
  private
    FBarcode: WideString;
    FBarcodeType: WideString;
  public
    property BarcodeType: WideString read FBarcodeType;
    property Barcode: WideString read FBarcode;
  end;


implementation

uses Variants;



{ TPositions1C }

constructor TPositions1C.Create;
var
  Guid: TGUID;
begin
  inherited Create;
  FList := TList.Create;
  FFFDVersion := 0;
  CreateGUID(Guid);
  FID := GUIDToString(Guid);
end;

destructor TPositions1C.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TPositions1C.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TPositions1C.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPositions1C.GetItem(Index: Integer): TPosition1C;
begin
  Result := FList[Index];
end;

procedure TPositions1C.InsertItem(AItem: TPosition1C);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TPositions1C.RemoveItem(AItem: TPosition1C);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TPositions1C.Add: TPosition1C;
begin
  Result := TPosition1C.Create(Self);
end;

procedure TPositions1C.ReadFromXML(AXML: WideString; ANonFiscal: Boolean);
var
  Xml: IXMLDocument;
  Node: IXMLNode;
  i: Integer;
  Doc: IXMLNode;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXML(AXML);
    if ANonFiscal then
      Doc := XML.ChildNodes.FindNode('Document')
    else
      Doc := XML.ChildNodes.FindNode('CheckPackage');
    if Doc = nil then Exit;
    for i := 0 to Doc.ChildNodes.Count - 1 do
    begin
      Node := Doc.ChildNodes.Nodes[i];
      if Node = nil then Continue;
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
         LoadPayments(Node);
         Continue;
      end;
    end;
  finally
    XML := nil;
  end;
end;


(*

<Parameters PaymentType="1" TaxVariant="0" CashierName="Казакова Н.А." SenderEmail="info@1c.ru" CustomerEmail="" CustomerPhone="" AgentSign="2" AddressSettle="г.Москва, Дмитровское ш. д.9">
		<AgentData PayingAgentOperation="operation" PayingAgentPhone="tel" ReceivePaymentsOperatorPhone="tel" MoneyTransferOperatorPhone="tel" MoneyTransferOperatorName="name" MoneyTransferOperatorAddress="addr"/>
		<PurveyorData PurveyorPhone="12343332" PurveyorName="123fffff" PurveyorVATIN="123456789"/>
	</Parameters>
*)

procedure TPositions1C.LoadParameters(ANode: IXMLNode);
var
  Node: IXMLNode;
begin
  FPaymentType := LoadInteger(ANode, 'PaymentType', True);
  FCustomerEmail := LoadString(ANode, 'CustomerEmail', False);
  FCustomerPhone := LoadString(ANode, 'CustomerPhone', False);
  FTaxVariant := LoadInteger(ANode, 'TaxVariant', True);
  FAgentPhone := LoadString(ANode, 'AgentPhone', False);
  FAgentSign := LoadString(ANode, 'AgentSign', False);
  FCustomerInfo := LoadString(ANode, 'CustomerInfo', False);
  FCustomerINN := LoadString(ANode, 'CustomerINN', False);
  if BPOVersion = 22 then
  begin
    FSenderEmail := LoadString(ANode, 'SenderEmail', False);
    FCashierName := LoadString(ANode, 'CashierName', True);
    FCashierVATIN := LoadString(ANode, 'CashierVATIN', False);
    FAdditionalAttribute := LoadString(ANode, 'AdditionalAttribute', False);
    FAgentData.Enabled := False;
    FPurveyorData.Enabled := False;
    Node := ANode.ChildNodes.FindNode('AgentData');
    if Node <> nil then
    begin
      FAgentData.Enabled := True;
      FAgentData.PayingAgentOperation := LoadString(Node, 'PayingAgentOperation', False);
      FAgentData.PayingAgentPhone := LoadString(Node, 'PayingAgentPhone', False);
      FAgentData.ReceivePaymentsOperatorPhone := LoadString(Node, 'ReceivePaymentsOperatorPhone', False);
      FAgentData.MoneyTransferOperatorPhone := LoadString(Node, 'MoneyTransferOperatorPhone', False);
      FAgentData.MoneyTransferOperatorName := LoadString(Node, 'MoneyTransferOperatorName', False);
      FAgentData.MoneyTransferOperatorAddress := LoadString(Node, 'MoneyTransferOperatorAddress', False);
      FAgentData.MoneyTransferOperatorVATIN := LoadString(Node, 'MoneyTransferOperatorVATIN', False);
    end;
    Node := ANode.ChildNodes.FindNode('PurveyorData');
    if Node <> nil then
    begin
      FPurveyorData.Enabled := True;
      FPurveyorData.PurveyorPhone := LoadString(Node, 'PurveyorPhone', False);
      FPurveyorData.PurveyorName := LoadString(Node, 'PurveyorName', False);
      FPurveyorData.PurveyorVATIN := LoadString(Node, 'PurveyorVATIN', False);
    end;
    FAgentData.Enabled := False;
    Node := ANode.ChildNodes.FindNode('UserAttribute');
    if Node <> nil then
    begin
      FUserAttribute.Enabled := True;
      FUserAttribute.Name := LoadString(Node, 'Name', True);
      FUserAttribute.Value := LoadString(Node, 'Value', True);
    end;
  end;
end;

procedure TPositions1C.LoadPositions(ANode: IXMLNode; ANonFiscal: Boolean);
var
  i: Integer;
  Node: IXMLNode;
begin
  for i := 0 to ANode.ChildNodes.Count - 1 do
  begin
    Node := ANode.ChildNodes.Nodes[i];
    if Node = nil then Continue;
    if not ANonFiscal then
      begin
      if Node.NodeName = 'FiscalString' then
      begin
         if BPOVersion = 22 then
           LoadFiscalString22(Node)
         else
           LoadFiscalString(Node);
         Continue;
      end;
    end;
    if Node.NodeName = 'TextString' then
    begin
       LoadNonFiscalString(Node);
       Continue;
    end;
    if Node.NodeName = 'Barcode' then
    begin
       LoadBarcode(Node);
       Continue;
    end;
  end;
end;

procedure TPositions1C.LoadPayments(ANode: IXMLNode);
begin
  FCash := LoadDecimal(ANode, 'Cash', False);
  if BPOVersion = 22 then
  begin
    FElectronicPayment := LoadDecimal(ANode, 'ElectronicPayment', True);
    FAdvancePayment := LoadDecimal(ANode, 'AdvancePayment', True);
    FCredit := LoadDecimal(ANode, 'Credit', True);
    FCashProvision := LoadDecimal(ANode, 'CashProvision', True);
  end
  else
  begin
    FPayment1 := LoadDecimal(ANode, 'CashLessType1', False);
    FPayment2 := LoadDecimal(ANode, 'CashLessType2', False);
    FPayment3 := LoadDecimal(ANode, 'CashLessType3', False);
  end;
end;

procedure TPositions1C.LoadBarcode(ANode: IXMLNode);
var
  Item: TBarcode;
begin
  Item := TBarcode.Create(Self);
  Item.FBarcodeType := LoadString(ANode, 'BarcodeType', True);
  Item.FBarcode := LoadString(ANode, 'Barcode', True);
end;

procedure TPositions1C.LoadFiscalString(ANode: IXMLNode);
var
  Item: TFiscalString;
  T: WideString;
begin
  Item := TFiscalString.Create(Self);
  Item.FName := LoadString(ANode, 'Name', True);
  if ItemNameLength > 0 then
    Item.FName := Copy(Item.FName, 1, ItemNameLength);

  Item.FBarcode := LoadString(ANode, 'Barcode', False);
  Item.FQuantity := LoadDouble(ANode, 'Quantity', True);
  Item.FPrice := LoadDouble(ANode, 'Price', True);
  Item.FAmount := LoadDouble(ANode, 'Amount', True);
  T := LoadString(ANode, 'Tax', True);
  if (T = '18') or (T = '20') then
    Item.FTax := 1
  else
    if T = '10' then
      Item.FTax := 2
    else
      if T = '0' then
        Item.FTax := 3
      else
        if T = 'none' then
          Item.FTax := 4
        else
          if (T = '18/118') or (T = '20/120') then
            Item.FTax := 5
          else
          if T = '10/110' then
            Item.FTax := 6
          else
            raise Exception.Create('Invalid Tax Value: ' + T);
  Item.FDepartment := LoadInteger(ANode, 'Department', False);
end;

procedure TPositions1C.LoadNonFiscalString(ANode: IXMLNode);
begin
  TNonFiscalString.Create(Self).FText := LoadString(ANode, 'Text', True);
end;

procedure TPositions1C.LoadFiscalString22(ANode: IXMLNode);
var
  Item: TFiscalString22;
  T: WideString;
  Node: IXMLNode;
begin
  Item := TFiscalString22.Create(Self);
  Item.FName := LoadString(ANode, 'Name', True);
  if ItemNameLength > 0 then
    Item.FName := Copy(Item.FName, 1, ItemNameLength);

  Item.FQuantity := LoadDouble(ANode, 'Quantity', True);
  Item.FPriceWithDiscount := LoadDouble(ANode, 'PriceWithDiscount', True);
  Item.FSumWithDiscount := LoadDouble(ANode, 'SumWithDiscount', True);
  if ANode.Attributes['DiscountSum'] = '' then
    Item.FDiscountSum := 0
  else
    Item.FDiscountSum := LoadDouble(ANode, 'DiscountSum', True);
  Item.FSignMethodCalculation := LoadIntegerDef(ANode, 'SignMethodCalculation', False, 4);
  Item.FSignCalculationObject := LoadIntegerDef(ANode, 'SignCalculationObject', False, 1);
  T := LoadString(ANode, 'Tax', True);
  Item.FTax := TaxToInt(T);
  Item.FDepartment := LoadIntegerDef(ANode, 'Department', False, 0);
  Item.AgentSign :=  LoadString(ANode, 'SignSubjectCalculationAgent', False);
  //2.5
  Item.ExciseAmount := LoadString(ANode, 'ExciseAmount', False);

  Item.FCountryOfOfigin := LoadString(ANode, 'CountryOfOrigin', False);
  Item.FCustomsDeclaration := LoadString(ANode, 'CustomsDeclaration', False);
  Item.FAdditionalAttribute := LoadString(ANode, 'AdditionalAttribute', False);
  Item.FMeasurementUnit := LoadString(ANode, 'MeasurementUnit', False);

  Item.FItemCodeData.StampType := '';
  Item.FItemCodeData.Stamp := '';
  Item.FItemCodeData.GTIN := '';
  Item.FItemCodeData.SerialNumber := '';



  // Код маркировки
  Node := ANode.ChildNodes.FindNode('GoodCodeData');
  if Node <> nil then
  begin
    Item.FItemCodeData.StampType := LoadString(Node, 'StampType', False);
    Item.FItemCodeData.Stamp := LoadString(Node, 'Stamp', False);
    Item.FItemCodeData.GTIN := LoadString(Node, 'GTIN', False);
    Item.FItemCodeData.SerialNumber := LoadString(Node, 'SerialNumber', False);
    Item.FItemCodeData.MarkingCode := LoadString(Node, 'MarkingCode', False);
    Item.FItemCodeData.State := LoadInteger(Node, 'State', False);
  end;

  // Данные агента
  Item.FAgentData.Enabled := False;
  Node := ANode.ChildNodes.FindNode('AgentData');
  if Node <> nil then
  begin
    if Node.AttributeNodes.Count > 0 then
    begin
      Item.FAgentData.Enabled := True;
      Item.FAgentData.PayingAgentOperation := LoadString(Node, 'PayingAgentOperation', False);
      Item.FAgentData.PayingAgentPhone := LoadString(Node, 'PayingAgentPhone', False);
      Item.FAgentData.ReceivePaymentsOperatorPhone := LoadString(Node, 'ReceivePaymentsOperatorPhone', False);
      Item.FAgentData.MoneyTransferOperatorPhone := LoadString(Node, 'MoneyTransferOperatorPhone', False);
      Item.FAgentData.MoneyTransferOperatorName := LoadString(Node, 'MoneyTransferOperatorName', False);
      Item.FAgentData.MoneyTransferOperatorAddress := LoadString(Node, 'MoneyTransferOperatorAddress', False);
      Item.FAgentData.MoneyTransferOperatorVATIN := LoadString(Node, 'MoneyTransferOperatorVATIN', False);
    end;
  end;

  // Данные поставщика
  Item.FPurveyorData.Enabled := False;
  Node := ANode.ChildNodes.FindNode('PurveyorData');
  if Node <> nil then
  begin
    if Node.AttributeNodes.Count > 0 then
    begin
      Item.FPurveyorData.Enabled := True;
      Item.FPurveyorData.PurveyorPhone := LoadString(Node, 'PurveyorPhone', False);
      Item.FPurveyorData.PurveyorName := LoadString(Node, 'PurveyorName', False);
      Item.FPurveyorData.PurveyorVATIN := LoadString(Node, 'PurveyorVATIN', False);
    end;   
  end;
end;

function TPositions1C.TaxToInt(const ATax: WideString): Integer;
begin
  if (ATax = '18') or (ATax = '20') then
    Result := 1
  else
    if ATax = '10' then
      Result := 2
    else
      if ATax = '0' then
        Result := 3
      else
        if ATax = 'none' then
          Result := 4
        else
          if (ATax = '18/118') or (ATax = '20/120') then
            Result := 5
          else
          if ATax = '10/110' then
            Result := 6
          else
            raise Exception.Create('Invalid Tax Value: ' + ATax);
end;

{ TPosition1C }

constructor TPosition1C.Create(AOwner: TPositions1C);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TPosition1C.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TPosition1C.SetOwner(AOwner: TPositions1C);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;


end.
