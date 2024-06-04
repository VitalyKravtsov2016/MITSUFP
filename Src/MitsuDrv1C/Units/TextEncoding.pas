unit TextEncoding;

interface

uses
  // VCL
  Windows, SysUtils, StrUtils, ActiveX;

function GetText(const Text: string): WideString;
function UnicodeToAnsi(const Text: WideString; CodePage: Integer): string;
function AnsiToUnicode(const Text: AnsiString; CodePage: Word): WideString;
function UnicodeToArmenian(const Text: WideString): WideString;
function ArmenianToUnicode(const Text: string): WideString;
function AsciiToArmenian(const Text: WideString): string;
function ArmenianToAscii(const Text: string): WideString;

implementation

type
  TCharMap = record
    Ansi: Byte; // Ansi char
    Unicode: Word; // Unicode char
  end;

const
  NDC = $3F; // NDC - Not Defined Character

  (*
    TableUnicodeToArmenian2: array[0..0] of TCharMap = (
    (Ansi: $B2; Unicode: $0531)
    );

    TableUnicodeToArmenian3: array[0..0, 0..1] of Word = (
    ($B2, $0531),
    ($B3, $0561),
    ($B4, $0532),
    ($B5, $0562),
    ($B6, $0533),
    ($B7, $0563),
    );

    (*
    NDC, $B4, $B6, $B8, $BA, $BC, $BE,


    {0x538} $C0, $C2, $C4, $C6, $C8, $CA, $CC, $CE,
    {0x540} $D0, $D2, $D4, $D6, $D8, $DA, $DC, $DE,
    {0x548} $E0, $E2, $E4, $E6, $E8, $EA, $EC, $EE,
    {0x550} $F0, $F2, $F4, $F6, $F8, $FA, $FC, NDC,
    {0x558} NDC, $00, $60, $00, $AF, $AA, $B1, $00,
    {0x560} NDC, $B3, $B5, $B7, $B9, $BB, $BD, $BF,
    {0x568} $C1, $C3, $C5, $C7, $C9, $CB, $CD, $CF,
    {0x570} $D1, $D3, $D5, $D7, $D9, $DB, $DD, $DF,
    {0x578} $E1, $E3, $E5, $E7, $E9, $EB, $ED, $EF,
    {0x580} $F1, $F3, $F5, $F7, $F9, $FB, $FD, $A8,
    {0x588} NDC, $3A, $00, NDC, NDC, NDC, NDC, NDC
    );
  *)

  TableUnicodeToArmenian: array [$0530 .. $058F] of Byte = (
    { 0x530 } NDC, $B2, $B4, $B6, $B8, $BA, $BC, $BE,
    { 0x538 } $C0, $C2, $C4, $C6, $C8, $CA, $CC, $CE,
    { 0x540 } $D0, $D2, $D4, $D6, $D8, $DA, $DC, $DE,
    { 0x548 } $E0, $E2, $E4, $E6, $E8, $EA, $EC, $EE,
    { 0x550 } $F0, $F2, $F4, $F6, $F8, $FA, $FC, NDC,
    { 0x558 } NDC, $00, $60, $00, $AF, $AA, $B1, $00,
    { 0x560 } NDC, $B3, $B5, $B7, $B9, $BB, $BD, $BF,
    { 0x568 } $C1, $C3, $C5, $C7, $C9, $CB, $CD, $CF,
    { 0x570 } $D1, $D3, $D5, $D7, $D9, $DB, $DD, $DF,
    { 0x578 } $E1, $E3, $E5, $E7, $E9, $EB, $ED, $EF,
    { 0x580 } $F1, $F3, $F5, $F7, $F9, $FB, $FD, $A8,
    { 0x588 } NDC, $3A, $00, NDC, NDC, NDC, NDC, NDC);

  TableArmenianToUnicode: array [$00 .. $FF] of Word = (
    { 0x00 } $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007,
    { 0x08 } $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F,
    { 0x10 } $0010, $0011, $0012, $0013, $0014, $0015, $0016, $0017,
    { 0x18 } $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F,
    { 0x20 } $0020, $0021, $0022, $0023, $0024, $0025, $0026, $0027,
    { 0x28 } $0028, $0029, $002A, $002B, $002C, $002D, $002E, $002F,
    { 0x30 } $0030, $0031, $0032, $0033, $0034, $0035, $0036, $0037,
    { 0x38 } $0038, $0039, $003A, $003B, $003C, $003D, $003E, $003F,
    { 0x40 } $0040, $0041, $0042, $0043, $0044, $0045, $0046, $0047,
    { 0x48 } $0048, $0049, $004A, $004B, $004C, $004D, $004E, $004F,
    { 0x50 } $0050, $0051, $0052, $0053, $0054, $0055, $0056, $0057,
    { 0x58 } $0058, $0059, $005A, $005B, $005C, $005D, $005E, $005F,
    { 0x60 } $0060, $0061, $0062, $0063, $0064, $0065, $0066, $0067,
    { 0x68 } $0068, $0069, $006A, $006B, $006C, $006D, $006E, $006F,
    { 0x70 } $0070, $0071, $0072, $0073, $0074, $0075, $0076, $0077,
    { 0x78 } $0078, $0079, $007A, $007B, $007C, $007D, $007E, $007F,
    { 0x80 } $0080, $0081, $0082, $0083, $0084, $0085, $0086, $0087,
    { 0x88 } $0088, $0089, $008A, $008B, $008C, $008D, $008E, $008F,
    { 0x90 } $0090, $0091, $0092, $0093, $0094, $0095, $0096, $0097,
    { 0x98 } $0098, $0099, $009A, $009B, $009C, $009D, $009E, $009F,
    { 0xA0 } $0531, $0532, $0533, $0534, $0535, $0535, $0537, $0538,
    { 0xA8 } $0539, $053A, $053B, $053C, $053D, $053E, $053F, $0540,
    { 0xB0 } $00B0, $055E, $0531, $0561, $0532, $0562, $0533, $0563,
    { 0xB8 } $0534, $0564, $0535, $0565, $0536, $0566, $0537, $0567,
    { 0xC0 } $0538, $0568, $0539, $0569, $053A, $056A, $053B, $056B,
    { 0xC8 } $053C, $056C, $053D, $056D, $053E, $056E, $053F, $056F,
    { 0xD0 } $0540, $0570, $0541, $0571, $0542, $0572, $0543, $0573,
    { 0xD8 } $0544, $0574, $0545, $0575, $0546, $0576, $0547, $0577,
    { 0xE0 } $0548, $0578, $0549, $0579, $054A, $057A, $054B, $057B,
    { 0xE8 } $054C, $057C, $054D, $057D, $054E, $057E, $054F, $057F,
    { 0xF0 } $0550, $0580, $0551, $0581, $0552, $0582, $0553, $0583,
    { 0xF8 } $0554, $0584, $0555, $0585, $0556, $0586, $0557, $0587);

  TableAsciiToArmenian: array [$00 .. $FF] of Byte = (
    { 0x00 } $00, $01, $02, $03, $04, $05, $06, $07,
    { 0x08 } $08, $09, $0A, $0B, $0C, $0D, $0E, $0F,
    { 0x10 } $10, $11, $12, $13, $14, $15, $16, $17,
    { 0x18 } $18, $19, $1A, $1B, $1C, $1D, $1E, $1F,
    { 0x20 } $20, $21, $22, $23, $24, $25, $26, $27,
    { 0x28 } $28, $29, $2A, $2B, $2C, $2D, $2E, $2F,
    { 0x30 } $30, $31, $32, $33, $34, $35, $36, $37,
    { 0x38 } $38, $39, $3A, $3B, $3C, $3D, $3E, $3F,
    { 0x40 } $40, $41, $42, $43, $44, $45, $46, $47,
    { 0x48 } $48, $49, $4A, $4B, $4C, $4D, $4E, $4F,
    { 0x50 } $50, $51, $52, $53, $54, $55, $56, $57,
    { 0x58 } $58, $59, $5A, $5B, $5C, $5D, $5E, $5F,
    { 0x60 } $60, $61, $62, $63, $64, $65, $66, $67,
    { 0x68 } $68, $69, $6A, $6B, $6C, $6D, $6E, $6F,
    { 0x70 } $70, $71, $72, $73, $74, $75, $76, $77,
    { 0x78 } $78, $79, $7A, $7B, $7C, $7D, $7E, $7F,
    { 0x80 } $80, $81, $82, $83, $84, $85, $86, $87,
    { 0x88 } $88, $89, $8A, $8B, $8C, $8D, $8E, $8F,
    { 0x90 } $90, $91, $92, $93, $94, $95, $96, $97,
    { 0x98 } $98, $99, $9A, $9B, $9C, $9D, $9E, $9F,
    { 0xA0 } $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7,
    { 0xA8 } $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF,
    { 0xB0 } $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7,
    { 0xB8 } $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF,
    { 0xC0 } $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7,
    { 0xC8 } $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF,
    { 0xD0 } $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7,
    { 0xD8 } $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF,
    { 0xE0 } $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7,
    { 0xE8 } $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF,
    { 0xF0 } $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7,
    { 0xF8 } $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF);

  TableArmenianToAscii: array [$00 .. $FF] of Byte = (
    { 0x00 } $00, $01, $02, $03, $04, $05, $06, $07,
    { 0x08 } $08, $09, $0A, $0B, $0C, $0D, $0E, $0F,
    { 0x10 } $10, $11, $12, $13, $14, $15, $16, $17,
    { 0x18 } $18, $19, $1A, $1B, $1C, $1D, $1E, $1F,
    { 0x20 } $20, $21, $22, $23, $24, $25, $26, $27,
    { 0x28 } $28, $29, $2A, $2B, $2C, $2D, $2E, $2F,
    { 0x30 } $30, $31, $32, $33, $34, $35, $36, $37,
    { 0x38 } $38, $39, $3A, $3B, $3C, $3D, $3E, $3F,
    { 0x40 } $40, $41, $42, $43, $44, $45, $46, $47,
    { 0x48 } $48, $49, $4A, $4B, $4C, $4D, $4E, $4F,
    { 0x50 } $50, $51, $52, $53, $54, $55, $56, $57,
    { 0x58 } $58, $59, $5A, $5B, $5C, $5D, $5E, $5F,
    { 0x60 } $60, $61, $62, $63, $64, $65, $66, $67,
    { 0x68 } $68, $69, $6A, $6B, $6C, $6D, $6E, $6F,
    { 0x70 } $70, $71, $72, $73, $74, $75, $76, $77,
    { 0x78 } $78, $79, $7A, $7B, $7C, $7D, $7E, $7F,
    { 0x80 } $80, $81, $82, $83, $84, $85, $86, $87,
    { 0x88 } $88, $89, $8A, $8B, $8C, $8D, $8E, $8F,
    { 0x90 } $90, $91, $92, $93, $94, $95, $96, $97,
    { 0x98 } $98, $99, $9A, $9B, $9C, $9D, $9E, $9F,
    { 0xA0 } $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7,
    { 0xA8 } $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF,
    { 0xB0 } $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7,
    { 0xB8 } $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF,
    { 0xC0 } $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7,
    { 0xC8 } $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF,
    { 0xD0 } $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7,
    { 0xD8 } $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF,
    { 0xE0 } $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7,
    { 0xE8 } $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF,
    { 0xF0 } $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7,
    { 0xF8 } $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF);

  { Converts Unicode string to Ansi string using specified code page.
    @param   ws       Unicode string.
    @param   codePage Code page to be used in conversion.
    @returns Converted ansi string.
  }

function AnsiToUnicode(const Text: AnsiString; CodePage: Word): WideString;
var
  Len: Integer;
begin
  Result := '';
  if Text = '' then
    Exit;
  Len := MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PAnsiChar(@Text[1]),
    -1, nil, 0);
  SetLength(Result, Len - 1);
  if Len > 1 then
    MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PAnsiChar(@Text[1]), -1,
      PWideChar(@Result[1]), Len - 1);
end;

function UnicodeToAnsi(const Text: WideString; CodePage: Integer): string;
var
  Len: Integer;
begin
  Result := '';
  if Text = '' then
    Exit;
  Len := WideCharToMultiByte(CodePage, WC_COMPOSITECHECK or WC_DISCARDNS or
    WC_SEPCHARS or WC_DEFAULTCHAR, @Text[1], -1, nil, 0, nil, nil);
  SetLength(Result, Len - 1);
  if Len > 1 then
    WideCharToMultiByte(CodePage, WC_COMPOSITECHECK or WC_DISCARDNS or
      WC_SEPCHARS or WC_DEFAULTCHAR, @Text[1], -1, @Result[1], Len - 1,
      nil, nil);
end;

function UnicodeToArmenian(const Text: WideString): WideString;
var
  C: Byte;
  W: Word;
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Text) do
  begin
    W := Ord(Text[i]);
    C := Lo(W);
    if (W >= Low(TableUnicodeToArmenian)) and (W <= High(TableUnicodeToArmenian))
    then
    begin
      C := TableUnicodeToArmenian[W];
    end;
    Result := Result + Chr(C);
  end;
end;

function ArmenianToUnicode(const Text: string): WideString;
var
  C: Byte;
  W: Word;
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Text) do
  begin
    C := Ord(Text[i]);
    W := TableArmenianToUnicode[Ord(C)];
    Result := Result + WideChar(W);
  end;
end;

function AsciiToArmenian(const Text: WideString): string;
var
  C: Byte;
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Text) do
  begin
    C := Ord(Text[i]);
    C := TableAsciiToArmenian[C];
    Result := Result + Chr(C);
  end;
end;

function ArmenianToAscii(const Text: string): WideString;
var
  C: Byte;
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Text) do
  begin
    C := Ord(Text[i]);
    C := TableArmenianToAscii[C];
    Result := Result + Chr(C);
  end;
end;

function GetText(const Text: string): WideString;
begin
  Result := AnsiToUnicode(Text, 1251);
end;

end.
