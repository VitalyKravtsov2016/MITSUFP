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
  ClassReg.AddFunc('GetInterfaceRevision', 'ѕолучить–евизию»нтерфейса', @TExtention30.GetInterfaceRevision, 0);
  ClassReg.AddFunc('GetDescription', 'ѕолучитьќписание', @TExtention30.GetDescription, 1);
  ClassReg.AddFunc('GetLastError', 'ѕолучитьќшибку', @TExtention30.GetLastError, 1);
  ClassReg.AddFunc('GetParameters', 'ѕолучитьѕараметры', @TExtention30.GetParameters, 1);
  ClassReg.AddFunc('SetParameter', '”становитьѕараметр', @TExtention30.SetParameter, 2);
  ClassReg.AddFunc('Open', 'ѕодключить', @TExtention30.Open, 1);
  ClassReg.AddFunc('Close', 'ќтключить', @TExtention30.Close, 1);
  ClassReg.AddFunc('DeviceTest', '“ест”стройства', @TExtention30.DeviceTest, 2);
  ClassReg.AddFunc('GetAdditionalActions', 'ѕолучитьƒополнительныеƒействи€', @TExtention30.GetAdditionalActions, 1);
  ClassReg.AddFunc('DoAdditionalAction', '¬ыполнитьƒополнительноеƒействие', @TExtention30.DoAdditionalAction, 1);
  ClassReg.AddFunc('GetLocalizationPattern', 'ѕолучитьЎаблонЋокализации', @TExtention30.GetLocalizationPattern, 1);
  ClassReg.AddFunc('SetLocalization', '”становитьЋокализацию', @TExtention30.SetLocalization, 1);
  // KKT Methods
  ClassReg.AddFunc('GetDataKKT', 'ѕолучитьѕараметры  “', @TExtention30.GetDataKKT, 2);
  ClassReg.AddFunc('OperationFN', 'ќпераци€‘Ќ', @TExtention30.OperationFN, 3);
  ClassReg.AddFunc('OpenShift', 'ќткрыть—мену', @TExtention30.OpenShift, 3);
  ClassReg.AddFunc('CloseShift', '«акрыть—мену', @TExtention30.CloseShift, 3);
  ClassReg.AddFunc('ProcessCheck', '—формировать„ек', @TExtention30.ProcessCheck, 4);
  ClassReg.AddFunc('ProcessCorrectionCheck', '—формировать„ек оррекции', @TExtention30.ProcessCorrectionCheck, 3);
  ClassReg.AddFunc('PrintTextDocument', 'Ќапечатать“екстовыйƒокумент', @TExtention30.PrintTextDocument, 2);
  ClassReg.AddFunc('CashInOutcome', 'Ќапечатать„ек¬несени€¬ыемки', @TExtention30.CashInOutcome, 3);
  ClassReg.AddFunc('PrintXReport', 'ЌапечататьќтчетЅез√ашени€', @TExtention30.PrintXReport, 2);
  ClassReg.AddFunc('PrintCheckCopy', 'Ќапечатать опию„ека', @TExtention30.PrintCheckCopy, 2);
  ClassReg.AddFunc('GetCurrentStatus', 'ѕолучить“екущее—осто€ние', @TExtention30.GetCurrentStatus, 3);
  ClassReg.AddFunc('ReportCurrentStatusOfSettlements', 'ќтчетќ“екущем—осто€нии–асчетов', @TExtention30.ReportCurrentStatusOfSettlements, 3);
  ClassReg.AddFunc('OpenCashDrawer', 'ќткрытьƒенежныйящик', @TExtention30.OpenCashDrawer, 1);
  ClassReg.AddFunc('GetLineLength', 'ѕолучитьЎирину—троки', @TExtention30.GetLineLength, 2);
  ClassReg.AddFunc('OpenSessionRegistrationKM', 'ќткрыть—ессию–егистрации ћ', @TExtention30.OpenSessionRegistrationKM, 1);
  ClassReg.AddFunc('CloseSessionRegistrationKM', '«акрыть—ессию–егистрации ћ', @TExtention30.CloseSessionRegistrationKM, 1);
  ClassReg.AddFunc('RequestKM', '«апрос ћ', @TExtention30.RequestKM, 3);
  ClassReg.AddFunc('GetProcessingKMResult', 'ѕолучить–езультаты«апроса ћ', @TExtention30.GetProcessingKMResult, 3);
  ClassReg.AddFunc('ConfirmKM', 'ѕодтвердить ћ', @TExtention30.ConfirmKM, 3);
end.

