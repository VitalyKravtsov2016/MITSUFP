unit Driver1Cst22;

interface

uses
  // VCL
  SysUtils,
  // This
  MitsuDrv_1C;

type
  { TDriver1Cst22 }

  TDriver1Cst22 = class
  private
    FDriver: TMitsuDrv1C;
    function GetDriver: TMitsuDrv1C;
    property Driver: TMitsuDrv1C read GetDriver;
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




    function CloseShift(const DeviceID, InputParameters: WideString;
       var OutputParameters: WideString; var SessionNumber,DocumentNumber: Integer): WordBool;
    function GetCurrentStatus(const DeviceID: WideString; out CheckNumber,
      SessionNumber, SessionState: Integer; out StatusParameters: WideString): WordBool;
    function GetDataKKT(const DeviceID: WideString;
      out TableParametersKKT: WideString): WordBool;

    function Open(var DeviceID: WideString): WordBool;
    function OpenShift(const DeviceID, InputParameters: WideString;
                         var OutputParameters: WideString; var SessionNumber,
                         DocumentNumber: Integer): WordBool;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
           const ParametersFiscal: WideString): WordBool;
    function ProcessCheck(const DeviceID: WideString;
      const CashierName: WideString; Electronically: WordBool;
      const CheckPackage: WideString; out CheckNumber,
      SessionNumber: Integer; out FiscalSign,
      AddressSiteInspections: WideString): WordBool;
    function ProcessCorrectionCheck(const DeviceID,
      CheckCorrectionPackage: WideString; out CheckNumber,
      SessionNumber: Integer; out FiscalSign,
      AddressSiteInspections: WideString): WordBool;
    function ReportCurrentStatusOfSettlements(
      const DeviceID: WideString; InputParameters: WideString; var OutputParameters: WideString): WordBool;
    function PrintTextDocument(const DeviceID, DocumentPackage: WideString): WordBool;
    function GetParameters(var TableParameters: WideString): WordBool;
    function GetAdditionalDescription: WideString;
    function SetParameter(const Name: WideString;
             Value: OleVariant): WordBool;
    function CashInOutcome(const DeviceID: WideString;
          Amount: Double; const InputParameters: WideString): WordBool;
    function OpenCashDrawer(const DeviceID: WideString;
          CashDrawerID: Integer): WordBool;
    function PrintXReport(const DeviceID: WideString): WordBool;
    function CloseSessionRegistrationKM(const DeviceID: WideString): WordBool;
    function ExecuteCheckKM(const DeviceID, ControlMarks: WideString;
      var CheckResults: WideString): WordBool;
    function OpenSessionRegistrationKM(const DeviceID: WideString;
       SessionRegistrationParameters: WideString): WordBool;

  end;


implementation

{ TDriver1Cst22 }

constructor TDriver1Cst22.Create;
begin
  inherited Create;
  FDriver := TMitsuDrv1C.Create;
  FLogger := TLogFile.Create;
  Logger.Debug('Create');
end;

destructor TDriver1Cst22.Destroy;
begin
  FDriver.Free;
  FLogger := nil;
  inherited Destroy;
end;


procedure TDriver1Cst22.CreateParamList;
var
  Page: TParamList1CPage;
  Group: TParamList1CGroup;
  Item: TParamList1CItem;
  ChoiceListItem: TParam1CChoiceListItem;
  i: Integer;

resourcestring
  SConnectionParams = 'Параметры связи';
  SConnectionType = 'Тип подключения';
  SPort = 'Порт';
  SBaudrate = 'Скорость';
  STimeout = 'Таймаут';
  SIPAddress = 'IP адрес';
  STCPPort = 'TCP порт';

  SDeviceParams = 'Параметры устройства';
  SAdminPassword = 'Пароль администратора';
  SCloseSession = 'Закрывать смену для программирования налоговых ставок (в случае некорректных значений)';
  SBufferStrings = 'Буферизировать строки';
  SBarcodeFirstLine = 'Номер линии для загрузки QR Code';
  SQRCodeHeight = 'Высота QR Code, точек';
  SQRCodeDotWidth = 'Толщина точки QR Code (3-8)';

  SReceiptFormat = 'Формат чека';
  SEnablePaymentSignPrint = 'Печатать признак и способ расчета (ФФД 1.05)';
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

  SOrangeData = 'Orange Data';
  SODEnabled = 'Включить передачу данных в Orange Data';
  SODTaxOSN = 'ОСН';
  SODTaxUSND = 'УСН доход';
  SODTaxUSNDMR = 'УСН доход минус расход';
  SODTaxENVD = 'ЕНВД';
  SODTaxESN = 'ЕСН';
  SODTaxPSN = 'ПСН';

  SODTax = 'Системы налогообложения';
  SODServerURL = 'URL сервера';
  SODINN = 'ИНН';
  SODGroup = 'Группа';
  SODCertFileName = 'Путь к файлу клиентского сертификата (.crt)';
  SODKeyFileName = 'Путь к файлу клиентского ключа (.key)';
  SODSignKeyFileName = 'Путь к файлу ключа для подписи запросов (.pem)';
  SODKeyName = 'Название ключа для проверки подписи (опционально)';
  SODRetryCount = 'Количество попыток подтверждения документа';
  SODRetryTimeout = 'Время между попытками подтверждения документа, сек.';
  SItemnameLength = 'Кол-во используемых символов наименования товара (0 - использовать целиком)';
  SCheckFontNumber = 'Номер шрифта тела чека';


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
{  Item := Group.Items.Add;
  Item.Name := 'BarcodeFirstLine';
  Item.Caption := GetRes(@SBarcodeFirstLine);
  Item.Description := GetRes(@SBarcodeFirstLine);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '1';}
  //
  {Item := Group.Items.Add;
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


  // СТРАНИЦА ФОРМАТ ЧЕКА
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SReceiptFormat);
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SReceiptFormat);
  Item := Group.Items.Add;
  Item.Name := 'EnablePaymentSignPrint';
  Item.Caption := GetRes(@SEnablePaymentSignPrint);
  Item.Description := GetRes(@SEnablePaymentSignPrint);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'True';

  Item := Group.Items.Add;
  Item.Name := 'ItemNameLength';
  Item.Caption := GetRes(@SItemNameLength);
  Item.Description := GetRes(@SItemNameLength);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';

  Item := Group.Items.Add;
  Item.Name := 'CheckFontNumber';
  Item.Caption := GetRes(@SCheckFontNumber);
  Item.Description := GetRes(@SCheckFontNumber);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '1';


  // Orange data
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SOrangeData);
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SOrangeData);

  Item := Group.Items.Add;
  Item.Name := 'ODEnabled';
  Item.Caption := GetRes(@SODEnabled);
  Item.Description := GetRes(@SODEnabled);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'ODServerURL';
  Item.Caption := GetRes(@SODServerURL);
  Item.Description := GetRes(@SODServerURL);
  Item.TypeValue := 'String';
  Item.DefaultValue := 'https://apip.orangedata.ru:2443/api/v2/';

  Item := Group.Items.Add;
  Item.Name := 'ODINN';
  Item.Caption := GetRes(@SODINN);
  Item.Description := GetRes(@SODINN);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODGroup';
  Item.Caption := GetRes(@SODGroup);
  Item.Description := GetRes(@SODGroup);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODCertFileName';
  Item.Caption := GetRes(@SODCertFileName);
  Item.Description := GetRes(@SODCertFileName);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODKeyFileName';
  Item.Caption := GetRes(@SODKeyFileName);
  Item.Description := GetRes(@SODKeyFileName);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODSignKeyFileName';
  Item.Caption := GetRes(@SODSignKeyFileName);
  Item.Description := GetRes(@SODSignKeyFileName);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODKeyName';
  Item.Caption := GetRes(@SODKeyName);
  Item.Description := GetRes(@SODKeyName);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';

  Item := Group.Items.Add;
  Item.Name := 'ODRetryCount';
  Item.Caption := GetRes(@SODRetryCount);
  Item.Description := GetRes(@SODRetryCount);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '10';

  Item := Group.Items.Add;
  Item.Name := 'ODRetryTimeout';
  Item.Caption := GetRes(@SODRetryTimeout);
  Item.Description := GetRes(@SODRetryTimeout);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '2';


  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SODTax);

  Item := Group.Items.Add;
  Item.Name := 'ODTaxOSN';
  Item.Caption := GetRes(@SODTaxOSN);
  Item.Description := GetRes(@SODTaxOSN);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'True';

  Item := Group.Items.Add;
  Item.Name := 'ODTaxUSND';
  Item.Caption := GetRes(@SODTaxUSND);
  Item.Description := GetRes(@SODTaxUSND);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'ODTaxUSNDMR';
  Item.Caption := GetRes(@SODTaxUSNDMR);
  Item.Description := GetRes(@SODTaxUSNDMR);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'ODTaxENVD';
  Item.Caption := GetRes(@SODTaxENVD);
  Item.Description := GetRes(@SODTaxENVD);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

  Item := Group.Items.Add;
  Item.Name := 'ODTaxESN';
  Item.Caption := GetRes(@SODTaxESN);
  Item.Description := GetRes(@SODTaxESN);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';


  Item := Group.Items.Add;
  Item.Name := 'ODTaxPSN';
  Item.Caption := GetRes(@SODTaxPSN);
  Item.Description := GetRes(@SODTaxPSN);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';


  {SODServerURL = 'URL сервера';
  SODINN = 'ИНН';
  SODGroup = 'Группа';
  SODCertFileName = 'Путь к файлу клиентского сертификата (.crt)';
  SODKeyFileName = 'Путь к файлу клиентского ключа (.key)';
  SODSignKeyFileName = 'Путь к файлу ключа для подписи запросов (.pem)';
  SODKeyName = 'Название ключа для проверки подписи (опционально)';
  SODRetryCount = 'Количество попыток подтверждения документа';
  SODRetryTimeout = 'Время между попытками подтверждения документа, сек.';
}










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
///////////////////////////////////////////////////////////
// Возвращает номер версии драйвера }
function TDriver1Cst22.GetVersion: WideString;
begin
  ClearError;
  Result := GetModuleVersion;
end;

function TDriver1Cst22.GetLastError(
  var ErrorDescription: WideString): Integer;
begin
  ErrorDescription := Format('%.2xh, %s', [FResultCode, FResultDescription]);
  Result := FResultCode;
  Logger.Debug('GetLastError ' + ErrorDescription);
end;

function TDriver1Cst22.GetParameters(
  var TableParameters: WideString): WordBool;
begin
  Logger.Debug('GetParameters');
  TableParameters := FParamList.ToString;
  Result := True;
end;

function TDriver1Cst22.SetParameter(const Name: WideString;
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
      FParams.CloseSession := WideSameText(Value, 'True') or (WideSameText('1', Value));
    if WideSameStr('PayName1', Name) then
      FParams.Paynames[1] := Value;
    if WideSameStr('PayName2', Name) then
      FParams.Paynames[2] := Value;
    if WideSameStr('PayName3', Name) then
      FParams.Paynames[3] := Value;


    //if WideSameStr('Codepage', Name) then
    //FCodepage := Value;
{    if WideSameStr('BarcodeFirstLine', Name) then
      FParams.BarcodeFirstLine := Value;
    if WideSameStr('QRCodeHeight', Name) then
      FParams.QRCodeHeight := Value;}
    if WideSameStr('QRCodeDotWidth', Name) then
      FParams.QRCodeDotWidth := Value;

    if WideSameStr('EnablePaymentSignPrint', Name) then
      FParams.EnablePaymentSignPrint := (WideSameText('True', Value)) or (WideSameText('1', Value));

    if WideSameStr('ODEnabled', Name) then
      FParams.ODEnabled :=( WideSameText('True', Value)) or (WideSameText('1', Value));
    if WideSameStr('ODServerURL', Name) then
      FParams.ODServerURL := Value;

    if WideSameStr('ODINN', Name) then
      FParams.ODINN := Value;

    if WideSameStr('ODGroup', Name) then
      FParams.ODGroup := Value;

    if WideSameStr('ODCertFileName', Name) then
      FParams.ODCertFileName := Value;

    if WideSameStr('ODKeyFileName', Name) then
      FParams.ODKeyFileName := Value;

    if WideSameStr('ODSignKeyFileName', Name) then
      FParams.ODSignKeyFileName := Value;

    if WideSameStr('ODKeyName', Name) then
      FParams.ODKeyName := Value;

    if WideSameStr('ODRetryCount', Name) then
      FParams.ODRetryCount := Value;

    if WideSameStr('ODRetryTimeout', Name) then
      FParams.ODRetryTimeout := Value;

    if WideSameStr('ItemNameLength', Name) then
      FParams.ItemNameLength := Value;

    if WideSameStr('CheckFontNumber', Name) then
      FParams.CheckFontNumber := Value;


  if WideSameStr('ODTaxOSN', Name) then
      FParams.ODTaxOSN := Value;

  if WideSameStr('ODTaxUSND', Name) then
      FParams.ODTaxUSND := Value;

  if WideSameStr('ODTaxUSNDMR', Name) then
      FParams.ODTaxUSNDMR := Value;

  if WideSameStr('ODTaxENVD', Name) then
      FParams.ODTaxENVD := Value;

  if WideSameStr('ODTaxESN', Name) then
      FParams.ODTaxESN := Value;

  if WideSameStr('ODTaxPSN', Name) then
      FParams.ODTaxPSN := Value;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst22.Open(var DeviceID: WideString): WordBool;
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

function TDriver1Cst22.Close(const DeviceID: WideString): WordBool;
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

function TDriver1Cst22.DeviceTest(var AdditionalDescription, DemoModeIsActivated: WideString): WordBool;
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

function TDriver1Cst22.GetAdditionalActions(
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

function TDriver1Cst22.DoAdditionalAction(
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

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
// 01

function TDriver1Cst22.GetDataKKT(const DeviceID: WideString;
  out TableParametersKKT: WideString): WordBool;
begin
  Logger.Debug('GetDataKKT ' + DeviceID);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.GetDataKKT22(TableParametersKKT);
    Logger.Debug('TableParametersKKT  ' + TableParametersKKT);
  except
    on E: Exception do
    begin
      Logger.Error('GetDataKKT Error');
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst22.OperationFN(const DeviceID: WideString; OperationType: Integer;
      const ParametersFiscal: WideString): WordBool;
begin
  Logger.Debug('OperationFN');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OperationFN22(OperationType, ParametersFiscal);
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


function TDriver1Cst22.CloseShift(const DeviceID, InputParameters: WideString;
      var OutputParameters: WideString; var SessionNumber,DocumentNumber: Integer): WordBool;
begin
  Logger.Debug('CloseShift');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.CloseShiftFN22(InputParameters, OutputParameters, SessionNumber, DocumentNumber);
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

function TDriver1Cst22.GetCurrentStatus(const DeviceID: WideString;
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

function TDriver1Cst22.OpenShift(const DeviceID, InputParameters: WideString;
                         var OutputParameters: WideString; var SessionNumber,
                         DocumentNumber: Integer): WordBool;
begin
  Logger.Debug('OpenShift');
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OpenShiftFN22(InputParameters, OutputParameters, SessionNumber, DocumentNumber);
  except
    on E: Exception do
    begin
      Logger.Error('OpenShift Error');
      Result := False;
      HandleException(E);
    end;
  end;
end;


function TDriver1Cst22.ProcessCheck(const DeviceID: WideString;
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

function TDriver1Cst22.ProcessCorrectionCheck(const DeviceID,
  CheckCorrectionPackage: WideString; out CheckNumber,
  SessionNumber: Integer; out FiscalSign,
  AddressSiteInspections: WideString): WordBool;
begin
  Logger.Debug('ProcessCorrectionCheck');
  Logger.Debug('Package: ' + CheckCorrectionPackage);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.ProcessCheckCorrection22(CheckCorrectionPackage,
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

function TDriver1Cst22.ReportCurrentStatusOfSettlements(
      const DeviceID: WideString; InputParameters: WideString; var OutputParameters: WideString): WordBool;
begin
  Logger.Debug('ReportCurrentStatusOfSettlements ' + InputParameters);
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.ReportCurrentStatusOfSettelements22(InputParameters, OutputParameters);
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

function TDriver1Cst22.PrintTextDocument(const DeviceID,
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


procedure TDriver1Cst22.ClearError;
begin
  FResultCode := 0;
  FResultDescription := 'Ошибок нет';
end;


procedure TDriver1Cst22.HandleException(E: Exception);
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

procedure TDriver1Cst22.SelectDevice(const DeviceID: string);
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

function TDriver1Cst22.GetLineLength(const DeviceID: WideString;
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

function TDriver1Cst22.GetAdditionalDescription: WideString;
begin
  Result := Format('%.2xh, %s', [FResultCode, FResultDescription]);
end;


function TDriver1Cst22.CashInOutcome(const DeviceID: WideString;
  Amount: Double; const InputParameters: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.CashInOutcome22(Amount, InputParameters);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst22.OpenCashDrawer(const DeviceID: WideString;
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

function TDriver1Cst22.PrintXReport(const DeviceID: WideString): WordBool;
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


function TDriver1Cst22.CloseSessionRegistrationKM(
  const DeviceID: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.CloseSessionRegistrationKM;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst22.ExecuteCheckKM(const DeviceID,
  ControlMarks: WideString; var CheckResults: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.ExecuteCheckKM(ControlMarks, CheckResults);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst22.OpenSessionRegistrationKM(
  const DeviceID: WideString;
  SessionRegistrationParameters: WideString): WordBool;
begin
  ClearError;
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.OpenSessionRegistrationKM(SessionRegistrationParameters);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

end.
