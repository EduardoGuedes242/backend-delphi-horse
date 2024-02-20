unit Controllers.Leads;

interface

procedure Registry;

implementation

uses
Horse,
System.JSON,
Providers.Authorization,
Services.Proposta,
SysUtils,
LoginClaims,
JOSE.Core.JWT;

Procedure criarProposta(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Proposta: TServicesProposta;
  LSession: TLoginClaims;
  erro: String;
  jsonArray: TJSONArray;
  i: Integer;
  codigoCliente : String;
  observacao : String;
  clienteProspect : boolean;
  retornoProposta : String;
  jsonObj: TJSONObject;

begin
  try
    try
      LSession := Req.Session<TLoginClaims>;
      Proposta        := TServicesProposta.Create;
      jsonObj         := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(req.Body), 0) as TJSONObject;
      codigoCliente   := jsonObj.Get('cliente').JsonValue.Value;
      observacao      := jsonObj.Get('observacao').JsonValue.Value;
      clienteProspect := jsonObj.Get('clienteProspect').JsonValue.Value.ToBoolean();
      if codigoCliente = '' then
      begin
        codigoCliente := '3'
      end;

    //  retornoProposta := Proposta.criarProposta(LSession.Usuario, LSession.Vendedor, LSession.TabPreco, codigoCliente, observacao, clienteProspect, erro);

      if erro  <> '' then
      begin
        Res.Send(TJSONObject.Create.AddPair('erro', erro)).Status(THTTPStatus.BadRequest).ContentType('application/json');
        Exit;
      end else
      begin
        Res.Send(TJSONObject.Create.AddPair('proposta', retornoProposta))
               .Status(THTTPStatus.OK).ContentType('application/json');
      end;



    finally
      Proposta.Free;
    end;
  except
    on e: Exception do
    begin
      Res.Send(e.Message).Status(THTTPStatus.ServiceUnavailable).ContentType('application/json');
    end;
  end;
end;

Procedure PostAddProspec(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Leads: TServicesProposta;
  //LSession: TmyClaims;
  erro: String;
  jsonArray: TJSONArray;
  i: Integer;
  nomeLead : String;
  telefoneLead : String;
  emailLead : String;
  origemLead : String;
  valorLead : Double;
  obsLead : String;
  jsonObj: TJSONObject;

begin
  try
    try
      Leads := TServicesProposta.Create;
      jsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(req.Body), 0) as TJSONObject;
      nomeLead := jsonObj.Get('nome').JsonValue.Value;
      telefoneLead := jsonObj.Get('telefone').JsonValue.Value;
      emailLead := jsonObj.Get('email').JsonValue.Value;
      origemLead := jsonObj.Get('origem').JsonValue.Value;
      obsLead := jsonObj.Get('obsLead').JsonValue.Value;
      valorLead := StrToFloatDef(jsonObj.Get('valor').JsonValue.Value, 0.0);

      if not Leads.addProspect(nomeLead, telefoneLead, emailLead, origemLead, obsLead, valorLead, erro) then
      begin
        Res.Send(TJSONObject.Create.AddPair('erro', erro)).Status(THTTPStatus.BadRequest).ContentType('application/json');
        Exit;
      end;

      Res.Send(TJSONObject.Create.AddPair('mensagem', 'Lead Registrado com Sucesso'))
               .Status(THTTPStatus.OK).ContentType('application/json');

    finally
      Leads.Free;
    end;
  except
    on e: Exception do
    begin
      Res.Send(e.Message).Status(THTTPStatus.ServiceUnavailable).ContentType('application/json');
    end;
  end;
end;

Procedure PostAddProspecLog(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Leads: TServicesProposta;
  //LSession: TmyClaims;
  erro: String;
  jsonArray: TJSONArray;
  jsonObj: TJSONObject;
  dadosBody : String;

begin
  try
    try
      Leads := TServicesProposta.Create;
      jsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(req.Body), 0) as TJSONObject;
      dadosBody := jsonObj.ToString;

      if not Leads.addProspectLog(dadosBody, erro) then
      begin
        Res.Send(TJSONObject.Create.AddPair('erro', erro)).Status(THTTPStatus.BadRequest).ContentType('application/json');
        Exit;
      end;

      Res.Send(TJSONObject.Create.AddPair('mensagem', 'Lead Registrado com Sucesso na tabela de LOG'))
               .Status(THTTPStatus.OK).ContentType('application/json');

    finally
      Leads.Free;
    end;
  except
    on e: Exception do
    begin
      Res.Send(e.Message).Status(THTTPStatus.ServiceUnavailable).ContentType('application/json');
    end;
  end;
end;

procedure Registry;
begin
  THorse.Post('/v1/leads/prospect/add', PostAddProspecLog);
  THorse.AddCallback(AuthorizationV2()).post('/v1/proposta', criarProposta);
end;

end.
