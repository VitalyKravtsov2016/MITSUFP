unit OleMain1C30;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  // VCL
  ActiveX, StdVcl, SysUtils, ActiveXView, ComObj, ComServ,
  // This
  MitsuLib_TLB, LogFile, MitsuDrv_1C, StringUtils, ActiveXControl1C,
  AddIn1CInterface, AxCtrls, classes, TranslationUtil, FileUtils;

type
  TDrvFR1C30 = class(TActiveXControl1C, IMitsu1C30)
  private
    FLogger: ILogFile;
    FDriver: TMitsuDrv1C;
    function GetLogFile: ILogFile;
    function GetDriver: TMitsuDrv1C;
    property Logger: ILogFile read GetLogFile;
    property Driver: TMitsuDrv1C read GetDriver;
  protected
    function GetInterfaceRevision: Integer; safecall;
    function GetDescription(out DriverDescription: WideString)
      : WordBool; safecall;
    function GetLastError(out ErrorDescription: WideString): Integer; safecall;
    function GetParameters(out TableParameters: WideString): WordBool; safecall;
    function SetParameter(const Name: WideString; Value: OleVariant)
      : WordBool; safecall;
    function Open(out DeviceID: WideString): WordBool; safecall;
    function Close(const DeviceID: WideString): WordBool; safecall;
    function DeviceTest(out Description: WideString;
      out DemoModeIsActivated: WideString): WordBool; safecall;
    function GetAdditionalActions(out TableActions: WideString)
      : WordBool; safecall;
    function DoAdditionalAction(const ActionName: WideString)
      : WordBool; safecall;
    function GetDataKKT(const DeviceID: WideString;
      out TableParametersKKT: WideString): WordBool; safecall;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
      const ParametersFiscal: WideString): WordBool; safecall;
    function OpenShift(const DeviceID: WideString;
      const InputParameters: WideString; out OutputParameters: WideString)
      : WordBool; safecall;
    function CloseShift(const DeviceID: WideString;
      const InputParameters: WideString; out OutputParameters: WideString)
      : WordBool; safecall;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool;
      const CheckPackage: WideString; out DocumentOutputParameters: WideString)
      : WordBool; safecall;
    function ProcessCorrectionCheck(const DeviceID: WideString;
      const CheckPackage: WideString; out DocumentOutputParameters: WideString)
      : WordBool; safecall;
    function PrintTextDocument(const DeviceID: WideString;
      const DocumentPackage: WideString): WordBool; safecall;
    function CashInOutcome(const DeviceID: WideString;
      const InputParameters: WideString; Amount: Double): WordBool; safecall;
    function PrintXReport(const DeviceID: WideString;
      const InputParameters: WideString): WordBool; safecall;
    function GetCurrentStatus(const DeviceID: WideString;
      const InputParameters: WideString; out OutputParameters: WideString)
      : WordBool; safecall;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString;
      const InputParameters: WideString; out OutputParameters: WideString)
      : WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; safecall;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer)
      : WordBool; safecall;
    function PrintCheckCopy(const DeviceID: WideString;
      const CheckNumber: WideString): WordBool; safecall;
    function CloseSessionRegistrationKM(const DeviceID: WideString)
      : WordBool; safecall;

    function ConfirmKM(const DeviceID, RequestGUID: WideString;
      ConfirmationType: Integer): WordBool; safecall;
    function Get_sm_FormatVersion: Integer; safecall;
    function GetProcessingKMResult(const DeviceID: WideString;
      out ProcessingKMResult: WideString; out RequestStatus: Integer)
      : WordBool; safecall;

    function OpenSessionRegistrationKM(const DeviceID: WideString)
      : WordBool; safecall;

    function RequestKM(const DeviceID, RequestKM: WideString;
      out RequestKMResult: WideString): WordBool; safecall;
    procedure Set_sm_FormatVersion(Value: Integer); safecall;
    function GetLocalizationPattern(out LocalizationPattern: WideString)
      : WordBool; safecall;
    function SetLocalization(const LanguageCode, LocalizationPattern
      : WideString): WordBool; safecall;
  public
    procedure SetLang(LangID: Integer); safecall;
    destructor Destroy; override;
  end;

implementation

destructor TDrvFR1C30.Destroy;
begin
  FDriver.Free;
  FLogger := nil;
  inherited Destroy;
end;

function TDrvFR1C30.GetLogFile: ILogFile;
begin
  if FLogger = nil then
  begin
    FLogger := TLogFile.Create;
    FLogger.Enabled := true;
    FLogger.FilePath := GetModulePath;
    FLogger.FileName := 'MitsuDrv1C.log';
  end;
  Result := FLogger;
end;


function TDrvFR1C30.CashInOutcome(const DeviceID, InputParameters: WideString;
  Amount: Double): WordBool;
begin
  Result := Driver.CashInOutcome(DeviceID, InputParameters, Amount);
end;

function TDrvFR1C30.Close(const DeviceID: WideString): WordBool;
begin
  Result := Driver.Close(DeviceID);
end;

function TDrvFR1C30.CloseShift(const DeviceID, InputParameters: WideString;
  out OutputParameters: WideString): WordBool;
begin
  Result := Driver.CloseShift(DeviceID, InputParameters, OutputParameters);
end;

function TDrvFR1C30.DeviceTest(out Description: WideString;
  out DemoModeIsActivated: WideString): WordBool;
begin
  Result := Driver.DeviceTest(Description, DemoModeIsActivated);
end;

function TDrvFR1C30.DoAdditionalAction(const ActionName: WideString): WordBool;
begin
  Result := Driver.DoAdditionalAction(ActionName);
end;

function TDrvFR1C30.GetAdditionalActions(out TableActions: WideString)
  : WordBool;
begin
  Result := Driver.GetAdditionalActions(TableActions);
end;

function TDrvFR1C30.GetCurrentStatus(const DeviceID, InputParameters
  : WideString; out OutputParameters: WideString): WordBool;
begin
  Result := Driver.GetCurrentStatus(DeviceID, InputParameters,
    OutputParameters);
end;

function TDrvFR1C30.GetDataKKT(const DeviceID: WideString;
  out TableParametersKKT: WideString): WordBool;
begin
  Result := Driver.GetDataKKT(DeviceID, TableParametersKKT);
end;

function TDrvFR1C30.GetDescription(out DriverDescription: WideString): WordBool;
begin
  Result := Driver.GetDescription(DriverDescription);
end;

function TDrvFR1C30.GetDriver: TMitsuDrv1C;
begin
  if FDriver = nil then
    FDriver := TMitsuDrv1C.Create;
  Result := FDriver;
end;

function TDrvFR1C30.GetInterfaceRevision: Integer;
begin
  Result := Driver.GetInterfaceRevision;
end;

function TDrvFR1C30.GetLastError(out ErrorDescription: WideString): Integer;
begin
  Logger.Debug('GetLastError');
  Result := Driver.GetLastError(ErrorDescription);
  Logger.Debug(Format('%s(ErrorDescription: %s): %d', ['GetLastError',
    ErrorDescription, Result]));
end;

function TDrvFR1C30.GetLineLength(const DeviceID: WideString;
  out LineLength: Integer): WordBool;
begin
  Logger.Debug(Format('GetLineLength(DeviceID: %s)', [DeviceID]));
  Result := Driver.GetLineLength(DeviceID, LineLength);
  Logger.Debug(Format('GetLineLength(LineLength: %d): %s',
    [LineLength, BoolToStr(Result)]));
end;

function TDrvFR1C30.GetParameters(out TableParameters: WideString): WordBool;
begin
  Result := Driver.GetParameters(TableParameters);
end;

function TDrvFR1C30.Open(out DeviceID: WideString): WordBool;
begin
  Result := Driver.Open(DeviceID);
end;

function TDrvFR1C30.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin
  Result := Driver.OpenCashDrawer(DeviceID);
end;

function TDrvFR1C30.OpenShift(const DeviceID, InputParameters: WideString;
  out OutputParameters: WideString): WordBool;
begin
  Result := Driver.OpenShift(DeviceID, InputParameters, OutputParameters);
end;

function TDrvFR1C30.OperationFN(const DeviceID: WideString;
  OperationType: Integer; const ParametersFiscal: WideString): WordBool;
begin
  Result := Driver.OperationFN(DeviceID, OperationType, ParametersFiscal);
end;

function TDrvFR1C30.PrintCheckCopy(const DeviceID, CheckNumber: WideString)
  : WordBool;
begin
  Result := Driver.PrintCheckCopy(DeviceID, CheckNumber);
end;

function TDrvFR1C30.PrintTextDocument(const DeviceID, DocumentPackage
  : WideString): WordBool;
begin
  Result := Driver.PrintTextDocument(DeviceID, DocumentPackage);
end;

function TDrvFR1C30.PrintXReport(const DeviceID, InputParameters: WideString)
  : WordBool;
begin
  Result := Driver.PrintXReport(DeviceID, InputParameters);
end;

function TDrvFR1C30.ProcessCheck(const DeviceID: WideString;
  Electronically: WordBool; const CheckPackage: WideString;
  out DocumentOutputParameters: WideString): WordBool;
begin
  Result := Driver.ProcessCheck(DeviceID, Electronically, CheckPackage,
    DocumentOutputParameters);
end;

function TDrvFR1C30.ProcessCorrectionCheck(const DeviceID,
  CheckPackage: WideString; out DocumentOutputParameters: WideString): WordBool;
begin
  Result := Driver.ProcessCorrectionCheck(DeviceID, CheckPackage,
    DocumentOutputParameters);
end;

function TDrvFR1C30.ReportCurrentStatusOfSettlements(const DeviceID,
  InputParameters: WideString; out OutputParameters: WideString): WordBool;
begin
  Result := Driver.ReportCurrentStatusOfSettlements(DeviceID, InputParameters,
    OutputParameters);
end;

procedure TDrvFR1C30.SetLang(LangID: Integer);
begin
  if LangID = 0 then
    SetCustomTranslationLanguage('RU')
  else
    SetCustomTranslationLanguage('EN');
end;

function TDrvFR1C30.SetParameter(const Name: WideString; Value: OleVariant)
  : WordBool;
begin
  Result := Driver.SetParameter(Name, Value);
end;

function TDrvFR1C30.CloseSessionRegistrationKM(const DeviceID: WideString)
  : WordBool;
begin
  Result := Driver.CloseSessionRegistrationKM(DeviceID);
end;

function TDrvFR1C30.ConfirmKM(const DeviceID, RequestGUID: WideString;
  ConfirmationType: Integer): WordBool;
begin
  Result := Driver.ConfirmKM(DeviceID, RequestGUID, ConfirmationType);
end;

function TDrvFR1C30.Get_sm_FormatVersion: Integer;
begin
  Result := 0;
  // Result := Driver.FormatVersion; !!!
end;

function TDrvFR1C30.GetProcessingKMResult(const DeviceID: WideString;
  out ProcessingKMResult: WideString; out RequestStatus: Integer): WordBool;
begin
  Result := Driver.GetProcessingKMResult(DeviceID, ProcessingKMResult,
    RequestStatus);
end;

function TDrvFR1C30.OpenSessionRegistrationKM(const DeviceID: WideString)
  : WordBool;
begin
  Result := Driver.OpenSessionRegistrationKM(DeviceID);
end;

function TDrvFR1C30.RequestKM(const DeviceID, RequestKM: WideString;
  out RequestKMResult: WideString): WordBool;
begin
  Result := Driver.RequestKM(DeviceID, RequestKM, RequestKMResult);
end;

procedure TDrvFR1C30.Set_sm_FormatVersion(Value: Integer);
begin
  // Driver.FormatVersion := Value; !!!
end;

function TDrvFR1C30.GetLocalizationPattern(out LocalizationPattern: WideString)
  : WordBool;
begin
  Result := Driver.GetLocalizationPattern(LocalizationPattern);
end;

function TDrvFR1C30.SetLocalization(const LanguageCode, LocalizationPattern
  : WideString): WordBool;
begin
  Result := Driver.SetLocalization(LanguageCode, LocalizationPattern);
end;

initialization

{$IFNDEF WIN64}
  SetTranslationLanguage;
{$ENDIF}
ComServer.SetServerName('AddIn');
TActiveXControlFactory.Create(ComServer, TDrvFR1C30, TActiveXView,
  Class_Mitsu1C30, 1, '', OLEMISC_INVISIBLEATRUNTIME, tmApartment);

end.
