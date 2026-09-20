unit Unit6;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TForm6 = class(TForm)
    pageControl: TPageControl;
    tabStoklar: TTabSheet;
    tabTalepler: TTabSheet;

    pnlStokUst: TPanel;
    edtArama: TEdit;         // Stok Arama Kutusu
    edtTalepArama: TEdit;    // Talep Arama Kutusu
    btnTalepEt: TPanel;

    dbgStoklar: TDBGrid;
    dbgTalepler: TDBGrid;

    qryStokListesi: TFDQuery;
    dsStokListesi: TDataSource;
    qryTalepGecmisi: TFDQuery;
    dsTalepGecmisi: TDataSource;
    qryIslem: TFDQuery;

    procedure FormShow(Sender: TObject);
    procedure dbgStoklarCellClick(Column: TColumn);
    procedure btnTalepEtClick(Sender: TObject);
    procedure dbgStoklarDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure dbgTaleplerDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure pageControlChange(Sender: TObject);
    procedure edtAramaChange(Sender: TObject);
    procedure edtTalepAramaChange(Sender: TObject);
  private
    { Private declarations }
    FSeciliIlacID: Integer;
    FSeciliIlacAdi: string;

    procedure StokListesiniYukle;
    procedure TalepGecmisiniYukle;
    procedure SutunGenislikleriniAyarla;
    function TurkceKarakterDuzelt(const S: string): string;
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.dfm}

uses Unit1;

function TForm6.TurkceKarakterDuzelt(const S: string): string;
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

procedure TForm6.FormShow(Sender: TObject);
begin
  Caption := 'Servis İlaç Stok ve Eczane Talep Yönetimi';
  Position := poScreenCenter;

  Font.Size := 11;
  Font.Name := 'Segoe UI';

  dbgStoklar.Font.Size := 11;
  dbgStoklar.TitleFont.Size := 11;
  dbgStoklar.TitleFont.Style := [fsBold];

  dbgTalepler.Font.Size := 11;
  dbgTalepler.TitleFont.Size := 11;
  dbgTalepler.TitleFont.Style := [fsBold];

  dbgStoklar.OnDrawColumnCell := dbgStoklarDrawColumnCell;
  dbgStoklar.OnCellClick := dbgStoklarCellClick;
  dbgTalepler.OnDrawColumnCell := dbgTaleplerDrawColumnCell;

  if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
  begin
    qryStokListesi.Connection := FrmLogin.FDConnection1;
    qryTalepGecmisi.Connection := FrmLogin.FDConnection1;
    qryIslem.Connection := FrmLogin.FDConnection1;
  end;

  dbgStoklar.DataSource := dsStokListesi;
  dbgTalepler.DataSource := dsTalepGecmisi;

  FSeciliIlacID := 0;
  FSeciliIlacAdi := '';

  StokListesiniYukle;
  TalepGecmisiniYukle;

  // 🌟 AÇILIŞTA İLK SEKMEYİ (STOKLAR) AKTİF YAP
  if Assigned(pageControl) then
    pageControl.ActivePageIndex := 0;
end;

// 1. SERVİS İLAÇ STOKLARI (SKT SÜTUNU EKLENDİ)
procedure TForm6.StokListesiniYukle;
var
  AramaKelimesi, AktifServis, SqlWhere: string;
begin
  AramaKelimesi := Trim(edtArama.Text);

  AktifServis := 'Dahiliye';
  if Assigned(FrmLogin) and (Trim(FrmLogin.GirisYapanServisAdi) <> '') then
    AktifServis := FrmLogin.GirisYapanServisAdi;

  SqlWhere := 'WHERE LOWER(TRIM(SS.ServisAdi)) LIKE LOWER(:pServis) ';

  if AramaKelimesi <> '' then
  begin
    SqlWhere := SqlWhere + ' AND (I.IlacAdi LIKE :pArama OR I.EtkenMadde LIKE :pArama) ';
  end;

  qryStokListesi.Close;
  qryStokListesi.SQL.Text :=
    'SELECT ' +
    '   COALESCE(I.IlacAdi, ''İlaç ID: '' || SS.IlacID) AS [İlaç Adı], ' +
    '   COALESCE(I.EtkenMadde, ''Belirtilmemiş'') AS [Etken Madde], ' +
    '   SS.MevcutMiktar AS [Mevcut Adet], ' +
    '   SS.KritikEsikMiktari AS [Kritik Düzey], ' +
    '   COALESCE((SELECT MIN(P.SonKullanmaTarihi) FROM ILAC_PARTI P WHERE P.IlacID = SS.IlacID AND P.KalanMiktar > 0), ''Yok'') AS [En Yakın SKT], ' +
    '   SS.IlacID ' +
    'FROM SERVIS_STOK SS ' +
    'LEFT JOIN ILAC I ON SS.IlacID = I.IlacID ' +
    SqlWhere +
    'ORDER BY SS.MevcutMiktar ASC;';

  qryStokListesi.ParamByName('pServis').AsString := '%' + Trim(AktifServis) + '%';
  if AramaKelimesi <> '' then
    qryStokListesi.ParamByName('pArama').AsString := '%' + AramaKelimesi + '%';

  try
    qryStokListesi.Open;
    SutunGenislikleriniAyarla;
  except
    on E: Exception do
      ShowMessage('Stok Liste Hatası: ' + E.Message);
  end;
end;

// 2. ECZANE TALEP GEÇMİŞİ
procedure TForm6.TalepGecmisiniYukle;
var
  AramaKelimesi, AktifServis, SqlWhere: string;
begin
  if Assigned(edtTalepArama) then
    AramaKelimesi := Trim(edtTalepArama.Text)
  else
    AramaKelimesi := '';

  AktifServis := 'Dahiliye';
  if Assigned(FrmLogin) and (Trim(FrmLogin.GirisYapanServisAdi) <> '') then
    AktifServis := FrmLogin.GirisYapanServisAdi;

  SqlWhere := 'WHERE LOWER(TRIM(H.GorevliOlduguServis)) LIKE LOWER(:pServis) ';

  if AramaKelimesi <> '' then
  begin
    SqlWhere := SqlWhere + ' AND (I.IlacAdi LIKE :pArama OR I.EtkenMadde LIKE :pArama) ';
  end;

  qryTalepGecmisi.Close;
  qryTalepGecmisi.SQL.Text :=
    'SELECT ' +
    '   COALESCE(I.IlacAdi, ''İlaç ID: '' || EST.IlacID) AS [İlaç Adı], ' +
    '   COALESCE(I.EtkenMadde, ''Belirtilmemiş'') AS [Etken Madde], ' +
    '   CAST(EST.Durum AS VARCHAR(50)) AS [Durum], ' +
    '   COALESCE(H.Ad || '' '' || H.Soyad, ''Hemşire ID: '' || EST.HemsireID) AS [Hemşire], ' +
    '   EST.IstenenMiktar AS [Adet], ' +
    '   COALESCE(SUBSTR(EST.TalepTarihi, 1, 10), ''Tarih Yok'') AS [Tarih] ' +
    'FROM ECZANE_SEVK_TALEP EST ' +
    'LEFT JOIN ILAC I ON EST.IlacID = I.IlacID ' +
    'LEFT JOIN HEMSIRE H ON EST.HemsireID = H.HemsireID ' +
    SqlWhere +
    'ORDER BY EST.TalepID DESC;';

  qryTalepGecmisi.ParamByName('pServis').AsString := '%' + Trim(AktifServis) + '%';
  if AramaKelimesi <> '' then
    qryTalepGecmisi.ParamByName('pArama').AsString := '%' + AramaKelimesi + '%';

  try
    qryTalepGecmisi.Open;
    SutunGenislikleriniAyarla;
  except
    on E: Exception do
      ShowMessage('Talep Geçmişi Hatası: ' + E.Message);
  end;
end;

procedure TForm6.edtAramaChange(Sender: TObject);
begin
  StokListesiniYukle;
end;

procedure TForm6.edtTalepAramaChange(Sender: TObject);
begin
  TalepGecmisiniYukle;
end;

procedure TForm6.pageControlChange(Sender: TObject);
begin
  if pageControl.ActivePage = tabTalepler then
    TalepGecmisiniYukle
  else if pageControl.ActivePage = tabStoklar then
    StokListesiniYukle;
end;

procedure TForm6.SutunGenislikleriniAyarla;
begin
  if (Assigned(dbgStoklar.Columns)) and (dbgStoklar.Columns.Count >= 5) then
  begin
    dbgStoklar.Columns[0].Width := 240; // İlaç Adı
    dbgStoklar.Columns[1].Width := 220; // Etken Madde
    dbgStoklar.Columns[2].Width := 110; // Mevcut Adet
    dbgStoklar.Columns[3].Width := 110; // Kritik Düzey
    dbgStoklar.Columns[4].Width := 140; // En Yakın SKT

    if dbgStoklar.Columns.Count > 5 then
      dbgStoklar.Columns[5].Visible := False; // IlacID gizli
  end;

  if (Assigned(dbgTalepler.Columns)) and (dbgTalepler.Columns.Count >= 6) then
  begin
    dbgTalepler.Columns[0].Width := 220;
    dbgTalepler.Columns[1].Width := 200;
    dbgTalepler.Columns[2].Width := 120;
    dbgTalepler.Columns[3].Width := 160;
    dbgTalepler.Columns[4].Width := 70;
    dbgTalepler.Columns[5].Width := 120;

    dbgTalepler.Columns[4].Alignment := taLeftJustify;
    dbgTalepler.Columns[4].Title.Alignment := taLeftJustify;
  end;
end;

procedure TForm6.dbgStoklarCellClick(Column: TColumn);
begin
  if not qryStokListesi.IsEmpty then
  begin
    FSeciliIlacID := qryStokListesi.FieldByName('IlacID').AsInteger;
    FSeciliIlacAdi := TurkceKarakterDuzelt(qryStokListesi.FieldByName('İlaç Adı').AsString);
  end;
end;

procedure TForm6.btnTalepEtClick(Sender: TObject);
var
  MiktarStr: string;
  Miktar, HemsireID: Integer;
begin
  if FSeciliIlacID = 0 then
  begin
    ShowMessage('Lütfen önce aşağıdaki tablodan talep etmek istediğiniz ilacı seçiniz!');
    Exit;
  end;

  MiktarStr := '10';

  if InputQuery('Eczane İlaç Talebi',
                '(' + FSeciliIlacAdi + ') ilacından kaç adet sevk edilmesini istiyorsunuz?',
                MiktarStr) then
  begin
    Miktar := StrToIntDef(Trim(MiktarStr), 0);

    if Miktar <= 0 then
    begin
      ShowMessage('Geçersiz adet girdiniz.');
      Exit;
    end;

    HemsireID := 1;
    if Assigned(FrmLogin) and (FrmLogin.GirisYapanHemsireID > 0) then
      HemsireID := FrmLogin.GirisYapanHemsireID;

    try
      qryIslem.Close;
      qryIslem.SQL.Text :=
        'INSERT INTO ECZANE_SEVK_TALEP (HemsireID, IlacID, IstenenMiktar, Durum, TalepTarihi) ' +
        'VALUES (:pHemsireID, :pIlacID, :pMiktar, ''Beklemede'', DATETIME(''now'', ''localtime''));';
      qryIslem.ParamByName('pHemsireID').AsInteger := HemsireID;
      qryIslem.ParamByName('pIlacID').AsInteger := FSeciliIlacID;
      qryIslem.ParamByName('pMiktar').AsInteger := Miktar;
      qryIslem.ExecSQL;

      ShowMessage('✅ "' + FSeciliIlacAdi + '" ilacından ' + IntToStr(Miktar) + ' adet sevk talebi başarıyla oluşturuldu.');

      TalepGecmisiniYukle;
      pageControl.ActivePage := tabTalepler;
    except
      on E: Exception do
        ShowMessage('Talep oluşturulurken hata oluştu: ' + E.Message);
    end;
  end;
end;

{-------------------------------------------------------------------------------
  🌟 Stok ve SKT (Miat) Durumuna Göre Renklendirme Mantığı (3 Aşamalı)
-------------------------------------------------------------------------------}
procedure TForm6.dbgStoklarDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Mevcut, Kritik: Integer;
  SktStr: string;
  SktTarihi, Bugün, OtuzGunSonra: TDateTime;
  SktGecmis, SktYakin: Boolean;
begin
  if (Assigned(qryStokListesi)) and (not qryStokListesi.IsEmpty) then
  begin
    Mevcut := qryStokListesi.FieldByName('Mevcut Adet').AsInteger;
    Kritik := qryStokListesi.FieldByName('Kritik Düzey').AsInteger;
    SktStr := Trim(qryStokListesi.FieldByName('En Yakın SKT').AsString);

    // SKT Hesaplamaları
    SktGecmis := False;
    SktYakin := False;

    if (SktStr <> '') and (SktStr <> 'Yok') then
    begin
      Bugün := Date;
      OtuzGunSonra := Bugün + 30;
      if TryStrToDate(SktStr, SktTarihi) then
      begin
        if SktTarihi < Bugün then
          SktGecmis := True
        else if SktTarihi <= OtuzGunSonra then
          SktYakin := True;
      end;
    end;

    // Satır seçili değilse renkleri uygula
    if not (gdSelected in State) then
    begin
      // 1. KRİTİK SEVİYE 1 (Koyu Kırmızı): SKT Geçmiş veya Stok Biten (0 olan) İlaçlar
      if SktGecmis or (Mevcut <= 0) then
      begin
        dbgStoklar.Canvas.Brush.Color := $0000008B; // Koyu Kırmızı
        dbgStoklar.Canvas.Font.Color := clWhite;
        dbgStoklar.Canvas.Font.Style := [fsBold];
      end
      // 2. KRİTİK SEVİYE 2 (Açık Kırmızı / Pembe): SKT Yaklaşan (<30 Gün) veya Stok < Kritik
      else if SktYakin or (Mevcut < Kritik) then
      begin
        dbgStoklar.Canvas.Brush.Color := $00C0C0FF; // Açık Kırmızı / Pembe
        dbgStoklar.Canvas.Font.Color := clMaroon;
        dbgStoklar.Canvas.Font.Style := [fsBold];
      end
      // 3. KRİTİK SEVİYE 3 (Sarı): Stok = Kritik Eşik
      else if Mevcut = Kritik then
      begin
        dbgStoklar.Canvas.Brush.Color := $0080FFFF; // Sarı
        dbgStoklar.Canvas.Font.Color := $00003366;
        dbgStoklar.Canvas.Font.Style := [fsBold];
      end;
    end;
  end;

  dbgStoklar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TForm6.dbgTaleplerDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if Column.FieldName = 'Adet' then
  begin
    Column.Alignment := taLeftJustify;
  end;
  dbgTalepler.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

initialization
  RegisterClasses([TPageControl, TTabSheet, TPanel, TLabel, TButton, TEdit, TDBGrid]);

end.
