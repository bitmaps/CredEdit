{ To do list:

1. Change asset type to an external table with user configurable items.
2. Change percentage rate to a numeric dial component.
3. Fix bug with null date, set focus on dateedit rather than save todays date

}
unit uAsset;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, DbCtrls, {maskedit,} Spin, ExtCtrls;

type

  { TfrAsset }

  TfrAsset = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    cbAssetType: TComboBox;
    cbChangeInValue: TComboBox;
    deDate: TDateEdit;
    eValue: TEdit;
    eName: TDBEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    mNotes: TDBMemo;
    pBottom: TPanel;
    sePercentageRate: TSpinEdit;
    procedure cbChangeInValueChange(Sender: TObject);
    procedure cbChangeInValueExit(Sender: TObject);
    procedure eValueExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    EditMode : string;
  end;

var
  frAsset: TfrAsset;

implementation

{$R *.lfm}

uses uDataModule;

{ TfrAsset }

procedure TfrAsset.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if modalresult = mrOk then
  begin
    if eName.Text = '' then
    begin
      canclose := False;
      eName.SetFocus;
      exit;
    end;
    if eValue.Text = '' then
    begin
      canclose := False;
      eValue.SetFocus;
      exit;
    end;
    if deDate.Text = '' then
    begin
      canclose := False;
      deDate.SetFocus;
      exit;
    end;

    if not sePercentageRate.ReadOnly then
      dmData.ztAssets.FieldByName('VALUECHANGERATE').AsInteger := sePercentageRate.Value;

    dmData.ztAssets.FieldByName('VALUE').AsCurrency := dmData.CurrencyEditToFloat(eValue);
//    dmData.ztAssets.FieldByName('STARTDATE').AsString := FormatDateTime('YYYY/MM/DD',deDate.Date);
    dmData.ztAssets.FieldByName('STARTDATE').AsString := FormatDateTime('YYYY-MM-DD',deDate.Date);
    dmData.ztAssets.FieldByName('ASSETTYPE').AsString := frAsset.cbAssetType.Text;
    dmData.ztAssets.FieldByName('VALUECHANGE').AsString := frAsset.cbChangeInValue.Text;
  end;
end;


procedure TfrAsset.cbChangeInValueChange(Sender: TObject);
begin
  sePercentageRate.ReadOnly := (cbChangeInValue.text = 'None');
  sePercentageRate.Enabled := not sePercentageRate.ReadOnly;
end;

procedure TfrAsset.cbChangeInValueExit(Sender: TObject);
begin
  sePercentageRate.ReadOnly := (cbChangeInValue.text = 'None');
  sePercentageRate.Enabled := not sePercentageRate.ReadOnly;
end;

procedure TfrAsset.eValueExit(Sender: TObject);
begin
  dmData.DisplayCurrencyEdit(eValue);
end;

procedure TfrAsset.FormShow(Sender: TObject);
begin
  if EditMode = 'Edit' then
     frAsset.Caption:= 'Editing Asset'
  else
  if EditMode = 'Insert' then
     frAsset.Caption:= 'New Asset';

  eName.SetFocus;
  eValue.Text:= floatToStr(dmData.ztAssets.FieldByName('VALUE').AsCurrency);
  dmData.DisplayCurrencyEdit(eValue);

  frAsset.cbAssetType.Text := dmData.ztAssets.FieldByName('ASSETTYPE').AsString;
  frAsset.cbChangeInValue.Text := dmData.ztAssets.FieldByName('VALUECHANGE').AsString;
  sePercentageRate.Value := dmData.ztAssets.FieldByName('VALUECHANGERATE').AsInteger;

  sePercentageRate.ReadOnly := (cbChangeInValue.text = 'None');
  sePercentageRate.Enabled := not sePercentageRate.ReadOnly;
end;

end.

