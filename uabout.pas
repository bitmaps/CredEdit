{
1. Add product info
http://wiki.lazarus.freepascal.org/Show_Application_Title,_Version,_and_Company
2. Add an acknowledgement , components used etc

}

unit uAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, windows {fileinfo, winpeimagereader, elfreader, machoreader};

type

  { TfrAbout }

  TfrAbout = class(TForm)
    bClose: TButton;
    GroupBox1: TGroupBox;
    Image1: TImage;
    lbFileDate: TLabel;
    lbProductName: TLabel;
    lbProductVersion: TLabel;
    lbZeosVersion: TLabel;
    lbWebsite: TLabel;
    lbWebsiteURL: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    pBottom: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure bCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function GetFileVersion(filename:string=''): String;
    procedure Image1Click(Sender: TObject);
    procedure lbWebsiteURLClick(Sender: TObject);
    procedure lbWebsiteURLMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frAbout: TfrAbout;

implementation

{$R *.lfm}

uses uDataModule;

{ TfrAbout }

function TfrAbout.GetFileVersion(filename:string): String;
var
  my :record
    Dummy: DWord;
    VerInfo: Pointer;
    VerInfoSize: DWord;
    VerValueSize: DWord;
    VerValue:  PVSFixedFileInfo;
    end;
begin
  Result:='';
  my.Dummy:=0; // to keep the compiler happy
  if filename='' then filename:=ParamStr(0);
  my.VerInfoSize := GetFileVersionInfoSize(PChar(filename), my.Dummy);
  if my.VerInfoSize=0 then
     exit;
  GetMem(my.VerInfo, my.VerInfoSize);
  GetFileVersionInfo(PChar(filename), 0, my.VerInfoSize, my.VerInfo);
  VerQueryValue(my.VerInfo, '\', Pointer(my.VerValue), my.VerValueSize);
  with my.VerValue^ do  begin
     result := IntTostr(dwFileVersionMS shr 16);
     result := result+'.'+   IntTostr(dwFileVersionMS and $FFFF);
     result := result+'.'+   IntTostr(dwFileVersionLS shr 16);
     result := result+'.'+   IntTostr(dwFileVersionLS and $FFFF);
  end;
  FreeMem(my.VerInfo, my.VerInfoSize);
end;

procedure TfrAbout.Image1Click(Sender: TObject);
begin

end;

procedure TfrAbout.lbWebsiteURLClick(Sender: TObject);
begin
  ShellExecute(0,nil, PChar(lbWebsiteURL.Caption),PChar(lbWebsiteURL.Caption),nil,0);
end;

procedure TfrAbout.lbWebsiteURLMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if lbWebsiteURL.MouseEntered then
    lbWebsiteURL.Cursor:=crHandPoint
  else
    lbWebsiteURL.Cursor:=crDefault;
end;

procedure TfrAbout.bCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrAbout.FormCreate(Sender: TObject);
begin
  lbWebsiteURL.Caption:= Homepage;
  lbProductName.Caption := ApplicationName ;
  lbProductVersion.Caption := 'Version #: ' + GetFileVersion(application.exename) ;
  lbFileDate.Caption := 'Date : ' + DateTimeToStr(FileDateToDateTime(FileAge(Application.ExeName)));
  lbZeosVersion.Caption:= 'ZeosLib Version #: ' +dmdata.zcDatabaseConnection.Version;
end;

end.

