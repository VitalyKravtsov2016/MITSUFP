unit DriverTypes;

interface

uses
  // VCL
  Windows, SysUtils, ShlObj,
  // This
  GlobalConst;

const
  /////////////////////////////////////////////////////////////////////////////
  // ModelID constants

  MODEL_SHTRIH_MINI_FRK_KAZ = 12;



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

resourcestring
  SParamsReadError = '������ ������ ����������: ';
  SParamsWriteError = '������ ������ ����������: ';

resourcestring
  SDriverName = '������� ' + DeviceName;
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
    dmYARUS02K            // ����-02�
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
  Registration = $01;        //	����� � �����������
  OpenSession = $02;         //	����� �� �������� �����
  Receipt = $03;             //	�������� ���
  BSO = $04;                 //	����� ������� ����������
  CloseSession = $05;        //	����� � �������� �����
  CloseFN = $06;             //	����� � �������� ����������� ����������
  OperatorConfirm = $07;     //	������������� ���������
  ChangeRegistrationParams = $0B;    //	����� �� ��������� ���������� �����������
  CalculationStatusReport = $15;     //	����� � ������� ��������� ��������
  CorrectionReceipt = $1F;           //	�������� ��� ���������
  CorrectionBSO = $29;               //	����� ������� ���������� ���������

type
  { TFNDocType }

  TFNDocType = class
    class function ToString(const AValue: Integer): string;
  end;

const
  Income = 1; // ������
  ReturnIncome = 2;  // ������� �������
  Outcome = 3;       // ������
  ReturnOutcome = 4; // ������� �������

type
  { TFNCheckType }

  TFNCheckType = class
    class function ToString(const AValue: Integer): string;
  end;

const
  // ��� ����� � ����������� ��������
  DriverIniFileName = 'DrvFRIni.xml';

  // SaveSettingsType
  stRegLocalMachine = 0;
  stRegCurrentUser = 1;

  // ConnectionType
  CT_LOCAL = 0;
  CT_TCP = 1;
  CT_DCOM = 2;
  CT_ESCAPE = 3;
  CT_PACKETDRV = 4;
  CT_EMULATOR = 5;
  CT_TCPSOCKET = 6;
  REGSTR_KEY_DRIVER = '\SOFTWARE\ShtrihM\DrvFR';
  REGSTR_KEY_PARAMS = REGSTR_KEY_DRIVER + '\Param';
  REGSTR_KEY_TABLEDEFS = REGSTR_KEY_DRIVER + '\TableDefs';
  REGSTR_KEY_DEVICES = REGSTR_KEY_DRIVER + '\Logical Devices';
  REGSTR_KEY_COMMANDS = REGSTR_KEY_DRIVER + '\Timeouts';
  REGSTR_KEY_PARAMS1C = REGSTR_KEY_DRIVER + '\Params1C';
  REGSTR_KEY_TABLEPARAMS = REGSTR_KEY_DRIVER + '\TableParams';
  // ��������� ����������
  REGSTR_VAL_TIMEOUT = 'Timeout';
  REGSTR_VAL_CONNECTIONTIMEOUT = 'ConnectionTimeout';
  REGSTR_VAL_BAUDRATE = 'BaudRate';
  REGSTR_VAL_COMNUMBER = 'ComNumber';
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
  DefTimeout = 100;              // ������� �� ���������
  DefConnectionTimeout = 0;               // ������� ����������� �� ���������
  DefBaudRate = 1;                // �������� �� ��������� 4800
  DefComNumber = 1;                // ����� COM �����
  DefTCPPort = 211;              // ���� ������� ������ �� ���������
  DefIPAddress = '127.0.0.1';      // IP ����� ������� ������ �� ���������
  DefConnectionType = CT_LOCAL;         // ��� ����������� �� ���������
  DefEscapeIP = '127.0.0.1';      // IP ����� Escape �� ���������
  DefEscapePort = 1000;             // UDP ���� Escape �� ���������
  DefEscapeTimeout = 1000;             // ������� Escape �� ���������, ��
  DefSysAdminPassword = 30;
  QuantityFactor: Integer = 1000;
  BoolToInt: array[Boolean] of Byte = (0, 1);
  BoolToStr: array[Boolean] of string = ('0', '1');
  MODE_CHECK_OPENED = 8;

  //
  MaxRepeatCount = 3;

  // PrintBarcodeType
  pbNone = 0;
  pbDown = 1;
  pbUp = 2;
  pbUpDown = 3;
  DefMaxAnsCount = 5;
  DefCommandRetryCount = 1;
  DefLogMaxFileSize = 10;
  DefLogMaxFileCount = 10;
  DefSaveSettingsType = stRegLocalMachine;

function GetDllFileName: string;

function ECRDateTimeToDateTime(const Value: TECRDateTime): TDateTime;

function GetDefaultLogFileName: string;

function GetUserShtrihPath: string;

function SaveSettingsTypeToRegRootKey(SaveSettingsType: Integer): HKEY;

implementation

function SaveSettingsTypeToRegRootKey(SaveSettingsType: Integer): HKEY;
begin
  if SaveSettingsType = stRegLocalMachine then
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

function GetDefaultLogFileName: string;
var
  DllFileName: string;
begin
  DllFileName := GetDllFileName;
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(DllFileName)) + 'Logs\' + ChangeFileExt(ExtractFileName(DllFileName), '.log');
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

{ TFNDocType }

class function TFNDocType.ToString(const AValue: Integer): string;
begin
  case AValue of
    Registration:
      Result := '����� � �����������';
    OpenSession:
      Result := '����� �� �������� �����';
    Receipt:
      Result := '�������� ���';
    BSO:
      Result := '����� ������� ����������';
    CloseSession:
      Result := '����� � �������� �����';
    CloseFN:
      Result := '����� � �������� ����������� ����������';
    OperatorConfirm:
      Result := '������������� ���������';
    ChangeRegistrationParams:
      Result := '����� �� ��������� ���������� �����������';
    CalculationStatusReport:
      Result := '����� � ������� ��������� ��������';
    CorrectionReceipt:
      Result := '�������� ��� ���������';
    CorrectionBSO:
      Result := '��� ���������';
  else
    Result := '����������� ��� ���������';
  end;
end;

{ TFNCheckType }

class function TFNCheckType.ToString(const AValue: Integer): string;
begin
  case AValue of
    Income:
      Result := '������';
    ReturnIncome:
      Result := '������� �������';
    Outcome:
      Result := '������';
    ReturnOutcome:
      Result := '������� �������';
  else
    Result := '����������� ��� ����';
  end;
end;

end.

