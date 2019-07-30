{
  ******************************************************************************
  FileManager2 for Android
  Autor: Andrey Yefimov (Contact: http://delphifmandroid.blogspot.ru/)
  Use only non-commercial purposes. Necessarily indicating the authorship.
  ����������� ������ � �������������� �����. ����������� � ��������� ���������.
  ******************************************************************************
}

unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListBox, FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Edit, FMX.Effects;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    Label1: TLabel;
    ToolBar1: TToolBar;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    ImageBook: TStyleBook;
    SpeedButton4: TSpeedButton;
    Image1: TImage;
    StyleBook1: TStyleBook;
    Image2: TImage;
    Dialog: TRectangle;
    ToolBar2: TToolBar;
    Layout1: TLayout;
    DialogEdit: TEdit;
    DialogTitle: TLabel;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    ShadowEffect1: TShadowEffect;
    DialogFon: TRectangle;
    DialogError: TLabel;
    SpeedButton7: TSpeedButton;
    Image3: TImage;
    SpeedButton8: TSpeedButton;
    ToolBar3: TToolBar;
    Image4: TImage;
    SpeedButton9: TSpeedButton;
    Image5: TImage;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1ItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure ListBox1ChangeCheck(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure DialogEditChangeTracking(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
  private
    procedure AddListItem(list: array of string; itype: string);
    procedure TotalWork(path_tr: string; clear: boolean);
    procedure OnOffButton(del, add, copy, cut: boolean);
    { Private declarations }
  public
    function GetImage(const AImageName: string): TBitmap;
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.IOUtils, System.Generics.Collections, Generics.Defaults,
  FMX.Helpers.Android, Androidapi.JNI.JavaTypes,
  Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.Webkit;

var
  path: string; // ����� ����� ������� ����
  ItemsCheck: array of array of string; // ������ � ����������� ��������

function CompareLowerStr(const Left, Right: string): Integer;
begin
  Result := CompareStr(AnsiLowerCase(Left), AnsiLowerCase(Right));
end;

{������� ��������� �������� �� ImageBook'�(�����: ������� ������)}
function TForm1.GetImage(const AImageName: string): TBitmap;
var
  StyleObject: TFmxObject;
  Image: TImage;
begin
  StyleObject := ImageBook.Style.FindStyleResource(AImageName);
  if (StyleObject <> nil) and (StyleObject is TImage) then
  begin
    Image := StyleObject as TImage;
    // ����� �� ������� �������� ������� dpi (Scale)
    Result := Image.Bitmap;
  end
  else
    Result := nil;
end;

{��������� ��� ������� �������� � ListBox}
procedure TForm1.AddListItem(list: array of string; itype: string);
var
  c: integer;
  LItem: TListBoxItem;
  BitmapFolder, BitmapFile: TBitmap;
begin

  BitmapFolder := GetImage('folder');
  BitmapFile := GetImage('file');

  ListBox1.BeginUpdate;

  for c := 0 to Length(list) - 1 do
  begin

    LItem := TListBoxItem.Create(ListBox1);

    if itype = 'folder' then
    begin
      if BitmapFolder <> nil then
      begin
        LItem.ItemData.Bitmap.Assign(BitmapFolder);
      end;
    end
    else
    begin
      if BitmapFile <> nil then begin
        LItem.ItemData.Bitmap.Assign(BitmapFile);
      end;
    end;

    LItem.ItemData.Text := ExtractFileName(list[c]);
    LItem.ItemData.Detail := list[c]; // �������� ������ ���� � Detail
    LItem.TagString := itype;
    ListBox1.AddObject(LItem);

  end;

  ListBox1.EndUpdate;

end;

{������� ��� �������� ��������� �����}
function CheckName(NewName: string): Boolean;
const
  InvalidChars: Array[0..9] of Char = ('\', '/', ':', '*', '?', '"', '<', '>', '|', '~');
var
  LengthName, i, j: integer;
begin

  Result := False;

  LengthName := Length(NewName);

  if LengthName <> 0 then
  begin
    for i := 0 to LengthName - 1 do
    begin
      for j := 0 to 9 do
      begin
        if NewName[i] = InvalidChars[j] then
        begin
          Result := True;
        end;
      end;
    end;
  end;

end;

{����������� ���� �������� � ��������� ��}
procedure TForm1.DialogEditChangeTracking(Sender: TObject);
begin
  if CheckName(DialogEdit.Text) then
    DialogError.Text := '������������� \ / : * ? " < > | ~'
  else
    DialogError.Text := '';
end;

{��������� ������ ������ � ����� ����������}
procedure TForm1.FormCreate(Sender: TObject);
begin
  // ������ ����������
  path := '/';

  TotalWork(path, False);
end;

{������������ ������ Hardware Back, Enter}
procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if Dialog.Visible = False then
  begin

    if (Key = vkHardwareBack) AND (path <> '/') then
    begin
      SpeedButton1Click(Self); // �������� ������ �����
      Key := 0;
    end;

  end
  else
  begin
    if Key = vkHardwareBack then
    begin
      SpeedButton5Click(Self); // �������� ������ ������
      Key := 0;
    end;

    if Key = 13 then
    begin
      SpeedButton6Click(Self); // �������� ������ �������
    end;
  end;
end;

{����� �������� ������}
procedure TForm1.ListBox1ChangeCheck(Sender: TObject);
var
  i: integer;
begin
  SetLength(ItemsCheck, 0, 0);

  for i := 0 to ListBox1.Count-1 do
  begin

    if ListBox1.ListItems[i].IsChecked then
    begin
      SetLength(ItemsCheck, i + 1, 3);
      ItemsCheck[i][0] := ListBox1.ListItems[i].Text; // ���
      ItemsCheck[i][1] := ListBox1.ListItems[i].TagString; // ���
      ItemsCheck[i][2] := ListBox1.ListItems[i].ItemData.Detail; // ����
    end;

  end;

  if Length(ItemsCheck) <> 0 then begin
    OnOffButton(True, False, True, True);
  end
  else begin
    OnOffButton(False, False, False, False);
  end;

end;

{���� �� Item'�, �����}
procedure TForm1.ListBox1ItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
var
  FileName, ExtFile: string;
  mime: JMimeTypeMap;
  ExtToMime: JString;
  Intent: JIntent;
begin

  if Length(ItemsCheck) <> 0 then begin
    OnOffButton(False, True, False, False);
  end
  else begin
    OnOffButton(False, False, False, False);
  end;

  if Item.TagString = 'folder' then
  begin

    // ��������� ��������� ����
    path := Item.ItemData.Detail;

    if TDirectory.Exists(path) then
    begin
      TotalWork(path, True);
    end
    else
    begin
      ListBox1.Items.Delete(Item.Index);
      ShowMessage('����� �� �������');
    end;
  end
  else if Item.TagString = 'file' then
  begin

    // �������� ���� �� �����
    FileName := Item.ItemData.Detail;

    try
      //���������� ���������� ����� � ��� mime ���
      ExtFile := AnsiLowerCase(StringReplace(TPath.GetExtension(FileName), '.', '',[]));
      mime := TJMimeTypeMap.JavaClass.getSingleton();
      ExtToMime := mime.getMimeTypeFromExtension(StringToJString(ExtFile));

      //����������� �������� �����
      Intent := TJIntent.Create;
      Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
      Intent.setDataAndType(StrToJURI('file:' + FileName), ExtToMime);
      SharedActivity.startActivity(Intent);
    except
      ShowMessage('���������� ������� ����!');
    end;
  end;
end;

{��������� ��������}
procedure TForm1.OnOffButton(del, add, copy, cut: boolean);
begin
    SpeedButton2.Enabled := del; // ������ ��������
    SpeedButton7.Enabled := add; // ������ ��������
    SpeedButton8.Enabled := copy; // ������ ����������
    SpeedButton9.Enabled := cut; // ������ ��������
end;

{������ �����}
procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  // ���������� ���������� �����
  path := ExtractFileDir(path);

  if path = '/' then path := '/'
  else path := path;

  TotalWork(path, True);

  if Length(ItemsCheck) <> 0 then begin
    OnOffButton(False, True, False, False);
  end
  else begin
    OnOffButton(False, False, False, False);
  end;
end;

{������ �������}
procedure TForm1.SpeedButton2Click(Sender: TObject);
var
  i: integer; // ������������� �������
  LItemPath: string;
  msg: integer;
begin
  msg := MessageDlg('������� ��������� �����?', System.UITypes.TMsgDlgType.mtConfirmation,
  [
    System.UITypes.TMsgDlgBtn.mbYes,
    System.UITypes.TMsgDlgBtn.mbNo
  ], 0);

  if msg = mrYes then
  begin

    for i := 0 to Length(ItemsCheck) - 1 do
    begin

      if ItemsCheck[i][0] <> '' then
      begin
        // �������� ���� �� �������
        LItemPath := ItemsCheck[i][2];

        if ItemsCheck[i][1] = 'folder' then begin

          if TDirectory.Exists(LItemPath) then
          begin
            TDirectory.Delete(LItemPath, True); // ������� ����� � ��������
          end;

        end
        else if ItemsCheck[i][1] = 'file' then begin

          if TFile.Exists(LItemPath) then
          begin
            TFile.Delete(LItemPath); // ������� ����
          end;

        end;
      end;
    end;
    TotalWork(path, True); // ��������� ������
    ListBox1ChangeCheck(Self); // ������ ������ � �.�.
  end;
end;

{������ ��� �������� ����� - ������� ���� ��� ����� ����� �����}
procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
  DialogTitle.Text := '������� ��� �����';
  DialogEdit.TagString := 'CreateFile';
  DialogFon.Visible := True;
  Dialog.Visible := True;
end;

{������ ��� �������� ����� - ������� ���� ��� ����� ����� �����}
procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  DialogTitle.Text := '������� ��� �����';
  DialogEdit.TagString := 'CreateFolder';
  DialogFon.Visible := True;
  Dialog.Visible := True;
end;

{��������� ���� - ������ ������ - "���������" ����}
procedure TForm1.SpeedButton5Click(Sender: TObject);
begin
  DialogEdit.Text := '';
  DialogError.Text := '';
  Dialog.Visible := False;
  DialogFon.Visible := False;
end;

{��������� ���� - ������ ������� - ������ ����� ��� ����}
procedure TForm1.SpeedButton6Click(Sender: TObject);
var
  newpath: string;
  newfile: TFileStream;
begin

  if (Length(DialogEdit.Text) = 0) OR (DialogEdit.Text = ' ') then begin
    DialogError.Text := '������� ���!';
    Exit;
  end;

  newpath := path + PathDelim + DialogEdit.Text;

  if DialogEdit.TagString = 'CreateFile' then
  begin
    if TFile.Exists(newpath) then begin
      ShowMessage('���� ����������!');
    end
    else begin
      newfile := TFile.Create(newpath); // ������ ����(�����)
      newfile.Free; // ������� �����
      SpeedButton5Click(Self); // ��������� ����
      TotalWork(path, True); // ��������� ������
    end;
  end
  else if DialogEdit.TagString = 'CreateFolder' then
  begin
    if TDirectory.Exists(newpath) then begin
      ShowMessage('����� ����������!');
    end
    else begin
      TDirectory.CreateDirectory(newpath); // ������ �����
      SpeedButton5Click(Self); // ��������� ����
      TotalWork(path, True); // ��������� ������
    end;
  end;
end;

{������ ��������}
procedure TForm1.SpeedButton7Click(Sender: TObject);
var
  i: integer; // ������������� �������
  LItemPath: string; // ������ ���� �� ����� ��� �����
begin

  for i := 0 to Length(ItemsCheck) - 1 do
  begin

    if ItemsCheck[i][0]<>'' then
    begin
      // �������� ���� �� �������
      LItemPath := ItemsCheck[i][2];

      if ItemsCheck[i][1] = 'folder' then begin
        try
          if SpeedButton9.Tag <> 1 then begin
            TDirectory.Copy(LItemPath, path + PathDelim + ItemsCheck[i][0]); // �������� �����
          end
          else begin
            TDirectory.Move(LItemPath, path + PathDelim + ItemsCheck[i][0]); // ���������� �����
          end;
        except
          ShowMessage('����������� ����� ' + ItemsCheck[i][0] + ' �� ��������!');
        end;
      end
      else if ItemsCheck[i][1] = 'file' then begin
        try
          if SpeedButton9.Tag <> 1 then begin
            TFile.Copy(LItemPath, path + PathDelim + ItemsCheck[i][0], True); // �������� ����
          end
          else begin
            TFile.Move(LItemPath, path + PathDelim + ItemsCheck[i][0]); // ���������� ����
          end;
        except
          ShowMessage('����������� ����� ' + ItemsCheck[i][0] + ' �� ��������!');
        end;
      end;
    end;
  end;
  SpeedButton9.Tag := 0;
  TotalWork(path, True); // ��������� ������
  ListBox1ChangeCheck(Self); // ������ ������ � �.�.
end;

{������ ����������}
procedure TForm1.SpeedButton8Click(Sender: TObject);
begin
  if Length(ItemsCheck) <> 0 then
  begin
    ShowMessage('����������� � �����, ��������� � ������ ����� ��� ������� ��������');
  end;
end;

{������ ��������/����������}
procedure TForm1.SpeedButton9Click(Sender: TObject);
begin
  if Length(ItemsCheck) <> 0 then
  begin
    SpeedButton9.Tag := 1;
    ShowMessage('�������� � �����, ��������� � ������ ����� ��� ������� ��������');
  end;
end;

{������ ��� ��������� ����������� �� ������}
procedure TForm1.TotalWork(path_tr: string; clear: boolean);
var
  folders, files: TStringDynArray;
begin

  // ������� ������� ����
  Label1.Text := path_tr;

//*****�����*****
  // ���� �����
  folders := TDirectory.GetDirectories(path_tr);

  // ��������� �����
  TArray.Sort<String>(folders, TComparer<String>.Construct(CompareLowerStr));

  if clear then begin
    // ������� ��������
    ListBox1.Clear;
  end;

  // ��������� �������� ������� ��������������� �����
  AddListItem(folders, 'folder');
//***************

//*****�����*****
  // ���� �����
  files := TDirectory.GetFiles(path_tr);

  // ��������� �����
  TArray.Sort<String>(files, TComparer<String>.Construct(CompareLowerStr));

  // ��������� �������� ������� ��������������� ������
  AddListItem(files, 'file');
//***************

end;

end.
