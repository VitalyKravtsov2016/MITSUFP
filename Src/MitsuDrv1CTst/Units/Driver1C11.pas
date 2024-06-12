
{ Тест интерфейса в соответствии с "Требованиями к разработке драйверов для
  фискальных регистраторов" компании 1С 1.1}

unit Driver1C11;

interface

uses
  // VCL
  Windows, Classes, ComObj, SysUtils, Variants, ActiveX, Types,
  // This
  AddIn1CInterface, MitsuLib_TLB, MitsuDrv1CTst_TLB, StringUtils,
  untTypes, Driver1C;

type
  { TDriver1C11 }

  TDriver1C11 = class(TDriver1C)
  private
    FDriver: IMitsu1C11;
    function GetDriver: IMitsu1C11;
    property Driver: IMitsu1C11 read GetDriver;
  public
    // IDriver1C
    procedure CashInOutcome; override;
    procedure Close; override;
    procedure CloseCheck; override;
    procedure DeviceTest; override;
    procedure GetLastError; override;
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
    procedure SetConnectionParams; override;
    function GetSerialNumber: WideString; override;
    function GetDrvVersion: Integer; override;
    function GetLastError(var Desc: WideString): Integer; override;
    function GetParameters: WideString; override;
    procedure PrintBarCode; override;
    procedure GetDescription; override;
    procedure GetLineLength; override;
    procedure SetLang(Lang: Integer); override;
  end;

implementation

{ TDriver1C11 }

procedure TDriver1C11.CancelCheck;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.CancelCheck(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s):%s', ['CancelCheck', FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C11.CashInOutcome;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.CashInOutcome(FDeviceID, FAmount);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s, %.2f):%s', ['CashInOutcome', FDeviceID, FAmount, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C11.CheckPrintingStatus;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.CheckPrintingStatus(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s):%s', ['CheckPrintingStatus', FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
//  raise Exception.Create('function "CheckPrintingStatus" not supported');
end;

procedure TDriver1C11.Close;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.Close(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s):%s', ['Close', FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C11.CloseCheck;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.CloseCheck(FDeviceID, FCash, FPayByCard, FPayByCredit, FPayByCertificate);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s, Cash:%.2f, PayByCard:%.2f, PayByCredit:%.2f):%s',
    ['CloseCheck', FDeviceID, FCash, FPayByCard, FPayByCredit, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C11.ContinuePrinting;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.ContinuePrinting(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('ContinuePrinting(%s):%s',
    [FAdditionalDescription, BoolToStr(Res)]));
  DoChange(Res);

//  raise Exception.Create('function "ContinuePrinting" not supported');
end;

procedure TDriver1C11.DeviceTest;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.DeviceTest(FAdditionalDescription, FDemoModeIsActivated);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('DeviceTest(%s):%s',
    [FAdditionalDescription, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C11.GetLastError;
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

procedure TDriver1C11.GetVersion;
var
  S: string;
begin
  FRunTime := GetTickCount;
  S := Driver.GetVersion;
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s:%s', ['GetVersion', S]));
  DoChange(True);
end;

procedure TDriver1C11.Open;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.Open(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('Open(DeviceID = %s):%s',
    [FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C11.OpenCheck;
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

procedure TDriver1C11.PrintFiscalString;
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

procedure TDriver1C11.PrintNonFiscalString;
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

procedure TDriver1C11.PrintXReport;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.PrintXReport(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s):%s', ['PrintXReport', FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C11.PrintZReport;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.PrintZReport(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s):%s', ['PrintZReport', FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;


function TDriver1C11.GetDriver: IMitsu1C11;
begin
  if FDriver = nil then
  begin
    FDriver := CreateOleObject('Addin.Mitsu1C11') as IMitsu1C11;
  end;
  Result := FDriver;
end;

procedure TDriver1C11.PrintTestFiscalReceipt;
var
  i: Integer;
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
  FTextString := '------------------------------';
  PrintNonFiscalString;

  // Позиция 1
  FName := 'Продукт 1';
  FQuantity := 1.123;
  FPrice := 34.15;
  FAmount := FPrice * FQuantity - 5.45; // Скидка 5.45
  FDepartment := 1;
  FTax := FConnectionParams.Tax1;
  PrintFiscalString;

  FTextString := '------------------------------';
  PrintNonFiscalString;

  // Позиция 2
  FName := 'Продукт 2';
  FQuantity := 2.432;
  FPrice := 4.35;
  FAmount := FPrice * FQuantity + 1.23; // Надбавка 1.23
  FDepartment := 2;
  FTax := FConnectionParams.Tax2;
  PrintFiscalString;

  FTextString := '------------------------------';
  PrintNonFiscalString;

  // Позиция 3
  FName := 'Продукт 3';
  FQuantity := 7.812;
  FPrice := 0.15;
  FAmount := FPrice * FQuantity - 0.12; // Скидка 0.12
  FDepartment := 3;
  FTax := FConnectionParams.Tax3;
  PrintFiscalString;

  FTextString := '------------------------------';
  PrintNonFiscalString;

  // Позиция 4
  FName := 'Продукт 4'#13'Строка 2'#13#10'Строка 3';
  FQuantity := 3.512;
  FPrice := 12.75;
  FAmount := FPrice * FQuantity + 1.2; // Надбавка 1.2
  FDepartment := 4;
  FTax := FConnectionParams.Tax4;
  PrintFiscalString;

  FTextString := '------------------------------';
  PrintNonFiscalString;

  // Позиция 5
  FName := 'Продукт 5 01234567890123456789012345678901234567890123456789' +
    '01234567890123456789012345678901234567890123456789' +
    'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя';
  FQuantity := 1.123;
  FPrice := 34.15;
  FAmount := FPrice * FQuantity; // Без скидки
  FDepartment := 5;
  FTax := 0;
  PrintFiscalString;

  FTextString := '------------------------------';
  PrintNonFiscalString;

  // Закрываем чек
  FCash := 250.45;
  FPayByCard := 1.34;
  FPayByCredit := 3.45;
  CloseCheck;
end;


procedure TDriver1C11.PrintTestNonFiscalReceipt;
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

procedure TDriver1C11.TestError;
begin
  raise Exception.Create('function "TestError" not supported');
end;

procedure TDriver1C11.OpenCashDrawer(CashDrawerID: Integer);
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.OpenCashDrawer(FDeviceID);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('%s(%s,%d):%s', ['OpenCashDrawer', FDeviceID,
    CashDrawerID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C11.LoadLogo;
begin
  raise Exception.Create('function "LoadLogo" not supported');
end;

procedure TDriver1C11.OpenSession;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.OpenShift(FDeviceID);
  AddLine(Format('OpenShift(%s):%s', [FDeviceID, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C11.DeviceControl;
begin
  raise Exception.Create('function "DeviceControl" not supported');
end;

procedure TDriver1C11.DeviceControlHEX;
begin
  raise Exception.Create('function "DeviceControlHEX" not supported');
end;

procedure TDriver1C11.SetConnectionParams;
begin
  Driver.SetParameter('Port', FConnectionParams.Port);
  Driver.SetParameter('ConnectionType', FConnectionParams.ConnectionType);
  Driver.SetParameter('Baudrate', FConnectionParams.Speed);
  Driver.SetParameter('Timeout', FConnectionParams.Timeout);
  Driver.SetParameter('ComputerName', FConnectionParams.ComputerName);
  Driver.SetParameter('IPAddress', FConnectionParams.IPAddress);
  Driver.SetParameter('TCPPort', FConnectionParams.TCPPort);
  Driver.SetParameter('UserPassword', FConnectionParams.UserPassword);
  Driver.SetParameter('AdminPassword', FConnectionParams.AdminPassword);
  Driver.SetParameter('EnableLog', FConnectionParams.EnableLog);
  Driver.SetParameter('CloseSession', FConnectionParams.CloseSession);
  Driver.SetParameter('Tax1', FConnectionParams.Tax1);
  Driver.SetParameter('Tax2', FConnectionParams.Tax2);
  Driver.SetParameter('Tax3', FConnectionParams.Tax3);
  Driver.SetParameter('Tax4', FConnectionParams.Tax4);
  Driver.SetParameter('PayName1', FConnectionParams.PayName1);
  Driver.SetParameter('PayName2', FConnectionParams.PayName2);
  Driver.SetParameter('PayName3', FConnectionParams.PayName3);
  Driver.SetParameter('ProtocolType', FConnectionParams.ProtocolType);
  Driver.SetParameter('BufferStrings', FConnectionParams.BufferStrings);
  Driver.SetParameter('BarcodeFirstLine', FConnectionParams.BarcodeFirstLine);
  Driver.SetParameter('QRCodeHeight', FConnectionParams.QRCodeHeight);
end;

function TDriver1C11.GetSerialNumber: WideString;
begin
  Result := '';
end;

function TDriver1C11.GetDrvVersion: Integer;
begin
  Result := 1;
end;

function TDriver1C11.GetLastError(var Desc: WideString): Integer;
begin
  Result := Driver.GetLastError(Desc);
end;

function TDriver1C11.GetParameters: WideString;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.GetParameters(Result);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('GetParameters: %s', [ BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C11.PrintBarCode;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.PrintBarCode(FDeviceID, FBarcodeType, FBarCode);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('PrintBarCode(%s,%s, %s):%s', [FDeviceID,
    FBarcodeType, FBarCode, BoolToStr(Res)]));
  DoChange(Res);
end;
 
procedure TDriver1C11.GetDescription;
var
  Res: Boolean;
  Name, Description, EquipmentType: WideString;
  InterfaceRevision: Integer;
  IntegrationLibrary, MainDriverInstalled: WordBool;
  GetDownloadUrl: WideString;
begin
  FRunTime := GetTickCount;
  Res := Driver.GetDescription(Name, Description, EquipmentType,
    InterfaceRevision, IntegrationLibrary, MainDriverInstalled, GetDownloadUrl);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('GetDescription: Name:%s; Description:%s; EquipmentType:%s; ' +
  'InterfaceRevision:%d; IntegrationLibrary:%s; MainDriverInstalled:%s; ' +
  'GetDownloadUrl:%s; Result:%s' , [Name, Description, EquipmentType, InterfaceRevision,
  BoolToStr(IntegrationLibrary), BoolToStr(MainDriverInstalled), GetDownloadUrl, BoolToStr(Res)]));
  DoChange(True);
end;

procedure TDriver1C11.GetLineLength;
var
  Res: Boolean;
begin
  FRunTime := GetTickCount;
  Res := Driver.GetLineLength(FDeviceID, FLineLength);
  FRunTime := GetTickCount - FRunTime;
  AddLine(Format('GetLineLength(%s, %d):%s', [FDeviceID,
    FLineLength, BoolToStr(Res)]));
  DoChange(Res);
end;

procedure TDriver1C11.SetLang(Lang: Integer);
begin
  if Lang = 0 then
    (Driver as ILanguageExtender).SetLocale('rus_RUS')
  else
    (Driver as ILanguageExtender).SetLocale('en_US')
end;

end.
