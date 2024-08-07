[CustomMessages]
; English
en.CompanyName=VAV
en.AppName=Fiscal printer MITSU 1-F driver
en.AppComments=Retail equipment
en.AppCopyright=Copyright � 2024 VAV
en.DefaultDirName=\VAV\MitsuDrv
en.DefaultGroupName=VAV MitsuDrv
en.HistoryIcon=Version history
en.UninstallShortcutText=Uninstall
en.StartApplication=Run driver test
en.HistoryFileName=Doc\en\History.txt
en.DesktopIconDescription=Create shortcut on the desktop
en.QuickLaunchIconDescription=Create shortcut on the quick launch panel
en.DesktopGroupDescription=Create shortcuts
en.AppPublisher=VAV
en.AppCopyright=Copyright � 2024 VAV
en.ComponentsMain=Driver and tests
en.VersionHistory=Versions history
en.DriverTest1C=Driver test (1C interface)
en.HistoryFileName=res\History_en.txt
; russian
ru.CompanyName=��� �������
ru.AppName=������� ��� MITSU 1-F
ru.AppComments=���������� ������������
ru.AppCopyright=Copyright � 2024 ��� �������
ru.DefaultDirName=\VAV\MitsuDrv
ru.DefaultGroupName=VAV ������� ���
ru.HistoryIcon=������� ������
ru.UninstallShortcutText=�������
ru.StartApplication=��������� ���� ��������
ru.HistoryFileName=Doc\ru\History.txt
ru.DesktopIconDescription=������� ����� �� &������� �����
ru.QuickLaunchIconDescription=������� &����� � ������ �������� �������
ru.DesktopGroupDescription=�������� �������
ru.AppPublisher=��� �������
ru.AppCopyright=Copyright � 2024 ��� �������
ru.ComponentsMain=������� � �����
ru.VersionHistory=������� ������
ru.DriverTest1C=���� �������� ��� (��������� 1�)
ru.UninstallShortcutText=�������
ru.HistoryFileName=res\History_ru.txt
[Setup]
AppName= {cm:AppName}
AppVerName= {cm:AppName} 1.0"
DefaultDirName= {pf}\{cm:DefaultDirName}5
DefaultGroupName= {cm:DefaultGroupName} 1.0 (64-bit)
UninstallDisplayIcon= {app}\Uninstall.exe
AllowNoIcons=Yes
OutputDir="."
UsePreviousAppDir=No
UsePreviousGroup=No
AppVersion=1.0.0.4
AppPublisher= {cm:AppPublisher}
AppComments= {cm:AppComments}
AppReadmeFile=History.txt
AppCopyright= {cm:AppCopyright}
;Version
VersionInfoCompany=VAV
VersionInfoDescription=Fiscal printer driver
VersionInfoTextVersion="1.0.0.4"
VersionInfoVersion=1.0.0.4
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
[Files]
; Version history
Source: "Res\History_ru.txt"; DestDir: "{app}"; DestName: "History.txt"; Flags: 64bit; Components: main; Languages: ru
Source: "Res\History_en.txt"; DestDir: "{app}"; DestName: "History.txt"; Flags: 64bit; Components: main; Languages: en
; Driver and test
Source: "Bin\Win64\MitsuDrv1C.dll"; DestDir: "{app}\Bin"; Flags: ignoreversion regserver 64bit; Components: main
;Source: "Bin\Win64\MitsuDrv1CTst.exe"; DestDir: "{app}\Bin"; Flags: ignoreversion 64bit; Components: main
Source: "res\1C\32\mitsudrv_32_x32_64.zip"; DestDir: "{app}\Bin\1C"; Flags: ignoreversion 64bit; Components: main
Source: "res\1C\40\mitsudrv_40_x32_64.zip"; DestDir: "{app}\Bin\1C"; Flags: ignoreversion 64bit; Components: main
[Icons]
; Version history
Name: "{group}\{cm:VersionHistory}"; Filename: "{app}\History.txt"; Components: main
; Main
;Name: "{group}\{cm:DriverTest} 1.0 (64-bit)"; Filename: "{app}\Bin\DrvFRTst.exe"; WorkingDir: "{app}\Bin"; Components: main
;Name: "{group}\{cm:UninstallShortcutText} ������� ��� 1.0 (64-bit)"; Filename: "{uninstallexe}"
; Shortcuts
;Name: "{userdesktop}\{cm:DriverTest} 1.0 (64-bit)"; Filename: "{app}\Bin\MitsuDrv1CTst.exe"; Tasks: desktopicon
;Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{cm:DriverTest} 1.0 (64-bit)"; Filename: "{app}\Bin\MitsuDrv1CTst.exe"; Tasks: quicklaunchicon
;[Run]
;Filename: "{app}\Bin\MitsuDrv1CTst.exe"; Description: {cm:StartApplication}; Flags: postinstall nowait skipifsilent skipifdoesntexist; Components: main; Check: Is64BitInstallMode
