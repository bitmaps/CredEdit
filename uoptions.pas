{ To do list:

1. Add incremental naming for backups
2. Add colour for future transactions ie. budgeting.
3. 10 user defined colours for charts?
4. User specific colours for user defined categories
5. Add option to specify report options on homepage

}
unit uOptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, Spin, customdrawncontrols, customdrawn_common;

type

  { TfrOptions }

  TfrOptions = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    bResetDefaults: TButton;
    cbDefaultAccount: TComboBox;
    cbDefaultNewDate: TComboBox;
    cbDefCategory: TComboBox;
    cbDefStatus: TComboBox;
    cbDefPayee: TComboBox;
    cbDefType: TComboBox;
    cbDisplayDateFormat: TComboBox;
    cbDefBudgetFrequency: TComboBox;
    cbItemLimit: TComboBox;
    cbToolbarCaptions: TCheckBox;
    cbRepAccounts: TComboBox;
    cbRepGroup: TComboBox;
    cbStartMonth: TComboBox;
    cbStartupBackup: TCheckBox;
    cbBackupExit: TCheckBox;
    cbShowLocationCaption: TCheckBox;
    cbShowBudgetColours: TCheckBox;
    cbDefBudgetType: TComboBox;
    cdbExpenses: TCDButton;
    cdbIncome: TCDButton;
    cdbListBackground: TCDButton;
    cdbListRow0: TCDButton;
    cdbListRow1: TCDButton;
    cdbNavTree: TCDButton;
    cdbChartBack: TCDButton;
    cbMouseOver: TCheckBox;
    ColorDialog1: TColorDialog;
    edDatabaseLocation: TEdit;
    edDatabasePassword: TEdit;
    eCurrencySymbol: TEdit;
    eUserName: TEdit;
    gbFinancialYear: TGroupBox;
    gbDisplayDateFormat: TGroupBox;
    gbUserName: TGroupBox;
    gbTransDefaults: TGroupBox;
    gbDatabaseLocation: TGroupBox;
    gbDatabaseBackup: TGroupBox;
    gbDatabasePassword: TGroupBox;
    GroupBox2: TGroupBox;
    gbDefSelection: TGroupBox;
    gbMouseOver: TGroupBox;
    gbFinancialDetails: TGroupBox;
    gbBudgetDefaults: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label8: TLabel;
    lbDate: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    nbOptions: TNotebook;
    pgInterface: TPage;
    pgReports: TPage;
    pgGeneral: TPage;
    pgTranDefaults: TPage;
    pgDatabase: TPage;
    pgColours: TPage;
    pBottom: TPanel;
    rgToolbarPosition: TRadioGroup;
    rgDefaultReport: TRadioGroup;
    seStartDay: TSpinEdit;
    seMaxBackup: TSpinEdit;
    seDecPlaces: TSpinEdit;
    tvOptions: TTreeView;
    procedure bResetDefaultsClick(Sender: TObject);
    procedure cbDisplayDateFormatChange(Sender: TObject);
    procedure cdbChartBackClick(Sender: TObject);
    procedure cdbExpensesClick(Sender: TObject);
    procedure cdbIncomeClick(Sender: TObject);
    procedure cdbListBackgroundClick(Sender: TObject);
    procedure cdbListRow0Click(Sender: TObject);
    procedure cdbListRow1Click(Sender: TObject);
    procedure cdbNavTreeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure tvOptionsChange(Sender: TObject; Node: TTreeNode);
    procedure LoadSettings;
    procedure SaveSettings;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frOptions: TfrOptions;

implementation

{$R *.lfm}

uses uDataModule, uMain, uReportFuncs;

{ TfrOptions }

procedure TfrOptions.LoadSettings;
begin
//  SetupRepAccountsComboBox(frOptions.cbRepAccounts);
  dmData.SetupComboBox(frOptions.cbRepAccounts, dmdata.ztAccountList, 'ACCOUNTNAME', '[All Accounts]', '[All Accounts]');

  lbDate.Caption := FormatDateTime(cbDisplayDateFormat.Text, now);
  with dmData do
  begin
    cdbListRow1.Color := StringToColor(GetInfoSettings('COLOURS_LISTROW1', '$00F5E9E2'));
    cdbListRow0.Color := StringToColor(GetInfoSettings('COLOURS_LISTROW0', 'clWindow'));
    cdbListBackground.Color := StringToColor(GetInfoSettings('COLOURS_LISTBACKGROUND', 'clWindow'));
    cdbNavTree.Color := StringToColor(GetInfoSettings('COLOURS_NAVTREE', 'clWindow'));
    cdbChartBack.Color := StringToColor(GetInfoSettings('COLOURS_CHARTBACKGROUND', 'clBtnFace'));
    cdbExpenses.Color := StringToColor(GetInfoSettings('COLOURS_EXPENSES', 'clRed'));
    cdbIncome.Color := StringToColor(GetInfoSettings('COLOURS_INCOME', 'clBlue'));
    cbDefaultAccount.Text:= GetInfoSettings('DEFAULT_ACCOUNT', 'None');
    cbDefaultNewDate.Text:= GetInfoSettings('DEFAULT_NEWDATE', 'Todays Date');
    cbDefPayee.Text:= GetInfoSettings('DEFAULT_PAYEE', 'None');
    cbDefCategory.Text:= GetInfoSettings('DEFAULT_CATEGORY', 'None');
    cbDefStatus.Text := GetInfoSettings('DEFAULT_STATUS', 'Last Used');
    cbDefType.Text := GetInfoSettings('DEFAULT_TYPE', 'Last Used');
    rgDefaultReport.itemindex := GetInfoSettingsInt('REPORTS_TYPE', 0);
    cbRepGroup.itemindex := GetInfoSettingsInt('REPORTS_FILTER', 0);
    cbItemLimit.itemindex := GetInfoSettingsInt('REPORTS_LIMIT', 0);
    cbRepAccounts.Text := GetInfoSettings('REPORTS_ACCOUNT', '[All Accounts]');
    cbStartupBackup.Checked := GetInfoSettingsBool('BACKUP_STARTUP', False);
    cbBackupExit.Checked := GetInfoSettingsBool('BACKUP_EXIT', False);
    seMaxBackup.Value:= GetInfoSettingsInt('BACKUP_MAX', 0);
    seStartDay.Value := GetInfoSettingsInt('FINANCIAL_YEAR_START_DAY', 1);
    cbStartMonth.ItemIndex := GetInfoSettingsInt('FINANCIAL_YEAR_START_MONTH', 7) -1;
    cbDisplayDateFormat.Text := GetInfoSettings('DATEFORMAT', 'YYYY-MM-DD');
    eUserName.Text := GetInfoSettings('USERNAME', '');
    edDatabasePassword.Text := DecodeStringBase64(dmData.GetInfoSettings('PASSWORD', ''));
    edDatabaseLocation.Text:= zcDatabaseConnection.Database;
    cbShowLocationCaption.Checked := GetInfoSettingsBool('SHOW_DATABASELOCATION', true);
    cbShowBudgetColours.Checked := GetInfoSettingsBool('SHOW_BUDGET_COLOURS', true);
    rgToolbarPosition.itemindex := GetInfoSettingsInt('TOOLBAR_POSITION', 0);
    cbMouseOver.Checked := GetInfoSettingsBool('MOUSE_OVER', True);
    cbToolbarCaptions.Checked := GetInfoSettingsBool('TOOLBAR_CAPTIONS', False);
    seDecPlaces.Value := GetInfoSettingsInt('FINANCIAL_DECIMAL_PLACES', 2);
    eCurrencySymbol.Text := GetInfoSettings('FINANCIAL_CURRENCY_SYMBOL', '£');
    cbDefBudgetType.Text := GetInfoSettings('DEFAULT_BUDGET_TYPE', 'Last Used');
    cbDefBudgetFrequency.Text := GetInfoSettings('DEFAULT_BUDGET_FREQUENCY', 'Last Used');
  end;
end;

procedure TfrOptions.SaveSettings;
var  EncodedPassword : string;
begin
  with frMain do
  begin
    DefaultReportType := rgDefaultReport.ItemIndex;
    UpdateGridColours(cdbListRow0.Color, cdbListRow1.Color);
    tvNavigation.BackgroundColor := cdbNavTree.Color;
    PieChart.BackColor := cdbChartBack.Color;
    BarChart.BackColor:= cdbChartBack.Color;
    miViewToolbarCaptions.Checked:= cbToolbarCaptions.Checked;
  end;

  EncodedPassword := dmData.EncodeStringBase64(edDatabasePassword.Text);

  with dmData do
  begin
    DisplayDateFormat := cbDisplayDateFormat.Text;
    ExitBackup := cbBackupExit.Checked;
    StartupBackup:= cbStartupBackup.Checked;
    MouseOver := cbMouseOver.Checked;
    SetInfoSettings('COLOURS_LISTROW1', ColorToString(cdbListRow1.Color));
    SetInfoSettings('COLOURS_LISTROW0', ColorToString(cdbListRow0.Color));
    SetInfoSettings('COLOURS_LISTBACKGROUND', ColorToString(cdbListBackground.Color));
    SetInfoSettings('COLOURS_NAVTREE', ColorToString(cdbNavTree.Color));
    SetInfoSettings('COLOURS_CHARTBACKGROUND', ColorToString(cdbChartBack.Color));
    SetInfoSettings('COLOURS_EXPENSES', ColorToString(cdbExpenses.Color));
    SetInfoSettings('COLOURS_INCOME', ColorToString(cdbIncome.Color));
    SetInfoSettingsBool('SHOW_BUDGET_COLOURS', cbShowBudgetColours.Checked);
    SetInfoSettings('DEFAULT_ACCOUNT', cbDefaultAccount.Text);
    SetInfoSettings('DEFAULT_NEWDATE', cbDefaultNewDate.Text);
    SetInfoSettings('DEFAULT_PAYEE', cbDefPayee.Text);
    SetInfoSettings('DEFAULT_CATEGORY', cbDefCategory.Text);
    SetInfoSettings('DEFAULT_STATUS', cbDefStatus.Text);
    SetInfoSettings('DEFAULT_TYPE', cbDefType.Text);
    SetInfoSettingsInt('REPORTS_TYPE', rgDefaultReport.itemindex);
    SetInfoSettingsInt('REPORTS_FILTER', cbRepGroup.itemindex);
    SetInfoSettingsInt('REPORTS_LIMIT', cbItemLimit.itemindex);
    SetInfoSettings('REPORTS_ACCOUNT', cbRepAccounts.Text);
    SetInfoSettingsBool('BACKUP_STARTUP', cbStartupBackup.Checked);
    SetInfoSettingsBool('BACKUP_EXIT', cbBackupExit.Checked);
    SetInfoSettingsInt('BACKUP_MAX', seMaxBackup.Value);
    SetInfoSettingsInt('FINANCIAL_YEAR_START_DAY', seStartDay.Value);
    SetInfoSettingsInt('FINANCIAL_YEAR_START_MONTH', cbStartMonth.ItemIndex + 1);
    SetInfoSettingsInt('FINANCIAL_DECIMAL_PLACES', seDecPlaces.Value);
    SetInfoSettings('FINANCIAL_CURRENCY_SYMBOL', eCurrencySymbol.Text);
    SetInfoSettings('DATEFORMAT', cbDisplayDateFormat.Text);
    SetInfoSettings('USERNAME', eUserName.Text);
    SetInfoSettings('PASSWORD', EncodedPassword);
    SetInfoSettingsBool('SHOW_DATABASELOCATION', cbShowLocationCaption.Checked);
    SetInfoSettingsInt('TOOLBAR_POSITION', rgToolbarPosition.itemindex);
    SetInfoSettingsBool('MOUSE_OVER', cbMouseOver.Checked);
    SetInfoSettingsBool('TOOLBAR_CAPTIONS', cbToolbarCaptions.Checked);
    SetInfoSettings('DEFAULT_BUDGET_TYPE', cbDefBudgetType.Text);
    SetInfoSettings('DEFAULT_BUDGET_FREQUENCY', cbDefBudgetFrequency.Text);
    zcDatabaseConnection.Password := edDatabasePassword.Text;
  end;
  frMain.ShowDatabaseLocation;
  dmdata.SetToolbarPositions(rgToolbarPosition.itemindex);
  frMain.ToggleToolbarCaptions(cbToolbarCaptions.Checked);
  dmdata.SetupCurrencyValues;
end;


procedure TfrOptions.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if modalresult = mrOk then
    SaveSettings;
end;

procedure TfrOptions.cbDisplayDateFormatChange(Sender: TObject);
begin
  lbDate.Caption := FormatDateTime(cbDisplayDateFormat.Text, now);
end;

procedure TfrOptions.cdbChartBackClick(Sender: TObject);
begin
  ColorDialog1.Color := cdbChartBack.Color;
  if ColorDialog1.Execute then
    cdbChartBack.Color:= ColorDialog1.Color;
end;

procedure TfrOptions.cdbExpensesClick(Sender: TObject);
begin
  ColorDialog1.Color := cdbExpenses.Color;
  if ColorDialog1.Execute then
    cdbExpenses.Color:= ColorDialog1.Color;
end;

procedure TfrOptions.cdbIncomeClick(Sender: TObject);
begin
  ColorDialog1.Color := cdbIncome.Color;
  if ColorDialog1.Execute then
    cdbIncome.Color:= ColorDialog1.Color;
end;

procedure TfrOptions.cdbListBackgroundClick(Sender: TObject);
begin
  ColorDialog1.Color := cdbListBackground.Color;
  if ColorDialog1.Execute then
    cdbListBackground.Color:= ColorDialog1.Color;
end;

procedure TfrOptions.cdbListRow0Click(Sender: TObject);
begin
  ColorDialog1.Color := cdbListRow0.Color;
  if ColorDialog1.Execute then
    cdbListRow0.Color:= ColorDialog1.Color;
end;

procedure TfrOptions.cdbListRow1Click(Sender: TObject);
begin
  ColorDialog1.Color := cdbListRow1.Color;
  if ColorDialog1.Execute then
    cdbListRow1.Color:= ColorDialog1.Color;
end;

procedure TfrOptions.cdbNavTreeClick(Sender: TObject);
begin
  ColorDialog1.Color := cdbNavTree.Color;
  if ColorDialog1.Execute then
    cdbNavTree.Color:= ColorDialog1.Color;
end;

procedure TfrOptions.bResetDefaultsClick(Sender: TObject);
begin
  cdbListRow1.Color := StringToColor('$00F5E9E2');
  cdbListRow0.Color := clWindow;
  cdbListBackground.Color := clWindow;
  cdbNavTree.Color := clWindow;
  cdbChartBack.Color := clBtnFace;
  //add prompt option to reset category colours
end;

procedure TfrOptions.FormShow(Sender: TObject);
//var i : integer;
begin
  LoadSettings;
  nbOptions.PageIndex:= 0;
end;

procedure TfrOptions.tvOptionsChange(Sender: TObject; Node: TTreeNode);
var parentNode : TTreeNode;
begin
  if not assigned(Node) then exit;

  parentNode := Node.Parent;
  if Assigned(parentNode) then
  begin
    while Assigned(parentNode.Parent) do
      parentNode := parentNode.Parent;
    nbOptions.PageIndex := ParentNode.Index;
  end else
    nbOptions.PageIndex:= Node.Index;
end;



end.

