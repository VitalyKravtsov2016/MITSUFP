unit DriverError;

interface

uses
  // VCL
  SysUtils;

type
  { EDriverError }

  EDriverError = class(Exception)
  private
    FCode: Integer;
  public
    property Code: Integer read FCode;
    constructor Create2(Code: Integer; const Msg: WideString);
  end;

procedure RaiseError(Code: Integer; const Message: WideString);
procedure raiseOpenKeyError(const KeyName: WideString);

implementation

procedure raiseOpenKeyError(const KeyName: WideString);
begin
  raise Exception.CreateFmt('%s: %s', ['Error opening registry', KeyName]);
end;

{ EDriverError }

constructor EDriverError.Create2(Code: Integer; const Msg: WideString);
begin
  inherited Create(Msg);
  FCode := Code;
end;

procedure RaiseError(Code: Integer; const Message: WideString);
begin
  raise EDriverError.Create2(Code, Message);
end;

end.
