{ To do list:

1. Cancel button will need to revert changes somehow. Maybe use arrays rather than db tables.
2. Add support for repeat split transactions

}

unit uSplitTransaction;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DBGrids, DbCtrls, math;

type

  { TfrSplitTransaction }

  TfrSplitTransaction = class(TForm)
    bAdd: TButton;
    bCancel: TButton;
    bRemove: TButton;
    bEdit: TButton;
    bOk: TButton;
    dbeTransID: TDBEdit;
    dbgSplitTransactions: TDBGrid;
    GroupBox1: TGroupBox;
    lbTotalType: TLabel;
    lbTotValue: TLabel;
    panFooter: TPanel;
    procedure bAddClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bEditClick(Sender: TObject);
    procedure bRemoveClick(Sender: TObject);
//    procedure DisplaySplitTransactionsGrid(TransID : Integer);
    procedure DisplaySplitTransactionsGrid;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure UpdateTotalsLabel;
  private
    { private declarations }
  public
    { public declarations }
//    EditMode : string;
    TransID : integer;
    Transcode : string;
    Mode : string;
  end;

var
  frSplitTransaction: TfrSplitTransaction;

implementation

{$R *.lfm}

uses uMain, uSplitDetail, uDataModule;

procedure TfrSplitTransaction.UpdateTotalsLabel;
var vTotal : Float;
begin
  vTotal := dmData.SplitTransactionsTotal;
  if vTotal = 0 then
    lbTotValue.Caption:= frMain.CurrencySymbol + frMain.FullDecimalPlacesStr
  else
    lbTotValue.Caption := frMain.CurrencySymbol+dmData.CurrencyStr2DP(FloatToStr(vTotal));
end;

//procedure TfrSplitTransaction.DisplaySplitTransactionsGrid(TransID : Integer);

procedure TfrSplitTransaction.DisplaySplitTransactionsGrid;
var TableName : string;
begin
  if Mode = 'Normal' then
    TableName := dmData.ztSplitTransactions.TableName
  else
    TableName := dmData.ztRepeatSplitTransactions.TableName;

  with dmData do
  begin
    zqSplitTransactions.Active:= False;
    zqSplitTransactions.SQL.Clear;
    zqSplitTransactions.SQL.Add(
      ' select s.*, '+
      ' case s.categid when -1 then '+chr(39)+chr(39)+
      ' else '+
      '   case s.subcategid when -1 then categname '+
      '   else coalesce(categname,'+chr(39)+chr(39)+') ||'+chr(39)+': '+chr(39)+'||coalesce(subcategname,'+chr(39)+chr(39)+') '+
      '   end '+
      ' end as category '+
      ' from '+TableName+' s '+
      ' left outer join '+dmData.ztCategory.TableName+' c on s.categid = c.categid '+
      ' left outer join '+dmData.ztSubCategory.TableName+' sc on c.categid = sc.categid and s.subcategid = sc.subcategid '+
      ' where s.transid = :transid ');
    zqSplitTransactions.ParamByName('transid').Value := TransID;
    zqSplitTransactions.ExecSQL;
    zqSplitTransactions.Active:= True;
  end;
  UpdateTotalsLabel;
end;

procedure TfrSplitTransaction.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
var vTotal : Float;
begin
  if modalresult = mrOk then
  begin
    vTotal := dmData.SplitTransactionsTotal;
    CanClose := (vTotal > 0);
    if CanClose = False then MessageDlg('Invalid total amount: '+lbTotValue.Caption,mtError, [mbOk], 0);
  end;

  dmdata.SaveGridLayout(dbgSplitTransactions);
end;

procedure TfrSplitTransaction.FormCreate(Sender: TObject);
begin
  dbeTransID.Visible:= dmData.DebugMode;
end;

procedure TfrSplitTransaction.bAddClick(Sender: TObject);
begin
  try
    frSplitDetail := TfrSplitDetail.create(self);
    frSplitDetail.EditMode:= 'Insert';
    frSplitDetail.Mode:= Mode;

    if Mode = 'Normal' then
    begin
      dmData.ztSplitTransactions.Insert;
      dmData.ztSplitTransactions.FieldByName('TRANSID').AsInteger := frSplitTransaction.transid;
    end else
    begin
      dmData.ztRepeatSplitTransactions.Insert;
      dmData.ztRepeatSplitTransactions.FieldByName('TRANSID').AsInteger := frSplitTransaction.transid;
    end;

    frSplitDetail.Transcode := Transcode;

    if frSplitDetail.Showmodal = mrOk then
    begin
      if Mode = 'Normal' then dmData.SaveChanges(dmData.ztSplitTransactions, false) else dmData.SaveChanges(dmData.ztRepeatSplitTransactions, false);

      dmdata.RefreshDataset(dmData.zqSplitTransactions);
    end else
      if Mode = 'Normal' then dmData.ztSplitTransactions.Cancel else dmData.ztRepeatSplitTransactions.Cancel;

  finally
    frSplitDetail.Free;
  end;
  UpdateTotalsLabel;
end;

procedure TfrSplitTransaction.bCancelClick(Sender: TObject);
begin

end;

procedure TfrSplitTransaction.bEditClick(Sender: TObject);
var ads : TDataset;
begin
  if Mode = 'Normal' then
  begin
    if dmData.ztSplitTransactions.Locate('SPLITTRANSID', dmData.zqSplitTransactions.FieldByName('SPLITTRANSID').AsInteger, [loCaseInsensitive]) = True then
    begin
      try
        frSplitDetail := TfrSplitDetail.create(self);
        frSplitDetail.Mode:= Mode;
        frSplitDetail.EditMode:= 'Edit';
        frSplitDetail.Transcode := Transcode;
        dmData.ztSplitTransactions.Edit;
        if frSplitDetail.Showmodal = mrOk then
        begin
          dmData.SaveChanges(dmData.ztSplitTransactions, false);
          dmdata.RefreshDataset(dmData.zqSplitTransactions);
        end else
          dmData.ztSplitTransactions.Cancel;
      finally
        frSplitDetail.Free;
      end;
      UpdateTotalsLabel;
    end;
  end else
  begin
    if dmData.ztRepeatSplitTransactions.Locate('SPLITTRANSID', dmData.zqSplitTransactions.FieldByName('SPLITTRANSID').AsInteger, [loCaseInsensitive]) = True then
    begin
      try
        frSplitDetail := TfrSplitDetail.create(self);
        frSplitDetail.Mode:= Mode;
        frSplitDetail.EditMode:= 'Edit';
        frSplitDetail.Transcode := Transcode;
        dmData.ztRepeatSplitTransactions.Edit;
        if frSplitDetail.Showmodal = mrOk then
        begin
          dmData.SaveChanges(dmData.ztRepeatSplitTransactions, false);
          dmdata.RefreshDataset(dmData.zqSplitTransactions);
        end else
          dmData.ztRepeatSplitTransactions.Cancel;
      finally
        frSplitDetail.Free;
      end;
      UpdateTotalsLabel;
    end;
  end;
end;

procedure TfrSplitTransaction.bRemoveClick(Sender: TObject);
var Tablename : string;
begin
  if dmData.zqSplitTransactions.RecordCount = 0 then exit;

  if MessageDlg('Are you sure you want to delete this split transaction?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;
  if Mode = 'Normal' then
    Tablename := dmData.ztSplitTransactions.TableName
  else
    Tablename := dmData.ztRepeatSplitTransactions.TableName;

  dmData.ZQuery1.SQL.Clear;
  dmData.ZQuery1.SQL.Add('delete from '+Tablename+' where splittransid = '+
    IntToStr(dmData.zqSplitTransactions.FieldByName('splittransid').AsInteger)+';');
  dmData.ZQuery1.ExecSQL;
  dmdata.RefreshDataset(dmData.zqSplitTransactions);
  UpdateTotalsLabel;
end;

procedure TfrSplitTransaction.FormShow(Sender: TObject);
begin
  if Mode = 'Normal' then
  begin
    dbeTransID.DataField := '';
    dbeTransID.DataSource := dmData.dsCheckingAccount;
    dbeTransID.DataField := 'TRANSID';
  end else
  begin
    dbeTransID.DataField := '';
    dbeTransID.DataSource := dmData.dsRepeatTransactions;
    dbeTransID.DataField := 'REPTRANSID';
  end;

  dbgSplitTransactions.Options := frMain.dbgBankAccount.Options;
  dmdata.LoadGridLayout(dbgSplitTransactions);
end;


end.

