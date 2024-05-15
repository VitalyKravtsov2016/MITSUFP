unit ParamList1CGroup;

interface

Uses
  // VCL
  Classes, XMLIntf, XMLDoc,
  // This
  ParamList1CItem;

type
  TParamList1CGroup = class;

  { TParamList1CGroups }

  TParamList1CGroups = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TParamList1CGroup;
    procedure InsertItem(AItem: TParamList1CGroup);
    procedure RemoveItem(AItem: TParamList1CGroup);
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TParamList1CGroup;
    procedure SaveToXML(XML: IXMLNode);

    procedure Clear;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TParamList1CGroup read GetItem; default;
  end;

  { TParamList1CGroup }

  TParamList1CGroup = class
  private
    FCaption: WideString;
    FItems: TParamList1CItems;
    FOwner: TParamList1CGroups;
    procedure SetOwner(AOwner: TParamList1CGroups);
  public
    procedure SaveToXML(XML: IXMLNode);
    constructor Create(AOwner: TParamList1CGroups);
    destructor Destroy; override;
    property Caption: WideString read FCaption write FCaption;
    property Items: TParamList1CItems read FItems;
  end;

implementation

{ TParamList1CGroups }

constructor TParamList1CGroups.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TParamList1CGroups.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TParamList1CGroups.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TParamList1CGroups.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TParamList1CGroups.GetItem(Index: Integer): TParamList1CGroup;
begin
  Result := FList[Index];
end;

procedure TParamList1CGroups.InsertItem(AItem: TParamList1CGroup);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TParamList1CGroups.RemoveItem(AItem: TParamList1CGroup);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TParamList1CGroups.Add: TParamList1CGroup;
begin
  Result := TParamList1CGroup.Create(Self);
end;

procedure TParamList1CGroups.SaveToXML(XML: IXMLNode);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Items[i].SaveToXML(XML);
  end;
end;

{ TParamList1CGroup }

constructor TParamList1CGroup.Create(AOwner: TParamList1CGroups);
begin
  inherited Create;
  FItems := TParamList1CItems.Create;
  SetOwner(AOwner);
end;

destructor TParamList1CGroup.Destroy;
begin
  FItems.Free;
  SetOwner(nil);
  inherited Destroy;
end;

procedure TParamList1CGroup.SaveToXML(XML: IXMLNode);
var
  Node: IXMLNode;
begin
  Node := XML.AddChild('Group');
  Node.Attributes['Caption'] := FCaption;
  FItems.SaveToXML(Node);
end;

procedure TParamList1CGroup.SetOwner(AOwner: TParamList1CGroups);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

end.
