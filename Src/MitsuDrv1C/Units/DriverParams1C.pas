unit DriverParams1C;

interface

uses
  // VCL
  SysUtils;

const
  IdxConnectionType = 0;
  IdxPortName = 1;
  IdxBaudRate = 2;
  IdxByteTimeout = 3;
  IdxRemoteHost = 4;
  IdxRemotePort = 5;
  IdxLogPath = 6;
  IdxLogEnabled = 7;
  IdxCashierName = 8;
  IdxCashierINN = 9;
  IdxPrintRequired = 10;
  IdxSaleAddress = 11;
  IdxSaleLocation = 12;
  IdxExtendedProperty = 13;
  IdxExtendedData = 14;
  IdxTaxSystem = 15;
  IdxAutomaticNumber = 16;
  IdxSenderEmail = 17;
  IdxSerialNumber = 18;

type
  { TDriverParams }

  TDriverParams = record
    ConnectionType: Integer;
    PortName: AnsiString;
    BaudRate: Integer;
    ByteTimeout: Integer;
    RemoteHost: AnsiString;
    RemotePort: Integer;
    LogPath: WideString;
    LogEnabled: Boolean;

    CashierName: WideString;
    CashierINN: WideString;
    PrintRequired: Boolean;
    SaleAddress: WideString; // Адрес проведения расчетов
    SaleLocation: WideString; // Место проведения расчетов
    ExtendedProperty: WideString; // дополнительный реквизит ОР
    ExtendedData: WideString; // дополнительные данные ОР
    TaxSystem: Integer; // Система налогообложения
    AutomaticNumber: WideString; // Номер автомата для автоматического режима
    SenderEmail: WideString; // Адрес электронной почты отправителя чека

    SerialNumber: WideString;

    (*
    Correction: TMTSCorrection;
    AdminPassword: Integer;
    CloseSession: Boolean;
    BarcodeFirstLine: Integer;
    QRCodeHeight: Integer;
    EnablePaymentSignPrint: Boolean;
    QRCodeDotWidth: Integer;
    ItemNameLength: Integer;
    CheckFontNumber: Integer;
    EnableNonFiscalHeader: Boolean;
    EnableNonFiscalFooter: Boolean;
    FormatVersion: Integer;
    DisablePrintReports: Boolean;
    CheckClock: Boolean;
    UseRepeatDocument: Boolean;
    *)
  end;

function GetParamName(Index: Integer): string;
function GetParamValue(V: Variant; Index: Integer): Variant;
function GetStrParamValue(V: Variant; Index: Integer): string;
function GetIntParamValue(V: Variant; Index: Integer): Integer;
function GetBoolParamValue(V: Variant; Index: Integer): Boolean;
procedure SetParamValue(V: Variant; Index: Integer; Value: Variant);

function ReadDriverParams(V: Variant): TDriverParams;
procedure WriteDriverParams(V: Variant; const Params: TDriverParams);

implementation

function ReadDriverParams(V: Variant): TDriverParams;
begin
  Result.ConnectionType := GetIntParamValue(V, IdxConnectionType);
  Result.PortName := GetStrParamValue(V, IdxPortName);
  Result.BaudRate := GetIntParamValue(V, IdxBaudRate);
  Result.ByteTimeout := GetIntParamValue(V, IdxByteTimeout);
  Result.RemoteHost := GetStrParamValue(V, IdxRemoteHost);
  Result.RemotePort := GetIntParamValue(V, IdxRemotePort);
  Result.LogPath := GetStrParamValue(V, IdxLogPath);
  Result.LogEnabled := GetBoolParamValue(V, IdxLogEnabled);
  Result.CashierName := GetStrParamValue(V, IdxCashierName);
  Result.CashierINN := GetStrParamValue(V, IdxCashierINN);
  Result.PrintRequired := GetBoolParamValue(V, IdxPrintRequired);
  Result.SaleAddress := GetParamValue(V, IdxSaleAddress);
  Result.SaleLocation := GetParamValue(V, IdxSaleLocation);
  Result.ExtendedProperty := GetParamValue(V, IdxExtendedProperty);
  Result.ExtendedData := GetParamValue(V, IdxExtendedData);
  Result.TaxSystem := GetParamValue(V, IdxTaxSystem);
  Result.AutomaticNumber := GetParamValue(V, IdxAutomaticNumber);
  Result.SenderEmail := GetParamValue(V, IdxSenderEmail);
  Result.SerialNumber := GetParamValue(V, IdxSerialNumber);
end;

procedure WriteDriverParams(V: Variant; const Params: TDriverParams);
begin
  SetParamValue(V, IdxConnectionType, Params.ConnectionType);
  SetParamValue(V, IdxPortName, Params.PortName);
  SetParamValue(V, IdxBaudRate, Params.BaudRate);
  SetParamValue(V, IdxByteTimeout, Params.ByteTimeout);
  SetParamValue(V, IdxRemoteHost, Params.RemoteHost);
  SetParamValue(V, IdxRemotePort, Params.RemotePort);
  SetParamValue(V, IdxLogPath, Params.LogPath);
  SetParamValue(V, IdxLogEnabled, Params.LogEnabled);
  SetParamValue(V, IdxCashierName, Params.CashierName);
  SetParamValue(V, IdxCashierINN, Params.CashierINN);
  SetParamValue(V, IdxPrintRequired, Params.PrintRequired);
  SetParamValue(V, IdxSaleAddress, Params.SaleAddress);
  SetParamValue(V, IdxSaleLocation, Params.SaleLocation);
  SetParamValue(V, IdxExtendedProperty, Params.ExtendedProperty);
  SetParamValue(V, IdxExtendedData, Params.ExtendedData);
  SetParamValue(V, IdxTaxSystem, Params.TaxSystem);
  SetParamValue(V, IdxAutomaticNumber, Params.AutomaticNumber);
  SetParamValue(V, IdxSenderEmail, Params.SenderEmail);
  SetParamValue(V, IdxSerialNumber, Params.SerialNumber);
end;

function GetParamName(Index: Integer): string;
begin
  case Index of
    IdxConnectionType: Result := 'ConnectionType';
    IdxPortName: Result := 'PortName';
    IdxBaudRate: Result := 'BaudRate';
    IdxByteTimeout: Result := 'ByteTimeout';
    IdxRemoteHost: Result := 'RemoteHost';
    IdxRemotePort: Result := 'RemotePort';
    IdxLogPath: Result := 'LogPath';
    IdxLogEnabled: Result := 'LogEnabled';
    IdxCashierName: Result := 'CashierName';
    IdxCashierINN: Result := 'CashierINN';
    IdxPrintRequired: Result := 'PrintRequired';
  else
    Result := 'Unknown'
  end;
end;

function GetIntParamValue(V: Variant; Index: Integer): Integer;
begin
  Result := Integer(GetParamValue(V, Index));
end;

function GetStrParamValue(V: Variant; Index: Integer): string;
begin
  Result := String(GetParamValue(V, Index));
end;

function GetBoolParamValue(V: Variant; Index: Integer): Boolean;
begin
  Result := Boolean(GetParamValue(V, Index));
end;

function GetParamValue(V: Variant; Index: Integer): Variant;
var
  Msg: string;
begin
  try
    Result := V.Get(Index);
  except
    on E: Exception do
    begin
      Msg := Format('Failed to get value, name=%s', [GetParamName(Index)]);
      E.Message := Msg + E.Message;
      raise;
    end;
  end;
end;

procedure SetParamValue(V: Variant; Index: Integer; Value: Variant);
var
  Msg: string;
begin
  try
    V.Set(Index, Value);
  except
    on E: Exception do
    begin
      Msg := Format('Failed to set value, name=%s', [GetParamName(Index)]);
      E.Message := Msg + E.Message;
      raise;
    end;
  end;
end;

end.
