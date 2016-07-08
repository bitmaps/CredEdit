{ To do list:

1.

}
unit uImport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  EditBtn, StdCtrls, Grids, DBGrids, ExtCtrls, Spin, DbCtrls,
  ZDataset, ZConnection, ZSqlUpdate, IniFiles, sqldb, db, mssqlconn,
  sqlite3conn;

type

  { TfrImport }

  TfrImport = class(TForm)
    bClose: TButton;
    bCreateTables: TButton;
    bEmptyTables: TButton;
    bImport: TButton;
    bAdd: TButton;
    bRemove: TButton;
    bUp: TButton;
    bDown: TButton;
    bOpen: TButton;
    bSaveAs: TButton;
    bDefault: TButton;
    cbDateFormat: TComboBox;
    cbStripApostrophe: TCheckBox;
    dbcbAccountName: TDBComboBox;
    eUserDefined: TEdit;
    fneImportFile: TFileNameEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbChosenCSVFields: TListBox;
    lbCSVFields: TListBox;
    OpenDialogCSVOrder: TOpenDialog;
    PageControl1: TPageControl;
    pbImport: TProgressBar;
    RadioGroup1: TRadioGroup;
    rgCSVDelimiter: TRadioGroup;
    SaveDialogCSVOrder: TSaveDialog;
    sgImportFile: TStringGrid;
    seIgnoreLines: TSpinEdit;
    tsImport: TTabSheet;
    procedure bAddClick(Sender: TObject);
    procedure bCloseClick(Sender: TObject);
    procedure bCreateTablesClick(Sender: TObject);
    procedure bDefaultClick(Sender: TObject);
    procedure bDownClick(Sender: TObject);
    procedure bEmptyTablesClick(Sender: TObject);
    procedure bImportClick(Sender: TObject);
    procedure bOpenClick(Sender: TObject);
    procedure bRemoveClick(Sender: TObject);
    procedure bSaveAsClick(Sender: TObject);
    procedure bUpClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure fneImportFileChange(Sender: TObject);
    procedure lbChosenCSVFieldsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbChosenCSVFieldsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbChosenCSVFieldsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LoadImportFile(ImportFilename : string);
    procedure OpenDatabase;
    procedure LoadSettings;
    procedure rgCSVDelimiterChangeBounds(Sender: TObject);
    procedure rgCSVDelimiterClick(Sender: TObject);
    procedure rgCSVDelimiterSelectionChanged(Sender: TObject);
    procedure SaveSettings;
    procedure OpenDatabaseTables;
    procedure CloseDatabaseTables;
    procedure LoadCSVOrder(filename : string);
    function StripApostropheFromString(InString : string ) : string;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frImport: TfrImport;
  StartingPoint : TPoint;

implementation

{$R *.lfm}
uses uMain, uDataModule;

{ TfrImport }

procedure TfrImport.LoadImportFile(ImportFilename : string);
begin
//  sgImportFile.LoadFromCSVFile(ImportFilename, eUserDefined.Text, False);
  sgImportFile.LoadFromCSVFile(ImportFilename, ',', False);
end;

procedure TfrImport.SaveSettings;
var IniFile : TIniFile;
begin
  lbChosenCSVFields.Items.SaveToFile(ExtractFilePath(application.exename)+'csvimp.mcv');

  try
    IniFile := TIniFile.create(ExtractFilePath(application.exename)+'settings.ini');
    IniFile.WriteString('Configuration', 'ImportFilename', fneImportFile.Text);
    IniFile.WriteString('Configuration', 'OpenCSVDir', OpenDialogCSVOrder.InitialDir);
    IniFile.WriteString('Configuration', 'SaveCSVDir', SaveDialogCSVOrder.InitialDir);
    IniFile.WriteInteger('Configuration', 'IgnoreLines', seIgnoreLines.Value);
    IniFile.WriteBool('Configuration', 'StripApostrophe', cbStripApostrophe.Checked);
    IniFile.WriteInteger('Configuration', 'DateFormat', cbDateFormat.ItemIndex);
    IniFile.WriteInteger('Configuration', 'AccountName', dbcbAccountName.ItemIndex);
{    IniFile.WriteInteger('Configuration', 'WindowWidth', frImport.Width);
    IniFile.WriteInteger('Configuration', 'WindowHeight', frImport.Height);
    IniFile.WriteInteger('Configuration', 'WindowLeft', frImport.Left);
    IniFile.WriteInteger('Configuration', 'WindowTop', frImport.Top);}
  finally
    IniFile.Free;
  end;
end;

procedure TfrImport.OpenDatabase;
begin
  dmData.zcDatabaseConnection.Connected:= True;
  dmData.ztCategory.Active:= True;
  dmData.ztPayee.Active:= True;
  dmData.ztSubCategory.Active:= True;
  dmData.ztAccountList.Active:= True;
end;

procedure TfrImport.LoadCSVOrder(filename : string);
var     i, j : integer;
    tmpstr : string;
begin
  if fileexists(filename) then
  begin
    lbChosenCSVFields.Items.LoadFromFile(ExtractFilePath(application.exename)+'csvimp.mcv');
    for i:=0 to lbChosenCSVFields.Items.Count-1 do
    begin
      tmpstr := lbChosenCSVFields.Items.Strings[i];
      j := lbCSVFields.Items.IndexOf(tmpstr);
      if (j > -1) and (tmpstr <> 'Ignore') then
        lbCSVFields.Items.Delete(j);
    end;
  end;
end;

procedure TfrImport.LoadSettings;
var IniFile : TIniFile;
begin
  if FileExists(ExtractFilePath(application.exename)+'csvimp.mcv') then
    LoadCSVOrder(ExtractFilePath(application.exename)+'csvimp.mcv');
  try
    IniFile := TIniFile.create(ExtractFilePath(application.exename)+'settings.ini');
    fneImportFile.Text := IniFile.ReadString('Configuration', 'ImportFilename', '');
    OpenDialogCSVOrder.InitialDir := IniFile.ReadString('Configuration', 'OpenCSVDir', ExtractFilePath(application.exename));
    SaveDialogCSVOrder.InitialDir := IniFile.ReadString('Configuration', 'SaveCSVDir', ExtractFilePath(application.exename));
    seIgnoreLines.Value := IniFile.ReadInteger('Configuration', 'IgnoreLines', 0);
    cbStripApostrophe.Checked := IniFile.ReadBool('Configuration', 'StripApostrophe', True);
    cbDateFormat.ItemIndex := IniFile.ReadInteger('Configuration', 'DateFormat', 0);
    dbcbAccountName.ItemIndex := IniFile.ReadInteger('Configuration', 'AccountName', 0);
{    frImport.Width := IniFile.ReadInteger('Configuration', 'WindowWidth', 585);
    frImport.Height := IniFile.ReadInteger('Configuration', 'WindowHeight', 510 );
    frImport.Left := IniFile.ReadInteger('Configuration', 'WindowLeft', 388);
    frImport.Top := IniFile.ReadInteger('Configuration', 'WindowTop', 218);}
  finally
    IniFile.Free;
  end;
end;

procedure TfrImport.rgCSVDelimiterChangeBounds(Sender: TObject);
begin
end;

procedure TfrImport.rgCSVDelimiterClick(Sender: TObject);
begin
end;

procedure TfrImport.rgCSVDelimiterSelectionChanged(Sender: TObject);
begin
  case rgCSVDelimiter.itemindex of
    0 : eUserDefined.Text := ',';
    1 : eUserDefined.Text := ';';
    2 : eUserDefined.Text := ',';
    3 : eUserDefined.Text := ',';
  end;
end;

procedure TfrImport.bCloseClick(Sender: TObject);
begin
  close;
end;

procedure TfrImport.bCreateTablesClick(Sender: TObject);
begin

end;

procedure TfrImport.bDefaultClick(Sender: TObject);
begin
  lbChosenCSVFields.Items.Clear;
  lbCSVFields.Items.Clear;
  lbCSVFields.Items.Add('Date');
  lbCSVFields.Items.Add('Payee');
  lbCSVFields.Items.Add('Amount(+/-)');
  lbCSVFields.Items.Add('Category');
  lbCSVFields.Items.Add('SubCategory');
  lbCSVFields.Items.Add('Number');
  lbCSVFields.Items.Add('Notes');
  lbCSVFields.Items.Add('Ignore');
  lbCSVFields.Items.Add('Withdrawal');
  lbCSVFields.Items.Add('Deposit');
  lbCSVFields.Items.Add('To/From(+/-)');
  lbCSVFields.Items.Add('Balance');
end;

procedure TfrImport.bDownClick(Sender: TObject);
var CurrIndex, LastIndex: Integer;
begin
  with lbChosenCSVFields do
  begin
    CurrIndex := ItemIndex;
    LastIndex := Items.Count;
    if ItemIndex <> -1 then
    begin
      if CurrIndex + 1 < LastIndex then
      begin
        Items.Move(ItemIndex, (CurrIndex + 1));
        ItemIndex := CurrIndex + 1;
      end;
    end;
  end;
end;


procedure TfrImport.OpenDatabaseTables;
begin
  dmData.ztCategory.Open;
  dmData.ztPayee.Open;
  dmData.ztCheckingAccount.Open;
  dmData.ztSubCategory.Open;
  dmData.ztAccountList.Open;
end;

procedure TfrImport.CloseDatabaseTables;
begin
  dmData.ztCategory.Close;
  dmData.ztPayee.Close;
  dmData.ztCheckingAccount.Close;
  dmData.ztSubCategory.Close;
  dmData.ztAccountList.Close;
end;

function TfrImport.StripApostropheFromString(InString : string ) : string;
var i : integer;
begin
  result := InString;
  if not cbStripApostrophe.Checked then exit;
  i := pos('''', InString);
  if i = 1 then
    delete(InString, i, 1);
  result := InString;
end;

procedure TfrImport.bEmptyTablesClick(Sender: TObject);
begin
{  SQLQuery1.sql.text := 'delete from CATEGORY';
  SQLQuery1.ExecSQL;
  SQLQuery1.sql.text := 'delete from PAYEE';
  SQLQuery1.ExecSQL;
  SQLTransaction1.Commit;}
end;

procedure TfrImport.bImportClick(Sender: TObject);
var i,j, CatID, PayeeID, ChkAccID, AccID,ToAccID, SubCatID, ImportRowStart : integer;
  Str,TransDateStr, CategoryStr,SubCatStr, PayeeStr, TransCodeStr, NotesStr,TransNumber : string;
  Balance, Amount, Withdrawal, Deposit : Currency;
begin
  if sgImportFile.ColCount <> lbChosenCSVFields.Items.Count then
  begin
     MessageDlg('Column import file count does not match column setup.',mtError, [mbOK], 0);
     exit;
  end;
  {  Str := sgImportFile.Cells[1, i];
    SQLQuery1.sql.text := 'insert OR IGNORE into CATEGORY (CATEGNAME) values (:CATEGNAME)';
    SQLQuery1.Params.ParamByName('CATEGNAME').AsString := Str;
    SQLQuery1.ExecSQL;}

{    qCategory.sql.text := 'select CATEGID from CATEGORY where CATEGNAME = :CATEGNAME';
    qCategory.Params.ParamByName('CATEGNAME').AsString := Str;
    qCategory.ExecSQL;
}
{    SQLQuery1.sql.text := 'insert OR IGNORE into PAYEE (PAYEENAME) values (:PAYEENAME)';
//    SQLQuery1.sql.text := 'insert OR IGNORE into PAYEE (PAYEENAME, CATEGID) values (:PAYEENAME, :CATEGID)';
    SQLQuery1.Params.ParamByName('PAYEENAME').AsString := Str;
//    SQLQuery1.Params.ParamByName('CATEGID').AsString := idStr;
    SQLQuery1.ExecSQL;

    SQLTransaction1.Commit;}

    {SQLQuery1.InsertSQL.Add('INSERT INTO CATEGORY(CATEGNAME) VALUES ('+Str+'); ');;
    SQLQuery1.ExecSQL;
    SQLQuery1.Post;
    SQLQuery1.ApplyUpdates;

    select p.*, c.categname, s.subcategname
    from payee_v1 p, category_v1 c, subcategory_v1 s
    where p.categid = c.categid
    and p.subcategid = s.subcategid;

    }
  pbImport.max := sgImportFile.RowCount;
  pbImport.step := 1;


{  lbChosenCSVFields.Items.IndexOf('Balance');}

//  OpenDatabaseTables;
  j := 1 + seIgnoreLines.Value;

  for i:=j to sgImportFile.RowCount-1 do
  begin
    AccID := -1;
    CatID := -1;
    SubCatID := -1;
    PayeeID := -1;
    ChkAccID := -1;
    ToAccID := -1;
    CategoryStr := '';
    TransDateStr := '';
    PayeeStr := '';
    SubCatStr := '';
    NotesStr := '';
    TransCodeStr := '';
    TransNumber := '';

    if lbChosenCSVFields.Items.IndexOf('Date') > -1 then
      TransDateStr := sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Date'), i];

    if lbChosenCSVFields.Items.IndexOf('Notes') > -1 then
    begin
      NotesStr := StripApostropheFromString(NotesStr);
      NotesStr := sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Notes'), i];
    end;
    if lbChosenCSVFields.Items.IndexOf('Number') > -1 then
    begin
      TransNumber := StripApostropheFromString(TransNumber);
      TransNumber := sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Number'), i];
    end;

    if lbChosenCSVFields.Items.IndexOf('Withdrawal') > -1 then
    begin
      Amount := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Withdrawal'), i]);
      Withdrawal := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Withdrawal'), i]);
      if Amount >= 0 then
        TransCodeStr := 'Withdrawal'
      else
        TransCodeStr := 'Deposit';
    end;

    if lbChosenCSVFields.Items.IndexOf('Deposit') > -1 then
    begin
      Amount := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Deposit'), i]);
      Deposit := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Deposit'), i]);
      if Amount >= 0 then
        TransCodeStr := 'Deposit'
      else
        TransCodeStr := 'Withdrawal';
    end;

    if lbChosenCSVFields.Items.IndexOf('Amount(+/-)') > -1 then
    begin
      Amount := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Amount(+/-)'), i]);

      if Amount >= 0 then
      begin
        TransCodeStr := 'Deposit';
        Deposit := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Deposit'), i]);
      end else
      begin
        TransCodeStr := 'Withdrawal';
        Withdrawal := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Withdrawal'), i]);
      end;
    end;

    if lbChosenCSVFields.Items.IndexOf('To/From(+/-)') > -1 then
    begin
      Amount := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('To/From(+/-)'), i]);
      if Amount >= 0 then
      begin
        TransCodeStr := 'Withdrawal';
        Withdrawal := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Withdrawal'), i]);
      end else
      begin
        TransCodeStr := 'Deposit';
        Deposit := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Deposit'), i]);
      end;
    end;

    //category
    if lbChosenCSVFields.Items.IndexOf('Category') > -1 then
    begin
      dmData.ztCategory.Open;
      CategoryStr := sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Category'), i];
      CategoryStr := StripApostropheFromString(CategoryStr);
      if dmData.ztCategory.Locate('CATEGNAME', CategoryStr, [loCaseInsensitive]) = True then
      CatID := dmData.ztCategory.fieldbyname('CATEGID').AsInteger else
      begin
        dmData.ztCategory.Insert;
        dmData.ztCategory.FieldByName('CATEGNAME').AsString := CategoryStr;
        dmData.ztCategory.Post;
        CatID := dmData.ztCategory.fieldbyname('CATEGID').AsInteger;
      end;
      dmData.ztCategory.Close;
    end;

    //subcategory
    if lbChosenCSVFields.Items.IndexOf('SubCategory') > -1 then
    begin
      dmData.ztSubCategory.Open;
      SubCatStr := sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('SubCategory'), i];
      SubCatStr := StripApostropheFromString(SubCatStr);
      if dmData.ztSubCategory.Locate('SUBCATEGNAME', SubCatStr, [loCaseInsensitive]) = True then
      begin
        SubCatID := dmData.ztSubCategory.fieldbyname('SUBCATEGID').AsInteger;
        if dmData.ztSubCategory.fieldbyname('CATEGID').AsInteger >= 0 then
          CatID := dmData.ztSubCategory.fieldbyname('CATEGID').AsInteger;
      end else
      begin
        dmData.ztSubCategory.Insert;
        dmData.ztSubCategory.FieldByName('SUBCATEGNAME').AsString := SubCatStr;
        dmData.ztSubCategory.Post;
        SubCatID := dmData.ztSubCategory.fieldbyname('SUBCATEGID').AsInteger;
      end;
      dmData.ztSubCategory.Close;
    end;

    //payee
    if lbChosenCSVFields.Items.IndexOf('Payee') > -1 then
    begin
      dmData.ztPayee.Open;
      PayeeStr := sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Payee'), i];
      PayeeStr := StripApostropheFromString(PayeeStr);
      if dmData.ztPayee.Locate('PAYEENAME', PayeeStr, [loCaseInsensitive]) = True then
      begin
        PayeeID := dmData.ztPayee.fieldbyname('PAYEEID').AsInteger;
        if dmData.ztPayee.fieldbyname('SUBCATEGID').AsInteger >= 0  then
          SubCatID := dmData.ztPayee.fieldbyname('SUBCATEGID').AsInteger;
        if dmData.ztCategory.fieldbyname('CATEGID').AsInteger >= 0 then
          CatID := dmData.ztCategory.fieldbyname('CATEGID').AsInteger;
      end else
      begin
        dmData.ztPayee.Insert;
        dmData.ztPayee.FieldByName('PAYEENAME').AsString := PayeeStr;
        dmData.ztPayee.Post;
        PayeeID := dmData.ztPayee.fieldbyname('PAYEEID').AsInteger;
      end;
      dmData.ztPayee.Close;
    end;

    dmData.ztCheckingAccount.Open;
    dmData.ztCheckingAccount.Insert;
    dmData.ztCheckingAccount.FieldByName('ACCOUNTID').AsInteger := AccID;         //Required
//      ztCheckingAccount.FieldByName('TOACCOUNTID').AsInteger := ToAccID;
    dmData.ztCheckingAccount.FieldByName('PAYEEID').AsInteger := PayeeID;         //Required
    TransCodeStr := StripApostropheFromString(TransCodeStr);
    dmData.ztCheckingAccount.FieldByName('TRANSCODE').AsString := TransCodeStr;               //Required
    dmData.ztCheckingAccount.FieldByName('TRANSAMOUNT').AsCurrency:= abs(Amount);            //Required
    dmData.ztCheckingAccount.FieldByName('WITHDRAWAL').AsCurrency:= abs(Withdrawal);            //Required
    dmData.ztCheckingAccount.FieldByName('DEPOSIT').AsCurrency:= abs(Deposit);            //Required
//    frMain.ztCheckingAccount.FieldByName('TRANSAMOUNT').AsCurrency:= abs(Amount);            //Required
//      ztCheckingAccount.FieldByName('STATUS').AsString := ;
    dmData.ztCheckingAccount.FieldByName('TRANSACTIONNUMBER').AsString := TransNumber;
    dmData.ztCheckingAccount.FieldByName('NOTES').AsString := NotesStr;
    dmData.ztCheckingAccount.FieldByName('CATEGID').AsInteger := CatID;
    dmData.ztCheckingAccount.FieldByName('SUBCATEGID').AsInteger := SubCatID;
    dmData.ztCheckingAccount.FieldByName('TRANSDATE').AsString := TransDateStr;
//      ztCheckingAccount.FieldByName('FOLLOWUPID').AsInteger := ;
//      ztCheckingAccount.FieldByName('TOTRANSAMOUNT').AsCurrency := ;
    dmData.ztCheckingAccount.Post;
    ChkAccID := dmData.ztCheckingAccount.fieldbyname('TRANSID').AsInteger;
    dmData.ztCheckingAccount.Close;

    pbImport.StepIt;
    application.processmessages;
  end;
{  ztPayee.Close;
  ztCategory.Close;
  ztCheckingAccount.Close;
  ztSubCategory.Close;}
//  CloseDatabaseTables;
end;

procedure TfrImport.bSaveAsClick(Sender: TObject);
begin
  if SaveDialogCSVOrder.Execute then
  begin
    lbChosenCSVFields.Items.SaveToFile(SaveDialogCSVOrder.FileName);
  end;
end;

procedure TfrImport.bOpenClick(Sender: TObject);
var i, j: integer;
  tmpstr : string;
begin
  if OpenDialogCSVOrder.Execute then
    LoadCSVOrder(OpenDialogCSVOrder.FileName);
end;

procedure TfrImport.bAddClick(Sender: TObject);
begin
  if lbCSVFields.ItemIndex = -1 then exit;
  lbChosenCSVFields.Items.Add(lbCSVFields.Items.Strings[lbCSVFields.ItemIndex]);
  if lbCSVFields.Items.IndexOf('Ignore') <> lbCSVFields.ItemIndex then
    lbCSVFields.Items.Delete(lbCSVFields.ItemIndex);
end;

procedure TfrImport.bRemoveClick(Sender: TObject);
begin
  if lbChosenCSVFields.ItemIndex = -1 then exit;
  if lbChosenCSVFields.Items.Count = 0 then exit;

  if lbChosenCSVFields.Items.Strings[lbChosenCSVFields.ItemIndex] <> 'Ignore' then
    lbCSVFields.Items.Add(lbChosenCSVFields.Items.Strings[lbChosenCSVFields.ItemIndex]);

  lbChosenCSVFields.Items.Delete(lbChosenCSVFields.ItemIndex);
end;

procedure TfrImport.bUpClick(Sender: TObject);
var CurrIndex: Integer;
begin
  with lbChosenCSVFields do
  if ItemIndex > 0 then
  begin
    CurrIndex := ItemIndex;
    Items.Move(ItemIndex, (CurrIndex - 1));
    ItemIndex := CurrIndex - 1;
  end;
end;

procedure TfrImport.Button1Click(Sender: TObject);
begin
end;

procedure TfrImport.fneImportFileChange(Sender: TObject);
begin
  LoadImportFile(fneImportFile.FileName);
end;

procedure TfrImport.lbChosenCSVFieldsDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  DropPosition, StartPosition: Integer;
  DropPoint: TPoint;
begin
  DropPoint.X := X;
  DropPoint.Y := Y;
  with Source as TListBox do
  begin
    StartPosition := ItemAtPos(StartingPoint,True) ;
    DropPosition := ItemAtPos(DropPoint,True) ;
    Items.Move(StartPosition, DropPosition) ;
  end;
end;

procedure TfrImport.lbChosenCSVFieldsDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source = lbChosenCSVFields;
//  Accept := (Source is TListbox);
end;

procedure TfrImport.lbChosenCSVFieldsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  StartingPoint.X := X;
  StartingPoint.Y := Y;
end;

procedure TfrImport.FormCreate(Sender: TObject);
begin
  LoadSettings;
  fneImportFile.InitialDir:= ExtractFileDir(application.exename);
  OpenDatabase;
//  OpenDatabaseTables;
  lbChosenCSVFields.DragMode := dmAutomatic;
//  zcDataCon.Connected:= True;
end;

procedure TfrImport.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveSettings;
end;

end.

