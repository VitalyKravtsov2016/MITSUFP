library MitsuDrv1C;

uses
  Forms,
  ComServ,
  OleMain1C30 in 'Units\OleMain1C30.pas',
  LogFile in '..\Shared\LogFile.pas',
  ActiveXView in '..\Shared\ActiveXView.pas',
  WideException in '..\Shared\WideException.pas',
  MitsuDrv_1C in 'Units\MitsuDrv_1C.pas',
  MitsuDrv in 'Units\MitsuDrv.pas',
  PrinterPort in '..\Shared\PrinterPort.pas',
  SerialPort in '..\Shared\SerialPort.pas',
  DeviceNotification in '..\Shared\DeviceNotification.pas',
  PortUtil in '..\Shared\PortUtil.pas',
  TextReport in '..\Shared\TextReport.pas',
  SocketPort in '..\Shared\SocketPort.pas',
  DriverError in '..\Shared\DriverError.pas',
  StringUtils in '..\Shared\StringUtils.pas',
  ByteUtils in '..\Shared\ByteUtils.pas',
  XmlDoc1C in 'Units\XmlDoc1C.pas',
  XmlUtils in 'Units\XmlUtils.pas',
  VersionInfo in '..\Shared\VersionInfo.pas',
  ParamList1C in 'Units\ParamList1C.pas',
  ParamList1CPage in 'Units\ParamList1CPage.pas',
  ParamList1CGroup in 'Units\ParamList1CGroup.pas',
  ParamList1CItem in 'Units\ParamList1CItem.pas',
  Param1CChoiceList in 'Units\Param1CChoiceList.pas',
  FDTypes in 'Units\FDTypes.pas',
  Params1C in 'Units\Params1C.pas',
  Types1C in 'Units\Types1C.pas',
  DriverTypes in '..\Shared\DriverTypes.pas',
  GlobalConst in '..\Shared\GlobalConst.pas',
  LangUtils in '..\TstShared\LangUtils.pas',
  Positions1C3 in 'Units\Positions1C3.pas',
  GS1Util in 'Units\GS1Util.pas',
  GS1Barcode in 'Units\GS1Barcode.pas',
  ActiveXControl1C in 'Units\ActiveXControl1C.pas',
  AddIn1CTypes in 'Units\AddIn1CTypes.pas',
  AddIn1CInterface in 'Units\AddIn1CInterface.pas',
  TextEncoding in 'Units\TextEncoding.pas',
  TranslationUtil in '..\Shared\TranslationUtil.pas',
  gnugettext in '..\Shared\gnugettext.pas',
  FileUtils in '..\Shared\FileUtils.pas',
  MitsuLib_TLB in 'MitsuLib_TLB.pas',
  oleMain1C10 in 'Units\oleMain1C10.pas',
  Driver1Cst in 'Units\Driver1Cst.pas';

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
