[Code]
#include "services_unicode.iss"

const
  KKTPROXY_SERVICE_NAME = 'kktproxy';
  KKTPROXY_SERVICE_DISPLAY_NAME = 'SHTRIH-M: kktproxy';
  KKTPROXY_SERVICE_EXE = 'kktproxy.exe';

var
  ServiceStarted: Boolean;

const
  NET_FW_SCOPE_ALL = 0;
  NET_FW_IP_VERSION_ANY = 2;

procedure SetFirewallException(AppName,FileName:string);
var
  FirewallObject: Variant;
  FirewallManager: Variant;
  FirewallProfile: Variant;
  ResultCode: Integer;
begin
  try
    Exec(
    'cmd.exe', '/C netsh advfirewall firewall add rule name=L2TP_TCP protocol=TCP localport=1080 action=allow dir=IN', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

    FirewallObject := CreateOleObject('HNetCfg.FwAuthorizedApplication');
    FirewallObject.ProcessImageFileName := FileName;
    FirewallObject.Name := AppName;
    FirewallObject.Scope := NET_FW_SCOPE_ALL;
    FirewallObject.IpVersion := NET_FW_IP_VERSION_ANY;
    FirewallObject.Enabled := True;
    FirewallManager := CreateOleObject('HNetCfg.FwMgr');
    FirewallProfile := FirewallManager.LocalPolicy.CurrentProfile;
    FirewallProfile.AuthorizedApplications.Add(FirewallObject);
  except
  end;
end;

procedure RemoveFirewallException( FileName:string );
var
  FirewallManager: Variant;
  FirewallProfile: Variant;
begin
  try
    FirewallManager := CreateOleObject('HNetCfg.FwMgr');
    FirewallProfile := FirewallManager.LocalPolicy.CurrentProfile;
    FireWallProfile.AuthorizedApplications.Remove(FileName);
  except
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
//  if pos('kktproxy', WizardSelectedComponents(False)) > 0 then
  begin
 	  if CurStep = ssInstall then 
    begin
      ServiceStarted := False;
      if ServiceExists(KKTPROXY_SERVICE_NAME) then 
      begin
        try
          if SimpleQueryService(KKTPROXY_SERVICE_NAME) = SERVICE_RUNNING then 
          begin
            ServiceStarted := True;
            try
              SimpleStopService(KKTPROXY_SERVICE_NAME, True, True);
              Sleep(3000);
            except
            end;
          end;
          SimpleDeleteService(KKTPROXY_SERVICE_NAME);
        except
        end;
      end;
    end
    else if CurStep = ssPostInstall then 
    begin        
      SetFirewallException('SHTRIH-M: kktproxy', ExpandConstant('{app}\Bin\kktproxy\' + KKTPROXY_SERVICE_EXE));                                 
      SimpleCreateService(KKTPROXY_SERVICE_NAME, KKTPROXY_SERVICE_DISPLAY_NAME, ExpandConstant('{app}\Bin\kktproxy\' + KKTPROXY_SERVICE_EXE), SERVICE_AUTO_START, '', '', False, False);
      //if ServiceStarted then
      begin
        SimpleStartService(KKTPROXY_SERVICE_NAME, True, True);
      end;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
 	  if CurUninstallStep = usUninstall then 
    begin
      if ServiceExists(KKTPROXY_SERVICE_NAME) then 
      begin
        if SimpleQueryService(KKTPROXY_SERVICE_NAME) = SERVICE_RUNNING then 
        begin
          SimpleStopService(KKTPROXY_SERVICE_NAME, True, False);
          Sleep(3000);
        end;
        SimpleDeleteService(KKTPROXY_SERVICE_NAME);
      end;
      RemoveFirewallException(ExpandConstant('{app}\Bin\kktproxy\' + KKTPROXY_SERVICE_EXE));
    end;
end;

#ifdef UNICODE
  #define AW "W"
#else
  #define AW "A"
#endif

function GetLastError: DWORD;
  external 'GetLastError@kernel32.dll stdcall setuponly';

const
  MAX_PATH = 260;

  SPOST_NONE = 0;
  SPOST_PATH = 1;
  SPOST_URL = 2;

  SP_COPY_DELETESOURCE = $0000001;
  SP_COPY_REPLACEONLY = $0000002;
  SP_COPY_NOOVERWRITE = $0000008;
  SP_COPY_OEMINF_CATALOG_ONLY = $0040000;

function IsWindowsVersionXP(Version: TWindowsVersion): Boolean;
begin
  Result := (Version.Major = 5) and (Version.Minor = 1);
end;

function IsWindowsVersionNew(Version: TWindowsVersion): Boolean;
begin
  Result := ((Version.Major = 5) and (Version.Minor > 1)) or (Version.Major > 5);
end;

[CustomMessages]
CompanyName=SHTRIH-M
AppName=ШТРИХ-М: Драйвер ККТ: kktproxy
AppComments=Торговое оборудование от производителя, автоматизация торговли
AppCopyright=Copyright © 2022 ШТРИХ-М
DefaultDirName=\SHTRIH-M\DrvFR
DefaultGroupName=ШТРИХ-М Драйвер ККТ
HistoryIcon=История версий
UninstallShortcutText=Удалить
StartApplication=Запустить тест драйвера
HistoryFileName=Doc\ru\History.txt
DesktopIconDescription=Создать ярлык на &рабочем столе
QuickLaunchIconDescription=Создать &ярлык в панели быстрого запуска
DesktopGroupDescription=Создание ярлыков
AppPublisher=ШТРИХ-М
AppPublisherURL=http://www.shtrih-m.ru
AppSupportURL=http://www.shtrih-m.ru
AppUpdatesURL=http://www.shtrih-m.ru
AppCopyright=Copyright © 2022 ШТРИХ-М
ComponentsMain=Драйвер и тесты
ComponentsSamples=Примеры
ComponentsOKassa=Облачная касса
Componentskktproxy=Служба kktproxy
Componentspppnetservice=Служба pppnetservice
VersionHistory=История версий
PrintServer=Сервер печати ККТ
DriverTest=Тест драйвера ККТ
OKassa=Облачная касса
DriverTest1C=Тест драйвера ККТ (интерфейс 1С)
ServiceProg=Сервисная программа
TaxProg=Программа налогового инспектора
TaxProg2=Программа налогового инспектора 2
ServerFR=Сервер ККТ
UninstallShortcutText=Удалить
HistoryFileName=res\History_txt
StartOKassa=Запустить мастер установки сервиса "Облачная касса"
OKassaMaster=Мастер установки сервиса Облачная касса
;OKassaDoc=Документация по настройке сервиса Облачная касса
OKassaFolder=Облачная касса
FiscalMaster=Мастер фискализации
[Setup]
AppName= {cm:AppName}
AppVerName= {cm:AppName} ${version2}"
DefaultDirName= {pf}\{cm:DefaultDirName}5
DefaultGroupName= {cm:DefaultGroupName} ${version2} ${Arch2}
UninstallDisplayIcon= {app}\Uninstall.exe
AllowNoIcons=Yes
OutputDir="."
UsePreviousAppDir=No
UsePreviousGroup=No
${Architecture}
AppVersion=${version2}
AppPublisher= {cm:AppPublisher}
AppPublisherURL= {cm:AppPublisherURL}
AppSupportURL= {cm:AppSupportURL}
AppUpdatesURL= {cm:AppUpdatesURL}
AppComments= {cm:AppComments}
AppContact=(495)787-6090
AppReadmeFile=History.txt
AppCopyright= {cm:AppCopyright}
;Version
VersionInfoCompany=SHTRIH-M
VersionInfoDescription=Fiscal printer driver
VersionInfoTextVersion="${version}"
VersionInfoVersion=${version}
UsePreviousLanguage=no
OutputBaseFilename=setup
[Files]
;kktproxy
Source: "Bin\Win32\kktproxy.exe"; DestDir: "{app}\Bin\kktproxy"; Flags: sharedfile ${Archbit};
Source: "res\kktproxy.ini"; DestDir: "{app}\Bin\kktproxy"; Flags: onlyifdoesntexist ${Archbit};