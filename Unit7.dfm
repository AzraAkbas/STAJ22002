object Form7: TForm7
  Left = 0
  Top = 0
  Caption = 'Ge'#231'mi'#351' Uygulamalar'
  ClientHeight = 719
  ClientWidth = 1143
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1143
    Height = 57
    Align = alTop
    Color = 16315632
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 1071
    object Label1: TLabel
      Left = 46
      Top = 19
      Width = 64
      Height = 17
      Caption = 'Hasta Ara:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 507
      Top = 19
      Width = 60
      Height = 17
      Caption = 'Tarih Ara:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAramaGecmis: TEdit
      Left = 128
      Top = 18
      Width = 193
      Height = 23
      TabOrder = 0
      OnChange = edtAramaGecmisChange
    end
    object dtpTarihFiltre: TDateTimePicker
      Left = 584
      Top = 18
      Width = 186
      Height = 23
      Date = 46230.000000000000000000
      Time = 0.056883645833295300
      TabOrder = 1
      OnCloseUp = dtpTarihFiltreChange
      OnChange = dtpTarihFiltreChange
    end
  end
  object dbGridGecmis: TDBGrid
    Left = 0
    Top = 57
    Width = 1143
    Height = 662
    Align = alClient
    DataSource = DataSource1
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = '1'
        Visible = True
      end>
  end
  object qryGecmisUygulamalar: TFDQuery
    Connection = FrmLogin.FDConnection1
    SQL.Strings = (
      'SELECT 1')
    Left = 728
    Top = 96
  end
  object DataSource1: TDataSource
    DataSet = qryGecmisUygulamalar
    Left = 640
    Top = 128
  end
end
