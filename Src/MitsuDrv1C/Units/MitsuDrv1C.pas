unit MitsuDrv1C;

interface

uses
  // VCL
  Classes, SysUtils, XMLDoc, XMLIntf,
  // This
  MitsuDrv, ByteUtils, Types1C_1, DriverError;

type
  { TDevice }

  TDevice = class(TCollectionItem)
  private
    FID: Integer;
    FParams: TMitsuParams;
  public
    property ID: Integer read FID;
    property Params: TMitsuParams read FParams;
  end;

  { TDevices }

  TDevices = class(TCollection)
  private
    function GetFreeID: Integer;
    function ItemByID(ID: Integer): TDevice;
    function GetItem(Index: Integer): TDevice;
  public
    property Items[Index: Integer]: TDevice read GetItem; default;
  end;

  { TMitsuDrv1C }

  TMitsuDrv1C = class
  private
    FDevice: TDevice;
    FDevices: TDevices;
    FDriver: TMitsuDrv;
    FLogger: Variant; // !!!
    FReader: T1CXmlReaderWriter;
    FResultCode: Integer;
    FResultDescription: string;

    procedure ClearError;
    procedure HandleException(E: Exception);
    procedure SelectDevice(const DeviceID: string);
    procedure ReadParametersKKT(Params: TParametersKKT);
  public
    constructor Create;
    destructor Destroy; override;

    function GetDataKKT(const DeviceID: WideString;
      var TableParametersKKT: WideString): WordBool;

    function OperationFN(const DeviceID: WideString; OperationType: Integer;
      const ParametersFiscal: WideString): WordBool;

    property Logger: Variant read FLogger;
    property Driver: TMitsuDrv read FDriver;
  end;

implementation

{ TMitsuDrv1C }

constructor TMitsuDrv1C.Create;
begin
  inherited Create;
  FDriver := TMitsuDrv.Create;
  FReader := T1CXmlReaderWriter.Create;
end;

destructor TMitsuDrv1C.Destroy;
begin
  FReader.Free;
  FDriver.Free;
  inherited Destroy;
end;

procedure TMitsuDrv1C.ClearError;
begin
  FResultCode := 0;
  FResultDescription := 'Ошибок нет';
end;

procedure TMitsuDrv1C.HandleException(E: Exception);
var
  DriverError: EDriverError;
begin
  if E is EDriverError then
  begin
    DriverError := E as EDriverError;
    FResultCode := DriverError.Code;
    FResultDescription := EDriverError(E).Message;
  end
  else
  begin
    //FResultCode := E_UNKNOWN; !!!
    FResultDescription := E.Message;
  end;
  Logger.Error('HandleException: ' + IntToStr(FResultCode) + ', ' + FResultDescription);
end;

procedure TMitsuDrv1C.SelectDevice(const DeviceID: string);
var
  ID: Integer;
  Device: TDevice;
begin
  Logger.Debug('SelectDevice DeviceID = ' + DeviceID);
  ID := 0;
  try
    ID := StrToInt(DeviceID);
  except
    //RaiseError(E_INVALIDPARAM, Format('%s %s', [GetRes(@SInvalidParam), '"DeviceID"'])); !!!
  end;

  Device := FDevices.ItemByID(ID);
  if Device = nil then
  begin
    Logger.Error(Format('Device "%s"  not found', [DeviceID]));
    //RaiseError(E_INVALIDPARAM, GetRes(@SDeviceNotActive));
  end;

  if Device <> FDevice then
  begin
    Driver.Disconnect;
    Driver.Params := Device.Params;
    FDevice := Device;
  end;
  Logger.Debug('SelectDevice.end');
end;

procedure TMitsuDrv1C.ReadParametersKKT(Params: TParametersKKT);
var
  Version: TMTSVersion;
  RegParams: TMTSRegParams;
begin
  Driver.Check(Driver.ReadRegParams(RegParams));
  Driver.Check(Driver.ReadDeviceVersion(Version));

  // //Регистрационный номер ККТ
  Params.KKTNumber := RegParams.T1037;
  // Заводской номер ККТ
  Params.KKTSerialNumber := RegParams.T1013;
  // Версия прошивки
  Params.FirmwareVersion := Version.Version;
  // Признак регистрации фискального накопителя
  Params.Fiscal := RegParams.RegNumber > 0;
  // Версия ФФД ФН (одно из следующих значений "1.0","1.1"
  Params.FFDVersionFN := RegParams.T1190;
  // Версия ФФД ККТ (одно из следующих значений "1.0","1.0.5","1.1")
  Params.FFDVersionKKT := RegParams.T1189;
  // Заводской номер ФН
  Params.FNSerialNumber := RegParams.T1041;
  // Номер документа регистрация фискального накопителя
  Params.DocumentNumber := IntToStr(RegParams.FDocNumber);
  // Дата и время операции регистрации фискального накопителя
  Params.DateTime := MTSDateTimeToDateTime(RegParams.Date, RegParams.Time);
  // Название организации
  Params.CompanyName := RegParams.T1048;
  // ИНН организация
  Params.CompanyINN := RegParams.T1018;
  // Адрес проведения расчетов
  Params.SaleAddress := RegParams.T1009;
  // Место проведения расчетов
  Params.SaleLocation := RegParams.T1187;
  // Коды системы налогообложения через разделитель ",".
  Params.TaxationSystems := RegParams.T1062;
  // Признак автономного режима
  Params.IsOffline := RegParams.IsOffline;
  // Признак шифрование данных
  Params.IsEncrypted := RegParams.IsEncrypted;
  // Признак расчетов за услуги
  Params.IsService := RegParams.IsService;
  // Продажа подакцизного товара
  Params.IsExcisable := RegParams.IsExcisable;
  // Признак проведения азартных игр
  Params.IsGambling := RegParams.IsGambling;
  // Признак проведения лотереи
  Params.IsLottery := RegParams.IsLottery;
  // Коды признаков агента через разделитель ",".
  Params.AgentTypes := '';
  // Признак формирования АС БСО
  Params.BSOSing := False;
  // Признак установки принтера в автомате
  Params.IsAutomaticPrinter := RegParams.IsAutomat;
  // Признак автоматического режима
  Params.IsAutomaticMode := RegParams.IsAutomatic;
  // Номер автомата для автоматического режима
  Params.AutomaticNumber := RegParams.T1036;
  // Название организации ОФД
  Params.OFDCompany := RegParams.T1046;
  // ИНН организации ОФД
  Params.OFDCompanyINN := RegParams.T1017;
  // Адрес сайта уполномоченного органа (ФНС) в сети «Интернет»
  Params.FNSURL := RegParams.T1060;
  // Адрес электронной почты отправителя чека
  Params.SenderEmail := RegParams.T1117;
  // Признак ККТ для расчетов в Интернет
  Params.IsOnline := RegParams.IsInternet;
  // Признак применения при осуществлении торговли товарами, подлежащими обязательной маркировке средствами идентификации
  Params.IsMarking := RegParams.IsMarking;
  // Признак применения при осуществлении ломбардами кредитования граждан
  Params.IsPawnshop := RegParams.IsPawnshop;
  // Признак применения при осуществлении деятельности по страхованию
  Params.IsInsurance := RegParams.IsAssurance;
  // Признак применения в автоматическом торговом автомате
  Params.IsVendingMachine := RegParams.IsVendingMachine;
  // Признак применения при оказании услуг общественного питания
  Params.IsCatering := RegParams.IsCatering;
  // Признак применения о оптовой торговле с организациями и ИП
  Params.IsWholesaleTrade := RegParams.IsWholesale;
end;

function TMitsuDrv1C.GetDataKKT(const DeviceID: WideString;
  var TableParametersKKT: WideString): WordBool;
var
  Params: TParametersKKT;
begin
  Logger.Debug('GetDataKKT DeviceID = ' + DeviceID);
  ClearError;
  Result := True;
  Params := TParametersKKT.Create;
  try
    SelectDevice(DeviceID);
    ReadParametersKKT(Params);
    FReader.Write(TableParametersKKT, Params);
    Logger.Debug('TableParametersKKT  ' + TableParametersKKT);
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
      Logger.Error('GetDataKKT, ' + E.Message);
    end;
  end;
  Logger.Debug('GetDataKKT.end');
  Params.Free;
end;

function TMitsuDrv1C.OperationFN(const DeviceID: WideString;
  OperationType: Integer; const ParametersFiscal: WideString): WordBool;

  procedure FNOpen(Params: TParametersFiscal);
  begin

  end;

  procedure FNChange(Params: TParametersFiscal);
  begin

  end;

  procedure FNClose(Params: TParametersFiscal);
  begin

  end;

var
  Params: TParametersFiscal;
begin
  Logger.Debug('OperationFN');
  ClearError;
  Result := True;
  Params := TParametersFiscal.Create;
  try
    SelectDevice(DeviceID);
    FReader.Read(ParametersFiscal, Params);
    case OperationType of
      D1C_FNOT_OPEN: FNOpen(Params);
      D1C_FNOT_CHANGE: FNChange(Params);
      D1C_FNOT_CLOSE: FNClose(Params);
    else

    end;
  except
    on E: Exception do
    begin
      Result := False;
      HandleException(E);
      Logger.Error('OperationFN Error ' + E.Message);
    end;
  end;
  Params.Free;
  Logger.Debug('OperationFN.end');
end;

{ TDevices }

function TDevices.GetFreeID: Integer;
var
  ID: Integer;
begin
  ID := 1;
  while True do
  begin
    if ItemByID(ID) = nil then
    begin
      Result := ID;
      Exit;
    end;
    Inc(ID);
  end;
end;

function TDevices.GetItem(Index: Integer): TDevice;
begin
  Result := inherited Items[Index] as TDevice;
end;

function TDevices.ItemByID(ID: Integer): TDevice;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    Result := Items[i];
    if Result.ID = ID then Exit;
  end;
  Result := nil;
end;

end.
