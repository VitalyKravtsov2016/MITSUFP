unit ActiveXControl1C;

interface

uses
  // VCL
  Windows, ActiveX, SysUtils, Variants, Registry, Classes,
  // This
  ComObj, AddIn1CTypes, AddIn1CInterface, LogFile, AxCtrls;

type
  { TActiveXControl1C }

  TActiveXControl1C = class(TActiveXControl, IInitDone, ILanguageExtender)
  private
    FLogger: ILogFile;
    FProps: TAddinProps;
    FMethods: TAddinFuncs;

    function GetLogger: ILogFile;
    function vtToStr(vt: Word):string;
    function GetNParam(var pArray : PSafeArray; lIndex: Integer ): OleVariant;
    procedure UpdateAddinLists;

    property Logger: ILogFile read GetLogger;
    procedure PutNParam(var pArray: PSafeArray; lIndex: Integer; var varPut: OleVariant);
  public
     // IInitDone
    function Init(pConnection: IDispatch): HResult; stdcall;
    function Done: HResult; stdcall;
    function GetInfo(var pInfo: PSafeArray): HResult; stdcall;
    // ILanguageExtender
    function GetNProps(var Count: Integer): HResult; stdcall;
    function GetNMethods(var Count: Integer): HResult; stdcall;
    function RegisterExtensionAs(var ExtensionName: WideString): HResult; stdcall;
    function GetNParams(Index: Integer; var Count: Integer): HResult; stdcall;
    function HasRetVal(Index: Integer; var RetValue: Integer): HResult; stdcall;
    function GetPropVal(Index: Integer; var Value: OleVariant): HResult; stdcall;
    function SetPropVal(Index: Integer; var Value: OleVariant): HResult; stdcall;
    function CallAsProc(Index: Integer; var Params: PSafeArray): HResult; stdcall;
    function IsPropReadable(Index: Integer; var Value: Integer): HResult; stdcall;
    function IsPropWritable(Index: Integer; var Value: Integer): HResult; stdcall;
    function FindProp(const PropName: WideString; var Index: Integer): HResult; stdcall;
    function FindMethod(const MethodName: WideString; var Index: Integer): HResult; stdcall;
    function GetMethodName(Index, Alias: Integer; var MethodName: WideString): HResult; stdcall;
    function GetPropName(Index, Alias: Integer; var PropName: WideString): HResult; stdcall;
    function CallAsFunc(Index: Integer; var RetValue: OleVariant; var Params: PSafeArray): HResult; stdcall;
    function GetParamDefValue(mIndex, pIndex: Integer; var ParamDefValue: OleVariant): HResult; stdcall;
    function SetLocale(bstrLocale: WideString): HResult; stdcall;
    procedure SetLanguage(LangType: string); virtual;
    procedure LogMethods;
  public
    procedure Initialize; override;
    destructor Destroy; override;

    property Props: TAddinProps read FProps;
    property Methods: TAddinFuncs read FMethods;
  end;

implementation

const
  BoolToInt: array[Boolean] of Integer = (0, 1);

{ TActiveXControl1C }

destructor TActiveXControl1C.Destroy;
begin
  Logger.Debug('Destroy');
  FProps.Free;
  FMethods.Free;
  FLogger := nil;
  inherited Destroy;
end;

procedure TActiveXControl1C.UpdateAddinLists;
var
  I, J, k: Integer;
  Prop: TAddinProp;
  Func: TAddinFunc;
  Param: TAddinParam;
  TypeAttr: PTypeAttr;
  TypeInfo: ITypeInfo;
  FuncDesc: PFuncDesc;
  EngName: WideString;
  RusName: WideString;
  pEngName: TBStr;
  pRusName: TBStr;

  pPDEx: PParamDescEx;
  pPD: TParamDesc;
begin
  Logger.Debug('UpdateAddinLists');
  Props.Clear;
  Methods.Clear;
  GetTypeInfo(0, 0, typeInfo);
  if TypeInfo = nil then Exit;
  TypeInfo.GetTypeAttr(TypeAttr);
  try
    for i := 0 to TypeAttr.cFuncs - 1 do
    begin
      TypeInfo.GetFuncDesc(i, FuncDesc);
      try
        pEngName := '';
        pRusName := '';
        if not Succeeded(TypeInfo.GetDocumentation(FuncDesc.memid, @pEngName, @pRusName, nil, nil)) then Continue;
        try
          EngName := OleStrToString(pEngName);
          RusName := UTF8Decode(OleStrToString(pRusName));
        finally
          SysFreeString(pEngName);
          SysFreeString(pRusName);
        end;

        case FuncDesc.invkind of
          INVOKE_PROPERTYGET:
          begin
            Prop := TAddinProp.Create(Props);
            Prop.MemId := FuncDesc.memid;
            Prop.EngName := EngName;
            Prop.RusName := RusName;
            Prop.IsReadable := True;
            Prop.vt := FuncDesc.elemdescFunc.tdesc.vt;
          end;
          INVOKE_FUNC:
          begin
            Func := TAddinFunc.Create(Methods);
            Func.MemId := FuncDesc.memid;
            Func.EngName := EngName;
            Func.RusName := RusName;
//            Logger.Debug(IntToStr(i) + ' ' + Func.RusName + ' ' + Func.EngName);
            Func.retType := FuncDesc.elemdescFunc.tdesc.vt;
            for k := 0 to FuncDesc.cParams-1 do
            begin
              Param := TAddinParam.Create(Func.Params);
              Param.vt := FuncDesc.lprgelemdescParam[k].tdesc.vt;
              Param.isPtr := Param.vt = VT_PTR;
              if Param.isPtr then
                Param.vt := FuncDesc.lprgelemdescParam[k].tdesc.ptdesc.vt;
              Param.wParamFlags := FuncDesc.lprgelemdescParam[k].paramdesc.wParamFlags;
              pPD := FuncDesc.lprgelemdescParam[k].paramdesc;
              if (pPD.wParamFlags and PARAMFLAG_FHASDEFAULT) <> 0 then
              begin
                if pPD.pparamdescex <> nil then
                begin
                  pPDEx := PParamDescEx(pPD.pparamdescex);
                  Param.defVal := pPDEx.varDefaultValue;
                end;
              end;
//              Logger.Debug('ParamCount: ' + IntToStr(Func.Params.Count));
            end;
          end;
        else
          begin
            for j := Props.Count - 1 downto 0 do
            begin
              if Props[j].MemId = FuncDesc.memid then
              begin
                Props[j].IsWritable := True;
                Break;
              end;
            end;
          end;
        end;
      finally
        TypeInfo.ReleaseFuncDesc(FuncDesc);
      end;
    end;
  finally
    TypeInfo.ReleaseTypeAttr(TypeAttr);
  end;
end;

{ ILanguageExtender }

function TActiveXControl1C.RegisterExtensionAs(var ExtensionName: WideString): HResult;
begin
  ExtensionName := Factory.ClassName;
  Result := S_OK;
end;

procedure TActiveXControl1C.PutNParam(var pArray: PSafeArray; lIndex: Integer; var varPut: OleVariant);
begin
  SafeArrayPutElement(pArray,lIndex,varPut);
end;

function TActiveXControl1C.GetNParam(var pArray : PSafeArray; lIndex: Integer ): OleVariant;
var
  varGet : OleVariant;
begin
  SafeArrayGetElement(pArray,lIndex,varGet);
  GetNParam := varGet;
end;

function TActiveXControl1C.vtToStr(vt: Word):string;
begin
  case vt and $FF of
    VT_EMPTY           : Result := 'VT_EMPTY';   { [V]   [P]  nothing                     }
    VT_NULL            : Result := 'VT_NULL';   { [V]        SQL style Null              }
    VT_I2              : Result := 'VT_I2';   { [V][T][P]  2 byte signed int           }
    VT_I4              : Result := 'VT_I4';   { [V][T][P]  4 byte signed int           }
    VT_R4              : Result := 'VT_R4';   { [V][T][P]  4 byte real                 }
    VT_R8              : Result := 'VT_R8';   { [V][T][P]  8 byte real                 }
    VT_CY              : Result := 'VT_CY';   { [V][T][P]  currency                    }
    VT_DATE            : Result := 'VT_DATE';   { [V][T][P]  date                        }
    VT_BSTR            : Result := 'VT_BSTR';   { [V][T][P]  binary string               }
    VT_DISPATCH        : Result := 'VT_DISPATCH';   { [V][T]     IDispatch FAR*              }
    VT_ERROR           : Result := 'VT_ERROR';  { [V][T]     SCODE                       }
    VT_BOOL            : Result := 'VT_BOOL';  { [V][T][P]  True: Result := ''-1, False: Result := ''0            }
    VT_VARIANT         : Result := 'VT_VARIANT';  { [V][T][P]  VARIANT FAR*                }
    VT_UNKNOWN         : Result := 'VT_UNKNOWN';  { [V][T]     IUnknown FAR*               }
    VT_DECIMAL         : Result := 'VT_DECIMAL';  { [V][T]   [S]  16 byte fixed point      }
    VT_I1              : Result := 'VT_I1';  {    [T]     signed char                 }
    VT_UI1             : Result := 'VT_UI1';  {    [T]     unsigned char               }
    VT_UI2             : Result := 'VT_UI2';  {    [T]     unsigned short              }
    VT_UI4             : Result := 'VT_UI4';  {    [T]     unsigned long               }
    VT_I8              : Result := 'VT_I8';  {    [T][P]  signed 64-bit int           }
    VT_UI8             : Result := 'VT_UI8';  {    [T]     unsigned 64-bit int         }
    VT_INT             : Result := 'VT_INT';  {    [T]     signed machine int          }
    VT_UINT            : Result := 'VT_UINT';  {    [T]     unsigned machine int        }
    VT_VOID            : Result := 'VT_VOID';  {    [T]     C style void                }
    VT_HRESULT         : Result := 'VT_HRESULT';  {    [T]                                 }
    VT_PTR             : Result := 'VT_PTR';  {    [T]     pointer type                }
    VT_SAFEARRAY       : Result := 'VT_SAFEARRAY';  {    [T]     (use VT_ARRAY in VARIANT)   }
    VT_CARRAY          : Result := 'VT_CARRAY';  {    [T]     C style array               }
    VT_USERDEFINED     : Result := 'VT_USERDEFINED';  {    [T]     user defined type          }
    VT_LPSTR           : Result := 'VT_LPSTR';  {    [T][P]  null terminated string      }
    VT_LPWSTR          : Result := 'VT_LPWSTR';  {    [T][P]  wide null terminated string }
    VT_FILETIME        : Result := 'VT_FILETIME';  {       [P]  FILETIME                    }
    VT_BLOB            : Result := 'VT_BLOB';  {       [P]  Length prefixed bytes       }
    VT_STREAM          : Result := 'VT_STREAM';  {       [P]  Name of the stream follows  }
    VT_STORAGE         : Result := 'VT_STORAGE';  {       [P]  Name of the storage follows }
    VT_STREAMED_OBJECT : Result := 'VT_STREAMED_OBJECT';  {       [P]  Stream contains an object   }
    VT_STORED_OBJECT   : Result := 'VT_STORED_OBJECT';  {       [P]  Storage contains an object  }
    VT_BLOB_OBJECT     : Result := 'VT_BLOB_OBJECT';  {       [P]  Blob contains an object     }
    VT_CF              : Result := 'VT_CF';  {       [P]  Clipboard format            }
    VT_CLSID           : Result := 'VT_CLSID';  {       [P]  A Class ID                  }
  else
    Result := Format('Unknown type: 0x%.4x',[vt]);
  end;
  case vt and $F000 of
    VT_VECTOR        : Result := 'VT_VECTOR+' + Result; {       [P]  simple counted array        }
    VT_ARRAY         : Result := 'VT_ARRAY+' + Result; { [V]        SAFEARRAY*                  }
    VT_BYREF         : Result := 'VT_BYREF+' + Result; { [V]                                    }
    VT_RESERVED      : Result := 'VT_RESERVED+' + Result;
  end;
end;

function TActiveXControl1C.CallAsFunc(Index: Integer; var RetValue: OleVariant;
  var Params: PSafeArray): HResult;
var
  i: Integer;
  Func: TAddinFunc;
  Param: TAddinParam;
  cElements: Integer;
  DispParams: TDispParams;
  pParams: PVariantArgList;
  p1CParams: PVariantArgList;
  ex: tagEXCEPINFO;
  WS: WideString;
  i4: Integer;
  V: OleVariant;
  PV: OleVariant;
  PVs: string;
  S: string;
begin
  Logger.Debug(Format('%s(%d)', ['TActiveXControl1C.CallAsFunc', Index]));
  pParams := nil;
  cElements := 0;
  FillChar(ex, sizeof(ex), 0);
  SafeArrayLock(Params);

  if Params <> nil then
  begin
    p1CParams := Params.pvData;
    cElements := Params.rgsabound[0].cElements;

    GetMem(pParams, cElements*Sizeof(tagVARIANT));

    Func := Methods[Index];
    S := 'CallAsFunc params (' + IntToStr(cElements) + '):';
    for i := 0 to cElements-1 do
    begin
      PV := GetNParam(Params, i);
      try
        PVs := VarToStr(PV);
      except
        PVs := '';
      end;
      S := Format('%s %s:%s,',[S, vtToStr(p1CParams[i].vt), PVs]);
      Param := Func.params[i];
      if ((Param.wParamFlags and PARAMFLAG_FOUT) <> 0) and // [out] non-VARIANT param
         (Param.vt <> VT_VARIANT) then
      begin
        { По-хорошему надо сделать для всех типов }
        if (p1CParams[i].vt = VT_EMPTY) and (Param.vt = VT_BSTR) then
        begin                      //!!!
          pParams[cElements-1-i].vt := VT_BYREF + VT_BSTR;
          pParams[cElements-1-i].pbstrVal := @WS;
        end
        else
          if (p1CParams[i].vt = VT_EMPTY) and (Param.vt = VT_I4) then
          begin                      //!!!
            pParams[cElements-1-i].vt := VT_BYREF + VT_I4;
            pParams[cElements-1-i].pbstrVal := @i4;
          end
          else
            begin
            // make "typed" BY_REF VARIANT
              pParams[cElements-1-i].vt := VT_BYREF + p1CParams[i].vt;
              // See VARIANTARG and DECIMAL definitions to understand next lines
              if ((pParams[cElements-1-i].vt and VT_DECIMAL) = VT_DECIMAL) then
              begin
                pParams[cElements-1-i].pdecVal := @p1CParams[i].pdecVal;
              end else
              begin
                pParams[cElements-1-i].plVal := @p1CParams[i].lVal;
              end;
            end;
      end
      else
        begin
          // [in] or [out] VARIANT param
          // pass whole VARIANT as BY_REF
          pParams[cElements-1-i].vt := VT_BYREF + VT_VARIANT;
          pParams[cElements-1-i].pvarVal := @p1CParams[i];
        end;
    end;
  end;
  Logger.Debug(Copy(S, 1, Length(S) - 1));
  FillChar(DispParams, SizeOf(DispParams), 0);
  DispParams.rgvarg := pParams;
  DispParams.cArgs := cElements;

  Logger.Debug(Format('%s %s %s', ['Invoke ', Methods[Index].EngName, Methods[Index].RusName]));

  Result := Invoke(
    Methods[Index].MemId,
    GUID_NULL,
    LOCALE_USER_DEFAULT,
    DISPATCH_METHOD,
    DispParams,
    @RetValue,
    @ex,
    nil);

  for i := 0 to cElements - 1 do
  begin
    if pParams[i].vt = VT_BYREF + VT_BSTR then
    begin
      V := pParams[i].pbstrVal^;
      PutNParam(Params, cElements - i - 1, V);
    end;

    if pParams[i].vt = VT_BYREF + VT_I4 then
    begin
      V := pParams[i].plVal^;
      PutNParam(Params, cElements - i - 1, V);
    end;
  end;

  if Methods[Index].retType = VT_BOOL then
    RetValue := WordBool(RetValue);

  Logger.Debug('RetValue:' + vartostr(RetValue));

  if Result = 0 then
    Logger.Debug(Format('Invoke: 0x%.8x (%s)', [Result, SysErrorMessage(Result)]))
  else
    Logger.Error(Format('Invoke: 0x%.8x (%s)', [Result, SysErrorMessage(Result)]));


  SafeArrayUnlock(Params);
  FreeMem(pParams);
end;



function TActiveXControl1C.CallAsProc(Index: Integer; var Params: PSafeArray): HResult;
var
  RetValue: OleVariant;
begin
  RetValue := 0;
  Result := CallAsFunc(Index, RetValue, Params);
  Logger.Debug(Format('TActiveXControl1C.CallAsProc(%d)=%d', [Index, Result]));
end;

function TActiveXControl1C.FindMethod(const MethodName: WideString;
  var Index: Integer): HResult;
var
  S: WideString;
  i: Integer;
  Method: TAddinFunc;
begin
  Index := -1;
  Result := S_FALSE;
  S := MethodName;
  for i := 0 to Methods.Count - 1 do
  begin
    Method := Methods[i];
    if (WideCompareText(Method.EngName, S) = 0) or
      (WideCompareText(Method.RusName, S) = 0) then
    begin
      Index := i;
      Result := S_OK;
      Break;
    end;
  end;
  Logger.Debug(Format('FindMethod(%s, %d)=%d', [MethodName, Index, Result]));
end;

function TActiveXControl1C.FindProp(const PropName: WideString;
  var Index: Integer): HResult;
var
  i: Integer;
  S: WideString;
  Prop: TAddinProp;
begin
  Index := -1;
  Result := S_FALSE;
  S := PropName;
  for i := 0 to Props.Count - 1 do
  begin
    Prop := Props[i];
    if (WideCompareText(Prop.EngName, S) = 0) or
      (WideCompareText(Prop.RusName, S) = 0) then
    begin
      Index := i;
      Result := S_OK;
      Break;
    end;
  end;
  Logger.Debug(Format('FindProp(%s, %d)=%d', [PropName, Index, Result]));
end;

function TActiveXControl1C.GetMethodName(Index, Alias: Integer;
  var MethodName: WideString): HResult;
begin
  if (Index >= 0) and (Index < Methods.Count) then
  begin
    case Alias of
      0: MethodName := Methods[Index].EngName;
    else
      MethodName := Methods[Index].RusName;
    end;
    Result := S_OK;
  end
  else begin
    MethodName := '';
    Result := S_FALSE;
  end;
  Logger.Debug(Format('TActiveXControl1C.GetMethodName(%d,%d,%s)=%d',
    [Index, Alias, MethodName, Result]));
end;

function TActiveXControl1C.GetNMethods(var Count: Integer): HResult;
begin
  Logger.Debug('TActiveXControl1C.GetNMethods');

  Count := Methods.Count;
  Result := S_OK;
  Logger.Debug(Format('TActiveXControl1C.GetNMethods(%d)=%d', [Count, Result]));
end;

{******************************************************************************}
{
{  Для нового стандарта 1С используются методы с параметрами
{
{******************************************************************************}

function TActiveXControl1C.GetNParams(Index: Integer; var Count: Integer): HResult;
begin
  Logger.Debug('TActiveXControl1C.GetNParams');
  Result := S_FALSE;
  if (Index >= 0) and (Index < Methods.Count) then
  begin
    Count := Methods[Index].Params.Count;
    Result := S_OK;
  end;
  Logger.Debug(Format('TActiveXControl1C.GetNParams(%d, %d)=%d', [Index, Count, Result]));
end;

{ Количество свойств }

function TActiveXControl1C.GetNProps(var Count: Integer): HResult;
begin
  Logger.Debug('TActiveXControl1C.GetNProps');

  Count := Props.Count;
  Result := S_OK;
  Logger.Debug(Format('TActiveXControl1C.GetNProps(%d)=%d', [Count, Result]));
end;

function TActiveXControl1C.GetParamDefValue(mIndex, pIndex: Integer;
  var ParamDefValue: OleVariant): HResult;
var
  Func: TAddinFunc;
  //Param: TAddinParam;
begin
  Logger.Debug('TActiveXControl1C.GetParamDefValue');
  if Methods.ValidIndex(mIndex) then
  begin
    Func := Methods[mIndex];
    if Func.Params.ValidIndex(pIndex) then
    begin
      // Param := Func.Params[pIndex];
      //ParamDefValue := Param.DefVal; { !!! }
    end;
  end;
  Result := S_OK;
end;

function TActiveXControl1C.GetPropName(Index, Alias: Integer;
  var PropName: WideString): HResult;
begin
  Logger.Debug('TActiveXControl1C.GetPropName');
  if (Index >= 0) and (Index < Props.Count) then
  begin
    case Alias of
      0: PropName := Props[Index].EngName;
    else
      PropName := Props[Index].RusName;
    end;
    Result := S_OK;
  end
  else begin
    PropName := '';
    Result := S_FALSE;
  end;
end;

{ Получение значения свойства }

function TActiveXControl1C.GetPropVal(Index: Integer; var Value: OleVariant): HResult;
var
  DispParams: TDispParams;
begin
  Logger.Debug('TActiveXControl1C.GetPropVal');

  VarClear(Value);
  FillChar(DispParams, SizeOf(DispParams), 0);
  Result := Invoke(Props[Index].MemId, GUID_NULL,
    0, DISPATCH_PROPERTYGET, DispParams, @Value,
    nil, nil);

  // Свойства BOOL преобразуются в Integer
  if Props[Index].vt = VT_BOOL then
    Value := BoolToInt[Boolean(Value)];
  // Свойства CURRENCY преобразуются в Double
  if Props[Index].vt = VT_CY then
    Value := Double(Value);
end;

{ Все методы возвращают значения }

function TActiveXControl1C.HasRetVal(Index: Integer; var RetValue: Integer): HResult;
begin
  Logger.Debug('TActiveXControl1C.HasRetVal');
  if Methods.ValidIndex(Index) then
    RetValue := BoolToInt[Methods[Index].retType <> VT_VOID];
  Result := S_OK;
end;

{ Читается ли свойство }

function TActiveXControl1C.IsPropReadable(Index: Integer; var Value: Integer): HResult;
begin
  Logger.Debug('TActiveXControl1C.IsPropReadable');
  Result := S_FALSE;
  if (Index >= 0) and (Index < Props.Count) then
  begin
    Value := BoolToInt[Props[Index].IsReadable];
    Result := S_OK;
  end;
end;

{ Записывается ли свойство }

function TActiveXControl1C.IsPropWritable(Index: Integer; var Value: Integer): HResult;
begin
  Logger.Debug('TActiveXControl1C.IsPropWritable');
  Result := S_FALSE;
  if (Index >= 0) and (Index < Props.Count) then
  begin
    Value := BoolToInt[Props[Index].IsWritable];
    Result := S_OK;
  end;
end;

{ Запись свойства }

const
  DispIDArgs: Longint = DISPID_PROPERTYPUT;

function TActiveXControl1C.SetPropVal(Index: Integer; var Value: OleVariant): HResult;
var
  DispParams: TDispParams;
begin
  Logger.Debug('TActiveXControl1C.SetPropVal');
  with DispParams do
  begin
    rgvarg := @Value;
    rgdispidNamedArgs := @DispIDArgs;
    cArgs := 1;
    cNamedArgs := 1;
  end;
  Result := Invoke(Props[Index].MemId, GUID_NULL, 0,
    DISPATCH_PROPERTYPUT, DispParams, nil, nil, nil);
end;

function TActiveXControl1C.GetLogger: ILogFile;
begin
  if FLogger = nil then
  begin
    FLogger := TLogFile.Create;
    FLogger.FilePath := 'C:\';
    FLogger.FileName := 'v8napi.log';
    FLogger.Enabled := True;

  end;
  Result := FLogger;
end;

// IInitDone

function TActiveXControl1C.Init(pConnection: IDispatch): HResult;
begin
  Result := S_OK;
end;

function TActiveXControl1C.Done: HResult;
begin
  Result := S_OK;
end;

function TActiveXControl1C.GetInfo(var pInfo: PSafeArray): HResult;
var
  Index: Integer;
  Value: OleVariant;
begin
  Index := 0;
  Value := '1000';
  SafeArrayPutElement(pInfo, Index, Value);
  Result := S_OK;
end;

procedure TActiveXControl1C.Initialize;
begin
  Logger.Debug('Initialize');
  inherited Initialize;
  FProps := TAddinProps.Create;
  FMethods := TAddinFuncs.Create;
  UpdateAddinLists;
//  LogMethods;
end;

function TActiveXControl1C.SetLocale(bstrLocale: WideString): HResult;
begin
  Result := S_OK;
  SetLanguage(bstrLocale);
end;

procedure TActiveXControl1C.SetLanguage(LangType: string);
begin

end;

procedure TActiveXControl1C.LogMethods;
var
  i: Integer;
  FP: TStringList;
  FM: TStringList;
  R: string;
begin
  FP := TStringList.Create;
  FM := TStringList.Create;
  try
    for i := 0 to Props.Count - 1 do
    begin
      FP.Add(Props[i].EngName);
      FP.Add(Props[i].RusName);
      case Props[i].vt of
        VT_I4: FP.Add('Тип: Integer / Целое');
        VT_DATE: FP.Add('Тип: Datetime / ДатаВремя');
        VT_BSTR: FP.Add('Тип: String / Строка');
        VT_BOOL: FP.Add('Тип: WordBool / Логическое');
        VT_CY: FP.Add('Тип: Currency / Денежный');
      end;
      R := '';
      if Props[i].IsReadable then R := R + 'R';
      if Props[i].IsWritable then R := R + 'W';
      FP.Add('Доступ: ' + R);
      FP.Add('');
      FP.Add('');
      FP.Add('-------------------------');
    end;

    for i := 0 to Methods.Count - 1 do
    begin
      FM.Add(Methods[i].EngName);
      FM.Add(Methods[i].RusName);
      FM.Add('');
      FM.Add('Используемые свойства');
      FM.Add('');
      FM.Add('Модифицируемые свойства');
      FM.Add('');
      FM.Add('-------------------------');
    end;

    FP.SaveToFile('c:\drvProps.txt');
    FM.SaveToFile('c:\drvMeth.txt');
  finally
    FP.Free;
    FM.Free;
  end

end;

end.



