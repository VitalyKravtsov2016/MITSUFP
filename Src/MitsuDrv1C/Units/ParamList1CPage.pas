unit ParamList1CPage;

interface

Uses
  // VCL
  Classes, XMLIntf, XMLDoc,
  // This
  ParamList1CGroup
  ;

type

  TParamList1CPage = class;

  { TParamList1CPages }

  TParamList1CPages = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TParamList1CPage;
    procedure InsertItem(AItem: TParamList1CPage);
    procedure RemoveItem(AItem: TParamList1CPage);
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TParamList1CPage;

    procedure Clear;
    procedure SaveToXML(XML: IXMLNode);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TParamList1CPage read GetItem; default;
  end;

  { TParamList1CPage }

  TParamList1CPage = class
  private
    FCaption: WideString;
    FGroups: TParamList1CGroups;
    FOwner: TParamList1CPages;
    procedure SetOwner(AOwner: TParamList1CPages);
  public
    procedure SaveToXML(XML: IXMLNode);
    constructor Create(AOwner: TParamList1CPages);
    destructor Destroy; override;
    property Caption: WideString read FCaption write FCaption;
    property Groups: TParamList1CGroups read FGroups;
  end;

implementation

{ TParamList1CPages }

constructor TParamList1CPages.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TParamList1CPages.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TParamList1CPages.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TParamList1CPages.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TParamList1CPages.GetItem(Index: Integer): TParamList1CPage;
begin
  Result := FList[Index];
end;

procedure TParamList1CPages.InsertItem(AItem: TParamList1CPage);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TParamList1CPages.RemoveItem(AItem: TParamList1CPage);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TParamList1CPages.Add: TParamList1CPage;
begin
  Result := TParamList1CPage.Create(Self);
end;

procedure TParamList1CPages.SaveToXML(XML: IXMLNode);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Items[i].SaveToXML(XML);
  end;
end;

{ TParamList1CPage }

constructor TParamList1CPage.Create(AOwner: TParamList1CPages);
begin
  FGroups := TParamList1CGroups.Create;
  inherited Create;
  SetOwner(AOwner);
end;

destructor TParamList1CPage.Destroy;
begin
  FGroups.Free;
  SetOwner(nil);
  inherited Destroy;
end;

procedure TParamList1CPage.SaveToXML(XML: IXMLNode);
var
  Node: IXMLNode;
begin
  Node := XML.AddChild('Page');
  Node.Attributes['Caption'] := FCaption;
  FGroups.SaveToXML(Node);
end;

procedure TParamList1CPage.SetOwner(AOwner: TParamList1CPages);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

end.
