unit Providers.Authorization;

interface

uses Horse, Horse.JWT, Horse.BasicAuthentication;

function Authorization: THorseCallback;
function AuthorizationV2 : THorseCallback;
function BasicAuthorization: THorseCallback;

implementation

uses Configs.Login, Services.Users, MyClaims, LoginClaims, System.SysUtils;

function DoBasicAuthentication(const Username, Password: string): Boolean;
var
  Users: TServiceUsers;
begin
  try
    Users := TServiceUsers.Create;
    try
      Result := Users.IsValid(Username, Password);
    finally
      Users.Free;
    end;
  except
//    on e:Exception do
//    begin
//      raise Exception.Create(e.Message);
//    end;
  end;
end;
function BasicAuthorization: THorseCallback;
begin
  Result := HorseBasicAuthentication(DoBasicAuthentication);
end;

function Authorization: THorseCallback;
var
  Config: TConfigLogin;
begin
   Result := HorseJWT(Config.Secret,THorseJWTConfig.New.SessionClass(TMyClaims));
end;

function AuthorizationV2: THorseCallback;
var
  Config: TConfigLogin;
begin
   Result := HorseJWT(Config.Secret,THorseJWTConfig.New.SessionClass(TLoginClaims));
end;

end.
