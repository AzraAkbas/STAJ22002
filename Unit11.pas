unit Unit11;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.ComCtrls;

type
  TForm11 = class(TForm)
    pnlTop: TPanel;
    edtGecmisAra: TEdit;
    Label1: TLabel;
    dbGridGecmis: TDBGrid;
    qryGecmis: TFDQuery;
    DataSourceGecmis: TDataSource;
    dtpGecmisTarih: TDateTimePicker;
    Label2: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edtGecmisAraChange(Sender: TObject);
    procedure dtpGecmisTarihChange(Sender: TObject);
    procedure dbGridGecmisDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure dbGridGecmisDblClick(Sender: TObject); // 🌟 Çift Tıklama Garantili Yöntem
  private
    procedure GecmisTalepleriYukle;
    procedure SütunGenislikleriniAyarla;
    procedure BasliklariTurkceYap;
  public
    { Public declarations }
    AktifEczaciID: Integer;
  end;

var
  Form11: TForm11;

implementation

{$R *.dfm}

uses Unit1;

{-------------------------------------------------------------------------------
  FormCreate: Bağlantı ve olay atamaları
-------------------------------------------------------------------------------}
procedure TForm11.FormCreate(Sender: TObject);
begin
  Self.Caption := 'Ecza Deposu Talep Geçmişi ve Teslimat';
  Self.Position := poScreenCenter;

  Self.Font.Name := 'Segoe UI';
  Self.Font.Size := 11;

  if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
  begin
    qryGecmis.Connection := FrmLogin.FDConnection1;
  end
  else
  begin
    ShowMessage('DEBUG HATA: FrmLogin veya FDConnection1 bulunamadı!');
    Exit;
  end;

  if not qryGecmis.Connection.Connected then
    qryGecmis.Connection.Connected := True;

  dbGridGecmis.DataSource := DataSourceGecmis;
  DataSourceGecmis.DataSet := qryGecmis;

  // 🌟 Talep Geçmişi Grid Font Ayarları (Yazı Boyutu: 11, Başlıklar: 11 Bold)
  dbGridGecmis.Font.Name := 'Segoe UI';
  dbGridGecmis.Font.Size := 11;
  dbGridGecmis.TitleFont.Name := 'Segoe UI';
  dbGridGecmis.TitleFont.Size := 11;
  dbGridGecmis.TitleFont.Style := [fsBold];

  dbGridGecmis.OnDrawColumnCell := dbGridGecmisDrawColumnCell;
  dbGridGecmis.OnDblClick := dbGridGecmisDblClick;

  edtGecmisAra.Text := '';
  dtpGecmisTarih.Date := Date;
  AktifEczaciID := 0;
end;

{-------------------------------------------------------------------------------
  FormActivate: Form açılınca veriler yüklenir
-------------------------------------------------------------------------------}
procedure TForm11.FormActivate(Sender: TObject);
begin
  GecmisTalepleriYukle;
end;

{-------------------------------------------------------------------------------
  FormClose: Hafızadan temizleme
-------------------------------------------------------------------------------}
procedure TForm11.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Form11 := nil;
end;

{-------------------------------------------------------------------------------
  Grid Başlıklarını Türkçeleştirme ve Kalınlaştırma
-------------------------------------------------------------------------------}
procedure TForm11.BasliklariTurkceYap;
var
  i: Integer;
begin
  if dbGridGecmis.Columns.Count >= 7 then
  begin
    dbGridGecmis.Columns[0].Visible := False; // SiparisID
    dbGridGecmis.Columns[1].Visible := False; // IlacID
    dbGridGecmis.Columns[2].Title.Caption := 'İlaç Adı';
    dbGridGecmis.Columns[3].Title.Caption := 'Etken Madde';
    dbGridGecmis.Columns[4].Title.Caption := 'Talep Edilen Adet';
    dbGridGecmis.Columns[5].Title.Caption := 'Talep Tarihi';
    dbGridGecmis.Columns[6].Title.Caption := 'Teslimat İşlemi';
  end;

  for i := 0 to dbGridGecmis.Columns.Count - 1 do
  begin
    dbGridGecmis.Columns[i].Title.Font.Name := 'Segoe UI';
    dbGridGecmis.Columns[i].Title.Font.Size := 11;
    dbGridGecmis.Columns[i].Title.Font.Style := [fsBold];
  end;
end;

{-------------------------------------------------------------------------------
  Sütun Genişliklerini Ayarlama (11 pt fonta uygun güncellendi)
-------------------------------------------------------------------------------}
procedure TForm11.SütunGenislikleriniAyarla;
var
  i: Integer;
begin
  for i := 0 to dbGridGecmis.Columns.Count - 1 do
  begin
    case i of
      0, 1: dbGridGecmis.Columns[i].Width := 0;   // Gizli ID'ler
      2:    dbGridGecmis.Columns[i].Width := 210; // İlaç Adı
      3:    dbGridGecmis.Columns[i].Width := 210; // Etken Madde
      4:    dbGridGecmis.Columns[i].Width := 140; // Talep Edilen Adet
      5:    dbGridGecmis.Columns[i].Width := 140; // Talep Tarihi
      6:    dbGridGecmis.Columns[i].Width := 140; // Teslimat İşlemi
    else
      dbGridGecmis.Columns[i].Width := 110;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Geçmiş Talepleri Yükleme
-------------------------------------------------------------------------------}
procedure TForm11.GecmisTalepleriYukle;
var
  AramaMetni, TarihMetni: string;
begin
  if not Assigned(qryGecmis.Connection) then Exit;

  AramaMetni := Trim(edtGecmisAra.Text);
  TarihMetni := FormatDateTime('yyyy-mm-dd', dtpGecmisTarih.Date);

  qryGecmis.Close;
  qryGecmis.SQL.Clear;

  qryGecmis.SQL.Add('SELECT');
  qryGecmis.SQL.Add('    S.SiparisID,');
  qryGecmis.SQL.Add('    S.IlacID,');
  qryGecmis.SQL.Add('    CAST(I.IlacAdi AS VARCHAR) AS [İlaç Adı],');
  qryGecmis.SQL.Add('    CAST(I.EtkenMadde AS VARCHAR) AS [Etken Madde],');
  qryGecmis.SQL.Add('    S.SiparisMiktari AS [Talep Edilen Adet],');
  qryGecmis.SQL.Add('    CAST(SUBSTR(S.SiparisTarihi, 1, 10) AS VARCHAR) AS [Talep Edilen Tarih],');
  qryGecmis.SQL.Add('    CAST(S.Durum AS VARCHAR) AS [Teslimat İşlemi]');
  qryGecmis.SQL.Add('FROM ECZA_DEPOSU_SIPARIS S');
  qryGecmis.SQL.Add('JOIN ILAC I ON S.IlacID = I.IlacID');
  qryGecmis.SQL.Add('WHERE SUBSTR(S.SiparisTarihi, 1, 10) = :pTarih');

  if AramaMetni <> '' then
  begin
    qryGecmis.SQL.Add('  AND (I.IlacAdi LIKE :pArama OR I.EtkenMadde LIKE :pArama)');
  end;

  qryGecmis.SQL.Add('ORDER BY S.SiparisTarihi DESC;');

  qryGecmis.ParamByName('pTarih').AsString := TarihMetni;

  if AramaMetni <> '' then
    qryGecmis.ParamByName('pArama').AsString := '%' + AramaMetni + '%';

  try
    qryGecmis.Open;
    SütunGenislikleriniAyarla;
    BasliklariTurkceYap;
  except
    on E: Exception do
      ShowMessage('Geçmiş talepler yüklenirken hata oluştu: ' + E.Message);
  end;
end;

{-------------------------------------------------------------------------------
  Grid Hücrelerine Canlı Yeşil "Teslim Al" Butonu Çizme
-------------------------------------------------------------------------------}
procedure TForm11.dbGridGecmisDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Durum: string;
  ButtonRect: TRect;
begin
  if Column.Title.Caption = 'Teslimat İşlemi' then
  begin
    Durum := qryGecmis.FieldByName('Teslimat İşlemi').AsString;

    dbGridGecmis.Canvas.FillRect(Rect);

    ButtonRect := Rect;
    InflateRect(ButtonRect, -2, -2);

    if (Durum = 'Alındı') or (Durum = 'Teslim Alındı') then
    begin
      dbGridGecmis.Canvas.Brush.Color := clSilver;
      dbGridGecmis.Canvas.Font.Color := clBlack;
      dbGridGecmis.Canvas.Font.Style := [fsBold];
      dbGridGecmis.Canvas.FillRect(ButtonRect);
      DrawText(dbGridGecmis.Canvas.Handle, PChar('Alındı'), -1, ButtonRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    end
    else
    begin
      dbGridGecmis.Canvas.Brush.Color := RGB(40, 167, 69); // Canlı Yeşil
      dbGridGecmis.Canvas.Font.Color := clWhite;
      dbGridGecmis.Canvas.Font.Style := [fsBold];
      dbGridGecmis.Canvas.FillRect(ButtonRect);
      DrawText(dbGridGecmis.Canvas.Handle, PChar('Teslim Al'), -1, ButtonRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    end;
  end
  else
  begin
    dbGridGecmis.DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end;
end;

{-------------------------------------------------------------------------------
  🌟 Çift Tıklandığında Parti / SKT Girişi Alıp Stoğu Artırma ve Parti Açma
-------------------------------------------------------------------------------}
procedure TForm11.dbGridGecmisDblClick(Sender: TObject);
var
  UpdateQuery: TFDQuery;
  SiparisID, IlacID, Miktar: Integer;
  IlacAdi, Durum: string;
  PartiNo, SktStr: string;
begin
  if qryGecmis.IsEmpty then Exit;

  // Sadece "Teslimat İşlemi" sütununa çift tıklandığında çalışsın
  if dbGridGecmis.SelectedField.FieldName = 'Teslimat İşlemi' then
  begin
    Durum := qryGecmis.FieldByName('Teslimat İşlemi').AsString;

    if (Durum = 'Alındı') or (Durum = 'Teslim Alındı') then
    begin
      ShowMessage('Bu sipariş zaten daha önce teslim alınmış! ⚠️');
      Exit;
    end;

    SiparisID := qryGecmis.FieldByName('SiparisID').AsInteger;
    IlacID := qryGecmis.FieldByName('IlacID').AsInteger;
    Miktar := qryGecmis.FieldByName('Talep Edilen Adet').AsInteger;
    IlacAdi := qryGecmis.FieldByName('İlaç Adı').AsString;

    // 🌟 1. Eczacıdan Parti Numarasını İsteyelim
    PartiNo := 'PRT-2026-999';
    if not InputQuery('Parti / Lot Girişi', IlacAdi + ' için Parti Numarasını giriniz:', PartiNo) then
      Exit;

    // 🌟 2. Eczacıdan Son Kullanma Tarihini İsteyelim (Format: YYYY-AA-GG)
    SktStr := FormatDateTime('yyyy-mm-dd', Date + 365); // Varsayılan 1 yıl sonrası
    if not InputQuery('Son Kullanma Tarihi (SKT)', IlacAdi + ' için Son Kullanma Tarihini giriniz (YYYY-AA-GG):', SktStr) then
      Exit;

    UpdateQuery := TFDQuery.Create(nil);
    try
      UpdateQuery.Connection := FrmLogin.FDConnection1;

      UpdateQuery.Connection.StartTransaction;
      try
        // 3. Merkez stoğu artır
        UpdateQuery.SQL.Text := 'UPDATE ILAC SET MerkezStokMiktari = MerkezStokMiktari + :pMiktar WHERE IlacID = :pIlacID;';
        UpdateQuery.ParamByName('pMiktar').AsInteger := Miktar;
        UpdateQuery.ParamByName('pIlacID').AsInteger := IlacID;
        UpdateQuery.ExecSQL;

        // 🌟 4. ILAC_PARTI Tablosuna Yeni Parti Kaydı Aç (FIFO ve Miat Takibi İçin)
        UpdateQuery.SQL.Text :=
          'INSERT INTO ILAC_PARTI (IlacID, PartiNo, Miktar, KalanMiktar, SonKullanmaTarihi, GirisTarihi) ' +
          'VALUES (:pIlacID, :pPartiNo, :pMiktar, :pMiktar, :pSkt, datetime(''now'', ''localtime''));';
        UpdateQuery.ParamByName('pIlacID').AsInteger := IlacID;
        UpdateQuery.ParamByName('pPartiNo').AsString := Trim(PartiNo);
        UpdateQuery.ParamByName('pMiktar').AsInteger := Miktar;
        UpdateQuery.ParamByName('pSkt').AsString := Trim(SktStr);
        UpdateQuery.ExecSQL;

        // 5. Sipariş Durumunu "Alındı" olarak güncelle
        UpdateQuery.SQL.Text := 'UPDATE ECZA_DEPOSU_SIPARIS SET Durum = ''Alındı'' WHERE SiparisID = :pID;';
        UpdateQuery.ParamByName('pID').AsInteger := SiparisID;
        UpdateQuery.ExecSQL;

        UpdateQuery.Connection.Commit;
        ShowMessage(IlacAdi + ' için ' + IntToStr(Miktar) + ' adet ürün teslim alındı, merkeze eklendi ve yeni parti oluşturuldu! ✅');

        // Listeyi tazele
        GecmisTalepleriYukle;
      except
        UpdateQuery.Connection.Rollback;
        raise;
      end;
    finally
      UpdateQuery.Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Arama Kutusu Değişiklik Olayı
-------------------------------------------------------------------------------}
procedure TForm11.edtGecmisAraChange(Sender: TObject);
begin
  GecmisTalepleriYukle;
end;

{-------------------------------------------------------------------------------
  Tarih Seçimi Değişiklik Olayı
-------------------------------------------------------------------------------}
procedure TForm11.dtpGecmisTarihChange(Sender: TObject);
begin
  GecmisTalepleriYukle;
end;

end.
