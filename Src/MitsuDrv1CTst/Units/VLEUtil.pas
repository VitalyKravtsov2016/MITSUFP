unit VLEUtil;

interface

uses
  // VCL
  Windows, SysUtils, Graphics, ValEdit, Grids, Classes;

procedure VLE_SETPickPropertyValue(AVLE: TValueListEditor; AName: string; AValue: Integer);
function VLE_GetPickPropertyValue(AVLE: TValueListEditor; AName: string): Integer;
function VLE_GetPropertyValue(AVLE: TValueListEditor; AName: string): string;
procedure VLE_AddProperty(AVLE: TValueListEditor; AName: string; AValueDef: string);
procedure VLE_AddPickProperty(AVLE: TValueListEditor; AName: string; AValueDef: string;
  APickItemNames: array of string; APickItemValues: array of Integer);
procedure VLE_AddSeparator(AVLE: TValueListEditor; AName: string);
procedure VLE_SetPropertyValue(AVLE: TValueListEditor; AName: string; AValue: string);
procedure VLE_DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
function VLEParamsToString(AVLE: TValueListEditor): string;
procedure StringToVLEParams(AVLE: TValueListEditor; AStr: string);

implementation

procedure VLE_AddPickProperty(AVLE: TValueListEditor; AName: string; AValueDef: string;
  APickItemNames: array of string; APickItemValues: array of Integer);
var
  i: Integer;
begin
  if not Assigned(AVLE) then
    Exit;
  AVLE.InsertRow(AName, AValueDef, True);
  if High(APickItemNames) = 0 then
    Exit;
  if High(APickItemNames) <> High(APickItemValues) then
    Exit;
  for i := 0 to High(APickItemnames) do
  begin
    AVLE.ItemProps[AName].EditStyle := esPickList;
    AVLE.ItemProps[AName].ReadOnly := True;
    AVLE.ItemProps[AName].PickList.AddObject(APickItemNames[i],
      TObject(APickItemValues[i]));
  end;
end;

procedure VLE_AddProperty(AVLE: TValueListEditor; AName: string; AValueDef: string);
begin
  VLE_AddPickProperty(AVLE, AName, AValueDef, [], []);
end;

function VLE_GetPropertyValue(AVLE: TValueListEditor; AName: string): string;
begin
  Result := AVLE.Values[AName];
end;

function VLE_GetPickPropertyValue(AVLE: TValueListEditor; AName: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to AVLE.ItemProps[AName].PickList.Count - 1 do
    if AVLE.ItemProps[AName].PickList.Strings[i] = AVLE.Values[AName] then
    begin
      Result := Integer(AVLE.ItemProps[AName].PickList.Objects[i]);
      Break;
    end;
end;

procedure VLE_SetPropertyValue(AVLE: TValueListEditor; AName: string; AValue: string);
begin
  AVLE.Values[AName] := AValue;
end;

procedure VLE_SETPickPropertyValue(AVLE: TValueListEditor; AName: string; AValue: Integer);
var
  i: Integer;
begin
  for i := 0 to AVLE.ItemProps[AName].PickList.Count - 1 do
    if Integer(AVLE.ItemProps[AName].PickList.Objects[i]) = AValue then
    begin
      AVLE.Values[AName] := AVLE.ItemProps[AName].PickList.Strings[i];
      Break;
    end;
end;

procedure VLE_AddSeparator(AVLE: TValueListEditor; AName: string);
begin
   AVLE.InsertRow('|;separator;|' + AName, '', True);
   AVLE.ItemProps['|;separator;|' + AName].ReadOnly := True;
end;

procedure VLE_DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  HT: Integer;
  HR: Integer;
  s: string;
  VLE: TValueListEditor;
begin
  if Sender is TValueListEditor then
    VLE := TValueListEditor(Sender)
  else
    Exit;

  if Pos('|;separator;|', VLE.Cells[ACol, ARow]) > 0 then
  begin
    VLE.Canvas.Brush.Color := VLE.Canvas.Pen.Color;
    VLE.Canvas.Rectangle(Rect);
    VLE.Canvas.Font.Style := [fsBold];
    HR := Rect.Bottom - Rect.Top;
    HT := VLE.Canvas.TextHeight(VLE.Cells[ACol, ARow]);
    s := VLE.Cells[ACol, ARow];
    Delete(s, 1, 13);
    VLE.Canvas.TextOut(Rect.Left + 10, Rect.Top + (HR-HT) div 2, s);
  end;
end;

function VLEParamsToString(AVLE: TValueListEditor): string;
var
  i: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    for i := 1 to AVLE.RowCount - 1 do
      SL.Add(AVLE.Cells[1, i]);
    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

procedure StringToVLEParams(AVLE: TValueListEditor; AStr: string);
var
  i: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  SL.Text := AStr;
  try
    if SL.Count <> (AVLE.RowCount - 1) then Exit;
    for i := 1 to AVLE.RowCount - 1 do
    begin
      AVLE.Cells[1, i] := SL[i - 1];
    end;
  finally
    SL.Free;
  end;
end;

end.


