{ To do list:

http://delphi.about.com/od/adptips2005/qt/sqlformatvalue.htm

  1. Add support for multiple currencies, and formatting.
  2. Add a description field to category, sub category, and payee tables.

}

unit uDataModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, LR_Class, LR_DBSet, LR_E_TXT, LR_E_HTM,
  LR_E_CSV, ZDataset, ZConnection, ZSqlMonitor, controls, ZSqlUpdate, StdCtrls,
  math, forms, Dialogs, base64, dateutils, graphics, LCLIntf, ExtCtrls,
  ComCtrls, Grids, DBGrids, variants, ComObj;

type

  { TdmData }

  TDateQuery = (dqCurrentWeek, dqCurrentMonth, dqCurrentYear, dqCurrentQuarter);

{  TDatesTypes = (trNone, trWeekly, trBiWeekly, trMonthly, trBiMonthly, trQuartertly,
    trHalfYearly, trYearly, trFourMonths, trFourWeeks, trDaily, trInXDays, trInXMonths,
    trEveryXDays, trEveryXMonths, trMonthlyLastDay, trMonthlyLastBusinessDay);}

  TdmData = class(TDataModule)
    dsRepFilters: TDataSource;
    dsGridSettings: TDataSource;
    dsqBankAccounts: TDataSource;
    dsRepeatSplitTransactions: TDataSource;
    dszqPayee: TDataSource;
    dszqPayeeImport: TDataSource;
    dszqTodaysRepTrans: TDataSource;
    dsztPayeeImport: TDataSource;
    dszqHomepageRep1: TDataSource;
    dszqHomepageRep2: TDataSource;
    dszqUpcomingTrans: TDataSource;
    dsTransFilter: TDataSource;
    dszqBudgetYear: TDataSource;
    dszqTransFilters: TDataSource;
    dsZQuery1: TDataSource;
    dszqRepeatTransactions: TDataSource;
    dsRepeatTransactions: TDataSource;
    dsqBudget: TDataSource;
    dsSplitTransactions: TDataSource;
    dsqSplitTransactions: TDataSource;
    dszqTransactions: TDataSource;
    dsqCategories: TDataSource;
    dsBudget: TDataSource;
    dsBudgetYear: TDataSource;
    dsInfoTable: TDataSource;
    dsqAssets: TDatasource;
    dsAccountList: TDatasource;
    dsAssets: TDatasource;
    dsCategory: TDatasource;
    dsCheckingAccount: TDatasource;
    dsPayee: TDatasource;
    dsSubCategory: TDatasource;
    dszqReport: TDataSource;
    frCSVExport1: TfrCSVExport;
    frDBDataSet1: TfrDBDataSet;
    frHTMExport1: TfrHTMExport;
    frReport1: TfrReport;
    frTextExport1: TfrTextExport;
    MemoField1: TMemoField;
    MemoField2: TMemoField;
    Timer: TTimer;
    zcDatabaseConnection: TZConnection;
    zqAssetsASSETID: TLargeintField;
    zqAssetsASSETNAME: TMemoField;
    zqAssetsASSETTYPE: TMemoField;
    zqAssetsCALCURVALUE1: TCurrencyField;
    zqAssetsfrmstartdate: TStringField;
    zqAssetsNOTES: TMemoField;
    zqAssetsSTARTDATE: TMemoField;
    zqAssetsVALUE: TFloatField;
    zqAssetsVALUECHANGE: TMemoField;
    zqAssetsVALUECHANGERATE: TFloatField;
    zqBankAccounts2chcategid: TLargeintField;
    zqBankAccounts2chnotes: TMemoField;
    zqBankAccounts2chpayeeid: TLargeintField;
    zqBankAccounts2chstatus: TMemoField;
    zqBankAccounts2chsubcategid: TLargeintField;
    zqBankAccounts2chtransactionnumber: TMemoField;
    zqBankAccounts2chtransamount: TFloatField;
    zqBankAccounts2chtranscode: TMemoField;
    zqBankAccounts2chtransdate: TMemoField;
    zqBankAccounts2chtransid: TLargeintField;
    zqBankAccounts2ppayeename: TMemoField;
    zqBankAccountscategory: TStringField;
    zqBankAccountsDEPOSIT: TStringField;
    zqBankAccountsDEPOSITCURRENCY: TFloatField;
    zqBankAccountsfrmtrandate: TStringField;
    zqBankAccountsPAYEE: TStringField;
    zqBankAccountsSTATUSDESCRIPTION1: TStringField;
    zqBankAccountsWITHDRAWAL: TStringField;
    zqBankAccountsWITHDRAWALCURRENCY: TFloatField;
    zqBankAccountsBALANCE: TStringField;
    zqBankAccountsBALANCECURRENCY: TCurrencyField;
    zqBankAccountsCATEGNAME: TMemoField;
    zqBankAccountsNOTES: TMemoField;
    zqBankAccountsPAYEEID: TLargeintField;
    zqBankAccountsPAYEENAME: TMemoField;
    zqBankAccountsSTATUS: TMemoField;
    zqBankAccountsSUBCATEGNAME: TMemoField;
    zqBankAccountsTRANSACTIONNUMBER: TMemoField;
    zqBankAccountsTRANSAMOUNT: TFloatField;
    zqBankAccountsTRANSCODE: TMemoField;
    zqBankAccountsTRANSDATE: TMemoField;
    zqBankAccountsTRANSID: TLargeintField;
    zqBudgetBUDGET_AMOUNT: TStringField;
    zqBudgetBUDGET_ENTRY_ID: TStringField;
    zqBudgetBUDGET_PERIOD: TStringField;
    zqBudgetBUDGET_YEAR_ID: TStringField;
    zqBudgetCATEGID: TLargeintField;
    zqBudgetCATEGNAME: TMemoField;
    zqBudgetSUBCATEGID: TLargeintField;
    zqBudgetSUBCATEGNAME: TMemoField;
    zqBudgetYear: TZQuery;
    zqBudgetYearARCHIVED: TMemoField;
    zqBudgetYearBUDGETACCOUNT: TMemoField;
    zqBudgetYearBUDGETFREQUENCY: TMemoField;
    zqBudgetYearBUDGETMONTH: TMemoField;
    zqBudgetYearBUDGETYEAR: TMemoField;
    zqBudgetYearBUDGETYEARID: TLargeintField;
    zqBudgetYearBUDGETYEARNAME: TMemoField;
    zqBudgetYearMONTHDESCRIPTION1: TStringField;
    zqCategoriesCATEGID: TLargeintField;
    zqCategoriesCATEGNAME: TMemoField;
    zqCategoriesSUBCATEGNAME: TMemoField;
    zqPayeeCATEGID: TLargeintField;
    zqPayeeCATEGORY: TStringField;
    zqPayeeCOLOUR: TMemoField;
    zqPayeeImportMATCHTEXT: TMemoField;
    zqPayeeImportPAYEEID: TLargeintField;
    zqPayeeImportPAYEEIMPORTID: TLargeintField;
    zqPayeeImportPAYEENAME: TMemoField;
    zqPayeePAYEEID: TLargeintField;
    zqPayeePAYEENAME: TMemoField;
    zqPayeeSUBCATEGID: TLargeintField;
    zqRepeatTransactionsACCOUNTID: TLargeintField;
    zqRepeatTransactionsACCOUNTNAME: TMemoField;
    zqRepeatTransactionsCATEGID: TLargeintField;
    zqRepeatTransactionsFOLLOWUPID: TLargeintField;
    zqRepeatTransactionsFREQUENCY: TStringField;
    zqRepeatTransactionsfrmnextdate: TStringField;
    zqRepeatTransactionsfrmtrandate: TStringField;
    zqRepeatTransactionsNEXTOCCURRENCEDATE: TMemoField;
    zqRepeatTransactionsNOTES: TMemoField;
    zqRepeatTransactionsNUMOCCURRENCES: TLargeintField;
    zqRepeatTransactionsPAYEEID: TLargeintField;
    zqRepeatTransactionsPAYEENAME: TMemoField;
    zqRepeatTransactionsREMAININGDAYS1: TStringField;
    zqRepeatTransactionsREPEATS: TLargeintField;
    zqRepeatTransactionsREPTRANSID: TLargeintField;
    zqRepeatTransactionsSTATUS: TMemoField;
    zqRepeatTransactionsSUBCATEGID: TLargeintField;
    zqRepeatTransactionsTOACCOUNTID: TLargeintField;
    zqRepeatTransactionsTOTRANSAMOUNT: TFloatField;
    zqRepeatTransactionsTRANSACTIONNUMBER: TMemoField;
    zqRepeatTransactionsTRANSAMOUNT: TFloatField;
    zqRepeatTransactionsTRANSCODE: TMemoField;
    zqRepeatTransactionsTRANSDATE: TMemoField;
    zqReport: TZQuery;
    zqSplitTransactions: TZQuery;
    zqSplitTransactionsCATEGID: TLargeintField;
    zqSplitTransactionscategory: TStringField;
    zqSplitTransactionsSPLITTRANSAMOUNT: TFloatField;
    zqSplitTransactionsSPLITTRANSID: TLargeintField;
    zqSplitTransactionsSUBCATEGID: TLargeintField;
    zqSplitTransactionsTRANSID: TLargeintField;
    zqTodaysRepTransACCOUNTID: TLargeintField;
    zqTodaysRepTransAUTORUN: TMemoField;
    zqTodaysRepTransAUTORUNUSER: TMemoField;
    zqTodaysRepTransCATEGID: TLargeintField;
    zqTodaysRepTransFOLLOWUPID: TLargeintField;
    zqTodaysRepTransNEXTOCCURRENCEDATE: TMemoField;
    zqTodaysRepTransNOTES: TMemoField;
    zqTodaysRepTransNUMOCCURRENCES: TLargeintField;
    zqTodaysRepTransPAYEEID: TLargeintField;
    zqTodaysRepTransREPEATS: TLargeintField;
    zqTodaysRepTransREPTRANSID: TLargeintField;
    zqTodaysRepTransSTATUS: TMemoField;
    zqTodaysRepTransSUBCATEGID: TLargeintField;
    zqTodaysRepTransTOACCOUNTID: TLargeintField;
    zqTodaysRepTransTOTRANSAMOUNT: TFloatField;
    zqTodaysRepTransTRANSACTIONNUMBER: TMemoField;
    zqTodaysRepTransTRANSAMOUNT: TFloatField;
    zqTodaysRepTransTRANSCODE: TMemoField;
    zqTodaysRepTransTRANSDATE: TMemoField;
    zqTransactionsACCOUNTID: TLargeintField;
    zqTransactionsACCOUNTNAME: TMemoField;
    zqTransactionsBALANCE: TStringField;
    zqTransactionscategory: TStringField;
    zqTransactionsDEPOSIT: TStringField;
    zqTransactionsfrmtrandate: TStringField;
    zqTransactionsNOTES: TMemoField;
    zqTransactionsPAYEENAME: TMemoField;
    zqTransactionsSTATUS: TMemoField;
    zqTransactionsTRANSACTIONNUMBER: TMemoField;
    zqTransactionsTRANSAMOUNT: TFloatField;
    zqTransactionsTRANSCODE: TMemoField;
    zqTransactionsTRANSDATE: TMemoField;
    zqTransactionsTRANSID: TLargeintField;
    zqTransactionsWITHDRAWAL: TStringField;
    zqTransFilters: TZQuery;
    zqTransFiltersARCHIVED: TMemoField;
    zqTransFiltersCATEGID: TFloatField;
    zqTransFiltersCATEGORY: TStringField;
    zqTransFiltersDATEFILTER: TFloatField;
    zqTransFiltersDATERANGE: TStringField;
    zqTransFiltersFROMAMOUNT: TFloatField;
    zqTransFiltersFROMDATE: TMemoField;
    zqTransFiltersPAYEENAME: TMemoField;
    zqTransFiltersSUBCATEGID: TFloatField;
    zqTransFiltersTOAMOUNT: TFloatField;
    zqTransFiltersTODATE: TMemoField;
    zqTransFiltersTRANSCODE: TMemoField;
    zqTransFiltersTRANSFILTERID: TLargeintField;
    zqTransFiltersTRANSFILTERNAME: TMemoField;
    ZQuery1: TZQuery;
    zqAssets: TZQuery;
    zqCategories: TZQuery;
    zqTransactions: TZQuery;
    zqBudget: TZQuery;
    zqRepeatTransactions: TZQuery;
    zqHomepageRep1: TZQuery;
    zqHomepageRep2: TZQuery;
    zqPayeeImport: TZQuery;
    zqPayee: TZQuery;
    zqTodaysRepTrans: TZQuery;
    zqBankAccounts: TZQuery;
    zqUpcomingTrans: TZQuery;
    zqUpcomingTransACCOUNTID: TLargeintField;
    zqUpcomingTransACCOUNTNAME: TMemoField;
    zqUpcomingTransCATEGID: TLargeintField;
    zqUpcomingTransFOLLOWUPID: TLargeintField;
    zqUpcomingTransFREQUENCY: TStringField;
    zqUpcomingTransfrmnextdate: TStringField;
    zqUpcomingTransfrmtrandate: TStringField;
    zqUpcomingTransNEXTOCCURRENCEDATE: TMemoField;
    zqUpcomingTransNOTES: TMemoField;
    zqUpcomingTransNUMOCCURRENCES: TLargeintField;
    zqUpcomingTransPAYEEID: TLargeintField;
    zqUpcomingTransPAYEENAME: TMemoField;
    zqUpcomingTransREMAININGDAYS1: TStringField;
    zqUpcomingTransREPEATS: TLargeintField;
    zqUpcomingTransREPTRANSID: TLargeintField;
    zqUpcomingTransSTATUS: TMemoField;
    zqUpcomingTransSUBCATEGID: TLargeintField;
    zqUpcomingTransTOACCOUNTID: TLargeintField;
    zqUpcomingTransTOTRANSAMOUNT: TFloatField;
    zqUpcomingTransTRANSACTIONNUMBER: TMemoField;
    zqUpcomingTransTRANSAMOUNT: TFloatField;
    zqUpcomingTransTRANSCODE: TMemoField;
    zqUpcomingTransTRANSDATE: TMemoField;
    ZSQLMonitor: TZSQLMonitor;
    ztBudgetYearBUDGETACCOUNT: TMemoField;
    ztRepFilters: TZTable;
    ztGridSettings: TZTable;
    ztGridSettingsCAPTION: TMemoField;
    ztGridSettingsCOLUMNINDEX: TLargeintField;
    ztGridSettingsCOLUMNWIDTH: TLargeintField;
    ztGridSettingsFIELDNAME: TMemoField;
    ztGridSettingsGRIDNAME: TMemoField;
    ztGridSettingsGRIDSETTINGSID: TLargeintField;
    ztGridSettingsVISIBLE: TMemoField;
    ztRepeatSplitTransactions: TZTable;
    ztPayeeImport: TZTable;
    ztBudgetYearARCHIVED: TMemoField;
    ztPayeeImportMATCHTEXT: TMemoField;
    ztPayeeImportPAYEEID: TLargeintField;
    ztPayeeImportPAYEEIMPORTID: TLargeintField;
    ztRepeatSplitTransactionsCATEGID: TLargeintField;
    ztRepeatSplitTransactionsSPLITTRANSAMOUNT: TFloatField;
    ztRepeatSplitTransactionsSPLITTRANSID: TLargeintField;
    ztRepeatSplitTransactionsSUBCATEGID: TLargeintField;
    ztRepeatSplitTransactionsTRANSID: TLargeintField;
    ztRepeatTransactionsAUTORUN: TMemoField;
    ztRepeatTransactionsAUTORUNUSER: TMemoField;
    ztTransFilter: TZTable;
    ztBudgetYearBUDGETFREQUENCY: TMemoField;
    ztBudgetYearBUDGETMONTH: TMemoField;
    ztBudgetYearBUDGETYEAR: TMemoField;
    ztCategoryINCLUDEBUDGET: TMemoField;
    ztRepeatTransactions: TZTable;
    ztCategoryCOLOUR: TMemoField;
    ztCheckingAccountACCOUNTID: TLargeintField;
    ztCheckingAccountCATEGID: TLargeintField;
    ztCheckingAccountFOLLOWUPID: TLargeintField;
    ztCheckingAccountNOTES: TMemoField;
    ztCheckingAccountPAYEEID: TLargeintField;
    ztCheckingAccountSTATUS: TMemoField;
    ztCheckingAccountSUBCATEGID: TLargeintField;
    ztCheckingAccountTOACCOUNTID: TLargeintField;
    ztCheckingAccountTOTRANSAMOUNT: TFloatField;
    ztCheckingAccountTRANSACTIONNUMBER: TMemoField;
    ztCheckingAccountTRANSAMOUNT: TFloatField;
    ztCheckingAccountTRANSCODE: TMemoField;
    ztCheckingAccountTRANSDATE: TMemoField;
    ztCheckingAccountTRANSID: TLargeintField;
    ztPayeeCOLOUR: TMemoField;
    ztRepeatTransactionsACCOUNTID: TLargeintField;
    ztRepeatTransactionsCATEGID: TLargeintField;
    ztRepeatTransactionsFOLLOWUPID: TLargeintField;
    ztRepeatTransactionsNEXTOCCURRENCEDATE: TMemoField;
    ztRepeatTransactionsNOTES: TMemoField;
    ztRepeatTransactionsNUMOCCURRENCES: TLargeintField;
    ztRepeatTransactionsPAYEEID: TLargeintField;
    ztRepeatTransactionsREPEATS: TLargeintField;
    ztRepeatTransactionsREPTRANSID: TLargeintField;
    ztRepeatTransactionsSTATUS: TMemoField;
    ztRepeatTransactionsSUBCATEGID: TLargeintField;
    ztRepeatTransactionsTOACCOUNTID: TLargeintField;
    ztRepeatTransactionsTOTRANSAMOUNT: TFloatField;
    ztRepeatTransactionsTRANSACTIONNUMBER: TMemoField;
    ztRepeatTransactionsTRANSAMOUNT: TFloatField;
    ztRepeatTransactionsTRANSCODE: TMemoField;
    ztRepeatTransactionsTRANSDATE: TMemoField;
    ztSplitTransactions: TZTable;
    ztBudget: TZTable;
    ztBudgetAMOUNT: TFloatField;
    ztBudgetBUDGETENTRYID: TLargeintField;
    ztBudgetBUDGETYEARID: TLargeintField;
    ztBudgetCATEGID: TLargeintField;
    ztBudgetPERIOD: TMemoField;
    ztBudgetSUBCATEGID: TLargeintField;
    ztBudgetYear: TZTable;
    ztBudgetYearBUDGETYEARID: TLargeintField;
    ztBudgetYearBUDGETYEARNAME: TMemoField;
    ztInfoTable: TZTable;
    ztAccountList: TZTable;
    ztAccountListACCESSINFO: TMemoField;
    ztAccountListACCOUNTID: TLargeintField;
    ztAccountListACCOUNTNAME: TMemoField;
    ztAccountListACCOUNTNUM: TMemoField;
    ztAccountListACCOUNTTYPE: TMemoField;
    ztAccountListCONTACTINFO: TMemoField;
    ztAccountListCURRENCYID: TLargeintField;
    ztAccountListFAVORITEACCT: TMemoField;
    ztAccountListHELDAT: TMemoField;
    ztAccountListINITIALBAL: TFloatField;
    ztAccountListNOTES: TMemoField;
    ztAccountListSTATUS: TMemoField;
    ztAccountListWEBSITE: TMemoField;
    ztAssets: TZTable;
    ztAssetsASSETID: TLargeintField;
    ztAssetsASSETNAME: TMemoField;
    ztAssetsASSETTYPE: TMemoField;
    ztAssetsCURRENTVALUE: TCurrencyField;
    ztAssetsNOTES: TMemoField;
    ztAssetsSTARTDATE: TMemoField;
    ztAssetsVALUE: TFloatField;
    ztAssetsVALUECHANGE: TMemoField;
    ztAssetsVALUECHANGERATE: TFloatField;
    ztCategory: TZTable;
    ztCategoryCATEGID: TLargeintField;
    ztCategoryCATEGNAME: TMemoField;
    ztCheckingAccount: TZTable;
    ztPayee: TZTable;
    ztPayeeCATEGID: TLargeintField;
    ztPayeeDefaultCategory: TStringField;
    ztPayeePAYEEID: TLargeintField;
    ztPayeePAYEENAME: TMemoField;
    ztPayeeSUBCATEGID: TLargeintField;
    ztSplitTransactionsCATEGID: TLargeintField;
    ztSplitTransactionsSPLITTRANSAMOUNT: TFloatField;
    ztSplitTransactionsSPLITTRANSID: TLargeintField;
    ztSplitTransactionsSUBCATEGID: TLargeintField;
    ztSplitTransactionsTRANSID: TLargeintField;
    ztSubCategory: TZTable;
    ztSubCategoryCATEGID: TLargeintField;
    ztSubCategoryINCLUDEBUDGET: TMemoField;
    ztSubCategorySUBCATEGID: TLargeintField;
    ztSubCategorySUBCATEGNAME: TMemoField;
    ztTransFilterARCHIVED: TMemoField;
    ztTransFilterCATEGID: TFloatField;
    ztTransFilterDATEFILTER: TFloatField;
    ztTransFilterFROMAMOUNT: TFloatField;
    ztTransFilterFROMDATE: TMemoField;
    ztTransFilterPAYEENAME: TMemoField;
    ztTransFilterSUBCATEGID: TFloatField;
    ztTransFilterTOAMOUNT: TFloatField;
    ztTransFilterTODATE: TMemoField;
    ztTransFilterTRANSCODE: TMemoField;
    ztTransFilterTRANSFILTERID: TLargeintField;
    ztTransFilterTRANSFILTERNAME: TMemoField;
    ZUpdateSQL1: TZUpdateSQL;
    function CurrencyEditToFloat(InputEdit : TEdit) : float;
    procedure DisplayCurrencyEdit(var Edit : TEdit);
    function StripChars(const InputString, CharsToStrip: string): string;
    procedure ShowDBTextFields(Sender: TField; var aText: string; DisplayText: Boolean);
    procedure zqAssetsAfterOpen(DataSet: TDataSet);
    procedure zqAssetsAfterRefresh(DataSet: TDataSet);
    procedure zqAssetsCalcFields(DataSet: TDataSet);
    procedure zqBankAccountsAfterOpen(DataSet: TDataSet);
    procedure zqBankAccountsAfterRefresh(DataSet: TDataSet);
    procedure zqBankAccountsCalcFields(DataSet: TDataSet);
    procedure zqBudgetAfterOpen(DataSet: TDataSet);
    procedure zqBudgetYearCalcFields(DataSet: TDataSet);
    procedure zqCategoriesAfterOpen(DataSet: TDataSet);
    procedure zqHomepageRep1AfterOpen(DataSet: TDataSet);
    procedure zqHomepageRep2AfterOpen(DataSet: TDataSet);
    procedure zqPayeeAfterOpen(DataSet: TDataSet);
    procedure zqPayeeAfterRefresh(DataSet: TDataSet);
    procedure zqRepeatTransactionsAfterOpen(DataSet: TDataSet);
    procedure zqRepeatTransactionsCalcFields(DataSet: TDataSet);
    procedure zqReportAfterOpen(DataSet: TDataSet);
    procedure zqTransactionsAfterOpen(DataSet: TDataSet);
    procedure zqTransFiltersAfterOpen(DataSet: TDataSet);
    procedure ZQuery1AfterApplyUpdates(Sender: TObject);
    procedure ZQuery1AfterDelete(DataSet: TDataSet);
    procedure ZQuery1AfterInsert(DataSet: TDataSet);
    procedure ZQuery1AfterOpen(DataSet: TDataSet);
    procedure ZQuery1AfterPost(DataSet: TDataSet);
    procedure zqUpcomingTransAfterOpen(DataSet: TDataSet);
    procedure zqUpcomingTransAfterRefresh(DataSet: TDataSet);
    procedure zqUpcomingTransCalcFields(DataSet: TDataSet);
    procedure ztPayeeAfterOpen(DataSet: TDataSet);
    procedure ztPayeeAfterRefresh(DataSet: TDataSet);
    procedure ztPayeeCalcFields(DataSet: TDataSet);
    function GetCategoryDescription(CatID, SubCatID: integer; DefaultCaption : string) : string;
    procedure OpenDatabaseTables(Toggle : Boolean);
    procedure CreateDatabase(Filename : string);
    function StripApostropheFromString(InString : string ) : string;
    function FormatDateSQL(DateField : string ) : string;
    procedure BackupDatabase(BackupFilename : string);
    procedure SpoolQueryToSQLSpy(Sender : TZQuery);
{    function EncodePassword(Password : string) : string;
    function DecodePassword(Password : string) : string;}
{    function EncryptPassword(s: string): string;
    function DecryptPassword(s: string): string;}
    function DecodeStringBase64(s:string):String;
    function EncodeStringBase64(s:string):String;
    function GetInfoSettings(Infoname, DefaultResult : string) : string;
    procedure SetInfoSettings(Infoname, Infovalue : string);
    function GetInfoSettingsInt(Infoname: string; DefaultResult : integer) : integer;
    procedure SetInfoSettingsInt(Infoname : string; Infovalue : integer);
    procedure SetInfoSettingsBool(Infoname : string; Infovalue : boolean);
    function GetInfoSettingsBool(Infoname: string; DefaultResult : boolean) : boolean;
    function CalculateValueChange(value: real; startdate, changetype : string; valuechangerate : integer) : real;
    function RoundEx(const AInput: real; APlaces: integer): real;
    function FormatToUKDate(startdate : string) : string;
    function FormatDateToDisplayFormat(datestring : string) : string;
    function GetRandomColour : TColor;
    function GetCategoryColour(CategoryID : integer) : TColor;
    function CurrencyStr2DP(CurrencyStr : string) : string;
    procedure LinkSplitTransactions(TransID : Integer; TableName : string);
    function HasSplitTransactions(TransID : Integer; TableName : string) : Boolean;
    function SplitTransactionsTotal : Float;
    procedure RemoveTempSplitTransactions(TableName : string);
    procedure DisplayCurrencyEditRemoveNegative(var Edit : TEdit);
    function StatusBalance(BankAccountID : integer; StatusType : string) : Float;
    Procedure Dataset2SeparatedFile(ads: TDataset; const Filename: String; const Separator: String = ';');
{    procedure SaveToExcelFile(const AFileName: TFileName; ads: TDataset);}
    Procedure StringGrid2SeparatedFile(StringGrid: TStringGrid; const Filename: String; const Separator: String = ';');
    function GetNodeByText(ATree : TTreeView; AValue:String; AVisible: Boolean): TTreeNode;
    function FindStringGridColumn(StringGrid: TStringGrid; SearchColumn:Integer; FindString:string):Integer ;
    function FindStringGridTotalColumn(StringGrid: TStringGrid; CategoryID:string):Integer ;
    function UpdateAllTotalColumns(StringGrid: TStringGrid; CategoryID:string):Integer ;
    function BoolToStr(Boolvalue : boolean) : string;
    function StrToBool(StringValue : String) : boolean;
    procedure UpdateGrandTotalsColumns(StringGrid: TStringGrid);
    function CalcEstimatedAmount(Amount: Float; AmountFrequency, BudgetFrequency:string): Float ;
    procedure PopulateComboBox(ComboBox: TComboBox; DatabaseTable : TZTable; FieldName : string);
    procedure CopyBudgetYear(OldBudgetYearID, NewBudgetYearID : Integer);
    procedure UpdateBudgetTotalCaptions(EstimatedIncome, EstimatedExpenses, ActualIncome, ActualExpenses : Float);
    function CategoryActualBalance(CategoryID, SubCategory : integer;Account, FromDate, ToDate : string) : Float;
    procedure SetupComboBox(var ComboBox : TComboBox; DatabaseTable : TZTable; FieldName, AllItemsText, SelectedItem : String);
    procedure SetupComboBoxFilterArchived(var ComboBox : TComboBox; DatabaseTable : TZTable; FieldName, AllItemsText, SelectedItem : String);
    function ConvertCurrencyStringToFloat(CurrencyString : string) : float;
    function ConvertFloatToCurrencyString(Currency : float) : string;
    procedure SetupBetweenDatesSQL(var FromDate, ToDate : String; DateType : TDateQuery);
    function SetupDateSQL(Date : String; DateType, DateModifier : integer) : string;
    function GetTransactionStatusText(Status : string) : string;
    procedure CalcRemainingDaysRepeatTransfers(DataSet: TDataSet);
    procedure ztRepeatSplitTransactionsCalcFields(DataSet: TDataSet);
    procedure ztRepeatTransactionsCalcFields(DataSet: TDataSet);
    Procedure RefreshDataset(ads: TDataset);
    Procedure SaveChanges(ads: TDataset; Refresh : Boolean);
    procedure EmptyDatabaseTable(Tablename : string);
    procedure SetToolbarPositions(ToolbarPosition : Integer);
    Procedure StringExplode(s: string; Delimiter: string; Var res: TStringList);
//    procedure saveGridLayout(Mydbgrid: TDBGrid; fileName: string);
//    procedure loadGridLayout(Mydbgrid: TDBGrid; fileName: string);
    procedure loadGridLayout(Mydbgrid: TDBGrid);
    procedure saveGridLayout(Mydbgrid: TDBGrid);
    procedure DeleteDBRecord(TableName, WhereIDField : string; DeleteIDField : Integer);
    procedure SetupCurrencyValues;
  private
    { private declarations }
  public
    { public declarations }
    DatabaseLocation,
    DisplayDateFormat : String;
    DebugMode, StartupBackup, ExitBackup, MouseOver : Boolean;
   end;

var
  dmData: TdmData;
  s1, s2: TStringStream;
  fs : TFormatSettings;
  {  ec: TBlowfishEncryptStream;
  dc: TBlowfishDecryptStream;}

const
  //tablenames
{  tblAccountList = 'ACCOUNTLIST_V1';
  tblAssets = 'ASSETS_V1';
  tblBudget = 'BUDGET_V1';
  tblBudgetYear = 'BUDGETYEAR_V1';
  tblCategory = 'CATEGORY_V1';
  tblCheckingAccount = 'CHECKINGACCOUNT_V1';
  tblInfotable = 'INFOTABLE_V1';
  tblPayee = 'PAYEE_V1';
  tblPayeeImport = 'PAYEEIMPORT';
  tblRepeatTransactions = 'REPEATTRANSACTIONS_V1';
  tblRepeatSplitTransactions = 'REPEATSPLITTRANSACTIONS_V1';
  tblSplitTransactions = 'SPLITTRANSACTIONS_V1';
  tblSubCategory = 'SUBCATEGORY_V1';
  tblTransFilter = 'TRANSFILTERS';
  tblGridSettings = 'GRID_SETTINGS';}
  tblAccountList = 'ACCOUNTS';
  tblAssets = 'ASSETS';
  tblBudget = 'BUDGET_DETAIL';
  tblBudgetYear = 'BUDGET_HEADER';
  tblCategory = 'CATEGORIES';
  tblCheckingAccount = 'TRANSACTIONS';
  tblInfotable = 'USER_SETTINGS';
  tblPayee = 'PAYEES';
  tblPayeeImport = 'PAYEE_IMPORT';
  tblRepeatTransactions = 'REPEAT_TRANSACTIONS';
  tblRepeatSplitTransactions = 'REPEAT_SPLIT_TRANSACTIONS';
  tblSplitTransactions = 'SPLIT_TRANSACTIONS';
  tblSubCategory = 'SUB_CATEGORIES';
  tblTransFilter = 'TRANS_FILTERS';
  tblGridSettings = 'GRID_SETTINGS';
  tblRepFilters = 'REP_FILTERS';

  ApplicationName = 'CredEdit';
  Homepage = 'http://www.jnmitchell.co.uk/';
  dbExt = '.db3';
  DefaultDBFileName = 'creddata';
  EncryptionKey = 'key';
  ReportsPath = '\reports\';

  //transfer display options
  TransferTo = '>';
  TransferFrom = '<';

  //currency defaults
//  DecimalPlaces = 2;
  {DecimalPlacesStr = '.00';
  FullDecimalPlacesStr = '0.00';
  CurrencySymbol = '£';}

  //page indexes for the tabs on the main form
  pgHomepage = 0;
  pgBankAccs = 1;
  pgAssets = 2;
  pgPayees = 3;
  pgRepTrans = 4;
  pgBudgets = 5;
  pgReports = 6;

  //column header indexes for budgets grid
  sgBudgetCategoryID = 1;
  sgBudgetCategory = 2;
  sgBudgetSubcategoryID = 3;
  sgBudgetSubcategory = 4;
  sgBudgetFrequency = 5;
  sgBudgetAmount = 6;
  sgBudgetEstimated = 7;
  sgBudgetActual = 8;
  sgBudgetBudgetEntryID = 9;
  sgBudgetBudgetYearID = 10;
  sgBudgetCategoryColour = 11;
  sgBudgetIncomeExpense = 12;

//  BudgetYearID = 1;  //for testing
  ColumnHeader = 0;

  //budget frequency lengths
  None = 0;
  Weekly = 52;
  BiWeekly = 26;
  Monthly = 12;
  BiMonthly = 6;
  Quarterly = 4;
  HalfYearly = 2;
  Yearly = 1;
  Daily = 365;

  //month values
  January = 1;
  February = 2;
  March = 3;
  April = 4;
  May = 5;
  June = 6;
  July = 7;
  August = 8;
  September = 9;
  October = 10;
  November = 11;
  December = 12;

  //Repeat Date Type values
  trNone = 0;
  trWeekly = 1;
  trBiWeekly = 2;
  trMonthly = 3;
  trBiMonthly = 4;
  trQuartertly = 5;
  trHalfYearly = 6;
  trYearly = 7;
  trFourMonths = 8;
  trFourWeeks = 9;
  trDaily = 10;
  trInXDays = 11;
  trInXMonths = 12;
  trEveryXDays = 13;
  trEveryXMonths = 14;
  trMonthlyLastDay = 15;
  trMonthlyLastBusinessDay = 16;


implementation

{$R *.lfm}

uses uMain, uSQLLog, uLogin;

{ TdmData }

procedure TdmData.CreateDatabase(Filename : string);
begin
  zcDatabaseConnection.Connected:= False;
  zcDatabaseConnection.Database:= Filename;
  ZQuery1.Connection := zcDatabaseConnection;
  zcDatabaseConnection.Connected:= True;

  //create the accountlist table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztAccountList.TableName+'(ACCOUNTID integer primary key AUTOINCREMENT, ACCOUNTNAME TEXT COLLATE NOCASE NOT NULL UNIQUE,'+
  ' ACCOUNTTYPE TEXT NOT NULL , ACCOUNTNUM TEXT, STATUS TEXT NOT NULL, NOTES TEXT , HELDAT TEXT , WEBSITE TEXT , '+
  'CONTACTINFO TEXT, ACCESSINFO TEXT , INITIALBAL numeric , FAVORITEACCT TEXT NOT NULL, CURRENCYID integer NOT NULL); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztAccountList.TableName+'_ACCOUNTTYPE ON '+ztAccountList.TableName+'(ACCOUNTTYPE); ');
  ZQuery1.ExecSQL;

  //create the assets table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztAssets.TableName+'(ASSETID integer primary key AUTOINCREMENT, STARTDATE TEXT NOT NULL , ASSETNAME TEXT COLLATE NOCASE NOT NULL, '+
  ' VALUE numeric, VALUECHANGE TEXT, NOTES TEXT, VALUECHANGERATE numeric, ASSETTYPE TEXT); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztAssets.TableName+'_ASSETTYPE ON '+ztAssets.TableName+'(ASSETTYPE); ');
  ZQuery1.ExecSQL;

  //create the category table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztCategory.TableName+'(CATEGID integer primary key AUTOINCREMENT, CATEGNAME TEXT COLLATE NOCASE NOT NULL UNIQUE, COLOUR TEXT, INCLUDEBUDGET TEXT); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztCategory.TableName+'_CATEGNAME ON '+ztCategory.TableName+'(CATEGNAME);');
  ZQuery1.ExecSQL;

  //create the checkingaccount table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztCheckingAccount.TableName+'(TRANSID integer primary key AUTOINCREMENT, ACCOUNTID integer NOT NULL, TOACCOUNTID integer, '+
  ' PAYEEID integer NOT NULL, TRANSCODE TEXT NOT NULL, TRANSAMOUNT numeric NOT NULL, STATUS TEXT, TRANSACTIONNUMBER TEXT, '+
  ' NOTES TEXT, CATEGID integer, SUBCATEGID integer, TRANSDATE TEXT, FOLLOWUPID integer, TOTRANSAMOUNT numeric);');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztCheckingAccount.TableName+'_TRANSDATE ON '+ztCheckingAccount.TableName+'(TRANSDATE);'+
  ' CREATE INDEX IDX_'+ztCheckingAccount.TableName+'_ACCOUNT ON '+ztCheckingAccount.TableName+' (ACCOUNTID, TOACCOUNTID);');
  ZQuery1.ExecSQL;

  //create the payee table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztPayee.TableName+'(PAYEEID integer primary key AUTOINCREMENT, PAYEENAME TEXT COLLATE NOCASE NOT NULL UNIQUE, CATEGID integer, SUBCATEGID integer, COLOUR TEXT); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztPayee.TableName+'_INFONAME ON '+ztPayee.TableName+'(PAYEENAME); ');
  ZQuery1.ExecSQL;

  //create the payee import table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztPayeeImport.TableName+'(PAYEEIMPORTID integer primary key AUTOINCREMENT,MATCHTEXT TEXT, PAYEEID integer); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztPayeeImport.TableName+'_MATCHTEXT ON '+ztPayeeImport.TableName+'(MATCHTEXT)');
  ZQuery1.ExecSQL;

  //create the sub category table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztSubCategory.TableName+'(SUBCATEGID integer primary key AUTOINCREMENT, SUBCATEGNAME TEXT COLLATE NOCASE NOT NULL, CATEGID integer NOT NULL, INCLUDEBUDGET TEXT, UNIQUE(CATEGID, SUBCATEGNAME)); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztSubCategory.TableName+'_CATEGID ON '+ztSubCategory.TableName+'(CATEGID);');
  ZQuery1.ExecSQL;

  //create the info table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztInfoTable.Tablename+'(INFOID integer not null primary key, INFONAME TEXT COLLATE NOCASE NOT NULL UNIQUE, INFOVALUE TEXT); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztInfoTable.Tablename+'_INFONAME ON '+ztInfoTable.Tablename+'(INFONAME);');
  ZQuery1.ExecSQL;

  //create Budget year table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztBudgetYear.tablename+'(BUDGETYEARID integer primary key, BUDGETYEARNAME TEXT NOT NULL UNIQUE, BUDGETFREQUENCY TEXT, BUDGETYEAR TEXT, BUDGETMONTH TEXT, ARCHIVED TEXT, BUDGETACCOUNT TEXT); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztBudgetYear.tablename+'_BUDGETYEARNAME ON '+ztBudgetYear.tablename+'(BUDGETYEARNAME); ');
  ZQuery1.ExecSQL;

  //Create Budget table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztBudget.tablename+'(BUDGETENTRYID integer primary key, BUDGETYEARID integer, CATEGID integer, SUBCATEGID integer, PERIOD TEXT NOT NULL, AMOUNT numeric NOT NULL); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztBudget.tablename+'_BUDGETYEARID ON '+ztBudget.tablename+'(BUDGETYEARID); ');
  ZQuery1.ExecSQL;

  //Create split transactions table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztSplitTransactions.tablename+'(SPLITTRANSID integer primary key, TRANSID integer NOT NULL, CATEGID integer, SUBCATEGID integer, SPLITTRANSAMOUNT numeric); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztSplitTransactions.tablename+'_TRANSID ON '+ztSplitTransactions.tablename+'(TRANSID); ');
  ZQuery1.ExecSQL;

  //Create repeat transactions table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztRepeatTransactions.tablename+'(REPTRANSID integer primary key, ACCOUNTID integer NOT NULL, TOACCOUNTID integer, PAYEEID integer NOT NULL, TRANSCODE TEXT NOT NULL, '+
  ' TRANSAMOUNT numeric NOT NULL, STATUS TEXT, TRANSACTIONNUMBER TEXT, NOTES TEXT, CATEGID integer, SUBCATEGID integer, TRANSDATE TEXT, FOLLOWUPID integer, TOTRANSAMOUNT numeric, REPEATS '+
  ' integer, NEXTOCCURRENCEDATE TEXT, NUMOCCURRENCES integer, AUTORUN TEXT, AUTORUNUSER TEXT ); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztRepeatTransactions.tablename+'_ACCOUNT ON '+ztRepeatTransactions.tablename+' (ACCOUNTID, TOACCOUNTID); ');
  ZQuery1.ExecSQL;

  //Create repeat split transactions table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztRepeatSplitTransactions.tablename+'(SPLITTRANSID integer primary key, TRANSID integer NOT NULL, CATEGID integer, SUBCATEGID integer, SPLITTRANSAMOUNT numeric); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztRepeatSplitTransactions.tablename+'_TRANSID ON '+ztRepeatSplitTransactions.tablename+'(TRANSID); ');
  ZQuery1.ExecSQL;

  //Create transfilter table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztTransFilter.tablename+'(TRANSFILTERID integer primary key AUTOINCREMENT, TRANSFILTERNAME TEXT NOT NULL , FROMDATE TEXT, TODATE TEXT, TRANSCODE TEXT, FROMAMOUNT numeric, '+
  ' TOAMOUNT numeric, PAYEENAME TEXT, CATEGID numeric, SUBCATEGID numeric, ARCHIVED TEXT, DATEFILTER numeric); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztTransFilter.tablename+'_TRANSFILTERNAME ON '+ztTransFilter.tablename+'(TRANSFILTERNAME); ');
  ZQuery1.ExecSQL;

  //Create gridsettings table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztGridSettings.TableName+'(GRIDSETTINGSID integer not null primary key, '+
  ' GRIDNAME TEXT, FIELDNAME TEXT, COLUMNINDEX integer, COLUMNWIDTH integer, VISIBLE TEXT, CAPTION TEXT); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztGridSettings.TableName+'_GRIDNAME ON '+ztGridSettings.TableName+'(GRIDNAME); ');
  ZQuery1.ExecSQL;

  //Create reportfilters table
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE TABLE '+ztRepFilters.TableName+'(REPFILTERID integer primary key AUTOINCREMENT, REPFILTERNAME TEXT NOT NULL , '+
  ' FROMDATE TEXT, TODATE TEXT, TRANSCODE TEXT, FROMAMOUNT numeric, TOAMOUNT numeric, PAYEENAME TEXT, '+
  ' CATEGID numeric, SUBCATEGID numeric, ARCHIVED TEXT, DATEFILTER numeric); ');
  ZQuery1.ExecSQL;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' CREATE INDEX IDX_'+ztRepFilters.TableName+'_REPFILTERNAME ON '+ztRepFilters.TableName+'(REPFILTERNAME); ');
  ZQuery1.ExecSQL;

  //Populate infotable
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' INSERT INTO '+ztInfoTable.TableName+' (INFONAME) VALUES '+
  ' (''USERNAME''); ');
  ZQuery1.ExecSQL;

  //Populate default categories
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' INSERT INTO '+ztCategory.TableName+' (CATEGNAME, INCLUDEBUDGET) VALUES '+
  ' (''Bills'', ''1''), '+
  ' (''Food'', ''1''), '+
  ' (''Leisure'', ''1''), '+
  ' (''Vehicles'', ''1''), '+
  ' (''Education'', ''1''), '+
  ' (''Homeneeds'', ''1''), '+
  ' (''Healthcare'', ''1''), '+
  ' (''Insurance'', ''1''), '+
  ' (''Holiday'', ''1''), '+
  ' (''Taxes'', ''1''), '+
  ' (''Miscellaneous'', ''1''), '+
  ' (''Gifts'', ''1''), '+
  ' (''Income'', ''1''), '+
  ' (''Other Income'', ''1''), '+
  ' (''Other Expenses'', ''1''), '+
  ' (''Transfer'', ''1''); ');
  ZQuery1.ExecSQL;

  //Populate default sub categories
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' INSERT INTO '+ztSubCategory.TableName+' (SUBCATEGNAME, CATEGID, INCLUDEBUDGET) VALUES '+
  ' (''Cable TV'', 1, ''1''), '+
  ' (''Mobile Phone'', 1, ''1''), '+
  ' (''Council Tax'', 1, ''1''), '+
  ' (''Electricity'', 1, ''1''), '+
  ' (''Gas'', 1, ''1''), '+
  ' (''Internet'', 1, ''1''), '+
  ' (''Rent'', 1, ''1''), '+
  ' (''Mortgage'', 1, ''1''), '+
  ' (''Telephone'', 1, ''1''), '+
  ' (''Water'', 1, ''1''), '+
  ' (''Dining Out'', 2, ''1''), '+
  ' (''Take Away'', 2, ''1''), '+
  ' (''Groceries'', 2, ''1''), '+
  ' (''Magazines'', 3, ''1''), '+
  ' (''Movies'', 3, ''1''), '+
  ' (''Video Rental'', 3, ''1''), '+
  ' (''Fuel'', 4, ''1''), '+
  ' (''Maintenance'', 4, ''1''), '+
  ' (''Parking'', 4, ''1''), '+
  ' (''Road Tax'', 4, ''1''), '+
  ' (''MOT'', 4, ''1''), '+
  ' (''Car Insurance'', 4, ''1''), '+
  ' (''Books'', 5, ''1''), '+
  ' (''Others'', 5, ''1''), '+
  ' (''Tuition'', 5, ''1''), '+
  ' (''Clothing'', 6, ''1''), '+
  ' (''Furnishing'', 6, ''1''), '+
  ' (''Others'', 6, ''1''), '+
  ' (''Dental'', 7, ''1''), '+
  ' (''Eyecare'', 7, ''1''), '+
  ' (''Health'', 7, ''1''), '+
  ' (''Physician'', 7, ''1''), '+
  ' (''Prescriptions'', 7, ''1''), '+
  ' (''Auto'', 8, ''1''), '+
  ' (''Health'', 8, ''1''), '+
  ' (''Home'', 8, ''1''), '+
  ' (''Life'', 8, ''1''), '+
  ' (''Lodging'', 9, ''1''), '+
  ' (''Sightseeing'', 9, ''1''), '+
  ' (''Travel'', 9, ''1''), '+
  ' (''Income Tax'', 10, ''1''), '+
  ' (''Others'', 10, ''1''), '+
  ' (''Investment Income'', 13, ''1''), '+
  ' (''Reimbursement/Refunds'', 13, ''1''), '+
  ' (''Salary'', 13, ''1''); ');
  ZQuery1.ExecSQL;

  //Populate default transaction filters
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' INSERT INTO '+ztTransFilter.TableName+' (TRANSFILTERNAME, TRANSCODE, PAYEENAME, CATEGID, SUBCATEGID, ARCHIVED, DATEFILTER) VALUES '+
  ' (''Withdrawals'', ''Withdrawal'', ''[All Payees]'', -1, -1, ''0'', 0), '+
  ' (''Deposits'', ''Deposit'', ''[All Payees]'', -1, -1, ''0'', 0), '+
  ' (''Current Month'', ''[All Transactions]'', ''[All Payees]'', -1, -1, ''0'', 3), '+
  ' (''Future Transactions'', ''[All Transactions]'', ''[All Payees]'', -1, -1, ''0'', 6), '+
  ' (''Transfers'', ''Transfer'', ''[All Payees]'', -1, -1, ''0'', 0), '+
  ' (''Bills'', ''[All Transactions]'', ''[All Payees]'', 1, -1, ''0'', 0); ');
  ZQuery1.ExecSQL;

  DatabaseLocation := filename;

  OpenDatabaseTables(true);

  SetInfoSettings('CREATEDATE', DateToStr(now));
end;

procedure TdmData.OpenDatabaseTables(Toggle : Boolean);
begin
  ztAccountList.TableName := tblAccountList;
  ztAssets.TableName := tblAssets;
  ztBudget.TableName := tblBudget;
  ztBudgetYear.TableName := tblBudgetYear;
  ztCategory.TableName := tblCategory;
  ztCheckingAccount.TableName := tblCheckingAccount;
  ztInfotable.TableName := tblInfotable;
  ztPayee.TableName := tblPayee;
  ztPayeeImport.TableName := tblPayeeImport;
  ztRepeatTransactions.TableName := tblRepeatTransactions;
  ztRepeatSplitTransactions.TableName := tblRepeatSplitTransactions;
  ztSplitTransactions.TableName := tblSplitTransactions;
  ztRepFilters.TableName := tblRepFilters;

  ztSubCategory.TableName := tblSubCategory;
  ztTransFilter.TableName := tblTransFilter;
  ztGridSettings.TableName := tblGridSettings;

  Screen.Cursor:= crHourGlass;
  if not FileExists(dmData.DatabaseLocation) then
  begin
    CreateDatabase(ExtractFilePath(application.exename)+DefaultDBFileName+dbExt);
  end;
  zcDatabaseConnection.Database:= dmData.DatabaseLocation;
  zcDatabaseConnection.Connected:= Toggle;

  if Toggle then
  begin
    ztAccountList.open;
    ztAssets.open;
    ztBudget.open;
    ztBudgetYear.open;
    ztCategory.open;
    ztCheckingAccount.open;
    ztInfotable.open;
    ztPayee.open;
    ztPayeeImport.open;
    ztRepeatTransactions.open;
    ztRepeatSplitTransactions.open;
    ztRepFilters.Open;
    ztSplitTransactions.open;
    ztSubCategory.open;
    ztTransFilter.open;
    ztGridSettings.Open;
  end else
  begin
    ztAccountList.close;
    ztAssets.close;
    ztBudget.close;
    ztBudgetYear.close;
    ztCategory.close;
    ztCheckingAccount.close;
    ztInfotable.close;
    ztPayee.close;
    ztPayeeImport.close;
    ztRepeatTransactions.Close;
    ztRepFilters.Close;
    ztSplitTransactions.Close;
    ztSubCategory.close;
    ztTransFilter.Close;
    ztRepeatSplitTransactions.close;
    ztGridSettings.Close;
  end;
  ztAccountList.active := Toggle;
  ztAssets.active := Toggle;
  ztBudget.active := Toggle;
  ztBudgetYear.active := Toggle;
  ztCategory.active := Toggle;
  ztCheckingAccount.active := Toggle;
  ztInfotable.active := Toggle;
  ztPayee.active := Toggle;
  ztPayeeImport.active := Toggle;
  ztRepeatTransactions.active := Toggle;
  ztSplitTransactions.active := Toggle;
  ztSubCategory.active := Toggle;
  ztTransFilter.active := Toggle;
  ztRepeatSplitTransactions.active := Toggle;
  ztGridSettings.active := Toggle;
  ztRepFilters.active := Toggle;

  //Database password
{  if ztInfotable.Locate('INFONAME', 'PASSWORD', [loCaseInsensitive]) = True then
     zcDatabaseConnection.Password := DecodeStringBase64(ztInfotable.FieldByName('INFOVALUE').AsString)
  else
    zcDatabaseConnection.Password := '';}
  zcDatabaseConnection.Password := dmData.DecodeStringBase64(dmData.GetInfoSettings('PASSWORD', ''));
  Screen.Cursor:= crDefault;

  if (Toggle = true) and (zcDatabaseConnection.Password <> '') then
  begin
    frLogin := TfrLogin.create(self);
    if frLogin.ShowModal = mrOk then
    begin

      frLogin.Free;
    end else
    begin
      frLogin.Free;
      application.Terminate;
    end;
  end;
  frMain.ShowDatabaseLocation;
end;

procedure  TdmData.ShowDBTextFields(Sender: TField; var aText: string; DisplayText: Boolean);
var Str : string;
    //i : integer;
//    CurrencyFormat : Byte;
begin
//  CurrencyFormat = LOCALE_ICURRENCY;
  str := Copy(Sender.AsString, 1, 50);

  if (Sender.FieldName = 'WITHDRAWAL')
  or (Sender.FieldName = 'TRANSAMOUNT')
  or (Sender.FieldName = 'AMOUNT')
  or (Sender.FieldName = 'VALUE')
  or (Sender.FieldName = 'BALANCE')
  or (Sender.FieldName = 'BALANCECURRENCY')
  or (Sender.FieldName = 'DEPOSITCURRENCY')
  or (Sender.FieldName = 'WITHDRAWALCURRENCY')
  or (Sender.FieldName = 'BUDGET_AMOUNT')
//  or (Sender.FieldName = 'CURRENTVALUE')
  or (Sender.FieldName = 'CALCURVALUE')
  or (Sender.FieldName = 'DEPOSIT')
  or (Sender.FieldName = 'FROMAMOUNT')
  or (Sender.FieldName = 'TOAMOUNT')
  or (Sender.FieldName = 'TOTRANSAMOUNT')
  or (Sender.FieldName = 'SPLITTRANSAMOUNT') then
  begin
//    Str := FloatToStrF(Sender.AsFloat, ffCurrency, 4, 2);

    CurrencyString := '';
    if Sender.AsString <> '' then
//      Str := Format('%m', [Sender.AsFloat]);

    // **original //     Str := AnsiToUTF8(FloatToStrF(Sender.AsFloat, ffCurrency, 4, -1));

    Str := AnsiToUTF8(FloatToStrF(Sender.AsFloat,ffCurrency, 4, frMain.DecimalPlaces));
    if Str = frMain.FullDecimalPlacesStr then Str := '';
  end;
  aText := Str;
end;

procedure TdmData.zqAssetsAfterOpen(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
  SpoolQueryToSQLSpy(zqAssets);
end;

procedure TdmData.zqAssetsAfterRefresh(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
end;

procedure TdmData.zqAssetsCalcFields(DataSet: TDataSet);
//var NewValue : float;
begin
//  NewValue
  zqAssets.FieldByName('CALCURVALUE').AsCurrency := CalculateValueChange(zqAssets.FieldByName('VALUE').AsCurrency,
  zqAssets.FieldByName('STARTDATE').AsString,
  zqAssets.FieldByName('VALUECHANGE').AsString, zqAssets.FieldByName('VALUECHANGERATE').AsInteger);

//  ztAssets.FieldByName('CALCURVALUE').AsCurrency := NewValue;
end;

procedure TdmData.zqBankAccountsAfterOpen(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
  spoolQueryToSQLSpy(zqBankAccounts);
end;

procedure TdmData.zqBankAccountsAfterRefresh(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
end;

procedure TdmData.zqBankAccountsCalcFields(DataSet: TDataSet);
var InitBal, TempBal : Real;
begin
  if PAccountRec(frMain.tvNavigation.Selected.Data) = nil then
    InitBal := 0
  else
    InitBal := PAccountRec(frMain.tvNavigation.Selected.Data)^.InitialBal;

  zqBankAccounts.FieldByName('STATUSDESCRIPTION').AsString := dmData.GetTransactionStatusText(dmData.zqBankAccounts.fieldbyname('STATUS').AsString);

  if zqBankAccounts.FieldByName('DEPOSIT').AsString <> '' then
    zqBankAccounts.FieldByName('DEPOSITCURRENCY').AsCurrency := zqBankAccounts.FieldByName('DEPOSIT').AsCurrency;
  if zqBankAccounts.FieldByName('WITHDRAWAL').AsString <> '' then
    zqBankAccounts.FieldByName('WITHDRAWALCURRENCY').AsCurrency := zqBankAccounts.FieldByName('WITHDRAWAL').AsCurrency;

    TempBal := zqBankAccounts.FieldByName('balance').AsCurrency;
    TempBal := InitBal + TempBal;

    zqBankAccounts.FieldByName('BALANCECURRENCY').AsCurrency := TempBal;

end;

procedure TdmData.zqBudgetAfterOpen(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
  spoolQueryToSQLSpy(zqBudget);
end;

procedure TdmData.zqBudgetYearCalcFields(DataSet: TDataSet);
var Month : Integer;
begin
  if dmdata.zqBudgetYear.FieldByName('BUDGETMONTH').AsString = '' then exit;
  Month := StrToInt(dmdata.zqBudgetYear.FieldByName('BUDGETMONTH').AsString);

  case Month of
    January :  dmdata.zqBudgetYear.FieldByName('MONTHDESCRIPTION').AsString := 'January';
    February :  dmdata.zqBudgetYear.FieldByName('MONTHDESCRIPTION').AsString := 'February';
    March :  dmdata.zqBudgetYear.FieldByName('MONTHDESCRIPTION').AsString := 'March';
    April :  dmdata.zqBudgetYear.FieldByName('MONTHDESCRIPTION').AsString := 'April';
    May :  dmdata.zqBudgetYear.FieldByName('MONTHDESCRIPTION').AsString := 'May';
    June :  dmdata.zqBudgetYear.FieldByName('MONTHDESCRIPTION').AsString := 'June';
    July :  dmdata.zqBudgetYear.FieldByName('MONTHDESCRIPTION').AsString := 'July';
    August :  dmdata.zqBudgetYear.FieldByName('MONTHDESCRIPTION').AsString := 'August';
    September :  dmdata.zqBudgetYear.FieldByName('MONTHDESCRIPTION').AsString := 'September';
    October :  dmdata.zqBudgetYear.FieldByName('MONTHDESCRIPTION').AsString := 'October';
    November :  dmdata.zqBudgetYear.FieldByName('MONTHDESCRIPTION').AsString := 'November';
    December :  dmdata.zqBudgetYear.FieldByName('MONTHDESCRIPTION').AsString := 'December';
  end;
end;

procedure TdmData.zqCategoriesAfterOpen(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
  spoolQueryToSQLSpy(zqCategories);
end;

procedure TdmData.zqHomepageRep1AfterOpen(DataSet: TDataSet);
begin
  SpoolQueryToSQLSpy(zqHomepageRep1);
end;

procedure TdmData.zqHomepageRep2AfterOpen(DataSet: TDataSet);
begin
  SpoolQueryToSQLSpy(zqHomepageRep2);
end;

procedure TdmData.zqPayeeAfterOpen(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
  spoolQueryToSQLSpy(zqPayee);
end;

procedure TdmData.zqPayeeAfterRefresh(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
  spoolQueryToSQLSpy(zqPayee);
end;

procedure TdmData.zqRepeatTransactionsAfterOpen(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
  spoolQueryToSQLSpy(zqRepeatTransactions);
end;

procedure TdmData.CalcRemainingDaysRepeatTransfers(DataSet: TDataSet);
var toDate : TDate;
  Days : integer;
  DayStr : String;
begin
//  if DataSet.FieldByName('REPEATS').AsInteger = 0 then DataSet.FieldByName('REMAININGDAYS').AsString := '';

  if (DataSet.FieldByName('NEXTOCCURRENCEDATE').AsString <> '') then
  begin
    toDate := StrToDate(FormatToUKDate(DataSet.FieldByName('NEXTOCCURRENCEDATE').AsString));
    if toDate > now then
    begin
      Days := DaysBetween(toDate, now) + 1;
{      if Days > 1 then
        DayStr := 's'
      else
        DayStr := '';}
      DayStr := 's';
      if Days > 1 then
        DataSet.FieldByName('REMAININGDAYS').AsString := IntToStr(Days) + ' day'+DayStr+' remaining';
      if Days = 0 then
        DataSet.FieldByName('REMAININGDAYS').AsString := 'Due today';
    end else
    begin
      Days := DaysBetween(toDate, now);
{      if Days > 1 then
        DayStr := 's'
      else
        DayStr := '';}
      DayStr := 's';
      if Days > 1 then
        DataSet.FieldByName('REMAININGDAYS').AsString := IntToStr(Days) + ' day'+DayStr+' overdue!';
      if Days = 0 then
        DataSet.FieldByName('REMAININGDAYS').AsString := 'Due today';
    end;
  end;
end;

procedure TdmData.ztRepeatSplitTransactionsCalcFields(DataSet: TDataSet);
begin
end;

procedure TdmData.ztRepeatTransactionsCalcFields(DataSet: TDataSet);
begin
end;

procedure TdmData.zqRepeatTransactionsCalcFields(DataSet: TDataSet);
begin
  CalcRemainingDaysRepeatTransfers(zqRepeatTransactions);
end;

procedure TdmData.zqReportAfterOpen(DataSet: TDataSet);
begin
  spoolQueryToSQLSpy(zqReport);
end;

procedure TdmData.zqTransactionsAfterOpen(DataSet: TDataSet);
begin
  //SpoolQueryToSQLSpy(zqTransactions);
end;

procedure TdmData.zqTransFiltersAfterOpen(DataSet: TDataSet);
begin
  SpoolQueryToSQLSpy(zqTransFilters);
end;

procedure TdmData.ZQuery1AfterApplyUpdates(Sender: TObject);
begin
  SpoolQueryToSQLSpy(ZQuery1);
end;

procedure TdmData.ZQuery1AfterDelete(DataSet: TDataSet);
begin
  SpoolQueryToSQLSpy(ZQuery1);
end;

procedure TdmData.ZQuery1AfterInsert(DataSet: TDataSet);
begin

end;

procedure TdmData.ZQuery1AfterOpen(DataSet: TDataSet);
begin
  SpoolQueryToSQLSpy(ZQuery1);
end;

procedure TdmData.ZQuery1AfterPost(DataSet: TDataSet);
begin
  SpoolQueryToSQLSpy(ZQuery1);
end;

procedure TdmData.zqUpcomingTransAfterOpen(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
  SpoolQueryToSQLSpy(zqUpcomingTrans);
end;

procedure TdmData.zqUpcomingTransAfterRefresh(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
end;

procedure TdmData.zqUpcomingTransCalcFields(DataSet: TDataSet);
begin
  CalcRemainingDaysRepeatTransfers(zqUpcomingTrans);
end;

procedure TdmData.ztPayeeAfterOpen(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
end;

procedure TdmData.ztPayeeAfterRefresh(DataSet: TDataSet);
begin
  frMain.UpdateStatusBarText;
end;

procedure TdmData.ztPayeeCalcFields(DataSet: TDataSet);
var TmpStr : string;
begin
  if ztPayee.FieldByName('CATEGNAME').AsString <> '' then
    TmpStr := ztPayee.FieldByName('CATEGNAME').AsString;
  if ztPayee.FieldByName('SUBCATEGNAME').AsString <> '' then
    TmpStr := TmpStr + ': '+ ztPayee.FieldByName('SUBCATEGNAME').AsString;

  ztPayee.FieldByName('DefaultCategory').AsString := TmpStr;
end;

function TdmData.StripChars(const InputString, CharsToStrip: string): string;
var
  c: Char;
begin
  Result := InputString;
  for c in CharsToStrip do
    Result := StringReplace(Result, c, '', [rfReplaceAll, rfIgnoreCase]);
end;

procedure TdmData.DisplayCurrencyEdit(var Edit : TEdit);
var Str : string;
  CurrValue : real;
begin
  if Edit.Text = '' then exit;
  CurrencyString := '';
  Str := StripChars(Edit.text, ',');
  CurrValue := StrToFloat(Str);
//  Str := Format('%m', [CurrValue]);
  Str := AnsiToUTF8(FloatToStrF(CurrValue,ffCurrency, 4, frMain.DecimalPlaces));

//  if Str = '0.00' then Str := '';
  if Str = frMain.DecimalPlacesStr then Str := '0'+frMain.DecimalPlacesStr;
  Edit.text := Str;
end;

procedure TdmData.DisplayCurrencyEditRemoveNegative(var Edit : TEdit);
var Str : string;
  CurrValue : real;
begin
  if Edit.Text = '' then exit;
  CurrencyString := '';
  Str := StripChars(Edit.text, ',');
  CurrValue := StrToFloat(Str);
//  Str := Format('%m', [CurrValue]);
  Str := AnsiToUTF8(FloatToStrF(CurrValue,ffCurrency, 4, frMain.DecimalPlaces));
  delete(Str, 1, 1);  //remove negative
  if Str = frMain.FullDecimalPlacesStr then Str := '';
  Edit.text := Str;
end;

function TdmData.CurrencyEditToFloat(InputEdit : TEdit) : float;
var Str : string;
//  CurrValue : real;
begin
  if InputEdit.Text = '' then exit;
  CurrencyString := '';
  Str := StripChars(InputEdit.text, ',');
  result := StrToFloat(Str)
end;

function TdmData.GetCategoryDescription(CatID, SubCatID : integer; DefaultCaption : string) : string;
var TmpStr : string;
begin
  result := '';
  TmpStr := '';

 if ztCategory.Locate('CATEGID', CatID, [loCaseInsensitive]) = True then
    TmpStr := ztCategory.FieldByName('CATEGNAME').AsString;

  if ztSubCategory.Locate('SUBCATEGID', SubCatID, [loCaseInsensitive]) = True then
    TmpStr := TmpStr + ': '+ ztSubCategory.FieldByName('SUBCATEGNAME').AsString;

  if TmpStr = '' then TmpStr := DefaultCaption;
  result := TmpStr;
end;

function TdmData.StripApostropheFromString(InString : string ) : string;
var i : integer;
begin
  result := InString;
//  if not cbStripApostrophe.Checked then exit;
  i := pos('''', InString);
  if i = 1 then
    delete(InString, i, 1);
  result := InString;
end;

function TdmData.FormatDateSQL(DateField : string) : string;
var {i : integer;}
  DateString : string;
begin
  DateString := '';;

  if DisplayDateFormat = 'DDMMYY' then
    DateString :=
     ' strftime('+chr(39)+'%d'+chr(39)+','+DateField+')||strftime('
          +chr(39)+'%m'+chr(39)+','+DateField+')||substr(strftime('
          +chr(39)+'%Y'+chr(39)+','+DateField+'), 3, 2) '
  else
  if DisplayDateFormat = 'DD-MM-YY' then
    DateString :=
     ' strftime('+chr(39)+'%d'+chr(39)+','+DateField+')||'+chr(39)+'-'+chr(39)+'||strftime('
          +chr(39)+'%m'+chr(39)+','+DateField+')||'+chr(39)+'-'+chr(39)+'||substr(strftime('
          +chr(39)+'%Y'+chr(39)+','+DateField+'), 3, 2) '
  else
  if DisplayDateFormat = 'DD.MM.YY' then
    DateString :=
     ' strftime('+chr(39)+'%d'+chr(39)+','+DateField+')||'+chr(39)+'.'+chr(39)+'||strftime('
          +chr(39)+'%m'+chr(39)+','+DateField+')||'+chr(39)+'.'+chr(39)+'||substr(strftime('
          +chr(39)+'%Y'+chr(39)+','+DateField+'), 3, 2) '
  else
  if DisplayDateFormat = 'DD/MM/YY' then
    DateString :=
     ' strftime('+chr(39)+'%d'+chr(39)+','+DateField+')||'+chr(39)+'/'+chr(39)+'||strftime('
          +chr(39)+'%m'+chr(39)+','+DateField+')||'+chr(39)+'/'+chr(39)+'||substr(strftime('
          +chr(39)+'%Y'+chr(39)+','+DateField+'), 3, 2) '
  else
  if DisplayDateFormat = 'DDMMYYYY' then
    DateString := ' strftime('+chr(39)+'%d%m%Y'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'DD-MM-YYYY' then
    DateString := ' strftime('+chr(39)+'%d-%m-%Y'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'DD.MM.YYYY' then
    DateString := ' strftime('+chr(39)+'%d.%m.%Y'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'DD/MM/YYYY' then
    DateString := ' strftime('+chr(39)+'%d/%m/%Y'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'MM-DD-YY' then
    DateString :=
     ' strftime('+chr(39)+'%m'+chr(39)+','+DateField+')||'+chr(39)+'-'+chr(39)+'||strftime('
          +chr(39)+'%d'+chr(39)+','+DateField+')||'+chr(39)+'-'+chr(39)+'||substr(strftime('
          +chr(39)+'%Y'+chr(39)+','+DateField+'), 3, 2) '
  else
  if DisplayDateFormat = 'MM.DD.YY' then
    DateString :=
     ' strftime('+chr(39)+'%m'+chr(39)+','+DateField+')||'+chr(39)+'.'+chr(39)+'||strftime('
          +chr(39)+'%d'+chr(39)+','+DateField+')||'+chr(39)+'.'+chr(39)+'||substr(strftime('
          +chr(39)+'%Y'+chr(39)+','+DateField+'), 3, 2) '
  else
  if DisplayDateFormat = 'MM/DD/YY' then
    DateString :=
     ' strftime('+chr(39)+'%m'+chr(39)+','+DateField+')||'+chr(39)+'/'+chr(39)+'||strftime('
          +chr(39)+'%d'+chr(39)+','+DateField+')||'+chr(39)+'/'+chr(39)+'||substr(strftime('
          +chr(39)+'%Y'+chr(39)+','+DateField+'), 3, 2) '
  else
  if DisplayDateFormat = 'MMDDYYYY' then
    DateString := ' strftime('+chr(39)+'%m%d%Y'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'MM-DD-YYYY' then
    DateString := ' strftime('+chr(39)+'%m-%d-%Y'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'MM.DD.YYYY' then
    DateString := ' strftime('+chr(39)+'%m.%d.%Y'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'MM/DD/YYYY' then
    DateString := ' strftime('+chr(39)+'%m/%d/%Y'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'YYMMDD' then
    DateString := 'substr(strftime('+chr(39)+'%Y'+chr(39)+','+DateField+'), 3, 2)||strftime('
      +chr(39)+'%m'+chr(39)+','+DateField+')||strftime('+chr(39)+'%d'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'YY-MM-DD' then
    DateString := 'substr(strftime('+chr(39)+'%Y'+chr(39)+','+DateField+'), 3, 2)||'+chr(39)+'-'+chr(39)+'||strftime('
      +chr(39)+'%m'+chr(39)+','+DateField+')||'+chr(39)+'-'+chr(39)+'||strftime('+chr(39)+'%d'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'YY.MM.DD' then
    DateString := 'substr(strftime('+chr(39)+'%Y'+chr(39)+','+DateField+'), 3, 2)||'+chr(39)+'.'+chr(39)+'||strftime('
      +chr(39)+'%m'+chr(39)+','+DateField+')||'+chr(39)+'.'+chr(39)+'||strftime('+chr(39)+'%d'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'YY/MM/DD' then
    DateString := 'substr(strftime('+chr(39)+'%Y'+chr(39)+','+DateField+'), 3, 2)||'+chr(39)+'/'+chr(39)+'||strftime('
      +chr(39)+'%m'+chr(39)+','+DateField+')||'+chr(39)+'/'+chr(39)+'||strftime('+chr(39)+'%d'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'YYYYMMDD' then
    DateString := ' strftime('+chr(39)+'%Y%m%d'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'YYYY-MM-DD' then
    DateString := ' strftime('+chr(39)+'%Y-%m-%d'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat = 'YYYY.MM.DD' then
    DateString := ' strftime('+chr(39)+'%Y.%m.%d'+chr(39)+','+DateField+') '
  else
  if DisplayDateFormat =  'YYYY/MM/DD' then
    DateString := ' strftime('+chr(39)+'%Y/%m/%d'+chr(39)+','+DateField+') ';

  result := DateString;
end;

procedure TdmData.BackupDatabase(BackupFilename : string);
var DateStamp, OrgFilePath, OrgFilename,FileExt,Filename : string;
  ExtPos : integer;
begin
  DateStamp := FormatDateTime('YYYY-MM-DD',now);
  OrgFilename := ExtractFileName(dmData.DatabaseLocation);
  FileExt := ExtractFileExt(dmData.DatabaseLocation);
  ExtPos := pos(FileExt, OrgFilename);
  Filename := copy(OrgFilename, 0, ExtPos-1);

  OrgFilePath := ExtractFilePath(zcDatabaseConnection.Database);
  BackupFilename := OrgFilePath + Filename +'_'+ BackupFilename +'_'+ DateStamp + dbExt;
  OpenDatabaseTables(False);
  if CopyFile(dmData.DatabaseLocation, BackupFilename) = false then ShowMessage('Backup failed!');
  OpenDatabaseTables(True);
end;

procedure TdmData.SpoolQueryToSQLSpy(Sender : TZQuery);
begin
  if (frMain.miSQLLog.Checked) and (frSQLLog <> nil) then
  begin
    if Sender.Active then
      frSQLLog.mLog.Lines.Add('('+IntToStr(Sender.RecordCount)+')');
    frSQLLog.mLog.Lines.AddStrings(Sender.SQL);
    frSQLLog.mLog.Lines.Add('');
  end;
end;

{function TdmData.EncodePassword(Password : string) : string;
var
  en: TBlowFishEncryptStream;
  s1,s2: TStringStream;
  temp: String;
begin
//  result := EncodeStringBase64(Password));
  s1 := TStringStream.Create('');
  en := TBlowFishEncryptStream.Create(EncryptionKey,s1);
  en.WriteAnsiString(password);
//  result := en.ReadAnsiString;
  en.Free;
  s1.Free;
end;

function TdmData.DecodePassword(Password : string) : string;
var  de: TBlowFishDeCryptStream;
  s2: TStringStream;
begin
  s2 := TStringStream.Create(password);
  de := TBlowFishDeCryptStream.Create(EncryptionKey,s2);
  result := de.ReadAnsiString;
  de.Free;
  s2.free;
end;}

{function TdmData.EncryptPassword(s: string): string; //note you may need to use a try...finally...end; statement
var bf : TBlowfishEncryptStream;
begin
  if (s<>'') then
  begin
    s1:=TStringStream.Create(s); //used as your source string
    s2:=TStringStream.Create('');  //make sure destination stream is blank
    bf:=TBlowfishEncryptStream.Create(EncryptionKey, s2);  //writes to destination stream
    bf.copyfrom(s1, s1.size);
    bf.free;
    result:=s2.datastring;
    s2.free;
    s1.free;
  end;
end;

function TdmData.DecryptPassword(s: string): string; //note you may need to use a try...finally...end; statement
var bf : TBlowfishDecryptStream;
begin
  if (s<>'') then
  begin
    s1:=TStringStream.Create(s); //used as your source string
    s2:=TStringStream.Create('');  //make sure destination stream is blank
    bf:=TBlowfishDecryptStream.Create(EncryptionKey, s1);  //reads from source stream
    s2.copyfrom(bf, s1.size); //to destination stream copy contents from bf to the size of source stream
    bf.free;
    result:=s2.datastring;
    s2.free;
    s1.free;
  end;
end;}

function TdmData.DecodeStringBase64(s:string):String;
var
  Instream,
  Outstream : TStringStream;
  Decoder   : TBase64DecodingStream;
begin
  if s = '' then exit;
//  s := s+EncryptionKey;
  Instream:=TStringStream.Create(s);
  try
    Outstream:=TStringStream.Create('');
    try
      Decoder:=TBase64DecodingStream.Create(Instream,bdmMIME);
      try
         Outstream.CopyFrom(Decoder,Decoder.Size);
         Outstream.Position:=0;
         Result:=Outstream.ReadString(Outstream.Size);
      finally
        Decoder.Free;
      end;
    finally
     Outstream.Free;
     end;
  finally
    Instream.Free;
  end;
end;

function TdmData.EncodeStringBase64(s:string):String;
var
  Outstream : TStringStream;
  Encoder   : TBase64EncodingStream;
begin
  if s = '' then exit;
//  s := s+EncryptionKey;
  Outstream:=TStringStream.Create('');
  try
    Encoder:=TBase64EncodingStream.create(outstream);
    try
      Encoder.Write(s[1],Length(s));
    finally
      Encoder.Free;
    end;
    Outstream.Position:=0;
    Result:=Outstream.ReadString(Outstream.Size);
  finally
    Outstream.free;
  end;
end;

function TdmData.GetInfoSettings(Infoname, DefaultResult : string) : string;
begin
  if ztInfotable.Locate('INFONAME', Infoname, [loCaseInsensitive]) = True then
    result := ztInfotable.FieldByName('INFOVALUE').AsString
  else
    result := DefaultResult;
end;

function TdmData.GetInfoSettingsInt(Infoname: string; DefaultResult : integer) : integer;
begin
  if ztInfotable.Locate('INFONAME', Infoname, [loCaseInsensitive]) = True then
    result := StrToInt(ztInfotable.FieldByName('INFOVALUE').AsString)
  else
    result := DefaultResult;
end;

function TdmData.GetInfoSettingsBool(Infoname: string; DefaultResult : boolean) : boolean;
//var BoolStr : String;
begin
  if ztInfotable.Locate('INFONAME', Infoname, [loCaseInsensitive]) = True then
  begin
    if ztInfotable.FieldByName('INFOVALUE').AsString = '0' then
      result := false
    else
      result := true;
  end else
    result := DefaultResult;
end;

procedure TdmData.SetInfoSettings(Infoname, Infovalue : string);
begin
  if ztInfotable.Locate('INFONAME', Infoname, [loCaseInsensitive]) = True then
  begin
    ztInfotable.Edit;
    ztInfotable.FieldByName('INFOVALUE').AsString := Infovalue;
    SaveChanges(ztInfotable, False);
  end else
  begin
    ztInfotable.Insert;
    ztInfotable.FieldByName('INFONAME').AsString := Infoname;
    ztInfotable.FieldByName('INFOVALUE').AsString := Infovalue;
    SaveChanges(ztInfotable, False);
  end;
end;

procedure TdmData.SetInfoSettingsInt(Infoname : string; Infovalue : integer);
begin
  if ztInfotable.Locate('INFONAME', Infoname, [loCaseInsensitive]) = True then
  begin
    ztInfotable.Edit;
    ztInfotable.FieldByName('INFOVALUE').AsString := IntToStr(Infovalue);
    SaveChanges(ztInfotable, False);
  end else
  begin
    ztInfotable.Insert;
    ztInfotable.FieldByName('INFONAME').AsString := Infoname;
    ztInfotable.FieldByName('INFOVALUE').AsString := IntToStr(Infovalue);
    SaveChanges(ztInfotable, False);
  end;
end;

procedure TdmData.SetInfoSettingsBool(Infoname : string; Infovalue : boolean);
begin
  if ztInfotable.Locate('INFONAME', Infoname, [loCaseInsensitive]) = True then
  begin
    ztInfotable.Edit;
    if Infovalue then
      ztInfotable.FieldByName('INFOVALUE').AsString := '1'
    else
      ztInfotable.FieldByName('INFOVALUE').AsString := '0';
    SaveChanges(ztInfotable, False);
  end else
  begin
    ztInfotable.Insert;
    ztInfotable.FieldByName('INFONAME').AsString := Infoname;
    if Infovalue then
      ztInfotable.FieldByName('INFOVALUE').AsString := '1'
    else
      ztInfotable.FieldByName('INFOVALUE').AsString := '0';
    SaveChanges(ztInfotable, False);
  end;
end;

function TdmData.BoolToStr(Boolvalue : boolean) : string;
begin
  if Boolvalue then
    result := '1'
  else
    result := '0';
end;

function TdmData.StrToBool(StringValue : String) : boolean;
begin
  if StringValue = '' then
    result := False
  else
    result := (StringValue = '1');
end;


function TdmData.FormatToUKDate(startdate : string) : string;
var
  YearStr, MonthStr, DayStr : string;
begin
  YearStr := copy(startdate, 1, 4);
  MonthStr := copy(startdate, 6, 2);
  DayStr := copy(startdate, 9, 2);
  result := DayStr + '/' + MonthStr + '/' + YearStr;
end;

function TdmData.CalculateValueChange(value: real; startdate, changetype : string; valuechangerate : integer) : real;
var   {CurrYear, CurrMonth, CurrDay, PrevMonth: Word;}
  i, AgeYrs : integer;
  CalculatingAmount : real;

  function ValueChange(invalue : real) : real;
  begin
    result := ((invalue / 100) * valuechangerate);
  end;
begin
//  AgeYrs := round(DaysBetween(now, StrToDate(TmpDateStr)) / 365);
  AgeYrs := round(DaysBetween(now, StrToDate(FormatToUKDate(Startdate))) / 365.242);

  CalculatingAmount := value;
  if (changetype = 'Appreciates') then
  begin
    for i:= 1 to AgeYrs do
      CalculatingAmount := CalculatingAmount + ValueChange(CalculatingAmount);
  end else
  if (changetype = 'Depreciates') then
  begin
    for i:= 1 to AgeYrs do
      CalculatingAmount := CalculatingAmount - ValueChange(CalculatingAmount);
  end else
//  if changetype = 'None' then
    CalculatingAmount := value;

//  result := RoundEx(CalculatingAmount, DecimalPlaces);
// **original  result := RoundEx(CalculatingAmount, fs.CurrencyDecimals);
  result := RoundEx(CalculatingAmount, frMain.DecimalPlaces);
end;

function TdmData.RoundEx(const AInput: real; APlaces: integer): real;
var
  k: real;
begin
  if APlaces = 0 then begin
    result := round(AInput);
  end else begin
    if APlaces > 0 then begin
      k := power(10, APlaces);
      result := round(AInput * k) / k;
    end else begin
      k := power(10, (APlaces*-1));
      result := round(AInput / k) * k;
    end;
  end;
end;

function TdmData.GetRandomColour : TColor;
begin
  Result := RGB(Random(255), Random(255), Random(255));
end;

function TdmData.GetCategoryColour(CategoryID : integer) : TColor;
var CatSQL : TZQuery;
begin
  //very slow, wouldnt want to use in a loop.
  try
    CatSQL := TZQuery.create(nil);
    CatSQL.Connection := dmData.zcDatabaseConnection;
  //  CatSQL.SQL.Clear;
    CatSQL.SQL.Add(
    ' select * '+
    ' from '+dmdata.ztCategory.TableName+
    ' where categid = :categid '+
    ' order by categname '
    );
    CatSQL.ParamByName('categid').AsInteger := CategoryID;
    CatSQL.ExecSQL;
    CatSQL.Active:= True;
    if CatSQL.FieldByName('COLOUR').AsString <> '' then
      Result := StringToColor(CatSQL.FieldByName('COLOUR').AsString)
    else
      Result := clDefault;
  finally
    CatSQL.Free;
  end;
end;

function TdmData.CurrencyStr2DP(CurrencyStr : string) : string;
var x : integer;
//    CurrencyFormat : Byte;
begin
  //  CurrencyFormat = LOCALE_ICURRENCY;
  x := pos('.', CurrencyStr);
  if x = 0 then
    CurrencyStr := CurrencyStr + frMain.DecimalPlacesStr
  else
  begin
    while (length(CurrencyStr) - x) <> frMain.DecimalPlaces do
    begin
      CurrencyStr := CurrencyStr + '0';
    end;
{    if length(CurrencyStr) - x <> 2 then
      CurrencyStr := CurrencyStr + '0';}
  end;
  Result := CurrencyStr;

//  Result := Format('%m', [StrToFloat(CurrencyStr)]);

end;

procedure TdmData.LinkSplitTransactions(TransID : Integer; TableName : string);
begin
  with dmData do
  begin
    ZQuery1.SQL.Clear;
//    ZQuery1.SQL.Add('update '+dmData.ztSplitTransactions.TableName+' set transid = '+IntToStr(TransID)+' where transid = 0;');
    ZQuery1.SQL.Add('update '+TableName+' set transid = '+IntToStr(TransID)+' where transid = 0;');
    ZQuery1.ExecSQL;
  end;
end;

procedure TdmData.RemoveTempSplitTransactions(TableName : string);
begin
  with dmData do
  begin
    ZQuery1.SQL.Clear;
//    ZQuery1.SQL.Add('delete from '+dmData.ztSplitTransactions.TableName+' where transid = 0;');
    ZQuery1.SQL.Add('delete from '+TableName+' where transid = 0;');
    ZQuery1.ExecSQL;
  end;
end;

function TdmData.HasSplitTransactions(TransID : Integer; TableName : string) : Boolean;
begin
  with dmData do
  begin
    ZQuery1.Active:= False;
    ZQuery1.SQL.Clear;
    ZQuery1.SQL.Add(
      ' select s.* '+
      ' from '+TableName+' s '+
      ' where transid = :transid '
      );
    ZQuery1.ParamByName('transid').Value := TransID;
    ZQuery1.ExecSQL;
    ZQuery1.Active:= True;
    Result := (ZQuery1.RecordCount > 0);
  end;
end;

function TdmData.SplitTransactionsTotal{(ads : TDataset)} : Float;
var i: integer;
  vTotal : Float;
begin
  vTotal := 0;
//  ads.First;
  dmData.zqSplitTransactions.first;
  for i:= 1 to dmData.zqSplitTransactions.recordcount do
//  for i:= 1 to ads.RecordCount do
  begin
    vTotal := vTotal + dmData.zqSplitTransactions.fieldByName('SPLITTRANSAMOUNT').AsCurrency;
//    vTotal := vTotal + ads.fieldByName('SPLITTRANSAMOUNT').AsCurrency;
    dmData.zqSplitTransactions.Next;
//    ads.Next;
  end;
  result := vTotal;
end;

function TdmData.StatusBalance(BankAccountID : integer; StatusType : string) : Float;
var vTotal : Float;
begin
  //need to add support for transfered values
  vTotal := 0;
  dmData.zqReport.SQL.Clear;
  dmData.zqReport.SQL.Add(
//  ' select status, sum(transamount) total '+
//  ' select status, sum(amount) totamount '+
  ' select status, ' +
//  ' sum(case transcode when ''Withdrawal'' then transamount * -1 '+
//' else transamount end) as totamount '+

  ' sum(case when (transcode =''Withdrawal'' or transcode = ''Transfer'' and accountid = '+IntToStr(BankAccountID)+
  ') then transamount * -1 else transamount end) totamount '+
  ' from '+dmData.ztCheckingAccount.Tablename +
//  ' where accountid = '+IntToStr(BankAccountID)+
  ' where (accountid = '+IntToStr(BankAccountID)+' or toaccountid = '+IntToStr(BankAccountID)+') '+
  ' and status = '+QuotedStr(StatusType) +
  ' group by status ');
  dmData.zqReport.Active:=True;
  if dmData.zqReport.RecordCount > 0 then
//    vTotal := RoundEx(dmData.zqReport.fieldByName('totamount').AsCurrency, DecimalPlaces)
    vTotal := RoundEx(dmData.zqReport.fieldByName('totamount').AsCurrency, {fs.CurrencyDecimals} frMain.DecimalPlaces)
  else
    vTotal := 0;
  dmData.zqReport.Active:=False;
  result := vTotal;
end;

Procedure TdmData.Dataset2SeparatedFile(ads: TDataset; const Filename: String; const Separator: String = ';');
var  sl: TStringList;
  s: String;
  i: Integer;
  bm: TBookmark;

  Procedure ClipIt;
  begin
    s := Copy(s, 1, Length(s) - Length(Separator));
    sl.Add(s);
    s := '';
  end;
  Function FixIt(const s: String): String;
  begin
    // maybe changed
    Result := StringReplace(StringReplace(StringReplace(s, Separator, '', [rfReplaceAll]), #13, '', [rfReplaceAll]), #10, '', [rfReplaceAll]);
    // additional changes could be Quoting Strings
  end;

begin
  sl := TStringList.Create;
  try
    s := '';
    For i := 0 to ads.FieldCount - 1 do
    begin
      if ads.Fields[i].Visible then
        s := s + FixIt(ads.Fields[i].DisplayLabel) + Separator;
    end;
    ClipIt;
    bm := ads.GetBookmark;
    ads.DisableControls;
    try
      ads.First;
      while not ads.Eof do
      begin
        For i := 0 to ads.FieldCount - 1 do
        begin
          if ads.Fields[i].Visible then
            s := s + FixIt(ads.Fields[i].DisplayText) + Separator;
        end;
        ClipIt;
        ads.Next;
      end;
      ads.GotoBookmark(bm);
    finally
      ads.EnableControls;
      ads.FreeBookmark(bm);
    end;
    sl.SaveToFile(Filename);
  finally
    sl.Free;
  end;
end;

function TdmData.GetNodeByText(ATree : TTreeView; AValue:String; AVisible: Boolean): TTreeNode;
var Node: TTreeNode;
begin
  Result := nil;
  if ATree.Items.Count = 0 then Exit;
  Node := ATree.Items[0];
  while Node <> nil do
  begin
    if UpperCase(Node.Text) = UpperCase(AValue) then
    begin
      Result := Node;
      if AVisible then
        Result.MakeVisible;
      Break;
    end;
    Node := Node.GetNext;
  end;
end;

{procedure TdmData.SaveToExcelFile(const AFileName: TFileName; ads: TDataset);
const
  Worksheet = -4167;
var
  Row, Col: Integer;
  Excel, Sheet, Data: OLEVariant;
  I, J, DataCols, DataRows: Integer;
begin
  DataCols := ads.FieldCount;
  DataRows := ads.RecordCount + 1; //1 for the title

  //Create a variant array the size of your data
  Data := VarArrayCreate([1, DataRows, 1, DataCols], varVariant);

  //write the titles
  for I := 0 to DataCols - 1 do
    Data[1, I+1] := ads.Fields[I].FieldName;

  //write data
  J := 1;
  ads.First;
  while (not ads.Eof) and (J < DataRows) do
  begin
    for I := 0 to DataCols - 1 do
      Data[J + 1, I + 1] := ads.Fields[I].Value;
    Inc(J);
    ads.Next;
  end;

  //Create Excel-OLE Object
  Excel := CreateOleObject('Excel.Application');
  try
    //Don't show excel
    Excel.Visible := False;

    Excel.Workbooks.Add(Worksheet);
    Sheet := Excel.Workbooks[1].WorkSheets[1];
    Sheet.Name := 'Sheet1';
    //Fill up the sheet
    Sheet.Range[RefToCell(1, 1), RefToCell(DataRows, DataCols)].Value := Data;
    //Save Excel Worksheet
    try
      Excel.Workbooks[1].SaveAs(AFileName);
    except
      on E: Exception do
        raise Exception.Create('Data transfer error: ' + E.Message);
    end;
  finally
    if not VarIsEmpty(Excel) then
    begin
      Excel.DisplayAlerts := False;
      Excel.Quit;
      Excel := Unassigned;
      Sheet := Unassigned;
    end;
  end;
end;}

Procedure TdmData.StringGrid2SeparatedFile(StringGrid: TStringGrid; const Filename: String; const Separator: String = ';');
var  sl: TStringList;
  s, Str: String;
  i, j: Integer;

  Procedure ClipIt;
  begin
    s := Copy(s, 1, Length(s) - Length(Separator));
    sl.Add(s);
    s := '';
  end;
  Function FixIt(const s: String): String;
  begin
    // maybe changed
    Result := StringReplace(StringReplace(StringReplace(s, Separator, '', [rfReplaceAll]), #13, '', [rfReplaceAll]), #10, '', [rfReplaceAll]);
    // additional changes could be Quoting Strings
  end;

begin
  Screen.Cursor:= crHourGlass;
  sl := TStringList.Create;
  try
    s := '';

    Str := '';
    For i := 1 to StringGrid.ColCount-1 do
    begin
      if StringGrid.ColWidths[i] > 0 then
      begin
        Str := StringGrid.Cells[i, ColumnHeader];
        s := s + FixIt(Str) + Separator;
      end;
    end;
    ClipIt;

    For I := 1 To StringGrid.RowCount - 1 Do
    begin
      For j := 1 to StringGrid.ColCount - 1 do
      begin
        if StringGrid.ColWidths[j] > 0 then
        begin
          Str := StringGrid.Cells[j, i];
          s := s + FixIt(Str) + Separator;
        end;
      end;
      ClipIt;
    end;

    sl.SaveToFile(Filename);
  finally
    sl.Free;
  end;
  Screen.Cursor:= crDefault;
end;

function TdmData.FindStringGridColumn(StringGrid: TStringGrid; SearchColumn:Integer; FindString:string):Integer ;
var i:Integer ;
begin
  Result:=0 ;
  for i:=1 to StringGrid.RowCount-1 do
  begin
    if Pos(UpperCase(FindString), UpperCase(StringGrid.Cells[SearchColumn,i])) > 0 then
    begin
      StringGrid.Col:=SearchColumn ;
      StringGrid.Row:=i ;
      Result:=i ;
      Exit ;
    end ;
  end ;
end;

function TdmData.FindStringGridTotalColumn(StringGrid: TStringGrid; CategoryID:string):Integer ;
var i:Integer ;
begin
  Result:=0 ;
  for i:=1 to StringGrid.RowCount-1 do
  begin
    if (CategoryID = StringGrid.Cells[sgBudgetCategoryID,i]) and
       (StringGrid.Cells[sgBudgetSubcategoryID,i] = '') then
    begin
      StringGrid.Col:=sgBudgetCategoryID ;
    //  StringGrid.Row:=i ;
      Result:=i ;
      Exit ;
    end ;
  end ;
end;

function TdmData.UpdateAllTotalColumns(StringGrid: TStringGrid; CategoryID:string):Integer ;
var i:Integer ;
  TotAmount, TotEstimated, TotActual : Float;
begin
  Result:=0 ;
  TotAmount := 0;
  TotEstimated := 0;
  TotActual := 0;
  for i:=1 to StringGrid.RowCount-1 do
  begin
    if (CategoryID = StringGrid.Cells[sgBudgetCategoryID,i]) and
    (StringGrid.Cells[sgBudgetSubcategoryID,i] <> '') then
    begin
      {TotAmount := TotAmount + StrToFloat(StringGrid.Cells[sgBudgetAmount,i]);
      TotEstimated := TotEstimated + StrToFloat(StringGrid.Cells[sgBudgetEstimated,i]);
      TotActual := TotActual + StrToFloat(StringGrid.Cells[sgBudgetActual,i]);}
      TotAmount := TotAmount + ConvertCurrencyStringToFloat(StringGrid.Cells[sgBudgetAmount,i]);
      TotEstimated := TotEstimated + ConvertCurrencyStringToFloat(StringGrid.Cells[sgBudgetEstimated,i]);
      TotActual := TotActual + ConvertCurrencyStringToFloat(StringGrid.Cells[sgBudgetActual,i]);
    end;

    if (CategoryID = StringGrid.Cells[sgBudgetCategoryID,i]) and
       (StringGrid.Cells[sgBudgetSubcategoryID,i] = '') then
    begin
//      StringGrid.Cells[sgBudgetAmount, i] := CurrencyStr2DP(FloatToStr(TotAmount));

{      StringGrid.Cells[sgBudgetEstimated, i] := CurrencyStr2DP(FloatToStr(TotEstimated));
      StringGrid.Cells[sgBudgetActual, i] := CurrencyStr2DP(FloatToStr(TotActual));}
      StringGrid.Cells[sgBudgetEstimated, i] := dmdata.ConvertFloatToCurrencyString(TotEstimated);
      StringGrid.Cells[sgBudgetActual, i] := dmdata.ConvertFloatToCurrencyString(TotActual);

      Result:=i ;
      Exit ;
    end ;
  end ;

  //need to add code here for grand total calculation
end;

procedure TdmData.UpdateGrandTotalsColumns(StringGrid: TStringGrid);
var i:Integer ;
  TotAmount, TotEstimated, TotActual,
  EstimatedIncome, EstimatedExpenses, ActualIncome, ActualExpenses: Float;
begin
  TotAmount := 0;
  TotEstimated := 0;
  TotActual := 0;
  for i:=1 to StringGrid.RowCount-1 do
  begin
    //just use category total fields
    if (StringGrid.Cells[sgBudgetCategoryID,i] <> '') and
       (StringGrid.Cells[sgBudgetBudgetYearID,i] = '') and
       (StringGrid.Cells[sgBudgetSubcategoryID,i] = '') then
       begin
         if StringGrid.Cells[sgBudgetAmount,i] <> '' then
//           TotAmount := TotAmount + StrToFloat(StringGrid.Cells[sgBudgetAmount,i]);
           TotAmount := TotAmount + ConvertCurrencyStringToFloat(StringGrid.Cells[sgBudgetAmount,i]);
         if StringGrid.Cells[sgBudgetEstimated,i] <> '' then
           TotEstimated := TotEstimated + ConvertCurrencyStringToFloat(StringGrid.Cells[sgBudgetEstimated,i]);
//         TotEstimated := TotEstimated + StrToFloat(StringGrid.Cells[sgBudgetEstimated,i]);
         if StringGrid.Cells[sgBudgetActual,i] <> '' then
//           TotActual := TotActual + StrToFloat(StringGrid.Cells[sgBudgetActual,i]);
           TotActual := TotActual + ConvertCurrencyStringToFloat(StringGrid.Cells[sgBudgetActual,i]);
       end;
  end ;
//  StringGrid.Cells[sgBudgetAmount, i] := CurrencyStr2DP(FloatToStr(TotAmount));
{  StringGrid.Cells[sgBudgetEstimated, i] := CurrencyStr2DP(FloatToStr(TotEstimated));
  StringGrid.Cells[sgBudgetActual, i] := CurrencyStr2DP(FloatToStr(TotActual));}
  StringGrid.Cells[sgBudgetEstimated, i] := ConvertFloatToCurrencyString(TotEstimated);
  StringGrid.Cells[sgBudgetActual, i] := ConvertFloatToCurrencyString(TotActual);

{  //temp figures
  EstimatedIncome := 0;
  EstimatedExpenses := 0;
  ActualIncome := 0;
  ActualExpenses := 0;

  UpdateBudgetTotalCaptions(EstimatedIncome, EstimatedExpenses, ActualIncome, ActualExpenses);}
end;

function TdmData.CalcEstimatedAmount(Amount: Float; AmountFrequency, BudgetFrequency:string): Float ;
var TempTot:Float ;
  myDate, LoopDate : TDateTime;
  myYear, myMonth, myDay : Word;
  NumofDays, NumofDaysYear : integer;
begin
  myDate := date;
  DecodeDate(myDate, myYear, myMonth, myDay);
  NumofDays := DaysInAMonth(myYear, myMonth);
  NumofDaysYear := DaysInAYear(myYear);

  if BudgetFrequency = 'Monthly' then
    NumofDays := DaysInAMonth(myYear, myMonth)
  else
    NumofDays := NumofDaysYear;

  TempTot := Amount;
  if AmountFrequency = 'Weekly' then TempTot := TempTot * Weekly else
  if AmountFrequency = 'Bi-Weekly' then TempTot := TempTot* BiWeekly else
  if AmountFrequency = 'Monthly' then TempTot := TempTot* Monthly else
  if AmountFrequency = 'Bi-Monthly' then TempTot := TempTot* BiMonthly else
  if AmountFrequency = 'Quarterly' then TempTot := TempTot* Quarterly else
  if AmountFrequency = 'Half-Yearly' then TempTot := TempTot* HalfYearly else
  if AmountFrequency = 'Yearly' then TempTot := TempTot* Yearly else
  if AmountFrequency = 'Daily' then TempTot := TempTot* NumofDays;

  if (BudgetFrequency = 'Monthly') and (AmountFrequency <> 'Daily') then
  begin
    TempTot := TempTot / 12;
  end else
  if BudgetFrequency = 'Yearly' then
  begin
    //Do nothing
  end else
  if BudgetFrequency = 'Quarterly' then
  begin
    TempTot := TempTot / 4;
  end;

//  result := RoundEx(TempTot, DecimalPlaces);
  result := RoundEx(TempTot, {fs.CurrencyDecimals}frMain.DecimalPlaces);
end;

procedure TdmData.PopulateComboBox(ComboBox: TComboBox; DatabaseTable : TZTable; FieldName : string);
var i : integer;
begin
  ComboBox.Items.Clear;
  DatabaseTable.First;
  for i:= 1 to DatabaseTable.recordcount do
  begin
    ComboBox.Items.Add(DatabaseTable.FieldByName(FieldName).AsString);
    DatabaseTable.Next;
  end;
end;

procedure TdmData.CopyBudgetYear(OldBudgetYearID, NewBudgetYearID : Integer);
begin
//  dmData.ztBudget.Active:= False;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' INSERT INTO '+dmData.ztBudget.TableName+' (BUDGETYEARID, CATEGID, SUBCATEGID, PERIOD, AMOUNT) '+
  ' SELECT '+IntToStr(NewBudgetYearID)+', CATEGID, SUBCATEGID, PERIOD, AMOUNT '+
  ' FROM '+dmData.ztBudget.TableName+' WHERE BUDGETYEARID = '+ IntToStr(OldBudgetYearID) +'; '
  );
  ZQuery1.ExecSQL;
//  dmData.ztBudget.Active:= True;
end;

procedure TdmData.UpdateBudgetTotalCaptions(EstimatedIncome, EstimatedExpenses, ActualIncome, ActualExpenses : Float);
var DifferenceIncome, DifferenceExpenses : Float;
  BudgetText, BudgetValueStr: string;
begin
  EstimatedExpenses := EstimatedExpenses * -1;
  ActualExpenses := ActualExpenses * -1;
  DifferenceIncome := EstimatedIncome - ActualIncome;
  DifferenceExpenses := EstimatedExpenses - ActualExpenses;

{  frMain.lBudIncEstimatedTotal.Caption:= 'Estimated: £'+CurrencyStr2DP(FloatToStr(EstimatedIncome));
  frMain.lBudExpEstimatedTotal.Caption:= 'Estimated: £'+CurrencyStr2DP(FloatToStr(EstimatedExpenses));
  frMain.lBudIncActualTotal.Caption:= 'Actual: £'+CurrencyStr2DP(FloatToStr(ActualIncome));
  frMain.lBudExpActualTotal.Caption:= 'Actual: £'+CurrencyStr2DP(FloatToStr(ActualExpenses));

  frMain.lBudIncDifferencelTotal.Caption:= 'Difference: £'+CurrencyStr2DP(FloatToStr(DifferenceIncome)); ;
  frMain.lBudExpDifferencelTotal.Caption:= 'Difference: £'+CurrencyStr2DP(FloatToStr(DifferenceExpenses)); ;}

  frMain.lBudIncEstimatedTotal.Caption:= frMain.CurrencySymbol+ConvertFloatToCurrencyString(EstimatedIncome);
  frMain.lBudExpEstimatedTotal.Caption:= frMain.CurrencySymbol+ConvertFloatToCurrencyString(EstimatedExpenses);
  frMain.lBudIncActualTotal.Caption:= frMain.CurrencySymbol+ConvertFloatToCurrencyString(ActualIncome);
  frMain.lBudExpActualTotal.Caption:= frMain.CurrencySymbol+ConvertFloatToCurrencyString(ActualExpenses);

  frMain.lBudIncDifferencelTotal.Caption:= frMain.CurrencySymbol+ConvertFloatToCurrencyString(DifferenceIncome);
  frMain.lBudExpDifferencelTotal.Caption:= frMain.CurrencySymbol+ConvertFloatToCurrencyString(DifferenceExpenses);

  frMain.lBudEstimatedTotals.Caption:= frMain.CurrencySymbol+ConvertFloatToCurrencyString(EstimatedIncome - EstimatedExpenses);
  frMain.lBudActualTotals.Caption:= frMain.CurrencySymbol+ConvertFloatToCurrencyString(ActualIncome - ActualExpenses);

  frMain.lBudTotalDescription.Font.Color:= clDefault;
  if (EstimatedIncome - EstimatedExpenses) > 0 then
    BudgetText := frMain.CurrencySymbol+ConvertFloatToCurrencyString(EstimatedIncome - EstimatedExpenses) + #13+#10+' Under budget' else
  if (EstimatedIncome - EstimatedExpenses) = 0 then BudgetText := '' else
  if (EstimatedIncome - EstimatedExpenses) < 0 then
  begin
    BudgetValueStr := ConvertFloatToCurrencyString(EstimatedIncome - EstimatedExpenses);
    delete(BudgetValueStr, 1, 1);
    BudgetText := frMain.CurrencySymbol+ BudgetValueStr+ #13+#10+' Over budget';
    frMain.lBudTotalDescription.Font.Color:= clRed;
  end;

  frMain.lBudTotalDescription.Caption := BudgetText;

end;

function TdmData.CategoryActualBalance(CategoryID, SubCategory : integer; Account, FromDate, ToDate : string) : Float;
var vTotal : Float;
  AccountFilter, AccountFrom : string;
begin
  if Account = '[All Accounts]' then
  begin
    AccountFilter := '';
    AccountFrom := '';
  end else
  begin
    AccountFilter := ' and t.accountid = a.accountid and a.accountname = '+QuotedStr(Account)+ ' ';
    AccountFrom := ', '+dmData.ztAccountList.Tablename + ' a ';
  end;

  vTotal := 0;
  dmData.zqReport.SQL.Clear;
  dmData.zqReport.SQL.Add(
  ' select ' +
  ' ifnull(sum(case t.transcode when ''Withdrawal'' then t.transamount * -1 '+
  ' else t.transamount end), 0) as totamount '+
  ' from '+dmData.ztCheckingAccount.Tablename + ' t ' + AccountFrom +
  ' where t.categid = '+IntToStr(CategoryID)+
  ' and t.subcategid = '+IntToStr(SubCategory)+
  ' and t.transdate >= '+QuotedStr(FromDate)+
  ' and t.transdate <= '+QuotedStr(ToDate)+
  AccountFilter);

  dmData.zqReport.Active:=True;
  if dmData.zqReport.RecordCount > 0 then
    vTotal := dmData.zqReport.fieldByName('totamount').AsCurrency //RoundEx(dmData.zqReport.fieldByName('totamount').AsCurrency, 2)
  else
    vTotal := 0;
  dmData.zqReport.Active:=False;
  result := vTotal;
end;

function TdmData.FormatDateToDisplayFormat(datestring : string) : string;
var
{  YearStr, MonthStr, DayStr : string;}
  FormatString : string;
  TempDate :  TDateTime;
begin
  datestring := FormatToUKDate(datestring);
  TempDate := StrToDate(datestring);

  if DisplayDateFormat = 'DDMMYY' then
    FormatString := 'ddmmyy'
  else
  if DisplayDateFormat = 'DD-MM-YY' then
    FormatString := 'dd-mm-yy'
  else
  if DisplayDateFormat = 'DD.MM.YY' then
    FormatString := 'dd.mm.yy'
  else
  if DisplayDateFormat = 'DD/MM/YY' then
    FormatString := 'dd/mm/yy'
  else
  if DisplayDateFormat = 'DDMMYYYY' then
    FormatString := 'ddmmyyyy'
  else
  if DisplayDateFormat = 'DD-MM-YYYY' then
    FormatString := 'dd-mm-yyyy'
  else
  if DisplayDateFormat = 'DD.MM.YYYY' then
    FormatString := 'dd.mm.yyyy'
  else
  if DisplayDateFormat = 'DD/MM/YYYY' then
    FormatString := 'dd/mm/yyyy'
  else
  if DisplayDateFormat = 'MM-DD-YY' then
    FormatString := 'mm-dd-yy'
  else
  if DisplayDateFormat = 'MM.DD.YY' then
    FormatString := 'mm.dd.yy'
  else
  if DisplayDateFormat = 'MM/DD/YY' then
    FormatString := 'mm/dd/yy'
  else
  if DisplayDateFormat = 'MMDDYYYY' then
    FormatString := 'mmddyy'
  else
  if DisplayDateFormat = 'MM-DD-YYYY' then
    FormatString := 'mm-dd-yyyy'
  else
  if DisplayDateFormat = 'MM.DD.YYYY' then
    FormatString := 'mm.dd.yyyy'
  else
  if DisplayDateFormat = 'MM/DD/YYYY' then
    FormatString := 'mm/dd/yyyy'
  else
  if DisplayDateFormat = 'YYMMDD' then
    FormatString := 'yymmdd'
  else
  if DisplayDateFormat = 'YY-MM-DD' then
    FormatString := 'yy-mm-dd'
  else
  if DisplayDateFormat = 'YY.MM.DD' then
    FormatString := 'yy.mm.dd'
  else
  if DisplayDateFormat = 'YY/MM/DD' then
    FormatString := 'yy/mm/dd'
  else
  if DisplayDateFormat = 'YYYYMMDD' then
    FormatString := 'yyyymmdd'
  else
  if DisplayDateFormat = 'YYYY-MM-DD' then
    FormatString := 'yyyy-mm-dd'
  else
  if DisplayDateFormat = 'YYYY.MM.DD' then
    FormatString := 'yyyy.mm.dd'
  else
  if DisplayDateFormat =  'YYYY/MM/DD' then
    FormatString := 'yyyy/mm/dd';

  result := FormatDatetime(FormatString, TempDate);
end;

procedure TdmData.SetupComboBox(var ComboBox : TComboBox; DatabaseTable : TZTable; FieldName, AllItemsText, SelectedItem : String);
var i, SelectedIndex : integer;
    BeforeSortFieldName, BeforeSortIndex : string;
{    BeforeSortSortType : TSortType;}
begin
  ComboBox.Items.Clear;
  BeforeSortIndex := DatabaseTable.IndexFieldNames;
  BeforeSortFieldName := DatabaseTable.SortedFields;
//  BeforeSortSortType := DatabaseTable.SortType;

  DatabaseTable.SortedFields:= FieldName;
//  DatabaseTable.SortType:= stAscending;
  DatabaseTable.IndexFieldNames:= FieldName + ' Asc';
  DatabaseTable.First;
  ComboBox.Items.Add(AllItemsText);
//  if SelectedItem = '' then SelectedItem := AllItemsText;
  if SelectedItem = AllItemsText then
    SelectedIndex := 0;
  for i:= 1 to DatabaseTable.RecordCount do
  begin
{    if DatabaseTable.FieldByName('ARCHIVED').AsString = '0' then
    begin}
      ComboBox.Items.Add(DatabaseTable.FieldByName(FieldName).AsString);
      if SelectedItem = DatabaseTable.FieldByName(FieldName).AsString then
        SelectedIndex := i;
//    end;
    DatabaseTable.Next;
  end;
  ComboBox.ItemIndex:= SelectedIndex;
  if SelectedItem = '' then ComboBox.ItemIndex := -1;

  DatabaseTable.IndexFieldNames := BeforeSortIndex;
  DatabaseTable.SortedFields := BeforeSortFieldName;
end;

procedure TdmData.SetupComboBoxFilterArchived(var ComboBox : TComboBox; DatabaseTable : TZTable; FieldName, AllItemsText, SelectedItem : String);
var i, SelectedIndex : integer;
    BeforeSortFieldName, BeforeSortIndex : string;
//    BeforeSortSortType : TSortType;
begin
  ComboBox.Items.Clear;
  BeforeSortIndex := DatabaseTable.IndexFieldNames;
  BeforeSortFieldName := DatabaseTable.SortedFields;
//  BeforeSortSortType := DatabaseTable.SortType;

  DatabaseTable.SortedFields:= FieldName;
//  DatabaseTable.SortType:= stAscending;
  DatabaseTable.IndexFieldNames:= FieldName + ' Asc';
  DatabaseTable.First;
  if AllItemsText <> '' then
    ComboBox.Items.Add(AllItemsText);
//  if SelectedItem = '' then SelectedItem := AllItemsText;
  if SelectedItem = AllItemsText then
    SelectedIndex := 0;
  for i:= 1 to DatabaseTable.RecordCount do
  begin
    if DatabaseTable.FieldByName('ARCHIVED').AsString = '0' then
    begin
      ComboBox.Items.Add(DatabaseTable.FieldByName(FieldName).AsString);
      if SelectedItem = DatabaseTable.FieldByName(FieldName).AsString then
        SelectedIndex := i;
    end;
    DatabaseTable.Next;
  end;
  ComboBox.ItemIndex:= SelectedIndex;
  if SelectedItem = '' then ComboBox.ItemIndex := -1;

  DatabaseTable.IndexFieldNames := BeforeSortIndex;
  DatabaseTable.SortedFields := BeforeSortFieldName;
end;

function TdmData.ConvertFloatToCurrencyString(Currency : float) : string;
var decSep : char;
begin
//  result := CurrToStrF(Currency, ffNumber , DecimalPlaces);    //with comma formatting no currency symbol
// ** original //  result := CurrToStrF(Currency, ffNumber , fs.CurrencyDecimals);    //with comma formatting no currency symbol
//  result := FloatToStr(Currency, fs);
  result := CurrToStrF(Currency, ffNumber , frMain.DecimalPlaces);    //with comma formatting no currency symbol
end;

function TdmData.ConvertCurrencyStringToFloat(CurrencyString : string) : float;
var Str : string;
begin
  Str := StripChars(CurrencyString, ',');
  if Str = '' then
    result := 0
  else
    result := StrToFloat(Str);
end;

procedure TdmData.SetupBetweenDatesSQL(var FromDate, ToDate : String; DateType : TDateQuery);
var NumofDays, NumofDaysYear, StartDay, EndDay : integer;
  myDate : TDateTime;
  myYear, myMonth, myDay : Word;
  myMonth2DP : string;
begin
  myDate := date;
  DecodeDate(myDate, myYear, myMonth, myDay);
  NumofDays := DaysInAMonth(myYear, myMonth);
  NumofDaysYear := DaysInAYear(myYear);

  if myMonth < 10 then
    myMonth2DP := '0'+IntToStr(myMonth)
  else
    myMonth2DP := IntToStr(myMonth);

  case DayOfWeek(now) of
    1 : begin //sunday
          StartDay := 6;
          EndDay := 0;
        end;
    2 : begin //monday
          StartDay := 0;
          EndDay := 6;
        end;
    3 : begin //tuesday
          StartDay := 1;
          EndDay := 5;
        end;
    4 : begin //wedsday
          StartDay := 2;
          EndDay := 4;
        end;
    5 : begin //thursday
          StartDay := 3;
          EndDay := 3;
        end;
    6 : begin //friday
          StartDay := 4;
          EndDay := 2;
        end;
    7 : begin  //saturday
          StartDay := 5;
          EndDay := 1;
        end;
  end;

  if DateType = dqCurrentWeek then
  begin
    FromDate := FormatDateTime('YYYY-MM-DD', (now - StartDay));
    ToDate := FormatDateTime('YYYY-MM-DD', (now + EndDay));
  end else
  if DateType = dqCurrentMonth then
  begin
    FromDate := IntToStr(myYear)+'-'+myMonth2DP+'-01';
    ToDate := IntToStr(myYear)+'-'+myMonth2DP+'-'+IntToStr(NumofDays);
  end else
  if DateType = dqCurrentYear then
  begin
    FromDate := IntToStr(myYear) +'-01-01';
    ToDate := IntToStr(myYear) +'-12-'+IntToStr(DaysInAMonth(myYear, 12));
  end else
  if DateType = dqCurrentQuarter then
  begin
    case myMonth of
     1,2,3 : begin
               FromDate := IntToStr(myYear)+'-01-01';
               ToDate := IntToStr(myYear)+'-03-'+IntToStr(DaysInAMonth(myYear, 3));
             end;
     4,5,6 :begin
               FromDate := IntToStr(myYear)+'-04-01';
               ToDate := IntToStr(myYear)+'-06-'+IntToStr(DaysInAMonth(myYear, 6));
             end;
     7,8,9 :begin
               FromDate := IntToStr(myYear)+'-07-01';
               ToDate := IntToStr(myYear)+'-09-'+IntToStr(DaysInAMonth(myYear, 9));
             end;
     10,11,12 :begin
               FromDate := IntToStr(myYear)+'-10-01';
               ToDate := IntToStr(myYear)+'-12-'+IntToStr(DaysInAMonth(myYear, 12));
             end;
    end;
  end;
end;

function TdmData.SetupDateSQL(Date : String; DateType, DateModifier : integer) : string;
var NumofDays, NumofDaysYear, StartDay, EndDay : integer;
  myDate : TDateTime;
  myYear, myMonth, myDay : Word;
begin
  myDate := StrToDate(FormatToUKDate(Date));
  DecodeDate(myDate, myYear, myMonth, myDay);
  NumofDays := DaysInAMonth(myYear, myMonth);
  NumofDaysYear := DaysInAYear(myYear);

  case DayOfWeek(now) of
    1 : begin //sunday
          StartDay := 6;
          EndDay := 0;
        end;
    2 : begin //monday
          StartDay := 0;
          EndDay := 6;
        end;
    3 : begin //tuesday
          StartDay := 1;
          EndDay := 5;
        end;
    4 : begin //wedsday
          StartDay := 2;
          EndDay := 4;
        end;
    5 : begin //thursday
          StartDay := 3;
          EndDay := 3;
        end;
    6 : begin //friday
          StartDay := 4;
          EndDay := 2;
        end;
    7 : begin  //saturday
          StartDay := 5;
          EndDay := 1;
        end;
  end;

  case DateType of
    trWeekly : myDate := IncWeek(myDate, 1);
    trBiWeekly : myDate := IncWeek(myDate, 2);
    trMonthly : myDate := IncMonth(myDate, 1);
    trBiMonthly : myDate := IncMonth(myDate, 2);
    trQuartertly : myDate := IncMonth(myDate, 3);
    trHalfYearly : myDate := IncMonth(myDate, 6);
    trFourMonths : myDate := IncMonth(myDate, 4);
    trFourWeeks : myDate := IncWeek(myDate, 4);
    trDaily : myDate := myDate + 1;
    trInXDays : myDate := myDate + DateModifier;
    trInXMonths : myDate := IncMonth(myDate, DateModifier);
{    trMonthlyLastDay : begin
                       end;
    trMonthlyLastBusinessDay : begin
                       end;}
  end;

  result := FormatDateTime('YYYY-MM-DD',myDate);

//  result := DateToStr(myDate);
end;

function TdmData.GetTransactionStatusText(Status : string) : string;
begin
  if status = 'N' then
    result := 'None' else
  if status = 'R' then
    result := 'Reconciled' else
  if status = 'V' then
    result := 'Void' else
  if status = 'F' then
    result := 'Follow Up' else
  if status = 'D' then
    result := 'Duplicate';
end;

Procedure TdmData.RefreshDataset(ads: TDataset);
begin
  if ads.Active then ads.Refresh;
end;

Procedure TdmData.SaveChanges(ads: TDataset; Refresh : Boolean);
begin
  Screen.Cursor:= crHourGlass;
  try
    ads.Post;
  except
     on E : Exception do
      ShowMessage(E.ClassName+' error saving, with message : '+E.Message);
  end;
  if Refresh then RefreshDataset(ads);
  Screen.Cursor:= crDefault;
end;

procedure TdmData.EmptyDatabaseTable(Tablename : string);
begin
  with dmData do
  begin
    ZQuery1.SQL.Clear;
    ZQuery1.SQL.Add('delete from '+TableName+';');
    ZQuery1.ExecSQL;
  end;
end;

procedure TdmData.SetToolbarPositions(ToolbarPosition : Integer);
begin
  case ToolbarPosition of
    0 : begin
          frMain.tbAssets.Align:= alTop;
          frMain.tbBankAccounts.Align:= alTop;
          frMain.tbPayees.Align:= alTop;
          frMain.tbRepTrans.Align:= alTop;
          frMain.tbReports.Align:= alTop;
          frMain.tbBudgets.Align:= alTop;
        end;
    1 : begin
          frMain.tbAssets.Align:= alBottom;
          frMain.tbBankAccounts.Align:= alBottom;
          frMain.tbPayees.Align:= alBottom;
          frMain.tbRepTrans.Align:= alBottom;
          frMain.tbReports.Align:= alBottom;
          frMain.tbBudgets.Align:= alBottom;
        end;
  end;
end;

// code for the stringExplode method...
Procedure TdmData.StringExplode(s: string; Delimiter: string; Var res: TStringList);
Begin
	res.Clear;
	res.Text := StringReplace(s, Delimiter, #13#10, [rfIgnoreCase, rfReplaceAll]);
End;

{procedure TdmData.SaveGridLayout(Mydbgrid: TDBGrid; fileName: string);
var
  lines: TStringList;
  i: integer;
begin
  try
    lines := TStringList.Create;
    with Mydbgrid do
    begin
      for i := 0 to Mydbgrid.Columns.count-1 do
      begin
	lines.Add(  IntToStr(Mydbgrid.Columns[i].Index)
	+ '~ ' + Mydbgrid.Columns[i].DisplayName
	+ '~ ' + Mydbgrid.Columns[i].Title.Caption
	+ '~ ' + IntToStr(Mydbgrid.Columns[i].Width)
	+ '~ ' + BoolToStr(Mydbgrid.Columns[i].Visible)
        );
      end;
    end;
    lines.SaveToFile(fileName);
  finally
    lines.free;
  end;
end;}

{procedure TdmData.LoadGridLayout(Mydbgrid: TDBGrid; fileName: string);
var
  lines: TStringList;
  columnInfo: TStringList;
  lineCtr: integer;
  colIdx: integer;
  cnt: integer;
begin
  if Fileexists(filename) = false then exit;
  try
    lines := TStringList.Create;
    columnInfo := TStringList.Create;
    lines.LoadFromFile(fileName);
    for lineCtr := 0 to lines.Count-1 do
    begin
      if trim(lines[lineCtr]) <> '' then
      begin
	StringExplode(lines[lineCtr], '~ ', columnInfo);
	cnt:=Mydbgrid.Columns.count;
	// go through all the columns, looking for the one we are currently working on
	for colIdx := 0 to cnt-1 do
        begin
	  // once found, set its width and title, then its index (order)
	  if Mydbgrid.Columns[colIdx].FieldName = columnInfo[1] then
          begin
            Mydbgrid.Columns[colIdx].Visible := StrToBool(columnInfo[4]);
	    Mydbgrid.Columns[colIdx].Width := StrToInt(columnInfo[3]);
	    Mydbgrid.Columns[colIdx].Title.Caption := columnInfo[2];
	   // do the index assignment last!
	    // ignore the index specified in the file. use its line
	    Mydbgrid.Columns[colIdx].Index := lineCtr; //StrToInt(columnInfo[0]); order instead
	  end; // if
	end;
      end;
    end;
  finally
    lines.free;
    if assigned(columnInfo) then columnInfo.free;
  end;
end;}

procedure TdmData.LoadGridLayout(Mydbgrid: TDBGrid);
var i, colIdx, cnt : integer;
begin
  ZQuery1.Connection := zcDatabaseConnection;
  zcDatabaseConnection.Connected:= True;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(
  ' select * from '+ztGridSettings.TableName+' where gridname = '+QuotedStr(Mydbgrid.Name) +' order by columnindex');
  ZQuery1.ExecSQL;
  ZQuery1.Active:= True;

  for i:= 1 to dmData.ZQuery1.RecordCount do
  begin
    cnt:=Mydbgrid.Columns.count;
    for colIdx := 0 to cnt-1 do
    begin
      if Mydbgrid.Columns[colIdx].FieldName = dmData.ZQuery1.FieldByName('FIELDNAME').AsString then
      begin
        Mydbgrid.Columns[colIdx].Visible := StrToBool(dmData.ZQuery1.FieldByName('VISIBLE').AsString);
        Mydbgrid.Columns[colIdx].Width := dmData.ZQuery1.FieldByName('COLUMNWIDTH').AsInteger;
        Mydbgrid.Columns[colIdx].Title.Caption := dmData.ZQuery1.FieldByName('CAPTION').AsString;
        Mydbgrid.Columns[colIdx].Index := dmData.ZQuery1.FieldByName('COLUMNINDEX').AsInteger;
      end;
    end;
    dmData.ZQuery1.Next;
  end;
  ZQuery1.Active:= False;
end;

procedure TdmData.SaveGridLayout(Mydbgrid: TDBGrid);
var i : integer;
begin
  with Mydbgrid do
  begin
    for i := 0 to Mydbgrid.Columns.count-1 do
    begin
      if dmData.ztGridSettings.Locate('GRIDNAME;FIELDNAME', VarArrayOf([Mydbgrid.Name, Mydbgrid.Columns[i].DisplayName]), [loCaseInsensitive]) = True then
        dmData.ztGridSettings.Edit
      else
        dmData.ztGridSettings.Insert;

      dmData.ztGridSettings.FieldByName('GRIDNAME').AsString := Mydbgrid.Name;
      dmData.ztGridSettings.FieldByName('COLUMNINDEX').AsInteger := Mydbgrid.Columns[i].Index;
      dmData.ztGridSettings.FieldByName('FIELDNAME').AsString := Mydbgrid.Columns[i].DisplayName;
      dmData.ztGridSettings.FieldByName('CAPTION').AsString := Mydbgrid.Columns[i].Title.Caption;
      dmData.ztGridSettings.FieldByName('COLUMNWIDTH').AsInteger := Mydbgrid.Columns[i].Width;
      dmData.ztGridSettings.FieldByName('VISIBLE').AsString := BoolToStr(Mydbgrid.Columns[i].Visible);
      dmData.SaveChanges(dmData.ztGridSettings, false);
    end;
  end;

end;

procedure TdmData.DeleteDBRecord(TableName, WhereIDField : string; DeleteIDField : Integer);
begin
  dmData.ZQuery1.SQL.Clear;
  dmData.ZQuery1.SQL.Add('delete from '+TableName+' where '+WhereIDField+' = '+IntToStr(DeleteIDField)+';');
  dmData.ZQuery1.ExecSQL;
end;

procedure TdmData.SetupCurrencyValues;
var i, DecPlaces : integer;
  TmpStr : String;
begin
  TmpStr := '';
  decplaces := GetInfoSettingsInt('FINANCIAL_DECIMAL_PLACES', 2);
  frMain.CurrencySymbol := GetInfoSettings('FINANCIAL_CURRENCY_SYMBOL', '£');
  frMain.DecimalPlaces := decplaces;
  for i:=1 to DecPlaces do
  begin
    TmpStr := TmpStr + '0';
  end;
  frMain.DecimalPlacesStr := '.' + TmpStr;
  frMain.FullDecimalPlacesStr := '0.'+ TmpStr;
end;

end.

