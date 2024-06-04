unit Param1CChoiceList;

interface

Uses
  // VCL
  Classes, XMLIntf, XMLDoc;

type
  TParam1CChoiceListItem = class;

  { TParam1CChoiceList }

  TParam1CChoiceList = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TParam1CChoiceListItem;
    procedure InsertItem(AItem: TParam1CChoiceListItem);
    procedure RemoveItem(AItem: TParam1CChoiceListItem);
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TParam1CChoiceListItem;
    procedure Clear;
    procedure SaveToXML(XML: IXMLNode);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TParam1CChoiceListItem
      read GetItem; default;
  end;

  { TParam1CChoiceListItem }

  TParam1CChoiceListItem = class
  private
    FName: WideString;
    FValue: WideString;
    FOwner: TParam1CChoiceList;
    procedure SetOwner(AOwner: TParam1CChoiceList);
  public
    procedure SaveToXML(XML: IXMLNode);
    constructor Create(AOwner: TParam1CChoiceList);
    destructor Destroy; override;
    property Name: WideString read FName write FName;
    property Value: WideString read FValue write FValue;
  end;

implementation

{ TParam1CChoiceList }

constructor TParam1CChoiceList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TParam1CChoiceList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TParam1CChoiceList.Clear;
begin
  while Count > 0 do
    Items[0].Free;
end;

function TParam1CChoiceList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TParam1CChoiceList.GetItem(Index: Integer): TParam1CChoiceListItem;
begin
  Result := FList[Index];
end;

procedure TParam1CChoiceList.InsertItem(AItem: TParam1CChoiceListItem);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TParam1CChoiceList.RemoveItem(AItem: TParam1CChoiceListItem);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TParam1CChoiceList.Add: TParam1CChoiceListItem;
begin
  Result := TParam1CChoiceListItem.Create(Self);
end;

procedure TParam1CChoiceList.SaveToXML(XML: IXMLNode);
var
  i: Integer;
  Node: IXMLNode;
begin
  Node := XML.AddChild('ChoiceList');
  for i := 0 to Count - 1 do
  begin
    Items[i].SaveToXML(Node);
  end;
end;

{ TParam1CChoiceListItem }

constructor TParam1CChoiceListItem.Create(AOwner: TParam1CChoiceList);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TParam1CChoiceListItem.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TParam1CChoiceListItem.SaveToXML(XML: IXMLNode);
var
  Node: IXMLNode;
begin
  Node := XML.AddChild('Item');
  Node.Text := FName;
  Node.Attributes['Value'] := FValue;
end;

procedure TParam1CChoiceListItem.SetOwner(AOwner: TParam1CChoiceList);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then
      FOwner.RemoveItem(Self);
    if AOwner <> nil then
      AOwner.InsertItem(Self);
  end;
end;

end.
