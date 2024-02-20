inherited ServiceUsers: TServiceUsers
  OnCreate = DataModuleCreate
  Height = 185
  Width = 320
  inherited FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'User_Name=sysdba'
      'Password=masterkey')
    Left = 102
    Top = 21
  end
  object Users: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'select '
      '*'
      'from users')
    Left = 22
    Top = 69
    object UsersID: TLargeintField
      FieldName = 'ID'
      Origin = 'ID'
    end
    object UsersUSERNAME: TStringField
      FieldName = 'USERNAME'
      Origin = 'USERNAME'
      Size = 50
    end
    object UsersNAME: TStringField
      FieldName = 'NAME'
      Origin = 'NAME'
      Size = 50
    end
    object UsersPASS: TStringField
      DisplayWidth = 100
      FieldName = 'PASS'
      Origin = 'PASS'
      Size = 100
    end
  end
  object Query: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'select '
      '*'
      'from users')
    Left = 26
    Top = 6
  end
end
