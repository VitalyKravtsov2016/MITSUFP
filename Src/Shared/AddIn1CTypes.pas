unit AddIn1CTypes;

interface

uses
  // VCL
  Windows, Classes, SysUtils, ActiveX;

type
  TAddinProp = class;
  TAddinFunc = class;
  TAddinParam = class;
  TAddinParams = class;

  { TAddinProps }

  TAddinProps = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TAddinProp;
    procedure InsertItem(AItem: TAddinProp);
    procedure RemoveItem(AItem: TAddinProp);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function ValidIndex(Index: Integer): Boolean;
    function ItemByEngName(const Value: string): TAddinProp;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TAddinProp read GetItem; default;
  end;

  { TAddinProp }

  TAddinProp = class
  private
    FOwner: TAddinProps;
    procedure SetOwner(AOwner: TAddinProps);
  public
    MemId: Integer;
    EngName: WideString;
    RusName: WideString;
    IsReadable: Boolean;
    IsWritable: Boolean;
    vt: DWORD;
    constructor Create(AOwner: TAddinProps);
    destructor Destroy; override;
  end;

  { TAddinFuncs }

  TAddinFuncs = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TAddinFunc;
    procedure InsertItem(AItem: TAddinFunc);
    procedure RemoveItem(AItem: TAddinFunc);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function ValidIndex(Index: Integer): Boolean;
    function ItemByEngName(const Value: string): TAddinFunc;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TAddinFunc read GetItem; default;
  end;

  { TAddinFunc }

  TAddinFunc = class
  private
    FOwner: TAddinFuncs;
    FParams: TAddinParams;
    procedure SetOwner(AOwner: TAddinFuncs);
  public
    MemId: Integer;
    EngName: WideString;
    RusName: WideString;
    IsReadable: Boolean;
    IsWritable: Boolean;
    vt: DWORD;
    retType: DWORD;
    
    constructor Create(AOwner: TAddinFuncs);
    destructor Destroy; override;
    property Params: TAddinParams read FParams;
  end;

  { TAddinParams }

  TAddinParams = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TAddinParam;
    procedure InsertItem(AItem: TAddinParam);
    procedure RemoveItem(AItem: TAddinParam);
  public
    constructor Create;
    destructor Destroy; override;
    function ValidIndex(Index: Integer): Boolean;
    procedure Clear;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TAddinParam read GetItem; default;
  end;

  { TAddinParam }

  TAddinParam = class
  private
    FOwner: TAddinParams;
    procedure SetOwner(AOwner: TAddinParams);
  public
    vt: DWORD;
    isPtr: Boolean;
    DefVal: TVariantArg;
    wParamFlags: DWORD; // copy of PARAMDESC.wParamFlags

    constructor Create(AOwner: TAddinParams);
    destructor Destroy; override;
  end;

implementation

{ TAddinProps }

constructor TAddinProps.Create;
begin
  Inherited Create;
  FList := TList.Create;
end;

destructor TAddinProps.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TAddinProps.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TAddinProps.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TAddinProps.GetItem(Index: Integer): TAddinProp;
begin
  Result := FList[Index];
end;

procedure TAddinProps.InsertItem(AItem: TAddinProp);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TAddinProps.RemoveItem(AItem: TAddinProp);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TAddinProps.ValidIndex(Index: Integer): Boolean;
begin
  Result := (Index >= 0)and(Index < Count);
end;

function TAddinProps.ItemByEngName(const Value: string): TAddinProp;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := Items[i];
    if AnsiCompareText(Result.EngName, Value) = 0 then Exit;
  end;
  Result := nil;
end;

{ TAddinProp }

constructor TAddinProp.Create(AOwner: TAddinProps);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TAddinProp.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TAddinProp.SetOwner(AOwner: TAddinProps);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

{ TAddinFuncs }

constructor TAddinFuncs.Create;
begin
  Inherited Create;
  FList := TList.Create;
end;

destructor TAddinFuncs.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TAddinFuncs.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TAddinFuncs.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TAddinFuncs.GetItem(Index: Integer): TAddinFunc;
begin
  Result := FList[Index];
end;

procedure TAddinFuncs.InsertItem(AItem: TAddinFunc);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TAddinFuncs.RemoveItem(AItem: TAddinFunc);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TAddinFuncs.ItemByEngName(const Value: string): TAddinFunc;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := Items[i];
    if AnsiCompareText(Result.EngName, Value) = 0 then Exit;
  end;
  Result := nil;
end;

function TAddinFuncs.ValidIndex(Index: Integer): Boolean;
begin
  Result := (Index >= 0)and(Index < Count);
end;


{ TAddinFunc }

constructor TAddinFunc.Create(AOwner: TAddinFuncs);
begin
  inherited Create;
  SetOwner(AOwner);
  FParams := TAddinParams.Create;
end;

destructor TAddinFunc.Destroy;
begin
  SetOwner(nil);
  FParams.Free;
  inherited Destroy;
end;

procedure TAddinFunc.SetOwner(AOwner: TAddinFuncs);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

{ TAddinParams }

constructor TAddinParams.Create;
begin
  Inherited Create;
  FList := TList.Create;
end;

destructor TAddinParams.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TAddinParams.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TAddinParams.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TAddinParams.GetItem(Index: Integer): TAddinParam;
begin
  Result := FList[Index];
end;

procedure TAddinParams.InsertItem(AItem: TAddinParam);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TAddinParams.RemoveItem(AItem: TAddinParam);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TAddinParams.ValidIndex(Index: Integer): Boolean;
begin
  Result := (Index >= 0)and(Index < Count);
end;

{ TAddinParam }

constructor TAddinParam.Create(AOwner: TAddinParams);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TAddinParam.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TAddinParam.SetOwner(AOwner: TAddinParams);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;


end.
