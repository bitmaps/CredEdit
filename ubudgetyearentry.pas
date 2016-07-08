{ To do list:


}

unit uBudgetYearEntry;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DbCtrls, Spin;

type

  { TfrBudgetYearEntry }

  TfrBudgetYearEntry = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    cbBudgets: TComboBox;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    pBottom: TPanel;
    seYear: TSpinEdit;
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frBudgetYearEntry: TfrBudgetYearEntry;

implementation

uses uDataModule;

{$R *.lfm}

{ TfrBudgetYearEntry }

procedure TfrBudgetYearEntry.FormShow(Sender: TObject);
begin
  dmData.PopulateComboBox(frBudgetYearEntry.cbBudgets, dmData.ztBudgetYear, 'BUDGETYEARNAME');
end;

end.

