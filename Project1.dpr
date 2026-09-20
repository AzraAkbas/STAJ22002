program Project1;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {FrmLogin},
  Unit2 in 'Unit2.pas' {FormDoktorPaneli},
  Unit3 in 'Unit3.pas' {Form3},
  Unit4 in 'Unit4.pas' {FormGecmisReceteler},
  Unit5 in 'Unit5.pas' {frmHemsireAnaSayfa},
  Unit6 in 'Unit6.pas' {Form6},
  Unit7 in 'Unit7.pas' {Form7},
  Unit8 in 'Unit8.pas' {Form8},
  Unit9 in 'Unit9.pas' {Form9},
  Unit10 in 'Unit10.pas' {Form10},
  Unit11 in 'Unit11.pas' {Form11},
  Unit12 in 'Unit12.pas' {Form12};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TFormGecmisReceteler, FormGecmisReceteler);
  Application.CreateForm(TfrmHemsireAnaSayfa, frmHemsireAnaSayfa);
  Application.CreateForm(TForm6, Form6);
  Application.CreateForm(TForm7, Form7);
  Application.CreateForm(TForm9, Form9);
  Application.CreateForm(TForm10, Form10);
  Application.CreateForm(TForm11, Form11);
  Application.CreateForm(TForm12, Form12);
  Application.Run;
end.
