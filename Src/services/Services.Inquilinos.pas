unit Services.Inquilinos;

interface

uses
  System.SysUtils, System.Classes, Providers.Connection, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, GlobalController;

type
  TServicesInquilinos = class(TProviderConnection)
    qryInquilinos: TFDQuery;
  private
    { Private declarations }
  public
    { Public declarations }
    function criarInquilino(nome, email : String; out erro, idInquilino : String) : Boolean;
  end;

var
  ServicesInquilinos: TServicesInquilinos;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TServicesInquilinos }

function TServicesInquilinos.criarInquilino(nome, email: String; out erro, idInquilino : String): Boolean;
begin
  try
    try
      idInquilino := NextGenerator(FDConnection, 'INQUILINOS_INQ_ID_GEN1', 'INQ_ID', 'INQUILINOS');

      qryInquilinos.SQL.Text :=
      ' INSERT INTO INQUILINOS' +
      ' (INQ_ID, INQ_NOME, INQ_EMAIL)' +
      ' VALUES' +
      ' (:INQ_ID, :INQ_NOME, :INQ_EMAIL)';
      qryInquilinos.ParamByName('INQ_ID').AsString := idInquilino;
      qryInquilinos.ParamByName('INQ_NOME').AsString := nome;
      qryInquilinos.ParamByName('INQ_EMAIL').AsString := email;
      qryInquilinos.ExecSQL;
    finally
      qryInquilinos.Free;
      Result := True;
    end;
  Except
    on E : Exception do
    begin
      if FDConnection.InTransaction then
        FDConnection.Rollback;
      qryInquilinos.Free;
      Result := false;
      erro := E.Message;
    end;
  end;
end;

end.
