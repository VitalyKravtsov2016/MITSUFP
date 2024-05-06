library MitsuDrv1C;

uses
  Forms,
  SMDrvFR1CLib_TLB in 'SMDrvFR1CLib_TLB.pas',
  oleMain in 'Units\oleMain.pas' {smDrvFR1C: CoClass},
  untLogger in '..\Shared\untLogger.pas',
  LogFile in '..\Shared\LogFile.pas',
  GlobalConst in '..\Shared\GlobalConst.pas',
  untAxCtrls in 'Units\untAxCtrls.pas',
  AxCtrls2 in 'Units\AxCtrls2.pas',
  ActiveXControl1C in 'Units\ActiveXControl1C.pas',
  TextEncoding in 'Units\TextEncoding.pas',
  VersionInfo in '..\Shared\VersionInfo.pas',
  ActiveXView in '..\Shared\ActiveXView.pas',
  AddIn1CInterface in '..\Shared\AddIn1CInterface.pas',
  AddIn1CTypes in '..\Shared\AddIn1CTypes.pas',
  Devices1C in 'Units\Devices1C.pas',
  Devices1C3 in 'Units\Devices1C3.pas',
  Devices3 in 'Units\Devices3.pas',
  Driver1Cst in 'Units\Driver1Cst.pas',
  Driver1Cst17 in 'Units\Driver1Cst17.pas',
  Driver1Cst22 in 'Units\Driver1Cst22.pas',
  Driver1Cst30 in 'Units\Driver1Cst30.pas',
  MitsuDrv in 'Units\MitsuDrv.pas',
  OleMain1C17 in 'Units\OleMain1C17.pas',
  OleMain1C22 in 'Units\OleMain1C22.pas',
  OleMain1C30 in 'Units\OleMain1C30.pas',
  OleMain17 in 'Units\OleMain17.pas',
  WException in '..\Shared\WException.pas',
  oleMain1C10 in 'Units\oleMain1C10.pas',
  oleMain1C11 in 'Units\oleMain1C11.pas',
  DrvFR1CLib_TLB in '..\MitsuDrv\DrvFR1CLib_TLB.pas',
  ComObj2 in 'Units\ComObj2.pas',
  ComServ2 in 'Units\ComServ2.pas',
  PrinterTypes in '..\Shared\PrinterTypes.pas',
  StringUtils in '..\Shared\StringUtils.pas',
  DriverError in '..\Shared\DriverError.pas',
  Types1C in 'Units\Types1C.pas',
  Params1C in 'Units\Params1C.pas',
  DriverTypes in '..\Shared\DriverTypes.pas',
  LangUtils in '..\TstShared\LangUtils.pas',
  Driver1CParams in 'Units\Driver1CParams.pas',
  BinUtils in '..\TstShared\BinUtils.pas',
  Positions1C in 'Units\Positions1C.pas',
  XmlUtils in 'Units\XmlUtils.pas',
  FormatTLV in 'Units\FormatTLV.pas',
  ODClient in 'Units\ODClient.pas',
  uLkJSON in 'Units\uLkJSON.pas',
  ControlMark in 'Units\ControlMark.pas',
  Positions1C3 in 'Units\Positions1C3.pas',
  GS1Util in 'Units\GS1Util.pas',
  GS1Barcode in 'Units\GS1Barcode.pas',
  Optional in 'Units\Optional.pas';

{$E dll}

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  DllInstall;

{$R *.TLB}

{$R *.RES}

{$R Addin1c.res}

begin
end.
