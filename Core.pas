unit Core;

interface

uses
 Auction,StdCtrls,SysUtils,Classes,Dialogs,Forms,ComCtrls,Grids,ZConnection,ZDataset,ZSQLProcessor;

function ConCheck  : boolean;
function MySQLQuery(SQLStr,DB : string) : TZQuery;
function GetInstItemId(Owner, guid : integer) : integer;
function GetCharItemList(var SLS : TStringList; char_guid : integer) : TStrings;
function GetItemName(entry : integer) : string;
function IdFromName(name : string) : string;
function LoginExist(login:string) : boolean;
function PassExist(login,pass:string) : boolean;
function GetCharList(ac : integer) : TStrings;
function GetAcId(name : string) : integer;
function GetCharId(name : string) : integer;
function GetCharName(id : string) : string;
procedure WriteStates(var RE : TRichEdit; itemid : string);
function ToAuct(itemguid,itemid,sellerguid,priceitemid,price_count,pricetype : string) : boolean;
function GetItemPrice(index : integer; item,count : string) : string;
function ShowAucList(var SG,DBS : TStringGrid) : boolean;
function ThreadQuery(SQL,DB : string) : TZQuery;
function MySQLCommand(SQL,DB : String) : boolean;
function GetAucItem(guid,pricetype,pricecount,itemtem : integer; char : TCharacter;owner : integer; priceitem : integer = 0) : boolean;
function ChangeFilter(item : string; filter : string) : boolean;
function GetCharCount(ac : integer; db : string) : TCharCount;
function LoadRealms : TStringList;
function CheckItemBlackList(Item : TItem; bls : TBlackItemList) : boolean;


type
 TColor = -$7FFFFFFF-1..$7FFFFFFF;
 TMSThread = class(TThread)
  private
   QR : TZQuery;
   QS,QB : string;
  protected
   procedure Execute; override;
  end;

const
 HOST = 'localhost';
 CPASS = 'dutylegion';
 CUSER = 'acherus';
 DBAUTH = 'auth';
 SELCOLOR = $00C4AEA6;
 SITE = 'http://92.248.229.222';

 anytypes : array[0..16] of string =
  ('�����������','���������','������','��������','�����','','','�������������','','������','������','','�������','����','','������','������');
 types : array[2..4,0..20] of string = (
  ('���������� �����','��������� �����','���','�������������','���������� ��������','��������� ��������','���������','���������� ���','��������� ���','','�����','','','��������','������(������)','������','�����������','','�������','����','������'),  //Weapons
  ('�������','�����','������','����������','�������','���������','������','�������','��������','��������������','��������','','','','','','','','','',''),  //Javells
  ('������(�������)','�����','����','��������','����','','���','����������','����','�����','������','','','','','','','','','','')); //Armor

var
 ConCount : integer;

function GetStats(char : String) : TCharStats;

implementation

uses Unit1;

procedure TMSThread.Execute;
begin
 QR := MySQLQuery(QS,QB);
end;

//�������� ���-�� ����������
function ConCheck  : boolean;
begin
 result := false;
 if ConCount > 10 then
  begin
   ShowMessage('������� ����� �����������!');
   exit;
  end;
 result := true;
end;

//������� ������ Mysql
function MySQLQuery(SQLStr,DB : string) : TZQuery;
var
 ACChar: TZConnection;
 AQChar: TZQuery;
begin
 result := nil;
 if ACChar <> nil then ACChar := nil;
 ACChar := TZConnection.Create(nil);
 with ACChar do
  begin
   Protocol := 'mysql';
   HostName := HOST;
   Port := 3306;
   User := CUSER;
   Password := CPASS;
   Database := DB;
   Connect;
  end;

 AQChar := TZQuery.Create(nil);
 with AQChar do
  begin
   Connection := ACChar;
   SQL.Add(SQLStr);
   try
    Active := true;
   except
    ACChar.Free;
    AQChar.Free;
    exit;
   end;
   First;
  end;
  result := AQChar;
end;

//INSERT ������ MySQL
function MySQLCommand(SQL,DB : String) : boolean;
var
 ACChar: TZConnection;
 AComChar: TZSQLProcessor;
begin
 result := false;

 ACChar := TZConnection.Create(nil);
 with ACChar do
  begin
   Protocol := 'mysql';
   HostName := HOST;
   Port := 3306;
   User := CUSER;
   Password := CPASS;
   Database := DB;
   try
    Connect;
   except
    result := false;
    Free;
    exit;
   end;
  end;

 AComChar := TZSQLProcessor.Create(nil);
 with AComChar do
  begin
   Script.Text := SQL;
   Connection := ACChar;
   try
    Execute;
   except
    Connection.Disconnect;
    Connection.Free;
    Free;
    exit;
   end;
   Connection.Disconnect;
   Connection.Free;
   Free;
   result := true;
  end;
end;

//��������� ������ MySQL
function ThreadQuery(SQL,DB : string) : TZQuery;
begin
 result := nil;
 with TMSThread.Create(true) do
  begin
   FreeOnTerminate := true;
   QS := SQL;
   QB := DB;
   Execute;
   Application.ProcessMessages;
   result := QR;
  end;
end;

//������� ID ���� �� Guid
function GetInstItemId(Owner, guid : integer) : integer;
var
 pc,chr : integer;
 val : string;
 data,qt : string;
begin
 result := -1;
//2.4.3
// qt := 'SELECT data FROM item_instance WHERE guid='+InttoStr(guid)+' and owner_guid='+InttoStr(Owner)+';';
//  ConCount := ConCount +1;
//  with ThreadQuery(qt,DBCHAR) do
//  begin
//   data := Fields[0].AsString;
//   Connection.Free;
//   Free;
//  end;
//  ConCount := ConCount -1;
//  chr := 0;
//  pc := 0;
//  val := '';
//  while (pc < 4) do
//   begin
//    chr := chr + 1;
//    if data[chr] = ' ' then Inc(pc);
//    if (pc = 3)and(data[chr]<>' ') then
//     val := val + data[chr];
//   end;

//3.3.5a
   qt := 'SELECT itemEntry FROM item_instance WHERE guid='+InttoStr(guid)+' and owner_guid='+InttoStr(Owner)+';';
   with ThreadQuery(qt,DBCHAR) do
    begin
     val := Fields[0].AsString;
     Connection.Disconnect;
     Connection.Free;
     Free;
    end;
   result := StrToInt(val);
end;

//��� ���� �� ID
function GetItemName(entry : integer) : string;
begin
 ConCount := ConCount +1;
 with ThreadQuery('SELECT name_loc8 FROM locales_item WHERE entry='+InttoStr(entry)+';',DBWORLD) do
  begin
   If Fields[0].AsString <> '' then
    result := Fields[0].AsString
   else
    begin
     ConCount := ConCount +1;
     with ThreadQUery('SELECT name FROM item_template WHERE entry='+InttoStr(entry)+';',DBWORLD) do
      begin
       result := Fields[0].AsString;
       Connection.Disconnect;
       Connection.Free;
       Free;
      end;
     ConCount := ConCount -1;
    end;
   Connection.Disconnect;
   Connection.Free;
   Free;
  end;
 ConCount := ConCount -1;
end;

//ID ���� �� ����� �� ������
function IdFromName(name : string) : string;
var
 i : integer;
begin
 result := '';
 for i := 1 to pos(' - ',name)-1 do
   result := result + name[i];
end;

//���� ����� ���������
function GetCharItemList(var SLS : TStringList; char_guid : integer) : TStrings;
var
 f: integer;
 sl : tstringlist;
 guids : TZQuery;
 count : string;
begin
f := 0;
if sl <> nil then sl := nil;
sl := tstringlist.Create;
result := nil;

ConCount := ConCount +1;
guids := ThreadQuery('SELECT guid,count FROM item_instance WHERE owner_guid='+inttostr(char_guid),DBCHAR);
with guids do
 begin
  while not eof do
   begin
    f := GetInstItemId(char_guid,Fields[0].AsInteger);
    if f >0 then
     begin
      if Fields[1].AsInteger > 1 then
       count := '('+Fields[1].AsString+')' else count := '';
      sl.Add(inttostr(f)+' - ' +GetItemName(f)+count);
      SLS.Add(Fields[0].AsString);
     end;
    Application.ProcessMessages;
    Next;
   end;
   Connection.Disconnect;
   Connection.Free;
   Free;
 end;
ConCount := ConCount -1;
  result := sl;
end;

//��������� ���������� ����
function GetItemStats(id : string) : TZQuery;
begin
 ConCount := ConCount +1;
 result := ThreadQuery('SELECT * FROM item_template WHERE entry='+id+';',DBWORLD);
 ConCount := ConCount -1;
end;

//����������� ����� �������� ����
function SColor(State : integer) : TColor;
const
 States : array[0..6] of TColor = ($00C2BBB4,$00C1C19F,$0061DC6A,$00FA6D29,$00C525C0,$003492E7,$0091F1F9);
begin
 try
  result := States[state];
 except
  result := States[1];
 end;
end;

//����������� �������������� ����
function Pers(State : integer) : string;
const
 Persons : array[0..2] of string = ('','������������ ��� ��������','������������ ��� ���������');
begin
 try
  result := Persons[State];
 except
  result := '';
 end;
end;

//��� ����
function IType(iclass,subclass,Itype : integer) : string;
const
  inventory : array[1..16] of string =
  ('������','���','�����','����','����','����','����','������','������','����','������','���������','����������','���������','���','�����');
begin
 result := '';
 try
  case iclass of
  2..4:
   begin
    result := anytypes[iclass] + #13 + types[iclass,subclass];
    if (iclass = 4) and (subclass < 7) and (Itype < 17) then result := result + ' | ' + inventory[Itype];
   end;
  else result := anytypes[iclass];
  end;
 finally
 //Nothing
 end;
end;

//��� ��������� �� �������
function ParName(index : integer) : string;
const
 params : array[0..48] of string =
  ('','�����','','��������','����','����������','����','������������','','','',
   '','�������� ������','�������� ���������','�������� ������������','�������� �����','�������� �������� (������� ���)','�������� �������� (������� ���)','�������� �������� (����������)','�������� ������������ ����� (������� ���)','�������� ������������ ����� (������� ���)','�������� ������������ ����� (����������)',
   '','','','','','','�������� �������� (������� ���)','�������� �������� (������� ���)','�������� �������� (����������)','�������� ��������','�������� ������������ �����',
   '','','�������� ������������','�������� ��������','�������� ����������','���� �����','���� ����� �������� ���','���� ����� � ������ �����,������� � ��������� �������','���� ���������� (���������)','���� ���������� (����)','�������� �������������� ����',
   '�������� ���������� �����','���� ����������','�������� �������������� �����','����������� ����������� ����������','�������� �����');
begin
 try
  result := params[index];
 except
  result := '';
 end;
end;

//��������� - White Zone
function GetWhitePar(stypes,svalues : array of integer) : string;
var
 i : integer;
begin
 result := '';
 for i := 0 to 9 do
  begin
   case stypes[i] of
    0..7:
     if (svalues[i] <> 0) then
      result := result + '+ '+inttostr(svalues[i])+' � '+ParName(stypes[i])+#13;
   end;
  end;
end;

//��������� - Green Zone
function GetGreenPar(stypes,svalues : array of integer) : string;
var
 i : integer;
begin
 result := '';
 for i := 0 to 9 do
  begin
   case stypes[i] of
    0..7:;
    else
     if (svalues[i] <> 0) then
      result := result + '+ '+inttostr(svalues[i])+' � '+ParName(stypes[i])+#13;
   end;
  end;
end;

//���� / �������� / ���
function GetDamPar(min,max,speed : integer) : string;
var
 dps,del : real;
begin
 result := '';
 del := 2*(speed / 1000);
 dps := ((min + max)/2) / (speed / 1000);
 result := #13 + '����: '+ inttostr(min)+ ' - '+ inttostr(max)
           +#13 + '��������: ' + floattostr(speed/1000) + #13
           +'('+inttostr(Trunc(dps))+' ��. ����� � �������)';
end;

//������ ���������� � RichEdit
procedure WriteStates(var RE : TRichEdit; itemid : string);
var
 itemq : TZQuery;
 i : integer;
 stats,vals : array[1..10] of integer;
begin
 itemq := TZQuery.Create(nil);
 itemq := GetItemStats(itemid);
 with RE do
  begin
   Clear;
   //���
   SelAttributes.Color := SColor(itemq.Fields[6].AsInteger);
   SelText := #13+GetItemName(strtoint(itemid));
   //��������������
   SelStart := Length(text);
   SelAttributes.Color := $00C1C19F;
   SelText := #13+#13+Pers(itemq.FieldByName('bonding').AsInteger);
   //����� ����
   Selstart := Length(text);
   SelText := #13 +
    IType(itemq.FieldByName('class').AsInteger,itemq.FieldByName('subclass').AsInteger,itemq.FieldByName('InventoryType').AsInteger);
   //���� / �����
   SelStart := Length(text);
   if itemq.FieldByName('armor').AsInteger > 0 then
    SelText := #13 + '�����: ' + itemq.FieldByName('armor').AsString;

   Selstart := Length(text);
   if itemq.FieldByName('dmg_max1').AsInteger > 0 then
    SelText := #13 + GetDamPar(itemq.FieldByName('dmg_min1').AsInteger,itemq.FieldByName('dmg_max1').AsInteger,itemq.FieldByName('delay').AsInteger);

   //���������
   Selstart := Length(text);
   for i := 1 to 10 do
    begin
     stats[i] := itemq.FieldByName('stat_type'+inttostr(i)).AsInteger;
     vals[i] := itemq.FieldByName('stat_value'+inttostr(i)).AsInteger;
    end;
   SelText := #13+#13 + GetWhitePar(stats,vals);
   SelAttributes.Color := $0061DC6A;
   SelText := GetGreenPar(stats,vals);
  end;
end;

//��������� ����� ���������
function GetStats(char : String) : TCharStats;
begin
 with TCharacter.Create(GetCharId(char),true) do
   result := stats;
end;

//���������� ���������� Guid � ������
function Auc_Last_Guid : string;
var
 guid : integer;
begin
 ConCount := ConCount +1;
 with ThreadQuery('SELECT Max(guid) FROM auction WHERE guid >= 0',DBCHAR) do
  begin
   if Fields[0]<> nil then result := Inttostr(Fields[0].AsInteger+1);
   Connection.Disconnect;
   Connection.Free;
   Free;
  end;
 ConCount := ConCount -1;
end;


//�������� ��������� ���� �� �������
function ToAuct(itemguid,itemid,sellerguid,priceitemid,price_count,pricetype : string) : boolean;
label Mes;
begin
 result := false;
 //�������� ������� ����
 if StrToInt(itemguid)<0 then
  begin
Mes:
   ShowMessage('������! ������ ������� �� ����� ������� �� �������.');
   exit;
  end;
  //�������� ���� �� ���������
  if not MySQLCommand('DELETE FROM character_inventory WHERE item='+itemguid+';',DBCHAR)
   then goto Mes;
  //�������� �� item_inst
  if not MySQLCommand('DELETE FROM item_instance WHERE guid='+itemguid+';',DBCHAR)
   then goto Mes;


 ConCount := ConCount +1;
 MySQLCommand('INSERT INTO auction VALUES ('+Auc_Last_Guid+','+sellerguid+','+itemid+','+pricetype+','+priceitemid+','+price_count+');',DBCHAR);
 ConCount := ConCount -1;
 result := true;
end;

//��������� ������ ���� ��������
function GetItemPrice(index : integer;item,count : string) : string;
const
 PRICES : array[0..2] of string = ('����', '�����', '���� �����');
begin
 result := '';
 case index of
  3: result := GetItemName(StrToInt(item)) + ' (' + count+')';
  else result := PRICES[index] + ' - ' + count;
 end;
end;

//�������� ��������
function ChangeFilter(item : string; filter : string) : boolean;
begin
 result := false;

 ConCount := ConCount + 1;
 with ThreadQuery('SELECT entry FROM item_template WHERE entry='+item+filter+';',DBWORLD) do
  begin
   if Fields[0].AsString <> '' then
    result := true;
   Connection.Disconnect;
   Connection.Free;
   Free;
  end;
 ConCount := ConCount -1;
end;

//����� �������� � �����
function ShowAucList(var SG,DBS : TStringGrid) : boolean;
var
 curline : string;
 i : integer;
begin
 result := false;

 ConCount := ConCOunt + 1;
 with ThreadQuery('SELECT * FROM auction WHERE guid >= 0;',DBCHAR) do
  begin
   if Fields[0].AsString = '' then
   begin
    Connection.Disconnect;
    Connection.Free;
    Free;
    ConCount := ConCount -1;
    exit;
   end;
   repeat
    begin
     with SG.Rows[SG.RowCount-1] do
      begin
       Add(GetItemName(Fields[2].AsInteger));
       Add(GetCharName(Fields[1].AsString));
       Add(GetItemPrice(Fields[3].AsInteger,Fields[4].AsString,Fields[5].AsString));
      end;
     with DBS.Rows[SG.RowCount-1] do
      begin
       Add(Fields[0].AsString);
       Add(Fields[1].AsString);
       Add(Fields[2].AsString);
       Add(Fields[3].AsString);
       Add(Fields[4].AsString);
       Add(Fields[5].AsString);
      end;
     SG.RowCount := SG.RowCount + 1;
     DBS.RowCount := SG.RowCount;
     next;
    end;
   until eof;
   SG.RowCount := SG.RowCount -1;
   result := true;
  end;
  ConCount := ConCount -1;
end;

//�������� ������
function LoginExist(login:string) : boolean;
var
 lms : TZQuery;
begin
 result := false;
 ConCount := ConCount +1;
 lms := ThreadQuery('SELECT username FROM account WHERE username="'+AnsiUpperCase(login)+'";',DBAUTH);
 if lms <> nil then
  begin
   if lms.Fields[0].AsString <> '' then
    result := true;
   lms.Connection.Disconnect;
   lms.Connection.Free;
   lms.Free;
  end;
 ConCount := ConCount -1;
end;

//�������� ������
function PassExist(login,pass:string) : boolean;
var
 prehash : string;
begin
 result := false;
 ConCount := ConCount + 1;
 prehash := AnsiUpperCase(login)+':'+AnsiUpperCase(pass);
 with ThreadQuery('SELECT sha_pass_hash FROM account WHERE sha_pass_hash=SHA1("'+prehash+'");',DBAUTH) do
  begin
   if Fields[0].AsString <> '' then result := true;
   Connection.Disconnect;
   Connection.Free;
   Free;
  end;
 ConCount := ConCount -1;
end;

//���-�� ����������
function GetCharCount(ac : integer; db : string) : TCharCount;
begin
 result.count := 0;
 with ThreadQuery('SELECT * FROM characters WHERE account='+IntToStr(ac)+';',db) do
  begin
   SetLength(result.chs,1);
   repeat
    begin
     if Fields[0].AsString = '' then Next;
     result.chs[result.count]:= TCharacter.Create(Fields[0].AsInteger,false);
     result.count := result.count+1;
     SetLength(result.chs,result.count+1);
     Next;
    end;
   until eof; 
   Connection.Disconnect;
   Connection.Free;
   Free;
  end;
end;
//����� ������ ����������
function GetCharList(ac : integer) : TStrings;
var
 qw : TZQuery;
 sl : TStringlist;
begin
 result := nil;
 sl := TStringlist.Create;

 ConCount := ConCount +1;
 qw := ThreadQuery('SELECT name FROM characters WHERE account="'+InttoStr(ac)+'";',DBCHAR);
 if qw=nil then exit;
 while not qw.Eof do
  begin
   sl.Add(qw.Fields[0].AsString);
   qw.Next;
  end;
  
 if sl.Count > 0 then result := sl;
 qw.Connection.Disconnect;
 qw.Connection.Free;
 qw.Free;
 ConCount := ConCount -1;
end;

//Id �������� �� ������
function GetAcId(name : string) : integer;
begin
 result := -1;
 ConCount := ConCount +1;
 with ThreadQuery('SELECT id FROM account WHERE username="'+name+'";',DBAUTH) do
  begin
   if Fields[0]=nil then exit;
   result := Fields[0].AsInteger;
   Connection.Free;
   Free;
  end;
 ConCount := ConCount -1;
end;

//Id ��������� �� ������
function GetCharId(name : string) : integer;
begin
 result := -1;
 ConCount := ConCount +1;
 with ThreadQuery('SELECT guid FROM characters WHERE name="'+name+'";',DBCHAR) do
  begin
   if Fields[0]=nil then exit;
   result := Fields[0].AsInteger;
   Connection.Free;
   Free;
  end;
 ConCount := ConCount -1;
end;

//��� ����-� �� Id
function GetCharName(id : string) : string;
begin
 result := '';
 ConCount := ConCount +1;
 with ThreadQuery('SELECT name FROM characters WHERE guid='+id+';',DBCHAR) do
  begin
   if Fields[0]=nil then exit;
   result := Fields[0].AsString;
   Connection.Free;
   Free;
  end;
 ConCount := ConCount -1;
end;

//���������� ����
function MaxGuid(valname,table,DB : string) : string;
begin
 result := '0';
 ConCount := Concount +1;

 with ThreadQuery('SELECT Max('+valname+') FROM '+table+';',DB) do
  begin
   if Fields[0] <> nil then result := Inttostr(Fields[0].AsInteger+1);
   Connection.Disconnect;
   Connection.Free;
   Free;
  end;

 ConCount := Concount -1;
end;

//��������� ������� � item_instance
function GenerateInstItem(guid,id,owner : string) : boolean;
begin
 result := false;
 ConCount := ConCount + 1;
 if MySQLCommand('INSERT INTO item_instance VALUES ('+guid+','+id+','+owner+',0,0,1,0,"0 0 0 0 0 ",0,"0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ",0,10,0,"");',DBCHAR)
  then result := true;
 ConCount := ConCount - 1;
end;

//������� ������ ������
function SendMail(hasitems :boolean;resiever,itemguid : integer) : boolean;
var
 guid,HI : string;
begin
 result := false;
 ConCount := ConCount + 2;
 guid := MaxGuid('id','mail',DBCHAR);
 if hasitems then HI := '1' else HI := '0';

 MySQLCommand('INSERT INTO mail VALUES ('+guid+',0,61,0,0,'+Inttostr(resiever)+',"�������","������� �� ������� � ��������!",'+HI+',0,0,0,0,0);',DBCHAR);
 if hasitems then
  MySQLCommand('INSERT INTO mail_items VALUES ('+guid+','+InttoStr(itemguid)+','+Inttostr(resiever)+');',DBCHAR);

 result := true;
 ConCount := ConCount - 2;
end;

//�������� ���� �� item_instance
procedure DelInstItem(guid,owner : integer);
begin
 ConCount := ConCount + 1;
 MySQLCommand('DELETE FROM item_instance WHERE guid='+IntToStr(GetInstItemId(owner,guid))+';',DBCHAR);
 ConCount := ConCount - 1;
end;
//�������� ������ ����� �� item_instance
procedure DelInstItems(SL: TStringList;count : integer);
label s;
var
 i,mcount,curcount : integer;
 valname,lcguid : string;
begin
 valname := '';
 mcount := 0;
 for i := 0 to SL.Count-1 do
 begin
  with ThreadQuery('SELECT count FROM item_instance WHERE guid='+SL[i]+';',DBCHAR) do
   begin
    curcount := Fields[0].AsInteger;
    mcount := mcount + curcount;
    Connection.Disconnect;
    Connection.Free;
    Free;
   end;
   if mcount < count then
    if valname <> '' then
     valname := valname +',' +SL[i]
    else
     valname := valname + SL[i]
   else
    begin
     if curcount > 1 then
      lcguid := SL[i]
     else
      if valname <> '' then
       valname := valname +',' + SL[i]
      else valname := valname + SL[i];
     goto s;
    end;
 end;
s:
 ConCount := ConCount + 2;
  if valname <> '' then
   begin
    MySQLCommand('DELETE FROM item_instance WHERE guid in ('+valname+');',DBCHAR);
    MySQLCommand('DELETE FROM character_inventory WHERE item in ('+valname+');',DBCHAR);
   end;
 ConCount := ConCount - 1;

 if lcguid <> '' then
  MySQLCommand('UPDATE item_instance SET count='+Inttostr(mcount-count)+' WHERE guid='+lcguid+';',DBCHAR);
 ConCount := ConCount -1;
end;

//���-�� ����� ������ ����
function GetInstItemCount(var SL : TStringList; itemid,owner:integer) : integer;
begin
 result := 0;
 ConCount := ConCount + 1;
 SL.Clear;

 with ThreadQuery('SELECT guid,count FROM item_instance WHERE itemEntry='+IntToStr(itemid)+' and owner_guid='+IntToStr(owner)+';',DBCHAR) do
  begin
   while (Fields[0].AsString <> '') and (not eof) do
    begin
     SL.Add(Fields[0].AsString);
     result := result + Fields[1].AsInteger;
     Next;
    end;
   Connection.Disconnect;
   Connection.Free;
   Free;
  end;
 ConCount := ConCount -1;
end;

//������ ���� � ��������
function GetAucItem(guid,pricetype,pricecount,itemtem : integer; char : TCharacter;owner : integer; priceitem : integer = 0) : boolean;
var
 val,i : integer;
 ItemSL : TStringList;
 valname,mguid : string;
begin
 result := false;
 if char.id < 0 then exit;


 case pricetype of
 0:
 begin
   val := Char.stats.gold;
   valname := 'money';
 end;
 1:
 begin
   val := Char.stats.honor;
   valname := 'totalhonorpoints';
 end;
 2:
 begin
   val := Char.stats.arena;
   valname := 'arenaPoints';
 end;
 else //Item
  begin
   ItemSL := TStringList.Create;
   val := GetInstItemCount(ItemSL,priceitem,owner);
  end;
 end;

 if val < pricecount then exit;

 mguid := MaxGuid('guid','item_instance',DBCHAR);

 if not GenerateInstItem(mguid,Inttostr(itemtem),inttostr(char.id)) then
  begin
   DelInstItem(strtoint(mguid),char.id);
   exit;
  end;
 if not SendMail(true,char.id,strtoint(mguid)) then
  begin
   DelInstItem(strtoint(mguid),char.id);
   exit;
  end;

 if pricetype < 3 then
  begin
   Char.Repl(valname,Inttostr(val-pricecount));
   Char.LoadStats(owner); //��������� ���������
   Char.Repl(valname,Inttostr(val+pricecount)); //� ���������� ��� ����
  end
  else
   begin
    if pricecount < val then
     begin
      valname := '';
      if ItemSL.Count > 0 then
       DelInstItems(ItemSL,pricecount);
      ItemSL.Free;
     end
    else
     begin
      ShowMessage('������������ ������� ��� �������');
      exit;
     end;
   end;

 ConCount := ConCount + 1;
 MySQLCommand('DELETE FROM auction WHERE guid='+IntToStr(guid)+' and seller='+InttoStr(owner)+';',DBCHAR);
 ConCount := ConCount - 1;

 result := true;
end;

function LoadRealms : TStringList;
begin
 result := TStringList.Create;
 with ThreadQuery('SELECT name FROM realmsdb WHERE realmid>0',DBAUTH) do
  begin
   while not eof do
    begin
     result.Add(Fields[0].AsString);
     Next;
    end;
   Connection.Disconnect;
   Connection.Free;
   Free;
  end;
end;

function CheckItemBlackList(Item : TItem; bls : TBlackItemList) : boolean;
var
 i : integer;
begin
 result := false;
 with bls do
  begin
   for i :=0 to entrylist.Count-1 do
    if Item.entry = StrToInt(entrylist.Strings[i])
     then exit;
   if (Item.ilevel > maxilevel) or (Item.ilevel < minilevel) then
    exit;
   if (Item.level > maxlev) or (Item.level < minlev) then
    exit;
   if (Item.quality > maxqual) or (Item.quality < minqual) then
    exit;
  end;
 result := true; 
end;

end.
