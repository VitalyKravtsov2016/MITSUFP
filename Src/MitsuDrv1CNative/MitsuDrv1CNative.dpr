library MitsuDrv1CNative;

uses
  SysUtils,
  Classes,
  VersionInfo in '..\Shared\VersionInfo.pas',
  WideException in '..\Shared\WideException.pas',
  v8napi in 'Units\v8napi.pas',
  Extention30 in 'units\Extention30.pas',
  MitsuLib_TLB in 'Units\MitsuLib_TLB.pas',
  Driver30 in 'units\Driver30.pas',
  LogFile in '..\Shared\LogFile.pas',
  untLogger in '..\Shared\untLogger.pas';

{$R *.res}
{$R MitsuDrv1CNative_ver.res}
{$IFDEF V1C_34}
{$R AddIn34.res}
{$ELSE}
{$R AddIn.res}
{$ENDIF}

var
  ClassReg: TClassReg;
begin

{$IFDEF V1C_34}
  ClassReg := ClassRegList.RegisterClass(TExtention30, 'SMDrvFR1C4', 'SMDrvFR1C4');
{$ELSE}
  ClassReg := ClassRegList.RegisterClass(TExtention30, 'SMDrvFR1C3', 'SMDrvFR1C3');
{$ENDIF}

  // Common methods
  ClassReg.AddFunc('GetInterfaceRevision', '�������������������������', @TExtention30.GetInterfaceRevision, 0);
  ClassReg.AddFunc('GetDescription', '����������������', @TExtention30.GetDescription, 1);
  ClassReg.AddFunc('GetLastError', '��������������', @TExtention30.GetLastError, 1);
  ClassReg.AddFunc('GetParameters', '�����������������', @TExtention30.GetParameters, 1);
  ClassReg.AddFunc('SetParameter', '������������������', @TExtention30.SetParameter, 2);
  ClassReg.AddFunc('Open', '����������', @TExtention30.Open, 1);
  ClassReg.AddFunc('Close', '���������', @TExtention30.Close, 1);
  ClassReg.AddFunc('DeviceTest', '��������������', @TExtention30.DeviceTest, 2);
  ClassReg.AddFunc('GetAdditionalActions', '������������������������������', @TExtention30.GetAdditionalActions, 1);
  ClassReg.AddFunc('DoAdditionalAction', '�������������������������������', @TExtention30.DoAdditionalAction, 1);
  ClassReg.AddFunc('GetLocalizationPattern', '�������������������������', @TExtention30.GetLocalizationPattern, 1);
  ClassReg.AddFunc('SetLocalization', '���������������������', @TExtention30.SetLocalization, 1);
  // KKT Methods
  ClassReg.AddFunc('GetDataKKT', '��������������������', @TExtention30.GetDataKKT, 2);
  ClassReg.AddFunc('OperationFN', '����������', @TExtention30.OperationFN, 3);
  ClassReg.AddFunc('OpenShift', '������������', @TExtention30.OpenShift, 3);
  ClassReg.AddFunc('CloseShift', '������������', @TExtention30.CloseShift, 3);
  ClassReg.AddFunc('ProcessCheck', '���������������', @TExtention30.ProcessCheck, 4);
  ClassReg.AddFunc('ProcessCorrectionCheck', '������������������������', @TExtention30.ProcessCorrectionCheck, 3);
  ClassReg.AddFunc('PrintTextDocument', '���������������������������', @TExtention30.PrintTextDocument, 2);
  ClassReg.AddFunc('CashInOutcome', '���������������������������', @TExtention30.CashInOutcome, 3);
  ClassReg.AddFunc('PrintXReport', '�������������������������', @TExtention30.PrintXReport, 2);
  ClassReg.AddFunc('PrintCheckCopy', '�������������������', @TExtention30.PrintCheckCopy, 2);
  ClassReg.AddFunc('GetCurrentStatus', '������������������������', @TExtention30.GetCurrentStatus, 3);
  ClassReg.AddFunc('ReportCurrentStatusOfSettlements', '������������������������������', @TExtention30.ReportCurrentStatusOfSettlements, 3);
  ClassReg.AddFunc('OpenCashDrawer', '�������������������', @TExtention30.OpenCashDrawer, 1);
  ClassReg.AddFunc('GetLineLength', '��������������������', @TExtention30.GetLineLength, 2);
  ClassReg.AddFunc('OpenSessionRegistrationKM', '��������������������������', @TExtention30.OpenSessionRegistrationKM, 1);
  ClassReg.AddFunc('CloseSessionRegistrationKM', '��������������������������', @TExtention30.CloseSessionRegistrationKM, 1);
  ClassReg.AddFunc('RequestKM', '��������', @TExtention30.RequestKM, 3);
  ClassReg.AddFunc('GetProcessingKMResult', '���������������������������', @TExtention30.GetProcessingKMResult, 3);
  ClassReg.AddFunc('ConfirmKM', '�������������', @TExtention30.ConfirmKM, 3);
end.

