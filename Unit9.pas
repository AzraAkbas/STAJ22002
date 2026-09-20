unit Unit9;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TForm9 = class(TForm)
    PageControl1: TPageControl;

    // 1. Sekme Bileşenleri (Geçmiş Doktor Reçeteleri)
    pnlReceteTop: TPanel;
    edtServisAraRecete: TEdit;
    Label1: TLabel;
    dbGridReceteler: TDBGrid;
    dtpTarihRecete: TDateTimePicker;

    // 2. Sekme Bileşenleri (Geçmiş Hemşire Stok İstekleri)
    dbGridStokIstek: TDBGrid;
    pnlStokTop: TPanel;
    edtServisAraStok: TEdit;
    Label2: TLabel;
    dtpTarihStok: TDateTimePicker;

    // Veritabanı Bileşenleri
    qryReceteler: TFDQuery;
    qryStokIstek: TFDQuery;
    DataSourceReceteler: TDataSource;
    DataSourceStokIstek: TDataSource;
    Label3: TLabel;
    Label4: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edtServisAraReceteChange(Sender: TObject);
    procedure edtServisAraStokChange(Sender: TObject);
    procedure dtpTarihReceteChange(Sender: TObject);
    procedure dtpTarihStokChange(Sender: TObject);
  private
    procedure ReceteleriYukle;
    procedure StokIstekleriniYukle;
    procedure SütunGenislikleriniAyarla;
    procedure BasliklariTurkceYap;
  public
    { Public declarations }
  end;

var
  Form9: TForm9;

implementation

{$R *.dfm}

uses Unit1;

{-------------------------------------------------------------------------------
  FormCreate: Bağlantılar ve bileşen eşitlemeleri kurulur
-------------------------------------------------------------------------------}
procedure TForm9.FormCreate(Sender: TObject);
begin
  Self.Caption := 'Geçmiş Sevk ve Gönderim İşlemleri';
  Self.Position := poScreenCenter;

  Self.Font.Name := 'Segoe UI';
  Self.Font.Size := 11;

  // Reçeteler Grid Font Ayarları
  dbGridReceteler.Font.Name := 'Segoe UI';
  dbGridReceteler.Font.Size := 11;
  dbGridReceteler.TitleFont.Name := 'Segoe UI';
  dbGridReceteler.TitleFont.Size := 11;
  dbGridReceteler.TitleFont.Style := [fsBold];

  // Stok İstekleri Grid Font Ayarları
  dbGridStokIstek.Font.Name := 'Segoe UI';
  dbGridStokIstek.Font.Size := 11;
  dbGridStokIstek.TitleFont.Name := 'Segoe UI';
  dbGridStokIstek.TitleFont.Size := 11;
  dbGridStokIstek.TitleFont.Style := [fsBold];

  if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
  begin
    qryReceteler.Connection := FrmLogin.FDConnection1;
    qryStokIstek.Connection := FrmLogin.FDConnection1;
  end
  else
  begin
    ShowMessage('DEBUG HATA: FrmLogin veya FDConnection1 bulunamadı!');
    Exit;
  end;

  if not qryReceteler.Connection.Connected then
    qryReceteler.Connection.Connected := True;

  dbGridReceteler.DataSource := DataSourceReceteler;
  DataSourceReceteler.DataSet := qryReceteler;

  dbGridStokIstek.DataSource := DataSourceStokIstek;
  DataSourceStokIstek.DataSet := qryStokIstek;

  edtServisAraRecete.Text := '';
  edtServisAraStok.Text := '';

  dtpTarihRecete.Date := Date;
  dtpTarihStok.Date := Date;
end;

{-------------------------------------------------------------------------------
  FormActivate: Form ekrana gelince veriler yüklenir
-------------------------------------------------------------------------------}
procedure TForm9.FormActivate(Sender: TObject);
begin
  if not qryReceteler.Active then
    ReceteleriYukle;

  if not qryStokIstek.Active then
    StokIstekleriniYukle;
end;

{-------------------------------------------------------------------------------
  FormClose: Form kapatılır
-------------------------------------------------------------------------------}
procedure TForm9.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

{-------------------------------------------------------------------------------
  🌟 Grid Başlıklarını Türkçe Yapma ve Koyu (Bold) Hale Getirme
-------------------------------------------------------------------------------}
procedure TForm9.BasliklariTurkceYap;
var
  i: Integer;
begin
  if dbGridReceteler.Columns.Count >= 10 then
  begin
    dbGridReceteler.Columns[0].Title.Caption := 'Gönderim Tarihi';
    dbGridReceteler.Columns[1].Title.Caption := 'Hasta Adı';
    dbGridReceteler.Columns[2].Title.Caption := 'Doktor Adı';
    dbGridReceteler.Columns[3].Title.Caption := 'Servis Adı';
    dbGridReceteler.Columns[4].Title.Caption := 'İlaç Adı';
    dbGridReceteler.Columns[5].Title.Caption := 'Etken Madde';
    dbGridReceteler.Columns[6].Title.Caption := 'Doz';
    dbGridReceteler.Columns[7].Title.Caption := 'Öğün';
    dbGridReceteler.Columns[8].Title.Caption := 'Adet';
    dbGridReceteler.Columns[9].Title.Caption := 'İşlemi Yapan Eczacı';

    // 🌟 Reçeteler grid başlıklarını tek tek koyu (bold) yap
    for i := 0 to dbGridReceteler.Columns.Count - 1 do
    begin
      dbGridReceteler.Columns[i].Title.Font.Name := 'Segoe UI';
      dbGridReceteler.Columns[i].Title.Font.Size := 11;
      dbGridReceteler.Columns[i].Title.Font.Style := [fsBold];
    end;
  end;

  if dbGridStokIstek.Columns.Count >= 7 then
  begin
    dbGridStokIstek.Columns[0].Title.Caption := 'Gönderim Tarihi';
    dbGridStokIstek.Columns[1].Title.Caption := 'Servis Adı';
    dbGridStokIstek.Columns[2].Title.Caption := 'Hemşire Adı';
    dbGridStokIstek.Columns[3].Title.Caption := 'İlaç Adı';
    dbGridStokIstek.Columns[4].Title.Caption := 'Etken Madde';
    dbGridStokIstek.Columns[5].Title.Caption := 'İstenen Miktar';
    dbGridStokIstek.Columns[6].Title.Caption := 'İşlemi Yapan Eczacı';

    // 🌟 Stok İstekleri grid başlıklarını tek tek koyu (bold) yap
    for i := 0 to dbGridStokIstek.Columns.Count - 1 do
    begin
      dbGridStokIstek.Columns[i].Title.Font.Name := 'Segoe UI';
      dbGridStokIstek.Columns[i].Title.Font.Size := 11;
      dbGridStokIstek.Columns[i].Title.Font.Style := [fsBold];
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Sütun Genişliklerini Ayarlama
-------------------------------------------------------------------------------}
procedure TForm9.SütunGenislikleriniAyarla;
var
  i: Integer;
begin
  for i := 0 to dbGridReceteler.Columns.Count - 1 do
  begin
    case i of
      0: dbGridReceteler.Columns[i].Width := 150; // Gönderim Tarihi
      1: dbGridReceteler.Columns[i].Width := 140; // Hasta Adı
      2: dbGridReceteler.Columns[i].Width := 140; // Doktor Adı
      3: dbGridReceteler.Columns[i].Width := 170; // Servis Adı
      4: dbGridReceteler.Columns[i].Width := 160; // İlaç Adı
      5: dbGridReceteler.Columns[i].Width := 160; // Etken Madde
      6: dbGridReceteler.Columns[i].Width := 80;  // Doz
      7: dbGridReceteler.Columns[i].Width := 140; // Öğün
      8: dbGridReceteler.Columns[i].Width := 60;  // Adet
      9: dbGridReceteler.Columns[i].Width := 170; // Eczacı Adı
    else
      dbGridReceteler.Columns[i].Width := 100;
    end;
  end;

  for i := 0 to dbGridStokIstek.Columns.Count - 1 do
  begin
    case i of
      0: dbGridStokIstek.Columns[i].Width := 150; // Gönderim Tarihi
      1: dbGridStokIstek.Columns[i].Width := 200; // Servis Adı
      2: dbGridStokIstek.Columns[i].Width := 160; // Hemşire Adı
      3: dbGridStokIstek.Columns[i].Width := 170; // İlaç Adı
      4: dbGridStokIstek.Columns[i].Width := 170; // Etken Madde
      5: dbGridStokIstek.Columns[i].Width := 130; // İstenen Miktar
      6: dbGridStokIstek.Columns[i].Width := 170; // Eczacı Adı
    else
      dbGridStokIstek.Columns[i].Width := 100;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  1. SEKME: Geçmiş Reçeteleri Yükle (Servis ve Tarih Filtreli)
-------------------------------------------------------------------------------}
procedure TForm9.ReceteleriYukle;
var
  ServisFiltre, TarihFiltre: string;
begin
  if not Assigned(qryReceteler.Connection) then Exit;

  ServisFiltre := Trim(edtServisAraRecete.Text);
  TarihFiltre := FormatDateTime('yyyy-mm-dd', dtpTarihRecete.Date);

  qryReceteler.Close;
  qryReceteler.SQL.Clear;

  qryReceteler.SQL.Add('SELECT');
  qryReceteler.SQL.Add('    CAST(SUBSTR(RD.GonderimTarihi, 1, 10) AS VARCHAR) AS [Gönderim Tarihi],');
  qryReceteler.SQL.Add('    CAST(H.Ad || '' '' || H.Soyad AS VARCHAR) AS [Hasta Adı],');
  qryReceteler.SQL.Add('    CAST(D.Ad || '' '' || D.Soyad AS VARCHAR) AS [Doktor Adı],');
  qryReceteler.SQL.Add('    CAST(COALESCE(Y.ServisAdi, ''Ayakta Tedavi'') AS VARCHAR) AS [Servis Adı],');
  qryReceteler.SQL.Add('    CAST(I.IlacAdi AS VARCHAR) AS [İlaç Adı],');
  qryReceteler.SQL.Add('    CAST(I.EtkenMadde AS VARCHAR) AS [Etken Madde],');
  qryReceteler.SQL.Add('    CAST(RD.Doz AS VARCHAR) AS Doz,');
  qryReceteler.SQL.Add('    CAST(RD.Ogun AS VARCHAR) AS Öğün,');
  qryReceteler.SQL.Add('    RD.Adet AS Adet,');
  qryReceteler.SQL.Add('    CAST(COALESCE(EC.Ad || '' '' || EC.Soyad, ''Bilinmiyor'') AS VARCHAR) AS [İşlemi Yapan Eczacı]');
  qryReceteler.SQL.Add('FROM RECETE_DETAY RD');
  qryReceteler.SQL.Add('JOIN RECETE R ON RD.ReceteID = R.ReceteID');
  qryReceteler.SQL.Add('JOIN HASTA H ON R.HastaID = H.HastaID');
  qryReceteler.SQL.Add('JOIN DOKTOR D ON R.DoktorID = D.DoktorID');
  qryReceteler.SQL.Add('JOIN ILAC I ON RD.IlacID = I.IlacID');
  qryReceteler.SQL.Add('LEFT JOIN YATIS Y ON H.HastaID = Y.HastaID AND Y.AktifMi = ''Evet''');
  qryReceteler.SQL.Add('LEFT JOIN ECZACI EC ON RD.EczaciID = EC.EczaciID');
  qryReceteler.SQL.Add('WHERE RD.Durum = ''Gonderildi''');
  qryReceteler.SQL.Add('  AND SUBSTR(RD.GonderimTarihi, 1, 10) = :pTarih');

  if ServisFiltre <> '' then
    qryReceteler.SQL.Add('  AND COALESCE(Y.ServisAdi, '''') LIKE :pServisFiltre');

  qryReceteler.SQL.Add('ORDER BY RD.GonderimTarihi DESC;');

  qryReceteler.ParamByName('pTarih').AsString := TarihFiltre;
  if ServisFiltre <> '' then
    qryReceteler.ParamByName('pServisFiltre').AsString := '%' + ServisFiltre + '%';

  try
    qryReceteler.Open;
    SütunGenislikleriniAyarla;
    BasliklariTurkceYap;
  except
    on E: Exception do
      ShowMessage('Geçmiş reçeteler yüklenirken hata oluştu: ' + E.Message);
  end;
end;

{-------------------------------------------------------------------------------
  2. SEKME: Geçmiş Stok İsteklerini Yükle (Servis ve Tarih Filtreli)
-------------------------------------------------------------------------------}
procedure TForm9.StokIstekleriniYukle;
var
  ServisFiltre, TarihFiltre: string;
begin
  if not Assigned(qryStokIstek.Connection) then Exit;

  ServisFiltre := Trim(edtServisAraStok.Text);
  TarihFiltre := FormatDateTime('yyyy-mm-dd', dtpTarihStok.Date);

  qryStokIstek.Close;
  qryStokIstek.SQL.Clear;

  qryStokIstek.SQL.Add('SELECT');
  qryStokIstek.SQL.Add('    CAST(SUBSTR(T.GonderimTarihi, 1, 10) AS VARCHAR) AS [Gönderim Tarihi],');
  qryStokIstek.SQL.Add('    CAST(HM.GorevliOlduguServis AS VARCHAR) AS [Servis Adı],');
  qryStokIstek.SQL.Add('    CAST(HM.Ad || '' '' || HM.Soyad AS VARCHAR) AS [Hemşire Adı],');
  qryStokIstek.SQL.Add('    CAST(I.IlacAdi AS VARCHAR) AS [İlaç Adı],');
  qryStokIstek.SQL.Add('    CAST(I.EtkenMadde AS VARCHAR) AS [Etken Madde],');
  qryStokIstek.SQL.Add('    T.IstenenMiktar AS [İstenen Miktar],');
  qryStokIstek.SQL.Add('    CAST(COALESCE(EC.Ad || '' '' || EC.Soyad, ''Bilinmiyor'') AS VARCHAR) AS [İşlemi Yapan Eczacı]');
  qryStokIstek.SQL.Add('FROM ECZANE_SEVK_TALEP T');
  qryStokIstek.SQL.Add('JOIN HEMSIRE HM ON T.HemsireID = HM.HemsireID');
  qryStokIstek.SQL.Add('JOIN ILAC I ON T.IlacID = I.IlacID');
  qryStokIstek.SQL.Add('LEFT JOIN ECZACI EC ON T.EczaciID = EC.EczaciID');
  qryStokIstek.SQL.Add('WHERE T.Durum = ''Gonderildi''');
  qryStokIstek.SQL.Add('  AND SUBSTR(T.GonderimTarihi, 1, 10) = :pTarih');

  if ServisFiltre <> '' then
    qryStokIstek.SQL.Add('  AND HM.GorevliOlduguServis LIKE :pServisFiltre');

  qryStokIstek.SQL.Add('ORDER BY T.GonderimTarihi DESC;');

  qryStokIstek.ParamByName('pTarih').AsString := TarihFiltre;
  if ServisFiltre <> '' then
    qryStokIstek.ParamByName('pServisFiltre').AsString := '%' + ServisFiltre + '%';

  try
    qryStokIstek.Open;
    SütunGenislikleriniAyarla;
    BasliklariTurkceYap;
  except
    on E: Exception do
      ShowMessage('Geçmiş stok istekleri yüklenirken hata oluştu: ' + E.Message);
  end;
end;

{-------------------------------------------------------------------------------
  Arama ve Tarih Değişiklik Olayları
-------------------------------------------------------------------------------}
procedure TForm9.edtServisAraReceteChange(Sender: TObject);
begin
  ReceteleriYukle;
end;

procedure TForm9.edtServisAraStokChange(Sender: TObject);
begin
  StokIstekleriniYukle;
end;

procedure TForm9.dtpTarihReceteChange(Sender: TObject);
begin
  ReceteleriYukle;
end;

procedure TForm9.dtpTarihStokChange(Sender: TObject);
begin
  StokIstekleriniYukle;
end;

end.
