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
  DrvFRLib_TLB in '..\MitsuDrv\DrvFRLib_TLB.pas',
  SMDrvFR1CLib_TLB in '..\MitsuDrv1C\SMDrvFR1CLib_TLB.pas',
  BaseForm in '..\Shared\BaseForm.pas',
  AddIn1CInterface in 'Units\AddIn1CInterface.pas',
  WException in '..\Shared\WException.pas';

{$R *.TLB}

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
