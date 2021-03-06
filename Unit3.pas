unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, BSMorphButton, ComCtrls, Core, Auction,ZDataSet, jpeg,
  ExtCtrls;

type
  TFChoseItem = class(TForm)
    REDescr: TRichEdit;
    LBItems: TListBox;
    EItemName: TEdit;
    BMSearch: TBSMorphButton;
    BMChose: TBSMorphButton;
    Label1: TLabel;
    Image1: TImage;
    procedure BMSearchClick(Sender: TObject);
    procedure LBItemsClick(Sender: TObject);
    procedure BMChoseClick(Sender: TObject);
    procedure LBItemsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FChoseItem: TFChoseItem;
  Chosen : array of TItem;

implementation

uses
 Unit1;
 
{$R *.dfm}

procedure TFChoseItem.BMSearchClick(Sender: TObject);
label
 after;
var
 itemq : TZQuery;
 i : integer;
begin
 if (not ConCheck) or (Length(EItemName.Text)<3) then
  begin
   ShowMessage('��������� ������'+#13+'���������� ������ ����� ������ �������� ����'+#13+'��� ���������');
   exit;
  end;
 LBItems.Clear;
 BMSearch.Hide;
 itemq := ThreadQuery('SELECT * FROM item_template WHERE ItemLevel between '+IntToStr(BL.minilevel)+' and '+IntToStr(BL.maxilevel)+' and RequiredLevel between '+IntToStr(BL.minlev)+' and '+IntToStr(BL.maxlev)+' and quality between '+IntToStr(BL.minqual)+ ' and '+IntToStr(BL.maxqual)+' and name like "%'+EItemName.Text+'%";',Unit1.Auction.currealm.DBWORLD);
 if itemq.Fields[0].AsString = '' then
  goto after;
 i := 1;
 with itemq do
  while not eof do
   begin
    SetLength(chosen,i);
    Chosen[i-1] := TItem.Create(itemq);
    Inc(i);
    next;
   end;
 for i := 0 to Length(Chosen)-1 do
  LBItems.Items.Add(Chosen[i].iname);
after:
 itemq.Connection.Disconnect;
 itemq.Connection.Free;
 itemq.Free;
 BMSearch.Show;
end;

procedure TFChoseItem.LBItemsClick(Sender: TObject);
begin
 if LBItems.ItemIndex < 0 then exit;
 WriteStates(REDescr,Inttostr(Chosen[LBItems.ItemIndex].entry));
end;

procedure TFChoseItem.BMChoseClick(Sender: TObject);
var
 i : integer;
begin
 if (LBItems.ItemIndex < 0) or (Length(Chosen)=0) then
  begin
   Form1.NEPriceI.Text := '0';
   Self.Close;
   exit;
  end;

 Form1.NEPriceI.Text := IntToStr(Chosen[LBItems.ItemIndex].entry);
 for i := 0 to Length(Chosen)-1 do
  Chosen[i].Free;
 SetLength(Chosen,0);
 Self.Close;
end;

procedure SetChangeColor(LB : TListBox; State: TOwnerDrawState; Rect: TRect; Index:integer);
begin
 With LB do
  begin
   if odSelected in State then
    Canvas.Brush.Color := SELCOLOR;
   Canvas.FillRect( Rect );
   Canvas.TextOut( Rect.Left + 2, Rect.Top, Items[Index] );
 end;
end;

procedure TFChoseItem.LBItemsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
 SetChangeColor(LBItems,State,Rect,Index);
end;

end.
