{ Тест интерфейса в соответствии с "Требованиями к разработке драйверов для
  фискальных регистраторов" компании 1С}

unit Driver1C10;

interface

uses
  // VCL
  Windows, Classes, ComObj, SysUtils, Variants, ActiveX, Types,
  // This
  MitsuLib_TLB, MitsuDrv1CTst_TLB, LanguageExtender, OleArray1C, StringUtils,
  untTypes, Driver1C;

type
  { TDriver1C10 }

  TDriver1C10 = class(TDriver1C)
  private
    FDriver: IMitsu1C;
    FValuesArray: IArray1C;
    FLogoValuesArray: IArray1C;
    function GetDriver: IMitsu1C;
    property Driver: IMitsu1C read GetDriver;
  public
    procedure CashInOutcome; override; 
    procedure Close; override; 
    procedure CloseCheck; override; 
    procedure DeviceTest; override; 
    procedure GetVersion; override; 
    procedure Open; override; 
    procedure OpenCheck; override; 
    procedure PrintFiscalString; override; 
    procedure PrintNonFiscalString; override; 
    procedure PrintXReport; override; 
    procedure PrintZReport; override; 
    procedure CancelCheck; override; 
    procedure CheckPrintingStatus; override; 
    procedure ContinuePrinting; override; 
    procedure PrintTestFiscalReceipt; override; 
    procedure PrintTestNonFiscalReceipt; override; 
    procedure TestError; override; 
    procedure OpenCashDrawer(CashDrawerID: Integer); override; 
    procedure LoadLogo; override; 
    procedure OpenSession; override; 
    procedure DeviceControl; override; 
    procedure DeviceControlHEX; override; 
    procedure GetLastError; override; 
    procedure SetConnectionParams; override;
    function GetSerialNumber: WideString; override; 
    function GetDrvVersion: Integer; override; 
    function GetLastError(var Desc: WideString): Integer; override; 
    function GetParameters: WideString; override; 
    procedure PrintBarCode; override; 
    procedure GetDescription; override;
    procedure GetLineLength; override;
    procedure SetLang(Lang: Integer); override;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

const
  OpenCheckID = 13;

{ TDriver1C }

procedure TDriver1C10.CancelCheck;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.CancelCheck(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s):%s', ['CancelCheck', FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.CashInOutcome;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.CashInOutcome(FDeviceID, FAmount);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s, %.2f):%s', ['CashInOutcome', FDeviceID, FAmount, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.CheckPrintingStatus;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.CheckPrintingStatus(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s):%s', ['CheckPrintingStatus', FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.Close;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.Close(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s):%s', ['Close', FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.CloseCheck;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Driver.DiscountOnCheck := FDiscountOnCheck;
  Driver.PayType4 := FPayByCertificate;
  Res := Driver.CloseCheck(FDeviceID, FCash, FPayByCard, FPayByCredit);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s, Cash:%.2f, PayByCard:%.2f, PayByCredit:%.2f):%s',
    ['CloseCheck', FDeviceID, FCash, FPayByCard, FPayByCredit, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.ContinuePrinting;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.ContinuePrinting(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s):%s', ['ContinuePrinting', FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.DeviceTest;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.DeviceTest(FValuesArray as IDispatch, FAdditionalDescription);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(ValuesArray:(%s), %s):%s',
    ['DeviceTest', ValuesArrayToStr(FValuesArray), FAdditionalDescription, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.GetLastError;
var
  Err: Integer;
  Desc: WideString;
begin
   FRunTime := GetTickCount;
   Err := Driver.GetLastError(Desc);
   FRunTime := GetTickCount - FRunTime;
   AddLine(Format('%s(%s):%d', ['GetLastError', Desc, Err]));
   DoChange(True);
end;

procedure TDriver1C10.GetVersion;
var
  S: string;
begin
  FRunTime := GetTickCount;
  S := Driver.GetVersion;
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s:%s', ['GetVersion', S]));
  DoChange(True);
end;

procedure TDriver1C10.Open;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.Open(FValuesArray as IDispatch, FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(ValuesArray:(%s), DeviceID = %s):%s',
    ['Open', ValuesArrayToStr(FValuesArray), FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.OpenCheck;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.OpenCheck(FDeviceID, FIsFiscalCheck, FIsReturnCheck, FCancelOpenedCheck,
    FCheckNumber, FSessionNumber);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s, IsFiscalCheck:%s, IsReturnCheck: %s, CancelopenedCheck: %s,' +
    'CheckNumber = %d, SessionNumber = %d):%s',
    ['OpenCheck', FDeviceID, BoolToStr(FIsFiscalCheck), BoolToStr(FIsReturnCheck),
    BoolToStr(FCancelOpenedCheck), FCheckNumber, FSessionNumber, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.PrintFiscalString;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.PrintFiscalString(FDeviceID, FName, FQuantity, FPrice, FAmount, FDepartment, FTax);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s, Name:%s, Quantity:%.3f, Price:%.2f, Amount:%.2f, Department:%d, Tax:%.2f):%s',
    ['PrintFiscalSTring', FDeviceID, FName, FQuantity, FPrice, FAmount, FDepartment, FTax, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.PrintNonFiscalString;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.PrintNonFiscalString(FDeviceID, FTextString);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s, TextString:%s):%s',
    ['PrintNonFiscalString', FDeviceID, FTextString, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.PrintXReport;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.PrintXReport(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s):%s', ['PrintXReport', FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.PrintZReport;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.PrintZReport(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s):%s', ['PrintZReport', FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

constructor TDriver1C10.Create;
begin
  inherited;
  FValuesArray := TArray1C.Create(nil);
  FLogoValuesArray := TArray1C.Create(nil);
end;

destructor TDriver1C10.Destroy;
begin
  FValuesArray := nil;
  FLogoValuesArray := nil;
  inherited Destroy;
end;

procedure TDriver1C10.PrintTestFiscalReceipt;
var
  i: Integer;
  V: Variant;
begin
  FIsFiscalCheck := True;
  FIsReturnCheck := False;
  FCancelOpenedCheck := True;
  OpenCheck;
  for i := 1 to 5 do
  begin
    FTextString := Format('Нефискальная строка %d', [i]);
    PrintNonFiscalString;
  end;
  V := FValuesArray as IDispatch;
  FTextString := '------------------------------';
  PrintNonFiscalString;

  // Позиция 1
  FName := 'Продукт 1';
  FQuantity := 1.123;
  FPrice := 34.15;
  FAmount := FPrice * FQuantity - 5.45; // Скидка 5.45
  FDepartment := 1;
  FTax := V.Get(6);
  PrintFiscalString;

  FTextString := '------------------------------';
  PrintNonFiscalString;

  // Позиция 2
  FName := 'Продукт 2';
  FQuantity := 2.432;
  FPrice := 4.35;
  FAmount := FPrice * FQuantity + 1.23; // Надбавка 1.23
  FDepartment := 2;
  FTax := V.Get(7);
  PrintFiscalString;

  FTextString := '------------------------------';
  PrintNonFiscalString;

  // Позиция 3
  FName := 'Продукт 3';
  FQuantity := 7.812;
  FPrice := 0.15;
  FAmount := FPrice * FQuantity - 0.12; // Скидка 0.12
  FDepartment := 3;
  FTax := V.Get(8);
  PrintFiscalString;

  FTextString := '------------------------------';
  PrintNonFiscalString;

  // Позиция 4
  FName := 'Продукт 4';
  FQuantity := 3.512;
  FPrice := 12.75;
  FAmount := FPrice * FQuantity + 1.2; // Надбавка 1.2
  FDepartment := 4;
  FTax := V.Get(9);
  PrintFiscalString;

  FTextString := '------------------------------';
  PrintNonFiscalString;

  // Позиция 5
  FName := 'Продукт 5';
  FQuantity := 1.123;
  FPrice := 34.15;
  FAmount := FPrice * FQuantity; // Без скидки
  FDepartment := 5;
  FTax := 0;
  PrintFiscalString;

  // Позиция 6
  FName := 'Продукт 6 ЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя';
  FQuantity := 1.123;
  FPrice := 34.15;
  FAmount := FPrice * FQuantity; // Без скидки
  FDepartment := 5;
  FTax := 0;
  PrintFiscalString;

  // Позиция 7
  FName := 'Продукт 7 КЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя';
  FQuantity := 1.123;
  FPrice := 34.15;
  FAmount := FPrice * FQuantity; // Без скидки
  FDepartment := 5;
  FTax := 0;
  PrintFiscalString;

  // Позиция 8
  FName := 'Продукт 8 ФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя';
  FQuantity := 1.123;
  FPrice := 34.15;
  FAmount := FPrice * FQuantity; // Без скидки
  FDepartment := 5;
  FTax := 0;
  PrintFiscalString;

  FTextString := '------------------------------';
  PrintNonFiscalString;
  FTextString := 'Строка 1';
  PrintNonFiscalString;
  FTextString := 'Строка 2';
  PrintNonFiscalString;
  FTextString := 'Строка 3';
  PrintNonFiscalString;

  // Закрываем чек
  FCash := 250.45;
  FPayByCard := 1.34;
  FPayByCredit := 3.45;
  CloseCheck;
end;


procedure TDriver1C10.PrintTestNonFiscalReceipt;
begin
  FIsFiscalCheck := False;
  FIsReturnCheck := False;
  FCancelOpenedCheck := True;
  OpenCheck;
  FTextString := '------------------------------';
  PrintNonFiscalString;
  FTextString := '01234567890123456789012345678901234567890123456789' +
    '01234567890123456789012345678901234567890123456789';
  PrintNonFiscalString;
  FTextString := '------------------------------';
  PrintNonFiscalString;
  FTextString := 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчш' +
    'щъыьэюя';
  PrintNonFiscalString;
  FTextString := '------------------------------';
  PrintNonFiscalString;
  FTextString := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  PrintNonFiscalString;
  FTextString := '------------------------------';
  PrintNonFiscalString;
  FTextString := 'Cъешь ещё этих мягких французских булок, да выпей чаю.';
  PrintNonFiscalString;
  FTextString := '------------------------------';
  PrintNonFiscalString;
  FTextString := 'Строка 1'#13'Строка 2'#13'Строка 3'#13#10'Строка 4'#13 +
    'Строка 5 012345678901234567890123456789012345678901234567890123456789';
  PrintNonFiscalString;
  FTextString := '------------------------------';
  PrintNonFiscalString;
  CloseCheck;
end;

// Тест ошибки при вызове метода CallAsFunc с неправильными параметрами
procedure TDriver1C10.TestError;
var
  Obj: ILanguageExtender ;
  RetValue: OleVariant;
  Params: Variant;
begin
  Obj := Driver as ILanguageExtender;
  Params := VarArrayCreate([0, 5], varVariant);
  Params[0] := WideString('1'); // DeviceID
  Params[1] := WordBool(True); // IsFiscalcheck
  Params[2] := WordBool(False); // IsReturnCheck
  Params[3] := WordBool(False); // CancelOpenedCheck
  Params[4] := WideString('0'); // CheckNumber [OUT] -- Ошибочный параметр
  Params[5] := Integer(0); // SessionNumber [OUT]
  AddLine(Format('CallAsFunc: 0x%.8x', [Obj.CallAsFunc(OpenCheckID,
                       RetValue, PSafeArray(TVarData(Params).VArray))]));
  FOnChange(Self);
end;

procedure TDriver1C10.OpenCashDrawer(CashDrawerID: Integer);
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.OpenCashDrawer(FDeviceID, CashDrawerID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s,%d):%s', ['OpenCashDrawer', FDeviceID,
    CashDrawerID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.LoadLogo;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.LoadLogo(FLogoValuesArray as IDispatch, FLogoFileName, FCenterLogo, FLogoSize, FAdditionalDescription);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('LoadLogo(ValuesArray:(%s), LogoFileName: %s, CenterLogo: %s, LogoSize: %d, AdditionalDesctiption: %s):%s',
    [LogoValuesArrayToStr(FLogoValuesArray), FLogoFileName, BoolToStr(FCenterLogo), FLogoSize, FAdditionalDescription, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.OpenSession;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.OpenSession(FDeviceID);
  AddLine(Format('OpenSession(%s):%s', [FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.DeviceControl;
var
  Res: Boolean;
  Rx: WideString;
begin
  FRunTime := GetTickCount;
  Res := Driver.DeviceControl(FDeviceID, HexToStr(FTxData), Rx);
  FRxData := StrToHex(Rx);
  AddLine(Format('DeviceControl(%s, Tx: "%s", Rx: "%s"):%s', [FDeviceID, FTxData, FRxData, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C10.DeviceControlHEX;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.DeviceControlHEX(FDeviceID, FTxData, FRxData);
  AddLine(Format('DeviceControl(%s, Tx: "%s", Rx: "%s"):%s', [FDeviceID, FTxData, FRxData, BoolToStr(Res)]));
  DoChange(Res);
end;

function TDriver1C10.GetDriver: IMitsu1C;
begin
  if FDriver = nil then
    FDriver := CreateOleObject('Addin.Mitsu1C') as IMitsu1C;
  Result := FDriver;
end;

procedure TDriver1C10.SetConnectionParams;
begin
  FValuesArray.Set_(C_PORT, FConnectionParams.Port);
  FValuesArray.Set_(C_SPEED, FConnectionParams.Speed);
  FValuesArray.Set_(C_USERPASSWORD, FConnectionParams.UserPassword);
  FValuesArray.Set_(C_ADMINPASSWORD, FConnectionParams.AdminPassword);
  FValuesArray.Set_(C_TIMEOUT, FConnectionParams.Timeout);
  FValuesArray.Set_(C_SERIALNUMBER, '');
  FValuesArray.Set_(C_TAX1, FConnectionParams.Tax1);
  FValuesArray.Set_(C_TAX2, FConnectionParams.Tax2);
  FValuesArray.Set_(C_TAX3, FConnectionParams.Tax3);
  FValuesArray.Set_(C_TAX4, FConnectionParams.Tax4);
  FValuesArray.Set_(C_CLOSESESSION, FConnectionParams.CloseSession);
  FValuesArray.Set_(C_ENABLELOG, FConnectionParams.EnableLog);
  FValuesArray.Set_(C_PAYNAME1, FConnectionParams.PayName1);
  FValuesArray.Set_(C_PAYNAME2, FConnectionParams.PayName2);
  FValuesArray.Set_(C_PRINTLOGO, FConnectionParams.PrintLogo);
  FValuesArray.Set_(C_LOGOSIZE, FConnectionParams.LogoSize);
  FValuesArray.Set_(C_CONNECTION_TYPE, FConnectionParams.ConnectionType);
  FValuesArray.Set_(C_COMPUTERNAME, FConnectionParams.ComputerName);
  FValuesArray.Set_(C_IPADDRESS, FConnectionParams.IPAddress);
  FValuesArray.Set_(C_TCPPORT, FConnectionParams.TCPPort);
  FValuesArray.Set_(C_PROTOCOLTYPE, FConnectionParams.ProtocolType);
  FValuesArray.Set_(C_BUFFERSTRINGS, FConnectionParams.BufferStrings);

  FLogoValuesArray.Set_(0, FConnectionParams.Port);
  FLogoValuesArray.Set_(1, FConnectionParams.Speed);
  FLogoValuesArray.Set_(2, FConnectionParams.UserPassword);
  FLogoValuesArray.Set_(3, FConnectionParams.Timeout);
  FLogoValuesArray.Set_(4, FConnectionParams.ConnectionType);
  FLogoValuesArray.Set_(5, FConnectionParams.ComputerName);
  FLogoValuesArray.Set_(6, FConnectionParams.IPAddress);
  FLogoValuesArray.Set_(7, FConnectionParams.TCPPort);
  FLogoValuesArray.Set_(8, FConnectionParams.ProtocolType);
end;

function TDriver1C10.GetSerialNumber: WideString;
begin
  Result := FValuesArray.Get(C_SERIALNUMBER);
end;

function TDriver1C10.GetDrvVersion: Integer;
begin
  Result := 0;
end;

function TDriver1C10.GetLastError(var Desc: WideString): Integer;
begin
  Result := Driver.GetLastError(Desc);
end;

function TDriver1C10.GetParameters: WideString;
begin
  raise Exception.Create('function GetParameters not supported');
end;

procedure TDriver1C10.PrintBarCode;
begin
  raise Exception.Create('function PrintBarCode not supported');
end;

procedure TDriver1C10.GetDescription;
begin
  raise Exception.Create('function GetDescription not supported');
end;

procedure TDriver1C10.GetLineLength;
begin
  raise Exception.Create('function GetLineLength not supported');
end;

procedure TDriver1C10.SetLang(Lang: Integer);
begin

end;

end.
