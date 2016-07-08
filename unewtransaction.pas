{ To do list:

1. Stop user from choosing same account for Transfer to and from accounts
2. Default to transfer category when selecting transfer option from dropdown
3. Add currency option
}

unit uNewTransaction;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, DbCtrls, ExtCtrls, ComCtrls, ZDataset, db, DateUtils;

type

  { TfrNewTransaction }

  TfrNewTransaction = class(TForm)
    bCancel: TButton;
    bCategory: TButton;
    bOk: TButton;
    cbStatus: TComboBox;
    cbType: TComboBox;
    cbSplit: TCheckBox;
    dbeToAccountID: TDBEdit;
    dbeCatID: TDBEdit;
    dbeAccountID: TDBEdit;
    dbePayeeID: TDBEdit;
    dbeSubCatID: TDBEdit;
    dbeTransID: TDBEdit;
    dblcbPayeeName: TDBLookupComboBox;
    dblcbAccount: TDBLookupComboBox;
    dblcbTransferToAccount: TDBLookupComboBox;
    dbmNotes: TDBMemo;
    deDate: TDateEdit;
    eAmount: TEdit;
    eFormattedAmount: TDBEdit;
    eNumber: TDBEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    lbDayofWeek: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lbAccount: TLabel;
    lbPayee: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    pBottom: TPanel;
    udDay: TUpDown;
    ztPayeeLookup: TZTable;
    ztPayeeLookupCATEGID: TLargeintField;
    ztPayeeLookupPAYEEID: TLargeintField;
    ztPayeeLookupPAYEENAME: TMemoField;
    ztPayeeLookupSUBCATEGID: TLargeintField;
    procedure bCategoryClick(Sender: TObject);
    procedure cbSplitChange(Sender: TObject);
    procedure cbSplitClick(Sender: TObject);
    procedure cbTypeChange(Sender: TObject);
    procedure dblcbPayeeNameChange(Sender: TObject);
    procedure deDateChange(Sender: TObject);
    procedure eAmountExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure udDayClick(Sender: TObject; Button: TUDBtnType);
    procedure ToggleTransferToAccount(Toggle : Boolean);
  private
    { private declarations }
  public
    { public declarations }
    EditMode : string;
  end;

var
  frNewTransaction: TfrNewTransaction;

implementation

{$R *.lfm}

uses uDataModule, uOrganiseCategories, uMain, uSplitTransaction;

{ TfrNewTransaction }

procedure TfrNewTransaction.bCategoryClick(Sender: TObject);
var CatID, SubCatID : integer;
begin
  if cbSplit.Checked then
  begin
    try
      frSplitTransaction := TfrSplitTransaction.create(self);
      frSplitTransaction.Mode:= 'Normal';
      frSplitTransaction.lbTotalType.Caption:= cbType.Text+' Total:';
      frSplitTransaction.TransID := dmData.ztCheckingAccount.FieldByName('TRANSID').AsInteger;
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

procedure TfrNewTransaction.cbSplitChange(Sender: TObject);
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

procedure TfrNewTransaction.cbSplitClick(Sender: TObject);
begin
  if dmData.HasSplitTransactions(dmData.ztCheckingAccount.fieldbyname('TRANSID').AsInteger, dmData.ztSplitTransactions.TableName) then cbSplit.checked := True;
end;

procedure TfrNewTransaction.cbTypeChange(Sender: TObject);
begin
  ToggleTransferToAccount(cbType.Text = 'Transfer');
end;

procedure TfrNewTransaction.dblcbPayeeNameChange(Sender: TObject);
var CatID, SubCatID{, PayeeID} : integer;
begin
{  PayeeID := StrToInt(dbePayeeID.Text);
  if (ztPayeeLookup.Locate('PAYEEID', PayeeID, [loCaseInsensitive]) = True) then}
  //ztPayeeLookup.TableName:= dmData.ztPayee.TableName;
  //ztPayeeLookup.Open;
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
  //ztPayeeLookup.Close;
  bCategory.Caption := dmData.GetCategoryDescription(CatID, SubCatID, 'Category');
end;

procedure TfrNewTransaction.deDateChange(Sender: TObject);
begin
  lbDayofWeek.Caption := LongDayNames[DayOfWeek(deDate.Date)];
end;

procedure TfrNewTransaction.eAmountExit(Sender: TObject);
begin
  dmData.DisplayCurrencyEdit(eAmount);
end;

procedure TfrNewTransaction.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  ztPayeeLookup.close;
end;

procedure TfrNewTransaction.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
var TmpStr : string;
//  Amount : real;
// IniFile : TIniFile;
begin
  if modalresult = mrOk then
  begin
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

    dmData.ztCheckingAccount.FieldByName('TRANSCODE').AsString := frNewTransaction.cbType.Text;
    TmpStr := '';
    TmpStr := copy(cbStatus.Text, 1, 1);
    dmData.ztCheckingAccount.FieldByName('TRANSAMOUNT').AsCurrency := dmData.CurrencyEditToFloat(eAmount);
    dmData.ztCheckingAccount.FieldByName('STATUS').AsString := TmpStr;
    dmData.ztCheckingAccount.FieldByName('TRANSDATE').AsString := FormatDateTime('YYYY-MM-DD',deDate.Date);
    if dblcbTransferToAccount.Visible then
    begin
      dmData.ztCheckingAccount.FieldByName('PAYEEID').AsInteger := -1;
      dmData.ztCheckingAccount.FieldByName('TRANSAMOUNT').AsCurrency := dmData.CurrencyEditToFloat(eAmount);
    end
    else
      dmData.ztCheckingAccount.FieldByName('TOACCOUNTID').AsInteger := -1;

    dmData.ztCheckingAccount.FieldByName('FOLLOWUPID').AsInteger := -1;  //Not used yet

    dmData.SetInfoSettingsInt('LAST_USED_ACCOUNT', dmData.ztCheckingAccount.fieldbyname('ACCOUNTID').AsInteger);
    dmData.SetInfoSettings('LAST_USED_NEWDATE',  deDate.Text);
    if dbePayeeID.Visible then
      dmData.SetInfoSettingsInt('LAST_USED_PAYEE', dmData.ztCheckingAccount.fieldbyname('PAYEEID').AsInteger);
    dmData.SetInfoSettingsInt('LAST_USED_SUBCATEGORY', dmData.ztCheckingAccount.fieldbyname('SUBCATEGID').AsInteger);
    dmData.SetInfoSettingsInt('LAST_USED_CATEGORY', dmData.ztCheckingAccount.fieldbyname('CATEGID').AsInteger);
    dmData.SetInfoSettings('LAST_USED_STATUS', cbStatus.Text);
    dmData.SetInfoSettings('LAST_USED_TYPE', cbType.Text);
  end;
end;

procedure TfrNewTransaction.FormCreate(Sender: TObject);
//var CatID, SubCatID : integer;
begin
{  CatID := -1;
  SubCatID := -1;}

{  if dbeCatID.Text <> '' then
    CatID := StrToInt(dbeCatID.Text);
  if dbeSubCatID.Text <> '' then
    SubCatID := StrToInt(dbeSubCatID.Text);}

  dbeCatID.Visible:= dmData.DebugMode;
  dbeSubCatID.Visible:= dmData.DebugMode;
  dbePayeeID.Visible:= dmData.DebugMode;
  dbeTransID.Visible:= dmData.DebugMode;
  dbeAccountID.Visible:= dmData.DebugMode;
  dbeToAccountID.Visible:= dmData.DebugMode;
  eFormattedAmount.Visible:= dmData.DebugMode;
  ztPayeeLookup.TableName:= tblPayee;
  ztPayeeLookup.Open;
//  bCategory.Caption := ShowCategoryDescription(CatID, SubCatID);
end;

procedure TfrNewTransaction.FormShow(Sender: TObject);
var CatID, SubCatID, PayeeID, AccountID, ToAccountID : integer;
// IniFile : TIniFile;
 DefaultAccount, DefaultNewDate, DefPayee, DefCategory, DefType, DefStatus, Number, Notes, TmpDateStr : string;
 tmpDate : TDate;
begin
  if EditMode = 'Duplicate' then
  begin
    //copy all details to variables
    if dbeCatID.Text <> '' then
      CatID := StrToInt(dbeCatID.Text);
    if dbeSubCatID.Text <> '' then
      SubCatID := StrToInt(dbeSubCatID.Text);

    TmpDateStr := dmData.ztCheckingAccount.FieldByName('TRANSDATE').AsString;
    TmpDateStr := StringReplace(TmpDateStr, '-', '/', [rfReplaceAll, rfIgnoreCase]);
    deDate.Text := TmpDateStr;

    PayeeID :=  dmData.ztCheckingAccount.fieldbyname('PAYEEID').AsInteger;
    AccountID :=  dmData.ztCheckingAccount.fieldbyname('ACCOUNTID').AsInteger;
    ToAccountID := dmData.ztCheckingAccount.fieldbyname('TOACCOUNTID').AsInteger;
    cbType.Text :=  dmData.ztCheckingAccount.fieldbyname('TRANSCODE').AsString;
    Number := dmData.ztCheckingAccount.fieldbyname('TRANSACTIONNUMBER').AsString;
    Notes := dmData.ztCheckingAccount.fieldbyname('NOTES').AsString;

    cbStatus.Text := dmData.GetTransactionStatusText(dmData.ztCheckingAccount.fieldbyname('STATUS').AsString);

    eAmount.Text:= floatToStr(dmData.ztCheckingAccount.FieldByName('TRANSAMOUNT').AsCurrency);
    dmData.DisplayCurrencyEdit(eAmount);

    dmData.ztCheckingAccount.Insert;
    //copy all variables to fields

    dmData.ztCheckingAccount.fieldbyname('SUBCATEGID').AsInteger :=  SubCatID;
    dmData.ztCheckingAccount.fieldbyname('CATEGID').AsInteger :=  CatID;
    dmData.ztCheckingAccount.fieldbyname('PAYEEID').AsInteger := PayeeID;
    dmData.ztCheckingAccount.fieldbyname('ACCOUNTID').AsInteger := AccountID;
    dmData.ztCheckingAccount.fieldbyname('TOACCOUNTID').AsInteger := ToAccountID;
    dmData.ztCheckingAccount.fieldbyname('TRANSACTIONNUMBER').AsString := Number;
    dmData.ztCheckingAccount.fieldbyname('NOTES').AsString := Notes;

    bCategory.Caption := dmData.GetCategoryDescription(CatID, SubCatID, 'Category');
  end else
  if EditMode = 'Edit' then
  begin
     frNewTransaction.Caption:= 'Editing Transaction';
    if dbeCatID.Text <> '' then
      CatID := StrToInt(dbeCatID.Text);
    if dbeSubCatID.Text <> '' then
      SubCatID := StrToInt(dbeSubCatID.Text);

    bCategory.Caption := dmData.GetCategoryDescription(CatID, SubCatID, 'Category');

    eAmount.Text:= floatToStr(dmData.ztCheckingAccount.FieldByName('TRANSAMOUNT').AsCurrency);
    dmData.DisplayCurrencyEdit(eAmount);
  end else
  if EditMode = 'Insert' then
  begin
    if PAccountRec(frMain.tvNavigation.Selected.Data) = nil then
    begin
      DefaultAccount := dmData.GetInfoSettings('DEFAULT_ACCOUNT', 'None');
      if DefaultAccount <> 'None' then
      dmData.ztCheckingAccount.fieldbyname('ACCOUNTID').AsInteger :=
        dmData.GetInfoSettingsInt('LAST_USED_ACCOUNT', -1);
    end;

    DefaultNewDate := dmData.GetInfoSettings('DEFAULT_NEWDATE', 'Todays Date');
    if DefaultNewDate = 'None' then
      deDate.Text := '' else
    if DefaultNewDate = 'Todays Date' then deDate.Date := now else
    if DefaultNewDate = 'Last Used' then
      deDate.text := dmData.GetInfoSettings('LAST_USED_NEWDATE',  '');

    DefPayee := dmData.GetInfoSettings('DEFAULT_PAYEE', 'None');
    if DefPayee <> 'None' then
      dmData.ztCheckingAccount.fieldbyname('PAYEEID').AsInteger :=  dmData.GetInfoSettingsInt('LAST_USED_PAYEE', -1);

    DefType := dmData.GetInfoSettings('DEFAULT_TYPE', 'Last Used');
    if DefType = 'Last Used' then
      cbType.Text := dmData.GetInfoSettings('LAST_USED_TYPE', '')
    else
      cbType.Text := dmData.GetInfoSettings('DEFAULT_TYPE', '');

    DefStatus := dmData.GetInfoSettings('DEFAULT_STATUS', 'Last Used');
    if DefStatus = 'Last Used' then
      cbStatus.Text := dmData.GetInfoSettings('LAST_USED_STATUS', '')
    else
      cbStatus.Text := dmData.GetInfoSettings('DEFAULT_STATUS', '');

    DefCategory:= dmData.GetInfoSettings('DEFAULT_CATEGORY', 'None');
    if DefCategory <> 'None' then
    begin
      CatID := dmData.GetInfoSettingsInt('LAST_USED_CATEGORY', -1);
      SubCatID := dmData.GetInfoSettingsInt('LAST_USED_SUBCATEGORY', -1);

      dmData.ztCheckingAccount.fieldbyname('SUBCATEGID').AsInteger :=  SubCatID;
      dmData.ztCheckingAccount.fieldbyname('CATEGID').AsInteger :=  CatID;

      bCategory.Caption := dmData.GetCategoryDescription(CatID, SubCatID, 'Category');
    end;
  end;
  ToggleTransferToAccount(cbType.Text = 'Transfer');
  cbSplit.checked := dmData.HasSplitTransactions(dmData.ztCheckingAccount.fieldbyname('TRANSID').AsInteger, dmData.ztSplitTransactions.TableName);
  deDate.SetFocus;
end;

procedure TfrNewTransaction.udDayClick(Sender: TObject; Button: TUDBtnType);
begin
  if Button = btNext then deDate.Date := IncDay(deDate.Date, 1) else
  if Button = btPrev then deDate.Date := IncDay(deDate.Date, -1);
end;

procedure TfrNewTransaction.ToggleTransferToAccount(Toggle : Boolean);
begin
  dblcbTransferToAccount.Visible:= Toggle;
  dblcbPayeeName.Visible:= not Toggle;
  dblcbTransferToAccount.Left:= dblcbPayeeName.Left;
  dblcbTransferToAccount.Top := dblcbPayeeName.Top;
  dblcbTransferToAccount.Width:= dblcbPayeeName.Width;

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

