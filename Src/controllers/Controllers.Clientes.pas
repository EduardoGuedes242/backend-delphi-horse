unit Controllers.Clientes;

interface

procedure Registry;
function Formata_CPF_CNPJ(cnpj : String) : String;
function FormataTelefone(numero : String) : String;

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
Services.Clientes,
System.NetEncoding;



procedure cadastrarClienteProspect(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Clientes : TServiceClientes;
  LSession: TLoginClaims;
  erro : String;
  razaoSocial : String;
  nomeFantasia : String;
  telefone : String;
  jsonObj  : TJSONObject;
  codigoProspect : String;

begin
  LSession := Req.Session<TLoginClaims>;
  Clientes  := TServiceClientes.Create;
  jsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(req.Body), 0) as TJSONObject;
  razaoSocial := jsonObj.Get('razao').JsonValue.Value;
  nomeFantasia := jsonObj.Get('fantasia').JsonValue.Value;
  telefone := jsonObj.Get('telefone').JsonValue.Value;

  try
    codigoProspect := Clientes.cadastrartClienteProspect(razaoSocial, nomeFantasia, telefone, erro);

    if erro  <> '' then
    begin
      Res.Send(TJSONObject.Create.AddPair('erro', erro)).Status(THTTPStatus.BadRequest).ContentType('application/json');
      Exit;
    end else
    begin
      Res.Send(TJSONObject.Create.AddPair('prospect', codigoProspect))
             .Status(THTTPStatus.OK).ContentType('application/json');
    end;

  finally
    Clientes.Free;
  end;
end;

procedure DoGetClientesCnpj(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Clientes : TServiceClientes;
  LSession: TmyClaims;
  vcnpj : String;
  vnome : String;
  vtelefone : String;
  jsonObj  : TJSONObject;


begin
  LSession := Req.Session<TMyClaims>;
  Clientes  := TServiceClientes.Create;
  jsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(req.Body), 0) as TJSONObject;
  vcnpj := jsonObj.Get('cnpj').JsonValue.Value;
  vnome := jsonObj.Get('nome').JsonValue.Value;
  vtelefone := jsonObj.Get('telefone').JsonValue.Value;
  vtelefone := FormataTelefone(vtelefone);
  vcnpj := Formata_CPF_CNPJ(vcnpj);


  try
    Res.Send(Clientes.GetClienteContratoAtivo(vcnpj, vnome, vtelefone).ToJSONArray());
  finally
    Clientes.Free;
  end;

end;

procedure BuscarCodigoClienteComBaseCNPJouNumeroSerie(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Clientes : TServiceClientes;
  LSession: TmyClaims;
  vcnpj : String;
  vnumeroSerie : String;
  jsonObj  : TJSONObject;
begin
  LSession := Req.Session<TMyClaims>;
  Clientes  := TServiceClientes.Create;
  jsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(req.Body), 0) as TJSONObject;
  vcnpj := jsonObj.Get('cnpj').JsonValue.Value;
  vnumeroSerie := jsonObj.Get('numeroSerie').JsonValue.Value;
  vcnpj := Formata_CPF_CNPJ(vcnpj);

  try
    Res.Send(Clientes.BuscarCodigoClienteComBaseCNPJouNumeroSerie(vcnpj, vnumeroSerie).ToJSONArray());
  finally
    Clientes.Free;
  end;
end;

procedure DoGetContatoCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Clientes : TServiceClientes;
  LSession: TmyClaims;
  vtelefone : String;
  jsonObj  : TJSONObject;

begin

  LSession := Req.Session<TMyClaims>;
  Clientes  := TServiceClientes.Create;
  jsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(req.Body), 0) as TJSONObject;
  vtelefone := jsonObj.Get('telefone').JsonValue.Value;
  vtelefone := FormataTelefone(vtelefone);

  try
    Res.Send(Clientes.GetContatosCliente(vtelefone).ToJSONArray());
  finally
    Clientes.Free;
  end;

end;


function Formata_CPF_CNPJ(cnpj : String) : String;
var
  Cont : Integer;
  C_Valid : String;
begin
     { Retira a máscara e deixa só os números }
  for Cont := 1 to Length(cnpj) do
    if (cnpj[Cont] in ['0'..'9']) then
      C_Valid := C_Valid + cnpj[Cont];
  if Trim(C_Valid) = '' then
 begin
    Formata_CPF_CNPJ := '';
    Exit;
  end;
  { Verifica se é CGC }
  if (Length(C_Valid) in [14, 15]) then
  begin
    while (Length(C_Valid) < 14) do
      C_Valid := C_Valid + ' ';
    Formata_CPF_CNPJ := Copy(C_Valid, 1, 2) + '.' + Copy(C_Valid, 3, 3) + '.' +
     Copy(C_Valid, 6, 3) + '/' + Copy(C_Valid, 9, 4) + '-' +
      Copy(C_Valid, 13, 2);
 end
  else
  begin
    while (Length(C_Valid) < 11) do
      C_Valid := C_Valid + ' ';
    Formata_CPF_CNPJ := Copy(C_Valid, 1, 3) + '.' + Copy(C_Valid, 4, 3) + '.' +
      Copy(C_Valid, 7, 3) + '-' + Copy(C_Valid, 10, 2);
  end;
end;

function FormataTelefone(numero: String): String;
var
  I: Integer;
begin
  Result := '';

  //Remove todos os carcacteres especiais
    for I := 1 to Length(numero) do
    if numero[I] in ['0'..'9'] then
      Result := Result + numero[I];

  // Verifica se o número começa com '55' e ignora os dois primeiros caracteres
    if (Length(Result) >= 2) and (Copy(Result, 1, 2) = '55') then
    Delete(Result, 1, 2);

end;


procedure Registry;
begin
    THorse.Use(HorseSwagger);


  THorse.AddCallback(AuthorizationV2()).post('/v1/cliente/prospect', cadastrarClienteProspect);
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
  .Path('/v1/cliente/prospect')
    .Tag('Clientes')
    .POST('Cadastrar Cliente Prospect')
      .Description('Medodo POST para cadastrar Cliente prospect')
      .AddResponse(200)
        .Schema('Retorna uma imagem para utilizar no formato WEB')
      .&End
    .&End
  .&End;

  THorse.post('/v1/cliente/contrato/', DoGetClientesCnpj);
  THorse.post('/v1/cliente/contato/', DoGetContatoCliente);
  THorse.post('/v1/cliente/buscar-por-cnpj-ou-serie', BuscarCodigoClienteComBaseCNPJouNumeroSerie);
end;

end.
