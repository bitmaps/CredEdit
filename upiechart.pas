unit uPieChart;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TADbSource, TALegendPanel, TASeries,
  TAStyles, TASources, TATools, Forms, Controls, Graphics, Dialogs, DBGrids,
  StdCtrls, ZDataset, db, TARadialSeries, TALegend, TACustomSeries,
  TAChartListbox, TANavigation, TAGUIConnectorAggPas;

type

  { TfrPieChart }

  TfrPieChart = class(TForm)
    bPieChart: TButton;
    bBarChart: TButton;
    Chart1: TChart;
    Chart1BarSeries1: TBarSeries;
    Chart1PieSeries1: TPieSeries;
    ChartStyles1: TChartStyles;
    ChartToolset1: TChartToolset;
    ChartToolset1ZoomClickTool1: TZoomClickTool;
    ChartToolset1ZoomDragTool1: TZoomDragTool;
    ChartToolset1ZoomMouseWheelTool1: TZoomMouseWheelTool;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    ListChartSource1: TListChartSource;
    ZQuery1: TZQuery;
    ZQuery1CNT: TStringField;
    ZQuery1PAYEENAME: TMemoField;
    ZQuery1TOTAMOUNT: TStringField;
    ZQuery1TRANSCODE: TMemoField;
    procedure bPieChartClick(Sender: TObject);
    procedure bBarChartClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frPieChart: TfrPieChart;

implementation

{$R *.lfm}

{ TfrPieChart }
uses udatamodule;

procedure TfrPieChart.bPieChartClick(Sender: TObject);
var i : integer;
  TmpDate : TDate;
  TmpDateStr : string;
begin
  Chart1PieSeries1.Active:= True;
  Chart1BarSeries1.Active:= False;

  TmpDate := now - 30;
  TmpDateStr := FormatDateTime('YYYYMMDD', TmpDate);
//  bPieChart.Caption := TmpDateStr;

  Chart1.Title.Text.Clear;
  Chart1.Title.Text.Add('Test');
  Chart1.Title.Visible:= True;
  Chart1.AxisVisible:= False;
  Chart1.Frame.Visible:=true;

  //pie chart labels
//  Chart1PieSeries1.Marks.Format:= '%2:s'; //label
//  Chart1PieSeries1.Marks.Format:= '%2:s %1:.2f%%'; //label + percent
  Chart1PieSeries1.Marks.Format:= '%2:s %0:.9g'; //label + value
//  Chart1PieSeries1.Marks.Format:= '%1:.2f%%'; //percent
  Chart1PieSeries1.Marks.Visible:= false;
  Chart1PieSeries1.MarkPositions:= pmpAround;
//  Chart1PieSeries1.MarkPositions:= pmpInside;  //unit TARadialSeries

  //legend options
  Chart1.Legend.Visible:= true;
  Chart1.Legend.Alignment:= laBottomRight;
  Chart1.Legend.UseSidebar:= False;
  Chart1PieSeries1.Legend.Multiplicity:= lmPoint; //unit TALegend
  Chart1PieSeries1.Legend.Format:= '%2:s %1:.2f%%';


  zquery1.SQL.Clear;
  zquery1.SQL.Add(
  ' select transcode, payeename, sum(transamount) TOTAMOUNT, count(*) CNT '+
  ' from checkingaccount_v1 ch '+
  ' inner join payee_v1 p on ch.payeeid = p.payeeid '+
  ' where transcode = ''Withdrawal'' '+
  ' and strftime(''%Y%m%d'',transdate) >= '+QuotedStr(TmpDateStr)+
  ' group by transcode, payeename '
  );
  zquery1.Active:=True;
  zquery1.First;
  ListChartSource1.Clear;
  Chart1PieSeries1.Source := ListChartSource1;
  for i:= 1 to zquery1.RecordCount do
  begin;
    ListChartSource1.Add(0, zquery1.fieldbyname('TOTAMOUNT').AsFloat, zquery1.fieldbyname('PAYEENAME').AsString);
    zquery1.Next;
  end;
end;

procedure TfrPieChart.bBarChartClick(Sender: TObject);
var i : integer;
  TmpDate : TDate;
  TmpDateStr : string;
begin
  Chart1PieSeries1.Active:= false;
  Chart1BarSeries1.Active:= true;

  TmpDate := now - 30;
  TmpDateStr := FormatDateTime('YYYYMMDD', TmpDate);
//  bPieChart.Caption := TmpDateStr;

  Chart1.Title.Text.Clear;
  Chart1.Title.Text.Add('Test');
  Chart1.Title.Visible:= True;
  Chart1.AxisVisible:= true;
  Chart1.Frame.Visible:=True;
  Chart1.BottomAxis.Grid.Visible:= False;
  Chart1.LeftAxis.Grid.Visible:= True;

  //pie chart labels
//  Chart1PieSeries1.Marks.Format:= '%2:s'; //label
//  Chart1PieSeries1.Marks.Format:= '%2:s %1:.2f%%'; //label + percent
//  Chart1BarSeries1.Marks.Format:= '%2:s %0:.9g'; //label + value
//  Chart1PieSeries1.Marks.Format:= '%1:.2f%%'; //percent
  Chart1BarSeries1.Marks.Format:= '%0:.9g'; //value
  Chart1BarSeries1.Marks.Visible:= True;
//  Chart1BarSeries1.MarkPositions:= lmpOutside;    //unit TACustomSeries
  Chart1BarSeries1.MarkPositions:= lmpInside;  //unit TARadialSeries

  //legend options
  Chart1.Legend.Visible:= false;
//  Chart1BarSeries1.Legend.Multiplicity:= lmpInside; //unit TALegend
  Chart1BarSeries1.Legend.Multiplicity:= lmPoint; //unit TALegend
  Chart1BarSeries1.Legend.Format:= '%2:s %1:.2f%%';
  Chart1BarSeries1.Source := ListChartSource1;
  Chart1BarSeries1.Shadow.Visible:= true;


  zquery1.SQL.Clear;
  zquery1.SQL.Add(
  ' select transcode, payeename, sum(transamount) TOTAMOUNT, count(*) CNT '+
  ' from checkingaccount_v1 ch '+
  ' inner join payee_v1 p on ch.payeeid = p.payeeid '+
  ' where transcode = ''Withdrawal'' '+
  ' and strftime(''%Y%m%d'',transdate) >= '+QuotedStr(TmpDateStr)+
  ' group by transcode, payeename '
  );
  zquery1.Active:=True;
  zquery1.First;
  ListChartSource1.Clear;
  for i:= 1 to zquery1.RecordCount do
  begin;
    ListChartSource1.Add(i, zquery1.fieldbyname('TOTAMOUNT').AsFloat, zquery1.fieldbyname('PAYEENAME').AsString);
    zquery1.Next;
  end;
end;

end.

