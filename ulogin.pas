unit uLogin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TfrLogin }

  TfrLogin = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    ePassword: TEdit;
    pBottom: TPanel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frLogin: TfrLogin;

implementation

{$R *.lfm}

uses uDataModule;

{ TfrLogin }

procedure TfrLogin.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if modalresult = mrOk then
    CanClose := (ePassword.Text = dmData.zcDatabaseConnection.Password);
end;

end.

