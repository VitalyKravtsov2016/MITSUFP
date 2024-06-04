unit GS1Util;

interface

uses
  SysUtils, Classes, GS1Barcode;

procedure DecodeGS1_full(const ABarcode: AnsiString; var AGTIN: AnsiString;
  var ASerial: AnsiString);

implementation

type
  TAIRec = record
    AI: AnsiString;
    Length: Integer;
  end;

const
  AIs: array [0 .. 15] of TAIRec = ((AI: '00'; Length: 18), (AI: '01';
    Length: 14), (AI: '02'; Length: 14), (AI: '03'; Length: 14), (AI: '04';
    Length: 16), (AI: '11'; Length: 6), (AI: '12'; Length: 6), (AI: '13';
    Length: 68), (AI: '14'; Length: 6), (AI: '15'; Length: 6), (AI: '16';
    Length: 6), (AI: '17'; Length: 6), (AI: '18'; Length: 6), (AI: '19';
    Length: 6), (AI: '20'; Length: 2), (AI: '30'; Length: 8));

function GetAILength(const AI: AnsiString): Integer;
var
  Rec: TAIRec;
begin
  Result := 0;
  (*
    for Rec in AIs do
    begin
    if AI = Rec.AI then
    begin
    Result := Rec.Length;
    Break;
    end;

    end;
  *)
end;

procedure DecodeGS1_full(const ABarcode: AnsiString; var AGTIN: AnsiString;
  var ASerial: AnsiString);
var
  AI: AnsiString;
  Stream: TStringStream;
  Len: Integer;
  Data: AnsiString;
  c: AnsiString;
  B: TGS1Barcode;
begin
  ASerial := '';
  AGTIN := '';

  if Length(ABarcode) = 0 then
    Exit;

  if ABarcode[1] = '(' then
  begin
    B := DecodeGS1(ABarcode);
    AGTIN := B.GTIN;
    ASerial := B.Serial;
    Exit;
  end;

  Stream := TStringStream.Create(ABarcode);
  try
    repeat
      AI := Stream.ReadString(2);
      if AI = '21' then
      begin
        repeat
          c := Stream.ReadString(1);
          ASerial := ASerial + c;
        until (c = #$1D) or (Stream.Position >= Stream.Size);
        Break;
      end;
      Len := GetAILength(AI);
      if Len = 0 then
        raise Exception.Create('Can''t parse GS code: ' + ABarcode);
      Data := Stream.ReadString(Len);
      if AI = '01' then
        AGTIN := Data;
      if AI = '21' then
        ASerial := Data;
      if (AGTIN <> '') and (ASerial <> '') then
        Exit;
    until Stream.Position >= Stream.Size;
    if (AGTIN = '') or (ASerial = '') then
      raise Exception.Create('Can''t parse GS code: ' + ABarcode);
  finally
    Stream.Free;
  end;
end;

end.
