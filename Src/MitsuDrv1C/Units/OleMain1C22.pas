unit OleMain1C22;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  // VCL
  ActiveX, DrvFRLib_TLB, StdVcl, SysUtils, ActiveXView,
  // This
  ComObj, ComServ, untLogger, Driver1Cst22, StringUtils, ActiveXControl1C,
  AddIn1CInterface, AxCtrls, classes, TranslationUtil;

type
  TDrvFR1C22 = class(TActiveXControl1C, IDrvFR1C22)
  private
    FLogger: TLogger;
    FDriver: TDriver1Cst22;
    function GetLogger: TLogger;                                                          
    function GetDriver: TDriver1Cst22;
    property Logger: TLogger read GetLogger;
    property Driver: TDriver1Cst22 read GetDriver;
  protected
    function CashInOutcome(const DeviceID, InputParameters: WideString;
      Amount: Double): WordBool; safecall;
    function Close(const DeviceID: WideString): WordBool; safecall;
    function CloseShift(const DeviceID, InputParameters: WideString;
      out OutputParameters: WideString; out SessionNumber,
      DocumentNumber: Integer): WordBool; safecall;
    function DeviceTest(out Description,
      DemoModeIsActivated: WideString): WordBool; safecall;
    function DoAdditionalAction(const ActionName: WideString): WordBool;
      safecall;
    function GetAdditionalActions(out TableActions: WideString): WordBool;
      safecall;
    function GetCurrentStatus(const DeviceID: WideString; out CheckNumber,
      SessionNumber, SessionState: Integer;
      out StatusParameters: WideString): WordBool; safecall;
    function GetDataKKT(const DeviceID: WideString;
      out TableParametersKKT: WideString): WordBool; safecall;
    function GetDescription(out Name, Description, EquipmentType: WideString;
      out InterfaceRevision: Integer; out IntegrationLibrary,
      MainDriverInstalled: WordBool;
      out DownloadURL: WideString): WordBool; safecall;
    function GetLastError(out ErrorDescription: WideString): Integer; safecall;
    function GetLineLength(const DeviceID: WideString;
      out LineLength: Integer): WordBool; safecall;
    function GetParameters(out TableParameters: WideString): WordBool;
      safecall;
    function GetVersion: WideString; safecall;
    function Open(out DeviceID: WideString): WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; safecall;
    function OpenShift(const DeviceID, InputParameters: WideString;
      out OutputParameters: WideString; out SessionNumber,
      DocumentNumber: Integer): WordBool; safecall;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
      const ParametersFiscal: WideString): WordBool; safecall;
    function PrintTextDocument(const DeviceID,
      DocumentPackage: WideString): WordBool; safecall;
    function PrintXReport(const DeviceID,
      InputParameters: WideString): WordBool; safecall;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool;
      const CheckPackage: WideString; out CheckNumber,
      SessionNumber: Integer; out FiscalSign,
      AddressSiteInspections: WideString): WordBool; safecall;
    function ProcessCorrectionCheck(const DeviceID,
      CheckCorrectionPackage: WideString; out CheckNumber,
      SessionNumber: Integer; out FiscalSign,
      AddressSiteInspections: WideString): WordBool; safecall;
    function ReportCurrentStatusOfSettlements(const DeviceID,
      InputParameters: WideString;
      out OutputParameters: WideString): WordBool; safecall;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool;
      safecall;
    function CloseSessionRegistrationKM(const DeviceID: WideString): WordBool;
      safecall;
    function ExecuteCheckKM(const DeviceID, ControlMarks: WideString;
      out CheckResults: WideString): WordBool; safecall;
    function OpenSessionRegistrationKM(const DeviceID,
      SessionRegistrationParameters: WideString): WordBool; safecall;
  public
    procedure SetLang(LangID: Integer); safecall;
    destructor Destroy; override;
  end;

implementation

function TDrvFR1C22.CashInOutcome(const DeviceID,
  InputParameters: WideString; Amount: Double): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s, Amount: %.2f)', ['CashInOutcome',
    DeviceID, Amount]));
  Logger.Debug('InputParameters: ' + InputParameters);  
  Result := Driver.CashInOutcome(DeviceID, Amount, InputParameters);
  Logger.Debug(Format('%s: %s', ['CashInOutcome', BoolToStr(Result)]));
end;

function TDrvFR1C22.Close(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['Close', DeviceID]));
  Result := Driver.Close(DeviceID);
  Logger.Debug(Format('%s: %s', ['Close', BoolToStr(Result)]));
end;

function TDrvFR1C22.CloseShift(const DeviceID, InputParameters: WideString;
  out OutputParameters: WideString; out SessionNumber,
  DocumentNumber: Integer): WordBool;
begin
  Logger.Debug(Format('CloseShift(DeviceID: %s)', [DeviceID]));
  Logger.Debug(Format('InputParameters: %s', [InputParameters]));
  Result := Driver.CloseShift(DeviceID, InputParameters, OutputParameters, SessionNumber, DocumentNumber);
  Logger.Debug(Format('%s: %s', ['CloseShift', BoolToStr(Result)]));
  Logger.Debug(Format('OutputParameters: %s', [OutputParameters]));
  Logger.Debug(Format('SessionNumber: %d', [SessionNumber]));
  Logger.Debug(Format('DocumentNumber: %u', [Cardinal(DocumentNumber)]));
end;

destructor TDrvFR1C22.Destroy;
begin
  FDriver.Free;
  FLogger.Free;
  inherited;
end;

function TDrvFR1C22.DeviceTest(out Description,
  DemoModeIsActivated: WideString): WordBool;
begin
  Logger.Debug('DeviceTest');
  Result := Driver.DeviceTest(Description, DemoModeIsActivated);
  Logger.Debug(Format('DeviceTest(%s, %s): %s', [Description, DemoModeIsActivated, BoolToStr(Result)]));
end;

function TDrvFR1C22.DoAdditionalAction(
  const ActionName: WideString): WordBool;
begin
  Logger.Debug(Format('DoAdditionalAction(%s)', [ActionName]));
  Result := Driver.DoAdditionalAction(ActionName);
  Logger.Debug(Format('DoAdditionalAction: %s', [BoolToStr(Result)]));
end;

function TDrvFR1C22.GetAdditionalActions(
  out TableActions: WideString): WordBool;
begin
  Logger.Debug('GetAdditionalActions');
  Result := Driver.GetAdditionalActions(TableActions);
  Logger.Debug(Format('GetAdditionalActions(%s): %s', [TableActions, BoolToStr(Result)]));
end;

function TDrvFR1C22.GetCurrentStatus(const DeviceID: WideString;
  out CheckNumber, SessionNumber, SessionState: Integer;
  out StatusParameters: WideString): WordBool;
begin
  Result := Driver.GetCurrentStatus(DeviceID, CheckNumber, SessionNumber, SessionState, StatusParameters);
end;

function TDrvFR1C22.GetDataKKT(const DeviceID: WideString;
  out TableParametersKKT: WideString): WordBool;
begin
  Logger.Debug('GetDataKKT ' + DeviceID);
  Result := Driver.GetDataKKT(DeviceID, TableParametersKKT);
  Logger.Debug('TableParametersKKT: ' + TableParametersKKT);
end;

function TDrvFR1C22.GetDescription(out Name, Description,
  EquipmentType: WideString; out InterfaceRevision: Integer;
  out IntegrationLibrary, MainDriverInstalled: WordBool;
  out DownloadURL: WideString): WordBool;
begin
  Result := True;
  Name := 'Штрих-М: Драйвер ККТ с передачей данных в ОФД v2.2';
  Description := 'Драйвер ККТ с передачей данных в ОФД 2.2';
  EquipmentType := 'ККТ';
  InterfaceRevision := 2002;
  IntegrationLibrary := True;
  MainDriverInstalled := True;
  DownloadURL := 'http://www.shtrih-m.ru/support/download/?section_id=76&product_id=all&type_id=156';
end;

function TDrvFR1C22.GetDriver: TDriver1Cst22;
begin
  if FDriver = nil then
    FDriver := TDriver1Cst22.Create;
  Result := FDriver;
end;

function TDrvFR1C22.GetLastError(
  out ErrorDescription: WideString): Integer;
begin
  Logger.Debug('GetLastError');
  Result := Driver.GetLastError(ErrorDescription);
  Logger.Debug(Format('%s(ErrorDescription: %s): %d', ['GetLastError',
    ErrorDescription, Result]));
end;

function TDrvFR1C22.GetLineLength(const DeviceID: WideString;
  out LineLength: Integer): WordBool;
begin
  Logger.Debug(Format('GetLineLength(DeviceID: %s)', [DeviceID]));
  Result := Driver.GetLineLength(DeviceID, LineLength);
  Logger.Debug(Format('GetLineLength(LineLength: %d): %s', [LineLength, BoolToStr(Result)]));
end;

function TDrvFR1C22.GetLogger: TLogger;
begin
  if FLogger = nil then
    FLogger := TLogger.Create(Self.ClassName);
  Result := FLogger;
end;

function TDrvFR1C22.GetParameters(
  out TableParameters: WideString): WordBool;
begin
  Logger.Debug('GetParameters');
  Result := Driver.GetParameters(TableParameters);
  Logger.Debug(Format('GetParameters(TableParameters: %s): %s', [TableParameters, BoolToStr(Result)]));
end;

function TDrvFR1C22.GetVersion: WideString;
begin
  Logger.Debug('GetVersion');
  Result := Driver.GetVersion;
  Logger.Debug(Format('%s: %s', ['GetVersion', Result]));
end;

function TDrvFR1C22.Open(out DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('Open(%s)', [DeviceID]));
  Result := Driver.Open(DeviceID);
  Logger.Debug(Format('Open: %s', [BoolToStr(Result)]));
end;

function TDrvFR1C22.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('OpenCashDrawer(DeviceID: %s)', [DeviceID]));
  Result := Driver.OpenCashDrawer(DeviceID, 0);
  Logger.Debug(Format('OpenCashDrawer: %s', [BoolToStr(Result)]));
end;

function TDrvFR1C22.OpenShift(const DeviceID, InputParameters: WideString;
  out OutputParameters: WideString; out SessionNumber,
  DocumentNumber: Integer): WordBool;
begin
  Logger.Debug(Format('OpenShift(DeviceID: %s)', [DeviceID]));
  Logger.Debug(Format('InputParameters: %s', [InputParameters]));
  Result := Driver.OpenShift(DeviceID, InputParameters, OutputParameters, SessionNumber, DocumentNumber);
  Logger.Debug(Format('%s: %s', ['OpenShift', BoolToStr(Result)]));
  Logger.Debug(Format('OutputParameters: %s', [OutputParameters]));
  Logger.Debug(Format('SessionNumber: %d', [SessionNumber]));
  Logger.Debug(Format('DocumentNumber: %u', [Cardinal(DocumentNumber)]));
end;

function TDrvFR1C22.OperationFN(const DeviceID: WideString;
  OperationType: Integer; const ParametersFiscal: WideString): WordBool;
begin
  Logger.Debug(Format('OperationFN(DeviceID=%s; OpType=%d)', [DeviceID, OperationType]));
  Logger.Debug('ParametersFiscal: ' + ParametersFiscal);
  Result := Driver.OperationFN(DeviceID, OperationType, ParametersFiscal);
end;

function TDrvFR1C22.PrintTextDocument(const DeviceID,
  DocumentPackage: WideString): WordBool;
begin
  Logger.Debug('PrintTextDocument');
  Result := Driver.printTextDocument(DeviceID, DocumentPackage);
end;

function TDrvFR1C22.PrintXReport(const DeviceID,
  InputParameters: WideString): WordBool;
begin
  Logger.Debug('PrintXReport');
  Result := Driver.PrintXReport(DeviceID);
end;

function TDrvFR1C22.ProcessCheck(const DeviceID: WideString;
  Electronically: WordBool; const CheckPackage: WideString;
  out CheckNumber, SessionNumber: Integer; out FiscalSign,
  AddressSiteInspections: WideString): WordBool;
begin
  Logger.Debug('ProcessCheck');
  Result := Driver.ProcessCheck(DeviceID, '',
        Electronically, CheckPackage, CheckNumber, SessionNumber,
          FiscalSign, AddressSiteInspections);

end;

function TDrvFR1C22.ProcessCorrectionCheck(const DeviceID,
  CheckCorrectionPackage: WideString; out CheckNumber,
  SessionNumber: Integer; out FiscalSign,
  AddressSiteInspections: WideString): WordBool;
begin
  Logger.Debug('ProcessCheckCorrection');
  Result := Driver.ProcessCorrectionCheck(DeviceID, CheckCorrectionPackage, CheckNumber, SessionNumber, FiscalSign, AddressSiteInspections);

end;

function TDrvFR1C22.ReportCurrentStatusOfSettlements(const DeviceID,
  InputParameters: WideString; out OutputParameters: WideString): WordBool;
begin
  Logger.Debug('ReportCurrentStatusOfSettlements');
  Result := Driver.ReportCurrentStatusOfSettlements(DeviceID, InputParameters, OutputParameters);
end;

procedure TDrvFR1C22.SetLang(LangID: Integer);
begin
  if LangID = 0 then
    SetCustomTranslationLanguage('RU')
  else
    SetCustomTranslationLanguage('EN');
end;

function TDrvFR1C22.SetParameter(const Name: WideString;
  Value: OleVariant): WordBool;
begin
  Logger.Debug(Format('SetParameter(%s, %s)', [Name, string(Value)]));
  Result := Driver.SetParameter(Name, Value);
  Logger.Debug(Format('SetParameter: %s', [BoolToStr(Result)]));
end;

function TDrvFR1C22.CloseSessionRegistrationKM(
  const DeviceID: WideString): WordBool;
begin
  Logger.Debug('CloseSessionRegistrationKM ' + DeviceID);
  Result := Driver.CloseSessionRegistrationKM(DeviceID);
  Logger.Debug('CloseSessionRegistrationKM:' + BoolToStr(Result));
end;

function TDrvFR1C22.ExecuteCheckKM(const DeviceID,
  ControlMarks: WideString; out CheckResults: WideString): WordBool;
begin
  Logger.Debug('ExecuteCheckKM ' + DeviceID);
  Logger.Debug('  ControlMarks = ' + ControlMarks);
  Result := Driver.ExecuteCheckKM(DeviceID, ControlMarks, CheckResults);
  Logger.Debug('  CheckResults = ' + CheckResults);
  Logger.Debug('ExecuteCheckKM:' + BoolToStr(Result));
end;

function TDrvFR1C22.OpenSessionRegistrationKM(const DeviceID,
  SessionRegistrationParameters: WideString): WordBool;
begin
  Logger.Debug('OpenSessionRegistrationKM ' + DeviceID);
  Logger.Debug('  SessionRegistrationParameters = ' + SessionRegistrationParameters);
  Result := Driver.OpenSessionRegistrationKM(DeviceID, SessionRegistrationParameters);
  Logger.Debug('OpenSessionRegistrationKM:' + BoolToStr(Result));
end;

initialization
{$IFNDEF WIN64}
  SetTranslationLanguage;
{$ENDIF}
  ComServer.SetServerName('AddIn');
  TActiveXControlFactory.Create(ComServer, TDrvFR1C22, TActiveXView,
    Class_DrvFR1C22, 1, '', OLEMISC_INVISIBLEATRUNTIME, tmApartment);
end.
