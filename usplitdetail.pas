unit uSplitDetail;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DbCtrls;

type

  { TfrSplitDetail }

  TfrSplitDetail = class(TForm)
    bCancel: TButton;
    bCategory: TButton;
    bOk: TButton;
    cbType: TComboBox;
    dbeCatID: TDBEdit;
    dbeSubCatID: TDBEdit;
    dbeTransID: TDBEdit;
    eAmount: TEdit;
    eFormattedAmount: TDBEdit;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    pBottom: TPanel;
    procedure bCategoryClick(Sender: TObject);
    procedure eAmountExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    EditMode, Mode, Transcode : string;
  end;

var
  frSplitDetail: TfrSplitDetail;

implementation

{$R *.lfm}

uses uDataModule, uOrganiseCategories, uSplitTransaction;

{ TfrSplitDetail }

procedure TfrSplitDetail.bCategoryClick(Sender: TObject);
var CatID, SubCatID : integer;
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

procedure TfrSplitDetail.eAmountExit(Sender: TObject);
begin
  dmData.DisplayCurrencyEdit(eAmount);
end;

procedure TfrSplitDetail.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if modalresult = mrOk then
  begin
    if dbeCatID.Text = '' then
    begin
      canclose := False;
      bCategory.SetFocus;
      exit;
    end;
    if eAmount.Text = '' then
    begin
      canclose := False;
      eAmount.SetFocus;
      exit;
    end;

    if Mode = 'Normal' then
    begin
      //transcode does not exist for new records.
      if {(dmData.zqSplitTransactions.FieldByName('TRANSCODE').AsString} Transcode = 'Withdrawal' then
      begin
        if cbType.Text = 'Withdrawal' then
          dmData.ztSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency := (dmData.CurrencyEditToFloat(eAmount))
        else
  //      if cbType.Text = 'Deposit' then
          dmData.ztSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency := (dmData.CurrencyEditToFloat(eAmount) * -1);
      end else
      if {(dmData.zqSplitTransactions.FieldByName('TRANSCODE').AsString} Transcode = 'Deposit' then
      begin
        if cbType.Text = 'Withdrawal' then
          dmData.ztSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency := (dmData.CurrencyEditToFloat(eAmount) * -1)
        else
  //      if cbType.Text = 'Deposit' then
          dmData.ztSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency := (dmData.CurrencyEditToFloat(eAmount));
      end;
    end else
    begin
      //transcode does not exist for new records.
      if {(dmData.zqSplitTransactions.FieldByName('TRANSCODE').AsString} Transcode = 'Withdrawal' then
      begin
        if cbType.Text = 'Withdrawal' then
          dmData.ztRepeatSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency := (dmData.CurrencyEditToFloat(eAmount))
        else
  //      if cbType.Text = 'Deposit' then
          dmData.ztRepeatSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency := (dmData.CurrencyEditToFloat(eAmount) * -1);
      end else
      if {(dmData.zqSplitTransactions.FieldByName('TRANSCODE').AsString} Transcode = 'Deposit' then
      begin
        if cbType.Text = 'Withdrawal' then
          dmData.ztRepeatSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency := (dmData.CurrencyEditToFloat(eAmount) * -1)
        else
  //      if cbType.Text = 'Deposit' then
          dmData.ztRepeatSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency := (dmData.CurrencyEditToFloat(eAmount));
      end;
    end;

  end;
end;

procedure TfrSplitDetail.FormCreate(Sender: TObject);
begin
  dbeCatID.Visible:= dmData.DebugMode;
  dbeSubCatID.Visible:= dmData.DebugMode;
  dbeTransID.Visible:= dmData.DebugMode;
  eFormattedAmount.Visible:= dmData.DebugMode;
end;

procedure TfrSplitDetail.FormShow(Sender: TObject);
var CatID, SubCatID : integer;
  AmountStr : string;
begin
  if Mode = 'Normal' then
  begin
    dbeTransID.DataField := '';
    dbeTransID.DataSource := dmData.dsSplitTransactions;
    dbeTransID.DataField := 'TRANSID';
    eFormattedAmount.DataField := '';
    eFormattedAmount.DataSource := dmData.dsSplitTransactions;
    eFormattedAmount.DataField := 'SPLITTRANSAMOUNT';
    dbeCatID.DataField := '';
    dbeCatID.DataSource := dmData.dsSplitTransactions;
    dbeCatID.DataField := 'CATEGID';
    dbeSubCatID.DataField := '';
    dbeSubCatID.DataSource := dmData.dsSplitTransactions;
    dbeSubCatID.DataField := 'SUBCATEGID';
  end else
  begin
    dbeTransID.DataField := '';
    dbeTransID.DataSource := dmData.dsRepeatSplitTransactions;
    dbeTransID.DataField := 'TRANSID';
    eFormattedAmount.DataField := '';
    eFormattedAmount.DataSource := dmData.dsRepeatSplitTransactions;
    eFormattedAmount.DataField := 'SPLITTRANSAMOUNT';
    dbeCatID.DataField := '';
    dbeCatID.DataSource := dmData.dsRepeatSplitTransactions;
    dbeCatID.DataField := 'CATEGID';
    dbeSubCatID.DataField := '';
    dbeSubCatID.DataSource := dmData.dsRepeatSplitTransactions;
    dbeSubCatID.DataField := 'SUBCATEGID';
  end;


  if EditMode = 'Edit' then
  begin
    if Mode = 'Normal' then
      eAmount.Text:= floatToStr(dmData.ztSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency)
    else
      eAmount.Text:= floatToStr(dmData.ztRepeatSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency);

    dmData.DisplayCurrencyEdit(eAmount);

    if dbeCatID.Text <> '' then
      CatID := StrToInt(dbeCatID.Text);
    if dbeSubCatID.Text <> '' then
      SubCatID := StrToInt(dbeSubCatID.Text);

    bCategory.Caption := dmData.GetCategoryDescription(CatID, SubCatID, 'Category');

    if Mode = 'Normal' then
    begin
      if Transcode = 'Withdrawal' then
      begin
        if dmData.ztSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency > 0 then
          cbType.ItemIndex:= 0
        else
        begin
          cbType.ItemIndex:= 1;
          dmData.DisplayCurrencyEditRemoveNegative(eAmount);
        end;

      end else
      if Transcode = 'Deposit' then
      begin
        if dmData.ztSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency > 0 then
          cbType.ItemIndex:= 1
        else
        begin
          cbType.ItemIndex:= 0;
          dmData.DisplayCurrencyEditRemoveNegative(eAmount);
        end;
      end;
    end else
    begin
      if Transcode = 'Withdrawal' then
      begin
        if dmData.ztRepeatSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency > 0 then
          cbType.ItemIndex:= 0
        else
        begin
          cbType.ItemIndex:= 1;
          dmData.DisplayCurrencyEditRemoveNegative(eAmount);
        end;
      end else
      if Transcode = 'Deposit' then
      begin
        if dmData.ztRepeatSplitTransactions.FieldByName('SPLITTRANSAMOUNT').AsCurrency > 0 then
          cbType.ItemIndex:= 1
        else
        begin
          cbType.ItemIndex:= 0;
          dmData.DisplayCurrencyEditRemoveNegative(eAmount);
        end;
      end;
    end;
  end else
  if EditMode = 'Insert' then
  begin
    if Transcode = 'Withdrawal' then
      cbType.ItemIndex:= 0
    else
      cbType.ItemIndex:= 1;
  end;
end;

end.

