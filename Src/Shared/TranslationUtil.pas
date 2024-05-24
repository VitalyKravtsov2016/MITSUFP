unit TranslationUtil;

interface
uses
  // VCL
  SysUtils,
  // gnugettext
  gnugettext,
  // This
  VersionInfo, LangUtils;

  procedure SetTranslationLanguage;
  procedure SetCustomTranslationLanguage(const Language: string);

implementation

  procedure SetTranslationLanguage;
  begin
    bindtextdomain('DrvFR', IncludeTrailingBackslash(ExtractFilePath(GetDllFileName)) + 'locale');
    textdomain('DrvFR');
    UseLanguage(GetLanguage);
  end;

  procedure SetCustomTranslationLanguage(const Language: string);
  begin
    bindtextdomain('DrvFR', IncludeTrailingBackslash(ExtractFilePath(GetDllFileName)) + 'locale');
    textdomain('DrvFR');
    UseLanguage(Language);
  end;
end.
