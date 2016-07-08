{ To do list:

1. Add counts before confirmation.
2. Add option to create new payee.
3. Add edit filter to checklist box items
4. Add option to update existing payee categories

}
unit uRelocatePayee;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, CheckLst, db;

type

  { TfrRelocatePayee }

  TfrRelocatePayee = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    cbPayeeTo: TComboBox;
    cbDeleteSource: TCheckBox;
    chlbSource: TCheckListBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    pBottom: TPanel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure DoRelocate;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frRelocatePayee: TfrRelocatePayee;

implementation

{$R *.lfm}

uses uDataModule, uMain;

{ TfrRelocatePayee }

procedure TfrRelocatePayee.FormCreate(Sender: TObject);
var i : integer;
begin
  dmData.ztPayee.First;
  for i:=1 to dmData.ztPayee.recordcount do
  begin
    cbPayeeTo.Items.Add(dmData.ztPayee.FieldByName('PAYEENAME').AsString);
    chlbSource.Items.Add(dmData.ztPayee.FieldByName('PAYEENAME').AsString);
    dmData.ztPayee.Next;
  end;
end;

procedure TfrRelocatePayee.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if modalresult = mrOk then
  begin
    if {(cbPayeeFrom.Text = '')  or} (cbPayeeTo.Text = '') then
      begin
        CanClose := False;
        exit;
      end;

    DoRelocate;
  end;
end;

procedure TfrRelocatePayee.DoRelocate;
var TransCnt, SplitTransCnt, RepTransCnt, RepSplitTransCnt, DefPayCnt, BudCnt, ToPayeeID, FromPayeeID, i : integer;
begin
{  TransCnt := 0;
  SplitTransCnt := 0;
  RepTransCnt := 0;
  RepSplitTransCnt := 0;
  DefPayCnt := 0;
  BudCnt := 0;
  ToPayeeID := -1;
  FromPayeeID := -1;

  dmData.ZQuery1.Active:= False;
  dmData.ZQuery1.SQL.Clear;
  dmData.ZQuery1.SQL.Add(
  ' select * '+
  ' from '+ dmData.ztCheckingAccount.TableName+' ch, '+
  dmData.ztPayee.TableName+' p '+
  ' where ch.payeeid = p.payeeid '+
  ' and p.payeename = '+QuotedStr(cbPayeeFrom.Text));
  dmData.ZQuery1.ExecSQL;
  dmData.ZQuery1.Active:= True;
  TransCnt := dmData.ZQuery1.RecordCount;
  dmData.ZQuery1.Active:= False;

  if MessageDlg(
  'Please Confirm '+
  #13#10#13#10+
  'Records found in transactions: '+IntToStr(TransCnt)+#13#10+
{  'Records found in split transactions: '+IntToStr(SplitTransCnt)+#13#10+
  'Records found in repeating transactions: '+IntToStr(RepTransCnt)+#13#10+
  'Records found in repeating split transactions: '+IntToStr(RepSplitTransCnt)+#13#10+
  'Records found in Default Payee category: '+IntToStr(DefPayCnt)+#13#10+
  'Records found in budget: '+IntToStr(BudCnt)+#13#10+}
  #13#10+
  'Changing all payees of: '+#13#10+
  cbPayeeFrom.Text+#13#10+
  'to: '+#13#10+
  cbPayeeTo.Text+#13#10
  ,mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;

  if (dmData.ztPayee.Locate('PAYEENAME', cbPayeeTo.Text, [loCaseInsensitive]) = True) then
    ToPayeeID := dmData.ztPayee.FieldByName('PAYEEID').AsInteger;

  if (dmData.ztPayee.Locate('PAYEENAME', cbPayeeFrom.Text, [loCaseInsensitive]) = True) then
    FromPayeeID := dmData.ztPayee.FieldByName('PAYEEID').AsInteger;

  //Run datafix
  dmData.ZQuery1.SQL.Clear;
  dmData.ZQuery1.SQL.Add(
  ' update '+dmData.ztCheckingAccount.TableName+
  ' set payeeid = '+IntToStr(ToPayeeID) +
  ' where payeeid = '+IntToStr(FromPayeeID));
  dmData.ZQuery1.ExecSQL;

  if cbDeleteSource.Checked then
  begin
    dmData.ZQuery1.SQL.Clear;
    dmData.ZQuery1.SQL.Add('delete from '+dmData.ztPayee.TableName+' where payeeid = '+IntToStr(FromPayeeID)+';');
    dmData.ZQuery1.ExecSQL;

//    dmdata.RefreshDataset(dmData.ztPayee);
//    dmdata.RefreshDataset(dmData.zqPayee);
  end;

  }

  if (dmData.ztPayee.Locate('PAYEENAME', cbPayeeTo.Text, [loCaseInsensitive]) = True) then
    ToPayeeID := dmData.ztPayee.FieldByName('PAYEEID').AsInteger;

  for i := 0 to chlbSource.Items.Count-1 do
  begin
    if chlbSource.Checked[i] then
      begin
        dmData.ZQuery1.SQL.Clear;

        if (dmData.ztPayee.Locate('PAYEENAME', chlbSource.items[i], [loCaseInsensitive]) = True) then
          FromPayeeID := dmData.ztPayee.FieldByName('PAYEEID').AsInteger;

        dmData.ZQuery1.SQL.Add(
          ' update '+dmData.ztCheckingAccount.TableName+
          ' set payeeid = '+IntToStr(ToPayeeID) +
          ' where payeeid = '+IntToStr(FromPayeeID));
        dmData.ZQuery1.ExecSQL;

        if cbDeleteSource.Checked then
        begin
          dmData.DeleteDBRecord(dmData.ztPayee.TableName, 'payeeid', FromPayeeID);
        end;
      end;
  end;
  dmdata.RefreshDataset(dmData.ztPayee);

  case frMain.pcNavigation.PageIndex of
    pgPayees : dmdata.RefreshDataset(dmData.zqPayee);
    pgBankAccs : dmdata.RefreshDataset(dmData.zqBankAccounts);
  end;
end;

end.

