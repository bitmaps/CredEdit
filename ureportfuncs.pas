{ To do list:
  1. Add values to midway points in bar chart left axis
  2. Add ability to export charts
}

unit uReportFuncs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ComCtrls, ExtCtrls, {iniFiles,} db, math,
  TARadialSeries, TALegend, TACustomSeries, FileUtil, forms, StdCtrls,
  TASources, graphics, Dialogs, uReportFilter, TAGraph, ZDataset;

procedure RunDefaultReport(LoadReportSettings : Boolean);
procedure DoPieChart(Node : TTreeNode);
procedure DoBarChart(Node : TTreeNode);
function SetupReportDateFilter(ReportName : string) : string;
function SetupTransactionFilter(Node : TTreeNode) : string;
procedure SetupPieChartReportQuery(Node : TTreeNode);
procedure SetupBarChartReportQuery(Node : TTreeNode);
//procedure SetupRepAccountsComboBox(var ComboBox : TComboBox);
procedure SetupLeftAxisValues(ListChartSource, AxisChartSource : TListChartSource);
procedure RunLazReport(Node : TTreeNode);
function SetupTransactionReport : Boolean;
procedure DoHomepageBarChart(QueryName : TZQuery; HomepageBarChart : TChart ; MarksSource, LeftAxis, BottomAxis : TListChartSource; ReportName, ReportType : string; GroupBy : integer);
procedure SetupHomepageBarChartReportQuery(QueryName : TZQuery; HomepageBarChart : TChart ; MarksSource, LeftAxis, BottomAxis : TListChartSource; ReportName, ReportType : string; GroupBy : integer);
function SetupHomepageBarChartTransactionFilter(ReportType : string) : string;

implementation

uses uMain, uDataModule;

{procedure SetupRepAccountsComboBox(var ComboBox : TComboBox);
var i : integer;
begin
  ComboBox.Items.Clear;
  dmData.ztAccountList.First;
  ComboBox.Items.Add('All Accounts');
  for i:= 1 to dmData.ztAccountList.RecordCount do
  begin
    ComboBox.Items.Add(dmData.ztAccountList.FieldByName('ACCOUNTNAME').AsString);
    dmData.ztAccountList.Next;
  end;
end;}

procedure DoPieChart(Node : TTreeNode);
var ReportTitleStr : string;
begin
  Screen.Cursor:= crHourGlass;
  with frMain do
  begin
    PieChart.BackColor:= StringToColor(dmData.GetInfoSettings('COLOURS_CHARTBACKGROUND', 'clBtnFace'));
    PieChart.Visible:= True;
    PieChart.Align:= alClient;
    PieChartPieSeries1.Active:= True;
    BarChart.Visible:= False;
    BarChartBarSeries1.Active:= False;

    lcsChartValues.Clear;
    lcsPieChartValues.Clear;
    lcsBottomAxisValues.Clear;
    lcsLeftAxisValues.Clear;
    dmData.zqReport.SQL.Clear;


{    if assigned(Node.Parent) and (Node.Parent.Text <> 'Reports') then
      gbReport.Caption := Node.Parent.Text + ': ' + Node.Text + ' (' + cbRepAccounts.Text + ': ' + cbItemLimit.Text + ') '
    else
      gbReport.Caption := Node.Text + ' (' + cbRepAccounts.Text + ': ' + cbItemLimit.Text + ') ';}
    gbReport.Caption := '';
    if assigned(Node.Parent) and (Node.Parent.Text <> 'Reports') then
      ReportTitleStr := Node.Parent.Text + ': ' + Node.Text + ' (' + cbRepAccounts.Text + ': ' + cbItemLimit.Text + ') '
    else
      ReportTitleStr := Node.Text + ' (' + cbRepAccounts.Text + ': ' + cbItemLimit.Text + ') ';

    PieChart.Title.Text.Clear;
    PieChart.Title.Text.Add(ReportTitleStr);
    PieChart.Title.Visible:= True;
    PieChart.Title.Font.Color:= PieChart.Font.Color;
    PieChart.Title.Font.Style:=[fsUnderline, fsBold];
    PieChart.AxisVisible:= False;
    PieChart.Frame.Visible:=false;

    //pie chart labels
  //  PieChartPieSeries1.Marks.Format:= '%2:s'; //label
    PieChartPieSeries1.Marks.Format:= '%2:s %1:.2f%%'; //label + percent
//    PieChartPieSeries1.Marks.Format:= '%2:s %0:.9g'; //label + value
  //  Chart1PieSeries1.Marks.Format:= '%1:.2f%%'; //percent
    PieChartPieSeries1.Marks.Visible:= true;
    PieChartPieSeries1.MarkPositions:= pmpLeftRight;
  //  Chart1PieSeries1.MarkPositions:= pmpAround;
  //  Chart1PieSeries1.MarkPositions:= pmpInside;  //unit TARadialSeries

    //legend options
    PieChart.Legend.Visible:= false;
  //  Chart1.Legend.Alignment:= laBottomRight;
    PieChart.Legend.UseSidebar:= false;
    PieChartPieSeries1.Legend.Multiplicity:= lmPoint; //unit TALegend
    PieChartPieSeries1.Legend.Format:= '%2:s %1:.2f%%';
  end;
  SetupPieChartReportQuery(Node);
  Screen.Cursor:= crDefault;
end;

procedure DoBarChart(Node : TTreeNode);
var ReportTitleStr : string;
begin
  Screen.Cursor:= crHourGlass;
  with frMain do
  begin
    BarChart.BackColor:= StringToColor(dmData.GetInfoSettings('COLOURS_CHARTBACKGROUND', 'clBtnFace'));
    BarChart.Visible:= True;
    BarChart.Align:= alClient;
    BarChartBarSeries1.Active:= True;
    PieChart.Visible:= False;
    PieChartPieSeries1.Active:= False;

{    Chart1PieSeries1.Active:= false;
    Chart1BarSeries1.Active:= true;}
//    Chart1.Title.Text.Clear;

{    if assigned(Node.Parent) and (Node.Parent.Text <> 'Reports') then
      gbReport.Caption := Node.Parent.Text + ': ' + Node.Text + ' (' + cbRepAccounts.Text + ': ' + cbItemLimit.Text + ') '
    else
      gbReport.Caption := Node.Text + ' (' + cbRepAccounts.Text + ': ' + cbItemLimit.Text + ') ';}

    gbReport.Caption := '';
    if assigned(Node.Parent) and (Node.Parent.Text <> 'Reports') then
      ReportTitleStr := Node.Parent.Text + ': ' + Node.Text + ' (' + cbRepAccounts.Text + ': ' + cbItemLimit.Text + ') '
    else
      ReportTitleStr := Node.Text + ' (' + cbRepAccounts.Text + ': ' + cbItemLimit.Text + ') ';

    BarChart.Title.Text.Clear;
    BarChart.Title.Text.Add(ReportTitleStr);
    BarChart.Title.Visible:= True;
    BarChart.Title.Font.Color:= PieChart.Font.Color;
    BarChart.Title.Font.Style:=[fsUnderline, fsBold];


{  {  Chart1.Title.Text.Add(Node.Parent.Text + ': ' + Node.Text);
    Chart1.Title.Visible:= True;}
    Chart1.AxisVisible:= false;
    BarChart.Frame.Visible:=True;
    Chart1.BottomAxis.Grid.Visible:= False;
    Chart1.LeftAxis.Grid.Visible:= True;

    //pie chart labels
  //  Chart1PieSeries1.Marks.Format:= '%2:s'; //label
  //  Chart1PieSeries1.Marks.Format:= '%2:s %1:.2f%%'; //label + percent
    Chart1BarSeries1.Marks.Format:= '%2:s %0:.9g'; //label + value
  //  Chart1PieSeries1.Marks.Format:= '%1:.2f%%'; //percent
  //  Chart1BarSeries1.Marks.Format:= '%0:.9g'; //value
    Chart1BarSeries1.Marks.Visible:= True;
    Chart1.Margins.Bottom := 0;
    Chart1BarSeries1.MarkPositions:= lmpOutside;    //unit TACustomSeries
  //  Chart1BarSeries1.MarkPositions:= lmpInside;  //unit TARadialSeries

    //legend options
    Chart1.Legend.Visible:= false;
  //  Chart1BarSeries1.Legend.Multiplicity:= lmpInside; //unit TALegend
    Chart1BarSeries1.Legend.Multiplicity:= lmPoint; //unit TALegend
    Chart1BarSeries1.Legend.Format:= '%2:s %1:.2f%%';
    Chart1BarSeries1.Source := ListChartSource1;
    Chart1BarSeries1.Shadow.Visible:= true;}
  end;
  SetupBarChartReportQuery(Node);
  Screen.Cursor:= crDefault;
end;

function SetupReportDateFilter(ReportName : string) : string;
var
  FinStartDayStr, FinStartMonthStr, CurrMonthStr, {CurrYearStr,} CurrDayStr, TranDatefilter, TmpDateStr, PrevMonthStr: string;
  FinStartDay, FinStartMonth  : integer;
  CurrYear, CurrMonth, CurrDay, PrevMonth: Word;
  FinDate : TDate;
begin
  //Grab date variables
  DecodeDate(now, CurrYear, CurrMonth, CurrDay);
  if CurrMonth < 10 then
    CurrMonthStr := '0'+IntToStr(CurrMonth)
  else
    CurrMonthStr := IntToStr(CurrMonth);

  PrevMonth := CurrMonth - 1;
  if PrevMonth < 10 then
    PrevMonthStr := '0'+IntToStr(PrevMonth)
  else
    PrevMonthStr := IntToStr(PrevMonth);

  if CurrDay < 10 then
    CurrDayStr := '0'+IntToStr(CurrDay)
  else
    CurrDayStr := IntToStr(CurrDay);

  FinStartDay := dmData.GetInfoSettingsInt('FINANCIAL_YEAR_START_DAY', 1);
  if FinStartDay < 10 then
    FinStartDayStr := '0'+IntToStr(FinStartDay)
  else
    FinStartDayStr := IntToStr(FinStartDay);

  FinStartMonth := dmData.GetInfoSettingsInt('FINANCIAL_YEAR_START_MONTH', 7);
  if FinStartMonth < 10 then
    FinStartMonthStr := '0'+IntToStr(FinStartMonth)
  else
    FinStartMonthStr := IntToStr(FinStartMonth);

  if ReportName = 'Last Calendar Month' then
  begin
    TranDatefilter :=
    ' and strftime(''%Y%m%d'',transdate) >= '+ QuotedStr(IntToStr(CurrYear) + PrevMonthStr + '01')  +
    ' and strftime(''%Y%m%d'',transdate) < '+ QuotedStr(IntToStr(CurrYear) + CurrMonthStr + '01');
  end else
  if ReportName = 'Last Year' then
  begin
    TranDatefilter :=
    ' and strftime(''%Y%m%d'',transdate) >= '+ QuotedStr(IntToStr(CurrYear-1) + '0101')  +
    ' and strftime(''%Y%m%d'',transdate) <= '+ QuotedStr(IntToStr(CurrYear-1) + '1231');
  end else
  if ReportName = 'Last Financial Year' then
  begin
{    TranDatefilter :=
    ' and strftime(''%Y%m%d'',transdate) >= '+ QuotedStr(IntToStr(CurrYear-1) + FinStartMonthStr + FinStartDayStr)  +
    ' and strftime(''%Y%m%d'',transdate) < '+ QuotedStr(IntToStr(CurrYear) + FinStartMonthStr + FinStartDayStr);}
    FinDate := EncodeDate(CurrYear,FinStartMonth,FinStartDay);
    if Date < FinDate then
    begin
      TranDatefilter :=
      ' and strftime(''%Y%m%d'',transdate) >= '+ QuotedStr(IntToStr(CurrYear-2) + FinStartMonthStr + FinStartDayStr)  +
      ' and strftime(''%Y%m%d'',transdate) < '+ QuotedStr(IntToStr(CurrYear-1) + FinStartMonthStr + FinStartDayStr);
    end else
    begin
      TranDatefilter :=
      ' and strftime(''%Y%m%d'',transdate) >= '+ QuotedStr(IntToStr(CurrYear-1) + FinStartMonthStr + FinStartDayStr)  +
      ' and strftime(''%Y%m%d'',transdate) < '+ QuotedStr(IntToStr(CurrYear) + FinStartMonthStr + FinStartDayStr);
    end;
  end else
  if ReportName = 'Current Financial Year' then
  begin
    FinDate := EncodeDate(CurrYear,FinStartMonth,FinStartDay);
    if Date < FinDate then
    begin
      TranDatefilter :=
      ' and strftime(''%Y%m%d'',transdate) >= '+ QuotedStr(IntToStr(CurrYear-1) + FinStartMonthStr + FinStartDayStr)  +
      ' and strftime(''%Y%m%d'',transdate) < '+ QuotedStr(IntToStr(CurrYear) + FinStartMonthStr + FinStartDayStr);
    end else
    begin
      TranDatefilter :=
      ' and strftime(''%Y%m%d'',transdate) >= '+ QuotedStr(IntToStr(CurrYear) + FinStartMonthStr + FinStartDayStr)  +
      ' and strftime(''%Y%m%d'',transdate) < '+ QuotedStr(IntToStr(CurrYear+1) + FinStartMonthStr + FinStartDayStr);
    end;

    {    TmpDateStr :=  IntToStr(CurrYear) + FinStartMonthStr + FinStartDayStr;
    TranDatefilter := ' and strftime(''%Y%m%d'',transdate) >= '+QuotedStr(TmpDateStr);}
  end else
  if ReportName = 'Last 30 Days' then
  begin
    TmpDateStr := FormatDateTime('YYYYMMDD', (now - 30));
    TranDatefilter := ' and strftime(''%Y%m%d'',transdate) >= '+QuotedStr(TmpDateStr);
  end else
  if ReportName = 'Current Year' then
  begin
    TmpDateStr := IntToStr(CurrYear)+'0101';
    TranDatefilter := ' and strftime(''%Y%m%d'',transdate) >= '+QuotedStr(TmpDateStr);
  end else
  if ReportName = 'Current Month' then
  begin
    TmpDateStr := IntToStr(CurrYear)+CurrMonthStr+'01';
    TranDatefilter := ' and strftime(''%Y%m%d'',transdate) >= '+QuotedStr(TmpDateStr);
  end
  else TranDatefilter := '';

  result := TranDatefilter;
end;

function SetupTransactionFilter(Node : TTreeNode) : string;
var TranscodeFilter : string;
begin
  if assigned(Node.Parent) then
  begin
    if Node.Parent.Text = 'Where the Money Goes' then
      TranscodeFilter := ' where transcode = ''Withdrawal'' '
    else
    if Node.Parent.Text = 'Where the Money Comes From' then
      TranscodeFilter := ' where transcode = ''Deposit'' ';
  end else TranscodeFilter := ' where 1=1 ';

  Result := TranscodeFilter;
end;

procedure SetupBarChartReportQuery(Node : TTreeNode);
var i : integer;
  AccountFilter, TranscodeFilter, TranDatefilter, RowFilter,
  SelectField, SelectJoin, AmountStr, MainSelect, Groupby: string;
  Colour : TColor;
begin
  if not assigned(Node) then exit;

  if dmData.ztAccountList.Locate('ACCOUNTNAME', frMain.cbRepAccounts.Text , [loCaseInsensitive]) = True then
    AccountFilter := ' and accountid = '+IntToStr(dmData.ztAccountList.fieldbyname('ACCOUNTID').AsInteger)
  else
    AccountFilter := '';

  with frMain do
  begin
    if cbItemLimit.Text = 'All Items' then RowFilter := '' else
    if cbItemLimit.Text = 'Top 10' then RowFilter := ' limit 10 ' else
    if cbItemLimit.Text = 'Top 20' then RowFilter := ' limit 20 ' else
    if cbItemLimit.Text = 'Top 30' then RowFilter := ' limit 30 ';
  end;
  dmData.zqReport.SQL.Clear;

  TranscodeFilter := SetupTransactionFilter(Node);
  TranDatefilter := SetupReportDateFilter(Node.Text);

  if Node.Text = 'Income Vs Expenses' then
  begin
    dmData.zqReport.SQL.Add(
    ' select ''Expenses'' trantype,'+
    ' case when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." then COALESCE(SUM(transamount),0) || "0" '+
    ' when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" then COALESCE(SUM(transamount),0) || "'+frMain.DecimalPlacesStr+'" '+
    ' else COALESCE(SUM(transamount),0) '+
    ' end as totamount '+
    ' from '+dmData.ztCheckingAccount.TableName+' '+
    ' where transcode = ''Withdrawal'' '+
    AccountFilter +
    ' union  '+
    ' select ''Income'' trantype, '+
    ' case when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." then COALESCE(SUM(transamount),0) || "0" '+
    ' when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" then COALESCE(SUM(transamount),0) || "'+frMain.DecimalPlacesStr+'" '+
    ' else COALESCE(SUM(transamount),0) '+
    ' end as totamount '+
    ' from '+dmData.ztCheckingAccount.TableName+' '+
    ' where transcode = ''Deposit'' '+
    AccountFilter +
    ' order by totamount desc ');
    dmData.zqReport.Active:=True;

    dmData.SpoolQueryToSQLSpy(dmData.zqReport);

    for i:= 1 to dmData.zqReport.RecordCount do
    begin;
//      AmountStr := FloatToStr(dmData.RoundEx(dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, DecimalPlaces));
      AmountStr := FloatToStr(dmData.RoundEx(dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, {fs.CurrencyDecimals}frMain.DecimalPlaces));
      AmountStr := frMain.CurrencySymbol+dmData.CurrencyStr2DP(AmountStr);

      if dmData.zqReport.fieldbyname('trantype').AsString = 'Expenses' then
        Colour := StringToColor(dmdata.GetInfoSettings('COLOURS_EXPENSES', 'clRed')) else
      if dmData.zqReport.fieldbyname('trantype').AsString = 'Income' then Colour := StringToColor(dmdata.GetInfoSettings('COLOURS_INCOME', 'clBlue')) else
        Colour := dmData.GetRandomColour;

      frMain.lcsChartValues.Add(i, dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, {dmData.zqReport.fieldbyname('trantype').AsString} AmountStr, Colour);
      frMain.lcsBottomAxisValues.Add(i, dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, dmData.zqReport.fieldbyname('trantype').AsString, Colour);
      dmData.zqReport.Next;
    end;
  end else
  if (Node.Parent.Text = 'Where the Money Goes') or (Node.Parent.Text = 'Where the Money Comes From') then
  begin
    case frMain.cbRepGroup.itemindex of
    0 : begin
          SelectField := 'payeename';
          MainSelect :=
          ' case when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." then COALESCE(SUM(transamount),0) || "0" '+
          ' when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" '+
          ' then COALESCE(SUM(transamount),0) || "'+frMain.DecimalPlacesStr+'"  else COALESCE(SUM(transamount),0) end as TOTAMOUNT, p.colour, '+
          ' count(*) CNT ' +
          ' from '+dmData.ztCheckingAccount.TableName+' ch ';
          SelectJoin := ' inner join '+dmData.ztPayee.TableName+' p on ch.payeeid = p.payeeid ';
          Groupby := 'payeename';
        end;
    1 : begin
          SelectField := ' case s.transid when ch.transid then c2.categname else '+
                         ' case ch.categid when 0 then ''N/A'' else '+
                         ' case ch.categid when -1 then ''N/A'' else c.categname '+
                         ' end end end as category ';
          MainSelect :=
          ' case when substr(COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0),length(ROUND(COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." '+
          '  then COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0) || "0" '+
          '  when substr(COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0),length(ROUND(COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" '+
          '  then COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0) || "'+frMain.DecimalPlacesStr+'"  else COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0) end as TOTAMOUNT,  '+
          ' case ch.categid when -1 then c2.colour else c.colour end as colour '+
          ' from '+dmData.ztCheckingAccount.TableName+' ch ';

          SelectJoin := ' left outer join '+dmData.ztCategory.TableName+' c on ch.categid = c.categid '+
                        ' left outer join '+dmData.ztSplitTransactions.Tablename+' s on ch.transid = s.transid '+
                        ' left outer join '+dmData.ztCategory.TableName+' c2 on s.categid = c2.categid ';
          Groupby := 'category';
        end;
    end;

    dmData.zqReport.SQL.Add(
    ' select '+SelectField+', '+
    MainSelect +
    SelectJoin +
    TranscodeFilter +
    AccountFilter +
    TranDatefilter +
    ' group by '+Groupby +
    ' order by totamount desc '+
    RowFilter);
    dmData.zqReport.Active:=True;

    dmData.SpoolQueryToSQLSpy(dmData.zqReport);

    for i:= 1 to dmData.zqReport.RecordCount do
    begin;
//      AmountStr := FloatToStr(dmData.RoundEx(dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, DecimalPlaces));
      AmountStr := FloatToStr(dmData.RoundEx(dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, {fs.CurrencyDecimals}frMain.DecimalPlaces));
      AmountStr := frMain.CurrencySymbol+dmData.CurrencyStr2DP(AmountStr);
      if dmData.zqReport.fieldbyname('COLOUR').AsString <> '' then
        Colour := StringToColor(dmData.zqReport.fieldbyname('COLOUR').AsString)
      else
        Colour := dmData.GetRandomColour;

      frMain.lcsChartValues.Add(i, dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, AmountStr, Colour);
      frMain.lcsBottomAxisValues.Add(i, dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, dmData.zqReport.fieldbyname(Groupby).AsString, Colour);
      dmData.zqReport.Next;
    end;
  end;
  dmData.zqReport.Active:=False;

  SetupLeftAxisValues(frMain.lcsChartValues, frMain.lcsLeftAxisValues);
end;

procedure SetupPieChartReportQuery(Node : TTreeNode);
var i : integer;
//  TmpDate : TDate;
  {TmpDateStr,} AccountFilter,TranscodeFilter, TranDatefilter, RowFilter,
  SelectField, SelectJoin, AmountStr, MainSelect, GroupBy : string;
//  CurrYear, CurrMonth, CurrDay: Word;
Colour : TColor;
begin
  if not assigned(Node) then exit;

  TranDatefilter := '';

  if dmData.ztAccountList.Locate('ACCOUNTNAME', frMain.cbRepAccounts.Text , [loCaseInsensitive]) = True then
    AccountFilter := ' and accountid = '+IntToStr(dmData.ztAccountList.fieldbyname('ACCOUNTID').AsInteger)
  else
    AccountFilter := '';

  with frMain do
  begin
    if cbItemLimit.Text = 'All Items' then RowFilter := '' else
    if cbItemLimit.Text = 'Top 10' then RowFilter := ' limit 10 ' else
    if cbItemLimit.Text = 'Top 20' then RowFilter := ' limit 20 ' else
    if cbItemLimit.Text = 'Top 30' then RowFilter := ' limit 30 ';
{    lcsChartValues.Clear;
    lcsPieChartValues.Clear;   }
    PieChartPieSeries1.Source := lcsPieChartValues;
  end;
  dmData.zqReport.SQL.Clear;

  TranscodeFilter := SetupTransactionFilter(Node);
  TranDatefilter := SetupReportDateFilter(Node.Text);

  if Node.Text = 'Income Vs Expenses' then
  begin
    dmData.zqReport.SQL.Add(
    ' select ''Expenses'' trantype,'+ //'COALESCE(SUM(transamount),0) totamount '+
{    ' case when substr(sum(transamount),length(ROUND(sum(transamount),2))-1,1) = "." then sum(transamount) || "0" '+
    ' when substr(sum(transamount),length(ROUND(sum(transamount),2))-1,1) = "" then sum(transamount) || ".00" '+
    ' else sum(transamount) '+
    ' end as totamount '+}
    ' case when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." then COALESCE(SUM(transamount),0) || "0" '+
    ' when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" then COALESCE(SUM(transamount),0) || ".00" '+
    ' else COALESCE(SUM(transamount),0) '+
    ' end as totamount '+
//    ' select ''Withdrawal'' trantype, sum(transamount) totamount '+
    ' from '+dmData.ztCheckingAccount.TableName+' '+
    ' where transcode = ''Withdrawal'' '+
    AccountFilter +
    ' union  '+
//    ' select ''Income'' trantype, sum(transamount) totamount '+
    ' select ''Income'' trantype, '+ //'COALESCE(SUM(transamount),0) totamount '+
{    ' case when substr(sum(transamount),length(ROUND(sum(transamount),2))-1,1) = "." then sum(transamount) || "0" '+
    ' when substr(sum(transamount),length(ROUND(sum(transamount),2))-1,1) = "" then sum(transamount) || ".00" '+
    ' else sum(transamount) '+
    ' end as totamount '+}
    ' case when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." then COALESCE(SUM(transamount),0) || "0" '+
    ' when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" then COALESCE(SUM(transamount),0) || ".00" '+
    ' else COALESCE(SUM(transamount),0) '+
    ' end as totamount '+
    ' from '+dmData.ztCheckingAccount.TableName+' '+
    ' where transcode = ''Deposit'' '+
    AccountFilter +
    ' order by totamount desc '
    );

    dmData.zqReport.Active:=True;

    dmData.SpoolQueryToSQLSpy(dmData.zqReport);

    for i:= 1 to dmData.zqReport.RecordCount do
    begin;
//      AmountStr := FloatToStr(dmData.RoundEx(dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, DecimalPlaces));
      AmountStr := FloatToStr(dmData.RoundEx(dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, {fs.CurrencyDecimals}frMain.DecimalPlaces));
      AmountStr := frMain.CurrencySymbol+dmData.CurrencyStr2DP(AmountStr);

      if dmData.zqReport.fieldbyname('trantype').AsString = 'Expenses' then
        Colour := StringToColor(dmdata.GetInfoSettings('COLOURS_EXPENSES', 'clRed')) else
      if dmData.zqReport.fieldbyname('trantype').AsString = 'Income' then Colour := StringToColor(dmdata.GetInfoSettings('COLOURS_INCOME', 'clBlue')) else
        Colour := dmData.GetRandomColour;

      frMain.lcsPieChartValues.Add(0, dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, dmData.zqReport.fieldbyname('trantype').AsString {AmountStr}, Colour);
//      BottomAxis.Add(i, QueryName.fieldbyname('TOTAMOUNT').AsFloat, QueryName.fieldbyname('trantype').AsString, Colour);

      //      frMain.lcsPieLabels.Add(0, dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, dmData.zqReport.fieldbyname('trantype').AsString + ' '+ AmountStr, Colour);
      dmData.zqReport.Next;
    end;
  end else
  if (Node.Parent.Text = 'Where the Money Goes') or (Node.Parent.Text = 'Where the Money Comes From') then
  begin
    case frMain.cbRepGroup.itemindex of
    0 : begin
       {   SelectField := 'payeename';
          SelectJoin := ' inner join payee_v1 p on ch.payeeid = p.payeeid ';}
          SelectField := 'payeename';
          MainSelect :=
          ' case when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." then COALESCE(SUM(transamount),0) || "0" '+
          ' when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" '+
          ' then COALESCE(SUM(transamount),0) || "'+frMain.DecimalPlacesStr+'"  else COALESCE(SUM(transamount),0) end as TOTAMOUNT, p.colour, '+
          ' count(*) CNT ' +
          ' from '+dmData.ztCheckingAccount.TableName+' ch ';
          SelectJoin := ' inner join '+dmData.ztPayee.TableName+' p on ch.payeeid = p.payeeid ';
          Groupby := 'payeename';

        end;
    1 : begin
       {   SelectField := 'categname';
          SelectJoin := ' left outer join category_v1 c on ch.categid = c.categid ';}
          SelectField := ' case s.transid when ch.transid then c2.categname else '+
                         ' case ch.categid when 0 then ''N/A'' else '+
                         ' case ch.categid when -1 then ''N/A'' else c.categname '+
                         ' end end end as category ';
          MainSelect :=
          ' case when substr(COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0),length(ROUND(COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." '+
          '  then COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0) || "0" '+
          '  when substr(COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0),length(ROUND(COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" '+
          '  then COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0) || "'+frMain.DecimalPlacesStr+'"  else COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0) end as TOTAMOUNT,  '+
          ' case ch.categid when -1 then c2.colour else c.colour end as colour '+
          ' from '+dmData.ztCheckingAccount.TableName+' ch ';

          SelectJoin := ' left outer join '+dmData.ztCategory.TableName+' c on ch.categid = c.categid '+
                        ' left outer join '+dmData.ztSplitTransactions.TableName+' s on ch.transid = s.transid '+
                        ' left outer join '+dmData.ztCategory.TableName+' c2 on s.categid = c2.categid ';
          Groupby := 'category';
        end;
    end;

    dmData.zqReport.SQL.Add(
    ' select '+SelectField+', '+
    MainSelect +
    SelectJoin +
    TranscodeFilter +
    AccountFilter +
    TranDatefilter +
    ' group by '+Groupby+
    ' order by totamount desc '+
    RowFilter);
    dmData.zqReport.Active:=True;

    dmData.SpoolQueryToSQLSpy(dmData.zqReport);

    for i:= 1 to dmData.zqReport.RecordCount do
    begin;
//      AmountStr := FloatToStr(dmData.RoundEx(dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, DecimalPlaces));
      AmountStr := FloatToStr(dmData.RoundEx(dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, {fs.CurrencyDecimals}frMain.DecimalPlaces));
      AmountStr := frMain.CurrencySymbol+dmData.CurrencyStr2DP(AmountStr);

      if dmData.zqReport.fieldbyname('COLOUR').AsString <> '' then
        Colour := StringToColor(dmData.zqReport.fieldbyname('COLOUR').AsString)
      else
        Colour := dmData.GetRandomColour;

      frMain.lcsPieChartValues.Add(0, dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, dmData.zqReport.fieldbyname(Groupby).AsString, Colour);
      frMain.lcsPieLabels.Add(0, dmData.zqReport.fieldbyname('TOTAMOUNT').AsFloat, dmData.zqReport.fieldbyname(Groupby).AsString + ' '+ AmountStr, Colour);

      dmData.zqReport.Next;
    end;
  end;
  dmData.zqReport.Active:=False;
end;

procedure RunDefaultReport(LoadReportSettings : Boolean);
var ReportType : integer;
begin
  with frMain do
  begin
    lcsChartValues.Clear;
    lcsPieChartValues.Clear;
    lcsBottomAxisValues.Clear;
    lcsLeftAxisValues.Clear;
    dmData.zqReport.SQL.Clear;

    if LoadReportSettings then
    begin
      DefaultReportType := dmData.GetInfoSettingsInt('REPORTS_TYPE', 0);
      cbRepGroup.itemindex := dmData.GetInfoSettingsInt('REPORTS_FILTER', 0);
      cbItemLimit.itemindex := dmData.GetInfoSettingsInt('REPORTS_LIMIT', 0);
      cbRepAccounts.Text := dmData.GetInfoSettings('REPORTS_ACCOUNT', '[All Accounts]');

      ReportType := DefaultReportType;
  //    LastReportType := ReportType;
    end else
      ReportType := LastReportType;

    case ReportType of
      0 : bBarChartClick(nil);
      1 : bPieChartClick(nil);
    end;
  end;
end;

procedure SetupLeftAxisValues(ListChartSource, AxisChartSource : TListChartSource);
var i, x, y, divnumber, Mindivnumber : integer;
  ItemName, ItemValueStr, TempStr : string;
  ItemValue,AxisValue, MaxValue,MinValue : float;
begin
  MaxValue := 0;
  MinValue := 0;
  for i:= 0 to ListChartSource.DataPoints.Count-1 do
  begin
    ListChartSource.DataPoints.GetNameValue(i, ItemName, ItemValueStr);
    TempStr := ItemValueStr;
    x := pos('|', TempStr);
    delete(TempStr, 1, x);
    x := pos('|', TempStr);
    delete(TempStr, x, length(TempStr));
    ItemValue := StrToFloat(TempStr);
    if ItemValue > MaxValue then
      MaxValue := ItemValue;
    if ItemValue < MinValue then
      MinValue := ItemValue;
  end;

  AxisChartSource.Clear;

  if ListChartSource.DataPoints.Count > 0 then
    AxisChartSource.Add(0,0,frMain.CurrencySymbol+frMain.FullDecimalPlacesStr);

  if MaxValue > 2000 then
    divnumber := 1000
  else
    divnumber := 100;

  if MinValue < -2000 then
    Mindivnumber := -1000
  else
    Mindivnumber := -100;

  MaxValue := round(MaxValue) + divnumber;
  MinValue := round(MinValue) + Mindivnumber;

  x := round(MaxValue / divnumber);
  y := round(MinValue / Mindivnumber);

  for i := 1 to y do
  begin
    AxisValue := (i * Mindivnumber);
    AxisChartSource.Add(0,AxisValue,frMain.CurrencySymbol+FloatToStr(AxisValue)+'.00');
  end;

  for i := 1 to x do
  begin
    AxisValue := (i * divnumber);
    AxisChartSource.Add(0,AxisValue,frMain.CurrencySymbol+FloatToStr(AxisValue)+'.00');
  end;
end;

function SetupTransactionReport : Boolean;
var DateStr, DateFilterStr, AccountFilterStr: string;
begin
  AccountFilterStr := '';
  DateFilterStr := '';
  frReportFilter := TfrReportFilter.create(nil);
  //  frReportFilter := TfrReportFilter.create(self);
  if frReportFilter.Showmodal = mrOk then
    result := True
  else
    begin
      result := false;
      exit;
    end;
  AccountFilterStr := frReportFilter.AccountFilter;
  DateFilterStr := frReportFilter.DateFilter;
  frReportFilter.Free;

  dmData.zqTransactions.Active:= False;
  dmData.zqTransactions.SQL.Clear;
  DateStr := dmData.FormatDateSQL('transdate');
  dmData.zqTransactions.SQL.Add(
    ' select ch.transid, a.accountid, a.accountname, '+
    DateStr + ' frmtrandate, transdate, '+
    ' transactionnumber, payeename, ch.status, '+
    ' case s.transid when ch.transid then '+chr(39)+'...'+chr(39)+' else ' +
    ' case ch.categid when 0 then '+chr(39)+chr(39)+' else '+
    ' case ch.categid when -1 then '+chr(39)+chr(39)+
    ' else '+
    '   case ch.subcategid when -1 then categname '+
    '   else coalesce(categname,'+chr(39)+chr(39)+') ||'+chr(39)+': '+chr(39)+'||coalesce(subcategname,'+chr(39)+chr(39)+') '+
    '   end '+
    ' end end end as category, '+
    ' case transcode '+
    ' when ''Withdrawal'' then '+
    ' case when substr(transamount,length(ROUND(transamount,'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." then transamount || "0" '+
    ' when substr(transamount,length(ROUND(transamount,'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" then transamount || "'+frMain.DecimalPlacesStr+'" '+
    ' else transamount '+
    ' end '+
    ' else '+chr(39)+chr(39)+
    ' end as WITHDRAWAL, '+
    ' case transcode '+
    ' when ''Deposit'' then '+
    ' case when substr(transamount,length(ROUND(transamount,'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." then transamount || "0" '+
    ' when substr(transamount,length(ROUND(transamount,'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" then transamount || "'+frMain.DecimalPlacesStr+'" '+
    ' else transamount '+
    ' end '+
    ' else '+chr(39)+chr(39)+
    ' end as DEPOSIT, '+
    ' amount, '+
{    ' case when substr((select round(sum(amount), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid),length(ROUND((select round(sum(amount), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid),2))-1,1) = "." then (select round(sum(amount), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid) || "0" '+
    ' when substr((select round(sum(amount), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid),length(ROUND((select round(sum(amount), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid),2))-1,1) = "" then (select round(sum(amount), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid) || ".00" '+
    ' else (select round(sum(amount), 2) '+
    ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid) '+
    ' end as BALANCE, '+}
    //add accountfilter string here

    ' case when substr((select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), '+IntToStr(frmain.DecimalPlaces)+') '+
     ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid),length(ROUND((select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), '+IntToStr(frmain.DecimalPlaces)+') '+
     ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." '+
     ' then (select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), '+IntToStr(frmain.DecimalPlaces)+') '+
     ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid) || "0"  when substr((select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), '+IntToStr(frmain.DecimalPlaces)+') '+
     ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid),length(ROUND((select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), '+IntToStr(frmain.DecimalPlaces)+') '+
     ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" then (select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), '+IntToStr(frmain.DecimalPlaces)+') '+
     ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid) || "'+frMain.DecimalPlacesStr+'"  else (select round(sum(case transcode when ''Withdrawal'' then transamount * -1 '+
    ' else transamount end), '+IntToStr(frmain.DecimalPlaces)+') '+
     ' from '+dmData.ztCheckingAccount.TableName+' where accountid = ch.accountid and transid<=ch.transid) '+
     ' end as BALANCE, '+

    ' transcode,transamount, ch.notes '+
    ' from '+dmData.ztCheckingAccount.TableName+' ch'+
    ' inner join '+dmData.ztPayee.TableName+' p on ch.payeeid = p.payeeid '+
    ' inner join '+dmData.ztAccountList.TableName+' a on ch.accountid = a.accountid '+
    ' left outer join '+dmData.ztCategory.TableName+' c on ch.categid = c.categid '+
    ' left outer join '+dmData.ztSubCategory.TableName+' sc on c.categid = sc.categid and ch.subcategid = sc.subcategid '+
    ' left outer join '+dmData.ztSplitTransactions.TableName+' s on ch.transid = s.transid '+
    ' where 1 = 1 '+
    AccountFilterStr +
    DateFilterStr +
    ' group by ch.transid ' +
    ' order by ch.transid, transdate'
    );
  dmData.zqTransactions.ExecSQL;
  dmData.zqTransactions.Active:= True;
end;

procedure RunLazReport(Node : TTreeNode);
var ReportLocation, ReportName : string;
begin
  frMain.pcNavigation.ActivePageIndex := 0;

  if Node.Text = 'Transaction Report' then
  begin
    if SetupTransactionReport = false then exit;
    ReportName := 'transactions.lrf';
    dmData.frDBDataSet1.DataSet := dmData.zqTransactions;
    dmData.frDBDataSet1.DataSource := dmData.dszqTransactions;
  end else
  if Node.Text = 'Budget Performance' then
  begin

  end else
  if Node.Text = 'Budget Category Summary' then
  begin

  end else
  if Node.Text = 'Cash Flow' then
  begin

  end else
  if Node.Text = 'Summary of Accounts' then
  begin

  end else
  if Node.Text = 'Categories' then
  begin
    ReportName := 'categories.lrf';
    dmData.frDBDataSet1.DataSet := dmData.zqCategories;
    dmData.frDBDataSet1.DataSource := dmData.dsqCategories;
  end else
  if Node.Text = 'Payees' then
  begin
    ReportName := 'payees.lrf';
    dmData.frDBDataSet1.DataSet := dmData.ztPayee;
    dmData.frDBDataSet1.DataSource := dmData.dsPayee;
  end else
  if Node.Text = 'Assets' then
  begin
    ReportName := 'assets.lrf';
    dmData.frDBDataSet1.DataSet := dmData.zqAssets;
    dmData.frDBDataSet1.DataSource := dmData.dsqAssets;
  end;

  ReportLocation := ExtractFileDir(application.exename)+ReportsPath+ReportName;
  if FileExists(ReportLocation) then
  begin
    dmData.frReport1.LoadFromFile(ReportLocation);
    dmData.frReport1.ShowReport;
  end else
     MessageDlg(Node.Text+': No report found.',mtError, [mbOk], 0);

end;

procedure DoHomepageBarChart(QueryName : TZQuery; HomepageBarChart : TChart ; MarksSource, LeftAxis, BottomAxis : TListChartSource; ReportName, ReportType : string; GroupBy : integer);
begin
  with frMain do
  begin
    HomepageBarChart.BackColor:= StringToColor(dmData.GetInfoSettings('COLOURS_CHARTBACKGROUND', 'clBtnFace'));
    HomepageBarChart.Visible:= True;
    HomepageBarChart.Align:= alClient;
    BarChartBarSeries1.Active:= True;
{    PieChart.Visible:= False;
    PieChartPieSeries1.Active:= False;}
{    if assigned(Node.Parent) and (Node.Parent.Text <> 'Reports') then
      ReportTitleStr := Node.Parent.Text + ': ' + Node.Text + ' (' + cbRepAccounts.Text + ': ' + cbItemLimit.Text + ') '
    else
      ReportTitleStr := Node.Text + ' (' + cbRepAccounts.Text + ': ' + cbItemLimit.Text + ') ';}

    HomepageBarChart.Title.Text.Clear;
    HomepageBarChart.Title.Text.Add(ReportName);
    HomepageBarChart.Title.Visible:= True;
    HomepageBarChart.Title.Font.Color:= PieChart.Font.Color;
    HomepageBarChart.Title.Font.Style:=[fsUnderline, fsBold];

  end;
  SetupHomepageBarChartReportQuery(QueryName, HomepageBarChart, MarksSource, LeftAxis, BottomAxis, ReportName, ReportType, GroupBy);
//  SetupHomepageBarChartReportQuery(Node);
end;

function SetupHomepageBarChartTransactionFilter(ReportType : string) : string;
var TranscodeFilter : string;
begin
  if ReportType = 'Where the Money Goes' then
    TranscodeFilter := ' where transcode = ''Withdrawal'' '
  else
  if ReportType = 'Where the Money Comes From' then
    TranscodeFilter := ' where transcode = ''Deposit'' '
  else TranscodeFilter := ' where 1=1 ';

  Result := TranscodeFilter;
end;


procedure SetupHomepageBarChartReportQuery(QueryName : TZQuery; HomepageBarChart : TChart ; MarksSource, LeftAxis, BottomAxis : TListChartSource; ReportName, ReportType : string; GroupBy : integer);
var i : integer;
  AccountFilter, TranscodeFilter, TranDatefilter, RowFilter,
  SelectField, SelectJoin, AmountStr, MainSelect, GroupbyStr: string;
  Colour : TColor;
begin
  MarksSource.Clear;
  BottomAxis.Clear;
  LeftAxis.Clear;
  QueryName.SQL.Clear;

  {
  if dmData.ztAccountList.Locate('ACCOUNTNAME', frMain.cbRepAccounts.Text , [loCaseInsensitive]) = True then
    AccountFilter := ' and accountid = '+IntToStr(dmData.ztAccountList.fieldbyname('ACCOUNTID').AsInteger)
  else
    AccountFilter := '';

  with frMain do
  begin
    if cbItemLimit.Text = 'All Items' then RowFilter := '' else
    if cbItemLimit.Text = 'Top 10' then RowFilter := ' limit 10 ' else
    if cbItemLimit.Text = 'Top 20' then RowFilter := ' limit 20 ' else
    if cbItemLimit.Text = 'Top 30' then RowFilter := ' limit 30 ';
  end;
  dmData.zqReport.SQL.Clear;}

  TranscodeFilter := SetupHomepageBarChartTransactionFilter(ReportType);
  TranDatefilter := SetupReportDateFilter('Current Month');
  AccountFilter := '';
  RowFilter := ' limit 5 ';

  if ReportName = 'Income Vs Expenses' then
  begin
    QueryName.SQL.Add(
    ' select ''Expenses'' trantype,'+
    ' case when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." then COALESCE(SUM(transamount),0) || "0" '+
    ' when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" then COALESCE(SUM(transamount),0) || "'+frMain.DecimalPlacesStr+'" '+
    ' else COALESCE(SUM(transamount),0) '+
    ' end as totamount '+
    ' from '+dmData.ztCheckingAccount.TableName+' '+
    ' where transcode = ''Withdrawal'' '+
    TranDatefilter +
    AccountFilter +
    ' union  '+
    ' select ''Income'' trantype, '+
    ' case when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." then COALESCE(SUM(transamount),0) || "0" '+
    ' when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" then COALESCE(SUM(transamount),0) || "'+frMain.DecimalPlacesStr+'" '+
    ' else COALESCE(SUM(transamount),0) '+
    ' end as totamount '+
    ' from '+dmData.ztCheckingAccount.TableName+' '+
    ' where transcode = ''Deposit'' '+
    TranDatefilter +
    AccountFilter +
    ' order by totamount desc ');
    QueryName.Active:=True;

    dmData.SpoolQueryToSQLSpy(QueryName);

    for i:= 1 to QueryName.RecordCount do
    begin;
//      AmountStr := FloatToStr(dmData.RoundEx(QueryName.fieldbyname('TOTAMOUNT').AsFloat, DecimalPlaces));
      AmountStr := FloatToStr(dmData.RoundEx(QueryName.fieldbyname('TOTAMOUNT').AsFloat,  {fs.CurrencyDecimals}frMain.DecimalPlaces));
      AmountStr := frMain.CurrencySymbol+dmData.CurrencyStr2DP(AmountStr);

      if QueryName.fieldbyname('trantype').AsString = 'Expenses' then
        Colour := StringToColor(dmdata.GetInfoSettings('COLOURS_EXPENSES', 'clRed')) else
      if QueryName.fieldbyname('trantype').AsString = 'Income' then Colour := StringToColor(dmdata.GetInfoSettings('COLOURS_INCOME', 'clBlue')) else
        Colour := dmData.GetRandomColour;

      MarksSource.Add(i, QueryName.fieldbyname('TOTAMOUNT').AsFloat, AmountStr, Colour);
      BottomAxis.Add(i, QueryName.fieldbyname('TOTAMOUNT').AsFloat, QueryName.fieldbyname('trantype').AsString, Colour);
      QueryName.Next;
    end;
  end else
  if (ReportType = 'Where the Money Goes') or (ReportType = 'Where the Money Comes From') then
  begin
    case GroupBy of
    0 : begin
          SelectField := 'payeename';
          MainSelect :=
          ' case when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." then COALESCE(SUM(transamount),0) || "0" '+
          ' when substr(COALESCE(SUM(transamount),0),length(ROUND(COALESCE(SUM(transamount),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" '+
          ' then COALESCE(SUM(transamount),0) || "'+frMain.DecimalPlacesStr+'"  else COALESCE(SUM(transamount),0) end as TOTAMOUNT, p.colour, '+
          ' count(*) CNT ' +
          ' from '+dmData.ztCheckingAccount.TableName+' ch ';
          SelectJoin := ' inner join '+dmData.ztPayee.TableName+' p on ch.payeeid = p.payeeid ';
          GroupbyStr := 'payeename';
        end;
    1 : begin
          SelectField := ' case s.transid when ch.transid then c2.categname else '+
                         ' case ch.categid when 0 then ''N/A'' else '+
                         ' case ch.categid when -1 then ''N/A'' else c.categname '+
                         ' end end end as category ';
          MainSelect :=
          ' case when substr(COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0),length(ROUND(COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "." '+
          '  then COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0) || "0" '+
          '  when substr(COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0),length(ROUND(COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0),'+IntToStr(frmain.DecimalPlaces)+'))-1,1) = "" '+
          '  then COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0) || "'+frMain.DecimalPlacesStr+'"  else COALESCE(SUM(case s.transid when ch.transid then s.splittransamount else ch.transamount '+
          ' end),0) end as TOTAMOUNT,  '+
          ' case ch.categid when -1 then c2.colour else c.colour end as colour '+
          ' from '+dmData.ztCheckingAccount.TableName+' ch ';

          SelectJoin := ' left outer join '+dmData.ztCategory.TableName+' c on ch.categid = c.categid '+
                        ' left outer join '+dmData.ztSplitTransactions.Tablename+' s on ch.transid = s.transid '+
                        ' left outer join '+dmData.ztCategory.TableName+' c2 on s.categid = c2.categid ';
          GroupbyStr := 'category';
        end;
    end;

    QueryName.SQL.Add(
    ' select '+SelectField+', '+
    MainSelect +
    SelectJoin +
    TranscodeFilter +
    AccountFilter +
    TranDatefilter +
    ' group by '+GroupbyStr +
    ' order by totamount desc '+
    RowFilter);
    QueryName.Active:=True;

    dmData.SpoolQueryToSQLSpy(QueryName);

    for i:= 1 to QueryName.RecordCount do
    begin;
//      AmountStr := FloatToStr(dmData.RoundEx(QueryName.fieldbyname('TOTAMOUNT').AsFloat, DecimalPlaces));
      AmountStr := FloatToStr(dmData.RoundEx(QueryName.fieldbyname('TOTAMOUNT').AsFloat, {fs.CurrencyDecimals}frMain.DecimalPlaces));
      AmountStr := frMain.CurrencySymbol+dmData.CurrencyStr2DP(AmountStr);
      if QueryName.fieldbyname('COLOUR').AsString <> '' then
        Colour := StringToColor(QueryName.fieldbyname('COLOUR').AsString)
      else
        Colour := dmData.GetRandomColour;

      MarksSource.Add(i, QueryName.fieldbyname('TOTAMOUNT').AsFloat, AmountStr, Colour);
      BottomAxis.Add(i, QueryName.fieldbyname('TOTAMOUNT').AsFloat, QueryName.fieldbyname(GroupbyStr).AsString, Colour);
      QueryName.Next;
    end;
  end;
  QueryName.Active:=False;

  SetupLeftAxisValues(MarksSource, LeftAxis);
end;

end.

