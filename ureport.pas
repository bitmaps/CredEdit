unit uReport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, LR_Class, LR_DBSet, LR_View, LR_Desgn, Forms,
  Controls, Graphics, Dialogs, StdCtrls, DBGrids, ZDataset;

type

  { TFrmReport }

  TFrmReport = class(TForm)
    Button1: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    frDBDataSet1: TfrDBDataSet;
    frDesigner1: TfrDesigner;
    frPreview1: TfrPreview;
    frReport1: TfrReport;
    OpenDialog1: TOpenDialog;
    ZQuery1: TZQuery;
    ZQuery1ASSETID: TLargeintField;
    ZQuery1ASSETNAME: TMemoField;
    ZQuery1ASSETTYPE: TMemoField;
    ZQuery1NOTES: TMemoField;
    ZQuery1STARTDATE: TMemoField;
    ZQuery1VALUE: TFloatField;
    ZQuery1VALUECHANGE: TMemoField;
    ZQuery1VALUECHANGERATE: TFloatField;
    procedure Button1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmReport: TFrmReport;

implementation

{$R *.lfm}

uses uDataModule;

{ TFrmReport }

procedure TFrmReport.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    frReport1.FileName := OpenDialog1.FileName;
    frReport1.LoadFromFile(OpenDialog1.Filename);
//    frReport1.DesignReport;
    frReport1.ShowReport;
  end;
end;

end.

