program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Core in 'Core.pas',
  Unit2 in 'Unit2.pas' {Form2},
  Auction in 'Auction.pas',
  Unit3 in 'Unit3.pas' {FChoseItem};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
