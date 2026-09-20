object Form3: TForm3
  Left = 1049
  Top = 425
  Caption = 'Hasta Detay ve Re'#231'ete Giri'#351' Paneli'
  ClientHeight = 739
  ClientWidth = 1095
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  TextHeight = 15
  object PanelSolDetay: TPanel
    Left = 0
    Top = 0
    Width = 577
    Height = 739
    Align = alLeft
    BevelOuter = bvNone
    Color = 16251386
    ParentBackground = False
    TabOrder = 0
    ExplicitHeight = 731
    object LabelDetayHeader: TLabel
      Left = 26
      Top = 32
      Width = 138
      Height = 28
      Caption = 'HASTA DETAYI'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelAdSoyadBaslik: TLabel
      Left = 36
      Top = 96
      Width = 82
      Height = 20
      Caption = 'Ad'#305' Soyad'#305': '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5000268
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelAdSoyad: TLabel
      Left = 207
      Top = 96
      Width = 96
      Height = 20
      Caption = 'LabelAdSoyad'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LabelTCBaslik: TLabel
      Left = 36
      Top = 144
      Width = 141
      Height = 20
      Caption = 'TC Kimlik Numaras'#305':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5000268
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelTC: TLabel
      Left = 207
      Top = 144
      Width = 52
      Height = 20
      Caption = 'LabelTC'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LabelCinsiyetBaslik: TLabel
      Left = 36
      Top = 192
      Width = 151
      Height = 20
      Caption = 'Cinsiyet / Do'#287'um Y'#305'l'#305':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5000268
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelCinsiyetYil: TLabel
      Left = 207
      Top = 192
      Width = 103
      Height = 20
      Caption = 'LabelCinsiyetYil'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LabelBoyKiloBaslik: TLabel
      Left = 36
      Top = 240
      Width = 73
      Height = 20
      Caption = 'Boy / Kilo:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5000268
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelBoyKilo: TLabel
      Left = 207
      Top = 240
      Width = 87
      Height = 20
      Caption = 'LabelBoyKilo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LabelGebelikEmzirmeBaslik: TLabel
      Left = 36
      Top = 528
      Width = 132
      Height = 20
      Caption = 'Gebelik / Emzirme:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5000268
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelGebelikEmzirme: TLabel
      Left = 207
      Top = 528
      Width = 144
      Height = 20
      Caption = 'LabelGebelikEmzirme'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LabelTelNoBaslik: TLabel
      Left = 36
      Top = 288
      Width = 128
      Height = 20
      Caption = 'Telefon Numaras'#305':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5000268
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelTelNo: TLabel
      Left = 207
      Top = 288
      Width = 75
      Height = 20
      Caption = 'LabelTelNo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LabelKonumBaslik: TLabel
      Left = 36
      Top = 336
      Width = 86
      Height = 20
      Caption = 'Oda / Yatak:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5000268
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelDrNotuBaslik: TLabel
      Left = 36
      Top = 384
      Width = 93
      Height = 20
      Caption = 'Doktor Notu:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5000268
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelKronikBaslik: TLabel
      Left = 36
      Top = 432
      Width = 111
      Height = 20
      Caption = 'Kronik Hastal'#305'k:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5000268
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelKonum: TLabel
      Left = 207
      Top = 336
      Width = 83
      Height = 20
      Caption = 'LabelKonum'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LabelDrNotu: TLabel
      Left = 207
      Top = 384
      Width = 85
      Height = 20
      Caption = 'LabelDrNotu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LabelKronik: TLabel
      Left = 207
      Top = 432
      Width = 78
      Height = 20
      Caption = 'LabelKronik'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object PanelAlerjiKutu: TPanel
      Left = 26
      Top = 470
      Width = 479
      Height = 41
      BevelOuter = bvNone
      Color = 15000575
      ParentBackground = False
      TabOrder = 0
      object LabelAlerjiBaslik: TLabel
        Left = 10
        Top = 13
        Width = 41
        Height = 20
        Caption = 'Alerji:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5000268
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LabelAlerji: TLabel
        Left = 181
        Top = 13
        Width = 71
        Height = 20
        Caption = 'LabelAlerji'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
    end
    object BtnGecmisRecete: TPanel
      Left = 368
      Top = 656
      Width = 169
      Height = 45
      Cursor = crHandPoint
      BevelOuter = bvNone
      Caption = 'Ge'#231'mi'#351' Re'#231'eteler'
      Color = 12774840
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
      OnClick = BtnGecmisReceteClick
    end
  end
  object PanelSagRecete: TPanel
    Left = 577
    Top = 0
    Width = 518
    Height = 739
    Cursor = crHandPoint
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 583
    object LabelReceteHeader: TLabel
      Left = 32
      Top = 32
      Width = 183
      Height = 28
      Caption = 'YEN'#304' RE'#199'ETE G'#304'R'#304#350#304
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelIlacAdi: TLabel
      Left = 60
      Top = 86
      Width = 56
      Height = 20
      Caption = #304'la'#231' Ad'#305':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelDoz: TLabel
      Left = 60
      Top = 144
      Width = 31
      Height = 20
      Caption = 'Doz:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelOgun: TLabel
      Left = 60
      Top = 226
      Width = 42
      Height = 20
      Caption = #214#287#252'n:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelGunSayisi: TLabel
      Left = 60
      Top = 311
      Width = 76
      Height = 20
      Caption = 'G'#252'n Say'#305's'#305':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelAdet: TLabel
      Left = 60
      Top = 369
      Width = 38
      Height = 20
      Caption = 'Adet:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object ComboIlacSecimi: TComboBox
      Left = 160
      Top = 83
      Width = 305
      Height = 28
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnChange = ComboIlacSecimiChange
    end
    object EditDoz: TEdit
      Left = 160
      Top = 144
      Width = 150
      Height = 28
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnChange = ComboIlacSecimiChange
    end
    object EditGunSayisi: TEdit
      Left = 160
      Top = 308
      Width = 150
      Height = 28
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object EditAdet: TEdit
      Left = 160
      Top = 369
      Width = 150
      Height = 28
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object BtnKaydet: TPanel
      Left = 200
      Top = 672
      Width = 180
      Height = 45
      Cursor = crHandPoint
      Caption = 'Kaydet'
      Color = 16432781
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 4
      OnClick = BtnKaydetClick
    end
    object clbOgunler: TCheckListBox
      Left = 160
      Top = 202
      Width = 150
      Height = 57
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemHeight = 17
      Items.Strings = (
        'Sabah'
        #214#287'le'
        'Ak'#351'am')
      ParentFont = False
      TabOrder = 5
    end
    object ListView1: TListView
      Left = 88
      Top = 421
      Width = 385
      Height = 150
      Columns = <
        item
          Caption = #304'la'#231' Ad'#305
          Width = 85
        end
        item
          Caption = 'Doz'
          Width = 60
        end
        item
          Caption = #214#287#252'n'
          Width = 120
        end
        item
          Caption = 'G'#252'n Say'#305's'#305
        end
        item
          Caption = 'Adet'
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      GridLines = True
      RowSelect = True
      ParentFont = False
      TabOrder = 6
      ViewStyle = vsReport
    end
    object BtnIlacEkle: TPanel
      Left = 136
      Top = 577
      Width = 105
      Height = 33
      Caption = 'Ekle'
      Color = 5226514
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 7
      OnClick = BtnIlacEkleClick
    end
    object BtnIlacSil: TPanel
      Left = 304
      Top = 577
      Width = 105
      Height = 33
      Caption = 'Sil'
      Color = 327901
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 8
      OnClick = BtnIlacSilClick
    end
  end
  object FDQueryHasta: TFDQuery
    Left = 1018
    Top = 24
  end
  object FDQueryKaydet: TFDQuery
    Left = 1026
    Top = 216
  end
  object FDQueryIlaclar: TFDQuery
    Left = 1034
    Top = 320
  end
end
