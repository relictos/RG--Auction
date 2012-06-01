unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, DB, ADODB, StdCtrls, BSMorphButton, Grids,
  DBGrids,Core, ComCtrls, pngimage, NkEdit1, dblookup, ListBoxChange,
  ImgList, Buttons,Auction,Unit3,IniFiles,IdHttp;




type
  TForm1 = class(TForm)
    Image1: TImage;
    REItemStats: TRichEdit;
    LBChars: TListBox;
    LBItemList: TListBoxChange;
    LBPriceT: TListBox;
    PPrices: TPanel;
    NECount: TNkEdit1;
    NEPriceI: TNkEdit1;
    BMToAuc: TBSMorphButton;
    LTextMain: TLabel;
    LBChoseMain: TListBoxChange;
    BMShowMain: TBSMorphButton;
    LBSubs: TListBox;
    BMUpdate: TBSMorphButton;
    BMPickItem: TBSMorphButton;
    SGAuct: TStringGrid;
    LAcName: TLabel;
    MBLogout: TBSMorphButton;
    LCharName: TLabel;
    IGold: TImage;
    LGold: TLabel;
    IHonor: TImage;
    LHonor: TLabel;
    IArena: TImage;
    LArena: TLabel;
    MBClose: TBSMorphButton;
    MBHide: TBSMorphButton;
    Pwait: TPanel;
    BMChoseItemId: TBSMorphButton;
    NEMinIL: TNkEdit1;
    NEMaxIL: TNkEdit1;
    NEMinL: TNkEdit1;
    NEMaxL: TNkEdit1;
    EItemname: TEdit;
    procedure RefreshItemList;
    procedure RefreshAucList;
    function ChangeFilters : string;
    procedure ShowAuc;
    procedure MBLogoutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure LBCharsClick(Sender: TObject);
    procedure BMToAucClick(Sender: TObject);
    procedure BMUpdateClick(Sender: TObject);
    procedure SGAuctSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure BMPickItemClick(Sender: TObject);
    procedure SGAuctDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure LBItemListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure LBItemListChange(Sender: TObject);
    procedure BMShowMainClick(Sender: TObject);
    procedure LBChoseMainDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure LBChoseMainClick(Sender: TObject);
    procedure LBCharsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure LBPriceTDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure LBSubsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure LBPriceTClick(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MBCloseClick(Sender: TObject);
    procedure MBHideClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BMChoseItemIdClick(Sender: TObject);
    procedure NECountKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure NEMinILKeyPress(Sender: TObject; var Key: Char);
    procedure NEMaxILKeyPress(Sender: TObject; var Key: Char);
    procedure NEMinLKeyPress(Sender: TObject; var Key: Char);
    procedure NEMaxLKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

 TStringGridX = class(TStringGrid)
  public
    procedure MoveColumn(FromIndex, ToIndex: Longint);
    procedure MoveRow(FromIndex, ToIndex: Longint);
  end;

var
 Form1: TForm1;
 LBStringList: TStringList;
 Auction : TAuction;
 BL : TBlackItemList;
implementation

uses Unit2;

{$R *.dfm}

procedure TStringGridX.MoveColumn(FromIndex, ToIndex: Integer);
begin
  inherited;
end;

procedure TStringGridX.MoveRow(FromIndex, ToIndex: Integer);
begin
  inherited;
end;

//Создание формы
procedure TForm1.MBLogoutClick(Sender: TObject);
begin
 Form2.Show;
 Self.Hide;
 
end;

procedure TForm1.RefreshItemList;
var
 i : integer;
begin
 LBChars.Enabled := false;
 LBItemList.Clear; //Чистим прямой и скрытый листбоксы
 LBItemList.Refresh;
 Auction.curchar := Auction.account.realmchars[LBChars.Itemindex];
 Auction.curchar.LoadStats(Auction.curchar.id);
 //Получаем список вещей в прямой и скрытый листбоксы
 //LBItemList.Items := GetCharItemList(LBStringList,GetCharId(LBChars.Items[LBChars.ItemIndex]));
 for i := 0 To Auction.curchar.Items.count-1 do
  LBItemList.Items.Add(Auction.curchar.Items.names[i]);
 LBChars.Enabled := true;

 LGold.Caption := IntToStr(Auction.curchar.stats.gold);
 LHonor.Caption := IntToStr(Auction.curchar.stats.honor);
 LArena.Caption := IntToStr(Auction.curchar.stats.arena);

end;

function FindIClass(classf : string) : integer;
var
 i : integer;
begin
 result := -1;
 for i := 0 To 16 do
  if anytypes[i] = classf then
   begin
    result := i;
    exit;
   end;
end;

function FindSub(subclass : string; classf : integer) : integer;
var
 i : integer;
begin
 result := -1;
 for i := 0 to 20 do
  if types[classf][i] = subclass then
   begin
    result := i;
    exit;
   end;
end;

procedure TForm1.ShowAuc;
var
 i : integer;
begin
 SGAuct.Hide;
 for i := 0 To Auction.filtcount -1 do
  begin
   SGAuct.Rows[i].Clear;
   SGAuct.Rows[i].Add(Auction.FItems[i].item_item.iname);
   SGAuct.Rows[i].Add(GetCharName(IntToStr(Auction.FItems[i].seller)));
   SGAuct.Rows[i].Add(GetItemPrice(Auction.FItems[i].pricetype,IntToStr(Auction.FItems[i].price_itemid),IntToStr(Auction.FItems[i].price_count)));
   SGAuct.RowCount := i + 1;
  end;
 SGAuct.Show; 
end;
procedure TForm1.RefreshAucList;
begin
 SGAuct.Rowcount := 0;
 SGAuct.Rows[0].Clear;
 SGAuct.Hide;
 
 Auction.ReloadItems;
 ShowAuc;
 {ShowAucList(SGAuct,SGS);
 if ChangeFilters = '' then
  begin
   SGAuct.Show;
   exit;
  end;}
{ for i := SGAuct.RowCount-1 DownTo 0 do
  begin
   if not ChangeFilter(SGS.Cells[2,i],ChangeFilters) then
    begin
    SGAuct.Rows[i].Clear;
     SGS.Rows[i].Clear;
     TStringGridX(SGAuct).DeleteRow(i);
     TStringGridX(SGS).DeleteRow(i);
    end;
  end; }
 SGAuct.Refresh;
 SGAuct.Show;
 SGAuct.Update;
end;


function TForm1.ChangeFilters : string;
begin
 result := '';
 if EItemname.Text <> '' then
  result := result +' and name Like "%'+EitemName.Text+'%"';

 if (NEMinIL.Numb > 0) and (NEMaxIL.Numb >= NEMinIL.Numb) then
  result := result + ' and ItemLevel between '+NEMinIL.Text+' and '+NEMaxIL.Text;

 if (NEMinL.Numb > 0) and (NEMaxL.Numb >= NEMinL.Numb) then
  result := result + ' and RequiredLevel between '+NEMinL.Text+' and '+NEMaxL.Text;

 if LBChoseMain.ItemIndex > 0 then
  begin
   result := result + ' and class='+InttoStr(FindIClass(LBChoseMain.Items[LBChoseMain.Itemindex]));
   if LBSubs.ItemIndex > 0 then
    result := result + ' and subclass='+Inttostr(FindSub(LBSubs.Items[LBSubs.ItemIndex],FindIClass(LBChoseMain.Items[LBChoseMain.Itemindex])));
  end;

end;

//Цвет выделения ListBox
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
//Создание формы (активация конечно)
procedure TForm1.FormActivate(Sender: TObject);
var
 chars : TStrings;
 i : integer;
begin
 PWait.Show;
 MBHide.Hide;
 MBClose.Hide;
 MBLogout.Hide;
 Auction := TAuction.Create(Form2.Elogin.Text,Form2.CBRealm.ItemIndex+1);
 SGAuct.ColWidths[0] := 330;
 SGAuct.ColWidths[1] := SGAuct.ColWidths[1] - 40;
 SGAuct.ColWidths[2] := SGAuct.ColWidths[2] + 60;
 //Получаем лист персонажей
 //chars := GetCharList(GetAcId(Form2.Edit1.Text));
 for i := 0 to Auction.account.charcount-1 do
  LBChars.Items.Add(Auction.account.realmchars[i].cname);
 //Проверка и вывод
 //if chars <> nil then
 // begin
//   LBChars.Items := chars;
//   chars.Free;
 // end;
 
end;

procedure TForm1.LBCharsClick(Sender: TObject);
begin
 ConCheck; //Проверка кол-ва подключений
 if LBChars.ItemIndex < 0 then exit; //Проверка индекса
 RefreshItemList;
 LCharName.Caption := LBChars.Items[LBChars.ItemIndex];
end;

procedure TForm1.BMToAucClick(Sender: TObject);
var
 MsgString : string;
begin
 //Проверка полей
 if (LBItemList.ItemIndex < 0) or (LBPriceT.ItemIndex < 0) or (NECount.Numb <= 0) then
  begin
   ShowMessage('Пожалуйста, заполните все требуемые поля!');
   exit;
  end;
 if not CheckItemBlackList(Auction.curchar.Items.items[LBItemList.ItemIndex],BL) then
  begin
   ShowMessage('Предмет не удовлетворяет требованиям аукциона!');
   exit;
  end;
 //Подтверждение
 MsgString := 'Предмет: ' + LBItemList.Items[LBItemList.ItemIndex] + #13
              + 'Цена: ' + GetItemPrice(LBPriceT.ItemIndex,NEPriceI.Text,NECount.Text);
 if MessageBoxA(Form1.Handle,PAnsiChar('Вы уверены?' + #13 + MsgString),'Аукцион',1)=2 then exit;
 //Проверка кол-ва подключений
 if not ConCheck then exit;
 PWait.Show;
 //Запись вещи на аукцион
 ToAuct(IntToStr(Auction.curchar.Items.Ids[LBItemList.ItemIndex]),IdFromName(LBItemList.Items[LBItemList.ItemIndex]),InttoStr(GetCharId(LBChars.Items[LBChars.ItemIndex])),NEPriceI.Text, NECount.Text, InttoStr(LBPriceT.ItemIndex));
 Auction.curchar.ReloadItems;
 RefreshItemList;
 RefreshAucList;
 PWait.Hide;
 Form1.Refresh;
end;

procedure TForm1.BMUpdateClick(Sender: TObject);
var
 cl, subcl : integer;
begin
 //Проверка кол-ва подключений
 if not ConCheck then exit;
 if (Length(NEMinIl.Text)=0) or (Length(NEMaxIL.Text)=0)
    or (Length(NEMinL.Text)=0) or (Length(NEMaxL.Text)=0) then exit;
 SGAuct.Visible := false;
 BMUpdate.Visible := false;

 if LBChoseMain.ItemIndex >= 0 then
  cl := FindIClass(LBChoseMain.Items[LBChoseMain.Itemindex])
 else cl := -1;
 if (LBChoseMain.ItemIndex >=0) and (LBSubs.ItemIndex >= 0) then
  subcl := FindSub(LBSubs.Items[LBSubs.ItemIndex],cl)
 else subcl := -1;
 //Проба вывода списка
 try
  Auction.SetFilter(Eitemname.Text,cl,subcl,
                    StrToInt(NEMinIL.Text),StrToInt(NEMaxIL.Text),StrToInt(NEMinL.Text),StrToInt(NEMaxL.Text));
  RefreshAucList;
 except
 //При ошибке - список пуст
  ShowMessage('Список пуст!');
  BMUpdate.Show;
  exit;
 end;
 BMUpdate.Visible := true;
 SGAuct.Visible := true;
end;

procedure TForm1.SGAuctSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
 if not ConCheck then exit; //Проверка кол-ва подключений
 if (not SGAuct.Enabled)or(not SGAuct.Visible) then exit;
 SGAuct.Enabled := false;
 if (SGAuct.Cols[1].Strings[ARow] <> '') then //если колонка - 1 (название вещи)
  //то выводим параметры из данных невидимой таблицы
  WriteStates(REItemStats,IntToStr(Auction.FItems[ARow].item_item.entry));

 SGAuct.Enabled := true;
end;

procedure TForm1.BMPickItemClick(Sender: TObject);
var
 MsgString : string;
 Item : TAucItem;
begin
//Проверка персонажа
 if LBChars.ItemIndex < 0 then
  begin
   ShowMessage('Выберите персонажа');
   exit;
  end
 else if (SGAuct.Col < 0) or (SGAuct.Row < 0) or (SGAuct.Cells[0,0] = '') then
  begin
   ShowMessage('Не выбран предмет покупки');
   exit;
  end;
 //Проверка подключений
 if not ConCheck then exit;

 MsgString := 'Предмет: ' + SGAuct.Cols[0].Strings[SGAuct.Row] + #13
              + 'Цена: ' + SGAuct.Cols[2].Strings[SGAuct.Row];
 if MessageBoxA(Form1.Handle,PAnsiChar('Вы уверены?' + #13 + MsgString),'Аукцион',1)=2 then exit;
 Item := Auction.FItems[SGAuct.Row];
 BMPickItem.Enabled := false;
 PWait.Show;
 if not GetAucItem(Item.guid,Item.pricetype,Item.price_count,Item.item_item.entry,Auction.curchar,Item.seller,Item.price_itemid)
  then ShowMessage('Произошла ошибка')
  else
   begin
    RefreshAucList;
    RefreshItemList;
    ShowMessage('Поздравляем, предмет успешно куплен и выслан вам на почту в игре');
   end;
 BMPickItem.Enabled := true;
 PWait.Hide;
 Form1.Refresh;
end;

procedure TForm1.SGAuctDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
if ( gdSelected in State ) then
   with TStringGrid( Sender ),Canvas do
   begin
      Brush.Color := SELCOLOR;
      FillRect(Rect);
      TextRect(Rect,Rect.Left+2, Rect.Top+2, Cells[ACol,ARow]);
   end;
end;

procedure TForm1.LBItemListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
 SetChangeColor(LBItemList,State,Rect,Index);
end;

procedure TForm1.LBItemListChange(Sender: TObject);
begin
 //Проверка кол-ва подключений
 if not ConCheck then exit;
 //Проверка индекса
 if (LBItemList.ItemIndex < 0) then exit;

 LBItemList.Enabled := false;
 //Вывод параметров вещи на панель
 WriteStates(REItemStats,IdFromName(LBitemList.Items[LBItemList.ItemIndex]));
 LBItemList.Enabled := true;
 LBItemList.SetFocus;
end;

procedure TForm1.BMShowMainClick(Sender: TObject);
begin
 if LBChoseMain.Visible then
  begin
   LBChoseMain.Hide;
  end
 else
  begin
   LbChoseMain.Show;
  end;
end;

procedure TForm1.LBChoseMainDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
 SetChangeColor(LBChoseMain,State,Rect,Index);
end;

procedure TForm1.LBChoseMainClick(Sender: TObject);
label SubCl;
var
 i,id : integer;
begin
 if LBChoseMain.ItemIndex <0 then exit;
 LTextMain.Caption := LBChoseMain.Items[LBChoseMain.ItemIndex];
 LBChoseMain.Hide;
 LBSubs.Hide;
 LBSubs.Clear;
 LBSubs.Items.Add('Нет');
 for i := 2 to 4 do
   if LTextMain.Caption = anytypes[i] then
    begin
     id := i;
     goto SubCl;
    end;
 exit;
SubCl:
 for i := 0 to 20 do
  if types[id,i] <> '' then
   LBSubs.Items.Add(types[id,i]);
 LBSubs.Show;
end;

procedure TForm1.LBCharsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
 SetChangeColor(LBChars,State,Rect,Index);
end;

procedure TForm1.LBPriceTDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
 SetChangeColor(LBPriceT,State,Rect,Index);
end;

procedure TForm1.LBSubsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
 SetChangeColor(LBSubs,State,Rect,Index);
end;

procedure TForm1.LBPriceTClick(Sender: TObject);
begin
 if LBPriceT.ItemIndex = 3 then
  begin
   BMChoseItemId.Show;
   NEPriceI.Show;
  end
 else
  begin
   NEPriceI.Hide;
   BMChoseItemId.Hide;
  end; 
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const sc_dragmove = $f012;
begin
 ReleaseCapture;
 Form1.Perform(wm_syscommand, sc_dragmove, 0);
end;

procedure TForm1.MBCloseClick(Sender: TObject);
begin
 Form1.Close;
 Form2.Close;
end;

procedure TForm1.MBHideClick(Sender: TObject);
begin
 Application.Minimize;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
 blacklist : TIniFile;
 FS : TFileStream;
begin
 with TIdHTTP.Create(nil) do
  begin
   FS := TFileStream.Create(ExtractFilePath(Application.ExeName)+'blacklist.ini',fmCreate or fmOpenWrite);
   try
    Get(SITE+'/blacklist.ini',FS);
   except
    ShowMessage('Ошибка соединения с сервером! Выполнение программы будет прекращено');
    Form1.Close;
    Form2.Close;
    exit;
   end;
   FS.Free;
   Free;
  end;

 blacklist := TIniFile.Create(ExtractFilePath(Application.ExeName)+'blacklist.ini');
 with BL do
  begin
   entrylist := TStringList.Create;
   blacklist.ReadSection('ENTRYLIST',entrylist);
   maxilevel := blackList.ReadInteger('LEVELS','maxil',0);
   minilevel := blackList.ReadInteger('LEVELS','minil',0);
   maxlev := blackList.ReadInteger('LEVELS','maxl',0);
   minlev := blackList.ReadInteger('LEVELS','minl',0);
   maxqual := blackList.ReadInteger('LEVELS','maxqual',0);
   minqual := blackList.ReadInteger('LEVELS','minqual',0);
   blacklist.Free;
  end;
 DeleteFile(ExtractFilePath(Application.ExeName)+'blacklist.ini');
 Self.Show;
 //Пробуем показать список аукциона
 try
  ShowAuc;
 except
 end;

 LBChoseMain.ItemIndex := 0;
 LBSubs.ItemIndex := 0;
 PWait.Hide;
 MBHide.Show;
 MBClose.Show;
 MBLogout.Show;
 Form1.Refresh;
end;

procedure TForm1.BMChoseItemIdClick(Sender: TObject);
begin
 Application.CreateForm(TFChoseItem, FChoseItem);
 FChoseItem.ShowModal;
end;

procedure TForm1.NECountKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Length(NECount.Text) = 0 then
  NECount.Text := '0';
end;

procedure CheckKey(var Key : Char);
begin
 case Key of
 '0'..'9': ;
 else Key := #0;
 end;
end;

procedure TForm1.NEMinILKeyPress(Sender: TObject; var Key: Char);
begin
 CheckKey(Key);
end;

procedure TForm1.NEMaxILKeyPress(Sender: TObject; var Key: Char);
begin
CheckKey(Key);
end;

procedure TForm1.NEMinLKeyPress(Sender: TObject; var Key: Char);
begin
CheckKey(Key);
end;

procedure TForm1.NEMaxLKeyPress(Sender: TObject; var Key: Char);
begin
CheckKey(Key);
end;

end.

