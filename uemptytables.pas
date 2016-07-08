unit uEmptyTables;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DbCtrls, CheckLst;

type

  { TfrEmptyTables }

  TfrEmptyTables = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    clbTables: TCheckListBox;
    gbTables: TGroupBox;
    pBottom: TPanel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frEmptyTables: TfrEmptyTables;

implementation

{$R *.lfm}

uses uDataModule;

{ TfrEmptyTables }

procedure TfrEmptyTables.FormShow(Sender: TObject);
var i : integer;
begin
  clbTables.Items.Add(dmdata.ztAccountList.TableName);
  clbTables.Items.Add(dmdata.ztAssets.TableName);
  clbTables.Items.Add(dmdata.ztBudget.TableName);
  clbTables.Items.Add(dmdata.ztBudgetYear.TableName);
  clbTables.Items.Add(dmdata.ztCategory.TableName);
  clbTables.Items.Add(dmdata.ztCheckingAccount.TableName);
  clbTables.Items.Add(dmdata.ztGridSettings.TableName);
  clbTables.Items.Add(dmdata.ztInfotable.TableName);
  clbTables.Items.Add(dmdata.ztPayee.TableName);
  clbTables.Items.Add(dmdata.ztPayeeImport.TableName);
  clbTables.Items.Add(dmdata.ztRepeatTransactions.TableName);
  clbTables.Items.Add(dmdata.ztRepeatSplitTransactions.TableName);
  clbTables.Items.Add(dmdata.ztSplitTransactions.TableName);
  clbTables.Items.Add(dmdata.ztSubCategory.TableName);
  clbTables.Items.Add(dmdata.ztTransFilter.TableName);

  for i:= 0 to clbTables.Count-1 do
    clbTables.Checked[i] := True;
end;

procedure TfrEmptyTables.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
var i : integer;
begin
  if modalresult = mrOk then
  begin
    Screen.Cursor:= crHourGlass;
    for i:= 0 to clbTables.Count-1 do
    begin
      if clbTables.Checked[i] then dmData.EmptyDatabaseTable(clbTables.Items.Strings[i]);
    end;
    Screen.Cursor:= crDefault;
  end;
end;

end.

