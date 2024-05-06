unit StringUtils;

interface

uses
  // VCL
  Windows, SysUtils, Classes;

function IsDigit(Key: AnsiChar): Boolean;
function ConvertCharCodeString(const S: WideString): WideString;

type
  TSetOfChar = set of char;

function Inverse(const S: AnsiString): AnsiString;
function StrToHex(const S: AnsiString): AnsiString;
function StrToHexText(const S: AnsiString): AnsiString;
function HexToStr(const Data: AnsiString): AnsiString;
function CurrencyToStr(Value: Currency): AnsiString;
function StrToCurrency(const S: AnsiString): Currency;
function BoolToStr(Value: Boolean): AnsiString;

function Str1251To866(const S: AnsiString): AnsiString;
function Str866To1251(const S: AnsiString): AnsiString;

function GetString(const S: AnsiString; K: Integer; Delimiters: TSetOfChar): AnsiString;
function GetInteger(const Data: AnsiString; Index: Integer; Delimiters: TSetOfChar): Integer;

function WideStringToAnsiString(CodePage: Integer; const S: WideString): Ansistring;
function AnsiStringToWideString(CodePage: Integer; const S: ansistring): WideString;

function AddLeadingZeros(const S: AnsiString; ACount: Integer): AnsiString;
function AddFinalSpaces(const S: AnsiString; ACount: Integer): AnsiString;
function DecimalToString(Value: Currency): WideString;


implementation

resourcestring
  SCannotReadOddPos = 'Cannot read WideString from odd byte position';
  SCannotWriteOddPos = 'Cannot write WideString to odd byte position';
  SOddSizeInvalid = 'Odd size not valid for WideString';
  SNegativeSizeInvalid = 'Negative stream size invalid';
  SNegativeCapacityInvalid = 'Negative stream capacity invalid';
  SOddPosInvalid = 'Odd byte position not valid for WideString';
  SStringPositionInvalid = 'String position invalid';
  SCapacityLessSize = 'Capacity cannot be less than size';
  STargetNil = 'Target must not be nil';
  // STargetClosed = 'Target closed';
  SBufferSizeNotPositive = 'Buffer size must be positive';
  SReadBufferHasData = 'Read buffer has unprocessed data';
  SInvalidProcessInBuffer = 'Invalid call to ProcessInBuffer()';
  SInvalidProcessOutBuffer = 'Invalid call to ProcessOutBuffer()';
  SRecursiveRead = 'Recursive call to Read()';
  SRecursiveWrite = 'Recursive call to Write()';
  SStackCapacityError = 'Invalid Capacity for Stack: %d';
  SSwapDistanceError = 'Invalid Swap Distance: %d';
  SRotateDistanceError = 'Invalid Rotate Distance: %d';
  SInvalidBase64Encoding = 'Invalid Base64 encoding: %s';
  SBase64EndDetected = 'End of Base64 conversion detected';

  SWriterNotOpen = 'Writer not open';
  SReaderNotOpen = 'Reader not open';
  SReaderClosed = 'Reader closed';
  SFilterOpen = 'Filter open';
  SFilterNotOpen = 'Filter not open';
  SFilterClosed = 'Filter closed';
  SFilterClosing = 'Filter closing';
  SFilterNotClosed = 'Filter not closed';
  SFilterNil = 'Filter must not be nil';
  SFilterProcessorNil = 'Filter processor must not be nil';
  SFilterDriverNil = 'Filter driver must not be nil';
  SInvalidFilterInBuffer = 'Invalid call to ProcessInBuffer()';
  SInvalidFilterOutBuffer = 'Invalid call to ProcessOutBuffer()';
  SExtraDataFound = 'Extra data found';
  SUnexpectedFilterState = 'Unexpected filter state';
  SProcessorArgs = 'Invalid processor arguments';
  SStreamNil = 'Stream must not be nil';
  SWriterError = 'Writer error';
  SInvalidBuffer = 'Invalid buffer';
  SIOObjectNotReset = 'IO object not reset';
  SUnprocessedInput = 'Unprocessed input: %d bytes';

  SStringTableTooSmall = 'String table capacity too small'; 

function AddLeadingZeros(const S: AnsiString; ACount: Integer): AnsiString;
begin
  Result := Copy(S, 1, ACount);
  if ACount < Length(S) then Exit;
  Result := StringOfChar('0', ACount - Length(S)) + S;
end;

function AddFinalSpaces(const S: AnsiString; ACount: Integer): AnsiString;
begin
  Result := Copy(S, 1, ACount);
  if ACount < Length(S) then Exit;
  Result := S + StringOfChar(' ', ACount - Length(S));
end;

function IsDigit(Key: AnsiChar): Boolean;
begin
  Result := Key in ['0'..'9', Chr(VK_CLEAR), Chr(VK_BACK)];
end;

function ConvertCharCodeString(const S: WideString): WideString;
begin
  Result := S;
end;


function GetSubString(const S: AnsiString; var Value: AnsiString; K: Integer;
  Delimiters: TSetOfChar): Boolean;
var
  LastPos: Integer;
  CurPos: Integer;
  CurParam: Integer;
  Len: Integer;
begin
  Result := False;
  Value := '';
  Len := Length(S);
  CurParam := 1;
  CurPos := 1;
  while (CurPos <= Len) and (CurParam <= K) do
  begin
    LastPos := CurPos;
    while (CurPos <= Len) and not (S[CurPos] in Delimiters) do Inc(CurPos);
    if CurParam = K then
    begin
      Result := True;
      Value := Copy(S, LastPos, CurPos - LastPos);
      Exit;
    end;
    Inc(CurPos);
    Inc(CurParam);
  end;
end;

function GetString(const S: AnsiString; K: Integer; Delimiters: TSetOfChar): AnsiString;
begin
  Result := '';
  GetSubString(S, Result, K, Delimiters);
end;

function GetInteger(const Data: AnsiString; Index: Integer; Delimiters: TSetOfChar): Integer;
var
  S: AnsiString;
begin
  Result := 0;
  if GetSubString(Data, S, Index, Delimiters) then
    Result := StrToInt(S);
end;

function Inverse(const S: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    Result := Result + Chr(Ord(S[i]) xor $FF);
end;

function CurrencyToStr(Value: Currency): AnsiString;
var
  SaveDecimalSeparator: Char;
begin
  SaveDecimalSeparator := DecimalSeparator;
  try
    DecimalSeparator := '.';
    Result := Format('%.2f', [Value]);
  finally
    DecimalSeparator := SaveDecimalSeparator;
  end;
end;

function StrToCurrency(const S: AnsiString): Currency;
var
  SaveDecimalSeparator: Char;
begin
  SaveDecimalSeparator := DecimalSeparator;
  try
    DecimalSeparator := '.';
    Result := StrToFloat(S);
  finally
    DecimalSeparator := SaveDecimalSeparator;
  end;
end;

function StrToHex(const S: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    if i <> 1 then Result := Result + ' ';
    Result := Result + IntToHex(Ord(S[i]), 2);
  end;
end;

function StrToHexText(const S: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    Result := Result + IntToHex(Ord(S[i]), 2);
  end;
end;

function HexToStr(const Data: AnsiString): AnsiString;
var
  S: AnsiString;
  i: Integer;
  V, Code: Integer;
begin
  S := '';
  Result := '';
  for i := 1 to Length(Data) do
  begin
    S := Trim(S + Data[i]);
    if (Length(S) <> 0)and((Length(S) = 2)or(Data[i] = ' ')) then
    begin
      Val('$' + S, V, Code);
      if Code <> 0 then Exit;
      Result := Result + AnsiChar(V);
      S := '';
    end;
  end;
  // Last symbol
  if Length(S) <> 0 then
  begin
    Val('$' + S, V, Code);
    if Code <> 0 then Exit;
    Result := Result + Chr(V);
  end;
end;

function BoolToStr(Value: Boolean): AnsiString;
begin
  if Value then Result := 'True'
  else Result := 'False';
end;

const
  Table866To1251: array [0..255] of Byte = (
  {00} $00,$01,$02,$03,$04,$05,$06,$07, $08,$09,$0A,$0B,$0C,$0D,$0E,$0F,
  {10} $10,$11,$12,$13,$14,$15,$16,$17, $18,$19,$1A,$1B,$1C,$1D,$1E,$1F,
  {20} $20,$21,$22,$23,$24,$25,$26,$27, $28,$29,$2A,$2B,$2C,$2D,$2E,$2F,
  {30} $30,$31,$32,$33,$34,$35,$36,$37, $38,$39,$3A,$3B,$3C,$3D,$3E,$3F,
  {40} $40,$41,$42,$43,$44,$45,$46,$47, $48,$49,$4A,$4B,$4C,$4D,$4E,$4F,
  {50} $50,$51,$52,$53,$54,$55,$56,$57, $58,$59,$5A,$5B,$5C,$5D,$5E,$5F,
  {60} $60,$61,$62,$63,$64,$65,$66,$67, $68,$69,$6A,$6B,$6C,$6D,$6E,$6F,
  {70} $70,$71,$72,$73,$74,$75,$76,$77, $78,$79,$7A,$7B,$7C,$7D,$7E,$7F,
  {80} $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7, $C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF,
  {90} $D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7, $D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF,
  {A0} $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7, $E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF,
  {B0} $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F, $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,
  {C0} $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F, $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,
  {D0} $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F, $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,
  {E0} $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7, $F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF,
  {F0} $A8,$B8,$AA,$BA,$AF,$BF,$A1,$A2, $B0,$3F,$B7,$3F,$B9,$A4,$3F,$A0
  );

function Char866To1251(C: AnsiChar): AnsiChar;
begin
  Result := AnsiChar(Table866To1251[Ord(C)]);
end;

function Str866To1251(const S: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    Result := Result + Char866To1251(S[i]);
end;

const
  Table1251To866: array [0..255] of Byte = (
  {00} $00,$01,$02,$03,$04,$05,$06,$07, $08,$09,$0A,$0B,$0C,$0D,$0E,$0F,
  {10} $10,$11,$12,$13,$14,$15,$16,$17, $18,$19,$1A,$1B,$1C,$1D,$1E,$1F,
  {20} $20,$21,$22,$23,$24,$25,$26,$27, $28,$29,$2A,$2B,$2C,$2D,$2E,$2F,
  {30} $30,$31,$32,$33,$34,$35,$36,$37, $38,$39,$3A,$3B,$3C,$3D,$3E,$3F,
  {40} $40,$41,$42,$43,$44,$45,$46,$47, $48,$49,$4A,$4B,$4C,$4D,$4E,$4F,
  {50} $50,$51,$52,$53,$54,$55,$56,$57, $58,$59,$5A,$5B,$5C,$5D,$5E,$5F,
  {60} $60,$61,$62,$63,$64,$65,$66,$67, $68,$69,$6A,$6B,$6C,$6D,$6E,$6F,
  {70} $70,$71,$72,$73,$74,$75,$76,$77, $78,$79,$7A,$7B,$7C,$7D,$7E,$7F,

  {80} $3F,$3F,$2C,$3F,$3F,$3F,$3F,$3F, $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,
  {90} $3F,$3F,$2C,$3F,$3F,$3F,$3F,$3F, $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,
  {A0} $FF,$F6,$F7,$3F,$FD,$3F,$3F,$3F, $F0,$3F,$F2,$3F,$3F,$3F,$3F,$F4,
  {B0} $F8,$3F,$3F,$3F,$3F,$3F,$3F,$FA, $F1,$FC,$F3,$3F,$3F,$6A,$73,$F5,
  {C0} $80,$81,$82,$83,$84,$85,$86,$87, $88,$89,$8A,$8B,$8C,$8D,$8E,$8F,
  {D0} $90,$91,$92,$93,$94,$95,$96,$97, $98,$99,$9A,$9B,$9C,$9D,$9E,$9F,
  {E0} $A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7, $A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF,
  {F0} $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7, $E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF
  );

function Char1251To866(C: AnsiChar): AnsiChar;
begin
  Result := AnsiChar(Table1251To866[Ord(C)]);
end;

function Str1251To866(const S: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    Result := Result + Char1251To866(S[i]);
end;

function WideStringToAnsiString(CodePage: Integer; const S: WideString): Ansistring;
var
  P: PAnsiChar;
  Count: Integer;
  CharCount: Integer;
begin
  Result := '';
  Count := WideCharToMultiByte(CodePage, 0, PWideChar(S), Length(S), nil, 0,
    nil, nil);
  if Count > 0 then
  begin
    P := AllocMem(Count);
    CharCount := WideCharToMultiByte(CodePage, 0, PWideChar(S), Length(S),
      P, Count, nil, nil);
    Result := P;
    SetLength(Result, CharCount);

    FreeMem(P);
  end;
end;

function AnsiStringToWideString(CodePage: Integer; const S: Ansistring): WideString;
var
  P: PWideChar;
  Count: Integer;
  CharCount: Integer;
begin
  Result := '';
  Count := MultiByteToWideChar(CodePage, 0, PAnsiChar(S), Length(S), nil, 0);
  if Count > 0 then
  begin
    P := AllocMem(Count*Sizeof(WideChar));
    CharCount := MultiByteToWideChar(CodePage, 0, PAnsiChar(S), Length(S), P, Count);
    Result := P;
    SetLength(Result, CharCount);
    FreeMem(P);
  end;
end;

function DecimalToString(Value: Currency): WideString;
var
  C: Char;
begin
  C := DecimalSeparator;
  DecimalSeparator := '.';
  try
    Result := CurrToStr(Value);
  finally
    DecimalSeparator := C;
  end;
end;


end.
