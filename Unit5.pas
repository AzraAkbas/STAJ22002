unit Unit5;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TfrmHemsireAnaSayfa = class(TForm)
    scrCards: TScrollBox;
    pnlTop: TPanel;
    Label1: TLabel;
    edtArama: TEdit;
    pnlStokKontrol: TPanel;
    pnlCardTemplate: TPanel;
    lblHeaderTemplate: TLabel;
    lblDetailsTemplate: TLabel;
    Bevel1: TBevel;
    lblMedsTemplate: TLabel;
    pnlUygulandi: TPanel;
    pnlUygulanmadi: TPanel;
    qryServisKartlari: TFDQuery;
    qryStokKontrol: TFDQuery;
    qryIslem: TFDQuery;
    pnlGecmisSayfasinaGit: TPanel;

    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure edtAramaChange(Sender: TObject);
    procedure pnlStokKontrolClick(Sender: TObject);
    procedure pnlUygulandiClick(Sender: TObject);
    procedure pnlUygulanmadiClick(Sender: TObject);
    procedure pnlGecmisSayfasinaGitClick(Sender: TObject);
  private
    function TurkceKarakterDuzelt(const S: string): string;
    procedure OtomatikStokAlarmVeKontrol(const ServisAdi: string; GosterAlert: Boolean);
    procedure MiatKontrolVeUyar(const ServisAdi: string);
    procedure IlacIslemKaydet(Panel: TPanel; const DurumStr: string);
  public
    procedure ServisKartlariniYukle(ServisAdi: string; const AramaMetni: string = '');
  end;

var
  frmHemsireAnaSayfa: TfrmHemsireAnaSayfa;
  IlkAcilisYapildi: Boolean = False;

implementation

{$R *.dfm}

uses Unit1, Unit6, Unit7;

function TfrmHemsireAnaSayfa.TurkceKarakterDuzelt(const S: string): string;
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

procedure TfrmHemsireAnaSayfa.FormShow(Sender: TObject);
var
  AktifServis: string;
begin
  if IlkAcilisYapildi then Exit;
  IlkAcilisYapildi := True;

  if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
  begin
    qryServisKartlari.Connection := FrmLogin.FDConnection1;
    qryStokKontrol.Connection := FrmLogin.FDConnection1;
    qryIslem.Connection := FrmLogin.FDConnection1;
  end;

  if (Assigned(FrmLogin)) and (Trim(FrmLogin.GirisYapanServisAdi) <> '') then
    AktifServis := FrmLogin.GirisYapanServisAdi
  else
    AktifServis := 'Dahiliye';

  if Assigned(pnlCardTemplate) then
  begin
    pnlCardTemplate.Visible := False;
    if Assigned(pnlUygulandi) then pnlUygulandi.OnClick := pnlUygulandiClick;
    if Assigned(pnlUygulanmadi) then pnlUygulanmadi.OnClick := pnlUygulanmadiClick;
  end;

  OtomatikStokAlarmVeKontrol(AktifServis, True);
  MiatKontrolVeUyar(AktifServis);
  ServisKartlariniYukle(AktifServis);
end;

procedure TfrmHemsireAnaSayfa.OtomatikStokAlarmVeKontrol(const ServisAdi: string; GosterAlert: Boolean);
var
  KritikVeAltiCount: Integer;
begin
  if not Assigned(qryStokKontrol.Connection) then Exit;

  qryStokKontrol.Close;
  qryStokKontrol.SQL.Text :=
    'SELECT COUNT(*) AS Sayi FROM SERVIS_STOK ' +
    'WHERE LOWER(TRIM(ServisAdi)) LIKE LOWER(:pServisAdi) ' +
    '  AND MevcutMiktar <= KritikEsikMiktari;';
  qryStokKontrol.ParamByName('pServisAdi').AsString := '%' + Trim(ServisAdi) + '%';

  try
    qryStokKontrol.Open;
    KritikVeAltiCount := qryStokKontrol.FieldByName('Sayi').AsInteger;
  except
    KritikVeAltiCount := 0;
  end;

  if Assigned(pnlStokKontrol) then
  begin
    if KritikVeAltiCount > 0 then
    begin
      pnlStokKontrol.Caption := Format('🚨 STOK ALARMI (%d)', [KritikVeAltiCount]);
      pnlStokKontrol.Font.Color := clRed;
    end
    else
    begin
      pnlStokKontrol.Caption := '📦 Stok Yönetimi';
      pnlStokKontrol.Font.Color := clWindowText;
    end;
  end;

  if GosterAlert and (KritikVeAltiCount > 0) then
    ShowMessage(Format('🚨 DİKKAT! Servisinizde kritik miktarda veya kritik miktarın altında %d adet ilaç bulunmaktadır!', [KritikVeAltiCount]));
end;

procedure TfrmHemsireAnaSayfa.MiatKontrolVeUyar(const ServisAdi: string);
var
  MiatGecenVeyaYakinSayisi: Integer;
  IlacListesiStr: string;
begin
  if not Assigned(qryStokKontrol.Connection) then Exit;

  qryStokKontrol.Close;
  qryStokKontrol.SQL.Text :=
    'SELECT COUNT(DISTINCT P.IlacID) AS Sayi, ' +
    '       GROUP_CONCAT(DISTINCT I.IlacAdi) AS IlacListesi ' +
    'FROM ILAC_PARTI P ' +
    'INNER JOIN SERVIS_STOK SS ON P.IlacID = SS.IlacID ' +
    'INNER JOIN ILAC I ON P.IlacID = I.IlacID ' +
    'WHERE LOWER(TRIM(SS.ServisAdi)) LIKE LOWER(:pServisAdi) ' +
    '  AND P.KalanMiktar > 0 ' +
    '  AND date(P.SonKullanmaTarihi) <= date(''now'', ''+30 days'', ''localtime'');';
  qryStokKontrol.ParamByName('pServisAdi').AsString := '%' + Trim(ServisAdi) + '%';

  try
    qryStokKontrol.Open;
    MiatGecenVeyaYakinSayisi := qryStokKontrol.FieldByName('Sayi').AsInteger;
    IlacListesiStr := qryStokKontrol.FieldByName('IlacListesi').AsString;
  except
    MiatGecenVeyaYakinSayisi := 0;
    IlacListesiStr := '';
  end;

  if MiatGecenVeyaYakinSayisi > 0 then
  begin
    IlacListesiStr := TurkceKarakterDuzelt(IlacListesiStr);
    IlacListesiStr := StringReplace(IlacListesiStr, ',', sLineBreak + '• ', [rfReplaceAll]);

    ShowMessage(Format(
      '⚠️ MİAT (SKT) UYARISI!' + sLineBreak + sLineBreak +
      'Servisinizde son kullanma tarihi geçmiş veya 30 günden az kalmış %d çeşit ilaç bulunmaktadır:' + sLineBreak + sLineBreak +
      '• %s' + sLineBreak + sLineBreak +
      'Lütfen stokları kontrol ediniz.',
      [MiatGecenVeyaYakinSayisi, IlacListesiStr]
    ));
  end;
end;

procedure TfrmHemsireAnaSayfa.pnlStokKontrolClick(Sender: TObject);
var
  AktifServis: string;
begin
  AktifServis := 'Dahiliye';
  if Assigned(FrmLogin) and (Trim(FrmLogin.GirisYapanServisAdi) <> '') then
    AktifServis := FrmLogin.GirisYapanServisAdi;

  Form6 := TForm6.Create(Self);
  try
    Form6.ShowModal;
  finally
    Form6.Free;
  end;

  OtomatikStokAlarmVeKontrol(AktifServis, False);
end;

procedure TfrmHemsireAnaSayfa.pnlGecmisSayfasinaGitClick(Sender: TObject);
begin
  Form7 := TForm7.Create(Self);
  try
    Form7.ShowModal;
  finally
    Form7.Free;
  end;
end;

procedure TfrmHemsireAnaSayfa.IlacIslemKaydet(Panel: TPanel; const DurumStr: string);
var
  ReceteDetayID: Integer;
  OgunAdi: string;
  Gerekce, AktifServis, AramaMetni: string;
  IlacID: Integer;
  Adet: Integer;
  PartiID: Integer;
  HemsireID: Integer;
begin
  if not Assigned(Panel) then Exit;
  ReceteDetayID := Panel.Tag;
  OgunAdi := Trim(Panel.Hint);

  if DurumStr = 'Uygulanmadi' then
  begin
    Gerekce := '';
    while Trim(Gerekce) = '' do
    begin
      if not InputQuery('Gerekçe Girişi', 'Uygulanmadı gerekçesini giriniz:', Gerekce) then
        Exit;
    end;
  end;

  qryIslem.Close;
  qryIslem.SQL.Text := 'SELECT IlacID, Adet FROM RECETE_DETAY WHERE DetayID = :pDetayID;';
  qryIslem.ParamByName('pDetayID').AsInteger := ReceteDetayID;
  qryIslem.Open;

  if qryIslem.IsEmpty then Exit;
  IlacID := qryIslem.FieldByName('IlacID').AsInteger;
  Adet := qryIslem.FieldByName('Adet').AsInteger;
  if Adet <= 0 then Adet := 1;

  AktifServis := 'Dahiliye';
  if Assigned(FrmLogin) and (Trim(FrmLogin.GirisYapanServisAdi) <> '') then
    AktifServis := FrmLogin.GirisYapanServisAdi;

  // Giriş yapan hemşire ID'sini dinamik olarak alıyoruz
  HemsireID := 1;
  if Assigned(FrmLogin) and (FrmLogin.GirisYapanHemsireID > 0) then
    HemsireID := FrmLogin.GirisYapanHemsireID;

  // 1. Tedavi Uygulama Kaydını Ekle
  qryIslem.Close;
  qryIslem.SQL.Text :=
    'INSERT INTO TEDAVI_UYGULAMA (ReceteDetayID, HemsireID, Durum, Gerekce, Ogun, UygulamaTarihi) ' +
    'VALUES (:pDetayID, :pHemsireID, :pDurum, :pGerekce, :pOgun, datetime(''now'', ''localtime''));';
  qryIslem.ParamByName('pDetayID').AsInteger := ReceteDetayID;
  qryIslem.ParamByName('pHemsireID').AsInteger := HemsireID;
  qryIslem.ParamByName('pDurum').AsString := DurumStr;
  qryIslem.ParamByName('pGerekce').AsString := Gerekce;
  qryIslem.ParamByName('pOgun').AsString := OgunAdi;
  qryIslem.ExecSQL;

  // 2. İLAÇ UYGULANDIĞINDA: Stoklarda herhangi bir değişiklik YAPILMAZ.
  //    İLAÇ UYGULANMADIYSA: Servis stoğuna ve ilgili partiye geri iade et (+Adet).
  if DurumStr = 'Uygulanmadi' then
  begin
    // Servis stoğunu artır
    qryIslem.Close;
    qryIslem.SQL.Text :=
      'UPDATE SERVIS_STOK SET MevcutMiktar = MevcutMiktar + :pAdet ' +
      'WHERE LOWER(TRIM(ServisAdi)) LIKE LOWER(:pServis) AND IlacID = :pIlacID;';
    qryIslem.ParamByName('pAdet').AsInteger := Adet;
    qryIslem.ParamByName('pServis').AsString := '%' + Trim(AktifServis) + '%';
    qryIslem.ParamByName('pIlacID').AsInteger := IlacID;
    qryIslem.ExecSQL;

    // İlgili ilaca ait en uygun aktif partiye iade et
    qryIslem.Close;
    qryIslem.SQL.Text :=
      'SELECT PartiID FROM ILAC_PARTI ' +
      'WHERE IlacID = :pIlacID ' +
      'ORDER BY SonKullanmaTarihi DESC, GirisTarihi DESC LIMIT 1;';
    qryIslem.ParamByName('pIlacID').AsInteger := IlacID;
    qryIslem.Open;

    if not qryIslem.IsEmpty then
    begin
      PartiID := qryIslem.FieldByName('PartiID').AsInteger;

      qryIslem.Close;
      qryIslem.SQL.Text :=
        'UPDATE ILAC_PARTI SET KalanMiktar = KalanMiktar + :pAdet, Miktar = Miktar + :pAdet ' +
        'WHERE PartiID = :pPartiID;';
      qryIslem.ParamByName('pAdet').AsInteger := Adet;
      qryIslem.ParamByName('pPartiID').AsInteger := PartiID;
      qryIslem.ExecSQL;
    end;
  end;

  ShowMessage('İşlem başarıyla kaydedildi.');

  AramaMetni := '';
  if Assigned(edtArama) then
    AramaMetni := edtArama.Text;

  ServisKartlariniYukle(AktifServis, AramaMetni);
  OtomatikStokAlarmVeKontrol(AktifServis, False);
end;

procedure TfrmHemsireAnaSayfa.pnlUygulandiClick(Sender: TObject);
begin
  IlacIslemKaydet(TPanel(Sender), 'Uygulandi');
end;

procedure TfrmHemsireAnaSayfa.pnlUygulanmadiClick(Sender: TObject);
begin
  IlacIslemKaydet(TPanel(Sender), 'Uygulanmadi');
end;

procedure TfrmHemsireAnaSayfa.edtAramaChange(Sender: TObject);
var
  AktifServis, AramaMetni: string;
begin
  AktifServis := 'Dahiliye';
  if Assigned(FrmLogin) and (Trim(FrmLogin.GirisYapanServisAdi) <> '') then
    AktifServis := FrmLogin.GirisYapanServisAdi;

  AramaMetni := '';
  if Assigned(edtArama) then
    AramaMetni := edtArama.Text;

  ServisKartlariniYukle(AktifServis, AramaMetni);
end;

procedure TfrmHemsireAnaSayfa.FormActivate(Sender: TObject);
begin
  // Boş bırakıldı
end;

procedure TfrmHemsireAnaSayfa.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TfrmHemsireAnaSayfa.ServisKartlariniYukle(ServisAdi: string; const AramaMetni: string = '');
var
  CardPanel: TPanel;
  lblH, lblD, lblR, lblM: TLabel;
  pnlU, pnlUn: TPanel;
  CardTop, Spacing, TemplateHeight, IlacTop: Integer;
  ArananServis, OncekiHastaID, OncekiReceteID: string;
  HastaAdSoyad, ServisBilgi, DoktorAdi, ReceteTarihi, HamOgunler, TekilOgun: string;
  CurrentDetayID: Integer;
  OgunListesi: TStringList;
  i: Integer;
  GosterilecekOgunSayisi: Integer;
  TempQuery: TFDQuery;
begin
  while scrCards.ControlCount > 0 do
  begin
    if (scrCards.Controls[scrCards.ControlCount - 1] <> pnlCardTemplate) and
       (scrCards.Controls[scrCards.ControlCount - 1] <> pnlTop) then
      scrCards.Controls[scrCards.ControlCount - 1].Free
    else
      Break;
  end;

  ArananServis := Trim(ServisAdi);
  if ArananServis = '' then
    ArananServis := 'Dahiliye';

  qryServisKartlari.Close;
  qryServisKartlari.SQL.Text :=
    'SELECT ' +
    '    H.HastaID, RD.DetayID, R.ReceteID, ' +
    '    H.Ad || '' '' || H.Soyad AS HastaAdSoyad, ' +
    '    Y.OdaNo, Y.YatakNo, Y.ServisAdi, ' +
    '    COALESCE(D.Unvan || '' '' || D.Ad || '' '' || D.Soyad, D.Ad || '' '' || D.Soyad, ''Belirtilmedi'') AS DoktorAdSoyad, ' +
    '    COALESCE(I.IlacAdi, ''-'') AS IlacAdi, ' +
    '    COALESCE(RD.Doz, ''-'') AS Doz, ' +
    '    COALESCE(RD.Adet, 1) AS Adet, ' +
    '    COALESCE(RD.Ogun, ''-'') AS Ogun, ' +
    '    COALESCE(RD.GunSayisi, 1) AS GunSayisi, ' +
    '    R.Tarih AS ReceteTarihi ' +
    'FROM YATIS Y ' +
    'INNER JOIN HASTA H ON Y.HastaID = H.HastaID ' +
    'INNER JOIN RECETE R ON R.HastaID = H.HastaID AND R.Tarih >= Y.YatisTarihi ' +
    'LEFT JOIN DOKTOR D ON R.DoktorID = D.DoktorID ' +
    'LEFT JOIN RECETE_DETAY RD ON R.ReceteID = RD.ReceteID ' +
    'LEFT JOIN ILAC I ON RD.IlacID = I.IlacID ' +
    'WHERE (LOWER(TRIM(Y.AktifMi)) = ''evet'' OR Y.AktifMi IS NULL) ' +
    '  AND LOWER(TRIM(Y.ServisAdi)) LIKE LOWER(:pServisAdi) ' +
    '  AND (:pArama = '''' OR LOWER(H.Ad || '' '' || H.Soyad) LIKE LOWER(:pAramaFiltre)) ' +
    '  AND datetime(R.Tarih, ''+'' || COALESCE(RD.GunSayisi, 1) || '' days'') >= datetime(''now'', ''localtime'') ' +
    'ORDER BY H.HastaID, R.Tarih DESC, RD.DetayID;';

  qryServisKartlari.ParamByName('pServisAdi').AsString := '%' + Trim(ArananServis) + '%';
  qryServisKartlari.ParamByName('pArama').AsString := Trim(AramaMetni);
  qryServisKartlari.ParamByName('pAramaFiltre').AsString := '%' + Trim(AramaMetni) + '%';

  try
    qryServisKartlari.Open;
  except
    on E: Exception do
    begin
      ShowMessage('Sorgu Hatası: ' + E.Message);
      Exit;
    end;
  end;

  if qryServisKartlari.IsEmpty then
    Exit;

  CardTop := 75;
  Spacing := 15;
  TemplateHeight := 110;
  if Assigned(pnlCardTemplate) then
    TemplateHeight := pnlCardTemplate.Height;

  OncekiHastaID := '';
  OncekiReceteID := '';
  CardPanel := nil;
  OgunListesi := TStringList.Create;
  TempQuery := TFDQuery.Create(nil);
  try
    if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
      TempQuery.Connection := FrmLogin.FDConnection1;

    while not qryServisKartlari.Eof do
    begin
      CurrentDetayID := qryServisKartlari.FieldByName('DetayID').AsInteger;
      if CurrentDetayID > 0 then
      begin
        HamOgunler := qryServisKartlari.FieldByName('Ogun').AsString;
        OgunListesi.Clear;
        HamOgunler := StringReplace(HamOgunler, ',', '-', [rfReplaceAll]);
        ExtractStrings(['-'], [' '], PChar(HamOgunler), OgunListesi);
        if OgunListesi.Count = 0 then
          OgunListesi.Add(HamOgunler);

        GosterilecekOgunSayisi := 0;
        for i := 0 to OgunListesi.Count - 1 do
        begin
          TekilOgun := Trim(OgunListesi[i]);
          TempQuery.Close;
          TempQuery.SQL.Text :=
            'SELECT COUNT(*) AS Sayi FROM TEDAVI_UYGULAMA ' +
            'WHERE ReceteDetayID = :pDetayID ' +
            '  AND Ogun = :pOgun ' +
            '  AND date(UygulamaTarihi) = date(''now'', ''localtime'');';
          TempQuery.ParamByName('pDetayID').AsInteger := CurrentDetayID;
          TempQuery.ParamByName('pOgun').AsString := TekilOgun;
          TempQuery.Open;

          if TempQuery.FieldByName('Sayi').AsInteger = 0 then
            Inc(GosterilecekOgunSayisi);
        end;

        if GosterilecekOgunSayisi > 0 then
        begin
          if OncekiHastaID <> qryServisKartlari.FieldByName('HastaID').AsString then
          begin
            if Assigned(CardPanel) then
              CardTop := CardTop + CardPanel.Height + Spacing;

            OncekiHastaID := qryServisKartlari.FieldByName('HastaID').AsString;
            OncekiReceteID := '';

            CardPanel := TPanel.Create(scrCards);
            CardPanel.Parent := scrCards;
            CardPanel.SetBounds(15, CardTop, scrCards.ClientWidth - 30, TemplateHeight);
            CardPanel.Anchors := [akLeft, akTop, akRight];
            CardPanel.Color := clWindow;
            CardPanel.StyleElements := [];
            CardPanel.BevelOuter := bvNone;
            CardPanel.BorderWidth := 1;

            HastaAdSoyad := TurkceKarakterDuzelt(qryServisKartlari.FieldByName('HastaAdSoyad').AsString);

            lblH := TLabel.Create(CardPanel);
            lblH.Parent := CardPanel;
            lblH.SetBounds(16, 10, CardPanel.Width - 30, 21);
            lblH.Anchors := [akLeft, akTop, akRight];
            if Assigned(lblHeaderTemplate) then
              lblH.Font.Assign(lblHeaderTemplate.Font);
            lblH.Caption := HastaAdSoyad;

            ServisBilgi := Format('Oda No: %s  |  Yatak No: %s  |  Servis: %s',
              [qryServisKartlari.FieldByName('OdaNo').AsString,
               qryServisKartlari.FieldByName('YatakNo').AsString,
               TurkceKarakterDuzelt(qryServisKartlari.FieldByName('ServisAdi').AsString)]);

            lblD := TLabel.Create(CardPanel);
            lblD.Parent := CardPanel;
            lblD.SetBounds(16, 37, CardPanel.Width - 30, 17);
            lblD.Anchors := [akLeft, akTop, akRight];
            if Assigned(lblDetailsTemplate) then
              lblD.Font.Assign(lblDetailsTemplate.Font);
            lblD.Caption := ServisBilgi;

            with TBevel.Create(CardPanel) do
            begin
              Parent := CardPanel;
              SetBounds(16, 60, CardPanel.Width - 32, 2);
              Anchors := [akLeft, akTop, akRight];
              Shape := bsTopLine;
            end;

            IlacTop := 68;
          end;

          if OncekiReceteID <> qryServisKartlari.FieldByName('ReceteID').AsString then
          begin
            OncekiReceteID := qryServisKartlari.FieldByName('ReceteID').AsString;
            ReceteTarihi := qryServisKartlari.FieldByName('ReceteTarihi').AsString;
            DoktorAdi := TurkceKarakterDuzelt(qryServisKartlari.FieldByName('DoktorAdSoyad').AsString);

            lblR := TLabel.Create(CardPanel);
            lblR.Parent := CardPanel;
            lblR.SetBounds(16, IlacTop, CardPanel.Width - 30, 18);
            lblR.Anchors := [akLeft, akTop, akRight];
            lblR.Font.Name := 'Segoe UI';
            lblR.Font.Size := 9;
            lblR.Font.Style := [fsBold, fsUnderline];
            lblR.Caption := Format('📜 Reçete Tarihi: %s  —  Dr. %s', [ReceteTarihi, DoktorAdi]);

            IlacTop := IlacTop + 24;
            CardPanel.Height := IlacTop + 15;
          end;

          for i := 0 to OgunListesi.Count - 1 do
          begin
            TekilOgun := Trim(OgunListesi[i]);

            TempQuery.Close;
            TempQuery.SQL.Text :=
              'SELECT COUNT(*) AS Sayi FROM TEDAVI_UYGULAMA ' +
              'WHERE ReceteDetayID = :pDetayID ' +
              '  AND Ogun = :pOgun ' +
              '  AND date(UygulamaTarihi) = date(''now'', ''localtime'');';
            TempQuery.ParamByName('pDetayID').AsInteger := CurrentDetayID;
            TempQuery.ParamByName('pOgun').AsString := TekilOgun;
            TempQuery.Open;

            if TempQuery.FieldByName('Sayi').AsInteger > 0 then
              Continue;

            lblM := TLabel.Create(CardPanel);
            lblM.Parent := CardPanel;
            lblM.SetBounds(16, IlacTop, CardPanel.Width - 250, 18);
            lblM.Anchors := [akLeft, akTop, akRight];
            if Assigned(lblMedsTemplate) then
              lblM.Font.Assign(lblMedsTemplate.Font);
            lblM.Caption := Format('• İlaç: %s | Doz: %s (%d Adet) | Öğün: %s (%d Gün)',
              [TurkceKarakterDuzelt(qryServisKartlari.FieldByName('IlacAdi').AsString),
               qryServisKartlari.FieldByName('Doz').AsString,
               qryServisKartlari.FieldByName('Adet').AsInteger,
               TekilOgun,
               qryServisKartlari.FieldByName('GunSayisi').AsInteger]);

            pnlU := TPanel.Create(CardPanel);
            pnlU.Parent := CardPanel;
            if Assigned(pnlUygulandi) then
            begin
              pnlU.SetBounds(CardPanel.Width - 225, IlacTop - 1, 95, 23);
              pnlU.Caption := pnlUygulandi.Caption;
              pnlU.Font.Assign(pnlUygulandi.Font);
              pnlU.Font.Size := 8;
            end
            else
            begin
              pnlU.SetBounds(CardPanel.Width - 225, IlacTop - 1, 95, 23);
              pnlU.Caption := '✔ Uygulandı';
              pnlU.Font.Size := 8;
            end;
            pnlU.Font.Color := clGreen;
            pnlU.Anchors := [akTop, akRight];
            pnlU.Tag := CurrentDetayID;
            pnlU.Hint := TekilOgun;
            pnlU.OnClick := pnlUygulandiClick;

            pnlUn := TPanel.Create(CardPanel);
            pnlUn.Parent := CardPanel;
            if Assigned(pnlUygulanmadi) then
            begin
              pnlUn.SetBounds(CardPanel.Width - 125, IlacTop - 1, 112, 23);
              pnlUn.Caption := pnlUygulanmadi.Caption;
              pnlUn.Font.Assign(pnlUygulanmadi.Font);
              pnlUn.Font.Size := 8;
            end
            else
            begin
              pnlUn.SetBounds(CardPanel.Width - 125, IlacTop - 1, 112, 23);
              pnlUn.Caption := '❌ Uygulanmadı';
              pnlUn.Font.Size := 8;
            end;
            pnlUn.Font.Color := clRed;
            pnlUn.Anchors := [akTop, akRight];
            pnlUn.Tag := CurrentDetayID;
            pnlUn.Hint := TekilOgun;
            pnlUn.OnClick := pnlUygulanmadiClick;

            IlacTop := IlacTop + 28;
            CardPanel.Height := IlacTop + 15;
          end;
        end;
      end;

      qryServisKartlari.Next;
    end;
  finally
    TempQuery.Free;
    OgunListesi.Free;
  end;
end;

initialization
  RegisterClasses([TBevel, TPanel, TLabel, TEdit]);

end.
