unit uPayeeImport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DbCtrls;

type

  { TfrPayeeImport }

  TfrPayeeImport = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    dbePayeeID: TDBEdit;
    dbePayeeImportID: TDBEdit;
    dblcbPayeeName: TDBLookupComboBox;
    eMatchText: TDBEdit;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label6: TLabel;
    pBottom: TPanel;
    procedure dblcbPayeeNameChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    EditMode : string;
  end;

var
  frPayeeImport: TfrPayeeImport;

implementation

{$R *.lfm}

uses uDataModule;

{ TfrPayeeImport }

procedure TfrPayeeImport.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if modalresult = mrOk then
  begin
    if eMatchText.Text = '' then
    begin
      canclose := False;
      eMatchText.SetFocus;
      exit;
    end;
    if dbePayeeID.Text = '' then
    begin
      canclose := False;
      dblcbPayeeName.SetFocus;
      exit;
    end;

  end;
end;

procedure TfrPayeeImport.dblcbPayeeNameChange(Sender: TObject);
begin
  if eMatchText.Text = '' then eMatchText.Text:= dblcbPayeeName.Text;
end;

procedure TfrPayeeImport.FormShow(Sender: TObject);
begin
  if EditMode = 'Edit' then
  begin
     frPayeeImport.Caption:= 'Editing Payee Import Criteria';
     dmData.ztPayeeImport.Edit;

  end else
  if EditMode = 'Insert' then
  begin
    frPayeeImport.Caption:= 'Inserting Payee Import Criteria';
    dmData.ztPayeeImport.Insert;

  end;
end;

end.

