{ To do list:

1.

}
unit uAccountWizard;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, db;

type

  { TfrNewAccountWizard }

  TfrNewAccountWizard = class(TForm)
    bCancel: TButton;
    bNext: TButton;
    bPrevious: TButton;
    cbAccountType: TComboBox;
    eAccountName: TEdit;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    nbPages: TNotebook;
    Page1: TPage;
    Page2: TPage;
    Page3: TPage;
    Panel1: TPanel;
    pBottom: TPanel;
    pgWelcome1: TPage;
    procedure bCancelClick(Sender: TObject);
    procedure bNextClick(Sender: TObject);
    procedure bPreviousClick(Sender: TObject);
    procedure eAccountNameChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SaveNewAccount;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frNewAccountWizard: TfrNewAccountWizard;

implementation

{$R *.lfm}

uses uMain,uDataModule;

{ TfrNewAccountWizard }

procedure TfrNewAccountWizard.SaveNewAccount;
var ParentNode, newNode : TTreeNode;
  MyAccountRec: PAccountRec;
  AccountID : integer;
begin
  dmData.ztAccountList.Insert;
  dmData.ztAccountList.FieldByName('ACCOUNTNAME').AsString := eAccountName.Text;
  dmData.ztAccountList.FieldByName('ACCOUNTTYPE').AsString := cbAccountType.Text;
  dmData.ztAccountList.FieldByName('STATUS').AsString := 'Open';
  dmData.ztAccountList.FieldByName('INITIALBAL').AsInteger := 0;
  dmData.ztAccountList.FieldByName('FAVORITEACCT').AsString := 'FALSE';
  dmData.ztAccountList.FieldByName('CURRENCYID').AsInteger := 1;
  dmData.SaveChanges(dmData.ztAccountList, False);
  AccountID := dmData.ztAccountList.fieldbyname('ACCOUNTID').AsInteger;


  New(MyAccountRec);
  MyAccountRec^.AccountID :=  AccountID;
  MyAccountRec^.AccountName:= eAccountName.Text;
  MyAccountRec^.AccountType:= cbAccountType.Text;

  ParentNode := dmData.GetNodeByText(frMain.tvNavigation, 'Bank Accounts', false);
  if ParentNode = nil then
    //Insert a bank accounts parent node.
    ShowMessage('Not found!')
  else
    ParentNode.Selected := True;

  newNode := frMain.tvNavigation.Items.addChildObject(ParentNode, eAccountName.Text, MyAccountRec);
  newNode.SelectedIndex:=3;
  newNode.ImageIndex:=3;

  frMain.tvNavigation.Selected := newNode;

  Close;
end;

procedure TfrNewAccountWizard.bNextClick(Sender: TObject);
begin
  if bNext.Caption = 'Finish' then
  begin
    SaveNewAccount;
    exit;
  end;
  if nbPages.PageIndex < 2 then
    nbPages.PageIndex := nbPages.PageIndex + 1;
  bPrevious.enabled := (nbPages.PageIndex > 0);

  case nbPages.PageIndex of
    0 : begin
          bNext.Caption:='Next >';
        end;
    1 : begin
          bNext.Enabled:= (length(eAccountName.Text) > 0);
          eAccountName.SetFocus;
          bNext.Caption:='Next >';
        end;
    2 : begin
          if dmData.ztAccountList.Locate('ACCOUNTNAME', eAccountName.Text, [loCaseInsensitive]) = True then
            begin
              nbPages.PageIndex := 1;
              MessageDlg('Account name: '+eAccountName.Text+' already exists.',mtError, [mbOK], 0);
              exit;
            end;

          cbAccountType.SetFocus;
          bNext.Caption:= 'Finish';
        end;
  end;
end;

procedure TfrNewAccountWizard.bCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrNewAccountWizard.bPreviousClick(Sender: TObject);
begin
  if nbPages.PageIndex > 0 then
    nbPages.PageIndex := nbPages.PageIndex - 1;

  if nbPages.PageIndex = 2 then bNext.Caption:= 'Finish' else bNext.Caption:='Next >';

  bPrevious.enabled := (nbPages.PageIndex > 0);

  if nbPages.PageIndex > 0 then
    bNext.Enabled:= (length(eAccountName.Text) > 0)
  else
    bNext.Enabled := True;
end;

procedure TfrNewAccountWizard.eAccountNameChange(Sender: TObject);
begin
  bNext.Enabled:= (length(eAccountName.Text) > 0);
end;

procedure TfrNewAccountWizard.FormCreate(Sender: TObject);
begin
  cbAccountType.ItemIndex:= 0;
end;

end.

