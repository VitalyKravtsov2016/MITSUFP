unit untLogger;

interface

uses
  // VCL
  Windows, Classes, SysUtils, Variants,
  // This
  LogFile;


type
  { TLogger }

  TLogger = class
  private
    FName: string;
  public
    constructor Create(const AName: string);
    procedure WriteMethodName(const AMethodName: string);
    procedure WriteMethodValue(const AMethodName: string; AValue: Variant);
    procedure WriteSeparator;
    procedure WriteData(const Prefix, Data: AnsiString);
    procedure WriteRxData(const Data: AnsiString);
    procedure WriteTxData(const Data: AnsiString);
    procedure Info(Message: string);
    procedure Debug(Message: string);
    procedure Error(Message: string; Err: Exception = nil);
  end;

implementation

const
  StrLen = 20; // Максимальная длина строки данных
  S_SEPARATOR = '------------------------------------------------------------';

function StrToHex(const S: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    if i <> 1 then
      Result := Result + ' ';
    Result := Result + IntToHex(Ord(S[i]), 2);
  end;
end;

function GetModFileName: string;
var
  Buffer: array[0..261] of Char;
begin
  SetString(Result, Buffer, Windows.GetModuleFileName(HInstance,
    Buffer, SizeOf(Buffer)));
end;

{ TLogger }

constructor TLogger.Create(const AName: string);
begin
  FName := AName;
end;

procedure TLogger.Info(Message: string);
begin
  GlobalLogger.Info(FName + ' ' + Message);
end;

procedure TLogger.Debug(Message: string);
begin
  GlobalLogger.Debug(FName + ' ' + Message);
end;

procedure TLogger.Error(Message: string; Err: Exception = nil);
begin
  if Err <> nil then
    GlobalLogger.Error(FName + ' ' + Message + ' (' + Err.Message + ')')
  else
    GlobalLogger.Error(FName + ' ' + Message);
end;

procedure TLogger.WriteMethodName(const AMethodName: string);
begin
  Debug(AMethodName);
end;

procedure TLogger.WriteMethodValue(const AMethodName: string;
  AValue: Variant);
begin
  Debug(Format('%s: %s', [AMethodName, VarToStr(AValue)]));
end;

procedure TLogger.WriteSeparator;
begin
  Info(S_SEPARATOR);
end;

procedure TLogger.WriteRxData(const Data: AnsiString);
begin
  WriteData('<- ', Data);
end;

procedure TLogger.WriteTxData(const Data: AnsiString);
begin
  WriteData('-> ', Data);
end;

procedure TLogger.WriteData(const Prefix, Data: AnsiString);
var
  I: Integer;
  Text: string;
  Count: Integer;
  DataLen: Integer;
begin
  DataLen := Length(Data);
  Count := DataLen div StrLen;
  if (DataLen mod StrLen) <> 0 then
    Inc(Count);
  if Count = 0 then
    Inc(Count);
  for i := 0 to Count - 1 do
  begin
    Text := Prefix + StrToHex(Copy(Data, 1 + i * StrLen, StrLen));
    Debug(Text);
  end;
end;

end.

