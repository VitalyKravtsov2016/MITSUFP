unit oleMain1C11;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  // VCL
  ActiveX, DrvFRLib_TLB, StdVcl, SysUtils, ActiveXView,
  // This
  ComObj, ComServ, untLogger, Driver1Cst11, StringUtils, ActiveXControl1C,
  AddIn1CInterface, AxCtrls, TranslationUtil;

type
  TDrvFR1C11 = class(TActiveXControl1C, IDrvFR1C11, IInitDone, ILanguageExtender)
  private
    FLogger: TLogger;
    FDriver: TDriver1Cst11;
    function GetLogger: TLogger;
    function GetDriver: TDriver1Cst11;
    property Logger: TLogger read GetLogger;
    property Driver: TDriver1Cst11 read GetDriver;
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
      Barcode: WideString): WordBool; safecall;
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
    function DeviceControlHEX(const DeviceID, TxData: WideString;
      out RxData: WideString): WordBool; safecall;
  public
    destructor Destroy; override;
    procedure SetLang(LangID: Integer); safecall;
  end;

implementation

function TDrvFR1C11.GetLogger: TLogger;
begin
  if FLogger = nil then
    FLogger := TLogger.Create(Self.ClassName);
  Result := FLogger;
end;

function TDrvFR1C11.GetDriver: TDriver1Cst11;
begin
  if FDriver = nil then
    FDriver := TDriver1Cst11.Create;
  Result := FDriver;
end;

function TDrvFR1C11.CancelCheck(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['CancelCheck', DeviceID]));
  Result := Driver.CancelCheck(DeviceID);
  Logger.Debug(Format('%s: %s', ['CancelCheck', BoolToStr(Result)]));
end;

function TDrvFR1C11.CashInOutcome(const DeviceID: WideString;
  Amount: Double): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s, Amount: %.2f)', ['CashInOutcome',
    DeviceID, Amount]));
  Result := Driver.CashInOutcome(DeviceID, Amount);
  Logger.Debug(Format('%s: %s', ['CashInOutcome', BoolToStr(Result)]));
end;

function TDrvFR1C11.Close(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['Close', DeviceID]));
  Result := Driver.Close(DeviceID);
  Logger.Debug(Format('%s: %s', ['Close', BoolToStr(Result)]));
end;

function TDrvFR1C11.CloseCheck(const DeviceID: WideString; Cash, PayByCard,
  PayByCredit, PayByCertificate: Double): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s, Cash: %.2f, PayByCard: %.2f, PayByCredit: %.2f, PayBySertificate: %.2f)',
    ['CloseCheck', DeviceID, Cash, PayByCard, PayByCredit, PayByCertificate]));
  Result := Driver.CloseCheck(DeviceID, Cash, PayByCard, PayByCredit, PayByCertificate);
  Logger.Debug(Format('%s: %s', ['CloseCheck', BoolToStr(Result)]));
end;

function TDrvFR1C11.DeviceTest(out Description,
  DemoModeIsActivated: WideString): WordBool;
begin
  Logger.Debug('DeviceTest');
  Result := Driver.DeviceTest(nil, Description, DemoModeIsActivated);
  Logger.Debug(Format('DeviceTest(%s, %s): %s', [Description, DemoModeIsActivated, BoolToStr(Result)]));
end;

function TDrvFR1C11.DoAdditionalAction(
  const ActionName: WideString): WordBool;
begin
  Logger.Debug(Format('DoAdditionalAction(%s)', [ActionName]));
  Result := Driver.DoAdditionalAction(ActionName);
  Logger.Debug(Format('DoAdditionalAction: %s', [BoolToStr(Result)]));
end;

function TDrvFR1C11.GetAdditionalActions(
  out TableActions: WideString): WordBool;
begin
  Logger.Debug('GetAdditionalActions');
  Result := Driver.GetAdditionalActions(TableActions);
  Logger.Debug(Format('GetAdditionalActions(%s): %s', [TableActions, BoolToStr(Result)]));
end;

function TDrvFR1C11.GetDescription(out Name, Description,
  EquipmentType: WideString; out InterfaceRevision: Integer;
  out IntegrationLibrary, MainDriverInstalled: WordBool;
  out GetDownloadURL: WideString): WordBool;
begin
  Result := True;
  Name := 'Штрих-М: Драйвер ФР';
  Description := 'Драйвер ФР';
  EquipmentType := 'ФискальныйРегистратор';
  InterfaceRevision := 1005;
  IntegrationLibrary := True;
  MainDriverInstalled := True;
  GetDownloadURL := 'http://www.shtrih-m.ru/support/download/?section_id=76&product_id=all&type_id=156';
end;

function TDrvFR1C11.GetLastError(
  out ErrorDescription: WideString): Integer;
begin
  Logger.Debug('GetLastError');
  Result := Driver.GetLastError(ErrorDescription);
  Logger.Debug(Format('%s(ErrorDescription: %s): %d', ['GetLastError',
    ErrorDescription, Result]));
end;

function TDrvFR1C11.GetLineLength(const DeviceID: WideString;
  out LineLength: Integer): WordBool;
begin
  Logger.Debug(Format('GetLineLength(DeviceID: %s)', [DeviceID]));
  Result := Driver.GetLineLength(DeviceID, LineLength);
  Logger.Debug(Format('GetLineLength(LineLength: %d): %s', [LineLength, BoolToStr(Result)]));
end;

function TDrvFR1C11.GetParameters(
  out TableParameters: WideString): WordBool;
begin
  Logger.Debug('GetParameters');
  Result := Driver.GetParameters(TableParameters);
  Logger.Debug(Format('GetParameters(TableParameters: %s): %s', [TableParameters, BoolToStr(Result)]));
end;

function TDrvFR1C11.GetVersion: WideString;
begin
  Logger.Debug('GetVersion');
  Result := Driver.GetVersion;
  Logger.Debug(Format('%s: %s', ['GetVersion', Result]));
end;

function TDrvFR1C11.Open(out DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('Open(%s)', [DeviceID]));
  Result := Driver.Open(nil, DeviceID);
  Logger.Debug(Format('Open: %s', [BoolToStr(Result)]));
end;

function TDrvFR1C11.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('OpenCashDrawer(DeviceID: %s)', [DeviceID]));
  Result := Driver.OpenCashDrawer(DeviceID, 0);
  Logger.Debug(Format('OpenCashDrawer: %s', [BoolToStr(Result)]));
end;

function TDrvFR1C11.OpenCheck(const DeviceID: WideString; IsFiscalCheck,
  IsReturnCheck, CancelOpenedCheck: WordBool; out CheckNumber,
  SessionNumber: Integer): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s, IsFiscalCheck: %s, IsReturnCheck: %s,' +
    'CancelOpenedCheck: %s)', ['OpenCheck', DeviceID, BoolToStr(IsFiscalCheck),
      BoolToStr(IsReturnCheck), BoolToStr(CancelOpenedCheck)]));
  Result := Driver.OpenCheck(DeviceID, IsFiscalCheck, IsReturnCheck,
    CancelOpenedCheck, CheckNumber, SessionNumber);
  Logger.Debug(Format('%s(CheckNumber: %d; SessionNumber: %d): %s',
    ['OpenCheck', CheckNumber, SessionNumber, BoolToStr(Result)]));
end;

function TDrvFR1C11.PrintBarCode(const DeviceID, BarcodeType,
  Barcode: WideString): WordBool;
begin
  Logger.Debug(Format('PrintBarCode(%s, %s, %s)', [DeviceID, BarcodeType, Barcode]));
  Result := Driver.PrintBarCode(DeviceID, BarcodeType, Barcode);
  Logger.Debug(Format('PrintBarCode: %s', [BoolToStr(Result)]));
end;

function TDrvFR1C11.PrintFiscalString(const DeviceID, Name: WideString;
  Quantity, Price, Amount: Double; Department: Integer;
  Tax: Double): WordBool;
begin
 Logger.Debug(Format('%s(DeviceID: %s, Name: %s, Quantity: %.3f, Price: %.2f,' +
    'Amount: %.2f, Department: %d, Tax: %.2f)', ['PrintFiscalString', DeviceID,
      Name, Quantity, Price, Amount, Department, Tax]));
  Result := Driver.PrintFiscalString(DeviceID,
    Name, Quantity, Price, Amount, Department, Tax);
  Logger.Debug(Format('%s: %s',
    ['PrintFiscalString', BoolToStr(Result)]));
end;

function TDrvFR1C11.PrintNonFiscalString(const DeviceID,
  TextString: WideString): WordBool;
var
  i: Integer;
  s: string;
begin
  Logger.Debug(Format('%s(DeviceID: %s, TextString: %s)',
    ['PrintNonFiscalString', DeviceID, TextString]));
  Result := Driver.PrintNonFiscalString(DeviceID, TextString);
  s := '';
  for i := 1 to Length(TextString) do
  begin
    s := s + IntToHex(Word(Ord(TextString[i])), 4) + ' ';
  end;

  Logger.Debug('PrintText2 ' + s);

  Logger.Debug(Format('%s: %s', ['PrintNonFiscalString', BoolToStr(Result)]));
end;

function TDrvFR1C11.PrintXReport(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['PrintXReport', DeviceID]));
  Result := Driver.PrintXReport(DeviceID);
  Logger.Debug(Format('%s: %s', ['PrintXReport', BoolToStr(Result)]));
end;

function TDrvFR1C11.PrintZReport(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['PrintZReport', DeviceID]));
  Result := Driver.PrintZReport(DeviceID);
  Logger.Debug(Format('%s: %s', ['PrintZReport', BoolToStr(Result)]));
end;

function TDrvFR1C11.SetParameter(const Name: WideString;
  Value: OleVariant): WordBool;
begin
  Logger.Debug(Format('SetParameter(%s, %s)', [Name, string(Value)]));
  Result := Driver.SetParameter(Name, Value);
  Logger.Debug(Format('SetParameter: %s', [BoolToStr(Result)]));
end;

destructor TDrvFR1C11.Destroy;
begin
  FLogger.Free;
  FDriver.Free;
  inherited Destroy;
end;

procedure TDrvFR1C11.SetLang(LangID: Integer);
begin
  if LangID = 0 then
    SetCustomTranslationLanguage('RU')
  else
    SetCustomTranslationLanguage('EN');
end;

function TDrvFR1C11.OpenShift(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['OpenShift', DeviceID]));
  Result := Driver.OpenShift(DeviceID);
  Logger.Debug(Format('%s: %s', ['OpenShift', BoolToStr(Result)]));
end;


function TDrvFR1C11.PrintFiscalString2(const DeviceID, Name: WideString;
  Quantity, Price, Amount: Double; Department, Tax1, Tax2, Tax3,
  Tax4: Integer): WordBool;
begin
 Logger.Debug(Format('%s(DeviceID: %s, Name: %s, Quantity: %.3f, Price: %.2f,' +
    'Amount: %.2f, Department: %d, Tax1: %d, Tax2: %d, Tax3: %d, Tax4: %d)', ['PrintFiscalString2', DeviceID,
      Name, Quantity, Price, Amount, Department, Tax1, Tax2, Tax3, Tax4]));
  Result := Driver.PrintFiscalString2(DeviceID,
    Name, Quantity, Price, Amount, Department, Tax1, Tax2, Tax3, Tax4);
  Logger.Debug(Format('%s: %s',
    ['PrintFiscalString2', BoolToStr(Result)]));
end;

function TDrvFR1C11.CheckPrintingStatus(
  const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['CheckPrintingStatus', DeviceID]));
  Result := Driver.CheckPrintingStatus(DeviceID);
  Logger.Debug(Format('%s: %s', ['CheckPrintingStatus', BoolToStr(Result)]));
end;

function TDrvFR1C11.ContinuePrinting(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['ContinuePrinting', DeviceID]));
  Result := Driver.ContinuePrinting(DeviceID);
  Logger.Debug(Format('%s: %s', ['ContinuePrinting', BoolToStr(Result)]));
end;

function TDrvFR1C11.DeviceControlHEX(const DeviceID, TxData: WideString;
  out RxData: WideString): WordBool;
begin
  Logger.Debug(Format('DeviceControlHex(%s, Tx: "%s")', [DeviceID, TxData]));
  Result := Driver.DeviceControlHex(DeviceID, TxData, RxData);
  Logger.Debug(Format('DeviceControlHex(%s, Rx: "%s"): %s', [DeviceID, RxData, BoolToStr(Result)]));
end;

initialization
{$IFNDEF WIN64}
  SetTranslationLanguage;
{$ENDIF}
  ComServer.SetServerName('AddIn');
  TActiveXControlFactory.Create(ComServer, TDrvFR1C11, TActiveXView,
    Class_DrvFR1C11, 1, '', OLEMISC_INVISIBLEATRUNTIME, tmApartment);
end.
