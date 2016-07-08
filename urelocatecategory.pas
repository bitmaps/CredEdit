{ To do list:

1. Finish off counts for other transaction types.
2. Refresh previous screen if showing a grid where data has changed

}

unit uRelocateCategory;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TfrRelocateCategory }

  TfrRelocateCategory = class(TForm)
    bCancel: TButton;
    bFrom: TButton;
    bTo: TButton;
    bOk: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    pBottom: TPanel;
    procedure bFromClick(Sender: TObject);
    procedure bToClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure DoRelocate;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frRelocateCategory: TfrRelocateCategory;
  SourceCatID, SourceSubCatID,
  ToCatID, ToSubCatID : integer;


implementation

{$R *.lfm}

uses uDataModule, uOrganiseCategories;

{ TfrRelocateCategory }

procedure TfrRelocateCategory.bFromClick(Sender: TObject);
begin
  if frOrganiseCategories.SelectCategory(SourceCatID, SourceSubCatID) then
    bFrom.Caption := dmData.GetCategoryDescription(SourceCatID, SourceSubCatID, 'Category');
end;

procedure TfrRelocateCategory.bToClick(Sender: TObject);
begin
  if frOrganiseCategories.SelectCategory(ToCatID, ToSubCatID) then
    bTo.Caption := dmData.GetCategoryDescription(ToCatID, ToSubCatID, 'Category');
end;

procedure TfrRelocateCategory.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  if modalresult = mrOk then
  begin
    if ((SourceCatID = -1) and (SourceSubCatID = -1)) or
    ((ToCatID = -1) and (ToSubCatID = -1)) then
      begin
        CanClose := False;
        exit;
      end;

    DoRelocate;
  end;
end;

procedure TfrRelocateCategory.FormCreate(Sender: TObject);
var i : integer;
begin
  SourceCatID := -1;
  SourceSubCatID := -1;
  ToCatID := -1;
  ToSubCatID := -1;
end;

procedure TfrRelocateCategory.DoRelocate;
var TransCnt, SplitTransCnt, RepTransCnt, RepSplitTransCnt, DefPayCnt, BudCnt : integer;
begin
  TransCnt := 0;
  SplitTransCnt := 0;
  RepTransCnt := 0;
  RepSplitTransCnt := 0;
  DefPayCnt := 0;
  BudCnt := 0;

  dmData.ZQuery1.Active:= False;
  dmData.ZQuery1.SQL.Clear;
  dmData.ZQuery1.SQL.Add(
  ' select * '+
  ' from '+dmData.ztCheckingAccount.TableName+
  ' where categid = '+IntToStr(SourceCatID)+
  ' and subcategid = '+IntToStr(SourceSubCatID));
  dmData.ZQuery1.ExecSQL;
  dmData.ZQuery1.Active:= True;
  TransCnt := dmData.ZQuery1.RecordCount;
  dmData.ZQuery1.Active:= False;

  dmData.ZQuery1.Active:= False;
  dmData.ZQuery1.SQL.Clear;
  dmData.ZQuery1.SQL.Add(
  ' select * '+
  ' from '+dmData.ztSplitTransactions.TableName+
  ' where categid = '+IntToStr(SourceCatID)+
  ' and subcategid = '+IntToStr(SourceSubCatID));
  dmData.ZQuery1.ExecSQL;
  dmData.ZQuery1.Active:= True;
  SplitTransCnt := dmData.ZQuery1.RecordCount;
  dmData.ZQuery1.Active:= False;

  if MessageDlg(
  'Please Confirm '+
  #13#10#13#10+
  'Records found in transactions: '+IntToStr(TransCnt)+#13#10+
  'Records found in split transactions: '+IntToStr(SplitTransCnt)+#13#10+
{  'Records found in repeating transactions: '+IntToStr(RepTransCnt)+#13#10+
  'Records found in repeating split transactions: '+IntToStr(RepSplitTransCnt)+#13#10+
  'Records found in Default Payee category: '+IntToStr(DefPayCnt)+#13#10+
  'Records found in budget: '+IntToStr(BudCnt)+#13#10+}
  #13#10+
  'Changing all categories of: '+#13#10+
  bFrom.Caption+#13#10+
  'to: '+#13#10+
  bTo.Caption+#13#10
  ,mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;

  //Run datafix
  dmData.ZQuery1.SQL.Clear;
  dmData.ZQuery1.SQL.Add(
  ' update '+dmData.ztCheckingAccount.TableName+
  ' set categid = '+IntToStr(ToCatID)+ ','+
  ' subcategid  = '+IntToStr(ToSubCatID)+
  ' where categid = '+IntToStr(SourceCatID)+
  ' and subcategid = '+IntToStr(SourceSubCatID));
  dmData.ZQuery1.ExecSQL;

  if SplitTransCnt > 0 then
  begin
    dmData.ZQuery1.SQL.Clear;
    dmData.ZQuery1.SQL.Add(
    ' update '+dmData.ztSplitTransactions.TableName+
    ' set categid = '+IntToStr(ToCatID)+ ','+
    ' subcategid  = '+IntToStr(ToSubCatID)+
    ' where categid = '+IntToStr(SourceCatID)+
    ' and subcategid = '+IntToStr(SourceSubCatID));
    dmData.ZQuery1.ExecSQL;
  end;

//  dmData.ztCheckingAccount.Refresh;
end;

end.

