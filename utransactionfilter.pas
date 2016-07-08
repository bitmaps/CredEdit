{ To do list:

  1. Add ability for complex queries: not, equal to, greater than, greater than/equal to, less than, less than/equal to, in, is null, like.
  2. Add support for fields: number, status, notes

}

unit uTransactionFilter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, EditBtn, db, dateutils;

type

  { TfrTransactionFilter }

  TfrTransactionFilter = class(TForm)
    bCancel: TButton;
    bCategory: TButton;
    bOk: TButton;
    cbPayee: TComboBox;
    cbShowFilters: TCheckBox;
    cbPresetDates: TComboBox;
    eFilterName: TEdit;
    cbTransType: TComboBox;
    deFromDate: TDateEdit;
    deToDate: TDateEdit;
    eAmountFrom: TEdit;
    eAmountTo: TEdit;
    gbDates: TGroupBox;
    gbPayee: TGroupBox;
    gbCategory: TGroupBox;
    gbFilterName: TGroupBox;
    gbTransType: TGroupBox;
    gbAmount: TGroupBox;
    pBottom: TPanel;
    procedure bCategoryClick(Sender: TObject);
    procedure cbPresetDatesChange(Sender: TObject);
    procedure eAmountFromExit(Sender: TObject);
    procedure eAmountToExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure ResetFilters;
    procedure RunTransFilter(TransFiltername : string);
    procedure ToggleBetweenDates(Toggle : Boolean);
  private
    { private declarations }
  public
    { public declarations }
//    DateFilter , PayeeFilter, CategoryFilter, AmountFilter, TransTypeFilter : string;
    CatID, SubCatID : Integer;
    EditMode : String;
  end;

var
  frTransactionFilter: TfrTransactionFilter;

implementation

{$R *.lfm}

uses uDatamodule, uOrganiseCategories, uMain;

{ TfrTransactionFilter }

procedure TfrTransactionFilter.RunTransFilter(TransFiltername : string);
var vDateFilter : integer;
  FromDate, ToDate : string;
begin
  if TransFilterName = '[None]' then
  begin
    ResetFilters;
    frMain.DisplayBankAccountsGrid;
    exit;
  end else
  if dmData.ztTransFilter.Locate('TRANSFILTERNAME', TransFiltername, [loCaseInsensitive]) = True then
  begin
    ResetFilters;
    vDateFilter := dmData.ztTransFilter.FieldByName('DATEFILTER').AsInteger;

    case vDateFilter of
     1 :  begin // User Specified
            FromDate := dmData.ztTransFilter.FieldByName('FROMDATE').AsString;
            ToDate := dmData.ztTransFilter.FieldByName('TODATE').AsString;
          end;
     2 : dmdata.SetupBetweenDatesSQL(FromDate, ToDate, dqCurrentWeek);
     3 : dmdata.SetupBetweenDatesSQL(FromDate, ToDate, dqCurrentMonth);
     4 : dmdata.SetupBetweenDatesSQL(FromDate, ToDate, dqCurrentQuarter);
     5 : dmdata.SetupBetweenDatesSQL(FromDate, ToDate, dqCurrentYear);
     6 : begin
           FromDate := FormatDateTime('YYYY-MM-DD',now);
           ToDate := '';
         end;
    end;

    if vDateFilter > 0 then
    begin
{      if dmData.ztTransFilter.FieldByName('FROMDATE').AsString <> '' then
        frMain.TransRepDateFilter := ' and ch.transdate >= '+chr(39)+ dmData.ztTransFilter.FieldByName('FROMDATE').AsString+chr(39);
      if dmData.ztTransFilter.FieldByName('TODATE').AsString <> '' then
        frMain.TransRepDateFilter := frMain.TransRepDateFilter+' and ch.transdate <= '+chr(39)+ dmData.ztTransFilter.FieldByName('TODATE').AsString+chr(39);}
      if FromDate <> '' then
        frMain.TransRepDateFilter := ' and ch.transdate >= '+chr(39)+ FromDate +chr(39);
      if ToDate <> '' then
        frMain.TransRepDateFilter := frMain.TransRepDateFilter+' and ch.transdate <= '+chr(39)+ ToDate +chr(39);
    end;

    if dmData.ztTransFilter.FieldByName('TRANSCODE').AsString <> '[All Transactions]' then
      frMain.TransTypeFilter := ' and ch.transcode = '+QuotedStr(dmData.ztTransFilter.FieldByName('TRANSCODE').AsString)
    else
      frMain.TransTypeFilter := '';

    if dmData.ztTransFilter.FieldByName('FROMAMOUNT').AsString <> '' then
      frMain.TransAmountFilter := ' and ch.transamount >= '+FloatToStr(dmData.ztTransFilter.FieldByName('FROMAMOUNT').AsCurrency);

    if dmData.ztTransFilter.FieldByName('TOAMOUNT').AsString <> '' then
      frMain.TransAmountFilter := frMain.TransAmountFilter+' and ch.transamount <= '+FloatToStr(dmData.ztTransFilter.FieldByName('TOAMOUNT').AsCurrency);

    if dmData.ztPayee.Locate('PAYEENAME', dmData.ztTransFilter.FieldByName('PAYEENAME').AsString , [loCaseInsensitive]) = True then
      frMain.TransRepPayeeFilter := ' and ch.payeeid = '+IntToStr(dmData.ztPayee.fieldbyname('PAYEEID').AsInteger)
    else
      frMain.TransRepPayeeFilter := '';

    if dmData.ztTransFilter.FieldByName('CATEGID').AsInteger <> -1 then
      frMain.TransRepCatFilter := ' and ch.categid = '+IntToStr(dmData.ztTransFilter.FieldByName('CATEGID').AsInteger);

    if dmData.ztTransFilter.FieldByName('SUBCATEGID').AsInteger <> -1 then
      frMain.TransRepCatFilter := frMain.TransRepCatFilter + ' and ch.subcategid = '+IntToStr(dmData.ztTransFilter.FieldByName('SUBCATEGID').AsInteger);

    frMain.DisplayBankAccountsGrid;
    exit;
  end;
end;

procedure TfrTransactionFilter.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  if modalresult = mrOk then
  begin
    if  eFilterName.Text = '' then
    begin
      canclose := False;
      eFilterName.SetFocus;
      exit;
    end;
  end;
end;

procedure TfrTransactionFilter.ResetFilters;
begin
  with frMain do
  begin
    TransRepPayeeFilter := '';
    TransRepDateFilter := '';
    TransRepCatFilter := '';
    TransAmountFilter := '';
    TransTypeFilter := '';
  end;
end;

procedure TfrTransactionFilter.FormShow(Sender: TObject);
var TmpDate : String;
begin
  dmData.SetupComboBox(frTransactionFilter.cbPayee, dmdata.ztPayee, 'PAYEENAME', '[All Payees]', '[All Payees]');
  if (EditMode = 'Insert') or (EditMode = 'Insert List') then
  begin
    frTransactionFilter.Caption:= 'New Transaction Filter';
    CatID := -1;
    SubCatID := -1;
    //dmData.SetupComboBoxFilterArchived(frTransactionFilter.cbPayee, dmdata.ztPayee, 'PAYEENAME', '[All Payees]', '[All Payees]');
    cbTransType.ItemIndex:= 0;
    cbPayee.ItemIndex:= 0;
    cbShowFilters.Checked:= True;
    cbPresetDates.ItemIndex := 0;
  end else
  if EditMode = 'Edit' then
  begin
    frTransactionFilter.Caption:= 'Editing Transaction Filter';
    eFilterName.Text := dmData.ztTransFilter.FieldByName('TRANSFILTERNAME').AsString;
    cbShowFilters.Checked := (dmData.ztTransFilter.FieldByName('ARCHIVED').AsString <> '1');

    cbPresetDates.ItemIndex := dmData.ztTransFilter.FieldByName('DATEFILTER').AsInteger;

    if dmData.ztTransFilter.FieldByName('TODATE').AsString <> '' then
    begin
      TmpDate := dmData.ztTransFilter.FieldByName('TODATE').AsString;
      TmpDate := StringReplace(TmpDate, '-', '/', [rfReplaceAll, rfIgnoreCase]);
      deToDate.Text := TmpDate;
    end;

    if dmData.ztTransFilter.FieldByName('FROMDATE').AsString <> '' then
    begin
      TmpDate := dmData.ztTransFilter.FieldByName('FROMDATE').AsString;
      TmpDate := StringReplace(TmpDate, '-', '/', [rfReplaceAll, rfIgnoreCase]);
      deFromDate.Text := TmpDate;
    end;

    cbTransType.Text := dmData.ztTransFilter.FieldByName('TRANSCODE').AsString;
    cbPayee.Text := dmData.ztTransFilter.FieldByName('PAYEENAME').AsString;
    CatID := dmData.ztTransFilter.FieldByName('CATEGID').AsInteger;
    SubCatID := dmData.ztTransFilter.FieldByName('SUBCATEGID').AsInteger;
    bCategory.Caption := dmData.GetCategoryDescription(CatID, SubCatID, 'Category');

    if dmData.ztTransFilter.FieldByName('FROMAMOUNT').AsString <> '' then
      eAmountFrom.Text:= floatToStr(dmData.ztTransFilter.FieldByName('FROMAMOUNT').AsCurrency);
    dmData.DisplayCurrencyEdit(eAmountFrom);
    if dmData.ztTransFilter.FieldByName('TOAMOUNT').AsString <> '' then
      eAmountTo.Text:= floatToStr(dmData.ztTransFilter.FieldByName('TOAMOUNT').AsCurrency);
    dmData.DisplayCurrencyEdit(eAmountTo);
  end;
  ToggleBetweenDates(cbPresetDates.ItemIndex = 1);
end;

procedure TfrTransactionFilter.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
var SelectedFilter : integer;

  procedure SaveFields;
  var PreviousFilter : string;
  begin
    dmData.ztTransFilter.FieldByName('TRANSFILTERNAME').AsString := eFilterName.Text;
    if deFromDate.Text <> '    /  /  ' then
      dmData.ztTransFilter.FieldByName('FROMDATE').AsString := FormatDateTime('YYYY-MM-DD',deFromDate.Date);
    if deToDate.Text <> '    /  /  ' then
      dmData.ztTransFilter.FieldByName('TODATE').AsString := FormatDateTime('YYYY-MM-DD',deToDate.Date);
    dmData.ztTransFilter.FieldByName('TRANSCODE').AsString := cbTransType.Text;
    if eAmountFrom.Text <> '' then
      dmData.ztTransFilter.FieldByName('FROMAMOUNT').AsCurrency := dmData.CurrencyEditToFloat(eAmountFrom);
    if eAmountTo.Text <> '' then
      dmData.ztTransFilter.FieldByName('TOAMOUNT').AsCurrency := dmData.CurrencyEditToFloat(eAmountTo);
    dmData.ztTransFilter.FieldByName('PAYEENAME').AsString := cbPayee.Text;
    dmData.ztTransFilter.FieldByName('CATEGID').AsInteger := CatID;
    dmData.ztTransFilter.FieldByName('SUBCATEGID').AsInteger := SubCatID;
    dmData.ztTransFilter.FieldByName('DATEFILTER').AsInteger := cbPresetDates.ItemIndex;

    if cbShowFilters.Checked then
      dmData.ztTransFilter.FieldByName('ARCHIVED').AsString := '0'
    else
      dmData.ztTransFilter.FieldByName('ARCHIVED').AsString := '1';

    dmData.SaveChanges(dmData.ztTransFilter, true);
    PreviousFilter := frMain.cbFilterList.Text;
    if (EditMode = 'Insert') or (EditMode = 'Insert List') then
      dmData.SetupComboBoxFilterArchived(frMain.cbFilterList, dmdata.ztTransFilter, 'TRANSFILTERNAME', '[None]', eFilterName.Text)
    else
      dmData.SetupComboBoxFilterArchived(frMain.cbFilterList, dmdata.ztTransFilter, 'TRANSFILTERNAME', '[None]', PreviousFilter);

    dmdata.RefreshDataset(dmData.zqTransFilters);
  end;

begin
  if modalresult = mrOk then
  begin
    //save filter details
    if EditMode = 'Edit' then
    begin
      dmData.ztTransFilter.Edit;
      SaveFields;
    end else
    if (EditMode = 'Insert') or (EditMode = 'Insert List')  then
    begin
      dmData.ztTransFilter.Insert;
      SaveFields;
      if (EditMode = 'Insert') then  //dont update main filters if added from list screen
      begin
        ResetFilters;
        if deFromDate.Text <> '    /  /  ' then
          frMain.TransRepDateFilter := ' and ch.transdate >= '+chr(39)+ FormatDateTime('YYYY-MM-DD',deFromDate.Date)+chr(39);

        if deToDate.Text <> '    /  /  ' then
          frMain.TransRepDateFilter := frMain.TransRepDateFilter+' and ch.transdate <= '+chr(39)+ FormatDateTime('YYYY-MM-DD',deToDate.Date)+chr(39);

        if dmData.ztPayee.Locate('PAYEENAME', cbPayee.Text , [loCaseInsensitive]) = True then
          frMain.TransRepPayeeFilter := ' and ch.payeeid = '+IntToStr(dmData.ztPayee.fieldbyname('PAYEEID').AsInteger)
        else
          frMain.TransRepPayeeFilter := '';

        if cbTransType.Text <> '[All Transactions]' then
          frMain.TransTypeFilter := ' and ch.transcode = '+QuotedStr(cbTransType.Text)
        else
          frMain.TransTypeFilter := '';

        if eAmountFrom.Text <> '' then
          frMain.TransAmountFilter := ' and ch.transamount >= '+FloatToStr(dmData.CurrencyEditToFloat(eAmountFrom));

        if eAmountTo.Text <> '' then
          frMain.TransAmountFilter := frMain.TransAmountFilter+' and ch.transamount <= '+FloatToStr(dmData.CurrencyEditToFloat(eAmountTo));

        if CatID <> -1 then
          frMain.TransRepCatFilter := ' and ch.categid = '+IntToStr(CatID);

        if SubCatID <> -1 then
          frMain.TransRepCatFilter := frMain.TransRepCatFilter + ' and ch.subcategid = '+IntToStr(SubCatID);
      end;
  {    if bCategory.Caption <> 'Category Description' then
        frMain.TransRepCatFilter := ' and category = '+QuotedStr(bCategory.Caption)
      else
        frMain.TransRepCatFilter := '';}
    end;

  end;
end;

procedure TfrTransactionFilter.bCategoryClick(Sender: TObject);
begin
  frOrganiseCategories.SelectCategory(CatID, SubCatID);
  bCategory.Caption := dmData.GetCategoryDescription(CatID, SubCatID, 'Category Description');
end;

procedure TfrTransactionFilter.cbPresetDatesChange(Sender: TObject);
begin
  ToggleBetweenDates(cbPresetDates.ItemIndex = 1);
end;

procedure TfrTransactionFilter.ToggleBetweenDates(Toggle : Boolean);
begin
  deFromDate.Enabled:= Toggle;
  deToDate.Enabled:= Toggle;
  if Toggle = False then
  begin
    deToDate.Text:= '';
    deFromDate.Text:= '';
  end;
end;

procedure TfrTransactionFilter.eAmountFromExit(Sender: TObject);
begin
  dmData.DisplayCurrencyEdit(eAmountFrom);
end;

procedure TfrTransactionFilter.eAmountToExit(Sender: TObject);
begin
  dmData.DisplayCurrencyEdit(eAmountTo);
end;

end.

