{ To do list:

1. Add ability to save presets for quicker import. Similar to foobar convert setup.
2. Ask user to specify categories for new payees after scanning them before the import.
   Use a temporary table which is a copy of payees. Copy these records over at the end.
3. Check to see if records already exist in database, if they do dont import them.
   If they are similar but not exact match (costs slightly out) then ask user if they
   want to overwrite values in database with new imported value from csv.
4. After import update balances if bank accounts screen is visible.
}
unit uImportWizard;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, EditBtn, DbCtrls, Grids, Spin, ComCtrls, DBGrids, ZDataset,
  Variants{, IniFiles};

type

  { TfrImportWizard }

  TfrImportWizard = class(TForm)
    bAdd: TButton;
    bDelete: TButton;
    bEdit: TButton;
    bNew: TButton;
    bCancel: TButton;
    bDefault: TButton;
    bDown: TButton;
    bNext: TButton;
    bOpen: TButton;
    bPrevious: TButton;
    bRemove: TButton;
    bSaveAs: TButton;
    bUp: TButton;
    cbAccountName: TComboBox;
    cbDateFormat: TComboBox;
    cbStripApostrophe: TCheckBox;
    cbUseExistingPayees: TCheckBox;
    cbUsePayeeImport: TCheckBox;
    dbgPayeeReplace: TDBGrid;
    eUserDefined: TEdit;
    fneImportFile: TFileNameEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    gbAdvancedOptions: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    lPreview: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    lbChosenCSVFields: TListBox;
    lbCSVFields: TListBox;
    mProgress: TMemo;
    nbPages: TNotebook;
    OpenDialogCSVOrder: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    pbImport: TProgressBar;
    pgStep1: TPage;
    pgStep2: TPage;
    pgStep3: TPage;
    pgStep4: TPage;
    pBottom: TPanel;
    rgCSVDelimiter: TRadioGroup;
    SaveDialogCSVOrder: TSaveDialog;
    seIgnoreLines: TSpinEdit;
    sgImportFile: TStringGrid;
    procedure bAddClick(Sender: TObject);
    procedure bDefaultClick(Sender: TObject);
    procedure bDeleteClick(Sender: TObject);
    procedure bDownClick(Sender: TObject);
    procedure bEditClick(Sender: TObject);
    procedure bNewClick(Sender: TObject);
    procedure bNextClick(Sender: TObject);
    procedure bOpenClick(Sender: TObject);
    procedure bPreviousClick(Sender: TObject);
    procedure bRemoveClick(Sender: TObject);
    procedure bSaveAsClick(Sender: TObject);
    procedure bUpClick(Sender: TObject);
    procedure fneImportFileChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure lbChosenCSVFieldsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbChosenCSVFieldsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbChosenCSVFieldsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LoadCSVOrder(filename : string);
    procedure LoadImportFile(ImportFilename : string);
    procedure RunImport;
    procedure LoadSettings;
    procedure SaveSettings;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frImportWizard: TfrImportWizard;
  StartingPoint : TPoint;

implementation

{$R *.lfm}

uses uDataModule, uPayeeImport, uMain;

{ TfrImportWizard }

procedure TfrImportWizard.FormShow(Sender: TObject);
var i : integer;
begin
  dmData.ztAccountList.First;
  for i:=1 to dmData.ztAccountList.RecordCount do
  begin
    cbAccountName.items.add(dmData.ztAccountList.fieldbyname('ACCOUNTNAME').asstring);
    dmData.ztAccountList.Next;
  end;

  dmData.zqPayeeImport.Active:= False;
  dmData.zqPayeeImport.SQL.Clear;
  dmData.zqPayeeImport.SQL.Add(
    ' select pi.*, p.payeename '+
    ' from '+dmData.ztPayeeImport.TableName+' pi, '+dmdata.ztPayee.TableName+' p '+
    ' where pi.payeeid = p.payeeid '
    );
  dmData.zqPayeeImport.ExecSQL;
  dmData.zqPayeeImport.Active:= True;

  LoadSettings;
end;

procedure TfrImportWizard.lbChosenCSVFieldsDragDrop(Sender, Source: TObject; X,
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

procedure TfrImportWizard.lbChosenCSVFieldsDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source = lbChosenCSVFields;
end;

procedure TfrImportWizard.lbChosenCSVFieldsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  StartingPoint.X := X;
  StartingPoint.Y := Y;
end;

procedure TfrImportWizard.bPreviousClick(Sender: TObject);
begin
  if nbPages.PageIndex > 0 then
    nbPages.PageIndex := nbPages.PageIndex - 1;

  if nbPages.PageIndex = 3 then
    bNext.Caption:= 'Finish'
  else
    bNext.Caption:='Next >';

  bPrevious.enabled := (nbPages.PageIndex > 0);
end;

procedure TfrImportWizard.bNextClick(Sender: TObject);
begin
  if bNext.Caption = 'Close' then close;

  if bNext.Caption = 'Import' then
  begin
    RunImport;
    exit;
  end;

  case nbPages.PageIndex of
    0 : begin
          if fneImportFile.Text = '' then
          begin
            //MessageDlg('Please select an import file.',mtError, [mbOK], 0);
            fneImportFile.SetFocus;
            exit;
          end;
          if cbAccountName.Text = '' then
          begin
            //MessageDlg('Please select an account to import file into.',mtError, [mbOK], 0);
            cbAccountName.SetFocus;
            exit;
          end;
          if cbDateFormat.Text = '' then
          begin
            //MessageDlg('Please select a data format.',mtError, [mbOK], 0);
            cbDateFormat.SetFocus;
            exit;
          end;
          bNext.Caption:='Next >';
        end;

    1 : begin
          if sgImportFile.ColCount <> lbChosenCSVFields.Items.Count then
          begin
            MessageDlg('Column import file count does not match column setup.',mtError, [mbOK], 0);
            exit;
          end;
          bNext.Caption:='Next >';
        end;
    2 : begin

          bNext.Caption:='Import';
        end;
    3 : begin
          {          if dmData.ztAccountList.Locate('ACCOUNTNAME', eAccountName.Text, [loCaseInsensitive]) = True then
                      begin
                        pgStep1.PageIndex := 1;
                        MessageDlg('Account name: '+eAccountName.Text+' already exists.',mtError, [mbOK], 0);
                        exit;
                      end;

                    cbAccountType.SetFocus;}
//          bNext.Caption:= 'Import';
        end;
  end;

  if nbPages.PageIndex < 3 then
    nbPages.PageIndex := nbPages.PageIndex + 1;
  bPrevious.enabled := (nbPages.PageIndex > 0);

end;

procedure TfrImportWizard.bOpenClick(Sender: TObject);
begin
  if OpenDialogCSVOrder.Execute then
    LoadCSVOrder(OpenDialogCSVOrder.FileName);
end;

procedure TfrImportWizard.bRemoveClick(Sender: TObject);
begin
  if lbChosenCSVFields.ItemIndex = -1 then exit;
  if lbChosenCSVFields.Items.Count = 0 then exit;

  if lbChosenCSVFields.Items.Strings[lbChosenCSVFields.ItemIndex] <> 'Ignore' then
    lbCSVFields.Items.Add(lbChosenCSVFields.Items.Strings[lbChosenCSVFields.ItemIndex]);

  lbChosenCSVFields.Items.Delete(lbChosenCSVFields.ItemIndex);
end;

procedure TfrImportWizard.bSaveAsClick(Sender: TObject);
begin
  if SaveDialogCSVOrder.Execute then
    lbChosenCSVFields.Items.SaveToFile(SaveDialogCSVOrder.FileName);
end;

procedure TfrImportWizard.bUpClick(Sender: TObject);
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

procedure TfrImportWizard.fneImportFileChange(Sender: TObject);
begin
  LoadImportFile(fneImportFile.FileName);
end;

procedure TfrImportWizard.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  savesettings;
end;

procedure TfrImportWizard.bAddClick(Sender: TObject);
begin
  if lbCSVFields.ItemIndex = -1 then exit;
  lbChosenCSVFields.Items.Add(lbCSVFields.Items.Strings[lbCSVFields.ItemIndex]);
  if lbCSVFields.Items.IndexOf('Ignore') <> lbCSVFields.ItemIndex then
    lbCSVFields.Items.Delete(lbCSVFields.ItemIndex);
end;

procedure TfrImportWizard.bDefaultClick(Sender: TObject);
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

procedure TfrImportWizard.bDeleteClick(Sender: TObject);
begin
  if dmData.ztPayeeImport.RecordCount = 0 then exit;

  if MessageDlg('Are you sure you want to delete "'+dmData.zqPayeeImport.FieldByName('MATCHTEXT').AsString+'"?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;

  if dmData.ztPayeeImport.Locate('PAYEEIMPORTID', dmData.zqPayeeImport.FieldByName('PAYEEIMPORTID').AsString, [loCaseInsensitive]) = True then
  begin
    dmData.DeleteDBRecord(dmData.ztPayeeImport.TableName, 'PAYEEIMPORTID', dmData.zqPayeeImport.FieldByName('PAYEEIMPORTID').AsInteger);
    dmdata.RefreshDataset(dmData.ztPayeeImport);
    dmdata.RefreshDataset(dmData.zqPayeeImport);
  end;
end;

procedure TfrImportWizard.bDownClick(Sender: TObject);
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

procedure TfrImportWizard.bEditClick(Sender: TObject);
begin
  if dmData.ztPayeeImport.Locate('PAYEEIMPORTID', dmData.zqPayeeImport.FieldByName('PAYEEIMPORTID').AsString, [loCaseInsensitive]) = True then
  begin
    frPayeeImport := TfrPayeeImport.create(self);
    frPayeeImport.EditMode:= 'Edit';
    if frPayeeImport.Showmodal = mrOk then
    begin
      dmData.SaveChanges(dmData.ztPayeeImport, True);
      dmdata.RefreshDataset(dmData.zqPayeeImport);
    end else
      dmData.ztPayeeImport.Cancel;

    frPayeeImport.Free;
  end;
end;

procedure TfrImportWizard.bNewClick(Sender: TObject);
begin
  frPayeeImport := TfrPayeeImport.create(self);
  frPayeeImport.EditMode:= 'Insert';

  if frPayeeImport.Showmodal = mrOk then
  begin
    dmData.SaveChanges(dmData.ztPayeeImport, True);
    dmdata.RefreshDataset(dmData.zqPayeeImport);
  end else
    dmData.ztPayeeImport.Cancel;

  frPayeeImport.Free;
end;

procedure TfrImportWizard.LoadCSVOrder(filename : string);
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

procedure TfrImportWizard.LoadImportFile(ImportFilename : string);
begin
  sgImportFile.LoadFromCSVFile(ImportFilename, ',', False);
  lPreview.Caption:= 'Import file preview: ('+IntToStr(sgImportFile.RowCount)+' records)';
end;


procedure TfrImportWizard.RunImport;
var i,j,k, CatID, PayeeID, ChkAccID, AccID,ToAccID, SubCatID, ImportRowStart,
  ImpCat, ImpSubCat, ImpWith, ImpDep, ImpPay, ImSkipped : integer;
  Str,TransDateStr, CategoryStr,SubCatStr, PayeeStr, TransCodeStr, NotesStr,TransNumber : string;
  Balance, Amount, Withdrawal, Deposit : Currency;
  TransDate : TDateTime;
begin
  bPrevious.Enabled:= False;
  bNext.Enabled:= False;
  bCancel.Enabled:= False;
try
  mProgress.Clear;
  mProgress.Lines.Add('Import started: '+DateTimeToStr(now));

  pbImport.max := sgImportFile.RowCount;
  pbImport.step := 1;

  ImpCat := 0;
  ImpSubCat := 0;
  ImpWith := 0;
  ImpDep := 0;
  ImpPay := 0;
  ImSkipped := 0;

{  lbChosenCSVFields.Items.IndexOf('Balance');}

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

    if dmData.ztAccountList.Locate('ACCOUNTNAME', cbAccountName.Text, [loCaseInsensitive]) = True then
    begin
      AccID := dmData.ztAccountList.fieldbyname('ACCOUNTID').AsInteger;
    end else
    begin
      dmData.ztAccountList.Insert;
      dmData.ztAccountList.FieldByName('ACCOUNTNAME').AsString := cbAccountName.Text;
      dmData.ztAccountList.FieldByName('ACCOUNTTYPE').AsString := 'Checking';
      dmData.ztAccountList.FieldByName('STATUS').AsString := 'Open';
      dmData.ztAccountList.FieldByName('INITIALBAL').AsInteger := 0;
      dmData.ztAccountList.FieldByName('FAVORITEACCT').AsString := 'FALSE';
      dmData.ztAccountList.FieldByName('CURRENCYID').AsInteger := 1;
      dmData.SaveChanges(dmData.ztAccountList, False);
//      dmData.ztAccountList.Refresh;
      AccID := dmData.ztAccountList.fieldbyname('ACCOUNTID').AsInteger;
    end;

    if lbChosenCSVFields.Items.IndexOf('Date') > -1 then
    begin
      TransDateStr := sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Date'), i];

      TransDate := StrToDate(TransDateStr);
//      TransDateStr := FormatDateTime(dmData.DisplayDateFormat, TransDate);
      TransDateStr := FormatDateTime('YYYY-MM-DD', TransDate);
    end;

    if lbChosenCSVFields.Items.IndexOf('Notes') > -1 then
    begin
      if cbStripApostrophe.Checked then
        NotesStr := dmData.StripApostropheFromString(NotesStr)
      else
        NotesStr := NotesStr;
      NotesStr := sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Notes'), i];
    end;
    if lbChosenCSVFields.Items.IndexOf('Number') > -1 then
    begin
      if cbStripApostrophe.Checked then
        TransNumber := dmData.StripApostropheFromString(TransNumber)
      else
        TransNumber := TransNumber;

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
//        Deposit := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Deposit'), i]);
      end else
      begin
        TransCodeStr := 'Withdrawal';
  //      Withdrawal := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Withdrawal'), i]);
      end;
    end;

    if lbChosenCSVFields.Items.IndexOf('To/From(+/-)') > -1 then
    begin
      Amount := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('To/From(+/-)'), i]);
      if Amount >= 0 then
      begin
        TransCodeStr := 'Withdrawal';
//        Withdrawal := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Withdrawal'), i]);
      end else
      begin
        TransCodeStr := 'Deposit';
//        Deposit := StrToCurr(sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Deposit'), i]);
      end;
    end;

    //category
    if lbChosenCSVFields.Items.IndexOf('Category') > -1 then
    begin
      CategoryStr := sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Category'), i];
      if CategoryStr <> '' then
      begin
        if cbStripApostrophe.Checked then
          CategoryStr := dmData.StripApostropheFromString(CategoryStr)
        else
          CategoryStr := CategoryStr;
        if dmData.ztCategory.Locate('CATEGNAME', CategoryStr, [loCaseInsensitive]) = True then
        CatID := dmData.ztCategory.fieldbyname('CATEGID').AsInteger else
        begin
          dmData.ztCategory.Insert;
          dmData.ztCategory.FieldByName('CATEGNAME').AsString := CategoryStr;
          dmData.SaveChanges(dmData.ztCategory, False);
  //        dmData.ztCategory.Refresh;
          CatID := dmData.ztCategory.fieldbyname('CATEGID').AsInteger;
          ImpCat := ImpCat + 1;
        end;
      end;
    end;

    //subcategory
    if lbChosenCSVFields.Items.IndexOf('SubCategory') > -1 then
    begin
      SubCatStr := sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('SubCategory'), i];
      if SubCatStr <> '' then
      begin
        if cbStripApostrophe.Checked then
          SubCatStr := dmData.StripApostropheFromString(SubCatStr)
        else
          SubCatStr := SubCatStr;

        if dmData.ztSubCategory.Locate('SUBCATEGNAME', SubCatStr, [loCaseInsensitive]) = True then
        begin
          SubCatID := dmData.ztSubCategory.fieldbyname('SUBCATEGID').AsInteger;
          if dmData.ztSubCategory.fieldbyname('CATEGID').AsInteger > 0 then
            CatID := dmData.ztSubCategory.fieldbyname('CATEGID').AsInteger;
        end else
        begin
          dmData.ztSubCategory.Insert;
          dmData.ztSubCategory.FieldByName('SUBCATEGNAME').AsString := SubCatStr;
          dmData.SaveChanges(dmData.ztSubCategory, False);
  //        dmData.ztSubCategory.Refresh;
          SubCatID := dmData.ztSubCategory.fieldbyname('SUBCATEGID').AsInteger;
          ImpSubCat := ImpSubCat + 1;
        end;
      end;
    end;

    //payee
    if lbChosenCSVFields.Items.IndexOf('Payee') > -1 then
    begin
      PayeeStr := sgImportFile.Cells[lbChosenCSVFields.Items.IndexOf('Payee'), i];
      if PayeeStr <> '' then
      begin
        if cbStripApostrophe.Checked then
          PayeeStr := dmData.StripApostropheFromString(PayeeStr)
        else
          PayeeStr := PayeeStr;

{        if dmData.ztPayee.Locate('PAYEENAME', PayeeStr, [loCaseInsensitive]) = True then
        begin
          PayeeID := dmData.ztPayee.fieldbyname('PAYEEID').AsInteger;
          if dmData.ztPayee.fieldbyname('SUBCATEGID').AsInteger > 0  then
            SubCatID := dmData.ztPayee.fieldbyname('SUBCATEGID').AsInteger;
          if dmData.ztPayee.fieldbyname('CATEGID').AsInteger > 0 then
            CatID := dmData.ztPayee.fieldbyname('CATEGID').AsInteger;
        end else
        begin
          dmData.ztPayee.Insert;
          dmData.ztPayee.FieldByName('PAYEENAME').AsString := PayeeStr;
          dmData.ztPayee.fieldbyname('CATEGID').AsInteger := -1;
          dmData.ztPayee.fieldbyname('SUBCATEGID').AsInteger := -1;
          dmData.ztPayee.Post;
  //        dmData.ztPayee.Refresh;
          PayeeID := dmData.ztPayee.fieldbyname('PAYEEID').AsInteger;
          ImpPay := ImpPay + 1;
        end;}

        if dmData.ztPayee.Locate('PAYEENAME', PayeeStr, [loCaseInsensitive]) = True then
        begin
          PayeeID := dmData.ztPayee.fieldbyname('PAYEEID').AsInteger;
          if dmData.ztPayee.fieldbyname('SUBCATEGID').AsInteger > 0  then
            SubCatID := dmData.ztPayee.fieldbyname('SUBCATEGID').AsInteger;
          if dmData.ztPayee.fieldbyname('CATEGID').AsInteger > 0 then
            CatID := dmData.ztPayee.fieldbyname('CATEGID').AsInteger;
        end else
        begin
          PayeeID := 0;

          if cbUseExistingPayees.Checked = True then
          begin
            //find partial matches already existing in the payees table
            if PayeeID = 0 then
            begin
              dmdata.ztPayee.First;
              for k:= 1 to dmdata.ztPayee.RecordCount do
              begin
                if pos(dmData.ztPayee.fieldbyname('PAYEENAME').AsString, PayeeStr) > 0 then
                begin
                  PayeeID := dmData.ztPayee.fieldbyname('PAYEEID').AsInteger;
                  if dmData.ztPayee.fieldbyname('SUBCATEGID').AsInteger > 0  then
                    SubCatID := dmData.ztPayee.fieldbyname('SUBCATEGID').AsInteger;
                  if dmData.ztPayee.fieldbyname('CATEGID').AsInteger > 0 then
                    CatID := dmData.ztPayee.fieldbyname('CATEGID').AsInteger;
                  break;
                end;
                dmdata.ztPayee.Next;
              end;
            end;
          end;

          //find partial matches against the payee match text table
          if cbUsePayeeImport.Checked = True then
          begin
            dmdata.ztPayeeImport.First;
            for k:= 1 to dmdata.ztPayeeImport.RecordCount do
            begin
              if pos(dmData.ztPayeeImport.fieldbyname('MATCHTEXT').AsString, PayeeStr) > 0 then
              begin
                PayeeID := dmData.ztPayeeImport.fieldbyname('PAYEEID').AsInteger;

                //grab category and subcategory links
                if dmData.ztPayee.Locate('PAYEEID', PayeeID, [loCaseInsensitive]) = True then
                begin
                  if dmData.ztPayee.fieldbyname('SUBCATEGID').AsInteger > 0  then
                    SubCatID := dmData.ztPayee.fieldbyname('SUBCATEGID').AsInteger;
                  if dmData.ztPayee.fieldbyname('CATEGID').AsInteger > 0 then
                    CatID := dmData.ztPayee.fieldbyname('CATEGID').AsInteger;
                end;
                break;
              end;
              dmdata.ztPayeeImport.Next;
            end;
          end;

          if PayeeID = 0 then
          begin
            dmData.ztPayee.Insert;
            dmData.ztPayee.FieldByName('PAYEENAME').AsString := PayeeStr;
            dmData.ztPayee.fieldbyname('CATEGID').AsInteger := -1;
            dmData.ztPayee.fieldbyname('SUBCATEGID').AsInteger := -1;
            dmData.SaveChanges(dmData.ztPayee, False);
    //        dmData.ztPayee.Refresh;
            PayeeID := dmData.ztPayee.fieldbyname('PAYEEID').AsInteger;
            ImpPay := ImpPay + 1;
          end;

        end;
      end;
    end;

    //check to see if an indentical record already exists before importing a duplicate
    if dmData.ztCheckingAccount.Locate('ACCOUNTID;PAYEEID;TRANSCODE;TRANSAMOUNT;TRANSDATE', VarArrayOf([AccID,PayeeID,TransCodeStr,abs(Amount),TransDateStr]) , []) = False then
    begin
      dmData.ztCheckingAccount.Insert;
      dmData.ztCheckingAccount.FieldByName('ACCOUNTID').AsInteger := AccID;         //Required
  //      ztCheckingAccount.FieldByName('TOACCOUNTID').AsInteger := ToAccID;
      dmData.ztCheckingAccount.FieldByName('PAYEEID').AsInteger := PayeeID;         //Required
      if cbStripApostrophe.Checked then
        TransCodeStr := dmData.StripApostropheFromString(TransCodeStr)
      else
        TransCodeStr := TransCodeStr;
      dmData.ztCheckingAccount.FieldByName('TRANSCODE').AsString := TransCodeStr;               //Required
      dmData.ztCheckingAccount.FieldByName('TRANSAMOUNT').AsCurrency:= abs(Amount);            //Required
  //      ztCheckingAccount.FieldByName('STATUS').AsString := ;
      dmData.ztCheckingAccount.FieldByName('TRANSACTIONNUMBER').AsString := TransNumber;
      dmData.ztCheckingAccount.FieldByName('NOTES').AsString := NotesStr;
      if CatID = 0 then CatID := -1;
      dmData.ztCheckingAccount.FieldByName('CATEGID').AsInteger := CatID;
      if SubCatID = 0 then SubCatID := -1;
      dmData.ztCheckingAccount.FieldByName('SUBCATEGID').AsInteger := SubCatID;
      dmData.ztCheckingAccount.FieldByName('TRANSDATE').AsString := TransDateStr;
  //      ztCheckingAccount.FieldByName('FOLLOWUPID').AsInteger := ;
  //      ztCheckingAccount.FieldByName('TOTRANSAMOUNT').AsCurrency := ;
      dmData.SaveChanges(dmData.ztCheckingAccount, False);
  //    dmData.ztCheckingAccount.Refresh;
      ChkAccID := dmData.ztCheckingAccount.fieldbyname('TRANSID').AsInteger;

      if TransCodeStr = 'Withdrawal' then ImpWith := ImpWith + 1 else
      if TransCodeStr = 'Deposit' then ImpDep := ImpDep + 1;

    end else
      ImSkipped := ImSkipped + 1;


    pbImport.StepIt;
    application.processmessages;
  end;

  mProgress.Lines.Add('');

  if ImpWith >  0 then
    mProgress.Lines.Add(IntToStr(ImpWith)+ ' Withdrawal lines imported.');
  if ImpDep >  0 then
    mProgress.Lines.Add(IntToStr(ImpDep)+ ' Deposit lines imported.');
  if ImpCat >  0 then
    mProgress.Lines.Add(IntToStr(ImpCat)+ ' new Categories created.');
  if ImpSubCat >  0 then
    mProgress.Lines.Add(IntToStr(ImpSubCat)+ ' new Subcategories created.');
  if ImpPay >  0 then
    mProgress.Lines.Add(IntToStr(ImpPay)+ ' new Payees created.');
  if ImSkipped > 0 then
    mProgress.Lines.Add(IntToStr(ImSkipped)+ ' identical transactions skipped.');

  mProgress.Lines.Add('');
  mProgress.Lines.Add('Import completed: '+DateTimeToStr(now));

  finally
    bNext.Enabled:= True;
    bNext.Caption:= 'Close';
    bPrevious.enabled := False;
  end;
  dmData.zqBankAccounts.Active:= True;

  case frMain.pcNavigation.PageIndex of
    pgBankAccs : frMain.DisplayBankAccountsGrid; //dmdata.RefreshDataset(dmData.zqBankAccounts);
  end;
end;

procedure TfrImportWizard.LoadSettings;
var ImportFileStr : string;
begin
  if FileExists(ExtractFilePath(application.exename)+'csvimp.mcv') then
    LoadCSVOrder(ExtractFilePath(application.exename)+'csvimp.mcv');
  ImportFileStr := dmData.GetInfoSettings('IMPORT_FILENAME', '');
  if FileExists(ImportFileStr) then fneImportFile.Text := ImportFileStr;
  OpenDialogCSVOrder.InitialDir := dmData.GetInfoSettings('IMPORT_OPENCSVDIR', ExtractFilePath(application.exename));
  SaveDialogCSVOrder.InitialDir := dmData.GetInfoSettings('IMPORT_SAVECSVDIR', ExtractFilePath(application.exename));
  seIgnoreLines.Value := dmData.GetInfoSettingsInt('IMPORT_IGNORELINES', 0);
  cbStripApostrophe.Checked := dmData.GetInfoSettingsBool('IMPORT_STRIPAPSTROPHE', True);
  cbDateFormat.ItemIndex := dmData.GetInfoSettingsInt('IMPORT_DATEFORMAT', 0);
  cbAccountName.ItemIndex := dmData.GetInfoSettingsInt('IMPORT_ACCOUNTNAME', 0);
  cbUseExistingPayees.Checked := dmData.GetInfoSettingsBool('IMPORT_EXISTINGPAYEE', True);
  cbUsePayeeImport.Checked := dmData.GetInfoSettingsBool('IMPORT_PAYEEIMPORT', True);
end;

procedure TfrImportWizard.SaveSettings;
begin
  dmData.SetInfoSettings('IMPORT_FILENAME', fneImportFile.Text);
  dmData.SetInfoSettings('IMPORT_OPENCSVDIR', OpenDialogCSVOrder.InitialDir);
  dmData.SetInfoSettings('IMPORT_SAVECSVDIR', SaveDialogCSVOrder.InitialDir);
  dmData.SetInfoSettingsBool('IMPORT_STRIPAPSTROPHE', cbStripApostrophe.Checked);
  dmData.SetInfoSettingsInt('IMPORT_IGNORELINES', seIgnoreLines.Value);
  dmData.SetInfoSettingsInt('IMPORT_DATEFORMAT', cbDateFormat.ItemIndex);
  dmData.SetInfoSettingsInt('IMPORT_ACCOUNTNAME', cbAccountName.ItemIndex);
  dmData.SetInfoSettingsBool('IMPORT_EXISTINGPAYEE', cbUseExistingPayees.Checked);
  dmData.SetInfoSettingsBool('IMPORT_PAYEEIMPORT', cbUsePayeeImport.Checked);
  lbChosenCSVFields.Items.SaveToFile(ExtractFilePath(application.exename)+'csvimp.mcv');
end;

end.

