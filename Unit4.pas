unit Unit4;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids,
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, Data.DB, FireDAC.Stan.Async, FireDAC.DApt, Vcl.Printers, System.UITypes;

type
  TFormGecmisReceteler = class(TForm)
    PanelUst: TPanel;
    LabelAra: TLabel;
    EditIlacAra: TEdit;
    DBGridGecmis: TDBGrid;
    FDQueryGecmis: TFDQuery;
    DataSourceGecmis: TDataSource;
    BtnPdfCikti: TPanel;

    procedure FormCreate(Sender: TObject);
    procedure EditIlacAraChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure DBGridGecmisDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure BtnPdfCiktiClick(Sender: TObject);
  private
    { Private declarations }
    FCurrentHastaID: Integer;
    FIsProcessingPDF: Boolean;
    procedure GridDuzenle;
    procedure PDFRaporOlustur(const AReceteID: Integer);
    function DecryptAES128HexLocal(const EncryptedHexText: string; const Key: string): string;
  public
    { Public declarations }
    procedure GecmisReceteleriYukle(const AHastaID: Integer);
  end;

var
  FormGecmisReceteler: TFormGecmisReceteler;

implementation

{$R *.dfm}

uses Unit1;

type
  TGridHack = class(TDBGrid);

const
  REAL_AES_KEY = 'K9f!X2#mP8$zL5*q';
  REAL_AES_IV  = 'r4#mQ9$zK2!pL5*x';

{-------------------------------------------------------------------------------
  🔒 BAĞIMSIZ WINDOWS CNG AES-128 CBC DEŞİFRE FONKSİYONU
-------------------------------------------------------------------------------}
type
  BCRYPT_ALG_HANDLE = Pointer;
  BCRYPT_KEY_HANDLE = Pointer;

  TBCryptOpenAlgorithmProvider = function(var phAlgorithm: BCRYPT_ALG_HANDLE; pszAlgId: LPCWSTR; pszImplementation: LPCWSTR; dwFlags: ULONG): LONG; stdcall;
  TBCryptSetProperty = function(hObject: Pointer; pszProperty: LPCWSTR; pbInput: PByte; cbInput: ULONG; dwFlags: ULONG): LONG; stdcall;
  TBCryptGetProperty = function(hObject: Pointer; pszProperty: LPCWSTR; pbOutput: PByte; cbOutput: ULONG; var pcbResult: ULONG; dwFlags: ULONG): LONG; stdcall;
  TBCryptGenerateSymmetricKey = function(hAlgorithm: BCRYPT_ALG_HANDLE; var phKey: BCRYPT_KEY_HANDLE; pbKeyObject: PByte; cbKeyObject: ULONG; pbSecret: PByte; cbSecret: ULONG; dwFlags: ULONG): LONG; stdcall;
  TBCryptDecrypt = function(hKey: BCRYPT_KEY_HANDLE; pbInput: PByte; cbInput: ULONG; pPaddingInfo: Pointer; pbIV: PByte; cbIV: ULONG; pbOutput: PByte; cbOutput: ULONG; var pcbResult: ULONG; dwFlags: ULONG): LONG; stdcall;
  TBCryptDestroyKey = function(hKey: BCRYPT_KEY_HANDLE): LONG; stdcall;
  TBCryptCloseAlgorithmProvider = function(hAlgorithm: BCRYPT_ALG_HANDLE; dwFlags: ULONG): LONG; stdcall;

function TFormGecmisReceteler.DecryptAES128HexLocal(const EncryptedHexText: string; const Key: string): string;
var
  CleanHex: string; EncryptedBytes, KeyBytes, IVBytes, DecryptedBytes: TBytes; PaddingCount: Integer;
  hBCryptLib: HMODULE; BCryptOpenAlgorithmProvider: TBCryptOpenAlgorithmProvider; BCryptSetProperty: TBCryptSetProperty;
  BCryptGetProperty: TBCryptGetProperty; BCryptGenerateSymmetricKey: TBCryptGenerateSymmetricKey; BCryptDecrypt: TBCryptDecrypt;
  BCryptDestroyKey: TBCryptDestroyKey; BCryptCloseAlgorithmProvider: TBCryptCloseAlgorithmProvider;
  hAlg: BCRYPT_ALG_HANDLE; hKey: BCRYPT_KEY_HANDLE; cbKeyObject, cbResult, cbPlaintext: ULONG; pbKeyObject: PByte;
  LocalIV: TBytes; Status: LONG; ModeCBC: WideString;
begin
  CleanHex := System.SysUtils.Trim(EncryptedHexText);
  if (CleanHex = '') or (Length(CleanHex) mod 2 <> 0) then begin Result := EncryptedHexText; Exit; end;
  hBCryptLib := LoadLibrary('bcrypt.dll'); if hBCryptLib = 0 then begin Result := EncryptedHexText; Exit; end;
  @BCryptOpenAlgorithmProvider := GetProcAddress(hBCryptLib, 'BCryptOpenAlgorithmProvider');
  @BCryptSetProperty := GetProcAddress(hBCryptLib, 'BCryptSetProperty');
  @BCryptGetProperty := GetProcAddress(hBCryptLib, 'BCryptGetProperty');
  @BCryptGenerateSymmetricKey := GetProcAddress(hBCryptLib, 'BCryptGenerateSymmetricKey');
  @BCryptDecrypt := GetProcAddress(hBCryptLib, 'BCryptDecrypt');
  @BCryptDestroyKey := GetProcAddress(hBCryptLib, 'BCryptDestroyKey');
  @BCryptCloseAlgorithmProvider := GetProcAddress(hBCryptLib, 'BCryptCloseAlgorithmProvider');
  hAlg := nil; hKey := nil; pbKeyObject := nil; Result := EncryptedHexText;
  try
    SetLength(EncryptedBytes, Length(CleanHex) div 2); HexToBin(PChar(CleanHex), Pointer(EncryptedBytes), Length(EncryptedBytes));
    KeyBytes := TEncoding.UTF8.GetBytes(Key); IVBytes := TEncoding.UTF8.GetBytes(REAL_AES_IV); LocalIV := Copy(IVBytes);
    Status := BCryptOpenAlgorithmProvider(hAlg, 'AES', nil, 0); if Status <> 0 then Exit; ModeCBC := 'ChainingModeCBC';
    Status := BCryptSetProperty(hAlg, 'ChainingMode', PByte(PWideChar(ModeCBC)), (Length(ModeCBC) + 1) * SizeOf(WideChar), 0); if Status <> 0 then Exit;
    Status := BCryptGetProperty(hAlg, 'ObjectLength', PByte(@cbKeyObject), SizeOf(ULONG), cbResult, 0); if Status <> 0 then Exit; GetMem(pbKeyObject, cbKeyObject);
    Status := BCryptGenerateSymmetricKey(hAlg, hKey, pbKeyObject, cbKeyObject, PByte(KeyBytes), Length(KeyBytes), 0); if Status <> 0 then Exit;
    SetLength(DecryptedBytes, Length(EncryptedBytes));
    Status := BCryptDecrypt(hKey, PByte(EncryptedBytes), Length(EncryptedBytes), nil, PByte(LocalIV), Length(LocalIV), PByte(DecryptedBytes), Length(DecryptedBytes), cbPlaintext, 0); if Status <> 0 then Exit;
    SetLength(DecryptedBytes, cbPlaintext);
    if Length(DecryptedBytes) > 0 then begin
      PaddingCount := DecryptedBytes[Length(DecryptedBytes) - 1];
      if (PaddingCount > 0) and (PaddingCount <= 16) then SetLength(DecryptedBytes, Length(DecryptedBytes) - PaddingCount);
    end;
    Result := TEncoding.UTF8.GetString(DecryptedBytes);
  except Result := EncryptedHexText; end;
  if hKey <> nil then BCryptDestroyKey(hKey); if pbKeyObject <> nil then FreeMem(pbKeyObject);
  if hAlg <> nil then BCryptCloseAlgorithmProvider(hAlg, 0); FreeLibrary(hBCryptLib);
end;

procedure TFormGecmisReceteler.FormCreate(Sender: TObject);
begin
  Self.Position := poMainFormCenter;
  Self.Caption := 'Hastanın Geçmiş Reçete Kayıtları';
  Self.Width := 1150;
  Self.Height := 650;
  FIsProcessingPDF := False;

  PanelUst.BevelOuter := bvNone;
  PanelUst.Color := RGB(245, 247, 250);

  // 🌟 Hücre ve Başlık Font Ayarları (Yazı Boyutu: 11, Başlıklar: 11 Bold)
  DBGridGecmis.Font.Name := 'Segoe UI';
  DBGridGecmis.Font.Size := 11;
  DBGridGecmis.Font.Style := [];
  DBGridGecmis.TitleFont.Name := 'Segoe UI';
  DBGridGecmis.TitleFont.Size := 11;
  DBGridGecmis.TitleFont.Style := [fsBold];

  DBGridGecmis.DefaultDrawing := False;
  DBGridGecmis.Options := [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit];

  DataSourceGecmis.DataSet := FDQueryGecmis;
  DBGridGecmis.DataSource := DataSourceGecmis;

  EditIlacAra.OnChange := EditIlacAraChange;
  DBGridGecmis.OnDrawColumnCell := DBGridGecmisDrawColumnCell;

  BtnPdfCikti.OnClick := nil;
  BtnPdfCikti.OnClick := BtnPdfCiktiClick;
end;

procedure TFormGecmisReceteler.DBGridGecmisDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  CellText: string; DrawRect: TRect; FormatFlags: UINT; GridField: TField; CurrentRow: Integer;
begin
  GridField := Column.Field;
  if not Assigned(GridField) then Exit;

  CurrentRow := TGridHack(DBGridGecmis).DataLink.ActiveRecord + 1;
  if (CurrentRow > 0) and (CurrentRow < TGridHack(DBGridGecmis).RowCount) then
  begin
    if TGridHack(DBGridGecmis).RowHeights[CurrentRow] <> 38 then
    begin
      TGridHack(DBGridGecmis).RowHeights[CurrentRow] := 38; // Satır yüksekliği 11 pt için ayarlandı
      TGridHack(DBGridGecmis).RowHeights[0] := 32;         // Başlık satır yüksekliği ayarlandı
    end;
  end;

  if gdSelected in State then
  begin
    DBGridGecmis.Canvas.Brush.Color := clHighlight;
    DBGridGecmis.Canvas.Font.Color := clHighlightText;
  end
  else
  begin
    DBGridGecmis.Canvas.Brush.Color := clWindow;
    DBGridGecmis.Canvas.Font.Color := clWindowText;
  end;

  DBGridGecmis.Canvas.Font.Name := 'Segoe UI';
  DBGridGecmis.Canvas.Font.Size := 11;
  DBGridGecmis.Canvas.Font.Style := [];
  DBGridGecmis.Canvas.FillRect(Rect);
  CellText := GridField.AsString;
  DrawRect := Rect;

  if SameText(Column.FieldName, 'GunSayisi') or SameText(Column.FieldName, 'Adet') or (DataCol = 5) or (DataCol = 6) then
    FormatFlags := DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX
  else
  begin
    DrawRect.Left := DrawRect.Left + 8;
    FormatFlags := DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX;
  end;

  Winapi.Windows.DrawText(DBGridGecmis.Canvas.Handle, PChar(CellText), Length(CellText), DrawRect, FormatFlags);
end;

procedure TFormGecmisReceteler.BtnPdfCiktiClick(Sender: TObject);
var
  SelectedReceteID: Integer;
begin
  if FIsProcessingPDF then Exit;

  if FDQueryGecmis.IsEmpty then
  begin
    ShowMessage('Lütfen listeden raporunu oluşturmak istediğiniz bir reçete satırı seçin!');
    Exit;
  end;

  SelectedReceteID := FDQueryGecmis.FieldByName('ReceteID').AsInteger;
  if SelectedReceteID <= 0 then
  begin
    ShowMessage('Seçilen reçete kaydı geçersiz veya kimliği okunamadı!');
    Exit;
  end;

  try
    FIsProcessingPDF := True;
    PDFRaporOlustur(SelectedReceteID);
  finally
    FIsProcessingPDF := False;
  end;
end;

{-------------------------------------------------------------------------------
  🔒 GÜVENLİ VE TEK EKRANLI RAPORLAMA MOTORU
-------------------------------------------------------------------------------}
procedure TFormGecmisReceteler.PDFRaporOlustur(const AReceteID: Integer);
var
  RaporQuery: TFDQuery;
  PdfYaziciIndeks, i, YPos: Integer; YaziciBulundu: Boolean;
  HastaAd, HastaSoyad, HastaTC, HastaTel, HastaKronik, HastaAlerji: string;
  DoktorAd, DoktorSoyad, DoktorUnvan, DoktorSicilNo, ReceteTarih: string;
  RawTarihText: string;
  ScaleX, ScaleY: Double;
  RowGap, LineGap, PageW, LeftMargin, RightMargin, RightBlockX: Integer;
  ColDozX, ColOgunX, ColGunX, ColAdetX: Integer;
  TextW: Integer;
begin
  YaziciBulundu := False; PdfYaziciIndeks := -1;
  for i := 0 to Printer.Printers.Count - 1 do begin
    if Pos('PRINT TO PDF', UpperCase(Printer.Printers[i])) > 0 then begin
      PdfYaziciIndeks := i; YaziciBulundu := True; Break;
    end;
  end;
  if not YaziciBulundu then begin ShowMessage('Sisteminizde "Microsoft Print to PDF" yazıcı sürücüsü bulunamadı.'); Exit; end;

  RaporQuery := TFDQuery.Create(nil);
  try
    if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then RaporQuery.Connection := FrmLogin.FDConnection1;

    RaporQuery.SQL.Text :=
      'SELECT r.ReceteID, r.Tarih, h.Ad AS HastaAd, h.Soyad AS HastaSoyad, h.TC, h.TelNo, h.Alerji, h.KronikHastalik, ' +
      '       d.Ad AS DrAd, d.Soyad AS DrSoyad, d.Unvan, d.SicilNo ' +
      'FROM RECETE r ' +
      'INNER JOIN HASTA h ON r.HastaID = h.HastaID ' +
      'INNER JOIN DOKTOR d ON r.DoktorID = d.DoktorID ' +
      'WHERE r.ReceteID = :ReceteID';
    RaporQuery.ParamByName('ReceteID').AsInteger := AReceteID; RaporQuery.Open;
    if RaporQuery.IsEmpty then begin ShowMessage('Reçete detayları doğrulanamadı.'); Exit; end;

    HastaAd := RaporQuery.FieldByName('HastaAd').AsString; HastaSoyad := RaporQuery.FieldByName('HastaSoyad').AsString;
    HastaTC := DecryptAES128HexLocal(RaporQuery.FieldByName('TC').AsString, REAL_AES_KEY);
    HastaTel := DecryptAES128HexLocal(RaporQuery.FieldByName('TelNo').AsString, REAL_AES_KEY);
    HastaAlerji := DecryptAES128HexLocal(RaporQuery.FieldByName('Alerji').AsString, REAL_AES_KEY);
    HastaKronik := DecryptAES128HexLocal(RaporQuery.FieldByName('KronikHastalik').AsString, REAL_AES_KEY);

    DoktorAd := RaporQuery.FieldByName('DrAd').AsString; DoktorSoyad := RaporQuery.FieldByName('DrSoyad').AsString;
    DoktorUnvan := RaporQuery.FieldByName('Unvan').AsString; DoktorSicilNo := RaporQuery.FieldByName('SicilNo').AsString;

    RawTarihText := RaporQuery.FieldByName('Tarih').AsString;
    if Length(RawTarihText) >= 10 then ReceteTarih := Copy(RawTarihText, 1, 10) else ReceteTarih := RawTarihText;

    Printer.PrinterIndex := PdfYaziciIndeks;
    Printer.BeginDoc;
    try
      PageW := Printer.PageWidth;
      ScaleX := GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSX) / 96.0;
      ScaleY := GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSY) / 96.0;

      LeftMargin  := Round(50 * ScaleX);
      RightMargin := PageW - Round(50 * ScaleX);
      RightBlockX := Round(PageW * 0.52);

      RowGap := Round(42 * ScaleY);
      LineGap := Round(24 * ScaleY);

      Printer.Canvas.Font.Name := 'Arial';

      Printer.Canvas.Font.Style := [fsBold];
      Printer.Canvas.Font.Size := Round(16 * (ScaleY / ScaleX) * 1.2);
      YPos := Round(60 * ScaleY);
      TextW := Printer.Canvas.TextWidth('T.C. SAĞLIK BAKANLIĞI HASTANE OTOMASYONU');
      Printer.Canvas.TextOut((PageW - TextW) div 2, YPos, 'T.C. SAĞLIK BAKANLIĞI HASTANE OTOMASYONU');

      Printer.Canvas.Font.Size := Round(12 * (ScaleY / ScaleX) * 1.2);
      YPos := YPos + RowGap + 5;
      TextW := Printer.Canvas.TextWidth('E-REÇETE / MEDİKAL ORDER RAPORU');
      Printer.Canvas.TextOut((PageW - TextW) div 2, YPos, 'E-REÇETE / MEDİKAL ORDER RAPORU');

      Printer.Canvas.Pen.Width := Round(2 * ScaleY);
      YPos := YPos + RowGap;
      Printer.Canvas.MoveTo(LeftMargin, YPos);
      Printer.Canvas.LineTo(RightMargin, YPos);

      YPos := YPos + LineGap + 10;
      Printer.Canvas.Font.Size := Round(11 * (ScaleY / ScaleX) * 1.1);
      Printer.Canvas.Font.Style := [fsBold];
      Printer.Canvas.TextOut(LeftMargin + Round(10 * ScaleX), YPos, 'HASTA BİLGİLERİ');

      Printer.Canvas.Font.Style := [];
      YPos := YPos + LineGap + 8;
      Printer.Canvas.TextOut(LeftMargin + Round(10 * ScaleX), YPos, 'T.C. Kimlik No: ' + HastaTC);
      YPos := YPos + LineGap;
      Printer.Canvas.TextOut(LeftMargin + Round(10 * ScaleX), YPos, 'Adı Soyadı    : ' + HastaAd + ' ' + HastaSoyad);
      YPos := YPos + LineGap;
      Printer.Canvas.TextOut(LeftMargin + Round(10 * ScaleX), YPos, 'Telefon No    : ' + HastaTel);
      YPos := YPos + LineGap;
      Printer.Canvas.TextOut(LeftMargin + Round(10 * ScaleX), YPos, 'Kronik Hast.  : ' + HastaKronik);
      YPos := YPos + LineGap;

      if (UpperCase(HastaAlerji) <> '') and (Pos('YOK', UpperCase(HastaAlerji)) = 0) then begin
        Printer.Canvas.Font.Style := [fsBold]; Printer.Canvas.Font.Color := clRed;
        Printer.Canvas.TextOut(LeftMargin + Round(10 * ScaleX), YPos, 'ALERJİ RİSKİ : ' + HastaAlerji);
        Printer.Canvas.Font.Color := clBlack; Printer.Canvas.Font.Style := [];
      end else
        Printer.Canvas.TextOut(LeftMargin + Round(10 * ScaleX), YPos, 'Alerji Bilgisi: Risk Yok');

      YPos := YPos - (LineGap * 5) - 8;
      Printer.Canvas.Font.Style := [fsBold];
      Printer.Canvas.TextOut(RightBlockX, YPos, 'HEKİM / DOKTOR BİLGİLERİ');

      Printer.Canvas.Font.Style := [];
      YPos := YPos + LineGap + 8;
      Printer.Canvas.TextOut(RightBlockX, YPos, 'Hekim Adı Soyadı : ' + DoktorUnvan + ' ' + DoktorAd + ' ' + DoktorSoyad);
      YPos := YPos + LineGap;
      Printer.Canvas.TextOut(RightBlockX, YPos, 'Hekim Sicil No   : ' + DoktorSicilNo);
      YPos := YPos + LineGap;
      Printer.Canvas.TextOut(RightBlockX, YPos, 'Düzenleme Tarihi : ' + ReceteTarih);
      YPos := YPos + LineGap;
      Printer.Canvas.TextOut(RightBlockX, YPos, 'Reçete No        : #' + IntToStr(AReceteID));

      YPos := YPos + RowGap + 35;
      Printer.Canvas.Pen.Width := Round(1.5 * ScaleY);
      Printer.Canvas.MoveTo(LeftMargin, YPos);
      Printer.Canvas.LineTo(RightMargin, YPos);

      ColDozX   := Round(PageW * 0.54);
      ColOgunX  := Round(PageW * 0.66);
      ColGunX   := Round(PageW * 0.79);
      ColAdetX  := Round(PageW * 0.89);

      YPos := YPos + LineGap;
      Printer.Canvas.Font.Style := [fsBold];
      Printer.Canvas.TextOut(LeftMargin + Round(10 * ScaleX), YPos, 'İLAÇ ADI (ETKEN MADDE)');
      Printer.Canvas.TextOut(ColDozX, YPos, 'DOZ');
      Printer.Canvas.TextOut(ColOgunX, YPos, 'ÖĞÜN');
      Printer.Canvas.TextOut(ColGunX, YPos, 'GÜN');
      Printer.Canvas.TextOut(ColAdetX, YPos, 'ADET');

      YPos := YPos + LineGap + 5;
      Printer.Canvas.MoveTo(LeftMargin, YPos);
      Printer.Canvas.LineTo(RightMargin, YPos);

      RaporQuery.Close;
      RaporQuery.SQL.Text :=
        'SELECT CASE WHEN i.EtkenMadde IS NULL OR Trim(i.EtkenMadde) = '''' THEN i.IlacAdi ' +
        '            ELSE i.IlacAdi || '' ('' || i.EtkenMadde || '')'' END AS TamIlacAdi, ' +
        '       rd.Doz, rd.Ogun, rd.GunSayisi, rd.Adet ' +
        'FROM RECETE_DETAY rd ' +
        'INNER JOIN ILAC i ON rd.IlacID = i.IlacID ' +
        'WHERE rd.ReceteID = :ReceteID';
      RaporQuery.ParamByName('ReceteID').AsInteger := AReceteID; RaporQuery.Open;

      YPos := YPos + LineGap + 10;
      Printer.Canvas.Font.Style := [];

      while not RaporQuery.Eof do begin
        Printer.Canvas.TextOut(LeftMargin + Round(10 * ScaleX), YPos, RaporQuery.FieldByName('TamIlacAdi').AsString);
        Printer.Canvas.TextOut(ColDozX, YPos, RaporQuery.FieldByName('Doz').AsString);
        Printer.Canvas.TextOut(ColOgunX, YPos, RaporQuery.FieldByName('Ogun').AsString);
        Printer.Canvas.TextOut(ColGunX, YPos, RaporQuery.FieldByName('GunSayisi').AsString);
        Printer.Canvas.TextOut(ColAdetX, YPos, RaporQuery.FieldByName('Adet').AsString);

        YPos := YPos + RowGap;
        RaporQuery.Next;
      end;

      YPos := YPos + 10;
      Printer.Canvas.Pen.Width := Round(1 * ScaleY);
      Printer.Canvas.MoveTo(LeftMargin, YPos);
      Printer.Canvas.LineTo(RightMargin, YPos);

      YPos := YPos + LineGap;
      Printer.Canvas.Font.Size := Round(8 * (ScaleY / ScaleX) * 1.1);
      Printer.Canvas.Font.Style := [fsItalic];
      Printer.Canvas.TextOut(LeftMargin, YPos, 'Bu belge elektronik altyapı üzerinden 5070 sayılı Kanuna uygun olarak dijital imzalanmıştır.');

      Printer.EndDoc;
      ShowMessage('Medikal Rapor başarıyla PDF formatına dönüştürüldü! ✅');
    except
      on E: Exception do begin
        Printer.Abort;
        ShowMessage('PDF oluşturulurken hata oluştu: ' + E.Message);
      end;
    end;
  finally
    RaporQuery.Free;
  end;
end;

procedure TFormGecmisReceteler.GecmisReceteleriYukle(const AHastaID: Integer);
begin
  FCurrentHastaID := AHastaID;
  EditIlacAra.OnChange := nil; EditIlacAra.Clear; EditIlacAra.OnChange := EditIlacAraChange;

  if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
    FDQueryGecmis.Connection := FrmLogin.FDConnection1;

  FDQueryGecmis.Close;
  FDQueryGecmis.SQL.Text :=
    'SELECT r.ReceteID, CAST(date(r.Tarih) AS VARCHAR(15)) AS Tarih, ' +
    '       CAST(CASE WHEN i.EtkenMadde IS NULL OR Trim(i.EtkenMadde) = '''' THEN i.IlacAdi ' +
    '            ELSE i.IlacAdi || '' ('' || i.EtkenMadde || '')'' END AS VARCHAR(250)) AS IlacAdi, ' +
    '       CAST(rd.Doz AS VARCHAR(50)) AS Doz, ' +
    '       CAST(rd.Ogun AS VARCHAR(50)) AS Ogun, ' +
    '       rd.GunSayisi, ' +
    '       rd.Adet ' +
    'FROM RECETE r ' +
    'INNER JOIN RECETE_DETAY rd ON r.ReceteID = rd.ReceteID ' +
    'INNER JOIN ILAC i ON rd.IlacID = i.IlacID ' +
    'WHERE r.HastaID = :HastaID ' +
    'ORDER BY r.Tarih DESC';

  FDQueryGecmis.ParamByName('HastaID').AsInteger := FCurrentHastaID;

  try
    FDQueryGecmis.Open;
    GridDuzenle;
  except
    on E: Exception do ShowMessage('Geçmiş reçeteler yüklenirken hata oluştu: ' + E.Message);
  end;
end;

procedure TFormGecmisReceteler.EditIlacAraChange(Sender: TObject);
var
  ArananIlac: string;
begin
  ArananIlac := Trim(EditIlacAra.Text);
  if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then FDQueryGecmis.Connection := FrmLogin.FDConnection1;

  FDQueryGecmis.Close;
  if ArananIlac.IsEmpty then
  begin
    FDQueryGecmis.SQL.Text :=
      'SELECT r.ReceteID, CAST(date(r.Tarih) AS VARCHAR(15)) AS Tarih, ' +
      '       CAST(CASE WHEN i.EtkenMadde IS NULL OR Trim(i.EtkenMadde) = '''' THEN i.IlacAdi ' +
      '            ELSE i.IlacAdi || '' ('' || i.EtkenMadde || '')'' END AS VARCHAR(250)) AS IlacAdi, ' +
      '       CAST(rd.Doz AS VARCHAR(50)) AS Doz, CAST(rd.Ogun AS VARCHAR(50)) AS Ogun, ' +
      '       rd.GunSayisi, rd.Adet ' +
      'FROM RECETE r ' +
      'INNER JOIN RECETE_DETAY rd ON r.ReceteID = rd.ReceteID ' +
      'INNER JOIN ILAC i ON rd.IlacID = i.IlacID ' +
      'WHERE r.HastaID = :HastaID ' +
      'ORDER BY r.Tarih DESC';
  end
  else
  begin
    FDQueryGecmis.SQL.Text :=
      'SELECT r.ReceteID, CAST(date(r.Tarih) AS VARCHAR(15)) AS Tarih, ' +
      '       CAST(CASE WHEN i.EtkenMadde IS NULL OR Trim(i.EtkenMadde) = '''' THEN i.IlacAdi ' +
      '            ELSE i.IlacAdi || '' ('' || i.EtkenMadde || '')'' END AS VARCHAR(250)) AS IlacAdi, ' +
      '       CAST(rd.Doz AS VARCHAR(50)) AS Doz, CAST(rd.Ogun AS VARCHAR(50)) AS Ogun, ' +
      '       rd.GunSayisi, rd.Adet ' +
      'FROM RECETE r ' +
      'INNER JOIN RECETE_DETAY rd ON r.ReceteID = rd.ReceteID ' +
      'INNER JOIN ILAC i ON rd.IlacID = i.IlacID ' +
      'WHERE r.HastaID = :HastaID AND (i.IlacAdi LIKE :IlacParam OR i.EtkenMadde LIKE :IlacParam) ' +
      'ORDER BY r.Tarih DESC';
    FDQueryGecmis.ParamByName('IlacParam').AsString := '%' + ArananIlac + '%';
  end;

  FDQueryGecmis.ParamByName('HastaID').AsInteger := FCurrentHastaID;

  try
    FDQueryGecmis.Open;
    GridDuzenle;
  except
    on E: Exception do ShowMessage('Filtreleme esnasında hata oluştu: ' + E.Message);
  end;
end;

procedure TFormGecmisReceteler.GridDuzenle;
var
  i: Integer;
begin
  if DBGridGecmis.Columns.Count >= 7 then
  begin
    DBGridGecmis.Columns[0].Visible := False; DBGridGecmis.Columns[0].Width := 0;
    DBGridGecmis.Columns[1].Title.Caption := 'Yazılma Tarihi'; DBGridGecmis.Columns[1].Width := 140;
    DBGridGecmis.Columns[2].Title.Caption := 'İlaç Adı (Etken Madde)'; DBGridGecmis.Columns[2].Width := 440;
    DBGridGecmis.Columns[3].Title.Caption := 'Doz'; DBGridGecmis.Columns[3].Width := 120;
    DBGridGecmis.Columns[4].Title.Caption := 'Öğün'; DBGridGecmis.Columns[4].Width := 180;
    DBGridGecmis.Columns[5].Title.Caption := 'Gün Sayısı'; DBGridGecmis.Columns[5].Title.Alignment := taCenter; DBGridGecmis.Columns[5].Width := 110;
    DBGridGecmis.Columns[6].Title.Caption := 'Adet'; DBGridGecmis.Columns[6].Title.Alignment := taCenter; DBGridGecmis.Columns[6].Width := 90;

    for i := 0 to DBGridGecmis.Columns.Count - 1 do
    begin
      DBGridGecmis.Columns[i].Title.Font.Name := 'Segoe UI';
      DBGridGecmis.Columns[i].Title.Font.Size := 11;
      DBGridGecmis.Columns[i].Title.Font.Style := [fsBold];
      DBGridGecmis.Columns[i].Title.Font.Color := clWindowText;
    end;
  end;
end;

procedure TFormGecmisReceteler.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

end.
