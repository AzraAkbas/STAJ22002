object Form12: TForm12
  Left = 0
  Top = 0
  Caption = 'Form12'
  ClientHeight = 577
  ClientWidth = 598
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 598
    Height = 49
    Align = alTop
    Color = 16315632
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 817
    object Label1: TLabel
      Left = 232
      Top = 11
      Width = 110
      Height = 23
      Caption = 'Yeni '#304'la'#231' Giri'#351'i'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlFormContainer: TPanel
    Left = 0
    Top = 49
    Width = 598
    Height = 528
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 8
    ExplicitTop = 41
    ExplicitWidth = 817
    ExplicitHeight = 527
    object Label2: TLabel
      Left = 86
      Top = 31
      Width = 54
      Height = 20
      Caption = 'Barkod:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 86
      Top = 96
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
    object Label4: TLabel
      Left = 86
      Top = 166
      Width = 95
      Height = 20
      Caption = 'Etken Madde:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 86
      Top = 228
      Width = 28
      Height = 20
      Caption = 'T'#252'r:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 86
      Top = 296
      Width = 36
      Height = 20
      Caption = 'Stok:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 86
      Top = 360
      Width = 74
      Height = 20
      Caption = 'Kritik E'#351'ik:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBarkod: TEdit
      Left = 248
      Top = 28
      Width = 193
      Height = 23
      TabOrder = 0
    end
    object edtIlacAdi: TEdit
      Left = 248
      Top = 93
      Width = 193
      Height = 23
      TabOrder = 1
    end
    object edtEtkenMadde: TEdit
      Left = 248
      Top = 163
      Width = 193
      Height = 23
      TabOrder = 2
    end
    object edtMerkezStok: TEdit
      Left = 248
      Top = 293
      Width = 193
      Height = 23
      TabOrder = 3
    end
    object edtKritikEsik: TEdit
      Left = 248
      Top = 357
      Width = 193
      Height = 23
      TabOrder = 4
    end
    object cbTur: TComboBox
      Left = 248
      Top = 225
      Width = 193
      Height = 23
      TabOrder = 5
      Items.Strings = (
        'Tablet'
        'Kaps'#252'l'
        'Draje'
        'Efervesan Tablet'
        #350'urup'
        'S'#252'spansiyon'
        'Sol'#252'syon'
        'Toz / Sa'#351'e'
        'Ampul'
        'Flakon'
        'Haz'#305'r Enjekt'#246'r / Kalem'
        'Serum / '#304'nf'#252'zyon Sol'#252'syonu'
        'Merhem'
        'Krem'
        'Jel'
        'Losyon'
        'Liniment'
        'Medikal Sprey'
        'G'#246'z Damlas'#305
        'Kulak Damlas'#305
        'Burun Damlas'#305
        'G'#246'z Merhemi'
        #304'nhaler / '#304'nhalasyon Tozu'
        'Neb'#252'liz'#246'r Sol'#252'syonu'
        'Fitil (S'#252'pozituvar)'
        'Ov'#252'lFlaster')
    end
    object btnIptal: TPanel
      Left = 360
      Top = 456
      Width = 153
      Height = 41
      Caption = #304'ptal'
      Color = 3157203
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 6
      OnClick = btnIptalClick
    end
    object btnKaydet: TPanel
      Left = 86
      Top = 456
      Width = 163
      Height = 41
      Caption = 'Kaydet'
      Color = 5226514
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 7
      OnClick = btnKaydetClick
    end
  end
  object qryIlacEkle: TFDQuery
    Left = 496
    Top = 17
  end
end
