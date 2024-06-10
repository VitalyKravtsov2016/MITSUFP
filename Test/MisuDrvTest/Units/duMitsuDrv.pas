unit duMitsuDrv;

interface

uses
  // This
  XMLDoc, XmlIntf, SysUtils, Math,
  // DUnit
  TestFramework,
  // This
  MitsuDrv, StringUtils, FileUtils, FFDTypes;

type
  { TMitsuDrvTest }

  TMitsuDrvTest = class(TTestCase)
  private
    Driver: TMitsuDrv;
    procedure TestReadVATNames;
    procedure InitPrinter;
  protected
    procedure Setup; override;
    procedure TearDown; override;
  published
    procedure TestXmlParser;
    procedure TestXmlWriter;
    procedure TestCommandCrc;
    procedure TestReadDeviceName;
    procedure TestReadDeviceVersion;
    procedure TestReadCashier;
    procedure TestReadPrinterParams;
    procedure TestReadDrawerParams;
    procedure TestReadBaudRate;
    procedure TestReadText;
    procedure TestReadLANParams;
    procedure TestReadFDOParams;
    procedure TestReadOISMParams;
    procedure TestReadOKPParams;
    procedure TestCommands;
    procedure TestReadRegParams;
    procedure TestReadDayStatus;
    procedure TestReadDayTotalsReceipts;
    procedure TestReadDayTotalsCorrection;
    procedure TestReadFDStatus;
    procedure TestReadFDOStatus;
    procedure TestReadMCStatus;
    procedure TestReadOISMStatus;
    procedure TestReadKeysStatus;
    procedure TestReadDocStatus;
    procedure TestReadFD;
    procedure TestReadFD2;
    procedure TestReadPowerLost;
    procedure TestReadOptions;

    procedure TestWriteDate;
    procedure TestWriteCashier;
    procedure TestWriteBaudRate;

    procedure TestFiscalReceiptCancel;
    procedure TestFiscalReceipt;

    procedure TestPrintText;
    procedure TestPrintBarcode;
    procedure TestPrintQRCode;
    procedure TestPrintPicture;
    procedure TestPrintLine;
    procedure TestCheckMarkCode;
    procedure TestPrintCalcReport;
    procedure TestPrintXReport;
  end;

implementation

{ TDriver1CstTest }

procedure TMitsuDrvTest.Setup;
var
  Params: TMitsuParams;
begin
  Driver := TMitsuDrv.Create;
  Params.ConnectionType := ConnectionTypeSerial;
  Params.PortName := 'COM8';
  Params.BaudRate := 115200;
  Params.ByteTimeout := 1000;
  Params.RemoteHost := '';
  Params.RemotePort := 0;
  Params.LogPath := GetModulePath;
  Params.LogEnabled := True;
  Driver.Params := Params;
end;

procedure TMitsuDrvTest.TearDown;
begin
  Driver.Free;
end;

procedure TMitsuDrvTest.TestXmlParser;
var
  Doc: XmlIntf.IXMLDocument;
const
  Data = '<GET DATE=''1'' TIME=''2''/>';
  Data2 = '<OK TAX=''T1:20%, T2:10%, T3:20/120, T4:10/110, T5:0%, T6:ÁÅÇ ÍÄÑ''/>';
  Data3 = '<OK LENGTH=''512''>3C44</OK>';
begin
  Doc := LoadXMLData(Data);
  CheckEquals('GET', Doc.DocumentElement.NodeName, 'Doc.DocumentElement.NodeName');
  CheckEquals('1', Doc.DocumentElement.GetAttributeNS('DATE', ''));
  CheckEquals('2', Doc.DocumentElement.GetAttributeNS('TIME', ''));

  Doc := LoadXMLData(Data3);
  CheckEquals('OK', Doc.DocumentElement.NodeName, 'Doc.DocumentElement.NodeName.2');
  CheckEquals('3C44', Doc.DocumentElement.Text, 'DocumentElement.Text');

(*
  Doc := LoadXMLData(Data2);
  CheckEquals('OK', Doc.DocumentElement.NodeName, 'Doc.DocumentElement.NodeName');
  CheckEquals('T1:20%, T2:10%, T3:20/120, T4:10/110, T5:0%, T6:ÁÅÇ ÍÄÑ', Doc.DocumentElement.GetAttributeNS('TAX', ''));
*)
end;

procedure TMitsuDrvTest.TestXmlWriter;
var
  Xml: IXMLDocument;
begin
  Xml := NewXMLDocument('');
  Xml.DocumentElement := Xml.CreateElement('REG', '');
  Xml.DocumentElement.SetAttribute('BASE', 0);
  Xml.DocumentElement.SetAttribute('MARK', 1);
  Xml.DocumentElement.SetAttribute('PAWN', 1);
  CheckEquals('<REG BASE="0" MARK="1" PAWN="1"/>', Trim(Xml.XML.Text));
end;

procedure TMitsuDrvTest.TestCommandCrc;
const
  Data = '<GET DATE=''?'' TIME=''?''/>';
  CommandHex = '02 18 00 3C 47 45 54 20 44 41 54 45 3D 27 3F 27 20 54 49 4D 45 3D 27 3F 27 2F 3E 03 63';
var
  Command: AnsiString;
begin
  Command := Driver.EncodeCommand(Data);
  CheckEquals(CommandHex, StrToHex(Command), 'Command');
end;

// <OK DATE='2023-02-06' TIME='08:32:18' />
procedure TMitsuDrvTest.TestCommands;
var
  S: AnsiString;
  Answer: AnsiString;
begin
  // VER
  Driver.Send('<GET VER=''?'' />', Answer);
  CheckEquals('<OK VER=''1.1.06'' SIZE=''296472'' CRC32=''FABD758E'' SERIAL=''065001000000008'' MAC=''00-11-00-4E-00-22'' STS=''00000000''/>', Answer, 'VER');
  // VER DATE
  Driver.Send('<GET VER=''?'' DATE=''?'' />', Answer);
  //CheckEquals('', Answer, 'VER DATE');
  // DATE
  Driver.Send('<GET DATE=''?'' />', Answer);
  S := FormatDateTime('yyyy-mm-dd', Now);
  S := Format('<OK DATE=''%s''/>', [S]);
  CheckEquals(S, Answer, 'DATE');
  // TIME
  Driver.Send('<GET TIME=''?'' />', Answer);
  S := FormatDateTime('hh:nn:ss', Now);
  S := Format('<OK TIME=''%s''/>', [S]);
  //CheckEquals(S, Answer, 'TIME'); !!!
end;

procedure TMitsuDrvTest.TestReadDeviceName;
var
  DeviceName: WideString;
begin
  Driver.Check(Driver.ReadDeviceName(DeviceName));
  CheckEquals('MITSU-1-F', DeviceName, 'DeviceName');
end;

procedure TMitsuDrvTest.TestReadDeviceVersion;
var
  R: TMTSVersion;
begin
  Driver.Check(Driver.ReadDeviceVersion(R));
  CheckEquals('1.1.06', R.Version, 'R.Version');
  CheckEquals('296472', R.Size, 'R.Size');
  //CheckEquals('2071B37A', R.CRC32, 'R.CRC32');
  CheckEquals('065001000000008', R.Serial, 'R.Serial');
  CheckEquals('00-11-00-4E-00-22', R.MAC, 'R.MAC');
  CheckEquals('00000000', R.STS, 'R.STS');
end;

procedure TMitsuDrvTest.TestReadCashier;
var
  R: TMTSCashier;
begin
  Driver.Check(Driver.ReadCashier(R));
  CheckEquals('', R.Name, 'Name');
  CheckEquals('', R.INN, 'INN');
end;

// <OK PRINTER='2' BAUDRATE='115200' PAPER='80' FONT='0' WIDTH='576' LENGTH='48'/>
procedure TMitsuDrvTest.TestReadPrinterParams;
var
  R: TMTSPrinterParams;
begin
  Driver.Check(Driver.ReadPrinterParams(R));
  CheckEquals('2', R.Printer, 'Printer');
  CheckEquals(115200, R.BaudRate, 'BaudRate');
  CheckEquals(80, R.PaperWidth, 'PaperWidth');
  CheckEquals(0, R.FontType, 'FontType');
  CheckEquals(576, R.PrintWidth, 'PrintWidth');
  CheckEquals(48, R.CharWidth, 'CharWidth');
end;

// <OK CD='2' FALL='100' RISE='100'/>
procedure TMitsuDrvTest.TestReadDrawerParams;
var
  R: TMTSDrawerParams;
begin
  Driver.Check(Driver.ReadDrawerParams(R));
  CheckEquals(2, R.Pin, 'Pin');
  CheckEquals(100, R.Rise, 'Rise');
  CheckEquals(100, R.Fall, 'Fall');
end;

procedure TMitsuDrvTest.TestReadBaudRate;
var
  BaudRate: Integer;
begin
  Driver.Check(Driver.ReadBaudRate(BaudRate));
  CheckEquals(115200, BaudRate, 'BaudRate');
end;

procedure TMitsuDrvTest.TestReadText;
var
  Text: TMTSText;
begin
  Text.Number := 2;
  Driver.Check(Driver.ReadText(Text));
  CheckEquals('', Text.Lines[0], 'Text.Lines[0]');
  CheckEquals('', Text.Lines[1], 'Text.Lines[1]');
  CheckEquals('', Text.Lines[2], 'Text.Lines[2]');
  CheckEquals('', Text.Lines[3], 'Text.Lines[3]');
  CheckEquals('', Text.Lines[4], 'Text.Lines[4]');
  CheckEquals('', Text.Lines[5], 'Text.Lines[5]');
  CheckEquals('', Text.Lines[6], 'Text.Lines[6]');
  CheckEquals('', Text.Lines[7], 'Text.Lines[7]');
  CheckEquals('', Text.Lines[8], 'Text.Lines[8]');
  CheckEquals('', Text.Lines[9], 'Text.Lines[9]');
end;

// <OK LAN='192.168.1.100' DNS='192.168.1.1' GW='192.168.1.1' MASK='255.255.255.0' PORT='8200'/>
procedure TMitsuDrvTest.TestReadLANParams;
var
  R: TMTSLANParams;
begin
  Driver.Check(Driver.ReadLANParams(R));
  CheckEquals('192.168.1.100', R.Address, 'Address');
  CheckEquals('192.168.1.1', R.DNS, 'DNS');
  CheckEquals('192.168.1.1', R.Gateway, 'Gateway');
  CheckEquals('255.255.255.0', R.Mask, 'Mask');
  CheckEquals(8200, R.Port, 'Port');
end;

// <OK OFD='' PORT='80' CLIENT='1' TimerFN='30' TimerOFD='5'/>
procedure TMitsuDrvTest.TestReadFDOParams;
var
  R: TMTSFDOParams;
begin
  Driver.Check(Driver.ReadFDOParams(R));
  CheckEquals('', R.Address, 'Address');
  CheckEquals(80, R.Port, 'Port');
  CheckEquals(1, R.Client, 'Client');
  CheckEquals(30, R.FNPollPeriod, 'FNPollPeriod');
  CheckEquals(5, R.FDOPollPeriod, 'FDOPollPeriod');
end;

// <OK OISM='' PORT='80'/>
procedure TMitsuDrvTest.TestReadOISMParams;
var
  R: TMTSOISMParams;
begin
  Driver.Check(Driver.ReadOISMParams(R));
  CheckEquals('', R.Address, 'Address');
  CheckEquals(80, R.Port, 'Port');
end;

procedure TMitsuDrvTest.TestReadOKPParams;
var
  R: TMTSOKPParams;
begin
  Driver.Check(Driver.ReadOKPParams(R));
  CheckEquals('prod01.okp-fn.ru', R.Address, 'Address');
  CheckEquals(26101, R.Port, 'Port');
end;

// T1:20%, T2:10%, T3:20/120, T4:10/110, T5:0%, T6:ÁÅÇ ÍÄÑ
// <OK TAX='T1:20%, T2:10%, T3:20/120, T4:10/110, T5:0%, T6:ÁÅÇ ÍÄÑ'/>
procedure TMitsuDrvTest.TestReadVATNames;
var
  R: TMTSVATNames;
begin
  Driver.Check(Driver.ReadVATNames(R));
  CheckEquals('20%', R[1], 'R[1]');
  CheckEquals('10%', R[2], 'R[2]');
  CheckEquals('20/120', R[3], 'R[3]');
  CheckEquals('10/110', R[4], 'R[4]');
  CheckEquals('0%', R[5], 'R[5]');
  CheckEquals('ÁÅÇ ÍÄÑ', R[6], 'R[6]');
end;

procedure TMitsuDrvTest.TestReadRegParams;
var
  R: TMTSRegParams;
begin
  Driver.Check(Driver.ReadRegParams(R));
  CheckEquals(1, R.RegNumber, 'RegNumber');
  CheckEquals(1, R.FDocNumber, 'FDocNumber');
  CheckEquals('', R.Base, 'Base');
(*
  CheckEquals(0, R.Mode, 'Mode');
  CheckEquals(17, R.ExtMode, 'ExtMode');
  CheckEquals('065001000000008', R.T1013, 'T1013');
  CheckEquals('001', R.T1188, 'T1188');
  CheckEquals('4', R.T1189, 'T1189');
  CheckEquals('4', R.T1190, 'T1190');
  CheckEquals('4', R.T1209, 'T1209');
  CheckEquals('0000000000046409', R.T1037, 'T1037');
  CheckEquals('505303696069', R.T1018, 'T1018');
  CheckEquals('7728699517', R.T1017, 'T1017');
  CheckEquals('', R.T1036, 'T1036');
  CheckEquals('0,1', R.T1062, 'T1062');
  CheckEquals('9999078902007739', R.T1041, 'T1041');
  CheckEquals('V1', R.T1048, 'T1048');
  CheckEquals('1', R.T1009, 'T1009');
  CheckEquals('1', R.T1187, 'T1187');
  CheckEquals('ßÐÓÑ', R.T1046, 'T1046');
  CheckEquals('v@mail.ru', R.T1117, 'T1117');
  CheckEquals('www.nalog.gov.ru', R.T1060, 'T1060');
*)  
end;

// <OK SHIFT='1' STATE='1' COUNT='2' KeyValid='410'></OK>
procedure TMitsuDrvTest.TestReadDayStatus;
var
  R: TMTSDayStatus;
begin
  Driver.Check(Driver.ReadDayStatus(R));
  CheckEquals(1, R.DayNumber, 'DayNumber');
  CheckEquals(1, R.DayStatus, 'DayStatus');
  CheckEquals(2, R.RecNumber, 'RecNumber');
  //CheckEquals(410, R.KeyExpDays, 'KeyExpDays');
end;

// <OK SHIFT='1'><INCOME COUNT='2|0' TOTAL='2000|0' T1136='2000|0' T1138='0|0' T1218='0|0' T1219='0|0' T1220='0|0' T1139='334|0' T1140='0|0' T1141='0|0' T1142='0|0' T1143='0|0' T1183='0|0'/><PAYOUT COUNT='0|0'/></OK>
procedure TMitsuDrvTest.TestReadDayTotalsReceipts;
var
  R: TMTSDayTotals;
begin
  Driver.Check(Driver.ReadDayTotalsReceipts(R));
end;

procedure TMitsuDrvTest.TestReadDayTotalsCorrection;
var
  R: TMTSDayTotals;
begin
  Driver.Check(Driver.ReadDayTotalsCorrection(R));
end;

(*
<OK FN='9999078902014447' FFD='1.2' PHASE='0x03' REG='3|27' VALID='2024-07-17'
LAST='80' DATE='2023-04-27' TIME='23:00' FLAG='0x08'> </OK>
*)

procedure TMitsuDrvTest.TestReadFDStatus;
var
  R: TMTSFDStatus;
begin
  Driver.Check(Driver.ReadFDStatus(R));
end;

// <OK FN='9999078902007739' COUNT='4' FIRST='1' DATE='2024-05-01' TIME='16:19'/>
procedure TMitsuDrvTest.TestReadFDOStatus;
var
  R: TMTSFDOStatus;
begin
  Driver.Check(Driver.ReadFDOStatus(R));
  CheckEquals('9999078902007739', R.Serial, 'Serial');
end;

// <OK MARK='1' KEEP='0' FLAG='0x05' NOTICE='0' HOLDS='0'PENDING='1' WARNING='0'/>
procedure TMitsuDrvTest.TestReadMCStatus;
var
  R: TMTSMCStatus;
begin
  Driver.Check(Driver.ReadMCStatus(R));
end;

procedure TMitsuDrvTest.TestReadOISMStatus;
var
  R: TOISMStatus;
begin
  Driver.Check(Driver.ReadOISMStatus(R));
end;

procedure TMitsuDrvTest.TestReadKeysStatus;
var
  R: TKeysStatus;
begin
  Driver.Check(Driver.ReadKeysStatus(R));
end;

procedure TMitsuDrvTest.TestReadDocStatus;
var
  R: TDocStatus;
begin
  Driver.Check(Driver.ReadDocStatus(0, R));
end;

procedure TMitsuDrvTest.TestReadFD;
var
  i: Integer;
  R: TFDParams;
  Count: Integer;
  DocData: AnsiString;
  BlockData: AnsiString;
const
  BlockSize = 512;
begin
  Driver.Check(Driver.ReadFDDoc(1, R));
  if R.Size > 0 then
  begin
    Count := (R.Size + BlockSize-1) div BlockSize;
    DocData := '';
    for i := 0 to Count-1 do
    begin
      Driver.Check(Driver.ReadFDData(R.Offset, Min(R.Size, BlockSize), BlockData));
      DocData := DocData + BlockData;
      Inc(R.Offset, BlockSize);
      Dec(R.Size, BlockSize);
    end;
  end;
  WriteFileData('Document.xml', DocData);
end;

procedure TMitsuDrvTest.TestReadFD2;
var
  DocData: AnsiString;
begin
  Driver.Check(Driver.ReadFD(1, DocData));
  WriteFileData('Document2.xml', DocData);
end;

procedure TMitsuDrvTest.TestReadPowerLost;
var
  Flag: Boolean;
begin
  Driver.Check(Driver.ReadPowerLost(Flag));
end;

procedure TMitsuDrvTest.TestReadOptions;
var
  Options: Integer;
begin
  Driver.Check(Driver.ReadOptions(Options));
end;

procedure TMitsuDrvTest.TestWriteDate;
begin
  Driver.Check(Driver.WriteDate(Now));
end;

procedure TMitsuDrvTest.TestWriteCashier;
var
  R: TMTSCashier;
begin
  R.Name := 'Test cashier';
  R.INN := '505303696069';
  Driver.Check(Driver.WriteCashier(R));

  R.Name := '';
  R.INN := '';
  Driver.Check(Driver.ReadCashier(R));
  CheckEquals('Test cashier', R.Name, 'Name');
  CheckEquals('505303696069', R.INN, 'INN');
end;

procedure TMitsuDrvTest.TestWriteBaudRate;
begin
  Driver.Check(Driver.WriteBaudRate(115200));
end;

procedure TMitsuDrvTest.TestFiscalReceiptCancel;
var
  Doc: TDocStatus;
  StartDoc: TDocStatus;
  Params: TMTSOpenReceipt;
begin
  Driver.Check(Driver.Reset);
  Driver.Check(Driver.ReadLastDocStatus(StartDoc));
  // Open
  Params.ReceiptType := MTS_RT_SALE;
  Params.TaxSystem := MTS_TS_GENERAL;
  Driver.Check(Driver.OpenReceipt(Params));
  // Read doc status
  Driver.Check(Driver.ReadLastDocStatus(Doc));
  CheckEquals(MTS_DOC_TYPE_RECEIPT, Doc.DocType, 'Doc.DocType');
  CheckEquals(MTS_DOC_STATUS_OPENED, Doc.Status, 'Doc.Status');
  // Cancel
  Driver.Check(Driver.CancelReceipt);
  // Read doc status
  Driver.Check(Driver.ReadLastDocStatus(Doc));
  CheckEquals(StartDoc.Number, Doc.Number, 'Doc.Number');
  CheckEquals(StartDoc.Size, Doc.Size, 'Doc.Size');
  CheckEquals(StartDoc.DocType, Doc.DocType, 'Doc.DocType');
  CheckEquals(StartDoc.Status, Doc.Status, 'Doc.Status');
end;

procedure TMitsuDrvTest.TestFiscalReceipt;
var
  Doc: TDocStatus;
  Position: TMTSPosition;
  Params: TMTSOpenReceipt;
begin
  Driver.Check(Driver.Reset);
  // Open
  Params.ReceiptType := MTS_RT_SALE;
  Params.TaxSystem := MTS_TS_GENERAL;
  Driver.Check(Driver.OpenReceipt(Params));
  // Begin add positions
  Driver.Check(Driver.BeginRecPositions);
  // Add positions
  Position.Quantity := 1.234567;
  Position.TaxRate := MTS_VAT_RATE_NONE;
  Position.UnitValue := 0;
  Position.Price := 12345; // 15241 +- 1
  Position.Total := 15241;
  Position.ItemType := 1;
  Position.PaymentType := 4;
  Position.ExciseTaxTotal := 0;
  Position.CountryCode := Format('%.3d', [FFD_CC_RUSSIA]);
  Position.CustomsDeclaration := '';
  Position.Name := 'Item 1';
  Position.Numerator := 0;
  Position.Denominator := 0;
  Position.MarkingCode := '';
  Position.AddAttribute := '';
  Position.AgentType := -1;

  Driver.Check(Driver.AddRecPosition(Position));
end;

procedure TMitsuDrvTest.TestPrintText;
var
  P: TMTSPrintText;
begin
  Driver.Check(Driver.Reset);

  Driver.Check(Driver.OpenNonfiscal);
  // Normal
  P.Text := '1. Normal text';
  P.IsInversion := False;
  P.HorizontalFactor := 0;
  P.VerticalFactor := 0;
  P.FontType := 0;
  P.UnderlineMode := 0;
  P.Alignment := 0;
  Driver.Check(Driver.AddText(P));
  // Inversion
  P.Text := '2. Inverted text';
  P.IsInversion := True;
  P.HorizontalFactor := 0;
  P.VerticalFactor := 0;
  P.FontType := 0;
  P.UnderlineMode := 0;
  P.Alignment := 0;
  Driver.Check(Driver.AddText(P));
  // HorizontalFactor
  P.Text := '3. HorizontalFactor = 2';
  P.IsInversion := False;
  P.HorizontalFactor := 2;
  P.VerticalFactor := 0;
  P.FontType := 0;
  P.UnderlineMode := 0;
  P.Alignment := 0;
  Driver.Check(Driver.AddText(P));
  // VerticalFactor
  P.Text := '4. VerticalFactor = 2';
  P.IsInversion := False;
  P.HorizontalFactor := 0;
  P.VerticalFactor := 2;
  P.FontType := 0;
  P.UnderlineMode := 0;
  P.Alignment := 0;
  Driver.Check(Driver.AddText(P));
  // FontType = 1
  P.Text := '5. FontType = 1';
  P.IsInversion := False;
  P.HorizontalFactor := 0;
  P.VerticalFactor := 0;
  P.FontType := 1;
  P.UnderlineMode := 0;
  P.Alignment := 0;
  Driver.Check(Driver.AddText(P));
  // FontType = 2
  P.Text := '6. FontType = 2';
  P.IsInversion := False;
  P.HorizontalFactor := 0;
  P.VerticalFactor := 0;
  P.FontType := 2;
  P.UnderlineMode := 0;
  P.Alignment := 0;
  Driver.Check(Driver.AddText(P));
  // UnderlineMode = 1
  P.Text := '7. UnderlineMode = 1';
  P.IsInversion := False;
  P.HorizontalFactor := 0;
  P.VerticalFactor := 0;
  P.FontType := 0;
  P.UnderlineMode := 1;
  P.Alignment := 0;
  Driver.Check(Driver.AddText(P));
  // UnderlineMode = 2
  P.Text := '8. UnderlineMode = 2';
  P.IsInversion := False;
  P.HorizontalFactor := 0;
  P.VerticalFactor := 0;
  P.FontType := 0;
  P.UnderlineMode := 2;
  P.Alignment := 0;
  Driver.Check(Driver.AddText(P));
  // Align center
  P.Text := '9. Align center';
  P.IsInversion := False;
  P.HorizontalFactor := 0;
  P.VerticalFactor := 0;
  P.FontType := 0;
  P.UnderlineMode := 0;
  P.Alignment := 1;
  Driver.Check(Driver.AddText(P));
  // Align right
  P.Text := '10. Align right';
  P.IsInversion := False;
  P.HorizontalFactor := 0;
  P.VerticalFactor := 0;
  P.FontType := 0;
  P.UnderlineMode := 0;
  P.Alignment := 2;
  Driver.Check(Driver.AddText(P));

  Driver.Check(Driver.CloseNonfiscal(False));
  Driver.Check(Driver.Print);
end;

procedure TMitsuDrvTest.TestPrintBarcode;
var
  Barcode: TMTSBarcode;
begin
  Driver.Check(Driver.Reset);
  Driver.Check(Driver.OpenNonfiscal);
  // UPC-A
  Driver.Check(Driver.AddText('UPC-A'));
  Barcode.BarcodeType := MTS_BARCODE_UPC_A;
  Barcode.ModuleWidth := 2;
  Barcode.BarcodeHeight := 100;
  Barcode.Data := '123456123456';
  Driver.Check(Driver.AddBarcode(Barcode));
(*
  // UPC-E
  Driver.Check(Driver.AddText('UPC-E'));
  Barcode.BarcodeType := MTS_BARCODE_UPC_E;
  Barcode.ModuleWidth := 2;
  Barcode.BarcodeHeight := 100;
  Barcode.Data := '0123456';
  Driver.Check(Driver.AddBarcode(Barcode));
*)
  // EAN13
  Driver.Check(Driver.AddText('EAN13'));
  Barcode.BarcodeType := MTS_BARCODE_EAN13;
  Barcode.ModuleWidth := 2;
  Barcode.BarcodeHeight := 100;
  Barcode.Data := '123456123456';
  Driver.Check(Driver.AddBarcode(Barcode));
  // EAN8
  Driver.Check(Driver.AddText('EAN8'));
  Barcode.BarcodeType := MTS_BARCODE_EAN8;
  Barcode.ModuleWidth := 2;
  Barcode.BarcodeHeight := 100;
  Barcode.Data := '1234568';
  Driver.Check(Driver.AddBarcode(Barcode));
  // CODE39
  Driver.Check(Driver.AddText('CODE39'));
  Barcode.BarcodeType := MTS_BARCODE_CODE39;
  Barcode.ModuleWidth := 2;
  Barcode.BarcodeHeight := 100;
  Barcode.Data := '1234568';
  Driver.Check(Driver.AddBarcode(Barcode));
  // ITF
  Driver.Check(Driver.AddText('ITF'));
  Barcode.BarcodeType := MTS_BARCODE_ITF;
  Barcode.ModuleWidth := 2;
  Barcode.BarcodeHeight := 100;
  Barcode.Data := '1234568';
  Driver.Check(Driver.AddBarcode(Barcode));
  // CODABAR
  Driver.Check(Driver.AddText('CODABAR'));
  Barcode.BarcodeType := MTS_BARCODE_CODABAR;
  Barcode.ModuleWidth := 2;
  Barcode.BarcodeHeight := 100;
  Barcode.Data := '1234568';
  Driver.Check(Driver.AddBarcode(Barcode));
  // CODE93
  Driver.Check(Driver.AddText('CODE93'));
  Barcode.BarcodeType := MTS_BARCODE_CODE93;
  Barcode.ModuleWidth := 2;
  Barcode.BarcodeHeight := 100;
  Barcode.Data := '1234568';
  Driver.Check(Driver.AddBarcode(Barcode));
  // CODE128
  Driver.Check(Driver.AddText('CODE128'));
  Barcode.BarcodeType := MTS_BARCODE_CODE128;
  Barcode.ModuleWidth := 2;
  Barcode.BarcodeHeight := 100;
  Barcode.Data := '123456886876';
  Driver.Check(Driver.AddBarcode(Barcode));

  Driver.Check(Driver.CloseNonfiscal(True));
  Driver.Check(Driver.Print);
end;

procedure TMitsuDrvTest.TestPrintQRCode;
var
  QRCode: TMTSQRCode;
begin
  Driver.Check(Driver.Reset);
  Driver.Check(Driver.OpenNonfiscal);


  QRCode.Data := '182376817236817236';
  QRCode.Text := 'QRCode.Text';
  QRCode.Alignment := MTS_ALIGN_CENTER;
  QRCode.ModuleWidth := 3;
  QRCode.CorrectionLevel := 2;
  Driver.Check(Driver.AddQRCode(QRCode));

  Driver.Check(Driver.CloseNonfiscal(True));
  Driver.Check(Driver.Print);
end;

procedure TMitsuDrvTest.TestPrintPicture;
var
  Picture: TMTSPicture;
begin
  Driver.Check(Driver.Reset);
  Driver.Check(Driver.OpenNonfiscal);

  Picture.PicNumber := 1;
  Picture.Alignment := MTS_ALIGN_CENTER;
  Driver.Check(Driver.AddPicture(Picture));

  Driver.Check(Driver.CloseNonfiscal(False));
  Driver.Check(Driver.Print);
end;

procedure TMitsuDrvTest.TestPrintLine;
begin
  Driver.Check(Driver.Reset);
  Driver.Check(Driver.OpenNonfiscal);

  Driver.Check(Driver.FeedPixels(20));
  Driver.Check(Driver.AddSeparatorLine(MTS_LINE_SINGLE));
  Driver.Check(Driver.AddBlankPixels(20));
  Driver.Check(Driver.FeedPixels(20));
  Driver.Check(Driver.AddSeparatorLine(MTS_LINE_DOUBLE));
  Driver.Check(Driver.AddBlankPixels(20));
  Driver.Check(Driver.AddSeparatorLine(MTS_LINE_THICK));
  Driver.Check(Driver.AddBlankPixels(20));
  Driver.Check(Driver.FeedPixels(20));

  Driver.Check(Driver.CloseNonfiscal(False));
  Driver.Check(Driver.Print);
end;

procedure TMitsuDrvTest.InitPrinter;
var
  Day: TMTSDayStatus;
  Cashier: TMTSCashier;
  DayParams: TMTSDayParams;
begin
  Cashier.Name := 'Cashier1';
  Cashier.INN := '505303696069';
  DayParams.SaleAddress := 'SaleAddress';
  DayParams.SaleLocation := 'SaleLocation';
  DayParams.ExtendedProperty := 'ExtendedProperty';
  DayParams.ExtendedData := 'ExtendedData';
  DayParams.PrintRequired := False;

  Driver.Check(Driver.ReadDayStatus(Day));
  case Day.DayStatus of
    MTS_DAY_STATUS_CLOSED:
    begin
      Driver.Check(Driver.WriteCashier(Cashier));
      Driver.Check(Driver.OpenFiscalDay(DayParams));
    end;
    MTS_DAY_STATUS_OPENED:;
    MTS_DAY_STATUS_EXPIRED:
    begin
      Driver.Check(Driver.WriteCashier(Cashier));
      Driver.Check(Driver.CloseFiscalDay(DayParams));
    end;
  else
    raise Exception.Create('Unknown day status value');
  end;

  Driver.Check(Driver.Reset);
end;

procedure TMitsuDrvTest.TestCheckMarkCode;
const
  MarkCode = '00000046210654NKZaYPiAAModGVz';
var
  Params: TMTSOpenReceipt;
  CheckResult: TMTSMarkCheck;
begin
  InitPrinter;
  // Open receipt
  Params.ReceiptType := MTS_RT_SALE;
  Params.TaxSystem := MTS_TS_GENERAL;
  Driver.Check(Driver.OpenReceipt(Params));
  // Check mark code
  Driver.Check(Driver.MCCheckMarkingCode(MarkCode, CheckResult));
end;

procedure TMitsuDrvTest.TestPrintCalcReport;
var
  R: TMTSCalcReport;
begin
  Driver.Check(Driver.MakeCalcReport(R));
  Driver.Check(Driver.Print);
end;

procedure TMitsuDrvTest.TestPrintXReport;
var
  R: TMTSDayStatus;
begin
  Driver.Check(Driver.MakeXReport(R));
  Driver.Check(Driver.Print);
end;

initialization
  RegisterTest('', TMitsuDrvTest.Suite);

end.
