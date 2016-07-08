{ To do list:

1. After adding budget ask user if they would like to add details. If so close window and select new budget in grid
2. Add favourite budget option, show the amounts for this budget on the main tab.
3. Show a faded font for filters which are archived

}

unit uBudgetEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DbCtrls, DBGrids, ZDataset, db, ComCtrls;

type

  { TfrBudgetEditor }

  TfrBudgetEditor = class(TForm)
    bAdd: TButton;
    bEdit: TButton;
    bClose: TButton;
    bDelete: TButton;
    dbgBudgets: TDBGrid;
    panFooter: TPanel;
    RadioGroup1: TRadioGroup;
    procedure bEditClick(Sender: TObject);
    procedure bAddClick(Sender: TObject);
    procedure bDeleteClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ShowDBTextFields(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure ztBudgetYearCalcFields(DataSet: TDataSet);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frBudgetEditor: TfrBudgetEditor;

implementation

{$R *.lfm}

uses uDataModule, uMain, uBudget;

{ TfrBudgetEditor }

procedure  TfrBudgetEditor.ShowDBTextFields(Sender: TField; var aText: string; DisplayText: Boolean);
begin
end;

procedure TfrBudgetEditor.ztBudgetYearCalcFields(DataSet: TDataSet);
begin
end;


procedure TfrBudgetEditor.FormShow(Sender: TObject);
begin
end;

procedure TfrBudgetEditor.bAddClick(Sender: TObject);
begin
  try
    frBudget := TfrBudget.create(self);
    frBudget.EditMode:= 'Insert';
    frBudget.Showmodal;
  finally
    frBudget.Free;
  end;
end;

procedure TfrBudgetEditor.bDeleteClick(Sender: TObject);
var ParentNode, Node : TTreenode;
begin
  if dmData.ztBudgetYear.RecordCount = 0 then exit;

  if MessageDlg('Are you sure you want to delete "'+dmdata.zqBudgetYear.FieldByName('BUDGETYEARNAME').AsString+'" budget?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;

  if dmData.ztBudgetYear.Locate('BUDGETYEARNAME', dmdata.zqBudgetYear.FieldByName('BUDGETYEARNAME').AsString, [loCaseInsensitive]) = True then
  begin
    dmData.DeleteDBRecord(dmData.ztBudget.TableName, 'BUDGETYEARID', dmData.ztBudgetYear.FieldByName('BUDGETYEARID').AsInteger);
    dmData.DeleteDBRecord(dmData.ztBudgetYear.TableName, 'BUDGETYEARID', dmData.ztBudgetYear.FieldByName('BUDGETYEARID').AsInteger);
    dmdata.RefreshDataset(dmData.ztBudgetYear);
    dmdata.RefreshDataset(dmData.ztBudget);
    dmdata.RefreshDataset(dmData.zqBudgetYear);

    frMain.CreateBudgetSetupItems;

    ParentNode := dmData.GetNodeByText(frMain.tvNavigation, 'Budgets', false);
    Node := frMain.tvNavigation.Selected;
    if Node <> nil then
    begin
      if Node.Parent <> ParentNode then
        Node := ParentNode.GetFirstChild;
      if Node <> nil then Node.Selected := True;
    end;

  end;
end;

procedure TfrBudgetEditor.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  dmdata.SaveGridLayout(dbgBudgets);
end;

procedure TfrBudgetEditor.FormCreate(Sender: TObject);
begin
  dmdata.zqBudgetYear.Active:= False;
  dmdata.zqBudgetYear.SQL.Clear;
  dmData.zqBudgetYear.SQL.Add(
  ' select * from '+dmdata.ztBudgetYear.TableName+
  ' order by BUDGETYEARNAME '
    );
  dmdata.zqBudgetYear.ExecSQL;
  dmdata.zqBudgetYear.Active:= True;
  dmdata.LoadGridLayout(dbgBudgets);
end;

procedure TfrBudgetEditor.bEditClick(Sender: TObject);
var month : integer;
  MonthStr : string;
begin
  if dmData.ztBudgetYear.Locate('BUDGETYEARNAME', dmdata.zqBudgetYear.FieldByName('BUDGETYEARNAME').AsString, [loCaseInsensitive]) = True then
  begin
    try
      frBudget := TfrBudget.create(self);
      frBudget.EditMode := 'Edit';
      frBudget.Showmodal;
    finally
      frBudget.Free;
    end;
  end;
end;

end.

