unit fmuMain;

interface

uses
  // VCL
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, ComCtrls, Grids, ValEdit,
  // Tnt
  TntForms, TntDialogs, TntExtCtrls, TntStdCtrls, TntComCtrls,
  // This
  BaseForm, Driver1C, OleArray1C, VLEUtil, untTypes, Driver1C10, Driver1C11;

type
  { TfmMain }

  TfmMain = class(TBaseForm)
    memInfo: TTntMemo;
    edtDeviceID: TTntEdit;
    lblDeviceID: TTntLabel;
    pcMain: TTntPageControl;
    tsCommon: TTntTabSheet;
    tsReceipt: TTntTabSheet;
    btnGetVersion: TTntButton;
    btnGetLastError: TTntButton;
    btnClose: TTntButton;
    btnOpen: TTntButton;
    btnPrintXReport: TTntButton;
    btnPrintZReport: TTntButton;
    btnCashInOutcome: TTntButton;
    btnDeviceTest: TTntButton;
    grpOpenCheck: TTntGroupBox;
    lblCheckNumber: TTntLabel;
    lblSessionNumber: TTntLabel;
    chkIsFiscalCheck: TTntCheckBox;
    chkIsReturnCheck: TTntCheckBox;
    chkCancelOpenedCheck: TTntCheckBox;
    edtCheckNumber: TTntEdit;
    edtSessionNumber: TTntEdit;
    grpCloseCheck: TTntGroupBox;
    lblCash: TTntLabel;
    lblPayByCard: TTntLabel;
    lblPayByCredit: TTntLabel;
    edtCash: TTntEdit;
    edtPayByCard: TTntEdit;
    edtPayByCredit: TTntEdit;
    grpPrintNonFiscalString: TTntGroupBox;
    lblTextString: TTntLabel;
    edtTextString: TTntEdit;
    tsTest: TTntTabSheet;
    grpTestCheck: TTntGroupBox;
    btnTestFiscalReceipt: TTntButton;
    btnTestNonFiscalReceipt: TTntButton;
    Button1: TTntButton;
    bllCashDrawerID: TTntLabel;
    edtCashDrawerID: TTntEdit;
    dlgOpen: TTntOpenDialog;
    tsLoadLogo: TTntTabSheet;
    grp1: TTntGroupBox;
    lbl5: TTntLabel;
    lbl6: TTntLabel;
    edtLogoFileName: TTntEdit;
    chkCenterLogo: TTntCheckBox;
    btnOpenImage: TTntButton;
    edtLogoSize: TTntEdit;
    Splitter1: TTntSplitter;
    pnlParams: TTntPanel;
    vleLogo: TValueListEditor;
    btnOpenSession: TTntButton;
    tsAttitional: TTntTabSheet;
    edtTxData: TTntEdit;
    edtRxData: TTntEdit;
    lblTxData: TTntLabel;
    lblRxData: TTntLabel;
    btnDeviceControl: TTntButton;
    btnDeviceControlHEX: TTntButton;
    lblDiscountOnCheck: TTntLabel;
    edtDiscountOnCheck: TTntEdit;
    cbInterfaceType: TTntComboBox;
    lblInterfaceType: TTntLabel;
    TntGroupBox1: TTntGroupBox;
    memGetParameters: TTntMemo;
    btnGetParameters: TTntButton;
    TntTabSheet1: TTntTabSheet;
    edtBarcode: TTntEdit;
    btnPrintBarcode: TTntButton;
    lblBarcode: TTntLabel;
    btnGetDescription: TTntButton;
    vleParams: TValueListEditor;
    btnTestError: TTntButton;
    btnOpenCheck: TTntButton;
    btnCloseCheck: TTntButton;
    btnPrintNonFiscalString: TTntButton;
    grpPrintFiscalString: TTntGroupBox;
    lblName: TTntLabel;
    lblQuantity: TTntLabel;
    lblPrice: TTntLabel;
    lblAmount: TTntLabel;
    lblDepartment: TTntLabel;
    lblTax: TTntLabel;
    edtName: TTntEdit;
    edtQuantity: TTntEdit;
    edtPrice: TTntEdit;
    edtAmount: TTntEdit;
    edtDepartment: TTntEdit;
    edtTax: TTntEdit;
    btnPrintFiscalString: TTntButton;
    btnContinuePrinting: TTntButton;
    btnCheckPaperStatus: TTntButton;
    btnCancelCheck: TTntButton;
    btnLoadLogo: TTntButton;
    lblGetLineLength: TTntLabel;
    edtLineLength: TTntEdit;
    btnGetLineLength: TTntButton;
    lblPayType4: TTntLabel;
    edtPayByCertificate: TTntEdit;
    tsLang: TTntTabSheet;
    lblLang: TTntLabel;
    cbLang: TTntComboBox;
    btnSetLanguage: TTntButton;
    cbBarcodeType: TTntComboBox;
    lblBarcodeType: TTntLabel;
    procedure btnGetVersionClick(Sender: TObject);
    procedure btnGetLastErrorClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnPrintXReportClick(Sender: TObject);
    procedure btnPrintZReportClick(Sender: TObject);
    procedure btnCashInOutcomeClick(Sender: TObject);
    procedure btnOpenCheckClick(Sender: TObject);
    procedure btnPrintFiscalStringClick(Sender: TObject);
    procedure btnCloseCheckClick(Sender: TObject);
    procedure btnCancelCheckClick(Sender: TObject);
    procedure btnPrintNonFiscalStringClick(Sender: TObject);
    procedure btnDeviceTestClick(Sender: TObject);
    procedure btnCheckPaperStatusClick(Sender: TObject);
    procedure btnContinuePrintingClick(Sender: TObject);
    procedure btnTestFiscalReceiptClick(Sender: TObject);
    procedure btnTestNonFiscalReceiptClick(Sender: TObject);
    procedure btnTestErrorClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnLoadLogoClick(Sender: TObject);
    procedure btnOpenImageClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure vleParamsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure btnOpenSessionClick(Sender: TObject);
    procedure btnDeviceControlClick(Sender: TObject);
    procedure btnDeviceControlHEXClick(Sender: TObject);
    procedure btnGetParametersClick(Sender: TObject);
    procedure btnPrintBarcodeClick(Sender: TObject);
    procedure btnGetDescriptionClick(Sender: TObject);
    procedure cbInterfaceTypeChange(Sender: TObject);
    procedure btnGetLineLengthClick(Sender: TObject);
    procedure btnSetLanguageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FDriver: TDriver1C;
    FInterfaceType: Integer;

    procedure SetValues;
    procedure Initialize;
    procedure UpdateForm(Sender: TObject);
    procedure SetInterfaceType(const Value: Integer);
    procedure AddLine(Sender: TObject; const Line: WideString);
    function GetDriver: TDriver1C;

    property Driver: TDriver1C read GetDriver;
    property InterfaceType: Integer read FInterfaceType write SetInterfaceType;
  public
    destructor Destroy; override;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

{ TfmMain }

destructor TfmMain.Destroy;
begin
  FDriver.Free;
  // VLE workaround
  vleLogo.Strings.Clear;
  vleParams.Strings.Clear;
  inherited Destroy;
end;

function TfmMain.GetDriver: TDriver1C;
begin
  if FDriver = nil then
  begin
    case cbInterfaceType.ItemIndex of
      0: FDriver := TDriver1C10.Create;
    else
      FDriver := TDriver1C11.Create;
    end;
    FDriver.OnLine := AddLine;
    FDriver.OnChange := UpdateForm;
  end;
  Result := FDriver;
end;

procedure TfmMain.AddLine(Sender: TObject; const Line: WideString);
begin
  memInfo.Lines.Add(Line);
  SendMessage(memInfo.Handle, EM_LINESCROLL, 0, memInfo.Lines.Count-1);
end;

procedure TfmMain.Initialize;
begin
  VLE_AddPickProperty(vleParams, 'ConnectionType', '0. Local', ['0. Local', '1. TCP', '2. DCOM', '3. Escape', '4. Сервер печати', '5. Эмулятор ФР', '6. TCP socket'], [0, 1, 2, 3, 4, 5, 6]);
  VLE_AddPickProperty(vleParams, 'ProtocolType', '0. Стандартный', ['0. Стандартный', '1. Протокол ККТ 2.0'], [0, 1]);
  VLE_AddProperty(vleParams, 'Port', '1');
  VLE_AddPickProperty(vleParams, 'Speed', '19200', ['2400', '4800', '9600', '19200', '38400', '57600', '115200'], [2400, 4800, 9600, 19200, 38400, 57600, 115200]);
  VLE_AddProperty(vleParams, 'UserPassword', '1');
  VLE_AddProperty(vleParams, 'AdminPassword', '30');
  VLE_AddProperty(vleParams, 'Timeout', '100');
  VLE_AddProperty(vleParams, 'ComputerName', '');
  VLE_AddProperty(vleParams, 'IPAddress', '');
  VLE_AddProperty(vleParams, 'TCPPort', '211');
  VLE_AddProperty(vleParams, 'SerialNumber', '');
  VLE_AddProperty(vleParams, 'Tax1', '12,32');
  VLE_AddProperty(vleParams, 'Tax2', '15,4');
  VLE_AddProperty(vleParams, 'Tax3', '0,45');
  VLE_AddProperty(vleParams, 'Tax4', '1,34');
  VLE_AddProperty(vleParams, 'PayName1', 'ПЛАТ.КАРТОЙ');
  VLE_AddProperty(vleParams, 'PayName2', 'КРЕДИТОМ');
  VLE_AddProperty(vleParams, 'PayName3', 'СЕРТИФИКАТ');
  VLE_AddPickProperty(vleParams, 'PrintLogo', 'False',  ['True', 'False'], [1, 0]);
  VLE_AddProperty(vleParams, 'LogoSize', '0');
  VLE_AddPickProperty(vleParams, 'CloseSession', 'False',  ['True', 'False'], [1, 0]);
  VLE_AddPickProperty(vleParams, 'EnableLog', 'True',  ['True', 'False'], [1, 0]);

  VLE_AddPickProperty(vleLogo, 'ConnectionType', 'Local', ['Local', 'TCP', 'DCOM', 'TCP socket'], [0, 1, 2, 6]);
  VLE_AddProperty(vleLogo, 'Port', '1');
  VLE_AddPickProperty(vleLogo, 'Speed', '19200', ['2400', '4800', '9600', '19200', '38400', '57600', '115200'], [2400, 4800, 9600, 19200, 38400, 57600, 115200]);
  VLE_AddProperty(vleLogo, 'UserPassword', '1');
  VLE_AddProperty(vleLogo, 'Timeout', '100');
  VLE_AddProperty(vleLogo, 'ComputerName', '');
  VLE_AddProperty(vleLogo, 'IPAddress', '');
  VLE_AddProperty(vleLogo, 'TCPPort', '211');
  VLE_AddPickProperty(vleParams, 'BufferStrings', 'False',  ['True', 'False'], [1, 0]);
  VLE_AddProperty(vleParams, 'BarcodeFirstLine', '1');
  VLE_AddProperty(vleParams, 'QRCodeHeight', '200');
end;

procedure TfmMain.FormShow(Sender: TObject);
begin
  Initialize;
  SetValues;
end;

procedure TfmMain.UpdateForm(Sender: TObject);
var
  decimalsep: Char;
begin
  decimalsep := DecimalSeparator;
  DecimalSeparator := ',';
  try
    if Driver.FDeviceID <> '' then
      edtDeviceID.Text := Driver.FDeviceID;

    edtCheckNumber.Text := IntToStr(Driver.FCheckNumber);
    edtSessionNumber.Text := IntToStr(Driver.FSessionNumber);
    edtLogoSize.Text := IntToStr(Driver.FLogoSize);
    edtRxData.Text := Driver.FRxData;
    edtLineLength.Text := IntToStr(Driver.FLineLength);

    try
      VLE_SetPropertyValue(vleParams, 'SerialNumber', Driver.GetSerialNumber);
      VLE_SetPropertyValue(vleParams, 'LogoSize', IntToStr(Driver.FLogoSize));
    except
      memInfo.Lines.Add('Ошибка в параметрах подключения!');
    end;
  finally
    DecimalSeparator := decimalsep;
  end;
end;

procedure TfmMain.btnGetVersionClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.GetVersion;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.SetValues;
var
  decimalsep: Char;
begin
  decimalsep := DecimalSeparator;
  DecimalSeparator := ',';
  try
    Driver.FDeviceID := edtDeviceID.Text;
    Driver.FName := edtName.Text;
    Driver.FQuantity := StrToFloat(edtQuantity.Text);
    Driver.FPrice := StrToFloat(edtPrice.Text);
    Driver.FAmount := StrToFloat(edtAmount.Text);
    Driver.FDepartment := StrToInt(edtDepartment.Text);
    Driver.FTax := StrToFloat(edtTax.Text);
    Driver.FIsFiscalCheck := chkIsFiscalCheck.Checked;
    Driver.FIsReturnCheck := chkIsReturnCheck.Checked;
    Driver.FCancelOpenedCheck := chkCancelOpenedCheck.Checked;
    Driver.FTextString := edtTextString.Text;
    Driver.FCash := StrToFloat(edtCash.Text);
    Driver.FPayByCard := StrToFloat(edtPayByCard.Text);
    Driver.FPayByCredit := StrToFloat(edtPayByCredit.Text);
    Driver.FPayByCertificate := StrToFloat(edtPayByCertificate.Text);
    Driver.FTxData := edtTxData.Text;
    Driver.FRxData := edtRxData.Text;
    Driver.FDiscountOnCheck := StrToFloat(edtDiscountOnCheck.Text);
    Driver.FBarcode := edtBarCode.Text;
    Driver.FCenterLogo := chkCenterLogo.Checked;
    Driver.FLogoFileName := edtLogoFileName.Text;
    Driver.FBarcodeType := cbBarcodeType.Text;
    Driver.FLogoSize := StrToInt(VLE_GetPropertyValue(vleParams, 'LogoSize'));
    Driver.FConnectionParams.Port := StrToInt(VLE_GetPropertyValue(vleParams, 'Port'));
    Driver.FConnectionParams.Speed := VLE_GetPickPropertyValue(vleParams, 'Speed');
    Driver.FConnectionParams.UserPassword := VLE_GetPropertyValue(vleParams, 'UserPassword');
    Driver.FConnectionParams.AdminPassword :=  VLE_GetPropertyValue(vleParams, 'AdminPassword');
    Driver.FConnectionParams.Timeout := StrToInt(VLE_GetPropertyValue(vleParams, 'Timeout'));
    Driver.FConnectionParams.SerialNumber := '';
    Driver.FConnectionParams.Tax1 := StrToFloat(VLE_GetPropertyValue(vleParams, 'Tax1'));
    Driver.FConnectionParams.Tax2 := StrToFloat(VLE_GetPropertyValue(vleParams, 'Tax2'));
    Driver.FConnectionParams.Tax3 := StrToFloat(VLE_GetPropertyValue(vleParams, 'Tax3'));
    Driver.FConnectionParams.Tax4 := StrToFloat(VLE_GetPropertyValue(vleParams, 'Tax4'));
    Driver.FConnectionParams.CloseSession := VLE_GetPickPropertyValue(vleParams, 'CloseSession') = 1;
    Driver.FConnectionParams.EnableLog := VLE_GetPickPropertyValue(vleParams, 'EnableLog') = 1;
    Driver.FConnectionParams.PayName1 := VLE_GetPropertyValue(vleParams, 'PayName1');
    Driver.FConnectionParams.PayName2 := VLE_GetPropertyValue(vleParams, 'PayName2');
    Driver.FConnectionParams.PayName3 := VLE_GetPropertyValue(vleParams, 'PayName3');
    Driver.FConnectionParams.PrintLogo := VLE_GetPickPropertyValue(vleParams, 'PrintLogo') = 1;
    Driver.FConnectionParams.LogoSize := StrToInt(VLE_GetPropertyValue(vleParams, 'LogoSize'));
    Driver.FConnectionParams.ConnectionType := VLE_GetPickPropertyValue(vleParams, 'ConnectionType');
    Driver.FConnectionParams.ComputerName :=  VLE_GetPropertyValue(vleParams, 'ComputerName');
    Driver.FConnectionParams.IPAddress := VLE_GetPropertyValue(vleParams, 'IPAddress');
    Driver.FConnectionParams.TCPPort := StrToInt(VLE_GetPropertyValue(vleParams, 'TCPPort'));
    Driver.FConnectionParams.ProtocolType := VLE_GetPickPropertyValue(vleParams, 'ProtocolType');
    Driver.FConnectionParams.BufferStrings := VLE_GetPickPropertyValue(vleParams, 'BufferStrings') = 1;
    Driver.FConnectionParams.BarcodeFirstLine := StrToInt(VLE_GetPropertyValue(vleParams, 'BarcodeFirstLine'));
    Driver.FConnectionParams.QRCodeHeight := StrToInt(VLE_GetPropertyValue(vleParams, 'QRCodeHeight'));
    Driver.SetConnectionParams;
  finally
    DecimalSeparator := decimalsep;
  end;
end;

procedure TfmMain.btnGetLastErrorClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.GetLastError;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnOpenClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.Open;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnCloseClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.Close;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnPrintXReportClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.PrintXReport;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnPrintZReportClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.PrintZReport;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnCashInOutcomeClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.CashInOutcome;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnOpenCheckClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.OpenCheck;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnPrintFiscalStringClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.PrintFiscalString;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnCloseCheckClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.CloseCheck;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnCancelCheckClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.CancelCheck;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnPrintNonFiscalStringClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.PrintNonFiscalString;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnDeviceTestClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.DeviceTest;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnCheckPaperStatusClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.CheckPrintingStatus;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnContinuePrintingClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.ContinuePrinting;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnTestFiscalReceiptClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.PrintTestFiscalReceipt;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnTestNonFiscalReceiptClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.PrintTestNonFiscalReceipt;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnTestErrorClick(Sender: TObject);
begin
  Driver.TestError;
end;

procedure TfmMain.Button1Click(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.OpenCashDrawer(StrToInt(edtCashDrawerID.Text));
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnLoadLogoClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.LoadLogo;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnOpenImageClick(Sender: TObject);
begin
  if not dlgOpen.Execute then Exit;
  edtLogoFileName.Text := dlgOpen.FileName;
end;

procedure TfmMain.vleParamsDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  VLE_DrawCell(Sender, ACol, ARow, Rect, State);
end;

procedure TfmMain.btnOpenSessionClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.OpenSession;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnDeviceControlClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.DeviceControl;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnDeviceControlHEXClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.DeviceControlHEX;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnGetParametersClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    memGetParameters.Text := Driver.GetParameters;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnPrintBarcodeClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.PrintBarCode;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnGetDescriptionClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.GetDescription;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.cbInterfaceTypeChange(Sender: TObject);
begin
  InterfaceType := cbInterfaceType.ItemIndex;
end;

procedure TfmMain.SetInterfaceType(const Value: Integer);
begin
  if Value <> InterfaceType then
  begin
    FDriver.Free;
    FDriver := nil;
  end;
  FInterfaceType := Value;
end;

procedure TfmMain.btnGetLineLengthClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.GetLineLength;
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.btnSetLanguageClick(Sender: TObject);
begin
  EnableButtons(False);
  try
    SetValues;
    Driver.SetLang(cbLang.ItemIndex);
  finally
    EnableButtons(True);
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  FInterfaceType := 1;
  SetInterfaceType(1);
end;

end.
