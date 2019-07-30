unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.Objects, FMX.StdCtrls, FMX.Edit,
  IdHTTP, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  FMX.Controls.Presentation;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    NoThredDown_bt: TButton;
    URLEdit: TEdit;
    ProgressBar1: TProgressBar;
    DownImage: TImage;
    Layout1: TLayout;
    FileNameEdit: TEdit;
    SpeedButton1: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Pie1: TPie;
    Circle1: TCircle;
    RateText: TText;
    AniIndicator1: TAniIndicator;
    procedure NoThredDown_btClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    procedure FilePositionChange(Sender: TObject; OldPos, NewPos: integer);
  public
     ResPath : string;
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  ImpFileStream;

{$R *.fmx}


//----------------------------------------------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
begin
  {$IFDEF IOS}
  ResPath := GetHomePath() + PathDelim + 'Library' + PathDelim;    //  StartUp\Library
  {$ELSE}
     {$IFDEF ANDROID}
       ResPath := GetHomePath() + PathDelim;                        // .\assets\internal
     {$ELSE}
       ResPath := '..\..\_Data\';
     {$ENDIF}
  {$ENDIF}

  Pie1.Opacity := 0;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  DownImage.Bitmap.Clear( $FFFFFF );
  ProgressBar1.Value := 0;
  Pie1.EndAngle := -90;
  Pie1.StartAngle := -90;
  Pie1.Opacity := 0.0;
  Label1.Text := '0 Bytes';
end;

//**********************************************************************
procedure TForm1.NoThredDown_btClick(Sender: TObject);
var
  i : integer;
  mHTTP: TIdHTTP;
  SaveFile, URL : string;
  fsSource : TImpFileStream; // TFileStream;

begin
  SpeedButton1Click( Sender );

  SaveFile := ResPath + FileNameEdit.Text;
  URL := URLEdit.Text + FileNameEdit.Text;

  if FileExists( SaveFile ) then
     fsSource := TImpFileStream.Create( SaveFile, fmOpenWrite )
  else
     fsSource := TImpFileStream.Create( SaveFile, fmCreate );

  try
    //-----------------------------------------------------
    fsSource.OnPositionChange := FilePositionChange;
    if fsSource.Size = 0 then  ProgressBar1.Max := 3454761        // ���� ���� �ٿ�ε�ô� �ܸ��⿡���� ���ϻ����� �𸣹Ƿ� ���������� �˷� �����.
    else                       ProgressBar1.Max := fsSource.Size; // ���������� �����Ƿ� ������ �˰� ����.
    ProgressBar1.Value := 0;

    Pie1.Opacity := 0.6;
    Pie1.EndAngle := -90;
    Pie1.StartAngle := -90;
    //-----------------------------------------------------

    mHTTP := TIdHTTP.Create(nil);
    mHttp.Get( URL, fsSource );       // �ٿ�޾� ���� ����
  finally
    fsSource.Free;
    mHTTP.Free;

// �ٿ���� ���� �ҷ���.
// �ܸ��⿡ ���� �����̹�����(2000��ȭ�ұ� ���ػ�)�� ��������� ȭ�鿡�� �ε�������.

//  DownImage.MultiResBitmap.Items[0].Bitmap.LoadThumbnailFromFile( SaveFile, DownImage.Width, DownImage.Height ); // �̷����� �泻�Ϸ� ǥ���Ҽ� ����. ���� 600�� ȭ�������� �ε�����
    DownImage.MultiResBitmap.Items[0].Bitmap.LoadFromFile( SaveFile ); // ����ũ��(?)�� ȭ��ǥ�ð���
  end;
end;

//------------------------------------------------------------------------------
procedure TForm1.FilePositionChange(Sender: TObject; OldPos, NewPos: integer);
var
  rate : single;
begin
  ProgressBar1.Value := NewPos;
  Label1.Text := IntToStr( NewPos ) + ' Bytes';

  // ���̱׷��� ǥ�� --------------------------------------------------
  Pie1.EndAngle := 360 * NewPos / ProgressBar1.Max + Pie1.StartAngle;
  rate := ( Pie1.EndAngle - Pie1.StartAngle ) * 100 / 360;
  RateText.Text := Format( '%.0f' , [rate] ) + '%';

  if rate >= 100 then Pie1.AnimateFloatDelay( 'Opacity', 0.0, 1.5, 1.0 ); // �����ְ� �����.

  Application.ProcessMessages;
end;



end.
