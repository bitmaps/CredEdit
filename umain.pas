{
Project started: 28/03/2014

To do list:

1. Help
2. Fix date order bys in grids (bank accounts grid).
3. Add encryption to database tables
4. Tidy up charts:
   Pie chart crashes when income and expenses values are both 0.
   Zoom in/out option.
5. Homepage:
   List bank accounts with reconciled balances against actual balances
   List assets totals
6. Have an app settings table, use this instead of inifiles
7. MRU file option: recent database files, clear recent list.
8. Add a welcome screen to ask user:
     i. Open last database
    ii. Create a new database
   iii. Open an existing database
    iv. Read documentation
     v. Visit website
    vi. Show this display next time app starts
   vii. Add option to display this screen from Help menu
9. Add a tips screen on bootup
10. Option to show full trans details on budgets (this will show transactions under each category).
11. Add report date drop to report toolbar / replace items in navigation tree.
    Add option to build own saved queries. Have them show in the navigation tree.
    Similar setup to transaction filter.
12. When deleting currently selected budget, refresh screen
13. Need to calculate balances with initial bank balance if no records exist
14. Add button to Payees tab to reallocate payees
15. Would be nice to have CreateCalendarBar use word wrapping on formsize
16. Navigation Tree popup doesnt work on the 2nd attempt if still on same node
17. Only sort grids with left mouse button click on title bar / exclude right mouse button
18. Add an F1 hotkey which will display a section of the help file based on the current screen (window / tab)
}

unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TATools, TASources, TASeries, TAStyles,
  Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls, Menus, ExtDlgs,
  DBGrids, StdCtrls, Grids, DbCtrls, Buttons, inifiles, ShellApi, db,
  TARadialSeries, TALegend, TACustomSeries, PrintersDlgs, dateutils, OSPrinters,
  {TAPrint,} Printers, {PopupNotifier,} ZDataset, math, windows;

type

  { TfrMain }
  PAccountRec = ^TAccountRec;
  TAccountRec = record
    AccountID: integer;
    AccountName: string;
    AccountType: string;
    InitialBal : Real;
  end;

  PBudgetYearRec = ^TBudgetYearRec;
  TBudgetYearRec = record
    BudgetAccount : string;
    BudgetYearID: integer;
    BudgetYearName: string;
    BudgetFrequency: string;
    EstimatedIncome: Float;
    EstimatedExpenses: Float;
    ActualIncome: Float;
    ActualExpenses: Float;
    FromDate : String;
    ToDate : string;
  end;


  TfrMain = class(TForm)
    bAssetsDelete: TSpeedButton;
    bAssetsEdit: TSpeedButton;
    bAssetsNew: TSpeedButton;
    bBarChart: TSpeedButton;
    bBnkAccDelete: TSpeedButton;
    bBnkAccDupe: TSpeedButton;
    bBnkAccExport: TSpeedButton;
    bBnkAccEdit: TSpeedButton;
    bAssetsExport: TSpeedButton;
    bBnkAccNew: TSpeedButton;
    bBudgetEditor: TSpeedButton;
    bFilter: TSpeedButton;
    bPayeesExport: TSpeedButton;
    bDefaultCategory: TSpeedButton;
    bPayeesDelete: TSpeedButton;
    bPayeesEdit: TSpeedButton;
    bRepTransExport: TSpeedButton;
    bPayeesNew: TSpeedButton;
    bPieChart: TSpeedButton;
    bRepTransDelete: TSpeedButton;
    bRepTransEdit: TSpeedButton;
    bRepTransEnter: TSpeedButton;
    bBudgetExport: TSpeedButton;
    bRepTransNew: TSpeedButton;
    bRepTransSkip: TSpeedButton;
    bTestError: TButton;
    Button1: TButton;
    Button2: TButton;
    cbBudgetFilterList: TComboBox;
    cbFilterList: TComboBox;
    cbItemLimit: TComboBox;
    cbPayeeFilterList: TComboBox;
    cbRepAccounts: TComboBox;
    cbRepGroup: TComboBox;
    cbRepTransFilter: TComboBox;
    dbgBankAccount: TDBGrid;
    dbgPayees: TDBGrid;
    HomePageBarChart2: TChart;
    HomepageBarChart1: TChart;
    HomepageBarChartBarSeries2: TBarSeries;
    HomepageBarChartBarSeries1: TBarSeries;
    CalendarDialog1: TCalendarDialog;
    dbgRepTrans: TDBGrid;
    dbgUpcomingTrans: TDBGrid;
    gbCalendar: TGroupBox;
    gbBudgetDetails: TGroupBox;
    gbReport1: TGroupBox;
    gbReport2: TGroupBox;
    gbRepeatingTransactions: TGroupBox;
    lAccountBalance: TLabel;
    lBudTotalDescription: TLabel;
    lBudExpActualTotal: TLabel;
    lBudActualTotals: TLabel;
    lBudExpDifferencelTotal: TLabel;
    lBudExpEstimatedTotal: TLabel;
    lBudEstimatedTotals: TLabel;
    lBudExpHeader1: TLabel;
    lBudExpHeader2: TLabel;
    lBudIncActualTotal: TLabel;
    lBudIncDifferencelTotal: TLabel;
    lBudIncEstimatedTotal: TLabel;
    lBudIncHeader: TLabel;
    lBudIncHeader1: TLabel;
    lBudIncHeader2: TLabel;
    lBudIncHeader3: TLabel;
    lcsBottomAxisValues: TListChartSource;
    lcsBottomAxisValues1: TListChartSource;
    lcsBottomAxisValues2: TListChartSource;
    lcsChartValues1: TListChartSource;
    lcsChartValues2: TListChartSource;
    lcsLeftAxisValues1: TListChartSource;
    lcsLeftAxisValues2: TListChartSource;
    lDifferenceBalance: TLabel;
    lReconciledBalance: TLabel;
    miGridsPrint: TMenuItem;
    miEmptyTables: TMenuItem;
    miBankSplit3: TMenuItem;
    miBankEditBudgetEditor: TMenuItem;
    miBankSplit2: TMenuItem;
    miBankEditBudget: TMenuItem;
    miBankDeleteBudget: TMenuItem;
    miViewToolbarCaptions: TMenuItem;
    miUpdateCategories: TMenuItem;
    miGridsSkip: TMenuItem;
    miGridsEnter: TMenuItem;
    miBudgetEditor: TMenuItem;
    miReportsPrintCanvas: TMenuItem;
    miReportsPrint: TMenuItem;
    miReportsClipboard: TMenuItem;
    miReportsExport: TMenuItem;
    rgBankDetails: TGroupBox;
    PieChart: TChart;
    PieChartPieSeries1: TPieSeries;
    BarChart: TChart;
    BarChartBarSeries1: TBarSeries;
    ChartStyles1: TChartStyles;
    ChartToolset1: TChartToolset;
    ChartToolset1DataPointHintTool1: TDataPointHintTool;
    ChartToolset1ZoomDragTool1: TZoomDragTool;
    ChartToolset1ZoomMouseWheelTool1: TZoomMouseWheelTool;
    dbgAssets: TDBGrid;
    gbReport: TGroupBox;
    ImageList1: TImageList;
    lcsChartValues: TListChartSource;
    lcsLeftAxisValues: TListChartSource;
    lcsPieChartValues: TListChartSource;
    lcsPieLabels: TListChartSource;
    MainMenu: TMainMenu;
    miGridsSpacer: TMenuItem;
    miGridsDefCat: TMenuItem;
    miGridsDupe: TMenuItem;
    miGridsExport: TMenuItem;
    miGridsDelete: TMenuItem;
    miGridsEdit: TMenuItem;
    miGridsNew: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    miBankSplit1: TMenuItem;
    MenuItem6: TMenuItem;
    miRelocatePayees: TMenuItem;
    miRelocateCategories: TMenuItem;
    miRelocationOf: TMenuItem;
    miViewHeaders: TMenuItem;
    miSQLLog: TMenuItem;
    miBankWebsite: TMenuItem;
    miBankDeleteAccount: TMenuItem;
    miBankEditAccount: TMenuItem;
    miNewTransaction: TMenuItem;
    miOpenDatabase: TMenuItem;
    miOrgPayees: TMenuItem;
    miOrgCurrency: TMenuItem;
    miAssets: TMenuItem;
    miTransRepFilter: TMenuItem;
    miOptions: TMenuItem;
    miHelpFile: TMenuItem;
    miViewNavigation: TMenuItem;
    miViewBankAccounts: TMenuItem;
    miViewStockAccounts: TMenuItem;
    miSaveDatabaseAs: TMenuItem;
    MenuItem20: TMenuItem;
    miExportCSV: TMenuItem;
    MenuItem22: TMenuItem;
    miImportCSV: TMenuItem;
    miExit: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    miEditAccount: TMenuItem;
    miDeleteAccount: TMenuItem;
    miFile: TMenuItem;
    miAbout: TMenuItem;
    miAccounts: TMenuItem;
    miTools: TMenuItem;
    miView: TMenuItem;
    miHelp: TMenuItem;
    miNewDatabase: TMenuItem;
    miNewAccount: TMenuItem;
    miOrgCatagories: TMenuItem;
    miViewToolbar: TMenuItem;
    odOpenDatabase: TOpenDialog;
    pmReports: TPopupMenu;
    PrintDialog: TPrintDialog;
    PrinterSetupDialog: TPrinterSetupDialog;
    pcNavigation: TPageControl;
    pmGrids: TPopupMenu;
    pmBank: TPopupMenu;
    spdReports: TSavePictureDialog;
    sdGridExport: TSaveDialog;
    sdSaveDialog: TSaveDialog;
    sdNewDatabase: TSaveDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    splitMain: TSplitter;
    splitHomeBottom: TSplitter;
    splitHomeMiddle: TSplitter;
    StatusBar1: TStatusBar;
    sgBudget: TStringGrid;
    tbNewAccount: TToolButton;
    tbNewDatabase: TToolButton;
    tbNewTransaction: TToolButton;
    tbOpenDatabase: TToolButton;
    tbOptionsDialog: TToolButton;
    tbOrgCatDialog: TToolButton;
    tbOrgCurrDialog: TToolButton;
    tbOrgPayeesDialog: TToolButton;
    tbTransRepFilter: TToolButton;
    tbMain: TToolBar;
    tbBankAccounts: TToolBar;
    tbAssets: TToolBar;
    tbPayees: TToolBar;
    tbRepTrans: TToolBar;
    tbReports: TToolBar;
    Timer1: TTimer;
    tbBudgets: TToolBar;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton2: TToolButton;
    tbBudgetEditor: TToolButton;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
    ToolButton23: TToolButton;
    ToolButton24: TToolButton;
    ToolButton25: TToolButton;
    ToolButton26: TToolButton;
    ToolButton27: TToolButton;
    ToolButton28: TToolButton;
    ToolButton29: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    tsAssets: TTabSheet;
    tsBankAccounts: TTabSheet;
    tsBudgets: TTabSheet;
    tsHomePage: TTabSheet;
    tsPayees: TTabSheet;
    tsRepeatingTransactions: TTabSheet;
    tsReports: TTabSheet;
    tvNavigation: TTreeView;
    procedure ApplicationProperties1Hint(Sender: TObject);
    procedure ApplicationPropertiesException(Sender: TObject; E: Exception);
    procedure bAssetsDeleteClick(Sender: TObject);
    procedure bAssetsDeleteMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bAssetsEditClick(Sender: TObject);
    procedure bAssetsEditMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bAssetsExportMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bAssetsNewClick(Sender: TObject);
    procedure bAssetsNewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bBarChartClick(Sender: TObject);
    procedure bBarChartMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bBnkAccDeleteClick(Sender: TObject);
    procedure bBnkAccDeleteMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bBnkAccDupeClick(Sender: TObject);
    procedure bBnkAccDupeMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bBnkAccEditClick(Sender: TObject);
    procedure bBnkAccEditMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bBnkAccExportMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bBnkAccNewClick(Sender: TObject);
    procedure bBnkAccNewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bBudgetEditorMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bBudgetExportMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bDefaultCategoryClick(Sender: TObject);
    procedure bDefaultCategoryMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bFilterClick(Sender: TObject);
    procedure bFilterMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bPayeesDeleteClick(Sender: TObject);
    procedure bPayeesDeleteMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bPayeesEditClick(Sender: TObject);
    procedure bPayeesEditMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bPieChartMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bRepTransExportMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bPayeesExportMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bPayeesNewClick(Sender: TObject);
    procedure bPayeesNewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bPieChartClick(Sender: TObject);
    procedure bRepTransDeleteClick(Sender: TObject);
    procedure bRepTransDeleteMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bRepTransEditClick(Sender: TObject);
    procedure bRepTransEditMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bRepTransEnterClick(Sender: TObject);
    procedure bRepTransEnterMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bRepTransNewClick(Sender: TObject);
    procedure bRepTransNewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bRepTransSkipClick(Sender: TObject);
    procedure bRepTransSkipMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bTestErrorClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbBudgetFilterListChange(Sender: TObject);
    procedure cbFilterListChange(Sender: TObject);
    procedure cbItemLimitChange(Sender: TObject);
    procedure cbPayeeFilterListChange(Sender: TObject);
    procedure cbRepAccountsChange(Sender: TObject);
    procedure cbRepGroupChange(Sender: TObject);
    procedure cbRepTransFilterChange(Sender: TObject);
    procedure dbgAssetsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure dbgAssetsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dbgBankAccountColumnMoved(Sender: TObject; FromIndex,
      ToIndex: Integer);
    procedure dbgBankAccountColumnSized(Sender: TObject);
    procedure dbgBankAccountMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure dbgBankAccountMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dbgPayeesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure dbgPayeesMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dbgPayeesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure dbgRepTransMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure dbgRepTransMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dbgRepTransTitleClick(Column: TColumn);
    procedure dbgUpcomingTransMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure dbgUpcomingTransMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormShowHint(Sender: TObject; HintInfo: PHintInfo);
    procedure miBankDeleteBudgetClick(Sender: TObject);
    procedure miBankEditBudgetClick(Sender: TObject);
    procedure miBudgetEditorClick(Sender: TObject);
    procedure miEmptyTablesClick(Sender: TObject);
    procedure miGridsEnterClick(Sender: TObject);
    procedure miGridsExportClick(Sender: TObject);
    procedure miGridsPrintClick(Sender: TObject);
    procedure miGridsSkipClick(Sender: TObject);
    procedure miReportsClipboardClick(Sender: TObject);
    procedure miReportsExportClick(Sender: TObject);
    procedure miReportsPrintClick(Sender: TObject);
    procedure miTransRepFilterClick(Sender: TObject);
    procedure miUpdateCategoriesClick(Sender: TObject);
    procedure miViewBankAccountsClick(Sender: TObject);
    procedure miViewToolbarCaptionsClick(Sender: TObject);
    procedure pcNavigationChange(Sender: TObject);
    procedure PieChartMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure dbgAssetsTitleClick(Column: TColumn);
    procedure dbgBankAccountTitleClick(Column: TColumn);
    procedure dbgPayeesTitleClick(Column: TColumn);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miAccountListClick(Sender: TObject);
    procedure miAssetsClick(Sender: TObject);
    procedure miBankWebsiteClick(Sender: TObject);
    procedure miDeleteAccountClick(Sender: TObject);
    procedure miEditAccountClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miGridsDefCatClick(Sender: TObject);
    procedure miGridsDeleteClick(Sender: TObject);
    procedure miGridsDupeClick(Sender: TObject);
    procedure miGridsEditClick(Sender: TObject);
    procedure miGridsNewClick(Sender: TObject);
    procedure miImportCSVClick(Sender: TObject);
    procedure miNewAccountClick(Sender: TObject);
    procedure miNewDatabaseClick(Sender: TObject);
    procedure miOpenDatabaseClick(Sender: TObject);
    procedure miOptionsClick(Sender: TObject);
    procedure miOrgCatagoriesClick(Sender: TObject);
    procedure miOrgPayeesClick(Sender: TObject);
    procedure miRelocateCategoriesClick(Sender: TObject);
    procedure miRelocatePayeesClick(Sender: TObject);
    procedure miSaveDatabaseAsClick(Sender: TObject);
    procedure miSQLLogClick(Sender: TObject);
    procedure miViewHeadersClick(Sender: TObject);
    procedure miViewNavigationClick(Sender: TObject);
    procedure miViewSQLLogClick(Sender: TObject);
    procedure miViewToolbarClick(Sender: TObject);
    procedure pmBankPopup(Sender: TObject);
    procedure pmBudgetsPopup(Sender: TObject);
    procedure pmGridsPopup(Sender: TObject);
    procedure rgBankDetailsClick(Sender: TObject);
    procedure sgBudgetDblClick(Sender: TObject);
    procedure sgBudgetDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StatusBar1Hint(Sender: TObject);
    procedure tbBudgetEditorMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tbNewAccountMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tbNewDatabaseMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tbNewTransactionMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tbOpenDatabaseMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tbOptionsDialogClick(Sender: TObject);
    procedure tbOptionsDialogMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tbOrgCatDialogMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tbOrgCurrDialogMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tbOrgPayeesDialogMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure tbShowAccountListClick(Sender: TObject);
    procedure tbTransRepFilterClick(Sender: TObject);
    procedure tbTransRepFilterMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure tsAssetsShow(Sender: TObject);
    procedure tsBankAccountsShow(Sender: TObject);
    procedure tsBudgetsShow(Sender: TObject);
    procedure tsHomePageShow(Sender: TObject);
    procedure tsPayeesShow(Sender: TObject);
    procedure tsRepeatingTransactionsShow(Sender: TObject);
    procedure tsReportsShow(Sender: TObject);
    procedure tvNavigationChange(Sender: TObject; Node: TTreeNode);
    procedure tvNavigationClick(Sender: TObject);
    procedure AutoSizeCol(Grid: TStringGrid; Column: integer);
    procedure tvNavigationDeletion(Sender: TObject; Node: TTreeNode);
    procedure tvNavigationMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpdateGridColours(Colour1, Colour2 : TColor);
    procedure CreateCalendarBar(GroupBox : TGroupBox);
    procedure DumpExceptionCallStack(E: Exception);
    procedure CustomExceptionHandler(Sender: TObject; E: Exception);
    procedure DisplayUpcomingTransactionsGrid;
    procedure ToggleToolbarCaptions(Toggle : Boolean);
    procedure pmBankPopupMode(Toggle : Boolean);
    procedure LoadSettings;
    procedure LoadDatabaseSettings;
    procedure SaveSettings;
    procedure DisplayBankAccountsGrid;
    procedure DisplayRepeatingTransactionsGrid;
    procedure CreateBankAccountItems;
    procedure CreateBudgetSetupItems;
    procedure GotoHomepage;
    procedure DisplayAssetsGrid;
    procedure ShowDatabaseLocation;
    procedure PopulateBudgetsGrid;
    procedure UpdateStatusBarText;
    procedure DisplayPayeesGrid;
    procedure tbMouseMove(ToolButton : TToolButton);
    procedure sbMouseMove(SpeedButton : TSpeedButton);
    procedure dbgMouseMove(DBGrid : TDBGrid; X, Y: Integer);
    procedure dbgMouseDown(DBGrid : TDBGrid; X, Y: Integer);
    procedure SetBudgetFilter(ACol:Integer;FilterExp:String);
    procedure RestoreBudgetFilter;
  private
    { private declarations }
  public
    { public declarations }
    DefaultReportType, LastReportType, DecimalPlaces : integer;
    TransRepPayeeFilter, TransRepDateFilter, TransRepCatFilter, TransAmountFilter,
    TransTypeFilter, DecimalPlacesStr, FullDecimalPlacesStr, CurrencySymbol : string;
{    FilterList : TStringList;}
  end;

var
  frMain: TfrMain;
  BankAccountSort,
  AssetSort,
  PayeeSort,
  RepTransSort,
  Login: string;


implementation

{$R *.lfm}

{ TfrMain }

uses uAccountWizard, uOrganiseCategories, uAccount, uAbout, uNewTransaction,
  uAsset, uOptions, uOrganisePayees,uDataModule, uImportWizard,
  uRelocateCategory, uSQLLog, uRelocatePayee, uReportFuncs, uBudgetEntry,
  uBudgetEditor, uTransactionFilter, uTransFiltersList, uBudget,
  uErrorDialog, uRepeatingTransaction, uEmptyTables{, uProgressBar};

procedure TfrMain.LoadDatabaseSettings;
var IniFile : TIniFile;
begin
  IniFile := TIniFile.create(ExtractFilePath(application.exename)+'settings.ini');
  try
    dmData.DatabaseLocation := IniFile.ReadString('Database', 'DatabaseLocation', ExtractFilePath(application.exename)+DefaultDBFileName+dbExt);
    frMain.Width := IniFile.ReadInteger('Configuration', 'WindowWidth', 770);
    frMain.Height := IniFile.ReadInteger('Configuration', 'WindowHeight', 630 );
    frMain.Left := IniFile.ReadInteger('Configuration', 'WindowLeft', 388);
    frMain.Top := IniFile.ReadInteger('Configuration', 'WindowTop', 218);
    miViewToolbar.Checked := IniFile.ReadBool('Configuration', 'MainToolbar', True);
    miViewToolbarCaptions.Checked := IniFile.ReadBool('Configuration', 'MainToolbarCaptions', True);
    miViewNavigation.Checked := IniFile.ReadBool('Configuration', 'Navigation', True);
    miViewHeaders.Checked := IniFile.ReadBool('Configuration', 'Headers', True);
    miSQLLog.Checked := IniFile.ReadBool('Configuration', 'EnableSQLLog', False);
    tvNavigation.Width := IniFile.ReadInteger('Configuration', 'SplitMain', 164);
    gbReport1.Width := IniFile.ReadInteger('Configuration', 'splitHomeMiddle', 250);
    gbRepeatingTransactions.Height := IniFile.ReadInteger('Configuration', 'splitHomeBottom', 180);
  finally
    IniFile.Free;
  end;
end;

procedure TfrMain.LoadSettings;
var Colour1, Colour2 : TColor;
begin
  odOpenDatabase.DefaultExt:= dbExt;
  odOpenDatabase.Filter:= 'Database Files (*'+dbExt+')|*'+dbExt;
  sdSaveDialog.DefaultExt := odOpenDatabase.DefaultExt;
  sdSaveDialog.Filter := odOpenDatabase.Filter;
  sdNewDatabase.DefaultExt := odOpenDatabase.DefaultExt;
  sdNewDatabase.Filter := odOpenDatabase.Filter;

  dmData.MouseOver := dmData.GetInfoSettingsBool('MOUSE_OVER', True);
  dmData.StartupBackup := dmData.GetInfoSettingsBool('BACKUP_STARTUP', False);
  dmData.ExitBackup := dmData.GetInfoSettingsBool('BACKUP_EXIT', False);
  Colour2 := StringToColor(dmData.GetInfoSettings('COLOURS_LISTROW1', '$00F5E9E2'));
  Colour1 := StringToColor(dmData.GetInfoSettings('COLOURS_LISTROW0', 'clWindow'));
  tvNavigation.BackgroundColor := StringToColor(dmData.GetInfoSettings('COLOURS_NAVTREE', 'clWindow'));
  PieChart.BackColor:= StringToColor(dmData.GetInfoSettings('COLOURS_CHARTBACKGROUND', 'clBtnFace'));
  BarChart.BackColor:= StringToColor(dmData.GetInfoSettings('COLOURS_CHARTBACKGROUND', 'clBtnFace'));
  cbRepGroup.itemindex := dmdata.GetInfoSettingsInt('REPORTS_FILTER', 0);
  cbItemLimit.itemindex := dmdata.GetInfoSettingsInt('REPORTS_LIMIT', 0);
  dmData.DisplayDateFormat := dmData.GetInfoSettings('DATEFORMAT', 'YYYY-MM-DD');
  dmdata.SetToolbarPositions(dmdata.GetInfoSettingsInt('TOOLBAR_POSITION', 0));

  UpdateGridColours(Colour1, Colour2);
  dmData.zcDatabaseConnection.Database:= dmData.DatabaseLocation;
  dmData.ZSQLMonitor.Active:= miSQLLog.Checked;
  dmData.DebugMode := miSQLLog.Checked;
  tbMain.Visible:= miViewToolbar.Checked;
  tvNavigation.Visible:= miViewNavigation.Checked;
  pcNavigation.ShowTabs:= miViewHeaders.Checked;

  miViewToolbarCaptions.Checked := dmdata.GetInfoSettingsBool('TOOLBAR_CAPTIONS', False);
  ToggleToolbarCaptions(miViewToolbarCaptions.Checked);

  //Rowlines on
  //dbgBankAccount.Options := [dgTitles,dgIndicator,dgColumnResize,dgColumnMove,dgColLines,dgRowLines,dgTabs,dgRowSelect,dgAlwaysShowSelection,dgConfirmDelete,dgCancelOnExit,dgAutoSizeColumns,dgDisableDelete,dgDisableInsert,dgTruncCellHints,dgCellEllipsis];
  //Rowlines off
  dbgBankAccount.Options := [dgAnyButtonCanSelect, dgTitles,dgIndicator,dgColumnResize,dgColumnMove,dgColLines,dgRowSelect,dgAlwaysShowSelection,dgConfirmDelete,dgCancelOnExit,dgAutoSizeColumns,dgDisableDelete,dgDisableInsert,dgTruncCellHints,dgCellEllipsis];
  dbgAssets.Options := dbgBankAccount.Options;
  dbgPayees.Options := dbgBankAccount.Options;
  dbgRepTrans.Options := dbgBankAccount.Options;
  dbgUpcomingTrans.Options := dbgBankAccount.Options;

  miEmptyTables.Visible:= dmData.DebugMode;

  ShowDatabaseLocation;

  if dmData.StartupBackup then
    dmData.BackupDatabase('startup');
end;

procedure TfrMain.SaveSettings;
var IniFile : TIniFile;
begin
  IniFile := TIniFile.create(ExtractFilePath(application.exename)+'settings.ini');
  try
    IniFile.WriteString('Database', 'DatabaseLocation', dmData.DatabaseLocation);
    IniFile.WriteBool('Configuration', 'EnableSQLLog', miSQLLog.Checked);
    IniFile.WriteBool('Configuration', 'MainToolbar', miViewToolbar.Checked);
    IniFile.WriteBool('Configuration', 'MainToolbarCaptions', miViewToolbarCaptions.Checked);
    IniFile.WriteBool('Configuration', 'Navigation', miViewNavigation.Checked);
    IniFile.WriteBool('Configuration', 'Headers', miViewHeaders.Checked);
    IniFile.WriteInteger('Configuration', 'WindowWidth', frMain.Width);
    IniFile.WriteInteger('Configuration', 'WindowHeight', frMain.Height);
    IniFile.WriteInteger('Configuration', 'WindowLeft', frMain.Left);
    IniFile.WriteInteger('Configuration', 'WindowTop', frMain.Top);
    IniFile.WriteInteger('Configuration', 'SplitMain', tvNavigation.Width);
    IniFile.WriteInteger('Configuration', 'splitHomeMiddle', gbReport1.Width);
    IniFile.WriteInteger('Configuration', 'splitHomeBottom', gbRepeatingTransactions.Height);
  finally
    IniFile.Free;
  end;

  if dmdata.zqBankAccounts.Active then
    dmdata.SaveGridLayout(dbgBankAccount);
  if dmdata.zqAssets.Active then
    dmdata.SaveGridLayout(dbgAssets);
  if dmdata.zqPayee.Active then
    dmdata.SaveGridLayout(dbgPayees);
  if dmdata.zqRepeatTransactions.Active then
    dmdata.SaveGridLayout(dbgRepTrans);
  if dmdata.zqUpcomingTrans.Active then
    dmdata.SaveGridLayout(dbgUpcomingTrans);

  if (frSQLLog <> nil) then frSQLLog.SaveSettings;
end;

procedure TfrMain.miImportCSVClick(Sender: TObject);
begin
  try
    frImportWizard := TfrImportWizard.create(self);
    frImportWizard.Showmodal;
  finally
    frImportWizard.Free;
  end;
end;

procedure TfrMain.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrMain.miGridsDefCatClick(Sender: TObject);
begin
  case pcNavigation.PageIndex of
    pgPayees : bDefaultCategory.Click;
  end;
end;

procedure TfrMain.miGridsDeleteClick(Sender: TObject);
begin
  case pcNavigation.PageIndex of
    pgBankAccs : bBnkAccDelete.Click;
    pgAssets : bAssetsDelete.Click;
    pgPayees : bPayeesDelete.Click;
    pgRepTrans : bRepTransDelete.Click;
  end;
end;

procedure TfrMain.miGridsDupeClick(Sender: TObject);
begin
  case pcNavigation.PageIndex of
    pgBankAccs : bBnkAccDupe.Click;
  end;
end;

procedure TfrMain.miGridsEditClick(Sender: TObject);
begin
  case pcNavigation.PageIndex of
    pgBankAccs : bBnkAccEdit.Click;
    pgAssets : bAssetsEdit.Click;
    pgPayees : bPayeesEdit.Click;
    pgRepTrans : bRepTransEdit.Click;
  end;
end;

procedure TfrMain.miGridsNewClick(Sender: TObject);
begin
  case pcNavigation.PageIndex of
    pgBankAccs : bBnkAccNew.Click;
    pgAssets : bAssetsNew.Click;
    pgPayees : bPayeesNew.Click;
    pgRepTrans : bRepTransNew.Click;
  end;
end;

procedure TfrMain.GotoHomepage;
var ParentNode : TTreenode;
begin
{  ParentNode := GetNodeByText(tvNavigation, 'Reports', false);
  if ParentNode = nil then
    ShowMessage('Not found!')
  else
    begin
      ParentNode.Selected := True;
      ParentNode.Expanded:= False;
    end;}

  ParentNode := dmData.GetNodeByText(tvNavigation, 'Homepage', false);
  if ParentNode = nil then
    ShowMessage('Not found!')
  else
    ParentNode.Selected := True;
end;

procedure TfrMain.DumpExceptionCallStack(E: Exception);
var
  I: Integer;
  Frames: PPointer;
  Report: string;
begin
{  Report := 'Program exception! ' + LineEnding +
    'Stacktrace:' + LineEnding + LineEnding;}
  if E <> nil then
  begin
    Report := Report + 'Exception class: ' + E.ClassName + LineEnding +
    'Message: ' + E.Message + LineEnding;
  end;
  Report := Report + BackTraceStrFunc(ExceptAddr);
  Frames := ExceptFrames;
  for I := 0 to ExceptFrameCount - 1 do
    Report := Report + LineEnding + BackTraceStrFunc(Frames[I]);
  //ShowMessage(Report);
  frErrorDialog.ShowMessage(Report);
//  Halt; // End of program execution
end;

procedure TfrMain.CustomExceptionHandler(Sender: TObject; E: Exception);
begin
  DumpExceptionCallStack(E);
//  Halt; // End of program execution
end;

procedure TfrMain.FormCreate(Sender: TObject);
begin
   GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, fs) ;   //grab system formatting settings
{ sysutils
  CurrencyFormat:=StrToIntDef(GetLocaleStr(LID, LOCALE_ICURRENCY, '0'), 0);
  NegCurrFormat:=StrToIntDef(GetLocaleStr(LID, LOCALE_INEGCURR, '0'), 0);
  ThousandSeparator:=GetLocaleChar(LID, LOCALE_STHOUSAND, ',');
  DecimalSeparator:=GetLocaleChar(LID, LOCALE_SDECIMAL, '.');
  CurrencyDecimals:=StrToIntDef(GetLocaleStr(LID, LOCALE_ICURRDIGITS, '0'), 0);}
//  Application.OnException := @CustomExceptionHandler;
  Randomize;
  frMain.Caption:= ApplicationName;
  dmData := TdmData.create(self);
  LoadDatabaseSettings;
  dmData.OpenDatabaseTables(True);
  loadsettings;
  //  OpenDatabase;
  CreateBankAccountItems;
  CreateBudgetSetupItems;
  dmData.SetupCurrencyValues;
  GotoHomepage;
  frTransactionFilter.ResetFilters;
//  CreateCalendarBar(gbCalendar);   //doesnt work on create, font width incorrect
end;

procedure TfrMain.FormShow(Sender: TObject);
begin
  CreateCalendarBar(gbCalendar);
  if miSQLLog.Checked then
    frSQLLog.Show
  else
    frSQLLog.Close;

  Timer1.Enabled:= True;
end;

procedure TfrMain.miAboutClick(Sender: TObject);
begin
  try
    frAbout := TfrAbout.create(self);
    frAbout.Showmodal;
  finally
    frAbout.Free;
  end;
end;

procedure TfrMain.miAccountListClick(Sender: TObject);
begin
  GotoHomepage;
end;

procedure TfrMain.miAssetsClick(Sender: TObject);
begin
  try
    frAsset := TfrAsset.create(self);
    frAsset.Showmodal;
  finally
    frAsset.Free;
  end;
end;

procedure TfrMain.miBankWebsiteClick(Sender: TObject);
var url : string;
begin
  if PAccountRec(tvNavigation.Selected.Data) = nil then exit;

  if dmData.ztAccountList.Locate('ACCOUNTID', PAccountRec(tvNavigation.Selected.Data)^.AccountID, [loCaseInsensitive]) = True then
  begin
    url := dmData.ztAccountList.FieldByName('WEBSITE').AsString;
    url := 'http://'+url;
    if url <> 'http://' then
      ShellExecute(0,nil, PChar(url),PChar(url),nil,0);
  end;
end;

procedure TfrMain.miDeleteAccountClick(Sender: TObject);
var MyAccountRec: PAccountRec;
begin
  if PAccountRec(tvNavigation.Selected.Data) = nil then exit;
  if MessageDlg('Are you sure you want to delete "'+PAccountRec(tvNavigation.Selected.Data)^.AccountName+ '" account and any relating transactions?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;
  dmData.DeleteDBRecord(dmData.ztAccountList.TableName, 'accountid', PAccountRec(tvNavigation.Selected.Data)^.AccountID);
  dmData.DeleteDBRecord(dmData.ztCheckingAccount.TableName, 'accountid', PAccountRec(tvNavigation.Selected.Data)^.AccountID);

  MyAccountRec := PAccountRec(tvNavigation.Selected.Data);
  tvNavigation.Items.Delete(tvNavigation.Selected);
  Dispose(MyAccountRec);
{  dmData.ztAccountList.Refresh;
  dmData.ztCheckingAccount.Refresh;}
  GotoHomepage;
end;

procedure TfrMain.miEditAccountClick(Sender: TObject);
var Node : TTreeNode;
begin
  if PAccountRec(tvNavigation.Selected.Data) = nil then exit;

  frAccount := TfrAccount.create(self);
  if dmData.ztAccountList.Locate('ACCOUNTID', PAccountRec(tvNavigation.Selected.Data)^.AccountID, [loCaseInsensitive]) = True then
  begin
    dmData.ztAccountList.Edit;
    frAccount.cbAccountType.Text:= dmData.ztAccountList.FieldByName('ACCOUNTTYPE').AsString;
    frAccount.cbAccountStatus.Text:= dmData.ztAccountList.FieldByName('STATUS').AsString;
    //
    if frAccount.Showmodal = mrOk then
    begin
      dmData.SaveChanges(dmData.ztAccountList, False);
      PAccountRec(tvNavigation.Selected.Data)^.AccountName:= dmData.ztAccountList.FieldByName('ACCOUNTNAME').AsString;
      PAccountRec(tvNavigation.Selected.Data)^.AccountType:= dmData.ztAccountList.FieldByName('ACCOUNTTYPE').AsString;
      PAccountRec(tvNavigation.Selected.Data)^.InitialBal := dmData.ztAccountList.FieldByName('INITIALBAL').AsCurrency;

      Node := tvNavigation.Selected;
      Node.Text:= PAccountRec(tvNavigation.Selected.Data)^.AccountName;
    end else
      dmData.ztAccountList.Cancel;

  end;
  frAccount.Free;
end;

procedure TfrMain.dbgAssetsTitleClick(Column: TColumn);
var i : integer;
  DateOrder{, ColumnSort} : string;
begin
  DateOrder := '';
  //reset sort image headers
  for i:= 0 to dbgAssets.Columns.Count-1 do
    dbgAssets.Columns.Items[i].Title.ImageIndex:=-1;

  if (Column.FieldName = dmData.zqAssets.SortedFields)
  or ((Column.FieldName = 'frmstartdate') and (dmData.zqAssets.SortedFields ='STARTDATE'))
  then
  begin
    if AssetSort = ' asc' then
    begin
      AssetSort := ' desc';
      Column.Title.ImageIndex:= 30;
    end
    else
      begin
        AssetSort := ' asc';
        Column.Title.ImageIndex:= 31;
      end;
  end else
  begin
    AssetSort := ' asc';
    Column.Title.ImageIndex:= 31;
  end;

//  dmData.zqAssets.SortedFields:= Column.FieldName;

  if Column.FieldName = 'frmstartdate' then
  begin
    dmData.zqAssets.SortedFields:= 'STARTDATE';
    dmData.zqAssets.IndexFieldNames := 'STARTDATE' + AssetSort ;
  end else
  begin
    dmData.zqAssets.SortedFields:= Column.FieldName;
    dmData.zqAssets.IndexFieldNames := Column.FieldName + AssetSort ;
  end;

end;

procedure TfrMain.dbgBankAccountTitleClick(Column: TColumn);
var i : integer;
  //DateOrder : string;
begin
  //reset sort image headers
  for i:= 0 to dbgBankAccount.Columns.Count-1 do
    dbgBankAccount.Columns.Items[i].Title.ImageIndex:=-1;

  if (Column.FieldName = dmData.zqBankAccounts.SortedFields)
  or ((Column.FieldName = 'frmtrandate') and (dmData.zqBankAccounts.SortedFields ='TRANSDATE'))
  then
  begin
    if BankAccountSort = ' asc' then
    begin
      BankAccountSort := ' desc';
      Column.Title.ImageIndex:= 30;
    end
    else
      begin
        BankAccountSort := ' asc';
        Column.Title.ImageIndex:= 31;
      end;
  end else
  begin
    BankAccountSort := ' asc';
    Column.Title.ImageIndex:= 31;
  end;

  dmData.zqBankAccounts.SortedFields:= Column.FieldName;

{  if Column.FieldName = 'frmtrandate' then
    DateOrder := ' , transid '
  else
    DateOrder := '';}

  if Column.FieldName = 'frmtrandate' then
  begin
    dmData.zqBankAccounts.SortedFields:= 'TRANSDATE';
    dmData.zqBankAccounts.IndexFieldNames := 'TRANSDATE' + BankAccountSort ;
  end else
  begin
    dmData.zqBankAccounts.SortedFields:= Column.FieldName;
    dmData.zqBankAccounts.IndexFieldNames := Column.FieldName + BankAccountSort ;
  end;
//  dmData.zqBankAccounts.IndexFieldNames := Column.FieldName + DateOrder + BankAccountSort ;
end;

procedure TfrMain.dbgPayeesTitleClick(Column: TColumn);
var i : integer;
begin
  for i:= 0 to dbgPayees.Columns.Count-1 do
    dbgPayees.Columns.Items[i].Title.ImageIndex:=-1;

  if Column.FieldName = dmData.zqPayee.SortedFields then
  begin
    if PayeeSort = ' asc' then
    begin
      PayeeSort := ' desc';
      Column.Title.ImageIndex:= 30;
    end
    else
      begin
        PayeeSort := ' asc';
        Column.Title.ImageIndex:= 31;
      end;
  end else
  begin
    PayeeSort := ' asc';
    Column.Title.ImageIndex:= 31;
  end;

  dmData.zqPayee.SortedFields:= Column.FieldName;
  dmData.zqPayee.IndexFieldNames := Column.FieldName + PayeeSort ;
end;

procedure TfrMain.AutoSizeCol(Grid: TStringGrid; Column: integer);
var
  i, W, WMax: integer;
begin
  WMax := 0;
  for i := 0 to (Grid.RowCount - 1) do begin
    W := Grid.Canvas.TextWidth(Grid.Cells[Column, i]);
    if W > WMax then
      WMax := W;
  end;
  Grid.ColWidths[Column] := WMax + 5;
end;

procedure TfrMain.bBnkAccEditClick(Sender: TObject);
var TmpDate : String;
begin
  try
    frNewTransaction := TfrNewTransaction.create(self);
    frNewTransaction.EditMode:= 'Edit';

    if dmData.ztCheckingAccount.Locate('TRANSID', dmData.zqBankAccounts.FieldByName('TRANSID').AsInteger, [loCaseInsensitive]) = True then
    begin
      TmpDate := dmData.ztCheckingAccount.FieldByName('TRANSDATE').AsString;
      TmpDate := StringReplace(TmpDate, '-', '/', [rfReplaceAll, rfIgnoreCase]);
      // select Replace(startdate, '-', '/') from checkingaccount_v1
      frNewTransaction.deDate.Text := TmpDate;
      dmData.ztCheckingAccount.Edit;
      frNewTransaction.cbType.Text:= dmData.ztCheckingAccount.FieldByName('TRANSCODE').AsString;

      if dmData.ztCheckingAccount.FieldByName('STATUS').AsString = 'N' then
        frNewTransaction.cbStatus.Text:= 'None' else
      if dmData.ztCheckingAccount.FieldByName('STATUS').AsString = 'R' then
        frNewTransaction.cbStatus.Text:= 'Reconciled' else
      if dmData.ztCheckingAccount.FieldByName('STATUS').AsString = 'V' then
        frNewTransaction.cbStatus.Text:= 'Void' else
      if dmData.ztCheckingAccount.FieldByName('STATUS').AsString = 'F' then
        frNewTransaction.cbStatus.Text:= 'Follow Up' else
      if dmData.ztCheckingAccount.FieldByName('STATUS').AsString = 'D' then
        frNewTransaction.cbStatus.Text:= 'Duplicate';

      //    frNewTransaction.cbStatus.Text:= frMain.ztCheckingAccount.FieldByName('STATUS').AsString;
  {    frNewTransaction.cbType.Enabled:= False;
      frNewTransaction.cbStatus.Enabled:= False;
      frNewTransaction.dblcbAccount.Enabled:= False;}
      if frNewTransaction.Showmodal = mrOk then
      begin
        dmData.SaveChanges(dmData.ztCheckingAccount, False);
        dmData.LinkSplitTransactions(dmData.ztCheckingAccount.FieldByName('TRANSID').AsInteger, dmData.ztSplitTransactions.TableName);
        dmdata.RefreshDataset(dmData.zqBankAccounts);
      end
      else
      begin
        dmData.ztCheckingAccount.Cancel;
        dmData.RemoveTempSplitTransactions(dmData.ztSplitTransactions.TableName);
      end;
      //
    end;
  finally
    frNewTransaction.Free;
  end;
end;

procedure TfrMain.bBnkAccEditMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  sbMouseMove(bBnkAccEdit);
end;

procedure TfrMain.bBnkAccExportMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bBnkAccExport);
end;

procedure TfrMain.bBnkAccNewClick(Sender: TObject);
begin
  try
    frNewTransaction := TfrNewTransaction.create(self);
    frNewTransaction.EditMode:= 'Insert';
    dmData.ztCheckingAccount.Insert;
  //  frNewTransaction.deDate.Text := FormatDateTime('YYYY/MM/DD', now);
    frNewTransaction.deDate.Text := FormatDateTime(dmData.DisplayDateFormat, now);

    if PAccountRec(tvNavigation.Selected.Data) <> nil then
    begin
      if dmData.ztAccountList.Locate('ACCOUNTID', PAccountRec(frMain.tvNavigation.Selected.Data)^.AccountID, [loCaseInsensitive]) then
      begin
        dmData.ztCheckingAccount.FieldByName('ACCOUNTID').AsInteger := dmData.ztAccountList.FieldByName('ACCOUNTID').AsInteger;
      end;
    end;

    if frNewTransaction.Showmodal = mrOk then
    begin
      dmData.SaveChanges(dmData.ztCheckingAccount, False);
      dmData.LinkSplitTransactions(dmData.ztCheckingAccount.FieldByName('TRANSID').AsInteger, dmData.ztSplitTransactions.TableName);
      dmdata.RefreshDataset(dmData.zqBankAccounts);
    end else
    begin
      dmData.ztCheckingAccount.Cancel;
      dmData.RemoveTempSplitTransactions(dmData.ztSplitTransactions.TableName);
    end;
  finally
    frNewTransaction.Free;
  end;
end;

procedure TfrMain.bBnkAccNewMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  sbMouseMove(bBnkAccNew);
end;

procedure TfrMain.bBudgetEditorMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bBudgetEditor);
end;

procedure TfrMain.bBudgetExportMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bBudgetExport);
end;

procedure TfrMain.bDefaultCategoryClick(Sender: TObject);
var CatID, SubCatID : integer;
begin
 CatID := dmData.zqPayee.FieldByName('CATEGID').AsInteger;
 SubCatID := dmData.zqPayee.FieldByName('SUBCATEGID').AsInteger;
 if frOrganiseCategories.SelectCategory(CatID, SubCatID) then
 begin
   dmData.ztPayee.Edit;
   dmData.ztPayee.FieldByName('CATEGID').AsInteger := CatID;
   dmData.ztPayee.FieldByName('SUBCATEGID').AsInteger := SubCatID;
   dmData.SaveChanges(dmData.ztPayee, False);
   dmdata.RefreshDataset(dmData.zqPayee);
 end;
//    bDefaultCategory.Caption := frNewTransaction.GetCategoryDescription(CatID, SubCatID);
end;

procedure TfrMain.bDefaultCategoryMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  sbMouseMove(bDefaultCategory);
end;

procedure TfrMain.bFilterClick(Sender: TObject);
begin
  try
    frTransactionFilter := TfrTransactionFilter.create(nil);
  {  if frTransactionFilter.Showmodal = mrOk then
    begin
      TransRepPayeeFilter := frTransactionFilter.PayeeFilter;
      TransRepDateFilter := frTransactionFilter.DateFilter;
      TransRepCatFilter := frTransactionFilter.CategoryFilter;
      TransAmountFilter := frTransactionFilter.AmountFilter;
      TransTypeFilter := frTransactionFilter.TransTypeFilter;
    end;}
    frTransactionFilter.EditMode := 'Insert';
    frTransactionFilter.Showmodal;
  finally
    frTransactionFilter.Free;
  end;
  DisplayBankAccountsGrid;
end;

procedure TfrMain.bFilterMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  sbMouseMove(bFilter);
end;

procedure TfrMain.bPayeesDeleteClick(Sender: TObject);
begin
 if dmData.zqPayee.RecordCount = 0 then exit;
 if MessageDlg('Are you sure you want to delete "'+dmData.zqPayee.FieldByName('PAYEENAME').AsString+'" payee?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;
 dmData.DeleteDBRecord(dmData.ztPayee.TableName, 'payeeid', dmData.zqPayee.FieldByName('payeeid').AsInteger);
 dmdata.RefreshDataset(dmData.ztPayee);
 dmdata.RefreshDataset(dmData.zqPayee);
end;

procedure TfrMain.bPayeesDeleteMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bPayeesDelete);
end;

procedure TfrMain.bPayeesEditClick(Sender: TObject);
begin
  try
    frPayee := TfrPayee.create(self);
    frPayee.EditMode:= 'Edit';
    if dmdata.ztPayee.Locate('PAYEEID', dmdata.zqPayee.FieldByName('PAYEEID').AsInteger, [loCaseInsensitive]) = True then
    begin
      frPayee.bCategory.Caption := dmData.GetCategoryDescription(dmData.ztPayee.FieldByName('CATEGID').AsInteger, dmData.ztPayee.FieldByName('SUBCATEGID').AsInteger, 'Default Category');

      dmData.ztPayee.Edit;
      if frPayee.Showmodal = mrOk then
      begin
        dmData.SaveChanges(dmData.ztPayee, True);
        dmdata.RefreshDataset(dmData.zqPayee);
      end
      else
        dmData.ztPayee.Cancel;
    end;
  finally
    frPayee.Free;
  end;
end;

procedure TfrMain.bPayeesEditMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  sbMouseMove(bPayeesEdit);
end;

procedure TfrMain.bPieChartMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  sbMouseMove(bPieChart);
end;

procedure TfrMain.bRepTransExportMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bRepTransExport);
end;

procedure TfrMain.bPayeesExportMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bPayeesExport);
end;

procedure TfrMain.bPayeesNewClick(Sender: TObject);
begin
  try
    frPayee := TfrPayee.create(self);
    frPayee.EditMode:= 'Insert';
    dmData.ztPayee.Insert;
    if frPayee.Showmodal = mrOk then
    begin
      dmData.SaveChanges(dmData.ztPayee, False);
      dmdata.RefreshDataset(dmData.zqPayee);
    end
    else
      dmData.ztPayee.Cancel;
  finally
    frPayee.Free;
  end;
end;

procedure TfrMain.bPayeesNewMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  sbMouseMove(bPayeesNew);
end;

procedure TfrMain.bPieChartClick(Sender: TObject);
var Node : TTreeNode;
begin
  LastReportType := 1;
  Node := tvNavigation.Selected;
  if not assigned(Node) then exit;
  DoPieChart(Node);
end;

procedure TfrMain.bRepTransDeleteClick(Sender: TObject);
begin
  if dmData.ztRepeatTransactions.RecordCount = 0 then exit;
  if MessageDlg('Are you sure you want to delete this repeating transaction?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;

  if dmData.ztRepeatTransactions.Locate('REPTRANSID', dmData.zqRepeatTransactions.FieldByName('REPTRANSID').AsInteger, [loCaseInsensitive]) = True then
  begin
    dmData.DeleteDBRecord(dmData.ztRepeatSplitTransactions.TableName, 'TRANSID', dmData.zqRepeatTransactions.FieldByName('REPTRANSID').AsInteger);
    dmData.DeleteDBRecord(dmData.ztRepeatTransactions.TableName, 'REPTRANSID', dmData.zqRepeatTransactions.FieldByName('REPTRANSID').AsInteger);
    dmdata.RefreshDataset(dmData.ztRepeatTransactions);
    dmdata.RefreshDataset(dmData.zqRepeatTransactions);
  end;
end;

procedure TfrMain.bRepTransDeleteMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bRepTransDelete);
end;

procedure TfrMain.bRepTransEditClick(Sender: TObject);
begin
  if dmData.ztRepeatTransactions.Locate('REPTRANSID', dmData.zqRepeatTransactions.FieldByName('REPTRANSID').AsInteger, [loCaseInsensitive]) = True then
  begin
    try
      frRepeatingTransaction := TfrRepeatingTransaction.create(self);
      frRepeatingTransaction.EditMode:= 'Edit';
      frRepeatingTransaction.Showmodal;
    finally
      frRepeatingTransaction.Free;
    end;
  end;
end;

procedure TfrMain.bRepTransEditMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bRepTransEdit);
end;

procedure TfrMain.bRepTransEnterClick(Sender: TObject);
begin
  if dmData.ztRepeatTransactions.Locate('REPTRANSID', dmData.zqRepeatTransactions.FieldByName('REPTRANSID').AsInteger, [loCaseInsensitive]) = True then
  begin
    try
      frRepeatingTransaction := TfrRepeatingTransaction.create(self);
      frRepeatingTransaction.EditMode:= 'Manual';
      frRepeatingTransaction.Showmodal;
    finally
      frRepeatingTransaction.Free;
    end;
  end;
  //frRepeatingTransaction.ProcessRepeatPayment(dmdata.zqRepeatTransactions.FieldByName('REPTRANSID').AsInteger);
end;

procedure TfrMain.bRepTransEnterMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bRepTransEnter);
end;

procedure TfrMain.bRepTransNewClick(Sender: TObject);
begin
  try
    frRepeatingTransaction := TfrRepeatingTransaction.create(self);
    frRepeatingTransaction.EditMode:= 'Insert';
    frRepeatingTransaction.Showmodal;
  finally
    frRepeatingTransaction.Free;
  end;
end;

procedure TfrMain.bRepTransNewMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  sbMouseMove(bRepTransNew);
end;

procedure TfrMain.bRepTransSkipClick(Sender: TObject);
begin
  frRepeatingTransaction.SkipRepeatPayment(dmdata.zqRepeatTransactions.FieldByName('REPTRANSID').AsInteger);
end;

procedure TfrMain.bRepTransSkipMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bRepTransSkip);
end;

procedure TfrMain.bTestErrorClick(Sender: TObject);
begin
  raise Exception.Create('Test');
end;

procedure TfrMain.Button1Click(Sender: TObject);
begin
  SetBudgetFilter(sgBudget.Col,sgBudget.Cells[sgBudget.Col,sgBudget.Row]);
end;

procedure TfrMain.Button2Click(Sender: TObject);
begin
  RestoreBudgetFilter;
end;

procedure TfrMain.cbBudgetFilterListChange(Sender: TObject);
var FilterStr : string;
  ColNum : integer;
begin
  FilterStr := '';
  ColNum := 0;
  if cbBudgetFilterList.Text = '[None]' then FilterStr := '' else
  if cbBudgetFilterList.Text = 'Expense' then
  begin
    FilterStr := 'Expense';
    ColNum := sgBudgetIncomeExpense;
  end else
  if cbBudgetFilterList.Text = 'Income' then
  begin
    FilterStr := 'Income';
    ColNum := sgBudgetIncomeExpense;
  end else
  if cbBudgetFilterList.Text = 'No Amount' then
  begin
    FilterStr := FullDecimalPlacesStr;
    ColNum := sgBudgetAmount;
  end else
  if cbBudgetFilterList.Text = 'Frequency None' then
  begin
    FilterStr := 'None';
    ColNum := sgBudgetFrequency;
  end else
  if cbBudgetFilterList.Text = 'Frequency Weekly' then
  begin
    FilterStr := 'Weekly';
    ColNum := sgBudgetFrequency;
  end else
  if cbBudgetFilterList.Text = 'Frequency Bi-Weekly' then
  begin
    FilterStr := 'Bi-Weekly';
    ColNum := sgBudgetFrequency;
  end else
  if cbBudgetFilterList.Text = 'Frequency Monthly' then
  begin
    FilterStr := 'Monthly';
    ColNum := sgBudgetFrequency;
  end else
  if cbBudgetFilterList.Text = 'Frequency Bi-Monthly' then
  begin
    FilterStr := 'Bi-Monthly';
    ColNum := sgBudgetFrequency;
  end else
  if cbBudgetFilterList.Text = 'Frequency Quarterly' then
  begin
    FilterStr := 'Quarterly';
    ColNum := sgBudgetFrequency;
  end else
  if cbBudgetFilterList.Text = 'Frequency Half-Yearly' then
  begin
    FilterStr := 'Half-Yearly';
    ColNum := sgBudgetFrequency;
  end else
  if cbBudgetFilterList.Text = 'Frequency Yearly' then
  begin
    FilterStr := 'Yearly';
    ColNum := sgBudgetFrequency;
  end else
  if cbBudgetFilterList.Text = 'Frequency Daily' then
  begin
    FilterStr := 'Daily';
    ColNum := sgBudgetFrequency;
  end;
  if FilterStr = '' then
    PopulateBudgetsGrid
  else
  begin
    PopulateBudgetsGrid;
    SetBudgetFilter(ColNum, FilterStr);
  end;
end;

procedure TfrMain.cbFilterListChange(Sender: TObject);
begin
  frTransactionFilter.RunTransFilter(cbFilterList.Text);
end;

procedure TfrMain.cbItemLimitChange(Sender: TObject);
begin
  RunDefaultReport(false);
end;

procedure TfrMain.cbPayeeFilterListChange(Sender: TObject);
begin
  DisplayPayeesGrid;
end;

procedure TfrMain.cbRepAccountsChange(Sender: TObject);
begin
  RunDefaultReport(false);
end;

procedure TfrMain.cbRepGroupChange(Sender: TObject);
begin
  DefaultReportType := cbRepGroup.ItemIndex;
  RunDefaultReport(false);
end;

procedure TfrMain.cbRepTransFilterChange(Sender: TObject);
begin
  DisplayRepeatingTransactionsGrid;
end;

procedure TfrMain.dbgAssetsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  dbgMouseDown(dbgAssets, x, y);
end;

procedure TfrMain.dbgAssetsMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  dbgMouseMove(dbgAssets, x, y);
end;

procedure TfrMain.dbgBankAccountColumnMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
begin
end;

procedure TfrMain.dbgBankAccountColumnSized(Sender: TObject);
begin
end;

procedure TfrMain.dbgBankAccountMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  dbgMouseDown(dbgBankAccount, x, y);
end;

procedure TfrMain.dbgBankAccountMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  dbgMouseMove(dbgBankAccount, x, y);
end;

procedure TfrMain.dbgPayeesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  dbgMouseDown(dbgPayees, x, y);
end;

procedure TfrMain.dbgPayeesMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  dbgMouseMove(dbgPayees, x, y);
end;

procedure TfrMain.dbgPayeesMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TfrMain.dbgRepTransMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  dbgMouseDown(dbgRepTrans, x, y);
end;

procedure TfrMain.dbgRepTransMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  dbgMouseMove(dbgRepTrans, x, y);
end;

procedure TfrMain.dbgRepTransTitleClick(Column: TColumn);
var i : integer;
begin
  for i:= 0 to dbgRepTrans.Columns.Count-1 do
    dbgRepTrans.Columns.Items[i].Title.ImageIndex:=-1;

  if Column.FieldName = dmData.zqRepeatTransactions.SortedFields then
  begin
    if RepTransSort = ' asc' then
    begin
      RepTransSort := ' desc';
      Column.Title.ImageIndex:= 30;
    end
    else
      begin
        RepTransSort := ' asc';
        Column.Title.ImageIndex:= 31;
      end;
  end else
  begin
    RepTransSort := ' asc';
    Column.Title.ImageIndex:= 31;
  end;

  dmData.zqRepeatTransactions.SortedFields:= Column.FieldName;
  dmData.zqRepeatTransactions.IndexFieldNames := Column.FieldName + RepTransSort ;
end;

procedure TfrMain.dbgUpcomingTransMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//  dbgMouseDown(dbgUpcomingTrans, x, y);
end;

procedure TfrMain.dbgUpcomingTransMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
//  dbgMouseMove(dbgUpcomingTrans, x, y);
end;

procedure TfrMain.FormShowHint(Sender: TObject; HintInfo: PHintInfo);
begin
end;

procedure TfrMain.miBankDeleteBudgetClick(Sender: TObject);
var ParentNode, Node : TTreenode;
begin
  if PBudgetYearRec(tvNavigation.Selected.Data) = nil then exit;
  if MessageDlg('Are you sure you want to delete "'+PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetYearName+'" budget?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;
  if dmData.ztBudgetYear.Locate('BUDGETYEARID', PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetYearID, [loCaseInsensitive]) = True then
  begin
    dmData.DeleteDBRecord(dmData.ztBudget.TableName, 'BUDGETYEARID', PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetYearID);
    dmData.DeleteDBRecord(dmData.ztBudgetYear.TableName, 'BUDGETYEARID', PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetYearID);
    dmdata.RefreshDataset(dmData.ztBudgetYear);
    dmdata.RefreshDataset(dmData.ztBudget);
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

procedure TfrMain.miBankEditBudgetClick(Sender: TObject);
begin
  if PBudgetYearRec(tvNavigation.Selected.Data) = nil then exit;
  if dmData.ztBudgetYear.Locate('BUDGETYEARID', PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetYearID, [loCaseInsensitive]) = True then
  begin
    try
      frBudget := TfrBudget.create(self);
      frBudget.EditMode := 'Edit';
      if frBudget.Showmodal = mrOk then
      begin
        case pcNavigation.PageIndex of
          pgBudgets : PopulateBudgetsGrid;
        end;
      end;
    finally
      frBudget.Free;
    end;
  end;
end;

procedure TfrMain.miBudgetEditorClick(Sender: TObject);
begin
  try
    frBudgetEditor := TfrBudgetEditor.create(self);
    frBudgetEditor.Showmodal;
  finally
    frBudgetEditor.Free;
  end;
end;

procedure TfrMain.miEmptyTablesClick(Sender: TObject);
begin
  try
    frEmptyTables := TfrEmptyTables.create(self);
    frEmptyTables.Showmodal;
  finally
    frEmptyTables.Free;
  end;
end;

procedure TfrMain.miGridsEnterClick(Sender: TObject);
begin
  case pcNavigation.PageIndex of
    pgRepTrans : bRepTransEnter.Click;
  end;
end;

procedure TfrMain.miGridsExportClick(Sender: TObject);
var Dataset : TDataset;
begin
  sdGridExport.InitialDir:= ExtractFileDir(application.exename);
  case pcNavigation.PageIndex of
    pgBankAccs : Dataset := dbgBankAccount.DataSource.DataSet;
    pgAssets : Dataset := dbgAssets.DataSource.DataSet;
    pgPayees : Dataset := dbgPayees.DataSource.DataSet;
    pgRepTrans : Dataset := dbgRepTrans.DataSource.DataSet;
  end;
  if sdGridExport.Execute then
  case pcNavigation.PageIndex of
    pgBankAccs, pgAssets, pgPayees, pgRepTrans : dmData.Dataset2SeparatedFile(Dataset,sdGridExport.FileName, ',');
    pgBudgets : dmData.StringGrid2SeparatedFile(sgBudget,sdGridExport.FileName, ',');
  end;
end;

procedure TfrMain.miGridsPrintClick(Sender: TObject);
begin
//  dbgPayees.PaintTo(Printer.Canvas, 0, 0);
end;

procedure TfrMain.miGridsSkipClick(Sender: TObject);
begin
  case pcNavigation.PageIndex of
    pgRepTrans : bRepTransSkip.Click;
  end;
end;

procedure TfrMain.miReportsClipboardClick(Sender: TObject);
var Chart : TChart;
begin
  if LastReportType = 0 then
    Chart := BarChart
  else
    Chart := PieChart;

  Chart.CopyToClipboardBitmap;
end;

procedure TfrMain.miReportsExportClick(Sender: TObject);
var Chart : TChart;
begin
  if LastReportType = 0 then
    Chart := BarChart
  else
    Chart := PieChart;
  spdReports.InitialDir:= ExtractFileDir(application.exename);
  if spdReports.Execute then
//  begin
  case spdReports.FilterIndex of
    1 : Chart.SaveToBitmapFile(spdReports.FileName);
    2 : Chart.SaveToFile(TJPEGImage, spdReports.FileName);
    3 : Chart.SaveToFile(TPortableNetworkGraphic, spdReports.FileName);
  end;
//  end;
end;

procedure TfrMain.miReportsPrintClick(Sender: TObject);
const
  MARGIN = 10;
var
  r: TRect;
  d: Integer;
  Chart : TChart;
  OriginalBackColor, OriginalColor, BrushColor : TColor;
begin
{  if not PrintDialog.Execute then exit;

  if LastReportType = 0 then
    Chart := BarChart
  else
    Chart := PieChart;

  //set background colours to plain
  OriginalBackColor := Chart.BackColor;
  OriginalColor := Chart.Color;
  BrushColor := Chart.Title.Brush.Color;
  Chart.BackColor:= clNone;
  Chart.Color:= clNone;
  Chart.Title.Brush.Color:= clNone;

  Printer.BeginDoc;
  try
    r := Rect(0, 0, Printer.PageWidth, Printer.PageHeight div 2);
    d := r.Right - r.Left;
    r.Left += d div MARGIN;
    r.Right -= d div MARGIN;
    d := r.Bottom - r.Top;
    r.Top += d div MARGIN;
    r.Bottom -= d div MARGIN;
    if Sender = miReportsPrintCanvas then
      Chart.PaintOnCanvas(Printer.Canvas, r)
    else
      Chart.Draw(TPrinterDrawer.Create(Printer), r);
  finally
    Printer.EndDoc;
  end;

  //restore background colours to original setting
  Chart.BackColor := OriginalBackColor;
  Chart.Color:= OriginalColor;
  Chart.Title.Brush.Color:= BrushColor;}
end;

procedure TfrMain.miTransRepFilterClick(Sender: TObject);
var DateStr, DateFilterStr, AccountFilterStr: string;
begin
  try
    frTransFilterList := TfrTransFilterList.create(nil);
    frTransFilterList.Showmodal;
  finally
    frTransFilterList.Free;
  end;
end;

procedure TfrMain.miUpdateCategoriesClick(Sender: TObject);
var i : integer;
begin
  try
    dmData.ZQuery1.Active:= False;
    dmData.ZQuery1.SQL.Clear;
    dmData.ZQuery1.SQL.Add(
    ' select c.transid, c.categid, c.subcategid, p.categid p_categid, p.subcategid p_subcategid '+
    ' from '+dmData.ztCheckingAccount.TableName+' c, '+dmData.ztPayee.TableName+' p '+
    ' where c.payeeid = p.payeeid '+
    ' and c.categid <> p.categid '+
  //  ' and c.subcategid <> p.subcategid '+
    ' and ((c.categid <> p.categid) or (c.subcategid <> p.subcategid)) '
      );
    dmData.ZQuery1.ExecSQL;
    dmData.ZQuery1.Active:= True;
    dmData.ZQuery1.First;

    if dmData.ZQuery1.RecordCount = 0 then
    begin
      MessageDlg('No transactions with invalid categories found.',mtInformation, [mbOk], 0);
      exit;
    end;

    if MessageDlg('There are '+IntToStr(dmData.ZQuery1.RecordCount)+ ' transactions with invalid categories. Would you like to automatically update them?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;

    for i:= 1 to dmData.ZQuery1.RecordCount do
    begin
      //add progress bar
      if dmData.ztCheckingAccount.Locate('TRANSID', dmData.ZQuery1.FieldByName('TRANSID').AsInteger, [loCaseInsensitive]) = True then
      begin
        dmData.ztCheckingAccount.Edit;
        dmData.ztCheckingAccount.FieldByName('CATEGID').AsInteger := dmData.ZQuery1.FieldByName('P_CATEGID').AsInteger;
        dmData.ztCheckingAccount.FieldByName('SUBCATEGID').AsInteger := dmData.ZQuery1.FieldByName('P_SUBCATEGID').AsInteger;
        dmData.SaveChanges(dmData.ztCheckingAccount, False);
      end;
      dmData.ZQuery1.Next;
    end;
  finally
    dmData.ZQuery1.Active:= False;
  end;

  case pcNavigation.PageIndex of
    pgBankAccs : dmdata.RefreshDataset(dmData.zqBankAccounts);
  end;
end;

procedure TfrMain.miViewBankAccountsClick(Sender: TObject);
begin
end;

procedure TfrMain.ToggleToolbarCaptions(Toggle : Boolean);
begin
  tbMain.ShowCaptions:= Toggle;
  if tbMain.ShowCaptions then
  begin
    tbMain.ButtonHeight:= 40;
    tbMain.ButtonWidth:= 40;
  end else
  begin
    tbMain.ButtonHeight:= 25;
    tbMain.ButtonWidth:= 25;
  end;
end;

procedure TfrMain.miViewToolbarCaptionsClick(Sender: TObject);
begin
  if miViewToolbarCaptions.Checked then
    miViewToolbarCaptions.Checked := false
  else
    miViewToolbarCaptions.Checked := true;
  ToggleToolbarCaptions(miViewToolbarCaptions.Checked);
end;

procedure TfrMain.UpdateStatusBarText;
var ItemCount, FilterCount : Integer;
begin
  FilterCount := -1;
  ItemCount := -1;

  case pcNavigation.PageIndex of
    pgHomepage :
     begin
     end;
    pgAssets :
     begin
       if dmdata.zqAssets.Active then
       begin
         FilterCount := dmdata.zqAssets.RecordCount;
         ItemCount := dmdata.ztAssets.RecordCount;
       end;
     end;
    pgPayees :
     begin
       if dmdata.zqPayee.Active then
       begin
         FilterCount := dmdata.zqPayee.RecordCount;
         ItemCount := dmdata.ztPayee.RecordCount;
       end;
     end;
    pgRepTrans :
     begin
       if dmdata.zqRepeatTransactions.Active then
       begin
         FilterCount := dmdata.zqRepeatTransactions.RecordCount;
         ItemCount := dmdata.ztRepeatTransactions.RecordCount;
       end;
     end;
    pgReports :
     begin
     end;
    pgBudgets :
     begin
     end;
    pgBankAccs :
    begin
      if dmdata.zqBankAccounts.Active then
      begin
        FilterCount := dmdata.zqBankAccounts.RecordCount;
        ItemCount := dmdata.zqBankAccounts.RecordCount;   //need to change
      end;
    end;
  end;

  //    StatusBar1.Panels.Items[1].Text:=IntToStr(FilterCount)+' / '+IntToStr(ItemCount)

{  if (ItemCount <> -1) and (FilterCount = -1) then
    StatusBar1.Panels.Items[1].Text:=IntToStr(FilterCount)+' records';

  if (ItemCount <> -1) and (FilterCount <> -1) then
    StatusBar1.Panels.Items[1].Text:=IntToStr(FilterCount)+' / '+IntToStr(ItemCount) +' records';}

  if (ItemCount <> -1) and (FilterCount <> -1) then
    StatusBar1.Panels.Items[1].Text:=IntToStr(FilterCount)+' records';

  if (ItemCount = -1) and (FilterCount = -1) then
    StatusBar1.Panels.Items[1].Text:= '';

end;

procedure TfrMain.pcNavigationChange(Sender: TObject);
//var parentNode, Node : TTreeNode;
begin
  if dmdata.zqBankAccounts.Active then
      dmdata.SaveGridLayout(dbgBankAccount);
  if dmdata.zqAssets.Active then
    dmdata.SaveGridLayout(dbgAssets);
  if dmdata.zqPayee.Active then
    dmdata.SaveGridLayout(dbgPayees);
  if dmdata.zqRepeatTransactions.Active then
    dmdata.SaveGridLayout(dbgRepTrans);
  if dmdata.zqUpcomingTrans.Active then
    dmdata.SaveGridLayout(dbgUpcomingTrans);

  UpdateStatusBarText;
{  pgBudgets :
   begin
       ParentNode := dmData.GetNodeByText(tvNavigation, 'Budgets', false);
     Node := tvNavigation.Selected;
     if Node <> nil then
     begin
       if Node.Parent <> ParentNode then
         Node := ParentNode.GetFirstChild;
       if Node <> nil then Node.Selected := True;
     end;
   end;
  pgBankAccs :
  begin
      ParentNode := dmData.GetNodeByText(tvNavigation, 'Bank Accounts', false);
    Node := tvNavigation.Selected;
    if Node <> nil then
    begin
      if Node.Parent <> ParentNode then
        Node := ParentNode.GetFirstChild;
      if Node <> nil then Node.Selected := True;
    end;
  end;}
end;

procedure TfrMain.PieChartMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
{  var
    i: Integer;}
begin
  //not working
  {  if PieChartPieSeries1.Active = False then exit;
  i := PieChartPieSeries1.FindContainingSlice(Point(X, Y));
  if i < 0 then exit;
  lcsPieChartValues.SetXValue(i, 0.2 - lcsPieChartValues[i]^.X);
  PieChart.Invalidate;}
end;

procedure TfrMain.bAssetsEditClick(Sender: TObject);
var TmpDate : String;
begin
  try
    frAsset := TfrAsset.create(self);
    frAsset.EditMode:= 'Edit';
    if dmData.ztAssets.Locate('ASSETID', dmData.zqAssets.FieldByName('ASSETID').AsInteger, [loCaseInsensitive]) = True then
    begin
      dmData.ztAssets.Edit;
      TmpDate := dmData.ztAssets.FieldByName('STARTDATE').AsString;
      TmpDate := StringReplace(TmpDate, '-', '/', [rfReplaceAll, rfIgnoreCase]);
      frAsset.deDate.Text := TmpDate;
      if frAsset.Showmodal = mrOk then
      begin
        dmData.SaveChanges(dmData.ztAssets, False);
        dmdata.RefreshDataset(dmData.zqAssets);
      end
      else
        dmData.ztAssets.Cancel;
    end;
  finally
    frAsset.Free;
  end;
end;

procedure TfrMain.bAssetsEditMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  sbMouseMove(bAssetsEdit);
end;

procedure TfrMain.bAssetsExportMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bAssetsExport);
end;

procedure TfrMain.bAssetsNewClick(Sender: TObject);
begin
  try
    frAsset := TfrAsset.create(self);
    frAsset.EditMode:= 'Insert';
    dmData.ztAssets.Insert;
  //  frAsset.deDate.Text := FormatDateTime('YYYY/MM/DD', now);
    frAsset.deDate.Text := FormatDateTime(dmData.DisplayDateFormat, now);
    if frAsset.Showmodal = mrOk then
    begin
      dmData.SaveChanges(dmData.ztAssets, False);
      dmdata.RefreshDataset(dmData.zqAssets);
    end else
      dmData.ztAssets.Cancel;
  finally
    frAsset.Free;
  end;
end;

procedure TfrMain.bAssetsNewMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  sbMouseMove(bAssetsNew);
end;

procedure TfrMain.bBarChartClick(Sender: TObject);
var Node : TTreeNode;
begin
  LastReportType := 0;
  Node := tvNavigation.Selected;
  if not assigned(Node) then exit;
  DoBarChart(Node);
end;

procedure TfrMain.bBarChartMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  sbMouseMove(bBarChart);
end;

procedure TfrMain.bAssetsDeleteClick(Sender: TObject);
begin
  if dmData.ztAssets.RecordCount = 0 then exit;
  if MessageDlg('Are you sure you want to delete this asset?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;
  dmData.DeleteDBRecord(dmData.ztAssets.TableName, 'assetid', dmData.ztAssets.FieldByName('assetid').AsInteger);
  dmdata.RefreshDataset(dmData.ztAssets);
  dmdata.RefreshDataset(dmData.zqAssets);
end;

procedure TfrMain.bAssetsDeleteMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bAssetsDelete);
end;

procedure TfrMain.ApplicationPropertiesException(Sender: TObject; E: Exception);
begin
  //save exception to a timestamped textfile in the application folder
end;

procedure TfrMain.ApplicationProperties1Hint(Sender: TObject);
begin
  StatusBar1.Panels[0].Text:= Application.Hint;
end;

procedure TfrMain.bBnkAccDeleteClick(Sender: TObject);
begin
  if dmData.zqBankAccounts.RecordCount = 0 then exit;

  if MessageDlg('Are you sure you want to delete this transaction?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;

  dmData.DeleteDBRecord(dmData.ztSplitTransactions.TableName, 'transid', dmData.zqBankAccounts.FieldByName('TRANSID').AsInteger);
  dmData.DeleteDBRecord(dmData.ztCheckingAccount.TableName, 'transid', dmData.zqBankAccounts.FieldByName('TRANSID').AsInteger);
  dmdata.RefreshDataset(dmData.zqBankAccounts);
end;

procedure TfrMain.bBnkAccDeleteMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  sbMouseMove(bBnkAccDelete);
end;

procedure TfrMain.bBnkAccDupeClick(Sender: TObject);
begin
  try
    frNewTransaction := TfrNewTransaction.create(self);
    frNewTransaction.EditMode:= 'Duplicate';
    if dmData.ztCheckingAccount.Locate('TRANSID', dmData.zqBankAccounts.FieldByName('TRANSID').AsInteger, [loCaseInsensitive]) = True then
    begin
      if frNewTransaction.Showmodal = mrOk then
      begin
        dmData.SaveChanges(dmData.ztCheckingAccount, False);
        dmdata.RefreshDataset(dmData.zqBankAccounts);
      end
      else
        dmData.ztCheckingAccount.Cancel;
    end;
  finally
    frNewTransaction.Free;
  end;
end;

procedure TfrMain.bBnkAccDupeMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  sbMouseMove(bBnkAccDupe);
end;

procedure TfrMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  savesettings;
  dmData.OpenDatabaseTables(False);

  if dmData.ExitBackup then
    dmData.BackupDatabase('exit');

  dmData.Free;
end;

procedure TfrMain.miNewAccountClick(Sender: TObject);
begin
  try
    frNewAccountWizard := TfrNewAccountWizard.create(self);
    frNewAccountWizard.Showmodal;
  finally
    frNewAccountWizard.Free;
  end;
end;

procedure TfrMain.miNewDatabaseClick(Sender: TObject);
begin
  sdNewDatabase.InitialDir:= ExtractFileDir(application.exename);
  if sdNewDatabase.Execute then
  begin
    dmData.CreateDatabase(sdNewDatabase.FileName);
    CreateBankAccountItems;
    CreateBudgetSetupItems;
    GotoHomepage;
  end;
end;

procedure TfrMain.miOpenDatabaseClick(Sender: TObject);
begin
  if odOpenDatabase.Execute then
  begin
    dmData.zcDatabaseConnection.Connected:= False;
    dmData.zcDatabaseConnection.Database:= odOpenDatabase.FileName;
    dmData.DatabaseLocation := odOpenDatabase.FileName;
    dmData.zcDatabaseConnection.Connected:= True;
    dmData.OpenDatabaseTables(True);
    CreateBankAccountItems;
    CreateBudgetSetupItems;
    GotoHomepage;
  end;
end;


procedure TfrMain.miOptionsClick(Sender: TObject);
begin
  try
    frOptions := TfrOptions.create(self);
    if frOptions.Showmodal = mrOk then
    begin
      case pcNavigation.PageIndex of
        pgBudgets : sgBudget.Refresh;  //refresh colours on grid
      end;
    end;
  finally
    frOptions.Free;
  end;
end;

procedure TfrMain.miOrgCatagoriesClick(Sender: TObject);
begin
  try
    frOrganiseCategories := TfrOrganiseCategories.create(self);
    frOrganiseCategories.bSelect.Visible:= False;
    if frOrganiseCategories.Showmodal = mrOk then
    begin
      case pcNavigation.PageIndex of
        pgBudgets : PopulateBudgetsGrid;  //refresh include in budget categories
      end;
    end;
  finally
    frOrganiseCategories.Free;
  end;
end;

procedure TfrMain.miOrgPayeesClick(Sender: TObject);
begin
  try
    frPayee := TfrPayee.create(self);
    frPayee.Showmodal;
  finally
    frPayee.Free;
  end;
end;

procedure TfrMain.miRelocateCategoriesClick(Sender: TObject);
begin
  try
    frRelocateCategory := TfrRelocateCategory.create(self);
    frRelocateCategory.Showmodal;
  finally
    frRelocateCategory.Free;
  end;
end;

procedure TfrMain.miRelocatePayeesClick(Sender: TObject);
begin
  try
    frRelocatePayee := TfrRelocatePayee.create(self);
    frRelocatePayee.Showmodal;
  finally
    frRelocatePayee.Free;
  end;
end;

procedure TfrMain.miSaveDatabaseAsClick(Sender: TObject);
begin
  if sdSaveDialog.Execute then
  begin
    try
      dmData.OpenDatabaseTables(False);
      if fileutil.CopyFile(dmData.DatabaseLocation, sdSaveDialog.FileName) = false then ShowMessage('Backup failed!');
    finally
      dmData.OpenDatabaseTables(True);
    end;
  end;
end;

procedure TfrMain.miSQLLogClick(Sender: TObject);
begin
  if miSQLLog.Checked then
  begin
    miSQLLog.Checked := false;
    frSQLLog.Close;
  end else
  begin
    miSQLLog.Checked := true;
    frSQLLog.Show;
  end;

  dmData.DebugMode := miSQLLog.Checked;
end;

procedure TfrMain.miViewHeadersClick(Sender: TObject);
begin
  if miViewHeaders.Checked then
    miViewHeaders.Checked := false
  else
    miViewHeaders.Checked := true;
  pcNavigation.ShowTabs:= miViewHeaders.Checked;
end;

procedure TfrMain.miViewNavigationClick(Sender: TObject);
begin
  if miViewNavigation.Checked then
    miViewNavigation.Checked := false
  else
    miViewNavigation.Checked := true;
  tvNavigation.Visible:= miViewNavigation.Checked;
end;

procedure TfrMain.miViewSQLLogClick(Sender: TObject);
begin
  frSQLLog.Show;
end;

procedure TfrMain.miViewToolbarClick(Sender: TObject);
begin
  if miViewToolbar.Checked then
    miViewToolbar.Checked := false
  else
    miViewToolbar.Checked := true;

  tbMain.Visible:= miViewToolbar.Checked;
end;

procedure TfrMain.pmBankPopupMode(Toggle : Boolean);
begin
  //Bank Accounts
  miBankEditAccount.Visible:= Toggle;
  miBankDeleteAccount.Visible:= Toggle;
  miBankSplit1.Visible:= Toggle;
  miBankWebsite.Visible:= Toggle;
  //Budgets
  miBankEditBudget.Visible:= not Toggle;
  miBankDeleteBudget.Visible:= not Toggle;
  miBankEditBudgetEditor.Visible:= not Toggle;
  miBankSplit3.Visible:= not Toggle;
end;

procedure TfrMain.pmBankPopup(Sender: TObject);
var Node : TTreeNode;
begin
  if Sender is TTreeNode then
  begin
    Node := TTreeNode(Sender);
    pmBank.AutoPopup := ((Node.Text = 'Bank Accounts') or (Node.Text = 'Budgets'));

    if Node.Text = 'Bank Accounts' then pmBankPopupMode(True) else pmBankPopupMode(False);

  end else
    pmBank.AutoPopup := False;
end;

procedure TfrMain.pmBudgetsPopup(Sender: TObject);
begin
end;

procedure TfrMain.pmGridsPopup(Sender: TObject);
begin
  miGridsNew.Visible:= true;
  miGridsEdit.Visible:= true;
  miGridsDelete.Visible:= true;
  miGridsSpacer.Visible:= true;
  miGridsEnter.Visible:= False;
  miGridsSkip.Visible:= False;
  miGridsDupe.Visible:= False;
  miGridsDefCat.Visible:= False;

  case pcNavigation.PageIndex of
    pgBankAccs :
      begin
        miGridsDupe.Visible:= True;
      end;
    pgAssets :
      begin
//        miGridsDupe.Visible:= false;
//        miGridsDefCat.Visible:= False;
      end;
    pgPayees :
      begin
        miGridsDefCat.Visible:= True;
      end;
    pgRepTrans :
      begin
        miGridsEnter.Visible:= true;
        miGridsSkip.Visible:= true;
      end;
    pgBudgets :
      begin
        miGridsNew.Visible:= false;
        miGridsEdit.Visible:= false;
        miGridsDelete.Visible:= false;
        miGridsSpacer.Visible:= false;
      end;
  end;
end;

procedure TfrMain.rgBankDetailsClick(Sender: TObject);
begin

end;

procedure TfrMain.sgBudgetDblClick(Sender: TObject);
var
  SelectedRow : integer;
  tmpStr, DefBudgetType, DefBudgetFreq : string;
  BudgetYearID : integer;
  TempTot : Float;
  EstimatedIncome, EstimatedExpenses, ActualIncome, ActualExpenses: Float;
  parentNode, Node : TTreeNode;
begin
  if PBudgetYearRec(tvNavigation.Selected.Data) = nil then
  begin

    if MessageDlg('No active budgets exist. Would you like to create a new budget?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;
    frBudget := TfrBudget.create(self);
    frBudget.EditMode:= 'Insert';
    frBudget.Showmodal;
    frBudget.Free;

    ParentNode := dmData.GetNodeByText(tvNavigation, 'Budgets', false);
    Node := tvNavigation.Selected;
    if Node <> nil then
    begin
      if Node.Parent <> ParentNode then
        Node := ParentNode.GetFirstChild;
      if Node <> nil then Node.Selected := True;
    end;
    PopulateBudgetsGrid;
    exit;
  end else
    BudgetYearID := PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetYearID;

  //l:=sgBudget.Selection.TopLeft.x; //Get most left cell
  //t:=sgBudget.Selection.TopLeft.y; //Get top cell
  //r:=sgBudget.Selection.BottomRight.x; //Get most right cell
  SelectedRow:=sgBudget.Selection.BottomRight.y; //Get bottom Cell
  //give the form the grid reference of cell
  //Panel7.caption := 'Cells from ' + IntToStr(l) + ',' + IntToStr(t) + ' to ' + IntToStr(r) + ',' + IntToStr(b);

  if sgBudget.Cells[sgBudgetSubcategoryID, SelectedRow] = '' then exit;

  frBudgetEntry := TfrBudgetEntry.create(self);
//  frBudgetEntry.SelectedRow:= b;
  frBudgetEntry.BUDGETENTRYID:= sgBudget.Cells[sgBudgetBudgetEntryID, SelectedRow];
  frBudgetEntry.BUDGETFREQUENCY:= PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetFrequency;

  if (dmData.ztBudget.Locate('BUDGETENTRYID', sgBudget.Cells[sgBudgetBudgetEntryID, SelectedRow], [loCaseInsensitive]) = True) then
  begin
    frBudgetEntry.Caption:= 'Editing Budget';
    frBudgetEntry.eAmount.Text:= floatToStr(dmData.ztBudget.FieldByName('AMOUNT').AsCurrency);
//    dmData.DisplayCurrencyEdit(frBudgetEntry.eAmount);
    if dmData.ztBudget.FieldByName('AMOUNT').AsCurrency > 0 then
      frBudgetEntry.cbType.ItemIndex:= 0
    else
    begin
      frBudgetEntry.cbType.ItemIndex:= 1;
      dmData.DisplayCurrencyEditRemoveNegative(frBudgetEntry.eAmount);
    end;
    frBudgetEntry.cbFrequency.Text:= dmData.ztBudget.FieldByName('PERIOD').AsString;

    dmData.ztBudget.Edit;
    dmData.DisplayCurrencyEdit(frBudgetEntry.eAmount);
  end else
  begin
    frBudgetEntry.Caption:= 'Inserting Budget';
    frBudgetEntry.cbType.ItemIndex:= 1;
    frBudgetEntry.cbFrequency.ItemIndex:= 0;
    dmData.ztBudget.Insert;

    DefBudgetType := dmData.GetInfoSettings('DEFAULT_BUDGET_TYPE', 'Last Used');
    if DefBudgetType = 'Last Used' then
      frBudgetEntry.cbType.Text := dmData.GetInfoSettings('LAST_USED_BUDGET_TYPE', '')
    else
      frBudgetEntry.cbType.Text := dmData.GetInfoSettings('DEFAULT_BUDGET_TYPE', '');

    DefBudgetFreq := dmData.GetInfoSettings('DEFAULT_BUDGET_FREQUENCY', 'Last Used');
    if DefBudgetFreq = 'Last Used' then
      frBudgetEntry.cbFrequency.Text := dmData.GetInfoSettings('LAST_USED_BUDGET_FREQUENCY', '')
    else
      frBudgetEntry.cbFrequency.Text := dmData.GetInfoSettings('DEFAULT_BUDGET_FREQUENCY', '');
  end;

  if (dmData.ztCategory.Locate('CATEGID',sgBudget.Cells[sgBudgetCategoryID, SelectedRow], [loCaseInsensitive]) = True) then
    frBudgetEntry.lbCatDescription.Caption:= dmData.ztCategory.FieldByName('CATEGNAME').AsString
  else
    frBudgetEntry.lbCatDescription.Caption:= '';

  dmData.ztBudget.FieldByName('BUDGETYEARID').AsInteger := BudgetYearID;
  dmData.ztBudget.FieldByName('CATEGID').AsInteger := StrToInt(sgBudget.Cells[sgBudgetCategoryID, SelectedRow]);
  dmData.ztBudget.FieldByName('SUBCATEGID').AsInteger := StrToInt(sgBudget.Cells[sgBudgetSubcategoryID, SelectedRow]);

  if sgBudget.Cells[sgBudgetSubcategory, SelectedRow] <> '' then
    frBudgetEntry.lbCatDescription.Caption:= frBudgetEntry.lbCatDescription.Caption + ' / ' + sgBudget.Cells[sgBudgetSubcategory, SelectedRow];

//  frBudgetEntry.lbSubCatDescription.Caption := sgBudget.Cells[sgBudgetSubcategory, SelectedRow];
  frBudgetEntry.lbEstimatedDescription.Caption := sgBudget.Cells[sgBudgetEstimated, SelectedRow];
  frBudgetEntry.lbActualDescription.Caption := sgBudget.Cells[sgBudgetActual, SelectedRow];

  if frBudgetEntry.Showmodal = mrOk then
  begin
    dmdata.SetInfoSettings('LAST_USED_BUDGET_TYPE', frBudgetEntry.cbType.Text);
    dmdata.SetInfoSettings('LAST_USED_BUDGET_FREQUENCY', frBudgetEntry.cbFrequency.Text);

    if frBudgetEntry.eAmount.Text <> '' then
    begin
      if frBudgetEntry.cbType.Text = 'Income' then
      begin
        dmData.ztBudget.FieldByName('AMOUNT').AsCurrency := dmData.CurrencyEditToFloat(frBudgetEntry.eAmount);
        sgBudget.Cells[sgBudgetIncomeExpense, SelectedRow] := 'Income';
      end else
      begin
        dmData.ztBudget.FieldByName('AMOUNT').AsCurrency := (dmData.CurrencyEditToFloat(frBudgetEntry.eAmount) * -1);
        sgBudget.Cells[sgBudgetIncomeExpense, SelectedRow] := 'Expense';
      end
    end else
      dmData.ztBudget.FieldByName('AMOUNT').AsCurrency := 0;

    dmData.ztBudget.FieldByName('PERIOD').AsString := frBudgetEntry.cbFrequency.Text;
    dmData.SaveChanges(dmData.ztBudget, False);

    sgBudget.Cells[sgBudgetBudgetEntryID, SelectedRow] := IntToStr(dmData.ztBudget.fieldbyname('BUDGETENTRYID').AsInteger);
    sgBudget.Cells[sgBudgetFrequency, SelectedRow] := dmData.ztBudget.FieldByName('PERIOD').AsString;
//    sgBudget.Cells[sgBudgetAmount, SelectedRow] := dmData.CurrencyStr2DP(dmData.ztBudget.FieldByName('AMOUNT').AsString);
    sgBudget.Cells[sgBudgetAmount, SelectedRow] := dmData.ConvertFloatToCurrencyString(dmData.ztBudget.FieldByName('AMOUNT').AsCurrency);

    TempTot := dmData.CalcEstimatedAmount(dmData.ztBudget.FieldByName('AMOUNT').AsCurrency,sgBudget.Cells[sgBudgetFrequency, SelectedRow], PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetFrequency);
//    sgBudget.Cells[sgBudgetEstimated, SelectedRow] := dmData.CurrencyStr2DP(FloatToStr(TempTot));
    sgBudget.Cells[sgBudgetEstimated, SelectedRow] := dmData.ConvertFloatToCurrencyString(TempTot);

    EstimatedExpenses := PBudgetYearRec(tvNavigation.Selected.Data)^.EstimatedExpenses;
    EstimatedIncome := PBudgetYearRec(tvNavigation.Selected.Data)^.EstimatedIncome;
    ActualExpenses := PBudgetYearRec(tvNavigation.Selected.Data)^.ActualExpenses;
    ActualIncome := PBudgetYearRec(tvNavigation.Selected.Data)^.ActualIncome;

    if TempTot > 0 then
      EstimatedIncome := EstimatedIncome + TempTot
    else
      EstimatedExpenses := EstimatedExpenses + TempTot;

    PBudgetYearRec(tvNavigation.Selected.Data)^.EstimatedExpenses := EstimatedExpenses;
    PBudgetYearRec(tvNavigation.Selected.Data)^.EstimatedIncome := EstimatedIncome;
    PBudgetYearRec(tvNavigation.Selected.Data)^.ActualExpenses := ActualExpenses;
    PBudgetYearRec(tvNavigation.Selected.Data)^.ActualIncome := ActualIncome;
    dmData.UpdateBudgetTotalCaptions(EstimatedIncome, EstimatedExpenses, ActualIncome, ActualExpenses);


    //Update totals code here
    dmData.UpdateAllTotalColumns(sgBudget, sgBudget.Cells[sgBudgetCategoryID, SelectedRow]);
    dmData.UpdateGrandTotalsColumns(sgBudget);
  end else
  begin
    dmData.ztBudget.Cancel;
  end;
  frBudgetEntry.Free;
end;

procedure TfrMain.sgBudgetDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  TextStr, CatID: string;
  Colour : TColor;
  TW, TL : integer;
const
  LM = 2;   // Left Margin
  TM = 2;   // Top Margin
begin
  //show category colours in budget grid
  if (ARow > ColumnHeader) and (ACol > ColumnHeader) and dmData.GetInfoSettingsBool('SHOW_BUDGET_COLOURS', true) then
  begin
    if sgBudget.Cells[sgBudgetCategoryColour, ARow] <> '' then
      Colour := StringToColor(sgBudget.Cells[sgBudgetCategoryColour, ARow]) //dmData.GetCategoryColour(StrToInt(CatID));
    else
      Colour := clDefault;

    if (gdSelected in aState) then
    begin
      sgBudget.Canvas.Brush.Color := clHighlight;
      sgBudget.Canvas.Font.Color := clHighlightText;
    end else
    begin
      sgBudget.Canvas.Brush.Color := Colour;
      sgBudget.Canvas.Font.Color := clWindowText;
    end;
  end else
  begin
    if (gdSelected in aState) then
    begin
      sgBudget.Canvas.Brush.Color := clHighlight;
      sgBudget.Canvas.Font.Color := clHighlightText;
    end else
    begin
      sgBudget.Canvas.Brush.Color := clDefault;
      sgBudget.Canvas.Font.Color := clWindowText;
    end;
  end;
  //paint border headers
  if (ARow = ColumnHeader) or (ACol = ColumnHeader) then
    begin
      sgBudget.Canvas.Brush.Color := clBtnFace;
      sgBudget.Canvas.Font.Color := clDefault;
    end;
  //make totals bold
  if (ACol > ColumnHeader) and (ARow > ColumnHeader)
    //and (sgBudget.Cells[sgBudgetCategoryID, ARow] <> '')
    and (sgBudget.Cells[sgBudgetSubcategoryID, ARow] = '')
    and (sgBudget.Cells[sgBudgetBudgetYearID, ARow] = '')
    and (sgBudget.Cells[sgBudgetBudgetYearID, ARow] = '')
    and ((ACol = sgBudgetAmount) or (ACol = sgBudgetEstimated)
        or (ACol = sgBudgetActual) or (ACol = sgBudgetFrequency))
  then
    sgBudget.Canvas.Font.Style := [fsBold]
  else
    sgBudget.Canvas.Font.Style := [];

  TW := sgBudget.Canvas.TextWidth(sgBudget.Cells[aCol, aRow]);

  sgBudget.Canvas.FillRect(aRect);
  case aCol of
    sgBudgetCategoryID, sgBudgetCategory, sgBudgetSubcategoryID,
    sgBudgetSubcategory, sgBudgetFrequency, sgBudgetBudgetEntryID,
    sgBudgetBudgetYearID, sgBudgetCategoryColour,sgBudgetIncomeExpense : TL := ARect.Left + LM;  // left align
    sgBudgetAmount,
    sgBudgetEstimated,
    sgBudgetActual : TL := ARect.Right - TW - LM;   // right align
//    0 : TL := LM;   // left align
//    1 : TL := (ARect.Left + ARect.Right - TW)/2;   // centre align
//    2 : TL := ARect.Right - TW - LM;   // right align
  end;
  sgBudget.Canvas.TextOut(TL, ARect.Top + TM, sgBudget.Cells[ACol, ARow]);
end;

procedure TfrMain.StatusBar1Hint(Sender: TObject);
begin
//  StatusBar1.Panels[0].Text := Application.Hint;
end;

procedure TfrMain.tbBudgetEditorMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  tbMouseMove(tbBudgetEditor);
end;

procedure TfrMain.tbNewAccountMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  tbMouseMove(tbNewAccount);
end;

procedure TfrMain.tbNewDatabaseMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  tbMouseMove(tbNewDatabase);
end;

procedure TfrMain.tbNewTransactionMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  tbMouseMove(tbNewTransaction);
end;

procedure TfrMain.tbOpenDatabaseMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  tbMouseMove(tbOpenDatabase);
end;

procedure TfrMain.tbOptionsDialogClick(Sender: TObject);
begin

end;

procedure TfrMain.tbOptionsDialogMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  tbMouseMove(tbOptionsDialog);
end;

procedure TfrMain.tbOrgCatDialogMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  tbMouseMove(tbOrgCatDialog);
end;

procedure TfrMain.tbOrgCurrDialogMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  tbMouseMove(tbOrgCurrDialog);
end;

procedure TfrMain.tbOrgPayeesDialogMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  tbMouseMove(tbOrgPayeesDialog);
end;

procedure TfrMain.tbShowAccountListClick(Sender: TObject);
begin

end;

procedure TfrMain.tbTransRepFilterClick(Sender: TObject);
begin
end;

procedure TfrMain.tbTransRepFilterMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  tbMouseMove(tbTransRepFilter);
end;

procedure TfrMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled:= False;
  frRepeatingTransaction.ProcessTodaysRepeatTransactions;
end;

procedure TfrMain.tsAssetsShow(Sender: TObject);
begin
  DisplayAssetsGrid;
end;

procedure TfrMain.tsBankAccountsShow(Sender: TObject);
var parentNode, Node : TTreeNode;
  PreviousFilter : string;
begin
  ParentNode := dmData.GetNodeByText(tvNavigation, 'Bank Accounts', false);
  Node := tvNavigation.Selected;
  if Node <> nil then
  begin
    if Node.Parent <> ParentNode then
      Node := ParentNode.GetFirstChild;
    if Node <> nil then Node.Selected := True;
  end;

  PreviousFilter := frMain.cbFilterList.Text;
  if PreviousFilter = '' then PreviousFilter := '[None]';
  dmData.SetupComboBoxFilterArchived(frMain.cbFilterList, dmdata.ztTransFilter, 'TRANSFILTERNAME', '[None]', PreviousFilter);
  DisplayBankAccountsGrid;
end;

procedure TfrMain.tsBudgetsShow(Sender: TObject);
var parentNode, Node : TTreeNode;
begin
  ParentNode := dmData.GetNodeByText(tvNavigation, 'Budgets', false);
  Node := tvNavigation.Selected;
  if Node <> nil then
  begin
    if Node.Parent <> ParentNode then
      Node := ParentNode.GetFirstChild;
    if Node <> nil then Node.Selected := True;
  end;

  PopulateBudgetsGrid;
end;

procedure TfrMain.tsHomePageShow(Sender: TObject);
begin
  DisplayUpcomingTransactionsGrid;
  DoHomepageBarChart(dmData.zqHomepageRep1, frMain.HomepageBarChart1, frMain.lcsChartValues1, frMain.lcsLeftAxisValues1, frMain.lcsBottomAxisValues1, 'Income Vs Expenses', 'Report', 1);          //0 Payee, 1 Category
  DoHomepageBarChart(dmData.zqHomepageRep2, frMain.HomepageBarChart2, frMain.lcsChartValues2, frMain.lcsLeftAxisValues2, frMain.lcsBottomAxisValues2, 'Current Month', 'Where the Money Goes', 1);  //'Last 30 Days'
end;

procedure TfrMain.tsPayeesShow(Sender: TObject);
begin
  DisplayPayeesGrid;
end;

procedure TfrMain.tsRepeatingTransactionsShow(Sender: TObject);
begin
  DisplayRepeatingTransactionsGrid;
end;

procedure TfrMain.tsReportsShow(Sender: TObject);
begin
  dmData.SetupComboBox(frMain.cbRepAccounts, dmdata.ztAccountList, 'ACCOUNTNAME', '[All Accounts]', '[All Accounts]');
end;

procedure TfrMain.DisplayBankAccountsGrid;
var BankID : integer;
  DateStr : string;
  ReconBalance, TotalBalance, DifBalance : Real;
begin
  if PAccountRec(tvNavigation.Selected.Data) = nil then
  begin
    BankID := 0;
    rgBankDetails.Caption:= 'Bank Details';
  end else
  begin
    BankID := PAccountRec(tvNavigation.Selected.Data)^.AccountID;
    rgBankDetails.Caption:= PAccountRec(tvNavigation.Selected.Data)^.AccountName+' : '+ PAccountRec(tvNavigation.Selected.Data)^.AccountType;
  end;

//  tvNavigation.Items.Clear;
  dmData.zqBankAccounts.Active:= False;
  dmData.zqBankAccounts.SQL.Clear;

  DateStr := dmData.FormatDateSQL('transdate');

  dmData.zqBankAccounts.SQL.Add(
    ' select ch.transid, '+
    DateStr + ' frmtrandate, '+
    ' ch.transactionnumber, ch.status, ch.payeeid, '+
    //payeename
    ' case when (ch.payeeid = -1) then '+
    ' case when (ch.accountid = :accountid) then '''+TransferTo+' ''||ta.accountname else '''+TransferFrom+' ''||ta.accountname '+
    ' end else p.payeename '+
    ' end as PAYEE, '+
    ' p.payeename, '+
    //category
    ' case s.transid when ch.transid then '+chr(39)+'...'+chr(39)+' else ' +
    ' case ch.categid when 0 then '+chr(39)+chr(39)+' else '+
    ' case ch.categid when -1 then '+chr(39)+chr(39)+
    ' else '+
    '   case ch.subcategid when -1 then categname '+
    '   else coalesce(categname,'+chr(39)+chr(39)+') ||'+chr(39)+': '+chr(39)+'||coalesce(subcategname,'+chr(39)+chr(39)+') '+
    '   end '+
    ' end end end as category, '+
    //withdrawal
  {  ' case transcode '+
    ' when ''Withdrawal'' then '+
    ' case when substr(transamount,length(ROUND(transamount,2))-1,1) = "." then transamount || "0" '+
    ' when substr(transamount,length(ROUND(transamount,2))-1,1) = "" then transamount || ".00" '+
    ' else transamount '+
    ' end '+
    ' else '+chr(39)+chr(39)+
    ' end as WITHDRAWAL, '+}
    //withdrawal formatted
{    ' case when (transcode = ''Withdrawal'' or transcode = ''Transfer'') then '+
    ' case when (transcode = ''Transfer'' and ch.accountid = :accountid) then '+
    ' case when substr(transamount,length(ROUND(transamount,2))-1,1) = "." then transamount || "0" '+
    ' when substr(transamount,length(ROUND(transamount,2))-1,1) = "" then transamount || ".00" '+
    ' else transamount end else '+
    ' case when (transcode = ''Withdrawal'') then '+
    ' case when substr(transamount,length(ROUND(transamount,2))-1,1) = "." then transamount || "0" '+
    ' when substr(transamount,length(ROUND(transamount,2))-1,1) = "" then transamount || ".00" '+
    ' else transamount end else '''' '+
    ' end end end as WITHDRAWAL, '+}
    {--withdrawal simple}
    ' case when (transcode = ''Withdrawal'' or transcode = ''Transfer'' and ch.accountid = :accountid) then transamount else '''' '+
    'end as withdrawal, '+
    //deposit formatted
{    ' case when (transcode = ''Deposit'' or transcode = ''Transfer'') then '+
    ' case when (transcode = ''Transfer'' ) then '+
    ' case when substr(transamount,length(ROUND(transamount,2))-1,1) = "." then transamount || "0" '+
    ' when substr(transamount,length(ROUND(transamount,2))-1,1) = "" then transamount || ".00" '+
    ' else transamount end else '+
    ' case when (transcode = ''Deposit'') then '+
    ' case when substr(transamount,length(ROUND(transamount,2))-1,1) = "." then transamount || "0" '+
    ' when substr(transamount,length(ROUND(transamount,2))-1,1) = "" then transamount || ".00" '+
    ' else transamount end else ''''  '+
    ' end end end as DEPOSIT, '+}
    {--deposit simple}
    ' case when (transcode = ''Deposit'' or transcode = ''Transfer'' and ch.toaccountid = :accountid) then transamount else '''' '+
    ' end as deposit, '+
   { ' case transcode '+
    ' when ''Deposit'' then '+
    ' case when substr(transamount,length(ROUND(transamount,2))-1,1) = "." then transamount || "0" '+
    ' when substr(transamount,length(ROUND(transamount,2))-1,1) = "" then transamount || ".00" '+
    ' else transamount '+
    ' end '+
    ' else '+chr(39)+chr(39)+
    ' end as DEPOSIT, '+}
    //balance formatted
    {' case when substr((select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid),length(ROUND((select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid),2))-1,1) = "." '+
    ' then (select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid) || "0"  when substr((select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid),length(ROUND((select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid),2))-1,1) = "" then (select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid) || ".00"  else (select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid) '+
    ' end as BALANCE, '+}
     //balance simple
     ' (select round(sum(case when (transcode =''Withdrawal'' or transcode = ''Transfer'' and accountid = :accountid) then transamount * -1 else transamount end), '+IntToStr(DecimalPlaces)+') '+
     ' from '+dmData.ztCheckingAccount.TableName+
     ' where (accountid = :accountid or toaccountid = :accountid) '+
     ' and transid<=ch.transid) BALANCE, '+
     //balance before the transfer amounts
     { ' (select round(sum(case transcode when ''Withdrawal'' then transamount * -1 else transamount end), 2) '+
    ' from CHECKINGACCOUNT_V1 '+
    ' where accountid = ch.accountid '+
    ' and transid<=ch.transid) BALANCE, '+}
    ' ch.transcode,ch.transamount, ch.notes, ch.transdate, ch.subcategid, ch.categid '+
    ' from '+dmData.ztCheckingAccount.TableName+' ch'+
    ' left outer join '+dmdata.ztPayee.TableName+' p on ch.payeeid = p.payeeid '+
    ' left outer join '+dmdata.ztAccountList.TableName+' ta on ch.toaccountid = ta.accountid '+
    ' left outer join '+dmdata.ztCategory.TableName+' c on ch.categid = c.categid '+
    ' left outer join '+dmdata.ztSubCategory.TableName+' sc on c.categid = sc.categid and ch.subcategid = sc.subcategid '+
    ' left outer join '+dmdata.ztSplitTransactions.TableName+' s on ch.transid = s.transid '+
    ' where (ch.accountid = :accountid or ch.toaccountid = :accountid) '+
    TransRepPayeeFilter +
    TransRepDateFilter +
    TransRepCatFilter +
    TransAmountFilter +
    TransTypeFilter +
    ' group by ch.transid '
//    ' order by transid, transdate'
    );

  dmData.zqBankAccounts.ParamByName('accountid').Value := BankID;
  dmData.zqBankAccounts.ExecSQL;
  dmData.zqBankAccounts.Active:= True;

  dmdata.LoadGridLayout(dbgBankAccount);

  dmData.zqBankAccounts.Last;
  TotalBalance := dmData.zqBankAccounts.FieldByName('BALANCECURRENCY').AsCurrency;

  if TotalBalance = 0 then
    lAccountBalance.Caption:= 'Account Balance: '+CurrencySymbol+'0'+DecimalPlacesStr
  else
    lAccountBalance.Caption:= 'Account Balance: '+CurrencySymbol+dmData.ConvertFloatToCurrencyString(TotalBalance);


  ReconBalance := dmData.StatusBalance(BankID, 'R');
  if ReconBalance = 0 then
    lReconciledBalance.Caption:= 'Reconciled Balance: '+CurrencySymbol+'0'+DecimalPlacesStr
  else
    lReconciledBalance.Caption:= 'Reconciled Balance: '+CurrencySymbol+dmData.ConvertFloatToCurrencyString(ReconBalance);


  DifBalance := TotalBalance - ReconBalance;
  if DifBalance = 0 then
    lDifferenceBalance.Caption:= 'Difference Balance: '+CurrencySymbol+'0'+DecimalPlacesStr
  else
    lDifferenceBalance.Caption:= 'Difference Balance: '+CurrencySymbol+dmData.ConvertFloatToCurrencyString(DifBalance);

end;


procedure TfrMain.tvNavigationChange(Sender: TObject; Node: TTreeNode);
var parentNode : TTreeNode;
begin
  if not assigned(Node) then exit;

  parentNode := Node.Parent;
  if Assigned(parentNode) then
  begin
    while Assigned(parentNode.Parent) do
      parentNode := parentNode.Parent;
    pcNavigation.ActivePageIndex := ParentNode.Index;
  end else
    pcNavigation.ActivePageIndex := Node.Index;

  if assigned(Node.Parent) then
    if Node.Parent.Text = 'Bank Accounts' then
      DisplayBankAccountsGrid;

  if assigned(Node.Parent) then
  begin
    pmBank.AutoPopup := ((PAccountRec(tvNavigation.Selected.Data) <> nil) and (Node.Parent.Text = 'Bank Accounts'))
    or ((PBudgetYearRec(tvNavigation.Selected.Data) <> nil) and (Node.Parent.Text = 'Budgets'));

    if Node.Parent.Text = 'Bank Accounts' then pmBankPopupMode(True) else pmBankPopupMode(False);

  end
  else
    pmBank.AutoPopup := False;

  if assigned(Node.Parent) then
    if Node.Parent.Text = 'Budgets' then
     // PopulateBudgetsGrid;
      cbBudgetFilterListChange(nil);

  if assigned(Node.Parent) then
    if (Node.Parent.Text = 'Reports') or {(Node.Parent.Text = 'Summary of Accounts') or}
       (Node.Parent.Text = 'Where the Money Goes') or (Node.Parent.Text = 'Where the Money Comes From') then
    begin
      RunDefaultReport(true);
    end;

  if assigned(Node.Parent) then
    if (Node.Parent.Text = 'Summary of Accounts')
    or (Node.Text = 'Categories')
    or (Node.Text = 'Payees')
    or (Node.Text = 'Transaction Report')
    or (Node.Text = 'Budget Performance')
    or (Node.Text = 'Budget Category Summary')
    or (Node.Text = 'Cash Flow')
  then
  begin
    RunLazReport(Node);
  end;

  cbRepGroup.Visible:= (Node.Text <> 'Income Vs Expenses');
  cbItemLimit.Visible:= (Node.Text <> 'Income Vs Expenses');
end;

procedure TfrMain.tvNavigationClick(Sender: TObject);
var parentNode : TTreeNode;
begin

end;

procedure TfrMain.CreateBankAccountItems;
var i : integer;
    ParentNode, newNode : TTreeNode;
    MyAccountRec: PAccountRec;
begin
  Screen.Cursor:= crHourGlass;
  ParentNode := dmData.GetNodeByText(tvNavigation, 'Bank Accounts', false);
  if ParentNode = nil then
    ShowMessage('Not found!')
  else begin
    ParentNode.Selected := True;
    //Delete any nodes currently under Bank Accounts. ** will need to free pointers too
    ParentNode.DeleteChildren;
  end;

  dmData.ztAccountList.First;
  for i:= 1 to dmData.ztAccountList.RecordCount do
  begin

    New(MyAccountRec);
    MyAccountRec^.AccountID :=  dmData.ztAccountList.FieldByName('ACCOUNTID').AsInteger;
    MyAccountRec^.AccountName:= dmData.ztAccountList.FieldByName('ACCOUNTNAME').AsString;
    MyAccountRec^.AccountType:= dmData.ztAccountList.FieldByName('ACCOUNTTYPE').AsString;
    MyAccountRec^.InitialBal := dmData.ztAccountList.FieldByName('INITIALBAL').AsCurrency;

    newNode := frMain.tvNavigation.Items.addChildObject({frMain.tvNavigation.Selected}ParentNode, dmData.ztAccountList.FieldByName('ACCOUNTNAME').AsString, MyAccountRec);
    newNode.SelectedIndex:=3;
    newNode.ImageIndex:=3;

    dmData.ztAccountList.Next;
  end;
//  ztAccountList.Close;
  Screen.Cursor:= crDefault;
end;

procedure TfrMain.tvNavigationDeletion(Sender: TObject; Node: TTreeNode);
begin
//  TObject(Node.Data).Free;
end;

procedure TfrMain.tvNavigationMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var     {ParentNode,} Node : TTreeNode;
begin
  Node := tvNavigation.GetNodeAt(X, Y);
  if Assigned(Node) then
    Node.Selected := True;
end;

procedure TfrMain.DisplayAssetsGrid;
var {BankID : integer;}
  DateStr : string;
begin
  dmData.zqAssets.Active:= False;
  dmData.zqAssets.SQL.Clear;

  DateStr := dmData.FormatDateSQL('startdate');

  dmData.zqAssets.SQL.Add(
{
select assetid, assetname, startdate, value, valuechange,
valuechangerate,
cast(round(julianday('now') - julianday(startdate)) as integer) daysbetween,
cast(round(julianday('now') - julianday(startdate)) as integer) / 365 years,
(value / 100) * valuechangerate changeperyear,
(cast(round(julianday('now') - julianday(startdate)) as integer) / 365) *
((value / 100) * valuechangerate) changevalue,

value + (cast(round(julianday('now') - julianday(startdate)) as integer) / 365) *
((value / 100) * valuechangerate) appreciatevalue,

value - (cast(round(julianday('now') - julianday(startdate)) as integer) / 365) *
((value / 100) * valuechangerate) depreciatevalue,

case when valuechange = 'Appreciates' then
value + (cast(round(julianday('now') - julianday(startdate)) as integer) / 365) *
((value / 100) * valuechangerate)
when valuechange = 'Depreciates' then
value - (cast(round(julianday('now') - julianday(startdate)) as integer) / 365) *
((value / 100) * valuechangerate)
else value
end as newvalue
}

  {    ' select assetid, assetname, startdate, value, valuechange, valuechangerate, '+
    ' notes, assettype, ' +
    DateStr + ' frmstartdate '+
    ' from '+dmData.ztAssets.TableName}

    //change rate calculation needs to update on a per year basis rather than in one go. ie
    // something 5 years need to do the calculation 5 times

    ' select assetid, assetname, startdate, value, valuechange, '+
    ' valuechangerate,  notes, assettype,  '+
    DateStr + ' frmstartdate '+
{    ' case when valuechange = ''Appreciates'' then '+
    ' value + (cast(round(julianday(''now'') - julianday(startdate)) as integer) / 365) * '+
    ' ((value / 100) * valuechangerate) '+
    ' when valuechange = ''Depreciates'' then '+
    ' value - (cast(round(julianday(''now'') - julianday(startdate)) as integer) / 365) * '+
    ' ((value / 100) * valuechangerate) '+
    ' else value '+
    ' end as CURRENTVALUE '+}
    ' from '+dmData.ztAssets.TableName
    );

  dmData.zqAssets.ExecSQL;
  dmData.zqAssets.Active:= True;

  dmdata.LoadGridLayout(dbgAssets);

//  dmData.SpoolQueryToSQLSpy(dmData.zqAssets);
end;

procedure TfrMain.UpdateGridColours(Colour1, Colour2 : TColor);
begin
  dbgBankAccount.Color := Colour1;
  dbgBankAccount.AlternateColor := Colour2;

  dbgAssets.Color := Colour1;
  dbgAssets.AlternateColor := Colour2;

  dbgPayees.Color := Colour1;
  dbgPayees.AlternateColor := Colour2;

  dbgRepTrans.Color := Colour1;
  dbgRepTrans.AlternateColor := Colour2;

  dbgBankAccount.Color := Colour1;
  dbgBankAccount.AlternateColor := Colour2;
end;

procedure TfrMain.ShowDatabaseLocation;
var ShowLocation : boolean;
begin
  ShowLocation := dmData.GetInfoSettingsBool('SHOW_DATABASELOCATION', true);
  if ShowLocation then
    frMain.Caption := 'CredEdit : '+dmData.DatabaseLocation
  else
    frMain.Caption := 'CredEdit';
end;

procedure TfrMain.CreateCalendarBar(GroupBox : TGroupBox);
var NumofDays, LabelTop, LabelLeft, i,LabelGap, TextWidth : integer;
  myDate, LoopDate : TDateTime;
  myYear, myMonth, myDay : Word;
  DayText : TLabel;
  IncYear, IncMonth : Boolean;
begin
  GroupBox.Caption:= '';
  myDate := date;
  DecodeDate(myDate, myYear, myMonth, myDay);
{  LabelTop := 10;
  LabelLeft := 15;
  groupbox.Height:= 58}
  LabelGap := 8;
  //slim display settings
  LabelTop := 3;
  LabelLeft := 10;
  groupbox.Height:= 48;
  TextWidth := 7;
  NumofDays := DaysInAMonth(myYear, myMonth);

  IncYear := False;
  IncMonth := False;

  GroupBox.Caption:= LongMonthNames[myMonth] + ' ' +IntToStr(myYear);
  GroupBox.Font.Style := [fsbold];

  //Grab month name
  if IncMonth then
  begin
    DayText := TLabel.Create(self);
    with DayText do
    begin
      Caption:= LongMonthNames[myMonth];
      Top:= LabelTop;
      Left:= LabelLeft;
      Visible:= True;
  //    Parent := self;
      Parent := groupbox;
      ParentFont := true;
      Name:= 'DayText'+Caption;
      font.Color := clDefault;
      Font.Style := [fsBold];
      Autosize := True;
  //    Font.size :=12;}
  //    Font.Name := 'Arial Bold';
  //      Font.Style := [fsBold];}
  //    Alignment := taCenter;
      OptimalFill := false;
      LabelLeft := LabelLeft + TextWidth{DayText.Width} + LabelGap;
    end;
  end;

  //Grab days in month
  for i := 1 to NumofDays do
  begin
    if i > 9 then TextWidth := 14;
    DayText := TLabel.Create(self);
    with DayText do
    begin
      Caption:= IntToStr(i);
      Top:= LabelTop;
      Left:= LabelLeft;
      Visible:= True;
      Parent := groupbox;
      ParentFont := true;
      AutoSize := True;
      Name:= 'DayText'+IntToStr(i);
      LoopDate := EncodeDate(myYear, myMonth, i);
      case DayOfWeek(LoopDate) of
        1 : font.Color:= clRed;
        2 : font.Color := clDefault;
        3 : font.Color := clDefault;
        4 : font.Color := clDefault;
        5 : font.Color := clDefault;
        6 : font.Color := clDefault;
        7 : font.Color:= clRed;
      end;

      if LoopDate = myDate then
        Font.Style := [fsBold]         //Maybe increase font size too?
      else
        Font.Style := [];

//      Font.size :=12;
//      Font.Name := 'Arial Bold';
//      Font.Style := [fsBold];}
      OptimalFill := false;
      DayText.Alignment := taCenter;
      LabelLeft := LabelLeft + {DayText.Width} TextWidth + LabelGap;
    end;
  end;

  //Grab year name
  if IncYear then
  begin
    DayText := TLabel.Create(self);
    with DayText do
    begin
      Caption:= IntToStr(myYear);
      Top:= LabelTop;
      Left:= LabelLeft;
      Visible:= True;
      Parent := groupbox;
      ParentFont := true;
      Name:= 'DayText'+Caption;
      font.Color := clDefault;
      Font.Style := [fsBold];
      Autosize := True;
  //    Font.size :=12;
  //    Font.Name := 'Arial Bold';
  //      Font.Style := [fsBold];}
  //    Alignment := taCenter;
      OptimalFill := false;
      LabelLeft := LabelLeft + TextWidth{DayText.Width} + LabelGap;
    end;
  end;
  groupbox.Width:= LabelLeft + LabelGap;
end;

procedure TfrMain.DisplayRepeatingTransactionsGrid;
var DateStr, DateStr2, DateFilter, FilterText, FromDateStr, ToDateStr : string;
  NumofDays, NumofDaysYear, StartDay, EndDay : integer;
  myDate : TDateTime;
  myYear, myMonth, myDay : Word;
begin
  if cbRepTransFilter.Text = 'Overdue Transactions' then
  begin
    FromDateStr := FormatDateTime('YYYY-MM-DD',now);
    FilterText := ' and rt.NEXTOCCURRENCEDATE < '+QuotedStr(FromDateStr);
  end else
  if cbRepTransFilter.Text = 'Due Today' then
  begin
    FromDateStr := FormatDateTime('YYYY-MM-DD',now);
    FilterText := ' and rt.NEXTOCCURRENCEDATE = '+QuotedStr(FromDateStr);
  end else
  if cbRepTransFilter.Text = 'Due This Week' then
  begin
    dmdata.SetupBetweenDatesSQL(FromDateStr, ToDateStr, dqCurrentWeek);
    FilterText := ' and rt.NEXTOCCURRENCEDATE >= '+QuotedStr(FromDateStr);
    FilterText := FilterText + ' and rt.NEXTOCCURRENCEDATE <= '+QuotedStr(ToDateStr);
  end else
  if cbRepTransFilter.Text = 'Due This Month' then
  begin
    dmdata.SetupBetweenDatesSQL(FromDateStr, ToDateStr, dqCurrentMonth);
    FilterText := ' and rt.NEXTOCCURRENCEDATE >= '+QuotedStr(FromDateStr);
    FilterText := FilterText + ' and rt.NEXTOCCURRENCEDATE <= '+QuotedStr(ToDateStr);
  end else
  if cbRepTransFilter.Text = 'Due This Quarter' then
  begin
    dmdata.SetupBetweenDatesSQL(FromDateStr, ToDateStr, dqCurrentQuarter);
    FilterText := ' and rt.NEXTOCCURRENCEDATE >= '+QuotedStr(FromDateStr);
    FilterText := FilterText + ' and rt.NEXTOCCURRENCEDATE <= '+QuotedStr(ToDateStr);
  end else FilterText := '';

  dmData.zqRepeatTransactions.Active:= False;
  dmData.zqRepeatTransactions.SQL.Clear;
  DateStr := dmData.FormatDateSQL('transdate');
  DateStr2 := dmData.FormatDateSQL('NEXTOCCURRENCEDATE');
  dmData.zqRepeatTransactions.SQL.Add(
    ' select a.accountname, p.payeename, rt.*, '+
    DateStr + ' frmtrandate, '+
    DateStr2 + ' frmnextdate, '+
    ' case rt.repeats '+
    ' when 1 then ''Weekly'' '+
    ' when 2 then ''Bi-Weekly'' '+
    ' when 3 then ''Monthly'' '+
    ' when 4 then ''Bi-Monthly'' '+
    ' when 5 then ''Quartertly'' '+
    ' when 6 then ''Half-Yearly'' '+
    ' when 7 then ''Yearly'' '+
    ' when 8 then ''Four Months'' '+
    ' when 9 then ''Four Weeks'' '+
    ' when 10 then ''Daily'' '+
    ' when 11 then ''In (x) Days'' '+
    ' when 12 then ''In (x) Months'' '+
    ' when 13 then ''Every (x) Days'' '+
    ' when 14 then ''Every (x) Months'' '+
    ' when 15 then ''Monthly (last day)'' '+
    ' when 16 then ''Monthly (last business day)'' '+
    ' else ''None'' end as FREQUENCY '+
    ' from '+dmData.ztRepeatTransactions.TableName+' rt, '+dmData.ztAccountList.TableName+' a, '+dmData.ztPayee.TableName+' p '+
    ' where a.accountid = rt.accountid '+
    FilterText +
    ' and p.payeeid = rt.payeeid '
    );
  dmData.zqRepeatTransactions.ExecSQL;
  dmData.zqRepeatTransactions.Active:= True;
  dmdata.LoadGridLayout(dbgRepTrans);
end;

procedure TfrMain.DisplayUpcomingTransactionsGrid;
var DateStr, DateStr2,  TranDatefilter,  FromDateStr, ToDateStr : string;
begin
  dmdata.SetupBetweenDatesSQL(FromDateStr, ToDateStr, dqCurrentWeek);
  TranDatefilter := ' and rt.NEXTOCCURRENCEDATE >= '+QuotedStr(FromDateStr);
  TranDatefilter := TranDatefilter + ' and rt.NEXTOCCURRENCEDATE <= '+QuotedStr(ToDateStr);

  dmData.zqUpcomingTrans.Active:= False;
  dmData.zqUpcomingTrans.SQL.Clear;
  DateStr := dmData.FormatDateSQL('transdate');
  DateStr2 := dmData.FormatDateSQL('NEXTOCCURRENCEDATE');
  dmData.zqUpcomingTrans.SQL.Add(
    ' select a.accountname, p.payeename, rt.*, '+
    DateStr + ' frmtrandate, '+
    DateStr2 + ' frmnextdate, '+
    ' case rt.repeats '+
    ' when 0 then ''None'' '+
    ' when 1 then ''Weekly'' '+
    ' when 2 then ''Bi-Weekly'' '+
    ' when 3 then ''Monthly'' '+
    ' when 4 then ''Bi-Monthly'' '+
    ' when 5 then ''Quartertly'' '+
    ' when 6 then ''Half-Yearly'' '+
    ' when 7 then ''Yearly'' '+
    ' when 8 then ''Four Months'' '+
    ' when 9 then ''Four Weeks'' '+
    ' when 10 then ''Daily'' '+
    ' when 11 then ''In (x) Days'' '+
    ' when 12 then ''In (x) Months'' '+
    ' when 13 then ''Every (x) Days'' '+
    ' when 14 then ''Every (x) Months'' '+
    ' when 15 then ''Monthly (last day)'' '+
    ' when 16 then ''Monthly (last business day)'' '+
    ' else ''None'' end as FREQUENCY '+
    ' from '+dmData.ztRepeatTransactions.TableName+' rt, '+dmData.ztAccountList.TableName+' a, '+dmData.ztPayee.TableName+' p '+
    ' where a.accountid = rt.accountid '+
    ' and p.payeeid = rt.payeeid '+
    TranDatefilter
    );
  dmData.zqUpcomingTrans.ExecSQL;
  dmData.zqUpcomingTrans.Active:= True;
  dmdata.LoadGridLayout(dbgUpcomingTrans);
end;


procedure TfrMain.PopulateBudgetsGrid;
var i, j, SubCatCnt,TotCnt, BudgetYearID,PrevCatID : integer;
  CatSQL, SubCatSQL, BudgetSQL : TZQuery;
  TotAmount, TotEstimated, TotActual,
  GrandTotAmount, GrandTotEstimated, GrandTotActual, TempTot, ActTot,
  EstimatedIncome, EstimatedExpenses, ActualIncome, ActualExpenses: Float;
  FromDate , ToDate,
  BudgetAccountStr : String;
  Node, parentNode : TTreeNode;

  procedure PopulateBudgetDetails(CatId, SubCatId, BudgetYearId : Integer);
  begin
    BudgetSQL.Active:= False;
    BudgetSQL.ParamByName('categid').AsInteger := CatId;
    BudgetSQL.ParamByName('subcategid').AsInteger := SubCatId;
    BudgetSQL.ParamByName('budgetyearid').AsInteger := BudgetYearId;
    BudgetSQL.ExecSQL;
    BudgetSQL.Active:= True;
    if BudgetSQL.RecordCount > 0 then
    begin
      sgBudget.Cells[sgBudgetBudgetEntryID, i+SubCatCnt+TotCnt] := BudgetSQL.FieldByName('BUDGETENTRYID').AsString;
      sgBudget.Cells[sgBudgetFrequency, i+SubCatCnt+TotCnt] := BudgetSQL.FieldByName('PERIOD').AsString;
//      sgBudget.Cells[sgBudgetAmount, i+SubCatCnt+TotCnt] := dmdata.CurrencyStr2DP(BudgetSQL.FieldByName('AMOUNT').AsString);
      sgBudget.Cells[sgBudgetAmount, i+SubCatCnt+TotCnt] := dmdata.ConvertFloatToCurrencyString(BudgetSQL.FieldByName('AMOUNT').AsCurrency);

      if (PBudgetYearRec(tvNavigation.Selected.Data) <> nil) then
        TempTot := dmData.CalcEstimatedAmount(BudgetSQL.FieldByName('AMOUNT').AsCurrency,sgBudget.Cells[sgBudgetFrequency, i+SubCatCnt+TotCnt], PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetFrequency)
      else
        TempTot := 0;
//      ActTot := dmData.CategoryActualBalance(CatId, SubCatId, FromDate, ToDate);
//      sgBudget.Cells[sgBudgetActual, i+SubCatCnt+TotCnt] := dmData.CurrencyStr2DP(FloatToStr(ActTot));

//      sgBudget.Cells[sgBudgetEstimated, i+SubCatCnt+TotCnt] := dmData.CurrencyStr2DP(FloatToStr(TempTot));
      sgBudget.Cells[sgBudgetEstimated, i+SubCatCnt+TotCnt] := dmdata.ConvertFloatToCurrencyString(TempTot);


      if TempTot > 0 then
        EstimatedIncome := EstimatedIncome + TempTot
      else
        EstimatedExpenses := EstimatedExpenses + TempTot;
    end else
    begin
      sgBudget.Cells[sgBudgetFrequency, i+SubCatCnt+TotCnt] := 'None';
      sgBudget.Cells[sgBudgetAmount, i+SubCatCnt+TotCnt] := '0'+DecimalPlacesStr;
      sgBudget.Cells[sgBudgetEstimated, i+SubCatCnt+TotCnt] := '0'+DecimalPlacesStr;
//      sgBudget.Cells[sgBudgetActual, i+SubCatCnt+TotCnt] := '0.00';
    end;
    if (PBudgetYearRec(tvNavigation.Selected.Data) <> nil) then
      ActTot := dmData.CategoryActualBalance(CatId, SubCatId, PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetAccount, FromDate, ToDate)
    else
      ActTot := 0;
    if ActTot > 0 then
    begin
      ActualIncome := ActualIncome + ActTot;
      sgBudget.Cells[sgBudgetIncomeExpense, i+SubCatCnt+TotCnt] := 'Income';
    end else
    begin
      ActualExpenses := ActualExpenses + ActTot;
      sgBudget.Cells[sgBudgetIncomeExpense, i+SubCatCnt+TotCnt] := 'Expense';
    end;
    //sgBudget.Cells[sgBudgetActual, i+SubCatCnt+TotCnt] := dmData.CurrencyStr2DP(FloatToStr(ActTot));
    sgBudget.Cells[sgBudgetActual, i+SubCatCnt+TotCnt] := dmdata.ConvertFloatToCurrencyString(ActTot);
  end;

begin
  Screen.Cursor:= crHourGlass;
  try
    if (PBudgetYearRec(tvNavigation.Selected.Data) = nil) {and (Node.Parent.Text <> 'Budgets')} then
    begin
      BudgetYearID := 0;
      gbBudgetDetails.Caption:= 'Budget Details';
      dmData.UpdateBudgetTotalCaptions(0, 0, 0, 0);
  //    exit;
    end else
      BudgetYearID := PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetYearID;

    EstimatedIncome := 0;
    EstimatedExpenses := 0;
    ActualIncome := 0;
    ActualExpenses := 0;

    sgBudget.BeginUpdate;
  //  sgBudget.Clear;
    sgBudget.RowCount := 1;
    sgBudget.ColCount:= 13;
    sgBudget.Cells[sgBudgetCategoryID, ColumnHeader] := 'CategoryID';
    sgBudget.Cells[sgBudgetCategory, ColumnHeader] := 'Category';
    sgBudget.ColWidths[sgBudgetCategory] := 140;
    sgBudget.Cells[sgBudgetSubcategoryID, ColumnHeader] := 'SubcategoryID';
    sgBudget.Cells[sgBudgetSubcategory, ColumnHeader] := 'Subcategory';
    sgBudget.ColWidths[sgBudgetSubcategory] := 140;
    sgBudget.Cells[sgBudgetFrequency, ColumnHeader] := 'Frequency';
    sgBudget.ColWidths[sgBudgetFrequency] := 100;
    sgBudget.Cells[sgBudgetAmount, ColumnHeader] := 'Amount';
    sgBudget.ColWidths[sgBudgetAmount] := 80;
    sgBudget.Cells[sgBudgetEstimated, ColumnHeader] := 'Estimated';
    sgBudget.ColWidths[sgBudgetEstimated] := 80;
    sgBudget.Cells[sgBudgetActual, ColumnHeader] := 'Actual';
    sgBudget.ColWidths[sgBudgetActual] := 80;
    sgBudget.Cells[sgBudgetBudgetEntryID, ColumnHeader] := 'BudgetEntryID';
    sgBudget.Cells[sgBudgetBudgetYearID, ColumnHeader] := 'BudgetYearID';
    sgBudget.Cells[sgBudgetCategoryColour, ColumnHeader] := 'CategoryColour';
    sgBudget.Cells[sgBudgetIncomeExpense, ColumnHeader] := 'BudgetType';

    if dmData.DebugMode = false then
    begin
      sgBudget.ColWidths[sgBudgetCategoryID] := 0;
      sgBudget.ColWidths[sgBudgetSubcategoryID] := 0;
      sgBudget.ColWidths[sgBudgetBudgetEntryID] := 0;
      sgBudget.ColWidths[sgBudgetBudgetYearID] := 0;
      sgBudget.ColWidths[sgBudgetCategoryColour] := 0;
      sgBudget.ColWidths[sgBudgetIncomeExpense] := 0;
    end else
    begin
      sgBudget.ColWidths[sgBudgetCategoryID] := 80;
      sgBudget.ColWidths[sgBudgetSubcategoryID] := 80;
      sgBudget.ColWidths[sgBudgetBudgetEntryID] := 80;
      sgBudget.ColWidths[sgBudgetBudgetYearID] := 80;
      sgBudget.ColWidths[sgBudgetCategoryColour] := 80;
      sgBudget.ColWidths[sgBudgetIncomeExpense] := 80;
    end;
    CatSQL := TZQuery.create(nil);
    CatSQL.Connection := dmData.zcDatabaseConnection;
    CatSQL.SQL.Clear;
    CatSQL.SQL.Add(
    ' select * '+
    ' from '+dmdata.ztCategory.TableName+
    ' where ifnull(includebudget, ''0'') = ''1'' '+
    ' order by categname '
    );
    CatSQL.ExecSQL;
    CatSQL.Active:= True;

    SubCatSQL := TZQuery.create(nil);
    SubCatSQL.Connection := dmData.zcDatabaseConnection;
    SubCatSQL.SQL.Clear;
    SubCatSQL.SQL.Add(
    ' select * '+
    ' from '+dmdata.ztSubCategory.TableName+
    ' where categid = :categid'+
    ' and ifnull(includebudget, ''0'') = ''1'' '+
    ' order by subcategname '
    );

    BudgetSQL := TZQuery.create(nil);
    BudgetSQL.Connection := dmData.zcDatabaseConnection;
    BudgetSQL.SQL.Clear;
    BudgetSQL.SQL.Add(
    ' select * '+
    ' from '+dmdata.ztBudget.TableName+
    ' where categid = :categid '+
    ' and subcategid = :subcategid '+
    ' and budgetyearid = :budgetyearid '
    );

    SubCatCnt := 0;
    TotCnt := 0;
    PrevCatID := 0;
    GrandTotAmount := 0;
    GrandTotEstimated := 0;
    GrandTotActual := 0;
    if (PBudgetYearRec(tvNavigation.Selected.Data) <> nil) then
    begin
      FromDate := PBudgetYearRec(tvNavigation.Selected.Data)^.FromDate;
      ToDate := PBudgetYearRec(tvNavigation.Selected.Data)^.ToDate;
    end else
    begin
      FromDate := '';
      ToDate := '';
    end;

    for i:= 1 to CatSQL.RecordCount do
    begin
      //Add Category row
      if PrevCatID <> CatSQL.FieldByName('CATEGID').AsInteger then
      begin
        TotAmount := 0;
        TotEstimated := 0;
        TotActual := 0;
      end;

      sgBudget.RowCount := sgBudget.RowCount + 1;
      sgBudget.Cells[sgBudgetCategoryID, i+SubCatCnt+TotCnt] := CatSQL.FieldByName('CATEGID').AsString;
      sgBudget.Cells[sgBudgetCategory, i+SubCatCnt+TotCnt] := CatSQL.FieldByName('CATEGNAME').AsString;
      sgBudget.Cells[sgBudgetSubcategoryID, i+SubCatCnt+TotCnt] := '-1';
      sgBudget.Cells[sgBudgetBudgetYearID, i+SubCatCnt+TotCnt] := IntToStr(BudgetYearID);
      sgBudget.Cells[sgBudgetCategoryColour, i+SubCatCnt+TotCnt] := CatSQL.FieldByName('COLOUR').AsString;
      SubCatSQL.ParamByName('categid').AsInteger := CatSQL.FieldByName('CATEGID').AsInteger;
      SubCatSQL.ExecSQL;
      SubCatSQL.Active:= True;

      PopulateBudgetDetails(CatSQL.FieldByName('CATEGID').AsInteger, -1, BudgetYearID);

  {    TotAmount := TotAmount + StrToFloat(sgBudget.Cells[sgBudgetAmount,i+SubCatCnt+TotCnt]);
      TotEstimated := TotEstimated + StrToFloat(sgBudget.Cells[sgBudgetEstimated,i+SubCatCnt+TotCnt]);
      TotActual := TotActual + StrToFloat(sgBudget.Cells[sgBudgetActual,i+SubCatCnt+TotCnt]);}
      TotAmount := TotAmount + dmdata.ConvertCurrencyStringToFloat(sgBudget.Cells[sgBudgetAmount,i+SubCatCnt+TotCnt]);
      TotEstimated := TotEstimated + dmdata.ConvertCurrencyStringToFloat(sgBudget.Cells[sgBudgetEstimated,i+SubCatCnt+TotCnt]);
      TotActual := TotActual + dmdata.ConvertCurrencyStringToFloat(sgBudget.Cells[sgBudgetActual,i+SubCatCnt+TotCnt]);

      for j:= 1 to SubCatSQL.RecordCount do
      begin
        //Add subcategory row(s)
        SubCatCnt := SubCatCnt + 1;
        sgBudget.RowCount := sgBudget.RowCount + 1;
          sgBudget.Cells[sgBudgetCategoryID, i+SubCatCnt+TotCnt] := CatSQL.FieldByName('CATEGID').AsString;
  //        sgBudget.Cells[sgBudgetCategory, i+SubCatCnt+TotCnt] := CatSQL.FieldByName('CATEGNAME').AsString;
        sgBudget.Cells[sgBudgetCategoryColour, i+SubCatCnt+TotCnt] := CatSQL.FieldByName('COLOUR').AsString;
        sgBudget.Cells[sgBudgetSubcategoryID, i+SubCatCnt+TotCnt] := SubCatSQL.FieldByName('SUBCATEGID').AsString;
        sgBudget.Cells[sgBudgetSubcategory, i+SubCatCnt+TotCnt] := SubCatSQL.FieldByName('SUBCATEGNAME').AsString;
        sgBudget.Cells[sgBudgetBudgetYearID, i+SubCatCnt+TotCnt] := IntToStr(BudgetYearID);

        PopulateBudgetDetails(SubCatSQL.FieldByName('CATEGID').AsInteger, SubCatSQL.FieldByName('SUBCATEGID').AsInteger, BudgetYearID);
  {      TotAmount := TotAmount + StrToFloat(sgBudget.Cells[sgBudgetAmount,i+SubCatCnt+TotCnt]);
        TotEstimated := TotEstimated + StrToFloat(sgBudget.Cells[sgBudgetEstimated,i+SubCatCnt+TotCnt]);
        TotActual := TotActual + StrToFloat(sgBudget.Cells[sgBudgetActual,i+SubCatCnt+TotCnt]);}
        TotAmount := TotAmount + dmdata.ConvertCurrencyStringToFloat(sgBudget.Cells[sgBudgetAmount,i+SubCatCnt+TotCnt]);
        TotEstimated := TotEstimated + dmdata.ConvertCurrencyStringToFloat(sgBudget.Cells[sgBudgetEstimated,i+SubCatCnt+TotCnt]);
        TotActual := TotActual + dmdata.ConvertCurrencyStringToFloat(sgBudget.Cells[sgBudgetActual,i+SubCatCnt+TotCnt]);
        SubCatSQL.Next;
      end;

      //Add Total row
      sgBudget.RowCount := sgBudget.RowCount + 1;
      TotCnt := TotCnt + 1;
      sgBudget.Cells[sgBudgetCategoryID, i+SubCatCnt+TotCnt] := CatSQL.FieldByName('CATEGID').AsString;

  //    sgBudget.Cells[sgBudgetAmount, i+SubCatCnt+TotCnt] := dmData.CurrencyStr2DP(FloatToStr(TotAmount));
  {    sgBudget.Cells[sgBudgetEstimated, i+SubCatCnt+TotCnt] := dmData.CurrencyStr2DP(FloatToStr(TotEstimated));
      sgBudget.Cells[sgBudgetActual, i+SubCatCnt+TotCnt] := dmData.CurrencyStr2DP(FloatToStr(TotActual));}
      sgBudget.Cells[sgBudgetEstimated, i+SubCatCnt+TotCnt] := dmdata.ConvertFloatToCurrencyString(TotEstimated);
      sgBudget.Cells[sgBudgetActual, i+SubCatCnt+TotCnt] := dmdata.ConvertFloatToCurrencyString(TotActual);
      GrandTotAmount := GrandTotAmount + TotAmount;
      GrandTotEstimated := GrandTotEstimated + TotEstimated;
      GrandTotActual := GrandTotActual + TotActual;
      //sgBudget.Cells[sgBudgetBudgetYearID, i+SubCatCnt+TotCnt] := IntToStr(BudgetYearID);
      CatSQL.Next;
    end;

    //Grand Totals
    sgBudget.RowCount := sgBudget.RowCount + 1;
    TotCnt := TotCnt + 1;
    if sgBudget.RowCount > 2 then
    begin
      //  sgBudget.Cells[sgBudgetFrequency, i+SubCatCnt+TotCnt] := 'Grand Totals:';
        //sgBudget.Cells[sgBudgetAmount, i+SubCatCnt+TotCnt] := dmData.CurrencyStr2DP(FloatToStr(GrandTotAmount));
      sgBudget.Cells[sgBudgetAmount, i+SubCatCnt+TotCnt] := 'Grand Totals:';
    {  sgBudget.Cells[sgBudgetEstimated, i+SubCatCnt+TotCnt] := dmData.CurrencyStr2DP(FloatToStr(GrandTotEstimated));
      sgBudget.Cells[sgBudgetActual, i+SubCatCnt+TotCnt] := dmData.CurrencyStr2DP(FloatToStr(GrandTotActual));}
      sgBudget.Cells[sgBudgetEstimated, i+SubCatCnt+TotCnt] := dmdata.ConvertFloatToCurrencyString(GrandTotEstimated);
      sgBudget.Cells[sgBudgetActual, i+SubCatCnt+TotCnt] := dmdata.ConvertFloatToCurrencyString(GrandTotActual);
    end;

    sgBudget.EndUpdate(True);

    if (PBudgetYearRec(tvNavigation.Selected.Data) <> nil) then
    begin
      if PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetAccount = '[All Accounts]' then
        BudgetAccountStr := 'All Accounts'
      else
        BudgetAccountStr := PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetAccount;

      PBudgetYearRec(tvNavigation.Selected.Data)^.EstimatedExpenses := EstimatedExpenses;
      PBudgetYearRec(tvNavigation.Selected.Data)^.EstimatedIncome := EstimatedIncome;
      PBudgetYearRec(tvNavigation.Selected.Data)^.ActualExpenses := ActualExpenses;
      PBudgetYearRec(tvNavigation.Selected.Data)^.ActualIncome := ActualIncome;
      dmData.UpdateBudgetTotalCaptions(EstimatedIncome, EstimatedExpenses, ActualIncome, ActualExpenses);
      gbBudgetDetails.Caption:= PBudgetYearRec(tvNavigation.Selected.Data)^.BudgetYearName + ' ('+
        BudgetAccountStr + ' - '+
        dmdata.FormatDateToDisplayFormat(PBudgetYearRec(tvNavigation.Selected.Data)^.FromDate) + ' : '+
        dmdata.FormatDateToDisplayFormat(PBudgetYearRec(tvNavigation.Selected.Data)^.ToDate)+')';
    end;

  finally
    BudgetSQL.Free;
    SubCatSQL.Free;
    CatSQL.Free;
  end;
  Screen.Cursor:= crDefault;

  //fix labels from not showing (sometimes)
  gbBudgetDetails.Refresh;

  if (PBudgetYearRec(tvNavigation.Selected.Data) = nil) then miBudgetEditorClick(nil);
end;

procedure TfrMain.CreateBudgetSetupItems;
var i : integer;
    ParentNode, newNode : TTreeNode;
    MyBudgetYearRec: PBudgetYearRec;
    myDate : TDateTime;
    myYear, myMonth, myDay : Word;
    NumofDays, NumofDaysYear, Year, Month : integer;
    YearStr, MonthStr, FromDate, ToDate : String;
begin
  Screen.Cursor:= crHourGlass;
  myDate := date;
  DecodeDate(myDate, myYear, myMonth, myDay);
//  NumofDays := DaysInAMonth(myYear, myMonth);
  ParentNode := dmData.GetNodeByText(tvNavigation, 'Budgets', false);
  if ParentNode = nil then
    ShowMessage('Not found!')
  else begin
//      tvNavigation.SetFocus;
    ParentNode.Selected := True;
    //Delete any nodes currently under Budget. ** will need to free pointers too
    ParentNode.DeleteChildren;
  end;

  dmData.ztBudgetYear.First;
  for i:= 1 to dmData.ztBudgetYear.RecordCount do
  begin
    if dmData.ztBudgetYear.FieldByName('ARCHIVED').AsString <> '1' then
    begin
      FromDate := '';
      ToDate := '';
      New(MyBudgetYearRec);
      MyBudgetYearRec^.BudgetAccount := dmData.ztBudgetYear.FieldByName('BudgetAccount').AsString;
      MyBudgetYearRec^.BudgetYearID :=  dmData.ztBudgetYear.FieldByName('BudgetYearID').AsInteger;
      MyBudgetYearRec^.BudgetYearName:= dmData.ztBudgetYear.FieldByName('BudgetYearName').AsString;
      MyBudgetYearRec^.BudgetFrequency:= dmData.ztBudgetYear.FieldByName('BUDGETFREQUENCY').AsString;
      YearStr := dmData.ztBudgetYear.FieldByName('BUDGETYEAR').AsString;
      MonthStr := dmData.ztBudgetYear.FieldByName('BUDGETMONTH').AsString;
      Year := StrToInt(YearStr);
      if dmData.ztBudgetYear.FieldByName('BUDGETFREQUENCY').AsString = 'Yearly' then
      begin
        FromDate := YearStr +'-01-01';
        ToDate := YearStr +'-12-31';
      end else
      if dmData.ztBudgetYear.FieldByName('BUDGETFREQUENCY').AsString = 'Monthly' then
      begin
        if MonthStr = '' then MonthStr := '1';
        Month := StrToInt(MonthStr);
        if Month < 10 then MonthStr := '0'+IntToStr(Month);
        NumofDays := DaysInAMonth(Year, Month);
        FromDate := YearStr+'-'+MonthStr+'-01';
        ToDate := YearStr+'-'+MonthStr+'-'+IntToStr(NumofDays);
      end;
      MyBudgetYearRec^.FromDate:=FromDate;
      MyBudgetYearRec^.ToDate:=ToDate;

      newNode := frMain.tvNavigation.Items.addChildObject(ParentNode, dmData.ztBudgetYear.FieldByName('BudgetYearName').AsString, MyBudgetYearRec);
      newNode.SelectedIndex:=23;
      newNode.ImageIndex:=23;
    end;
    dmData.ztBudgetYear.Next;
  end;
  Screen.Cursor:= crDefault;
end;

procedure TfrMain.DisplayPayeesGrid;
var Filter : string;
begin
  if cbPayeeFilterList.Text = 'Payees with no Category' then
    Filter := 'where ifnull(p.categid, '''') = ''''  or p.categid = -1 '
  else
  if cbPayeeFilterList.Text = 'All Payees' then
    Filter := ''
  else
  if cbPayeeFilterList.Text = 'Payees with no Colour' then
    Filter := 'where p.colour = ''clDefault'' ';

  dmData.zqPayee.Active:= False;
  dmData.zqPayee.SQL.Clear;
  dmData.zqPayee.SQL.Add(
    ' select p.*, '+
    ' case ifnull(p.categid, '''') when '''' then '''' else '+
    ' case p.categid when 0 then '+chr(39)+chr(39)+' else '+
    ' case p.categid when -1 then '+chr(39)+chr(39)+
    ' else '+
    '   case p.subcategid when -1 then categname '+
    '   else coalesce(categname,'+chr(39)+chr(39)+') ||'+chr(39)+': '+chr(39)+'||coalesce(subcategname,'+chr(39)+chr(39)+') '+
    '   end '+
    ' end end end as category '+
    ' from '+dmData.ztPayee.TableName+' p '+
    ' left outer join '+dmData.ztCategory.TableName+' c on p.categid = c.categid '+
    ' left outer join '+dmData.ztSubCategory.TableName+' sc on c.categid = sc.categid and p.subcategid = sc.subcategid '+
    Filter
    );
  dmData.zqPayee.ExecSQL;
  dmData.zqPayee.Active:= True;
  dmdata.LoadGridLayout(dbgPayees);
end;

procedure TfrMain.tbMouseMove(ToolButton : TToolButton);
begin
  if dmData.MouseOver = False then
  begin
    ToolButton.Cursor:=crDefault;
    exit;
  end;
  if ToolButton.MouseEntered then
    ToolButton.Cursor:=crHandPoint
  else
    ToolButton.Cursor:=crDefault;
end;

procedure TfrMain.sbMouseMove(SpeedButton : TSpeedButton);
begin
  if dmData.MouseOver = False then
  begin
    SpeedButton.Cursor:=crDefault;
    exit;
  end;
  if SpeedButton.MouseEntered then
    SpeedButton.Cursor:=crHandPoint
  else
    SpeedButton.Cursor:=crDefault;
end;

procedure TfrMain.dbgMouseMove(DBGrid : TDBGrid; X, Y: Integer);
var pt: TGridcoord;
begin
  if dmData.MouseOver = False then
  begin
    DBGrid.Cursor:=crDefault;
    exit;
  end;

  pt:= DBGrid.MouseCoord(x, y);

  if pt.y=0 then
    DBGrid.Cursor:=crHandPoint
  else
    DBGrid.Cursor:=crDefault;
end;

procedure TfrMain.dbgMouseDown(DBGrid : TDBGrid; X, Y: Integer);
begin
  if Y<DBGrid.DefaultRowHeight then DBGrid.PopupMenu := nil else DBGrid.PopupMenu :=pmGrids;
end;

procedure TfrMain.SetBudgetFilter(ACol:Integer;FilterExp:String);
var I,Counter:Integer;
begin
{  FilterList:=TStringList.Create;}
  With sgBudget do
  begin
{    For I := FixedRows To RowCount - 1 Do
      FilterList.Add(Rows[I].Text);}

    Counter:=FixedRows;
    For I := FixedRows To RowCount - 1 Do
    Begin
      If Cells[ACol,I] <> FilterExp Then
      Begin
         Rows[I].Clear;
      end
      Else
      begin
         If Counter <> I Then
         Begin
           Rows[Counter].Assign(Rows[I]);
           Rows[I].Clear;
         End;
         Inc(Counter);
      End;
    End;
    RowCount:=Counter;

  End;
end;

procedure TfrMain.RestoreBudgetFilter;
{var
  I:Integer;}
begin
{  With sgBudget do
  begin
    RowCount:=FixedRows+FilterList.Count;
    For I:=0 To FilterList.Count - 1 Do
        Rows[FixedRows+I].Text := FilterList.Strings[I];
  End;
  FilterList.Free;}
  PopulateBudgetsGrid;
end;

end.

