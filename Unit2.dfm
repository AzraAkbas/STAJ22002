object FormDoktorPaneli: TFormDoktorPaneli
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Hasta Takip ve Listeleme Paneli'
  ClientHeight = 778
  ClientWidth = 897
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 17
  object PanelUst: TPanel
    Left = 0
    Top = 0
    Width = 897
    Height = 67
    Align = alTop
    BevelOuter = bvNone
    Color = 16315632
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 991
    object LabelAra: TLabel
      Left = 32
      Top = 23
      Width = 64
      Height = 17
      Caption = 'Hasta Ara:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3877150
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object EditTCAra: TEdit
      Left = 112
      Top = 20
      Width = 257
      Height = 25
      TabOrder = 0
      OnChange = EditTCAraChange
      OnKeyDown = EditTCAraKeyDown
    end
  end
  object DBGridHastalar: TDBGrid
    Left = 0
    Top = 67
    Width = 897
    Height = 711
    Align = alClient
    DataSource = DataSourceHastalar
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object FDQueryHastalar: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      
        'SELECT HastaID, AdSoyad, ServisNo, Durum, TCKimlik_Enc, Alerji_E' +
        'nc FROM HASTALAR')
    Left = 720
    Top = 24
  end
  object DataSourceHastalar: TDataSource
    DataSet = FDQueryHastalar
    Left = 608
    Top = 8
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=D:\Kod dosyalar'#305'\Delphi\Ilac_Takip_DB.db'
      'DriverID=SQLite')
    Connected = True
    LoginPrompt = False
    Left = 800
    Top = 64
  end
end
