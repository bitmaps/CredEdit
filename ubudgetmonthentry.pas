{ To do list:


}

unit ubudgetmonthentry;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ExtCtrls;

type

  { TfrBudgetMonthEntry }

  TfrBudgetMonthEntry = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    cbBudgets: TComboBox;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    pBottom: TPanel;
    seYear: TSpinEdit;
    seMonth: TSpinEdit;
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frBudgetMonthEntry: TfrBudgetMonthEntry;

implementation

uses uDataModule;

{$R *.lfm}

{ TfrBudgetMonthEntry }

procedure TfrBudgetMonthEntry.FormShow(Sender: TObject);
begin
  dmData.PopulateComboBox(frBudgetMonthEntry.cbBudgets, dmData.ztBudgetYear, 'BUDGETYEARNAME');
end;

end.

