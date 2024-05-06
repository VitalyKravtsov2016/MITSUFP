unit ControlMark;

interface

Uses
  // VCL
  Classes, XMLDoc, XMLIntf, SysUtils,
  //
  XmlUtils, StringUtils, LogFile;

type

  TControlMark = class;

  { TControlMarks }

  TControlMarks = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TControlMark;
    procedure InsertItem(AItem: TControlMark);
    procedure RemoveItem(AItem: TControlMark);
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TControlMark;
    procedure Load(AXML: WideString);
    procedure Clear;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TControlMark read GetItem; default;
  end;

  { TControlMark }

  TControlMark = class
  private
    FOwner: TControlMarks;
    FState: Integer;
    FGUID: string;
    FMarkingCode: string;
    procedure SetOwner(AOwner: TControlMarks);
    function Destuff(AValue: string): string;
  public
    constructor Create(AOwner: TControlMarks);
    destructor Destroy; override;
    procedure Load(ANode: IXMLNode);
    property GUID: string read FGUID write FGUID;
    property MarkingCode: string read FMarkingCode write FMarkingCode;
    property State: Integer read FState write FState;
  end;


  TCheckResult = class;

  { TCheckResults }

  TCheckResults = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TCheckResult;
    procedure InsertItem(AItem: TCheckResult);
    procedure RemoveItem(AItem: TCheckResult);
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const AGuid: string; ASaleEnable: Boolean; AState: Integer; AError: Boolean; const ATextError: WideString): TCheckResult;
    function GetXML: WideString;
    procedure Clear;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TCheckResult read GetItem; default;
  end;

  { TCheckResult }

  TCheckResult = class
  private
    FOwner: TCheckResults;
    FSaleEnable: Boolean;
    FError: Boolean;
    FState: Integer;
    FTextError: WideString;
    FGuid: string;
    procedure SetOwner(AOwner: TCheckResults);
  public
    constructor Create(AOwner: TCheckResults);
    destructor Destroy; override;
    procedure Write(AXMLNode: IXMLNode);
    property Guid: string read FGuid write FGuid;
    property SaleEnable: Boolean read FSaleEnable write FSaleEnable;
    property State: Integer read FState write FState;
    property Error: Boolean read FError write FError;
    property TextError: WideString read FTextError write FTextError;
  end;


implementation

{ TControlMarks }

constructor TControlMarks.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TControlMarks.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TControlMarks.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TControlMarks.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TControlMarks.GetItem(Index: Integer): TControlMark;
begin
  Result := FList[Index];
end;

procedure TControlMarks.InsertItem(AItem: TControlMark);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TControlMarks.RemoveItem(AItem: TControlMark);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TControlMarks.Add: TControlMark;
begin
  Result := TControlMark.Create(Self);
end;

procedure TControlMarks.Load(AXML: WideString);
var
  Xml: IXMLDocument;
  Node: IXMLNode;
  i: Integer;
  Mark: TControlMark;
begin
  Clear;
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXmL(AXML);
    Node := Xml.ChildNodes.FindNode('ControlMarks');
    if Node = nil then
      raise Exception.Create('Error XML ControlMarks node ');
    for i := 0 to Node.ChildNodes.Count - 1 do
    begin
      Mark := Add;
      try
        Mark.Load(Node.ChildNodes[i]);
      except
        Mark.Free;
        raise
      end;
    end;
  finally
    Xml := nil;
  end;
end;

{ TControlMark }

constructor TControlMark.Create(AOwner: TControlMarks);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TControlMark.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

function TControlMark.Destuff(AValue: string): string;
begin
  Result := StringReplace(AValue, '\x1d', #$1D, [rfReplaceAll]);
end;

procedure TControlMark.Load(ANode: IXMLNode);
begin
  GUID := LoadString(ANode, 'GUID', True);
  MarkingCode := Destuff(LoadString(ANode, 'MarkingCode', True));
  State := LoadInteger(ANode, 'State', True);
end;

procedure TControlMark.SetOwner(AOwner: TControlMarks);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

{ TCheckResults }

constructor TCheckResults.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TCheckResults.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TCheckResults.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TCheckResults.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCheckResults.GetItem(Index: Integer): TCheckResult;
begin
  Result := FList[Index];
end;

procedure TCheckResults.InsertItem(AItem: TCheckResult);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TCheckResults.RemoveItem(AItem: TCheckResult);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TCheckResults.Add(const AGuid: string; ASaleEnable: Boolean; AState: Integer; AError: Boolean; const ATextError: WideString): TCheckResult;
begin
  Result := TCheckResult.Create(Self);
  Result.GUID := AGuid;
  Result.SaleEnable := ASaleEnable;
  Result.State := AState;
  Result.Error := AError;
  Result.TextError := ATextError;
end;

function TCheckResults.GetXML: WideString;
var
  Xml: IXMLDocument;
  Node: IXMLNode;
  Rec: IXMLNode;
  i: Integer;
begin
  Result := '';
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('CheckResults');
    for i := 0 to Count - 1 do
    begin
      Rec := Node.AddChild('Record');
      Items[i].Write(Rec);
    end;
    Result := XMLStringToWideString(Xml.XML.Text);
  finally
    Xml := nil;
  end;
end;

{ TCheckResult }

constructor TCheckResult.Create(AOwner: TCheckResults);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TCheckResult.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TCheckResult.SetOwner(AOwner: TCheckResults);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

procedure TCheckResult.Write(AXMLNode: IXMLNode);
begin
  AXMLNode.Attributes['GUID'] := FGuid;
  AXMLNode.Attributes['SaleEnable'] := StringUtils.BoolToStr(FSaleEnable);
  AXMLNode.Attributes['State'] := IntToStr(FState);
  AXMLNode.Attributes['Error'] := StringUtils.BoolToStr(FError);
  AXMLNode.Attributes['TextError'] := FTextError;
end;

end.


