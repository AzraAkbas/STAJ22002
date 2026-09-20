object Form10: TForm10
  Left = 0
  Top = 0
  Caption = #304'la'#231' Listesi'
  ClientHeight = 691
  ClientWidth = 952
  Color = clBtnFace
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
    Width = 952
    Height = 60
    Align = alTop
    Color = 16315632
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 950
    object Label1: TLabel
      Left = 40
      Top = 20
      Width = 166
      Height = 17
      Caption = #304'la'#231' veya Etken Madde Ara:'
      Color = 16315632
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
    end
    object edtIlacAra: TEdit
      Left = 216
      Top = 19
      Width = 193
      Height = 23
      TabOrder = 0
      OnChange = edtIlacAraChange
    end
    object btnTalepGecmisi: TPanel
      Left = 792
      Top = 13
      Width = 129
      Height = 41
      Caption = 'Ge'#231'mi'#351' Talepler'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = btnTalepGecmisiClick
    end
    object btnIlaclar: TPanel
      Left = 672
      Top = 13
      Width = 105
      Height = 41
      Caption = #304'la'#231' Ekle'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = BtnIlaclarClick
    end
  end
  object dbGridIlaclar: TDBGrid
    Left = 0
    Top = 60
    Width = 952
    Height = 572
    Align = alClient
    DataSource = DataSourceIlaclar
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDblClick = dbGridIlaclarDblClick
  end
  object Panel2: TPanel
    Left = 0
    Top = 632
    Width = 952
    Height = 59
    Align = alBottom
    TabOrder = 2
    ExplicitTop = 624
    ExplicitWidth = 950
    object btnIlacTalepEt: TPanel
      Left = 776
      Top = 14
      Width = 145
      Height = 41
      Caption = #304'la'#231' '#304'ste'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnIlacTalepEtClick
    end
  end
  object qryIlaclar: TFDQuery
    Connection = FrmLogin.FDConnection1
    Left = 480
    Top = 240
  end
  object DataSourceIlaclar: TDataSource
    DataSet = qryIlaclar
    Left = 688
    Top = 312
  end
end
