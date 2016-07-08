unit uProgressBar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls;

type

  { TfrProgressBar }

  TfrProgressBar = class(TForm)
    GroupBox1: TGroupBox;
    ProgressBar: TProgressBar;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure SetupProgressBar(MaxValue, StepValue : integer);
    procedure StepProgressBar;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frProgressBar: TfrProgressBar;

implementation

{$R *.lfm}


procedure TfrProgressBar.SetupProgressBar(MaxValue, StepValue : integer);
begin
  try
    frProgressBar := TfrProgressBar.create(self);
    frProgressBar.ProgressBar.Max:= MaxValue;
    frProgressBar.ProgressBar.Step := StepValue;
    frProgressBar.Timer1.Enabled:= True;
    frProgressBar.Showmodal;
  finally
    frProgressBar.Free;
  end;
end;

procedure TfrProgressBar.StepProgressBar;
begin
  frProgressBar.ProgressBar.StepIt;
end;

procedure TfrProgressBar.Timer1Timer(Sender: TObject);
begin
  if frProgressBar.ProgressBar.Position = frProgressBar.ProgressBar.Max then frProgressBar.close;
end;



end.

