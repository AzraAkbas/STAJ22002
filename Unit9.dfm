object Form9: TForm9
  Left = 0
  Top = 0
  Caption = 'Ge'#231'mi'#351' '#304'la'#231' '#304'stekleri'
  ClientHeight = 716
  ClientWidth = 1135
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnActivate = FormActivate
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1135
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
    ExplicitWidth = 1042
    ExplicitHeight = 708
    object TabSheet1: TTabSheet
      Caption = 'Doktor Re'#231'eteleri'
      object pnlReceteTop: TPanel
        Left = 0
        Top = 0
        Width = 1127
        Height = 60
        Align = alTop
        Color = 16315632
        ParentBackground = False
        TabOrder = 0
        ExplicitWidth = 1034
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
        object Label4: TLabel
          Left = 440
          Top = 16
          Width = 119
          Height = 17
          Caption = 'Tarihe G'#246're Arama:'
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
        object dtpTarihRecete: TDateTimePicker
          Left = 568
          Top = 13
          Width = 186
          Height = 25
          Date = 46230.000000000000000000
          Time = 0.769959502315032300
          TabOrder = 1
          OnChange = dtpTarihReceteChange
        end
      end
      object dbGridReceteler: TDBGrid
        Left = 0
        Top = 60
        Width = 1127
        Height = 624
        Align = alClient
        DataSource = DataSourceReceteler
        TabOrder = 1
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
        Width = 1127
        Height = 60
        Align = alTop
        Color = 16315632
        ParentBackground = False
        TabOrder = 0
        ExplicitWidth = 1036
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
        object Label3: TLabel
          Left = 440
          Top = 16
          Width = 119
          Height = 17
          Caption = 'Tarihe G'#246're Arama:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtServisAraStok: TEdit
          Left = 171
          Top = 13
          Width = 153
          Height = 25
          TabOrder = 0
          OnChange = edtServisAraStokChange
        end
        object dtpTarihStok: TDateTimePicker
          Left = 568
          Top = 13
          Width = 186
          Height = 25
          Date = 46230.000000000000000000
          Time = 0.770272488429327500
          TabOrder = 1
          OnChange = dtpTarihStokChange
        end
      end
      object dbGridStokIstek: TDBGrid
        Left = 0
        Top = 60
        Width = 1127
        Height = 624
        Align = alClient
        DataSource = DataSourceStokIstek
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
  end
  object DataSourceStokIstek: TDataSource
    DataSet = qryStokIstek
    Left = 540
    Top = 188
  end
  object qryReceteler: TFDQuery
    Connection = FrmLogin.FDConnection1
    Left = 940
    Top = 52
  end
  object qryStokIstek: TFDQuery
    Connection = FrmLogin.FDConnection1
    Left = 964
    Top = 140
  end
  object DataSourceReceteler: TDataSource
    DataSet = qryReceteler
    Left = 836
    Top = 52
  end
end
