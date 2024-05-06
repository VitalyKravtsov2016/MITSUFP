unit DriverError;

interface

uses
  // VCL
  SysUtils;

type
  { EDriverError }

  EDriverError = class(Exception)
  private
   FErrorCode: Integer;
   FWideMessage: WideString;
  public
    constructor Create2(Code: Integer; const Msg: WideString);
    property ErrorCode: Integer read FErrorCode write FErrorCode;
    property WideMessage: WideString read FWideMessage write FWideMessage;
  end;

procedure RaiseError(Code: Integer; const Message: WideString);

implementation

{ EDriverError }

constructor EDriverError.Create2(Code: Integer; const Msg: WideString);
begin
  inherited Create(Msg);
  FErrorCode := Code;
  FWideMessage := Msg;
end;

procedure RaiseError(Code: Integer; const Message: WideString);
begin
  raise EDriverError.Create2(Code, Message);
end;

end.
