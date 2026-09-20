object FrmLogin: TFrmLogin
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Sistem Giri'#351'i'
  ClientHeight = 501
  ClientWidth = 633
  Color = 14866641
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 14391348
  Font.Height = -21
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 30
  object TPanel
    Left = 144
    Top = 40
    Width = 353
    Height = 401
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object Label1: TLabel
      Left = 147
      Top = 80
      Width = 57
      Height = 23
      Caption = 'Sicil No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 6579033
      Font.Height = -17
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Şifre: TLabel
      Left = 155
      Top = 191
      Width = 33
      Height = 23
      Caption = #350'ifre'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 6579033
      Font.Height = -17
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 104
      Top = 16
      Width = 142
      Height = 30
      Caption = 'S'#304'STEM G'#304'R'#304#350#304
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5258796
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Edit1: TEdit
      Left = 112
      Top = 119
      Width = 121
      Height = 29
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object Edit2: TEdit
      Left = 112
      Top = 229
      Width = 121
      Height = 29
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      PasswordChar = '*'
      TabOrder = 1
    end
    object PnlGirisButon: TPanel
      Left = 104
      Top = 312
      Width = 137
      Height = 49
      Cursor = crHandPoint
      Caption = 'Giri'#351' Yap'
      Color = 16751528
      Font.Charset = DEFAULT_CHARSET
      Font.Color = -1
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 2
      OnClick = PnlGirisButonClick
    end
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=D:\Kod dosyalar'#305'\Delphi\Ilac_Takip_DB.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 560
    Top = 88
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    Left = 560
    Top = 192
  end
end
