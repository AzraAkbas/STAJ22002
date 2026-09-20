object Form11: TForm11
  Left = 0
  Top = 0
  Caption = 'Ge'#231'mi'#351' '#304'la'#231' Talepleri'
  ClientHeight = 717
  ClientWidth = 1022
  Color = 16315632
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnActivate = FormActivate
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1022
    Height = 60
    Align = alTop
    Color = 16315632
    ParentBackground = False
    TabOrder = 0
    ExplicitLeft = -24
    ExplicitTop = -6
    object Label1: TLabel
      Left = 48
      Top = 16
      Width = 166
      Height = 17
      Caption = #304'la'#231' veya Etken Madde Ara:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 499
      Top = 16
      Width = 119
      Height = 17
      Caption = 'Tarihe G'#246're Arama:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtGecmisAra: TEdit
      Left = 224
      Top = 15
      Width = 161
      Height = 23
      TabOrder = 0
      OnChange = edtGecmisAraChange
    end
    object dtpGecmisTarih: TDateTimePicker
      Left = 640
      Top = 15
      Width = 186
      Height = 23
      Date = 46230.000000000000000000
      Time = 0.910857361108355700
      TabOrder = 1
      OnChange = dtpGecmisTarihChange
    end
  end
  object dbGridGecmis: TDBGrid
    Left = 0
    Top = 60
    Width = 1022
    Height = 657
    Align = alClient
    DataSource = DataSourceGecmis
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDrawColumnCell = dbGridGecmisDrawColumnCell
    OnDblClick = dbGridGecmisDblClick
  end
  object qryGecmis: TFDQuery
    Connection = FrmLogin.FDConnection1
    Left = 528
    Top = 104
  end
  object DataSourceGecmis: TDataSource
    DataSet = qryGecmis
    Left = 752
    Top = 128
  end
end
