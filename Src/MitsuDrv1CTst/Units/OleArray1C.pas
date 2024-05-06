{Имитатор типа "Массив 1С:Предприятия"}

unit OleArray1C;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  // VCL
  Windows, ComObj, ActiveX, StdVcl,
  // This
  MitsuDrv1CTst_TLB;

type
  { TArray1C }

  TArray1C = class(TAutoObject, IArray1C)
  private
    FData: array[0..50] of OleVariant;
  public
    destructor Destroy; override;
    function Get(Index: Integer): OleVariant; safecall;
    procedure Set_(Index: Integer; Value: OleVariant); safecall;
  end;

implementation

uses ComServ;

destructor TArray1C.Destroy;
begin
  OutputDebugString('TArray1C.Destroy');
  inherited Destroy;
end;

function TArray1C.Get(Index: Integer): OleVariant;
begin
  if Index = 5 then
    Result := string(FData[Index])
  else
  Result := FData[Index];
end;

procedure TArray1C.Set_(Index: Integer; Value: OleVariant);
begin
  if Index = 5 then
    FData[Index] := string(Value)
  else
  FData[Index] := Value;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TArray1C, Class_Array1C,
    ciMultiInstance, tmApartment);
end.
