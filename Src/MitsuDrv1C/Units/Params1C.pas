unit Params1C;

interface

uses
  // VCL
  SysUtils,
  // This
  LangUtils, DriverError, Types1C, DriverTypes;

const
  // Value indexes
  DRVFR_VALUE_INDEX_PORT            = 0;
  DRVFR_VALUE_INDEX_SPEED           = 1;
  DRVFR_VALUE_INDEX_USERPASSWORD    = 2;
  DRVFR_VALUE_INDEX_ADMINPASSWORD   = 3;
  DRVFR_VALUE_INDEX_TIMEOUT         = 4;
  DRVFR_VALUE_INDEX_SERIALNUMBER    = 5;
  DRVFR_VALUE_INDEX_TAX1            = 6;
  DRVFR_VALUE_INDEX_TAX2            = 7;
  DRVFR_VALUE_INDEX_TAX3            = 8;
  DRVFR_VALUE_INDEX_TAX4            = 9;
  DRVFR_VALUE_INDEX_CLOSESESSION    = 10;
  DRVFR_VALUE_INDEX_ENABLELOG       = 11;
  DRVFR_VALUE_INDEX_PAYNAME1        = 12;
  DRVFR_VALUE_INDEX_PAYNAME2        = 13;
  DRVFR_VALUE_INDEX_PRINTLOGO       = 14;
  DRVFR_VALUE_INDEX_LOGOSIZE        = 15;
  DRVFR_VALUE_INDEX_CONNECTION_TYPE = 16;
  DRVFR_VALUE_INDEX_COMPUTERNAME    = 17;
  DRVFR_VALUE_INDEX_IPADDRESS       = 18;
  DRVFR_VALUE_INDEX_TCPPORT         = 19;
  DRVFR_VALUE_INDEX_PROTOCOLTYPE    = 20;
  DRVFR_VALUE_INDEX_BUFFERSTRINGS   = 21;

procedure RaiseInvalidValue(const ValueName: string);
function GetIntParamValue(V: Variant; Index: Integer; var Value: Integer): Boolean;
function GetBoolParamValue(V: Variant; Index: Integer; var Value: Boolean): Boolean;
function GetSingleParamValue(V: Variant; Index: Integer; var Value: Single): Boolean;
function GetStrParamValue(V: Variant; Index: Integer; var Value: string): Boolean;
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

procedure RaiseInvalidValue(const ValueName: string);
begin
  RaiseError(E_INVALIDPARAM, Format('%s, "%s"', [
    GetRes(@SErrorParameterRead), ValueName]));
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

function GetBoolParamValueAsString(V: Variant; Index: Integer): string;
var
  Value: Boolean;
begin
  if GetBoolParamValue(V, Index, Value) then
    Result := SysUtils.BoolToStr(Value, True)
  else
    Result := '<??>';
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
  sPort := GetIntParamValueAsString(V, DRVFR_VALUE_INDEX_PORT);
  sSpeed := GetIntParamValueAsString(V, DRVFR_VALUE_INDEX_SPEED);
  sUserPassword :=  GetStrParamValueAsString(V, DRVFR_VALUE_INDEX_USERPASSWORD);
  sAdminPassword := GetStrParamValueAsString(V, DRVFR_VALUE_INDEX_ADMINPASSWORD);
  sTimeout := GetIntParamValueAsString(V, DRVFR_VALUE_INDEX_TIMEOUT);
  sTax1 := GetSingleParamValueAsString(V, DRVFR_VALUE_INDEX_TAX1);
  sTax2 := GetSingleParamValueAsString(V, DRVFR_VALUE_INDEX_TAX2);
  sTax3 := GetSingleParamValueAsString(V, DRVFR_VALUE_INDEX_TAX3);
  sTax4 := GetSingleParamValueAsString(V, DRVFR_VALUE_INDEX_TAX4);
  sCloseSession :=  GetBoolParamValueAsString(V, DRVFR_VALUE_INDEX_CLOSESESSION);
  sEnableLog := GetBoolParamValueAsString(V, DRVFR_VALUE_INDEX_ENABLELOG);
  sPayName1 := GetStrParamValueAsString(V, DRVFR_VALUE_INDEX_PAYNAME1);
  sPayName2 := GetStrParamValueAsString(V, DRVFR_VALUE_INDEX_PAYNAME2);
  sPrintLogo := GetBoolParamValueAsString(V, DRVFR_VALUE_INDEX_PRINTLOGO);
  sLogoSize := GetIntParamValueAsString(V, DRVFR_VALUE_INDEX_LOGOSIZE);
  sConnectionType := GetIntParamValueAsString(V, DRVFR_VALUE_INDEX_CONNECTION_TYPE);
  sComputerName := GetStrParamValueAsString(V, DRVFR_VALUE_INDEX_COMPUTERNAME);
  sIPAddress := GetStrParamValueAsString(V, DRVFR_VALUE_INDEX_IPADDRESS);
  sTCPPort := GetIntParamValueAsString(V, DRVFR_VALUE_INDEX_TCPPORT);
  Result := 'Port: ' + sPort + '; Speed: ' + sSpeed + '; Userpassword: ' + sUserPassword +
            '; AdminPassword: ' + sAdminPassword + '; Timeout: ' + sTimeout +
            '; Tax1: ' + sTax1 + '; Tax2: ' + sTax2 + '; Tax3: ' + sTax3 + '; Tax4: ' + sTax4 +
            '; CloseSession: ' + sCloseSession + '; EnableLog: ' + sEnableLog +
            '; PayName1: ' + sPayName1 + '; PayName2: ' + sPayName2 +
            '; PrintLogo: ' + sPrintLogo + '; LogoSize: ' + sLogoSize +
            '; ConnectionType: ' + sConnectionType + '; ComputerName: ' + sComputerName +
            '; IPAddress: ' + sIPAddress + '; TCPPort: ' + sTCPPort;

  if AOut then
    Result := Result + '; SerialNumber: ' + GetStrParamValueAsString(V,
      DRVFR_VALUE_INDEX_SERIALNUMBER);
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
