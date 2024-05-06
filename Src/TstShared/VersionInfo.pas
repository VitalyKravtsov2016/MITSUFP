unit VersionInfo;

interface

uses
  // VCL
  SysUtils, Classes, JvVersionInfo, winapi.Windows;

type
  { TVersionInfo }

  TVersionInfo = record
    MajorVersion: WORD;
    MinorVersion: WORD;
    ProductRelease: WORD;
    ProductBuild: WORD;
  end;

function GetModFileName: string;
function GetModuleVersion: string;
function GetFileVersionInfoStr: string;
function GetFileVersionInfo: TVersionInfo;

implementation



function GetFileVersionInfo2: TVersionInfo;
var
  verblock:PVSFIXEDFILEINFO;
  versionMS,versionLS:cardinal;
  verlen:cardinal;
  rs:TResourceStream;
  m:TMemoryStream;
  p:pointer;
  s:cardinal;
begin
  m:=TMemoryStream.Create;
  try
    rs:=TResourceStream.CreateFromID(HInstance,1,RT_VERSION);
    try
      m.CopyFrom(rs,rs.Size);
    finally
      rs.Free;
    end;
    m.Position:=0;
    if VerQueryValue(m.Memory,'\',pointer(verblock),verlen) then
      begin

        VersionMS:=verblock.dwFileVersionMS;
        VersionLS:=verblock.dwFileVersionLS;
        Result.MajorVersion := versionMS shr 16;
        Result.MinorVersion := versionMS and $FFFF;
        Result.ProductRelease := VersionLS shr 16;
        Result.ProductBuild := VersionLS and $FFFF;
      end;
  finally
    m.Free;
  end;
end;

function GetFileVersionInfo3: TVersionInfo;
var
  Exe: string;
  v1, v2,  v4: Cardinal;
begin
   Exe := ParamStr(0);
   GetProductVersion(Exe, v1, v2, v4);
   Result.MajorVersion := v1;
   Result.MinorVersion := v2;
   Result.ProductRelease := 0;
   Result.ProductBuild := v4;
end;

function GetFileVersionInfo: TVersionInfo;
var
  hVerInfo: THandle;
  hGlobal: THandle;
  AddrRes: pointer;
  Buf: array[0..7]of byte;
begin
  Result.MajorVersion := 0;
  Result.MinorVersion := 0;
  Result.ProductRelease := 0;
  Result.ProductBuild := 0;

  hVerInfo:= FindResource(hInstance, '#1', RT_VERSION);
  if hVerInfo <> 0 then
  begin
    hGlobal := LoadResource(hInstance, hVerInfo);
    if hGlobal <> 0 then
    begin
      AddrRes:= LockResource(hGlobal);
      try
        CopyMemory(@Buf, Pointer(Integer(AddrRes)+48), 8);
        Result.MinorVersion := Buf[0] + Buf[1]*$100;
        Result.MajorVersion := Buf[2] + Buf[3]*$100;
        Result.ProductBuild := Buf[4] + Buf[5]*$100;
        Result.ProductRelease := Buf[6] + Buf[7]*$100;
      finally
        FreeResource(hGlobal);
      end;
    end;
  end;
end;

function GetFileVersionInfoStr: string;
var
  vi: TVersionInfo;
begin
//  Result := AppVerInfo.FileVersion;

  vi := GetFileVersionInfo;
  Result := Format('%d.%d.%d.%d', [vi.MajorVersion, vi.MinorVersion,
    vi.ProductRelease, vi.ProductBuild]);
end;

function GetModFileName: string;
var
  Buffer: array[0..261] of Char;
begin
  SetString(Result, Buffer, winapi.Windows.GetModuleFileName(HInstance,
    Buffer, SizeOf(Buffer)));
end;

function GetModuleVersion: string;
begin
  Result := GetFileVersionInfoStr;
end;

end.
