library MitsuDrvTestLib;

{%File 'MitsuDrvTest.dpr'}

uses
  TestFramework,
  GUITestRunner,
  duMitsuDrv1C in 'Units\duMitsuDrv1C.pas',
  MitsuDrv in '..\..\Src\MitsuDrv1C\Units\MitsuDrv.pas',
  PrinterPort in '..\..\Src\Shared\PrinterPort.pas',
  SerialPort in '..\..\Src\Shared\SerialPort.pas',
  LogFile in '..\..\Src\Shared\LogFile.pas',
  WException in '..\..\Src\Shared\WException.pas',
  DeviceNotification in '..\..\Src\Shared\DeviceNotification.pas',
  PortUtil in '..\..\Src\Shared\PortUtil.pas',
  TextReport in '..\..\Src\Shared\TextReport.pas',
  SocketPort in '..\..\Src\Shared\SocketPort.pas',
  DriverError in '..\..\Src\Shared\DriverError.pas',
  StringUtils in '..\..\Src\Shared\StringUtils.pas';

exports
  RegisteredTests name 'Test';
end.

