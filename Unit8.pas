unit Unit8;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TForm8 = class(TForm)
    PageControl1: TPageControl;

    // 1. Sekme Bileşenleri (Doktor Reçeteleri)
    pnlReceteTop: TPanel;
    edtServisAraRecete: TEdit;
    Label1: TLabel;
    dbGridReceteler: TDBGrid;
    edtEczaciNotu: TMemo;
    btnReceteGonderildi: TPanel;
    Label3: TLabel;
    btnGecmisRecete: TPanel; // Geçmiş Butonu / Paneli

    // 2. Sekme Bileşenleri (Hemşire Stok İstekleri)
    dbGridStokIstek: TDBGrid;
    Panel3: TPanel;
    edtStokNotu: TMemo;
    btnStokGonderildi: TPanel;
    Label4: TLabel;
    pnlStokTop: TPanel;
    edtServisAraStok: TEdit;
    Label2: TLabel;
    btnGecmisStok: TPanel;   // Geçmiş Butonu / Paneli

    // Veritabanı Bileşenleri
    qryReceteler: TFDQuery;
    qryStokIstek: TFDQuery;
    DataSourceReceteler: TDataSource;
    DataSourceStokIstek: TDataSource;
    Panel1: TPanel;
    Panel2: TPanel; // 🌟 Tüm İlaçlar ve Stok Butonu / Paneli

    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnReceteGonderildiClick(Sender: TObject);
    procedure btnStokGonderildiClick(Sender: TObject);
    procedure dbGridRecetelerCellClick(Column: TColumn);
    procedure dbGridStokIstekCellClick(Column: TColumn);
    procedure edtServisAraReceteChange(Sender: TObject);
    procedure edtServisAraStokChange(Sender: TObject);
    procedure btnGecmisReceteClick(Sender: TObject);
    procedure btnGecmisStokClick(Sender: TObject);
    procedure btnIlacListesiClick(Sender: TObject);
  private
    procedure ReceteleriYukle;
    procedure StokIstekleriniYukle;
    procedure SütunGenislikleriniAyarla;
    procedure BasliklariTurkceYap;
  public
    { Public declarations }
    AktifEczaciID: Integer;
  end;

var
  Form8: TForm8;

implementation

{$R *.dfm}

uses Unit1, Unit9, Unit10;

{-------------------------------------------------------------------------------
  FormCreate: Bağlantılar ve bileşen eşitlemeleri kurulur
-------------------------------------------------------------------------------}
procedure TForm8.FormCreate(Sender: TObject);
begin
  Self.Caption := 'Eczane Yönetim ve Sevk Paneli';
  Self.Position := poScreenCenter;

  Self.Font.Name := 'Segoe UI';
  Self.Font.Size := 11;

  // 🌟 Reçeteler Grid Font Ayarları (Yazı Boyutu: 11, Başlıklar: 11 Bold)
  dbGridReceteler.Font.Name := 'Segoe UI';
  dbGridReceteler.Font.Size := 11;
  dbGridReceteler.TitleFont.Name := 'Segoe UI';
  dbGridReceteler.TitleFont.Size := 11;
  dbGridReceteler.TitleFont.Style := [fsBold];

  // 🌟 Stok İstekleri Grid Font Ayarları (Yazı Boyutu: 11, Başlıklar: 11 Bold)
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

  edtEczaciNotu.Clear;
  edtStokNotu.Clear;
end;

{-------------------------------------------------------------------------------
  FormActivate: Form ekrana gelince veriler yüklenir
-------------------------------------------------------------------------------}
procedure TForm8.FormActivate(Sender: TObject);
begin
  if not qryReceteler.Active then
    ReceteleriYukle;

  if not qryStokIstek.Active then
    StokIstekleriniYukle;
end;

{-------------------------------------------------------------------------------
  Çarpıya (X) basıldığında uygulamanın tamamen sonlandırılması
-------------------------------------------------------------------------------}
procedure TForm8.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Application.Terminate;
end;

{-------------------------------------------------------------------------------
  Geçmiş Reçeteler Paneline Tıklanınca Unit9'u Açma
-------------------------------------------------------------------------------}
procedure TForm8.btnGecmisReceteClick(Sender: TObject);
begin
  if not Assigned(Form9) then
    Application.CreateForm(TForm9, Form9);
  Form9.Show;
end;

{-------------------------------------------------------------------------------
  Geçmiş Stok Paneline Tıklanınca Unit9'u Açma
-------------------------------------------------------------------------------}
procedure TForm8.btnGecmisStokClick(Sender: TObject);
begin
  if not Assigned(Form9) then
    Application.CreateForm(TForm9, Form9);
  Form9.Show;
end;

{-------------------------------------------------------------------------------
  🌟 Tüm İlaçlar ve Stok Listesine Tıklanınca Unit10'u Açma
-------------------------------------------------------------------------------}
procedure TForm8.btnIlacListesiClick(Sender: TObject);
begin
  if not Assigned(Form10) then
    Application.CreateForm(TForm10, Form10);
  Form10.Show;
  Form10.BringToFront;
end;

{-------------------------------------------------------------------------------
  🌟 Grid Başlıklarını Türkçe Yapma ve Koyu (Bold) Hale Getirme
-------------------------------------------------------------------------------}
procedure TForm8.BasliklariTurkceYap;
var
  i: Integer;
begin
  if dbGridReceteler.Columns.Count >= 9 then
  begin
    dbGridReceteler.Columns[0].Title.Caption := 'Reçete Tarihi';
    dbGridReceteler.Columns[1].Title.Caption := 'Hasta Adı';
    dbGridReceteler.Columns[2].Title.Caption := 'Doktor Adı';
    dbGridReceteler.Columns[3].Title.Caption := 'Servis Adı';
    dbGridReceteler.Columns[4].Title.Caption := 'İlaç Adı';
    dbGridReceteler.Columns[5].Title.Caption := 'Etken Madde';
    dbGridReceteler.Columns[6].Title.Caption := 'Doz';
    dbGridReceteler.Columns[7].Title.Caption := 'Öğün';
    dbGridReceteler.Columns[8].Title.Caption := 'Adet';

    // 🌟 Reçeteler başlıklarını koyu (bold) yap
    for i := 0 to dbGridReceteler.Columns.Count - 1 do
    begin
      dbGridReceteler.Columns[i].Title.Font.Name := 'Segoe UI';
      dbGridReceteler.Columns[i].Title.Font.Size := 11;
      dbGridReceteler.Columns[i].Title.Font.Style := [fsBold];
    end;
  end;

  if dbGridStokIstek.Columns.Count >= 6 then
  begin
    dbGridStokIstek.Columns[0].Title.Caption := 'Talep Tarihi';
    dbGridStokIstek.Columns[1].Title.Caption := 'Servis Adı';
    dbGridStokIstek.Columns[2].Title.Caption := 'Hemşire Adı';
    dbGridStokIstek.Columns[3].Title.Caption := 'İlaç Adı';
    dbGridStokIstek.Columns[4].Title.Caption := 'Etken Madde';
    dbGridStokIstek.Columns[5].Title.Caption := 'İstenen Miktar';

    // 🌟 Stok İstek başlıklarını koyu (bold) yap
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
procedure TForm8.SütunGenislikleriniAyarla;
var
  i: Integer;
begin
  for i := 0 to dbGridReceteler.Columns.Count - 1 do
  begin
    case i of
      0: dbGridReceteler.Columns[i].Width := 120; // Reçete Tarihi
      1: dbGridReceteler.Columns[i].Width := 140; // Hasta Adı
      2: dbGridReceteler.Columns[i].Width := 140; // Doktor Adı
      3: dbGridReceteler.Columns[i].Width := 180; // Servis Adı
      4: dbGridReceteler.Columns[i].Width := 170; // İlaç Adı
      5: dbGridReceteler.Columns[i].Width := 170; // Etken Madde
      6: dbGridReceteler.Columns[i].Width := 90;  // Doz
      7: dbGridReceteler.Columns[i].Width := 160; // Öğün
      8: dbGridReceteler.Columns[i].Width := 60;  // Adet
    else
      dbGridReceteler.Columns[i].Width := 100;
    end;
  end;

  for i := 0 to dbGridStokIstek.Columns.Count - 1 do
  begin
    case i of
      0: dbGridStokIstek.Columns[i].Width := 120; // Talep Tarihi
      1: dbGridStokIstek.Columns[i].Width := 230; // Servis Adı
      2: dbGridStokIstek.Columns[i].Width := 170; // Hemşire Adı
      3: dbGridStokIstek.Columns[i].Width := 190; // İlaç Adı
      4: dbGridStokIstek.Columns[i].Width := 190; // Etken Madde
      5: dbGridStokIstek.Columns[i].Width := 140; // İstenen Miktar
    else
      dbGridStokIstek.Columns[i].Width := 100;
    end;
  end;
end;

procedure TForm8.ReceteleriYukle;
var
  ServisFiltre: string;
begin
  if not Assigned(qryReceteler.Connection) then Exit;

  ServisFiltre := Trim(edtServisAraRecete.Text);

  qryReceteler.Close;
  qryReceteler.SQL.Clear;

  if ServisFiltre = '' then
  begin
    qryReceteler.SQL.Add('SELECT');
    qryReceteler.SQL.Add('    CAST(SUBSTR(R.Tarih, 1, 10) AS VARCHAR) AS [Reçete Tarihi],');
    qryReceteler.SQL.Add('    CAST(H.Ad || '' '' || H.Soyad AS VARCHAR) AS [Hasta Adı],');
    qryReceteler.SQL.Add('    CAST(D.Ad || '' '' || D.Soyad AS VARCHAR) AS [Doktor Adı],');
    qryReceteler.SQL.Add('    CAST(COALESCE(Y.ServisAdi, ''Ayakta Tedavi'') AS VARCHAR) AS [Servis Adı],');
    qryReceteler.SQL.Add('    CAST(I.IlacAdi AS VARCHAR) AS [İlaç Adı],');
    qryReceteler.SQL.Add('    CAST(I.EtkenMadde AS VARCHAR) AS [Etken Madde],');
    qryReceteler.SQL.Add('    CAST(RD.Doz AS VARCHAR) AS Doz,');
    qryReceteler.SQL.Add('    CAST(RD.Ogun AS VARCHAR) AS Öğün,');
    qryReceteler.SQL.Add('    RD.Adet AS Adet');
    qryReceteler.SQL.Add('FROM RECETE_DETAY RD');
    qryReceteler.SQL.Add('JOIN RECETE R ON RD.ReceteID = R.ReceteID');
    qryReceteler.SQL.Add('JOIN HASTA H ON R.HastaID = H.HastaID');
    qryReceteler.SQL.Add('JOIN DOKTOR D ON R.DoktorID = D.DoktorID');
    qryReceteler.SQL.Add('JOIN ILAC I ON RD.IlacID = I.IlacID');
    qryReceteler.SQL.Add('LEFT JOIN YATIS Y ON H.HastaID = Y.HastaID AND Y.AktifMi = ''Evet''');
    qryReceteler.SQL.Add('WHERE RD.Durum = ''Beklemede''');
    qryReceteler.SQL.Add('ORDER BY R.Tarih DESC;');
  end
  else
  begin
    qryReceteler.SQL.Add('SELECT');
    qryReceteler.SQL.Add('    CAST(SUBSTR(R.Tarih, 1, 10) AS VARCHAR) AS [Reçete Tarihi],');
    qryReceteler.SQL.Add('    CAST(H.Ad || '' '' || H.Soyad AS VARCHAR) AS [Hasta Adı],');
    qryReceteler.SQL.Add('    CAST(D.Ad || '' '' || D.Soyad AS VARCHAR) AS [Doktor Adı],');
    qryReceteler.SQL.Add('    CAST(COALESCE(Y.ServisAdi, ''Ayakta Tedavi'') AS VARCHAR) AS [Servis Adı],');
    qryReceteler.SQL.Add('    CAST(I.IlacAdi AS VARCHAR) AS [İlaç Adı],');
    qryReceteler.SQL.Add('    CAST(I.EtkenMadde AS VARCHAR) AS [Etken Madde],');
    qryReceteler.SQL.Add('    CAST(RD.Doz AS VARCHAR) AS Doz,');
    qryReceteler.SQL.Add('    CAST(RD.Ogun AS VARCHAR) AS Öğün,');
    qryReceteler.SQL.Add('    RD.Adet AS Adet');
    qryReceteler.SQL.Add('FROM RECETE_DETAY RD');
    qryReceteler.SQL.Add('JOIN RECETE R ON RD.ReceteID = R.ReceteID');
    qryReceteler.SQL.Add('JOIN HASTA H ON R.HastaID = H.HastaID');
    qryReceteler.SQL.Add('JOIN DOKTOR D ON R.DoktorID = D.DoktorID');
    qryReceteler.SQL.Add('JOIN ILAC I ON RD.IlacID = I.IlacID');
    qryReceteler.SQL.Add('LEFT JOIN YATIS Y ON H.HastaID = Y.HastaID AND Y.AktifMi = ''Evet''');
    qryReceteler.SQL.Add('WHERE RD.Durum = ''Beklemede''');
    qryReceteler.SQL.Add('  AND COALESCE(Y.ServisAdi, '''') LIKE :pServisFiltre');
    qryReceteler.SQL.Add('ORDER BY R.Tarih DESC;');

    qryReceteler.ParamByName('pServisFiltre').AsString := '%' + ServisFiltre + '%';
  end;

  try
    qryReceteler.Open;
    SütunGenislikleriniAyarla;
    BasliklariTurkceYap;
  except
    on E: Exception do
      ShowMessage('Reçeteler yüklenirken hata oluştu: ' + E.Message);
  end;
end;

{-------------------------------------------------------------------------------
  2. SEKME: Stok İsteklerini Yükle
-------------------------------------------------------------------------------}
procedure TForm8.StokIstekleriniYukle;
var
  ServisFiltre: string;
begin
  if not Assigned(qryStokIstek.Connection) then Exit;

  ServisFiltre := Trim(edtServisAraStok.Text);

  qryStokIstek.Close;
  qryStokIstek.SQL.Clear;

  if ServisFiltre = '' then
  begin
    qryStokIstek.SQL.Add('SELECT');
    qryStokIstek.SQL.Add('    CAST(SUBSTR(T.TalepTarihi, 1, 10) AS VARCHAR) AS [Talep Tarihi],');
    qryStokIstek.SQL.Add('    CAST(HM.GorevliOlduguServis AS VARCHAR) AS [Servis Adı],');
    qryStokIstek.SQL.Add('    CAST(HM.Ad || '' '' || HM.Soyad AS VARCHAR) AS [Hemşire Adı],');
    qryStokIstek.SQL.Add('    CAST(I.IlacAdi AS VARCHAR) AS [İlaç Adı],');
    qryStokIstek.SQL.Add('    CAST(I.EtkenMadde AS VARCHAR) AS [Etken Madde],');
    qryStokIstek.SQL.Add('    T.IstenenMiktar AS [İstenen Miktar]');
    qryStokIstek.SQL.Add('FROM ECZANE_SEVK_TALEP T');
    qryStokIstek.SQL.Add('JOIN HEMSIRE HM ON T.HemsireID = HM.HemsireID');
    qryStokIstek.SQL.Add('JOIN ILAC I ON T.IlacID = I.IlacID');
    qryStokIstek.SQL.Add('WHERE T.Durum = ''Beklemede''');
    qryStokIstek.SQL.Add('ORDER BY T.TalepTarihi DESC;');
  end
  else
  begin
    qryStokIstek.SQL.Add('SELECT');
    qryStokIstek.SQL.Add('    CAST(SUBSTR(T.TalepTarihi, 1, 10) AS VARCHAR) AS [Talep Tarihi],');
    qryStokIstek.SQL.Add('    CAST(HM.GorevliOlduguServis AS VARCHAR) AS [Servis Adı],');
    qryStokIstek.SQL.Add('    CAST(HM.Ad || '' '' || HM.Soyad AS VARCHAR) AS [Hemşire Adı],');
    qryStokIstek.SQL.Add('    CAST(I.IlacAdi AS VARCHAR) AS [İlaç Adı],');
    qryStokIstek.SQL.Add('    CAST(I.EtkenMadde AS VARCHAR) AS [Etken Madde],');
    qryStokIstek.SQL.Add('    T.IstenenMiktar AS [İstenen Miktar]');
    qryStokIstek.SQL.Add('FROM ECZANE_SEVK_TALEP T');
    qryStokIstek.SQL.Add('JOIN HEMSIRE HM ON T.HemsireID = HM.HemsireID');
    qryStokIstek.SQL.Add('JOIN ILAC I ON T.IlacID = I.IlacID');
    qryStokIstek.SQL.Add('WHERE T.Durum = ''Beklemede''');
    qryStokIstek.SQL.Add('  AND HM.GorevliOlduguServis LIKE :pServisFiltre');
    qryStokIstek.SQL.Add('ORDER BY T.TalepTarihi DESC;');

    qryStokIstek.ParamByName('pServisFiltre').AsString := '%' + ServisFiltre + '%';
  end;

  try
    qryStokIstek.Open;
    SütunGenislikleriniAyarla;
    BasliklariTurkceYap;
  except
    on E: Exception do
      ShowMessage('Stok istekleri yüklenirken hata oluştu: ' + E.Message);
  end;
end;

{-------------------------------------------------------------------------------
  Anlık Arama Kutusu Değişiklik Olayları
-------------------------------------------------------------------------------}
procedure TForm8.edtServisAraReceteChange(Sender: TObject);
begin
  ReceteleriYukle;
end;

procedure TForm8.edtServisAraStokChange(Sender: TObject);
begin
  StokIstekleriniYukle;
end;

{-------------------------------------------------------------------------------
  Grid Hücre Tıklama Olayları
-------------------------------------------------------------------------------}
procedure TForm8.dbGridRecetelerCellClick(Column: TColumn);
var
  UpdateQuery: TFDQuery;
  HastaAdiStr, IlacAdiStr, TarihStr: string;
begin
  if qryReceteler.IsEmpty then Exit;

  HastaAdiStr := qryReceteler.FieldByName('Hasta Adı').AsString;
  IlacAdiStr := qryReceteler.FieldByName('İlaç Adı').AsString;
  TarihStr := qryReceteler.FieldByName('Reçete Tarihi').AsString;

  UpdateQuery := TFDQuery.Create(nil);
  try
    UpdateQuery.Connection := FrmLogin.FDConnection1;
    UpdateQuery.SQL.Text :=
      'SELECT RD.EczaciNotu FROM RECETE_DETAY RD ' +
      'JOIN RECETE R ON RD.ReceteID = R.ReceteID ' +
      'JOIN HASTA H ON R.HastaID = H.HastaID ' +
      'JOIN ILAC I ON RD.IlacID = I.IlacID ' +
      'WHERE RD.Durum = ''Beklemede'' AND I.IlacAdi = :IlacAdi AND (H.Ad || '' '' || H.Soyad) = :HastaAdi AND SUBSTR(R.Tarih, 1, 10) = :Tarih LIMIT 1;';

    UpdateQuery.ParamByName('IlacAdi').AsString := IlacAdiStr;
    UpdateQuery.ParamByName('HastaAdi').AsString := HastaAdiStr;
    UpdateQuery.ParamByName('Tarih').AsString := TarihStr;
    UpdateQuery.Open;

    if not UpdateQuery.IsEmpty then
      edtEczaciNotu.Text := UpdateQuery.FieldByName('EczaciNotu').AsString;
  finally
    UpdateQuery.Free;
  end;
end;

procedure TForm8.dbGridStokIstekCellClick(Column: TColumn);
var
  UpdateQuery: TFDQuery;
  HemsireAdiStr, IlacAdiStr, TarihStr: string;
begin
  if qryStokIstek.IsEmpty then Exit;

  HemsireAdiStr := qryStokIstek.FieldByName('Hemşire Adı').AsString;
  IlacAdiStr := qryStokIstek.FieldByName('İlaç Adı').AsString;
  TarihStr := qryStokIstek.FieldByName('Talep Tarihi').AsString;

  UpdateQuery := TFDQuery.Create(nil);
  try
    UpdateQuery.Connection := FrmLogin.FDConnection1;
    UpdateQuery.SQL.Text :=
      'SELECT T.RedSebebi FROM ECZANE_SEVK_TALEP T ' +
      'JOIN HEMSIRE HM ON T.HemsireID = HM.HemsireID ' +
      'JOIN ILAC I ON T.IlacID = I.IlacID ' +
      'WHERE T.Durum = ''Beklemede'' AND I.IlacAdi = :IlacAdi AND (HM.Ad || '' '' || HM.Soyad) = :HemsireAdi AND SUBSTR(T.TalepTarihi, 1, 10) = :Tarih LIMIT 1;';

    UpdateQuery.ParamByName('IlacAdi').AsString := IlacAdiStr;
    UpdateQuery.ParamByName('HemsireAdi').AsString := HemsireAdiStr;
    UpdateQuery.ParamByName('Tarih').AsString := TarihStr;
    UpdateQuery.Open;

    if not UpdateQuery.IsEmpty then
      edtStokNotu.Text := UpdateQuery.FieldByName('RedSebebi').AsString;
  finally
    UpdateQuery.Free;
  end;
end;

{-------------------------------------------------------------------------------
  🌟 Seçilen Reçetenin Gönderilmesi (FIFO / Parti ve Servis Stok Entegrasyonlu)
-------------------------------------------------------------------------------}
procedure TForm8.btnReceteGonderildiClick(Sender: TObject);
var
  UpdateQuery: TFDQuery;
  HastaAdiStr, IlacAdiStr, TarihStr, ServisAdiStr: string;
  IlacID, Adet, PartiID: Integer;
begin
  if qryReceteler.IsEmpty then
  begin
    ShowMessage('İşlem yapılacak ilaç seçilmedi!');
    Exit;
  end;

  HastaAdiStr := qryReceteler.FieldByName('Hasta Adı').AsString;
  IlacAdiStr := qryReceteler.FieldByName('İlaç Adı').AsString;
  TarihStr := qryReceteler.FieldByName('Reçete Tarihi').AsString;
  ServisAdiStr := qryReceteler.FieldByName('Servis Adı').AsString;

  UpdateQuery := TFDQuery.Create(nil);
  try
    UpdateQuery.Connection := FrmLogin.FDConnection1;

    // 1. İlgili İlaç ID ve Adet bilgilerini alalım
    UpdateQuery.SQL.Text :=
      'SELECT RD.DetayID, RD.IlacID, RD.Adet FROM RECETE_DETAY RD ' +
      'JOIN RECETE R ON RD.ReceteID = R.ReceteID ' +
      'JOIN HASTA H ON R.HastaID = H.HastaID ' +
      'JOIN ILAC I ON RD.IlacID = I.IlacID ' +
      'WHERE RD.Durum = ''Beklemede'' AND I.IlacAdi = :IlacAdi AND (H.Ad || '' '' || H.Soyad) = :HastaAdi AND SUBSTR(R.Tarih, 1, 10) = :Tarih LIMIT 1;';
    UpdateQuery.ParamByName('IlacAdi').AsString := IlacAdiStr;
    UpdateQuery.ParamByName('HastaAdi').AsString := HastaAdiStr;
    UpdateQuery.ParamByName('Tarih').AsString := TarihStr;
    UpdateQuery.Open;

    if UpdateQuery.IsEmpty then
    begin
      ShowMessage('Seçilen reçete kaydı bulunamadı.');
      Exit;
    end;

    IlacID := UpdateQuery.FieldByName('IlacID').AsInteger;
    Adet := UpdateQuery.FieldByName('Adet').AsInteger;
    if Adet <= 0 then Adet := 1;

    // 2. Reçete Detay Durumunu 'Gonderildi' Olarak Güncelle
    UpdateQuery.Close;
    UpdateQuery.SQL.Text :=
      'UPDATE RECETE_DETAY ' +
      'SET Durum = ''Gonderildi'', EczaciNotu = :Not, ' +
      '    GonderimTarihi = datetime(''now'', ''localtime''), EczaciID = :EczaciID ' +
      'WHERE Durum = ''Beklemede'' ' +
      '  AND IlacID = :IlacID ' +
      '  AND ReceteID IN (SELECT R.ReceteID FROM RECETE R JOIN HASTA H ON R.HastaID = H.HastaID WHERE (H.Ad || '' '' || H.Soyad) = :HastaAdi AND SUBSTR(R.Tarih, 1, 10) = :Tarih);';

    UpdateQuery.ParamByName('Not').AsString := Trim(edtEczaciNotu.Text);
    UpdateQuery.ParamByName('EczaciID').AsInteger := AktifEczaciID;
    UpdateQuery.ParamByName('IlacID').AsInteger := IlacID;
    UpdateQuery.ParamByName('HastaAdi').AsString := HastaAdiStr;
    UpdateQuery.ParamByName('Tarih').AsString := TarihStr;
    UpdateQuery.ExecSQL;

    // 🌟 3. FIFO MANTIĞI: ILAC_PARTI Tablosundan En Yakın Miatlı Partiden Düş
    UpdateQuery.Close;
    UpdateQuery.SQL.Text :=
      'SELECT PartiID FROM ILAC_PARTI ' +
      'WHERE IlacID = :pIlacID AND KalanMiktar > 0 ' +
      'ORDER BY SonKullanmaTarihi ASC, GirisTarihi ASC LIMIT 1;';
    UpdateQuery.ParamByName('pIlacID').AsInteger := IlacID;
    UpdateQuery.Open;

    if not UpdateQuery.IsEmpty then
    begin
      PartiID := UpdateQuery.FieldByName('PartiID').AsInteger;

      UpdateQuery.Close;
      UpdateQuery.SQL.Text :=
        'UPDATE ILAC_PARTI SET KalanMiktar = KalanMiktar - :pAdet, Miktar = Miktar - :pAdet ' +
        'WHERE PartiID = :pPartiID;';
      UpdateQuery.ParamByName('pAdet').AsInteger := Adet;
      UpdateQuery.ParamByName('pPartiID').AsInteger := PartiID;
      UpdateQuery.ExecSQL;
    end;

    // 🌟 4. Servis Stok Miktarını Güncelle (Eğer servis stok kaydı varsa artır, yoksa oluştur)
    if ServisAdiStr <> 'Ayakta Tedavi' then
    begin
      UpdateQuery.Close;
      UpdateQuery.SQL.Text :=
        'UPDATE SERVIS_STOK SET MevcutMiktar = MevcutMiktar + :pAdet ' +
        'WHERE LOWER(TRIM(ServisAdi)) LIKE LOWER(:pServis) AND IlacID = :pIlacID;';
      UpdateQuery.ParamByName('pAdet').AsInteger := Adet;
      UpdateQuery.ParamByName('pServis').AsString := '%' + Trim(ServisAdiStr) + '%';
      UpdateQuery.ParamByName('pIlacID').AsInteger := IlacID;
      UpdateQuery.ExecSQL;
    end;

    ShowMessage('Seçilen reçete detayı karşılandı ve sevk edildi! ✅');
    edtEczaciNotu.Clear;
    ReceteleriYukle;
  finally
    UpdateQuery.Free;
  end;
end;

{-------------------------------------------------------------------------------
  🌟 Seçilen Stok Talebinin Gönderilmesi (FIFO / Parti ve Servis Stok Entegrasyonlu)
-------------------------------------------------------------------------------}
procedure TForm8.btnStokGonderildiClick(Sender: TObject);
var
  UpdateQuery: TFDQuery;
  HemsireAdiStr, IlacAdiStr, TarihStr, ServisAdiStr: string;
  IlacID, Adet, PartiID: Integer;
begin
  if qryStokIstek.IsEmpty then
  begin
    ShowMessage('İşlem yapılacak talep seçilmedi!');
    Exit;
  end;

  HemsireAdiStr := qryStokIstek.FieldByName('Hemşire Adı').AsString;
  IlacAdiStr := qryStokIstek.FieldByName('İlaç Adı').AsString;
  TarihStr := qryStokIstek.FieldByName('Talep Tarihi').AsString;
  ServisAdiStr := qryStokIstek.FieldByName('Servis Adı').AsString;

  UpdateQuery := TFDQuery.Create(nil);
  try
    UpdateQuery.Connection := FrmLogin.FDConnection1;

    // 1. İlaç ID ve İstenen Miktarı Alalım
    UpdateQuery.SQL.Text :=
      'SELECT T.TalepID, T.IlacID, T.IstenenMiktar FROM ECZANE_SEVK_TALEP T ' +
      'JOIN HEMSIRE HM ON T.HemsireID = HM.HemsireID ' +
      'JOIN ILAC I ON T.IlacID = I.IlacID ' +
      'WHERE T.Durum = ''Beklemede'' AND I.IlacAdi = :IlacAdi AND (HM.Ad || '' '' || HM.Soyad) = :HemsireAdi AND SUBSTR(T.TalepTarihi, 1, 10) = :Tarih LIMIT 1;';
    UpdateQuery.ParamByName('IlacAdi').AsString := IlacAdiStr;
    UpdateQuery.ParamByName('HemsireAdi').AsString := HemsireAdiStr;
    UpdateQuery.ParamByName('Tarih').AsString := TarihStr;
    UpdateQuery.Open;

    if UpdateQuery.IsEmpty then
    begin
      ShowMessage('Seçilen talep kaydı bulunamadı.');
      Exit;
    end;

    IlacID := UpdateQuery.FieldByName('IlacID').AsInteger;
    Adet := UpdateQuery.FieldByName('IstenenMiktar').AsInteger;
    if Adet <= 0 then Adet := 1;

    // 2. Sevk Talebini 'Gonderildi' Olarak Güncelle
    UpdateQuery.Close;
    UpdateQuery.SQL.Text :=
      'UPDATE ECZANE_SEVK_TALEP ' +
      'SET Durum = ''Gonderildi'', RedSebebi = :Not, ' +
      '    GonderimTarihi = datetime(''now'', ''localtime''), EczaciID = :EczaciID ' +
      'WHERE Durum = ''Beklemede'' ' +
      '  AND IlacID = :IlacID ' +
      '  AND HemsireID IN (SELECT HemsireID FROM HEMSIRE WHERE (Ad || '' '' || Soyad) = :HemsireAdi) ' +
      '  AND SUBSTR(TalepTarihi, 1, 10) = :Tarih;';

    UpdateQuery.ParamByName('Not').AsString := Trim(edtStokNotu.Text);
    UpdateQuery.ParamByName('EczaciID').AsInteger := AktifEczaciID;
    UpdateQuery.ParamByName('IlacID').AsInteger := IlacID;
    UpdateQuery.ParamByName('HemsireAdi').AsString := HemsireAdiStr;
    UpdateQuery.ParamByName('Tarih').AsString := TarihStr;
    UpdateQuery.ExecSQL;

    // 🌟 3. FIFO MANTIĞI: ILAC_PARTI Tablosundan Düşüş Yap
    UpdateQuery.Close;
    UpdateQuery.SQL.Text :=
      'SELECT PartiID FROM ILAC_PARTI ' +
      'WHERE IlacID = :pIlacID AND KalanMiktar > 0 ' +
      'ORDER BY SonKullanmaTarihi ASC, GirisTarihi ASC LIMIT 1;';
    UpdateQuery.ParamByName('pIlacID').AsInteger := IlacID;
    UpdateQuery.Open;

    if not UpdateQuery.IsEmpty then
    begin
      PartiID := UpdateQuery.FieldByName('PartiID').AsInteger;

      UpdateQuery.Close;
      UpdateQuery.SQL.Text :=
        'UPDATE ILAC_PARTI SET KalanMiktar = KalanMiktar - :pAdet, Miktar = Miktar - :pAdet ' +
        'WHERE PartiID = :pPartiID;';
      UpdateQuery.ParamByName('pAdet').AsInteger := Adet;
      UpdateQuery.ParamByName('pPartiID').AsInteger := PartiID;
      UpdateQuery.ExecSQL;
    end;

    // 🌟 4. Servis Stoğunu Güncelle
    UpdateQuery.Close;
    UpdateQuery.SQL.Text :=
      'UPDATE SERVIS_STOK SET MevcutMiktar = MevcutMiktar + :pAdet ' +
      'WHERE LOWER(TRIM(ServisAdi)) LIKE LOWER(:pServis) AND IlacID = :pIlacID;';
    UpdateQuery.ParamByName('pAdet').AsInteger := Adet;
    UpdateQuery.ParamByName('pServis').AsString := '%' + Trim(ServisAdiStr) + '%';
    UpdateQuery.ParamByName('pIlacID').AsInteger := IlacID;
    UpdateQuery.ExecSQL;

    ShowMessage('Stok talebi sevk edildi! ✅');
    edtStokNotu.Clear;
    StokIstekleriniYukle;
  finally
    UpdateQuery.Free;
  end;
end;

end.
