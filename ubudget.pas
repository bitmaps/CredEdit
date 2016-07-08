unit uBudget;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ExtCtrls, DbCtrls, ZDataset, db;

type

  { TfrBudget }

  TfrBudget = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    cbBudgets: TComboBox;
    cbMonth: TComboBox;
    cbFrequency: TComboBox;
    cbArchived: TCheckBox;
    cbAccounts: TComboBox;
    dsBudgetYearLookup: TDataSource;
    eBudgetName: TEdit;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label7: TLabel;
    lbBaseBudgets: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    pBottom: TPanel;
    seYear: TSpinEdit;
    ztBudgetYearLookup: TZTable;
    procedure cbFrequencyChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    EditMode : string;
  end;

var
  frBudget: TfrBudget;

implementation

{$R *.lfm}

uses uDataModule, uBudgetEditor, uMain;

{ TfrBudget }

procedure TfrBudget.GroupBox1Click(Sender: TObject);
begin

end;

procedure TfrBudget.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if modalresult = mrOk then
  begin
    if (eBudgetName.Text = '') then
      begin
        CanClose := False;
        eBudgetName.setfocus;
        exit;
      end;

    if (cbFrequency.Text = '') then
      begin
        CanClose := False;
        cbFrequency.setfocus;
        exit;
      end;

{    if dmData.ztBudgetYear.Locate('BUDGETYEARNAME', eBudgetName.Text, [loCaseInsensitive]) = True then
    begin
      MessageDlg('A budget with this name already exists.',mtError, [mbOk], 0);
      CanClose := False;
      eBudgetName.SetFocus;
      exit;
    end;}
  end;

end;

procedure TfrBudget.FormShow(Sender: TObject);
var CurrYear, CurrMonth, CurrDay: Word;
  Month : Integer;
begin
  ztBudgetYearLookup.TableName:= tblBudgetYear;

  DecodeDate(now, CurrYear, CurrMonth, CurrDay);
  ztBudgetYearLookup.Open;
  ztBudgetYearLookup.Active:= True;
//  dmData.PopulateComboBox(frBudget.cbBudgets, ztBudgetYearLookup, 'BUDGETYEARNAME');
  dmData.SetupComboBoxFilterArchived(frBudget.cbBudgets, ztBudgetYearLookup, 'BUDGETYEARNAME', '', '');
  dmData.SetupComboBox(frBudget.cbAccounts, dmdata.ztAccountList, 'ACCOUNTNAME', '[All Accounts]', '[All Accounts]');
  if (EditMode = 'Insert') or (EditMode = 'Insert List') then
  begin
    dmData.ztBudgetYear.Insert;
    frBudget.Caption:= 'Inserting a new Budget';
    cbArchived.Checked := True;
    seYear.Value:= CurrYear;
    cbAccounts.ItemIndex:= 0;
  end else
  if EditMode = 'Edit' then
  begin
    dmData.ztBudgetYear.Edit;
    frBudget.Caption:= 'Editing Budget';
    cbArchived.Checked := (dmData.ztBudgetYear.FieldByName('ARCHIVED').AsString <> '1');
    eBudgetName.text := dmData.ztBudgetYear.FieldByName('BUDGETYEARNAME').AsString;
    cbFrequency.Text := dmData.ztBudgetYear.FieldByName('BUDGETFREQUENCY').AsString;
    cbAccounts.Text := dmData.ztBudgetYear.FieldByName('BUDGETACCOUNT').AsString;
    seYear.value := StrToInt(dmData.ztBudgetYear.FieldByName('BUDGETYEAR').AsString);

    if dmData.ztBudgetYear.FieldByName('BUDGETMONTH').AsString <> '' then
    begin
      Month := StrToInt(dmData.ztBudgetYear.FieldByName('BUDGETMONTH').AsString);
      Month := Month - 1;
      cbMonth.itemindex := Month;
    end;
    //disable all the controls except for the name and checkbox
  end;
  cbMonth.Enabled := (cbFrequency.Text = 'Monthly');
  cbBudgets.Visible:= (EditMode <> 'Edit');
  lbBaseBudgets.Visible:= cbBudgets.Visible;
end;

procedure TfrBudget.cbFrequencyChange(Sender: TObject);
begin
  cbMonth.Enabled := (cbFrequency.Text = 'Monthly');
end;

procedure TfrBudget.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var MonthStr : string;
    Month, NewRecordID : Integer;
begin
  if modalresult = mrOk then
  begin
    dmData.ztBudgetYear.FieldByName('BUDGETYEARNAME').AsString := frBudget.eBudgetName.text;
    dmData.ztBudgetYear.FieldByName('BUDGETFREQUENCY').AsString :=  frBudget.cbFrequency.Text;
    dmData.ztBudgetYear.FieldByName('BUDGETYEAR').AsString :=  IntToStr(frBudget.seYear.value);
    dmData.ztBudgetYear.FieldByName('BUDGETACCOUNT').AsString :=  frBudget.cbAccounts.Text;
    Month := frBudget.cbMonth.itemindex;
    Month := Month + 1;
    if Month < 10 then
      MonthStr := '0'+ IntToStr(Month)
    else
      MonthStr := IntToStr(Month);
    if frBudget.cbMonth.Enabled then
      dmData.ztBudgetYear.FieldByName('BUDGETMONTH').AsString :=  MonthStr;

    if cbArchived.Checked then
      dmData.ztBudgetYear.FieldByName('ARCHIVED').AsString := '0'
    else
      dmData.ztBudgetYear.FieldByName('ARCHIVED').AsString := '1';

    dmData.SaveChanges(dmData.ztBudgetYear, False);
    NewRecordID := dmData.ztBudgetYear.fieldbyname('BUDGETYEARID').AsInteger;

    if (cbBudgets.Visible = true) and (frBudget.cbBudgets.Text <> '') then
      if dmData.ztBudgetYear.Locate('BUDGETYEARNAME', frBudget.cbBudgets.Text , [loCaseInsensitive]) = True then
        dmData.CopyBudgetYear(dmData.ztBudgetYear.FieldByName('BUDGETYEARID').AsInteger, NewRecordID);

    dmdata.RefreshDataset(dmData.ztBudgetYear);
    dmdata.RefreshDataset(dmData.zqBudgetYear);

    frMain.CreateBudgetSetupItems;
  end;
  ztBudgetYearLookup.Close;
end;

end.

