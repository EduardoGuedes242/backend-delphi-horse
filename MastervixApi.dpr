program MastervixApi;

uses
  Horse,
  Horse.Jhonson,
  Horse.CORS,
  Horse.GBSwagger,
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
  Controllers.Clientes in 'Src\controllers\Controllers.Clientes.pas',
  Services.Clientes in 'Src\services\Services.Clientes.pas' {ServiceClientes: TDataModule},
  Services.Proposta in 'Src\services\Services.Proposta.pas' {ServicesProposta: TDataModule},
  Controllers.Leads in 'Src\controllers\Controllers.Leads.pas',
  LoginClaims in 'Src\Class\LoginClaims.pas',
  GlobalController in 'Src\controllers\GlobalController.pas',
  Services.Inquilinos in 'Src\services\Services.Inquilinos.pas' {ServicesInquilinos: TDataModule},
  Controllers.Inquilinos in 'Src\controllers\Controllers.Inquilinos.pas';

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
  Controllers.Leads.Registry;
  Controllers.Inquilinos.Registry;

  THorse.Listen(9897,
  procedure
    begin
      Writeln('Server is runing on port ' + THorse.Port.ToString);
      Write('Press return to stop...');
      ReadLn;
      THorse.StopListen;
    end);
end.
