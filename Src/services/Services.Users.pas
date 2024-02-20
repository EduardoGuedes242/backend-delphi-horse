unit Services.Users;
interface
uses System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.ConsoleUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, Ragna, System.Hash, System.JSON, Providers.Connection, FireDAC.VCLUI.Wait,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, StrUtils, Controllers.Login;
type
  TServiceUsers = class(TProviderConnection)
    Users: TFDQuery;
    UsersID: TLargeintField;
    UsersUSERNAME: TStringField;
    UsersNAME: TStringField;
    UsersPASS: TStringField;
    Query: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    function IsValid(Username, Password: string): Boolean;
    function ValidateFieldsInsert(User: TJSONObject): boolean;
    function Post(User: TJSONObject): TFDQuery;
    function Get: TFDQuery;
    function Login(email, senha : string; out erro, inquilino, tipoUsuario : string): Boolean;
    function cadastrarUsuario(inquilino_inq, nome, email, senha, tipoUsuario : string; out erro : string): Boolean;
  end;

implementation

uses Providers.Encrypt;

{$R *.dfm}

procedure TServiceUsers.DataModuleCreate(Sender: TObject);
begin
  inherited;
  Users.Active := true;
end;

function TServiceUsers.Get: TFDQuery;
begin
  UsersPASS.Visible := False;
  Result := Users.OpenUp;
end;

function TServiceUsers.IsValid(Username, Password: string): Boolean;
begin
  try
    Result := not
    Users.
    Where(UsersUSERNAME).
    Equals(Username).
    &And(UsersPass).
    Equals(TProviderEncrypt.Encrypt(Password)).
    OpenUp.
    IsEmpty;
  except
//    on e:Exception do
//    begin
//      raise Exception.Create(e.Message);
//    end;
  end;
end;

function TServiceUsers.Post(User: TJSONObject): TFDQuery;
var
  Password: string;
begin
  Password := TProviderEncrypt.Encrypt(User.GetValue<string>('pass'));
  User.RemovePair('pass').Free;
  User.AddPair('pass', Password);
  Users.New(User).OpenUp;
  UsersPASS.Visible := False;
  Result := Users;
end;

function TServiceUsers.ValidateFieldsInsert(User: TJSONObject): boolean;
var
  username:string;
begin
  username := User.GetValue<string>('username');
  Result := Users.Where(UsersUSERNAME).Equals(username).OpenUp.IsEmpty;
end;


function Codifica(Action, Src: string): string;
label Fim; //Função para criptografar e descriptografar string's
var
  KeyLen: Integer;
  KeyPos: Integer;
  OffSet: Integer;
  Dest, Key: string;
  SrcPos: Integer;
  SrcAsc: Integer;
  TmpSrcAsc: Integer;
  Range: Integer;
begin
  try
    if (Src = '') then
    begin
      Result := '';
      goto Fim;
    end;
    Key := 'YUQL23KL23DF90WI5E1JAS467NMCXXL6JAOAUWWMCL0AOMM4A4VZYW9KHJUI2347EJHJKDF3424SKL K3LAKDJSL9RTIKJ';
    Dest := '';
    KeyLen := Length(Key);
    KeyPos := 0;
    SrcPos := 0;
    SrcAsc := 0;
    Range := 256;
    if (Action = UpperCase('C')) then
    begin
      Randomize;
      OffSet := Random(Range);
      Dest := Format('%1.2x', [OffSet]);
      for SrcPos := 1 to Length(Src) do
      begin
        SrcAsc := (Ord(Src[SrcPos]) + OffSet) mod 255;
        if KeyPos < KeyLen then KeyPos := KeyPos + 1 else KeyPos := 1;
        SrcAsc := SrcAsc xor Ord(Key[KeyPos]);
        Dest := Dest + Format('%1.2x', [SrcAsc]);
        OffSet := SrcAsc;
      end;
    end
    else if (Action = UpperCase('D')) then
    begin
      OffSet := StrToIntDef('$' + copy(Src, 1, 2), 0);
      SrcPos := 3;
      repeat
        SrcAsc := StrToIntDef('$' + copy(Src, SrcPos, 2), 0);
        if (KeyPos < KeyLen) then KeyPos := KeyPos + 1 else KeyPos := 1;
        TmpSrcAsc := SrcAsc xor Ord(Key[KeyPos]);
        if TmpSrcAsc <= OffSet then TmpSrcAsc := 255 + TmpSrcAsc - OffSet
        else TmpSrcAsc := TmpSrcAsc - OffSet;
        Dest := Dest + Chr(TmpSrcAsc);
        OffSet := SrcAsc;
        SrcPos := SrcPos + 2;
      until (SrcPos >= Length(Src));
    end;
    Result := Dest;
    Fim:
  except
    Src := '';
    Result := '';
  end;

end;

function TServiceUsers.Login(email, senha : string; out erro, inquilino, tipoUsuario : string): Boolean;
var
  SenhaRetornada : String;
begin
  try
    Query.SQL.text :=
    ' SELECT * FROM USUARIOS' +
    ' WHERE USUARIOS.USU_EMAIL = ''' + email.ToUpper + ''' ';
    Query.OpenUp;
    if Query.IsEmpty then
    begin
      erro := 'Informações de Login ou CNPJ inccoretas!';
      result := false;
    end else
    begin
      SenhaRetornada := Query.FieldByName('USU_SENHA').AsString;
      if SenhaRetornada <> Senha then
      begin
        erro := 'Login ou Senha Incorretos';
        result := false;
      end else
      begin
        inquilino := Query.FieldByName('INQ_ID').AsString;
        tipoUsuario := Query.FieldByName('USU_TIPO').AsString;
        result := True;
      end;
    end;
    Query.Connection.Commit;
  Except
    on E : Exception do
    begin
      Erro := 'Erro para pegar o usuário: ' + E.Message;
      Query.Connection.Rollback;
      Result := False;
    end;
  end;
end;

function TServiceUsers.cadastrarUsuario(inquilino_inq, nome, email, senha, tipoUsuario : string; out erro : string): Boolean;
begin
  try
    try
      Query.SQL.text :=
      ' INSERT INTO USUARIOS '+
      ' (INQ_ID, '+
      ' USU_NOME, '+
      ' USU_EMAIL, '+
      ' USU_SENHA, '+
      ' USU_TIPO) VALUES '+
      ' (:INQ_ID, '+
      ' :USU_NOME, '+
      ' :USU_EMAIL, '+
      ' :USU_SENHA, '+
      ' :USU_TIPO); ';
      Query.ParamByName('INQ_ID').AsString := inquilino_inq;
      Query.ParamByName('USU_NOME').AsString := nome;
      Query.ParamByName('USU_EMAIL').AsString := email;
      Query.ParamByName('USU_SENHA').AsString := senha;
      Query.ParamByName('USU_TIPO').AsString := tipoUsuario;
      Query.ExecSQL;
    finally
      Query.Free;
      Result := True;
    end;


  Except
    on E : Exception do
    begin
      Erro := 'Erro para cadastrar o usuário: ' + E.Message;
      Query.Connection.Rollback;
      Result := False;
    end;
  end;
end;


end.
