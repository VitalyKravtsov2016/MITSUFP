unit Optional;

interface

uses
  SysUtils;

type
  { TOptional }

  TOptional = class
  private
    FValue: AnsiString;
    function GetValue: AnsiString;
    procedure SetValue(const Value: AnsiString);
  public
    HasValue: Boolean;
    procedure SetEmpty;
    function DefValue(ADefValue: AnsiString): AnsiString;
    property Value: AnsiString read GetValue write SetValue;
  end;

implementation

{ TOptional<T> }

function TOptional.GetValue: AnsiString;
begin
  if HasValue then
    Result := FValue
  else
    raise Exception.Create('Optional value is Empty');
end;

procedure TOptional.SetEmpty;
begin
  HasValue := False;
end;

procedure TOptional.SetValue(const Value: AnsiString);
begin
  FValue := Value;
  HasValue := True;
end;

function TOptional.DefValue(ADefValue: AnsiString): AnsiString;
begin
  if HasValue then
    Result := Value
  else
    Result := ADefValue;
end;

end.
