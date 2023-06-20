object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Sistema de Cadastro de Cliente'
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = mmnMain
  ShowHint = True
  WindowState = wsMaximized
  TextHeight = 15
  object stbInformaSistema: TStatusBar
    Left = 0
    Top = 423
    Width = 628
    Height = 19
    Panels = <
      item
        Style = psOwnerDraw
        Width = 50
      end>
  end
  object mmnMain: TMainMenu
    Left = 40
    Top = 328
    object mnCadastro: TMenuItem
      Caption = '&Cadastros'
      object mnCliente: TMenuItem
        Action = actCliente
      end
    end
  end
  object aclAcoesMenuMain: TActionList
    Left = 40
    Top = 384
    object actCliente: TAction
      Category = 'Cadastros'
      Caption = 'Cliente'
      Hint = 'Cadstro de Clientes'
      ShortCut = 16460
      OnExecute = actClienteExecute
    end
  end
end
