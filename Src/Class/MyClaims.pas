unit MyClaims;

interface

uses
  JOSE.Core.JWT,
  JOSE.Core.JWS,
  JOSE.Core.JWK,
  JOSE.Core.JWA,
  JOSE.Types.JSON;

type
  TMyClaims = class(TJWTClaims)
  private
//    function GetCelular: string;
//    procedure SetCelular(const Value: string);
    function GetComanda: string;
    procedure SetComanda(const Value: string);

    function GetTabPreco: string;
    procedure SetTabPreco(const Value: string);

    function GetEmpresa: string;
    procedure SetEmpresa(const Value: string);
  public
//    property Celular: string read GetCelular write SetCelular;
    property Comanda: string read GetComanda write SetComanda;
    property TabPreco: string read GetTabPreco write SetTabPreco;
    property Empresa: string read GetEmpresa write SetEmpresa;
  end;

implementation

//function TMyClaims.GetCelular: string;
//begin
//  Result := TJSONUtils.GetJSONValue('celular', FJSON).AsString;
//end;
//
//procedure TMyClaims.SetCelular(const Value: string);
//begin
//  TJSONUtils.SetJSONValueFrom<string>('celular', Value, FJSON);
//end;

function TMyClaims.GetComanda: string;
begin
  Result := TJSONUtils.GetJSONValue('comanda', FJSON).AsString;
end;

procedure TMyClaims.SetComanda(const Value: string);
begin
  TJSONUtils.SetJSONValueFrom<string>('comanda', Value, FJSON);
end;
function TMyClaims.GetTabPreco: string;
begin
  Result := TJSONUtils.GetJSONValue('tabpreco', FJSON).AsString;
end;

procedure TMyClaims.SetTabPreco(const Value: string);
begin
  TJSONUtils.SetJSONValueFrom<string>('tabpreco', Value, FJSON);
end;
function TMyClaims.GetEmpresa: string;
begin
  Result := TJSONUtils.GetJSONValue('empresa', FJSON).AsString;
end;

procedure TMyClaims.SetEmpresa(const Value: string);
begin
  TJSONUtils.SetJSONValueFrom<string>('empresa', Value, FJSON);
end;
end.
