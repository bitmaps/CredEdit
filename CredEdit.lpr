program CredEdit;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, tachartlazaruspkg, printer4lazarus, tachartaggpas,
  zcomponent, uMain, uAccountWizard, uAccount, uOrganiseCategories, uAbout,
  uNewTransaction, uAsset, uOptions, uOrganisePayees, uDataModule,
  uImportWizard, uRelocateCategory, uSQLLog, uRelocatePayee, uReportFuncs,
  uLogin, uBudgetEntry, uReportFilter, uSplitTransaction, uSplitDetail,
  uRepeatingTransaction, uBudgetEditor, uBudget, uTransactionFilter,
  uTransFiltersList, uErrorDialog, uPayeeImport, uProgressBar, uEmptyTables;

{$R *.res}

begin
  Application.Title:='CredEdit';
 //'CredEdit';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrMain, frMain);
  Application.CreateForm(TfrSQLLog, frSQLLog);
  Application.Run;
end.

