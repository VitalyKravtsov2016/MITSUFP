unit OleMain17;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  // VCL
  ComObj2, ActiveX, StdVcl, SysUtils,
  // This
  SMDrvFR1CLib_TLB, DrvFRLib_TLB, VersionInfo, ActiveXView, AddIn1CInterface,
  ActiveXControl1C, AxCtrls2, LogFile;


type
  TSMDrvFR1C17 = class(TActiveXControl1C, ISMDrvFR1C17, IInitDone, ILanguageExtender)
  private
    FLastError: Integer;
    FLastErrorDescription: string;
    FDriver: TDrvFR1C17;
    function GetDriver: TDrvFR1C17;
    property Driver: TDrvFR1C17 read GetDriver;
    function HandleException(E: Exception): Boolean;
  protected
    function DeviceTest(out Description,
      DemoModeIsActivated: WideString): WordBool; safecall;
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
    function DoAdditionalAction(const ActionName: WideString): WordBool;
      safecall;
    function GetAdditionalActions(out TableActions: WideString): WordBool;
      safecall;
    function GetDataKKT(const DeviceID: WideString;
      out TableParametersKKT: WideString): WordBool; safecall;
    function OpenShift(const DeviceID, CashierName: WideString;
      out SessionNumber, DocumentNumber: Integer): WordBool; safecall;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
      const CashierName: WideString;
      var ParametersFiscal: WideString): WordBool; safecall;
    function ProcessCorrectionCheck(const DeviceID, CashierName,
      CheckCorrectionPackage: WideString; out CheckNumber,
      SessionNumber: Integer; out FiscalSign,
      AddressSiteInspections: WideString): WordBool; safecall;
    function ProcessCheck(const DeviceID, CashierName: WideString;
      Electronically: WordBool; const CheckPackage: WideString;
      out CheckNumber, SessionNumber: Integer; out FiscalSign,
      AddressSiteInspections: WideString): WordBool; safecall;
    function CashInOutcome(const DeviceID: WideString;
      Amount: Double): WordBool; safecall;
    function ReportCurrentStatusOfSettlements(
      const DeviceID: WideString): WordBool; safecall;
    function GetCurrentStatus(const DeviceID: WideString;
      out CheckNumber: Integer; var SessionNumber: Integer;
      out SessionState: Integer): WordBool; safecall;
    function GetLineLength(const DeviceID: WideString;
      out LineLength: Integer): WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; safecall;
    function PrintTextDocument(const DeviceID,
      DocumentPackage: WideString): WordBool; safecall;
  public
    procedure SetLang(LangType: string); override;
    procedure Initialize; override;
    destructor Destroy; override;
  end;

implementation

uses ComServ2;

{ TSMDrvFR1C17 }


function TSMDrvFR1C17.DeviceTest(out Description,
  DemoModeIsActivated: WideString): WordBool;
begin
  try
    Result := Driver.DeviceTest(Description, DemoModeIsActivated);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TSMDrvFR1C17.GetDescription(out Name, Description,
  EquipmentType: WideString; out InterfaceRevision: Integer;
  out IntegrationLibrary, MainDriverInstalled: WordBool;
  out DownloadURL: WideString): WordBool;
begin
  try
    Result := Driver.GetDescription(Name, Description, EquipmentType,
      InterfaceRevision, IntegrationLibrary, MainDriverInstalled, DownloadURL);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TSMDrvFR1C17.GetLastError(
  out ErrorDescription: WideString): Integer;
begin
    try
    Result := Driver.GetLastError(ErrorDescription);
  except
    on E: Exception do
    begin
      Result := FLastError;
      ErrorDescription := E.Message;
    end;
  end;

end;

function TSMDrvFR1C17.GetParameters(
  out TableParameters: WideString): WordBool;
begin
  try
    Result := Driver.GetParameters(TableParameters);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TSMDrvFR1C17.GetVersion: WideString;
begin
  try
    Result := Driver.GetVersion;
  except
    Result := GetFileVersionInfoStr;
  end;
end;

function TSMDrvFR1C17.Open(out DeviceID: WideString): WordBool;
begin
  try
    Result := Driver.Open(DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TSMDrvFR1C17.SetParameter(const Name: WideString;
  Value: OleVariant): WordBool;
begin
  try
    Result := Driver.SetParameter(Name, Value);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TSMDrvFR1C17.DoAdditionalAction(
  const ActionName: WideString): WordBool;
begin
  try
    Result := Driver.DoAdditionalAction(ActionName);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TSMDrvFR1C17.GetAdditionalActions(
  out TableActions: WideString): WordBool;
begin
  try
    Result := Driver.GetAdditionalActions(TableActions);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TSMDrvFR1C17.GetDataKKT(const DeviceID: WideString;
  out TableParametersKKT: WideString): WordBool;
begin
  try
    Result := Driver.GetDataKKT(DeviceID, TableParametersKKT);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TSMDrvFR1C17.OpenShift(const DeviceID, CashierName: WideString;
  out SessionNumber, DocumentNumber: Integer): WordBool;
begin
  try
    Result := Driver.OpenShift(DeviceID, CashierName, SessionNumber, DocumentNumber);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TSMDrvFR1C17.OperationFN(const DeviceID: WideString;
  OperationType: Integer; const CashierName: WideString;
  var ParametersFiscal: WideString): WordBool;
begin
  try
    Result := Driver.OperationFN(DeviceID, OperationType, CashierName, ParametersFiscal);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TSMDrvFR1C17.ProcessCorrectionCheck(const DeviceID, CashierName,
  CheckCorrectionPackage: WideString; out CheckNumber,
  SessionNumber: Integer; out FiscalSign,
  AddressSiteInspections: WideString): WordBool;
begin
  try
    Result := Driver.ProcessCorrectionCheck(DeviceID, CashierName,
       CheckCorrectionPackage, CheckNumber, SessionNumber, FiscalSign, AddressSiteInspections);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TSMDrvFR1C17.ProcessCheck(const DeviceID, CashierName: WideString;
  Electronically: WordBool; const CheckPackage: WideString;
  out CheckNumber, SessionNumber: Integer; out FiscalSign,
  AddressSiteInspections: WideString): WordBool;
begin
  try
    Result := Driver.ProcessCheck(DeviceID, CashierName, Electronically,
       CheckPackage, CheckNumber, SessionNumber, FiscalSign, AddressSiteInspections);
  except
    on E: Exception do
      Result := HandleException(E);
  end;

end;

function TSMDrvFR1C17.CashInOutcome(const DeviceID: WideString;
  Amount: Double): WordBool;
begin
  try
    Result := Driver.CashInOutcome(DeviceID, Amount);
  except
    on E: Exception do
      Result := HandleException(E);
  end;

end;

function TSMDrvFR1C17.ReportCurrentStatusOfSettlements(
  const DeviceID: WideString): WordBool;
begin
  try
    Result := Driver.ReportCurrentStatusOfSettlements(DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TSMDrvFR1C17.GetCurrentStatus(const DeviceID: WideString;
  out CheckNumber: Integer; var SessionNumber: Integer;
  out SessionState: Integer): WordBool;
begin
  try
    Result := Driver.GetCurrentStatus(DeviceID, CheckNumber, SessionNumber, SessionState);
  except
    on E: Exception do
      Result := HandleException(E);
  end;

end;

function TSMDrvFR1C17.GetLineLength(const DeviceID: WideString;
  out LineLength: Integer): WordBool;
begin
  try
    Result := Driver.GetLineLength(DeviceID, LineLength);
  except
    on E: Exception do
      Result := HandleException(E);
  end;

end;

function TSMDrvFR1C17.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin
  try
    Result := Driver.OpenCashDrawer(DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;

end;

function TSMDrvFR1C17.GetDriver: TDrvFR1C17;
begin
try
    if FDriver = nil then
    begin
      FDriver := TDrvFR1C17.Create(nil);
{      GlobalLogger.Enabled := True;
      GlobalLogger.FileName := ChangeFileExt(GetDllFileName, '.log');}

    end;
    Result := FDriver;
  except
    on E: Exception do
      raise Exception.Create('Объект драйвера не установлен');
  end;
end;

function TSMDrvFR1C17.HandleException(E: Exception): Boolean;
begin
  Result := False;
  FLastError := -100;
  FLastErrorDescription := E.Message;
end;

function TSMDrvFR1C17.PrintTextDocument(const DeviceID,
  DocumentPackage: WideString): WordBool;
begin
  try
    Result := Driver.PrintTextDocument(DeviceID, DocumentPackage);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

destructor TSMDrvFR1C17.Destroy;
begin
  FDriver.Free;
  inherited;
end;

procedure TSMDrvFR1C17.Initialize;
begin
  inherited;

end;

procedure TSMDrvFR1C17.SetLang(LangType: string);
begin
  if LangType = 'rus_RUS' then
    Driver.SetLang(0)
  else
    Driver.SetLang(1);
end;

initialization
  ComServer.SetServerName('AddIn');
  TActiveXControlFactory2.Create(ComServer, TsmDrvFR1C17, TActiveXView,
    CLASS_SMDrvFR1C17, 1, '', OLEMISC_INVISIBLEATRUNTIME, tmApartment);
end.
