program MitsuDrv1CTst;

uses
  Forms,
  VLEUtil in 'Units\VLEUtil.pas',
  LogFile in '..\Shared\LogFile.pas',
  Driver1C10 in 'Units\Driver1C10.pas',
  fmuMain in 'FMU\fmuMain.pas' {fmMain},
  OleArray1C in 'Units\OleArray1C.pas' {Array1C: CoClass},
  MitsuDrv1CTst_TLB in 'MitsuDrv1CTst_TLB.pas',
  LanguageExtender in 'Units\LanguageExtender.pas',
  RegExpr in '..\Shared\RegExpr.pas',
  StringUtils in '..\TstShared\StringUtils.pas',
  DriverTypes in '..\TstShared\DriverTypes.pas',
  GlobalConst in '..\TstShared\GlobalConst.pas',
  Driver1C11 in 'Units\Driver1C11.pas',
  untTypes in 'Units\untTypes.pas',
  Driver1C in 'Units\Driver1C.pas',
  BaseForm in '..\Shared\BaseForm.pas',
  AddIn1CInterface in 'Units\AddIn1CInterface.pas',
  WideException in '..\Shared\WideException.pas',
  MitsuLib_TLB in '..\MitsuDrv1C\MitsuLib_TLB.pas',
  gnugettext in '..\Shared\gnugettext.pas';

{$R *.TLB}

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
