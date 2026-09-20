object Form8: TForm8
  Left = 0
  Top = 0
  Caption = #304'la'#231' '#304'stekleri'
  ClientHeight = 716
  ClientWidth = 1192
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1192
    Height = 716
    ActivePage = TabSheet1
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    ExplicitWidth = 1190
    ExplicitHeight = 708
    object TabSheet1: TTabSheet
      Caption = 'Doktor Re'#231'eteleri'
      object pnlReceteTop: TPanel
        Left = 0
        Top = 0
        Width = 1184
        Height = 60
        Align = alTop
        Color = 16315632
        ParentBackground = False
        TabOrder = 0
        ExplicitWidth = 1182
        object Label1: TLabel
          Left = 40
          Top = 16
          Width = 125
          Height = 17
          Caption = 'Servise G'#246're Arama:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtServisAraRecete: TEdit
          Left = 176
          Top = 13
          Width = 153
          Height = 25
          TabOrder = 0
          OnChange = edtServisAraReceteChange
        end
        object btnGecmisRecete: TPanel
          Left = 823
          Top = 13
          Width = 155
          Height = 41
          Caption = 'G'#246'nderim Ge'#231'mi'#351'i'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnClick = btnGecmisReceteClick
        end
        object Panel1: TPanel
          Left = 1016
          Top = 13
          Width = 147
          Height = 41
          Caption = #304'la'#231'lar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          OnClick = btnIlacListesiClick
        end
      end
      object pnlReceteIslem: TPanel
        Left = 954
        Top = 60
        Width = 230
        Height = 624
        Align = alRight
        Color = 16315632
        ParentBackground = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 1
        ExplicitLeft = 952
        ExplicitHeight = 616
        object Label3: TLabel
          Left = 40
          Top = 88
          Width = 159
          Height = 17
          Caption = 'Se'#231'ilen '#304'lac'#305'n Eczac'#305' Notu:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEczaciNotu: TMemo
          Left = 24
          Top = 128
          Width = 185
          Height = 89
          TabOrder = 0
        end
        object btnReceteGonderildi: TPanel
          Left = 40
          Top = 256
          Width = 145
          Height = 41
          Caption = 'G'#246'nderildi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnClick = btnReceteGonderildiClick
        end
      end
      object dbGridReceteler: TDBGrid
        Left = 0
        Top = 60
        Width = 954
        Height = 624
        Align = alClient
        DataSource = DataSourceReceteler
        TabOrder = 2
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Hem'#351'ire Stok '#304'stekleri'
      ImageIndex = 1
      object pnlStokTop: TPanel
        Left = 0
        Top = 0
        Width = 1184
        Height = 60
        Align = alTop
        Color = 16315632
        ParentBackground = False
        TabOrder = 0
        object Label2: TLabel
          Left = 40
          Top = 16
          Width = 125
          Height = 17
          Caption = 'Servise G'#246're Arama:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtServisAraStok: TEdit
          Left = 176
          Top = 13
          Width = 153
          Height = 25
          TabOrder = 0
          OnChange = edtServisAraStokChange
        end
        object btnGecmisStok: TPanel
          Left = 824
          Top = 13
          Width = 153
          Height = 41
          Caption = 'G'#246'nderim Ge'#231'mi'#351'i'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnClick = btnGecmisStokClick
        end
        object Panel2: TPanel
          Left = 1014
          Top = 13
          Width = 147
          Height = 41
          Caption = #304'la'#231'lar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          OnClick = btnIlacListesiClick
        end
      end
      object Panel3: TPanel
        Left = 952
        Top = 60
        Width = 232
        Height = 624
        Align = alRight
        Color = 16315632
        ParentBackground = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 1
        object Label4: TLabel
          Left = 40
          Top = 88
          Width = 159
          Height = 17
          Caption = 'Se'#231'ilen '#304'lac'#305'n Eczac'#305' Notu:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtStokNotu: TMemo
          Left = 24
          Top = 128
          Width = 185
          Height = 89
          TabOrder = 0
        end
        object btnStokGonderildi: TPanel
          Left = 48
          Top = 248
          Width = 137
          Height = 41
          Caption = 'G'#246'nderildi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnClick = btnStokGonderildiClick
        end
      end
      object dbGridStokIstek: TDBGrid
        Left = 0
        Top = 60
        Width = 952
        Height = 624
        Align = alClient
        DataSource = DataSourceStokIstek
        TabOrder = 2
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
  end
  object qryReceteler: TFDQuery
    Connection = FrmLogin.FDConnection1
    Left = 604
    Top = 44
  end
  object qryStokIstek: TFDQuery
    Connection = FrmLogin.FDConnection1
    Left = 740
    Top = 140
  end
  object DataSourceReceteler: TDataSource
    DataSet = qryReceteler
    Left = 828
    Top = 156
  end
  object DataSourceStokIstek: TDataSource
    DataSet = qryStokIstek
    Left = 540
    Top = 188
  end
end
