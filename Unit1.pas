unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Hash, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  Vcl.Imaging.pngimage, FireDAC.VCLUI.Wait, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat;

type
  TFrmLogin = class(TForm)
    Label1: TLabel;
    Şifre: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label2: TLabel;
    PnlGirisButon: TPanel;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    procedure FormCreate(Sender: TObject);
    procedure PnlGirisButonClick(Sender: TObject);
  private
    { Private declarations }
    function StringToSHA256(const AInput: string): string;
  public
    { Public declarations }
    GirisYapanDoktorID: Integer;
    GirisYapanHemsireID: Integer;
    GirisYapanEczaciID: Integer;
    GirisYapanServisAdi: string;
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.dfm}

uses Unit2, Unit5, Unit8;

function TFrmLogin.StringToSHA256(const AInput: string): string;
begin
  Result := LowerCase(THashSHA2.GetHashString(AInput, THashSHA2.TSHA2Version.SHA256));
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
var
  vExePath, vDbYolu: string;
begin
  PnlGirisButon.BevelOuter := bvNone;
  FDConnection1.LoginPrompt := False;

  vExePath := ExtractFilePath(Application.ExeName);

  vDbYolu := vExePath + 'Ilac_Takip_DB.db';
  if not FileExists(vDbYolu) then
    vDbYolu := ExpandFileName(vExePath + '..\Ilac_Takip_DB.db');
  if not FileExists(vDbYolu) then
    vDbYolu := ExpandFileName(vExePath + '..\..\Ilac_Takip_DB.db');

  if not FileExists(vDbYolu) then
  begin
    ShowMessage('UYARI: Ilac_Takip_DB.db dosyası bulunamadı!' + sLineBreak +
                'Son Aranan Yol: ' + vDbYolu);
    Exit;
  end;

  FDConnection1.Connected := False;
  FDConnection1.Params.Clear;
  FDConnection1.Params.Add('DriverID=SQLite');
  FDConnection1.Params.Add('Database=' + vDbYolu);
  FDConnection1.Params.Add('StringFormat=Unicode');
  FDConnection1.Connected := True;
end;

procedure TFrmLogin.PnlGirisButonClick(Sender: TObject);
var
  vSicilNo, vGirilenSifre, vSifreHash: string;
  vAd, vSoyad, vUnvan, vKarsilamaMesaji, vRol: string;
begin
  vSicilNo := Trim(Edit1.Text);
  vGirilenSifre := Edit2.Text;

  if (vSicilNo = '') or (vGirilenSifre = '') then
  begin
    ShowMessage('Lütfen sicil numaranızı ve şifrenizi giriniz!');
    Exit;
  end;

  vSifreHash := StringToSHA256(vGirilenSifre);

  try
    if not FDConnection1.Connected then
      FDConnection1.Connected := True;

    FDQuery1.Close;
    FDQuery1.SQL.Clear;
    FDQuery1.SQL.Add('SELECT k.Rol, k.DoktorID, k.HemsireID, k.EczaciID, k.SifreHash, ');
    FDQuery1.SQL.Add('       COALESCE(d.Ad, h.Ad, e.Ad) AS Ad, ');
    FDQuery1.SQL.Add('       COALESCE(d.Soyad, h.Soyad, e.Soyad) AS Soyad, ');
    FDQuery1.SQL.Add('       d.Unvan, d.Uzmanlik, h.GorevliOlduguServis ');
    FDQuery1.SQL.Add('FROM KULLANICI k ');
    FDQuery1.SQL.Add('LEFT JOIN DOKTOR d ON k.DoktorID = d.DoktorID ');
    FDQuery1.SQL.Add('LEFT JOIN HEMSIRE h ON k.HemsireID = h.HemsireID ');
    FDQuery1.SQL.Add('LEFT JOIN ECZACI e ON k.EczaciID = e.EczaciID ');
    FDQuery1.SQL.Add('WHERE (LOWER(d.SicilNo) = LOWER(:pSicilNo) ');
    FDQuery1.SQL.Add('   OR LOWER(h.SicilNo) = LOWER(:pSicilNo) ');
    FDQuery1.SQL.Add('   OR LOWER(e.SicilNo) = LOWER(:pSicilNo)) ');
    FDQuery1.SQL.Add('  AND k.AktifMi = ''Evet''');

    FDQuery1.ParamByName('pSicilNo').AsString := vSicilNo;
    FDQuery1.Open;

    if not FDQuery1.Eof then
    begin
      if not SameText(FDQuery1.FieldByName('SifreHash').AsString, vSifreHash) then
      begin
        ShowMessage('Hatalı şifre girdiniz!');
        Exit;
      end;

      vAd := FDQuery1.FieldByName('Ad').AsString;
      vSoyad := FDQuery1.FieldByName('Soyad').AsString;
      vUnvan := FDQuery1.FieldByName('Unvan').AsString;
      vRol := UpperCase(FDQuery1.FieldByName('Rol').AsString);

      if vRol = 'DOKTOR' then
      begin
        GirisYapanDoktorID := FDQuery1.FieldByName('DoktorID').AsInteger;
        GirisYapanServisAdi := FDQuery1.FieldByName('Uzmanlik').AsString;

        if vUnvan <> '' then
          vKarsilamaMesaji := 'Hoş geldiniz, ' + vUnvan + ' ' + vAd + ' ' + vSoyad
        else
          vKarsilamaMesaji := 'Hoş geldiniz, Dr. ' + vAd + ' ' + vSoyad;

        ShowMessage('Giriş Başarılı!' + sLineBreak + vKarsilamaMesaji);

        Self.Hide;

        if not Assigned(FormDoktorPaneli) then
          Application.CreateForm(TFormDoktorPaneli, FormDoktorPaneli);

        FormDoktorPaneli.Show;
      end
      else if vRol = 'HEMSIRE' then
      begin
        GirisYapanHemsireID := FDQuery1.FieldByName('HemsireID').AsInteger;
        GirisYapanServisAdi := FDQuery1.FieldByName('GorevliOlduguServis').AsString;

        vKarsilamaMesaji := 'Hoş geldiniz, Hemşire ' + vAd + ' ' + vSoyad +
                            sLineBreak + 'Görev Yeri: ' + GirisYapanServisAdi;
        ShowMessage('Giriş Başarılı!' + sLineBreak + vKarsilamaMesaji);

        Self.Hide;

        if not Assigned(frmHemsireAnaSayfa) then
          Application.CreateForm(TfrmHemsireAnaSayfa, frmHemsireAnaSayfa);

        frmHemsireAnaSayfa.Show;
      end
      else if vRol = 'ECZACI' then
      begin
        GirisYapanEczaciID := FDQuery1.FieldByName('EczaciID').AsInteger;

        vKarsilamaMesaji := 'Hoş geldiniz, Eczacı ' + vAd + ' ' + vSoyad;
        ShowMessage('Giriş Başarılı!' + sLineBreak + vKarsilamaMesaji);

        Self.Hide;

        if not Assigned(Form8) then
          Application.CreateForm(TForm8, Form8);

        Form8.AktifEczaciID := GirisYapanEczaciID;
        Form8.Show;
      end
      else
      begin
        vKarsilamaMesaji := 'Hoş geldiniz, ' + vAd + ' ' + vSoyad;
        ShowMessage('Giriş Başarılı!' + sLineBreak + vKarsilamaMesaji);
      end;
    end
    else
    begin
      ShowMessage('Sicil numarasına ait kullanıcı bulunamadı!');
    end;

  except
    on E: Exception do
      ShowMessage('Bağlantı hatası: ' + E.Message);
  end;
end;

initialization
  RegisterClasses([TFDConnection, TFDQuery]);

end.
