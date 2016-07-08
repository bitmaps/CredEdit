{ To do list:
  1. Show a faded font for filters which are archived
  2. Show filter count on groupbox caption (enabled total / grand total including archived).
  3. Show from/to date or Date setup.
}
unit uTransFiltersList;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DBGrids, ZDataset;

type

  { TfrTransFilterList }

  TfrTransFilterList = class(TForm)
    bAdd: TButton;
    bClose: TButton;
    bDelete: TButton;
    bEdit: TButton;
    dbgTranFilters: TDBGrid;
    panFooter: TPanel;
    rgFilters: TRadioGroup;
    procedure bAddClick(Sender: TObject);
    procedure bDeleteClick(Sender: TObject);
    procedure bEditClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frTransFilterList: TfrTransFilterList;

implementation

{$R *.lfm}

uses uTransactionFilter, uDatamodule, uMain;

{ TfrTransFilterList }

procedure TfrTransFilterList.bAddClick(Sender: TObject);
begin
  frTransactionFilter := TfrTransactionFilter.create(nil);
  frTransactionFilter.EditMode := 'Insert List';
  frTransactionFilter.Showmodal;
  frTransactionFilter.Free;
end;

procedure TfrTransFilterList.bDeleteClick(Sender: TObject);
begin
  if dmData.zqTransFilters.RecordCount = 0 then exit;

  if MessageDlg('Are you sure you want to delete "'+dmData.zqTransFilters.FieldByName('TRANSFILTERNAME').AsString+'" filter?',mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;

  if dmData.ztTransFilter.Locate('TRANSFILTERNAME', dmData.zqTransFilters.FieldByName('TRANSFILTERNAME').AsString, [loCaseInsensitive]) = True then
  begin
    dmData.DeleteDBRecord(dmData.ztTransFilter.TableName, 'TRANSFILTERID', dmData.zqTransFilters.FieldByName('TRANSFILTERID').AsInteger);
//    dmData.ztTransFilter.Refresh;
    dmdata.RefreshDataset(dmData.ztTransFilter);
    dmdata.RefreshDataset(dmData.zqTransFilters);

    dmData.SetupComboBoxFilterArchived(frMain.cbFilterList, dmdata.ztTransFilter, 'TRANSFILTERNAME', '[None]', '[None]');
  end;
end;

procedure TfrTransFilterList.bEditClick(Sender: TObject);
begin
  frTransactionFilter := TfrTransactionFilter.create(nil);
  if dmData.ztTransFilter.Locate('TRANSFILTERNAME', dmData.zqTransFilters.FieldByName('TRANSFILTERNAME').AsString, [loCaseInsensitive]) = True then
  begin
    frTransactionFilter.EditMode := 'Edit';
    frTransactionFilter.Showmodal;
    frTransactionFilter.Free;
  end;
end;

procedure TfrTransFilterList.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
//  dmdata.SaveGridLayout(dbgTranFilters, ExtractFilePath(application.exename)+'dbgTranFilters.txt');
  dmdata.SaveGridLayout(dbgTranFilters);
end;

procedure TfrTransFilterList.FormCreate(Sender: TObject);
var ToDateStr, FromDateStr : string;
begin
  dmData.zqTransFilters.Active:= False;
  dmData.zqTransFilters.SQL.Clear;
  FromDateStr := dmData.FormatDateSQL('FROMDATE');
  ToDateStr := dmData.FormatDateSQL('TODATE');
  dmData.zqTransFilters.SQL.Add(
//    ' select tf.*, '+ FromDateStr + ' FRMFROMDATE, '+ToDateStr + ' FRMTODATE '+
    ' select tf.*, '+
//    ' tf.FROMDATE FRMFROMDATE, tf.TODATE FRMTODATE, '+
    ' case datefilter when 0 then ''None'' else '+
//    ' case datefilter when 1 then Fromdate ||'':''|| ToDate else '+
    ' case datefilter when 1 then '+FromDateStr+' ||'' : ''|| '+ToDateStr+' else '+
    ' case datefilter when 2 then ''Current Week'' else '+
    ' case datefilter when 3 then ''Current Month'' else '+
    ' case datefilter when 4 then ''Current Quarter'' else '+
    ' case datefilter when 5 then ''Current Year'' '+
    ' end end end end end end as DATERANGE, '+
    ' case tf.categid when -1 then '+chr(39)+chr(39)+
    ' else '+
    '   case tf.subcategid when -1 then categname '+
    '   else coalesce(categname,'+chr(39)+chr(39)+') ||'+chr(39)+': '+chr(39)+'||coalesce(subcategname,'+chr(39)+chr(39)+') '+
    '   end '+
    ' end as CATEGORY '+
    ' from '+dmData.ztTransFilter.TableName +' tf '+
    ' left outer join '+dmdata.ztCategory.TableName+' c on tf.categid = c.categid '+
    ' left outer join '+dmdata.ztSubCategory.TableName+' sc on c.categid = sc.categid and tf.subcategid = sc.subcategid '+
    ' order by tf.TRANSFILTERNAME '
    );
  dmData.zqTransFilters.ExecSQL;
  dmData.zqTransFilters.Active:= True;
//  dmdata.LoadGridLayout(dbgTranFilters, ExtractFilePath(application.exename)+'dbgTranFilters.txt');
  dmdata.LoadGridLayout(dbgTranFilters);
end;

end.

