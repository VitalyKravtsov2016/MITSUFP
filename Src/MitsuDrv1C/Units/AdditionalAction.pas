unit AdditionalAction;

interface

Uses
  // VCL
  Classes, SysUtils, XMLDoc, XMLIntf,
  // This
  FiscalPrinter, Devices1C;

type

  TAdditionalAction = class;

  { TAdditionalActions }

  TAdditionalActions = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TAdditionalAction;
    procedure InsertItem(AItem: TAdditionalAction);
    procedure RemoveItem(AItem: TAdditionalAction);
  public
    constructor Create;
    destructor Destroy; override;
    function ItemByName(Name: WideString): TAdditionalAction;
    function ToString: WideString;
    procedure SaveToXML(XML: IXMLNode);

    procedure Clear;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TAdditionalAction read GetItem; default;
  end;

  { TAdditionalAction }

  TAdditionalAction = class
  private
    FOwner: TAdditionalActions;
//    FCaption: WideString;
    procedure SetOwner(AOwner: TAdditionalActions);
  public
    constructor Create(AOwner: TAdditionalActions);
    destructor Destroy; override;
    procedure Execute(Device: TDevice1C); virtual;
    procedure SaveToXML(XML: IXMLNode);
    function GetName: WideString; virtual;
    function GetCaption: WideString; virtual;
    property Name: WideString read GetName;
    property Caption: WideString read GetCaption;
  end;

  TPrintTaxReportAdditionalAction = class(TAdditionalAction)
  public
    function GetName: WideString; override;
    function GetCaption: WideString; override;
    procedure Execute(Device: TDevice1C); override;
  end;

  TPrintDepartmentReportAdditionalAction = class(TAdditionalAction)
  public
    function GetName: WideString; override;
    function GetCaption: WideString; override;
    procedure Execute(Device: TDevice1C); override;
  end;


implementation

{ TAdditionalActions }

constructor TAdditionalActions.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TAdditionalActions.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TAdditionalActions.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TAdditionalActions.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TAdditionalActions.GetItem(Index: Integer): TAdditionalAction;
begin
  Result := FList[Index];
end;

procedure TAdditionalActions.InsertItem(AItem: TAdditionalAction);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TAdditionalActions.RemoveItem(AItem: TAdditionalAction);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TAdditionalActions.ItemByName(Name: WideString): TAdditionalAction;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if WideSameStr(Name, Items[i].Name) then
    begin
      Result := Items[i];
      Break;
    end;
  end;
end;

procedure TAdditionalActions.SaveToXML(XML: IXMLNode);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Items[i].SaveToXML(XML);
end;

function TAdditionalActions.ToString: WideString;
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
    Node := Xml.AddChild('Actions');
    SaveToXML(Node);
    Result := XML.XML.Text;
  finally
    Xml := nil;
  end;
end;

{ TAdditionalAction }

constructor TAdditionalAction.Create(AOwner: TAdditionalActions);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TAdditionalAction.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TAdditionalAction.Execute(Device: TDevice1C);
begin

end;

function TAdditionalAction.GetCaption: WideString;
begin
  Result := '';
end;

function TAdditionalAction.GetName: WideString;
begin
  Result := '';
end;

procedure TAdditionalAction.SaveToXML(XML: IXMLNode);
var
  Node: IXMLNode;
begin
  Node := XML.AddChild('Action');
  Node.Attributes['Name'] := Name;
  Node.Attributes['Caption'] := Caption;
end;

procedure TAdditionalAction.SetOwner(AOwner: TAdditionalActions);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

{ TPrintTaxReportAdditionalAction }

procedure TPrintTaxReportAdditionalAction.Execute(
  Device: TDevice1C);
begin
  Device.PrintTaxReport;
end;

function TPrintTaxReportAdditionalAction.GetCaption: WideString;
begin
  Result := 'Îעקוע ןמ םאכמדאל';
end;

function TPrintTaxReportAdditionalAction.GetName: WideString;
begin
  Result := 'TaxReport';
end;

{ TPrintDepartmentReportAdditionalAction }

procedure TPrintDepartmentReportAdditionalAction.Execute(
  Device: TDevice1C);
begin
  Device.PrintDepartmentReport;
end;

function TPrintDepartmentReportAdditionalAction.GetCaption: WideString;
begin
  Result := 'Îעקוע ןמ מעהוכאל';
end;

function TPrintDepartmentReportAdditionalAction.GetName: WideString;
begin
  Result := 'DepartmentReport';
end;

end.
