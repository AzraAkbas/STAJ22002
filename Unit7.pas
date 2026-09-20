unit Unit7;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.Grids, Vcl.DBGrids;

type
  TForm7 = class(TForm)
    pnlTop: TPanel;
    edtAramaGecmis: TEdit;
    dbGridGecmis: TDBGrid;
    DataSource1: TDataSource;
    qryGecmisUygulamalar: TFDQuery;
    dtpTarihFiltre: TDateTimePicker;

    procedure FormShow(Sender: TObject);
    procedure edtAramaGecmisChange(Sender: TObject);
    procedure dtpTarihFiltreChange(Sender: TObject);
    procedure dtpTarihFiltreCloseUp(Sender: TObject);
  private
    function TurkceKarakterDuzelt(const S: string): string;
    procedure SutunGenislikleriniAyarla;
  public
    procedure GecmisUygulamalariYukle;
  end;

var
  Form7: TForm7;

implementation

{$R *.dfm}

uses Unit1;

function TForm7.TurkceKarakterDuzelt(const S: string): string;
var
  ResultStr: string;
begin
  ResultStr := S;
  ResultStr := StringReplace(ResultStr, 'I', 'İ', [rfReplaceAll]);
  ResultStr := StringReplace(ResultStr, 'ı', 'i', [rfReplaceAll]);
  ResultStr := StringReplace(ResultStr, 'Þ', 'Ş', [rfReplaceAll]);
  ResultStr := StringReplace(ResultStr, 'þ', 'ş', [rfReplaceAll]);
  ResultStr := StringReplace(ResultStr, 'Ð', 'Ğ', [rfReplaceAll]);
  ResultStr := StringReplace(ResultStr, 'ð', 'ğ', [rfReplaceAll]);
  ResultStr := StringReplace(ResultStr, 'Ý', 'İ', [rfReplaceAll]);
  ResultStr := StringReplace(ResultStr, 'ý', 'ı', [rfReplaceAll]);
  Result := ResultStr;
end;

procedure TForm7.FormShow(Sender: TObject);
begin
  Font.Size := 11;
  Font.Name := 'Segoe UI';

  // 🌟 GEÇMİŞ UYGULAMALAR GRID FONT AYARLARI (Yazı boyutu büyütüldü & Başlıklar kalın yapıldı)
  dbGridGecmis.Font.Name := 'Segoe UI';
  dbGridGecmis.Font.Size := 11;              // Hücre içi yazı boyutu
  dbGridGecmis.TitleFont.Name := 'Segoe UI';
  dbGridGecmis.TitleFont.Size := 11;         // Başlık yazı boyutu
  dbGridGecmis.TitleFont.Style := [fsBold];  // Başlıklar kalın (Bold)

  if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
  begin
    qryGecmisUygulamalar.Connection := FrmLogin.FDConnection1;
  end
  else
  begin
    ShowMessage('Veritabanı bağlantısı bulunamadı!');
    Exit;
  end;

  edtAramaGecmis.Text := '';
  dtpTarihFiltre.Checked := True;
  GecmisUygulamalariYukle();
end;

procedure TForm7.edtAramaGecmisChange(Sender: TObject);
begin
  GecmisUygulamalariYukle();
end;

procedure TForm7.dtpTarihFiltreChange(Sender: TObject);
begin
  GecmisUygulamalariYukle();
end;

procedure TForm7.dtpTarihFiltreCloseUp(Sender: TObject);
begin
  GecmisUygulamalariYukle();
end;

procedure TForm7.SutunGenislikleriniAyarla;
begin
  // 🌟 Büyüyen başlık ve veri fontlarına uygun genişlikler
  if dbGridGecmis.Columns.Count >= 10 then
  begin
    dbGridGecmis.Columns[0].Width := 120; // Tarih
    dbGridGecmis.Columns[1].Width := 150; // Hemşire Adı
    dbGridGecmis.Columns[2].Width := 150; // Hasta Adı
    dbGridGecmis.Columns[3].Width := 170; // İlaç Adı
    dbGridGecmis.Columns[4].Width := 130; // Parti No
    dbGridGecmis.Columns[5].Width := 120; // İlaç SKT
    dbGridGecmis.Columns[6].Width := 90;  // Doz
    dbGridGecmis.Columns[7].Width := 120;  // Öğün
    dbGridGecmis.Columns[8].Width := 140; // Durum
    dbGridGecmis.Columns[9].Width := 160; // Gerekçe
  end;
end;

procedure TForm7.GecmisUygulamalariYukle;
var
  AramaMetni: string;
  SqlSorgu: string;
begin
  if not Assigned(qryGecmisUygulamalar.Connection) then Exit;

  AramaMetni := Trim(edtAramaGecmis.Text);

  // SQL Sorgusunda başlık takma adları (Alias) okunaklı hale getirildi
  SqlSorgu :=
    'SELECT ' +
    '    date(TU.UygulamaTarihi) AS [Tarih], ' +
    '    COALESCE(HM.Ad || '' '' || HM.Soyad, ''Sistem'') AS [Hemşire Adı], ' +
    '    COALESCE(H.Ad || '' '' || H.Soyad, ''Bilinmiyor'') AS [Hasta Adı], ' +
    '    COALESCE(I.IlacAdi, ''-'') AS [İlaç Adı], ' +
    '    COALESCE(P.PartiNo, ''Standart/Yok'') AS [Parti No], ' +
    '    COALESCE(P.SonKullanmaTarihi, ''-'') AS [İlaç SKT], ' +
    '    COALESCE(RD.Doz, ''-'') AS [Doz], ' +
    '    COALESCE(TU.Ogun, ''-'') AS [Öğün], ' +
    '    CASE ' +
    '        WHEN TU.Durum = ''Uygulandi'' THEN ''✔ Uygulandı'' ' +
    '        ELSE ''❌ Uygulanmadı'' ' +
    '    END AS [Durum], ' +
    '    COALESCE(TU.Gerekce, ''-'') AS [Gerekçe] ' +
    'FROM TEDAVI_UYGULAMA TU ' +
    'LEFT JOIN RECETE_DETAY RD ON TU.ReceteDetayID = RD.DetayID ' +
    'LEFT JOIN RECETE R ON RD.ReceteID = R.ReceteID ' +
    'LEFT JOIN HASTA H ON R.HastaID = H.HastaID ' +
    'LEFT JOIN ILAC I ON RD.IlacID = I.IlacID ' +
    'LEFT JOIN HEMSIRE HM ON TU.HemsireID = HM.HemsireID ' +
    'LEFT JOIN ILAC_PARTI P ON RD.IlacID = P.IlacID ' +
    'WHERE 1=1 ';

  if AramaMetni <> '' then
    SqlSorgu := SqlSorgu + 'AND (LOWER(COALESCE(H.Ad, '''') || '' '' || COALESCE(H.Soyad, '''')) LIKE LOWER(:pAramaFiltre)) ';

  if dtpTarihFiltre.Checked then
    SqlSorgu := SqlSorgu + 'AND (date(TU.UygulamaTarihi) LIKE :pSecilenTarih) ';

  SqlSorgu := SqlSorgu + 'ORDER BY TU.UygulamaTarihi DESC;';

  qryGecmisUygulamalar.Close;
  qryGecmisUygulamalar.SQL.Text := SqlSorgu;

  if AramaMetni <> '' then
    qryGecmisUygulamalar.ParamByName('pAramaFiltre').AsString := '%' + AramaMetni + '%';

  if dtpTarihFiltre.Checked then
    qryGecmisUygulamalar.ParamByName('pSecilenTarih').AsString := FormatDateTime('yyyy-mm-dd', dtpTarihFiltre.Date) + '%';

  try
    qryGecmisUygulamalar.Open;

    dbGridGecmis.Columns.Clear;
    DataSource1.DataSet := qryGecmisUygulamalar;
    dbGridGecmis.DataSource := DataSource1;
    dbGridGecmis.ReadOnly := True;

    // Sütun genişliklerini yeni yazı tiplerine göre ayarla
    SutunGenislikleriniAyarla;

  except
    on E: Exception do
      ShowMessage('Geçmiş uygulamalar yüklenirken hata oluştu: ' + E.Message);
  end;
end;

end.
