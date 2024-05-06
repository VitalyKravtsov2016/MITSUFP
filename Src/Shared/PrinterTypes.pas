unit PrinterTypes;

interface

uses
  // VCL
  Windows, SysUtils,
  // This
  BinUtils, DriverTypes, TextEncoding, LangUtils;

const
  CRLF = #13#10;

  /////////////////////////////////////////////////////////////////////////////

  BAUD_RATE_CODE_2400   = 0;
  BAUD_RATE_CODE_4800   = 1;
  BAUD_RATE_CODE_9600   = 2;
  BAUD_RATE_CODE_19200  = 3;
  BAUD_RATE_CODE_38400  = 4;
  BAUD_RATE_CODE_57600  = 5;
  BAUD_RATE_CODE_115200 = 6;
  BAUD_RATE_CODE_230400 = 7;
  BAUD_RATE_CODE_460800 = 8;
  BAUD_RATE_CODE_921600 = 9;

  BAUD_RATE_CODE_MIN = BAUD_RATE_CODE_2400;
  BAUD_RATE_CODE_MAX = BAUD_RATE_CODE_921600;

  BAUD_RATE_CODE_SEARCH_ORDER: array[1..10] of Integer =
                                (BAUD_RATE_CODE_115200,
                                 BAUD_RATE_CODE_4800,
                                 BAUD_RATE_CODE_19200,
                                 BAUD_RATE_CODE_9600,
                                 BAUD_RATE_CODE_38400,
                                 BAUD_RATE_CODE_57600,
                                 BAUD_RATE_CODE_230400,
                                 BAUD_RATE_CODE_460800,
                                 BAUD_RATE_CODE_921600,
                                 BAUD_RATE_CODE_2400
                                );

  // 2D barcode alignment constants

  BARCODE_2D_ALIGNMENT_LEFT     = 0;
  BARCODE_2D_ALIGNMENT_CENTER   = 1;
  BARCODE_2D_ALIGNMENT_RIGHT    = 2;


  BARCODE_TYPE_QR_GRAPH = 100;

type

  { TPrinterDate }

  TPrinterDate = packed record
    Day: Byte;
    Month: Byte;
    Year: Byte;
  end;

  { TPrinterTime }

  TPrinterTime = packed record
    Hour: Byte;
    Min: Byte;
    Sec: Byte;
  end;

  { TPrinterDateTime }

  TPrinterDateTime = packed record
    Day: Byte;
    Month: Byte;
    Year: Byte;
    Hour: Byte;
    Min: Byte;
    Sec: Byte;
  end;


  { T2DBarcode }

  T2DBarcode = record
    Password: DWORD;
    BarcodeType: Byte;
    DataLength: Word;
    BlockNumber: Byte;
    Parameter1: Byte;
    Parameter2: Byte;
    Parameter3: Byte;
    Parameter4: Byte;
    Parameter5: Byte;
    Alignment: Byte;
  end;

  { TBlockData }

  TBlockData = record
    Password: DWORD;
    BlockType: Byte;
    BlockNumber: Byte;
    BlockData: AnsiString;
  end;

  { TPrinterError }

  TPrinterError = class
  public
    class function GetDescription(Code: Integer; ACapFN: Boolean = False): WideString;
  end;

  { TFontRec }

  TFontRec = record
    LineWidth: Integer;
    CharWidth: Integer;
    CharHeight: Integer;
  end;

  { TPrinterString }

  TPrinterString = class
  public
    class function Convert(const S: string): string;
  end;

  { T1CTax }

  T1CTax = array[1..4] of Single;
  TTaxNames = array[1..6] of string;


//  FDepartments = array[1..]

  { T1CPayNames }

  T1CPayNames = array[1..3] of string;

  TCashierRec = record
    CashierName: WideString;
    CashierPass: Integer;
  end;
  {TCashiers}
  TCashiers = array[1..30] of TCashierRec;

  { T1CDriverParams }

  T1CDriverParams = record
    Port: Integer;
    Speed: Integer;
    UserPassword: string;
    AdminPassword: string;
    Timeout: Integer;
    RegNumber: string;
    SerialNumber: string;
    Tax: T1CTax;
    CloseSession: Boolean;
    EnableLog: Boolean;
    PayNames: T1CPayNames;
    Cashiers: TCashiers;
    PrintLogo: Boolean;
    LogoSize: Integer;
    ConnectionType: Integer;
    ComputerName: string;
    IPAddress: string;
    TCPPort: Integer;
    ProtocolType: Integer;
    BufferStrings: Boolean;
    Codepage: Integer;
    BarcodeFirstLine: Integer;
    QRCodeHeight: Integer;
  end;

const

  // ������ �����-��-� ��� ������
  ElvesFRKFonts: array [1..7] of TFontRec = (
   (LineWidth: 384; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 384; CharWidth: 24; CharHeight: 45;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 384; CharWidth: 24; CharHeight: 25;),
   (LineWidth: 384; CharWidth: 10; CharHeight: 19;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 25;));

  // ������ �����-��-� �� �������
  ElvesFRKFontsCompressed: array [1..7] of TFontRec = (
   (LineWidth: 384; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 384; CharWidth: 24; CharHeight: 22;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 384; CharWidth: 24; CharHeight: 25;),
   (LineWidth: 384; CharWidth: 10; CharHeight: 19;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 12;));

  // ������ �����-��-� ������ 3 (������ �� ������)
  FRF3Fonts: array [1..2] of TFontRec = (
   (LineWidth: 432; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 432; CharWidth: 24; CharHeight: 45;));

  // ������ �����-��-� ������ 4 ��� ������
  FRF4Fonts: array [1..7] of TFontRec = (
   (LineWidth: 432; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 432; CharWidth: 24; CharHeight: 45;),
   (LineWidth: 432; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 432; CharWidth: 24; CharHeight: 25;),
   (LineWidth: 400; CharWidth: 10; CharHeight: 19;),
   (LineWidth: 432; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 432; CharWidth: 12; CharHeight: 25;));

  // ������ �����-��-� ������ 4 �� �������
  FRF4FontsCompressed: array [1..7] of TFontRec = (
   (LineWidth: 432; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 432; CharWidth: 24; CharHeight: 22;),
   (LineWidth: 432; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 432; CharWidth: 24; CharHeight: 25;),
   (LineWidth: 400; CharWidth: 10; CharHeight: 19;),
   (LineWidth: 432; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 432; CharWidth: 12; CharHeight: 12;));

  // ������ �����-500 ��� ������
  Shtrih500Fonts: array [1..9] of TFontRec = (
   (LineWidth: 384; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 384; CharWidth: 24; CharHeight: 45;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 384; CharWidth: 24; CharHeight: 25;),
   (LineWidth: 380; CharWidth: 10; CharHeight: 19;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 384; CharWidth: 24; CharHeight: 45;));

  // ������ �����-500 �� �������
  Shtrih500FontsCompressed: array [1..9] of TFontRec = (
   (LineWidth: 384; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 384; CharWidth: 24; CharHeight: 22;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 384; CharWidth: 24; CharHeight: 25;),
   (LineWidth: 380; CharWidth: 10; CharHeight: 19;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 384; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 384; CharWidth: 24; CharHeight: 22;));

  // ������ �����-950
  Shtrih950Fonts: array [1..7] of TFontRec = (
   (LineWidth: 360; CharWidth:  9; CharHeight: 9;),
   (LineWidth: 360; CharWidth: 18; CharHeight: 9;),
   (LineWidth: 360; CharWidth:  9; CharHeight: 9;),
   (LineWidth: 360; CharWidth: 18; CharHeight: 9;),
   (LineWidth: 360; CharWidth: 11; CharHeight: 9;),
   (LineWidth: 360; CharWidth: 22; CharHeight: 9;),
   (LineWidth: 360; CharWidth:  7; CharHeight: 9;));

  // ������ �����-�����-��-� ��� ������
  ShtrihComboFonts: array [1..7] of TFontRec = (
   (LineWidth: 600; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 600; CharWidth: 24; CharHeight: 45;),
   (LineWidth: 600; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 600; CharWidth: 24; CharHeight: 25;),
   (LineWidth: 600; CharWidth: 10; CharHeight: 19;),
   (LineWidth: 600; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 600; CharWidth: 12; CharHeight: 25;));

  // ������ �����-�����-��-� �� �������
  ShtrihComboFontsCompressed: array [1..7] of TFontRec = (
   (LineWidth: 600; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 600; CharWidth: 24; CharHeight: 22;),
   (LineWidth: 600; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 600; CharWidth: 24; CharHeight: 25;),
   (LineWidth: 600; CharWidth: 10; CharHeight: 19;),
   (LineWidth: 600; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 600; CharWidth: 12; CharHeight: 12;));

  // ������ �����-����-��-� ������ 1 (�������) ��� ������
  ShtrihMiniFonts: array [1..7] of TFontRec = (
   (LineWidth: 600; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 600; CharWidth: 24; CharHeight: 45;),
   (LineWidth: 600; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 600; CharWidth: 24; CharHeight: 25;),
   (LineWidth: 600; CharWidth: 10; CharHeight: 19;),
   (LineWidth: 600; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 600; CharWidth: 12; CharHeight: 25;));

  // ������ �����-����-��-� ������ 1 (�������) �� �������
  ShtrihMiniFontsCompressed: array [1..7] of TFontRec = (
   (LineWidth: 600; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 600; CharWidth: 24; CharHeight: 22;),
   (LineWidth: 600; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 600; CharWidth: 24; CharHeight: 25;),
   (LineWidth: 600; CharWidth: 10; CharHeight: 19;),
   (LineWidth: 600; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 600; CharWidth: 12; CharHeight: 12;));

  // ������ �����-����-��-� ������ 2 (�����) ��� ������
  ShtrihMini2Fonts: array [1..7] of TFontRec = (
   (LineWidth: 432; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 432; CharWidth: 24; CharHeight: 45;),
   (LineWidth: 432; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 432; CharWidth: 24; CharHeight: 25;),
   (LineWidth: 432; CharWidth: 10; CharHeight: 19;),
   (LineWidth: 432; CharWidth: 12; CharHeight: 25;),
   (LineWidth: 432; CharWidth: 12; CharHeight: 25;));

  // ������ �����-����-��-� ������ 2 (�����) �� �������
  ShtrihMini2FontsCompressed: array [1..7] of TFontRec = (
   (LineWidth: 432; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 432; CharWidth: 24; CharHeight: 22;),
   (LineWidth: 432; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 432; CharWidth: 24; CharHeight: 25;),
   (LineWidth: 432; CharWidth: 10; CharHeight: 19;),
   (LineWidth: 432; CharWidth: 12; CharHeight: 12;),
   (LineWidth: 432; CharWidth: 12; CharHeight: 12;));

resourcestring
  SNoDescrpiption = '�������� ����������';

  /////////////////////////////////////////////////////////////////////////////
  // Cash registers

  SCashRegister00 = '���������� ������ � 1 ����� � ����';
  SCashRegister01 = '���������� ������� � 1 ����� � ����';
  SCashRegister02 = '���������� �������� ������ � 1 ����� � ����';
  SCashRegister03 = '���������� �������� ������� � 1 ����� � ����';
  SCashRegister04 = '���������� ������ � 2 ����� � ����';
  SCashRegister05 = '���������� ������� � 2 ����� � ����';
  SCashRegister06 = '���������� �������� ������ � 2 ����� � ����';
  SCashRegister07 = '���������� �������� ������� � 2 ����� � ����';
  SCashRegister08 = '���������� ������ � 3 ����� � ����';
  SCashRegister09 = '���������� ������� � 3 ����� � ����';
  SCashRegister0A = '���������� �������� ������ � 3 ����� � ����';
  SCashRegister0B = '���������� �������� ������� � 3 ����� � ����';
  SCashRegister0C = '���������� ������ � 4 ����� � ����';
  SCashRegister0D = '���������� ������� � 4 ����� � ����';
  SCashRegister0E = '���������� �������� ������ � 4 ����� � ����';
  SCashRegister0F = '���������� �������� ������� � 4 ����� � ����';
  SCashRegister10 = '���������� ������ � 5 ����� � ����';
  SCashRegister11 = '���������� ������� � 5 ����� � ����';
  SCashRegister12 = '���������� �������� ������ � 5 ����� � ����';
  SCashRegister13 = '���������� �������� ������� � 5 ����� � ����';
  SCashRegister14 = '���������� ������ � 6 ����� � ����';
  SCashRegister15 = '���������� ������� � 6 ����� � ����';
  SCashRegister16 = '���������� �������� ������ � 6 ����� � ����';
  SCashRegister17 = '���������� �������� ������� � 6 ����� � ����';
  SCashRegister18 = '���������� ������ � 7 ����� � ����';
  SCashRegister19 = '���������� ������� � 7 ����� � ����';
  SCashRegister1A = '���������� �������� ������ � 7 ����� � ����';
  SCashRegister1B = '���������� �������� ������� � 7 ����� � ����';
  SCashRegister1C = '���������� ������ � 8 ����� � ����';
  SCashRegister1D = '���������� ������� � 8 ����� � ����';
  SCashRegister1E = '���������� �������� ������ � 8 ����� � ����';
  SCashRegister1F = '���������� �������� ������� � 8 ����� � ����';
  SCashRegister20 = '���������� ������ � 9 ����� � ����';
  SCashRegister21 = '���������� ������� � 9 ����� � ����';
  SCashRegister22 = '���������� �������� ������ � 9 ����� � ����';
  SCashRegister23 = '���������� �������� ������� � 9 ����� � ����';
  SCashRegister24 = '���������� ������ � 10 ����� � ����';
  SCashRegister25 = '���������� ������� � 10 ����� � ����';
  SCashRegister26 = '���������� �������� ������ � 10 ����� � ����';
  SCashRegister27 = '���������� �������� ������� � 10 ����� � ����';
  SCashRegister28 = '���������� ������ � 11 ����� � ����';
  SCashRegister29 = '���������� ������� � 11 ����� � ����';
  SCashRegister2A = '���������� �������� ������ � 11 ����� � ����';
  SCashRegister2B = '���������� �������� ������� � 11 ����� � ����';
  SCashRegister2C = '���������� ������ � 12 ����� � ����';
  SCashRegister2D = '���������� ������� � 12 ����� � ����';
  SCashRegister2E = '���������� �������� ������ � 12 ����� � ����';
  SCashRegister2F = '���������� �������� ������� � 12 ����� � ����';
  SCashRegister30 = '���������� ������ � 13 ����� � ����';
  SCashRegister31 = '���������� ������� � 13 ����� � ����';
  SCashRegister32 = '���������� �������� ������ � 13 ����� � ����';
  SCashRegister33 = '���������� �������� ������� � 13 ����� � ����';
  SCashRegister34 = '���������� ������ � 14 ����� � ����';
  SCashRegister35 = '���������� ������� � 14 ����� � ����';
  SCashRegister36 = '���������� �������� ������ � 14 ����� � ����';
  SCashRegister37 = '���������� �������� ������� � 14 ����� � ����';
  SCashRegister38 = '���������� ������ � 15 ����� � ����';
  SCashRegister39 = '���������� ������� � 15 ����� � ����';
  SCashRegister3A = '���������� �������� ������ � 15 ����� � ����';
  SCashRegister3B = '���������� �������� ������� � 15 ����� � ����';
  SCashRegister3C = '���������� ������ � 16 ����� � ����';
  SCashRegister3D = '���������� ������� � 16 ����� � ����';
  SCashRegister3E = '���������� �������� ������ � 16 ����� � ����';
  SCashRegister3F = '���������� �������� ������� � 16 ����� � ����';
  SCashRegister40 = '���������� ������ � ������ � ����';
  SCashRegister41 = '���������� ������ � ������� � ����';
  SCashRegister42 = '���������� ������ � �������� ������ � ����';
  SCashRegister43 = '���������� ������ � �������� ������� � ����';
  SCashRegister44 = '���������� �������� �� ������� � ����';
  SCashRegister45 = '���������� �������� �� ������� � ����';
  SCashRegister46 = '���������� �������� �� �������� ������ � ����';
  SCashRegister47 = '���������� �������� �� �������� ������� � ����';
  SCashRegister48 = '���������� ����� ������ ��������� � ����';
  SCashRegister49 = '���������� ����� ������� ��������� � ����';
  SCashRegister4A = '���������� ����� �������� ������ ��������� � ����';
  SCashRegister4B = '���������� ����� �������� ������� ��������� � ����';
  SCashRegister4C = '���������� ����� ������ ����� ������ 2 � ����';
  SCashRegister4D = '���������� ����� ������� ����� ������ 2 � ����';
  SCashRegister4E = '���������� ����� �������� ������ ����� ������ 2 � ����';
  SCashRegister4F = '���������� ����� �������� ������� ����� ������ 2 � ����';
  SCashRegister50 = '���������� ����� ������ ����� ������ 3 � ����';
  SCashRegister51 = '���������� ����� ������� ����� ������ 3 � ����';
  SCashRegister52 = '���������� ����� �������� ������ ����� ������ 3 � ����';
  SCashRegister53 = '���������� ����� �������� ������� ����� ������ 3 � ����';
  SCashRegister54 = '���������� ����� ������ ����� ������ 4 � ����';
  SCashRegister55 = '���������� ����� ������� ����� ������ 4 � ����';
  SCashRegister56 = '���������� ����� �������� ������ ����� ������ 4 � ����';
  SCashRegister57 = '���������� ����� �������� ������� ����� ������ 4 � ����';
  SCashRegister58 = '������ �� ������ � � ������ � ����';
  SCashRegister59 = '������ �� ������ � � ������� � ����';
  SCashRegister5A = '������ �� ������ � � �������� ������ � ����';
  SCashRegister5B = '������ �� ������ � � �������� ������� � ����';
  SCashRegister5C = '������ �� ������ � � ������ � ����';
  SCashRegister5D = '������ �� ������ � � ������� � ����';
  SCashRegister5E = '������ �� ������ � � �������� ������ � ����';
  SCashRegister5F = '������ �� ������ � � �������� ������� � ����';
  SCashRegister60 = '������ �� ������ � � ������ � ����';
  SCashRegister61 = '������ �� ������ � � ������� � ����';
  SCashRegister62 = '������ �� ������ � � �������� ������ � ����';
  SCashRegister63 = '������ �� ������ � � �������� ������� � ����';
  SCashRegister64 = '������ �� ������ � � ������ � ����';
  SCashRegister65 = '������ �� ������ � � ������� � ����';
  SCashRegister66 = '������ �� ������ � � �������� ������ � ����';
  SCashRegister67 = '������ �� ������ � � �������� ������� � ����';
  SCashRegister68 = '���������� �� ������ � � ������ � ����';
  SCashRegister69 = '���������� �� ������ � � ������� � ����';
  SCashRegister6A = '���������� �� ������ � � �������� ������ � ����';
  SCashRegister6B = '���������� �� ������ � � �������� ������� � ����';
  SCashRegister6C = '���������� �� ������ � � ������ � ����';
  SCashRegister6D = '���������� �� ������ � � ������� � ����';
  SCashRegister6E = '���������� �� ������ � � �������� ������ � ����';
  SCashRegister6F = '���������� �� ������ � � �������� ������� � ����';
  SCashRegister70 = '���������� �� ������ � � ������ � ����';
  SCashRegister71 = '���������� �� ������ � � ������� � ����';
  SCashRegister72 = '���������� �� ������ � � �������� ������ � ����';
  SCashRegister73 = '���������� �� ������ � � �������� ������� � ����';
  SCashRegister74 = '���������� �� ������ � � ������ � ����';
  SCashRegister75 = '���������� �� ������ � � ������� � ����';
  SCashRegister76 = '���������� �� ������ � � �������� ������ � ����';
  SCashRegister77 = '���������� �� ������ � � �������� ������� � ����';
  SCashRegister78 = '���������� � ����� �� ������ �������� ����';
  SCashRegister79 = '���������� ������ � 1 ����� � �����';
  SCashRegister7A = '���������� ������� � 1 ����� � �����';
  SCashRegister7B = '���������� �������� ������ � 1 ����� � �����';
  SCashRegister7C = '���������� �������� ������� � 1 ����� � �����';
  SCashRegister7D = '���������� ������ � 2 ����� � �����';
  SCashRegister7E = '���������� ������� � 2 ����� � �����';
  SCashRegister7F = '���������� �������� ������ � 2 ����� � �����';
  SCashRegister80 = '���������� �������� ������� � 2 ����� � �����';
  SCashRegister81 = '���������� ������ � 3 ����� � �����';
  SCashRegister82 = '���������� ������� � 3 ����� � �����';
  SCashRegister83 = '���������� �������� ������ � 3 ����� � �����';
  SCashRegister84 = '���������� �������� ������� � 3 ����� � �����';
  SCashRegister85 = '���������� ������ � 4 ����� � �����';
  SCashRegister86 = '���������� ������� � 4 ����� � �����';
  SCashRegister87 = '���������� �������� ������ � 4 ����� � �����';
  SCashRegister88 = '���������� �������� ������� � 4 ����� � �����';
  SCashRegister89 = '���������� ������ � 5 ����� � �����';
  SCashRegister8A = '���������� ������� � 5 ����� � �����';
  SCashRegister8B = '���������� �������� ������ � 5 ����� � �����';
  SCashRegister8C = '���������� �������� ������� � 5 ����� � �����';
  SCashRegister8D = '���������� ������ � 6 ����� � �����';
  SCashRegister8E = '���������� ������� � 6 ����� � �����';
  SCashRegister8F = '���������� �������� ������ � 6 ����� � �����';
  SCashRegister90 = '���������� �������� ������� � 6 ����� � �����';
  SCashRegister91 = '���������� ������ � 7 ����� � �����';
  SCashRegister92 = '���������� ������� � 7 ����� � �����';
  SCashRegister93 = '���������� �������� ������ � 7 ����� � �����';
  SCashRegister94 = '���������� �������� ������� � 7 ����� � �����';
  SCashRegister95 = '���������� ������ � 8 ����� � �����';
  SCashRegister96 = '���������� ������� � 8 ����� � �����';
  SCashRegister97 = '���������� �������� ������ � 8 ����� � �����';
  SCashRegister98 = '���������� �������� ������� � 8 ����� � �����';
  SCashRegister99 = '���������� ������ � 9 ����� � �����';
  SCashRegister9A = '���������� ������� � 9 ����� � �����';
  SCashRegister9B = '���������� �������� ������ � 9 ����� � �����';
  SCashRegister9C = '���������� �������� ������� � 9 ����� � �����';
  SCashRegister9D = '���������� ������ � 10 ����� � �����';
  SCashRegister9E = '���������� ������� � 10 ����� � �����';
  SCashRegister9F = '���������� �������� ������ � 10 ����� � �����';
  SCashRegisterA0 = '���������� �������� ������� � 10 ����� � �����';
  SCashRegisterA1 = '���������� ������ � 11 ����� � �����';
  SCashRegisterA2 = '���������� ������� � 11 ����� � �����';
  SCashRegisterA3 = '���������� �������� ������ � 11 ����� � �����';
  SCashRegisterA4 = '���������� �������� ������� � 11 ����� � �����';
  SCashRegisterA5 = '���������� ������ � 12 ����� � �����';
  SCashRegisterA6 = '���������� ������� � 12 ����� � �����';
  SCashRegisterA7 = '���������� �������� ������ � 12 ����� � �����';
  SCashRegisterA8 = '���������� �������� ������� � 12 ����� � �����';
  SCashRegisterA9 = '���������� ������ � 13 ����� � �����';
  SCashRegisterAA = '���������� ������� � 13 ����� � �����';
  SCashRegisterAB = '���������� �������� ������ � 13 ����� � �����';
  SCashRegisterAC = '���������� �������� ������� � 13 ����� � �����';
  SCashRegisterAD = '���������� ������ � 14 ����� � �����';
  SCashRegisterAE = '���������� ������� � 14 ����� � �����';
  SCashRegisterAF = '���������� �������� ������ � 14 ����� � �����';
  SCashRegisterB0 = '���������� �������� ������� � 14 ����� � �����';
  SCashRegisterB1 = '���������� ������ � 15 ����� � �����';
  SCashRegisterB2 = '���������� ������� � 15 ����� � �����';
  SCashRegisterB3 = '���������� �������� ������ � 15 ����� � �����';
  SCashRegisterB4 = '���������� �������� ������� � 15 ����� � �����';
  SCashRegisterB5 = '���������� ������ � 16 ����� � �����';
  SCashRegisterB6 = '���������� ������� � 16 ����� � �����';
  SCashRegisterB7 = '���������� �������� ������ � 16 ����� � �����';
  SCashRegisterB8 = '���������� �������� ������� � 16 ����� � �����';
  SCashRegisterB9 = '���������� ������ � ������ � �����';
  SCashRegisterBA = '���������� ������ � ������� � �����';
  SCashRegisterBB = '���������� ������ � �������� ������ � �����';
  SCashRegisterBC = '���������� ������ � �������� ������� � �����';
  SCashRegisterBD = '���������� �������� �� ������� � �����';
  SCashRegisterBE = '���������� �������� �� ������� � �����';
  SCashRegisterBF = '���������� �������� �� �������� ������ � �����';
  SCashRegisterC0 = '���������� �������� �� �������� ������� � �����';
  SCashRegisterC1 = '���������� ����� ������ ��������� � �����';
  SCashRegisterC2 = '���������� ����� ������� ��������� � �����';
  SCashRegisterC3 = '���������� ����� �������� ������ ��������� � �����';
  SCashRegisterC4 = '���������� ����� �������� ������� ��������� � �����';
  SCashRegisterC5 = '���������� ����� ������ ����� ������ 2 � �����';
  SCashRegisterC6 = '���������� ����� ������� ����� ������ 2 � �����';
  SCashRegisterC7 = '���������� ����� �������� ������ ����� ������ 2 � �����';
  SCashRegisterC8 = '���������� ����� �������� ������� ����� ������ 2 � �����';
  SCashRegisterC9 = '���������� ����� ������ ����� ������ 3 � �����';
  SCashRegisterCA = '���������� ����� ������� ����� ������ 3 � �����';
  SCashRegisterCB = '���������� ����� �������� ������ ����� ������ 3 � �����';
  SCashRegisterCC = '���������� ����� �������� ������� ����� ������ 3 � �����';
  SCashRegisterCD = '���������� ����� ������ ����� ������ 4 � �����';
  SCashRegisterCE = '���������� ����� ������� ����� ������ 4 � �����';
  SCashRegisterCF = '���������� ����� �������� ������ ����� ������ 4 � �����';
  SCashRegisterD0 = '���������� ����� �������� ������� ����� ������ 4 � �����';
  SCashRegisterD1 = '������ �� ������ � � ������ � �����';
  SCashRegisterD2 = '������ �� ������ � � ������� � �����';
  SCashRegisterD3 = '������ �� ������ � � �������� ������ � �����';
  SCashRegisterD4 = '������ �� ������ � � �������� ������� � �����';
  SCashRegisterD5 = '������ �� ������ � � ������ � �����';
  SCashRegisterD6 = '������ �� ������ � � ������� � �����';
  SCashRegisterD7 = '������ �� ������ � � �������� ������ � �����';
  SCashRegisterD8 = '������ �� ������ � � �������� ������� � �����';
  SCashRegisterD9 = '������ �� ������ � � ������ � �����';
  SCashRegisterDA = '������ �� ������ � � ������� � �����';
  SCashRegisterDB = '������ �� ������ � � �������� ������ � �����';
  SCashRegisterDC = '������ �� ������ � � �������� ������� � �����';
  SCashRegisterDD = '������ �� ������ � � ������ � �����';
  SCashRegisterDE = '������ �� ������ � � ������� � �����';
  SCashRegisterDF = '������ �� ������ � � �������� ������ � �����';
  SCashRegisterE0 = '������ �� ������ � � �������� ������� � �����';
  SCashRegisterE1 = '���������� �� ������ � � ������ � �����';
  SCashRegisterE2 = '���������� �� ������ � � ������� � �����';
  SCashRegisterE3 = '���������� �� ������ � � �������� ������ � �����';
  SCashRegisterE4 = '���������� �� ������ � � �������� ������� � �����';
  SCashRegisterE5 = '���������� �� ������ � � ������ � �����';
  SCashRegisterE6 = '���������� �� ������ � � ������� � �����';
  SCashRegisterE7 = '���������� �� ������ � � �������� ������ � �����';
  SCashRegisterE8 = '���������� �� ������ � � �������� ������� � �����';
  SCashRegisterE9 = '���������� �� ������ � � ������ � �����';
  SCashRegisterEA = '���������� �� ������ � � ������� � �����';
  SCashRegisterEB = '���������� �� ������ � � �������� ������ � �����';
  SCashRegisterEC = '���������� �� ������ � � �������� ������� � �����';
  SCashRegisterED = '���������� �� ������ � � ������ � �����';
  SCashRegisterEE = '���������� �� ������ � � ������� � �����';
  SCashRegisterEF = '���������� �� ������ � � �������� ������ � �����';
  SCashRegisterF0 = '���������� �� ������ � � �������� ������� � �����';
  SCashRegisterF1 = '���������� ���������� � �����';
  SCashRegisterF2 = '���������� �������� �� �����';
  SCashRegisterF3 = '���������� ������ �� �����';
  SCashRegisterF4 = '������������ ����� �� ������������';
  SCashRegisterF5 = '����� ������ � ����� �� ����';
  SCashRegisterF6 = '����� ������� � ����� �� ���� ';
  SCashRegisterF7 = '����� ��������� ������ � ����� �� ����';
  SCashRegisterF8 = '����� ��������� ������� � ����� �� ����';
  SCashRegisterF9 = '����� �������������� ������ � �����';
  SCashRegisterFA = '����� �������������� ������� � �����';
  SCashRegisterFB = '����� �������������� ��������� ������ � �����';
  SCashRegisterFC = '����� �������������� ��������� ������� � �����';
  SCashRegisterFF = '���������� �� �������������� � �����';

  // ����������� ��������

  SCashRegister4096 = '���������� ����� ������ ����� ������ 5 � ����';
  SCashRegister4097 = '���������� ����� ������� ����� ������ 5 � ����';
  SCashRegister4098 = '���������� ����� �������� ������ ����� ������ 5 � ����';
  SCashRegister4099 = '���������� ����� �������� ������� ����� ������ 5 � ����';
  SCashRegister4100 = '���������� ����� ������ ����� ������ 6 � ����';
  SCashRegister4101 = '���������� ����� ������� ����� ������ 6 � ����';
  SCashRegister4102 = '���������� ����� �������� ������ ����� ������ 6 � ����';
  SCashRegister4103 = '���������� ����� �������� ������� ����� ������ 6 � ����';
  SCashRegister4104 = '���������� ����� ������ ����� ������ 7 � ����';
  SCashRegister4105 = '���������� ����� ������� ����� ������ 7 � ����';
  SCashRegister4106 = '���������� ����� �������� ������ ����� ������ 7 � ����';
  SCashRegister4107 = '���������� ����� �������� ������� ����� ������ 7 � ����';
  SCashRegister4108 = '���������� ����� ������ ����� ������ 8 � ����';
  SCashRegister4109 = '���������� ����� ������� ����� ������ 8 � ����';
  SCashRegister4110 = '���������� ����� �������� ������ ����� ������ 8 � ����';
  SCashRegister4111 = '���������� ����� �������� ������� ����� ������ 8 � ����';
  SCashRegister4112 = '���������� ����� ������ ����� ������ 9 � ����';
  SCashRegister4113 = '���������� ����� ������� ����� ������ 9 � ����';
  SCashRegister4114 = '���������� ����� �������� ������ ����� ������ 9 � ����';
  SCashRegister4115 = '���������� ����� �������� ������� ����� ������ 9 � ����';
  SCashRegister4116 = '���������� ����� ������ ����� ������ 10 � ����';
  SCashRegister4117 = '���������� ����� ������� ����� ������ 10 � ����';
  SCashRegister4118 = '���������� ����� �������� ������ ����� ������ 10 � ����';
  SCashRegister4119 = '���������� ����� �������� ������� ����� ������ 10 � ����';
  SCashRegister4120 = '���������� ����� ������ ����� ������ 11 � ����';
  SCashRegister4121 = '���������� ����� ������� ����� ������ 11 � ����';
  SCashRegister4122 = '���������� ����� �������� ������ ����� ������ 11 � ����';
  SCashRegister4123 = '���������� ����� �������� ������� ����� ������ 11 � ����';
  SCashRegister4124 = '���������� ����� ������ ����� ������ 12 � ����';
  SCashRegister4125 = '���������� ����� ������� ����� ������ 12 � ����';
  SCashRegister4126 = '���������� ����� �������� ������ ����� ������ 12 � ����';
  SCashRegister4127 = '���������� ����� �������� ������� ����� ������ 12 � ����';
  SCashRegister4128 = '���������� ����� ������ ����� ������ 13 � ����';
  SCashRegister4129 = '���������� ����� ������� ����� ������ 13 � ����';
  SCashRegister4130 = '���������� ����� �������� ������ ����� ������ 13 � ����';
  SCashRegister4131 = '���������� ����� �������� ������� ����� ������ 13 � ����';
  SCashRegister4132 = '���������� ����� ������ ����� ������ 14 � ����';
  SCashRegister4133 = '���������� ����� ������� ����� ������ 14 � ����';
  SCashRegister4134 = '���������� ����� �������� ������ ����� ������ 14 � ����';
  SCashRegister4135 = '���������� ����� �������� ������� ����� ������ 14 � ����';
  SCashRegister4136 = '���������� ����� ������ ����� ������ 15 � ����';
  SCashRegister4137 = '���������� ����� ������� ����� ������ 15 � ����';
  SCashRegister4138 = '���������� ����� �������� ������ ����� ������ 15 � ����';
  SCashRegister4139 = '���������� ����� �������� ������� ����� ������ 15 � ����';
  SCashRegister4140 = '���������� ����� ������ ����� ������ 16 � ����';
  SCashRegister4141 = '���������� ����� ������� ����� ������ 16 � ����';
  SCashRegister4142 = '���������� ����� �������� ������ ����� ������ 16 � ����';
  SCashRegister4143 = '���������� ����� �������� ������� ����� ������ 16 � ����';

  SCashRegister4144 = '���������� ����� ������ ����� ������ 5 � �����';
  SCashRegister4145 = '���������� ����� ������� ����� ������ 5 � �����';
  SCashRegister4146 = '���������� ����� �������� ������ ����� ������ 5 � �����';
  SCashRegister4147 = '���������� ����� �������� ������� ����� ������ 5 � �����';
  SCashRegister4148 = '���������� ����� ������ ����� ������ 6 � �����';
  SCashRegister4149 = '���������� ����� ������� ����� ������ 6 � �����';
  SCashRegister4150 = '���������� ����� �������� ������ ����� ������ 6 � �����';
  SCashRegister4151 = '���������� ����� �������� ������� ����� ������ 6 � �����';
  SCashRegister4152 = '���������� ����� ������ ����� ������ 7 � �����';
  SCashRegister4153 = '���������� ����� ������� ����� ������ 7 � �����';
  SCashRegister4154 = '���������� ����� �������� ������ ����� ������ 7 � �����';
  SCashRegister4155 = '���������� ����� �������� ������� ����� ������ 7 � �����';
  SCashRegister4156 = '���������� ����� ������ ����� ������ 8 � �����';
  SCashRegister4157 = '���������� ����� ������� ����� ������ 8 � �����';
  SCashRegister4158 = '���������� ����� �������� ������ ����� ������ 8 � �����';
  SCashRegister4159 = '���������� ����� �������� ������� ����� ������ 8 � �����';
  SCashRegister4160 = '���������� ����� ������ ����� ������ 9 � �����';
  SCashRegister4161 = '���������� ����� ������� ����� ������ 9 � �����';
  SCashRegister4162 = '���������� ����� �������� ������ ����� ������ 9 � �����';
  SCashRegister4163 = '���������� ����� �������� ������� ����� ������ 9 � �����';
  SCashRegister4164 = '���������� ����� ������ ����� ������ 10 � �����';
  SCashRegister4165 = '���������� ����� ������� ����� ������ 10 � �����';
  SCashRegister4166 = '���������� ����� �������� ������ ����� ������ 10 � �����';
  SCashRegister4167 = '���������� ����� �������� ������� ����� ������ 10 � �����';
  SCashRegister4168 = '���������� ����� ������ ����� ������ 11 � �����';
  SCashRegister4169 = '���������� ����� ������� ����� ������ 11 � �����';
  SCashRegister4170 = '���������� ����� �������� ������ ����� ������ 11 � �����';
  SCashRegister4171 = '���������� ����� �������� ������� ����� ������ 11 � �����';
  SCashRegister4172 = '���������� ����� ������ ����� ������ 12 � �����';
  SCashRegister4173 = '���������� ����� ������� ����� ������ 12 � �����';
  SCashRegister4174 = '���������� ����� �������� ������ ����� ������ 12 � �����';
  SCashRegister4175 = '���������� ����� �������� ������� ����� ������ 12 � �����';
  SCashRegister4176 = '���������� ����� ������ ����� ������ 13 � �����';
  SCashRegister4177 = '���������� ����� ������� ����� ������ 13 � �����';
  SCashRegister4178 = '���������� ����� �������� ������ ����� ������ 13 � �����';
  SCashRegister4179 = '���������� ����� �������� ������� ����� ������ 13 � �����';
  SCashRegister4180 = '���������� ����� ������ ����� ������ 14 � �����';
  SCashRegister4181 = '���������� ����� ������� ����� ������ 14 � �����';
  SCashRegister4182 = '���������� ����� �������� ������ ����� ������ 14 � �����';
  SCashRegister4183 = '���������� ����� �������� ������� ����� ������ 14 � �����';
  SCashRegister4184 = '���������� ����� ������ ����� ������ 15 � �����';
  SCashRegister4185 = '���������� ����� ������� ����� ������ 15 � �����';
  SCashRegister4186 = '���������� ����� �������� ������ ����� ������ 15 � �����';
  SCashRegister4187 = '���������� ����� �������� ������� ����� ������ 15 � �����';
  SCashRegister4188 = '���������� ����� ������ ����� ������ 16 � �����';
  SCashRegister4189 = '���������� ����� ������� ����� ������ 16 � �����';
  SCashRegister4190 = '���������� ����� �������� ������ ����� ������ 16 � �����';
  SCashRegister4191 = '���������� ����� �������� ������� ����� ������ 16 � �����';

  SCashRegister4192 = '������ �� ������ 18/118 � ������ � ����';
  SCashRegister4193 = '������ �� ������ 18/118 � ������� � ����';
  SCashRegister4194 = '������ �� ������ 18/118 � �������� ������ � ����';
  SCashRegister4195 = '������ �� ������ 18/118 � �������� ������� � ����';

  SCashRegister4196 = '������ �� ������ 10/110 � ������ � ����';
  SCashRegister4197 = '������ �� ������ 10/110 � ������� � ����';
  SCashRegister4198 = '������ �� ������ 10/110 � �������� ������ � ����';
  SCashRegister4199 = '������ �� ������ 10/110 � �������� ������� � ����';

  SCashRegister4200 = '���������� �� ������ 18/118 � ������ � ����';
  SCashRegister4201 = '���������� �� ������ 18/118 � ������� � ����';
  SCashRegister4202 = '���������� �� ������ 18/118 � �������� ������ � ����';
  SCashRegister4203 = '���������� �� ������ 18/118 � �������� ������� � ����';

  SCashRegister4204 = '���������� �� ������ 10/110 � ������ � ����';
  SCashRegister4205 = '���������� �� ������ 10/110 � ������� � ����';
  SCashRegister4206 = '���������� �� ������ 10/110 � �������� ������ � ����';
  SCashRegister4207 = '���������� �� ������ 10/110 � �������� ������� � ����';

  SCashRegister4208 = '������ �� ������ 18/118 � ������ � �����';
  SCashRegister4209 = '������ �� ������ 18/118 � ������� � �����';
  SCashRegister4210 = '������ �� ������ 18/118 � �������� ������ � �����';
  SCashRegister4211 = '������ �� ������ 18/118 � �������� ������� � �����';

  SCashRegister4212 = '������ �� ������ 10/110 � ������ � �����';
  SCashRegister4213 = '������ �� ������ 10/110 � ������� � �����';
  SCashRegister4214 = '������ �� ������ 10/110 � �������� ������ � �����';
  SCashRegister4215 = '������ �� ������ 10/110 � �������� ������� � �����';

  SCashRegister4216 = '���������� �� ������ 18/118 � ������ � �����';
  SCashRegister4217 = '���������� �� ������ 18/118 � ������� � �����';
  SCashRegister4218 = '���������� �� ������ 18/118 � �������� ������ � �����';
  SCashRegister4219 = '���������� �� ������ 18/118 � �������� ������� � �����';

  SCashRegister4220 = '���������� �� ������ 10/110 � ������ � �����';
  SCashRegister4221 = '���������� �� ������ 10/110 � ������� � �����';
  SCashRegister4222 = '���������� �� ������ 10/110 � �������� ������ � �����';
  SCashRegister4223 = '���������� �� ������ 10/110 � �������� ������� � �����';

  SCashRegister4224 = '����� ����� ��������� �������';
  SCashRegister4225 = '����� ����� ��������� �������';
  SCashRegister4226 = '����� ����� ��������� �������� �������';
  SCashRegister4227 = '����� ����� ��������� �������� �������';

  // �������� ��

  SCashRegister4228 = '����� ��: ���-�� ����';
  SCashRegister4229 = '����� ��: ���-�� ��������';
  SCashRegister4230 = '����� ��: ���-�� �������� � ��������� ������� �������';
  SCashRegister4231 = '����� ��: �������� ����� �������, ���������� � ���� (���) (������)';
  SCashRegister4232 = '����� ��: �������� ����� �� ����� (���) ��������� (������)';
  SCashRegister4233 = '����� ��: �������� ����� �� ����� (���) ������������ (������)';
  SCashRegister4234 = '����� ��: �������� ����� �� ���� (���) ����������� (������� ������) (������)';
  SCashRegister4235 = '����� ��: �������� ����� �� ���� (���) ����������� (� ������) (������)';
  SCashRegister4236 = '����� ��: �������� ����� �� ���� (���) ��������� ��������������� (������)';
  SCashRegister4237 = '����� ��: �������� ����� ��� ���� �� ������ 18% (������)';
  SCashRegister4238 = '����� ��: �������� ����� ��� ���� �� ������ 10% (������)';
  SCashRegister4239 = '����� ��: �������� ����� ������� �� ���� � ��� �� ������ 0% (������)';
  SCashRegister4240 = '����� ��: �������� ����� ������� �� ���� ��� ��� (������)';
  SCashRegister4241 = '����� ��: �������� ����� ��� ���� �� ����. ������ 18/118 (������)';
  SCashRegister4242 = '����� ��: �������� ����� ��� ���� �� ����. ������ 10/110 (������)';
  SCashRegister4243 = '����� ��: ���-�� �������� � ��������� ������� �������� �������';
  SCashRegister4244 = '����� ��: �������� ����� �������, ���������� � ���� (���) (������� �������)';
  SCashRegister4245 = '����� ��: �������� ����� �� ����� (���) ��������� (������� �������)';
  SCashRegister4246 = '����� ��: �������� ����� �� ����� (���) ������������ (������� �������)';
  SCashRegister4247 = '����� ��: �������� ����� �� ���� (���) ����������� (������� ������) (������� �������)';
  SCashRegister4248 = '����� ��: �������� ����� �� ���� (���) ����������� (� ������) (������� �������)';
  SCashRegister4249 = '����� ��: �������� ����� �� ���� (���) ��������� ��������������� (������� �������)';
  SCashRegister4250 = '����� ��: �������� ����� ��� ���� �� ������ 18% (������� �������)';
  SCashRegister4251 = '����� ��: �������� ����� ��� ���� �� ������ 10% (������� �������)';
  SCashRegister4252 = '����� ��: �������� ����� ������� �� ���� � ��� �� ������ 0% (������� �������)';
  SCashRegister4253 = '����� ��: �������� ����� ������� �� ���� ��� ��� (������� �������)';
  SCashRegister4254 = '����� ��: �������� ����� ��� ���� �� ����. ������ 18/118 (������� �������)';
  SCashRegister4255 = '����� ��: �������� ����� ��� ���� �� ����. ������ 10/110 (������� �������)';
  SCashRegister4256 = '����� ��: ���-�� �������� � ��������� ������� �������';
  SCashRegister4257 = '����� ��: �������� ����� �������, ���������� � ���� (���) (������)';
  SCashRegister4258 = '����� ��: �������� ����� �� ����� (���) ��������� (������)';
  SCashRegister4259 = '����� ��: �������� ����� �� ����� (���) ������������ (������)';
  SCashRegister4260 = '����� ��: �������� ����� �� ���� (���) ����������� (������� ������) (������)';
  SCashRegister4261 = '����� ��: �������� ����� �� ���� (���) ����������� (� ������) (������)';
  SCashRegister4262 = '����� ��: �������� ����� �� ���� (���) ��������� ��������������� (������)';
  SCashRegister4263 = '����� ��: �������� ����� ��� ���� �� ������ 18% (������)';
  SCashRegister4264 = '����� ��: �������� ����� ��� ���� �� ������ 10% (������)';
  SCashRegister4265 = '����� ��: �������� ����� ������� �� ���� � ��� �� ������ 0% (������)';
  SCashRegister4266 = '����� ��: �������� ����� ������� �� ���� ��� ��� (������)';
  SCashRegister4267 = '����� ��: �������� ����� ��� ���� �� ����. ������ 18/118 (������)';
  SCashRegister4268 = '����� ��: �������� ����� ��� ���� �� ����. ������ 10/110 (������)';
  SCashRegister4269 = '����� ��: ���-�� �������� � ��������� ������� �������� �������';
  SCashRegister4270 = '����� ��: �������� ����� �������, ���������� � ���� (���) (������� �������)';
  SCashRegister4271 = '����� ��: �������� ����� �� ����� (���) ��������� (������� �������)';
  SCashRegister4272 = '����� ��: �������� ����� �� ����� (���) ������������ (������� �������)';
  SCashRegister4273 = '����� ��: �������� ����� �� ���� (���) ����������� (������� ������) (������� �������)';
  SCashRegister4274 = '����� ��: �������� ����� �� ���� (���) ����������� (� ������) (������� �������)';
  SCashRegister4275 = '����� ��: �������� ����� �� ���� (���) ��������� ��������������� (������� �������)';
  SCashRegister4276 = '����� ��: �������� ����� ��� ���� �� ������ 18% (������� �������)';
  SCashRegister4277 = '����� ��: �������� ����� ��� ���� �� ������ 10% (������� �������)';
  SCashRegister4278 = '����� ��: �������� ����� ������� �� ���� � ��� �� ������ 0% (������� �������)';
  SCashRegister4279 = '����� ��: �������� ����� ������� �� ���� ��� ��� (������� �������)';
  SCashRegister4280 = '����� ��: �������� ����� ��� ���� �� ����. ������ 18/118 (������� �������)';
  SCashRegister4281 = '����� ��: �������� ����� ��� ���� �� ����. ������ 10/110 (������� �������)';
  SCashRegister4282 = '����� ��: ���-�� ����� ��������� �� ����� ���������� ��������';
  SCashRegister4283 = '����� ��: ���-�� ����� ��������� � ��������� ������� �������';
  SCashRegister4284 = '����� ��: �������� ����� �� ����� ��������� � ��������� ������� �������';
  SCashRegister4285 = '����� ��: ���-�� ����� ��������� � ��������� ������� �������� �������';
  SCashRegister4286 = '����� ��: �������� ����� �� ����� ��������� � ��������� ������� �������� �������';
  SCashRegister4287 = '����� ��: ���-�� ����� ��������� � ��������� ������� �������';
  SCashRegister4288 = '����� ��: �������� ����� �� ����� ��������� � ��������� ������� �������';
  SCashRegister4289 = '����� ��: ���-�� ����� ��������� � ��������� ������� �������� �������';
  SCashRegister4290 = '����� ��: �������� ����� �� ����� ��������� � ��������� ������� �������� �������';
  SCashRegister4291 = '����� ����� ��: ����� �����';
  SCashRegister4292 = '����� ����� ��: ���-�� ��������';
  SCashRegister4293 = '����� ����� ��: ���-�� �������� � ��������� ������� �������';
  SCashRegister4294 = '����� ����� ��: �������� ����� �������, ���������� � ���� (���) (������)';
  SCashRegister4295 = '����� ����� ��: �������� ����� �� ����� (���) ��������� (������)';
  SCashRegister4296 = '����� ����� ��: �������� ����� �� ����� (���) ������������ (������)';
  SCashRegister4297 = '����� ����� ��: �������� ����� �� ���� (���) ����������� (������� ������) (������)';
  SCashRegister4298 = '����� ����� ��: �������� ����� �� ���� (���) ����������� (� ������) (������)';
  SCashRegister4299 = '����� ����� ��: �������� ����� �� ���� (���) ��������� ��������������� (������)';
  SCashRegister4300 = '����� ����� ��: �������� ����� ��� ���� �� ������ 18% (������)';
  SCashRegister4301 = '����� ����� ��: �������� ����� ��� ���� �� ������ 10% (������)';
  SCashRegister4302 = '����� ����� ��: �������� ����� ������� �� ���� � ��� �� ������ 0% (������)';
  SCashRegister4303 = '����� ����� ��: �������� ����� ������� �� ���� ��� ��� (������)';
  SCashRegister4304 = '����� ����� ��: �������� ����� ��� ���� �� ����. ������ 18/118 (������)';
  SCashRegister4305 = '����� ����� ��: �������� ����� ��� ���� �� ����. ������ 10/110 (������)';
  SCashRegister4306 = '����� ����� ��: ���-�� �������� � ��������� ������� �������� �������';
  SCashRegister4307 = '����� ����� ��: �������� ����� �������, ���������� � ���� (���) (������� �������)';
  SCashRegister4308 = '����� ����� ��: �������� ����� �� ����� (���) ��������� (������� �������)';
  SCashRegister4309 = '����� ����� ��: �������� ����� �� ����� (���) ������������ (������� �������)';
  SCashRegister4310 = '����� ����� ��: �������� ����� �� ���� (���) ����������� (������� ������) (������� �������)';
  SCashRegister4311 = '����� ����� ��: �������� ����� �� ���� (���) ����������� (� ������) (������� �������)';
  SCashRegister4312 = '����� ����� ��: �������� ����� �� ���� (���) ��������� ��������������� (������� �������)';
  SCashRegister4313 = '����� ����� ��: �������� ����� ��� ���� �� ������ 18% (������� �������)';
  SCashRegister4314 = '����� ����� ��: �������� ����� ��� ���� �� ������ 10% (������� �������)';
  SCashRegister4315 = '����� ����� ��: �������� ����� ������� �� ���� � ��� �� ������ 0% (������� �������)';
  SCashRegister4316 = '����� ����� ��: �������� ����� ������� �� ���� ��� ��� (������� �������)';
  SCashRegister4317 = '����� ����� ��: �������� ����� ��� ���� �� ����. ������ 18/118 (������� �������)';
  SCashRegister4318 = '����� ����� ��: �������� ����� ��� ���� �� ����. ������ 10/110 (������� �������)';
  SCashRegister4319 = '����� ����� ��: ���-�� �������� � ��������� ������� �������';
  SCashRegister4320 = '����� ����� ��: �������� ����� �������, ���������� � ���� (���) (������)';
  SCashRegister4321 = '����� ����� ��: �������� ����� �� ����� (���) ��������� (������)';
  SCashRegister4322 = '����� ����� ��: �������� ����� �� ����� (���) ������������ (������)';
  SCashRegister4323 = '����� ����� ��: �������� ����� �� ���� (���) ����������� (������� ������) (������)';
  SCashRegister4324 = '����� ����� ��: �������� ����� �� ���� (���) ����������� (� ������) (������)';
  SCashRegister4325 = '����� ����� ��: �������� ����� �� ���� (���) ��������� ��������������� (������)';
  SCashRegister4326 = '����� ����� ��: �������� ����� ��� ���� �� ������ 18% (������)';
  SCashRegister4327 = '����� ����� ��: �������� ����� ��� ���� �� ������ 10% (������)';
  SCashRegister4328 = '����� ����� ��: �������� ����� ������� �� ���� � ��� �� ������ 0% (������)';
  SCashRegister4329 = '����� ����� ��: �������� ����� ������� �� ���� ��� ��� (������)';
  SCashRegister4330 = '����� ����� ��: �������� ����� ��� ���� �� ����. ������ 18/118 (������)';
  SCashRegister4331 = '����� ����� ��: �������� ����� ��� ���� �� ����. ������ 10/110 (������)';
  SCashRegister4332 = '����� ����� ��: ���-�� �������� �������� ������� ������� �������';
  SCashRegister4333 = '����� ����� ��: �������� ����� �������, ���������� � ���� (���) (������� �������)';
  SCashRegister4334 = '����� ����� ��: �������� ����� �� ����� (���) ��������� (������� �������)';
  SCashRegister4335 = '����� ����� ��: �������� ����� �� ����� (���) ������������ (������� �������)';
  SCashRegister4336 = '����� ����� ��: �������� ����� �� ���� (���) ����������� (������� ������) (������� �������)';
  SCashRegister4337 = '����� ����� ��: �������� ����� �� ���� (���) ����������� (� ������) (������� �������)';
  SCashRegister4338 = '����� ����� ��: �������� ����� �� ���� (���) ��������� ��������������� (������� �������)';
  SCashRegister4339 = '����� ����� ��: �������� ����� ��� ���� �� ������ 18% (������� �������)';
  SCashRegister4340 = '����� ����� ��: �������� ����� ��� ���� �� ������ 10% (������� �������)';
  SCashRegister4341 = '����� ����� ��: �������� ����� ������� �� ���� � ��� �� ������ 0% (������� �������)';
  SCashRegister4342 = '����� ����� ��: �������� ����� ������� �� ���� ��� ��� (������� �������)';
  SCashRegister4343 = '����� ����� ��: �������� ����� ��� ���� �� ����. ������ 18/118 (������� �������)';
  SCashRegister4344 = '����� ����� ��: �������� ����� ��� ���� �� ����. ������ 10/110 (������� �������)';
  SCashRegister4345 = '����� ����� ��: ���-�� ����� ��������� �� ����� ���������� ��������';
  SCashRegister4346 = '����� ����� ��: ���-�� ����� ��������� � ��������� ������� �������';
  SCashRegister4347 = '����� ����� ��: �������� ����� �� ����� ��������� � ��������� ������� �������';
  SCashRegister4348 = '����� ����� ��: ���-�� ����� ��������� � ��������� ������� �������� �������';
  SCashRegister4349 = '����� ����� ��: �������� ����� �� ����� ��������� � ��������� ������� �������� �������';
  SCashRegister4350 = '����� ����� ��: ���-�� ����� ��������� � ��������� ������� �������';
  SCashRegister4351 = '����� ����� ��: �������� ����� �� ����� ��������� � ��������� ������� �������';
  SCashRegister4352 = '����� ����� ��: ���-�� ����� ��������� � ��������� ������� �������� �������';
  SCashRegister4353 = '����� ����� ��: �������� ����� �� ����� ��������� � ��������� ������� �������� �������';
  SCashRegister4354 = '������������ ���� ��: ���-�� ������������ ����� � ����� ��������� �� ����� ���������� ��������';
  SCashRegister4355 = '������������ ���� ��: ���-�� ����� � ����� ��������� � ��������� ������� �������';
  SCashRegister4356 = '������������ ���� ��: �������� ����� �� ����� � ����� ��������� � ��������� ������� �������';
  SCashRegister4357 = '������������ ���� ��: ���-�� ����� � ����� ��������� � ��������� ������� �������� �������';
  SCashRegister4358 = '������������ ���� ��: �������� ����� �� ����� � ����� ��������� � ��������� ������� �������� �������';
  SCashRegister4359 = '������������ ���� ��: ���-�� ����� � ����� ��������� � ��������� ������� �������';
  SCashRegister4360 = '������������ ���� ��: �������� ����� �� ����� � ����� ��������� � ��������� ������� �������';
  SCashRegister4361 = '������������ ���� ��: ���-�� ����� � ����� ��������� � ��������� ������� �������� �������';
  SCashRegister4362 = '������������ ���� ��: �������� ����� �� ����� � ����� ��������� � ��������� ������� �������� �������';
  //////////////////////////////

  SCashRegister4363 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 1';
  SCashRegister4364 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 2';
  SCashRegister4365 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 3';
  SCashRegister4366 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 4';
  SCashRegister4367 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 5';
  SCashRegister4368 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 6';
  SCashRegister4369 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 7';
  SCashRegister4370 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 8';
  SCashRegister4371 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 9';
  SCashRegister4372 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 10';
  SCashRegister4373 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 11';
  SCashRegister4374 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 12';
  SCashRegister4375 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 13';
  SCashRegister4376 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 14';
  SCashRegister4377 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 15';
  SCashRegister4378 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 16';

  SCashRegister4379 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 1';
  SCashRegister4380 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 2';
  SCashRegister4381 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 3';
  SCashRegister4382 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 4';
  SCashRegister4383 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 5';
  SCashRegister4384 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 6';
  SCashRegister4385 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 7';
  SCashRegister4386 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 8';
  SCashRegister4387 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 9';
  SCashRegister4388 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 10';
  SCashRegister4389 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 11';
  SCashRegister4390 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 12';
  SCashRegister4391 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 13';
  SCashRegister4392 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 14';
  SCashRegister4393 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 15';
  SCashRegister4394 = '���������� �� ����� ��������� ������� � ����� �� ���� ������ 16';

  SCashRegister4395 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 1';
  SCashRegister4396 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 2';
  SCashRegister4397 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 3';
  SCashRegister4398 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 4';
  SCashRegister4399 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 5';
  SCashRegister4400 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 6';
  SCashRegister4401 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 7';
  SCashRegister4402 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 8';
  SCashRegister4403 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 9';
  SCashRegister4404 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 10';
  SCashRegister4405 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 11';
  SCashRegister4406 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 12';
  SCashRegister4407 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 13';
  SCashRegister4408 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 14';
  SCashRegister4409 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 15';
  SCashRegister4410 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 16';

  SCashRegister4411 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 1';
  SCashRegister4412 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 2';
  SCashRegister4413 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 3';
  SCashRegister4414 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 4';
  SCashRegister4415 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 5';
  SCashRegister4416 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 6';
  SCashRegister4417 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 7';
  SCashRegister4418 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 8';
  SCashRegister4419 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 9';
  SCashRegister4420 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 10';
  SCashRegister4421 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 11';
  SCashRegister4422 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 12';
  SCashRegister4423 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 13';
  SCashRegister4424 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 14';
  SCashRegister4425 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 15';
  SCashRegister4426 = '���������� �� ����� ��������� �������� ������� � ����� �� ���� ������ 16';



  /////////////////////////////////////////////////////////////////////////////
  // Operating registers

  SOperatingRegister00 = '���������� ������ � 1 ����� � ����';
  SOperatingRegister01 = '���������� ������� � 1 ����� � ����';
  SOperatingRegister02 = '���������� �������� ������ � 1 ����� � ����';
  SOperatingRegister03 = '���������� �������� ������� � 1 ����� � ����';
  SOperatingRegister04 = '���������� ������ � 2 ����� � ����';
  SOperatingRegister05 = '���������� ������� � 2 ����� � ����';
  SOperatingRegister06 = '���������� �������� ������ � 2 ����� � ����';
  SOperatingRegister07 = '���������� �������� ������� � 2 ����� � ����';
  SOperatingRegister08 = '���������� ������ � 3 ����� � ����';
  SOperatingRegister09 = '���������� ������� � 3 ����� � ����';
  SOperatingRegister0A = '���������� �������� ������ � 3 ����� � ����';
  SOperatingRegister0B = '���������� �������� ������� � 3 ����� � ����';
  SOperatingRegister0C = '���������� ������ � 4 ����� � ����';
  SOperatingRegister0D = '���������� ������� � 4 ����� � ����';
  SOperatingRegister0E = '���������� �������� ������ � 4 ����� � ����';
  SOperatingRegister0F = '���������� �������� ������� � 4 ����� � ����';
  SOperatingRegister10 = '���������� ������ � 5 ����� � ����';
  SOperatingRegister11 = '���������� ������� � 5 ����� � ����';
  SOperatingRegister12 = '���������� �������� ������ � 5 ����� � ����';
  SOperatingRegister13 = '���������� �������� ������� � 5 ����� � ����';
  SOperatingRegister14 = '���������� ������ � 6 ����� � ����';
  SOperatingRegister15 = '���������� ������� � 6 ����� � ����';
  SOperatingRegister16 = '���������� �������� ������ � 6 ����� � ����';
  SOperatingRegister17 = '���������� �������� ������� � 6 ����� � ����';
  SOperatingRegister18 = '���������� ������ � 7 ����� � ����';
  SOperatingRegister19 = '���������� ������� � 7 ����� � ����';
  SOperatingRegister1A = '���������� �������� ������ � 7 ����� � ����';
  SOperatingRegister1B = '���������� �������� ������� � 7 ����� � ����';
  SOperatingRegister1C = '���������� ������ � 8 ����� � ����';
  SOperatingRegister1D = '���������� ������� � 8 ����� � ����';
  SOperatingRegister1E = '���������� �������� ������ � 8 ����� � ����';
  SOperatingRegister1F = '���������� �������� ������� � 8 ����� � ����';
  SOperatingRegister20 = '���������� ������ � 9 ����� � ����';
  SOperatingRegister21 = '���������� ������� � 9 ����� � ����';
  SOperatingRegister22 = '���������� �������� ������ � 9 ����� � ����';
  SOperatingRegister23 = '���������� �������� ������� � 9 ����� � ����';
  SOperatingRegister24 = '���������� ������ � 10 ����� � ����';
  SOperatingRegister25 = '���������� ������� � 10 ����� � ����';
  SOperatingRegister26 = '���������� �������� ������ � 10 ����� � ����';
  SOperatingRegister27 = '���������� �������� ������� � 10 ����� � ����';
  SOperatingRegister28 = '���������� ������ � 11 ����� � ����';
  SOperatingRegister29 = '���������� ������� � 11 ����� � ����';
  SOperatingRegister2A = '���������� �������� ������ � 11 ����� � ����';
  SOperatingRegister2B = '���������� �������� ������� � 11 ����� � ����';
  SOperatingRegister2C = '���������� ������ � 12 ����� � ����';
  SOperatingRegister2D = '���������� ������� � 12 ����� � ����';
  SOperatingRegister2E = '���������� �������� ������ � 12 ����� � ����';
  SOperatingRegister2F = '���������� �������� ������� � 12 ����� � ����';
  SOperatingRegister30 = '���������� ������ � 13 ����� � ����';
  SOperatingRegister31 = '���������� ������� � 13 ����� � ����';
  SOperatingRegister32 = '���������� �������� ������ � 13 ����� � ����';
  SOperatingRegister33 = '���������� �������� ������� � 13 ����� � ����';
  SOperatingRegister34 = '���������� ������ � 14 ����� � ����';
  SOperatingRegister35 = '���������� ������� � 14 ����� � ����';
  SOperatingRegister36 = '���������� �������� ������ � 14 ����� � ����';
  SOperatingRegister37 = '���������� �������� ������� � 14 ����� � ����';
  SOperatingRegister38 = '���������� ������ � 15 ����� � ����';
  SOperatingRegister39 = '���������� ������� � 15 ����� � ����';
  SOperatingRegister3A = '���������� �������� ������ � 15 ����� � ����';
  SOperatingRegister3B = '���������� �������� ������� � 15 ����� � ����';
  SOperatingRegister3C = '���������� ������ � 16 ����� � ����';
  SOperatingRegister3D = '���������� ������� � 16 ����� � ����';
  SOperatingRegister3E = '���������� �������� ������ � 16 ����� � ����';
  SOperatingRegister3F = '���������� �������� ������� � 16 ����� � ����';
  SOperatingRegister40 = '���������� ������ � ������ � ����';
  SOperatingRegister41 = '���������� ������ � ������� � ����';
  SOperatingRegister42 = '���������� ������ � �������� ������ � ����';
  SOperatingRegister43 = '���������� ������ � �������� ������� � ����';
  SOperatingRegister44 = '���������� �������� �� ������� � ����';
  SOperatingRegister45 = '���������� �������� �� ������� � ����';
  SOperatingRegister46 = '���������� �������� �� �������� ������ � ����';
  SOperatingRegister47 = '���������� �������� �� �������� ������� � ����';
  SOperatingRegister48 = '���������� ������ � 1 ����� � �����';
  SOperatingRegister49 = '���������� ������� � 1 ����� � �����';
  SOperatingRegister4A = '���������� �������� ������ � 1 ����� � �����';
  SOperatingRegister4B = '���������� �������� ������� � 1 ����� � �����';
  SOperatingRegister4C = '���������� ������ � 2 ����� � �����';
  SOperatingRegister4D = '���������� ������� � 2 ����� � �����';
  SOperatingRegister4E = '���������� �������� ������ � 2 ����� � �����';
  SOperatingRegister4F = '���������� �������� ������� � 2 ����� � �����';
  SOperatingRegister50 = '���������� ������ � 3 ����� � �����';
  SOperatingRegister51 = '���������� ������� � 3 ����� � �����';
  SOperatingRegister52 = '���������� �������� ������ � 3 ����� � �����';
  SOperatingRegister53 = '���������� �������� ������� � 3 ����� � �����';
  SOperatingRegister54 = '���������� ������ � 4 ����� � �����';
  SOperatingRegister55 = '���������� ������� � 4 ����� � �����';
  SOperatingRegister56 = '���������� �������� ������ � 4 ����� � �����';
  SOperatingRegister57 = '���������� �������� ������� � 4 ����� � �����';
  SOperatingRegister58 = '���������� ������ � 5 ����� � �����';
  SOperatingRegister59 = '���������� ������� � 5 ����� � �����';
  SOperatingRegister5A = '���������� �������� ������ � 5 ����� � �����';
  SOperatingRegister5B = '���������� �������� ������� � 5 ����� � �����';
  SOperatingRegister5C = '���������� ������ � 6 ����� � �����';
  SOperatingRegister5D = '���������� ������� � 6 ����� � �����';
  SOperatingRegister5E = '���������� �������� ������ � 6 ����� � �����';
  SOperatingRegister5F = '���������� �������� ������� � 6 ����� � �����';
  SOperatingRegister60 = '���������� ������ � 7 ����� � �����';
  SOperatingRegister61 = '���������� ������� � 7 ����� � �����';
  SOperatingRegister62 = '���������� �������� ������ � 7 ����� � �����';
  SOperatingRegister63 = '���������� �������� ������� � 7 ����� � �����';
  SOperatingRegister64 = '���������� ������ � 8 ����� � �����';
  SOperatingRegister65 = '���������� ������� � 8 ����� � �����';
  SOperatingRegister66 = '���������� �������� ������ � 8 ����� � �����';
  SOperatingRegister67 = '���������� �������� ������� � 8 ����� � �����';
  SOperatingRegister68 = '���������� ������ � 9 ����� � �����';
  SOperatingRegister69 = '���������� ������� � 9 ����� � �����';
  SOperatingRegister6A = '���������� �������� ������ � 9 ����� � �����';
  SOperatingRegister6B = '���������� �������� ������� � 9 ����� � �����';
  SOperatingRegister6C = '���������� ������ � 10 ����� � �����';
  SOperatingRegister6D = '���������� ������� � 10 ����� � �����';
  SOperatingRegister6E = '���������� �������� ������ � 10 ����� � �����';
  SOperatingRegister6F = '���������� �������� ������� � 10 ����� � �����';
  SOperatingRegister70 = '���������� ������ � 11 ����� � �����';
  SOperatingRegister71 = '���������� ������� � 11 ����� � �����';
  SOperatingRegister72 = '���������� �������� ������ � 11 ����� � �����';
  SOperatingRegister73 = '���������� �������� ������� � 11 ����� � �����';
  SOperatingRegister74 = '���������� ������ � 12 ����� � �����';
  SOperatingRegister75 = '���������� ������� � 12 ����� � �����';
  SOperatingRegister76 = '���������� �������� ������ � 12 ����� � �����';
  SOperatingRegister77 = '���������� �������� ������� � 12 ����� � �����';
  SOperatingRegister78 = '���������� ������ � 13 ����� � �����';
  SOperatingRegister79 = '���������� ������� � 13 ����� � �����';
  SOperatingRegister7A = '���������� �������� ������ � 13 ����� � �����';
  SOperatingRegister7B = '���������� �������� ������� � 13 ����� � �����';
  SOperatingRegister7C = '���������� ������ � 14 ����� � �����';
  SOperatingRegister7D = '���������� ������� � 14 ����� � �����';
  SOperatingRegister7E = '���������� �������� ������ � 14 ����� � �����';
  SOperatingRegister7F = '���������� �������� ������� � 14 ����� � �����';
  SOperatingRegister80 = '���������� ������ � 15 ����� � �����';
  SOperatingRegister81 = '���������� ������� � 15 ����� � �����';
  SOperatingRegister82 = '���������� �������� ������ � 15 ����� � �����';
  SOperatingRegister83 = '���������� �������� ������� � 15 ����� � �����';
  SOperatingRegister84 = '���������� ������ � 16 ����� � �����';
  SOperatingRegister85 = '���������� ������� � 16 ����� � �����';
  SOperatingRegister86 = '���������� �������� ������ � 16 ����� � �����';
  SOperatingRegister87 = '���������� �������� ������� � 16 ����� � �����';
  SOperatingRegister88 = '���������� ������ � ������ � �����';
  SOperatingRegister89 = '���������� ������ � ������� � �����';
  SOperatingRegister8A = '���������� ������ � �������� ������ � �����';
  SOperatingRegister8B = '���������� ������ � �������� ������� � �����';
  SOperatingRegister8C = '���������� �������� �� ������� � �����';
  SOperatingRegister8D = '���������� �������� �� ������� � �����';
  SOperatingRegister8E = '���������� �������� �� �������� ������ � �����';
  SOperatingRegister8F = '���������� �������� �� �������� ������� � �����';
  SOperatingRegister90 = '���������� ����� ������ � �����';
  SOperatingRegister91 = '���������� ����� ������� � �����';
  SOperatingRegister92 = '���������� ����� �������� ������ � �����';
  SOperatingRegister93 = '���������� ����� �������� ������� � �����';
  SOperatingRegister94 = '����� ���� ������';
  SOperatingRegister95 = '����� ���� �������';
  SOperatingRegister96 = '����� ���� �������� ������';
  SOperatingRegister97 = '����� ���� �������� �������';
  SOperatingRegister98 = '�������� ����� ���������';
  SOperatingRegister99 = '���������� �������� �������� ���� �� �����';
  SOperatingRegister9A = '���������� ������ �������� ���� �� �����';
  SOperatingRegister9B = '����� �������� �������� ����';
  SOperatingRegister9C = '����� ������� �������� ����';
  SOperatingRegister9D = '���������� ���������� ���������� �� �����';
  SOperatingRegister9E = '����� �������� ������ ��� �������';
  SOperatingRegister9F = '����� �������� ������ � �������� �� ������������';
  SOperatingRegisterA0 = '����� ������ �������';
  SOperatingRegisterA1 = '����� ������� ����������� ������';
  SOperatingRegisterA2 = '����� ������������ ����������� ������';
  SOperatingRegisterA3 = '����� ��������� �������';
  SOperatingRegisterA4 = '����� ������ ��������� ������������ ���������';
  SOperatingRegisterA5 = '����� ������� �� �������';
  SOperatingRegisterA6 = '���������� �������������';
  SOperatingRegisterA7 = '���������� �������� ����� ���������������';
  SOperatingRegisterA8 = '���������� ����������� ����';
  SOperatingRegisterA9 = '���������� ������� �� ������ ����������� ����';
  SOperatingRegisterAA = '���������� ������� ��  ������ ���  �� ����';
  SOperatingRegisterAB = '���������� ������� �� ����������� ����� �� ����';
  SOperatingRegisterAC = '���������� ������� ��  ����� �� ����';
  SOperatingRegisterAD = '���������� ������� ��  ������ �� ����';
  SOperatingRegisterAE = '���������� ������� ��  ������ ���� �� ����';
  SOperatingRegisterAF = '���������� ������� ��  ����� � ������ �� ����';
  SOperatingRegisterB0 = '���������� ������� ��  ������ � ������ �� ����';
  SOperatingRegisterB1 = '���������� �������� ������� ����';
  SOperatingRegisterB2 = '����� ������ �� �������';
  SOperatingRegisterB3 = '���������� �������������� ����� ������';
  SOperatingRegisterB4 = '���������� �������������� ����� �������';
  SOperatingRegisterB5 = '���������� �������������� ����� �������� ������';
  SOperatingRegisterB6 = '���������� �������������� ����� �������� �������';
  SOperatingRegisterB7 = '���������� ������������ ���������� � ����';
  SOperatingRegisterB8 = '���������� ������������ ����������';
  SOperatingRegisterB9 = '�������� ����� ���������';
  SOperatingRegisterBA = '�������� ����� ��������� (������� �����)';
  SOperatingRegisterBB = '���������� ������������ �������� �� ��';
  SOperatingRegisterBC = '����� ������� �� ��������';
  SOperatingRegisterBD = '����� ������� ���������';
  SOperatingRegisterBE = '����� ������� �� �������';
  SOperatingRegisterC1 = '���������� ������������ ���������� �� �����';
  SOperatingRegisterC2 = '���������� ������������ ����������';
  SOperatingRegisterC3 = '����� ������� ���������� ��������� � �������� (�������) ������';
  SOperatingRegisterC4 = '����� ������� ���������� ��������� � �������� (�������) ������ (������� �����)';
  SOperatingRegisterC5 = '���������� ������������� �� �����';
  SOperatingRegisterC6 = '���������� ������������� �� ����� (������� �����)';

  SOperatingRegisterB8FN = '���������� ������� � ������ �������';
  SOperatingRegisterB9FN = '�������� ����� ��������� (������� �����)';
  SOperatingRegisterBAFN = '�������� ����� ��������� (������� �����)';
  SUnusedRegister = '�� ������������';
  SOperatingRegisterC4FN = '���������� ����� ������ (������� �����)';
  SOperatingRegisterC5FN = '���������� ����� ������ (������� �����)';
  SOperatingRegisterC6FN = '���������� ������� (������� �����)';
  SOperatingRegisterC7FN = '���������� ������� (������� �����)';

  SOperatingRegisterC8FN = '����� ���������� ����� ��������� �������';
  SOperatingRegisterC9FN = '����� ���������� ����� ��������� �������';
  SOperatingRegisterCAFN = '���������� ����� ��������� ������� �� �����';
  SOperatingRegisterCBFN = '���������� ����� ��������� ������� �� �����';


  {
  B8 - ���������� ������� � ������ �������
  �������� ����� ��������� B9-BA
�������� ����� ������� �� �������� BB
�BC-C3 �� �������
�C4-C5 ���������� ����� ������
�C6-C7 ���������� �������
�C8 - ����� ���������� ����� ��������� �������
�C9 - ����� ���������� ����� ��������� �������
�CA -  ���������� �� ����� �����  ��������� �������
�CB -  ���������� �� ����� ����� ��������� �������
�FF �� ������������}


  SOperatingRegisterFF = '���������� �� �������������� � �����';

  /////////////////////////////////////////////////////////////////////////////
  // Error description

  SErrorDescription00 = '������ ���';
  SErrorDescription01 = '���������� ���������� �� 1, �� 2 ��� ����';
  SErrorDescription02 = '����������� �� 1';
  SErrorDescription03 = '����������� �� 2';
  SErrorDescription04 = '������������ ��������� � ������� ��������� � ��';
  SErrorDescription05 = '��� ����������� ������';
  SErrorDescription06 = '�� � ������ ������ ������';
  SErrorDescription07 = '������������ ��������� � ������� ��� ������ ���������� ��';
  SErrorDescription08 = '������� �� �������������� � ������ ���������� ��';
  SErrorDescription09 = '������������ ����� �������';
  SErrorDescription0A = '������ ������ �� BCD';
  SErrorDescription0B = '���������� ������ ������ �� ��� ������ �����';
  SErrorDescription11 = '�� ������� ��������';
  SErrorDescription12 = '��������� ����� ��� ������';
  SErrorDescription13 = '������� ���� ������ ���� ��������� ������ � ��';
  SErrorDescription14 = '������� ������� ������ �� �����������';
  SErrorDescription15 = '����� ��� �������';
  SErrorDescription16 = '����� �� �������';
  SErrorDescription17 = '����� ������ ����� ������ ������ ��������� �����';
  SErrorDescription18 = '���� ������ ����� ������ ���� ��������� �����';
  SErrorDescription19 = '��� ������ � ��';
  SErrorDescription1A = '������� ��������������� � �� �����������';
  SErrorDescription1B = '��������� ����� �� ������';
  SErrorDescription1C = '� �������� ��������� ���� ������������ ������';
  SErrorDescription1D = '���������� ��������� ������ ������� ������';
  SErrorDescription1E = '������� ��������������� �� �����������';
  SErrorDescription1F = '����������� ������ ���������';
  SErrorDescription20 = '������������ ��������� �������� ��� ����������';
  SErrorDescription21 = '���������� ����� ������ ����������� ��������� ��������';
  SErrorDescription22 = '�������� ����';
  SErrorDescription23 = '��� ������ �����������';
  SErrorDescription24 = '������� ����������� �����������';
  SErrorDescription25 = '��� ����������� � ������������� �������';
  SErrorDescription26 = '� �� ������ 3 ������������ �������';
  SErrorDescription27 = '����������� ����������� ���� ��';
  SErrorDescription28 = '������������ �� �� ���������� ������������ ��';
  SErrorDescription29 = '������������������� ������ ��';
  SErrorDescription2F = '���� �� ��������';
  SErrorDescription30 = '���� �������� NAK';
  SErrorDescription31 = '����: ������ �������';
  SErrorDescription32 = '����: ������ ����������� �����';
  SErrorDescription33 = '������������ ��������� � �������';
  SErrorDescription34 = '��� ������';
  SErrorDescription35 = '������������ �������� ��� ������ ����������';
  SErrorDescription36 = '������������ ��������� � ������� ��� ������ ����������';
  SErrorDescription37 = '������� �� �������������� � ������ ����������';
  SErrorDescription38 = '������ � ���';
  SErrorDescription39 = '���������� ������ ��';
  SErrorDescription3A = '������������ ���������� �� ��������� � �����';
  SErrorDescription3B = '������������ ���������� � �����';
  SErrorDescription3C = '����: �������� ��������������� �����';
  SErrorDescription3D = '����� �� ������� - �������� ����������';
  SErrorDescription3E = '������������ ���������� �� ������� � �����';
  SErrorDescription3F = '������������ ���������� �� ������� � �����';
  SErrorDescription40 = '������������ ��������� ������';
  SErrorDescription41 = '������������ ��������� ������ ���������';
  SErrorDescription42 = '������������ ��������� ������ ����� 2';
  SErrorDescription43 = '������������ ��������� ������ ����� 3';
  SErrorDescription44 = '������������ ��������� ������ ����� 4';
  SErrorDescription45 = 'C���� ���� ����� ������ ������ ����� ����';
  SErrorDescription46 = '�� ������� ���������� � �����';
  SErrorDescription47 = '������������ ���������� �� ������� � �����';
  SErrorDescription48 = '������������ ����� ����';
  SErrorDescription49 = '�������� ���������� � �������� ���� ������� ����';
  SErrorDescription4A = '������ ��� - �������� ����������';
  SErrorDescription4B = '����� ���� ����������';
  SErrorDescription4C = '������������ ���������� �� ������� ������� � �����';
  SErrorDescription4D = '�������� ����������� ������� ����� ������ ����� ����';
  SErrorDescription4E = '����� ��������� 24 ����';
  SErrorDescription4F = '�������� ������';
  SErrorDescription50 = '���� ������ ���������� �������';
  SErrorDescription51 = '������������ ���������� ��������� � �����';
  SErrorDescription52 = '������������ ���������� �� ���� ������ 2 � �����';
  SErrorDescription53 = '������������ ���������� �� ���� ������ 3 � �����';
  SErrorDescription54 = '������������ ���������� �� ���� ������ 4 � �����';
  SErrorDescription55 = '��� ������ - �������� ����������';
  SErrorDescription56 = '��� ��������� ��� �������';
  SErrorDescription57 = '����: ���������� �������� ���� �� ��������� � ��';
  SErrorDescription58 = '�������� ������� ����������� ������';
  SErrorDescription59 = '�������� ������ ������ ����������';
  SErrorDescription5A = '������ ��������� ���������� � ����';
  SErrorDescription5B = '������������ ��������� ��������';
  SErrorDescription5C = '�������� ���������� 24�';
  SErrorDescription5D = '������� �� ����������';
  SErrorDescription5E = '������������ ��������';
  SErrorDescription5F = '������������� ���� ����';
  SErrorDescription60 = '������������ ��� ���������';
  SErrorDescription61 = '������������ ��������� ����';
  SErrorDescription62 = '������������ ��������� ����������';
  SErrorDescription63 = '������������ ��������� ������';
  SErrorDescription64 = '�� �����������';
  SErrorDescription65 = '�� ������� ����� � ������';
  SErrorDescription66 = '������������ ����� � ������';
  SErrorDescription67 = '������ ����� � ��';
  SErrorDescription68 = '�� ������� ����� �� ������� �������';
  SErrorDescription69 = '������������ ����� �� ������� �������';
  SErrorDescription6A = '������ ������� � ������ ������ �� I2C';
  SErrorDescription6B = '��� ������� �����';
  SErrorDescription6C = '��� ����������� �����';
  SErrorDescription6D = '�� ������� ����� �� ������';
  SErrorDescription6E = '������������ ����� �� ������';
  SErrorDescription6F = '������������ �� ������� � �����';
  SErrorDescription70 = '������������ ��';
  SErrorDescription71 = '������ ���������';
  SErrorDescription72 = '������� �� �������������� � ������ ���������';
  SErrorDescription73 = '������� �� �������������� � ������ ������';
  SErrorDescription74 = '������ ���';
  SErrorDescription75 = '������ �������';
  SErrorDescription76 = '������ ��������: ��� ��������� � ��������������';
  SErrorDescription77 = '������ ��������: ��� ������� � ��������';
  SErrorDescription78 = '������ ��';
  SErrorDescription79 = '������ ��';
  SErrorDescription7A = '���� �� �������������';
  SErrorDescription7B = '������ ������������';
  SErrorDescription7C = '�� ��������� ����';
  SErrorDescription7D = '�������� ������ ����';
  SErrorDescription7E = '�������� �������� � ���� �����';
  SErrorDescription7F = '������������ ��������� �����';
  SErrorDescription80 = '������ ����� � ��';
  SErrorDescription81 = '������ ����� � ��';
  SErrorDescription82 = '������ ����� � ��';
  SErrorDescription83 = '������ ����� � ��';
  SErrorDescription84 = '������������ ����������';
  SErrorDescription85 = '������������ �� �������� � �����';
  SErrorDescription86 = '������������ �� �������� � �����';
  SErrorDescription87 = '������������ �� ��������� ������ � �����';
  SErrorDescription88 = '������������ �� ��������� ������� � �����';
  SErrorDescription89 = '������������ �� �������� � �����';
  SErrorDescription8A = '������������ �� ��������� � ����';
  SErrorDescription8B = '������������ �� ������� � ����';
  SErrorDescription8C = '������������� ���� �������� � ����';
  SErrorDescription8D = '������������� ���� ������ � ����';
  SErrorDescription8E = '������� ���� ����';
  SErrorDescription8F = '����� �� ���������������';
  SErrorDescription90 = '���� ��������� ������ ������������� � ����������';
  SErrorDescription91 = '����� �� ������� ���� ������ ��� ������ ���������� ������';
  SErrorDescription92 = '��������� �����';
  SErrorDescription93 = '�������������� ��� ������ �������';
  SErrorDescription94 = '�������� ����� �������� � ����';
  SErrorDescription95 = '����������� ������ ����';
  SErrorDescriptionA0 = '������ ����� � ����';
  SErrorDescriptionA1 = '���� �����������';
  SErrorDescriptionA2 = '����: ������������ ������ ��� �������� �������';
  SErrorDescriptionA3 = '������������ ��������� ����';
  SErrorDescriptionA4 = '������ ����';
  SErrorDescriptionA5 = '������ �� � ������� ����';
  SErrorDescriptionA6 = '�������� ��������� ������ ����';
  SErrorDescriptionA7 = '���� �����������';
  SErrorDescriptionA8 = '����: �������� ���� ��� �����';
  SErrorDescriptionA9 = '����: ��� ����������� ������';
  SErrorDescriptionAA = '������������ ���� (������������� ���� ���������)';
  SErrorDescriptionAB = '��������� ���������� ������� ���������� ���������� �����������';
  SErrorDescriptionAC = '�������� ��� ���������� �����������';
  SErrorDescriptionAD = '����������� ������ ��������� ����� ���';
  SErrorDescriptionAE = '����������� ������ ���';
  SErrorDescriptionAF = '����������� ������ ����� ��������� �����';
  SErrorDescriptionB0 = '����: ������������ � ��������� ����������';
  SErrorDescriptionB1 = '����: ������������ � ��������� �����';
  SErrorDescriptionB2 = '����: ��� ��������������';
  SErrorDescriptionB3 = '����������� ������� ���� � �����';
  SErrorDescriptionC0 = '�������� ���� � ������� (����������� ���� � �����)';
  SErrorDescriptionC1 = '����: �������� ����� � �������� �������� ������';
  SErrorDescriptionC2 = '���������� ���������� ����� �������';
  SErrorDescriptionC3 = '������������ ������ ���� � ����';
  SErrorDescriptionC4 = '������������ ������� ����';
  SErrorDescriptionC5 = '����� ����������� ��������� ����';
  SErrorDescriptionC6 = '���������� �������� �����������';
  SErrorDescriptionC7 = '���� �� ������������� � ������ ������';
  SErrorDescriptionC8 = '������ ����� � ���������';
  SErrorDescriptionC9 = '�������� ���������� �������';
  SerrorDescriptionCA = '����������� ��� ������� ������������';
  SerrorDescriptionCB = '������������ �������� ��������� ������';
  SErrorDescriptionD0 = '�� ����������� ����������� ����� �� ����� �� ����';
  SErrorDescriptionD1 = '��� ������ � ������';
  SErrorDescriptionD2 = '�������� �������� ����� ��� ������ ���������� ����������';
  SErrorDescriptionD3 = '��� ������ �� ���������';
  SErrorDescriptionD4 = '��� ���������� ���������������';
  SErrorDescriptionD5 = '������ �����������';
  SErrorDescriptionE0 = '������ ����� � ����������������';
  SErrorDescriptionE1 = '�������������� �����';
  SErrorDescriptionE2 = '���� ���� �� ������������� ����� ���������������';
  SErrorDescriptionE3 = '������ ���������������';
  SErrorDescriptionE4 = '���� ��������������� �� �������';

  SErrorDescriptionF0 = '������ �������� � ��';
  SErrorDescriptionF1 = '������ ������ �� ��';
  SErrorDescriptionF2 = '����� ������� ������';
  SErrorDescriptionF3 = '������������ ������';
  SErrorDescriptionF4 = '��� ����������� �����';
  SErrorDescriptionF5 = '������������ ����� ������';


  { =====================================================
    ������ ��
  02h	������ ��������� ��|	������ ������� ������� ������� ��������� �� ��� ������ ���� ��������� ������� ���������� �������
  03h	����� ��|	��������� ����������� �������� � �������� ������. ������������� ��.
  04h	����� ��|	��������� ����������� �������� � �������� ������. ������������� ��.
  05h	��������� ������� �� ������������� ����� ����� ��|	���������� �������� ��������� �������
  07h	������������ ���� �/��� �����|	���� � ����� �������� �� ������������� ������������� �����������
  08h	��� ����������� ������|	����������� ������ ����������� � ������ ��
  09h	������������ �������� ���������� �������|	��������� ������� ����� ���������� ������, �� �� �������� �� �����
  0Ah	������������ �������. ��� ������ ����������� ������ � ������, ���� �� ������������� � ������ ��������� ���-1.1)|
    	� ������ ������ ���������������� �� ������� �� ���������
  0Bh	������������� ���������. (��� ������ ����������� ������ � ������, ���� �� ������������� � ������ ��������� ���-1.1)|
      �� �������� ��������� ��� � ����� ������� 07h ��� �������� � �� ������, ������� ������ ����������� ��. ����� ������������� ���������, ����������� ��� � ��, ���������� �� � ��� � ������ ������ (Uint16, LE)
  0Ch	������������ ������	|��� �������� ������, ������� ��� ���� �������� � ������� ������� ���������. ����� ������������ ��������� ��������� � ������ ������ (Uint16, LE)
  0Dh	����������� ������, ����������� ��� ����������� ����� � �� |	��� ����������� ����� � �������� ���������� ������, ��������� �������� ����������� ������ � ��
      ��� ������ ���������� ����� ����� ��������� ���. ���� ������, ����������� �� ����������� ����� �� ������ ����� ������
  0Eh	���������� ������� � ���������, ��������� ���������� ������|	�� �������� � ��� ���� ��� ������, ���� ������������ ����� �������, ��������� ���������� �������
  10h	���������� �������� TLV ������|	������ ������������ ������, ������� TLV ���������, �������� ����������
  11h	��� ������������� ����������|	������������ ���������� (��) �����������. ���������� ���������� �� � ��� � �������� � �� ������� "������������ ���������� � ���"
  12h	�������� ������ ��|	��������� �������� ��
  14h	����������� ������� ��|	����� ���� ����� � ���������� �������, � ��������� � ������� ��������������.
      ���� ����� ���� "��������� ����� �������� ������ ���", �� ��� ������, ��� ����� ���������� � ������� ������ ������� ��������� �� ������ ����� 30 ����������� ����. ������ ��� � ������ �������� ������. ���������� �������� ��������� � ���.
      ���� ����� ���� "����� �� �������� �� 90 %", �� ��� �������, ��� ����� �� ��������� �������� - ���������� ������� ��.
      ���� ����� �������������� �����������, �� ��� ��������, ��� ������ 30 �������� �������� ��� ���������� ��� ��� ��������.
  16h	����������������� ����� ���������|	����������������� ����� ��������� 24 ����. ��������� ������� �����.
  17h	������������ ������ � ���������� ������� ����� ����������� �����������|	������ � ���������� ������� ����� ����������� � ���������� ���������� ����������, ��������� ���, ����� ��� �� 5 ����� ��������� ������ �� ���� ���������� �������, ������������� �� ������� ��
  18h ������������ ��������, ���������� ��� � �� |	��������, ���������� ��� � ��, �� ������������� ������������� �����������.
      ����� ������������� ��������� ��������� � ������ ������ (Uint16, LE)
  19h ������������ �������� � ��������� ������� ������������ ������|	���������� ��������, ���������� � ��, �������� ������� "������� ������������ ������", ����� � ����������� ��� ������� ����� �� ��������� ���������� �����������, ���������� � ��, �� �������� ������� "������� ������������ ������"
  20h	��������� ��� �� ����� ���� �������|	��������� ��� �� ����� ���� �������, ����������� ������ ������ ��������� ������� ������ � �������� ���������
  }




  {
 02h	������ ��������� ��
03h	����� ��
04h	����� ��
05h	��������� ������� �� ������������� ����� ����� ��
07h	������������ ���� �/��� �����
08h	��� ����������� ������
09h	������������ �������� ���������� �������
0Ah	������������ �������.
0Bh	������������� ���������.
0Ch	������������ ������
0Dh	����������� ������, ����������� ��� ����������� ����� � ��
0Eh	���������� ������� � ���������, ��������� ���������� ������
10h	���������� �������� TLV ������
11h	��� ������������� ����������
12h	�������� ������ ��
14h	����������� ������� ��
16h	����������������� ����� ���������
17h	������������ ������ � ���������� ������� ����� ����������� �����������
18h ������������ ��������, ���������� ��� � ��
19h �������� �� ������������� ���������� ��� �����������
20h	������ ��� ��������� ������ � ��
23h	������ ������� ���������� ������ �������� ����� ����������
24h	����������� ����� ������� ���������� ������ ��������

32h + 6E = A0	��������� ������ � ������������� ��������
33h	A1 �������� ������������������ ������ ������ Bxh
34h	A2 ������ � �������������� �������� �������� �������������
35h	A3 ����������� ������� �������� ��
3Ch	AA � ����� TLV ����������� ����������� ���������
3Eh	AC � ��������� 2007 ���������� ��, ������� ����� �� ���������� � ��

}





  SErrorDescription01FN = '����������� �������, �������� ������ ������� ��� ����������� ���������';
  SErrorDescription02FN = '������ ��������� ��';
  SErrorDescription03FN = '����� ��';
  SErrorDescription04FN = '����� ��';
  SErrorDescription05FN = '��������� ������� �� ������������� ����� ����� ��';
  SErrorDescription06FN = '����� �� ����������';
  SErrorDescription07FN = '�������� ���� �/��� �����';
  SErrorDescription08FN = '��� ����������� ������';
  SErrorDescription09FN = '������������ �������� ���������� �������';
  SErrorDescription0AFN = '������������ �������';
  SErrorDescription0BFN = '������������� ���������';
  SErrorDescription0CFN = '������������ ������';
  SErrorDescription0DFN = '����������� ������, ����������� ��� ����������� ����� � ��';
  SErrorDescription0EFN = '���������� ������� � ��������� ��������� ���������� ������';
  SErrorDescription10FN = '���������� �������� TLV ������';
  SErrorDescription11FN = '��� ������������� ����������';
  SErrorDescription12FN = '�������� ������ ��';
  SErrorDescription14FN = '����������� ������� ��';
  SErrorDescription15FN = '�������� ������ �������� �������� ���������';
  SErrorDescription16FN = '����������������� ����� ����� 24 �����';
  SErrorDescription17FN = '������������ ������ � ���������� ������� ����� ����������� �����������';
  SErrorDescription18FN = '������������ ��������, ���������� ��� � ��';
  SErrorDescription19FN = '�������� �� ������������� ���������� ��� �����������';
  SErrorDescription20FN = '������ ��� ��������� ������ � ��';
  SErrorDescription21FN = '��� ����� � ��. ��������� ������ !!!';
  SErrorDescription30FN = '�� �� ��������';
  SErrorDescription77FN = '������ ��������';
  SErrorDescription79FN = '������ �����';

  SErrorDescription23FN =	'������ ������� ���������� ������ �������� ����� ����������';
  SErrorDescription24FN =	'����������� ����� ������� ���������� ������ ��������';
  SErrorDescriptionA0FN = '��������� ������ � ������������� ��������';
  SErrorDescriptionA1FN = '�������� ������������������ ������ ������ Bxh';
  SErrorDescriptionA2FN = '������ � �������������� �������� �������� �������������';
  SErrorDescriptionA3FN = '����������� ������� �������� ��';
  SErrorDescriptionAAFN = '� ����� TLV ����������� ����������� ���������';
  SErrorDescriptionACFN = '� ��������� 2007 ���������� ��, ������� ����� �� ���������� � ��';


  SErrorDescriptionUnknown = '����������� ��� ������';

  /////////////////////////////////////////////////////////////////////////////
  // Advanced mode

  SAdvancedMode0 = '������ ����';
  SAdvancedMode1 = '��������� ���������� ������';
  SAdvancedMode2 = '�������� ���������� ������';
  SAdvancedMode3 = '����� ��������� ���������� ������';
  SAdvancedMode4 = '���� ������ �������� ������� �������';
  SAdvancedMode5 = '���� ������ ��������';
  SAdvancedModeUnknown = '����������� �������� ���������� (%d)';

  /////////////////////////////////////////////////////////////////////////////
  // Device code

  SDeviceCode1 = '���������� ��1';
  SDeviceCode2 = '���������� ��2';
  SDeviceCode3 = '����';
  SDeviceCode4 = '����������������� ������';
  SDeviceCode5 = '��������� ��';
  SDeviceCode6 = '������ ��������';
  SDeviceCode7 = '����������� ������';
  SDeviceCodeUnknown = '����������� ��� ���������� (%d)';

  /////////////////////////////////////////////////////////////////////////////
  // Device mode

  SDeviceMode01 = '������ ������';
  SDeviceMode02 = '�������� �����; 24 ���� �� ���������';
  SDeviceMode03 = '�������� �����; 24 ���� ���������';
  SDeviceMode04 = '�������� �����';
  SDeviceMode05 = '���������� �� ������������� ������ ���������� ����������';
  SDeviceMode06 = '�������� ������������� ����� ����';
  SDeviceMode07 = '���������� ��������� ��������� ���������� �����';
  SDeviceMode08 = '�������� ��������: �������';
  SDeviceMode09 = '����� ���������� ���. ���������';
  SDeviceMode0A = '�������� ������';
  SDeviceMode0B = '������ ������� ������';
  SDeviceMode0C = '������ ������ ����';
  SDeviceMode0D = '������ �� �������';
  SDeviceMode0E = '�������� �������� ��';
  SDeviceMode0F = '�� �����������';
  SDeviceMode18 = '�������� ��������: �������';
  SDeviceMode1D = '������ �� �������';
  SDeviceMode1E = '�������� � ���������������� ��';
  SDeviceMode28 = '�������� ��������: ������� �������';
  SDeviceMode2D = '������ �� �������� �������';
  SDeviceMode2E = '���������������� ��';
  SDeviceMode38 = '�������� ��������: ������� �������';
  SDeviceMode48 = '�������� ��������: ������������';
  SDeviceMode3D = '������ �� �������� �������';
  SDeviceMode3E = '������ ��';
  SDeviceMode4C = '������ �� ���������';
  SDeviceMode4E = '������ ���������';
  SDeviceMode5E = '������ ��';
  SDeviceMode6E = '�������� ���������� ��';
  SDeviceModeUnknown = '����������� �����: %d';
  SCorrectionReceipt = '. (��� ���������)';

  /////////////////////////////////////////////////////////////////////////////
  // Command name

  SCommandName01 = '������ �����';
  SCommandName02 = '������ ������';
  SCommandName03 = '���������� ������ ������';
  SCommandName0D = '������������ � ������� ���';
  SCommandName0E = '���� �������� ���������� ������';
  SCommandName0F = '������ �������� ���������� ������';
  SCommandName10 = '�������� ������ ���������';
  SCommandName11 = '������ ���������';
  SCommandName12 = '������ ������ ������';
  SCommandName13 = '�����';
  SCommandName14 = '��������� ���������� ������';
  SCommandName15 = '������ ���������� ������';
  SCommandName16 = '��������������� ���������';
  SCommandName17 = '������ ������';
  SCommandName18 = '������ ��������� ���������';
  SCommandName19 = '�������� ������';
  SCommandName1A = '������ ��������� ��������';
  SCommandName1B = '������ ������������� ��������';
  SCommandName1C = '������ ��������';
  SCommandName1D = '������ ��������';
  SCommandName1E = '������ �������';
  SCommandName1F = '������ �������';
  SCommandName20 = '������ ��������� ���������� �����';
  SCommandName21 = '���������������� �������';
  SCommandName22 = '���������������� ����';
  SCommandName23 = '������������� ���������������� ����';
  SCommandName24 = '������������� ������';
  SCommandName25 = '������� ����';
  SCommandName26 = '��������� ��������� ������';
  SCommandName27 = '����� �������';
  SCommandName28 = '������� �������� ����';
  SCommandName29 = '��������';
  SCommandName2A = '������ ����������� ���������';
  SCommandName2B = '���������� ��������� �������';
  SCommandName2C = '������ ��������� ������������ ���������';
  SCommandName2D = '������ ��������� �������';
  SCommandName2E = '������ ��������� ����';
  SCommandName2F = '������ ������ ������ �������';
  SCommandName40 = '�������� ����� ��� �������';
  SCommandName41 = '�������� ����� � ��������';
  SCommandName42 = '����� �� �������';
  SCommandName43 = '����� �� �������';
  SCommandName50 = '��������';
  SCommandName51 = '�������';
  SCommandName57 = '�������� ���� (��������)';
  SCommandName60 = '���� ���������� ������';
  SCommandName61 = '������������� ��';
  SCommandName62 = '������ ����� ������� � ��';
  SCommandName63 = '������ ���� ��������� ������ � ��';
  SCommandName64 = '������ ��������� ��� � ����';
  SCommandName65 = '������������';
  SCommandName66 = '���������� ����� �� ��������� ���';
  SCommandName67 = '���������� ����� �� ��������� ����';
  SCommandName68 = '���������� ������� ������';
  SCommandName69 = '������ ���������� ������������';
  SCommandName6B = '������ �������� ������';
  SCommandName70 = '������� ���������� ���������� ��������';
  SCommandName71 = '������� ����������� ���������� ���������� ��������';
  SCommandName72 = '������������ �������� �� ���������� ���������';
  SCommandName73 = '������������ ����������� �������� �� ���������� ���������';
  SCommandName74 = '������������ ������ �� ���������� ���������';
  SCommandName75 = '������������ ����������� ������ �� ���������� ���������';
  SCommandName76 = '������������ �������� ���� �� ���������� ���������';
  SCommandName77 = '������������ ������������ �������� ���� �� ���������� ���������';
  SCommandName78 = '������������ ����������� ���������';
  SCommandName79 = '��������� ����������� ������������ ����������� ���������';
  SCommandName7A = '���������� ������ ����������� ��������� ������������ �����������';
  SCommandName7B = '������� ������ ������ ����������� ��������� �� ������������ ����������';
  SCommandName7C = '������� ����� ������ ����������� ��������� �� ������������ ����������';
  SCommandName7D = '������ ����������� ���������';
  SCommandName7E = '����� ������������ ����������� ���������';
  SCommandName80 = '�������';
  SCommandName81 = '�������';
  SCommandName82 = '������� �������';
  SCommandName83 = '������� �������';
  SCommandName84 = '������';
  SCommandName85 = '�������� ����';
  SCommandName86 = '������';
  SCommandName87 = '��������';
  SCommandName88 = '������������� ����';
  SCommandName89 = '������� ����';
  SCommandName8A = '������ ������';
  SCommandName8B = '������ ��������';
  SCommandName8C = '������ ���������';
  SCommandName8D = '������� ���';
  SCommandName90 = '������������ ���� ������� �������������� � ������ ���������� �������� ����';
  SCommandName91 = '������������ ���� ������� �������������� � ������ ���������� �� �������� �����';
  SCommandName92 = '������������ ���� ��������� ��� �������� ������� ��������������';
  SCommandName93 = '������� ���� �� � �����������';
  SCommandName94 = '������� ���� �� � �������� ��������';
  SCommandName95 = '������� ��������������';
  SCommandName96 = '������� ��';
  SCommandName97 = '���� ��';
  SCommandName98 = '����� ��';
  SCommandName99 = '����� ���� ���';
  SCommandName9A = '������� ���������� ��';
  SCommandName9B = '������� �������� ��������� �������';
  SCommandName9E = '������ ������� ���� ��';
  SCommandName9F = '������ ��������� ��';
  SCommandNameA0 = '����� ���� �� ������� � �������� ��������� ���';
  SCommandNameA1 = '����� ���� �� ������� � �������� ��������� ������� ����';
  SCommandNameA2 = '����� ���� �� ��������� ���� � �������� ��������� ���';
  SCommandNameA3 = '����� ���� �� ��������� ���� � �������� ��������� ������� ����';
  SCommandNameA4 = '����� ����� �� ������ ����� ����';
  SCommandNameA5 = '��������� �������� �� ���� �� ������ ���';
  SCommandNameA6 = '����������� ����� �� ���� �� ������ �����';
  SCommandNameA7 = '���������� ������� ������ ����';
  SCommandNameA8 = '���� ����������� ����';
  SCommandNameA9 = '����������� ����';
  SCommandNameAA = '�������� ������ ����';
  SCommandNameAB = '������ ���������������� ������ ����';
  SCommandNameAC = '����������� ����';
  SCommandNameAD = '������ ��������� ���� �� ���� 1';
  SCommandNameAE = '������ ��������� ���� �� ���� 2';
  SCommandNameAF = '���� ����������� ������ ����';
  SCommandNameB0 = '����������� ������';
  SCommandNameB1 = '������ ������ ����';
  SCommandNameB2 = '������������� ������ ����';
  SCommandNameB3 = '������ ������ ������ ����';
  SCommandNameB4 = '������ ����������� ����� ����';
  SCommandNameB5 = '������ ��������� ����';
  SCommandNameB6 = '������ ������ ���� �� ������� � �������� ��������� ���';
  SCommandNameB7 = '������ ������ ���� �� ������� � �������� ��������� ������� ����';
  SCommandNameB8 = '������ ������ ���� �� ��������� ���� � �������� ��������� ���';
  SCommandNameB9 = '������ ������ ���� �� ��������� ���� � �������� ��������� ������� ����';
  SCommandNameBA = '������ � ���� ������ ����� �� ������ �����';
  SCommandNameBB = '������ ����� ����������� ����';
  SCommandNameBC = '������� ������ ����';
  SCommandNameC0 = '�������� �������';
  SCommandNameC1 = '������ �������';
  SCommandNameC2 = '������ ���������';
  SCommandNameC3 = '������ ����������� �������';
  SCommandNameC4 = '�������� ����������� �������';
  SCommandNameD0 = '������ ��������� �������� IBM';
  SCommandNameD1 = '������� ������ ��������� �������� IBM';
  SCommandNameE0 = '�������� �����';
  SCommandNameF0 = '���������� ���������';
  SCommandNameF1 = '������ ���';
  SCommandNameFC = '�������� ��� ����������';
  SCommandNameFD = '���������� ������';

  SCommandNameF7 = '������ ���������� ������';

  SCommandNameFE = '��������� �������';

  SCommandName44 = '����� �� ��������'; { !!! }
  SCommandName45 = '����� ���������'; { !!! }
  SCommandName46 = '����� �� �������'; { !!! }
  SCommandName4E = '�������� ������� 512'; { !!! }
  SCommandName4F = '������ ������� � ����������������'; { !!! }

  SCommandName52 = '������ �����'; { !!! }
  SCommandName53 = '���������� ��������� � ������ �����'; { !!! }
  SCommandName54 = '������ ���������� ������'; { !!! }

  SCommandNameFE03 = '�������� ������� ������'; { !!! }
  SCommandNameC5 = '������ ����������� �����'; { !!! }

  SCommandNameFF01 = '������ ������� ��';
  SCommandNameFF02 = '������ ������ ��'; // FF02H	3
  SCommandNameFF03 = '������ ����� �������� ��'; // FF03H	3
  SCommandNameFF04 = '������ ������ ��'; // FF04H	4
  SCommandNameFF05 = '������ ����� � ����������� ���'; // FF05H	4
  SCommandNameFF06 = '������������ ����� � ����������� ���'; // FF06H	4
  SCommandNameFF07 = '����� ��������� ��'; // FF07H	4
  SCommandNameFF08 = '�������� �������� � ��'; // FF08H	5
  SCommandNameFF09 = '������ ������ ��������� ������������ (���������������)'; // FF09H	5
  SCommandNameFF0A = '����� ���������� �������� �� ������'; // FF0AH	6
  SCommandNameFF0B = '������� ����� � ��'; // FF0BH	6
  SCommandNameFF0C = '�������� ������������ TLV ���������'; // FF0CH	6
  SCommandNameFF0D = '�������� �� �������� � ����������'; // FF0DH	6
  SCommandNameFF30 = '��������� � ������� ������ � ������'; // FF30H	7
  SCommandNameFF31 = '��������� ���� ������ �� ������'; // FF31H	7
  SCommandNameFF32 = '������ ������ ������ � �����'; // FF32H	8
  SCommandNameFF33 = '�������� ���� ������ � �����'; // FF33H	8
  SCommandNameFF34 = '������������ ����� � ��������������� ���'; // FF34H	8
  SCommandNameFF35 = '������ ������������ ���� ���������'; // FF35H	8
  SCommandNameFF36 = '������������ ��� ���������'; // FF36H	8
  SCommandNameFF37 = '������ ������������ ������ � ��������� ��������'; // FF37H	9
  SCommandNameFF38 = '������������ ����� � ��������� ��������'; // FF38H	9
  SCommandNameFF39 = '�������� ������ ���������������  ������'; // FF39H	9
  SCommandNameFF3A = '��������� ���������� �������� � TLV �������'; // FF3AH	10
  SCommandNameFF3B = '������ TLV ����������� ���������'; // FF3BH	10
  SCommandNameFF3C = '������ ��������� � ��������� ������ � ��� �� ������  ���������'; // FF3CH	10
  SCommandNameFF3D = '������ �������� ����������� ������'; // FF3DH	10
  SCommandNameFF3E = '������� ���������� �����'; // FF3EH	10
  SCommandNameFF3F = '������ ���������� �� �� ������� ��� ���������'; // FF3FH	11
  SCommandNameFF40 = '������ ���������� ������� �����'; // FF40H	11
  SCommandNameFF41 = '������ �������� �����'; // FF41H	11
  SCommandNameFF42 = '������ �������� �����'; // FF42H	11
  SCommandNameFF43 = '������� ����� � ��'; // FF43H	11
  SCommandNameFF45 = '�������� ���� ����������� ������� V2'; // FF45H	12
  SCommandNameFF46 = '�������� V2'; // FF46H	13
  SCommandNameFF47 = '�������������� �������� ���'; // FF47H	14
  SCommandNameFF48 = '������ � �������� � ��������'; // FF48H	14
  SCommandNameFF49 = '�������� ���� �������� ������������'; // FF49H	14
  SCommandNameFF4A = '������������ ��� ��������� V2'; // FF4AH	14
  SCommandNameFF4B = '������, �������� �� ��� ��� ��������'; // FF4BH	15
  SCommandNameFF4C = '������ ������ ������������ (���������������) V2'; // FF4CH	15
  SCommandNameFF4D = '�������� ������������ TLV ��������� ����������� � ��������'; // FF4DH.	16
  SCommandNameFF4E = '������ ����� ������ ��������  �� �� SD �����'; // FF4EH	16
  SCommandNameFF50 = '������ �����'; // FF50H	16
  SCommandNameFF51 = '������ ������ ������'; // FF51H	17
  SCommandNameFF52 = '�������� �������� ���������� ������ ������'; // FF52H	17
  SCommandNameFF60 = '������ ��������� ������������ '; // FF60H	17
  SCommandNameFF61 = '��������  �������������� ������'; // FF61H	18
  SCommandNameFF62 = '���������������� �������� �� ��������� ��'; // FF62H	18
  SCommandNameFF63 = '������ ������� ��������� ������  � ��'; // FF63H	18
  SCommandNameFF64 = '�������� � ��  TLV �� ������'; // FF64H	19
  SCommandNameFF65 = '�������� ��������� ������������������'; // FF65H
  SCommandNameFF66 = '�����������'; // FF66H
  SCommandNameFF67 = '��������  �������������� ������ � �������'; // FF67H
  SCommandNameFF68 = '�������� ��������� �� �������� �����������'; // FF68H
  SCommandNameFF69 = '�������/��������� ��'; // FF69H
  SCommandNameFF70 = '������ ������� �� ������ � ������ ����������'; // FF70H
  SCommandNameFF71 = '������ �������� �����������  � ���������� ������������� �������'; // FF71H
  SCommandNameFF72 = '��������� ���� �����������'; // FF72H
  SCommandNameFF73 = '����������� �������� �����������'; // FF73H
  SCommandNameFF74 = '������ ���������� ��'; // FF74H
  SCommandNameFF75 = '������ ������� ������ ��������� � ��'; // FF75H

  SNoCommandName = '';

function WordToStr(Value: Word): AnsiString;
function GetCommandName(Command: Word): string;
function BaudRateToStr(Value: Integer): WideString;
function GetECRModeDescription(Value: Integer): WideString;
function GetDeviceCodeDescription(Value: Integer): WideString;
function GetAdvancedModeDescription(Value: Integer): WideString;
function GetCashRegisterName(Number: Integer; ACapFN: Boolean): WideString;
function GetOperRegisterName(Number: Integer; ACapFN: Boolean): WideString;
function PollToDescription(Poll1: Integer; Poll2: Integer): WideString;
function GetCommandTimeout(Command: Word): Integer;

implementation

{ TPrinterError }

class function TPrinterError.GetDescription(Code: Integer; ACapFN: Boolean = False): WideString;
var
  Res: PResStringRec;
begin
  case Code of
    $00: Res := @SErrorDescription00;
    $01: Res := @SErrorDescription01;
    $02: Res := @SErrorDescription02;
    $03: Res := @SErrorDescription03;
    $04: Res := @SErrorDescription04;
    $05: Res := @SErrorDescription05;
    $06: Res := @SErrorDescription06;
    $07: Res := @SErrorDescription07;
    $08: Res := @SErrorDescription08;
    $09: Res := @SErrorDescription09;
    $0A: Res := @SErrorDescription0A;
    $0B: Res := @SErrorDescription0B;

    $11: Res := @SErrorDescription11;
    $12: Res := @SErrorDescription12;
    $13: Res := @SErrorDescription13;
    $14: Res := @SErrorDescription14;
    $15: Res := @SErrorDescription15;
    $16: Res := @SErrorDescription16;
    $17: Res := @SErrorDescription17;
    $18: Res := @SErrorDescription18;
    $19: Res := @SErrorDescription19;
    $1A: Res := @SErrorDescription1A;
    $1B: Res := @SErrorDescription1B;
    $1C: Res := @SErrorDescription1C;
    $1D: Res := @SErrorDescription1D;
    $1E: Res := @SErrorDescription1E;
    $1F: Res := @SErrorDescription1F;

    $20: Res := @SErrorDescription20;
    $21: Res := @SErrorDescription21;
    $22: Res := @SErrorDescription22;
    $23: Res := @SErrorDescription23;
    $24: Res := @SErrorDescription24;
    $25: Res := @SErrorDescription25;
    $26: Res := @SErrorDescription26;
    $27: Res := @SErrorDescription27;
    $28: Res := @SErrorDescription28;
    $29: Res := @SErrorDescription29;
    $2F: Res := @SErrorDescription2F;

    $30: Res := @SErrorDescription30;
    $31: Res := @SErrorDescription31;
    $32: Res := @SErrorDescription32;
    $33: Res := @SErrorDescription33;
    $34: Res := @SErrorDescription34;
    $35: Res := @SErrorDescription35;
    $36: Res := @SErrorDescription36;
    $37: Res := @SErrorDescription37;
    $38: Res := @SErrorDescription38;
    $39: Res := @SErrorDescription39;
    $3A: Res := @SErrorDescription3A;
    $3B: Res := @SErrorDescription3B;
    $3C: Res := @SErrorDescription3C;
    $3D: Res := @SErrorDescription3D;
    $3E: Res := @SErrorDescription3E;
    $3F: Res := @SErrorDescription3F;

    $40: Res := @SErrorDescription40;
    $41: Res := @SErrorDescription41;
    $42: Res := @SErrorDescription42;
    $43: Res := @SErrorDescription43;
    $44: Res := @SErrorDescription44;
    $45: Res := @SErrorDescription45;
    $46: Res := @SErrorDescription46;
    $47: Res := @SErrorDescription47;
    $48: Res := @SErrorDescription48;
    $49: Res := @SErrorDescription49;
    $4A: Res := @SErrorDescription4A;
    $4B: Res := @SErrorDescription4B;
    $4C: Res := @SErrorDescription4C;
    $4D: Res := @SErrorDescription4D;
    $4E: Res := @SErrorDescription4E;
    $4F: Res := @SErrorDescription4F;

    $50: Res := @SErrorDescription50;
    $51: Res := @SErrorDescription51;
    $52: Res := @SErrorDescription52;
    $53: Res := @SErrorDescription53;
    $54: Res := @SErrorDescription54;
    $55: Res := @SErrorDescription55;
    $56: Res := @SErrorDescription56;
    $57: Res := @SErrorDescription57;
    $58: Res := @SErrorDescription58;
    $59: Res := @SErrorDescription59;
    $5A: Res := @SErrorDescription5A;
    $5B: Res := @SErrorDescription5B;
    $5C: Res := @SErrorDescription5C;
    $5D: Res := @SErrorDescription5D;
    $5E: Res := @SErrorDescription5E;
    $5F: Res := @SErrorDescription5F;

    $60: Res := @SErrorDescription60;
    $61: Res := @SErrorDescription61;
    $62: Res := @SErrorDescription62;
    $63: Res := @SErrorDescription63;
    $64: Res := @SErrorDescription64;
    $65: Res := @SErrorDescription65;
    $66: Res := @SErrorDescription66;
    $67: Res := @SErrorDescription67;
    $68: Res := @SErrorDescription68;
    $69: Res := @SErrorDescription69;
    $6A: Res := @SErrorDescription6A;
    $6B: Res := @SErrorDescription6B;
    $6C: Res := @SErrorDescription6C;
    $6D: Res := @SErrorDescription6D;
    $6E: Res := @SErrorDescription6E;
    $6F: Res := @SErrorDescription6F;

    $70: Res := @SErrorDescription70;
    $71: Res := @SErrorDescription71;
    $72: Res := @SErrorDescription72;
    $73: Res := @SErrorDescription73;
    $74: Res := @SErrorDescription74;
    $75: Res := @SErrorDescription75;
    $76: Res := @SErrorDescription76;
    $77: Res := @SErrorDescription77;
    $78: Res := @SErrorDescription78;
    $79: Res := @SErrorDescription79;
    $7A: Res := @SErrorDescription7A;
    $7B: Res := @SErrorDescription7B;
    $7C: Res := @SErrorDescription7C;
    $7D: Res := @SErrorDescription7D;
    $7E: Res := @SErrorDescription7E;
    $7F: Res := @SErrorDescription7F;

    $80: Res := @SErrorDescription80;
    $81: Res := @SErrorDescription81;
    $82: Res := @SErrorDescription82;
    $83: Res := @SErrorDescription83;
    $84: Res := @SErrorDescription84;
    $85: Res := @SErrorDescription85;
    $86: Res := @SErrorDescription86;
    $87: Res := @SErrorDescription87;
    $88: Res := @SErrorDescription88;
    $89: Res := @SErrorDescription89;
    $8A: Res := @SErrorDescription8A;
    $8B: Res := @SErrorDescription8B;
    $8C: Res := @SErrorDescription8C;
    $8D: Res := @SErrorDescription8D;
    $8E: Res := @SErrorDescription8E;
    $8F: Res := @SErrorDescription8F;

    $90: Res := @SErrorDescription90;
    $91: Res := @SErrorDescription91;
    $92: Res := @SErrorDescription92;
    $93: Res := @SErrorDescription93;
    $94: Res := @SErrorDescription94;
    $95: Res := @SErrorDescription95;

    $A0: Res := @SErrorDescriptionA0;
    $A1: Res := @SErrorDescriptionA1;
    $A2: Res := @SErrorDescriptionA2;
    $A3: Res := @SErrorDescriptionA3;
    $A4: Res := @SErrorDescriptionA4;
    $A5: Res := @SErrorDescriptionA5;
    $A6: Res := @SErrorDescriptionA6;
    $A7: Res := @SErrorDescriptionA7;
    $A8: Res := @SErrorDescriptionA8;
    $A9: Res := @SErrorDescriptionA9;
    $AA: Res := @SErrorDescriptionAA;
    $AB: Res := @SErrorDescriptionAB;
    $AC: Res := @SErrorDescriptionAC;
    $AD: Res := @SErrorDescriptionAD;
    $AE: Res := @SErrorDescriptionAE;
    $AF: Res := @SErrorDescriptionAF;

    $B0: Res := @SErrorDescriptionB0;
    $B1: Res := @SErrorDescriptionB1;
    $B2: Res := @SErrorDescriptionB2;
    $B3: Res := @SErrorDescriptionB3;

    $C0: Res := @SErrorDescriptionC0;
    $C1: Res := @SErrorDescriptionC1;
    $C2: Res := @SErrorDescriptionC2;
    $C3: Res := @SErrorDescriptionC3;
    $C4: Res := @SErrorDescriptionC4;
    $C5: Res := @SErrorDescriptionC5;
    $C6: Res := @SErrorDescriptionC6;
    $C7: Res := @SErrorDescriptionC7;
    $C8: Res := @SErrorDescriptionC8;
    $C9: Res := @SErrorDescriptionC9;
    $CA: Res := @SerrorDescriptionCA;
    $CB: Res := @SerrorDescriptionCB;

    $D0: Res := @SErrorDescriptionD0;
    $D1: Res := @SErrorDescriptionD1;
    $D2: Res := @SErrorDescriptionD2;
    $D3: Res := @SErrorDescriptionD3;
    $D4: Res := @SErrorDescriptionD4;
    $D5: Res := @SErrorDescriptionD5;

    $E0: Res := @SErrorDescriptionE0;
    $E1: Res := @SErrorDescriptionE1;
    $E2: Res := @SErrorDescriptionE2;
    $E3: Res := @SErrorDescriptionE3;
    $E4: Res := @SErrorDescriptionE4;

    $F0: Res := @SErrorDescriptionF0;
    $F1: Res := @SErrorDescriptionF1;
    $F2: Res := @SErrorDescriptionF2;
    $F3: Res := @SErrorDescriptionF3;
    $F4: Res := @SErrorDescriptionF4;
    $F5: Res := @SErrorDescriptionF5;
  else
    Res := @SErrorDescriptionUnknown;
  end;

  if ACapFN then
  begin
    case Code of
      $01: Res := @SErrorDescription01FN;
      $02: Res := @SErrorDescription02FN;
      $03: Res := @SErrorDescription03FN;
      $04: Res := @SErrorDescription04FN;
      $05: Res := @SErrorDescription05FN;
      $06: Res := @SErrorDescription06FN;
      $07: Res := @SErrorDescription07FN;
      $08: Res := @SErrorDescription08FN;
      $09: Res := @SErrorDescription09FN;
      $0A: Res := @SErrorDescription0AFN;
      $0B: Res := @SErrorDescription0BFN;
      $0C: Res := @SErrorDescription0CFN;
      $0D: Res := @SErrorDescription0DFN;
      $0E: Res := @SErrorDescription0EFN;
      $10: Res := @SErrorDescription10FN;
      $11: Res := @SErrorDescription11FN;
      $12: Res := @SErrorDescription12FN;
      $14: Res := @SErrorDescription14FN;
      $15: Res := @SErrorDescription15FN;
      $16: Res := @SErrorDescription16FN;
      $17: Res := @SErrorDescription17FN;
      $18: Res := @SErrorDescription18FN;
      $19: Res := @SErrorDescription19FN;
      $20: Res := @SErrorDescription20FN;
      $21: Res := @SErrorDescription21FN;
      $30: Res := @SErrorDescription30FN;
      $77: Res := @SErrorDescription77FN;
      $79: Res := @SErrorDescription79FN;



      $23: Res := @SErrorDescription23FN;
      $24: Res := @SErrorDescription24FN;
      $A0: Res := @SErrorDescriptionA0FN;
      $A1: Res := @SErrorDescriptionA1FN;
      $A2: Res := @SErrorDescriptionA2FN;
      $A3: Res := @SErrorDescriptionA3FN;
      $AA: Res := @SErrorDescriptionAAFN;
      $AC: Res := @SErrorDescriptionACFN;


    end;
  end;
  Result := GetRes(Res);
end;





function GetAdvancedModeDescription(Value: Integer): WideString;
var
  Res: PResStringRec;
begin
  Result := '';
  case Value of
    0: Res := @SAdvancedMode0;
    1: Res := @SAdvancedMode1;
    2: Res := @SAdvancedMode2;
    3: Res := @SAdvancedMode3;
    4: Res := @SAdvancedMode4;
    5: Res := @SAdvancedMode5;
  else
    Result := Format(GetRes(@SAdvancedModeUnknown), [Value]);
  end;
  if Result = '' then
    Result := GetRes(Res);
end;

function GetDeviceCodeDescription(Value: Integer): WideString;
var
  Res: PResStringRec;
begin
  Result := '';
  case Value of
    1: Res := @SDeviceCode1;
    2: Res := @SDeviceCode2;
    3: Res := @SDeviceCode3;
    4: Res := @SDeviceCode4;
    5: Res := @SDeviceCode5;
    6: Res := @SDeviceCode6;
    7: Res := @SDeviceCode7;
  else
    Result := Format(GetRes(@SDeviceCodeUnknown), [Value]);
  end;
  if Result = '' then
    Result := GetRes(Res);
end;

function WordToStr(Value: Word): AnsiString;
begin
  SetLength(Result, 2);
  Move(Value, Result[1], 2);
end;


function GetECRModeDescription(Value: Integer): WideString;
var
  Status: Integer;
  Res: PResStringRec;
begin
  Result := '';
  // ������� ��� ��������, ��� ���� �������� ��� �������������
  Status := Value and $7F;
  case Status of
    $01: Res := @SDeviceMode01;
    $02: Res := @SDeviceMode02;
    $03: Res := @SDeviceMode03;
    $04: Res := @SDeviceMode04;
    $05: Res := @SDeviceMode05;
    $06: Res := @SDeviceMode06;
    $07: Res := @SDeviceMode07;
    $08: Res := @SDeviceMode08;
    $09: Res := @SDeviceMode09;
    $0A: Res := @SDeviceMode0A;
    $0B: Res := @SDeviceMode0B;
    $0C: Res := @SDeviceMode0C;
    $0D: Res := @SDeviceMode0D;
    $0E: Res := @SDeviceMode0E;
    $0F: Res := @SDeviceMode0F;
    $18: Res := @SDeviceMode18;
    $1D: Res := @SDeviceMode1D;
    $1E: Res := @SDeviceMode1E;
    $28: Res := @SDeviceMode28;
    $2D: Res := @SDeviceMode2D;
    $2E: Res := @SDeviceMode2E;
    $38: Res := @SDeviceMode38;
    $48: Res := @SDeviceMode48;
    $3D: Res := @SDeviceMode3D;
    $3E: Res := @SDeviceMode3E;
    $4C: Res := @SDeviceMode4C;
  	$4E: Res := @SDeviceMode4E;
    $5E: Res := @SDeviceMode5E;
    $6E: Res := @SDeviceMode6E;
  else
    Result := Format(GetRes(@SDeviceModeUnknown), [Value]);
  end;
  if Result = '' then
    Result := GetRes(Res);
  if TestBit(Value, 7) then
    Result := Result + GetRes(@SCorrectionReceipt);
end;

function BaudRateToStr(Value: Integer): WideString;
begin
  case Value of
    0: Result := '2400';
    1: Result := '4800';
    2: Result := '9600';
    3: Result := '19200';
    4: Result := '38400';
    5: Result := '57600';
    6: Result := '115200';
    7: Result := '230400';
    8: Result := '460800';
    9: Result := '921600';
  else
    Result := '';
  end;
end;

function GetCashRegisterName(Number: Integer; ACapFN: Boolean): WideString;
var
  Res: PResStringRec;
begin
  Result := '';
  case Number of
    $00: Res := @SCashRegister00;
    $01: Res := @SCashRegister01;
    $02: Res := @SCashRegister02;
    $03: Res := @SCashRegister03;
    $04: Res := @SCashRegister04;
    $05: Res := @SCashRegister05;
    $06: Res := @SCashRegister06;
    $07: Res := @SCashRegister07;
    $08: Res := @SCashRegister08;
    $09: Res := @SCashRegister09;
    $0A: Res := @SCashRegister0A;
    $0B: Res := @SCashRegister0B;
    $0C: Res := @SCashRegister0C;
    $0D: Res := @SCashRegister0D;
    $0E: Res := @SCashRegister0E;
    $0F: Res := @SCashRegister0F;

    $10: Res := @SCashRegister10;
    $11: Res := @SCashRegister11;
    $12: Res := @SCashRegister12;
    $13: Res := @SCashRegister13;
    $14: Res := @SCashRegister14;
    $15: Res := @SCashRegister15;
    $16: Res := @SCashRegister16;
    $17: Res := @SCashRegister17;
    $18: Res := @SCashRegister18;
    $19: Res := @SCashRegister19;
    $1A: Res := @SCashRegister1A;
    $1B: Res := @SCashRegister1B;
    $1C: Res := @SCashRegister1C;
    $1D: Res := @SCashRegister1D;
    $1E: Res := @SCashRegister1E;
    $1F: Res := @SCashRegister1F;

    $20: Res := @SCashRegister20;
    $21: Res := @SCashRegister21;
    $22: Res := @SCashRegister22;
    $23: Res := @SCashRegister23;
    $24: Res := @SCashRegister24;
    $25: Res := @SCashRegister25;
    $26: Res := @SCashRegister26;
    $27: Res := @SCashRegister27;
    $28: Res := @SCashRegister28;
    $29: Res := @SCashRegister29;
    $2A: Res := @SCashRegister2A;
    $2B: Res := @SCashRegister2B;
    $2C: Res := @SCashRegister2C;
    $2D: Res := @SCashRegister2D;
    $2E: Res := @SCashRegister2E;
    $2F: Res := @SCashRegister2F;

    $30: Res := @SCashRegister30;
    $31: Res := @SCashRegister31;
    $32: Res := @SCashRegister32;
    $33: Res := @SCashRegister33;
    $34: Res := @SCashRegister34;
    $35: Res := @SCashRegister35;
    $36: Res := @SCashRegister36;
    $37: Res := @SCashRegister37;
    $38: Res := @SCashRegister38;
    $39: Res := @SCashRegister39;
    $3A: Res := @SCashRegister3A;
    $3B: Res := @SCashRegister3B;
    $3C: Res := @SCashRegister3C;
    $3D: Res := @SCashRegister3D;
    $3E: Res := @SCashRegister3E;
    $3F: Res := @SCashRegister3F;

    $40: Res := @SCashRegister40;
    $41: Res := @SCashRegister41;
    $42: Res := @SCashRegister42;
    $43: Res := @SCashRegister43;
    $44: Res := @SCashRegister44;
    $45: Res := @SCashRegister45;
    $46: Res := @SCashRegister46;
    $47: Res := @SCashRegister47;
    $48: Res := @SCashRegister48;
    $49: Res := @SCashRegister49;
    $4A: Res := @SCashRegister4A;
    $4B: Res := @SCashRegister4B;
    $4C: Res := @SCashRegister4C;
    $4D: Res := @SCashRegister4D;
    $4E: Res := @SCashRegister4E;
    $4F: Res := @SCashRegister4F;

    $50: Res := @SCashRegister50;
    $51: Res := @SCashRegister51;
    $52: Res := @SCashRegister52;
    $53: Res := @SCashRegister53;
    $54: Res := @SCashRegister54;
    $55: Res := @SCashRegister55;
    $56: Res := @SCashRegister56;
    $57: Res := @SCashRegister57;
    $58: Res := @SCashRegister58;
    $59: Res := @SCashRegister59;
    $5A: Res := @SCashRegister5A;
    $5B: Res := @SCashRegister5B;
    $5C: Res := @SCashRegister5C;
    $5D: Res := @SCashRegister5D;
    $5E: Res := @SCashRegister5E;
    $5F: Res := @SCashRegister5F;

    $60: Res := @SCashRegister60;
    $61: Res := @SCashRegister61;
    $62: Res := @SCashRegister62;
    $63: Res := @SCashRegister63;
    $64: Res := @SCashRegister64;
    $65: Res := @SCashRegister65;
    $66: Res := @SCashRegister66;
    $67: Res := @SCashRegister67;
    $68: Res := @SCashRegister68;
    $69: Res := @SCashRegister69;
    $6A: Res := @SCashRegister6A;
    $6B: Res := @SCashRegister6B;
    $6C: Res := @SCashRegister6C;
    $6D: Res := @SCashRegister6D;
    $6E: Res := @SCashRegister6E;
    $6F: Res := @SCashRegister6F;

    $70: Res := @SCashRegister70;
    $71: Res := @SCashRegister71;
    $72: Res := @SCashRegister72;
    $73: Res := @SCashRegister73;
    $74: Res := @SCashRegister74;
    $75: Res := @SCashRegister75;
    $76: Res := @SCashRegister76;
    $77: Res := @SCashRegister77;
    $78: Res := @SCashRegister78;
    $79: Res := @SCashRegister79;
    $7A: Res := @SCashRegister7A;
    $7B: Res := @SCashRegister7B;
    $7C: Res := @SCashRegister7C;
    $7D: Res := @SCashRegister7D;
    $7E: Res := @SCashRegister7E;
    $7F: Res := @SCashRegister7F;

    $80: Res := @SCashRegister80;
    $81: Res := @SCashRegister81;
    $82: Res := @SCashRegister82;
    $83: Res := @SCashRegister83;
    $84: Res := @SCashRegister84;
    $85: Res := @SCashRegister85;
    $86: Res := @SCashRegister86;
    $87: Res := @SCashRegister87;
    $88: Res := @SCashRegister88;
    $89: Res := @SCashRegister89;
    $8A: Res := @SCashRegister8A;
    $8B: Res := @SCashRegister8B;
    $8C: Res := @SCashRegister8C;
    $8D: Res := @SCashRegister8D;
    $8E: Res := @SCashRegister8E;
    $8F: Res := @SCashRegister8F;

    $90: Res := @SCashRegister90;
    $91: Res := @SCashRegister91;
    $92: Res := @SCashRegister92;
    $93: Res := @SCashRegister93;
    $94: Res := @SCashRegister94;
    $95: Res := @SCashRegister95;
    $96: Res := @SCashRegister96;
    $97: Res := @SCashRegister97;
    $98: Res := @SCashRegister98;
    $99: Res := @SCashRegister99;
    $9A: Res := @SCashRegister9A;
    $9B: Res := @SCashRegister9B;
    $9C: Res := @SCashRegister9C;
    $9D: Res := @SCashRegister9D;
    $9E: Res := @SCashRegister9E;
    $9F: Res := @SCashRegister9F;

    $A0: Res := @SCashRegisterA0;
    $A1: Res := @SCashRegisterA1;
    $A2: Res := @SCashRegisterA2;
    $A3: Res := @SCashRegisterA3;
    $A4: Res := @SCashRegisterA4;
    $A5: Res := @SCashRegisterA5;
    $A6: Res := @SCashRegisterA6;
    $A7: Res := @SCashRegisterA7;
    $A8: Res := @SCashRegisterA8;
    $A9: Res := @SCashRegisterA9;
    $AA: Res := @SCashRegisterAA;
    $AB: Res := @SCashRegisterAB;
    $AC: Res := @SCashRegisterAC;
    $AD: Res := @SCashRegisterAD;
    $AE: Res := @SCashRegisterAE;
    $AF: Res := @SCashRegisterAF;

    $B0: Res := @SCashRegisterB0;
    $B1: Res := @SCashRegisterB1;
    $B2: Res := @SCashRegisterB2;
    $B3: Res := @SCashRegisterB3;
    $B4: Res := @SCashRegisterB4;
    $B5: Res := @SCashRegisterB5;
    $B6: Res := @SCashRegisterB6;
    $B7: Res := @SCashRegisterB7;
    $B8: Res := @SCashRegisterB8;
    $B9: Res := @SCashRegisterB9;
    $BA: Res := @SCashRegisterBA;
    $BB: Res := @SCashRegisterBB;
    $BC: Res := @SCashRegisterBC;
    $BD: Res := @SCashRegisterBD;
    $BE: Res := @SCashRegisterBE;
    $BF: Res := @SCashRegisterBF;

    $C0: Res := @SCashRegisterC0;
    $C1: Res := @SCashRegisterC1;
    $C2: Res := @SCashRegisterC2;
    $C3: Res := @SCashRegisterC3;
    $C4: Res := @SCashRegisterC4;
    $C5: Res := @SCashRegisterC5;
    $C6: Res := @SCashRegisterC6;
    $C7: Res := @SCashRegisterC7;
    $C8: Res := @SCashRegisterC8;
    $C9: Res := @SCashRegisterC9;
    $CA: Res := @SCashRegisterCA;
    $CB: Res := @SCashRegisterCB;
    $CC: Res := @SCashRegisterCC;
    $CD: Res := @SCashRegisterCD;
    $CE: Res := @SCashRegisterCE;
    $CF: Res := @SCashRegisterCF;

    $D0: Res := @SCashRegisterD0;
    $D1: Res := @SCashRegisterD1;
    $D2: Res := @SCashRegisterD2;
    $D3: Res := @SCashRegisterD3;
    $D4: Res := @SCashRegisterD4;
    $D5: Res := @SCashRegisterD5;
    $D6: Res := @SCashRegisterD6;
    $D7: Res := @SCashRegisterD7;
    $D8: Res := @SCashRegisterD8;
    $D9: Res := @SCashRegisterD9;
    $DA: Res := @SCashRegisterDA;
    $DB: Res := @SCashRegisterDB;
    $DC: Res := @SCashRegisterDC;
    $DD: Res := @SCashRegisterDD;
    $DE: Res := @SCashRegisterDE;
    $DF: Res := @SCashRegisterDF;

    $E0: Res := @SCashRegisterE0;
    $E1: Res := @SCashRegisterE1;
    $E2: Res := @SCashRegisterE2;
    $E3: Res := @SCashRegisterE3;
    $E4: Res := @SCashRegisterE4;
    $E5: Res := @SCashRegisterE5;
    $E6: Res := @SCashRegisterE6;
    $E7: Res := @SCashRegisterE7;
    $E8: Res := @SCashRegisterE8;
    $E9: Res := @SCashRegisterE9;
    $EA: Res := @SCashRegisterEA;
    $EB: Res := @SCashRegisterEB;
    $EC: Res := @SCashRegisterEC;
    $ED: Res := @SCashRegisterED;
    $EE: Res := @SCashRegisterEE;
    $EF: Res := @SCashRegisterEF;

    $F0: Res := @SCashRegisterF0;
    $F1: Res := @SCashRegisterF1;
    $F2: Res := @SCashRegisterF2;
    $F3: Res := @SCashRegisterF3;
    $F4: Res := @SCashRegisterF4;
    $F5: Res := @SCashRegisterF5;
    $F6: Res := @SCashRegisterF6;
    $F7: Res := @SCashRegisterF7;
    $F8: Res := @SCashRegisterF8;
    $F9: Res := @SCashRegisterF9;
    $FA: Res := @SCashRegisterFA;
    $FB: Res := @SCashRegisterFB;
    $FC: Res := @SCashRegisterFC;
    $FF: Res := @SCashRegisterFF;

    // �������������� ��������
    4096: Res := @SCashRegister4096;
    4097: Res := @SCashRegister4097;
    4098: Res := @SCashRegister4098;
    4099: Res := @SCashRegister4099;
    4100: Res := @SCashRegister4100;
    4101: Res := @SCashRegister4101;
    4102: Res := @SCashRegister4102;
    4103: Res := @SCashRegister4103;
    4104: Res := @SCashRegister4104;
    4105: Res := @SCashRegister4105;
    4106: Res := @SCashRegister4106;
    4107: Res := @SCashRegister4107;
    4108: Res := @SCashRegister4108;
    4109: Res := @SCashRegister4109;
    4110: Res := @SCashRegister4110;
    4111: Res := @SCashRegister4111;
    4112: Res := @SCashRegister4112;
    4113: Res := @SCashRegister4113;
    4114: Res := @SCashRegister4114;
    4115: Res := @SCashRegister4115;
    4116: Res := @SCashRegister4116;
    4117: Res := @SCashRegister4117;
    4118: Res := @SCashRegister4118;
    4119: Res := @SCashRegister4119;
    4120: Res := @SCashRegister4120;
    4121: Res := @SCashRegister4121;
    4122: Res := @SCashRegister4122;
    4123: Res := @SCashRegister4123;
    4124: Res := @SCashRegister4124;
    4125: Res := @SCashRegister4125;
    4126: Res := @SCashRegister4126;
    4127: Res := @SCashRegister4127;
    4128: Res := @SCashRegister4128;
    4129: Res := @SCashRegister4129;
    4130: Res := @SCashRegister4130;
    4131: Res := @SCashRegister4131;
    4132: Res := @SCashRegister4132;
    4133: Res := @SCashRegister4133;
    4134: Res := @SCashRegister4134;
    4135: Res := @SCashRegister4135;
    4136: Res := @SCashRegister4136;
    4137: Res := @SCashRegister4137;
    4138: Res := @SCashRegister4138;
    4139: Res := @SCashRegister4139;
    4140: Res := @SCashRegister4140;
    4141: Res := @SCashRegister4141;
    4142: Res := @SCashRegister4142;
    4143: Res := @SCashRegister4143;
    4144: Res := @SCashRegister4144;
    4145: Res := @SCashRegister4145;
    4146: Res := @SCashRegister4146;
    4147: Res := @SCashRegister4147;
    4148: Res := @SCashRegister4148;
    4149: Res := @SCashRegister4149;
    4150: Res := @SCashRegister4150;
    4151: Res := @SCashRegister4151;
    4152: Res := @SCashRegister4152;
    4153: Res := @SCashRegister4153;
    4154: Res := @SCashRegister4154;
    4155: Res := @SCashRegister4155;
    4156: Res := @SCashRegister4156;
    4157: Res := @SCashRegister4157;
    4158: Res := @SCashRegister4158;
    4159: Res := @SCashRegister4159;
    4160: Res := @SCashRegister4160;
    4161: Res := @SCashRegister4161;
    4162: Res := @SCashRegister4162;
    4163: Res := @SCashRegister4163;
    4164: Res := @SCashRegister4164;
    4165: Res := @SCashRegister4165;
    4166: Res := @SCashRegister4166;
    4167: Res := @SCashRegister4167;
    4168: Res := @SCashRegister4168;
    4169: Res := @SCashRegister4169;
    4170: Res := @SCashRegister4170;
    4171: Res := @SCashRegister4171;
    4172: Res := @SCashRegister4172;
    4173: Res := @SCashRegister4173;
    4174: Res := @SCashRegister4174;
    4175: Res := @SCashRegister4175;
    4176: Res := @SCashRegister4176;
    4177: Res := @SCashRegister4177;
    4178: Res := @SCashRegister4178;
    4179: Res := @SCashRegister4179;
    4180: Res := @SCashRegister4180;
    4181: Res := @SCashRegister4181;
    4182: Res := @SCashRegister4182;
    4183: Res := @SCashRegister4183;
    4184: Res := @SCashRegister4184;
    4185: Res := @SCashRegister4185;
    4186: Res := @SCashRegister4186;
    4187: Res := @SCashRegister4187;
    4188: Res := @SCashRegister4188;
    4189: Res := @SCashRegister4189;
    4190: Res := @SCashRegister4190;
    4191: Res := @SCashRegister4191;

    4192: Res := @SCashRegister4192;
    4193: Res := @SCashRegister4193;
    4194: Res := @SCashRegister4194;
    4195: Res := @SCashRegister4195;
    4196: Res := @SCashRegister4196;
    4197: Res := @SCashRegister4197;
    4198: Res := @SCashRegister4198;
    4199: Res := @SCashRegister4199;
    4200: Res := @SCashRegister4200;
    4201: Res := @SCashRegister4201;
    4202: Res := @SCashRegister4202;
    4203: Res := @SCashRegister4203;
    4204: Res := @SCashRegister4204;
    4205: Res := @SCashRegister4205;
    4206: Res := @SCashRegister4206;
    4207: Res := @SCashRegister4207;
    4208: Res := @SCashRegister4208;
    4209: Res := @SCashRegister4209;
    4210: Res := @SCashRegister4210;
    4211: Res := @SCashRegister4211;
    4212: Res := @SCashRegister4212;
    4213: Res := @SCashRegister4213;
    4214: Res := @SCashRegister4214;
    4215: Res := @SCashRegister4215;
    4216: Res := @SCashRegister4216;
    4217: Res := @SCashRegister4217;
    4218: Res := @SCashRegister4218;
    4219: Res := @SCashRegister4219;
    4220: Res := @SCashRegister4220;
    4221: Res := @SCashRegister4221;
    4222: Res := @SCashRegister4222;
    4223: Res := @SCashRegister4223;
    4224: Res := @SCashRegister4224;
    4225: Res := @SCashRegister4225;
    4226: Res := @SCashRegister4226;
    4227: Res := @SCashRegister4227;
    4228: Res := @SCashRegister4228;
    4229: Res := @SCashRegister4229;
    4230: Res := @SCashRegister4230;
    4231: Res := @SCashRegister4231;
    4232: Res := @SCashRegister4232;
    4233: Res := @SCashRegister4233;
    4234: Res := @SCashRegister4234;
    4235: Res := @SCashRegister4235;
    4236: Res := @SCashRegister4236;
    4237: Res := @SCashRegister4237;
    4238: Res := @SCashRegister4238;
    4239: Res := @SCashRegister4239;
    4240: Res := @SCashRegister4240;
    4241: Res := @SCashRegister4241;
    4242: Res := @SCashRegister4242;
    4243: Res := @SCashRegister4243;
    4244: Res := @SCashRegister4244;
    4245: Res := @SCashRegister4245;
    4246: Res := @SCashRegister4246;
    4247: Res := @SCashRegister4247;
    4248: Res := @SCashRegister4248;
    4249: Res := @SCashRegister4249;
    4250: Res := @SCashRegister4250;
    4251: Res := @SCashRegister4251;
    4252: Res := @SCashRegister4252;
    4253: Res := @SCashRegister4253;
    4254: Res := @SCashRegister4254;
    4255: Res := @SCashRegister4255;
    4256: Res := @SCashRegister4256;
    4257: Res := @SCashRegister4257;
    4258: Res := @SCashRegister4258;
    4259: Res := @SCashRegister4259;
    4260: Res := @SCashRegister4260;
    4261: Res := @SCashRegister4261;
    4262: Res := @SCashRegister4262;
    4263: Res := @SCashRegister4263;
    4264: Res := @SCashRegister4264;
    4265: Res := @SCashRegister4265;
    4266: Res := @SCashRegister4266;
    4267: Res := @SCashRegister4267;
    4268: Res := @SCashRegister4268;
    4269: Res := @SCashRegister4269;
    4270: Res := @SCashRegister4270;
    4271: Res := @SCashRegister4271;
    4272: Res := @SCashRegister4272;
    4273: Res := @SCashRegister4273;
    4274: Res := @SCashRegister4274;
    4275: Res := @SCashRegister4275;
    4276: Res := @SCashRegister4276;
    4277: Res := @SCashRegister4277;
    4278: Res := @SCashRegister4278;
    4279: Res := @SCashRegister4279;
    4280: Res := @SCashRegister4280;
    4281: Res := @SCashRegister4281;
    4282: Res := @SCashRegister4282;
    4283: Res := @SCashRegister4283;
    4284: Res := @SCashRegister4284;
    4285: Res := @SCashRegister4285;
    4286: Res := @SCashRegister4286;
    4287: Res := @SCashRegister4287;
    4288: Res := @SCashRegister4288;
    4289: Res := @SCashRegister4289;
    4290: Res := @SCashRegister4290;
    4291: Res := @SCashRegister4291;
    4292: Res := @SCashRegister4292;
    4293: Res := @SCashRegister4293;
    4294: Res := @SCashRegister4294;
    4295: Res := @SCashRegister4295;
    4296: Res := @SCashRegister4296;
    4297: Res := @SCashRegister4297;
    4298: Res := @SCashRegister4298;
    4299: Res := @SCashRegister4299;
    4300: Res := @SCashRegister4300;
    4301: Res := @SCashRegister4301;
    4302: Res := @SCashRegister4302;
    4303: Res := @SCashRegister4303;
    4304: Res := @SCashRegister4304;
    4305: Res := @SCashRegister4305;
    4306: Res := @SCashRegister4306;
    4307: Res := @SCashRegister4307;
    4308: Res := @SCashRegister4308;
    4309: Res := @SCashRegister4309;
    4310: Res := @SCashRegister4310;
    4311: Res := @SCashRegister4311;
    4312: Res := @SCashRegister4312;
    4313: Res := @SCashRegister4313;
    4314: Res := @SCashRegister4314;
    4315: Res := @SCashRegister4315;
    4316: Res := @SCashRegister4316;
    4317: Res := @SCashRegister4317;
    4318: Res := @SCashRegister4318;
    4319: Res := @SCashRegister4319;
    4320: Res := @SCashRegister4320;
    4321: Res := @SCashRegister4321;
    4322: Res := @SCashRegister4322;
    4323: Res := @SCashRegister4323;
    4324: Res := @SCashRegister4324;
    4325: Res := @SCashRegister4325;
    4326: Res := @SCashRegister4326;
    4327: Res := @SCashRegister4327;
    4328: Res := @SCashRegister4328;
    4329: Res := @SCashRegister4329;
    4330: Res := @SCashRegister4330;
    4331: Res := @SCashRegister4331;
    4332: Res := @SCashRegister4332;
    4333: Res := @SCashRegister4333;
    4334: Res := @SCashRegister4334;
    4335: Res := @SCashRegister4335;
    4336: Res := @SCashRegister4336;
    4337: Res := @SCashRegister4337;
    4338: Res := @SCashRegister4338;
    4339: Res := @SCashRegister4339;
    4340: Res := @SCashRegister4340;
    4341: Res := @SCashRegister4341;
    4342: Res := @SCashRegister4342;
    4343: Res := @SCashRegister4343;
    4344: Res := @SCashRegister4344;
    4345: Res := @SCashRegister4345;
    4346: Res := @SCashRegister4346;
    4347: Res := @SCashRegister4347;
    4348: Res := @SCashRegister4348;
    4349: Res := @SCashRegister4349;
    4350: Res := @SCashRegister4350;
    4351: Res := @SCashRegister4351;
    4352: Res := @SCashRegister4352;
    4353: Res := @SCashRegister4353;
    4354: Res := @SCashRegister4354;
    4355: Res := @SCashRegister4355;
    4356: Res := @SCashRegister4356;
    4357: Res := @SCashRegister4357;
    4358: Res := @SCashRegister4358;
    4359: Res := @SCashRegister4359;
    4360: Res := @SCashRegister4360;
    4361: Res := @SCashRegister4361;
    4362: Res := @SCashRegister4362;
    4363: Res := @SCashRegister4363;
    4364: Res := @SCashRegister4364;
    4365: Res := @SCashRegister4365;
    4366: Res := @SCashRegister4366;
    4367: Res := @SCashRegister4367;
    4368: Res := @SCashRegister4368;
    4369: Res := @SCashRegister4369;
    4370: Res := @SCashRegister4370;
    4371: Res := @SCashRegister4371;
    4372: Res := @SCashRegister4372;
    4373: Res := @SCashRegister4373;
    4374: Res := @SCashRegister4374;
    4375: Res := @SCashRegister4375;
    4376: Res := @SCashRegister4376;
    4377: Res := @SCashRegister4377;
    4378: Res := @SCashRegister4378;
    4379: Res := @SCashRegister4379;
    4380: Res := @SCashRegister4380;
    4381: Res := @SCashRegister4381;
    4382: Res := @SCashRegister4382;
    4383: Res := @SCashRegister4383;
    4384: Res := @SCashRegister4384;
    4385: Res := @SCashRegister4385;
    4386: Res := @SCashRegister4386;
    4387: Res := @SCashRegister4387;
    4388: Res := @SCashRegister4388;
    4389: Res := @SCashRegister4389;
    4390: Res := @SCashRegister4390;
    4391: Res := @SCashRegister4391;
    4392: Res := @SCashRegister4392;
    4393: Res := @SCashRegister4393;
    4394: Res := @SCashRegister4394;
    4395: Res := @SCashRegister4395;
    4396: Res := @SCashRegister4396;
    4397: Res := @SCashRegister4397;
    4398: Res := @SCashRegister4398;
    4399: Res := @SCashRegister4399;
    4400: Res := @SCashRegister4400;
    4401: Res := @SCashRegister4401;
    4402: Res := @SCashRegister4402;
    4403: Res := @SCashRegister4403;
    4404: Res := @SCashRegister4404;
    4405: Res := @SCashRegister4405;
    4406: Res := @SCashRegister4406;
    4407: Res := @SCashRegister4407;
    4408: Res := @SCashRegister4408;
    4409: Res := @SCashRegister4409;
    4410: Res := @SCashRegister4410;
    4411: Res := @SCashRegister4411;
    4412: Res := @SCashRegister4412;
    4413: Res := @SCashRegister4413;
    4414: Res := @SCashRegister4414;
    4415: Res := @SCashRegister4415;
    4416: Res := @SCashRegister4416;
    4417: Res := @SCashRegister4417;
    4418: Res := @SCashRegister4418;
    4419: Res := @SCashRegister4419;
    4420: Res := @SCashRegister4420;
    4421: Res := @SCashRegister4421;
    4422: Res := @SCashRegister4422;
    4423: Res := @SCashRegister4423;
    4424: Res := @SCashRegister4424;
    4425: Res := @SCashRegister4425;
    4426: Res := @SCashRegister4426;
  else
    Res := @SNoDescrpiption;
  end;

  if ACapFN then
  begin
    case Number of
      244, 245..248, 253..255:  Res := @SUnusedRegister;
    end;
  end;

  Result := GetRes(Res);
end;

function GetOperRegisterName(Number: Integer; ACapFN: Boolean): WideString;
var
  Res: PResStringRec;
begin
  case Number of
    $00: Res := @SOperatingRegister00;
    $01: Res := @SOperatingRegister01;
    $02: Res := @SOperatingRegister02;
    $03: Res := @SOperatingRegister03;
    $04: Res := @SOperatingRegister04;
    $05: Res := @SOperatingRegister05;
    $06: Res := @SOperatingRegister06;
    $07: Res := @SOperatingRegister07;
    $08: Res := @SOperatingRegister08;
    $09: Res := @SOperatingRegister09;
    $0A: Res := @SOperatingRegister0A;
    $0B: Res := @SOperatingRegister0B;
    $0C: Res := @SOperatingRegister0C;
    $0D: Res := @SOperatingRegister0D;
    $0E: Res := @SOperatingRegister0E;
    $0F: Res := @SOperatingRegister0F;

    $10: Res := @SOperatingRegister10;
    $11: Res := @SOperatingRegister11;
    $12: Res := @SOperatingRegister12;
    $13: Res := @SOperatingRegister13;
    $14: Res := @SOperatingRegister14;
    $15: Res := @SOperatingRegister15;
    $16: Res := @SOperatingRegister16;
    $17: Res := @SOperatingRegister17;
    $18: Res := @SOperatingRegister18;
    $19: Res := @SOperatingRegister19;
    $1A: Res := @SOperatingRegister1A;
    $1B: Res := @SOperatingRegister1B;
    $1C: Res := @SOperatingRegister1C;
    $1D: Res := @SOperatingRegister1D;
    $1E: Res := @SOperatingRegister1E;
    $1F: Res := @SOperatingRegister1F;

    $20: Res := @SOperatingRegister20;
    $21: Res := @SOperatingRegister21;
    $22: Res := @SOperatingRegister22;
    $23: Res := @SOperatingRegister23;
    $24: Res := @SOperatingRegister24;
    $25: Res := @SOperatingRegister25;
    $26: Res := @SOperatingRegister26;
    $27: Res := @SOperatingRegister27;
    $28: Res := @SOperatingRegister28;
    $29: Res := @SOperatingRegister29;
    $2A: Res := @SOperatingRegister2A;
    $2B: Res := @SOperatingRegister2B;
    $2C: Res := @SOperatingRegister2C;
    $2D: Res := @SOperatingRegister2D;
    $2E: Res := @SOperatingRegister2E;
    $2F: Res := @SOperatingRegister2F;

    $30: Res := @SOperatingRegister30;
    $31: Res := @SOperatingRegister31;
    $32: Res := @SOperatingRegister32;
    $33: Res := @SOperatingRegister33;
    $34: Res := @SOperatingRegister34;
    $35: Res := @SOperatingRegister35;
    $36: Res := @SOperatingRegister36;
    $37: Res := @SOperatingRegister37;
    $38: Res := @SOperatingRegister38;
    $39: Res := @SOperatingRegister39;
    $3A: Res := @SOperatingRegister3A;
    $3B: Res := @SOperatingRegister3B;
    $3C: Res := @SOperatingRegister3C;
    $3D: Res := @SOperatingRegister3D;
    $3E: Res := @SOperatingRegister3E;
    $3F: Res := @SOperatingRegister3F;

    $40: Res := @SOperatingRegister40;
    $41: Res := @SOperatingRegister41;
    $42: Res := @SOperatingRegister42;
    $43: Res := @SOperatingRegister43;
    $44: Res := @SOperatingRegister44;
    $45: Res := @SOperatingRegister45;
    $46: Res := @SOperatingRegister46;
    $47: Res := @SOperatingRegister47;
    $48: Res := @SOperatingRegister48;
    $49: Res := @SOperatingRegister49;
    $4A: Res := @SOperatingRegister4A;
    $4B: Res := @SOperatingRegister4B;
    $4C: Res := @SOperatingRegister4C;
    $4D: Res := @SOperatingRegister4D;
    $4E: Res := @SOperatingRegister4E;
    $4F: Res := @SOperatingRegister4F;

    $50: Res := @SOperatingRegister50;
    $51: Res := @SOperatingRegister51;
    $52: Res := @SOperatingRegister52;
    $53: Res := @SOperatingRegister53;
    $54: Res := @SOperatingRegister54;
    $55: Res := @SOperatingRegister55;
    $56: Res := @SOperatingRegister56;
    $57: Res := @SOperatingRegister57;
    $58: Res := @SOperatingRegister58;
    $59: Res := @SOperatingRegister59;
    $5A: Res := @SOperatingRegister5A;
    $5B: Res := @SOperatingRegister5B;
    $5C: Res := @SOperatingRegister5C;
    $5D: Res := @SOperatingRegister5D;
    $5E: Res := @SOperatingRegister5E;
    $5F: Res := @SOperatingRegister5F;

    $60: Res := @SOperatingRegister60;
    $61: Res := @SOperatingRegister61;
    $62: Res := @SOperatingRegister62;
    $63: Res := @SOperatingRegister63;
    $64: Res := @SOperatingRegister64;
    $65: Res := @SOperatingRegister65;
    $66: Res := @SOperatingRegister66;
    $67: Res := @SOperatingRegister67;
    $68: Res := @SOperatingRegister68;
    $69: Res := @SOperatingRegister69;
    $6A: Res := @SOperatingRegister6A;
    $6B: Res := @SOperatingRegister6B;
    $6C: Res := @SOperatingRegister6C;
    $6D: Res := @SOperatingRegister6D;
    $6E: Res := @SOperatingRegister6E;
    $6F: Res := @SOperatingRegister6F;

    $70: Res := @SOperatingRegister70;
    $71: Res := @SOperatingRegister71;
    $72: Res := @SOperatingRegister72;
    $73: Res := @SOperatingRegister73;
    $74: Res := @SOperatingRegister74;
    $75: Res := @SOperatingRegister75;
    $76: Res := @SOperatingRegister76;
    $77: Res := @SOperatingRegister77;
    $78: Res := @SOperatingRegister78;
    $79: Res := @SOperatingRegister79;
    $7A: Res := @SOperatingRegister7A;
    $7B: Res := @SOperatingRegister7B;
    $7C: Res := @SOperatingRegister7C;
    $7D: Res := @SOperatingRegister7D;
    $7E: Res := @SOperatingRegister7E;
    $7F: Res := @SOperatingRegister7F;

    $80: Res := @SOperatingRegister80;
    $81: Res := @SOperatingRegister81;
    $82: Res := @SOperatingRegister82;
    $83: Res := @SOperatingRegister83;
    $84: Res := @SOperatingRegister84;
    $85: Res := @SOperatingRegister85;
    $86: Res := @SOperatingRegister86;
    $87: Res := @SOperatingRegister87;
    $88: Res := @SOperatingRegister88;
    $89: Res := @SOperatingRegister89;
    $8A: Res := @SOperatingRegister8A;
    $8B: Res := @SOperatingRegister8B;
    $8C: Res := @SOperatingRegister8C;
    $8D: Res := @SOperatingRegister8D;
    $8E: Res := @SOperatingRegister8E;
    $8F: Res := @SOperatingRegister8F;

    $90: Res := @SOperatingRegister90;
    $91: Res := @SOperatingRegister91;
    $92: Res := @SOperatingRegister92;
    $93: Res := @SOperatingRegister93;
    $94: Res := @SOperatingRegister94;
    $95: Res := @SOperatingRegister95;
    $96: Res := @SOperatingRegister96;
    $97: Res := @SOperatingRegister97;
    $98: Res := @SOperatingRegister98;
    $99: Res := @SOperatingRegister99;
    $9A: Res := @SOperatingRegister9A;
    $9B: Res := @SOperatingRegister9B;
    $9C: Res := @SOperatingRegister9C;
    $9D: Res := @SOperatingRegister9D;
    $9E: Res := @SOperatingRegister9E;
    $9F: Res := @SOperatingRegister9F;

    $A0: Res := @SOperatingRegisterA0;
    $A1: Res := @SOperatingRegisterA1;
    $A2: Res := @SOperatingRegisterA2;
    $A3: Res := @SOperatingRegisterA3;
    $A4: Res := @SOperatingRegisterA4;
    $A5: Res := @SOperatingRegisterA5;
    $A6: Res := @SOperatingRegisterA6;
    $A7: Res := @SOperatingRegisterA7;
    $A8: Res := @SOperatingRegisterA8;
    $A9: Res := @SOperatingRegisterA9;
    $AA: Res := @SOperatingRegisterAA;
    $AB: Res := @SOperatingRegisterAB;
    $AC: Res := @SOperatingRegisterAC;
    $AD: Res := @SOperatingRegisterAD;
    $AE: Res := @SOperatingRegisterAE;
    $AF: Res := @SOperatingRegisterAF;

    $B0: Res := @SOperatingRegisterB0;
    $B1: Res := @SOperatingRegisterB1;
    $B2: Res := @SOperatingRegisterB2;
    $B3: Res := @SOperatingRegisterB3;
    $B4: Res := @SOperatingRegisterB4;
    $B5: Res := @SOperatingRegisterB5;
    $B6: Res := @SOperatingRegisterB6;
    $B7: Res := @SOperatingRegisterB7;
    $B8: Res := @SOperatingRegisterB8;
    $B9: Res := @SOperatingRegisterB9;
    $BA: Res := @SOperatingRegisterBA;
    $BB: Res := @SOperatingRegisterBB;
    $BC: Res := @SOperatingRegisterBC;
    $BD: Res := @SOperatingRegisterBD;
    $BE: Res := @SOperatingRegisterBE;
    $C1: Res := @SOperatingRegisterC1;
    $C2: Res := @SOperatingRegisterC2;
    $C3: Res := @SOperatingRegisterC3;
    $C4: Res := @SOperatingRegisterC4;
    $C5: Res := @SOperatingRegisterC5;
    $C6: Res := @SOperatingRegisterC6;
    $FF: Res := @SOperatingRegisterFF;
  else
    Res := @SNoDescrpiption;
  end;

  if ACapFN then
  begin
    case Number of
      $B8: Res := @SOperatingRegisterB8FN;
      $B9: Res := @SOperatingRegisterB9FN;
      $BA: Res := @SOperatingRegisterBAFN;
      $BC..$C3, $FF: Res := @SUnusedRegister;
      $C4: Res := @SOperatingRegisterC4FN;
      $C5: Res := @SOperatingRegisterC5FN;
      $C6: Res := @SOperatingRegisterC6FN;
      $C7: Res := @SOperatingRegisterC7FN;

      $C8: Res := @SOperatingRegisterC8FN;
      $C9: Res := @SOperatingRegisterC9FN;
      $CA: Res := @SOperatingRegisterCAFN;
      $CB: Res := @SOperatingRegisterCBFN;
    end;
  end;
  Result := GetRes(Res);
end;


{ ��������� �������� ������� }

function GetCommandName(Command: Word): string;
var
  Res: PResStringRec;
begin
  case Command of
    $01: Res := @SCommandName01;
    $02: Res := @SCommandName02;
    $03: Res := @SCommandName03;
    $0D: Res := @SCommandName0D;
    $0E: Res := @SCommandName0E;
    $0F: Res := @SCommandName0F;
    $10: Res := @SCommandName10;
    $11: Res := @SCommandName11;
    $12: Res := @SCommandName12;
    $13: Res := @SCommandName13;
    $14: Res := @SCommandName14;
    $15: Res := @SCommandName15;
    $16: Res := @SCommandName16;
    $17: Res := @SCommandName17;
    $18: Res := @SCommandName18;
    $19: Res := @SCommandName19;
    $1A: Res := @SCommandName1A;
    $1B: Res := @SCommandName1B;
    $1C: Res := @SCommandName1C;
    $1D: Res := @SCommandName1D;
    $1E: Res := @SCommandName1E;
    $1F: Res := @SCommandName1F;
    $20: Res := @SCommandName20;
    $21: Res := @SCommandName21;
    $22: Res := @SCommandName22;
    $23: Res := @SCommandName23;
    $24: Res := @SCommandName24;
    $25: Res := @SCommandName25;
    $26: Res := @SCommandName26;
    $27: Res := @SCommandName27;
    $28: Res := @SCommandName28;
    $29: Res := @SCommandName29;
    $2A: Res := @SCommandName2A;
    $2B: Res := @SCommandName2B;
    $2C: Res := @SCommandName2C;
    $2D: Res := @SCommandName2D;
    $2E: Res := @SCommandName2E;
    $2F: Res := @SCommandName2F;
    $40: Res := @SCommandName40;
    $41: Res := @SCommandName41;
    $42: Res := @SCommandName42;
    $43: Res := @SCommandName43;
    $44: Res := @SCommandName44;
    $45: Res := @SCommandName45;
    $46: Res := @SCommandName46;
    $4E: Res := @SCommandName4E;
    $4F: Res := @SCommandName4F;
    $50: Res := @SCommandName50;
    $51: Res := @SCommandName51;
    $52: Res := @SCommandName52;
    $53: Res := @SCommandName53;
    $54: Res := @SCommandName54;
    $57: Res := @SCommandname57;
    $60: Res := @SCommandName60;
    $61: Res := @SCommandName61;
    $62: Res := @SCommandName62;
    $63: Res := @SCommandName63;
    $64: Res := @SCommandName64;
    $65: Res := @SCommandName65;
    $66: Res := @SCommandName66;
    $67: Res := @SCommandName67;
    $68: Res := @SCommandName68;
    $69: Res := @SCommandName69;
    $6B: Res := @SCommandName6B;
    $70: Res := @SCommandName70;
    $71: Res := @SCommandName71;
    $72: Res := @SCommandName72;
    $73: Res := @SCommandName73;
    $74: Res := @SCommandName74;
    $75: Res := @SCommandName75;
    $76: Res := @SCommandName76;
    $77: Res := @SCommandName77;
    $78: Res := @SCommandName78;
    $79: Res := @SCommandName79;
    $7A: Res := @SCommandName7A;
    $7B: Res := @SCommandName7B;
    $7C: Res := @SCommandName7C;
    $7D: Res := @SCommandName7D;
    $7E: Res := @SCommandName7E;
    $80: Res := @SCommandName80;
    $81: Res := @SCommandName81;
    $82: Res := @SCommandName82;
    $83: Res := @SCommandName83;
    $84: Res := @SCommandName84;
    $85: Res := @SCommandName85;
    $86: Res := @SCommandName86;
    $87: Res := @SCommandName87;
    $88: Res := @SCommandName88;
    $89: Res := @SCommandName89;
    $8A: Res := @SCommandName8A;
    $8B: Res := @SCommandName8B;
    $8C: Res := @SCommandName8C;
    $8D: Res := @SCommandName8D;
    $90: Res := @SCommandName90;
    $91: Res := @SCommandName91;
    $92: Res := @SCommandName92;
    $93: Res := @SCommandName93;
    $94: Res := @SCommandName94;
    $95: Res := @SCommandName95;
    $96: Res := @SCommandName96;
    $97: Res := @SCommandName97;
    $98: Res := @SCommandName98;
    $99: Res := @SCommandName99;
    $9A: Res := @SCommandName9A;
    $9B: Res := @SCommandName9B;
    $9E: Res := @SCommandName9E;
    $9F: Res := @SCommandName9F;
    $A0: Res := @SCommandNameA0;
    $A1: Res := @SCommandNameA1;
    $A2: Res := @SCommandNameA2;
    $A3: Res := @SCommandNameA3;
    $A4: Res := @SCommandNameA4;
    $A5: Res := @SCommandNameA5;
    $A6: Res := @SCommandNameA6;
    $A7: Res := @SCommandNameA7;
    $A8: Res := @SCommandNameA8;
    $A9: Res := @SCommandNameA9;
    $AA: Res := @SCommandNameAA;
    $AB: Res := @SCommandNameAB;
    $AC: Res := @SCommandNameAC;
    $AD: Res := @SCommandNameAD;
    $AE: Res := @SCommandNameAE;
    $AF: Res := @SCommandNameAF;
    $B0: Res := @SCommandNameB0;
    $B1: Res := @SCommandNameB1;
    $B2: Res := @SCommandNameB2;
    $B3: Res := @SCommandNameB3;
    $B4: Res := @SCommandNameB4;
    $B5: Res := @SCommandNameB5;
    $B6: Res := @SCommandNameB6;
    $B7: Res := @SCommandNameB7;
    $B8: Res := @SCommandNameB8;
    $B9: Res := @SCommandNameB9;
    $BA: Res := @SCommandNameBA;
    $BB: Res := @SCommandNameBB;
    $BC: Res := @SCommandNameBC;
    $C0: Res := @SCommandNameC0;
    $C1: Res := @SCommandNameC1;
    $C2: Res := @SCommandNameC2;
    $C3: Res := @SCommandNameC3;
    $C4: Res := @SCommandNameC4;
    $C5: Res := @SCommandNameC5;
    $D0: Res := @SCommandNameD0;
    $D1: Res := @SCommandNameD1;
    $E0: Res := @SCommandNameE0;
    $F0: Res := @SCommandNameF0;
    $F1: Res := @SCommandNameF1;
    $F7: Res := @SCommandNameF7;
    $FC: Res := @SCommandNameFC;
    $FD: Res := @SCommandNameFD;
    $FE: Res := @SCommandNameFE;
//    $FE03: Res := @SCommandNameFE03;


    $FF01: Res := @SCommandNameFF01;
    $FF02: Res := @SCommandNameFF02;
    $FF03: Res := @SCommandNameFF03;
    $FF04: Res := @SCommandNameFF04;
    $FF05: Res := @SCommandNameFF05;
    $FF06: Res := @SCommandNameFF06;
    $FF07: Res := @SCommandNameFF07;
    $FF08: Res := @SCommandNameFF08;
    $FF09: Res := @SCommandNameFF09;
    $FF0A: Res := @SCommandNameFF0A;
    $FF0B: Res := @SCommandNameFF0B;
    $FF0C: Res := @SCommandNameFF0C;
    $FF0D: Res := @SCommandNameFF0D;
    $FF30: Res := @SCommandNameFF30;
    $FF31: Res := @SCommandNameFF31;
    $FF32: Res := @SCommandNameFF32;
    $FF33: Res := @SCommandNameFF33;
    $FF34: Res := @SCommandNameFF34;
    $FF35: Res := @SCommandNameFF35;
    $FF36: Res := @SCommandNameFF36;
    $FF37: Res := @SCommandNameFF37;
    $FF38: Res := @SCommandNameFF38;
    $FF39: Res := @SCommandNameFF39;
    $FF3A: Res := @SCommandNameFF3A;
    $FF3B: Res := @SCommandNameFF3B;
    $FF3C: Res := @SCommandNameFF3C;
    $FF3D: Res := @SCommandNameFF3D;
    $FF3E: Res := @SCommandNameFF3E;
    $FF3F: Res := @SCommandNameFF3F;
    $FF40: Res := @SCommandNameFF40;
    $FF41: Res := @SCommandNameFF41;
    $FF42: Res := @SCommandNameFF42;
    $FF43: Res := @SCommandNameFF43;
    $FF45: Res := @SCommandNameFF45;
    $FF46: Res := @SCommandNameFF46;
    $FF47: Res := @SCommandNameFF47;
    $FF48: Res := @SCommandNameFF48;
    $FF49: Res := @SCommandNameFF49;
    $FF4A: Res := @SCommandNameFF4A;
    $FF4B: Res := @SCommandNameFF4B;
    $FF4C: Res := @SCommandNameFF4C;
    $FF4D: Res := @SCommandNameFF4D;
    $FF4E: Res := @SCommandNameFF4E;
    $FF50: Res := @SCommandNameFF50;
    $FF51: Res := @SCommandNameFF51;
    $FF52: Res := @SCommandNameFF52;
    $FF60: Res := @SCommandNameFF60;
    $FF61: Res := @SCommandNameFF61;
    $FF62: Res := @SCommandNameFF62;
    $FF63: Res := @SCommandNameFF63;
    $FF64: Res := @SCommandNameFF64;
    $FF65: Res := @SCommandNameFF65;
    $FF66: Res := @SCommandNameFF66;
    $FF67: Res := @SCommandNameFF67;
    $FF68: Res := @SCommandNameFF68;
    $FF69: Res := @SCommandNameFF69;
    $FF70: Res := @SCommandNameFF70;
    $FF71: Res := @SCommandNameFF71;
    $FF72: Res := @SCommandNameFF72;
    $FF73: Res := @SCommandNameFF73;
    $FF74: Res := @SCommandNameFF74;
    $FF75: Res := @SCommandNameFF75;
  else
    Res := @SNoCommandName;
  end;
  Result := GetRes(Res);
end;

{ TPrinterString }

class function TPrinterString.Convert(const S: string): string;
begin
  { !!! }
end;

resourcestring
  /////////////////////////////////////////////////////////////////////////////
  // Poll 1 description

  SPoll1Description10 = '����� ���������';
  SPoll1Description11 = '����� ��������� � ������� � ����������';
  SPoll1Description12 = '����� ��������� � ������� � ����������';
  SPoll1Description13 = '�������������';
  SPoll1Description14 = '�������� ������';
  SPoll1Description15 = '������������� ������';
  SPoll1Description17 = '����������� ������ � ����������';
  SPoll1Description18 = '������� ������';
  SPoll1Description19 = '������ ��������';
  SPoll1Description1A = '������ ������������ ����� ������� HOLD';
  SPoll1Description1B = '���������� ������. ������������ �����: %d ��';
  SPoll1Description1C = '������ �� �������. �������: ';

  SPoll1Description41 = '������������� ������� ���������';
  SPoll1Description42 = '������������� ������� ������� ��� �����������';
  SPoll1Description43 = '������ �������� � �������� ����';
  SPoll1Description44 = '������ �������� � ������������� �������';
  SPoll1Description45 = '������� �������������';
  SPoll1Description46 = '�����. ������ ��������� ������, ��� ���������� ����������';

  SPoll1Description80 = '������ �� ��������� ���������. ��� ������: %d';
  SPoll1Description81 = '������ ������� � ���������. ��� ������: %d';
  SPoll1Description82 = '������ ����������. ��� ������: %d';
  SPoll1DescriptionUnknown = '����������� �������� Poll1';

  /////////////////////////////////////////////////////////////////////////////
  // Poll 2 description

  // Poll1 = 1C
  SPoll2Description1C60 = '������ �������';
  SPoll2Description1C61 = '������ ��������������';
  SPoll2Description1C62 = '������ �������� � �������';
  SPoll2Description1C63 = '������ �����������/���������'; // ???
  SPoll2Description1C64 = '������ ��������������� ������';
  SPoll2Description1C65 = '������ ������������� ������';
  SPoll2Description1C66 = '������ ����������� ������';
  SPoll2Description1C67 = '������ ����������� �������';
  SPoll2Description1C68 = '����������� ������� ������';
  SPoll2Description1C69 = '������ �������';
  SPoll2Description1C6A = '������ ��������';
  SPoll2Description1C6C = '������ �����';
  SPoll2Description1CUnknown = '����������� �������';

  // Poll1 = 47
  SPoll2Description4750 = '������ ��������� ������������� �������';
  SPoll2Description4751 = '������ �������� ������������� ���������';
  SPoll2Description4752 = '������ ������������� ���������';
  SPoll2Description4753 = '������ �������������� ���������';
  SPoll2Description4754 = '��������� ��������� ��������� ������������� �������';
  SPoll2Description4755 = '������ ������ �� ���������� ��������';
  SPoll2Description4756 = '������ ������������� �������';
  SPoll2Description475F = '������ ������� �������';
  SPoll2Description47Unknown = '����������� �������� Poll2';

                                                   function PollToDescription(Poll1: Integer; Poll2: Integer): WideString;
begin
  case Poll1 of
    $10: Result := GetRes(@SPoll1Description10);
    $11: Result := GetRes(@SPoll1Description11);
    $12: Result := GetRes(@SPoll1Description12);
    $13: Result := GetRes(@SPoll1Description13);
    $14: Result := GetRes(@SPoll1Description14);
    $15: Result := GetRes(@SPoll1Description15);
    $17: Result := GetRes(@SPoll1Description17);
    $18: Result := GetRes(@SPoll1Description18);
    $19: Result := GetRes(@SPoll1Description19);
    $1A: Result := GetRes(@SPoll1Description1A);
    $1B: Result := Format(GetRes(@SPoll1Description1B), [Poll2 * 100]);
    $1C: begin
           Result := SPoll1Description1C;
           case Poll2 of
             $60: Result := Result + GetRes(@SPoll2Description1C60);
             $61: Result := Result + GetRes(@SPoll2Description1C61);
             $62: Result := Result + GetRes(@SPoll2Description1C62);
             $63: Result := Result + GetRes(@SPoll2Description1C63);
             $64: Result := Result + GetRes(@SPoll2Description1C64);
             $65: Result := Result + GetRes(@SPoll2Description1C65);
             $66: Result := Result + GetRes(@SPoll2Description1C66);
             $67: Result := Result + GetRes(@SPoll2Description1C67);
             $68: Result := Result + GetRes(@SPoll2Description1C68);
             $69: Result := Result + GetRes(@SPoll2Description1C69);
             $6A: Result := Result + GetRes(@SPoll2Description1C6A);
             $6C: Result := Result + GetRes(@SPoll2Description1C6C);
           else
             Result := Result + GetRes(@SPoll2Description1CUnknown);
           end;
         end;
    $41: Result := GetRes(@SPoll1Description41);
    $42: Result := GetRes(@SPoll1Description42);
    $43: Result := GetRes(@SPoll1Description43);
    $44: Result := GetRes(@SPoll1Description44);
    $45: Result := GetRes(@SPoll1Description45);
    $46: Result := GetRes(@SPoll1Description46);
    $47: case Poll2 of
           $50: Result := GetRes(@SPoll2Description4750);
           $51: Result := GetRes(@SPoll2Description4751);
           $52: Result := GetRes(@SPoll2Description4752);
           $53: Result := GetRes(@SPoll2Description4753);
           $54: Result := GetRes(@SPoll2Description4754);
           $55: Result := GetRes(@SPoll2Description4755);
           $56: Result := GetRes(@SPoll2Description4756);
           $5F: Result := GetRes(@SPoll2Description475F);
         else
           Result := GetRes(@SPoll2Description47Unknown);
         end;
    $80: Result := Format(GetRes(@SPoll1Description80), [Poll2]);
    $81: Result := Format(GetRes(@SPoll1Description81), [Poll2]);
    $82: Result := Format(GetRes(@SPoll1Description82), [Poll2]);
  else
    Result := GetRes(@SPoll1DescriptionUnknown);
  end;
end;

{ ��������� �������� ���������� ������� }
function GetCommandTimeout(Command: Word): Integer;
begin
  case Command of
    $16: Result := 60000; 	// ��������������� ���������
    $B2: Result := 20000; 	// ������������� ������ ����
    $B4: Result := 40000;   // ������ ����������� ����� ����
    $B5: Result := 40000;   // ������ ��������� ����
    $B6: Result := 150000;	// ������ ������ ���� �� ������� � �������� ��������� ���
    $B7: Result := 150000;	// ������ ������ ���� �� ������� � �������� ��������� ������� ����
    $B8: Result := 100000;	// ������ ������ ���� �� ��������� ���� � �������� ��������� ���
    $B9: Result := 100000;	// ������ ������ ���� �� ��������� ���� � �������� ��������� ������� ����
    $BA: Result := 40000; 	// ������ � ���� ������ ����� �� ������ �����
    $40: Result := 30000;   // �������� ����� ��� �������
    $41: Result := 30000;   // �������� ����� � ��������
    $61: Result := 20000;   // ������������� ��
    $62: Result := 30000;   // ������ ����� ������� � ��
    $66: Result := 35000;   // ���������� ����� �� ��������� ���
    $67: Result := 20000;   // ���������� ����� �� ��������� ����
    $FE: Result := 30000;
    $11: Result := 5000;
    $10: Result := 5000;
    $26: Result := 5000;
    $E0: Result := 40000;
    $FF61: Result := 40000;
    $FF67: Result := 40000;
  else
    Result := 30000;	        // �� ���������
  end;
end;

end.
