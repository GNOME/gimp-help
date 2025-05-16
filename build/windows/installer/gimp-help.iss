;Installer for GIMP Help
;
;.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,
;                                                                       ;
;Copyright (c) 2002-2012 Jernej Simon�i�                                ;
;                                                                       ;
;This software is provided 'as-is', without any express or implied      ;
;warranty. In no event will the authors be held liable for any damages  ;
;arising from the use of this software.                                 ;
;                                                                       ;
;Permission is granted to anyone to use this software for any purpose,  ;
;including commercial applications, and to alter it and redistribute it ;
;freely, subject to the following restrictions:                         ;
;                                                                       ;
;   1. The origin of this software must not be misrepresented; you must ;
;      not claim that you wrote the original software. If you use this  ;
;      software in a product, an acknowledgment in the product          ;
;      documentation would be appreciated but is not required.          ;
;                                                                       ;
;   2. Altered source versions must be plainly marked as such, and must ;
;      not be misrepresented as being the original software.            ;
;                                                                       ;
;   3. This notice may not be removed or altered from any source        ;
;      distribution.                                                    ;
;.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.;


;#define dontcompress
;#define nofiles

#ifndef MAJORVERSION
	#error MAJORVERSION must be defined
#endif
#ifndef MINORVERSION
	#error MINORVERSION must be defined
#endif
#ifndef MICROVERSION
	#error MICROVERSION must be defined
#endif
#ifndef LANG
	#error LANG must be defined
#endif

#define VERSION MAJORVERSION + '.' + MINORVERSION + '.' + MICROVERSION
#define MIN_VERSION MAJORVERSION + '.' + MINORVERSION

#include "version.isi"

;for picking up the correct Inno Setup language file
#if LANG=='en'
	#define LANGFILE='Default.isl'
#elif LANG=='bg'
	#define LANGFILE='Languages\Bulgarian.isl'
#elif LANG=='ca'
	#define LANGFILE='Languages\Catalan.isl'
#elif LANG=='cs'
	#define LANGFILE='Languages\Czech.isl'
#elif LANG=='de'
	#define LANGFILE='Languages\German.isl'
#elif LANG=='da'
	#define LANGFILE='Languages\Danish.isl'
#elif LANG=='el'
	#define LANGFILE='Languages\Unofficial\Greek.isl'
#elif LANG=='en_GB'
	#define LANGFILE='Languages\Unofficial\EnglishBritish.isl'
#elif LANG=='es'
	#define LANGFILE='Languages\Spanish.isl'
#elif LANG=='fa'
	#define LANGFILE='Languages\Unofficial\Farsi.isl'
#elif LANG=='fi'
	#define LANGFILE='Languages\Finnish.isl'
#elif LANG=='fr'
	#define LANGFILE='Languages\French.isl'
#elif LANG=='hr'
	#define LANGFILE='Languages\Unofficial\Croatian.isl'
#elif LANG=='hu'
	#define LANGFILE='Languages\Hungarian.isl'
#elif LANG=='it'
	#define LANGFILE='Languages\Italian.isl'
#elif LANG=='ja'
	#define LANGFILE='Languages\Japanese.isl'
#elif LANG=='ko'
	#define LANGFILE='Languages\Korean.isl'
#elif LANG=='lt'
	#define LANGFILE='Languages\Unofficial\Lithuanian.isl'
#elif LANG=='nl'
	#define LANGFILE='Languages\Dutch.isl'
#elif LANG=='no'
	#define LANGFILE='Languages\Norwegian.isl'
#elif LANG=='nn'
	#define LANGFILE='Languages\Unofficial\NorwegianNynorsk.isl'
#elif LANG=='pl'
	#define LANGFILE='Languages\Polish.isl'
#elif LANG=='pt'
	#define LANGFILE='Languages\Portuguese.isl'
#elif LANG=='pt_BR'
	#define LANGFILE='Languages\BrazilianPortuguese.isl'
#elif LANG=='ro'
	#define LANGFILE='Languages\Unofficial\Romanian.isl'
#elif LANG=='ru'
	#define LANGFILE='Languages\Russian.isl'
#elif LANG=='sk'
	#define LANGFILE='Languages\Slovak.isl'
#elif LANG=='sl'
	#define LANGFILE='Languages\Slovenian.isl'
#elif LANG=='sv'
	#define LANGFILE='Languages\Swedish.isl'
#elif LANG=='tr'
	#define LANGFILE='Languages\Turkish.isl'
#elif LANG=='uk'
	#define LANGFILE='Languages\Ukrainian.isl'
#elif LANG=='zh_CN'
	#define LANGFILE='Languages\Unofficial\ChineseSimplified.isl'
#endif

[Setup]
AppName=GIMP Help {#VERSION}
AppID=GIMP-Help-{#MAJORVERSION}
AppVerName=GIMP Help {#VERSION}
AppPublisherURL=https://docs.gimp.org/
AppSupportURL=https://docs.gimp.org/
AppUpdatesURL=https://docs.gimp.org/download.html
AppPublisher=The GIMP Team
DefaultDirName={autopf}\GIMP Help {#MAJORVERSION}
DirExistsWarning=no
DisableProgramGroupPage=yes
DisableDirPage=yes
FlatComponentsList=yes
WizardImageFile=big.bmp
WizardSmallImageFile=small.bmp
WizardImageStretch=no
CreateUninstallRegKey=no
UpdateUninstallLogAppName=no
UninstallFilesDir={app}\uninst
UsePreviousLanguage=no
VersionInfoDescription=GIMP Help {#VERSION}
VersionInfoProductName=GIMP Help {#VERSION}
#ifdef dontcompress
OutputDir=_Output\unc
Compression=none
InternalCompressLevel=0
#else
OutputDir=_Output
Compression=lzma/ultra
InternalCompressLevel=ultra
SolidCompression=yes
OutputBaseFilename=gimp-help-{#VERSION}-{#LANG}-setup
#endif
;SignedUninstaller=yes
;SignedUninstallerDir=_Uninst
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=commandline

[Languages]
Name: "{#LANG}"; MessagesFile: "compiler:{#LANGFILE},lang\help.en.isl,lang\help.{#LANG}.isl"

[Files]
#ifndef nofiles
Source: "{#HELPDIR}\{#LANG}\*.*"; DestDir: "{app}\share\gimp\{#DIR_VER}\help\{#LANG}"; Flags: recursesubdirs ignoreversion
#endif
;Source: "html\{#LANG}\*.jpg"; DestDir: "{app}\share\gimp\2.0\help\{#LANG}"; Flags: recursesubdirs nocompression
;Source: "html\{#LANG}\*.png"; DestDir: "{app}\share\gimp\2.0\help\{#LANG}"; Flags: recursesubdirs nocompression

[Code]
function WideCharToMultiByte(CodePage: Cardinal; dwFlags: DWORD; lpWideCharStr: String; cchWideCharStr: Integer;
                             lpMultiByteStr: PAnsiChar; cbMultiByte: Integer; lpDefaultChar: Integer;
                             lpUsedDefaultChar: Integer): Integer; external 'WideCharToMultiByte@Kernel32 stdcall';

function MultiByteToWideChar(CodePage: Cardinal; dwFlags: DWORD; lpMultiByteStr: PAnsiChar; cbMultiByte: Integer;
                             lpWideCharStr: String; cchWideChar: Integer): Integer;
                             external 'MultiByteToWideChar@Kernel32 stdcall';

function GetLastError(): DWORD; external 'GetLastError@Kernel32 stdcall';

const
	SHACF_FILESYSTEM = $1;
	CP_UTF8 = 65001;

	BCM_SETSHIELD = $160C;

#if Defined(DEVEL) && DEVEL != ""
	RegGimpUnins = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GIMP-{#MAJORVERSION}.{#MINORVERSION}_is1';
#else
	RegGimpUnins = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GIMP-{#MAJORVERSION}_is1';
#endif
	RegGimpUninsPathKey = 'Inno Setup: App Path';
	RegGimpUninsDispVerKey = 'DisplayVersion';

type
	TGimpInstall = record
		Path: String;
		RequireAdmin: Boolean;
		InstallCheckbox: TCheckbox;
	end;
	TGimpInstalls = array of TGimpInstall;

	TInstallModePreReqs = record
		Dir: Boolean;
		PrivOverride: Boolean;
	end;

var
	wpInstalls: TWizardPage;

	GimpInstalls: TGimpInstalls;

	InstallMode: (imFindInstalls, imInstall);

	LogParameter: String;
	SilentParameter: String;

	PreparingCounter: Integer;


function Count(What, Where: String): Integer;
begin
	Result := 0;
	if Length(What) = 0 then //nothing to count - should this throw an error?
		exit;

	while Pos(What,Where)>0 do
	begin
		Where := Copy(Where,Pos(What,Where)+Length(What),Length(Where));
		Result := Result + 1;
	end;
end;


//split text to array
procedure Explode(var ADest: TArrayOfString; aText, aSeparator: String);
var tmp: Integer;
begin
	if aSeparator='' then
		exit;

	SetArrayLength(ADest,Count(aSeparator,aText)+1)

	tmp := 0;
	repeat
		if Pos(aSeparator,aText)>0 then
		begin

			ADest[tmp] := Copy(aText,1,Pos(aSeparator,aText)-1);
			aText := Copy(aText,Pos(aSeparator,aText)+Length(aSeparator),Length(aText));
			tmp := tmp + 1;

		end else
		begin

			 ADest[tmp] := aText;
			 aText := '';

		end;
	until Length(aText)=0;
end;



//compares two version numbers, returns -1 if vA is newer, 0 if both are identical, 1 if vB is newer
function CompareVersion(vA,vB: String): Integer;
var tmp: TArrayOfString;
	verA,verB: Array of Integer;
	i,len: Integer;
begin

	StringChange(vA,'-','.');
	StringChange(vB,'-','.');

	Explode(tmp,vA,'.');
	SetArrayLength(verA,GetArrayLength(tmp));
	for i := 0 to GetArrayLength(tmp) - 1 do
		verA[i] := StrToIntDef(tmp[i],0);

	Explode(tmp,vB,'.');
	SetArrayLength(verB,GetArrayLength(tmp));
	for i := 0 to GetArrayLength(tmp) - 1 do
		verB[i] := StrToIntDef(tmp[i],0);

	len := GetArrayLength(verA);
	if GetArrayLength(verB) < len then
		len := GetArrayLength(verB);

	for i := 0 to len - 1 do
		if verA[i] < verB[i] then
		begin
			Result := 1;
			exit;
		end else
		if verA[i] > verB[i] then
		begin
			Result := -1;
			exit
		end;

	if GetArrayLength(verA) < GetArrayLength(verB) then
	begin
		Result := 1;
		exit;
	end else
	if GetArrayLength(verA) > GetArrayLength(verB) then
	begin
		Result := -1;
		exit;
	end;

	Result := 0;

end;


function RevPos(const SearchStr, Str: string): Integer;
var i: Integer;
begin

	if Length(SearchStr) < Length(Str) then
		for i := (Length(Str) - Length(SearchStr) + 1) downto 1 do
		begin

			if Copy(Str, i, Length(SearchStr)) = SearchStr then
			begin
				Result := i;
				exit;
			end;

		end;

	Result := 0;
end;


function Replace(pSearchFor, pReplaceWith, pText: String): String;
begin
    StringChangeEx(pText,pSearchFor,pReplaceWith,True);

	Result := pText;
end;


function Utf82String(const pInput: AnsiString): String;
var Output: String;
	ret, outLen, nulPos: Integer;
begin
	outLen := MultiByteToWideChar(CP_UTF8, 0, pInput, -1, Output, 0);
	Output := StringOfChar(#0,outLen);
	ret := MultiByteToWideChar(CP_UTF8, 0, pInput, -1, Output, outLen);

	if ret = 0 then
		RaiseException('MultiByteToWideChar failed: ' + IntToStr(GetLastError));

	nulPos := Pos(#0,Output) - 1;
	if nulPos = -1 then
		nulPos := Length(Output);

    Result := Copy(Output,1,nulPos);
end;


function LoadStringFromUTF8File(const pFileName: String; var oS: String): Boolean;
var Utf8String: AnsiString;
begin
	Result := LoadStringFromFile(pFileName, Utf8String);
	oS := Utf82String(Utf8String);
end;


function String2Utf8(const pInput: String): AnsiString;
var Output: AnsiString;
	ret, outLen, nulPos: Integer;
begin
	outLen := WideCharToMultiByte(CP_UTF8, 0, pInput, -1, Output, 0, 0, 0);
	Output := StringOfChar(#0,outLen);
	ret := WideCharToMultiByte(CP_UTF8, 0, pInput, -1, Output, outLen, 0, 0);

	if ret = 0 then
		RaiseException('WideCharToMultiByte failed: ' + IntToStr(GetLastError));

	nulPos := Pos(#0,Output) - 1;
	if nulPos = -1 then
		nulPos := Length(Output);

    Result := Copy(Output,1,nulPos);
end;


function SaveStringToUTF8File(const pFileName, pS: String; const pAppend: Boolean): Boolean;
begin
	Result := SaveStringToFile(pFileName, String2Utf8(pS), pAppend);
end;


procedure SaveToUninstInf(const pText: AnsiString);
var sUnInf: String;
	sOldContent: String;
begin
	sUnInf := ExpandConstant('{app}\uninst\uninst.inf');

	if not FileExists(sUnInf) then //save small header
		SaveStringToUTF8File(sUnInf,#$feff+'#Additional uninstall tasks'#13#10+ //#$feff BOM is required for LoadStringsFromFile
		                            '#This file uses UTF-8 encoding'#13#10+
		                            '#'#13#10+
		                            '#Empty lines and lines beginning with # are ignored'#13#10+
		                            '#'#13#10+
		                            '#Add uninstallers for GIMP add-ons that should be removed together with GIMP like this:'#13#10+
		                            '#Run:<description>/<full path to uninstaller>/<parameters for automatic uninstall>'#13#10+
		                            '#'#13#10+
		                            '#The file is parsed in reverse order' + #13#10 +
		                            '' + #13#10 //needs '' in front, otherwise preprocessor complains
		                            ,False)
	else
	begin
		if LoadStringFromUTF8File(sUnInf,sOldContent) then
			if Pos(#13#10+pText+#13#10,sOldContent) > 0 then //don't write duplicate lines
				exit;
	end;

	SaveStringToUTF8File(sUnInf,pText+#13#10,True);
end;


function ExtractGimpVersion(const VerStr: String): String;
var p: Integer;
begin
	p := Pos('gimp ',LowerCase(VerStr));
	if p > 0 then
		Result := Copy(VerStr,p+5,Length(VerStr))
	else
		Result := '0';
end;


procedure GetGimpInstall(const RootKey: Integer);
var n: Integer;
	Path, Version: String;
begin
	if RegQueryStringValue(RootKey, RegGimpUnins, RegGimpUninsPathKey, Path) then
		if RegQueryStringValue(RootKey, RegGimpUnins, RegGimpUninsDispVerKey, Version) then
		begin
			Log('Found GIMP install: ' + Path + '; ' + Version);

			if CompareVersion('{#MIN_VERSION}', Version) >= 0 then
			begin

				n := GetArrayLength(GimpInstalls);
				Inc(n);
				SetArrayLength(GimpInstalls,n);
				GimpInstalls[n-1].Path := Path;
				GimpInstalls[n-1].RequireAdmin := not (RootKey = HKCU);

			end;

		end;
end;


function GetGimpInfo(): Boolean;
begin

	if IsWin64 then
		GetGimpInstall(HKLM64);

	GetGimpInstall(HKLM);

	GetGimpInstall(HKCU);

	if GetArrayLength(GimpInstalls) = 0 then
	begin
		SuppressibleMsgBox(FmtMessage(CustomMessage('NoGimpInstallsFound'),[CustomMessage('GimpHelp'), '{#MIN_VERSION}']),mbError,MB_OK,IDOK);
		Result := False
	end else
	begin
		Result := True;
	end;

end;


procedure WriteUninstallInfo();
begin
	SaveToUninstInf('Run:GIMP Help/'+ExpandConstant('{uninstallexe}')+'//SILENT /NORESTART');
end;


function InitializeSetup(): Boolean;
var i: Integer;
	InstallModePreReqs: TInstallModePreReqs;
begin
	Result := True;
	InstallMode := imFindinstalls; //default
	PreparingCounter := 0;
	SilentParameter := '/SILENT'

	InstallModePreReqs.Dir := False;
	InstallModePreReqs.PrivOverride := False;

	for i := 0 to ParamCount do
	begin
		if LowerCase(ParamStr(i)) = '/install' then
			InstallMode := imInstall
		else if LowerCase(Copy(ParamStr(i),1,5)) = '/dir=' then
			InstallModePreReqs.Dir := True
		else if (LowerCase(Copy(ParamStr(i),1,9)) = '/allusers') or (LowerCase(Copy(ParamStr(i),1,12)) = '/currentuser') then
			InstallModePreReqs.PrivOverride := True
		else if LowerCase(Copy(ParamStr(i),1,4)) = '/log' then
			LogParameter := ParamStr(i)
		else if LowerCase(ParamStr(i)) = '/verysilent' then
			SilentParameter := '/VERYSILENT';
	end;

	if InstallMode = imInstall then
	begin
		//check for required parameters
		if (InstallModePreReqs.Dir = False) or (InstallModePreReqs.PrivOverride = False) then
		begin
			SuppressibleMsgBox(CustomMessage('MissingParameters'),mbError,MB_OK,IDOK);
			Result := False;
		end;

		exit;
	end;

	if Pos('=',LogParameter) > 0 then //needed, because only 1 instance of Setup can write to the same log file
	begin
		i := RevPos('.', LogParameter);
		if i > 0 then
			LogParameter := Copy(LogParameter, 1, i) + '?' + Copy(LogParameter, i, Length(LogParameter) - i + 1)
		else
			LogParameter := LogParameter + '.?';
		Log('New LogParameter: ' + LogParameter);
	end;

	Result := GetGimpInfo();
end;


procedure CurStepChanged(pCurStep: TSetupStep);
begin
	case pCurStep of
		ssInstall:
			if InstallMode = imFindinstalls then
			begin
				Abort();
			end;
		ssPostInstall:
		begin
			WriteUninstallInfo();
		end;
	end;
end;


function PrepareToInstall(var NeedsRestart: Boolean): String;
var n, r: Integer;
	Params: String;
begin
	if InstallMode = imFindInstalls then
	begin
		WizardForm.Hide;

		for n := 0 to GetArrayLength(GimpInstalls) - 1 do
			if (GimpInstalls[n].InstallCheckbox = nil) or (GimpInstalls[n].InstallCheckbox.Checked) then
			begin
				Params := '"' + ExpandConstant('{srcexe}') + '" ' + SilentParameter + ' /NOCANCEL /INSTALL /DIR="' +
				          GimpInstalls[n].Path + '" ' +
				          Replace('?', IntToStr(n + 1), LogParameter);

				if GimpInstalls[n].RequireAdmin then
					Params := Params + ' /ALLUSERS'
				else
					Params := Params + ' /CURRENTUSER';

				Log('Running: ' + Params);
				if Exec('>', Params, GetCurrentDir, SW_SHOW, ewWaitUntilTerminated, r) then
					Log('Success, Setup return code: ' + IntToStr(r))
				else
					Log('Failed, return code: ' + IntToStr(r) + ' (' + SysErrorMessage(r) + ')');
			end;

		WizardForm.Show;

		if not WizardSilent then
			Result := 'Abort'; //nothing to install in this session, abuse this to abort the setup, and show "finished" page
	                           //(only in non-silent mode, to not show an error dialog; in silent mode, abort in ssInstall)
	end;
end;


procedure InstallChecks();
var	n: Integer;
	SomethingSelected, AdminReqd: Boolean;
begin
	AdminReqd := False;
	SomethingSelected := False;

	for n := 0 to GetArrayLength(GimpInstalls) - 1 do
	begin
		if (GimpInstalls[n].InstallCheckbox = nil) or GimpInstalls[n].InstallCheckbox.Checked then
		begin
			SomethingSelected := True;

			if GimpInstalls[n].RequireAdmin then
				AdminReqd := True;
		end;
	end;

	WizardForm.NextButton.Enabled := SomethingSelected;

	if AdminReqd then
		PostMessage(WizardForm.NextButton.Handle, BCM_SETSHIELD, 0, 1)
	else
		PostMessage(WizardForm.NextButton.Handle, BCM_SETSHIELD, 0, 0);
end;


procedure CBInstallOnClick(Sender: TObject);
begin
	InstallChecks();
end;


procedure InitializeWizard();
var	n: Integer;
	lblInfo: TNewStaticText;
begin
	if (InstallMode = imFindInstalls) and (GetArrayLength(GimpInstalls) > 1) then
	begin
		wpInstalls := CreateCustomPage(wpWelcome, CustomMessage('SelectGimpInstallsCaption'),
		                               FmtMessage(CustomMessage('SelectGimpInstallsDescription'),[CustomMessage('GimpHelp')]));

		lblInfo := TNewStaticText.Create(wpInstalls);
		with lblInfo do
		begin
			Top := 0;
			Left := 0;
			Parent := wpInstalls.Surface;
			Caption := 'Text';
			Visible := False;
		end;
        WizardForm.AdjustLabelHeight(lblInfo);

		for n := 0 to GetArrayLength(GimpInstalls) - 1 do
		begin
			GimpInstalls[n].InstallCheckbox := TCheckBox.Create(wpInstalls);
			with GimpInstalls[n].InstallCheckbox do
			begin

				Left := 0;
                Width := wpInstalls.Surface.Width - Left;
				if n = 0 then
					Top := 0 //lblInfo.Top + lblInfo.Height + ScaleY(12)
				else
					Top := GimpInstalls[n-1].InstallCheckbox.Top + GimpInstalls[n-1].InstallCheckbox.Height + ScaleY(12);
                Height := lblInfo.Height;
				Tag := n;

				Checked := True;
				Caption := GimpInstalls[n].Path;
				OnClick := @CBInstallOnClick;

				Parent := wpInstalls.Surface;

			end;
		end;
	end;
end;


function ShouldSkipPage(PageID: Integer): Boolean;
begin
	Result := False;
	case PageID of
		wpReady:
			Result := GetArrayLength(GimpInstalls) > 1;  //skip the Ready page when confirmation page was shown
	end;
end;


procedure ChangeWPPreparing();
begin
	Inc(PreparingCounter);

	if PreparingCounter = 2 then //second time happens after PrepareToInstall returns non-empty string
	begin
		//TODO: this doesn't look like the normal Finished page
		WizardForm.NextButton.Visible := False;
		WizardForm.BackButton.Visible := False;
		WizardForm.CancelButton.Caption := SetupMessage(msgButtonFinish);
		WizardForm.PreparingErrorBitmapImage.Visible := False;
		WizardForm.PreparingLabel.Caption := SetupMessage(msgClickFinish);
		WizardForm.PreparingLabel.Left := 0;
		WizardForm.PreparingLabel.Width := WizardForm.PreparingPage.Width;
		WizardForm.AdjustLabelHeight(WizardForm.PreparingLabel);
		WizardForm.PageNameLabel.Caption := Replace('[name]',CustomMessage('GimpHelp'),SetupMessage(msgFinishedHeadingLabel));
		WizardForm.PageDescriptionLabel.Caption := Replace('[name]',CustomMessage('GimpHelp'),SetupMessage(msgFinishedLabel));
	end;
end;


procedure CurPageChanged(CurPageID: Integer);
begin
	Log('CurPageChanged: ' + IntToStr(CurPageID));
    if (CurPageID = wpReady) and (InstallMode = imFindInstalls) then
        InstallChecks();

    if (CurPageID = wpPreparing) and (InstallMode = imFindInstalls) then
    	ChangeWPPreparing();

    if (wpInstalls <> nil) and (CurPageID = wpInstalls.ID) then
    begin
        InstallChecks();
        WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall);
    end;
end;

#expr SaveToFile(AddBackslash(SourcePath) + "Preprocessed." + LANG + ".iss")
