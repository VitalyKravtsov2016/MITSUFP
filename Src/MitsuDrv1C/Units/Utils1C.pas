unit Utils1C;

interface

uses
  // VCL
  sysutils, XMLDoc, XMLIntf, xmlUtils;

type
  TFiscalParameters1C = record
    INN: WideString;
    TaxSystem: Integer;
    ReasonCode: Integerr;
    WorkMode: Integer;
  end;

procedure XMLToFiscalParameters(const AXml: WideString; var Params: TFiscalParameters1C);

implementation

function ParseTaxCodes(const ACodes: WideString): Byte;
var
  i: Integer
begin
  for i := 

end;

procedure XMLToFiscalParameters(const AXml: WideString; var Params: TFiscalParameters1C);
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
    Xml.XML.Text := Axml;
    Node := Xml.ChildNodes.FindNode('VATIN');
    if Node <> nil then
      Params.INN := Node.Text;




  finally
    Xml := nil;
  end;
end;

end.
