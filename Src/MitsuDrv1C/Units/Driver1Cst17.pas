unit Driver1Cst17;

interface

uses
  // VCL
  SysUtils,
  // This
  Driver1Cst11, ParamList1C, ParamList1CPage, ParamList1CGroup, ParamList1CItem,
  Param1CChoiceList, PrinterTypes, DriverError, DriverTypes, Devices1C,
  untLogger, Types1C, LogFile, AdditionalAction, TextEncoding, DrvFRLib_TLB,
  VersionInfo, LangUtils, untDrvFR;

type
  { TDriver1Cst17 }

  TDriver1Cst17 = class//(TDriver1Cst11)
  private
    FAdditionalActions: TAdditionalActions;
    FDriver: IDrvFR49;
    FDevices: TDevices1C;
    FResultCode: Integer;
    FResultDescription: string;
    FLogger: TLogger;
    FDevice: TDevice1C;
    FParamList: TParamList1C;
    FParams: TDeviceParams17;
    procedure CreateParamList;
    property Logger: TLogger read FLogger;
    procedure ClearError;
    procedure HandleException(E: Exception);
    procedure SelectDevice(const DeviceID: string);

    property Device: TDevice1C read FDevice;
    property Devices: TDevices1C read FDevices;
  public
    constructor Create;
    destructor Destroy; override;
    function Close(const DeviceID: WideString): WordBool;
    function GetLastError(var ErrorDescription: WideString): Integer;
    function GetVersion: WideString;
    function DeviceTest(var AdditionalDescription, DemoModeIsActivated: WideString): WordBool;
    function DoAdditionalAction(const ActionName: WideString): WordBool;
    function GetAdditionalActions(var TableActions: WideString): WordBool;
    function GetLineLength(const DeviceID: WideString;
           var LineLength: Integer): WordBool;




    function CloseShiftFN(const DeviceID, CashierName: WideString;
      out SessionNumber, DocumentNumber: Integer): WordBool;
    function GetCurrentStatus(const DeviceID: WideString; out CheckNumber,
      SessionNumber, SessionState: Integer; out StatusParameters: WideString): WordBool;
    function GetDataKKT(const DeviceID: WideString;
      out TableParametersKKT: WideString): WordBool;

    function Open(var DeviceID: WideString): WordBool;
    function OpenShiftFN(const DeviceID, CashierName: WideString;
      out SessionNumber, DocumentNumber: Integer): WordBool;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
      const CashierName, ParametersFiscal: WideString): WordBool;
    function ProcessCheck(const DeviceID: WideString;
      const CashierName: WideString; Electronically: WordBool;
      const CheckPackage: WideString; out CheckNumber,
      SessionNumber: Integer; out FiscalSign,
      AddressSiteInspections: WideString): WordBool;
    function ProcessCorrectionCheck(const DeviceID, CashierName,
      CheckCorrectionPackage: WideString; out CheckNumber,
      SessionNumber: Integer; out FiscalSign,
      AddressSiteInspections: WideString): WordBool;
    function ReportCurrentStatusOfSettlements(
      const DeviceID: WideString): WordBool;
    function PrintTextDocument(const DeviceID, DocumentPackage: WideString): WordBool;
    function GetParameters(var TableParameters: WideString): WordBool;
    function GetAdditionalDescription: WideString;
    function SetParameter(const Name: WideString;
             Value: OleVariant): WordBool;
    function CashInOutcome(const DeviceID: WideString;
          Amount: Double): WordBool;
    function OpenCashDrawer(const DeviceID: WideString;
          CashDrawerID: Integer): WordBool;
    function PrintXReport(const DeviceID: WideString): WordBool;

  end;


implementation

uses Driver1Cst;
 var
 ConnectionTypes: array[1..6] of Integer = (
   CT_LOCAL,
   CT_TCP,
   CT_DCOM,
   CT_ESCAPE,
   CT_EMULATOR,
   CT_TCPSOCKET);

resourcestring
  SInvalidParam = 'Некорректное значение параметра';


function BaudRateToStr(BaudRate: Integer): WideString;
begin
  case BaudRate of
    BAUD_RATE_CODE_2400:   Result := '2400';
    BAUD_RATE_CODE_4800:   Result := '4800';
    BAUD_RATE_CODE_9600:   Result := '9600';
    BAUD_RATE_CODE_19200:  Result := '19200';
    BAUD_RATE_CODE_38400:  Result := '38400';
    BAUD_RATE_CODE_57600:  Result := '57600';
    BAUD_RATE_CODE_115200: Result := '115200';
    BAUD_RATE_CODE_230400: Result := '230400';
    BAUD_RATE_CODE_460800: Result := '460800';
    BAUD_RATE_CODE_921600: Result := '921600';
  else
    RaiseError(E_INVALIDPARAM, Format('%s %s', [GetRes(@SInvalidParam), '"Baudrate"']));
  end;
end;

function ConnectionTypeToStr(ConnectionType: Integer): WideString;
begin
  case ConnectionType of
    CT_LOCAL     : Result := 'Локально';
    CT_TCP       : Result := 'TCP (сервер ФР)';
    CT_DCOM      : Result := 'DCOM (сервер ФР)';
    CT_ESCAPE    : Result := 'Escape';
    CT_EMULATOR  : Result := 'Эмулятор';
    CT_TCPSOCKET : Result := 'TCP socket'
  else
    RaiseError(E_INVALIDPARAM, Format('%s %s', [GetRes(@SInvalidParam), '"ConnectionType"']));
  end;
end;

{ TDriver1Cst17 }

constructor TDriver1Cst17.Create;
begin
  inherited Create;
  FDriver := DrvFr_create;
  FParamList := TParamList1C.Create;
  CreateParamList;
  FAdditionalActions := TAdditionalActions.Create;
  TPrintTaxReportAdditionalAction.Create(FAdditionalActions);
  TPrintDepartmentReportAdditionalAction.Create(FAdditionalActions);
  FLogger := TLogger.Create(Self.ClassName);

  FDevices := TDevices1C.Create(FDriver);
  FDevices.BPOVersion := 21;
end;

destructor TDriver1Cst17.Destroy;
begin
  FLogger.Free;
  FAdditionalActions.Free;
  FParamList.Free;
  FDevices.Free;
  FDriver := nil;
  inherited Destroy;
end;


procedure TDriver1Cst17.CreateParamList;
var
  Page: TParamList1CPage;
  Group: TParamList1CGroup;
  Item: TParamList1CItem;
  ChoiceListItem: TParam1CChoiceListItem;
  i: Integer;

resourcestring
  SConnectionParams = 'Параметры связи';

  SConnectionType = 'Тип подключения';
  SProtocolType = 'Тип протокола';
  SStandard = 'Стандартный';
  SProtocol2 = 'Протокол ККТ 2.0';
  SPort = 'Порт';
  SBaudrate = 'Скорость';
  STimeout = 'Таймаут';
  SComputerName = 'Имя компьютера';
  SIPAddress = 'IP адрес';
  STCPPort = 'TCP порт';

  SDeviceParams = 'Параметры устройства';
  SAdminPassword = 'Пароль администратора';
  SCloseSession = 'Закрывать смену для программирования налоговых ставок (в случае некорректных значений)';
  SBufferStrings = 'Буферизировать строки';
  SBarcodeFirstLine = 'Номер линии для загрузки QR Code';
  SQRCodeHeight = 'Высота QR Code, точек';

  SLogParams = 'Настройка лога';
  SEnableLog = 'Вести лог';
  SLogPath = 'Путь к файлу лога';
  STaxRates = 'Налоговые ставки и типы оплат';
  STax1 = 'Наименование ставки НДС 18 %';
  STax2 = 'Наименование ставки НДС 10%';
  STax3 = 'Наименование ставки НДС 0%';
  STax4 = 'Наименование ставки БЕЗ НДС';
  STax5 = 'Наименование ставки НДС 18/118';
  STax6 = 'Наименование ставки НДС 10/110';
  SPayName1 = 'Тип безнал. оплаты 1';
  SPayName2 = 'Тип безнал. оплаты 2';
  SPayName3 = 'Тип безнал. оплаты 3';
  SCashiers = 'Кассиры';
  SCashier = 'Кассир';
  SPassword = 'Пароль кассира';
  SPayName1DefaultValue = 'ПЛАТ.КАРТОЙ';
  SPayName2DefaultValue = 'КРЕДИТОМ';
  SPayName3DefaultValue = 'СЕРТИФИКАТОМ';

  SCodepage = 'Кодировка';
  SCodepageDef = 'Нет перекодировки';
  SCodepageRussian = 'Русская';
  SCodepageArmenianUnicode = 'Армянская UNICODE';
  SCodepageArmenianAnsi = 'Армянская ANSI';
  SCodePageKazakhUnicode = 'Казахская UNICODE';
  SCodepageTurkmenUnicode = 'Туркменская UNICODE';
  SQRCodeDotWidth = 'Толщина точки QR Code (3-8)';


begin
  // СТРАНИЦА Параметры связи
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SConnectionParams);
  { --- Параметры связи --- }
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SConnectionParams); // 'Параметры связи';
  // Тип подключения
  Item := Group.Items.Add;
  Item.Name := 'ConnectionType';
  Item.Caption := GetRes(@SConnectionType);
  Item.Description := GetRes(@SConnectionType);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';
  for i := Low(ConnectionTypes) to High(ConnectionTypes) do
    Item.AddChoiceListItem(ConnectionTypeToStr(ConnectionTypes[i]), IntToSTr(ConnectionTypes[i]));
  // Тип протокола
  Item := Group.Items.Add;
  Item.Name := 'ProtocolType';
  Item.Caption := GetRes(@SProtocolType);
  Item.Description := GetRes(@SProtocolType);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';
  Item.AddChoiceListItem(GetRes(@SStandard), '0');
  Item.AddChoiceListItem(GetRes(@SProtocol2), '1');
  // Порт
  Item := Group.Items.Add;
  Item.Name := 'Port';
  Item.Caption := GetRes(@SPort);
  Item.Description := GetRes(@SPort);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '1';
  for i := 1 to 256 do
    Item.AddChoiceListItem('COM' + IntToStr(i), IntToStr(i));
  // Baudrate
  Item := Group.Items.Add;
  Item.Name := 'Baudrate';
  Item.Caption := GetRes(@SBaudrate);
  Item.Description := GetRes(@SBaudrate);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '115200';
  for i := BAUD_RATE_CODE_MIN to BAUD_RATE_CODE_MAX do
  begin
    ChoiceListItem := Item.ChoiceList.Add;
    ChoiceListItem.Name := BaudRateToStr(i);
    ChoiceListItem.Value := BaudRateToStr(i);
  end;
  //Таймаут
  Item := Group.Items.Add;
  Item.Name := 'Timeout';
  Item.Caption := GetRes(@STimeout);
  Item.Description := GetRes(@STimeout);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '3000';
  //Computer name
  Item := Group.Items.Add;
  Item.Name := 'ComputerName';
  Item.Caption := GetRes(@SComputerName);
  Item.Description := GetRes(@SComputerName);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';
  //IP адрес
  Item := Group.Items.Add;
  Item.Name := 'IPAddress';
  Item.Caption := GetRes(@SIPAddress);
  Item.Description := GetRes(@SIPAddress);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';
  //TCP Port
  Item := Group.Items.Add;
  Item.Name := 'TCPPort';
  Item.Caption := GetRes(@STCPPort);
  Item.Description := GetRes(@STCPPort);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '211';

  // СТРАНИЦА Параметры Устройства
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SDeviceParams);
  { --- Параметры устройства --- }
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SDeviceParams);
  // Пароль администратора
  Item := Group.Items.Add;
  Item.Name := 'AdminPassword';
  Item.Caption := GetRes(@SAdminPassword);
  Item.Description := GetRes(@SAdminPassword);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '30';
{  // Буферизировать строки
  Item := Group.Items.Add;
  Item.Name := 'BufferStrings';
  Item.Caption := GetRes(@SBufferStrings);
  Item.Description := GetRes(@SBufferStrings);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'True';}

  // Печать QR
  {Item := Group.Items.Add;
  Item.Name := 'BarcodeFirstLine';
  Item.Caption := GetRes(@SBarcodeFirstLine);
  Item.Description := GetRes(@SBarcodeFirstLine);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '1';
  //
  Item := Group.Items.Add;
  Item.Name := 'QRCodeHeight';
  Item.Caption := GetRes(@SQRCodeHeight);
  Item.Description := GetRes(@SQRCodeHeight);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '200';}
  Item := Group.Items.Add;
  Item.Name := 'QRCodeDotWidth';
  Item.Caption := GetRes(@SQRCodeDotWidth);
  Item.Description := GetRes(@SQRCodeDotWidth);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '5';


  // СТРАНИЦА Налоговые ставки и типы оплат
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@STaxRates);

  { --- Налоговые ставки и типы оплат --- }
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@STaxRates);
  // Закрывать смену
  Item := Group.Items.Add;
  Item.Name := 'CloseSession';
  Item.Caption := GetRes(@SCloseSession);
  Item.Description := GetRes(@SCloseSession);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'True';
{  // Ставка 1
  Item := Group.Items.Add;
  Item.Name := 'Tax1Name';
  Item.Caption := GetRes(@STax1);
  Item.Description := GetRes(@STax1);
  Item.TypeValue := 'String';
  Item.DefaultValue := 'НДС 18%';
  // Ставка 2
  Item := Group.Items.Add;
  Item.Name := 'Tax2Name';
  Item.Caption := GetRes(@STax2);
  Item.Description := GetRes(@STax2);
  Item.TypeValue := 'String';
  Item.DefaultValue := 'НДС 10%';
  // Ставка 3
  Item := Group.Items.Add;
  Item.Name := 'Tax3Name';
  Item.Caption := GetRes(@STax3);
  Item.Description := GetRes(@STax3);
  Item.TypeValue := 'String';
  Item.DefaultValue := 'НДС 0%';
  // Ставка 4
  Item := Group.Items.Add;
  Item.Name := 'Tax4Name';
  Item.Caption := GetRes(@STax4);
  Item.Description := GetRes(@STax4);
  Item.TypeValue := 'String';
  Item.DefaultValue := 'БЕЗ НДС';
  // Ставка 5
  Item := Group.Items.Add;
  Item.Name := 'Tax5Name';
  Item.Caption := GetRes(@STax5);
  Item.Description := GetRes(@STax5);
  Item.TypeValue := 'String';
  Item.DefaultValue := 'НДС 18/118';
  // Ставка 6
  Item := Group.Items.Add;
  Item.Name := 'Tax6Name';
  Item.Caption := GetRes(@STax6);
  Item.Description := GetRes(@STax6);
  Item.TypeValue := 'String';
  Item.DefaultValue := 'НДС 10/110';   }

  // Наименование типа оплаты 1
  Item := Group.Items.Add;
  Item.Name := 'PayName1';
  Item.Caption := GetRes(@SPayName1);
  Item.Description := GetRes(@SPayName1);
  Item.TypeValue := 'String';
  Item.DefaultValue := GetRes(@SPayName1DefaultValue);
  // Наименование типа оплаты 2
  Item := Group.Items.Add;
  Item.Name := 'PayName2';
  Item.Caption := GetRes(@SPayName2);
  Item.Description := GetRes(@SPayName2);
  Item.TypeValue := 'String';
  Item.DefaultValue := GetRes(@SPayName2DefaultValue);
  // Наименование типа оплаты 3
  Item := Group.Items.Add;
  Item.Name := 'PayName3';
  Item.Caption := GetRes(@SPayName3);
  Item.Description := GetRes(@SPayName3);
  Item.TypeValue := 'String';
  Item.DefaultValue := GetRes(@SPayName3DefaultValue);


  // СТРАНИЦА Настройка лога
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SLogParams);
  { --- Настройка лога --- }
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SLogParams);
  // Лог
  Item := Group.Items.Add;
  Item.Name := 'EnableLog';
  Item.Caption := GetRes(@SEnableLog);
  Item.Description := GetRes(@SEnableLog);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'LogFileName';
  Item.Caption := GetRes(@SLogPath);
  Item.Description := GetRes(@SLogPath);
  Item.TypeValue := 'String';

  Item.DefaultValue := FDriver.ComLogFile;


{  // СТРАНИЦА Кодовая страница
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SCodepage);
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SCodepage);
  Item := Group.Items.Add;
  Item.Name := 'Codepage';
  Item.Caption := GetRes(@SCodepage);
  Item.Description := GetRes(@SCodepage);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '1';
  Item.AddChoiceListItem(GetRes(@SCodepageDef), '0');
  Item.AddChoiceListItem(GetRes(@SCodepageRussian), '1');
  Item.AddChoiceListItem(GetRes(@SCodepageArmenianUnicode), '2');
  Item.AddChoiceListItem(GetRes(@SCodepageArmenianAnsi), '3');}
end;






function TDriver1Cst17.CloseShiftFN(const DeviceID, CashierName: WideString;
  out SessionNumber, DocumentNumber: Integer): WordBool;
begin
  Logger.Debug('CloseShiftFN');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);

    Device.CloseShiftFN(CashierName, SessionNumber, DocumentNumber);
  except
    on E: Exception do
    begin
      Logger.Error('CloseShiftFN Error');
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('CloseShiftFN.end');
end;

function TDriver1Cst17.GetCurrentStatus(const DeviceID: WideString;
  out CheckNumber, SessionNumber, SessionState: Integer; out StatusParameters: WideString): WordBool;
begin
  Logger.Debug('GetCurrentStatus');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.GetCurrentStatus(CheckNumber, SessionNumber, SessionState, StatusParameters);
  except
    on E: Exception do
    begin
      Logger.Error('GetCurrentStatus Error');
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('GetCurrentStatus.end');
end;

function TDriver1Cst17.GetDataKKT(const DeviceID: WideString;
  out TableParametersKKT: WideString): WordBool;
begin
  Logger.Debug('GetDataKKT');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.GetDataKKT(TableParametersKKT);
  except
    on E: Exception do
    begin
      Logger.Error('GetDataKKT Error');
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('GetDataKKT.end');
end;


function TDriver1Cst17.OpenShiftFN(const DeviceID, CashierName: WideString;
  out SessionNumber, DocumentNumber: Integer): WordBool;
begin
  Logger.Debug('OpenShiftFN');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OpenShiftFN(CashierName, SessionNumber, DocumentNumber);
  except
    on E: Exception do
    begin
      Logger.Error('OpenShiftFN Error');
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('OpenShiftFN.end');
end;

function TDriver1Cst17.OperationFN(const DeviceID: WideString;
  OperationType: Integer; const CashierName,
  ParametersFiscal: WideString): WordBool;
begin
  Logger.Debug('OperationFN');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OperationFN(OperationType, CashierName, ParametersFiscal);
  except
    on E: Exception do
    begin
      Logger.Error('OperationFN Error');
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('OperationFN.end');
end;

function TDriver1Cst17.ProcessCheck(const DeviceID: WideString;
   const CashierName: WideString;
  Electronically: WordBool; const CheckPackage: WideString;
  out CheckNumber, SessionNumber: Integer; out FiscalSign,
  AddressSiteInspections: WideString): WordBool;
begin
  Logger.Debug('ProcessCheck');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.ProcessCheck( CashierName, Electronically, CheckPackage,
                        CheckNumber, SessionNumber, FiscalSign, AddressSiteInspections);
  except
    on E: Exception do
    begin
      Logger.Error('ProcessCheck Error');
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('ProcessCheck.end');
end;

function TDriver1Cst17.ProcessCorrectionCheck(const DeviceID, CashierName,
  CheckCorrectionPackage: WideString; out CheckNumber,
  SessionNumber: Integer; out FiscalSign,
  AddressSiteInspections: WideString): WordBool;
begin
  Logger.Debug('ProcessCorrectionCheck');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.ProcessCheckCorrection(CashierName, CheckCorrectionPackage,
          CheckNumber, SessionNumber, FiscalSign, AddressSiteInspections);
  except
    on E: Exception do
    begin
      Logger.Error('ProcessCorrectionCheck Error');
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('ProcessCorrectionCheck.end');
end;

function TDriver1Cst17.ReportCurrentStatusOfSettlements(
  const DeviceID: WideString): WordBool;
begin
  Logger.Debug('ReportCurrentStatusOfSettlements');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.ReportCurrentStatusOfSettelements;
  except
    on E: Exception do
    begin
      Logger.Error('ReportCurrentStatusOfSettlements Error');
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('ReportCurrentStatusOfSettlements.end');
end;

function TDriver1Cst17.PrintTextDocument(const DeviceID,
  DocumentPackage: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.PrintTextDocument(DocumentPackage);
  except
    on E: Exception do
    begin
      Logger.Error('PrintTextDocument Error');
      Result := False;
      HandleException(E);
    end;
  end;
  Logger.Debug('PrintTextDocument.end');
end;

function TDriver1Cst17.GetParameters(
  var TableParameters: WideString): WordBool;
begin
  Logger.Debug('GetParameters');
  TableParameters := FParamList.ToString;
  Result := True;
end;

function TDriver1Cst17.Open(var DeviceID: WideString): WordBool;
var
  ADevice: TDevice1C;
begin
  Logger.Debug('Open' + ' ' + DeviceID);
  Result := True;
   ADevice := nil;
  try
    ADevice := Devices.Add;
    ADevice.Params := FParams;
    ADevice.Open3;
    DeviceID := IntToStr(ADevice.ID);
    SelectDevice(DeviceID);
  except
    on E: Exception do
    begin
      ADevice.Free;
      Result := False;
      Logger.Error('Open Error');
      HandleException(E);
    end;
  end;
  Logger.Debug('Open.end');
end;

procedure TDriver1Cst17.ClearError;
begin
  FResultCode := 0;
  FResultDescription := 'Ошибок нет';
end;


procedure TDriver1Cst17.HandleException(E: Exception);
var
  DriverError: EDriverError;
begin
  if E is EDriverError then
  begin
    DriverError := E as EDriverError;
    FResultCode := DriverError.ErrorCode;
    FResultDescription := EDriverError(E).Message;
  end
  else
  begin
    FResultCode := E_UNKNOWN;
    FResultDescription := E.Message;
  end;
  Logger.Debug('HandleException: ' + IntToStr(FResultCode) + ', ' + FResultDescription);
end;

procedure TDriver1Cst17.SelectDevice(const DeviceID: string);
var
  ID: Integer;
  ADevice: TDevice1C;
begin
  ID := 0;
  try
    ID := StrToInt(DeviceID);
  except
    RaiseError(E_INVALIDPARAM, Format('%s %s', [GetRes(@SInvalidParam), '"DeviceID"']));
  end;
  ADevice := Devices.ItemByID(ID);
  if ADevice = nil then
    RaiseError(E_INVALIDPARAM, GetRes(@SDeviceNotActive));
  if ADevice <> FDevice then
  begin
    if FDevice <> nil then
    begin
      FDevice.Disconnect;
    end;
  end;
  FDevice := ADevice;
  FDevice.ApplyDeviceParams;
end;

function TDriver1Cst17.Close(const DeviceID: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.Close;
    FDevice.Free;
    FDevice := nil;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;


function TDriver1Cst17.GetLastError(
  var ErrorDescription: WideString): Integer;
begin

  ErrorDescription := Format('%.2xh, %s', [FResultCode, FResultDescription]);
  Result := FResultCode;
  Logger.Debug('GetLastError ' + ErrorDescription);
end;


// Возвращает номер версии драйвера }
function TDriver1Cst17.GetVersion: WideString;
begin
  ClearError;
  Result := GetModuleVersion;
end;


function TDriver1Cst17.DeviceTest(var AdditionalDescription, DemoModeIsActivated: WideString): WordBool;
var
  ADevice: TDevice1C;
begin
  Logger.Debug('DeviceTest');
  Result := True;
  try
    ADevice := Devices.Add;
    try
      ADevice.Params := FParams;
      ADevice.DeviceTest2(nil, AdditionalDescription, DemoModeIsActivated);
    finally
      ADevice.Free;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
      AdditionalDescription := GetAdditionalDescription;
    end;
  end;
end;

function TDriver1Cst17.DoAdditionalAction(
  const ActionName: WideString): WordBool;
var
  Action: TAdditionalAction;
  ADevice: TDevice1C;
begin
  Logger.Debug('DeviceTest');
  Result := True;
  ADevice := Devices.Add;
  try
    ADevice.Params := FParams;
    try
      Action := FAdditionalActions.ItemByName(ActionName);
      if Action <> nil then
        Action.Execute(ADevice);
    finally
      ADevice.Free;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst17.GetAdditionalActions(
  var TableActions: WideString): WordBool;
begin
  Result := True;
  try
    TableActions := FAdditionalActions.ToString;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst17.GetLineLength(const DeviceID: WideString;
  var LineLength: Integer): WordBool;
begin
  Result := True;
  try
    SelectDevice(DeviceID);
    LineLength := Device.GetLineLength;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst17.GetAdditionalDescription: WideString;
begin
  Result := Format('%.2xh, %s', [FResultCode, FResultDescription]);
end;

function TDriver1Cst17.SetParameter(const Name: WideString;
  Value: OleVariant): WordBool;
begin
  Result := True;
  try
    if WideSameStr('ConnectionType', Name) then
      FParams.ConnectionType := Value;
    if WideSameStr('ProtocolType', Name) then
      FParams.ProtocolType := Value;
    if WideSameStr('Port', Name) then
      FParams.Port := Value;
    if WideSameStr('Baudrate', Name) then
      FParams.Baudrate := Value;
    if WideSameStr('Timeout', Name) then
      FParams.Timeout := Value;
    if WideSameStr('IPAddress', Name) then
      FParams.IPAddress := Value;
    if WideSameStr('ComputerName', Name) then
      FParams.ComputerName := Value;
    if WideSameStr('TCPPort', Name) then
      FParams.TCPPort := Value;
    if WideSameStr('AdminPassword', Name) then
      FParams.AdminPassword := Value;
    if WideSameStr('EnableLog', Name) then
      FParams.LogEnabled := (WideSameText('True', Value)) or (WideSameText('1', Value));
    if WideSameStr('LogFileName', Name) then
    begin
      Logger.Debug('LogFName = ' + Value);
      FParams.LogFileName := Value;
    end;

    if WideSameStr('CloseSession', Name) then
      FParams.CloseSession := WideSameText(Value, 'True');
    if WideSameStr('PayName1', Name) then
      FParams.Paynames[1] := Value;
    if WideSameStr('PayName2', Name) then
      FParams.Paynames[2] := Value;
    if WideSameStr('PayName3', Name) then
      FParams.Paynames[3] := Value;


    //if WideSameStr('Codepage', Name) then
    //FCodepage := Value;
    {if WideSameStr('BarcodeFirstLine', Name) then
      FParams.BarcodeFirstLine := Value;
    if WideSameStr('QRCodeHeight', Name) then
      FParams.QRCodeHeight := Value;}
    if WideSameStr('QRCodeDotWidth', Name) then
      FParams.QRCodeDotWidth := Value;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;


function TDriver1Cst17.CashInOutcome(const DeviceID: WideString;
  Amount: Double): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.CashInOutcome(Amount);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst17.OpenCashDrawer(const DeviceID: WideString;
  CashDrawerID: Integer): WordBool;
begin
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OpenCashDrawer(CashDrawerID);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst17.PrintXReport(const DeviceID: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.PrintXReport;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;



end.
