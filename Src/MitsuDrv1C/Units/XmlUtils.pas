unit XmlUtils;

interface

uses
  // VCL
  SysUtils, Variants,
  // This
  MSXML, XMLDOC, XMLIntf, LogFile;

function GetChildNode(Node: IXmlNode; const NodeName: string): IXmlNode;

function GetNodeStr(Node: IXmlNode; const NodeName: string): string;
function GetNodeInt(Node: IXmlNode; const NodeName: string): Integer;
function GetNodeBool(Node: IXmlNode; const NodeName: string): Boolean;
function GetNodeStrDef(Node: IXmlNode;
  const NodeName, DefValue: string): string;
function GetNodeIntDef(Node: IXmlNode; const NodeName: string;
  DefValue: Integer): Integer;

function GetAttributeStr(Node: IXmlNode; const AttributeName: string): string;
function GetAttributeInt(Node: IXmlNode; const AttributeName: string): Integer;
function GetAttributeBool(Node: IXmlNode; const AttributeName: string): Boolean;

procedure SetNodeStr(Node: IXmlNode; const NodeName, NodeText: string);
procedure SetNodeInt(Node: IXmlNode; const NodeName: string;
  NodeValue: Integer);
procedure SetNodeBool(Node: IXmlNode; const NodeName: string;
  NodeValue: Boolean);

function LoadDecimal(ANode: IXmlNode; AName: WideString; AMustPresent: Boolean)
  : Currency;
function LoadString(ANode: IXmlNode; const AName: WideString;
  AMustPresent: Boolean): WideString;
function LoadDouble(ANode: IXmlNode; const AName: WideString;
  AMustPresent: Boolean): Double;
function LoadInteger(ANode: IXmlNode; const AName: WideString;
  AMustPresent: Boolean): Integer;
function LoadIntegerDef(ANode: IXmlNode; const AName: WideString;
  AMustPresent: Boolean; ADefValue: Integer): Integer;
function LoadDateTime(ANode: IXmlNode; const AName: WideString;
  AMustPresent: Boolean): TDateTime;
function HasAttribute(ANode: IXmlNode; const AName: WideString): Boolean;
function LoadBool(ANode: IXmlNode; const AName: WideString;
  AMustPresent: Boolean): Boolean;

implementation

const
  BoolToStr: array [Boolean] of string = ('0', '1');

function GetChildNode(Node: IXmlNode; const NodeName: string): IXmlNode;
begin
  Result := Node.ChildNodes[NodeName];
  if Result = nil then
    Result.AddChild(NodeName);
end;

procedure SetNodeStr(Node: IXmlNode; const NodeName, NodeText: string);
begin
  Node.AddChild(NodeName).Text := NodeText;
end;

procedure SetNodeInt(Node: IXmlNode; const NodeName: string;
  NodeValue: Integer);
begin
  Node.AddChild(NodeName).Text := IntToStr(NodeValue);
end;

procedure SetNodeBool(Node: IXmlNode; const NodeName: string;
  NodeValue: Boolean);
begin
  Node.AddChild(NodeName).Text := BoolToStr[NodeValue];
end;

function GetNodeStr(Node: IXmlNode; const NodeName: string): string;
var
  N: IXmlNode;
begin
  Result := '';
  N := Node.ChildNodes.Nodes[NodeName];
  if N <> nil then
    Result := N.Text;
end;

function GetNodeStrDef(Node: IXmlNode;
  const NodeName, DefValue: string): string;
var
  N: IXmlNode;
begin
  Result := DefValue;
  N := Node.ChildNodes.Nodes[NodeName];
  if N <> nil then
    Result := N.Text;
end;

function GetNodeInt(Node: IXmlNode; const NodeName: string): Integer;
begin
  Result := StrToInt(Node.ChildNodes.Nodes[NodeName].Text);
end;

function GetNodeIntDef(Node: IXmlNode; const NodeName: string;
  DefValue: Integer): Integer;
var
  N: IXmlNode;
begin
  Result := DefValue;
  N := Node.ChildNodes.Nodes[NodeName];
  if N <> nil then
    Result := StrToIntDef(N.Text, DefValue);
end;

function GetNodeBool(Node: IXmlNode; const NodeName: string): Boolean;
begin
  Result := Node.ChildNodes.Nodes[NodeName].Text <> '0';
end;

function GetAttributeStr(Node: IXmlNode; const AttributeName: string): string;
begin
  Result := Node.Attributes[AttributeName];
end;

function GetAttributeInt(Node: IXmlNode; const AttributeName: string): Integer;
begin
  Result := StrToInt(Node.Attributes[AttributeName]);
end;

function GetAttributeBool(Node: IXmlNode; const AttributeName: string): Boolean;
begin
  Result := Node.Attributes[AttributeName] <> '0';
end;

function LoadString(ANode: IXmlNode; const AName: WideString;
  AMustPresent: Boolean): WideString;
var
  Value: OleVariant;
begin
  Value := ANode.Attributes[AName];
  if VarIsNull(Value) then
  begin
    // globallogger.Debug('Attribute ' + AName + ' is null');
    if AMustPresent then
      raise Exception.Create('No XML attribute ' + AName)
    else
      Result := '';
    Exit;
  end;
  Result := Value;
end;

function IsTrue(const AStr: WideString): Boolean;
begin
  if AStr = '' then
  begin
    Result := False;
    Exit;
  end;
  Result := (AStr <> '0') and (UpperCase(AStr) <> 'FALSE');
end;

function LoadBool(ANode: IXmlNode; const AName: WideString;
  AMustPresent: Boolean): Boolean;
begin
  Result := IsTrue(LoadString(ANode, AName, AMustPresent));
end;

function DT1CToDateTime(S: WideString): TDateTime;
var
  F: TFormatSettings;
begin
  S := StringReplace(S, 'T', ' ', [rfReplaceAll]);
  GetLocaleFormatSettings(0, F);
  F.DateSeparator := '-';
  F.ShortDateFormat := 'yyyy-mm-dd';
  F.TimeSeparator := ':';
  F.ShortTimeFormat := 'hh:nn:ss';
  Result := StrToDateTime(S, F);
end;

function LoadDateTime(ANode: IXmlNode; const AName: WideString;
  AMustPresent: Boolean): TDateTime;
var
  Value: OleVariant;
begin
  // 2017-08-10T00:00:00
  Value := ANode.Attributes[AName];
  if VarIsNull(Value) then
  begin
    if AMustPresent then
      raise Exception.Create('No XML attribute ' + AName)
    else
      Result := 0;
    Exit;
  end;
  try
    Result := DT1CToDateTime(string(Value));
  except
    raise Exception.Create('Wrong format of DateTime ' + string(Value));
  end;
end;

function LoadDouble(ANode: IXmlNode; const AName: WideString;
  AMustPresent: Boolean): Double;
var
  saveSeparator: Char;
  Value: OleVariant;
begin
  Result := 0;
  Value := ANode.Attributes[AName];
  if VarIsNull(Value) then
  begin
    if AMustPresent then
      raise Exception.Create('No XML attribute ' + AName)
    else
    begin
      Exit;
    end;
  end;
  saveSeparator := FormatSettings.DecimalSeparator;
  try
    FormatSettings.DecimalSeparator := '.';
    try
      Result := StrToFloat(Value);
    except
      Result := 0;
      raise Exception.Create('Wrong Double XML Value ' + AName + ': ' +
        ANode.Attributes[AName]);
    end;
  finally
    FormatSettings.DecimalSeparator := saveSeparator;
  end;
end;

function HasAttribute(ANode: IXmlNode; const AName: WideString): Boolean;
var
  Value: OleVariant;
begin
  Value := ANode.Attributes[AName];
  Result := not VarIsNull(Value);
end;

function LoadDecimal(ANode: IXmlNode; AName: WideString; AMustPresent: Boolean)
  : Currency;
var
  saveSeparator: Char;
  Value: OleVariant;
begin
  Result := 0;
  Value := ANode.Attributes[AName];
  if VarIsNull(Value) then
  begin
    if AMustPresent then
      raise Exception.Create('No XML attribute ' + AName)
    else
    begin
      Exit;
    end;
  end;
  saveSeparator := FormatSettings.DecimalSeparator;
  try
    FormatSettings.DecimalSeparator := '.';
    try
      Result := StrToCurr(Value);
    except
      raise Exception.Create('Wrong Decimal XML Value ' + AName + ': ' +
        ANode.Attributes[AName]);
    end;
  finally
    FormatSettings.DecimalSeparator := saveSeparator;
  end;
end;

function LoadInteger(ANode: IXmlNode; const AName: WideString;
  AMustPresent: Boolean): Integer;
var
  Value: OleVariant;
begin
  Result := 0;
  Value := ANode.Attributes[AName];
  if VarIsNull(Value) then
  begin
    if AMustPresent then
      raise Exception.Create('No XML attribute ' + AName)
    else
      Exit;
  end;
  try
    Result := StrToInt(ANode.Attributes[AName]);
  except
    raise Exception.Create('Wrong Integer XML Value ' + AName + ': ' +
      ANode.Attributes[AName]);
  end;
end;

function LoadIntegerDef(ANode: IXmlNode; const AName: WideString;
  AMustPresent: Boolean; ADefValue: Integer): Integer;
var
  Value: OleVariant;
begin
  Result := ADefValue;
  Value := ANode.Attributes[AName];
  if VarIsNull(Value) then
  begin
    if AMustPresent then
      raise Exception.Create('No XML attribute ' + AName)
    else
      Exit;
  end;
  if ANode.Attributes[AName] = '' then
  begin
    Result := ADefValue;
    Exit;
  end;
  try
    Result := StrToInt(ANode.Attributes[AName]);
  except
    raise Exception.Create('Wrong Integer XML Value ' + AName + ': ' +
      ANode.Attributes[AName]);
  end;
end;

end.
