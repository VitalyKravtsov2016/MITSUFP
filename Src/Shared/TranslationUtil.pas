unit TranslationUtil;

interface

uses
  // VCL
  SysUtils,
  // This
  VersionInfo, LangUtils, gnugettext;

procedure SetTranslationLanguage;
procedure SetCustomTranslationLanguage(const Language: string);

implementation

procedure SetTranslationLanguage;
begin
  bindtextdomain('DrvFR', IncludeTrailingBackslash
    (ExtractFilePath(GetDllFileName)) + 'locale');
  textdomain('DrvFR');
  UseLanguage(GetLanguage);
end;

procedure SetCustomTranslationLanguage(const Language: string);
begin
  bindtextdomain('DrvFR', IncludeTrailingBackslash
    (ExtractFilePath(GetDllFileName)) + 'locale');
  textdomain('DrvFR');
  UseLanguage(Language);
end;

end.
