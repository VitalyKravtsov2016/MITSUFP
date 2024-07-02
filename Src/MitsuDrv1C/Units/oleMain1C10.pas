unit oleMain1C10;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  // VCL
  ComObj, ActiveX, StdVcl, SysUtils, ActiveXView, ComServ, AxCtrls,
  // This
  MitsuLib_TLB, LogFile, Driver1C10, StringUtils, ActiveXControl1C,
  AddIn1CInterface, TranslationUtil, FileUtils;

type
  { TOleMain1C }

  TOleMain1C = class(TActiveXControl1C, IMitsu1C, IInitDone, ILanguageExtender)
  private
    FPayType4: Double;
    FLogger: ILogFile;
    FDriver: TDriver1C10;
    function GetLogger: ILogFile;
    function GetDriver: TDriver1C10;
    property Logger: ILogFile read GetLogger;
    property Driver: TDriver1C10 read GetDriver;
  protected
    function CashInOutcome(const DeviceID: WideString;
      Amount: Double): WordBool; safecall;
    function Close(const DeviceID: WideString): WordBool; safecall;
    function DeviceTest(const ValuesArray: IDispatch;
      out AdditionalDescription: WideString): WordBool; safecall;
    function GetLastError(out ErrorDescription: WideString): Integer; safecall;
    function GetVersion: WideString; safecall;
    function Open(const ValuesArray: IDispatch;
      out DeviceID: WideString): WordBool; safecall;
    function PrintFiscalString(const DeviceID, Name: WideString; Quantity,
      Price, Amount: Double; Department: Integer; Tax: Single): WordBool;
      safecall;
    function PrintNonFiscalString(const DeviceID,
      TextString: WideString): WordBool; safecall;
    function PrintXReport(const DeviceID: WideString): WordBool; safecall;
    function PrintZReport(const DeviceID: WideString): WordBool; safecall;
    function CheckPrintingStatus(const DeviceID: WideString): WordBool;
      safecall;
    function ContinuePrinting(const DeviceID: WideString): WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString;
      CashDrawerID: Integer): WordBool; safecall;
    function LoadLogo(const ValuesArray: IDispatch;
      const LogoFileName: WideString; CenterLogo: WordBool;
      out LogoSize: Integer;
      out AdditionalDescription: WideString): WordBool; safecall;

    function OpenSession(const DeviceID: WideString): WordBool; safecall;
    function CancelCheck(const DeviceID: WideString): WordBool;
      safecall;
    function CloseCheck(const DeviceID: WideString; Cash, PayByCard,
      PayByCredit: Double): WordBool; safecall;
    function OpenCheck(const DeviceID: WideString; IsFiscalCheck,
      IsReturnCheck, CancelOpenedCheck: WordBool; out CheckNumber,
      SessionNumber: Integer): WordBool; safecall;
    function DeviceControl(const DeviceID, TxData: WideString;
      out RxData: WideString): WordBool; safecall;
    function DeviceControlHEX(const DeviceID, TxData: WideString;
      out RxData: WideString): WordBool; safecall;
    function Get_DiscountOnCheck: Double; safecall;
    procedure Set_DiscountOnCheck(Value: Double); safecall;
    function Get_PayType4: Double; safecall;
    procedure Set_PayType4(Value: Double); safecall;
  public
    destructor Destroy; override;
    procedure Initialize; override;
  end;

implementation

{ TOleMain1C }

procedure TOleMain1C.Initialize;
begin
  inherited Initialize;
  FPayType4 := 0;
end;

destructor TOleMain1C.Destroy;
begin
  FDriver.Free;
  FLogger := nil;
  inherited Destroy;
end;

function TOleMain1C.GetLogger: ILogFile;
begin
  if FLogger = nil then
  begin
    FLogger := TLogFile.Create;
    FLogger.FilePath := 'C:\';
    FLogger.DeviceName := 'MitsuDrv1C';
    FLogger.Enabled := True;
  end;
  Result := FLogger;
end;

function TOleMain1C.GetDriver: TDriver1C10;
begin
  if FDriver = nil then
    FDriver := TDriver1C10.Create(Logger);
  Result := FDriver;
end;

function TOleMain1C.CashInOutcome(const DeviceID: WideString;
  Amount: Double): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s, Amount: %.2f)', ['CashInOutcome',
    DeviceID, Amount]));
  Result := Driver.CashInOutcome(DeviceID, Amount);
  Logger.Debug(Format('%s: %s', ['CashInOutcome', BoolToStr(Result)]));
end;

function TOleMain1C.Close(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['Close', DeviceID]));
  Result := Driver.Close(DeviceID);
  Logger.Debug(Format('%s: %s', ['Close', BoolToStr(Result)]));
end;

function TOleMain1C.CloseCheck(
  const DeviceID: WideString;
  Cash, PayByCard, PayByCredit: Double): WordBool; safecall;
begin
  Logger.Debug(Format('%s(DeviceID: %s, Cash: %.2f, PayByCard: %.2f, PayByCredit: %.2f, PayType4: %.2f)',
    ['CloseCheck', DeviceID, Cash, PayByCard, PayByCredit, FPayType4]));
  Result := Driver.CloseCheck(DeviceID, Cash, PayByCard, PayByCredit, FPayType4);
  Logger.Debug(Format('%s: %s', ['CloseCheck', BoolToStr(Result)]));
end;

function TOleMain1C.DeviceTest(const ValuesArray: IDispatch;
  out AdditionalDescription: WideString): WordBool;
var
  S: WideString;
begin
  Logger.Debug('DeviceTest');
(*
  Logger.Debug(Format('%s(ValuesArray:(%s))', ['DeviceTest',
    ValuesArrayToStr(ValuesArray)]));
*)
  Result := Driver.DeviceTest(ValuesArray, AdditionalDescription, S);
  Logger.Debug(Format('DeviceTest; AdditionalDescription: %s): %s', [
    AdditionalDescription, BoolToStr(Result)]));

(*
  Logger.Debug(Format('%s(ValuesArray: (%s); AdditionalDescription: %s): %s', ['DeviceTest',
    ValuesArrayToStr(ValuesArray, True),AdditionalDescription, BoolToStr(Result)]));
*)
end;

function TOleMain1C.GetLastError(out ErrorDescription: WideString): Integer;
begin
  Logger.Debug('GetLastError');
  Result := Driver.GetLastError(ErrorDescription);
  Logger.Debug(Format('%s(ErrorDescription: %s): %d', ['GetLastError',
    ErrorDescription, Result]));
end;

function TOleMain1C.GetVersion: WideString;
begin
  Logger.Debug('GetVersion');
  Result := Driver.GetVersion;
  Logger.Debug(Format('%s: %s', ['GetVersion', Result]));
end;

function TOleMain1C.Open(const ValuesArray: IDispatch;
  out DeviceID: WideString): WordBool;
begin
  Logger.Debug('Open');
(*
  Logger.Debug(Format('%s(ValuesArray:(%s))', ['Open',
    ValuesArrayToStr(ValuesArray)]));
*)
  Result := Driver.Open(ValuesArray, DeviceID);
(*
  Logger.Debug(Format('%s(ValuesArray: (%s); DeviceID: %s): %s',
    ['Open', ValuesArrayToStr(ValuesArray, True), DeviceID, BoolToStr(Result)]));
*)
end;

function TOleMain1C.OpenCheck(const DeviceID: WideString; IsFiscalCheck,
  IsReturnCheck, CancelOpenedCheck: WordBool; out CheckNumber,
  SessionNumber: Integer): WordBool; safecall;
begin
  Logger.Debug(Format('%s(DeviceID: %s, IsFiscalCheck: %s, IsReturnCheck: %s,' +
    'CancelOpenedCheck: %s)', ['OpenCheck', DeviceID, BoolToStr(IsFiscalCheck),
      BoolToStr(IsReturnCheck), BoolToStr(CancelOpenedCheck)]));
  Result := Driver.OpenCheck(DeviceID, IsFiscalCheck, IsReturnCheck,
    CancelOpenedCheck, CheckNumber, SessionNumber);
  Logger.Debug(Format('%s(CheckNumber: %d; SessionNumber: %d): %s',
    ['OpenCheck', CheckNumber, SessionNumber, BoolToStr(Result)]));
end;

function TOleMain1C.PrintFiscalString(const DeviceID, Name: WideString;
  Quantity, Price, Amount: Double; Department: Integer;
  Tax: Single): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s, Name: %s, Quantity: %.3f, Price: %.2f,' +
    'Amount: %.2f, Department: %d, Tax: %.2f)', ['PrintFiscalString', DeviceID,
      Name, Quantity, Price, Amount, Department, Tax]));
  Result := Driver.PrintFiscalString(DeviceID,
    Name, Quantity, Price, Amount, Department, Tax);
  Logger.Debug(Format('%s: %s',
    ['PrintFiscalString', BoolToStr(Result)]));
end;

function TOleMain1C.PrintNonFiscalString(const DeviceID,
  TextString: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s, TextString: %s)',
    ['PrintNonFiscalString', DeviceID, TextString]));
  Result := Driver.PrintNonFiscalString(DeviceID, TextString);
  Logger.Debug(Format('%s: %s', ['PrintNonFiscalString', BoolToStr(Result)]));
end;

function TOleMain1C.PrintXReport(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['PrintXReport', DeviceID]));
  Result := Driver.PrintXReport(DeviceID);
  Logger.Debug(Format('%s: %s', ['PrintXReport', BoolToStr(Result)]));
end;

function TOleMain1C.PrintZReport(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['PrintZReport', DeviceID]));
  Result := Driver.PrintZReport(DeviceID);
  Logger.Debug(Format('%s: %s', ['PrintZReport', BoolToStr(Result)]));
end;

function TOleMain1C.CancelCheck(
  const DeviceID: WideString): WordBool; safecall;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['CancelCheck', DeviceID]));
  Result := Driver.CancelCheck(DeviceID);
  Logger.Debug(Format('%s: %s', ['CancelCheck', BoolToStr(Result)]));
end;

function TOleMain1C.CheckPrintingStatus(
  const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['CheckPrintingStatus', DeviceID]));
  Result := Driver.CheckPrintingStatus(DeviceID);
  Logger.Debug(Format('%s: %s', ['CheckPrintingStatus', BoolToStr(Result)]));
end;

function TOleMain1C.ContinuePrinting(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('%s(DeviceID: %s)', ['ContinuePrinting', DeviceID]));
  Result := Driver.ContinuePrinting(DeviceID);
  Logger.Debug(Format('%s: %s', ['ContinuePrinting', BoolToStr(Result)]));
end;

function TOleMain1C.OpenCashDrawer(const DeviceID: WideString;
  CashDrawerID: Integer): WordBool;
begin
  Logger.Debug(Format('OpenCashDrawer(DeviceID: %s)', [DeviceID]));
  Result := Driver.OpenCashDrawer(DeviceID, CashDrawerID);
  Logger.Debug(Format('OpenCashDrawer: %s', [BoolToStr(Result)]));
end;

function TOleMain1C.LoadLogo(const ValuesArray: IDispatch;
  const LogoFileName: WideString; CenterLogo: WordBool;
  out LogoSize: Integer; out AdditionalDescription: WideString): WordBool;
begin
  Logger.Debug(Format('LoadLogo(LogoFileName: %s; CenterLogo: %s; LogoSize: %d)',
    [LogoFileName, BoolToStr(CenterLogo), LogoSize]));
(*
  Logger.Debug(Format('LoadLogo(ValuesArray: (%s); LogoFileName: %s; CenterLogo: %s; LogoSize: %d)',
    [LogoValuesArrayToStr(ValuesArray), LogoFileName, BoolToStr(CenterLogo), LogoSize]));
*)
  Result := Driver.LoadLogo(ValuesArray, LogoFileName, CenterLogo, LogoSize, AdditionalDescription);
  Logger.Debug(Format('LoadLogo(AdditionalDescription: %s): %s', [AdditionalDescription, BoolToStr(Result)]));
end;

function TOleMain1C.OpenSession(const DeviceID: WideString): WordBool;
begin
  Logger.Debug(Format('Opensession(%s)', [DeviceID]));
  Result := Driver.OpenSession(DeviceID);
  Logger.Debug(Format('OpenSession(%s): %s', [DeviceID, BoolToStr(Result)]));
end;

function TOleMain1C.DeviceControl(const DeviceID, TxData: WideString;
  out RxData: WideString): WordBool;
begin
  Logger.Debug(Format('DeviceControl(%s, Tx: "%s")', [DeviceID, StrToHex(TxData)]));
  Result := Driver.DeviceControl(DeviceID, TxData, RxData);
  Logger.Debug(Format('DeviceControl(%s, Rx: "%s"): %s', [DeviceID, StrToHex(RxData), BoolToStr(Result)]));
end;

function TOleMain1C.DeviceControlHEX(const DeviceID, TxData: WideString;
  out RxData: WideString): WordBool;
begin
  Logger.Debug(Format('DeviceControlHex(%s, Tx: "%s")', [DeviceID, TxData]));
  Result := Driver.DeviceControlHex(DeviceID, TxData, RxData);
  Logger.Debug(Format('DeviceControlHex(%s, Rx: "%s"): %s', [DeviceID, RxData, BoolToStr(Result)]));
end;

function TOleMain1C.Get_DiscountOnCheck: Double;
begin
  Logger.Debug('Get_DiscountOnCheck');
  Result := Driver.DiscountOnCheck;
  Logger.Debug(Format('Get_DiscountOnCheck %.2f', [Result]));
end;

procedure TOleMain1C.Set_DiscountOnCheck(Value: Double);
begin
  Logger.Debug(Format('Set_DiscountOnCheck %.2f', [Value]));
  Driver.DiscountOnCheck := Value;
end;

function TOleMain1C.Get_PayType4: Double;
begin
  Result := FPayType4;
  Logger.Debug(Format('Get_PayType4 %.2f', [Result]));
end;

procedure TOleMain1C.Set_PayType4(Value: Double);
begin
  Logger.Debug(Format('Set_PayType4 %.2f', [Value]));
  FPayType4 := Value;
end;


(*
initialization
{$IFNDEF WIN64}
  SetTranslationLanguage;
{$ENDIF}
  ComServer.SetServerName('AddIn');
  TActiveXControlFactory.Create(ComServer, TOleMain1C, TActiveXView,
    Class_Mitsu1C, 1, '', OLEMISC_INVISIBLEATRUNTIME, tmApartment);
*)
end.


