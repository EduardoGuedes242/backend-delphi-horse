unit Controllers.Login;

interface

uses LoginClaims;

procedure Registry;

implementation

uses Horse, Providers.Authorization, JOSE.Core.JWT, Configs.Login, System.JSON, System.SysUtils, System.DateUtils,
  JOSE.Core.Builder, Services.Users, Horse.GBSwagger;


procedure cadastarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Users: TServiceUsers;
  JWT: TJWT;
  Claims: TJWTClaims;
  Config: TConfigLogin;
  nome: String;
  email: String;
  Senha: String;
  tipoUsuario: String;
  erro : String;
  jsonObj  : TJSONObject;
  LSession: TLoginClaims;

begin
  try
    LSession := Req.Session<TLoginClaims>;
    Users := TServiceUsers.Create;
    try
      jsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(req.Body), 0) as TJSONObject;
      nome   := jsonObj.Get('nome').JsonValue.Value;
      email   := jsonObj.Get('email').JsonValue.Value;
      Senha   := jsonObj.Get('senha').JsonValue.Value;
      tipoUsuario   := jsonObj.Get('tipoUsuario').JsonValue.Value;

      if not Users.cadastrarUsuario(LSession.Inquilino, nome, email, senha, tipoUsuario, erro) then
      begin
        Res.Send(TJSONObject.Create.AddPair('message', erro)).Status(THTTPStatus.BadRequest).ContentType('application/json');
      end else
      begin
        Res.Send(TJSONObject.Create.AddPair('message', 'usuario cadastrado com sucesso')).Status(THTTPStatus.BadRequest).ContentType('application/json');
      end;
    finally
      Users.Free;
    end;
  Except
    on E : Exception do
    begin
      Res.Send(e.Message).Status(THTTPStatus.ServiceUnavailable).ContentType('application/json');
    end;
  end;
end;



procedure login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Users: TServiceUsers;
  JWT: TJWT;
  Claims: TJWTClaims;
  Config: TConfigLogin;
  email: String;
  Senha: String;
  erro : String;
  jsonObj  : TJSONObject;
  arrayRetorno: TJSONArray;
  inquilino,
  tipoUsuario : String;
begin
  try
    Users := TServiceUsers.Create;
    try
      jsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(req.Body), 0) as TJSONObject;
      email   := jsonObj.Get('login').JsonValue.Value;
      Senha   := jsonObj.Get('senha').JsonValue.Value;
      if not Users.login(email, Senha, erro, inquilino, tipoUsuario) then
      begin
        Res.Send(TJSONObject.Create.AddPair('message', erro)).Status(THTTPStatus.BadRequest).ContentType('application/json');
      end else
      begin
        JWT := TJWT.Create;
        Claims := JWT.Claims;
        Claims.JSON := TJSONObject.Create;
        Claims.IssuedAt := Now;
        Claims.Expiration := IncHour(Now, Config.Expires);
        Claims.SetClaimOfType<string>('inquilino', inquilino);
        Claims.SetClaimOfType<string>('tipoUsuario', tipoUsuario);

        Res.Send(TJSONObject.Create.AddPair('token', TJOSE.SHA256CompactToken(Config.Secret, JWT)));
      end;
    finally
      Users.Free;
    end;
  Except
    on E : Exception do
    begin
      Res.Send(e.Message).Status(THTTPStatus.ServiceUnavailable).ContentType('application/json');
    end;
  end;
end;


procedure Registry;

begin
  THorse.Post('/v1/login', login);
  THorse.Post('/v1/usuario', cadastarUsuario);
  THorse.Use(HorseSwagger);
  Swagger
  .Info
    .Title('Horse Sample')
    .Description('API Horse')
    .Contact
      .Name('Inforvix')
      .Email('suporte@inforvix.com.br')
      .URL('https://inforvix.com.br')
    .&End
  .&End
  .BasePath('v1')
  .Path('/v2/login')
    .Tag('login')
    .POST('Autenticação do usuario')
      .AddParamBody('dados para autenticação')
        .Required(True)
        .Schema(
          '{"cnpj": "00.000.000/0000-00", "login": "MASTER", "senha": "master"}'
        )
      .&End
      .AddResponse(200)
        .Schema('{"token": "TOKEN_AUTH"}')
      .&End
    .&End
  .&End;
end;

end.
