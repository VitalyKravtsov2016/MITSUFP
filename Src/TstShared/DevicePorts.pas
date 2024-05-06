unit DevicePorts;

interface

uses
  // VCL
  Windows, Classes, SysUtils, System.Win.Registry;

type
  { TDevicePorts }

  TDevicePorts = class
  private
    class procedure GetDefaultPorts(Ports: TStrings; Count: Integer);
  public
    class function GetPortNames: string;
    class function GetSystemPortNames: string;
    class procedure GetPorts(Ports: TStrings);
    class procedure GetSystemPorts(Ports: TStringList);
  end;

implementation

{ TDevicePorts }

class procedure TDevicePorts.GetPorts(Ports: TStrings);
begin
  GetDefaultPorts(Ports, 256);
end;

class procedure TDevicePorts.GetDefaultPorts(Ports: TStrings; Count: Integer);
var
  i: Integer;
begin
  Ports.Clear;
  for i := 1 to Count do
    Ports.AddObject('COM '+ IntToStr(i), TObject(i));
end;

{ Сравниваем по номерам портов  }

function ComparePorts(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := Integer(List.Objects[Index1]) - Integer(List.Objects[Index2]);
end;

{ Порты должны называться COMx }
{ Другие порты мы не добавляем }

class procedure TDevicePorts.GetSystemPorts(Ports: TStringList);
var
  S: string;
  S1: string;
  i: Integer;
  Code: Integer;
  Reg: TRegistry;
  PortNumber: Integer;
  Strings: TStringList;
begin
  Ports.Clear;
  Reg := TRegistry.Create;
  Strings := TStringList.Create;
  try
    Reg.Access := KEY_READ;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\HARDWARE\DEVICEMAP\SERIALCOMM', False) then
    begin
      Reg.GetValueNames(Strings);
      for i := 0 to Strings.Count-1 do
      begin
        S := Reg.ReadString(Strings[i]);
        S1 := Copy(S, 4, Length(S));
        Val(S1, PortNumber, Code);
        if Code = 0 then
        begin
          if Ports.IndexOf(S) = -1 then
            Ports.AddObject(S, TObject(PortNumber));
        end;
      end;
      Ports.CustomSort(ComparePorts);
    end;
  finally
    Reg.Free;
    Strings.Free;
  end;
end;

class function TDevicePorts.GetSystemPortNames: string;
var
  PortNames: TStringList;
begin
  PortNames := TStringList.Create;
  try
    GetSystemPorts(PortNames);
    Result := PortNames.Text;
  finally
    PortNames.Free;
  end;
end;

class function TDevicePorts.GetPortNames: string;
var
  PortNames: TStringList;
begin
  PortNames := TStringList.Create;
  try
    GetPorts(PortNames);
    Result := PortNames.Text;
  finally
    PortNames.Free;
  end;
end;

end.
