unit uReportFilter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, EditBtn, db;

type

  { TfrReportFilter }

  TfrReportFilter = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    cbBankAccount: TComboBox;
    deFromDate: TDateEdit;
    deToDate: TDateEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    pBottom: TPanel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    DateFilter , AccountFilter : string;
  end;

var
  frReportFilter: TfrReportFilter;

implementation

{$R *.lfm}

uses {uReportFuncs,} uDataModule;

{ TfrReportFilter }

procedure TfrReportFilter.FormShow(Sender: TObject);
begin
  dmData.SetupComboBox(frReportFilter.cbBankAccount, dmdata.ztAccountList, 'ACCOUNTNAME', '[All Accounts]', '[All Accounts]');
//  SetupRepAccountsComboBox(frReportFilter.cbBankAccount);
  DateFilter := '';
  AccountFilter := '';
end;

procedure TfrReportFilter.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if deFromDate.Text <> '    /  /  ' then
    DateFilter := ' and transdate >= '+chr(39)+ FormatDateTime('YYYY-MM-DD',deFromDate.Date)+chr(39);

  if deToDate.Text <> '    /  /  ' then
    DateFilter := DateFilter+' and transdate <= '+chr(39)+ FormatDateTime('YYYY-MM-DD',deToDate.Date)+chr(39);

  if dmData.ztAccountList.Locate('ACCOUNTNAME', cbBankAccount.Text , [loCaseInsensitive]) = True then
    AccountFilter := ' and ch.accountid = '+IntToStr(dmData.ztAccountList.fieldbyname('ACCOUNTID').AsInteger)
  else
    AccountFilter := '';
end;

end.

