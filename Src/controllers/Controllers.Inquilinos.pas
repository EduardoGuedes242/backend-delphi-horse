unit Controllers.Inquilinos;

interface

procedure Registry;

implementation
uses
Horse,
Horse.GBSwagger,
Providers.Authorization,
System.JSON,
Ragna,
Configs.Login,
JOSE.Core.JWT,
JOSE.Core.Builder,
LoginClaims,
myClaims,
SysUtils,
Configs.Path,
System.Classes,
Services.Inquilinos,
System.NetEncoding;

procedure criarInquilino(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Inquilinos : TServicesInquilinos;
  erro : String;
  nome : String;
  email : String;
  jsonObj  : TJSONObject;
  idInquilino : String;

begin
  Inquilinos  := TServicesInquilinos.Create;
  jsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(req.Body), 0) as TJSONObject;
  nome := jsonObj.Get('nome').JsonValue.Value;
  email := jsonObj.Get('email').JsonValue.Value;

  try
    if not Inquilinos.criarInquilino(nome, email, erro, idInquilino)  then
    begin
      Res.Send(TJSONObject.Create.AddPair('erro', erro)).Status(THTTPStatus.BadRequest).ContentType('application/json');
      Exit;
    end else
    begin
      Res.Send(TJSONObject.Create.AddPair('message', 'Inquilino cadastrado com sucesso')
                                 .AddPair('codigo', idInquilino))
             .Status(THTTPStatus.OK).ContentType('applic.ation/json');
    end;

  finally
    Inquilinos.Free;
  end;
end;

procedure Registry;
begin
  THorse.post('/v1/inquilino/add', criarInquilino);
end;

end.
