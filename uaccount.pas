{ To do list:

1. Add Currency options
2. Enable favourite option

}

unit uAccount;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, DbCtrls, ExtCtrls;

type

  { TfrAccount }

  TfrAccount = class(TForm)
    bCancel: TButton;
    bCurrency: TButton;
    bOk: TButton;
    cbAccountStatus: TComboBox;
    cbAccountType: TComboBox;
    cbFavouriteAccount: TDBCheckBox;
    eAccessInfo: TDBEdit;
    eAccountName: TDBEdit;
    eAccountNumber: TDBEdit;
    eContact: TDBEdit;
    eHeldAt: TDBEdit;
    eInitialBalance: TEdit;
    eWebsite: TDBEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    memNotes: TDBMemo;
    PageControl1: TPageControl;
    pBottom: TPanel;
    tsNotes: TTabSheet;
    tsOthers: TTabSheet;
    procedure eInitialBalanceExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    EditMode : string;
  end;

var
  frAccount: TfrAccount;

implementation

{$R *.lfm}

uses uDataModule;

{ TfrAccount }

procedure TfrAccount.eInitialBalanceExit(Sender: TObject);
begin
  dmData.DisplayCurrencyEdit(eInitialBalance);
end;

procedure TfrAccount.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if modalresult = mrOk then
  begin
    if eAccountName.Text = '' then
    begin
      canclose := False;
      eAccountName.SetFocus;
      exit;
    end;
    if cbAccountType.Text = '' then
    begin
      canclose := False;
      cbAccountType.SetFocus;
      exit;
    end;
    if cbAccountStatus.Text = '' then
    begin
      canclose := False;
      cbAccountStatus.SetFocus;
      exit;
    end;

    if eInitialBalance.Text <> '' then
      dmData.ztAccountList.FieldByName('INITIALBAL').AsCurrency := dmData.CurrencyEditToFloat(eInitialBalance);
  end;
end;

procedure TfrAccount.FormShow(Sender: TObject);
begin
  eAccountName.SetFocus;
  eInitialBalance.Text:= floatToStr(dmData.ztAccountList.FieldByName('INITIALBAL').AsCurrency);
  dmData.DisplayCurrencyEdit(eInitialBalance);
end;

end.

