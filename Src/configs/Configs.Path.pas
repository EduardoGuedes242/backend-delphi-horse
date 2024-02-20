unit Configs.Path;

interface

type
  TConfigPath = record
  private
    function GetPathPhoto: string;
  public
    property PathPhoto: string read GetPathPhoto;
  end;

implementation

uses System.SysUtils;

function TConfigPath.GetPathPhoto: string;
begin
  if DebugHook > 0 then
    Result := 'C:\temp\foto\'
  else
    Result := 'C:\temp\foto\'
end;

end.
