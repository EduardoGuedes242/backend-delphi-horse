unit Services.Clientes;

interface

uses
  System.SysUtils, System.Classes, Providers.Connection, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Ragna, GlobalController;

type
  TServiceClientes = class(TProviderConnection)
    clientes: TFDQuery;
    contatoClientes: TFDQuery;
    qryExec: TFDQuery;
  private
    { Private declarations }
  public
  function GetClienteContratoAtivo(cnpj, nome, telefone : String) : TFDQuery;
  function GetContatosCliente(telefone : String ) : TFDQuery;
  function BuscarCodigoClienteComBaseCNPJouNumeroSerie(cnpj, numeroSerie : String) : TFDQuery;
  function GetClientes(vendedor : String) : TFDQuery;
  function cadastrartClienteProspect(RazaoSocial, NomeFantasia, telefone: String; out erro : String): String;
    { Public declarations }
  end;

var
  ServiceClientes: TServiceClientes;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TServiceClientes }

function TServiceClientes.BuscarCodigoClienteComBaseCNPJouNumeroSerie(cnpj,
  numeroSerie : String): TFDQuery;
  var
    codigoCliente : Integer;
begin
  clientes.SQL.Text :=
    ' SELECT ' +
    ' CLIENTES.CLI_CODIGO, ' +
    ' CLIENTES.CLI_CNPJ ' +
    ' FROM CLIENTES ' +
    ' WHERE CLIENTES.CLI_CNPJ = ''' + cnpj + ''' ';
  clientes.Open();
  if clientes.IsEmpty then
    codigoCliente := -1
  else
    codigoCliente := clientes.FieldByName('CLI_CODIGO').AsInteger;
  clientes.Close;

  if codigoCliente = -1 then
  begin
    clientes.SQL.Text :=
      ' SELECT ' +
      ' CON$CONTRATOS.CLI_CODIGO, ' +
      ' CLIENTES.CLI_CNPJ ' +
      ' FROM CON$CONTRATOS ' +
      ' JOIN CLIENTES ON (CON$CONTRATOS.CLI_CODIGO = CLIENTES.CLI_CODIGO) ' +
      ' WHERE CON$CONTRATOS.CTT_NUM_SERIE = ''' + numeroSerie + ''' ';
    clientes.Open();
    codigoCliente := clientes.FieldByName('CLI_CODIGO').AsInteger;
    clientes.Close;
  end;

  Result := clientes.OpenUp;
end;

function TServiceClientes.cadastrartClienteProspect(RazaoSocial, NomeFantasia, telefone: String; out erro : String): String;
var
  Conectado : boolean;
  codigo : String;
begin
  try
    try
      Conectado := FDConnection.InTransaction;

      if not Conectado then
        FDConnection.StartTransaction;
      QryExec.Connection := FDConnection;

      QryExec.SQL.Text :=
      ' INSERT INTO FIN$CLIENTES_TEMPORARIOS (CLIT_CODIGO, CLIT_RAZAO, CLIT_FANTASIA, CLIT_TELEFONE)'+
      ' VALUES (:CLIT_CODIGO, :CLIT_RAZAO, :CLIT_FANTASIA, :CLIT_TELEFONE)';
      codigo := NextGenerator(FDConnection, 'FIN$CLIENT_TEMP_CLIT_CODIGO_GEN', 'CLIT_CODIGO', 'FIN$CLIENTES_TEMPORARIOS');

      QryExec.ParamByName('CLIT_CODIGO').AsString := codigo;
      QryExec.ParamByName('CLIT_RAZAO').AsString := RazaoSocial;
      QryExec.ParamByName('CLIT_FANTASIA').AsString := NomeFantasia;
      QryExec.ParamByName('CLIT_TELEFONE').AsString := telefone;
      QryExec.ExecSQL;

      Result := codigo

    Except
      on E : Exception do
      begin
        if FDConnection.InTransaction then
          FDConnection.Rollback;
        Result := E.Message;
        erro := E.Message;
      end;
    end;
  finally
    QryExec.Free;
    if not Conectado then
      if FDConnection.InTransaction then
        FDConnection.Commit;
  end;

end;

function TServiceClientes.GetClienteContratoAtivo(cnpj, nome, telefone : String): TFDQuery;
var
  codigoCliente : Integer;
  codContato : integer;
  codContatoCadastrado : String;
begin
  clientes.SQL.Text :=
    'SELECT FIRST 1 CLIENTES.CLI_CODIGO as codCliente, CLIENTES.CLI_RAZAO '+
    'FROM CLIENTES '+
    'JOIN CON$CONTRATOS ON (CLIENTES.CLI_CODIGO = CON$CONTRATOS.CLI_CODIGO) '+
    'WHERE CLIENTES.CLI_CNPJ =  ''' + cnpj + ''' ' +
    'AND CON$CONTRATOS.CTT_FL_STATUS = ''A'' ';
  clientes.Open();

  if clientes.IsEmpty then
    codigoCliente := -1
  else
    codigoCliente := clientes.FieldByName('codCliente').AsInteger;

  clientes.Close;

  if codigoCliente > -1 then
  begin
    contatoClientes.SQL.Text :=
      ' SELECT FIRST 1 CONTATOS_CLIENTES.COC_CODIGO ' +
      ' FROM CONTATOS_CLIENTES ' +
      ' WHERE COC_TELEFONE_SEM_FORMATACAO = :TELEFONE ' +
      ' AND CLI_CODIGO = :CLI_CODIGO ';
    contatoClientes.ParamByName('TELEFONE').AsString := telefone;
    contatoClientes.ParamByName('CLI_CODIGO').AsString := InttoStr(codigoCliente);
    contatoClientes.Open();
    codContatoCadastrado := contatoClientes.FieldByName('COC_CODIGO').AsString;
    contatoClientes.Close;

    if codContatoCadastrado.IsEmpty then
    begin
      contatoClientes.SQL.Text :=
        'INSERT INTO CONTATOS_CLIENTES ' +
        '(' +
        ' CLI_CODIGO,' +
        ' COC_NOME,' +
        ' COC_TELEFONE' +
        ') ' +
        'VALUES(' +
        ' :CLI_CODIGO,' +
        ' :COC_NOME,' +
        ' :COC_TELEFONE' +
        ')';
      contatoClientes.ParamByName('CLI_CODIGO').AsInteger := codigoCliente;
      contatoClientes.ParamByName('COC_NOME').AsString := nome;
      contatoClientes.ParamByName('COC_TELEFONE').AsString := telefone;
      contatoClientes.ExecSQL;
      contatoClientes.Close;

    end else
    begin
      contatoClientes.SQL.Text :=
        'UPDATE CONTATOS_CLIENTES SET CONTATOS_CLIENTES.COC_NOME = :COC_NOME ' +
        'WHERE COC_CODIGO = :COC_CODIGO';
      contatoClientes.ParamByName('COC_NOME').AsString := nome;
      contatoClientes.ParamByName('COC_CODIGO').AsString := codContatoCadastrado;
      contatoClientes.ExecSQL;
      contatoClientes.Close;
    end;

    end;

  Result := Clientes.OpenUp;

end;

function TServiceClientes.GetContatosCliente(telefone: String): TFDQuery;
begin
  contatoClientes.SQL.Text :=
    'SELECT FIRST 1 CLIENTES.CLI_CODIGO "CodCliente",  CONTATOS_CLIENTES.COC_NOME "NomeContato" ' +
    '  ' +
    'FROM CON$CONTRATOS ' +
    '  ' +
    'JOIN CLIENTES ON (CON$CONTRATOS.CLI_CODIGO = CLIENTES.CLI_CODIGO) ' +
    'JOIN CONTATOS_CLIENTES ON (CLIENTES.CLI_CODIGO = CONTATOS_CLIENTES.CLI_CODIGO) ' +
    '  ' +
    'WHERE CON$CONTRATOS.CTT_FL_STATUS = ''A'' ' +
    'AND CONTATOS_CLIENTES.COC_TELEFONE_SEM_FORMATACAO = ' + QuotedStr(telefone);

  Result := contatoClientes.OpenUp;

end;

function TServiceClientes.GetClientes(vendedor : String) : TFDQuery;
begin
  contatoClientes.SQL.Text :=
    'SELECT CLIENTES.CLI_CODIGO "CodCliente",  CLIENTES.CLI_RAZAO' +
    '  ' +
    'FROM CLIENTES ' +
    '  ' +
    'WHERE CLIENTES.CLI_FL_ATIVO = ''S'' ';
  Result := contatoClientes.OpenUp;
end;



end.
