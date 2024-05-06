unit ODClient2;

interface
uses
  Classes, SysUtils,
   // Indy
  IdStack, IdHTTP, IdSSLOpenSSL, IdHashSha, IdGlobal,
  Positions1C3, untLogger,
  //untJsonOD, JSON,
  logfile, Optional;


type
  TODDocStatus2 = record
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

  TOIsmResponse = record
    dateTime: string;
    resultCode: Variant;
    itemCodeType: Variant;
    oismStatus: Variant;
    processingResults: Variant;
    itemId:  Variant;
  end;

  TKMCheckDocStatus = record
    id: string;
    GUID: string;
    deviceSN: string;
    deviceRN: string;
    fsNumber: string;
    processedAt: string;
    content: string;
//    checkResult: string;
    fsCheckStatus: Integer; //Результат проверки КМ, 2004
    fsCheckStatusCause: Integer; // Причина, по которой не была проведена локальная проверка:
                                 // 0 – КМ проверен в ФН
                                 // 1 – КМ данного типа не подлежит проверки в ФН
                                 // 2 – ФН не содержит ключ проверки кода проверки этого КМ
                                 // 3 – Проверка невозможна, так как отсутствуют идентификаторы применения GS1 91 и/или 92 или их формат неверный.
                                 // 4 – Проверка КМ в ФН невозможна по иной причине
    fsItemCodeType: Integer; // Тип кода маркировки, 2100;
    checkResult: Integer; // Результат проверки сведений о товаре, 2106
    oismCheckResultCode: Integer; // Код ответа ФН на команду онлайн-проверки
                                  // Если 0x20, то в следующем байте возвращается причина:
                                  // 1 – Неверный фискальный признак ответа;
                                  // 2 – Неверный формат реквизиов ответа;
                                  // 3 – Неверный номер запроса в ответе;
                                  // 4 – Неверный номер ФН;
                                  // 5 – Неверный CRC блока данных;
                                  // 7 – Неверная длина ответа.
                                  // Значение 0xFF, если сервер не ответил в течение таймаута.
    oismResponse: Variant; // Ответ ОИСМ на запрос.
                                      // Поле отсутствует если oismCheckResultCode имеет значение отличное от 0 или касса находится в автономном режиме.
  end;

  TODClient2 = class
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
    function GetValue<T>(js: TJSONobject; const Name: string): T;
    function ParseDocStatus(const Data: string): TODDocStatus2;
    function ParseKMCheckDocStatus(const Data: string): TKMCheckDocStatus;
//    procedure SendDocument(const Id: string; const Data: string; ACorrection: Boolean; var DocStatus: TODDocStatus2);
//    function ReadDocumentStatus(const ACorrection: Boolean; const Id: string; var DocStatus: TODDocStatus2; var AResponseCode: string; var AResponseData: string): Integer;
//    function ReadCustomDocumentStatus(const Host: string; var AResponseCode: string; var AResponseData: string): Integer;
    function SSLVerifyPeer(Certificate: TIdX509; AOk: Boolean; ADepth, AError: Integer): Boolean;
    procedure Send(const AServer: string; const Data: string; var AResponseCode: string; var AResponseData: string);
    function doCheckDocStatus(const AHost: string; const Id: string; var AResponseCode: string; var AResponseData: string): Integer;
    procedure CheckDocStatus(const AHost: string; const Id: string; var AResponseCode: string; var AResponseData: string);
    procedure SetServer(const Value: string);
//    property RootCertFileName: string read FRootCertFileName write FRootCertFileName;
    property Logger: TLogger read FLogger;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SendDocument1C(Positions: TPositions1C3; AIsAutomatic: Boolean; var DocStatus: TODDocStatus2);
    procedure SendCorrection1C(Correction: TCheckCorrectionParamsRec3; AIsAutomatic: Boolean; var DocStatus: TODDocStatus2);
    procedure SendCorrection1C_ffd12(Positions: TPositions1C3; AIsAutomatic: Boolean; var DocStatus: TODDocStatus2);
    procedure SendKMCheck(AKMData: TKMCheckQueryRec; var ADocStatus: TKmCheckDocStatus);
    property Inn: string read FInn write FInn;
    property Group: string read FGroup write FGroup;
    property CertFileName: string read FCertFileName write FCertFileName;
    property KeyFileName: string read FKeyFileName write FKeyFileName;
    property SignKeyFileName: string read FSignKeyFileName write FSignKeyFileName;
    property Server: string read FServer write SetServer;
    property KeyName: string read FKeyName write FKeyName;
    property RetryCount: Integer read FRetryCount write FRetryCount;
    property RetryTimeout: Integer read FRetryTimeout write FRetryTimeout;
  end;

implementation

{ TODClient2 }

procedure TODClient2.CheckDocStatus(const AHost, Id: string; var AResponseCode,
  AResponseData: string);
var
  i: Integer;
  Res: Integer;
begin
  for i := 1 to RetryCount do
  begin
    Res := doCheckDocStatus(AHost, Id, AResponseCode, AResponseData);
    if Res = 200 then
      Exit;
    if Res = 202 then
    begin
      Logger.Debug('Wait ' + RetryTimeout.ToString + 's');
      Sleep(RetryTimeout * 1000);
      Continue;
    end
    else
      raise Exception.Create('Ошибка отправки документа: ' + AResponseCode + ': ' + AResponseData);
  end;
  raise Exception.Create('Ошибка отправки документа: ' + AResponseCode + ': ' + AResponseData);
end;

constructor TODClient2.Create;
begin
  inherited;
  FLogger := TLogger.Create(Self.ClassName);
end;

destructor TODClient2.Destroy;
begin
  FLogger.Free;
  inherited;
end;

function TODClient2.doCheckDocStatus(const AHost: string; const Id: string; var AResponseCode: string; var AResponseData: string): Integer;
var
  Connection: TIdHTTP;
  IOHandler: TIdSSLIOHandlerSocketOpenSSL;
  Answer: TStringStream;
begin
  if not LoadOpenSSLLibrary then
    raise Exception.Create('Error loading SSL Library');

  Logger.Debug('OD Read doc status: ' + AHost);

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
  Connection.Request.Host := AHost;
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
      Connection.Get(AHost, Answer);
      Result := Connection.ResponseCode;
      AResponseCode := Connection.ResponseText;
      AResponseData := Answer.DataString;
      Logger.Debug('OD Read doc status <- ' + AResponseCode);
      Logger.Debug('OD Read doc status <- ' + AResponseData);
    except
      on E: EIdHTTPProtocolException do
      begin
        Result := Connection.ResponseCode;
        AResponseCode := E.Message;
        AResponseData := UTF8Decode(E.ErrorMessage);
        Logger.Error('OD Read doc status <- ' + AResponseCode + ', ' + AResponseData );
      end;
    end;
{    if Result = 200 then
      DocStatus := ParseDocStatus(AResponseData);}
  finally
    Answer.Free;
    IOHandler.Free;
    Connection.Free;
  end;
end;

(*
function TODClient2.ReadDocumentStatus(const ACorrection: Boolean; const Id: string; var DocStatus: TODDocStatus2; var AResponseCode: string; var AResponseData: string): Integer;
var
  Connection: TIdHTTP;
  IOHandler: TIdSSLIOHandlerSocketOpenSSL;
  Answer: TStringStream;
  Host: string;
begin
  if not LoadOpenSSLLibrary then
    raise Exception.Create('Error loading SSL Library');

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
      Logger.Debug('OD Read doc status <- ' + AResponseData);
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
*)

{
procedure TODClient2.SendDocument(const AHost: string; const Id: string; const Data: string; ACorrection: Boolean; var DocStatus: TODDocStatus2);
var
  Res: Integer;
  RespCode: string;
  RespData: string;
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

  Res := Send(Host, Data, RespCode, RespData, True);
  if (Res <> 201) then
    raise Exception.Create('Ошибка отправки документа: ' + RespCode + ':' + RespData);

  for i := 1 to RetryCount do
  begin
    Res := ReadDocumentStatus(ACorrection, Id, DocStatus, RespCode, RespData);
    if Res = 200 then
    begin
      Exit;
    end;
    if Res = 202 then
    begin
      Logger.Debug('Wait ' + RetryTimeout.ToString + 's');
      Sleep(RetryTimeout * 1000);
      Continue;
    end
    else
      raise Exception.Create('Ошибка отправки документа: ' + RespCode + ': ' + RespData);
  end;
  raise Exception.Create('Ошибка отправки документа: ' + RespCode + ': ' + RespData);
end;
}
procedure TODClient2.Send(const AServer: string; const Data: string; var AResponseCode: string; var AResponseData: string);
var
  Request: TStringStream;
  Connection: TIdHTTP;
  IOHandler: TIdSSLIOHandlerSocketOpenSSL;
  Answer: string;
  Signature: string;
  Res: Integer;
begin
  Logger.Debug('OD Send: ' + AServer);
  Logger.Debug('OD Send -> ' + Data);
  if not LoadOpenSSLLibrary then
    raise Exception.Create('Error loading SSL Library');
  Answer := '';
  Signature := EncodeJSON(FSignKeyFileName, Data);
  Logger.Debug('OD Send Signature: ' {+ Signature});
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
  Connection.Request.CustomHeaders.AddValue('X-Signature', Signature);
  Connection.ProxyParams.BasicAuthentication := False;
  Connection.ProxyParams.ProxyPort := 0;
  Connection.Request.ContentLength := -1;
  Connection.Request.ContentRangeEnd := 0;
  Connection.Request.ContentRangeStart := 0;//-1;
  Connection.Request.ContentRangeInstanceLength := 0;//-1;
  Connection.Request.BasicAuthentication := False;
  Connection.Request.Ranges.Units := 'bytes';
  Connection.HTTPOptions := [hoForceEncodeParams];

  Request := TStringStream.Create(Data);
  try
    try
      Answer := Connection.Post(AServer, Request);
      Res := Connection.ResponseCode;
      AResponseCode := Connection.ResponseText;
      AResponseData := Connection.ResponseText;
      Logger.Debug('OD Send <- ' + Answer);
      Logger.Debug('OD Send <- ' + Connection.ResponseText);
    except
      on E: EIdHTTPProtocolException do
      begin
        Res := Connection.ResponseCode;
        AResponseCode := E.Message;
        AResponseData := E.ErrorMessage;
        Logger.Error('OD Send <- ' + AResponseCode);
        Logger.Error('OD Send <- ' + AResponseData);
      end;
    end;
  finally
    Request.Free;
    IOHandler.Free;
    Connection.Free;
  end;

  if Res <> 201 then
    raise Exception.Create('Ошибка отправки документа: ' + AResponseCode + ':' + AResponseData);
end;

function TODClient2.SSLVerifyPeer(Certificate: TIdX509;
  AOk: Boolean; ADepth, AError: Integer): Boolean;
begin
  Result := True;
end;

function TODClient2.ParseDocStatus(const Data: string): TODDocStatus2;
var
  Json: TJSONobject;

  function GetValue(js: TJSONobject; const Name: string): Variant;
  begin
    if js.Get(Name) = nil then
      raise Exception.Create('Json parse error: no field ' + Name);
    Result := js.Get(Name).JsonValue.AsType<string>;
  end;

begin
  if Data = '' then
    raise Exception.Create('Empty answer');

  Json := TJSONObject.ParseJSONValue(Data) as TJSONObject;
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

    Result.documentIndex := GetValue(Json, 'documentIndex');
    Result.processedAt := GetValue(Json, 'processedAt');
    Result.fp := GetValue(Json, 'fp');

  finally
    Json.Free;
  end;
end;


function TODClient2.GetValue<T>(js: TJSONobject; const Name: string): T;
begin
  if js.Get(Name) = nil then
    raise Exception.Create('Json parse error: no field ' + Name);
  Result := js.Get(Name).JsonValue.AsType<T>;
end;

function TODClient2.ParseKMCheckDocStatus(
  const Data: string): TKMCheckDocStatus;
var
  Json: TJSONobject;
  CheckResult: TJSONObject;
  OismResponse: TJSONObject;
  Oism: TOIsmResponse;
begin
  if Data = '' then
    raise Exception.Create('Empty answer');

  Json := TJSONObject.ParseJSONValue(Data) as TJSONObject;
  try
    Result.id := GetValue<string>(Json, 'id');
    CheckResult := GetValue<TJSONObject>(Json, 'checkResult');
    Result.fsCheckStatus := GetValue<Integer>(CheckResult , 'fsCheckStatus');
    Result.fsCheckStatusCause := GetValue<Integer>(CheckResult , 'fsCheckStatusCause');
    Result.fsItemCodeType := GetValue<Integer>(CheckResult , 'fsItemCodeType');
    Result.checkResult := GetValue<Integer>(CheckResult , 'checkResult');
    Result.oismCheckResultCode := GetValue<Integer>(CheckResult , 'oismCheckResultCode');
    if CheckResult.FindValue('oismResponse') <> nil then
    begin
      OismResponse := GetValue<TJSONObject>(CheckResult, 'oismResponse');
//      Oism.dateTime := GetValue<string>(OismResponse, 'dateTime');
      if OismResponse.FindValue('resultCode') <> nil then
        Oism.resultCode.Value := GetValue<Integer>(OismResponse, 'resultCode');
      if OismResponse.FindValue('itemCodeType') <> nil then
        Oism.itemCodeType.Value := GetValue<Integer>(OismResponse, 'itemCodeType');
      if OismResponse.FindValue('oismStatus') <> nil then
        Oism.oismStatus.Value := GetValue<Integer>(OismResponse, 'oismStatus');
      if OismResponse.FindValue('processingResults') <> nil then
        Oism.processingResults.Value := GetValue<Integer>(OismResponse, 'processingResults');
      if OismResponse.FindValue('itemId') <> nil then
        Oism.itemId.Value := GetValue<string>(OismResponse, 'itemId');
      Result.oismResponse.Value := Oism;
    end;
  finally
    Json.Free;
  end;

end;

procedure TODClient2.SendDocument1C(Positions: TPositions1C3; AIsAutomatic: Boolean; var DocStatus: TODDocStatus2);
var
  Json: string;
  ResponseCode, ResponseData: string;
begin
  Json := Positions.GetJsonODCheck(FInn, FGroup, FKeyName, AIsAutomatic);
  globallogger.debug('OD JSON: ' + Json);
  Send(FServer + 'documents/', Json, ResponseCode, ResponseData);
  CheckDocStatus(FServer + 'documents/' + FInn + '/status/' + Positions.Id, Positions.Id, ResponseCode, ResponseData);
  DocStatus := ParseDocStatus(ResponseData);
end;

procedure TODClient2.SendCorrection1C(
  Correction: TCheckCorrectionParamsRec3; AIsAutomatic: Boolean; var DocStatus: TODDocStatus2);
var
  Json: string;
  ResponseCode, ResponseData: string;
begin
  Json := GetJsonODCorrection(Correction, FInn, FGroup, FKeyName, AIsAutomatic);
  Send(FServer + 'corrections/', Json, ResponseCode, ResponseData);
  CheckDocStatus(FServer + 'corrections/' + FInn + '/status/' + Correction.Id, Correction.Id, ResponseCode, ResponseData);
  DocStatus := ParseDocStatus(ResponseData);
end;

procedure TODClient2.SendCorrection1C_ffd12(Positions: TPositions1C3; AIsAutomatic: Boolean;
  var DocStatus: TODDocStatus2);
var
  Json: string;
  ResponseCode, ResponseData: string;
begin
  Json := Positions.GetJsonODCheck(FInn, FGroup, FKeyName, AIsAutomatic, True);
  globallogger.debug('OD JSON: ' + Json);
  Send(FServer + 'correction12/', Json, ResponseCode, ResponseData);
  CheckDocStatus(FServer + 'correction12/' + FInn + '/status/' + Positions.Id, Positions.Id, ResponseCode, ResponseData);
  DocStatus := ParseDocStatus(ResponseData);;
end;

procedure TODClient2.SendKMCheck(AKMData: TKMCheckQueryRec;
  var ADocStatus: TKmCheckDocStatus);
var
  Json: string;
  ResponseCode, ResponseData: string;
begin
  Json := AKMData.ToJSON(FInn, FGroup, FKeyName);
  globallogger.debug('OD JSON: ' + Json);
  Send(FServer + 'itemcode/', Json, ResponseCode, ResponseData);
  CheckDocStatus(FServer + 'itemcode/' + FInn + '/status/' + AKMData.Id, AKMData.id, ResponseCode, ResponseData);
  ADocStatus := ParseKMCheckDocStatus(ResponseData);
  ADocStatus.GUID := AKMData.GUID;
end;

procedure TODClient2.SetServer(const Value: string);
begin
  FServer := Value;
  if Copy(Value, Length(Value), 1) <> '/' then
    FServer := Value + '/';
end;


end.
