library HorseApache;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters.

  Important note about VCL usage: when this DLL will be implicitly
  loaded and this DLL uses TWicImage / TImageCollection created in
  any unit initialization section, then Vcl.WicImageInit must be
  included into your library's USES clause. }

uses
  Horse,
  Horse.Jhonson,
  Horse.CORS,
  System.SysUtils,
  web.HTTPD24Impl,
  Controllers.Categoria in 'Src\Controllers\Controllers.Categoria.pas',
  Providers.Connection in 'Src\Providers\Providers.Connection.pas' {ProviderConnection: TDataModule},
  Services.Noticias in 'Src\services\Services.Noticias.pas' {ServiceNoticias: TDataModule},
  Controllers.Produtos in 'Src\controllers\Controllers.Produtos.pas',
  Services.Produtos in 'Src\services\Services.Produtos.pas' {ServiceSections: TDataModule},
  Controllers.Pedido in 'Src\Controllers\Controllers.Pedido.pas',
  Services.Tasks in 'Src\Services\Services.Tasks.pas' {ServiceTasks: TDataModule},
  Controllers.Login in 'Src\Controllers\Controllers.Login.pas',
  Configs.Login in 'Src\Configs\Configs.Login.pas',
  Providers.Authorization in 'Src\Providers\Providers.Authorization.pas',
  Services.Users in 'Src\Services\Services.Users.pas' {ServiceUsers: TDataModule},
  Providers.Encrypt in 'Src\Providers\Providers.Encrypt.pas',
  Configs.Encrypt in 'Src\Configs\Configs.Encrypt.pas',
  Controllers.Users in 'Src\Controllers\Controllers.Users.pas',
  MyClaims in 'Src\Class\MyClaims.pas',
  Configs.Path in 'Src\configs\Configs.Path.pas',
  Services.Pedido in 'Src\services\Services.Pedido.pas' {ServicePedido: TDataModule};

{$R *.res}

var
  ModuleData : TApacheModuleData;
exports
  ModuleData name 'horseapache';

begin

  THorse.DefaultModule := @ModuleData;
  THorse.HandlerName := 'horseapachehandler';
  ReportMemoryLeaksOnShutdown := True;
  THorse.Use(Jhonson);
  THorse.Use(CORS);
  HorseCORS.AllowedOrigin('*').AllowedCredentials(true).AllowedHeaders('*').AllowedMethods('*').ExposedHeaders('*');
  Controllers.Login.Registry;
  Controllers.Users.Registry;
  Controllers.Categoria.Registry;
  Controllers.Produtos.Registry;

  THorse.Listen();
end.
