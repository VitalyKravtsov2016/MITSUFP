unit ODClient;

interface
uses
  Classes, SysUtils,
   // Indy
  IdStack, IdHTTP, IdSSLOpenSSL, IdHashSha, IdGlobal,
  uLkJSON, Positions1C, untLogger;


type
  TODDocStatus = record
    id: string;
    deviceSN: string;
    deviceRN: string;
    fsNumber: string;
    ofdName: string;
    ofdWebsite: string;
    ofdINN: string;
    fnsWebsite: string;
    companyINN: string;
    companyName: string;
    documentNumber: string;
    shiftNumber: string;
    documentIndex: string;
    processedAt: string;
    content: string;
    change: Double;
    fp: string;
  end;


{  TCheckCorrectionParamsRec22 = record
    CashierName: WideString; //ФИО уполномоченного лица для проведения операции 	Формирование нового чека с заданным атрибутами
    CashierVATIN: WideString; //  	ИНН уполномоченного лица для проведения операции
    CorrectionType: Integer; //	Тип коррекции
      // 0 - самостоятельно
      // 1 - по предписанию
    TaxVariant: Integer; // Код системы налогообложения
    PaymentType: Integer; //	Тип расчета
      //1 - Приход
      //2 - Возврат прихода
      //3 - Расход
      //4 - Возврат расхода
    CorrectionBaseName: WideString; // 	Наименование основания для коррекции
    CorrectionBaseDate: TDateTime; //	Дата документа основания для коррекции
    CorrectionBaseNumber: WideString; // Номер документа основания для коррекции
    Sum: Currency; // Сумма расчета, указанного в чеке
    SumTAX18: Currency; // Сумма НДС чека по ставке 18%
    SumTAX10: Currency; // Сумма НДС чека по ставке 10%
    SumTAX0: Currency; // Сумма НДС чека по ставке 0%
    SumTAXNone: Currency; //Сумма НДС чека по без НДС
    SumTAX110: Currency; // Сумма НДС чека по расч. ставке 10/110
    SumTAX118: Currency; // Сумма НДС чека по расч. ставке 18/118
    Cash: Currency; //Сумма наличной оплаты 	Параметры закрытия чека. Чек коррекции может быть оплачен только одним видом оплаты и без сдачи.
    ElectronicPayment: Currency; //Сумма электронной оплаты
    AdvancePayment: Currency; // Сумма предоплатой (зачетом аванса)
    Credit: Currency; // Сумма постоплатой (в кредит)
    CashProvision: Currency; // Сумма встречным предоставлением
  end;}



  TODClient = class
  private
    FCertFileName: string;
    FKeyFileName: string;
    FServer: string;
    FKeyName: string;
    //FRootCertFileName: string;
    FRetryTimeout: Integer;
    FRetryCount: Integer;
    FSignKeyFileName: string;
    FGroup: string;
    FInn: string;
    FLogger: TLogger;
    function Stuffing(const Value: string): string;

    function ParseDocStatus(const Data: string): TODDocStatus;
    function JsonAddStr(const Json: string; const Name: string; const Value: string): string;
    function JsonAddInt(const Json: string; const Name: string; const Value: string): string;
    function GetJsonDoc1C(Positions: TPositions1C): string;
    function GetJsonCorrection1C(Correction: TCheckCorrectionParamsRec22): string;
    procedure SendDocument(const Id: string; const Data: AnsiString; ACorrection: Boolean; var DocStatus: TODDocStatus);
    function ReadDocumentStatus(const ACorrection: Boolean; const Id: string; var DocStatus: TODDocStatus; var AResponseCode: AnsiString; var AResponseData: AnsiString): Integer;
    function SSLVerifyPeer(Certificate: TIdX509; AOk: Boolean; ADepth, AError: Integer): Boolean;
    function Send(const AServer: string; const Data: AnsiString; var AResponseCode: AnsiString; var AResponseData: AnsiString): Integer;
//    property RootCertFileName: string read FRootCertFileName write FRootCertFileName;
    property Logger: TLogger read FLogger;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SendDocument1C(Positions: TPositions1C; var DocStatus: TODDocStatus);
    procedure SendCorrection1C(Correction: TCheckCorrectionParamsRec22; var DocStatus: TODDocStatus);
    property Inn: string read FInn write FInn;
    property Group: string read FGroup write FGroup;
    property CertFileName: string read FCertFileName write FCertFileName;
    property KeyFileName: string read FKeyFileName write FKeyFileName;
    property SignKeyFileName: string read FSignKeyFileName write FSignKeyFileName;
    property Server: string read FServer write FServer;
    property KeyName: string read FKeyName write FKeyName;
    property RetryCount: Integer read FRetryCount write FRetryCount;
    property RetryTimeout: Integer read FRetryTimeout write FRetryTimeout;
  end;

implementation

{ TODClient }

constructor TODClient.Create;
begin
  inherited;
  FLogger := TLogger.Create(Self.ClassName);
end;

destructor TODClient.Destroy;
begin
  FLogger.Free;
  inherited;
end;

function TODClient.ReadDocumentStatus(const ACorrection: Boolean; const Id: string; var DocStatus: TODDocStatus; var AResponseCode: AnsiString; var AResponseData: AnsiString): Integer;
var
  Connection: TIdHTTP;
  IOHandler: TIdSSLIOHandlerSocketOpenSSL;
  Answer: TStringStream;
  Host: string;
begin

  if not LoadOpenSSLLibrary then
    raise Exception.Create('Error loading SSL Library');

//: GET /api/v2/documents/{inn}/status/{document_id}
//GET /api/v2/corrections/{inn}/status/{document_id}
  Host := FServer;
  if Copy(Host, Length(Host), 1) <> '/' then
    Host := Host + '/';

  if ACorrection then
    Host := FServer + 'corrections/' + FInn + '/status/' + Id
  else
    Host := FServer + 'documents/' + FInn + '/status/' + Id;

  Logger.Debug('OD Read doc status: ' + Host);

  Connection := TIdHTTP.Create;
  IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  GIdDefaultTextEncoding := encUTF8;
  Connection.IOHandler := IOHandler;
  IOHandler.SSLOptions.CertFile := FCertFileName;
  IOHandler.SSLOptions.KeyFile := FKeyFileName;
  //IOHandler.SSLOptions.RootCertFile := FRootCertFileName;

  IOHandler.SSLOptions.Method := sslvSSLv23;
  IOHandler.SSLOptions.SSLVersions := [sslvSSLv23];
  IOHandler.SSLOptions.Mode := sslmClient;
  IOHandler.SSLOptions.VerifyMode := [sslvrfPeer];
  IOHandler.SSLOptions.VerifyDepth := 0;
  IOHandler.OnVerifyPeer := SSLVerifyPeer;
  Connection.AllowCookies := True;
  Connection.HandleRedirects := True;
  Connection.Request.Host := Host;
  Connection.Request.UserAgent := 'Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.0.10) Gecko/2009042316 Firefox/3.0.10';
  Connection.Request.ContentType := 'application/json; charset=utf-8';
  Connection.Request.CharSet := 'utf-8';
  Connection.Request.Accept := 'application/json';
  Connection.Request.AcceptCharSet := 'utf-8';
  Connection.Response.CharSet := 'utf-8';
  Connection.Response.ContentType := 'application/json';
  Connection.Response.ContentEncoding := 'utf-8';
  Connection.ProxyParams.BasicAuthentication := False;
  Connection.ProxyParams.ProxyPort := 0;
  Connection.Request.ContentLength := -1;
  Connection.Request.ContentRangeEnd := 0;//-1;
  Connection.Request.ContentRangeStart := 0;//-1;
  Connection.Request.ContentRangeInstanceLength := 0;//-1;
  Connection.Request.BasicAuthentication := False;
  Connection.Request.Ranges.Units := 'bytes';
  Connection.HTTPOptions := [hoForceEncodeParams];

  Answer := TStringStream.Create('');
  try
    try
      Connection.Get(Host, Answer);
      Result := Connection.ResponseCode;
      AResponseCode := Connection.ResponseText;
      AResponseData := Answer.DataString;
      Logger.Debug('OD Read doc status <- ' + AResponseCode);
      Logger.Debug('OD Read doc status <- ' + UTF8Decode(AResponseData));
    except
      on E: EIdHTTPProtocolException do
      begin
        Result := Connection.ResponseCode;
        AResponseCode := E.Message;
        AResponseData := UTF8Decode(E.ErrorMessage);
        Logger.Error('OD Read doc status <- ' + AResponseCode + ', ' + AResponseData );
      end;
    end;
    if Result = 200 then
      DocStatus := ParseDocStatus(AResponseData);
  finally
    Answer.Free;
    IOHandler.Free;
    Connection.Free;
  end;
end;

procedure TODClient.SendDocument(const Id: string; const Data: Ansistring; ACorrection: Boolean; var DocStatus: TODDocStatus);
var
  Res: Integer;
  RespCode: AnsiString;
  RespData: AnsiString;
  i: Integer;
  Host: string;
begin
  Host := FServer;
  if Copy(Host, Length(Host), 1) <> '/' then
    Host := Host + '/';

 if ACorrection then
   Host := FServer + 'corrections/'
 else
   Host := FServer + 'documents/';

  Res := Send(Host, Data, RespCode, RespData);
  if (Res <> 201) then
    raise Exception.Create('Ошибка отправки документа: ' + RespCode);

  for i := 1 to RetryCount do
  begin
    Res := ReadDocumentStatus(ACorrection, Id, DocStatus, RespCode, RespData);
    if Res = 200 then
    begin
      Exit;
    end;
    if Res = 202 then
    begin
      Logger.Debug('Wait ' + IntToStr(RetryTimeout) + 's');
      Sleep(RetryTimeout * 1000);
      Continue;
    end
    else
      raise Exception.Create('Ошибка отправки документа: ' + RespCode);
  end;
  raise Exception.Create('Ошибка отправки документа: ' + RespCode);
end;

function TODClient.Send(const AServer: string; const Data: AnsiString; var AResponseCode: AnsiString; var AResponseData: Ansistring): Integer;
var
  Request: TStringStream;
  Connection: TIdHTTP;
  IOHandler: TIdSSLIOHandlerSocketOpenSSL;
  Answer: AnsiString;
  Signature: Ansistring;
begin
  Logger.Debug('OD Send: ' + AServer);
  Logger.Debug('OD Send -> ' + Data);
  if not LoadOpenSSLLibrary then
    raise Exception.Create('Error loading SSL Library');
  Answer := '';
  //Signature := EncodeJSON(FSignKeyFileName, Data); !!!
  Connection := TIdHTTP.Create;
  IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  GIdDefaultTextEncoding := encUTF8;
  Connection.IOHandler := IOHandler;
  IOHandler.SSLOptions.CertFile := FCertFileName;
  IOHandler.SSLOptions.KeyFile := FKeyFileName;
  //IOHandler.SSLOptions.RootCertFile := FRootCertFileName;

  IOHandler.SSLOptions.Method := sslvSSLv23;
  IOHandler.SSLOptions.SSLVersions := [sslvSSLv23];
  IOHandler.SSLOptions.Mode := sslmClient;
  IOHandler.SSLOptions.VerifyMode := [sslvrfPeer];
  IOHandler.SSLOptions.VerifyDepth := 0;
  IOHandler.OnVerifyPeer := SSLVerifyPeer;
  Connection.AllowCookies := True;
  Connection.HandleRedirects := True;
  Connection.Request.Host := AServer;
  Connection.Request.UserAgent := 'Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.0.10) Gecko/2009042316 Firefox/3.0.10';
  Connection.Request.ContentType := 'application/json; charset=utf-8';
  Connection.Request.CharSet := 'utf-8';
  Connection.Request.Accept := 'application/json';
  Connection.Request.AcceptCharSet := 'utf-8';
  Connection.Response.CharSet := 'utf-8';
  Connection.Response.ContentType := 'application/json';
  Connection.Response.ContentEncoding := 'utf-8';
  // X-Signature
  Connection.Request.CustomHeaders.AddValue('X-Signature', Signature);
//  WideShowMessage(Connection.Request.CustomHeaders.GetText);

  Connection.ProxyParams.BasicAuthentication := False;
  Connection.ProxyParams.ProxyPort := 0;
  Connection.Request.ContentLength := -1;
  Connection.Request.ContentRangeEnd := 0;
  Connection.Request.ContentRangeStart := 0;//-1;
  Connection.Request.ContentRangeInstanceLength := 0;//-1;
  Connection.Request.BasicAuthentication := False;
  Connection.Request.Ranges.Units := 'bytes';
  Connection.HTTPOptions := [hoForceEncodeParams];
  Request := TStringStream.Create(UTF8Encode(Data));
  try
    try
      Answer := Connection.Post(AServer, Request);
      Result := Connection.ResponseCode;
      AResponseCode := Connection.ResponseText;
      AResponseData := Connection.ResponseText;
      Logger.Debug('OD Send <- ' + Answer);
      Logger.Debug('OD Send <- ' + Connection.ResponseText);
    except
      on E: EIdHTTPProtocolException do
      begin
        Result := Connection.ResponseCode;
        AResponseCode := E.Message;
        AResponseData := UTF8Decode(E.ErrorMessage);
        Logger.Error('OD Send <- ' + AResponseCode);
        Logger.Error('OD Send <- ' + AResponseData);

      end;
    end;
  finally
    Request.Free;
    IOHandler.Free;
    Connection.Free;
  end;
end;

function TODClient.SSLVerifyPeer(Certificate: TIdX509;
  AOk: Boolean; ADepth, AError: Integer): Boolean;
begin
  Result := True;
end;

function TODClient.ParseDocStatus(const Data: string): TODDocStatus;
var
  Json: TlkJSONobject;

  function GetValue(js: TlkJSONobject; const Name: string): Variant;
  begin
    if js.Field[Name] = nil then
      raise Exception.Create('Json parse error: no field ' + Name);
    Result := js.Field[Name].Value;
  end;

begin
  if Data = '' then
    raise Exception.Create('Empty answer');
  Json := TlkJSon.ParseText(Data) as TlkJSONobject;

  try
    Result.id := GetValue(Json, 'id');
   { Result.deviceSN := GetValue(Json, 'deviceSN');
    Result.deviceRN := GetValue(Json, 'deviceRN');
    Result.fsNumber := GetValue(Json, 'fsNumber');
    Result.ofdName := GetValue(Json, 'ofdName');
    Result.ofdWebsite := GetValue(Json, 'ofdWebsite');
    Result.ofdINN := GetValue(Json, 'ofdinn');}
    Result.fnsWebsite := GetValue(Json, 'fnsWebsite');
{    Result.companyINN := GetValue(Json, 'companyINN');
    Result.companyName := GetValue(Json, 'companyName');}
    Result.documentNumber := GetValue(Json, 'documentNumber');
    Result.shiftNumber := GetValue(Json, 'shiftNumber');
{    Result.documentIndex := GetValue(Json, 'documentIndex');
    Result.processedAt := GetValue(Json, 'processedAt');}
    Result.fp := GetValue(Json, 'fp');
    {

    if Json.Field['change'] = nil then
      raise Exception.Create('Json parse error: no field change');
    Result.change := Json.getDouble('change');
    }
  finally
    Json.Free;
  end;
end;

procedure TODClient.SendDocument1C(Positions: TPositions1C; var DocStatus: TODDocStatus);
var
  Json: string;
begin
  Json := GetJsonDoc1C(Positions);
  SendDocument(Positions.Id, Json, False, DocStatus);
end;

function TODClient.GetJsonDoc1C(Positions: TPositions1C): string;

function ConvertTax(ATax: Integer): string;
begin
  case ATax of
    1: Result := '1';
    2: Result := '2';
    3: Result := '5';
    4: Result := '6';
    5: Result := '3';
    6: Result := '4';
  end;
end;

var
  i: Integer;
  Position: TFiscalString22;
  SaveSeparator: Char;
begin
  SaveSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  try
    Result := '{';
    Result := JsonAddStr(Result, 'id', Positions.Id) + ',';
    Result := JsonAddStr(Result, 'inn', FInn) + ',';
    Result := JsonAddStr(Result, 'group', FGroup) + ',';
    if FKeyName <> '' then
      Result := JsonAddStr(Result, 'key', FKeyName) + ',';
    Result := Result + '"content": {';
    Result := JsonAddInt(Result, 'type', IntToStr(Positions.PaymentType)) + ',';
    Result := Result + '"positions": [';

    for i := 0 to Positions.Count - 1 do
    begin
      if Positions[i] is TFiscalString22 then
        Position := TFiscalString22(Positions[i])
      else
        Continue;
      Result := Result + '{';
      Result := JsonAddInt(Result, 'quantity', Format('%.6f', [Position.Quantity])) + ',';
      Result := JsonAddInt(Result, 'price', Format('%.2f', [Position.PriceWithDiscount])) + ',';
      Result := JsonAddInt(Result, 'tax', ConvertTax(Position.Tax)) + ',';
      Result := JsonAddStr(Result, 'text', Stuffing(Position.Name)) + ',';
      Result := JsonAddInt(Result, 'paymentMethodType', IntToStr(Position.SignMethodCalculation)) + ',';
      Result := JsonAddInt(Result, 'paymentSubjectType', IntToStr(Position.SignCalculationObject));
      // !!! Result := JsonAddStrResult, 'nomenclatureCode', Position.ItemCodeData.);
      //!!! Agent
      Result := Result + '},';
    end;
    if Copy(Result, Length(Result), 1) = ',' then
      Result := Copy(Result, 1, Length(Result) - 1);
    // Positions
    Result := Result + '],';
    Result := Result + '"checkClose": {';
    Result := Result + '"payments": [{';
    Result := JsonAddInt(Result, 'type', '1') + ',';
    Result := JsonAddInt(Result, 'amount', Format('%.2f', [Positions.Cash]));
    Result := Result + '},{';
    Result := JsonAddInt(Result, 'type', '2') + ',';
    Result := JsonAddInt(Result, 'amount', Format('%.2f', [Positions.ElectronicPayment]));
    Result := Result + '},{';
    Result := JsonAddInt(Result, 'type', '14') + ',';
    Result := JsonAddInt(Result, 'amount', Format('%.2f', [Positions.AdvancePayment]));
    Result := Result + '},{';
    Result := JsonAddInt(Result, 'type', '15') + ',';
    Result := JsonAddInt(Result, 'amount', Format('%.2f', [Positions.Credit]));
    Result := Result + '},{';
    Result := JsonAddInt(Result, 'type', '16') + ',';
    Result := JsonAddInt(Result, 'amount', Format('%.2f', [Positions.CashProvision]));
    Result := Result + '}],';
    Result := JsonAddInt(Result, 'taxationSystem', IntToStr(Positions.TaxVariant));

    if (Positions.CustomerPhone = '') and (Positions.CustomerEmail = '') then
    begin
      Result := Result + '}';
    end
    else
    begin
      if Positions.CustomerEmail <> '' then
      begin
        Result := Result + '},';
        Result := JsonAddStr(Result, 'customerContact', Positions.CustomerEmail);
      end
      else
      begin
        Result := Result + '},';
        Result := JsonAddStr(Result, 'customerContact', Positions.CustomerPhone);
      end;
    end;

    Result := Result + '}}';
  finally
    DecimalSeparator := SaveSeparator;
  end;
end;

{function TODClient.JsonAddGroup(const Json, Value: string): string;
begin

end;}

function TODClient.JsonAddInt(const Json, Name, Value: string): string;
begin
  Result := Json;
  Result := Result + '"' + Name + '": '+ Value;
end;

function TODClient.JsonAddStr(const Json, Name, Value: string): string;
begin
  Result := Json;
  Result := Result + '"' + Name + '": "'+ Value + '"';
end;

procedure TODClient.SendCorrection1C(
  Correction: TCheckCorrectionParamsRec22; var DocStatus: TODDocStatus);
var
  Json: string;
begin
  Json := GetJsonCorrection1C(Correction);
  SendDocument(Correction.Id, Json, True, DocStatus);
end;


function DateTimeToJson(const AValue: TDateTime): string;
var
  d, m, y, h, min, s, ns: Word;
begin
  DecodeDate(AValue, y, m, d);
  DecodeTime(AValue, h, min, s, ns);
  Result := Format('%d-%.2d-%.2dT%.2d:%.2d:%.2d', [y, m, d, h, min, s]);
end;

function TODClient.GetJsonCorrection1C(Correction: TCheckCorrectionParamsRec22): string;
var
  SaveSeparator: Char;
begin
  SaveSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  try
    Result := '{';
    Result := JsonAddStr(Result, 'id', Correction.Id) + ',';
    Result := JsonAddStr(Result, 'inn', FInn) + ',';
    Result := JsonAddStr(Result, 'group', FGroup) + ',';
    if FKeyName <> '' then
      Result := JsonAddStr(Result, 'key', FKeyName) + ',';
    Result := Result + '"content": {';

    Result := JsonAddInt(Result, 'correctionType', IntToStr(Correction.CorrectionType)) + ',';
    Result := JsonAddInt(Result, 'type', IntToStr(Correction.PaymentType)) + ',';
    Result := JsonAddStr(Result, 'description', Correction.CorrectionBaseName) + ',';
    Result := JsonAddStr(Result, 'causeDocumentDate', DateTimeToJson((Correction.CorrectionBaseDate))) + ',';
    Result := JsonAddStr(Result, 'causeDocumentNumber', Correction.CorrectionBaseNumber) + ',';
    Result := JsonAddInt(Result, 'totalSum', Format('%.2f', [Correction.Sum])) + ',';
    Result := JsonAddInt(Result, 'cashSum', Format('%.2f', [Correction.Cash])) + ',';
    Result := JsonAddInt(Result, 'eCashSum', Format('%.2f', [Correction.ElectronicPayment])) + ',';
    Result := JsonAddInt(Result, 'prepaymentSum', Format('%.2f', [Correction.AdvancePayment])) + ',';
    Result := JsonAddInt(Result, 'postpaymentSum', Format('%.2f', [Correction.AdvancePayment])) + ',';
    Result := JsonAddInt(Result, 'otherPaymentTypeSum', Format('%.2f', [Correction.CashProvision])) + ',';
    Result := JsonAddInt(Result, 'tax1Sum', Format('%.2f', [Correction.SumTAX18])) + ',';
    Result := JsonAddInt(Result, 'tax2Sum', Format('%.2f', [Correction.SumTAX10])) + ',';
    Result := JsonAddInt(Result, 'tax3Sum', Format('%.2f', [Correction.SumTAX0])) + ',';
    Result := JsonAddInt(Result, 'tax4Sum', Format('%.2f', [Correction.SumTAXNone])) + ',';
    Result := JsonAddInt(Result, 'tax5Sum', Format('%.2f', [Correction.SumTAX118])) + ',';
    Result := JsonAddInt(Result, 'tax6Sum', Format('%.2f', [Correction.SumTAX110])) + ',';
    Result := JsonAddInt(Result, 'taxationSystem', IntToStr(Correction.TaxVariant)) + '}}';
  finally
    DecimalSeparator := SaveSeparator;
  end;

end;

//   <FiscalString Name="Аванс от: ООО &quot;ЭВОТОР&quot; ,
//     Основание: " Quantity="1" PriceWithDiscount="12100" SumWithDiscount="12100"
//    DiscountSum="0" Department="1" Tax="20/120" SignMethodCalculation="3" SignCalculationObject="10" TaxSum="0">
function TODClient.Stuffing(const Value: string): string;
begin
  Result := stringreplace(Value, '"', '\"', [rfReplaceAll]);
end;

end.
