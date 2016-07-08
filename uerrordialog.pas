{ To do list:

1. Add user input memo to describe process before error and have it email log
2. Log error to a text file. Include program build details, and user OS and pc details?

//  Application.OnException := @CustomExceptionHandler;  unrem this line in main.pas formcreate

}
unit uErrorDialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls{, registry};

type

  { TfrErrorDialog }

  TfrErrorDialog = class(TForm)
    bOk: TButton;
    Image1: TImage;
    Label2: TLabel;
    lbProblemHeader: TLabel;
    Label4: TLabel;
    mErrorLog: TMemo;
    Panel1: TPanel;
    ErrorPanel: TPanel;
    pBottom: TPanel;
    procedure bCloseClick(Sender: TObject);
    procedure bOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
//    procedure GetEnviromentVariableDetails(Memo : TMemo);
  private
    { private declarations }
  public
    { public declarations }
    procedure ShowMessage(Message : String);
  end;

var
  frErrorDialog: TfrErrorDialog;

implementation

{$R *.lfm}

{ TfrErrorDialog }

{procedure TfrErrorDialog.GetEnviromentVariableDetails(Memo : TMemo);
var
  reg:TRegistry;
  envl: TStringList;
  i: Integer;
begin
  reg:=TRegistry.Create();
  envl:=TStringList.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    Memo.lines.Add('');
    Memo.lines.Add('USER');
    if reg.OpenKeyReadOnly('\Environment') then
      begin
      reg.GetValueNames(envl);
      for i:=0 to envl.count-1 do
        begin
        Memo.lines.Add(envl[i]+' = '+ reg.ReadString(envl[i]));
        end;
      end;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Memo.lines.Add('SYSTEM');
    if reg.OpenKeyReadOnly('\SYSTEM\CurrentControlSet\Control\Session Manager\Environment') then
      begin
      reg.GetValueNames(envl);
      for i:=0 to envl.count-1 do
        begin
        Memo.lines.Add(envl[i]+' = '+ reg.ReadString(envl[i]));
        end;
      end;
  finally
    reg.free;
    envl.free;
  end;
end;}

procedure TfrErrorDialog.ShowMessage(Message : String);
begin
  frErrorDialog := TfrErrorDialog.create(self);
  with frErrorDialog do
  begin
    mErrorLog.Clear;
    mErrorLog.Lines.Add(Message);
//    GetEnviromentVariableDetails(mErrorLog);
    Showmodal;
    Free;
  end;
end;

procedure TfrErrorDialog.bCloseClick(Sender: TObject);
begin
end;

procedure TfrErrorDialog.bOkClick(Sender: TObject);
begin
  halt;
end;

procedure TfrErrorDialog.FormCreate(Sender: TObject);
begin
  lbProblemHeader.Caption:= ApplicationName + ' has encountered a problem.';
end;

procedure TfrErrorDialog.Image1Click(Sender: TObject);
begin
end;

end.

