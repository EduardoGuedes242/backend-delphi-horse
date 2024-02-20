inherited ServiceClientes: TServiceClientes
  Height = 232
  Width = 326
  inherited FDConnection: TFDConnection
    Left = 24
    Top = 8
  end
  object clientes: TFDQuery
    Connection = FDConnection
    Left = 24
    Top = 120
  end
  object contatoClientes: TFDQuery
    Connection = FDConnection
    Left = 24
    Top = 64
  end
  object qryExec: TFDQuery
    Connection = FDConnection
    Left = 144
    Top = 104
  end
end
