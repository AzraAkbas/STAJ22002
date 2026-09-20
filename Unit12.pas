unit Unit12;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TForm12 = class(TForm)
    pnlTop: TPanel;
    pnlFormContainer: TPanel;

    Label1: TLabel; // Form Başlığı
    Label2: TLabel; // Barkod Label
    edtBarkod: TEdit;

    Label3: TLabel; // İlaç Adı Label
    edtIlacAdi: TEdit;
    cbTur: TComboBox;

    Label4: TLabel; // Etken Madde Label
    edtEtkenMadde: TEdit;

    Label5: TLabel; // Merkez Stok Label
    edtMerkezStok: TEdit;

    Label6: TLabel; // Kritik Eşik Label
    edtKritikEsik: TEdit;

    btnKaydet: TPanel;
    btnIptal: TPanel;

    qryIlacEkle: TFDQuery;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    procedure btnIptalClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FDuzenlemeModu: Boolean;
    FDuzenlenecekIlacID: Integer;
    procedure FormuTemizle;
    function BarkodVarMi(const ABarkod: string; const AHaricIlacID: Integer = 0): Boolean;
  public
    procedure FormuDuzenlemeModundaAc(const AIlacID: Integer);
    procedure FormuYeniKayitModundaAc; // 🌟 Yeni Kayıt Modu Metodu
  end;

var
  Form12: TForm12;

implementation

{$R *.dfm}

uses Unit1;

procedure TForm12.FormCreate(Sender: TObject);
begin
  Self.Caption := 'İlaç Tanımlama ve Düzenleme';
  Self.Position := poScreenCenter;
  Self.BorderStyle := bsDialog;
  Self.Width := 480;
  Self.Height := 580;
  Self.Color := RGB(248, 250, 252);

  Self.Font.Name := 'Segoe UI';
  Self.Font.Size := 11;

  pnlTop.BevelOuter := bvNone;
  pnlTop.Color := RGB(37, 99, 235);

  if Assigned(Label1) then
  begin
    Label1.Font.Name := 'Segoe UI';
    Label1.Font.Size := 13;
    Label1.Font.Style := [fsBold];
    Label1.Font.Color := clWhite;
    Label1.Caption := '✚ YENİ İLAÇ KAYIT FORMU';
  end;

  cbTur.Items.Clear;
  cbTur.ItemIndex := 0;

  btnKaydet.BevelOuter := bvNone;
  btnKaydet.Color := RGB(40, 167, 69);
  btnKaydet.Font.Color := clWhite;
  btnKaydet.Font.Style := [fsBold];
  btnKaydet.Caption := '✔ Kaydet';

  btnIptal.BevelOuter := bvNone;
  btnIptal.Color := RGB(108, 117, 125);
  btnIptal.Font.Color := clWhite;
  btnIptal.Font.Style := [fsBold];
  btnIptal.Caption := '❌ İptal';

  if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
    qryIlacEkle.Connection := FrmLogin.FDConnection1;

  FormuTemizle;
end;

procedure TForm12.FormShow(Sender: TObject);
begin
  if edtBarkod.CanFocus then
    edtBarkod.SetFocus;
end;

procedure TForm12.FormuTemizle;
begin
  edtBarkod.Clear;
  edtIlacAdi.Clear;
  edtEtkenMadde.Clear;
  cbTur.ItemIndex := 0;
  edtMerkezStok.Text := '0';
  edtKritikEsik.Text := '10';
  FDuzenlemeModu := False;
  FDuzenlenecekIlacID := 0;

  if Assigned(Label1) then
    Label1.Caption := 'YENİ İLAÇ KAYIT FORMU';
end;

{-------------------------------------------------------------------------------
  🌟 YENİ KAYIT MODU
-------------------------------------------------------------------------------}
procedure TForm12.FormuYeniKayitModundaAc;
begin
  FormuTemizle;
end;

{-------------------------------------------------------------------------------
  🌟 DÜZENLEME MODU
-------------------------------------------------------------------------------}
procedure TForm12.FormuDuzenlemeModundaAc(const AIlacID: Integer);
var
  GetQuery: TFDQuery;
  TurIndex: Integer;
begin
  FormuTemizle;
  FDuzenlemeModu := True;
  FDuzenlenecekIlacID := AIlacID;

  if Assigned(Label1) then
    Label1.Caption := 'İLAÇ BİLGİLERİNİ DÜZENLE';

  GetQuery := TFDQuery.Create(nil);
  try
    GetQuery.Connection := FrmLogin.FDConnection1;
    GetQuery.SQL.Text := 'SELECT Barkod, IlacAdi, Tur, EtkenMadde, MerkezStokMiktari, MerkezKritikEsik FROM ILAC WHERE IlacID = :pID;';
    GetQuery.ParamByName('pID').AsInteger := AIlacID;
    GetQuery.Open;

    if not GetQuery.IsEmpty then
    begin
      edtBarkod.Text := GetQuery.FieldByName('Barkod').AsString;
      edtIlacAdi.Text := GetQuery.FieldByName('IlacAdi').AsString;
      edtEtkenMadde.Text := GetQuery.FieldByName('EtkenMadde').AsString;
      edtMerkezStok.Text := GetQuery.FieldByName('MerkezStokMiktari').AsString;
      edtKritikEsik.Text := GetQuery.FieldByName('MerkezKritikEsik').AsString;

      TurIndex := cbTur.Items.IndexOf(GetQuery.FieldByName('Tur').AsString);
      if TurIndex >= 0 then
        cbTur.ItemIndex := TurIndex
      else
        cbTur.Text := GetQuery.FieldByName('Tur').AsString;
    end;
  finally
    GetQuery.Free;
  end;
end;

function TForm12.BarkodVarMi(const ABarkod: string; const AHaricIlacID: Integer = 0): Boolean;
var
  CheckQuery: TFDQuery;
begin
  Result := False;
  CheckQuery := TFDQuery.Create(nil);
  try
    CheckQuery.Connection := FrmLogin.FDConnection1;
    if AHaricIlacID > 0 then
    begin
      CheckQuery.SQL.Text := 'SELECT 1 FROM ILAC WHERE Barkod = :pBarkod AND IlacID <> :pID LIMIT 1;';
      CheckQuery.ParamByName('pID').AsInteger := AHaricIlacID;
    end
    else
      CheckQuery.SQL.Text := 'SELECT 1 FROM ILAC WHERE Barkod = :pBarkod LIMIT 1;';

    CheckQuery.ParamByName('pBarkod').AsString := ABarkod;
    CheckQuery.Open;
    Result := not CheckQuery.IsEmpty;
  finally
    CheckQuery.Free;
  end;
end;

procedure TForm12.btnKaydetClick(Sender: TObject);
var
  BarkodStr, IlacAdiStr, EtkenMaddeStr, TurStr: string;
  StokMiktari, KritikEsik: Integer;
begin
  BarkodStr := Trim(edtBarkod.Text);
  IlacAdiStr := Trim(edtIlacAdi.Text);
  EtkenMaddeStr := Trim(edtEtkenMadde.Text);
  TurStr := cbTur.Text;

  if BarkodStr = '' then
  begin
    ShowMessage('Lütfen ilacın barkod numarasını giriniz! ⚠️');
    if edtBarkod.CanFocus then edtBarkod.SetFocus;
    Exit;
  end;

  if IlacAdiStr = '' then
  begin
    ShowMessage('Lütfen ilaç adını giriniz! ⚠️');
    if edtIlacAdi.CanFocus then edtIlacAdi.SetFocus;
    Exit;
  end;

  if not TryStrToInt(Trim(edtMerkezStok.Text), StokMiktari) or (StokMiktari < 0) then
  begin
    ShowMessage('Lütfen geçerli bir stok miktarı giriniz! ⚠️');
    if edtMerkezStok.CanFocus then edtMerkezStok.SetFocus;
    Exit;
  end;

  if not TryStrToInt(Trim(edtKritikEsik.Text), KritikEsik) or (KritikEsik < 0) then
  begin
    ShowMessage('Lütfen geçerli bir kritik eşik değeri giriniz! ⚠️');
    if edtKritikEsik.CanFocus then edtKritikEsik.SetFocus;
    Exit;
  end;

  if BarkodVarMi(BarkodStr, FDuzenlenecekIlacID) then
  begin
    ShowMessage('"' + BarkodStr + '" barkod numarası başka bir ilaçta kayıtlı! ❌');
    if edtBarkod.CanFocus then edtBarkod.SetFocus;
    Exit;
  end;

  try
    qryIlacEkle.Close;
    if FDuzenlemeModu then
    begin
      qryIlacEkle.SQL.Text :=
        'UPDATE ILAC ' +
        'SET Barkod = :pBarkod, IlacAdi = :pIlacAdi, Tur = :pTur, EtkenMadde = :pEtkenMadde, ' +
        '    MerkezStokMiktari = :pMerkezStok, MerkezKritikEsik = :pMerkezKritikEsik ' +
        'WHERE IlacID = :pID;';
      qryIlacEkle.ParamByName('pID').AsInteger := FDuzenlenecekIlacID;
    end
    else
    begin
      qryIlacEkle.SQL.Text :=
        'INSERT INTO ILAC (Barkod, IlacAdi, Tur, EtkenMadde, MerkezStokMiktari, MerkezKritikEsik) ' +
        'VALUES (:pBarkod, :pIlacAdi, :pTur, :pEtkenMadde, :pMerkezStok, :pMerkezKritikEsik);';
    end;

    qryIlacEkle.ParamByName('pBarkod').AsString := BarkodStr;
    qryIlacEkle.ParamByName('pIlacAdi').AsString := IlacAdiStr;
    qryIlacEkle.ParamByName('pTur').AsString := TurStr;
    qryIlacEkle.ParamByName('pEtkenMadde').AsString := EtkenMaddeStr;
    qryIlacEkle.ParamByName('pMerkezStok').AsInteger := StokMiktari;
    qryIlacEkle.ParamByName('pMerkezKritikEsik').AsInteger := KritikEsik;

    qryIlacEkle.ExecSQL;

    if FDuzenlemeModu then
      ShowMessage('✅ İlaç bilgileri başarıyla güncellendi!')
    else
      ShowMessage('✅ "' + IlacAdiStr + '" başarıyla veritabanına eklendi!');

    Self.ModalResult := mrOk;
  except
    on E: Exception do
      ShowMessage('Veritabanı işlemi sırasında hata oluştu: ' + E.Message);
  end;
end;

procedure TForm12.btnIptalClick(Sender: TObject);
begin
  Self.ModalResult := mrCancel;
end;

procedure TForm12.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Form12 := nil;
end;

end.
