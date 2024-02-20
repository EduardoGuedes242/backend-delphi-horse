object ProviderConnection: TProviderConnection
  Height = 150
  Width = 215
  object FDConnection: TFDConnection
    Params.Strings = (
      'CharacterSet=ISO8859_1'
      'Port=3050'
      'Protocol='
      'DriverID=FB'
      'User_Name=sysdba'
      'Password=masterkey')
    ConnectedStoredUsage = [auDesignTime]
    LoginPrompt = False
    BeforeConnect = FDConnectionBeforeConnect
    Left = 88
    Top = 56
  end
end
