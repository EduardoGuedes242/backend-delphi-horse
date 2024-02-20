unit Controllers.Users;
interface
procedure Registry;
implementation
uses Horse, System.JSON, Ragna, Providers.Authorization, Services.Users;
procedure DoGetUsers(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Users: TServiceUsers;
begin
  Users := TServiceUsers.Create;
  try
    Res.Send(Users.Get.ToJSONArray());
  finally
    Users.Free;
  end;
end;
procedure DoPostUser(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Users: TServiceUsers;
  obj:tJSONObject;
begin
  Users := TServiceUsers.Create;
  try
    obj := tJSONObject.Create;
    if Users.ValidateFieldsInsert(Req.Body<TJSONObject>) then
    begin
      obj := Users.Post(Req.Body<TJSONObject>).ToJSONObject();
      Res.Send(obj).Status(THTTPStatus.Created);
    end
    else
    begin
      Res.Send(obj.AddPair('message','Este username já está me uso')).Status(THTTPStatus.Conflict);
    end;
  finally
    Users.Free;
    //obj.Free;
  end;
end;
procedure Registry;
begin
  THorse.AddCallback(Authorization()).Get('/users', DoGetUsers);
  THorse.AddCallback(Authorization()).Post('/users', DoPostUser);
end;
end.
