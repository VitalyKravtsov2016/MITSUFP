program MitsuDrvTest;

uses
  TestFramework,
  GUITestRunner,
  duMitsuDrv in 'Units\duMitsuDrv.pas',
  MitsuDrv in '..\..\Src\MitsuDrv1C\Units\MitsuDrv.pas',
  PrinterPort in '..\..\Src\Shared\PrinterPort.pas',
  SerialPort in '..\..\Src\Shared\SerialPort.pas',
  WException in '..\..\Src\Shared\WException.pas',
  DeviceNotification in '..\..\Src\Shared\DeviceNotification.pas',
  PortUtil in '..\..\Src\Shared\PortUtil.pas',
  TextReport in '..\..\Src\Shared\TextReport.pas',
  SocketPort in '..\..\Src\Shared\SocketPort.pas',
  DriverError in '..\..\Src\Shared\DriverError.pas',
  StringUtils in '..\..\Src\Shared\StringUtils.pas',
  LogFile in 'Units\LogFile.pas',
  MitsuDrv1C in '..\..\Src\MitsuDrv1C\Units\MitsuDrv1C.pas',
  FileUtils in '..\..\Src\Shared\FileUtils.pas',
  ByteUtils in '..\..\Src\Shared\ByteUtils.pas',
  Types1C_1 in '..\..\Src\MitsuDrv1C\Units\Types1C_1.pas',
  XmlUtils in '..\..\Src\MitsuDrv1C\Units\XmlUtils.pas';

begin
  TGUITestRunner.RunTest(RegisteredTests);
end.
