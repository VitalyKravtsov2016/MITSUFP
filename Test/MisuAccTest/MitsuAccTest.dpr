program MitsuAccTest;

uses
  TestFramework,
  GUITestRunner,
  {$R}
  duDriver1Cst in 'Units\duDriver1Cst.pas' {$R *.res},
  MitsuLib_TLB in '..\..\Src\MitsuDrv1C\MitsuLib_TLB.pas',
  FileUtils in '..\..\Src\Shared\FileUtils.pas',
  XmlUtils in '..\..\Src\MitsuDrv1C\Units\XmlUtils.pas',
  LogFile in '..\..\Src\Shared\LogFile.pas',
  XmlDoc1C in '..\..\Src\MitsuDrv1C\Units\XmlDoc1C.pas',
  StringUtils in '..\..\Src\Shared\StringUtils.pas',
  GS1Util in '..\..\Src\MitsuDrv1C\Units\GS1Util.pas',
  GS1Barcode in '..\..\Src\MitsuDrv1C\Units\GS1Barcode.pas';

{$R *.res}

begin
  TGUITestRunner.RunTest(RegisteredTests);
end.
