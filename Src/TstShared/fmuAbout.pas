unit fmuAbout;

interface

uses
  // VCL
  Windows, Forms, ExtCtrls, StdCtrls, Controls, Classes, ShellAPI, Graphics,
  // gnugettext
  gnugettext, 
  // This
  BaseForm, Vcl.Imaging.pngimage;

type
  { TfmAbout }

  TfmAbout = class(TBaseForm)
    btnOK: TButton;
    lblURL: TLabel;
    lblWebSite: TLabel;
    lblSupport: TLabel;
    lblSupportMail: TLabel;
    NameLabel: TLabel;
    lbVersion: TListBox;
    lblFirmName: TLabel;
    Bevel2: TBevel;
    memAddress: TMemo;
    imgLogo: TImage;
    procedure lblURLClick(Sender: TObject);
    procedure lblSupportMailClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

procedure ShowAboutBox(ParentWnd: HWND; const ACaption: string;
  Info: array of string);

implementation

{$R *.DFM}

procedure ShowAboutBox(ParentWnd: HWND; const ACaption: string;
  Info: array of string);
var
  i: Integer;
  fm: TFmAbout;
begin
  fm := TfmAbout.Create(nil);
  try
    with fm do
    begin
      SetWindowLong(Handle, GWL_HWNDPARENT, ParentWnd);
      NameLabel.Caption := ACaption;
      for i:= Low(Info) to High(Info) do lbVersion.Items.Add(Info[i]);
      ShowModal;
    end;
  finally
    fm.Free;
  end;
end;

{ TfmAbout }

procedure TfmAbout.lblURLClick(Sender: TObject);
begin
  ShellExecute(GetDesktopWindow(),'open','http://www.shtrih-m.ru',
    nil, nil, SW_SHOWNORMAL);
end;

procedure TfmAbout.lblSupportMailClick(Sender: TObject);
begin
  ShellExecute(GetDesktopWindow(),'open','mailto:support@shtrih-m.ru',
    nil, nil, SW_SHOWNORMAL);
end;

procedure TfmAbout.FormCreate(Sender: TObject);
begin
{$IFNDEF  WIN64}
  TranslateComponent(Self);
{$ENDIF}
end;

end.
