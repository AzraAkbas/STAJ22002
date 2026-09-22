unit Unit10;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, System.UITypes;

type
  TForm10 = class(TForm)
    pnlTop: TPanel;
    edtIlacAra: TEdit;
    Label1: TLabel;
    dbGridIlaclar: TDBGrid;
    qryIlaclar: TFDQuery;
    DataSourceIlaclar: TDataSource;
    btnTalepGecmisi: TPanel;
    btnIlaclar: TPanel;
    Panel2: TPanel;
    btnIlacTalepEt: TPanel;

    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edtIlacAraChange(Sender: TObject);
    procedure dbGridIlaclarDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure dbGridIlaclarDblClick(Sender: TObject);
    procedure btnIlacTalepEtClick(Sender: TObject);
    procedure btnTalepGecmisiClick(Sender: TObject);
    procedure btnIlaclarClick(Sender: TObject);
  private
    procedure IlaclariYukle;
    procedure SütunGenislikleriniAyarla;
    procedure BasliklariTurkceYap;
    procedure BasliklariKalinYap;
    procedure DepoSiparisOlustur(const AIlacID: Integer; const AIlacAdi: string);
  public
    { Public declarations }
    AktifEczaciID: Integer;
  end;

var
  Form10: TForm10;

implementation

{$R *.dfm}

uses Unit1, Unit11, Unit12;

procedure TForm10.FormCreate(Sender: TObject);
begin
  Self.Caption := 'Hastane İlaç ve Merkez Stok Listesi';
  Self.Position := poScreenCenter;

  Self.Font.Name := 'Segoe UI';
  Self.Font.Size := 11;

  if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
  begin
    qryIlaclar.Connection := FrmLogin.FDConnection1;
  end
  else
  begin
    ShowMessage('DEBUG HATA: FrmLogin veya FDConnection1 bulunamadı!');
    Exit;
  end;

  if not qryIlaclar.Connection.Connected then
    qryIlaclar.Connection.Connected := True;

  dbGridIlaclar.DataSource := DataSourceIlaclar;
  DataSourceIlaclar.DataSet := qryIlaclar;

  dbGridIlaclar.Font.Name := 'Segoe UI';
  dbGridIlaclar.Font.Size := 11;
  dbGridIlaclar.TitleFont.Name := 'Segoe UI';
  dbGridIlaclar.TitleFont.Size := 11;
  dbGridIlaclar.TitleFont.Style := [fsBold];

  dbGridIlaclar.OnDblClick := dbGridIlaclarDblClick;
  dbGridIlaclar.OnDrawColumnCell := dbGridIlaclarDrawColumnCell;

  if Assigned(btnIlaclar) then
    btnIlaclar.OnClick := btnIlaclarClick;

  if Assigned(btnIlacTalepEt) then
    btnIlacTalepEt.OnClick := btnIlacTalepEtClick;

  edtIlacAra.Text := '';
  AktifEczaciID := 0;
end;

procedure TForm10.FormActivate(Sender: TObject);
begin
  if not qryIlaclar.Active then
    IlaclariYukle;
end;

procedure TForm10.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Form10 := nil;
end;

procedure TForm10.BasliklariKalinYap;
var
  i: Integer;
begin
  for i := 0 to dbGridIlaclar.Columns.Count - 1 do
  begin
    dbGridIlaclar.Columns[i].Title.Font.Name := 'Segoe UI';
    dbGridIlaclar.Columns[i].Title.Font.Size := 11;
    dbGridIlaclar.Columns[i].Title.Font.Style := [fsBold];
  end;
end;

procedure TForm10.BasliklariTurkceYap;
begin
  if dbGridIlaclar.Columns.Count >= 6 then
  begin
    dbGridIlaclar.Columns[0].Visible := False;
    dbGridIlaclar.Columns[1].Title.Caption := 'İlaç Adı';
    dbGridIlaclar.Columns[2].Title.Caption := 'Etken Madde';
    dbGridIlaclar.Columns[3].Title.Caption := 'Mevcut Stok';
    dbGridIlaclar.Columns[4].Title.Caption := 'Kritik Stok';
    dbGridIlaclar.Columns[5].Title.Caption := 'En Yakın SKT';
  end;
  BasliklariKalinYap;
end;

procedure TForm10.SütunGenislikleriniAyarla;
var
  i: Integer;
begin
  for i := 0 to dbGridIlaclar.Columns.Count - 1 do
  begin
    case i of
      0: dbGridIlaclar.Columns[i].Width := 0;
      1: dbGridIlaclar.Columns[i].Width := 220;
      2: dbGridIlaclar.Columns[i].Width := 220;
      3: dbGridIlaclar.Columns[i].Width := 130;
      4: dbGridIlaclar.Columns[i].Width := 150;
      5: dbGridIlaclar.Columns[i].Width := 140;
    else
      dbGridIlaclar.Columns[i].Width := 110;
    end;
  end;
end;

procedure TForm10.IlaclariYukle;
var
  AramaFiltre: string;
begin
  if not Assigned(qryIlaclar.Connection) then Exit;

  AramaFiltre := Trim(edtIlacAra.Text);

  qryIlaclar.Close;
  qryIlaclar.SQL.Clear;

  qryIlaclar.SQL.Add('SELECT');
  qryIlaclar.SQL.Add('    ILAC.IlacID,');
  qryIlaclar.SQL.Add('    CAST(ILAC.IlacAdi AS VARCHAR) AS [İlaç Adı],');
  qryIlaclar.SQL.Add('    CAST(ILAC.EtkenMadde AS VARCHAR) AS [Etken Madde],');
  qryIlaclar.SQL.Add('    ILAC.MerkezStokMiktari AS [Mevcut Stok],');
  qryIlaclar.SQL.Add('    ILAC.MerkezKritikEsik AS [Tanımlanan Kritik Stok],');
  qryIlaclar.SQL.Add('    COALESCE((SELECT MIN(P.SonKullanmaTarihi) FROM ILAC_PARTI P WHERE P.IlacID = ILAC.IlacID AND P.KalanMiktar > 0), ''Yok'') AS [En Yakın SKT]');
  qryIlaclar.SQL.Add('FROM ILAC');

  if AramaFiltre <> '' then
  begin
    qryIlaclar.SQL.Add('WHERE IlacAdi LIKE :pArama OR EtkenMadde LIKE :pArama OR Barkod LIKE :pArama');
  end;

  qryIlaclar.SQL.Add('ORDER BY ILAC.IlacAdi ASC;');

  if AramaFiltre <> '' then
    qryIlaclar.ParamByName('pArama').AsString := '%' + AramaFiltre + '%';

  try
    qryIlaclar.Open;
    SütunGenislikleriniAyarla;
    BasliklariTurkceYap;
  except
    on E: Exception do
      ShowMessage('İlaçlar yüklenirken hata oluştu: ' + E.Message);
  end;
end;

procedure TForm10.btnTalepGecmisiClick(Sender: TObject);
begin
  if not Assigned(Form11) then
    Application.CreateForm(TForm11, Form11);

  Form11.AktifEczaciID := Self.AktifEczaciID;
  Form11.Show;
  Form11.BringToFront;
end;

procedure TForm10.btnIlaclarClick(Sender: TObject);
begin
  if not Assigned(Form12) then
    Application.CreateForm(TForm12, Form12);

  Form12.FormuYeniKayitModundaAc;

  if Form12.ShowModal = mrOk then
  begin
    IlaclariYukle;
  end;
end;

procedure TForm10.dbGridIlaclarDblClick(Sender: TObject);
var
  SecilenIlacID: Integer;
begin
  if qryIlaclar.IsEmpty then Exit;

  SecilenIlacID := qryIlaclar.FieldByName('IlacID').AsInteger;

  if not Assigned(Form12) then
    Application.CreateForm(TForm12, Form12);

  Form12.FormuDuzenlemeModundaAc(SecilenIlacID);

  if Form12.ShowModal = mrOk then
  begin
    IlaclariYukle;
  end;
end;

procedure TForm10.DepoSiparisOlustur(const AIlacID: Integer; const AIlacAdi: string);
var
  TalepQuery: TFDQuery;
  MiktarStr: string;
  IstenenMiktar: Integer;
begin
  MiktarStr := '10';

  if not InputQuery('Ecza Deposu Siparişi', AIlacAdi + ' için depodan talep edilecek adedi girin:', MiktarStr) then
    Exit;

  if Trim(MiktarStr) = '' then Exit;

  if not TryStrToInt(Trim(MiktarStr), IstenenMiktar) or (IstenenMiktar <= 0) then
  begin
    ShowMessage('Lütfen geçerli bir sayı girin! ❌');
    Exit;
  end;

  TalepQuery := TFDQuery.Create(nil);
  try
    TalepQuery.Connection := FrmLogin.FDConnection1;
    TalepQuery.SQL.Text :=
      'INSERT INTO ECZA_DEPOSU_SIPARIS (IlacID, EczaciID, SiparisMiktari, Durum, SiparisTarihi) ' +
      'VALUES (:IlacID, :EczaciID, :Miktar, ''Beklemede'', datetime(''now'', ''localtime''));';

    TalepQuery.ParamByName('IlacID').AsInteger := AIlacID;

    TalepQuery.ParamByName('EczaciID').DataType := ftInteger;
    if AktifEczaciID > 0 then
      TalepQuery.ParamByName('EczaciID').AsInteger := AktifEczaciID
    else
      TalepQuery.ParamByName('EczaciID').Value := Null;

    TalepQuery.ParamByName('Miktar').AsInteger := IstenenMiktar;
    TalepQuery.ExecSQL;

    ShowMessage(AIlacAdi + ' için ' + IntToStr(IstenenMiktar) + ' adet depo siparişi başarıyla oluşturuldu! Durum: Beklemede ✅');
  finally
    TalepQuery.Free;
  end;
end;

procedure TForm10.btnIlacTalepEtClick(Sender: TObject);
var
  IlacID: Integer;
  IlacAdiStr: string;
begin
  if qryIlaclar.IsEmpty then
  begin
    ShowMessage('Lütfen sipariş vermek istediğiniz ilacı listeden seçiniz! ⚠️');
    Exit;
  end;

  IlacID := qryIlaclar.FieldByName('IlacID').AsInteger;
  IlacAdiStr := qryIlaclar.FieldByName('İlaç Adı').AsString;
  DepoSiparisOlustur(IlacID, IlacAdiStr);
end;

procedure TForm10.dbGridIlaclarDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  MevcutStok, KritikEsik: Integer;
  SktStr: string;
  SktTarihi, Bugün, OtuzGunSonra: TDateTime;
  SktGecmis, SktYakin: Boolean;
begin
  if (Assigned(qryIlaclar)) and (not qryIlaclar.IsEmpty) then
  begin
    MevcutStok := qryIlaclar.FieldByName('Mevcut Stok').AsInteger;
    KritikEsik := qryIlaclar.FieldByName('Tanımlanan Kritik Stok').AsInteger;
    SktStr := Trim(qryIlaclar.FieldByName('En Yakın SKT').AsString);

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

    if not (gdSelected in State) then
    begin

      if SktGecmis or (MevcutStok <= 0) then
      begin
        dbGridIlaclar.Canvas.Brush.Color := $0000008B; 
        dbGridIlaclar.Canvas.Font.Color := clWhite;
        dbGridIlaclar.Canvas.Font.Style := [fsBold];
      end
      else if SktYakin or (MevcutStok < KritikEsik) then
      begin
        dbGridIlaclar.Canvas.Brush.Color := $00C0C0FF;
        dbGridIlaclar.Canvas.Font.Color := clMaroon;
        dbGridIlaclar.Canvas.Font.Style := [fsBold];
      end
      else if MevcutStok = KritikEsik then
      begin
        dbGridIlaclar.Canvas.Brush.Color := $0080FFFF;
        dbGridIlaclar.Canvas.Font.Color := $00003366;
        dbGridIlaclar.Canvas.Font.Style := [fsBold];
      end;
    end;
  end;

  dbGridIlaclar.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TForm10.edtIlacAraChange(Sender: TObject);
begin
  IlaclariYukle;
end;

end.
