{ To do list:
  1. Make sure repeats box only accepts numbers
}
unit uRepeatingTransaction;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DbCtrls, EditBtn, Calendar, ComCtrls, ZDataset, math, DateUtils;

type

  { TfrRepeatingTransaction }

  TfrRepeatingTransaction = class(TForm)
    bCancel: TButton;
    bCategory: TButton;
    bOk1: TButton;
    Calendar1: TCalendar;
    cbRepeats: TComboBox;
    cbSplit: TCheckBox;
    cbStatus: TComboBox;
    cbType: TComboBox;
    cbAutoExec: TCheckBox;
    cbAutoExecNoUser: TCheckBox;
    dbeAccountID: TDBEdit;
    dbeCatID: TDBEdit;
    dbePayeeID: TDBEdit;
    dbeSubCatID: TDBEdit;
    dbeToAccountID: TDBEdit;
    dblcbAccount: TDBLookupComboBox;
    dblcbPayeeName: TDBLookupComboBox;
    dblcbTransferToAccount: TDBLookupComboBox;
    dbmNotes: TDBMemo;
    deDate: TDateEdit;
    deNextOccDate: TDateEdit;
    eAmount: TEdit;
    eTimesRepeated: TEdit;
    eNumber: TDBEdit;
    gbTranDetails: TGroupBox;
    gbRepeatDetails: TGroupBox;
    Label1: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lbAccount: TLabel;
    lbPayee: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbDayofWeek: TLabel;
    Panel1: TPanel;
    pBottom: TPanel;
    udDay: TUpDown;
    ztPayeeLookup: TZTable;
    ztPayeeLookupCATEGID: TLargeintField;
    ztPayeeLookupPAYEEID: TLargeintField;
    ztPayeeLookupPAYEENAME: TMemoField;
    ztPayeeLookupSUBCATEGID: TLargeintField;
    procedure bCategoryClick(Sender: TObject);
    procedure bOk1Click(Sender: TObject);
    procedure Calendar1DayChanged(Sender: TObject);
    procedure cbSplitChange(Sender: TObject);
    procedure cbSplitClick(Sender: TObject);
    procedure cbTypeChange(Sender: TObject);
    procedure dblcbPayeeNameChange(Sender: TObject);
    procedure deDateChange(Sender: TObject);
    procedure deNextOccDateChange(Sender: TObject);
    procedure eAmountExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ProcessRepeatPayment(RepTransID : Integer; FormEditMode : String);
    procedure SkipRepeatPayment(RepTransID : Integer);
    procedure ProcessTodaysRepeatTransactions;
    procedure udDayClick(Sender: TObject; Button: TUDBtnType);
    procedure ToggleTransferToAccount(Toggle : Boolean);
  private
    { private declarations }
  public
    { public declarations }
    EditMode, TranStatus, TranNotes, TRANSDATE, NEXTOCCDATE, TRANSACTIONNUMBER: string;
    ACCOUNTID, TOACCOUNTID, PAYEEID, SUBCATEGID, CATEGID, FOLLOWUPID : integer;
    TRANSAMOUNT, TOTRANSAMOUNT : Float;
  end;

var
  frRepeatingTransaction: TfrRepeatingTransaction;

implementation

{$R *.lfm}

uses uDataModule, uMain, uSplitTransaction, uOrganiseCategories, uProgressBar;

{ TfrRepeatingTransaction }

procedure TfrRepeatingTransaction.bCategoryClick(Sender: TObject);
var CatID, SubCatID : integer;
begin
  if cbSplit.Checked then
  begin
    try
      frSplitTransaction := TfrSplitTransaction.create(self);
      frSplitTransaction.Mode:= 'Repeat';
      frSplitTransaction.lbTotalType.Caption:= cbType.Text+' Total:';
      frSplitTransaction.TransID := dmData.ztRepeatTransactions.FieldByName('REPTRANSID').AsInteger;
      frSplitTransaction.Transcode := cbType.Text;
      frSplitTransaction.DisplaySplitTransactionsGrid;
      frSplitTransaction.Showmodal;
      eAmount.Text := FloatToStr(dmData.SplitTransactionsTotal);
      dmData.DisplayCurrencyEdit(eAmount);
    finally
      frSplitTransaction.Free;
    end;
  end else
  begin
    if dbeCatID.Text <> '' then
      CatID := StrToInt(dbeCatID.Text);
    if dbeSubCatID.Text <> '' then
      SubCatID := StrToInt(dbeSubCatID.Text);
    if frOrganiseCategories.SelectCategory(CatID, SubCatID) then
    begin
      dbeCatID.Text:= IntToStr(CatID);
      dbeSubCatID.Text:= IntToStr(SubCatID);
    end;
    bCategory.Caption := dmData.GetCategoryDescription(CatID, SubCatID, 'Category');
  end;
end;

procedure TfrRepeatingTransaction.bOk1Click(Sender: TObject);
begin

end;

procedure TfrRepeatingTransaction.Calendar1DayChanged(Sender: TObject);
begin
  deNextOccDate.Date := Calendar1.DateTime;
end;

procedure TfrRepeatingTransaction.cbSplitChange(Sender: TObject);
var CatID, SubCatID : integer;
begin
  if cbsplit.Checked then
  begin
    CatID := -1;
    SubCatID := -1;
    dbeCatID.Text:= IntToStr(CatID);
    dbeSubCatID.Text:= IntToStr(SubCatID);
    bCategory.Caption := dmData.GetCategoryDescription(CatID, SubCatID, 'Category');
//    if EditMode = 'Insert' then bCategory.Click;
  end;

  eAmount.Enabled := not cbsplit.Checked;
  if eAmount.Enabled then
    eAmount.Color:= clDefault
  else
    eAmount.Color:= clBtnFace;
end;

procedure TfrRepeatingTransaction.cbSplitClick(Sender: TObject);
begin
  if dmData.HasSplitTransactions(dmData.ztRepeatTransactions.fieldbyname('REPTRANSID').AsInteger, dmData.ztRepeatSplitTransactions.TableName) then cbSplit.checked := True;
end;

procedure TfrRepeatingTransaction.cbTypeChange(Sender: TObject);
begin
  ToggleTransferToAccount(cbType.Text = 'Transfer');
end;

procedure TfrRepeatingTransaction.dblcbPayeeNameChange(Sender: TObject);
var CatID, SubCatID : integer;
begin
{  ztPayeeLookup.TableName:= dmData.ztPayee.TableName;
  ztPayeeLookup.Open;}
  if (ztPayeeLookup.Locate('PAYEENAME', dblcbPayeeName.Text, [loCaseInsensitive]) = True) then
  begin
    if cbsplit.Checked then
    begin
      CatID := -1;
      SubCatID := -1;
    end else
    begin
      CatID := ztPayeeLookup.FieldByName('CATEGID').AsInteger;
      SubCatID := ztPayeeLookup.FieldByName('SUBCATEGID').AsInteger;
    end;
    dbeCatID.Text:= IntToStr(CatID);
    dbeSubCatID.Text:= IntToStr(SubCatID);
  end;
//  ztPayeeLookup.Close;
  bCategory.Caption := dmData.GetCategoryDescription(CatID, SubCatID, 'Category');
end;

procedure TfrRepeatingTransaction.deDateChange(Sender: TObject);
begin
  lbDayofWeek.Caption := LongDayNames[DayOfWeek(deDate.Date)];
end;

procedure TfrRepeatingTransaction.deNextOccDateChange(Sender: TObject);
begin
  deDate.Date:= deNextOccDate.Date;
  Calendar1.DateTime := deNextOccDate.Date;
end;

procedure TfrRepeatingTransaction.eAmountExit(Sender: TObject);
begin
   dmData.DisplayCurrencyEdit(eAmount);
end;

procedure TfrRepeatingTransaction.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
var TmpStr : string;
  RepTranID : Integer;
begin
  if modalresult = mrOk then
  begin
    dmData.ztRepeatTransactions.FieldByName('AUTORUN').AsString := dmData.BoolToStr(cbAutoExec.Checked);
    dmData.ztRepeatTransactions.FieldByName('AUTORUNUSER').AsString := dmData.BoolToStr(cbAutoExecNoUser.Checked);
    dmData.ztRepeatTransactions.FieldByName('TRANSCODE').AsString := cbType.Text;
    TmpStr := '';
    TmpStr := copy(cbStatus.Text, 1, 1);
    dmData.ztRepeatTransactions.FieldByName('TRANSAMOUNT').AsCurrency := dmData.CurrencyEditToFloat(eAmount);
    dmData.ztRepeatTransactions.FieldByName('STATUS').AsString := TmpStr;
    if (EditMode = 'Insert') or (EditMode = 'Manual') then
      dmData.ztRepeatTransactions.FieldByName('TRANSDATE').AsString := FormatDateTime('YYYY-MM-DD',deDate.Date);
    dmData.ztRepeatTransactions.FieldByName('NEXTOCCURRENCEDATE').AsString := FormatDateTime('YYYY-MM-DD',deNextOccDate.Date);
    dmData.ztRepeatTransactions.FieldByName('REPEATS').AsInteger := cbRepeats.ItemIndex;
    if eTimesRepeated.Text <> '' then
      dmData.ztRepeatTransactions.FieldByName('NUMOCCURRENCES').AsInteger := StrToInt(eTimesRepeated.Text)
    else
      dmData.ztRepeatTransactions.FieldByName('NUMOCCURRENCES').AsInteger := -1;

    if dblcbTransferToAccount.Visible then
    begin
      dmData.ztRepeatTransactions.FieldByName('PAYEEID').AsInteger := -1;
      dmData.ztRepeatTransactions.FieldByName('TRANSAMOUNT').AsCurrency := dmData.CurrencyEditToFloat(eAmount);
    end
    else
      dmData.ztRepeatTransactions.FieldByName('TOACCOUNTID').AsInteger := -1;

    dmData.ztRepeatTransactions.FieldByName('FOLLOWUPID').AsInteger := -1;  //Not used yet
    dmData.SaveChanges(dmData.ztRepeatTransactions, true);
    RepTranID := dmData.ztRepeatTransactions.FieldByName('REPTRANSID').AsInteger;
    dmData.LinkSplitTransactions(dmData.ztRepeatTransactions.FieldByName('REPTRANSID').AsInteger, dmData.ztRepeatSplitTransactions.TableName);

    if EditMode = 'Manual' then
      frRepeatingTransaction.ProcessRepeatPayment(RepTranID, 'Manual');

    dmdata.RefreshDataset(dmData.zqRepeatTransactions);
  end else
  begin
    dmData.ztRepeatTransactions.Cancel;
    dmData.RemoveTempSplitTransactions(dmData.ztRepeatSplitTransactions.TableName);
  end;
  ztPayeeLookup.close;
end;

procedure TfrRepeatingTransaction.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  if modalresult = mrOk then
  begin
{    if cbAccountName.Text = '' then
    begin
      canclose := False;
      cbAccountName.SetFocus;
      exit;
    end;}
    if deNextOccDate.Text = '    /  /  ' then
    begin
      canclose := False;
      deNextOccDate.SetFocus;
      exit;
    end;
    if cbStatus.Text = '' then
    begin
      canclose := False;
      cbStatus.SetFocus;
      exit;
    end;
    if cbType.Text = '' then
    begin
      canclose := False;
      cbType.SetFocus;
      exit;
    end;
    if deDate.Text = '    /  /  ' then
    begin
      canclose := False;
      deDate.SetFocus;
      exit;
    end;
    if eAmount.Text = '' then
    begin
      canclose := False;
      eAmount.SetFocus;
      exit;
    end;
    if dbeAccountID.Text = '' then
    begin
      canclose := False;
      dblcbAccount.SetFocus;
      exit;
    end;
    if (dblcbPayeeName.Visible = True) and (dbePayeeID.Text = '') then
    begin
      canclose := False;
      dblcbPayeeName.SetFocus;
      exit;
    end;
    if (dblcbTransferToAccount.Visible = True) and (dbeToAccountID.Text = '') then
    begin
      canclose := False;
      dblcbTransferToAccount.SetFocus;
      exit;
    end;

  end;
end;

procedure TfrRepeatingTransaction.FormCreate(Sender: TObject);
begin
  ztPayeeLookup.TableName:= tblPayee;
  ztPayeeLookup.Open;
end;

procedure TfrRepeatingTransaction.FormShow(Sender: TObject);
var CatID, SubCatID : integer;
  TmpDateStr : string;
begin
  if (EditMode = 'Edit') or (EditMode = 'Manual') then
  begin
    if (EditMode = 'Edit') then
      frRepeatingTransaction.Caption:= 'Editing Repeating Transaction';
    if (EditMode = 'Manual') then
      frRepeatingTransaction.Caption:= 'Manually Processing a Repeating Transaction';

    if dbeCatID.Text <> '' then
      CatID := StrToInt(dbeCatID.Text);
    if dbeSubCatID.Text <> '' then
      SubCatID := StrToInt(dbeSubCatID.Text);
    bCategory.Caption := dmData.GetCategoryDescription(CatID, SubCatID, 'Category');
    eAmount.Text:= floatToStr(dmData.ztRepeatTransactions.FieldByName('TRANSAMOUNT').AsCurrency);
    dmData.DisplayCurrencyEdit(eAmount);
    cbRepeats.ItemIndex := dmData.ztRepeatTransactions.FieldByName('REPEATS').AsInteger;
    if dmData.ztRepeatTransactions.FieldByName('NUMOCCURRENCES').AsInteger > 0 then
      eTimesRepeated.Text:= IntToStr(dmData.ztRepeatTransactions.FieldByName('NUMOCCURRENCES').AsInteger);
    //Dont update transdate value
    TmpDateStr := dmData.ztRepeatTransactions.FieldByName('TRANSDATE').AsString;
    TmpDateStr := StringReplace(TmpDateStr, '-', '/', [rfReplaceAll, rfIgnoreCase]);
    deDate.Text := TmpDateStr;
    TmpDateStr := dmData.ztRepeatTransactions.FieldByName('NEXTOCCURRENCEDATE').AsString;
    TmpDateStr := StringReplace(TmpDateStr, '-', '/', [rfReplaceAll, rfIgnoreCase]);
    deNextOccDate.Text := TmpDateStr;
    cbType.Text :=  dmData.ztRepeatTransactions.fieldbyname('TRANSCODE').AsString;
    cbStatus.Text := dmData.GetTransactionStatusText(dmData.ztRepeatTransactions.fieldbyname('STATUS').AsString);
    cbAutoExec.Checked := dmData.StrToBool(dmData.ztRepeatTransactions.FieldByName('AUTORUN').AsString);
    cbAutoExecNoUser.Checked := dmData.StrToBool(dmData.ztRepeatTransactions.FieldByName('AUTORUNUSER').AsString);
    dmdata.ztRepeatTransactions.Edit;

    if EditMode = 'Manual' then
    begin
      //disable repeat variable controls
      deNextOccDate.Enabled:= False;
      cbRepeats.Enabled:= False;
      cbAutoExec.Enabled:= False;
      cbAutoExecNoUser.Enabled:= False;
      Calendar1.Enabled:= False;
      cbType.Enabled:= False;
      deDate.Enabled:= True;
      deDate.SetFocus;
      udDay.Enabled:= deDate.Enabled;
      lbDayofWeek.Enabled:= deDate.Enabled;

      //Remember original repeat values
      ACCOUNTID := dmData.ztRepeatTransactions.fieldbyname('ACCOUNTID').AsInteger;
      TOACCOUNTID := dmData.ztRepeatTransactions.fieldbyname('TOACCOUNTID').AsInteger;
      PAYEEID := dmData.ztRepeatTransactions.fieldbyname('PAYEEID').AsInteger;
      TRANSAMOUNT := dmData.ztRepeatTransactions.FieldByName('TRANSAMOUNT').AsCurrency;
      TranStatus := dmData.ztRepeatTransactions.fieldbyname('STATUS').AsString;
      SUBCATEGID := dmData.ztRepeatTransactions.fieldbyname('SUBCATEGID').AsInteger;
      CATEGID := dmData.ztRepeatTransactions.fieldbyname('CATEGID').AsInteger;
      TRANSACTIONNUMBER := dmData.ztRepeatTransactions.fieldbyname('TRANSACTIONNUMBER').AsString;
      TranNOTES := dmData.ztRepeatTransactions.fieldbyname('NOTES').AsString;
      TRANSDATE := dmData.ztRepeatTransactions.fieldbyname('TRANSDATE').AsString;
      NEXTOCCDATE := dmData.ztRepeatTransactions.fieldbyname('NEXTOCCURRENCEDATE').AsString;
      TOTRANSAMOUNT := dmData.ztRepeatTransactions.fieldbyname('TOTRANSAMOUNT').AsCurrency;
      FOLLOWUPID := dmData.ztRepeatTransactions.fieldbyname('FOLLOWUPID').AsInteger;
    end;

  end else
  if EditMode = 'Insert' then
  begin
    dmData.ztRepeatTransactions.Insert;
    deNextOccDate.Text := FormatDateTime(dmData.DisplayDateFormat, now);

    if PAccountRec(frMain.tvNavigation.Selected.Data) <> nil then
    begin
      if dmData.ztAccountList.Locate('ACCOUNTID', PAccountRec(frMain.tvNavigation.Selected.Data)^.AccountID, [loCaseInsensitive]) then
      begin
        dmData.ztRepeatTransactions.FieldByName('ACCOUNTID').AsInteger := dmData.ztAccountList.FieldByName('ACCOUNTID').AsInteger;
      end;
    end;

  end;
  ToggleTransferToAccount(cbType.Text = 'Transfer');
  cbSplit.checked := dmData.HasSplitTransactions(dmData.ztRepeatTransactions.fieldbyname('REPTRANSID').AsInteger, dmData.ztRepeatSplitTransactions.TableName);
end;

procedure TfrRepeatingTransaction.SkipRepeatPayment(RepTransID : Integer);
var NewDate : string;
begin
  if dmData.ztRepeatTransactions.Locate('REPTRANSID', REPTRANSID, [loCaseInsensitive]) = True then
  begin
    NewDate := dmData.SetupDateSQL(dmData.ztRepeatTransactions.fieldbyname('NEXTOCCURRENCEDATE').AsString, dmData.ztRepeatTransactions.fieldbyname('REPEATS').AsInteger, dmData.ztRepeatTransactions.fieldbyname('NUMOCCURRENCES').AsInteger);
    dmData.ZQuery1.SQL.Clear;
    dmData.ZQuery1.SQL.Add('update '+dmData.ztRepeatTransactions.TableName+' set NEXTOCCURRENCEDATE = '+QuotedStr(NewDate)+' where REPTRANSID = '+IntToStr(RepTransID)+';');
    dmData.ZQuery1.ExecSQL;

    dmdata.RefreshDataset(dmData.ztRepeatTransactions);
    dmdata.RefreshDataset(dmData.zqRepeatTransactions);
  end;
end;

procedure TfrRepeatingTransaction.ProcessRepeatPayment(RepTransID : Integer; FormEditMode : String);
var NewDate, NumOccSQL : string;
  NewTransID, i, NumOcc : integer;
  NoRepeat : Boolean;
begin
  if dmData.ztRepeatTransactions.Locate('REPTRANSID', REPTRANSID, [loCaseInsensitive]) = True then
  begin
    NumOcc := dmData.ztRepeatTransactions.FieldByName('NUMOCCURRENCES').AsInteger;
    NoRepeat := (dmData.ztRepeatTransactions.FieldByName('REPEATS').AsInteger = 0) or
      ((dmData.ztRepeatTransactions.FieldByName('REPEATS').AsInteger <> 0) and (NumOcc = 1));

    if (dmData.ztRepeatTransactions.FieldByName('REPEATS').AsInteger > 0) and (NumOcc <> -1) then
    begin
      NumOcc := NumOcc - 1;
      NumOccSQL := ', NUMOCCURRENCES = '+IntToStr(NumOcc)+ ' ';
    end else
      NumOccSQL := '';

    //copy details from rep table to trans table
    dmData.ztCheckingAccount.Insert;
    dmData.ztCheckingAccount.fieldbyname('ACCOUNTID').AsInteger := dmData.ztRepeatTransactions.fieldbyname('ACCOUNTID').AsInteger;
    dmData.ztCheckingAccount.fieldbyname('TOACCOUNTID').AsInteger := dmData.ztRepeatTransactions.fieldbyname('TOACCOUNTID').AsInteger;
    dmData.ztCheckingAccount.fieldbyname('PAYEEID').AsInteger := dmData.ztRepeatTransactions.fieldbyname('PAYEEID').AsInteger;
    dmData.ztCheckingAccount.fieldbyname('TRANSCODE').AsString := dmData.ztRepeatTransactions.fieldbyname('TRANSCODE').AsString;
    dmData.ztCheckingAccount.FieldByName('TRANSAMOUNT').AsCurrency := dmData.ztRepeatTransactions.FieldByName('TRANSAMOUNT').AsCurrency;
    dmData.ztCheckingAccount.fieldbyname('STATUS').AsString := dmData.ztRepeatTransactions.fieldbyname('STATUS').AsString;
    dmData.ztCheckingAccount.fieldbyname('SUBCATEGID').AsInteger := dmData.ztRepeatTransactions.fieldbyname('SUBCATEGID').AsInteger;
    dmData.ztCheckingAccount.fieldbyname('CATEGID').AsInteger := dmData.ztRepeatTransactions.fieldbyname('CATEGID').AsInteger;
    dmData.ztCheckingAccount.fieldbyname('TRANSACTIONNUMBER').AsString := dmData.ztRepeatTransactions.fieldbyname('TRANSACTIONNUMBER').AsString;
    dmData.ztCheckingAccount.fieldbyname('NOTES').AsString := dmData.ztRepeatTransactions.fieldbyname('NOTES').AsString;
    dmData.ztCheckingAccount.FieldByName('FOLLOWUPID').AsInteger := dmData.ztRepeatTransactions.FieldByName('FOLLOWUPID').AsInteger;

    if FormEditMode = 'Manual' then
      dmData.ztCheckingAccount.fieldbyname('TRANSDATE').AsString := dmData.ztRepeatTransactions.fieldbyname('TRANSDATE').AsString
    else
      dmData.ztCheckingAccount.fieldbyname('TRANSDATE').AsString := dmData.ztRepeatTransactions.fieldbyname('NEXTOCCURRENCEDATE').AsString;

    dmData.ztCheckingAccount.fieldbyname('TOTRANSAMOUNT').AsCurrency := dmData.ztRepeatTransactions.fieldbyname('TOTRANSAMOUNT').AsCurrency;
    dmData.SaveChanges(dmData.ztCheckingAccount, false);
    NewTransID := dmData.ztCheckingAccount.fieldbyname('TRANSID').AsInteger;

    //copy details from rep split table to split table
    dmData.ZQuery1.Active:= False;
    dmData.ZQuery1.SQL.Clear;
    dmData.ZQuery1.SQL.Add(
      ' select * '+
      ' from '+dmData.ztRepeatSplitTransactions.TableName+' s '+
      ' where transid = :transid '
      );
    dmData.ZQuery1.ParamByName('transid').Value := RepTransID;
    dmData.ZQuery1.ExecSQL;
    dmData.ZQuery1.Active:= True;
    dmData.ZQuery1.First;
    for i:= 1 to dmData.ZQuery1.RecordCount do
    begin
      dmData.ztSplitTransactions.Insert;
      dmData.ztSplitTransactions.fieldbyname('TRANSID').AsInteger := NewTransID;
      dmData.ztSplitTransactions.fieldbyname('CATEGID').AsInteger := dmData.ZQuery1.fieldbyname('CATEGID').AsInteger;
      dmData.ztSplitTransactions.fieldbyname('SUBCATEGID').AsInteger := dmData.ZQuery1.fieldbyname('SUBCATEGID').AsInteger;
      dmData.ztSplitTransactions.fieldbyname('SPLITTRANSAMOUNT').AsCurrency := dmData.ZQuery1.fieldbyname('SPLITTRANSAMOUNT').AsCurrency;
      dmData.SaveChanges(dmData.ztSplitTransactions, false);
      dmData.ZQuery1.Next;
    end;

    dmdata.RefreshDataset(dmData.ztSplitTransactions);
    dmData.ZQuery1.Active:= False;

    if NoRepeat then
    begin
      //if no more repeats then delete entry and relating split transactions.
      dmData.DeleteDBRecord(dmData.ztRepeatTransactions.TableName, 'REPTRANSID', RepTransID);
      dmData.DeleteDBRecord(dmData.ztRepeatSplitTransactions.TableName, 'TRANSID', RepTransID);
    end else
    begin
      if (FormEditMode = 'Manual') then //reset original repeat variables
      begin
        if dmData.ztRepeatTransactions.Locate('REPTRANSID', RepTransID, [loCaseInsensitive]) then
        begin
          dmData.ztRepeatTransactions.Edit;
          dmData.ztRepeatTransactions.fieldbyname('ACCOUNTID').AsInteger := ACCOUNTID;
          dmData.ztRepeatTransactions.fieldbyname('TOACCOUNTID').AsInteger := TOACCOUNTID;
          dmData.ztRepeatTransactions.fieldbyname('PAYEEID').AsInteger := PAYEEID;
          dmData.ztRepeatTransactions.FieldByName('TRANSAMOUNT').AsCurrency := TRANSAMOUNT;
          dmData.ztRepeatTransactions.fieldbyname('STATUS').AsString := TranStatus;
          dmData.ztRepeatTransactions.fieldbyname('SUBCATEGID').AsInteger := SUBCATEGID;
          dmData.ztRepeatTransactions.fieldbyname('CATEGID').AsInteger := CATEGID;
          dmData.ztRepeatTransactions.fieldbyname('TRANSACTIONNUMBER').AsString := TRANSACTIONNUMBER;
          dmData.ztRepeatTransactions.fieldbyname('NOTES').AsString := TranNOTES;
          dmData.ztRepeatTransactions.fieldbyname('TRANSDATE').AsString := TRANSDATE;
          dmData.ztRepeatTransactions.fieldbyname('NEXTOCCURRENCEDATE').AsString := NEXTOCCDATE;
          dmData.ztRepeatTransactions.fieldbyname('TOTRANSAMOUNT').AsCurrency := TOTRANSAMOUNT;
          dmData.ztRepeatTransactions.fieldbyname('FOLLOWUPID').AsInteger := FOLLOWUPID;
          dmData.SaveChanges(dmData.ztRepeatTransactions, true);
        end;
      end;

      //update rep table with new date
      NewDate := dmData.SetupDateSQL(dmData.ztRepeatTransactions.fieldbyname('NEXTOCCURRENCEDATE').AsString, dmData.ztRepeatTransactions.fieldbyname('REPEATS').AsInteger, dmData.ztRepeatTransactions.fieldbyname('NUMOCCURRENCES').AsInteger);
      dmData.ZQuery1.SQL.Clear;
      dmData.ZQuery1.SQL.Add('update '+dmData.ztRepeatTransactions.TableName+' set NEXTOCCURRENCEDATE = '+QuotedStr(NewDate)+
        NumOccSQL+' where REPTRANSID = '+IntToStr(RepTransID)+';');
      dmData.ZQuery1.ExecSQL;
    end;
    dmdata.RefreshDataset(dmData.ztRepeatTransactions);
    dmdata.RefreshDataset(dmData.zqRepeatTransactions);
  end;
end;

procedure TfrRepeatingTransaction.ProcessTodaysRepeatTransactions;
var DateFilterText, TmpDateStr : string;
  i : integer;
  Manual : boolean;
begin
  TmpDateStr := FormatDateTime('YYYY-MM-DD', (now));
  DateFilterText := ' and strftime(''%Y-%m-%d'',NEXTOCCURRENCEDATE) <= '+QuotedStr(TmpDateStr);

  dmData.zqTodaysRepTrans.Active:= False;
  dmData.zqTodaysRepTrans.SQL.Clear;
  dmData.zqTodaysRepTrans.SQL.Add(
    ' select * '+
    ' from '+dmData.ztRepeatTransactions.TableName+' rt '+
    ' where AUTORUN = ''1'' '+
    DateFilterText
    );
  dmData.zqTodaysRepTrans.ExecSQL;
  dmData.zqTodaysRepTrans.Active:= True;
//  if dmData.zqTodaysRepTrans.RecordCount > 0 then frProgressBar.SetupProgressBar(1, dmData.zqTodaysRepTrans.RecordCount);
  for i:= 1 to dmData.zqTodaysRepTrans.RecordCount do
  begin
//    frProgressBar.StepProgressBar;
    if dmData.zqTodaysRepTrans.FieldByName('AUTORUNUSER').AsString = '1' then
    begin
      if dmData.ztRepeatTransactions.Locate('REPTRANSID', dmData.zqTodaysRepTrans.FieldByName('REPTRANSID').AsInteger, [loCaseInsensitive]) = True then
      begin
        try
          frRepeatingTransaction := TfrRepeatingTransaction.create(self);
          frRepeatingTransaction.EditMode:= 'Manual';
          frRepeatingTransaction.Showmodal;
        finally
          frRepeatingTransaction.Free;
        end;
      end;
    end else
      ProcessRepeatPayment(dmData.zqTodaysRepTrans.FieldByName('REPTRANSID').AsInteger, '');

    dmData.zqTodaysRepTrans.Next;
  end;
end;

procedure TfrRepeatingTransaction.udDayClick(Sender: TObject; Button: TUDBtnType);
begin
  if Button = btNext then deDate.Date := IncDay(deDate.Date, 1) else
  if Button = btPrev then deDate.Date := IncDay(deDate.Date, -1);
end;

procedure TfrRepeatingTransaction.ToggleTransferToAccount(Toggle : Boolean);
begin
  dblcbTransferToAccount.Visible:= Toggle;
  dblcbPayeeName.Visible:= not Toggle;
  dblcbTransferToAccount.Left:= dblcbPayeeName.Left;
  dblcbTransferToAccount.Top := dblcbPayeeName.Top;

  if Toggle then
  begin
    lbAccount.Caption:= 'From';
    lbPayee.Caption:= 'To';
  end else
  begin
    lbAccount.Caption:= 'Account';
    lbPayee.Caption:= 'Payee';
  end;
end;

end.

