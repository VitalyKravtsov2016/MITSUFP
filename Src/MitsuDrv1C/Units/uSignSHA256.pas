unit uSignSHA256;

interface

uses
  // VCL
  Windows,

  IdSSLOpenSSLHeaders, IdGlobal, VersionInfo;
  //Soap.EncdDecd, NetEncoding,

function EncodeJSON(const KeyFileName: AnsiString; const Json: string): string;


implementation

uses
  Classes, SysUtils;

type
  TKeyFileType = (kfPrivate, kfPublic);

function ReadKeyFile(AFileName: AnsiString; AType: TKeyFileType): PEVP_PKEY;
var
  FileName: AnsiString;
  BIO: pBIO;
begin
  FileName := AFileName;
  BIO := BIO_new(BIO_s_file());
  try
    BIO_read_filename(BIO, PIdAnsiChar(@FileName[1]));

    result := nil;
    case AType of
      kfPrivate:
        result := PEM_read_bio_PrivateKey(BIO, nil, nil, nil);
      kfPublic:
        result := PEM_read_bio_PUBKEY(BIO, nil, nil, nil);
    end;

    if Result = nil then
      raise Exception.Create('Unable to read private key');
  finally
    BIO_free(BIO);
  end;
end;

function SHASign(AKeyFileName: string; AData: AnsiString): AnsiString;
var
  Data: AnsiString;
  Key: pEVP_PKEY;
  Ctx: pEVP_MD_CTX;
  SHA256: pEVP_MD;
  Res: Integer;
  Buffer: TBytes;
  Len: size_t;
begin
  IdOpenSSLSetLibPath(IncludeTrailingBackSlash(ExtractFilePath(GetDllFileName)));
  if not IdSSLOpenSSLHeaders.Load() then
    raise Exception.Create('Cannot load SSL Library');
  Key := ReadKeyFile(AKeyFileName, kfPrivate);
  try
    Ctx := EVP_MD_CTX_create;

    if Ctx = nil then
      raise exception.Create('OpenSSL CTX create error');

    try
      SHA256 := EVP_sha256();

      Res := EVP_DigestSignInit(Ctx, nil, SHA256, nil, Key);
      if Res <> 1 then
        raise Exception.Create('EVP_DigestSignInit failed: ' + Res.ToString);

      Buffer := BytesOf(AData);

      Res := EVP_DigestSignUpdate(Ctx, PByte(Buffer), Length(Buffer));
      if Res <> 1 then
        raise Exception.Create('EVP_DigestSignUpdate failed: ' + Res.ToString);

      Res := EVP_DigestSignFinal(Ctx, nil, @Len);
      if Res <> 1 then
        raise Exception.Create('EVP_DigestFinal failed: ' + Res.ToString);

      SetLength(Buffer, Len);

      Res := EVP_DigestSignFinal(Ctx, PIdAnsiChar(PByte(Buffer)), @Len);
      if Res <> 1 then
        raise Exception.Create('EVP_DigestFinal failed: ' + Res.ToString);

      Result := TNetEncoding.Base64.EncodeBytesToString(PByte(Buffer), Len);
      Result := StringReplace(Result, #13, '', [rfReplaceAll]);
      Result := StringReplace(Result, #10, '', [rfReplaceAll]);
    finally
      EVP_MD_CTX_destroy(Ctx);
    end;
  finally
    EVP_PKEY_free(Key);
  end;
end;

function EncodeJSON(const KeyFileName: AnsiString; const Json: string): string;
var
  Data: RawByteString;
begin
  if not IdSSLOpenSSLHeaders.Load() then
    raise Exception.Create('Cannot load SSL library');
  Data := UTF8Encode(WideString(Json));
  Result := SHASign(KeyFileName, Data);
end;

end.

