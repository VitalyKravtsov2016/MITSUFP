unit Driver30;

interface

uses
  // VCL
  Variants, SysUtils, XMLDoc, XMLIntf,
  // This
  MitsuLib_TLB, LogFile, VersionInfo;

type
  TDriver30 = class
  private
    FLogger: ILogFile;
    FDriver: TDrvFR1C30;
    function GetDriver: TDrvFR1C30;
    function GetDriverVersion: string;
  public
    constructor Create(ALogger: ILogFile);
    destructor Destroy; override;

    function GetInterfaceRevision: Integer;
    function GetDescription(var DriverDescription: WideString): Boolean;
    function GetLastError(var ErrorDescription: WideString): Integer;
    function GetParameters(var TableParameters: WideString): Boolean;
    function SetParameter(const Name: WideString; Value: Variant): Boolean;
    function Open(var DeviceID: WideString): Boolean;
    function Close(const DeviceID: WideString): Boolean;
    function DeviceTest(var Description: WideString; var DemoModeIsActivated: WideString): Boolean;
    function GetAdditionalActions(var TableActions: WideString): Boolean;
    function DoAdditionalAction(const ActionName: WideString): Boolean;
    function GetLocalizationPattern(var LocalizationPattern: WideString): Boolean;
    function SetLocalization(const LanguageCode: WideString; const LocalizationPattern: WideString): Boolean;
    // KKT Methods
    function GetDataKKT(const DeviceID: WideString; var TableParametersKKT: WideString): Boolean;
    function OperationFN(const DeviceID: WideString; OperationType: Integer; const ParametersFiscal: WideString): Boolean;
    function OpenShift(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): Boolean;
    function CloseShift(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): Boolean;
    function ProcessCheck(const DeviceID: WideString; Electronically: Boolean; const CheckPackage: WideString; var DocumentOutputParameters: WideString): Boolean;
    function ProcessCorrectionCheck(const DeviceID: WideString; const  CheckPackage: WideString; var DocumentOutputParameters: WideString): Boolean;
    function PrintTextDocument(const DeviceID: WideString; const  DocumentPackage: WideString): Boolean;
    function CashInOutcome(const DeviceID: WideString; const InputParameters: WideString; Amount: Double): Boolean;
    function PrintXReport(const DeviceID: WideString; const InputParameters: WideString): Boolean;
    function PrintCheckCopy(const DeviceID: WideString; const  CheckNumber: WideString): Boolean;
    function GetCurrentStatus(const DeviceID: WideString; const  InputParameters: WideString; var OutputParameters: WideString): Boolean;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString; const InputParameters: WideString; var OutputParameters: WideString): Boolean;
    function OpenCashDrawer(const DeviceID: WideString): Boolean;
    function GetLineLength(const DeviceID: WideString; var LineLength: Integer): Boolean;
    //34
    function CloseSessionRegistrationKM(const DeviceID: WideString): WordBool;
    function ConfirmKM(const DeviceID, RequestGUID: WideString; ConfirmationType: Integer): WordBool;
    function Get_sm_FormatVersion: Integer;
    function GetProcessingKMResult(const DeviceID: WideString; var ProcessingKMResult: WideString;
          var RequestStatus: Integer): WordBool;
    function OpenSessionRegistrationKM(const DeviceID: WideString): WordBool;
    function RequestKM(const DeviceID, RequestKM: WideString; var RequestKMResult: WideString): WordBool;
    procedure Set_sm_FormatVersion(Value: Integer);

    property Driver: TDrvFR1C30 read GetDriver;
  end;

implementation

{ TDriver30 }

constructor TDriver30.Create(ALogger: ILogFile);
begin
  inherited Create;
  FLogger := ALogger;
end;

destructor TDriver30.Destroy;
begin
  FDriver.Free;
  FLogger := nil;
  inherited Destroy;
end;

function TDriver30.GetInterfaceRevision: Integer;
begin
  try
    Result := Driver.GetInterfaceRevision;
  except
    Result := 4001;
  end;
end;

function TDriver30.GetDriver: TDrvFR1C30;
begin
  try
    if FDriver = nil then
    begin
      FDriver := TDrvFR1C30.Create(nil);
    end;
    Result := FDriver;
  except
    on E: Exception do
      raise Exception.Create('Объект драйвера не установлен');
  end;
end;

function TDriver30.GetDriverVersion: string;
begin
  Result := ''; // !!!
end;

function To1CBool(Value: Boolean): WideString;
begin
  if Value then
    Result := 'true'
  else
    Result := 'false';
end;

function TDriver30.GetDescription(
  var DriverDescription: WideString): Boolean;
var
   Xml: IXMLDocument;
   Node: IXMLNode;
   DriverInstalled: Boolean;
begin


  DriverInstalled := True;
  try
    GetDriver;
  except
    DriverInstalled := False;
  end;

  if DriverInstalled then
  begin
{$IFDEF V1C_34}
   Driver.sm_FormatVersion := 34;
{$ELSE}
   Driver.sm_FormatVersion := 32;
{$ENDIF}

   // Result := Driver.GetDescription(DriverDescription);
   // Exit;
  end;

  Result := True;
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('DriverDescription');
{$IFDEF V1C_34}
    Node.Attributes['Name'] := 'Штрих-М: Драйвер ККТ с передачей данных в ОФД (4.1)';
    Node.Attributes['Description'] := 'Штрих-М: Драйвер ККТ с передачей данных в ОФД (4.1)';
{$ELSE}
    Node.Attributes['Name'] := 'Штрих-М: Драйвер ККТ с передачей данных в ОФД (3.2)';
    Node.Attributes['Description'] := 'Штрих-М: Драйвер ККТ с передачей данных в ОФД (3.2)';
{$ENDIF}

    Node.Attributes['EquipmentType'] := 'KKT';
    Node.Attributes['IntegrationComponent'] := 'true';
    Node.Attributes['MainDriverInstalled'] := To1CBool(DriverInstalled);
    if DriverInstalled then
      Node.Attributes['DriverVersion'] := GetDriverVersion
    else
      Node.Attributes['DriverVersion'] := '1.0';
    Node.Attributes['IntegrationComponentVersion'] := GetModuleVersion;
    Node.Attributes['DownloadURL'] := 'http://www.shtrih-m.ru/support/download/?section_id=76&product_id=all&type_id=156';
    Node.Attributes['LogIsEnabled'] := 'false';
    Node.Attributes['LogPath'] := '';
    DriverDescription := Xml.XML.Text;
  finally
    Xml := nil;
  end;
end;

function TDriver30.GetLastError(var ErrorDescription: WideString): Integer;
begin
  Result := Driver.GetLastError(ErrorDescription);
end;

function TDriver30.GetParameters(var TableParameters: WideString): Boolean;
begin
  Result := Driver.GetParameters(TableParameters);
end;

function TDriver30.GetProcessingKMResult(const DeviceID: WideString;
  var ProcessingKMResult: WideString; var RequestStatus: Integer): WordBool;
begin
  Result := Driver.GetProcessingKMResult(DeviceID, ProcessingKMResult, RequestStatus);
end;

function TDriver30.Get_sm_FormatVersion: Integer;
begin
  Result := Driver.sm_FormatVersion;
end;

function TDriver30.SetLocalization(const LanguageCode,
  LocalizationPattern: WideString): Boolean;
begin
  FLogger.Debug('SetLocalization: ' + LanguageCode + ', ' + LocalizationPattern);
  Result := Driver.SetLocalization(LanguageCode, LocalizationPattern);
end;

function TDriver30.SetParameter(const Name: WideString;
  Value: Variant): Boolean;
begin
  FLogger.Debug('SetParameter: ' + Name + ' = ' + VarToStr(Value));

  GlobalLogger.Debug(Name + ' ' + Value);

  Result := Driver.SetParameter(Name, Value);
end;

procedure TDriver30.Set_sm_FormatVersion(Value: Integer);
begin
  Driver.sm_FormatVersion := Value;
end;

function TDriver30.Open(var DeviceID: WideString): Boolean;
begin
  FLogger.Debug('Open');
  Result := Driver.Open(DeviceID);
end;

function TDriver30.Close(const DeviceID: WideString): Boolean;
begin
  FLogger.Debug('Close: ' + DeviceID);
  Result := Driver.Close(DeviceID);
end;

function TDriver30.DeviceTest(var Description: WideString;
  var DemoModeIsActivated: WideString): Boolean;
begin
  Result := Driver.DeviceTest(Description, DemoModeIsActivated);
end;

function TDriver30.GetAdditionalActions(
  var TableActions: WideString): Boolean;
begin
  Result := Driver.GetAdditionalActions(TableActions);
end;

function TDriver30.DoAdditionalAction(
  const ActionName: WideString): Boolean;
begin
  FLogger.Debug('DoAdditionalAction ' + ActionName);
  Result := Driver.DoAdditionalAction(ActionName);
end;

function TDriver30.GetDataKKT(const DeviceID: WideString;
  var TableParametersKKT: WideString): Boolean;
begin
  FLogger.Debug('GetDataKKT ' + DeviceID);
  Result := Driver.GetDataKKT(DeviceID, TableParametersKKT);
end;

function TDriver30.OperationFN(const DeviceID: WideString;
  OperationType: Integer; const ParametersFiscal: WideString): Boolean;
begin
  FLogger.Debug('OperationFN ' + DeviceID);
  Result := Driver.OperationFN(DeviceID, OperationType, ParametersFiscal);
end;

function TDriver30.OpenSessionRegistrationKM(
  const DeviceID: WideString): WordBool;
begin
  Result := Driver.OpenSessionRegistrationKM(DeviceID);
end;

function TDriver30.OpenShift(const DeviceID, InputParameters: WideString;
  var OutputParameters: WideString): Boolean;
begin
  FLogger.Debug('OpenShift ' + DeviceID);
  Result := Driver.OpenShift(DeviceID, InputParameters, OutputParameters);
end;

function TDriver30.CloseSessionRegistrationKM(
  const DeviceID: WideString): WordBool;
begin
  Result := Driver.CloseSessionRegistrationKM(DeviceID);
end;

function TDriver30.CloseShift(const DeviceID, InputParameters: WideString;
  var OutputParameters: WideString): Boolean;
begin
  FLogger.Debug('CloseShift ' + DeviceID);
  Result := Driver.CloseShift(DeviceID, InputParameters, OutputParameters);
end;

function TDriver30.ConfirmKM(const DeviceID, RequestGUID: WideString;
  ConfirmationType: Integer): WordBool;
begin
  Result := Driver.ConfirmKM(DeviceID, RequestGUID, ConfirmationType);
end;

function TDriver30.ProcessCheck(const DeviceID: WideString;
  Electronically: Boolean; const CheckPackage: WideString;
  var DocumentOutputParameters: WideString): Boolean;
begin
  FLogger.Debug('ProcessCheck ' + DeviceID);
  Result := Driver.ProcessCheck(DeviceID, Electronically, CheckPackage, DocumentOutputParameters);
end;

function TDriver30.ProcessCorrectionCheck(const DeviceID,
  CheckPackage: WideString;
  var DocumentOutputParameters: WideString): Boolean;
begin
  FLogger.Debug('ProcessCorrectionCheck ' + DeviceID);
  Result := Driver.ProcessCorrectionCheck(DeviceID, CheckPackage, DocumentOutputParameters);
end;

function TDriver30.PrintTextDocument(const DeviceID,
  DocumentPackage: WideString): Boolean;
begin
  FLogger.Debug('PrintTextDocument ' + DeviceID);
  Result := Driver.PrintTextDocument(DeviceID, DocumentPackage);
end;

function TDriver30.CashInOutcome(const DeviceID,
  InputParameters: WideString; Amount: Double): Boolean;
begin
  FLogger.Debug('CashInOutcome ' + DeviceID);
  Result := Driver.CashInOutcome(DeviceID, InputParameters, Amount);
end;

function TDriver30.PrintXReport(const DeviceID,
  InputParameters: WideString): Boolean;
begin
  FLogger.Debug('PrintXReport ' + DeviceID);
  Result := Driver.PrintXReport(DeviceID, InputParameters);
end;

function TDriver30.PrintCheckCopy(const DeviceID,
  CheckNumber: WideString): Boolean;
begin
  FLogger.Debug('PrintCheckCopy ' + DeviceID + ', ' + CheckNumber);
  Result := FDriver.PrintCheckCopy(DeviceID, CheckNumber);
end;

function TDriver30.GetCurrentStatus(const DeviceID,
  InputParameters: WideString; var OutputParameters: WideString): Boolean;
begin
  FLogger.Debug('GetCurrentStatus ' + DeviceID);
  Result := Driver.GetCurrentStatus(DeviceID, InputParameters, OutputParameters);
end;

function TDriver30.ReportCurrentStatusOfSettlements(const DeviceID,
  InputParameters: WideString; var OutputParameters: WideString): Boolean;
begin
  FLogger.Debug('ReportCurrentStatusOfSettlements ' +  DeviceID);
  Result := Driver.ReportCurrentStatusOfSettlements(DeviceID, InputParameters, OutputParameters);
end;

function TDriver30.RequestKM(const DeviceID, RequestKM: WideString;
  var RequestKMResult: WideString): WordBool;
begin
  Result := Driver.RequestKM(DeviceID, RequestKM, RequestKMResult);
end;

function TDriver30.OpenCashDrawer(const DeviceID: WideString): Boolean;
begin
  FLogger.Debug('OpenCashDrawer ' +  DeviceID);
  Result := Driver.OpenCashDrawer(DeviceID);
end;

function TDriver30.GetLineLength(const DeviceID: WideString;
  var LineLength: Integer): Boolean;
begin
  FLogger.Debug('GetLineLength ' +  DeviceID);
  Result := Driver.GetLineLength(DeviceID, LineLength);
end;

function TDriver30.GetLocalizationPattern(
  var LocalizationPattern: WideString): Boolean;
begin
  Logger.Debug('GetLocalizationPattern: ' + LocalizationPattern);
  Result := Driver.GetLocalizationPattern(LocalizationPattern);
end;

end.
