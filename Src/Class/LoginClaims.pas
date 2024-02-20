unit LoginClaims;

interface

uses
  JOSE.Core.JWT,
  JOSE.Core.JWS,
  JOSE.Core.JWK,
  JOSE.Core.JWA,
  JOSE.Types.JSON;

type
  TLoginClaims = class(TJWTClaims)
  private
    function GetInquilino: string;
    procedure SetInquilino(const Value: string);

    function GetTipoUsuario: string;
    procedure SetTipoUsuario(const Value: string);

  public
    property Inquilino: string read GetInquilino write SetInquilino;
    property TipoUsuario: string read GetTipoUsuario write SetTipoUsuario;

  end;

implementation

function TLoginClaims.GetInquilino: string;
begin
  Result := TJSONUtils.GetJSONValue('inquilino', FJSON).AsString;
end;
procedure TLoginClaims.SetInquilino(const Value: string);
begin
  TJSONUtils.SetJSONValueFrom<string>('inquilino', Value, FJSON);
end;

function TLoginClaims.GetTipoUsuario: string;
begin
  Result := TJSONUtils.GetJSONValue('tipoUsuario', FJSON).AsString;
end;
procedure TLoginClaims.SetTipoUsuario(const Value: string);
begin
  TJSONUtils.SetJSONValueFrom<string>('tipoUsuario', Value, FJSON);
end;

end.
