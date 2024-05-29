[CustomMessages]
; English
en.CompanyName=SHTRIH-M
en.AppName=SHTRIH-M: Fiscal printer driver
en.AppComments=Retail equipment
en.AppCopyright=Copyright � 2022 SHTRIH-M
en.DefaultDirName=\SHTRIH-M\DrvFR
en.DefaultGroupName=SHTRIH-M DrvFR
en.HistoryIcon=Version history
en.UninstallShortcutText=Uninstall
en.StartApplication=Run driver test
en.HistoryFileName=Doc\en\History.txt
en.DesktopIconDescription=Create shortcut on the desktop
en.QuickLaunchIconDescription=Create shortcut on the quick launch panel
en.DesktopGroupDescription=Create shortcuts
en.AppPublisher=SHTRIH-M
en.AppPublisherURL=http://www.shtrih-m.ru
en.AppSupportURL=http://www.shtrih-m.ru
en.AppUpdatesURL=http://www.shtrih-m.ru
en.AppCopyright=Copyright � 2022 SHTRIH-M
en.ComponentsMain=Driver and tests
en.ComponentsSamples=Samples
en.ComponentsOKassa=OKassa service
en.OKassaFolder=OKassa
en.Componentskktproxy=kktproxy service
en.Componentspppnetservice=PPP net service
en.ComponentsDrivers = USB Drivers
en.VersionHistory=Versions history
en.PrintServer=Print server
en.DriverTest=Driver test
en.OKassa=OKassa
en.OKassaMaster=OKassa service setup wizard
en.DriverTest1C=Driver test (1C interface)
en.ServiceProg=Service application
en.TaxProg=Tax inspector utility
en.TaxProg2=Tax inspector utility 2
en.ServerFR=Server FR
en.HistoryFileName=res\History_en.txt
en.StartOKassa=Start "OKassa" setup application
en.FiscalMaster=FiscalMaster
;en.OKassaDoc=OKassa service documentation
; russian
ru.CompanyName=SHTRIH-M
ru.AppName=�����-�: ������� ���
ru.AppComments=�������� ������������ �� �������������, ������������� ��������
ru.AppCopyright=Copyright � 2022 �����-�
ru.DefaultDirName=\SHTRIH-M\DrvFR
ru.DefaultGroupName=�����-� ������� ���
ru.HistoryIcon=������� ������
ru.UninstallShortcutText=�������
ru.StartApplication=��������� ���� ��������
ru.HistoryFileName=Doc\ru\History.txt
ru.DesktopIconDescription=������� ����� �� &������� �����
ru.QuickLaunchIconDescription=������� &����� � ������ �������� �������
ru.DesktopGroupDescription=�������� �������
ru.AppPublisher=�����-�
ru.AppPublisherURL=http://www.shtrih-m.ru
ru.AppSupportURL=http://www.shtrih-m.ru
ru.AppUpdatesURL=http://www.shtrih-m.ru
ru.AppCopyright=Copyright � 2022 �����-�
ru.ComponentsMain=������� � �����
ru.ComponentsSamples=�������
ru.ComponentsOKassa=�������� �����
ru.Componentskktproxy=������ kktproxy
ru.Componentspppnetservice=������ pppnetservice
ru.ComponentsDrivers = �������� USB
ru.VersionHistory=������� ������
ru.PrintServer=������ ������ ���
ru.DriverTest=���� �������� ���
ru.OKassa=�������� �����
ru.DriverTest1C=���� �������� ��� (��������� 1�)
ru.ServiceProg=��������� ���������
ru.TaxProg=��������� ���������� ����������
ru.TaxProg2=��������� ���������� ���������� 2
ru.ServerFR=������ ���
ru.UninstallShortcutText=�������
ru.HistoryFileName=res\History_ru.txt
ru.StartOKassa=��������� ������ ��������� ������� "�������� �����"
ru.OKassaMaster=������ ��������� ������� �������� �����
;ru.OKassaDoc=������������ �� ��������� ������� �������� �����
ru.OKassaFolder=�������� �����
ru.FiscalMaster=������ ������������
[Setup]
AppName= {cm:AppName}
AppVerName= {cm:AppName} 5.17"
DefaultDirName= {pf}\{cm:DefaultDirName}5
DefaultGroupName= {cm:DefaultGroupName} 5.17 (64-bit)
UninstallDisplayIcon= {app}\Uninstall.exe
AllowNoIcons=Yes
OutputDir="."
UsePreviousAppDir=No
UsePreviousGroup=No
ArchitecturesInstallIn64BitMode=x64
AppVersion=5.17.0.989
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
VersionInfoTextVersion="5.17.0.989"
VersionInfoVersion=5.17.0.989
UsePreviousLanguage=no
OutputBaseFilename=setup
[Languages]
Name: en; MessagesFile: compiler:Default.isl;
Name: ru; MessagesFile: "compiler:Languages\Russian.isl"
[Tasks]
Name: "desktopicon"; Description: {cm:DesktopIconDescription}; GroupDescription: {cm:DesktopGroupDescription}; Flags: unchecked
Name: "quicklaunchicon"; Description: {cm:QuickLaunchIconDescription}; GroupDescription: {cm:DesktopGroupDescription}; Flags: unchecked
[Components]
Name: "main"; Description: {cm:ComponentsMain}; Types: full compact custom
name: "usbdrivers"; Description: {cm:ComponentsDrivers}; Types: full compact custom
Name: "kktproxy"; Description: {cm:Componentskktproxy}; Types: full compact custom
Name: "pppnetservice"; Description: {cm:Componentspppnetservice}; Types: full compact custom
Name: "okassa"; Description: {cm:ComponentsOkassa}; Types: full compact custom; 
Name: "samples"; Description: {cm:ComponentsSamples}; 
Name: "images"; Description: "Images"; Types: full
                                                                                  
[Files]
; Version history
Source: "Res\History.txt"; DestDir: "{app}"; DestName: "History.txt"; Flags: 64bit; Components: main; Languages: ru
; Driver and test
Source: "res\1C\32\shtrih-m_32_x32_64.zip"; DestDir: "{app}\Bin\1C"; Flags: ignoreversion 64bit; Components: main
Source: "res\1C\40\shtrih-m_40_x32_64.zip"; DestDir: "{app}\Bin\1C"; Flags: ignoreversion 64bit; Components: main
[Icons]
; Version history
Name: "{group}\{cm:VersionHistory}"; Filename: "{app}\History.txt"; Components: main
; Main
Name: "{group}\{cm:UninstallShortcutText} ������� ��� 5.17 (64-bit)"; Filename: "{uninstallexe}"
;Samples
Name: "{group}\Samples"; Filename: "{app}\Samples"; WorkingDir: "{app}"; Components: Samples
; Shortcuts
Name: "{userdesktop}\{cm:DriverTest} 5.17 (64-bit)"; Filename: "{app}\Bin\DrvFRTst.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{cm:DriverTest} 5.17 (64-bit)"; Filename: "{app}\Bin\DrvFRTst.exe"; Tasks: quicklaunchicon
[Run]
Filename: "{app}\Bin\DrvFRTst.exe"; Description: {cm:StartApplication}; Flags: postinstall nowait skipifsilent skipifdoesntexist; Components: main
[Registry]
; 1C samples menu
Root: HKCU; Subkey: "Software\1C\1Cv7\7.5\Titles"; ValueType: string; ValueName: "{app}\Samples\1C\1C 7.5\"; ValueData: {cm:AppName}; Flags: uninsdeletevalue; Components: Samples
Root: HKCU; Subkey: "Software\1C\1Cv7\7.7\Titles"; ValueType: string; ValueName: "{app}\Samples\1C\1C 7.7\"; ValueData: {cm:AppName}; Flags: uninsdeletevalue; Components: Samples
