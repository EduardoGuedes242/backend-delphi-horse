library InforvixApiRest;

uses
  Horse,
  Horse.Jhonson,
  Horse.CORS,
  System.SysUtils,
  Providers.Connection in 'Src\Providers\Providers.Connection.pas' {ProviderConnection: TDataModule},
  Controllers.Login in 'Src\Controllers\Controllers.Login.pas',
  Configs.Login in 'Src\Configs\Configs.Login.pas',
  Providers.Authorization in 'Src\Providers\Providers.Authorization.pas',
  Services.Users in 'Src\Services\Services.Users.pas' {ServiceUsers: TDataModule},
  Providers.Encrypt in 'Src\Providers\Providers.Encrypt.pas',
  Configs.Encrypt in 'Src\Configs\Configs.Encrypt.pas',
  Controllers.Users in 'Src\Controllers\Controllers.Users.pas',
  MyClaims in 'Src\Class\MyClaims.pas',
  Configs.Path in 'Src\configs\Configs.Path.pas',
  Services.Clientes in 'Src\services\Services.Clientes.pas' {ServiceClientes: TDataModule},
  Controllers.Clientes in 'Src\controllers\Controllers.Clientes.pas';
{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  THorse.Use(Jhonson);
  THorse.Use(CORS);
  HorseCORS.AllowedOrigin('*').AllowedCredentials(true).AllowedHeaders('*')
  .AllowedMethods('*').ExposedHeaders('*');
  Controllers.Login.Registry;
  Controllers.Users.Registry;
  Controllers.Clientes.Registry;

  THorse.Listen();
end.

