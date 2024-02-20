unit Configs.Login;

interface

type
  TConfigLogin = record
  private
    function GetExpires: Integer;
    function GetSecret: string;
  public
    property Expires: Integer read GetExpires;
    property Secret: string read GetSecret;
  end;

implementation

uses System.SysUtils;

function TConfigLogin.GetExpires: Integer;
begin
  Result := 8;
end;

function TConfigLogin.GetSecret: string;
begin
  Result := 'fHD4367*HDgyugyg¨%$756jvjhVhguq-4um67w8943-698=%$#@%$#$&';
end;

end.
