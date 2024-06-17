
{ Тест интерфейса в соответствии с "Требованиями к разработке драйверов для
  фискальных регистраторов" компании 1С 1.1}

unit Driver1C;

interface

uses
  // VCL
  Windows, Classes, ComObj, SysUtils, Variants, ActiveX, Types,
  // This
  LanguageExtender, StringUtils, OleArray1C, DriverParams1C;

type
  TStringEvent = procedure (Sender: TObject; const Line: WideString) of object;

  { TDriver1C }

  TDriver1C = class
  protected
    FRunTime: Cardinal;
    FOnLine: TStringEvent;
    FOnChange: TNotifyEvent;
    procedure DoChange(ARes: Boolean);
    procedure AddLine(const S: string);
  public
    FParams: TDriverParams;

    FDeviceID: WideString;
    FName: WideString;
    FQuantity: Double;
    FPrice: Double;
    FAmount: Double;
    FDepartment: Integer;
    FTax: Single;
    FIsFiscalCheck: WordBool;
    FIsReturnCheck: WordBool;
    FCancelOpenedCheck: WordBool;
    FCheckNumber: Integer;
    FSessionNumber: Integer;
    FTextString: WideString;
    FErrorDescription: WideString;
    FCash: Double;
    FPayByCard: Double;
    FPayByCredit: Double;
    FPayByCertificate: Double;
    FAdditionalDescription: WideString;
    FDemoModeIsActivated: WideString;
    FLogoValuesArray: IDispatch;
    FLogoFileName: string;
    FCenterLogo: Boolean;
    FLogoSize: Integer;
    FRxData: WideString;
    FTxData: WideString;
    FDiscountOnCheck: Double;
    FBarCode: WideString;
    FBarcodeType: WideString;
    FLineLength: Integer;

    procedure CashInOutcome; virtual; abstract;
    procedure GetLastError; overload; virtual; abstract;
    procedure Close; virtual; abstract;
    procedure CloseCheck; virtual; abstract;
    procedure DeviceTest; virtual; abstract;
    procedure GetVersion; virtual; abstract;
    procedure GetDescription; virtual; abstract;
    procedure Open; virtual; abstract;
    procedure OpenCheck; virtual; abstract;
    procedure PrintFiscalString; virtual; abstract;
    procedure PrintNonFiscalString; virtual; abstract;
    procedure PrintXReport; virtual; abstract;
    procedure PrintZReport; virtual; abstract;
    procedure CancelCheck; virtual; abstract;
    procedure CheckPrintingStatus; virtual; abstract;
    procedure ContinuePrinting; virtual; abstract;
    procedure PrintTestFiscalReceipt; virtual; abstract;
    procedure PrintTestNonFiscalReceipt; virtual; abstract;
    procedure TestError; virtual; abstract;
    procedure OpenCashDrawer(CashDrawerID: Integer); virtual; abstract;
    procedure LoadLogo; virtual; abstract;
    procedure OpenSession; virtual; abstract;
    procedure DeviceControl; virtual; abstract;
    procedure DeviceControlHEX; virtual; abstract;
    function GetLastError(var Desc: WideString): Integer; overload; virtual; abstract; 
    procedure SetConnectionParams; virtual; abstract;
    function GetSerialNumber: WideString; virtual; abstract;
    function GetDrvVersion: Integer; virtual; abstract;
    function GetParameters: WideString; virtual; abstract;
    procedure PrintBarCode; virtual; abstract;
    procedure GetLineLength; virtual; abstract;
    procedure SetLang(Lang: Integer); virtual; abstract;

    property OnLine: TStringEvent read FOnLine write FOnLine;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

{ TDriver1C }

procedure TDriver1C.AddLine(const S: string);
var
  Line: WideString;
  Hour, Min, Sec, MSec: Word;
begin
  DecodeTime(Time, Hour, Min, Sec, MSec);
  Line := Format('[%.2d:%.2d:%.2d.%.3d] ',[Hour, Min, Sec, MSec]) + S;
  if Assigned(FOnLine) then
    FOnLine(Self, Line);
end;

procedure TDriver1C.DoChange(ARes: Boolean);
var
  Err: Integer;
  Desc: WideString;
begin
  if ARes then
  begin
    AddLine(Format('Операция выполнена успешно. Время выполнения: %dмс', [FRunTime]));
    if Assigned(FOnchange) then
      FOnChange(Self);
    Exit;
  end;
  Err := GetLastError(Desc);
  AddLine(Format('Ошибка: %d %s', [Err, Desc]));
  FOnChange(Self);
  Abort;
end;

end.
