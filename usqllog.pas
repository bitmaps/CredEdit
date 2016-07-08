{ To do list:

1. Maybe add a save to file option

}
unit uSQLLog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, inifiles;

type

  { TfrSQLLog }

  TfrSQLLog = class(TForm)
    MenuItem1: TMenuItem;
    miSelectAll: TMenuItem;
    miCopy: TMenuItem;
    miClearLog: TMenuItem;
    miClose: TMenuItem;
    mLog: TMemo;
    pmLog: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    procedure miClearLogClick(Sender: TObject);
    procedure miCloseClick(Sender: TObject);
    procedure miCopyClick(Sender: TObject);
    procedure miSelectAllClick(Sender: TObject);
    procedure LoadSettings;
    procedure SaveSettings;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frSQLLog: TfrSQLLog;

implementation

{$R *.lfm}

{ TfrSQLLog }

procedure TfrSQLLog.LoadSettings;
var IniFile : TIniFile;
begin
  IniFile := TIniFile.create(ExtractFilePath(application.exename)+'settings.ini');
  try
    frSQLLog.Width := IniFile.ReadInteger('Configuration', 'SQLWindowWidth', 460);
    frSQLLog.Height := IniFile.ReadInteger('Configuration', 'SQLWindowHeight', 460 );
    frSQLLog.Left := IniFile.ReadInteger('Configuration', 'SQLWindowLeft', 50);
    frSQLLog.Top := IniFile.ReadInteger('Configuration', 'SQLWindowTop', 50);
  finally
    IniFile.Free;
  end;
end;

procedure TfrSQLLog.SaveSettings;
var IniFile : TIniFile;
begin
  IniFile := TIniFile.create(ExtractFilePath(application.exename)+'settings.ini');
  try
    IniFile.WriteInteger('Configuration', 'SQLWindowWidth', frSQLLog.Width);
    IniFile.WriteInteger('Configuration', 'SQLWindowHeight', frSQLLog.Height);
    IniFile.WriteInteger('Configuration', 'SQLWindowLeft', frSQLLog.Left);
    IniFile.WriteInteger('Configuration', 'SQLWindowTop', frSQLLog.Top);
  finally
    IniFile.Free;
  end;
end;

procedure TfrSQLLog.miCloseClick(Sender: TObject);
begin
  SaveSettings;
  close;
end;

procedure TfrSQLLog.miCopyClick(Sender: TObject);
begin
  mLog.CopyToClipboard;
end;

procedure TfrSQLLog.miSelectAllClick(Sender: TObject);
begin
  mLog.SelectAll;
end;

procedure TfrSQLLog.miClearLogClick(Sender: TObject);
begin
  mLog.Clear;
end;

procedure TfrSQLLog.FormCreate(Sender: TObject);
begin
  LoadSettings;
end;

end.

