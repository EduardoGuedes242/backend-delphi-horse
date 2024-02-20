unit Services.Proposta;

interface

uses
  System.SysUtils, StrUtils,System.Classes, Providers.Connection, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, GlobalController;

type
  TServicesProposta = class(TProviderConnection)
    qryLeads: TFDQuery;
  private
    { Private declarations }
  public
    { Public declarations }
    function addProspectLog(bodyCompleto : String; out error : String) : boolean;
    function addProspect(nomeLead, telefoneLead, emailLead,  origemLead, obsLead: String; valorLead : Double; out error : String) : boolean;
    function criarProposta(usuarioCodigo, vendedorCodigo, tabelaPrecoCodigo, clienteCodigo, observacao : String; clienteProspect : boolean; out error : String) : String;
  end;

var
  ServicesProposta: TServicesProposta;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function TServicesProposta.criarProposta(usuarioCodigo, vendedorCodigo, tabelaPrecoCodigo, clienteCodigo, observacao : String; clienteProspect : boolean; out error : String) : String;
var
  codigoProposta : String;
begin
  try
    try
      writeln(usuarioCodigo);
      writeln(vendedorCodigo);
      writeln(tabelaPrecoCodigo);

      qryLeads.SQL.Text :=
      ' INSERT INTO FIN$PROPOSTA'+
      ' (PROP_CODIGO,' +
      IfThen(clienteProspect, 'CLIT_CODIGO,', 'CLI_CODIGO,') +
      ' TAB_CODIGO,'+
      ' PROP_DATA_ABERTURA,'+
      ' PROP_HORA_ABERTURA,'+
      ' PROP_OBS_IMPORTANTE,'+
      ' USU_CODIGO,'+
      ' VEN_CODIGO)'+
      ' VALUES'+
      ' (:PROP_CODIGO,'+
      ' :CODIGO_CLIENTE,'+
      ' :TAB_CODIGO,'+
      ' CURRENT_DATE,'+
      ' CURRENT_TIME,'+
      ' :PROP_OBS_IMPORTANTE,'+
      ' :USU_CODIGO,'+
      ' :VEN_CODIGO)';
      codigoProposta := NextGenerator(FDConnection, 'FIN$PROPOSTA_PROP_CODIGO_GEN', 'PROP_CODIGO', 'FIN$PROPOSTA');
      qryLeads.ParamByName('PROP_CODIGO').AsString         := codigoProposta;
      qryLeads.ParamByName('CODIGO_CLIENTE').AsString      := clienteCodigo;
      qryLeads.ParamByName('TAB_CODIGO').AsString          := tabelaPrecoCodigo;
      qryLeads.ParamByName('PROP_OBS_IMPORTANTE').AsString := observacao;
      qryLeads.ParamByName('USU_CODIGO').AsString          := usuarioCodigo;
      qryLeads.ParamByName('VEN_CODIGO').AsString          := vendedorCodigo;
      qryLeads.ExecSQL;
      qryLeads.Close;
    finally
      FDConnection.Commit;
      Result := codigoProposta;
    end;
  except
    on e: exception do
    begin
      FDConnection.Rollback;
      Result := e.Message;
      Error := e.Message;
    end;
  end;
end;

function TServicesProposta.addProspect(nomeLead, telefoneLead, emailLead,  origemLead, obsLead: String; valorLead : Double; out error : String) : boolean;
var
  codClienteTemporario : Integer;
  codProposta : Integer;
  codigosJaExistente  : boolean;

begin
  try
    try
      repeat
        //Coloca o numero gerado no editcodigo
        qryLeads.SQL.Text :=
        'Select GEN_ID (FIN$CLIENT_TEMP_CLIT_CODIGO_GEN, 1) From RDB$DATABASE';
        qryLeads.Open;
        codClienteTemporario := qryLeads.Fields[0].Value;
        qryLeads.Close;
        //Testa se existe esse codigo do contrario pede outro
        qryLeads.SQL.Text :=
        'Select * From FIN$CLIENTES_TEMPORARIOS Where CLIT_CODIGO = ' + codClienteTemporario.ToString;
        qryLeads.Open;
        codigosJaExistente := qryLeads.IsEmpty;
        qryLeads.Close;
      until (codigosJaExistente); { Só para de Sujerir novos codigo se o mesmo não existir }

      qryLeads.SQL.Text :=
      ' INSERT INTO FIN$CLIENTES_TEMPORARIOS ( ' +
      ' CLIT_CODIGO, ' +
      ' CLIT_RAZAO, ' +
      ' CLIT_TELEFONE, ' +
      ' CLIT_E_MAIL, ' +
      ' CLIT_FL_TIPO_INSCRICAO) ' +
      ' VALUES ( ' +
      ' :CLIT_CODIGO, ' +
      ' :CLIT_RAZAO, ' +
      ' :CLIT_TELEFONE, ' +
      ' :CLIT_E_MAIL, ' +
      ' ''O'') ';
      qryLeads.ParamByName('CLIT_CODIGO').AsInteger  := codClienteTemporario;
      qryLeads.ParamByName('CLIT_RAZAO').AsString    := nomeLead;
      qryLeads.ParamByName('CLIT_TELEFONE').AsString := telefoneLead;
      qryLeads.ParamByName('CLIT_E_MAIL').AsString   := emailLead;
      qryLeads.ExecSQL;
      qryLeads.Close;

      repeat
        //Coloca o numero gerado no editcodigo
        qryLeads.SQL.Text := 'Select GEN_ID (FIN$PROPOSTA_PROP_CODIGO_GEN, 1) From RDB$DATABASE';
        qryLeads.Open;
        codProposta := qryLeads.Fields[0].Value;
        qryLeads.Close;
        //Testa se existe esse codigo do contrario pede outro
        qryLeads.SQL.Text :=
        'Select * From FIN$PROPOSTA Where PROP_CODIGO = ' + codProposta.ToString;
        qryLeads.Open;
        codigosJaExistente :=qryLeads.IsEmpty;
        qryLeads.Close;
      until (codigosJaExistente);
      //////////////////////////////// Inserir Proposta ////////////////////////////////////////////////
      qryLeads.SQL.Text :=
      ' INSERT INTO FIN$PROPOSTA ( ' +
      '   PROP_CODIGO, ' +
      '   TAB_CODIGO, ' +
      '   CLIT_CODIGO, ' +
      '   PROP_DATA_ABERTURA, ' +
      '   PROP_HORA_ABERTURA, ' +
      '   PROP_FL_CLIENTE_RECEBEU_ORC, ' +
      '   PROP_FL_RECUSADA, ' +
      '   PROP_OBS_IMPORTANTE, ' +
      '   USU_CODIGO, ' +
      '   VEN_CODIGO, ' +
      '   PROP_CONTATO, ' +
      '   PROP_E_MAIL_CONTATO, ' +
      '   PROP_TELEFONE_CONTATO, ' +
      '   PROP_APROVADA, ' +
      '   PROP_FL_PEDIDO_GERADO, ' +
      '   PROP_FL_IMPRESSO_ENTREGA) ' +
      ' VALUES ( ' +
      '   :PROP_CODIGO, ' +
      '   ''1'', ' + //TABELA DE PREÇO
      '   :CLIT_CODIGO, ' +
      '   CURRENT_DATE, ' +
      '   CURRENT_TIME, ' +
      '   ''N'', ' +
      '   ''N'', ' +
      '   :PROP_OBS_IMPORTANTE, ' +
      '   ''1'', ' +//CODIGO DE USUARIO
      '   ''1'', ' + //CODIGO DE VENDEDOR
      '   :PROP_CONTATO, ' +
      '   :PROP_E_MAIL_CONTATO, ' +
      '   :PROP_TELEFONE_CONTATO, ' +
      '   ''N'', ' +
      '   ''N'', ' +
      '   ''N'')';
      qryLeads.ParamByName('PROP_CODIGO').AsInteger  := codProposta;
      qryLeads.ParamByName('CLIT_CODIGO').AsInteger  := codClienteTemporario;
      qryLeads.ParamByName('PROP_OBS_IMPORTANTE').AsString  := '***ORIGEM***: ' + origemLead + ' - ***OBS***: ' + obsLead;
      qryLeads.ParamByName('PROP_CONTATO').AsString  := nomeLead;
      qryLeads.ParamByName('PROP_E_MAIL_CONTATO').AsString  := emailLead;
      qryLeads.ParamByName('PROP_TELEFONE_CONTATO').AsString  := telefoneLead;
      qryLeads.ExecSQL;
      qryLeads.Close;


    finally
      FDConnection.Commit;
      Result := true;
    end;
  except
    on e: exception do
    begin
      FDConnection.Rollback;
      Result := false;
      Error := e.Message;
    end;
  end;
end;

function TServicesProposta.addProspectLog(bodyCompleto: String; out error: String): boolean;
begin
  try
    try
      qryLeads.SQL.Text :=
        'Insert into Log (' +
        ' CD_OPERADOR,' +
        ' DATA,' +
        ' HORA,' +
        ' DESCRICAO,' +
        ' LOG_MAQUINA,' +
        ' LOG_USU_WINDOWS,' +
        ' LOG_NOME_EXE,' +
        ' LOG_VERSAO_SIS' +
        ')' +
        ' Values (' +
        ' 188,' +
        ' Current_date,' +
        ' Current_Time,' +
        ' :DESCRICAO,' +
        ' ''LEADS'', ' +
        ' ''LEADS'', ' +
        ' ''LEADS'', ' +
        ' ''LEADS''  ' +
        ')';
      qryLeads.ParamByName('DESCRICAO').AsString := Trim(Copy(bodyCompleto, 1, 10000));
      qryLeads.ExecSQL;
      qryLeads.Close;
    finally
      FDConnection.Commit;
      Result := true;
    end;
  except
    on e: exception do
    begin
      FDConnection.Rollback;
      Result := false;
      Error := e.Message;
    end;
  end;
end;

end.
