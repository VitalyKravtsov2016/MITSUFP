program MitsuDrvTest;

uses
  TestFramework,
  GUITestRunner,
  duMitsuDrv1C in 'Units\duMitsuDrv1C.pas',
  MitsuDrv in '..\..\Src\MitsuDrv1C\Units\MitsuDrv.pas',
  PrinterPort in '..\..\Src\Shared\PrinterPort.pas',
  SerialPort in '..\..\Src\Shared\SerialPort.pas',
  WideException in '..\..\Src\Shared\WideException.pas',
  DeviceNotification in '..\..\Src\Shared\DeviceNotification.pas',
  PortUtil in '..\..\Src\Shared\PortUtil.pas',
  TextReport in '..\..\Src\Shared\TextReport.pas',
  SocketPort in '..\..\Src\Shared\SocketPort.pas',
  DriverError in '..\..\Src\Shared\DriverError.pas',
  StringUtils in '..\..\Src\Shared\StringUtils.pas',
  ByteUtils in '..\..\Src\Shared\ByteUtils.pas',
  XmlDoc1C in '..\..\Src\MitsuDrv1C\Units\XmlDoc1C.pas',
  XmlUtils in '..\..\Src\MitsuDrv1C\Units\XmlUtils.pas',
  VersionInfo in '..\..\Src\Shared\VersionInfo.pas',
  ParamList1C in '..\..\Src\MitsuDrv1C\Units\ParamList1C.pas',
  ParamList1CPage in '..\..\Src\MitsuDrv1C\Units\ParamList1CPage.pas',
  ParamList1CGroup in '..\..\Src\MitsuDrv1C\Units\ParamList1CGroup.pas',
  ParamList1CItem in '..\..\Src\MitsuDrv1C\Units\ParamList1CItem.pas',
  Param1CChoiceList in '..\..\Src\MitsuDrv1C\Units\Param1CChoiceList.pas',
  LangUtils in '..\..\Src\TstShared\LangUtils.pas',
  DriverTypes in '..\..\Src\TstShared\DriverTypes.pas',
  GlobalConst in '..\..\Src\TstShared\GlobalConst.pas',
  FDTypes in '..\..\Src\MitsuDrv1C\Units\FDTypes.pas',
  Params1C in '..\..\Src\MitsuDrv1C\Units\Params1C.pas',
  Types1C in '..\..\Src\MitsuDrv1C\Units\Types1C.pas',
  FFDTypes in '..\..\Src\MitsuDrv1C\Units\FFDTypes.pas',
  duMitsuDrv in 'Units\duMitsuDrv.pas',
  GS1Util in '..\..\Src\MitsuDrv1C\Units\GS1Util.pas',
  GS1Barcode in '..\..\Src\MitsuDrv1C\Units\GS1Barcode.pas',
  LogFile in '..\..\Src\Shared\LogFile.pas',
  MitsuDrv_1C in '..\..\Src\MitsuDrv1C\Units\MitsuDrv_1C.pas',
  ActiveXView in '..\..\Src\Shared\ActiveXView.pas',
  ActiveXControl1C in '..\..\Src\MitsuDrv1C\Units\ActiveXControl1C.pas',
  AddIn1CTypes in '..\..\Src\MitsuDrv1C\Units\AddIn1CTypes.pas',
  AddIn1CInterface in '..\..\Src\MitsuDrv1C\Units\AddIn1CInterface.pas',
  TextEncoding in '..\..\Src\MitsuDrv1C\Units\TextEncoding.pas',
  TranslationUtil in '..\..\Src\Shared\TranslationUtil.pas',
  gnugettext in '..\..\Src\Shared\gnugettext.pas',
  FileUtils in '..\..\Src\Shared\FileUtils.pas';

{$R *.res}

begin
  TGUITestRunner.RunTest(RegisteredTests);
end.
