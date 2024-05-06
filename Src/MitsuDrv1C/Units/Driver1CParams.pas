unit Driver1CParams;

interface

uses
  // VCL
  Windows, SysUtils, Registry,
  // This
  DrvFR1CLib_TLB, DriverTypes, LogFile;

type
  { TDriver1CParams }

  TDriver1CParams = class
  public
    function ReadCheckNumber(const SerialNumber: string): Integer;
    procedure WriteCheckNumber(const SerialNumber: string; CheckNumber: Integer);
  end;

implementation

resourcestring
  SParamsReadError = 'Ошибка чтения параметров';
  SParamsWriteError = 'Ошибка записи параметров';

{ TDriver1CParams }

function TDriver1CParams.ReadCheckNumber(const SerialNumber: string): Integer;
var
  Reg: TRegistry;
begin
  Result := 1;
  Reg := TRegistry.Create;
  try
    Reg.Access := KEY_READ;
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(REGSTR_KEY_PARAMS1C, False) then
    begin
      if Reg.ValueExists(SerialNumber) then
      begin
        Result := Reg.ReadInteger(SerialNumber);
      end;
    end;
  except
    on E: Exception do
    begin
      GlobalLogger.Error(Format('%s: %s', [SParamsReadError, E.Message]));
    end;
  end;
  Reg.Free;
end;

procedure TDriver1CParams.WriteCheckNumber(const SerialNumber: string;
  CheckNumber: Integer);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(REGSTR_KEY_PARAMS1C, True) then
      Reg.WriteInteger(SerialNumber, CheckNumber);
  except
    on E: Exception do
    begin
      GlobalLogger.Error(Format('%s: %s', [SParamsWriteError, E.Message]));
    end;
  end;
  Reg.Free;
end;


end.
