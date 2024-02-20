unit Providers.Connection;
interface
uses System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.ConsoleUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, System.IniFiles;
type
  TProviderConnection = class(TDataModule)
    FDConnection: TFDConnection;
    procedure FDConnectionBeforeConnect(Sender: TObject);
    function GetDLLPath: string;
  public
    constructor Create; reintroduce;
  end;
var
  ProviderConnection: TProviderConnection;
implementation

uses
  Winapi.Windows, FireDAC.Phys.IBWrapper;
{$R *.dfm}
constructor TProviderConnection.Create;
begin
  inherited Create(nil);
end;

function TProviderConnection.GetDLLPath: string;
var
  buffer: array[0..MAX_PATH] of Char;
begin
  SetString(Result, buffer, GetModuleFileName(HInstance, buffer, Length(buffer)));
end;

procedure TProviderConnection.FDConnectionBeforeConnect(Sender: TObject);
var
  Params: TFDPhysFBConnectionDefParams;
  ArqINI: TIniFile;
  hFile: THandle;
  PATH, local:STRING;
begin
  Params := TFDPhysFBConnectionDefParams(FDConnection.Params);
  {$IFDEF EXE}
  PATH := ExtractFilePath(ParamStr(0))+'InforvixApiRest.ini';
  {$ELSE}
  PATH := GetDLLPath;
  PATH := PATH.Replace('.dll','.ini');
  {$ENDIF}

  ArqINI := TIniFile.Create(PATH);
  //raise Exception.Create(PATH);
  local := ArqINI.ReadString('BANCO DE DADOS', 'LOCAL', 'S');
  if local[1] = 'S' then
    Params.Protocol := TIBProtocol.ipLocal
  else
    //Params.Protocol := TIBProtocol.ipTCPIP;
    //Params.Server := ArqINI.ReadString('BANCO DE DADOS', 'IP_SERVIDOR', '');
    //Params.Database := ArqINI.ReadString('BANCO DE DADOS', 'PATH_SERVIDOR', '');
  //raise Exception.Create(Params.Database);
    //Params.UserName :=ArqINI.ReadString('BANCO DE DADOS', 'USERNAME', '');
    //Params.Password := ArqINI.ReadString('BANCO DE DADOS', 'PASSWORD', '');
          Params.Protocol := TIBProtocol.ipLocal;
          Params.Server   := 'localhost';
          Params.Database := 'C:\Projetos\ekl-agenda\dados\EKL-AGENDA.GDB';
          //Params.Database := 'C:\projects\dados\EKL-AGENDA.GDB';
          Params.UserName := 'SYSDBA';
          Params.Password := 'masterkey';
          Params.Port := 3050;
    ArqINI.Free;

end;
end.
