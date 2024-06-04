[CustomMessages]
; English
en.CompanyName=VAV
en.AppName=Fiscal printer MITSU 1-F driver
en.AppComments=Retail equipment
en.AppCopyright=Copyright © 2024 VAV
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
en.AppCopyright=Copyright © 2024 VAV
en.ComponentsMain=Driver and tests
en.VersionHistory=Versions history
en.DriverTest1C=Driver test (1C interface)
en.HistoryFileName=res\History_en.txt
; russian
ru.CompanyName=ООО «ВиЭйВи»
ru.AppName=Драйвер ККТ MITSU 1-F
ru.AppComments=Фискальные регистраторы
ru.AppCopyright=Copyright © 2024 ООО «ВиЭйВи»
ru.DefaultDirName=\VAV\MitsuDrv
ru.DefaultGroupName=VAV Драйвер ККТ
ru.HistoryIcon=История версий
ru.UninstallShortcutText=Удалить
ru.StartApplication=Запустить тест драйвера
ru.HistoryFileName=Doc\ru\History.txt
ru.DesktopIconDescription=Создать ярлык на &рабочем столе
ru.QuickLaunchIconDescription=Создать &ярлык в панели быстрого запуска
ru.DesktopGroupDescription=Создание ярлыков
ru.AppPublisher=ООО «ВиЭйВи»
ru.AppCopyright=Copyright © 2024 ООО «ВиЭйВи»
ru.ComponentsMain=Драйвер и тесты
ru.VersionHistory=История версий
ru.DriverTest1C=Тест драйвера ККТ (интерфейс 1С)
ru.UninstallShortcutText=Удалить
ru.HistoryFileName=res\History_ru.txt
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
AppVersion=${version}
AppPublisher= {cm:AppPublisher}
AppComments= {cm:AppComments}
AppReadmeFile=History.txt
AppCopyright= {cm:AppCopyright}
;Version
VersionInfoCompany=VAV
VersionInfoDescription=Fiscal printer driver
VersionInfoTextVersion="${version}"
VersionInfoVersion=${version}
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
Source: "Res\History_ru.txt"; DestDir: "{app}"; DestName: "History.txt"; Flags: ${Archbit}; Components: main; Languages: ru
Source: "Res\History_en.txt"; DestDir: "{app}"; DestName: "History.txt"; Flags: ${Archbit}; Components: main; Languages: en
; Driver and test
Source: "Bin\${Arch}\MitsuDrv1C.dll"; DestDir: "{app}\Bin"; Flags: ignoreversion regserver ${Archbit}; Components: main
;Source: "Bin\${Arch}\MitsuDrv1CTst.exe"; DestDir: "{app}\Bin"; Flags: ignoreversion ${Archbit}; Components: main
Source: "res\1C\32\mitsudrv_32_x32_64.zip"; DestDir: "{app}\Bin\1C"; Flags: ignoreversion ${Archbit}; Components: main
Source: "res\1C\40\mitsudrv_40_x32_64.zip"; DestDir: "{app}\Bin\1C"; Flags: ignoreversion ${Archbit}; Components: main
[Icons]
; Version history
Name: "{group}\{cm:VersionHistory}"; Filename: "{app}\History.txt"; Components: main
; Main
;Name: "{group}\{cm:DriverTest} ${version2} ${Arch2}"; Filename: "{app}\Bin\DrvFRTst.exe"; WorkingDir: "{app}\Bin"; Components: main
;Name: "{group}\{cm:UninstallShortcutText} Драйвер ККТ ${version2} ${Arch2}"; Filename: "{uninstallexe}"
; Shortcuts
;Name: "{userdesktop}\{cm:DriverTest} ${version2} ${Arch2}"; Filename: "{app}\Bin\MitsuDrv1CTst.exe"; Tasks: desktopicon
;Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{cm:DriverTest} ${version2} ${Arch2}"; Filename: "{app}\Bin\MitsuDrv1CTst.exe"; Tasks: quicklaunchicon
;[Run]
;Filename: "{app}\Bin\MitsuDrv1CTst.exe"; Description: {cm:StartApplication}; Flags: postinstall nowait skipifsilent skipifdoesntexist; Components: main; Check: Is64BitInstallMode
