object Form6: TForm6
  Left = 0
  Top = 0
  Caption = 'Stok Y'#246'netimi'
  ClientHeight = 674
  ClientWidth = 752
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormShow
  TextHeight = 15
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 752
    Height = 674
    ActivePage = tabStoklar
    Align = alClient
    TabOrder = 0
    OnChange = PageControlChange
    ExplicitWidth = 750
    ExplicitHeight = 666
    object tabStoklar: TTabSheet
      Caption = 'Servis '#304'la'#231' Stoklar'#305
      object pnlStokUst: TPanel
        Left = 0
        Top = 0
        Width = 744
        Height = 65
        Align = alTop
        Color = 16315632
        ParentBackground = False
        TabOrder = 0
        ExplicitWidth = 742
        object Label1: TLabel
          Left = 32
          Top = 18
          Width = 155
          Height = 17
          Caption = #304'la'#231'/Etken Madde Arama:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object btnTalepEt: TPanel
          Left = 576
          Top = 8
          Width = 129
          Height = 40
          Caption = 'Eczaneden Talep Et'
          Color = 16766670
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentBackground = False
          ParentFont = False
          TabOrder = 0
          OnClick = btnTalepEtClick
        end
        object edtArama: TEdit
          Left = 200
          Top = 17
          Width = 249
          Height = 23
          TabOrder = 1
          OnChange = edtAramaChange
        end
      end
      object dbgStoklar: TDBGrid
        Left = 0
        Top = 65
        Width = 744
        Height = 579
        Align = alClient
        DataSource = dsStokListesi
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnCellClick = dbgStoklarCellClick
        OnDrawColumnCell = dbgStoklarDrawColumnCell
      end
    end
    object tabTalepler: TTabSheet
      Caption = 'Eczane Talep Ge'#231'mi'#351'i & Durum'
      ImageIndex = 1
      object dbgTalepler: TDBGrid
        Left = 0
        Top = 65
        Width = 744
        Height = 579
        Align = alClient
        DataSource = dsTalepGecmisi
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 744
        Height = 65
        Align = alTop
        Color = 16315632
        ParentBackground = False
        TabOrder = 1
        object Label2: TLabel
          Left = 32
          Top = 23
          Width = 155
          Height = 17
          Caption = #304'la'#231'/Etken Madde Arama:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtTalepArama: TEdit
          Left = 200
          Top = 22
          Width = 217
          Height = 23
          TabOrder = 0
          OnChange = edtTalepAramaChange
        end
      end
    end
  end
  object qryStokListesi: TFDQuery
    Left = 588
    Top = 226
  end
  object dsStokListesi: TDataSource
    DataSet = qryStokListesi
    Left = 572
    Top = 146
  end
  object qryTalepGecmisi: TFDQuery
    Left = 452
    Top = 426
  end
  object dsTalepGecmisi: TDataSource
    DataSet = qryTalepGecmisi
    Left = 484
    Top = 186
  end
  object qryIslem: TFDQuery
    Left = 396
    Top = 330
  end
end
