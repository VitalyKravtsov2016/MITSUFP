unit ParamList;

interface

uses
  // VCL
  Classes, SysUtils;

type
  { TParamList }

  TParamList = class
  private
    FParams: TStrings;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure Load(Values: IDispatch);
    procedure Save(Values: IDispatch);
    procedure Add(const Name: string; Value: Variant);
    procedure SetValue(const Name: string; Value: Variant);
    function GetValue(const Name: string): Variant;
  end;

implementation

{ TParamList }

constructor TParamList.Create;
begin
  inherited Create;
  FParams := TStringList.Create;
end;

destructor TParamList.Destroy;
begin
  FParams.Free;
  inherited Destroy;
end;

procedure TParamList.Clear;
begin
  FParams.Clear;
end;

function TParamList.GetValue(const Name: string): Variant;
begin
  Result := FParams.Values[Name];
end;

procedure TParamList.Load(Values: IDispatch);
var
  i: Integer;
  Msg: string;
  AName: string;
begin
  for i := 0 to FParams.Count-1 do
  begin
    AName := FParams.Names[i];
    try
      FParams.Values[AName] := Variant(Values).Get(i);
    except
      on E: Exception do
      begin
        Msg := Format('Failed to get value, name=%s', [AName]);
        E.Message := Msg + E.Message;
        raise;
      end;
    end;
  end;
end;

procedure TParamList.Save(Values: IDispatch);
var
  i: Integer;
  Msg: string;
  AName: string;
begin
  for i := 0 to FParams.Count-1 do
  begin
    AName := FParams.Names[i];
    try
      Variant(Values).Set(i, FParams.Values[AName]);
    except
      on E: Exception do
      begin
        Msg := Format('Failed to set value, name=%s', [AName]);
        E.Message := Msg + E.Message;
        raise;
      end;
    end;
  end;
end;

procedure TParamList.Add(const Name: string; Value: Variant);
begin
  FParams.Values[Name] := Value;
end;

procedure TParamList.SetValue(const Name: string; Value: Variant);
begin
  FParams.Values[Name] := Value;
end;

end.
