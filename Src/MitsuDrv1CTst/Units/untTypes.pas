unit untTypes;

interface

uses
  // VCL
  SysUtils;

type
  { T1CConnectionParams }

  T1CConnectionParams = record
    Port: Integer;
    Speed: Integer;
    UserPassword: string;
    AdminPassword: string;
    Timeout: Integer;
    Tax1: Single;
    Tax2: Single;
    Tax3: Single;
    Tax4: Single;
    CloseSession: Boolean;
    EnableLog: Boolean;
    PayName1: string;
    PayName2: string;
    PayName3: string;
    PrintLogo: Boolean;
    LogoSize: Integer;
    ConnectionType: Integer;
    ComputerName: string;
    IPAddress: string;
    TCPPort: Integer;
    SerialNumber: string;
    ProtocolType: Integer;
    BufferStrings: Boolean;
    BarcodeFirstLine: Integer;
    QRCodeHeight: Integer;
  end;

const
  C_PORT = 0;
  C_SPEED = 1;
  C_USERPASSWORD = 2;
  C_ADMINPASSWORD = 3;
  C_TIMEOUT = 4;
  C_SERIALNUMBER = 5;
  C_TAX1 = 6;
  C_TAX2 = 7;
  C_TAX3 = 8;
  C_TAX4 = 9;
  C_CLOSESESSION = 10;
  C_ENABLELOG = 11;
  C_PAYNAME1 = 12;
  C_PAYNAME2 = 13;
  C_PRINTLOGO = 14;
  C_LOGOSIZE = 15;
  C_CONNECTION_TYPE = 16;
  C_COMPUTERNAME = 17;
  C_IPADDRESS = 18;
  C_TCPPORT = 19;
  C_PROTOCOLTYPE = 20;
  C_BUFFERSTRINGS = 21;

function GetIntParamValue(V: Variant; Index: Integer; var Value: Integer): Boolean;
function GetIntParamValueAsString(V: Variant; Index: Integer): string;
function GetBoolParamValue(V: Variant; Index: Integer;
  var Value: Boolean): Boolean;
function GetBoolParamValueAsString(V: Variant; Index: Integer): string;
function GetSingleParamValue(V: Variant; Index: Integer;
  var Value: Single): Boolean;
function GetStrParamValue(V: Variant; Index: Integer;
  var Value: string): Boolean;
function GetStrParamValueAsString(V: Variant; Index: Integer): string;
function ValuesArrayToStr(const AValuesArray: IDispatch; AOut: Boolean = False): string;
function LogoValuesArrayToStr(const AValuesArray: IDispatch): string;

implementation


function GetIntParamValue(V: Variant; Index: Integer; var Value: Integer): Boolean;
begin
  Result := True;
  try
    Value := Integer(V.Get(Index));
  except
    Result := False;
  end;
end;

function GetIntParamValueAsString(V: Variant; Index: Integer): string;
var
  Value: Integer;
begin
  if GetIntParamValue(V, Index, Value) then
    Result := IntToStr(Value)
  else
    Result := '<??>';
end;

function GetBoolParamValue(V: Variant; Index: Integer;
  var Value: Boolean): Boolean;
begin
  Result := True;
  try
    Value := Boolean(V.Get(Index));
  except
    Result := False;
  end;
end;

function GetBoolParamValueAsString(V: Variant; Index: Integer): string;
var
  Value: Boolean;
begin
  if GetBoolParamValue(V, Index, Value) then
    Result := SysUtils.BoolToStr(Value, True)
  else
    Result := '<??>';
end;

function GetSingleParamValue(V: Variant; Index: Integer;
  var Value: Single): Boolean;
begin
  Result := True;
  try
    Value := Single(V.Get(Index));
  except
    Result := False;
  end;
end;

function GetSingleParamValueAsString(V: Variant; Index: Integer): string;
var
  Value: Single;
begin
  if GetSingleParamValue(V, Index, Value) then
    Result := Format('%.2f', [Value])
  else
    Result := '<??>'
end;

function GetStrParamValue(V: Variant; Index: Integer;
  var Value: string): Boolean;
begin
  Result := True;
  try
    Value := string(V.Get(Index));
  except
    Result := False;
  end;
end;

function GetStrParamValueAsString(V: Variant; Index: Integer): string;
var
  Value: string;
begin
  if GetStrParamValue(V, Index, Value) then
    Result := Value
  else
    Result := '<??>';
end;

function ValuesArrayToStr(const AValuesArray: IDispatch; AOut: Boolean = False): string;
var
  V: Variant;
  sPort: string;
  sSpeed: string;
  sUserPassword: string;
  sAdminPassword: string;
  sTimeout: string;
  sTax1: string;
  sTax2: string;
  sTax3: string;
  sTax4: string;
  sCloseSession: string;
  sEnableLog: string;
  sPayName1: string;
  sPayName2: string;
  sPrintLogo: string;
  sLogoSize: string;
  sConnectionType: string;
  sComputerName: string;
  sIPAddress: string;
  sTCPPort: string;
begin
  V := AValuesArray;

  sPort := GetIntParamValueAsString(V, C_PORT);

  sSpeed := GetIntParamValueAsString(V, C_SPEED);

  sUserPassword :=  GetStrParamValueAsString(V, C_USERPASSWORD);

  sAdminPassword := GetStrParamValueAsString(V, C_ADMINPASSWORD);

  sTimeout := GetIntParamValueAsString(V, C_TIMEOUT);

  sTax1 := GetSingleParamValueAsString(V, C_TAX1);

  sTax2 := GetSingleParamValueAsString(V, C_TAX2);

  sTax3 := GetSingleParamValueAsString(V, C_TAX3);

  sTax4 := GetSingleParamValueAsString(V, C_TAX4);

  sCloseSession :=  GetBoolParamValueAsString(V, C_CLOSESESSION);

  sEnableLog := GetBoolParamValueAsString(V, C_ENABLELOG);

  sPayName1 := GetStrParamValueAsString(V, C_PAYNAME1);

  sPayName2 := GetStrParamValueAsString(V, C_PAYNAME2);

  sPrintLogo := GetBoolParamValueAsString(V, C_PRINTLOGO);

  sLogoSize := GetIntParamValueAsString(V, C_LOGOSIZE);

  sConnectionType := GetIntParamValueAsString(V, C_CONNECTION_TYPE);

  sComputerName := GetStrParamValueAsString(V, C_COMPUTERNAME);

  sIPAddress := GetStrParamValueAsString(V, C_IPADDRESS);

  sTCPPort := GetIntParamValueAsString(V, C_TCPPORT);

  Result := 'Port: ' + sPort + '; Speed: ' + sSpeed + '; UserPassword: ' + sUserPassword +
            '; AdminPassword: ' + sAdminPassword + '; Timeout: ' + sTimeout +
            '; Tax1: ' + sTax1 + '; Tax2: ' + sTax2 + '; Tax3: ' + sTax3 + '; Tax4: ' + sTax4 +
            '; CloseSession: ' + sCloseSession + '; EnableLog: ' + sEnableLog +
            '; PayName1: ' + sPayName1 + '; PayName2: ' + sPayName2 +
            '; PrintLogo: ' + sPrintLogo + '; LogoSize: ' + sLogoSize +
            '; ConnectionType: ' + sConnectionType + '; ComputerName: ' + sComputerName +
            '; IPAddress: ' + sIPAddress + '; TCPPort: ' + sTCPPort;

  if AOut then
    Result := Result + '; SerialNumber: ' + GetStrParamValueAsString(V, C_SERIALNUMBER);
end;

function LogoValuesArrayToStr(const AValuesArray: IDispatch): string;
var
  V: Variant;
  sPort: string;
  sSpeed: string;
  sUserPassword: string;
  sTimeout: string;
  sConnectionType: string;
  sComputerName: string;
  sIPAddress: string;
  sTCPPort: string;
begin
  V := AValuesArray;

  sPort := GetIntParamValueAsString(V, 0);

  sSpeed := GetIntParamValueAsString(V, 1);

  sUserPassword :=  GetStrParamValueAsString(V, 2);

  sTimeout := GetIntParamValueAsString(V, 3);

  sConnectionType := GetIntParamValueAsString(V, 4);

  sComputerName := GetStrParamValueAsString(V, 5);

  sIPAddress := GetStrParamValueAsString(V, 6);

  sTCPPort := GetIntParamValueAsString(V, 7);

  Result := 'Port: ' + sPort + '; Speed: ' + sSpeed + '; Userpassword: ' + sUserPassword +
            '; Timeout: ' + sTimeout +
            '; ConnectionType: ' + sConnectionType + '; ComputerName: ' + sComputerName +
            '; IPAddress: ' + sIPAddress + '; TCPPort: ' + sTCPPort;
end;


end.
