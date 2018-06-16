object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Form1'
  ClientHeight = 430
  ClientWidth = 837
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 221
    Top = 96
    Width = 60
    Height = 13
    Caption = 'Arytmetyka:'
  end
  object Label2: TLabel
    Left = 287
    Top = 96
    Width = 3
    Height = 13
  end
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 50
    Height = 13
    Caption = 'Macierz A:'
  end
  object Label4: TLabel
    Left = 218
    Top = 8
    Width = 48
    Height = 13
    Caption = 'Wektor B:'
  end
  object Label6: TLabel
    Left = 241
    Top = 57
    Width = 18
    Height = 13
    Caption = 'mit:'
  end
  object Label7: TLabel
    Left = 321
    Top = 57
    Width = 21
    Height = 13
    Caption = 'eps:'
  end
  object Label5: TLabel
    Left = 310
    Top = 8
    Width = 48
    Height = 13
    Caption = 'Wektor X:'
  end
  object Label8: TLabel
    Left = 8
    Top = 152
    Width = 35
    Height = 13
    Caption = 'Wyniki:'
  end
  object Button1: TButton
    Left = 402
    Top = 128
    Width = 107
    Height = 25
    Caption = 'Oblicz'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 402
    Top = 53
    Width = 107
    Height = 24
    Caption = 'Przedzia'#322'owa'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 402
    Top = 23
    Width = 107
    Height = 24
    Caption = 'Zmiennopozycyjna'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Edit3: TEdit
    Left = 218
    Top = 24
    Width = 86
    Height = 21
    TabOrder = 3
    Text = '0,956;51,5603;2;5,8'
  end
  object Edit5: TEdit
    Left = 265
    Top = 54
    Width = 39
    Height = 21
    TabOrder = 4
    Text = '100'
  end
  object Edit6: TEdit
    Left = 348
    Top = 54
    Width = 48
    Height = 21
    TabOrder = 5
    Text = '1e-14'
  end
  object Memo1: TMemo
    Left = 8
    Top = 24
    Width = 204
    Height = 102
    Lines.Strings = (
      '-12,235;1,229;0,5597;0'
      '1,229;-6,78;0,765;0'
      '0,5597;0,765;91,0096;2'
      '0;0;-2;5,5')
    TabOrder = 6
  end
  object Memo2: TMemo
    Left = 8
    Top = 171
    Width = 821
    Height = 254
    ReadOnly = True
    TabOrder = 7
  end
  object Edit1: TEdit
    Left = 310
    Top = 24
    Width = 86
    Height = 21
    TabOrder = 8
    Text = '2;0,75;-1;0,9'
  end
end
