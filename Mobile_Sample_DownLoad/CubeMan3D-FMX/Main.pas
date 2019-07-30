unit Main;

{
  Firemonkey Mobile version of CubeMan3D (c)2014 Execute SARL
  http://www.execute.re

  see http://cc.embarcadero.com/Item/29684 for a native API version


}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms3D, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Objects3D, FMX.Controls3D, FMX.MaterialSources, FMX.Ani,
  System.Math.Vectors, FMX.Types3D;

type
  TForm1 = class(TForm3D)
    body: TRoundCube;
    LightMaterialSource1: TLightMaterialSource;
    Light1: TLight;
    head: TRoundCube;
    Arm2: TRoundCube;
    Forearm2: TRoundCube;
    Shoulder2: TDummy;
    Elbow2: TDummy;
    Shoulder1: TDummy;
    Arm1: TRoundCube;
    Elbow1: TDummy;
    Forearm1: TRoundCube;
    Pelvis1: TDummy;
    Thigh1: TRoundCube;
    Knee1: TDummy;
    Leg1: TRoundCube;
    Pelvis2: TDummy;
    Thigh2: TRoundCube;
    Knee2: TDummy;
    Leg2: TRoundCube;
    Arm2Animation: TFloatAnimation;
    TurnAround: TFloatAnimation;
    Arm1Animation: TFloatAnimation;
    Thigh1Animation: TFloatAnimation;
    Thigh2Animation: TFloatAnimation;
    Leg2Animation: TFloatAnimation;
    Forearm2Animation: TFloatAnimation;
    Forearm1Animation: TFloatAnimation;
    Leg1Animation: TFloatAnimation;
    procedure LegsAnimationFinish(Sender: TObject);
  private
    { D?larations priv?s }
  public
    { D?larations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.LegsAnimationFinish(Sender: TObject);
var
  Leg: TFloatAnimation;
begin
  Leg := TFloatAnimation(Sender);
  if Leg.Tag = 0 then
  begin
    Leg.Delay := 0;
    Leg.StartValue := 120;
    Leg.StopValue := 0;
    Leg.Tag := 1;
  end else begin
    Leg.Delay := 1;
    Leg.StartValue := 0;
    Leg.StopValue := 120;
    Leg.Tag := 0;
  end;
  Leg.Start;
end;

end.
