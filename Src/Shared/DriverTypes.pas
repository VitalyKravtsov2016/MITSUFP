unit DriverTypes;

interface

uses
  // VCL
  Windows, SysUtils, ShlObj,
  // This
  GlobalConst, LogFile;

const
  BARCODE_CODE128A = 0;
  BARCODE_CODE128B = 1;
  BARCODE_CODE128C = 2;
  BARCODE_QRCODE = 3; // 2D
  BARCODE_CODE128AUTO = 4;
  BARCODE_CODE39 = 5;
  BARCODE_CODE93 = 6;
  BARCODE_ITF14 = 7;
  BARCODE_UPCA = 8;
  BARCODE_UPCE = 9;
  BARCODE_PDF417 = 10; //2D
  BARCODE_AZTEC = 11; //2D
  BARCODE_2OF5_INTERLEAVED = 12;

  /////////////////////////////////////////////////////////////////////////////
  // ModelID constants

  MODEL_SHTRIH_MINI_FRK_KAZ = 12;
  MODEL_YARUS_M2100K = 20;

  /////////////////////////////////////////////////////////////////////////////
  // SwapBytesMode

  SwapBytesModeSwap = 0;
  SwapBytesModeNoSwap = 1;
  SwapBytesModeProp = 2;
  SwapBytesModeModel = 3;

resourcestring
  SDriverName = '������� ���';
  SServerVersionUnknown = '����������';
  SDefaultDeviceName = '���������� �';

type
  { TECRDateTime }

  TECRDateTime = record
    Day: Byte;
    Month: Byte;
    Year: Byte;
    Hour: Byte;
    Min: Byte;
    Sec: Byte;
  end;

  { TECRDate }

  TECRDate = record
    Day: Byte;
    Month: Byte;
    Year: Byte;
  end;

  { TECRTime }

  TECRTime = record
    Hour: Byte;
    Min: Byte;
    Sec: Byte;
  end;

  { TLicInfoRec }

  TLicInfoRec = record
    ResultCode: Integer;        // ���������
    ResultDesc: string;         // �������� ����������
    CashControl: Boolean;       // ��������� ������������� CashControl
    RemoteLaunch: Boolean;      // �������� ��������� ������
    KeyCount: Integer;          // ���������� ������
    LicCount: Integer;          // ���������� ��������
  end;

  { TDeviceModel }

  TDeviceModel = (dmUnknown, 					  // ����������� ������
    dmShtrihFRF3,				  // �����-��-� (������ 3)
    dmShtrihFRF4,				  // �����-��-� (������ 4)
    dmShtrihFRFKaz,   	  // �����-��-� (���������)
    dmElvesMiniFRF,			  // �����-����-��-�
    dmFelixRF, 					  // ������-� �
    dmShtrihFRK,				  // �����-��-�
    dmShtrih950K,				  // �����-950� ������ 1
    dmShtrih950Kv2,			  // �����950K ������ 2
    dmElvesFRK, 				  // �����-��-�
    dmShtrihMiniFRK, 		  // �����-����-��-�
    dmShtrihMiniFRK2, 	  // �����-����-��-� 2
    dmShtrihFRFBel, 		  // �����-��-� (����������)
    dmShtrihComboFRKv1,   // �����-�����-��-� ������ 1
    dmShtrihComboFRKv2,   // �����-�����-��-� ������ 2
    dmShtrihPOSF,				  // ���������� ���� �����-POS-�
    dmShtrih500,					// �����-500
    dmShtrihMFRK,         // �����-�-��-�
    dmShtrihLightFRK,    // �����-LIGHT-��-�
    dmYARUS01K,           // ����-01�
    dmYARUS02K,           // ����-02�
    dmYARUSM2100K,          // ���� �2100�
    dmShtrihMobilePTK,  //"�����-MOBILE-���"
    dmYarusTK,  //- "YARUS-��" | "���� YARUS C21"
    dmRetail01K,  //- "Retail-01�"
    dmRR02K,  //- "RR-02�"
    dmRR01K,  //- "RR-01�"
    dmRR04K,  //- "RR-04�"
    dmRR03K  //- "RR-03�"
);

  { TInt64Rec }

  TInt64Rec = record
    Value: Int64;
    IsEmpty: Boolean;
  end;

  { TFRFieldRec }

  TFRFieldRec = record
    FieldSize: Byte;
    FieldName: string;
    IsString: Boolean;
    StrValue: string;
    IntValue: Integer;
    MinValue: Integer;
    MaxValue: Integer;
  end;

  TBanknotes = array[0..23] of Integer;

const
  /////////////////////////////////////////////////////////////////////////////
  // SaveSettingsType constants

  stRegLocalMachine = 0;
  stRegCurrentUser = 1;

  /////////////////////////////////////////////////////////////////////////////
  // ConnectionType constants

  CT_LOCAL = 0;
  CT_TCP = 1;
  CT_DCOM = 2;
  CT_ESCAPE = 3;
  CT_PACKETDRV = 4;
  CT_EMULATOR = 5;
  CT_TCPSOCKET = 6;
  CT_PPP = 7;
  REGSTR_KEY_DRIVER = '\SOFTWARE\ShtrihM\DrvFR';
  REGSTR_KEY_PARAMS = REGSTR_KEY_DRIVER + '\Param';
  REGSTR_KEY_TABLEDEFS = REGSTR_KEY_DRIVER + '\TableDefs';
  REGSTR_KEY_DEVICES = REGSTR_KEY_DRIVER + '\Logical Devices';
  REGSTR_KEY_COMMANDS = REGSTR_KEY_DRIVER + '\Timeouts';
  REGSTR_KEY_PARAMS1C = REGSTR_KEY_DRIVER + '\Params1C';
  REGSTR_KEY_TABLEPARAMS = REGSTR_KEY_DRIVER + '\TableParams';
  REGSTR_KEY_PLUGINS = REGSTR_KEY_DRIVER + '\Plugins';
  // ��������� ����������
  REGSTR_VAL_TIMEOUT = 'Timeout';
  REGSTR_VAL_PLAINTRANSFERMODE = 'PlainTransferMode';
  REGSTR_VAL_TLSMODE = 'TLSMode';
  REGSTR_VAL_CONNECTIONTIMEOUT = 'ConnectionTimeout';
  REGSTR_VAL_TCPCONNECTIONTIMEOUT = 'TCPConnectionTimeout';
  REGSTR_VAL_SYNCTIMEOUT = 'SyncTimeout';
  REGSTR_VAL_BAUDRATE = 'BaudRate';
  REGSTR_VAL_COMNUMBER = 'ComNumber';
  REGSTR_VAL_PROTOCOLTYPE = 'ProtocolType';
  REGSTR_VAL_CURRENTDEVICE = 'CurrentDevice';
  REGSTR_VAL_COMPUTERNAME = 'ComputerName';
  REGSTR_VAL_TCPPORT = 'TCPPort';
  REGSTR_VAL_IPADDRESS = 'IPAddress';
  REGSTR_VAL_USEIPADDRESS = 'UseIPAddress';
  REGSTR_VAL_CONNECTIONTYPE = 'ConnectionType';
  REGSTR_VAL_ESCAPEIP = 'EscapeIP';
  REGSTR_VAL_ESCAPEPORT = 'EscapePort';
  REGSTR_VAL_ESCAPETIMEOUT = 'EscapeTimeout';
  REGSTR_VAL_RECOVERERROR165 = 'RecoverError165';
  REGSTR_VAL_SYSADMINPASSWORD = 'SysAdminPassword';

  //License Trial TimeStamp
  REGSTR_VAL_TRIALSTAMP = 'LCTStamp';

  // �������� �������
  REGSTR_VAL_ROWCOUNT = 'RowCount';
  REGSTR_VAL_TABLENAME = 'TableName';
  REGSTR_VAL_FIELDCOUNT = 'FieldCount';
  REGSTR_VAL_TABLENUMBER = 'TableNumber';
  // �������� ����� �������
  REGSTR_VAL_FIELDNAME = 'Name';
  REGSTR_VAL_FIELDSIZE = 'Size';
  REGSTR_VAL_FIELDTYPE = 'Type';
  REGSTR_VAL_FIELDNUMBER = 'Number';
  REGSTR_VAL_FIELDMINVALUE = 'MinValue';
  REGSTR_VAL_FIELDMAXVALUE = 'MaxValue';
  // �������� ��������� ����������
  REGSTR_VAL_DEVICENAME = 'Name';
  REGSTR_VAL_DEVICENUMBER = 'Number';
  REGSTR_VAL_DEVICETIMEOUT = 'Timeout';
  REGSTR_VAL_DEVICEBAUDRATE = 'Baudrate';
  REGSTR_VAL_DEVICECOMNUMBER = 'ComNumber';
  REGSTR_VAL_LOCKTIMEOUT = 'LockTimeout';
  // �������� �������
  REGSTR_VAL_COMMAND_CODE = 'Code';
  REGSTR_VAL_COMMAND_NAME = 'Name';
  REGSTR_VAL_COMMAND_TIMEOUT = 'Timeout';
  REGSTR_VAL_COMMAND_DEFTIMEOUT = 'DefTimeout';
  // ��������� � ������ ���� �������
  REGSTR_VAL_TABLE_LEFT = 'Left';
  REGSTR_VAL_TABLE_TOP = 'Top';
  REGSTR_VAL_TABLE_WIDTH = 'Width';
  REGSTR_VAL_TABLE_HEIGHT = 'Heigth';
  DefTimeout = 3000;              // ������� �� ���������
  DefConnectionTimeout = 0;               // ������� ����������� �� ���������
  DefTCPConnectionTimeout = 10000;
  DefBaudRate = 1;                // �������� �� ��������� 4800
  DefComNumber = 1;                // ����� COM �����
  DefTCPPort = 7778;              // ���� ������� ������ �� ���������
  DefIPAddress = '192.168.137.111';      // IP ����� ������� ������ �� ���������
  DefConnectionType = CT_LOCAL;         // ��� ����������� �� ���������
  DefEscapeIP = '127.0.0.1';      // IP ����� Escape �� ���������
  DefEscapePort = 1000;             // UDP ���� Escape �� ���������
  DefEscapeTimeout = 1000;             // ������� Escape �� ���������, ��
  DefSysAdminPassword = 30;
  DefSwapBytesMode = SwapBytesModeModel;
  QuantityFactor: Integer = 1000;
  BoolToInt: array[Boolean] of Byte = (0, 1);
  BoolToStr: array[Boolean] of string = ('0', '1');
  MODE_CHECK_OPENED = 8;

  //
  MaxRepeatCount = 3;

  /////////////////////////////////////////////////////////////////////////////
  // PrintBarcodeText

  PrintBarcodeTextNone = 0;
  PrintBarcodeTextBelow = 1;
  PrintBarcodeTextAbove = 2;
  PrintBarcodeTextBoth = 3;
  DefMaxAnsCount = 5;
  DefCommandRetryCount = 3;
  DefMaxCmdCount = 5;
  DefLogMaxFileSize = 10;
  DefLogMaxFileCount = 10;
  DefStorageType = stRegCurrentUser;

const
  // � �������� ������������ ������ ���
  E_ECR_FMOVERFLOW = $14; // ������� ������� ������ �� �����������
  E_ECR_PASSWORD = $4F; // �������� ������

  // ���� ������ ��������
  E_NOERROR = 0;
  E_NOHARDWARE = -1;  // ��� �����
  E_NOPORT = -2;  // �OM ���� ����������
  E_PORTBUSY = -3;  // �OM ���� ����� ������ �����������
  E_ANSWERLENGTH = -7;  // �������� ����� ������
  E_UNKNOWN = -8;
  E_INVALIDPARAM = -9;  // �������� ��� ���������
  E_NOTSUPPORTED = -12; // �� �������������� � ������ ������ ��������
  E_NOTLOADED = -16; // �� ������� ������������ � �������
  E_PORTLOCKED = -18; // ���� ����������
  E_REMOTECONNECTION = -19; // ��������� ����������� ���������

  E_USERBREAK = -30; // �������� �������������
  E_MP_SALEERROR = -31; // ������ ��������� �������.
  E_MP_CHECKOPENED = -32; // ��� ������. ������ ����������
  E_MP_PAYERROR = -33;
  E_NOPAPER = -34; // ��� ������
  E_RESET = -35; // �� ������� �������� ���
  E_MODELNOTFOUND = -36; // �� ������� �������� ������
  E_MODELSFILEERROR = -37; // �� ������ ��� ��������� ���� "Models.xml"
  E_SERVERVERSIONERROR = -38; // ������������� ������ ������� ��
  E_UNKNOWNTAG = -39;           // ����������� ���
  E_FILENOTFOUND = -40; // ���� �� ������
  E_DOCUMENTNOTFOUND = -41; // �������� �� ������
  E_INCORRECTTLVLENGTH = -42; // ����� ������ TLV ��������� ����������

  E_KMSRV_GENERIC_ERROR = -43; // ������ ���, ����� ������
  E_KMSRV_NOT_IMPLEMENTED = -44; // ������ ���, �� �����������
  E_KMSRV_UNSUPPORTED_TYPE = -45; // ������ ���, ���������������� ���
  E_KMSRV_UNSUPPORTED_VERSION = -46; // ������ ���, ���������������� ������
  E_SALE_NOT_ENABLED = -47; // ������� ���������
  E_FW_UPDATE_STARTED = -48; // ���� ���������� ��������
  E_DFU_MODE_NOT_SUPPORTED = -49; // ����� DFU �� �������������� ������ �������

  E_VMCSCANNER_ERROR = -50;
  E_DATE_TIME_DIFFER_MORE_THAN_24H = -51;

  CBR_230400 = 230400;
  CBR_460800 = 460800;
  CBR_921600 = 921600;
  FWUPDATE_SUCCESS = 0;
  FWUPDATE_RUNNING = 1;
  FWUPDATE_ERROR = 2;

resourcestring
  SIncorrectTLVLength = '����� ������ TLV ��������� ��������� ����������';
  SDriverNoErrors = '������ ���';
  SDriverNoHardware = '��� �����';
  SDriverNoPort = '�OM ���� ����������';
  SDriverPortBusy = '�OM ���� ����� ������ �����������';
  SDriverServerError = '������ �����������';
  SDriverAbortedByUser = '�������� �������������';
  SDriverAnswerLength = '�������� ����� ������';
  SDriverNotSupported = '�� �������������� � ������ ������ ��������';
  SDriverUnknown = '����������� ������';
  SDriverRemoteConnection = '��������� ����������� ���������';
  SDriverMPSaleError = '������ ��������� �������';
  SDriverReceiptOpened = '��� ������. ������ ����������';
  SDriverReset = '�� ������� �������� ���';
  SDriverPortLocked = '���� ����������';
  SDriverModelNotFound = '�� ������� �������� ������';
  SDriverModelsMissing = '�� ������ ��� ��������� ���� "Models.xml"';
  SDriverServerVersionError = '������������� ������ ������� ��';
  SUnknownTag = '����������� ���';
  SFileNotFound = '���� �� ������';
  SDocumentNotFound = '�������� �� ������';
  SFwupdateStarted = '���� ���������� �������� ���. �� ���������� ������� � �� ���������� ����������';
  SDfuModeNotSupported = '����� DFU �� �������������� �������';
  S_DATE_TIME_DIFFER_MORE_THAN_24H = '���� � ����� � �� � ��� ���������� �����, ��� �� �����';

resourcestring
  SParamsReadError = '������ ������ ����������: ';
  SParamsWriteError = '������ ������ ����������: ';

function GetDllFileName: string;

function ECRDateTimeToDateTime(const Value: TECRDateTime): TDateTime;

function GetDefaultLogFileName: string;

function GetUserShtrihPath: string;

function GetUserShtrihPath_def: string;

function GetBackupTablesPath: string;

function GetRegRootKey(RootKeyType: Integer): HKEY;

function GetCommonShtrihPath: string;

function DRV_SUCCESS(Value: Integer): Boolean;

function IsModelType2(Value: Integer): Boolean;

implementation

function DRV_SUCCESS(Value: Integer): Boolean;
begin
  Result := Value = E_NOERROR;
end;

function GetRegRootKey(RootKeyType: Integer): HKEY;
begin
  if RootKeyType = stRegLocalMachine then
    Result := HKEY_LOCAL_MACHINE
  else
    Result := HKEY_CURRENT_USER;
end;

function ECRDateTimeToDateTime(const Value: TECRDateTime): TDateTime;
begin
  try
    Result := EncodeDate(Value.Year + 2000, Value.Month, Value.Day) + EncodeTime(Value.Hour, Value.Min, Value.Sec, 0);
  except
    Result := 0;
  end;
end;

function GetDllFileName: string;
var
  Buffer: array[0..261] of Char;
begin
  SetString(Result, Buffer, Windows.GetModuleFileName(HInstance, Buffer, SizeOf(Buffer)));
end;

function GetUserShtrihPath: string;
begin
  SetLength(Result, MAX_PATH);
  ShlObj.SHGetSpecialFolderPath(0, @Result[1], CSIDL_APPDATA, false);
  SetLength(Result, Pos(#0, Result) - 1);

  Result := IncludeTrailingBackSlash(Result) + 'SHTRIH-M';
  if not DirectoryExists(Result) then
    CreateDir(Result);
  Result := Result + '\DrvFR';
  if not DirectoryExists(Result) then
    CreateDir(Result);
end;

{ !!! }
function GetCommonShtrihPath: string;
begin
(*
  SetLength(Result, MAX_PATH);
  ShlObj.SHGetSpecialFolderPath(0, @Result[1], CSIDL_COMMON_APPDATA, false);
  SetLength(Result, Pos(#0, Result) - 1);

  Result := IncludeTrailingBackSlash(Result) + 'SHTRIH-M';
  if not DirectoryExists(Result) then
    CreateDir(Result);
  Result := Result + '\DrvFR';
  if not DirectoryExists(Result) then
    CreateDir(Result);
*)
end;

function GetTempShtrihPath: string;
begin
(*
  SetLength(Result, MAX_PATH);
  ShlObj.SHGetSpecialFolderPath(0, @Result[1], CSIDL_COMMON_APPDATA, false);
  SetLength(Result, Pos(#0, Result) - 1);

  Result := IncludeTrailingBackSlash(Result) + 'SHTRIH-M';
  if not DirectoryExists(Result) then
    CreateDir(Result);
  Result := Result + '\DrvFR';
  if not DirectoryExists(Result) then
    CreateDir(Result);
*)    
end;


function GetUserShtrihPath_def: string;
begin
  SetLength(Result, MAX_PATH);
  ShlObj.SHGetSpecialFolderPath(0, @Result[1], CSIDL_APPDATA, false);
  SetLength(Result, Pos(#0, Result) - 1);

  Result := IncludeTrailingBackSlash(Result) + 'SHTRIH-M';
  if not DirectoryExists(Result) then
    CreateDir(Result);
end;

function GetDefaultLogFileName: string;
var
  DllFileName: string;
begin
  Result := IncludeTrailingBackslash(GetUserShtrihPath) + 'Logs\';
  if not DirectoryExists(Result) then
    CreateDir(Result);
  Result := Result + ChangeFileExt(ExtractFileName(DllFileName), '.log');
end;

function GetBackupTablesPath: string;
begin
  Result := IncludeTrailingBackslash(GetUserShtrihPath) + 'Tables';
end;


{
  16 - "�����-MPAY-�" | "���� MPAY" | "�����-����-�"
  19 - Mobile
  20 - "YARUS �2100�" | "���� YARUS �21" | "���� �2100�" // �� ������������
  21 - "YARUS-��" | "���� YARUS C21" | "���� ��" // �� ������������
  27 - "YARUS-KZ C21" // ��������� ISOFT // � ����������� ������ ��-��� // �� ������������ // C2100
  28 - "YARUS-MD C21" // ���������� // � ����������� ������ ��-��� // �� ������������ // C2100
  29 - "YARUS �2100�" | "���� YARUS M21" // 44 ��; Partner Windows CE 6.0
  30 - "YARUS �2100�" | "���� YARUS M21" // 57 ��; Partner Windows CE 6.0
  32 - "YARUS-TM C21" // ����������� // ��� ����������� ����� // �� ������������
  33 - "YARUS-MD M21" // ���������� // � ����������� ������ ��-��� // �� ������������ // M2100
  34 - "YARUS-KZ M21" // ��������� ISOFT // � ����������� ������ ��-��� // �� ������������ // M2100
  35 - "YARUS-TM M21" // ����������� // ��� ����������� ����� // �� ������������
  36 - "YARUS-TK-KZ C21" // ��������� dzun // ��� ����������� ����� ��-��� // �� ������������ // C2100
  37 - "YARUS-TK-KZ M21" // ��������� dzun // ��� ����������� ����� ��-��� // �� ������������ // M2100
  38 - "YARUS-KG C21" // ��������� // � ����������� ������ ��-��� // �� ������������ // C2100
  39 - "YARUS-KG M21" // ��������� // � ����������� ������ ��-��� // �� ������������ // M2100
  40 - "YARUS �2100�" | "���� YARUS �21" | "���� �2100�" // ��������� Jibe
  41 - "YARUS �2100�" | "���� YARUS �21" | "���� �2100�" // ������� M7100
  42 - "�����-MPAY-�Z" // ��������� ISOFT // � ����������� ������ ��-��� // MPAY
  45 - "����-01�" // SZZT KS8223
  45 - "�����-��������-�" // TELPO/ALPS/ROCO TPS570A
  45 - "�����-��������-����-�" // TELPO/ALPS/ROCO TPS900 // CLONTEK CS-10
  46 - "POSCENTER-AND-�" // JOLIMARK-IM-78 // 80 ��
}
// 37 - �����-����-��
// ������ ������ ��������, � ������ ���������� ������

function IsModelType2(Value: Integer): Boolean;
begin
  Result := Value in [16, 19, 20, 21, 27, 28, 29, 30, 32, 33, 34, 35, 36, {37,} 38, 39, 40, 41, 42, 45, 45, 45, 46];
  GlobalLogger.Debug('IsModelType2 ' + IntToStr(Value) + ' ' + SysUtils.BoolToStr(Result, True));
end;

end.

