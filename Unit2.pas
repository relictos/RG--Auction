unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Core,Unit1;

type
  TForm2 = class(TForm)
    Elogin: TEdit;
    Epass: TEdit;
    BConnect: TButton;
    CBRealm: TComboBox;
    procedure BConnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}


procedure TForm2.BConnectClick(Sender: TObject);
begin
 if not ConCheck then exit;
 BConnect.Enabled := false;
 if (LoginExist(Elogin.Text)) and (PassExist(Elogin.Text, Epass.Text)) then
  begin
   Self.hide;
   if Form1 <> nil then
    begin
     ShowMessage('aaaaa');
     Form1.Free;
    end;
   Application.CreateForm(TForm1, Form1);
   Form1.LAcName.Caption := Elogin.Text;
  end
  else
   begin
    ShowMEssage('Неверно введен логин или пароль');
   end;
  BConnect.Enabled := true; 
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
 CBREalm.Items :=  LoadRealms;
 CBRealm.ItemIndex := 0;
 if CBRealm.Items[0] = '' then
  begin
   ShowMessage('Ошибка чтения списка миров!');
   Form2.Close;
  end;
 Self.Visible := true;
end;

end.
