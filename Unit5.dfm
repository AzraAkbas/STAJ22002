object frmHemsireAnaSayfa: TfrmHemsireAnaSayfa
  Left = 0
  Top = 0
  Caption = 'Tedavi Plan'#305
  ClientHeight = 637
  ClientWidth = 814
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnActivate = FormActivate
  OnClose = FormClose
  OnShow = FormShow
  TextHeight = 15
  object scrCards: TScrollBox
    Left = 0
    Top = 0
    Width = 814
    Height = 637
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 812
    ExplicitHeight = 629
    object pnlTop: TPanel
      Left = 0
      Top = 0
      Width = 810
      Height = 60
      Align = alTop
      BevelOuter = bvNone
      Color = 16315632
      ParentBackground = False
      TabOrder = 0
      ExplicitWidth = 808
      object Label1: TLabel
        Left = 40
        Top = 19
        Width = 64
        Height = 17
        Caption = 'Hasta Ara:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 4210752
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object edtArama: TEdit
        Left = 120
        Top = 18
        Width = 220
        Height = 23
        TabOrder = 0
        TextHint = 'Hasta ad'#305' veya soyad'#305'...'
        OnChange = edtAramaChange
      end
      object pnlStokKontrol: TPanel
        Left = 384
        Top = 11
        Width = 153
        Height = 38
        Caption = 'Stok Y'#246'netimi'
        Color = 13299711
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 1
        OnClick = pnlStokKontrolClick
      end
      object pnlGecmisSayfasinaGit: TPanel
        Left = 568
        Top = 9
        Width = 145
        Height = 41
        Caption = 'Ge'#231'mi'#351' Tedaviler'
        Color = 13290239
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 2
        OnClick = pnlGecmisSayfasinaGitClick
      end
    end
    object pnlCardTemplate: TPanel
      Left = 15
      Top = 75
      Width = 882
      Height = 110
      BevelOuter = bvNone
      Color = clWindow
      ParentBackground = False
      TabOrder = 1
      Visible = False
      object lblHeaderTemplate: TLabel
        Left = 16
        Top = 10
        Width = 146
        Height = 21
        Caption = 'lblHeaderTemplate'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3355443
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblDetailsTemplate: TLabel
        Left = 16
        Top = 37
        Width = 106
        Height = 17
        Caption = 'lblDetailsTemplate'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6710886
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object Bevel1: TBevel
        Left = 16
        Top = 60
        Width = 718
        Height = 2
        Shape = bsTopLine
      end
      object lblMedsTemplate: TLabel
        Left = 16
        Top = 68
        Width = 95
        Height = 15
        Caption = 'lblMedsTemplate'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11753728
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        WordWrap = True
      end
      object pnlUygulanmadi: TPanel
        Left = 620
        Top = 7
        Width = 130
        Height = 32
        Caption = #10060' Uygulanmad'#305
        Color = 2959562
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        OnClick = pnlUygulanmadiClick
      end
      object pnlUygulandi: TPanel
        Left = 460
        Top = 7
        Width = 130
        Height = 32
        Caption = #10004' Uyguland'#305
        Color = 6865430
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 1
        OnClick = pnlUygulandiClick
      end
    end
  end
  object qryServisKartlari: TFDQuery
    Left = 536
    Top = 288
  end
  object qryStokKontrol: TFDQuery
    Left = 352
    Top = 304
  end
  object qryIslem: TFDQuery
    Left = 680
    Top = 296
  end
end
