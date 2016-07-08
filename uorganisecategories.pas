{ To do list:

1. Add drag and drop support?
2. Changing colour on parent needs to filter to child categories without having to close form (save)?
3. Fix problem when realocating categories from this form which uses this form again.

}
unit uOrganiseCategories;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, DbCtrls, customdrawncontrols, ZDataset, Variants{, IniFiles};

type

  { TfrOrganiseCategories }
  PCategoryRec = ^TCategoryRec;
  TCategoryRec = record
    CatID: integer;
    SubCatID: integer;
    CatName: string;
    SubCatName: string;
    Colour: string;
    IncludeBudget : Boolean;
  end;

  TfrOrganiseCategories = class(TForm)
    bAdd: TButton;
    bRename: TButton;
    bDelete: TButton;
    bSelect: TButton;
    bClose: TButton;
    bRelocateCat: TButton;
    cbExpand: TCheckBox;
    cbBudgetShow: TCheckBox;
    cdbCategory: TCDButton;
    ColorDialog1: TColorDialog;
    eCatedid: TEdit;
    eSubcategid: TEdit;
    eCategname: TEdit;
    eSubcategname: TEdit;
    dsCategories: TDatasource;
    eCategoryName: TEdit;
    Label8: TLabel;
    panHeader: TPanel;
    panFooter: TPanel;
    tvCategories: TTreeView;
    zqCategories: TZQuery;
    zqCategoriesCATEGID: TLargeintField;
    zqCategoriesCATEGNAME: TMemoField;
    zqCategoriesCOLOUR: TMemoField;
    zqCategoriesC_INCLUDEBUDGET: TMemoField;
    zqCategoriesSUBCATEGID: TLargeintField;
    zqCategoriesSUBCATEGNAME: TMemoField;
    zqCategoriesS_INCLUDEBUDGET: TMemoField;
    procedure bAddClick(Sender: TObject);
    procedure bCloseClick(Sender: TObject);
    procedure bDeleteClick(Sender: TObject);
    procedure bRelocateCatClick(Sender: TObject);
    procedure bRenameClick(Sender: TObject);
    procedure cbBudgetShowChange(Sender: TObject);
    procedure cbBudgetShowClick(Sender: TObject);
    procedure cbExpandChange(Sender: TObject);
    procedure cdbCategoryClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tvCategoriesChange(Sender: TObject; Node: TTreeNode);
    function SelectCategory(var CatId, SubCatID : integer) : boolean;
    procedure zqCategoriesAfterOpen(DataSet: TDataSet);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frOrganiseCategories: TfrOrganiseCategories;

implementation

{$R *.lfm}

uses uMain, uDataModule, uSQLLog, uRelocateCategory;

{ TfrOrganiseCategories }

procedure TfrOrganiseCategories.bCloseClick(Sender: TObject);
begin
//  Close;
end;

procedure TfrOrganiseCategories.bAddClick(Sender: TObject);
var CatName : String;
    CatID : integer;
    newNode, ParentNode : TTreeNode;
    MyCategoryRec: PCategoryRec;
begin
  if eCategoryName.Text = '' then exit;
  if PCategoryRec(tvCategories.Selected.Data) = nil then exit;

  if (dmData.ztSubCategory.Locate('SUBCATEGNAME', eCategoryName.Text, [loCaseInsensitive]) = True) or
    (dmData.ztCategory.Locate('CATEGNAME', eCategoryName.Text, [loCaseInsensitive]) = True) then
    begin
      MessageDlg('"'+eCategoryName.Text+'" already exists. Please choose a unique name.', mtError, [mbOk], 0);
      eCategoryName.SetFocus;
      exit;
    end;

  if PCategoryRec(tvCategories.Selected.Data)^.CatID = -1 then
  begin
    dmData.ztCategory.Insert;
  //  frMain.ztCategory.FieldByName('CATEGID').AsInteger := PCategoryRec(tvCategories.Selected.Data)^.CatID;         //Required
    dmData.ztCategory.FieldByName('CATEGNAME').AsString := eCategoryName.Text;               //Required
    dmData.ztCategory.FieldByName('COLOUR').AsString := ColorToString(cdbCategory.Color);
    dmData.ztCategory.FieldByName('INCLUDEBUDGET').AsString := dmData.BoolToStr(cbBudgetShow.Checked);
    dmData.SaveChanges(dmData.ztCategory, False);

    New(MyCategoryRec);
    MyCategoryRec^.CatID :=  dmData.ztCategory.FieldByName('CATEGID').AsInteger; //zqCategories.FieldByName('CATEGID').AsInteger;
    MyCategoryRec^.SubCatID :=  -1;
    MyCategoryRec^.CatName:= eCategoryName.Text; //zqCategories.FieldByName('CATEGNAME').AsString;
    MyCategoryRec^.SubCatName := '';
    MyCategoryRec^.Colour := ColorToString(cdbCategory.Color);
    MyCategoryRec^.IncludeBudget:= cbBudgetShow.Checked;

    ParentNode := dmData.GetNodeByText(tvCategories, 'Categories', false);
    newNode := tvCategories.Items.addChildObject(ParentNode, eCategoryName.Text, MyCategoryRec);
    newNode.Selected:= True;
  end else
  begin
    dmData.ztSubCategory.Insert;
    dmData.ztSubCategory.FieldByName('CATEGID').AsInteger := PCategoryRec(tvCategories.Selected.Data)^.CatID;         //Required
    dmData.ztSubCategory.FieldByName('SUBCATEGNAME').AsString := eCategoryName.Text;               //Required
    dmData.ztSubCategory.FieldByName('INCLUDEBUDGET').AsString := dmData.BoolToStr(cbBudgetShow.Checked);
    dmData.SaveChanges(dmData.ztSubCategory, False);
    CatName := PCategoryRec(tvCategories.Selected.Data)^.CatName;
    CatID := PCategoryRec(tvCategories.Selected.Data)^.CatID;

    New(MyCategoryRec);
    MyCategoryRec^.CatID := CatID; //frMain.ztSubCategory.FieldByName('CATEGID').AsInteger;
    MyCategoryRec^.SubCatID :=  dmData.ztSubCategory.FieldByName('SUBCATEGID').AsInteger;
    MyCategoryRec^.CatName:= CatName; //frMain.ztSubCategory.FieldByName('CATEGNAME').AsString;
    MyCategoryRec^.SubCatName := eCategoryName.Text;
    MyCategoryRec^.Colour := ColorToString(cdbCategory.Color);
    MyCategoryRec^.IncludeBudget:= cbBudgetShow.Checked;

    ParentNode := dmData.GetNodeByText(tvCategories, CatName, false);
    newNode := tvCategories.Items.addChildObject(ParentNode, eCategoryName.Text, MyCategoryRec);
    newNode.Selected:= True;
  end;
  tvCategories.SortType:= stData;
  tvCategories.AlphaSort;
end;

procedure TfrOrganiseCategories.bDeleteClick(Sender: TObject);
var  MyCategoryRec: PCategoryRec;
     ParentNode : TTreenode;
begin
  if PCategoryRec(tvCategories.Selected.Data) = nil then exit;

  if (PCategoryRec(tvCategories.Selected.Data)^.CatID > 0) and (PCategoryRec(tvCategories.Selected.Data)^.SubCatID = -1) then
  begin
    if MessageDlg('Are you sure you want to delete "'+PCategoryRec(tvCategories.Selected.Data)^.CatName+ '" category and any relating sub categories?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;
    dmData.DeleteDBRecord(dmData.ztSubCategory.TableName, 'categid', PCategoryRec(tvCategories.Selected.Data)^.CatID);

    if (frMain.miSQLLog.Checked) and (frSQLLog <> nil) then
    begin
      frSQLLog.mLog.Lines.AddStrings(dmData.ZQuery1.SQL);
      frSQLLog.mLog.Lines.Add('');
    end;
    dmData.DeleteDBRecord(dmData.ztCategory.TableName, 'categid', PCategoryRec(tvCategories.Selected.Data)^.CatID);

    if (frMain.miSQLLog.Checked) and (frSQLLog <> nil) then
    begin
      frSQLLog.mLog.Lines.AddStrings(dmData.ZQuery1.SQL);
      frSQLLog.mLog.Lines.Add('');
    end;

  end else
  if PCategoryRec(tvCategories.Selected.Data)^.SubCatID > 0 then
  begin
    if MessageDlg('Are you sure you want to delete "'+PCategoryRec(tvCategories.Selected.Data)^.SubCatName+ '" sub category?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;
    dmData.DeleteDBRecord(dmData.ztSubCategory.TableName, 'subcategid', PCategoryRec(tvCategories.Selected.Data)^.SubCatID);

    if (frMain.miSQLLog.Checked) and (frSQLLog <> nil) then
    begin
      frSQLLog.mLog.Lines.AddStrings(dmData.ZQuery1.SQL);
      frSQLLog.mLog.Lines.Add('');
    end;
  end;

  dmdata.RefreshDataset(dmData.ztCategory);
  dmdata.RefreshDataset(dmData.ztSubCategory);
  MyCategoryRec := PCategoryRec(tvCategories.Selected.Data);
  tvCategories.Items.Delete(tvCategories.Selected);
  Dispose(MyCategoryRec);

  ParentNode := dmData.GetNodeByText(tvCategories, 'Categories', false);
  if ParentNode = nil then
    ShowMessage('Not found!')
  else
    ParentNode.Selected := True;

end;

procedure TfrOrganiseCategories.bRelocateCatClick(Sender: TObject);
begin
  frRelocateCategory := TfrRelocateCategory.create(self);
  frRelocateCategory.Showmodal;
  frRelocateCategory.Free;
end;

procedure TfrOrganiseCategories.bRenameClick(Sender: TObject);
var  MyCategoryRec: PCategoryRec;
    Node : TTreeNode;
begin
  if PCategoryRec(tvCategories.Selected.Data) = nil then exit;
  MyCategoryRec := PCategoryRec(tvCategories.Selected.Data);


//  dmData.ztCategory.Open;
  if (dmData.ztCategory.Locate('CATEGID', PCategoryRec(tvCategories.Selected.Data)^.CatID, [loCaseInsensitive]) = True)
  and (PCategoryRec(tvCategories.Selected.Data)^.SubCatID = -1) then
  begin
    dmData.ztCategory.Edit;
//  frMain.ztCategory.FieldByName('CATEGID').AsInteger := PCategoryRec(tvCategories.Selected.Data)^.CatID;         //Required
    dmData.ztCategory.FieldByName('CATEGNAME').AsString := eCategoryName.Text;               //Required
//    dmData.ztCategory.FieldByName('COLOUR').AsString := ColorToString(cdbCategory.Color);
    dmData.SaveChanges(dmData.ztCategory, true);
    MyCategoryRec^.CatName := eCategoryName.Text;
    Node := frOrganiseCategories.tvCategories.Selected;
    Node.Text:= eCategoryName.Text;
  end;
//  dmData.ztCategory.Close;

//  dmData.ztSubCategory.Open;
  if dmData.ztSubCategory.Locate('SUBCATEGID', PCategoryRec(tvCategories.Selected.Data)^.SubCatID, [loCaseInsensitive]) = True then
  begin
    dmData.ztSubCategory.Edit;
//  frMain.ztSubCategory.FieldByName('CATEGID').AsInteger := PCategoryRec(tvCategories.Selected.Data)^.CatID;         //Required
    dmData.ztSubCategory.FieldByName('SUBCATEGNAME').AsString := eCategoryName.Text;               //Required
    dmData.SaveChanges(dmData.ztSubCategory, true);
    MyCategoryRec^.SubCatName := eCategoryName.Text;
    Node := frOrganiseCategories.tvCategories.Selected;
    Node.Text:= eCategoryName.Text;
  end;
//  frMain.ztSubCategory.Close;
  tvCategories.SortType:= stData;
  tvCategories.AlphaSort;
end;

procedure TfrOrganiseCategories.cbBudgetShowChange(Sender: TObject);
var  MyCategoryRec: PCategoryRec;
    Node : TTreeNode;
begin
  if PCategoryRec(tvCategories.Selected.Data) = nil then exit;
  if (PCategoryRec(tvCategories.Selected.Data)^.CatID > 0) then
  begin
    MyCategoryRec := PCategoryRec(tvCategories.Selected.Data);
    MyCategoryRec^.IncludeBudget := cbBudgetShow.Checked;

    if (PCategoryRec(tvCategories.Selected.Data)^.SubCatID > 0) then
    begin
      if dmData.ztSubCategory.Locate('SUBCATEGID', PCategoryRec(tvCategories.Selected.Data)^.SubCatID, [loCaseInsensitive]) = True then
      begin
        dmData.ztSubCategory.Edit;
        dmData.ztSubCategory.FieldByName('INCLUDEBUDGET').AsString := dmData.BoolToStr(cbBudgetShow.Checked);
        dmData.SaveChanges(dmData.ztSubCategory, false);
      end;
    end else
    begin
      if dmData.ztCategory.Locate('CATEGID', PCategoryRec(tvCategories.Selected.Data)^.CatID, [loCaseInsensitive]) = True then
      begin
        dmData.ztCategory.Edit;
        dmData.ztCategory.FieldByName('INCLUDEBUDGET').AsString := dmData.BoolToStr(cbBudgetShow.Checked);
        dmData.SaveChanges(dmData.ztCategory, false);
      end;
    end;
  end;
end;

procedure TfrOrganiseCategories.cbBudgetShowClick(Sender: TObject);
{var  MyCategoryRec: PCategoryRec;
    Node : TTreeNode;}
begin
{  if PCategoryRec(tvCategories.Selected.Data) = nil then exit;
  if (PCategoryRec(tvCategories.Selected.Data)^.CatID > 0) then
  begin
    MyCategoryRec := PCategoryRec(tvCategories.Selected.Data);
    MyCategoryRec^.IncludeBudget := cbBudgetShow.Checked;

    if (PCategoryRec(tvCategories.Selected.Data)^.SubCatID > 0) then
    begin
      if dmData.ztSubCategory.Locate('SUBCATEGID', PCategoryRec(tvCategories.Selected.Data)^.SubCatID, [loCaseInsensitive]) = True then
      begin
        dmData.ztSubCategory.Edit;
        dmData.ztSubCategory.FieldByName('INCLUDEBUDGET').AsString := dmData.BoolToStr(cbBudgetShow.Checked);
        dmData.ztSubCategory.Post;
      end;
    end else
    begin
      if dmData.ztCategory.Locate('CATEGID', PCategoryRec(tvCategories.Selected.Data)^.CatID, [loCaseInsensitive]) = True then
      begin
        dmData.ztCategory.Edit;
        dmData.ztCategory.FieldByName('INCLUDEBUDGET').AsString := dmData.BoolToStr(cbBudgetShow.Checked);
        dmData.ztCategory.Post;
      end;
    end;
  end;}
end;

procedure TfrOrganiseCategories.cbExpandChange(Sender: TObject);
var Node : TTreeNode;
begin
  if cbExpand.Checked then
    tvCategories.FullExpand
  else
    begin
      tvCategories.FullCollapse;
      Node := dmData.GetNodeByText(tvCategories, 'Categories', false);
      Node.Selected := True;
      Node.Expanded:= True;
    end;
end;

procedure TfrOrganiseCategories.cdbCategoryClick(Sender: TObject);
var  MyCategoryRec: PCategoryRec;
begin
  ColorDialog1.Color := cdbCategory.Color;
  if ColorDialog1.Execute then
    cdbCategory.Color:= ColorDialog1.Color;

  if PCategoryRec(tvCategories.Selected.Data) = nil then exit;
  if (PCategoryRec(tvCategories.Selected.Data)^.CatID > 0) then
  begin
    MyCategoryRec := PCategoryRec(tvCategories.Selected.Data);
    MyCategoryRec^.Colour := ColorToString(cdbCategory.Color);

    if dmData.ztCategory.Locate('CATEGID', PCategoryRec(tvCategories.Selected.Data)^.CatID, [loCaseInsensitive]) = True then
    begin
      dmData.ztCategory.Edit;
      dmData.ztCategory.FieldByName('COLOUR').AsString := ColorToString(cdbCategory.Color);
      dmData.SaveChanges(dmData.ztCategory, false);
    end;
  end;
//  zqCategories.Refresh;
end;

procedure TfrOrganiseCategories.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  dmData.SetInfoSettingsBool('EXPAND_CATEGORIES', cbExpand.Checked);
end;

procedure TfrOrganiseCategories.FormCreate(Sender: TObject);
var i, TopIndex : integer;
  MainParentNode, ParentNode, newNode : TTreeNode;
  MyCategoryRec: PCategoryRec;
begin
  eCatedID.Visible:= dmData.DebugMode;
  eSubCategID.Visible:= dmData.DebugMode;
  eCategname.Visible:= dmData.DebugMode;
  eSubcategname.Visible:= dmData.DebugMode;

  zqCategories.Active:= False;
  zqCategories.SQL.Clear;
  zqCategories.SQL.Add(
{   ' select c.categid, categname, c.colour, subcategid, subcategname, '+
   ' case sc.categid '+
   ' when sc.categid = c.categid then ifnull(sc.includebudget, ''0'') '+
   ' else ifnull(c.includebudget, ''0'') end as INCLUDEBUDGET '+
   ' from '+dmData.ztCategory.TableName+' c '+
   ' left outer join '+dmData.ztSubCategory.TableName+' sc on c.categid = sc.categid '+
   ' order by categname, subcategname '}
  ' select c.categid, categname, c.colour, subcategid, subcategname, '+
  ' c.includebudget c_includebudget, sc.includebudget s_includebudget'+
  ' from '+dmData.ztCategory.TableName+' c '+
  ' left outer join '+dmData.ztSubCategory.TableName+' sc on c.categid = sc.categid '+
  ' order by categname, subcategname '
  );
  zqCategories.ExecSQL;
  zqCategories.Active:= True;
  zqCategories.First;

  New(MyCategoryRec);
  MyCategoryRec^.CatID :=  -1;
  MyCategoryRec^.SubCatID :=  -1;
  MyCategoryRec^.CatName:= 'Categories';
  MyCategoryRec^.SubCatName := '';
  MyCategoryRec^.Colour := '';
  MyCategoryRec^.IncludeBudget:= false;

  MainParentNode := tvCategories.Items.AddObject(nil, 'Categories', MyCategoryRec);
  for i:= 1 to zqCategories.RecordCount do
  begin
    ParentNode := dmData.GetNodeByText(tvCategories, zqCategories.FieldByName('CATEGNAME').AsString, false);
    if ParentNode = nil then
    begin
      New(MyCategoryRec);
      MyCategoryRec^.CatID := zqCategories.FieldByName('CATEGID').AsInteger;
      MyCategoryRec^.SubCatID :=  -1;
      MyCategoryRec^.CatName:= zqCategories.FieldByName('CATEGNAME').AsString;
      MyCategoryRec^.SubCatName := '';
      MyCategoryRec^.Colour:= zqCategories.FieldByName('COLOUR').AsString;
      MyCategoryRec^.IncludeBudget:= dmData.StrToBool(zqCategories.FieldByName('C_INCLUDEBUDGET').AsString);

      //create parent
      ParentNode := tvCategories.Items.addChildObject(MainParentNode, zqCategories.FieldByName('CATEGNAME').AsString, MyCategoryRec);
      ParentNode.Selected := True;
      ParentNode.Expanded:= False;

      if zqCategories.FieldByName('SUBCATEGNAME').AsString <> '' then
      begin
        New(MyCategoryRec);
        MyCategoryRec^.CatID :=  zqCategories.FieldByName('CATEGID').AsInteger;
        MyCategoryRec^.SubCatID :=  zqCategories.FieldByName('SUBCATEGID').AsInteger;
        MyCategoryRec^.CatName:= zqCategories.FieldByName('CATEGNAME').AsString;
        MyCategoryRec^.SubCatName:= zqCategories.FieldByName('SUBCATEGNAME').AsString;
        MyCategoryRec^.Colour:= zqCategories.FieldByName('COLOUR').AsString;
        MyCategoryRec^.IncludeBudget:= dmData.StrToBool(zqCategories.FieldByName('S_INCLUDEBUDGET').AsString);

        newNode := tvCategories.Items.addChildObject(ParentNode, zqCategories.FieldByName('SUBCATEGNAME').AsString, MyCategoryRec);
        newNode.Expanded:= False;
      end;
    end
    else begin
      ParentNode.Selected := True;
      if zqCategories.FieldByName('SUBCATEGNAME').AsString <> '' then
      begin
        ParentNode := dmData.GetNodeByText(tvCategories, zqCategories.FieldByName('CATEGNAME').AsString, false);


        New(MyCategoryRec);
        MyCategoryRec^.CatID :=  zqCategories.FieldByName('CATEGID').AsInteger;
        MyCategoryRec^.SubCatID :=  zqCategories.FieldByName('SUBCATEGID').AsInteger;
        MyCategoryRec^.CatName:= zqCategories.FieldByName('CATEGNAME').AsString;
        MyCategoryRec^.SubCatName:= zqCategories.FieldByName('SUBCATEGNAME').AsString;
        MyCategoryRec^.Colour:= zqCategories.FieldByName('COLOUR').AsString;
        MyCategoryRec^.IncludeBudget:= dmData.StrToBool(zqCategories.FieldByName('S_INCLUDEBUDGET').AsString);

        newNode := tvCategories.Items.addChildObject(ParentNode, zqCategories.FieldByName('SUBCATEGNAME').AsString, MyCategoryRec);
        newNode.Expanded:= False;
      end;
    end;
    zqCategories.Next;
  end;
//  ParentNode.Index:= 0;
  MainParentNode.Selected := True;

  tvCategories.Items.BeginUpdate;
  tvCategories.SortType:= stData;
  tvCategories.AlphaSort;
  tvCategories.Items.EndUpdate;
end;

procedure TfrOrganiseCategories.FormShow(Sender: TObject);
begin
  cbExpand.Checked := dmData.GetInfoSettingsBool('EXPAND_CATEGORIES', True);
end;

procedure TfrOrganiseCategories.tvCategoriesChange(Sender: TObject;
  Node: TTreeNode);
var MyCategoryRec : PCategoryRec;
begin
  if not assigned(Node) then exit;

  MyCategoryRec := PCategoryRec(tvCategories.Selected.Data);
  eCatedID.text := IntToStr(MyCategoryRec^.CatID);
  esubCategID.text := IntToStr(MyCategoryRec^.SubCatID);
  eCategname.text := MyCategoryRec^.CatName;
  eSubCategname.text := MyCategoryRec^.SubCatName;
  if MyCategoryRec^.Colour <> '' then
    cdbCategory.Color := StringToColor(MyCategoryRec^.Colour)
  else
    cdbCategory.Color := clDefault;

  if Node.AbsoluteIndex <> 0 then
    eCategoryName.Text:= Node.Text
  else
    eCategoryName.Text:= '';

  cbBudgetShow.Checked := MyCategoryRec^.IncludeBudget;

  bAdd.Enabled := (tvCategories.Selected.Level < 2);
  bRename.Enabled:= (tvCategories.Selected.Level > 0);
  bDelete.Enabled:= (tvCategories.Selected.Level > 0);
  bSelect.Enabled := (Node.AbsoluteIndex <> 0);
  cbBudgetShow.Enabled := (Node.AbsoluteIndex <> 0);
  cdbCategory.Enabled := (tvCategories.Selected.Level = 1);
end;

function TfrOrganiseCategories.SelectCategory(var CatId, SubCatID : integer) : boolean;
var MyCategoryRec : PCategoryRec;
  Node : TTreeNode;
begin
  result := false;
  frOrganiseCategories := TfrOrganiseCategories.create(nil);
//  bClose.Caption:= 'Cancel';
  if (CatID > 0) then
  begin
    if frOrganiseCategories.zqCategories.Locate('CATEGID', CatID, [loCaseInsensitive]) = True then
    begin
      Node := dmData.GetNodeByText(frOrganiseCategories.tvCategories, frOrganiseCategories.zqCategories.FieldByName('CATEGNAME').AsString, false);
      Node.Selected := True;
      Node.Expanded:= True;
    end;
  end;

  if (SubCatID > 0) then
  begin
    if frOrganiseCategories.zqCategories.Locate('SUBCATEGID', SubCatID, [loCaseInsensitive]) = True then
    begin
      Node := dmData.GetNodeByText(frOrganiseCategories.tvCategories, frOrganiseCategories.zqCategories.FieldByName('SUBCATEGNAME').AsString, false);
      Node.Selected := True;
      Node.Expanded:= True;
    end;
  end;

  if frOrganiseCategories.ShowModal = mrOk then
  begin
    MyCategoryRec := PCategoryRec(frOrganiseCategories.tvCategories.Selected.Data);
    CatId := MyCategoryRec^.CatID;
    SubCatID := MyCategoryRec^.SubCatID;
    result := True;
  end;
  frOrganiseCategories.Free;
end;

procedure TfrOrganiseCategories.zqCategoriesAfterOpen(DataSet: TDataSet);
begin
  dmData.spoolQueryToSQLSpy(zqCategories);
end;

end.

