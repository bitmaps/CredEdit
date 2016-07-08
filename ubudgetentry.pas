{ To do list:

1. Add budget description details on top of screen: budget account, date criteria etc

}

unit uBudgetEntry;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DbCtrls, ZDataset, db, math;

type

  { TfrBudgetEntry }

  TfrBudgetEntry = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    cbFrequency: TComboBox;
    cbType: TComboBox;
    dbeBUDGETENTRYID: TDBEdit;
    dbeBudgetYearID: TDBEdit;
    dbeCatID: TDBEdit;
    dbeSubCatID: TDBEdit;
    eAmount: TEdit;
    eFormattedAmount: TDBEdit;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lbActualDescription: TLabel;
    lbCatDescription: TLabel;
    lbEstimatedDescription: TLabel;
    lbSubCatDescription: TLabel;
    pBottom: TPanel;
    procedure eAmountExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    EditMode, BUDGETENTRYID, BUDGETFREQUENCY : string;
  end;

var
  frBudgetEntry: TfrBudgetEntry;

implementation

{$R *.lfm}

uses uDataModule;

{ TfrBudgetEntry }

procedure TfrBudgetEntry.FormCreate(Sender: TObject);
begin
  dbeCatID.Visible:= dmData.DebugMode;
  dbeSubCatID.Visible:= dmData.DebugMode;
  dbeBudgetYearID.Visible:= dmData.DebugMode;
  eFormattedAmount.Visible:= dmData.DebugMode;
  dbeBUDGETENTRYID.Visible:= dmData.DebugMode;
end;

procedure TfrBudgetEntry.FormShow(Sender: TObject);
begin
  eAmount.SetFocus;
end;

procedure TfrBudgetEntry.eAmountExit(Sender: TObject);
var TempTot : Float;
begin
  dmData.DisplayCurrencyEdit(eAmount);

  //update estimated values
  if eAmount.Text <> '' then
  begin
    if frBudgetEntry.cbType.Text = 'Income' then
      TempTot := dmData.CalcEstimatedAmount(dmdata.CurrencyEditToFloat(eAmount), cbFrequency.Text, BUDGETFREQUENCY)
    else
      TempTot := (dmData.CalcEstimatedAmount(dmdata.CurrencyEditToFloat(eAmount), cbFrequency.Text, BUDGETFREQUENCY) * -1);
  end else
    TempTot := 0;

//  lbEstimatedDescription.Caption:= dmdata.CurrencyStr2DP(FloatToStr(TempTot));
  lbEstimatedDescription.Caption:= dmdata.ConvertFloatToCurrencyString(TempTot);
end;

end.

