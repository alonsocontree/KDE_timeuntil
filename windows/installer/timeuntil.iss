; Inno Setup script for the Windows installer. Build the app and deploy it
; into dist\TimeUntil first (see .github/workflows/ci.yml), then run from the
; repository root:
;   iscc /DAppVersion=1.1.0 windows\installer\timeuntil.iss

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
AppId={{6F1D7C2B-3C8E-4D6A-9E2F-7B5A1C0D4E91}
AppName=TimeUntil
AppVersion={#AppVersion}
AppPublisher=Alonso Contreras
AppPublisherURL=https://github.com/alonsocontree/KDE_timeuntil
DefaultDirName={autopf}\TimeUntil
DisableProgramGroupPage=yes
; Installs for the current user, without administrator rights.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=..\..\dist
OutputBaseFilename=TimeUntil-{#AppVersion}-setup
SetupIconFile=..\resources\timeuntil.ico
UninstallDisplayIcon={app}\TimeUntil.exe
LicenseFile=..\..\LICENSE
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "autostart"; Description: "{cm:AutoStartProgram,TimeUntil}"

[Files]
Source: "..\..\dist\TimeUntil\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\TimeUntil"; Filename: "{app}\TimeUntil.exe"

[Registry]
; The same value the app's "Start with Windows" menu item writes.
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "TimeUntil"; ValueData: """{app}\TimeUntil.exe"""; Tasks: autostart
; Remove it on uninstall, however it was enabled.
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: none; ValueName: "TimeUntil"; Flags: uninsdeletevalue

[Run]
Filename: "{app}\TimeUntil.exe"; Description: "{cm:LaunchProgram,TimeUntil}"; Flags: nowait postinstall skipifsilent
