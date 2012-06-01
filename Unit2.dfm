object Form2: TForm2
  Left = 672
  Top = 286
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1057#1086#1077#1076#1080#1085#1077#1085#1080#1077
  ClientHeight = 111
  ClientWidth = 144
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Elogin: TEdit
    Left = 13
    Top = 13
    Width = 124
    Height = 21
    Hint = #1051#1086#1075#1080#1085
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object Epass: TEdit
    Left = 13
    Top = 33
    Width = 124
    Height = 21
    Hint = #1055#1072#1088#1086#1083#1100
    ParentShowHint = False
    PasswordChar = '*'
    ShowHint = True
    TabOrder = 1
  end
  object BConnect: TButton
    Left = 13
    Top = 80
    Width = 122
    Height = 25
    Caption = #1057#1086#1077#1076#1080#1085#1080#1090#1100#1089#1103
    TabOrder = 2
    OnClick = BConnectClick
  end
  object CBRealm: TComboBox
    Left = 13
    Top = 56
    Width = 124
    Height = 21
    Hint = #1042#1099#1073#1086#1088' '#1084#1080#1088#1072
    Style = csDropDownList
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
end
