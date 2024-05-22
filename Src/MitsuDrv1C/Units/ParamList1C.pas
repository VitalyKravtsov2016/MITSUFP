unit ParamList1C;

interface

Uses
  // VCL
  Classes, XMLIntf, XMLDoc,
  // This
  ParamList1CPage;

type
  { TParamList1C }

  TParamList1C = class
  private
    FPages: TParamList1CPages;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveToXML(XML: IXMLNode);
    function ToString: WideString;

    property Pages: TParamList1CPages read FPages;
  end;

implementation

{ TParamList1C }

constructor TParamList1C.Create;
begin
  inherited Create;
  FPages := TParamList1CPages.Create;
end;

destructor TParamList1C.Destroy;
begin
  FPages.Free;
  inherited Destroy;
end;

function TParamList1C.ToString: WideString;
var
  Node: IXMLNode;
  Xml: IXMLDocument;
begin
  Result := '';
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('Settings');
    SaveToXML(Node);
    Xml.SaveToXML(Result);
  finally
    Xml := nil;
  end;
end;

procedure TParamList1C.SaveToXML(XML: IXMLNode);
begin
  Pages.SaveToXML(XML);
end;

end.
