object FormGecmisReceteler: TFormGecmisReceteler
  Left = 0
  Top = 0
  Cursor = crHandPoint
  Caption = 'Ge'#231'mi'#351' Re'#231'eteler'
  ClientHeight = 742
  ClientWidth = 921
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object PanelUst: TPanel
    Left = 0
    Top = 0
    Width = 921
    Height = 67
    Align = alTop
    BevelOuter = bvNone
    Color = 16315632
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 989
    object LabelAra: TLabel
      Left = 32
      Top = 22
      Width = 134
      Height = 17
      Caption = #304'laca G'#246're Re'#231'ete Ara:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3877150
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object EditIlacAra: TEdit
      Left = 184
      Top = 21
      Width = 257
      Height = 23
      TabOrder = 0
      OnChange = EditIlacAraChange
    end
  end
  object DBGridGecmis: TDBGrid
    Left = 0
    Top = 67
    Width = 921
    Height = 675
    Align = alClient
    DataSource = DataSourceGecmis
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDrawColumnCell = DBGridGecmisDrawColumnCell
  end
  object BtnPdfCikti: TPanel
    Left = 696
    Top = 8
    Width = 209
    Height = 36
    Cursor = crHandPoint
    Caption = 'Re'#231'ete Bilgilerini PDf Kaydet'
    Color = 3877150
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindow
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 2
    OnClick = BtnPdfCiktiClick
  end
  object FDQueryGecmis: TFDQuery
    SQL.Strings = (
      
        'SELECT HastaID, AdSoyad, ServisNo, Durum, TCKimlik_Enc, Alerji_E' +
        'nc FROM HASTALAR')
    Left = 648
  end
  object DataSourceGecmis: TDataSource
    DataSet = FDQueryGecmis
    Left = 560
    Top = 16
  end
end
