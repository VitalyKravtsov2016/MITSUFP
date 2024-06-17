unit fmuMain;

interface

uses
  // VCL
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, ComCtrls, Grids, ValEdit,
  // This
  BaseForm, Driver1C, OleArray1C, VLEUtil, Driver1C10, Driver1C11,
  DriverParams1C;

type
  { TfmMain }

  TfmMain = class(TBaseForm)
    memInfo: TMemo;
    edtDeviceID: TEdit;
    lblDeviceID: TLabel;
    pcMain: TPageControl;
    tsCommon: TTabSheet;
    tsReceipt: TTabSheet;
    btnGetVersion: TButton;
    btnGetLastError: TButton;
    btnClose: TButton;
    btnOpen: TButton;
    btnPrintXReport: TButton;
    btnPrintZReport: TButton;
    btnCashInOutcome: TButton;
    btnDeviceTest: TButton;
    grpOpenCheck: TGroupBox;
    lblCheckNumber: TLabel;
    lblSessionNumber: TLabel;
    chkIsFiscalCheck: TCheckBox;
    chkIsReturnCheck: TCheckBox;
    chkCancelOpenedCheck: TCheckBox;
    edtCheckNumber: TEdit;
    edtSessionNumber: TEdit;
    grpCloseCheck: TGroupBox;
    lblCash: TLabel;
    lblPayByCard: TLabel;
    lblPayByCredit: TLabel;
    edtCash: TEdit;
    edtPayByCard: TEdit;
    edtPayByCredit: TEdit;
    grpPrintNonFiscalString: TGroupBox;
    lblTextString: TLabel;
    edtTextString: TEdit;
    tsTest: TTabSheet;
    grpTestCheck: TGroupBox;
    btnTestFiscalReceipt: TButton;
    btnTestNonFiscalReceipt: TButton;
    Button1: TButton;
    bllCashDrawerID: TLabel;
    edtCashDrawerID: TEdit;
    dlgOpen: TOpenDialog;
    tsLoadLogo: TTabSheet;
    grp1: TGroupBox;
    lbl5: TLabel;
    lbl6: TLabel;
    edtLogoFileName: TEdit;
    chkCenterLogo: TCheckBox;
    btnOpenImage: TButton;
    edtLogoSize: TEdit;
    Splitter1: TSplitter;
    pnlParams: TPanel;
    vleLogo: TValueListEditor;
    btnOpenSession: TButton;
    tsAttitional: TTabSheet;
    edtTxData: TEdit;
    edtRxData: TEdit;
    lblTxData: TLabel;
    lblRxData: TLabel;
    btnDeviceControl: TButton;
    btnDeviceControlHEX: TButton;
    lblDiscountOnCheck: TLabel;
    edtDiscountOnCheck: TEdit;
    cbInterfaceType: TComboBox;
    lblInterfaceType: TLabel;
    TntGroupBox1: TGroupBox;
    memGetParameters: TMemo;
    btnGetParameters: TButton;
    TntTabSheet1: TTabSheet;
    edtBarcode: TEdit;
    btnPrintBarcode: TButton;
    lblBarcode: TLabel;
    btnGetDescription: TButton;
    vleParams: TValueListEditor;
    btnTestError: TButton;
    btnOpenCheck: TButton;
    btnCloseCheck: TButton;
    btnPrintNonFiscalString: TButton;
    grpPrintFiscalString: TGroupBox;
    lblName: TLabel;
    lblQuantity: TLabel;
    lblPrice: TLabel;
    lblAmount: TLabel;
    lblDepartment: TLabel;
    lblTax: TLabel;
    edtName: TEdit;
    edtQuantity: TEdit;
    edtPrice: TEdit;
    edtAmount: TEdit;
    edtDepartment: TEdit;
    edtTax: TEdit;
    btnPrintFiscalString: TButton;
    btnContinuePrinting: TButton;
    btnCheckPaperStatus: TButton;
    btnCancelCheck: TButton;
    btnLoadLogo: TButton;
    lblGetLineLength: TLabel;
    edtLineLength: TEdit;
    btnGetLineLength: TButton;
    lblPayType4: TLabel;
    edtPayByCertificate: TEdit;
    tsLang: TTabSheet;
    lblLang: TLabel;
    cbLang: TComboBox;
    btnSetLanguage: TButton;
    cbBarcodeType: TComboBox;
    lblBarcodeType: TLabel;
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
  VLE_AddPickProperty(vleParams, 'ConnectionType', '0. Serial', ['0. Serial', '1. TCP'], [0, 1]);
  VLE_AddPickProperty(vleParams, 'PortName', 'COM8',
    ['COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8'],
    [0, 1, 2, 3, 4, 5, 6, 7]);
  VLE_AddPickProperty(vleParams, 'BaudRate', '115200', ['2400', '4800', '9600', '19200', '38400', '57600', '115200'], [2400, 4800, 9600, 19200, 38400, 57600, 115200]);
  VLE_AddProperty(vleParams, 'ByteTimeout', '100');
  VLE_AddProperty(vleParams, 'RemoteHost', '');
  VLE_AddProperty(vleParams, 'RemotePort', '211');
  VLE_AddProperty(vleParams, 'SerialNumber', '');
  VLE_AddPickProperty(vleParams, 'LogEnabled', 'True',  ['True', 'False'], [1, 0]);

  VLE_AddProperty(vleParams, 'CashierName', 'CashierName');
  VLE_AddProperty(vleParams, 'CashierINN', '505303696069');
  VLE_AddProperty(vleParams, 'PrintRequired', '1');
  VLE_AddProperty(vleParams, 'SaleAddress', 'SaleAddress');
  VLE_AddProperty(vleParams, 'SaleLocation', 'SaleLocation');
  VLE_AddProperty(vleParams, 'ExtendedProperty', '');
  VLE_AddProperty(vleParams, 'ExtendedData', '');
  VLE_AddProperty(vleParams, 'TaxSystem', '0');
  VLE_AddProperty(vleParams, 'AutomaticNumber', '0');
  VLE_AddProperty(vleParams, 'SenderEmail', '');
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
  decimalsep := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := ',';
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
    FormatSettings.DecimalSeparator := decimalsep;
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
  decimalsep := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := ',';
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

    Driver.FParams.ConnectionType := VLE_GetPickPropertyValue(vleParams, 'ConnectionType');
    Driver.FParams.PortName := VLE_GetPropertyValue(vleParams, 'PortName');
    Driver.FParams.BaudRate := VLE_GetPickPropertyValue(vleParams, 'BaudRate');
    Driver.FParams.ByteTimeout := StrToInt(VLE_GetPropertyValue(vleParams, 'ByteTimeout'));
    Driver.FParams.SerialNumber := VLE_GetPropertyValue(vleParams, 'SerialNumber');
    Driver.FParams.LogEnabled := VLE_GetPickPropertyValue(vleParams, 'LogEnabled') = 1;
    Driver.FParams.RemoteHost := VLE_GetPropertyValue(vleParams, 'RemoteHost');
    Driver.FParams.RemotePort := StrToInt(VLE_GetPropertyValue(vleParams, 'RemotePort'));
    Driver.FParams.PrintRequired := VLE_GetPickPropertyValue(vleParams, 'PrintRequired') = 1;
    Driver.FParams.CashierName := VLE_GetPropertyValue(vleParams, 'CashierName');
    Driver.FParams.CashierINN := VLE_GetPropertyValue(vleParams, 'CashierINN');
    Driver.FParams.SaleAddress := VLE_GetPropertyValue(vleParams, 'SaleAddress');
    Driver.FParams.SaleLocation := VLE_GetPropertyValue(vleParams, 'SaleLocation');
    Driver.FParams.ExtendedProperty := VLE_GetPropertyValue(vleParams, 'ExtendedProperty');
    Driver.FParams.ExtendedData := VLE_GetPropertyValue(vleParams, 'ExtendedData');
    Driver.FParams.TaxSystem := StrToInt(VLE_GetPropertyValue(vleParams, 'TaxSystem'));
    Driver.FParams.AutomaticNumber := VLE_GetPropertyValue(vleParams, 'AutomaticNumber');
    Driver.FParams.SenderEmail := VLE_GetPropertyValue(vleParams, 'SenderEmail');

(*
    Driver.FLogoSize := StrToInt(VLE_GetPropertyValue(vleParams, 'LogoSize'));
    Driver.FParams.Tax1 := StrToFloat(VLE_GetPropertyValue(vleParams, 'Tax1'));
    Driver.FParams.Tax2 := StrToFloat(VLE_GetPropertyValue(vleParams, 'Tax2'));
    Driver.FParams.Tax3 := StrToFloat(VLE_GetPropertyValue(vleParams, 'Tax3'));
    Driver.FParams.Tax4 := StrToFloat(VLE_GetPropertyValue(vleParams, 'Tax4'));
    Driver.FParams.CloseSession := VLE_GetPickPropertyValue(vleParams, 'CloseSession') = 1;
    Driver.FParams.PayName1 := VLE_GetPropertyValue(vleParams, 'PayName1');
    Driver.FParams.PayName2 := VLE_GetPropertyValue(vleParams, 'PayName2');
    Driver.FParams.PayName3 := VLE_GetPropertyValue(vleParams, 'PayName3');
    Driver.FParams.PrintLogo := VLE_GetPickPropertyValue(vleParams, 'PrintLogo') = 1;
    Driver.FParams.LogoSize := StrToInt(VLE_GetPropertyValue(vleParams, 'LogoSize'));
    Driver.FParams.BufferStrings := VLE_GetPickPropertyValue(vleParams, 'BufferStrings') = 1;
    Driver.FParams.BarcodeFirstLine := StrToInt(VLE_GetPropertyValue(vleParams, 'BarcodeFirstLine'));
    Driver.FParams.QRCodeHeight := StrToInt(VLE_GetPropertyValue(vleParams, 'QRCodeHeight'));
    Driver.FParams.UserPassword := VLE_GetPropertyValue(vleParams, 'UserPassword');
    Driver.FParams.AdminPassword :=  VLE_GetPropertyValue(vleParams, 'AdminPassword');
*)

    Driver.SetConnectionParams;
  finally
    FormatSettings.DecimalSeparator := decimalsep;
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
