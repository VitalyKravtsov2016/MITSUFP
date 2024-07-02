unit duLogFile;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework,
  // This
  LogFile, FileUtils;

type
  { TLogFileTest }

  TLogFileTest = class(TTestCase)
  public
    procedure CheckMaxSize;
  published
    procedure CheckDeleteFile;
    procedure CheckWrite;
  end;

implementation

{ TLogFileTest }

procedure TLogFileTest.CheckMaxSize;
var
  Data: AnsiString;
  Logger: ILogFile;
  FilesPath: string;
  FileNames: TStringList;
begin
  FileNames := TStringList.Create;
  try
    Logger := TLogFile.Create;
    Logger.MaxCount := 1;
    Logger.Enabled := True;
    Logger.FilePath := GetModulePath + 'Logs';
    Logger.DeviceName := 'Device1';

    FilesPath := GetModulePath + 'Logs\';
    DeleteFiles(FilesPath + '*.log');
    Data := StringOfChar(#0, 4096);
    repeat
      Logger.Write(Data);
      if ((Logger.FileSize div 1024) > (MAX_FILE_SIZE_IN_KB * 2)) then Break;
    until False;
  finally
    FileNames.Free;
  end;
end;

procedure TLogFileTest.CheckDeleteFile;
var
  Logger: ILogFile;
  Lines: TStrings;
begin
  Logger := TLogFile.Create;
  Lines := TStringList.Create;
  try
    Logger.MaxCount := 10;
    Logger.Enabled := True;
    Logger.FilePath := GetModulePath + 'Logs\';
    Logger.DeviceName := 'DeviceName1';
    Logger.TimeStampEnabled := False;

    DeleteFile(Logger.GetFileName);
    CheckEquals(False, FileExists(Logger.GetFileName), 'FileExists!');

    Logger.Debug('Line1');
    Logger.Error('Line2');
    Logger.CloseFile;

    Lines.LoadFromFile(Logger.GetFileName);
    CheckEquals(2, Lines.Count, 'Lines.Count');
    CheckEquals('[DEBUG] Line1', Lines[0], 'Lines[0]');
    CheckEquals('[ERROR] Line2', Lines[1], 'Lines[1]');

    Logger.Debug('Line3');
    Logger.Error('Line4');
    Logger.CloseFile;

    Lines.LoadFromFile(Logger.GetFileName);
    CheckEquals(4, Lines.Count, 'Lines.Count');
    CheckEquals('[DEBUG] Line1', Lines[0], 'Lines[0]');
    CheckEquals('[ERROR] Line2', Lines[1], 'Lines[1]');
    CheckEquals('[DEBUG] Line3', Lines[2], 'Lines[2]');
    CheckEquals('[ERROR] Line4', Lines[3], 'Lines[3]');

    Logger.DeviceName := 'DeviceName2';
    DeleteFile(Logger.GetFileName);
    CheckEquals(False, FileExists(Logger.GetFileName), 'FileExists!');

    Logger.Debug('Line1');
    Logger.Error('Line2');
    Logger.CloseFile;

    Lines.LoadFromFile(Logger.GetFileName);
    CheckEquals(2, Lines.Count, 'Lines.Count');
    CheckEquals('[DEBUG] Line1', Lines[0], 'Lines[0]');
    CheckEquals('[ERROR] Line2', Lines[1], 'Lines[1]');

    Logger.Debug('Line3');
    Logger.Error('Line4');
    Logger.CloseFile;

    Lines.LoadFromFile(Logger.GetFileName);
    CheckEquals(4, Lines.Count, 'Lines.Count');
    CheckEquals('[DEBUG] Line1', Lines[0], 'Lines[0]');
    CheckEquals('[ERROR] Line2', Lines[1], 'Lines[1]');
    CheckEquals('[DEBUG] Line3', Lines[2], 'Lines[2]');
    CheckEquals('[ERROR] Line4', Lines[3], 'Lines[3]');
    Logger.CloseFile;

    DeleteFiles(Logger.FilePath  + '*.log');
  finally
    Lines.Free;
  end;
end;

procedure TLogFileTest.CheckWrite;
var
  Logger: ILogFile;
begin
  Logger := TLogFile.Create;
  Logger.MaxCount := 3;
  Logger.Enabled := True;
  Logger.FilePath := 'C:\';
  Logger.DeviceName := 'Device1';
  Logger.Write('Test');

end;


initialization
  RegisterTest('', TLogFileTest.Suite);

end.
