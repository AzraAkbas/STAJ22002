unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids,
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, Data.DB, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait;

type
  TFormDoktorPaneli = class(TForm)
    PanelUst: TPanel;
    LabelAra: TLabel;
    DBGridHastalar: TDBGrid;
    FDQueryHastalar: TFDQuery;
    DataSourceHastalar: TDataSource;
    EditTCAra: TEdit;

    procedure FormCreate(Sender: TObject);
    procedure EditTCAraChange(Sender: TObject);
    procedure BtnDetayClick(Sender: TObject);
    procedure BtnReceteClick(Sender: TObject);
    procedure EditTCAraKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure DBGridHastalarDblClick(Sender: TObject);
  private
    { Private declarations }
    procedure AramaIsleminiYap;
    procedure GridSutunlariniDuzenle;
    procedure DBGridHastalarDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  public
    { Public declarations }
  end;

var
  FormDoktorPaneli: TFormDoktorPaneli;

implementation

{$R *.dfm}

uses Unit1, Unit3;

type
  TGridHack = class(TDBGrid);

procedure TFormDoktorPaneli.DBGridHastalarDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  CellText: string;
  DrawRect: TRect;
  TextHeight: Integer;
begin
  if gdSelected in State then
  begin
    DBGridHastalar.Canvas.Brush.Color := clHighlight;
    DBGridHastalar.Canvas.Font.Color := clHighlightText;
  end
  else
  begin
    DBGridHastalar.Canvas.Brush.Color := clWindow;
    DBGridHastalar.Canvas.Font.Color := clWindowText;
  end;

  DBGridHastalar.Canvas.Font.Name := 'Segoe UI';
  DBGridHastalar.Canvas.Font.Size := 11;
  DBGridHastalar.Canvas.FillRect(Rect);
  CellText := Column.Field.AsString;
  DrawRect := Rect;
  DrawRect.Left := DrawRect.Left + 15;
  DrawRect.Right := DrawRect.Right - 15;
  TextHeight := DBGridHastalar.Canvas.TextHeight(CellText);
  DrawRect.Top := DrawRect.Top + ((Rect.Height - TextHeight) div 2);
  DBGridHastalar.Canvas.TextRect(DrawRect, CellText, [tfEndEllipsis, tfSingleLine]);
end;

procedure TFormDoktorPaneli.GridSutunlariniDuzenle;
var
  I: Integer;
begin
  if DBGridHastalar.Columns.Count >= 6 then
  begin
    DBGridHastalar.Columns[0].Visible := False;
    DBGridHastalar.Columns[1].Title.Caption := 'Hasta Adı Soyadı';
    DBGridHastalar.Columns[1].Width := 360;
    DBGridHastalar.Columns[2].Title.Caption := 'Yattığı Servis';
    DBGridHastalar.Columns[2].Width := 260;
    DBGridHastalar.Columns[3].Title.Caption := 'Oda No';
    DBGridHastalar.Columns[3].Width := 140;
    DBGridHastalar.Columns[4].Title.Caption := 'Yatak No';
    DBGridHastalar.Columns[4].Width := 140;
    DBGridHastalar.Columns[5].Title.Caption := 'Aktif Durum';
    DBGridHastalar.Columns[5].Width := 180;

    for I := 1 to DBGridHastalar.Columns.Count - 1 do
    begin
      DBGridHastalar.Columns[I].Title.Font.Name := 'Segoe UI';
      DBGridHastalar.Columns[I].Title.Font.Size := 11;
      DBGridHastalar.Columns[I].Title.Font.Style := [fsBold];

      if not DBGridHastalar.Columns[I].Title.Caption.StartsWith('   ') then
        DBGridHastalar.Columns[I].Title.Caption := '   ' + DBGridHastalar.Columns[I].Title.Caption;
    end;
  end;
end;

procedure TFormDoktorPaneli.FormCreate(Sender: TObject);
begin
  try
    Self.OnClose := FormClose;

    if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
    begin
      if not FrmLogin.FDConnection1.Connected then
      begin
        FrmLogin.FDConnection1.LoginPrompt := False;
        FrmLogin.FDConnection1.Connected := True;
      end;
      FDQueryHastalar.Connection := FrmLogin.FDConnection1;
    end;

    DBGridHastalar.Font.Name := 'Segoe UI';
    DBGridHastalar.Font.Size := 11;
    DBGridHastalar.TitleFont.Name := 'Segoe UI';
    DBGridHastalar.TitleFont.Size := 11;
    DBGridHastalar.TitleFont.Style := [fsBold];
    TGridHack(DBGridHastalar).DefaultRowHeight := 38;
    DBGridHastalar.Options := [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit];
    DBGridHastalar.OnDrawColumnCell := DBGridHastalarDrawColumnCell;
    DBGridHastalar.OnDblClick := DBGridHastalarDblClick;

    DataSourceHastalar.DataSet := FDQueryHastalar;
    DBGridHastalar.DataSource := DataSourceHastalar;

    FDQueryHastalar.Close;
    FDQueryHastalar.SQL.Text :=
      'SELECT h.HastaID, ' +
      '       (h.Ad || '' '' || h.Soyad) AS AdSoyad, ' +
      '       CAST(y.ServisAdi AS VARCHAR(100)) AS ServisNo, ' +
      '       CAST(y.OdaNo AS VARCHAR(20)) AS OdaNo, ' +
      '       CAST(y.YatakNo AS VARCHAR(20)) AS YatakNo, ' +
      '       CAST(y.AktifMi AS VARCHAR(10)) AS Durum ' +
      'FROM HASTA h ' +
      'INNER JOIN YATIS y ON h.HastaID = y.HastaID AND y.AktifMi = ''Evet'' ' +
      'WHERE y.ServisAdi LIKE :DoktorServis';

    if Assigned(FrmLogin) then
      FDQueryHastalar.ParamByName('DoktorServis').AsString := '%' + Trim(FrmLogin.GirisYapanServisAdi) + '%';

    FDQueryHastalar.Open;
    GridSutunlariniDuzenle;
  except
    on E: Exception do
      ShowMessage('Veri tabanı bağlantı hatası: ' + E.Message);
  end;
end;

procedure TFormDoktorPaneli.DBGridHastalarDblClick(Sender: TObject);
var
  SecilenID: Integer;
begin
  if not FDQueryHastalar.IsEmpty then
  begin
    SecilenID := FDQueryHastalar.FieldByName('HastaID').AsInteger;
    if not Assigned(Form3) then
      Application.CreateForm(TForm3, Form3);

    Form3.HastaYukle(SecilenID, FrmLogin.GirisYapanDoktorID);
    Form3.ShowModal;
  end;
end;

procedure TFormDoktorPaneli.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Winapi.Windows.PostQuitMessage(0);
  System.SysUtils.Abort;
end;

procedure TFormDoktorPaneli.FormDestroy(Sender: TObject);
begin
  Application.Terminate;
end;
procedure TFormDoktorPaneli.AramaIsleminiYap;
var
  ArananVal: string;
begin
  ArananVal := Trim(EditTCAra.Text);
  if Assigned(FrmLogin) and Assigned(FrmLogin.FDConnection1) then
    FDQueryHastalar.Connection := FrmLogin.FDConnection1;

  FDQueryHastalar.Close;

  if ArananVal.IsEmpty then
  begin
    FDQueryHastalar.SQL.Text :=
      'SELECT h.HastaID, ' +
      '       (h.Ad || '' '' || h.Soyad) AS AdSoyad, ' +
      '       CAST(y.ServisAdi AS VARCHAR(100)) AS ServisNo, ' +
      '       CAST(y.OdaNo AS VARCHAR(20)) AS OdaNo, ' +
      '       CAST(y.YatakNo AS VARCHAR(20)) AS YatakNo, ' +
      '       CAST(y.AktifMi AS VARCHAR(10)) AS Durum ' +
      'FROM HASTA h ' +
      'INNER JOIN YATIS y ON h.HastaID = y.HastaID AND y.AktifMi = ''Evet'' ' +
      'WHERE y.ServisAdi LIKE :DoktorServis';

    if Assigned(FrmLogin) then
      FDQueryHastalar.ParamByName('DoktorServis').AsString := '%' + Trim(FrmLogin.GirisYapanServisAdi) + '%';
  end
  else
  begin

    FDQueryHastalar.SQL.Text :=
      'SELECT h.HastaID, ' +
      '       (h.Ad || '' '' || h.Soyad) AS AdSoyad, ' +
      '       CAST(COALESCE(y.ServisAdi, ''Taburcu / Geçmiş'') AS VARCHAR(100)) AS ServisNo, ' +
      '       CAST(COALESCE(y.OdaNo, ''-'') AS VARCHAR(20)) AS OdaNo, ' +
      '       CAST(COALESCE(y.YatakNo, ''-'') AS VARCHAR(20)) AS YatakNo, ' +
      '       CAST(COALESCE(y.AktifMi, ''Hayır'') AS VARCHAR(10)) AS Durum ' +
      'FROM HASTA h ' +
      'LEFT JOIN YATIS y ON h.HastaID = y.HastaID ' +
      'WHERE h.Ad LIKE :Param OR h.Soyad LIKE :Param';
    FDQueryHastalar.ParamByName('Param').AsString := '%' + ArananVal + '%';
  end;

  try
    FDQueryHastalar.Open;
    GridSutunlariniDuzenle;
  except
    on E: Exception do
      ShowMessage('Arama esnasında hata oluştu: ' + E.Message);
  end;
end;

procedure TFormDoktorPaneli.EditTCAraChange(Sender: TObject);
begin
  AramaIsleminiYap;
end;

procedure TFormDoktorPaneli.EditTCAraKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    AramaIsleminiYap;
  end;
end;

procedure TFormDoktorPaneli.BtnDetayClick(Sender: TObject);
begin
  DBGridHastalarDblClick(Sender);
end;

procedure TFormDoktorPaneli.BtnReceteClick(Sender: TObject);
begin
  DBGridHastalarDblClick(Sender);
end;

end.
