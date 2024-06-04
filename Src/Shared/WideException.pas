unit WideException;

interface

uses
  // VCL
  SysUtils;

type
  { EWideException }

  EWideException = class(Exception)
  private
    FMessage: WideString;
  public
    constructor Create(const AMessage: WideString);
    property Message: WideString read FMessage;
  end;

procedure raiseException(const AMessage: WideString);
procedure raiseExceptionFmt(const AFormat: WideString;
  const Args: array of const);

function GetExceptionMessage(E: Exception): WideString;

implementation

procedure raiseException(const AMessage: WideString);
begin
  raise EWideException.Create(AMessage);
end;

procedure raiseExceptionFmt(const AFormat: WideString;
  const Args: array of const);
begin
  raise EWideException.Create(WideFormat(AFormat, Args));
end;

function GetExceptionMessage(E: Exception): WideString;
begin
  Result := E.Message;
  if E is EWideException then
    Result := (E as EWideException).Message;

  if Result = '' then
    Result := E.ClassName;
end;

{ EWideException }

constructor EWideException.Create(const AMessage: WideString);
begin
  inherited Create(AMessage);
  FMessage := AMessage;
end;

end.
