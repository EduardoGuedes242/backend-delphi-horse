unit GlobalController;

interface

uses
  System.SysUtils, System.Classes, Providers.Connection, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Ragna;

  function NextGenerator(FDConnection : TFDConnection; NomeGenerator, CampoCodigo, Tabela : string): string;

implementation

function NextGenerator(FDConnection : TFDConnection; NomeGenerator, CampoCodigo, Tabela : string): string;
var
  Ja_existe: boolean;
  qry : TFDQuery;
  CodigoRetornado : string;
  Conectado : Boolean;
begin
  try
    Conectado := FDConnection.InTransaction;

    if not Conectado then
      FDConnection.StartTransaction;
    qry := TFDQuery.Create(Nil);
    qry.Connection := FDConnection;
    try
      repeat
        qry.SQL.Text :=
          'Select GEN_ID('+ NomeGenerator +', 1) From RDB$DATABASE';
        qry.Open;
        CodigoRetornado := qry.Fields[0].Value;
        qry.Close;

        //Testa se existe esse codigo do contrario pede outro
        qry.SQL.Text :=
          'Select ' + CampoCodigo + ' From ' + Tabela +
          ' Where ' + CampoCodigo + ' = :ID';
        qry.ParamByName('ID').AsInteger := StrToInt(CodigoRetornado);
        qry.Open;

        Ja_existe := qry.IsEmpty;
        qry.Close;

      until (Ja_existe); {Só para de Sujerir novos codigo se o mesmo não existir}

      if Conectado then
        FDConnection.Commit;
      Result := CodigoRetornado;

    finally
      qry.Free;
    end;
  except
    on E: Exception do
    begin
      if FDConnection.InTransaction then
        FDConnection.Rollback;
      Result := 'Erro: ' + E.Message;
      Exit;
    end;
  end;
end;

end.
