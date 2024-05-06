unit ParamList1CItem;

interface

Uses
  // VCL
  SysUtils, Classes, XMLIntf, XMLDoc,
  // This
  Param1CChoiceList
  ;

type

  TParamList1CItem = class;

  { TParamList1CItems }

  TParamList1CItems = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TParamList1CItem;
    procedure InsertItem(AItem: TParamList1CItem);
    procedure RemoveItem(AItem: TParamList1CItem);
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TParamList1CItem;
    function ItemByName(AName: WideString): TParamList1CItem;

    procedure SaveToXML(XML: IXMLNode);
    procedure Clear;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TParamList1CItem read GetItem; default;
  end;

  { TParamList1CItem }

  TParamList1CItem = class
  private
    FName: WideString;
    FOwner: TParamList1CItems;
    FCaption: WideString;
    FTypeValue: WideString;
    FFieldFormat: WideString;
    FDefaultValue: WideString;
    FChoiceList: TParam1CChoiceList;
    FMasterParameterName: WideString;
    FMasterParameterOperation: WideString;
    FMasterparameterValue: WideString;
    FROnly: Boolean;
    FDescription: WideString;
    procedure SetOwner(AOwner: TParamList1CItems);
  public
    procedure SaveToXML(XML: IXMLNode);
    constructor Create(AOwner: TParamList1CItems);
    destructor Destroy; override;
    procedure AddChoiceListItem(const Name: WideString; const Value: Widestring);

    property Name: WideString read FName write FName;
    property Description: WideString read FDescription write FDescription;
    property ROnly: Boolean read FROnly write FROnly;
    property Caption: WideString read FCaption write FCaption;
    property TypeValue: WideString read FTypeValue write FTypeValue;
    property FieldFormat: WideString read FFieldFormat write FFieldFormat;
    property DefaultValue: WideString read FDefaultValue write FDefaultValue;
    property ChoiceList: TParam1CChoiceList read FChoiceList write FChoiceList;
    property MasterParameterName: WideString read FMasterParameterName write FMasterParameterName;
    property MasterParameterOperation: WideString read FMasterParameterOperation write FMasterParameterOperation;
    property MasterparameterValue: WideString read FMasterparameterValue write FMasterparameterValue;
  end;

implementation

{ TParamList1CItems }

constructor TParamList1CItems.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TParamList1CItems.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TParamList1CItems.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TParamList1CItems.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TParamList1CItems.GetItem(Index: Integer): TParamList1CItem;
begin
  Result := FList[Index];
end;

procedure TParamList1CItems.InsertItem(AItem: TParamList1CItem);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TParamList1CItems.RemoveItem(AItem: TParamList1CItem);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TParamList1CItems.Add: TParamList1CItem;
begin
  Result := TParamList1CItem.Create(Self);
end;

procedure TParamList1CItems.SaveToXML(XML: IXMLNode);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Items[i].SaveToXML(XML);
  end;
end;

function TParamList1CItems.ItemByName(
  AName: WideString): TParamList1CItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if WideSameStr(Items[i].Name, AName) then
    begin
      Result := Items[i];
      Break;
    end;
  end;
end;

{ TParamList1CItem }

procedure TParamList1CItem.AddChoiceListItem(const Name,
  Value: Widestring);
var
  Item: TParam1CChoiceListItem;
begin
  Item := ChoiceList.Add;
  Item.Name := Name;
  Item.Value := Value;
end;

constructor TParamList1CItem.Create(AOwner: TParamList1CItems);
begin
  inherited Create;
  SetOwner(AOwner);
  FChoiceList := TParam1CChoiceList.Create;
end;

destructor TParamList1CItem.Destroy;
begin
  FChoiceList.Free;
  SetOwner(nil);
  inherited Destroy;
end;

procedure TParamList1CItem.SaveToXML(XML: IXmlNode);
var
  Node: IXMLNode;
begin
  Node := XML.AddChild('Parameter');
  Node.Attributes['Name'] := FName;
  Node.Attributes['Caption'] := FCaption;
  Node.Attributes['Description'] := FDescription;
  Node.Attributes['TypeValue'] := FTypeValue;
  Node.Attributes['ReadOnly'] := BoolToStr(FROnly, True);

  if FFieldFormat <> '' then
    Node.Attributes['FieldFormat'] := FFieldFormat;
  if FMasterParameterName <> '' then
    Node.Attributes['MasterParameterName'] := FMasterParameterName;
  if FMasterParameterOperation <> '' then
    Node.Attributes['MasterParameterOperation'] := FMasterParameterOperation;
  if FMasterparameterValue <> '' then
    Node.Attributes['MasterparameterValue'] := FMasterparameterValue;
  if FDefaultValue <> '' then
    Node.Attributes['DefaultValue'] := FDefaultValue;

  if FChoiceList.Count > 0 then
    FChoiceList.SaveToXML(Node);
end;

procedure TParamList1CItem.SetOwner(AOwner: TParamList1CItems);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

end.
