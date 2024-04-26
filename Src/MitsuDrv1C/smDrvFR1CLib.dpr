library smDrvFR1CLib;

uses
  Forms,
  SMDrvFR1CLib_TLB in 'SMDrvFR1CLib_TLB.pas',
  oleMain in 'Units\oleMain.pas' {smDrvFR1C: CoClass},
  untLogger in '..\Shared\untLogger.pas',
  LogFile in '..\Shared\LogFile.pas',
  DriverTypes in '..\Shared\DriverTypes.pas',
  GlobalConst in '..\Shared\GlobalConst.pas',
  untAxCtrls in 'Units\untAxCtrls.pas',
  AxCtrls2 in 'Units\AxCtrls2.pas',
  ActiveXControl1C in 'Units\ActiveXControl1C.pas',
  ComServ2 in '..\Shared\ComServ2.pas',
  ComObj2 in '..\Shared\ComObj2.pas',
  TextEncoding in 'Units\TextEncoding.pas',
  VersionInfo in '..\Shared\VersionInfo.pas',
  ActiveXView in '..\Shared\ActiveXView.pas',
  AddIn1CInterface in '..\Shared\AddIn1CInterface.pas',
  AddIn1CTypes in '..\Shared\AddIn1CTypes.pas';

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
