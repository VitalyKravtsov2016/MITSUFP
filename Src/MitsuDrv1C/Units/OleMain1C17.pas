unit OleMain1C17;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  // VCL
  ActiveX, DrvFRLib_TLB, StdVcl, SysUtils, ActiveXView,
  // This
  ComObj, ComServ, untLogger, Driver1Cst17, StringUtils, ActiveXControl1C,
  AddIn1CInterface, AxCtrls, classes, TranslationUtil;

type
  TDrvFR1C17 = class(TActiveXControl1C, IDrvFR1C17)
  private
    FLogger: TLogger;
    FDriver: TDriver1Cst17;
    function GetLogger: TLogger;
    function GetDriver: TDriver1Cst17;
    property Logger: TLogger read GetLogger;
    property Driver: TDriver1Cst17 read GetDriver;
  protected
    function Close(const DeviceID: WideString): WordBool; safecall;
    function GetDescription(out Name, Description, EquipmentType: WideString;
      out InterfaceRevision: Integer; out IntegrationLibrary,
      MainDriverInstalled: WordBool;
      out DownloadURL: WideString): WordBool; safecall;
    function GetLastError(out ErrorDescription: WideString): Integer; safecall;
    function GetParameters(out TableParameters: WideString): WordBool;
      safecall;
    function GetVersion: WideString; safecall;
    function Open(out DeviceID: WideString): WordBool; safecall;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool;
      safecall;
    function DeviceTest(out Description,
      DemoModeIsActivated: WideString): WordBool; safecall;
    function DoAdditionalAction(const ActionName: WideString): WordBool;
      safecall;
    function GetAdditionalActions(out TableActions: WideString): WordBool;
      safecall;
    function CashInOutcome(const DeviceID: WideString;
      Amount: Double): WordBool; safecall;
    function CloseShift(const DeviceID, CashierName: WideString;
      out SessionNumber, DocumentNumber: Integer): WordBool; safecall;
    function GetCurrentStatus(const DeviceID: WideString; out CheckNumber,
      SessionNumber, SessionState: Integer;
      out StatusParameters: WideString): WordBool; safecall;
    function GetDataKKT(const DeviceID: WideString;
      out TableParametersKKT: WideString): WordBool; safecall;
    function GetLineLength(const DeviceID: WideString;
      out LineLength: Integer): WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; safecall;
    function OpenShift(const DeviceID, CashierName: WideString;
      out SessionNumber, DocumentNumber: Integer): WordBool; safecall;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
      const CashierName, ParametersFiscal: WideString): WordBool; safecall;
    function ProcessCheck(const DeviceID, CashierName: WideString;
      Electronically: WordBool; const CheckPackage: WideString;
      out CheckNumber, SessionNumber: Integer; out FiscalSign,
      AddressSiteInspections: WideString): WordBool; safecall;
    function ProcessCorrectionCheck(const DeviceID, CashierName,
      CheckCorrectionPackage: WideString; out CheckNumber,
      SessionNumber: Integer; out FiscalSign,
      AddressSiteInspections: WideString): WordBool; safecall;
    function ReportCurrentStatusOfSettlements(
      const DeviceID: WideString): WordBool; safecall;
    function PrintTextDocument(const DeviceID,
      DocumentPackage: WideString): WordBool; safecall;
    function PrintXReport(const DeviceID: WideString): WordBool; safecall;
  public    
     procedure SetLang(LangID: Integer); safecall;
     destructor Destroy; override;
  end;

implementation


function TDrvFR1C17.Close(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['Close', DeviceID]));
  Result := Driver.Close(DeviceID);
  Logger.Debug(Format('%s: %s', ['Close', BoolToStr(Result)]));
end;

function TDrvFR1C17.GetDescription(out Name, Description,
  EquipmentType: WideString; out InterfaceRevision: Integer;
  out IntegrationLibrary, MainDriverInstalled: WordBool;
  out DownloadURL: WideString): WordBool;
begin
  Result := True;
  Name := 'Штрих-М: Драйвер ККТ с передачей данных в ОФД';
  Description := 'Драйвер ККТ с передачей данных в ОФД';
  EquipmentType := 'ККТ';
  InterfaceRevision := 2001;
  IntegrationLibrary := True;
  MainDriverInstalled := True;
  DownloadURL := 'http://www.shtrih-m.ru/support/download/?section_id=76&product_id=all&type_id=156';
end;

function TDrvFR1C17.GetLastError(
  out ErrorDescription: WideString): Integer;
begin
  Logger.Debug('GetLastError');
  Result := Driver.GetLastError(ErrorDescription);
  Logger.Debug(Format('%s(ErrorDescription: %s): %d', ['GetLastError',
    ErrorDescription, Result]));
end;

function TDrvFR1C17.GetParameters(
  out TableParameters: WideString): WordBool;
begin
  Logger.Debug('GetParameters');
  Result := Driver.GetParameters(TableParameters);
  Logger.Debug(Format('GetParameters(TableParameters: %s): %s', [TableParameters, BoolToStr(Result)]));
end;

function TDrvFR1C17.GetVersion: WideString;
begin
  Logger.Debug('GetVersion');
  Result := Driver.GetVersion;
  Logger.Debug(Format('%s: %s', ['GetVersion', Result]));
end;

function TDrvFR1C17.Open(out DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('Open(%s)', [DeviceID]));
  Result := Driver.Open(DeviceID);
  Logger.Debug(Format('Open: %s', [BoolToStr(Result)]));
end;

function TDrvFR1C17.SetParameter(const Name: WideString;
  Value: OleVariant): WordBool;
begin
  Logger.Debug(Format('SetParameter(%s, %s)', [Name, string(Value)]));
  Result := Driver.SetParameter(Name, Value);
  Logger.Debug(Format('SetParameter: %s', [BoolToStr(Result)]));
end;

function TDrvFR1C17.DeviceTest(out Description,
  DemoModeIsActivated: WideString): WordBool;
begin
  Logger.Debug('DeviceTest');
  Result := Driver.DeviceTest(Description, DemoModeIsActivated);
  Logger.Debug(Format('DeviceTest(%s, %s): %s', [Description, DemoModeIsActivated, BoolToStr(Result)]));
end;

function TDrvFR1C17.DoAdditionalAction(
  const ActionName: WideString): WordBool;
begin
  Logger.Debug(Format('DoAdditionalAction(%s)', [ActionName]));
  Result := Driver.DoAdditionalAction(ActionName);
  Logger.Debug(Format('DoAdditionalAction: %s', [BoolToStr(Result)]));
end;

function TDrvFR1C17.GetAdditionalActions(
  out TableActions: WideString): WordBool;
begin
  Logger.Debug('GetAdditionalActions');
  Result := Driver.GetAdditionalActions(TableActions);
  Logger.Debug(Format('GetAdditionalActions(%s): %s', [TableActions, BoolToStr(Result)]));
end;

function TDrvFR1C17.CashInOutcome(const DeviceID: WideString;
  Amount: Double): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s, Amount: %.2f)', ['CashInOutcome',
    DeviceID, Amount]));
  Result := Driver.CashInOutcome(DeviceID, Amount);
  Logger.Debug(Format('%s: %s', ['CashInOutcome', BoolToStr(Result)]));
end;

function TDrvFR1C17.CloseShift(const DeviceID, CashierName: WideString;
  out SessionNumber, DocumentNumber: Integer): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['CloseShift', DeviceID]));
  Result := Driver.CloseShiftFN(DeviceID, CashierName, SessionNumber, DocumentNumber);
  Logger.Debug(Format('%s: %s', ['CloseShift', BoolToStr(Result)]));
end;

function TDrvFR1C17.GetCurrentStatus(const DeviceID: WideString;
  out CheckNumber, SessionNumber, SessionState: Integer;
  out StatusParameters: WideString): WordBool;
begin
 Result := Driver.GetCurrentStatus(DeviceID, CheckNumber, SessionNumber, SessionState, StatusParameters);
end;

function TDrvFR1C17.GetDataKKT(const DeviceID: WideString;
  out TableParametersKKT: WideString): WordBool;
begin
  Result := Driver.GetDataKKT(DeviceID, TableParametersKKT);
end;

function TDrvFR1C17.GetLineLength(const DeviceID: WideString;
  out LineLength: Integer): WordBool;
begin
  Logger.Debug(Format('GetLineLength(DeviceID: %s)', [DeviceID]));
  Result := Driver.GetLineLength(DeviceID, LineLength);
  Logger.Debug(Format('GetLineLength(LineLength: %d): %s', [LineLength, BoolToStr(Result)]));
end;

function TDrvFR1C17.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('OpenCashDrawer(DeviceID: %s)', [DeviceID]));
  Result := Driver.OpenCashDrawer(DeviceID, 0);
  Logger.Debug(Format('OpenCashDrawer: %s', [BoolToStr(Result)]));
end;

function TDrvFR1C17.OpenShift(const DeviceID, CashierName: WideString;
  out SessionNumber, DocumentNumber: Integer): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['OpenShift', DeviceID]));
  Result := Driver.OpenShiftFN(DeviceID, CashierName, SessionNumber, DocumentNumber);
  Logger.Debug(Format('%s: %s', ['OpenShift', BoolToStr(Result)]));
end;

function TDrvFR1C17.OperationFN(const DeviceID: WideString;
  OperationType: Integer; const CashierName,
  ParametersFiscal: WideString): WordBool;
begin
  Result := Driver.OperationFN(DeviceID, OperationType, CashierName, ParametersFiscal);
end;

function TDrvFR1C17.ProcessCheck(const DeviceID, CashierName: WideString;
  Electronically: WordBool; const CheckPackage: WideString;
  out CheckNumber, SessionNumber: Integer; out FiscalSign,
  AddressSiteInspections: WideString): WordBool;
begin
  Logger.Debug('ProcessCheck');
  Result := Driver.ProcessCheck(DeviceID, CashierName,
        Electronically, CheckPackage, CheckNumber, SessionNumber,
          FiscalSign, AddressSiteInspections)
end;

function TDrvFR1C17.ProcessCorrectionCheck(const DeviceID, CashierName,
  CheckCorrectionPackage: WideString; out CheckNumber,
  SessionNumber: Integer; out FiscalSign,
  AddressSiteInspections: WideString): WordBool;
begin
  Logger.Debug('ProcessCheckCorrection');
  Result := Driver.ProcessCorrectionCheck(DeviceID, CashierName,
    CheckCorrectionPackage, CheckNumber, SessionNumber, FiscalSign, AddressSiteInspections);
end;

function TDrvFR1C17.ReportCurrentStatusOfSettlements(
  const DeviceID: WideString): WordBool;
begin
  Logger.Debug('ReportCurrentStatusOfSettlements');
  Result := Driver.ReportCurrentStatusOfSettlements(DeviceID);
end;

function TDrvFR1C17.GetLogger: TLogger;
begin
  if FLogger = nil then
    FLogger := TLogger.Create(Self.ClassName);
  Result := FLogger;
end;

function TDrvFR1C17.GetDriver: TDriver1Cst17;
begin
  if FDriver = nil then
    FDriver := TDriver1Cst17.Create;
  Result := FDriver;
end;

function TDrvFR1C17.PrintTextDocument(const DeviceID,
  DocumentPackage: WideString): WordBool;
begin
  Logger.Debug('PrintTextDocument');
  Result := Driver.printTextDocument(DeviceID, DocumentPackage);
end;

destructor TDrvFR1C17.Destroy;
begin
  FLogger.Free;
  FDriver.Free;
  inherited Destroy;
end;

procedure TDrvFR1C17.SetLang(LangID: Integer);
begin
  if LangID = 0 then
    SetCustomTranslationLanguage('RU')
  else
    SetCustomTranslationLanguage('EN');
end;

function TDrvFR1C17.PrintXReport(const DeviceID: WideString): WordBool;
begin
  Logger.Debug('PrintXReport');
  Result := Driver.PrintXReport(DeviceID);
end;

initialization
{$IFNDEF WIN64}
  SetTranslationLanguage;
{$ENDIF}
  ComServer.SetServerName('AddIn');
  TActiveXControlFactory.Create(ComServer, TDrvFR1C17, TActiveXView,
    Class_DrvFR1C17, 1, '', OLEMISC_INVISIBLEATRUNTIME, tmApartment);
end.
