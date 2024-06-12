unit duDriver1Cst;

interface

uses
  // This
  Windows, ComServ, ActiveX, ComObj, SysUtils, Classes, Math, XMLDoc, XmlIntf,
  // DUnit
  TestFramework,
  // This
  MitsuDrv1CTst_TLB, LogFile, Driver1Cst, FileUtils, XmlDoc1C, OleArray1C,
  DriverTypes, VersionInfo, MitsuDrv;

type
  { TDriver1CTest }

  TDriver1CTest = class(TTestCase)
  private
    Logger: ILogFile;
    Driver: TDriver1Cst;
    DeviceID: WideString;
    Array1C: Variant;
    Params: TDriverParams;
  protected
    procedure Setup; override;
    procedure TearDown; override;
  published
    procedure TestParams;
    procedure TestOpen;
    procedure TestClose;
    procedure TestDeviceTest;
    procedure TestGetVersion;
    procedure TestPrintXReport;
    procedure TestPrintZReport;
  end;

implementation

{ TDriver1CstTest }

procedure TDriver1CTest.Setup;
begin
  //Driver := CreateOleObject('Addin.Mitsu1C') as IMitsu1C;
  Logger := TLogFile.Create;
  Driver := TDriver1Cst.Create(Logger);

  Params.DriverParams.ConnectionType := 0;
  Params.DriverParams.PortName := 'COM8';
  Params.DriverParams.BaudRate := 115200;
  Params.DriverParams.ByteTimeout := 1000;
  Params.DriverParams.RemoteHost := '';
  Params.DriverParams.RemotePort := 0;
  Params.DriverParams.LogPath := GetModulePath;
  Params.DriverParams.LogEnabled := True;
  Params.CashierName := 'CashierName';
  Params.CashierINN := '505303696069';
  Params.PrintRequired := True;
end;

procedure TDriver1CTest.TearDown;
begin
  Driver.Free;
  Logger := nil;
end;

procedure TDriver1CTest.TestParams;
var
  V: IDispatch;
  P: TDriverParams;
  P2: TDriverParams;
  M: TMitsuParams;
  M2: TMitsuParams;
begin
  V := TArray1C.Create;

  P.DriverParams.ConnectionType := 0;
  P.DriverParams.PortName := 'COM8';
  P.DriverParams.BaudRate := 115200;
  P.DriverParams.ByteTimeout := 1000;
  P.DriverParams.RemoteHost := '';
  P.DriverParams.RemotePort := 0;
  P.DriverParams.LogPath := GetModulePath;
  P.DriverParams.LogEnabled := True;
  P.CashierName := 'CashierName';
  P.CashierINN := '505303696069';
  P.PrintRequired := True;

  WriteDriverParams(V, Params);
  P2 := ReadDriverParams(V);

  D
  CheckEquals(P.DriverParams.ConnectionType, P2.DriverParams.ConnectionType,
  Params.DriverParams.PortName := 'COM8';
  Params.DriverParams.BaudRate := 115200;
  Params.DriverParams.ByteTimeout := 1000;
  Params.DriverParams.RemoteHost := '';
  Params.DriverParams.RemotePort := 0;
  Params.DriverParams.LogPath := GetModulePath;
  Params.DriverParams.LogEnabled := True;
  Params.CashierName := 'CashierName';
  Params.CashierINN := '505303696069';
  Params.PrintRequired := True;

end;

procedure TDriver1CTest.TestDeviceTest;
var
  V: Variant;
  rc: WordBool;
  AdditionalDescription, DemoModeIsActivated: WideString;
begin
  V := TArray1C.Create as IDispatch;
  WriteDriverParams(V, Params);
  rc := Driver.DeviceTest(V, AdditionalDescription, DemoModeIsActivated);
  CheckEquals(True, rc, 'DeviceTest');
  CheckEquals('MITSU-1-F № 065001000000008', AdditionalDescription, 'AdditionalDescription');
  CheckEquals('', DemoModeIsActivated, 'DemoModeIsActivated');
end;

procedure TDriver1CTest.TestOpen;
var
  rc: WordBool;
  V: IArray1C;
  DeviceID: WideString;
begin
  V := TArray1C.Create;
  WriteDriverParams(V, Params);
  rc := Driver.Open(V, DeviceID);
  CheckEquals(True, rc, 'Open');
  CheckEquals('1', DeviceID, 'DeviceID');
end;

procedure TDriver1CTest.TestClose;
var
  V: IArray1C;
  DeviceID: WideString;
  ErrorDescription: WideString;
begin
  CheckEquals(0, Driver.GetLastError(ErrorDescription), 'GetLastError');
  CheckEquals('0, Ошибок нет', ErrorDescription, 'ErrorDescription');

  CheckEquals(False, Driver.Close(''), 'Close');
  CheckEquals(E_INVALIDPARAM, Driver.GetLastError(ErrorDescription), 'GetLastError');
  CheckEquals('-9, Некорректное значение параметра "DeviceID"', ErrorDescription, 'ErrorDescription');

  CheckEquals(False, Driver.Close('0'), 'Close');
  CheckEquals(E_INVALIDPARAM, Driver.GetLastError(ErrorDescription), 'GetLastError');
  CheckEquals('-9, Устройство с таким ИДУстройства не подключено', ErrorDescription, 'ErrorDescription');

  CheckEquals(False, Driver.Close('qwe'), 'Close');
  CheckEquals(E_INVALIDPARAM, Driver.GetLastError(ErrorDescription), 'GetLastError');
  CheckEquals('-9, Некорректное значение параметра "DeviceID"', ErrorDescription, 'ErrorDescription');

  V := TArray1C.Create;
  WriteDriverParams(V, Params);
  CheckEquals(True, Driver.Open(Array1C, DeviceID), 'Open');
  CheckEquals('1', DeviceID, 'DeviceID');
  CheckEquals(0, Driver.GetLastError(ErrorDescription), 'GetLastError');
  CheckEquals('0, Ошибок нет', ErrorDescription, 'ErrorDescription');

  CheckEquals(True, Driver.Close(DeviceID), 'Close');
  CheckEquals(0, Driver.GetLastError(ErrorDescription), 'GetLastError');
  CheckEquals('0, Ошибок нет', ErrorDescription, 'ErrorDescription');
end;

procedure TDriver1CTest.TestGetVersion;
begin
  CheckEquals(GetModuleVersion, Driver.GetVersion, 'GetVersion');
end;

procedure TDriver1CTest.TestPrintXReport;
var
  V: IArray1C;
  DeviceID: WideString;
begin
  V := TArray1C.Create;
  WriteDriverParams(V, Params);
  CheckEquals(True, Driver.Open(Array1C, DeviceID), 'Open');
  CheckEquals('1', DeviceID, 'DeviceID');
  CheckEquals(True, Driver.PrintXReport(DeviceID), 'PrintXReport');
end;

procedure TDriver1CTest.TestPrintZReport;
begin

end;



initialization
  RegisterTest('', TDriver1CTest.Suite);

end.

(*
    function PrintXReport(const DeviceID: WideString): WordBool; safecall;
    function PrintZReport(const DeviceID: WideString): WordBool; safecall;
    function CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool; safecall;
    function OpenCheck(const DeviceID: WideString; IsFiscalCheck: WordBool;
                       IsReturnCheck: WordBool; CancelOpenedCheck: WordBool;
                       out CheckNumber: Integer; out SessionNumber: Integer): WordBool; safecall;
    function PrintFiscalString(const DeviceID: WideString; const Name: WideString;
                               Quantity: Double; Price: Double; Amount: Double;
                               Department: Integer; Tax: Single): WordBool; safecall;
    function CloseCheck(const DeviceID: WideString; Cash: Double; PayByCard: Double;
                        PayByCredit: Double): WordBool; safecall;
    function CancelCheck(const DeviceID: WideString): WordBool; safecall;
    function PrintNonFiscalString(const DeviceID: WideString; const TextString: WideString): WordBool; safecall;
    function DeviceTest(const ValuesArray: IDispatch; out AdditionalDescription: WideString): WordBool; safecall;
    function Open(const ValuesArray: IDispatch; out DeviceID: WideString): WordBool; safecall;
    function CheckPrintingStatus(const DeviceID: WideString): WordBool; safecall;
    function ContinuePrinting(const DeviceID: WideString): WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString; CashDrawerID: Integer): WordBool; safecall;
    function LoadLogo(const ValuesArray: IDispatch; const LogoFileName: WideString;
                      CenterLogo: WordBool; out LogoSize: Integer;
                      out AdditionalDescription: WideString): WordBool; safecall;
    function OpenSession(const DeviceID: WideString): WordBool; safecall;
    function DeviceControl(const DeviceID: WideString; const TxData: WideString;
                           out RxData: WideString): WordBool; safecall;
    function DeviceControlHEX(const DeviceID: WideString; const TxData: WideString;
                              out RxData: WideString): WordBool; safecall;
    function Get_DiscountOnCheck: Double; safecall;
    procedure Set_DiscountOnCheck(Value: Double); safecall;
    function Get_PayType4: Double; safecall;
    procedure Set_PayType4(Value: Double); safecall;
    property DiscountOnCheck: Double read Get_DiscountOnCheck write Set_DiscountOnCheck;
    property PayType4: Double read Get_PayType4 write Set_PayType4;

*)
