unit Driver1Cst11;

interface

uses
  // VCL
  SysUtils,
  // This
  Driver1Cst, ParamList1C, ParamList1CPage, ParamList1CGroup, ParamList1CItem,
  Param1CChoiceList, PrinterTypes, DriverError, DriverTypes, Devices1C,
  untLogger, Types1C, LogFile, AdditionalAction, TextEncoding, LangUtils;

type
  { TDriver1Cst11 }

  TDriver1Cst11 = class(TDriver1Cst)
  private
    FLogger: TLogger;

    FAdditionalActions: TAdditionalActions;
    FParamList: TParamList1C;
    procedure CreateParamList;
    function GetLogger: TLogger;
    property Logger: TLogger read GetLogger;

  public
    constructor Create;
    destructor Destroy; override;

    property ParamList: TParamList1C read FParamList;

    function Open(const ValuesArray: IDispatch; var DeviceID: WideString): WordBool; override;
    function DeviceTest(const ValuesArray: IDispatch;
      var AdditionalDescription, DemoModeIsActivated: WideString): WordBool; override;
    function PrintBarCode(const DeviceID, BarcodeType, Barcode: WideString): WordBool;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool;
    function DoAdditionalAction(const ActionName: WideString): WordBool;
    function GetAdditionalActions(var TableActions: WideString): WordBool;
    function GetLineLength(const DeviceID: WideString; var LineLength: Integer): WordBool;
    function GetParameters(var TableParameters: WideString): WordBool; virtual;
  end;

implementation

var
 ConnectionTypes: array[1..6] of Integer = (
   CT_LOCAL,
   CT_TCP,
   CT_DCOM,
   CT_ESCAPE,
   CT_EMULATOR,
   CT_TCPSOCKET);

resourcestring
  SInvalidParam = '������������ �������� ���������';


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
    RaiseError(E_INVALIDPARAM, Format('%s %s', [GetRes(@SInvalidParam), ' "Baudrate"']));
  end;
end;

function ConnectionTypeToStr(ConnectionType: Integer): WideString;
begin
  case ConnectionType of
    CT_LOCAL     : Result := '��������';
    CT_TCP       : Result := 'TCP (������ ��)';
    CT_DCOM      : Result := 'DCOM (������ ��)';
    CT_ESCAPE    : Result := 'Escape';
    CT_EMULATOR  : Result := '��������';
    CT_TCPSOCKET : Result := 'TCP socket'
  else
    RaiseError(E_INVALIDPARAM, Format('%s %s', [GetRes(@SInvalidParam), '"ConnectionType"']));
  end;
end;

{ TDriver1Cst11 }

constructor TDriver1Cst11.Create;
begin
  inherited Create;
  FParamList := TParamList1C.Create;
  FAdditionalActions := TAdditionalActions.Create;
  CreateParamList;
end;

destructor TDriver1Cst11.Destroy;
begin
  FLogger.Free;
  FParamList.Free;
  FAdditionalActions.Free;
  inherited Destroy;
end;

function TDriver1Cst11.GetLogger: TLogger;
begin
  if FLogger = nil then
    FLogger := TLogger.Create(Self.ClassName);
  Result := FLogger;
end;

procedure TDriver1Cst11.CreateParamList;
var
  Page: TParamList1CPage;
  Group: TParamList1CGroup;
  Item: TParamList1CItem;
  ChoiceListItem: TParam1CChoiceListItem;
  i: Integer;

resourcestring
  SConnectionParams = '��������� �����';

  SConnectionType = '��� �����������';
  SProtocolType = '��� ���������';
  SStandard = '�����������';
  SProtocol2 = '�������� ��� 2.0';
  SPort = '����';
  SBaudrate = '��������';
  STimeout = '�������';
  SComputerName = '��� ����������';
  SIPAddress = 'IP �����';
  STCPPort = 'TCP ����';

  SDeviceParams = '��������� ����������';
  SUserPassword = '������ ������������';
  SAdminPassword = '������ ��������������';
  SCloseSession = '��������� �����';
  SBufferStrings = '�������������� ������';
  SBarcodeFirstLine = '����� ����� ��� �������� QR Code';
  SQRCodeHeight = '������ QR Code, �����';

  SLogParams = '��������� ����';
  SEnableLog = '����� ���';

  STaxRates = '��������� ������ � ���� �����';
  STax1 = '������ 1';
  STax2 = '������ 2';
  STax3 = '������ 3';
  STax4 = '������ 4';
  SPayName1 = '��� ������. ������ 1';
  SPayName2 = '��� ������. ������ 2';
  SPayName3 = '��� ������. ������ 3';

  SPayName1DefaultValue = '����.������';
  SPayName2DefaultValue = '��������';
  SPayName3DefaultValue = '������������';

  SCodepage = '���������';
  SCodepageDef = '��� �������������';
  SCodepageRussian = '�������';
  SCodepageArmenianUnicode = '��������� UNICODE';
  SCodepageArmenianAnsi = '��������� ANSI';

begin
  // �������� ��������� �����
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SConnectionParams);
  { --- ��������� ����� --- }
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SConnectionParams); // '��������� �����';
  // ��� �����������
  Item := Group.Items.Add;
  Item.Name := 'ConnectionType';
  Item.Caption := GetRes(@SConnectionType);
  Item.Description := GetRes(@SConnectionType);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';
  for i := Low(ConnectionTypes) to High(ConnectionTypes) do
    Item.AddChoiceListItem(ConnectionTypeToStr(ConnectionTypes[i]), IntToSTr(ConnectionTypes[i]));
  // ��� ���������
  Item := Group.Items.Add;
  Item.Name := 'ProtocolType';
  Item.Caption := GetRes(@SProtocolType);
  Item.Description := GetRes(@SProtocolType);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';
  Item.AddChoiceListItem(GetRes(@SStandard), '0');
  Item.AddChoiceListItem(GetRes(@SProtocol2), '1');
  // ����
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
  //�������
  Item := Group.Items.Add;
  Item.Name := 'Timeout';
  Item.Caption := GetRes(@STimeout);
  Item.Description := GetRes(@STimeout);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '1000';
  //Computer name
  Item := Group.Items.Add;
  Item.Name := 'ComputerName';
  Item.Caption := GetRes(@SComputerName);
  Item.Description := GetRes(@SComputerName);
  Item.TypeValue := 'String';
  Item.DefaultValue := '';
  //IP �����
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

  // �������� ��������� ����������
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SDeviceParams);
  { --- ��������� ���������� --- }
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SConnectionParams);
  // ������ ������������
  Item := Group.Items.Add;
  Item.Name := 'UserPassword';
  Item.Caption := GetRes(@SUserPassword);
  Item.Description := GetRes(@SUserPassword);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '1';
  // ������ ��������������
  Item := Group.Items.Add;
  Item.Name := 'AdminPassword';
  Item.Caption := GetRes(@SAdminPassword);
  Item.Description := GetRes(@SAdminPassword);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '30';
  // ��������� �����
  Item := Group.Items.Add;
  Item.Name := 'CloseSession';
  Item.Caption := GetRes(@SCloseSession);
  Item.Description := GetRes(@SCloseSession);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';
  // �������������� ������
  Item := Group.Items.Add;
  Item.Name := 'BufferStrings';
  Item.Caption := GetRes(@SBufferStrings);
  Item.Description := GetRes(@SBufferStrings);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'True';

  // ������ QR
  Item := Group.Items.Add;
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
  Item.DefaultValue := '200';


  // �������� ��������� ������ � ���� �����
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@STaxRates);
  { --- ��������� ������ � ���� ����� --- }
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@STaxRates);
  // ������ 1
  Item := Group.Items.Add;
  Item.Name := 'Tax1';
  Item.Caption := GetRes(@STax1);
  Item.Description := GetRes(@STax1);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';
  // ������ 2
  Item := Group.Items.Add;
  Item.Name := 'Tax2';
  Item.Caption := GetRes(@STax2);
  Item.Description := GetRes(@STax2);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';
  // ������ 3
  Item := Group.Items.Add;
  Item.Name := 'Tax3';
  Item.Caption := GetRes(@STax3);
  Item.Description := GetRes(@STax3);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';
  // ������ 4
  Item := Group.Items.Add;
  Item.Name := 'Tax4';
  Item.Caption := GetRes(@STax4);
  Item.Description := GetRes(@STax4);
  Item.TypeValue := 'Number';
  Item.DefaultValue := '0';
  // ������������ ���� ������ 1
  Item := Group.Items.Add;
  Item.Name := 'PayName1';
  Item.Caption := GetRes(@SPayName1);
  Item.Description := GetRes(@SPayName1);
  Item.TypeValue := 'String';
  Item.DefaultValue := GetRes(@SPayName1DefaultValue);
  // ������������ ���� ������ 2
  Item := Group.Items.Add;
  Item.Name := 'PayName2';
  Item.Caption := GetRes(@SPayName2);
  Item.Description := GetRes(@SPayName2);
  Item.TypeValue := 'String';
  Item.DefaultValue := GetRes(@SPayName2DefaultValue);
  // ������������ ���� ������ 3
  Item := Group.Items.Add;
  Item.Name := 'PayName3';
  Item.Caption := GetRes(@SPayName3);
  Item.Description := GetRes(@SPayName3);
  Item.TypeValue := 'String';
  Item.DefaultValue := GetRes(@SPayName3DefaultValue);

  // �������� ��������� ����
  Page := FParamList.Pages.Add;
  Page.Caption := GetRes(@SLogParams);
  { --- ��������� ���� --- }
  Group := Page.Groups.Add;
  Group.Caption := GetRes(@SLogParams);
  // ������ ������������
  Item := Group.Items.Add;
  Item.Name := 'EnableLog';
  Item.Caption := GetRes(@SEnableLog);
  Item.Description := GetRes(@SEnableLog);
  Item.TypeValue := 'Boolean';
  Item.DefaultValue := 'False';

{  // �������� ������� ��������
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

function TDriver1Cst11.DeviceTest(const ValuesArray: IDispatch;
  var AdditionalDescription, DemoModeIsActivated: WideString): WordBool;
var
  ADevice: TDevice1C;
begin
  Logger.Debug('DeviceTest');
  Result := True;
  try
    ADevice := Devices.Add;
    try
      ADevice.Assign(Device);
      ADevice.DeviceTest2(ValuesArray, AdditionalDescription, DemoModeIsActivated);
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

function TDriver1Cst11.DoAdditionalAction(
  const ActionName: WideString): WordBool;
var
  Action: TAdditionalAction;
begin
  Result := True;
  try
    Action := FAdditionalActions.ItemByName(ActionName);
    if Action <> nil then
      Action.Execute(Device);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst11.GetAdditionalActions(
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

function TDriver1Cst11.GetLineLength(const DeviceID: WideString;
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

function TDriver1Cst11.GetParameters(
  var TableParameters: WideString): WordBool;
begin
  TableParameters := FParamList.ToString;
  Result := True;
end;

function TDriver1Cst11.Open(const ValuesArray: IDispatch;
  var DeviceID: WideString): WordBool;
var
  ADevice: TDevice1C;
begin
  Logger.Debug('Open' + ' ' + DeviceID);
  Result := True;
   ADevice := nil;
  try
    ADevice := Devices.Add;
    ADevice.Assign(Device);
    ADevice.Open2;
    DeviceID := IntToStr(ADevice.ID);
    SelectDevice(DeviceID);
  except
    on E: Exception do
    begin
      ADevice.Free;
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst11.PrintBarCode(const DeviceID, BarcodeType,
  Barcode: WideString): WordBool;
begin
  Result := True;
  try
    SelectDevice(DeviceID);
    Device.PrintBarCode(BarcodeType, Barcode);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

function TDriver1Cst11.SetParameter(const Name: WideString;
  Value: OleVariant): WordBool;
begin
  Result := True;
  try
    Device.SetParam(Name, Value);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
    end;
  end;
end;

end.
