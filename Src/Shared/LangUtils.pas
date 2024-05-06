unit LangUtils;

interface

uses
  // VCL
  Windows, Registry;

function GetLanguage: string;
procedure SetLanguage(const Language: string);

implementation

function GetModuleFileName: string;
var
  Buffer: array[0..261] of Char;
begin
  SetString(Result, Buffer, Windows.GetModuleFileName(HInstance,
    Buffer, SizeOf(Buffer)));
end;

function GetLanguage: string;
var
  Reg: TRegistry;
begin
  Result := '';
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Borland\Locales', False) then
      Result := Reg.ReadString(GetModuleFileName);
  finally
    Reg.Free;
  end;
end;

procedure SetLanguage(const Language: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Borland\Locales', True) then
      Reg.WriteString(GetModuleFileName, Language);
  finally
    Reg.Free;
  end;
end;

end.
