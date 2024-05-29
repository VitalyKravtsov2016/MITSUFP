unit Extention30;

interface

uses
  SysUtils, v8napi, Driver30, untLogger, logfile;

type
  TExtention30 = class(TV8UserObject)
  private
    FLogger: TLogger;
    FDriver: TDriver30;
    procedure CheckParamCount(ACount: Integer; AExpected: Integer);
    function HandleException(E: Exception): Boolean;

  public
    constructor Create; override;
    destructor Destroy; override;

    // Common methods
    function GetInterfaceRevision(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function GetDescription(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function GetLastError(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function GetParameters(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function SetParameter(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function Open(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function Close(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function DeviceTest(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function GetAdditionalActions(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function DoAdditionalAction(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function GetLocalizationPattern(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function SetLocalization(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    // KKT Methods
    function GetDataKKT(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function OperationFN(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function OpenShift(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function CloseShift(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function ProcessCheck(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function ProcessCorrectionCheck(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function PrintTextDocument(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function CashInOutcome(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function PrintXReport(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function PrintCheckCopy(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function GetCurrentStatus(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function ReportCurrentStatusOfSettlements(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function OpenCashDrawer(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function GetLineLength(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;

    function ProcessCheck34(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function OpenSessionRegistrationKM(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function CloseSessionRegistrationKM(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function RequestKM(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function GetProcessingKMResult(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): Boolean;
    function ConfirmKM(RetValue: PV8Variant;  Params: PV8ParamArray; const ParamCount: integer;  var v8: TV8AddInDefBase): Boolean;
  end;

implementation

{ TExtention30 }

constructor TExtention30.Create;
begin
  inherited;
//  GlobalLogger.Enabled := True;
//  GlobalLogger.FileName := 'e:\v8napi.txt';
  FLogger := TLogger.Create(Self.ClassName);
  FDriver := TDriver30.Create;
end;

destructor TExtention30.Destroy;
begin
  FDriver.Free;
  FLogger.Free;
  inherited;
end;

function TExtention30.HandleException(E: Exception): Boolean;
begin
  Result := False;
  FLogger.Error(E.Message);
end;

procedure TExtention30.CheckParamCount(ACount: Integer; AExpected: Integer);
begin
  if ACount < AExpected then
    raise Exception.Create('Incorrect Params count: ' + IntToStr(ACount) + '; Must be: ' + IntToStr(AExpected));
end;


///////////////////////////// Common methods

//function GetInterfaceRevision: Integer;
function TExtention30.GetInterfaceRevision(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  Revision: Integer;
begin
{$IFDEF V1C_34}
  FDriver.Set_sm_FormatVersion(41);
{$ELSE}
  FDriver.Set_sm_FormatVersion(30);
{$ENDIF}

  FLogger.Debug('GetInterfaceRevision ' + 'ParamCount = ' + IntToStr(ParamCount));
  Revision := FDriver.GetInterfaceRevision;
  V8SetInt(RetValue, Revision);
  Result := True;
end;

// function GetDescription(var DriverDescription: WideString): Boolean;
function TExtention30.GetDescription(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DriverDescription: WideString;
begin
{$IFDEF V1C_34}
  FDriver.Set_sm_FormatVersion(40);
{$ELSE}
  FDriver.Set_sm_FormatVersion(30);
{$ENDIF}

  FLogger.Debug('GetDescription ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 1);
    V8SetBool(RetValue, FDriver.GetDescription(DriverDescription));
    V8SetWString(@Params[1], DriverDescription);

    FLogger.Debug('GetDescription ' + V8AsWString(@Params[1]));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

// function GetLastError(var ErrorDescription: WideString): Integer;
function TExtention30.GetLastError(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  ErrorDescription: WideString;
begin
  FLogger.Debug('GetLastError ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 1);
    V8SetInt(RetValue, FDriver.GetLastError(ErrorDescription));
    V8SetWString(@Params[1], ErrorDescription)
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

// function GetParameters(var TableParameters: WideString): Boolean;
function TExtention30.GetParameters(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  TableParameters: WideString;
begin
  FLogger.Debug('GetParameters ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 1);
    V8SetBool(RetValue, FDriver.GetParameters(TableParameters));
    V8SetWString(@Params[1], TableParameters);
    FLogger.Debug('GetParameters = ' + V8AsWString(@Params[1]));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

// function SetParameter(const Name: WideString; Value: Variant): Boolean;
function TExtention30.SetLocalization(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
begin

end;

function TExtention30.SetParameter(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  Name: WideString;
  Value: WideString;
begin
  FLogger.Debug('SetParameter ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 2);
    Name := V8AsWString(@Params[1]);

    Value := V8AsVariant(@Params[2]);
    V8SetBool(RetValue, FDriver.SetParameter(Name, Value));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function Open(var DeviceID: WideString): Boolean;
function TExtention30.Open(RetValue: PV8Variant; Params: PV8ParamArray;
  const ParamCount: integer; var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
begin
  FLogger.Debug('Open ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 1);
    V8SetBool(RetValue, FDriver.Open(DeviceID));
    V8SetWString(@Params[1], DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function Close(const DeviceID: WideString): Boolean;
function TExtention30.Close(RetValue: PV8Variant; Params: PV8ParamArray;
  const ParamCount: integer; var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
begin
  FLogger.Debug('Close ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 1);
    DeviceID := V8AsWString(@Params[1]);
    V8SetBool(RetValue, FDriver.Close(DeviceID));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function DeviceTest(var Description: WideString; var DemoModeIsActivated: WideString): Boolean;
function TExtention30.DeviceTest(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  Description: WideString;
  DemoModeIsActivated: WideString;
begin
  FLogger.Debug('DeviceTest ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 2);
    V8SetBool(RetValue, FDriver.DeviceTest(Description, DemoModeIsActivated));
    V8SetWString(@Params[1], Description);
    V8SetWString(@Params[2], DemoModeIsActivated)
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function GetAdditionalActions(var TableActions: WideString): Boolean;
function TExtention30.GetAdditionalActions(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  TableActions: WideString;
begin
  FLogger.Debug('GetAdditionalActions ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 1);
    V8SetBool(RetValue, FDriver.GetAdditionalActions(TableActions));
    V8SetWString(@Params[1], TableActions);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function DoAdditionalAction(const ActionName: WideString): Boolean;
function TExtention30.DoAdditionalAction(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  ActionName: WideString;
begin
  FLogger.Debug('DoAdditionalAction ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 1);
    ActionName := V8AsWString(@Params[1]);
    V8SetBool(RetValue, FDriver.DoAdditionalAction(ActionName));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

///////////////////////////// KKT methods

//function GetDataKKT(const DeviceID: WideString; var TableParametersKKT: WideString): Boolean;
function TExtention30.GetDataKKT(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  TableParametersKKT: WideString;
begin
  FLogger.Debug('GetDataKKT ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 2);
    DeviceID := V8AsWString(@Params[1]);
    V8SetBool(RetValue, FDriver.GetDataKKT(DeviceID, TableParametersKKT));
    V8SetWString(@Params[2], TableParametersKKT);

  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

// function OperationFN(const DeviceID: WideString; OperationType: Integer; const ParametersFiscal: WideString): Boolean;
function TExtention30.OperationFN(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  OperationType: Integer;
  ParametersFiscal: WideString;
begin
  FLogger.Debug('OperationFN ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 3);
    DeviceID := V8AsWString(@Params[1]);
    OperationType := V8AsInt(@Params[2]);
    ParametersFiscal := V8AsWString(@Params[3]);
    V8SetBool(RetValue, FDriver.OperationFN(DeviceID, OperationType, ParametersFiscal));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function OpenShift(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): Boolean;
function TExtention30.OpenShift(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  InputParameters: WideString;
  OutputParameters: WideString;
begin
  FLogger.Debug('OpenShift ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 3);
    DeviceID := V8AsWString(@Params[1]);
    InputParameters := V8AsWString(@Params[2]);
    V8SetBool(RetValue, FDriver.OpenShift(DeviceID, InputParameters, OutputParameters));
    V8SetWString(@Params[3], OutputParameters);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function CloseShift(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): Boolean;
function TExtention30.CloseShift(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  InputParameters: WideString;
  OutputParameters: WideString;
begin
  FLogger.Debug('CloseShift ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 3);
    DeviceID := V8AsWString(@Params[1]);
    InputParameters := V8AsWString(@Params[2]);
    V8SetBool(RetValue, FDriver.CloseShift(DeviceID, InputParameters, OutputParameters));
    V8SetWString(@Params[3], OutputParameters);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;


//function ProcessCheck(const DeviceID: WideString; Electronically: Boolean; const CheckPackage: WideString; var DocumentOutputParameters: WideString): Boolean;
function TExtention30.ProcessCheck(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  Electronically: Boolean;
  CheckPackage: WideString;
  DocumentOutputParameters: WideString;
begin
  FLogger.Debug('ProcessCheck ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    FDriver.Set_sm_FormatVersion(30);
    CheckParamCount(ParamCount, 4);
    DeviceID := V8AsWString(@Params[1]);
    Electronically := V8AsBool(@Params[2]);
    CheckPackage := V8AsWString(@Params[3]);
    V8SetBool(RetValue, FDriver.ProcessCheck(DeviceID, Electronically, CheckPackage, DocumentOutputParameters));
    V8SetWString(@Params[4], DocumentOutputParameters);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function ProcessCorrectionCheck(const DeviceID: WideString; const  CheckPackage: WideString; var DocumentOutputParameters: WideString): Boolean;
function TExtention30.ProcessCorrectionCheck(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  CheckPackage: WideString;
  DocumentOutputParameters: WideString;
begin
  FLogger.Debug('ProcessCorrectionCheck ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 3);
    DeviceID := V8AsWString(@Params[1]);
    CheckPackage := V8AsWString(@Params[2]);
    V8SetBool(RetValue, FDriver.ProcessCorrectionCheck(DeviceID, CheckPackage, DocumentOutputParameters));
    V8SetWString(@Params[3], DocumentOutputParameters);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function PrintTextDocument(const DeviceID: WideString; const  DocumentPackage: WideString): Boolean;
function TExtention30.PrintTextDocument(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  DocumentPackage: WideString;
begin
  FLogger.Debug('PrintTextDocument ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 2);
    DeviceID := V8AsWString(@Params[1]);
    Logger.Debug('DeviceID ' + DeviceID);
    DocumentPackage := V8AsWString(@Params[2]);
    Logger.Debug('DocumentPackage ' + DocumentPackage);
    V8SetBool(RetValue, FDriver.PrintTextDocument(DeviceID, DocumentPackage));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function CashInOutcome(const DeviceID: WideString; const InputParameters: WideString; Amount: Double): Boolean;
function TExtention30.CashInOutcome(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  InputParameters: WideString;
  Amount: Double;
begin
  try
    Result := True;
    FLogger.Debug('CashInOutcome ' + 'ParamCount = ' + IntToStr(ParamCount));
    CheckParamCount(ParamCount, 3);
    DeviceID := V8AsWString(@Params[1]);
    InputParameters := V8AsWString(@Params[2]);
    Amount := V8AsDouble(@Params[3]);
    V8SetBool(RetValue, FDriver.CashInOutcome(DeviceID, InputParameters, Amount));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function PrintXReport(const DeviceID: WideString; const InputParameters: WideString): Boolean;
function TExtention30.PrintXReport(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  InputParameters: WideString;
begin
  try
    Result := True;
    FLogger.Debug('PrintXReport ' + 'ParamCount = ' + IntToStr(ParamCount));
    CheckParamCount(ParamCount, 2);
    DeviceID := V8AsWString(@Params[1]);
    InputParameters := V8AsWString(@Params[2]);
    V8SetBool(RetValue, FDriver.PrintXReport(DeviceID, InputParameters));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function PrintCheckCopy(const DeviceID: WideString; const  CheckNumber: WideString): Boolean;
function TExtention30.PrintCheckCopy(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  CheckNumber: WideString;
begin
  try
    Result := True;
    FLogger.Debug('PrintCheckCopy ' + 'ParamCount = ' + IntToStr(ParamCount));
    CheckParamCount(ParamCount, 2);
    DeviceID := V8AsWString(@Params[1]);
    CheckNumber := V8AsWString(@Params[2]);
    V8SetBool(RetValue, FDriver.PrintCheckCopy(DeviceID, CheckNumber));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function GetCurrentStatus(const DeviceID: WideString; const  InputParameters: WideString; var OutputParameters: WideString): Boolean;
function TExtention30.GetCurrentStatus(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  InputParameters: WideString;
  OutputParameters: WideString;
begin
  FLogger.Debug('GetCurrentStatus ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 3);
    DeviceID := V8AsWString(@Params[1]);
    InputParameters := V8AsWString(@Params[2]);
    V8SetBool(RetValue, FDriver.GetCurrentStatus(DeviceID, InputParameters, OutputParameters));
    V8SetWString(@Params[3], OutputParameters);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function ReportCurrentStatusOfSettlements(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): Boolean;
function TExtention30.ReportCurrentStatusOfSettlements(
  RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  InputParameters: WideString;
  OutputParameters: WideString;
begin
  FLogger.Debug('ReportCurrentStatusOfSettlements ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 3);
    DeviceID := V8AsWString(@Params[1]);
    InputParameters := V8AsWString(@Params[2]);
    V8SetBool(RetValue, FDriver.ReportCurrentStatusOfSettlements(DeviceID, InputParameters, OutputParameters));
    V8SetWString(@Params[3], OutputParameters);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function OpenCashDrawer(const DeviceID: WideString): Boolean;
function TExtention30.OpenCashDrawer(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
begin
  FLogger.Debug('OpenCashDrawer ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 1);
    DeviceID := V8AsWString(@Params[1]);
    V8SetBool(RetValue, FDriver.OpenCashDrawer(DeviceID));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

//function GetLineLength(const DeviceID: WideString; var LineLength: Integer): Boolean;
function TExtention30.GetLineLength(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  LineLength: Integer;
begin
  FLogger.Debug('GetLineLength ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 2);
    DeviceID := V8AsWString(@Params[1]);
    V8SetBool(RetValue, FDriver.GetLineLength(DeviceID, LineLength));
    V8SetInt(@Params[2], LineLength);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;


function TExtention30.GetLocalizationPattern(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
begin

end;

// V34

function TExtention30.ProcessCheck34(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  Electronically: Boolean;
  CheckPackage: WideString;
  DocumentOutputParameters: WideString;
begin
  FLogger.Debug('ProcessCheck ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    FDriver.Set_sm_FormatVersion(34);
    CheckParamCount(ParamCount, 4);
    DeviceID := V8AsWString(@Params[1]);
    Electronically := V8AsBool(@Params[2]);
    CheckPackage := V8AsWString(@Params[3]);
    V8SetBool(RetValue, FDriver.ProcessCheck(DeviceID, Electronically, CheckPackage, DocumentOutputParameters));
    V8SetWString(@Params[4], DocumentOutputParameters);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

// ЗакрытьСессиюРегистрацииКМ(CloseSessionRegistrationKM) 		STRING [IN] BOOL 	Закрывает сессию регистрацию контрольных марок
//    ИДУстройства (DeviceID) Идентификатор устройства
function TExtention30.CloseSessionRegistrationKM(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
begin
  FLogger.Debug('CloseSessionRegistrationKM ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 1);
    DeviceID := V8AsWString(@Params[1]);
    V8SetBool(RetValue, FDriver.CloseSessionRegistrationKM(DeviceID));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;


// ОткрытьСессиюРегистрацииКМ(OpenSessionRegistrationKM) BOOL 	Открывает сессию регистрацию контрольных марок
//       ИДУстройства (DeviceID) 	STRING [IN] 	Идентификатор устройства
function TExtention30.OpenSessionRegistrationKM(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
begin
  FLogger.Debug('OpenSessionRegistrationKM ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 1);
    DeviceID := V8AsWString(@Params[1]);
    V8SetBool(RetValue, FDriver.OpenSessionRegistrationKM(DeviceID));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

// ЗапросКМ (RequestKM) BOOL 	Метод производит локальную проверку КМ фискальным накопителем и формирование запроса о коде маркировки в ОИСМ.
// Метод возвращает результаты локальной проверки КМ фискальным накопителем.
//    ИДУстройства (DeviceID) 	STRING [IN] 	Идентификатор устройства
//    ЗапросКМ(RequestKM) XML таблица 	STRING [IN] 	Входные параметры запроса
//    РезультатЗапросаКМ(RequestKMResult) XML таблица 	STRING [OUT] 	Результат запроса

//function RequestKM(const DeviceID, RequestKM: WideString; var RequestKMResult: WideString): WordBool;
function TExtention30.RequestKM(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  RequestKM: WideString;
  RequestKMResult: WideString;
begin
  FLogger.Debug('RequestKM ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 3);
    DeviceID := V8AsWString(@Params[1]);
    RequestKM := V8AsWString(@Params[2]);
    V8SetBool(RetValue, FDriver.RequestKM(DeviceID, RequestKM, RequestKMResult));
    V8SetWString(@Params[3], RequestKMResult);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;


// ПолучитьРезультатыЗапросаКМ
// (GetProcessingKMResult) BOOL 	Метод запрашивает результаты проверки кода маркировки в ОИСМ.
//    ИДУстройства (DeviceID) 	STRING [IN] 	Идентификатор устройства
//    РезультатЗапросаКМ(ProcessingKMResult)  XML таблица 	STRING [OUT] 	Результат запроса
//    СтатусЗапроса (RequestStatus ) 	LONG [OUT] 	Статус запроса:
//          0 – результат получен
//          1 – результат еще не получен
//          2 – результата не может быть получен

//    function GetProcessingKMResult(const DeviceID: WideString; var ProcessingKMResult: WideString;
//          var RequestStatus: Integer): WordBool;

function TExtention30.GetProcessingKMResult(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  ProcessingKMResult: WideString;
  RequestStatus: Integer;
begin
  FLogger.Debug('GetProcessingKMResult ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 3);
    DeviceID := V8AsWString(@Params[1]);
    V8SetBool(RetValue, FDriver.GetProcessingKMResult(DeviceID, ProcessingKMResult, RequestStatus));
    V8SetWString(@Params[2], ProcessingKMResult);
    V8SetInt(@Params[3], RequestStatus);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

// ПодтвердитьКМ (ConfirmKM)  BOOL 	Подтверждает или отменяет к выбытию проверенную ранее КМ в состав документа о реализации маркированного товара. КМ должны быть ранее проверена методом ЗапросКМ (RequestKM)
//    ИДУстройства (DeviceID) 	STRING [IN] 	Идентификатор устройства
//    ИдентификаторЗапроса (GUID) 	STRING [IN] 	Уникальный идентификатор запроса КМ который ранее был произведен методом ЗапросКМ (RequestKM)
//    ТипПодтверждения (ConfirmationType) 	LONG [IN]
//            0 - КМ будет реализована в состав документа о реализации маркированного товара.
//            1 - КМ не будет реализована. НЕ войдет в документ о реализации маркированного товара.

//    function ConfirmKM(const DeviceID, RequestGUID: WideString; ConfirmationType: Integer): WordBool;
function TExtention30.ConfirmKM(RetValue: PV8Variant;
  Params: PV8ParamArray; const ParamCount: integer;
  var v8: TV8AddInDefBase): Boolean;
var
  DeviceID: WideString;
  RequestGUID: WideString;
  ConfirmationType: Integer;
begin
  FLogger.Debug('ConfirmKM ' + 'ParamCount = ' + IntToStr(ParamCount));
  try
    Result := True;
    CheckParamCount(ParamCount, 3);
    DeviceID := V8AsWString(@Params[1]);
    RequestGUID := V8AsWString(@Params[2]);
    ConfirmationType := V8AsInt(@Params[3]);
    V8SetBool(RetValue, FDriver.ConfirmKM(DeviceID, RequestGUID, ConfirmationType));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;



end.
