unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.CheckLst,
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option, System.UITypes, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, Data.DB, FireDAC.Stan.Async, FireDAC.DApt, Vcl.ComCtrls;

type
  TForm3 = class(TForm)
    PanelSolDetay: TPanel;
    PanelSagRecete: TPanel;
    LabelDetayHeader: TLabel;
    LabelAdSoyadBaslik: TLabel;
    LabelAdSoyad: TLabel;
    LabelTCBaslik: TLabel;
    LabelTC: TLabel;
    LabelCinsiyetBaslik: TLabel;
    LabelCinsiyetYil: TLabel;
    LabelBoyKiloBaslik: TLabel;
    LabelBoyKilo: TLabel;
    LabelGebelikEmzirmeBaslik: TLabel;
    LabelGebelikEmzirme: TLabel;
    LabelTelNoBaslik: TLabel;
    LabelTelNo: TLabel;
    LabelKonumBaslik: TLabel;
    LabelKonum: TLabel;
    LabelDrNotuBaslik: TLabel;
    LabelDrNotu: TLabel;
    LabelKronikBaslik: TLabel;
    LabelKronik: TLabel;

    PanelAlerjiKutu: TPanel;
    LabelAlerjiBaslik: TLabel;
    LabelAlerji: TLabel;

    LabelReceteHeader: TLabel;
    LabelIlacAdi: TLabel;
    ComboIlacSecimi: TComboBox;
    LabelDoz: TLabel;
    EditDoz: TEdit;
    LabelOgun: TLabel;
    clbOgunler: TCheckListBox;
    LabelGunSayisi: TLabel;
    EditGunSayisi: TEdit;
    LabelAdet: TLabel;
    EditAdet: TEdit;
    BtnKaydet: TPanel;

    FDQueryHasta: TFDQuery;
    FDQueryIlaclar: TFDQuery;
    BtnGecmisRecete: TPanel;
    ListView1: TListView;
    BtnIlacEkle: TPanel;
    BtnIlacSil: TPanel;

    procedure FormCreate(Sender: TObject);
    procedure BtnKaydetClick(Sender: TObject);
    procedure BtnIlacEkleClick(Sender: TObject);
    procedure BtnIlacSilClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnGecmisReceteClick(Sender: TObject);
    procedure ComboIlacSecimiChange(Sender: TObject);
    procedure ComboIlacSecimiDropDown(Sender: TObject); 
  private
    { Private declarations }
    FCurrentHastaID: Integer;
    FLoggedInDoktorID: Integer;

    function DecryptAES128Hex(const EncryptedHexText: string; const Key: string): string;
    procedure IlaclariYukle(const AAramaMetni: string = '');
    procedure InputAlanlariniTemizle;
  public
    { Public declarations }
    procedure HastaYukle(const AHastaID: Integer; const ADoktorID: Integer);
  end;

var
  Form3: TForm3;

const
  REAL_AES_KEY = 'K9f!X2#mP8$zL5*q'; 
  REAL_AES_IV  = 'r4#mQ9$zK2!pL5*x'; 

implementation

{$R *.dfm}

uses Unit1, Unit4;

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

function TForm3.DecryptAES128Hex(const EncryptedHexText: string; const Key: string): string;
var
  CleanHex: string;
  EncryptedBytes, KeyBytes, IVBytes, DecryptedBytes: TBytes;
  PaddingCount: Integer;

  hBCryptLib: HMODULE;
  BCryptOpenAlgorithmProvider: TBCryptOpenAlgorithmProvider;
  BCryptSetProperty: TBCryptSetProperty;
  BCryptGetProperty: TBCryptGetProperty;
  BCryptGenerateSymmetricKey: TBCryptGenerateSymmetricKey;
  BCryptDecrypt: TBCryptDecrypt;
  BCryptDestroyKey: TBCryptDestroyKey;
  BCryptCloseAlgorithmProvider: TBCryptCloseAlgorithmProvider;

  hAlg: BCRYPT_ALG_HANDLE;
  hKey: BCRYPT_KEY_HANDLE;
  cbKeyObject, cbResult, cbPlaintext: ULONG;
  pbKeyObject: PByte;
  LocalIV: TBytes;
  Status: LONG;

  ModeCBC: WideString;
begin
  CleanHex := System.SysUtils.Trim(EncryptedHexText);

  if (CleanHex = '') or (Length(CleanHex) mod 2 <> 0) then
  begin
    Result := EncryptedHexText;
    Exit;
  end;

  hBCryptLib := LoadLibrary('bcrypt.dll');
  if hBCryptLib = 0 then
  begin
    Result := EncryptedHexText;
    Exit;
  end;

  @BCryptOpenAlgorithmProvider   := GetProcAddress(hBCryptLib, 'BCryptOpenAlgorithmProvider');
  @BCryptSetProperty             := GetProcAddress(hBCryptLib, 'BCryptSetProperty');
  @BCryptGetProperty             := GetProcAddress(hBCryptLib, 'BCryptGetProperty');
  @BCryptGenerateSymmetricKey   := GetProcAddress(hBCryptLib, 'BCryptGenerateSymmetricKey');
  @BCryptDecrypt                 := GetProcAddress(hBCryptLib, 'BCryptDecrypt');
  @BCryptDestroyKey              := GetProcAddress(hBCryptLib, 'BCryptDestroyKey');
  @BCryptCloseAlgorithmProvider := GetProcAddress(hBCryptLib, 'BCryptCloseAlgorithmProvider');

  hAlg := nil;
  hKey := nil;
  pbKeyObject := nil;
  Result := EncryptedHexText;

  try
    SetLength(EncryptedBytes, Length(CleanHex) div 2);
    HexToBin(PChar(CleanHex), Pointer(EncryptedBytes), Length(EncryptedBytes));

    KeyBytes := TEncoding.UTF8.GetBytes(Key);
    IVBytes  := TEncoding.UTF8.GetBytes(REAL_AES_IV);
    LocalIV  := Copy(IVBytes);

    Status := BCryptOpenAlgorithmProvider(hAlg, 'AES', nil, 0);
    if Status <> 0 then Exit;

    ModeCBC := 'ChainingModeCBC';
    Status := BCryptSetProperty(hAlg, 'ChainingMode', PByte(PWideChar(ModeCBC)), (Length(ModeCBC) + 1) * SizeOf(WideChar), 0);
    if Status <> 0 then Exit;

    Status := BCryptGetProperty(hAlg, 'ObjectLength', PByte(@cbKeyObject), SizeOf(ULONG), cbResult, 0);
    if Status <> 0 then Exit;
    GetMem(pbKeyObject, cbKeyObject);

    Status := BCryptGenerateSymmetricKey(hAlg, hKey, pbKeyObject, cbKeyObject, PByte(KeyBytes), Length(KeyBytes), 0);
    if Status <> 0 then Exit;

    SetLength(DecryptedBytes, Length(EncryptedBytes));
    Status := BCryptDecrypt(hKey, PByte(EncryptedBytes), Length(EncryptedBytes), nil, PByte(LocalIV), Length(LocalIV), PByte(DecryptedBytes), Length(DecryptedBytes), cbPlaintext, 0);
    if Status <> 0 then Exit;

    SetLength(DecryptedBytes, cbPlaintext);

    if Length(DecryptedBytes) > 0 then
    begin
      PaddingCount := DecryptedBytes[Length(DecryptedBytes) - 1];
      if (PaddingCount > 0) and (PaddingCount <= 16) then
      begin
        SetLength(DecryptedBytes, Length(DecryptedBytes) - PaddingCount);
      end;
    end;

    Result := TEncoding.UTF8.GetString(DecryptedBytes);

  except
    Result := EncryptedHexText;
  end;

  if hKey <> nil then BCryptDestroyKey(hKey);
  if pbKeyObject <> nil then FreeMem(pbKeyObject);
  if hAlg <> nil then BCryptCloseAlgorithmProvider(hAlg, 0);
  FreeLibrary(hBCryptLib);
end;

procedure TForm3.InputAlanlariniTemizle;
var
  i: Integer;
begin
  ComboIlacSecimi.OnChange := nil;
  ComboIlacSecimi.ItemIndex := -1;
  ComboIlacSecimi.Text := '';
  ComboIlacSecimi.OnChange := ComboIlacSecimiChange;

  EditDoz.Clear;
  for i := 0 to clbOgunler.Items.Count - 1 do
    clbOgunler.Checked[i] := False;
  EditGunSayisi.Clear;
  EditAdet.Clear;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  Self.Position := poMainFormCenter;
  Self.Caption := 'Hasta Detay Bilgileri ve Reçete Yönetimi';

  PanelSolDetay.Align := alLeft;
  PanelSolDetay.BevelOuter := bvNone;

  PanelSagRecete.Align := alClient;
  PanelSagRecete.BevelOuter := bvNone;

  ComboIlacSecimi.AutoComplete := False;
  ComboIlacSecimi.Style := csDropDown;
  ComboIlacSecimi.OnChange := ComboIlacSecimiChange;
  ComboIlacSecimi.OnDropDown := ComboIlacSecimiDropDown; 

  if clbOgunler.Items.Count = 0 then
  begin
    clbOgunler.Items.Add('Sabah');
    clbOgunler.Items.Add('Öğle');
    clbOgunler.Items.Add('Akşam');
  end;

  ListView1.ViewStyle := vsReport;
  ListView1.RowSelect := True;
  ListView1.GridLines := True;

  BtnIlacEkle.OnClick := BtnIlacEkleClick;
  BtnIlacSil.OnClick  := BtnIlacSilClick;
  BtnKaydet.OnClick   := BtnKaydetClick;
  BtnGecmisRecete.OnClick := BtnGecmisReceteClick;

  Self.OnClose := FormClose;
end;

procedure TForm3.IlaclariYukle(const AAramaMetni: string = '');
var
  GorunurIsim, AramaTerm: string;
begin
  ComboIlacSecimi.Items.BeginUpdate;
  try
    ComboIlacSecimi.Items.Clear;

    FDQueryIlaclar.Close;
    FDQueryIlaclar.SQL.Clear;

    AramaTerm := Trim(AAramaMetni);

    if AramaTerm = '' then
    begin
      FDQueryIlaclar.SQL.Text :=
        'SELECT IlacID, IlacAdi, ' +
        '       CASE WHEN EtkenMadde IS NULL THEN '''' ELSE EtkenMadde END AS EtkenMadde ' +
        'FROM ILAC ORDER BY IlacAdi';
    end
    else
    begin
      FDQueryIlaclar.SQL.Text :=
        'SELECT IlacID, IlacAdi, ' +
        '       CASE WHEN EtkenMadde IS NULL THEN '''' ELSE EtkenMadde END AS EtkenMadde ' +
        'FROM ILAC ' +
        'WHERE (LOWER(IlacAdi) LIKE :Arama) OR (LOWER(EtkenMadde) LIKE :Arama) ' +
        'ORDER BY IlacAdi';
      FDQueryIlaclar.ParamByName('Arama').AsString := '%' + LowerCase(AramaTerm) + '%';
    end;

    try
      FDQueryIlaclar.Open;
    except
      Exit;
    end;

    while not FDQueryIlaclar.Eof do
    begin
      if Trim(FDQueryIlaclar.FieldByName('EtkenMadde').AsString) <> '' then
        GorunurIsim := FDQueryIlaclar.FieldByName('IlacAdi').AsString + ' (' + FDQueryIlaclar.FieldByName('EtkenMadde').AsString + ')'
      else
        GorunurIsim := FDQueryIlaclar.FieldByName('IlacAdi').AsString;

      ComboIlacSecimi.Items.AddObject(
        GorunurIsim,
        TObject(FDQueryIlaclar.FieldByName('IlacID').AsInteger)
      );
      FDQueryIlaclar.Next;
    end;
  finally
    ComboIlacSecimi.Items.EndUpdate;
  end;
end;

procedure TForm3.ComboIlacSecimiDropDown(Sender: TObject);
begin
  if Trim(ComboIlacSecimi.Text) = '' then
  begin
    ComboIlacSecimi.OnChange := nil;
    try
      IlaclariYukle('');
    finally
      ComboIlacSecimi.OnChange := ComboIlacSecimiChange;
    end;
  end;
end;

procedure TForm3.ComboIlacSecimiChange(Sender: TObject);
var
  MevcutMetin: string;
begin
  if ComboIlacSecimi.ItemIndex <> -1 then Exit;

  MevcutMetin := ComboIlacSecimi.Text;

  ComboIlacSecimi.OnChange := nil; 
  try
    if Trim(MevcutMetin) = '' then
    begin
      IlaclariYukle('');
      ComboIlacSecimi.Text := '';
    end
    else
    begin
      IlaclariYukle(MevcutMetin);
      ComboIlacSecimi.Text := MevcutMetin;
      ComboIlacSecimi.SelStart := Length(MevcutMetin);

      if ComboIlacSecimi.Items.Count > 0 then
        ComboIlacSecimi.DroppedDown := True;
    end;
  finally
    ComboIlacSecimi.OnChange := ComboIlacSecimiChange;
  end;
end;

procedure TForm3.HastaYukle(const AHastaID: Integer; const ADoktorID: Integer);
var
  RawAlerji, CinsiyetDurumu: string;
begin
  FCurrentHastaID := AHastaID;
  FLoggedInDoktorID := ADoktorID;

  if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
  begin
    FDQueryHasta.Connection := FrmLogin.FDConnection1;
    FDQueryIlaclar.Connection := FrmLogin.FDConnection1;
  end;

  IlaclariYukle(''); 
  ListView1.Items.Clear;

  FDQueryHasta.Close;
  FDQueryHasta.SQL.Text :=
    'SELECT h.*, ' +
    '       CAST(y.ServisAdi AS VARCHAR(100)) AS ServisNo, ' +
    '       CAST(y.OdaNo AS VARCHAR(20)) AS OdaNo, ' +
    '       CAST(y.YatakNo AS VARCHAR(20)) AS YatakNo ' +
    'FROM HASTA h ' +
    'LEFT JOIN YATIS y ON h.HastaID = y.HastaID AND y.AktifMi = ''Evet'' ' +
    'WHERE h.HastaID = :HastaID';
  FDQueryHasta.ParamByName('HastaID').AsInteger := FCurrentHastaID;
  FDQueryHasta.Open;

  if not FDQueryHasta.IsEmpty then
  begin
    LabelAdSoyad.Caption := FDQueryHasta.FieldByName('Ad').AsString + ' ' + FDQueryHasta.FieldByName('Soyad').AsString;
    LabelTC.Caption := DecryptAES128Hex(FDQueryHasta.FieldByName('TC').AsString, REAL_AES_KEY);

    CinsiyetDurumu := UpperCase(System.SysUtils.Trim(FDQueryHasta.FieldByName('Cinsiyet').AsString));
    LabelCinsiyetYil.Caption := FDQueryHasta.FieldByName('Cinsiyet').AsString + ' / ' + FDQueryHasta.FieldByName('DogumYili').AsString;

    if (CinsiyetDurumu = 'ERKEK') or (CinsiyetDurumu = 'E') then
    begin
      LabelGebelikEmzirmeBaslik.Visible := False;
      LabelGebelikEmzirme.Visible := False;
    end
    else
    begin
      LabelGebelikEmzirmeBaslik.Visible := True;
      LabelGebelikEmzirme.Visible := True;
      LabelGebelikEmzirme.Caption := 'Gebe: ' + FDQueryHasta.FieldByName('Gebe').AsString + ' / Emzirme: ' + FDQueryHasta.FieldByName('Emzirme').AsString;
    end;

    LabelBoyKilo.Caption := FDQueryHasta.FieldByName('Boy').AsString + ' cm / ' + FDQueryHasta.FieldByName('Kilo').AsString + ' kg';
    LabelTelNo.Caption := DecryptAES128Hex(FDQueryHasta.FieldByName('TelNo').AsString, REAL_AES_KEY);

    if not FDQueryHasta.FieldByName('ServisNo').IsNull then
    begin
      LabelKonum.Caption := FDQueryHasta.FieldByName('ServisNo').AsString +
        ' (Oda: ' + FDQueryHasta.FieldByName('OdaNo').AsString +
        ' / Yatak: ' + FDQueryHasta.FieldByName('YatakNo').AsString + ')';
    end
    else
    begin
      LabelKonum.Caption := 'Ayakta Tedavi / Poliklinik';
    end;

    if FDQueryHasta.FieldByName('DrNotu').AsString = '' then
      LabelDrNotu.Caption := 'Kayıtlı bir not bulunmuyor.'
    else
      LabelDrNotu.Caption := FDQueryHasta.FieldByName('DrNotu').AsString;

    LabelKronik.Caption := DecryptAES128Hex(FDQueryHasta.FieldByName('KronikHastalik').AsString, REAL_AES_KEY);

    RawAlerji := DecryptAES128Hex(FDQueryHasta.FieldByName('Alerji').AsString, REAL_AES_KEY);

    if (RawAlerji = '') or (UpperCase(RawAlerji) = 'YOK') or (Pos('YOK', UpperCase(RawAlerji)) > 0) then
    begin
      LabelAlerji.Caption := 'Kayıtlı Alerji Riski Yok.';
      LabelAlerji.Font.Color := clGreen;
      LabelAlerji.Font.Style := [];
      PanelAlerjiKutu.Color := Self.Color;
      PanelAlerjiKutu.ParentBackground := True;
    end
    else
    begin
      LabelAlerji.Caption := RawAlerji;
      LabelAlerji.Font.Color := clRed;
      LabelAlerji.Font.Style := [fsBold];
      PanelAlerjiKutu.ParentBackground := False;
      PanelAlerjiKutu.Color := RGB(255, 230, 230);
    end;
  end;
end;

procedure TForm3.BtnIlacEkleClick(Sender: TObject);
var
  Item: TListItem;
  SecilenIlacID: Integer;
  SecilenOgunler: string;
  i: Integer;
begin
  if ComboIlacSecimi.ItemIndex = -1 then
  begin
    ShowMessage('Lütfen listeden geçerli bir ilaç seçiniz!');
    Exit;
  end;

  if (Trim(EditDoz.Text) = '') or (Trim(EditAdet.Text) = '') then
  begin
    ShowMessage('Doz ve Adet doldurulmalı!');
    Exit;
  end;

  SecilenOgunler := '';
  for i := 0 to clbOgunler.Items.Count - 1 do
  begin
    if clbOgunler.Checked[i] then
    begin
      if SecilenOgunler <> '' then SecilenOgunler := SecilenOgunler + ', ';
      SecilenOgunler := SecilenOgunler + clbOgunler.Items[i];
    end;
  end;

  SecilenIlacID := Integer(ComboIlacSecimi.Items.Objects[ComboIlacSecimi.ItemIndex]);

  Item := ListView1.Items.Add;
  Item.Caption := ComboIlacSecimi.Text;
  Item.SubItems.Add(Trim(EditDoz.Text));
  Item.SubItems.Add(SecilenOgunler);
  Item.SubItems.Add(Trim(EditGunSayisi.Text));
  Item.SubItems.Add(Trim(EditAdet.Text));

  Item.Data := Pointer(SecilenIlacID);

  InputAlanlariniTemizle;
end;

procedure TForm3.BtnIlacSilClick(Sender: TObject);
begin
  if Assigned(ListView1.Selected) then
    ListView1.Selected.Delete
  else
    ShowMessage('Lütfen silmek istediğiniz ilacı listeden seçiniz!');
end;

procedure TForm3.BtnKaydetClick(Sender: TObject);
var
  YeniReceteID, SecilenIlacID, i: Integer;
  KayitQuery: TFDQuery;
  Item: TListItem;
  GunVal, AdetVal: Integer;
begin
  if ListView1.Items.Count = 0 then
  begin
    ShowMessage('Reçeteye en az 1 adet ilaç eklemelisiniz!');
    Exit;
  end;

  KayitQuery := TFDQuery.Create(nil);
  try
    if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
      KayitQuery.Connection := FrmLogin.FDConnection1
    else
    begin
      ShowMessage('Bağlantı hatası!');
      Exit;
    end;

    KayitQuery.Connection.StartTransaction;
    try
      KayitQuery.SQL.Text := 'INSERT INTO RECETE (DoktorID, HastaID, Tarih) VALUES (:DoktorID, :HastaID, :Tarih)';
      KayitQuery.ParamByName('DoktorID').AsInteger := FLoggedInDoktorID;
      KayitQuery.ParamByName('HastaID').AsInteger := FCurrentHastaID;
      KayitQuery.ParamByName('Tarih').AsDateTime := Date;
      KayitQuery.ExecSQL;

      KayitQuery.SQL.Text := 'SELECT MAX(ReceteID) AS SonID FROM RECETE';
      KayitQuery.Open;
      YeniReceteID := KayitQuery.FieldByName('SonID').AsInteger;
      KayitQuery.Close;

      KayitQuery.SQL.Text :=
        'INSERT INTO RECETE_DETAY (ReceteID, IlacID, Doz, Ogun, GunSayisi, Adet) ' +
        'VALUES (:ReceteID, :IlacID, :Doz, :Ogun, :GunSayisi, :Adet)';

      for i := 0 to ListView1.Items.Count - 1 do
      begin
        Item := ListView1.Items[i];
        SecilenIlacID := Integer(Item.Data);

        if not TryStrToInt(Item.SubItems[2], GunVal) then GunVal := 0;
        if not TryStrToInt(Item.SubItems[3], AdetVal) then AdetVal := 1;

        KayitQuery.ParamByName('ReceteID').AsInteger := YeniReceteID;
        KayitQuery.ParamByName('IlacID').AsInteger   := SecilenIlacID;
        KayitQuery.ParamByName('Doz').AsString       := Item.SubItems[0];
        KayitQuery.ParamByName('Ogun').AsString      := Item.SubItems[1];
        KayitQuery.ParamByName('GunSayisi').AsInteger := GunVal;
        KayitQuery.ParamByName('Adet').AsInteger      := AdetVal;

        KayitQuery.ExecSQL;
      end;

      KayitQuery.Connection.Commit;
      ShowMessage('Tüm ilaçlar reçeteye başarıyla kaydedildi! ✅');
      Self.Close;

    except
      on E: Exception do
      begin
        if KayitQuery.Connection.InTransaction then
          KayitQuery.Connection.Rollback;
        ShowMessage('Hata: ' + E.Message);
      end;
    end;
  finally
    KayitQuery.Free;
  end;
end;

procedure TForm3.BtnGecmisReceteClick(Sender: TObject);
begin
  if FCurrentHastaID <= 0 then Exit;

  if not Assigned(FormGecmisReceteler) then
    Application.CreateForm(TFormGecmisReceteler, FormGecmisReceteler);

  FormGecmisReceteler.GecmisReceteleriYukle(FCurrentHastaID);
  FormGecmisReceteler.ShowModal;
end;

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  InputAlanlariniTemizle;
  ListView1.Items.Clear;
  Action := caHide;
end;

end.
