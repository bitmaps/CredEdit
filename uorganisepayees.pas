{ To do list:

 1.

}
unit uOrganisePayees;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, Graphics, Dialogs, {ValEdit,}
  Grids, ExtCtrls, StdCtrls, DbCtrls, customdrawncontrols {, ZDataset};

type

  { TfrPayee }

  TfrPayee = class(TForm)
    bCancel: TButton;
    bCategory: TButton;
    bOk1: TButton;
    cdbPayee: TCDButton;
    ColorDialog1: TColorDialog;
    dbePayeeID: TDBEdit;
    dbePayeeName: TDBEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    pBottom: TPanel;
    procedure bCategoryClick(Sender: TObject);
    procedure cdbPayeeClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure zqPayeeCategoriesPAYEENAMEGetText(Sender: TField;
      var aText: string; DisplayText: Boolean);
  private
    { private declarations }
  public
    { public declarations }
    EditMode : string;
  end;

var
  frPayee: TfrPayee;

implementation

{$R *.lfm}

uses uDataModule, uOrganiseCategories{, uNewTransaction};

{ TfrPayee }

procedure TfrPayee.zqPayeeCategoriesPAYEENAMEGetText(Sender: TField;
  var aText: string; DisplayText: Boolean);
begin
  aText := Copy(Sender.AsString, 1, 50);
end;

procedure TfrPayee.FormShow(Sender: TObject);
begin
  if EditMode = 'Edit' then
  begin
     frPayee.Caption:= 'Editing Payee';
     if dmData.ztPayee.FieldByName('COLOUR').AsString <> '' then
       cdbPayee.Color :=  StringToColor(dmData.ztPayee.FieldByName('COLOUR').AsString);
  end else
  if EditMode = 'Insert' then
     frPayee.Caption:= 'New Payee';

  dbePayeeName.SetFocus;
end;

procedure TfrPayee.bCategoryClick(Sender: TObject);
var CatID, SubCatID : integer;
begin
  CatID := dmData.ztPayee.FieldByName('CATEGID').AsInteger;
  SubCatID := dmData.ztPayee.FieldByName('SUBCATEGID').AsInteger;
  if frOrganiseCategories.SelectCategory(CatID, SubCatID) then
  begin
//    frMain.ztPayee.Insert;
    dmData.ztPayee.FieldByName('CATEGID').AsInteger := CatID;
    dmData.ztPayee.FieldByName('SUBCATEGID').AsInteger := SubCatID;
//    frMain.ztPayee.Post;
  end;
  bCategory.Caption := dmData.GetCategoryDescription(CatID, SubCatID, 'Default Category');
end;

procedure TfrPayee.cdbPayeeClick(Sender: TObject);
begin
  ColorDialog1.Color := cdbPayee.Color;
  if ColorDialog1.Execute then
    cdbPayee.Color:= ColorDialog1.Color;
end;

procedure TfrPayee.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if modalresult = mrOk then
    begin
      if dbePayeeName.Text = '' then
      begin
        canclose := False;
        dbePayeeName.SetFocus;
        exit;
      end else
      begin
        if (dmdata.zqPayee.Locate('PAYEENAME', dbePayeeName.Text, [loCaseInsensitive]) = True) and (dbePayeeID.Text <> dmdata.zqPayee.FieldByName('PAYEEID').AsString) then
          begin
            MessageDlg('Payee name: '+dbePayeeName.Text+' already exists.',mtError, [mbOK], 0);
            canclose := False;
            dbePayeeName.SetFocus;
            exit;
          end;
      end;

      dmData.ztPayee.FieldByName('COLOUR').AsString := ColorToString(cdbPayee.Color);
    end;
end;

procedure TfrPayee.FormCreate(Sender: TObject);
begin
end;

end.

