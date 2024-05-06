unit oleMain;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  // VCL
  ComObj2, ActiveX, StdVcl, SysUtils,
  // This
  SMDrvFR1CLib_TLB, DrvFR1CLib_TLB, VersionInfo, ActiveXView, AddIn1CInterface,
  ActiveXControl1C, AxCtrls2, LogFile;

type
  TsmDrvFR1C = class(TActiveXControl1C, IsmDrvFR1C, IInitDone, ILanguageExtender)
  private
    FLastError: Integer;
    FLastErrorDescription: string;
    FDriver: TDrvFR1C11;
    function GetDriver: TDrvFR1C11;
    property Driver: TDrvFR1C11 read GetDriver;
    function HandleException(E: Exception): Boolean;
  protected
    function CancelCheck(const DeviceID: WideString): WordBool; safecall;
    function CashInOutcome(const DeviceID: WideString;
      Amount: Double): WordBool; safecall;
    function Close(const DeviceID: WideString): WordBool; safecall;
    function CloseCheck(const DeviceID: WideString; Cash, PayByCard,
      PayByCredit, PayByCertificate: Double): WordBool; safecall;
    function DeviceTest(out Description,
      DemoModeIsActivated: WideString): WordBool; safecall;
    function DoAdditionalAction(const ActionName: WideString): WordBool;
      safecall;
    function GetAdditionalActions(out TableActions: WideString): WordBool;
      safecall;
    function GetDescription(out Name, Description, EquipmentType: WideString;
      out InterfaceRevision: Integer; out IntegrationLibrary,
      MainDriverInstalled: WordBool;
      out GetDownloadURL: WideString): WordBool; safecall;
    function GetLastError(out ErrorDescription: WideString): Integer; safecall;
    function GetLineLength(const DeviceID: WideString;
      out LineLength: Integer): WordBool; safecall;
    function GetParameters(out TableParameters: WideString): WordBool;
      safecall;
    function GetVersion: WideString; safecall;
    function Open(out DeviceID: WideString): WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; safecall;
    function OpenCheck(const DeviceID: WideString; IsFiscalCheck,
      IsReturnCheck, CancelOpenedCheck: WordBool; out CheckNumber,
      SessionNumber: Integer): WordBool; safecall;
    function PrintBarCode(const DeviceID, BarcodeType,
      BarCode: WideString): WordBool; safecall;
    function PrintFiscalString(const DeviceID, Name: WideString; Quantity,
      Price, Amount: Double; Department: Integer; Tax: Double): WordBool;
      safecall;
    function PrintNonFiscalString(const DeviceID,
      TextString: WideString): WordBool; safecall;
    function PrintXReport(const DeviceID: WideString): WordBool; safecall;
    function PrintZReport(const DeviceID: WideString): WordBool; safecall;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool;
      safecall;
    function OpenShift(const DeviceID: WideString): WordBool; safecall;
    function PrintFiscalString2(const DeviceID, Name: WideString; Quantity,
      Price, Amount: Double; Department, Tax1, Tax2, Tax3,
      Tax4: Integer): WordBool; safecall;
    function CheckPrintingStatus(const DeviceID: WideString): WordBool;
      safecall;
    function ContinuePrinting(const DeviceID: WideString): WordBool; safecall;
  public
    procedure SetLang(LangType: string); override;
    procedure Initialize; override;
    destructor Destroy; override;
  end;

implementation

uses ComServ2;

function TsmDrvFR1C.CancelCheck(const DeviceID: WideString): WordBool;
begin
  try
    Result := Driver.CancelCheck(DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.CashInOutcome(const DeviceID: WideString;
  Amount: Double): WordBool;
begin
  try
    Result := Driver.CashInOutcome(DeviceID, Amount);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.Close(const DeviceID: WideString): WordBool;
begin
  try
    Result := Driver.Close(DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.CloseCheck(const DeviceID: WideString; Cash, PayByCard,
  PayByCredit, PayByCertificate: Double): WordBool;
begin
  try
    Result := Driver.CloseCheck(DeviceID, Cash, PayByCard, PayByCredit, PayByCertificate);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.DeviceTest(out Description,
  DemoModeIsActivated: WideString): WordBool;
begin
  try
    Result := Driver.DeviceTest(Description, DemoModeIsActivated);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.DoAdditionalAction(
  const ActionName: WideString): WordBool;
begin
  try
    Result := Driver.DoAdditionalAction(ActionName);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.GetAdditionalActions(
  out TableActions: WideString): WordBool;
begin
  try
    Result := Driver.GetAdditionalActions(TableActions);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.GetDescription(out Name, Description,
  EquipmentType: WideString; out InterfaceRevision: Integer;
  out IntegrationLibrary, MainDriverInstalled: WordBool;
  out GetDownloadURL: WideString): WordBool;
begin
  try
    Result := Driver.GetDescription(Name, Description, EquipmentType,
      InterfaceRevision, IntegrationLibrary, MainDriverInstalled, GetDownloadURL);
  except
    on E: Exception do
    begin
      Name := 'Штрих-М: Драйвер ФР';
      Description := 'Драйвер ФР';
      EquipmentType := 'ФискальныйРегистратор';
      InterfaceRevision := 1005;
      IntegrationLibrary := True;
      MainDriverInstalled := False;
      GetDownloadURL := 'http://old.shtrih-m.ru/modules.php?name=Downloads&d_op=showpage&cid=315&lid=316&typeid=129';
      Result := HandleException(E);
    end;
  end;
end;

function TsmDrvFR1C.GetDriver: TDrvFR1C11;
begin
  try
    if FDriver = nil then
    begin
      FDriver := TDrvFR1C11.Create(nil);
{      GlobalLogger.Enabled := True;
      GlobalLogger.FileName := ChangeFileExt(GetDllFileName, '.log');}

    end;
    Result := FDriver;
  except
    on E: Exception do
      raise Exception.Create('Объект драйвера не установлен');
  end;
end;

function TsmDrvFR1C.GetLastError(
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

function TsmDrvFR1C.GetLineLength(const DeviceID: WideString;
  out LineLength: Integer): WordBool;
begin
  try
    Result := Driver.GetLineLength(DeviceID, LineLength);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.GetParameters(
  out TableParameters: WideString): WordBool;
begin
  try
    Result := Driver.GetParameters(TableParameters);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.GetVersion: WideString;
begin
  try
    Result := Driver.GetVersion;
  except
    Result := GetFileVersionInfoStr;
  end;
end;

function TsmDrvFR1C.HandleException(E: Exception): Boolean;
begin
  Result := False;
  FLastError := -100;
  FLastErrorDescription := E.Message;
end;

procedure TsmDrvFR1C.Initialize;
begin
  inherited;
end;

function TsmDrvFR1C.Open(out DeviceID: WideString): WordBool;
begin
  try
    Result := Driver.Open(DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin
  try
    Result := Driver.OpenCashDrawer(DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.OpenCheck(const DeviceID: WideString; IsFiscalCheck,
  IsReturnCheck, CancelOpenedCheck: WordBool; out CheckNumber,
  SessionNumber: Integer): WordBool;
begin
  try
    Result := Driver.OpenCheck(DeviceID, IsFiscalCheck, IsReturnCheck,
      CancelOpenedCheck, CheckNumber, SessionNumber);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.PrintBarCode(const DeviceID, BarcodeType,
  BarCode: WideString): WordBool;
begin
  try
    Result := Driver.PrintBarCode(DeviceID, BarCodeType, BarCode);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.PrintFiscalString(const DeviceID, Name: WideString;
  Quantity, Price, Amount: Double; Department: Integer;
  Tax: Double): WordBool;
begin
  try
    Result := Driver.PrintFiscalString(DeviceID, Name, Quantity, Price, Amount,
      Department, Tax);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.PrintNonFiscalString(const DeviceID,
  TextString: WideString): WordBool;
begin
  try
    Result := Driver.PrintNonFiscalString(DeviceID, TextString);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.PrintXReport(const DeviceID: WideString): WordBool;
begin
  try
    Result := Driver.PrintXReport(DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.PrintZReport(const DeviceID: WideString): WordBool;
begin
  try
    Result := Driver.PrintZReport(DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TsmDrvFR1C.SetLang(LangType: string);
begin
  if LangType = 'rus_RUS' then
    Driver.SetLang(0)
  else
    Driver.SetLang(1);
end;

function TsmDrvFR1C.SetParameter(const Name: WideString;
  Value: OleVariant): WordBool;
begin
  try
    Result := Driver.SetParameter(Name, Value);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.OpenShift(const DeviceID: WideString): WordBool;
begin
  try
    Result := Driver.OpenShift(DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

destructor TsmDrvFR1C.Destroy;
begin
  FDriver.Free;
  inherited;
end;

function TsmDrvFR1C.PrintFiscalString2(const DeviceID, Name: WideString;
  Quantity, Price, Amount: Double; Department, Tax1, Tax2, Tax3,
  Tax4: Integer): WordBool;
begin
 try
    Result := Driver.PrintFiscalString2(DeviceID, Name, Quantity, Price, Amount,
      Department, Tax1, Tax2, Tax3, Tax4);
 except
    on E: Exception do
      Result := HandleException(E);
 end;
end;

function TsmDrvFR1C.CheckPrintingStatus(
  const DeviceID: WideString): WordBool;
begin
  try
    Result := Driver.CheckPrintingStatus(DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TsmDrvFR1C.ContinuePrinting(const DeviceID: WideString): WordBool;
begin
  try
    Result := Driver.ContinuePrinting(DeviceID);
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

initialization
  ComServer.SetServerName('AddIn');
{    TAutoObjectFactory.Create(ComServer, TsmDrvFR1C, Class_smDrvFR1C,
    ciMultiInstance, tmApartment);}
  TActiveXControlFactory2.Create(ComServer, TsmDrvFR1C, TActiveXView,
    CLASS_SMDrvFR1C, 1, '', OLEMISC_INVISIBLEATRUNTIME, tmApartment);


end.
