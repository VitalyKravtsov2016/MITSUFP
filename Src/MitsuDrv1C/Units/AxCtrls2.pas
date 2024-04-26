{*******************************************************}
{                                                       }
{       Borland Delphi Visual Component Library         }
{       ActiveX Controls Unit                           }
{                                                       }
{  Copyright (c) 1995-2001 Borland Software Corporation }
{                                                       }
{*******************************************************}

unit AxCtrls2;

{$WARN SYMBOL_PLATFORM OFF}

{$T-,H+,X+}

interface

uses
  Variants, Windows, Messages, ActiveX, SysUtils, {$IFDEF LINUX} WinUtils, {$ENDIF}
  ComObj2, Classes, Graphics, Controls, Forms, ExtCtrls, StdVCL, AxCtrls;

type
  TConnectionPoints2 = class;

  TConnectionPoint2 = class(TContainedObject, IConnectionPoint)
  private
    FContainer: TConnectionPoints2;
    FIID: TGUID;
    FSinkList: TList;
    FOnConnect: TConnectEvent;
    FKind: TConnectionKind;
    function AddSink(const Sink: IUnknown): Integer;
    procedure RemoveSink(Cookie: Longint);
  protected
    { IConnectionPoint }
    function GetConnectionInterface(out iid: TIID): HResult; stdcall;
    function GetConnectionPointContainer(
      out cpc: IConnectionPointContainer): HResult; stdcall;
    function Advise(const unkSink: IUnknown; out dwCookie: Longint): HResult; stdcall;
    function Unadvise(dwCookie: Longint): HResult; stdcall;
    function EnumConnections(out enumconn: IEnumConnections): HResult; stdcall;
  public
    constructor Create(Container: TConnectionPoints2;
      const IID: TGUID; Kind: TConnectionKind; OnConnect: TConnectEvent);
    property SinkList : TList read FSinkList;
    destructor Destroy; override;
  end;

  TConnectionPoints2 = class{IConnectionPointContainer}
  private
    FController: Pointer;  // weak ref to controller - don't keep it alive
    FConnectionPoints: TList;
    function GetController: IUnknown;
  protected
    { IConnectionPointContainer }
    function EnumConnectionPoints(
      out enumconn: IEnumConnectionPoints): HResult; stdcall;
    function FindConnectionPoint(const iid: TIID;
      out cp: IConnectionPoint): HResult; stdcall;
  public
    constructor Create(const AController: IUnknown);
    destructor Destroy; override;
    function CreateConnectionPoint(const IID: TGUID; Kind: TConnectionKind;
      OnConnect: TConnectEvent): TConnectionPoint2;
    property Controller: IUnknown read GetController;
  end;

  TActiveXControlFactory2 = class;

  TActiveXControl2 = class(TAutoObject,
    IConnectionPointContainer,
    IDataObject,
    IObjectSafety,
    IOleControl,
    IOleInPlaceActiveObject,
    IOleInPlaceObject,
    IOleObject,
    IPerPropertyBrowsing,
    IPersistPropertyBag,
    IPersistStorage,
    IPersistStreamInit,
    IQuickActivate,
    ISimpleFrameSite,
    ISpecifyPropertyPages,
    IViewObject,
    IViewObject2)

  private
    FControlFactory: TActiveXControlFactory2;
    FConnectionPoints: TConnectionPoints2;
    FPropertySinks: TConnectionPoint2;
    FObjectSafetyFlags: DWORD;
    FOleClientSite: IOleClientSite;
    FOleControlSite: IOleControlSite;
    FSimpleFrameSite: ISimpleFrameSite;
    FAmbientDispatch: IAmbientDispatch;
    FOleInPlaceSite: IOleInPlaceSite;
    FOleInPlaceFrame: IOleInPlaceFrame;
    FOleInPlaceUIWindow: IOleInPlaceUIWindow;
    FOleAdviseHolder: IOleAdviseHolder;
    FDataAdviseHolder: IDataAdviseHolder;
    FAdviseSink: IAdviseSink;
    FAdviseFlags: Integer;
    FControl: TWinControl;
    FControlWndProc: TWndMethod;
    FWinControl: TWinControl;
    FIsDirty: Boolean;
    FInPlaceActive: Boolean;
    FUIActive: Boolean;
    FEventsFrozen: Boolean;
    //FOleLinkStub: IInterface; // Pointer to a TOleLinkStub2 instance
    function CreateAdviseHolder: HResult;
    function GetPropertyID(const PropertyName: WideString): Integer;
    procedure RecreateWnd;
    procedure ViewChanged;
  protected
    { Renamed methods }
    function IPersistPropertyBag.InitNew = PersistPropBagInitNew;
    function IPersistPropertyBag.Load = PersistPropBagLoad;
    function IPersistPropertyBag.Save = PersistPropBagSave;
    function IPersistStreamInit.Load = PersistStreamLoad;
    function IPersistStreamInit.Save = PersistStreamSave;
    function IPersistStorage.InitNew = PersistStorageInitNew;
    function IPersistStorage.Load = PersistStorageLoad;
    function IPersistStorage.Save = PersistStorageSave;
    function IViewObject2.GetExtent = ViewObjectGetExtent;
    { IPersist }
    function GetClassID(out classID: TCLSID): HResult; stdcall;
    { IPersistPropertyBag }
    function PersistPropBagInitNew: HResult; stdcall;
    function PersistPropBagLoad(const pPropBag: IPropertyBag;
      const pErrorLog: IErrorLog): HResult; stdcall;
    function PersistPropBagSave(const pPropBag: IPropertyBag; fClearDirty: BOOL;
      fSaveAllProperties: BOOL): HResult; stdcall;
    { IPersistStreamInit }
    function IsDirty: HResult; stdcall;
    function PersistStreamLoad(const stm: IStream): HResult; stdcall;
    function PersistStreamSave(const stm: IStream;
      fClearDirty: BOOL): HResult; stdcall;
    function GetSizeMax(out cbSize: Largeint): HResult; stdcall;
    function InitNew: HResult; stdcall;
    { IPersistStorage }
    function PersistStorageInitNew(const stg: IStorage): HResult; stdcall;
    function PersistStorageLoad(const stg: IStorage): HResult; stdcall;
    function PersistStorageSave(const stgSave: IStorage;
      fSameAsLoad: BOOL): HResult; stdcall;
    function SaveCompleted(const stgNew: IStorage): HResult; stdcall;
    function HandsOffStorage: HResult; stdcall;
    { IObjectSafety }
    function GetInterfaceSafetyOptions(const IID: TIID; pdwSupportedOptions,
      pdwEnabledOptions: PDWORD): HResult; virtual; stdcall;
    function SetInterfaceSafetyOptions(const IID: TIID; dwOptionSetMask,
      dwEnabledOptions: DWORD): HResult; virtual; stdcall;
    { IOleObject }
    function SetClientSite(const clientSite: IOleClientSite): HResult;
      stdcall;
    function GetClientSite(out clientSite: IOleClientSite): HResult;
      stdcall;
    function SetHostNames(szContainerApp: POleStr;
      szContainerObj: POleStr): HResult; stdcall;
    function Close(dwSaveOption: Longint): HResult; stdcall;
    function SetMoniker(dwWhichMoniker: Longint; const mk: IMoniker): HResult;
      stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
    function InitFromData(const dataObject: IDataObject; fCreation: BOOL;
      dwReserved: Longint): HResult; stdcall;
    function GetClipboardData(dwReserved: Longint;
      out dataObject: IDataObject): HResult; stdcall;
    function DoVerb(iVerb: Longint; msg: PMsg; const activeSite: IOleClientSite;
      lindex: Longint; hwndParent: HWND; const posRect: TRect): HResult;
      stdcall;
    function EnumVerbs(out enumOleVerb: IEnumOleVerb): HResult; stdcall;
    function Update: HResult; stdcall;
    function IsUpToDate: HResult; stdcall;
    function GetUserClassID(out clsid: TCLSID): HResult; stdcall;
    function GetUserType(dwFormOfType: Longint; out pszUserType: POleStr): HResult;
      stdcall;
    function SetExtent(dwDrawAspect: Longint; const size: TPoint): HResult;
      stdcall;
    function GetExtent(dwDrawAspect: Longint; out size: TPoint): HResult;
      stdcall;
    function Advise(const advSink: IAdviseSink; out dwConnection: Longint): HResult;
      stdcall;
    function Unadvise(dwConnection: Longint): HResult; stdcall;
    function EnumAdvise(out enumAdvise: IEnumStatData): HResult; stdcall;
    function GetMiscStatus(dwAspect: Longint; out dwStatus: Longint): HResult;
      stdcall;
    function SetColorScheme(const logpal: TLogPalette): HResult; stdcall;
    { IOleControl }
    function GetControlInfo(var ci: TControlInfo): HResult; stdcall;
    function OnMnemonic(msg: PMsg): HResult; stdcall;
    function OnAmbientPropertyChange(dispid: TDispID): HResult; stdcall;
    function FreezeEvents(bFreeze: BOOL): HResult; stdcall;
    { IOleWindow }
    function GetWindow(out wnd: HWnd): HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    { IOleInPlaceObject }
    function InPlaceDeactivate: HResult; stdcall;
    function UIDeactivate: HResult; stdcall;
    function SetObjectRects(const rcPosRect: TRect;
      const rcClipRect: TRect): HResult; stdcall;
    function ReactivateAndUndo: HResult; stdcall;
    { IOleInPlaceActiveObject }
    function TranslateAccelerator(var msg: TMsg): HResult; stdcall;
    function OnFrameWindowActivate(fActivate: BOOL): HResult; stdcall;
    function OnDocWindowActivate(fActivate: BOOL): HResult; stdcall;
    function ResizeBorder(const rcBorder: TRect; const uiWindow: IOleInPlaceUIWindow;
      fFrameWindow: BOOL): HResult; stdcall;
    function EnableModeless(fEnable: BOOL): HResult; stdcall;
    { IViewObject }
    function Draw(dwDrawAspect: Longint; lindex: Longint; pvAspect: Pointer;
      ptd: PDVTargetDevice; hicTargetDev: HDC; hdcDraw: HDC;
      prcBounds: PRect; prcWBounds: PRect; fnContinue: TContinueFunc;
      dwContinue: Longint): HResult; stdcall;
    function GetColorSet(dwDrawAspect: Longint; lindex: Longint;
      pvAspect: Pointer; ptd: PDVTargetDevice; hicTargetDev: HDC;
      out colorSet: PLogPalette): HResult; stdcall;
    function Freeze(dwDrawAspect: Longint; lindex: Longint; pvAspect: Pointer;
      out dwFreeze: Longint): HResult; stdcall;
    function Unfreeze(dwFreeze: Longint): HResult; stdcall;
    function SetAdvise(aspects: Longint; advf: Longint;
      const advSink: IAdviseSink): HResult; stdcall;
    function GetAdvise(pAspects: PLongint; pAdvf: PLONGINT;
      out advSink: IAdviseSink): HResult; stdcall;
    { IViewObject2 }
    function ViewObjectGetExtent(dwDrawAspect: Longint; lindex: Longint;
      ptd: PDVTargetDevice; out size: TPoint): HResult; stdcall;
    { IPerPropertyBrowsing }
    function GetDisplayString(dispid: TDispID; out bstr: WideString): HResult; stdcall;
    function MapPropertyToPage(dispid: TDispID; out clsid: TCLSID): HResult; stdcall;
    function GetPredefinedStrings(dispid: TDispID; out caStringsOut: TCAPOleStr;
      out caCookiesOut: TCALongint): HResult; stdcall;
    function GetPredefinedValue(dispid: TDispID; dwCookie: Longint;
      out varOut: OleVariant): HResult; stdcall;
    { ISpecifyPropertyPages }
    function GetPages(out pages: TCAGUID): HResult; stdcall;
    { ISimpleFrameSite }
    function PreMessageFilter(wnd: HWnd; msg, wp, lp: Integer;
      out res: Integer; out Cookie: Longint): HResult; stdcall;
    function PostMessageFilter(wnd: HWnd; msg, wp, lp: Integer;
      out res: Integer; Cookie: Longint): HResult; stdcall;
    { IQuickActivate }
    function QuickActivate(var qaCont: tagQACONTAINER; var qaCtrl: tagQACONTROL): HResult; stdcall;
    function SetContentExtent(const sizel: TPoint): HResult; stdcall;
    function GetContentExtent(out sizel: TPoint): HResult; stdcall;
    { IDataObject }
    function GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium):
      HResult; stdcall;
    function GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium):
      HResult; stdcall;
    function QueryGetData(const formatetc: TFormatEtc): HResult;
      stdcall;
    function GetCanonicalFormatEtc(const formatetc: TFormatEtc;
      out formatetcOut: TFormatEtc): HResult; stdcall;
    function SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
      fRelease: BOOL): HResult; stdcall;
    function EnumFormatEtc(dwDirection: Longint; out enumFormatEtc:
      IEnumFormatEtc): HResult; stdcall;
    function DAdvise(const formatetc: TFormatEtc; advf: Longint;
      const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
    function DUnadvise(dwConnection: Longint): HResult; stdcall;
    function EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
      stdcall;
    { Standard properties }
    function Get_BackColor: Integer; safecall;
    function Get_Caption: WideString; safecall;
    function Get_Enabled: WordBool; safecall;
    function Get_Font: Font; safecall;
    function Get_ForeColor: Integer; safecall;
    function Get_HWnd: Integer; safecall;
    function Get_TabStop: WordBool; safecall;
    function Get_Text: WideString; safecall;
    procedure Set_BackColor(Value: Integer); safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure Set_Font(const Value: Font); safecall;
    procedure Set_ForeColor(Value: Integer); safecall;
    procedure Set_TabStop(Value: WordBool); safecall;
    procedure Set_Text(const Value: WideString); safecall;
    { Standard event handlers }
    procedure StdClickEvent(Sender: TObject);
    procedure StdDblClickEvent(Sender: TObject);
    procedure StdKeyDownEvent(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StdKeyPressEvent(Sender: TObject; var Key: Char);
    procedure StdKeyUpEvent(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StdMouseDownEvent(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StdMouseMoveEvent(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure StdMouseUpEvent(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    { Helper methods }
    function InPlaceActivate(ActivateUI: Boolean): HResult;
    procedure ShowPropertyDialog;
    procedure SetInPlaceSite(const NewInPlaceSite: IOleInPlaceSite);
    { Overrideable methods }
    procedure DefinePropertyPages(
      DefinePropertyPage: TDefinePropertyPage); virtual;
    function GetPropertyString(DispID: Integer;
      var S: string): Boolean; virtual;
    function GetPropertyStrings(DispID: Integer;
      Strings: TStrings): Boolean; virtual;
    procedure GetPropertyValue(DispID, Cookie: Integer;
      var Value: OleVariant); virtual;
    procedure GetPropFromBag(const PropName: WideString; DispatchID: Integer;
      PropBag: IPropertyBag; ErrorLog: IErrorLog); virtual;
    procedure InitializeControl; virtual;
    procedure LoadFromStream(const Stream: IStream); virtual;
    procedure PerformVerb(Verb: Integer); virtual;
    procedure PutPropInBag(const PropName: WideString; DispatchID: Integer;
      PropBag: IPropertyBag); virtual;
    procedure SaveToStream(const Stream: IStream); virtual;
    procedure WndProc(var Message: TMessage); virtual;
    property ConnectionPoints: TConnectionPoints2 read FConnectionPoints
      implements IConnectionPointContainer;
  public
    destructor Destroy; override;
    procedure Initialize; override;
    function ObjQueryInterface(const IID: TGUID; out Obj): HResult; override;
    procedure PropChanged(const PropertyName: WideString); overload;
    procedure PropChanged(DispID: TDispID); overload;
    function PropRequestEdit(const PropertyName: WideString): Boolean; overload;
    function PropRequestEdit(DispID: TDispID): Boolean; overload;
    property ClientSite: IOleClientSite read FOleClientSite;
    property InPlaceSite: IOleInPlaceSite read FOleInPlaceSite;
    property Control: TWinControl read FControl;
  end;

  TActiveXControl2Class = class of TActiveXControl2;

  TActiveXControlFactory2 = class(TAutoObjectFactory)
  private
    FWinControlClass: TWinControlClass;
    FMiscStatus: Integer;
    FToolboxBitmapID: Integer;
    FVerbs: TStringList;
    FLicFileStrings: TStringList;
    FLicenseFileRead: Boolean;
  protected
    function GetLicenseFileName: string; virtual;
    function HasMachineLicense: Boolean; override;
  public
    constructor Create(ComServer: TComServerObject;
      ActiveXControlClass: TActiveXControl2Class;
      WinControlClass: TWinControlClass; const ClassID: TGUID;
      ToolboxBitmapID: Integer; const LicStr: string; MiscStatus: Integer;
      ThreadingModel: TThreadingModel = tmSingle);
    destructor Destroy; override;
    procedure AddVerb(Verb: Integer; const VerbName: string);
    procedure UpdateRegistry(Register: Boolean); override;
    property MiscStatus: Integer read FMiscStatus;
    property ToolboxBitmapID: Integer read FToolboxBitmapID;
    property WinControlClass: TWinControlClass read FWinControlClass;
  end;

  { ActiveFormControl }

  TActiveFormControl2 = class(TActiveXControl2, IVCLComObject)
  protected
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage); override;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
  public
    procedure FreeOnRelease;
    procedure InitializeControl; override;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult;
      override;
    function ObjQueryInterface(const IID: TGUID; out Obj): HResult; override;
  end;

  { ActiveForm }

  TActiveForm2 = class(TCustomActiveForm)
  private
    FSinkChangeCount : Integer;
    FActiveFormControl: TActiveFormControl2;
  protected
    procedure DoDestroy; override;
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage); virtual;
    procedure EventSinkChanged(const EventSink: IUnknown); virtual;
    procedure Initialize; virtual;
  public
    property ActiveFormControl: TActiveFormControl2 read FActiveFormControl;
  end;

  TActiveForm2Class = class of TActiveForm;

  { ActiveFormFactory }

  TActiveFormFactory2 = class(TActiveXControlFactory2)
  public
    function GetIntfEntry(Guid: TGUID): PInterfaceEntry; override;
  end;

  { Property Page support }

type
  TPropertyPageImpl2 = class;
  TPropertyPageClass2 = class of TPropertyPage2;

  TPropertyPage2 = class(TCustomForm)
  private
    FActiveXPropertyPage: TPropertyPageImpl2;
    FOleObject: OleVariant;
    FOleObjects: TInterfaceList;
    procedure CMChanged(var Msg: TCMChanged); message CM_CHANGED;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Modified;
    procedure UpdateObject; virtual;
    procedure UpdatePropertyPage; virtual;
    property OleObject: OleVariant read FOleObject;
    property OleObjects: TInterfaceList read FOleObjects write FOleObjects;
    procedure EnumCtlProps(PropType: TGUID; PropNames: TStrings);
  published
    property ActiveControl;
    property AutoScroll;
    property Caption;
    property ClientHeight;
    property ClientWidth;
    property Ctl3D;
    property Color;
    property Enabled;
    property Font;
    property Height;
    property HorzScrollBar;
    property OldCreateOrder;
    property KeyPreview;
    property PixelsPerInch;
    property ParentFont;
    property PopupMenu;
    property PrintScale;
    property Scaled;
    property ShowHint;
    property VertScrollBar;
    property Visible;
    property Width;
    property OnActivate;
    property OnClick;
    property OnClose;
    property OnContextPopup;
    property OnCreate;
    property OnDblClick;
    property OnDestroy;
    property OnDeactivate;
    property OnDragDrop;
    property OnDragOver;
    property OnHide;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnPaint;
    property OnResize;
    property OnShow;
  end;

  { TPropertyPageImpl2 }

  TPropertyPageImpl2 = class(TAggregatedObject, IUnknown, IPropertyPage, IPropertyPage2)
  private
    FPropertyPage: TPropertyPage2;
    FPageSite: IPropertyPageSite;
    FActive: Boolean;
    FModified: Boolean;
    procedure Modified;
  protected
    { IPropertyPage }
    function SetPageSite(const pageSite: IPropertyPageSite): HResult; stdcall;
    function Activate(hwndParent: HWnd; const rc: TRect; bModal: BOOL): HResult;
      stdcall;
    function Deactivate: HResult; stdcall;
    function GetPageInfo(out pageInfo: TPropPageInfo): HResult; stdcall;
    function SetObjects(cObjects: Longint; pUnkList: PUnknownList): HResult; stdcall;
    function Show(nCmdShow: Integer): HResult; stdcall;
    function Move(const rect: TRect): HResult; stdcall;
    function IsPageDirty: HResult; stdcall;
    function Apply: HResult; stdcall;
    function Help(pszHelpDir: POleStr): HResult; stdcall;
    function TranslateAccelerator(msg: PMsg): HResult; stdcall;
    { IPropertyPage2 }
    function EditProperty(dispid: TDispID): HResult; stdcall;
  public
    procedure InitPropertyPage; virtual;
    property PropertyPage: TPropertyPage2 read FPropertyPage write FPropertyPage;
  end;

  TActiveXPropertyPage2 = class(TComObject, IPropertyPage, IPropertyPage2)
  private
    FPropertyPageImpl: TPropertyPageImpl2;
  public
    destructor Destroy; override;
    procedure Initialize; override;
    property PropertyPageImpl2: TPropertyPageImpl2 read FPropertyPageImpl
      implements IPropertyPage, IPropertyPage2;
  end;

  TActiveXPropertyPageFactory2 = class(TComObjectFactory)
  public
    constructor Create(ComServer: TComServerObject;
      PropertyPageClass: TPropertyPageClass2; const ClassID: TGUID);
    function CreateComObject(const Controller: IUnknown): TComObject; override;
  end;

  { Type adapter support }

  TCustomAdapter2 = class(TInterfacedObject)
  private
    FOleObject: IUnknown;
    FConnection: Longint;
    FNotifier: IUnknown;
  protected
    Updating: Boolean;
    procedure Changed; virtual;
    procedure ConnectOleObject(OleObject: IUnknown);
    procedure ReleaseOleObject;
    procedure Update; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TAdapterNotifier2 = class(TInterfacedObject,
    IPropertyNotifySink)
  private
    FAdapter: TCustomAdapter2;
  protected
    { IPropertyNotifySink }
    function OnChanged(dispid: TDispID): HResult; stdcall;
    function OnRequestEdit(dispid: TDispID): HResult; stdcall;
  public
    constructor Create(Adapter: TCustomAdapter2);
  end;

implementation

uses Consts;

const
  OCM_BASE = $2000;

type
  TWinControlAccess = class(TWinControl);

  IStdEvents = dispinterface
    ['{00020400-0000-0000-C000-000000000046}']
    procedure Click; dispid DISPID_CLICK;
    procedure DblClick; dispid DISPID_DBLCLICK;
    procedure KeyDown(var KeyCode: Smallint;
      Shift: Smallint); dispid DISPID_KEYDOWN;
    procedure KeyPress(var KeyAscii: Smallint); dispid DISPID_KEYPRESS;
    procedure KeyUp(var KeyCode: Smallint;
      Shift: Smallint); dispid DISPID_KEYDOWN;
    procedure MouseDown(Button, Shift: Smallint;
      X, Y: Integer); dispid DISPID_MOUSEDOWN;
    procedure MouseMove(Button, Shift: Smallint;
      X, Y: Integer); dispid DISPID_MOUSEMOVE;
    procedure MouseUp(Button, Shift: Smallint;
      X, Y: Integer); dispid DISPID_MOUSEUP;
  end;

function HandleException: HResult;
var
  E: TObject;
begin
  E := ExceptObject;
  if (E is EOleSysError) and (EOleSysError(E).ErrorCode < 0) then
    Result := EOleSysError(E).ErrorCode else
    Result := E_UNEXPECTED;
end;

procedure FreeObjects(List: TList);
var
  I: Integer;
begin
  for I := List.Count - 1 downto 0 do TObject(List[I]).Free;
end;

procedure FreeObjectList(List: TList);
begin
  if List <> nil then
  begin
    FreeObjects(List);
    List.Free;
  end;
end;

function CoAllocMem(Size: Integer): Pointer;
begin
  Result := CoTaskMemAlloc(Size);
  if Result = nil then OleError(E_OUTOFMEMORY);
  FillChar(Result^, Size, 0);
end;

procedure CoFreeMem(P: Pointer);
begin
  if P <> nil then CoTaskMemFree(P);
end;

function CoAllocString(const S: string): POleStr;
var
  W: WideString;
  Size: Integer;
begin
  W := S;
  Size := (Length(W) + 1) * 2;
  Result := CoAllocMem(Size);
  Move(PWideChar(W)^, Result^, Size);
end;

function GetKeyModifiers: Integer;
begin
  Result := 0;
  if GetKeyState(VK_SHIFT) < 0 then Result := 1;
  if GetKeyState(VK_CONTROL) < 0 then Result := Result or 2;
  if GetKeyState(VK_MENU) < 0 then Result := Result or 4;
end;

function GetEventShift(Shift: TShiftState): Integer;
const
  ShiftMap: array[0..7] of Byte = (0, 1, 4, 5, 2, 3, 6, 7);
begin
  Result := ShiftMap[Byte(Shift) and 7];
end;

function GetEventButton(Button: TMouseButton): Integer;
begin
  Result := 1 shl Ord(Button);
end;

{ TEnumConnections2 }

type
  TEnumConnections2 = class(TInterfacedObject, IEnumConnections)
  private
    FConnectionPoint: TConnectionPoint2;
    FController: IUnknown;
    FIndex: Integer;
    FCount: Integer;
  protected
    { IEnumConnections }
    function Next(celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enumconn: IEnumConnections): HResult; stdcall;
  public
    constructor Create(ConnectionPoint: TConnectionPoint2; Index: Integer);
  end;

constructor TEnumConnections2.Create(ConnectionPoint: TConnectionPoint2;
  Index: Integer);
begin
  inherited Create;
  FConnectionPoint := ConnectionPoint;
  // keep ConnectionPoint's controller alive as long as we're in use
  FController := FConnectionPoint.Controller;
  FIndex := Index;
  FCount := ConnectionPoint.FSinkList.Count;
end;

{ TEnumConnections2.IEnumConnections }

function TEnumConnections2.Next(celt: Longint; out elt;
  pceltFetched: PLongint): HResult;
type
  TConnectDatas = array[0..1023] of TConnectData;
var
  I: Integer;
  P: Pointer;
begin
  I := 0;
  while (I < celt) and (FIndex < FCount) do
  begin
    P := FConnectionPoint.FSinkList[FIndex];
    if P <> nil then
    begin
      Pointer(TConnectDatas(elt)[I].pUnk) := nil;
      TConnectDatas(elt)[I].pUnk := IUnknown(P);
      TConnectDatas(elt)[I].dwCookie := FIndex + 1;
      Inc(I);
    end;
    Inc(FIndex);
  end;
  if pceltFetched <> nil then pceltFetched^ := I;
  if I = celt then Result := S_OK else Result := S_FALSE;
end;

function TEnumConnections2.Skip(celt: Longint): HResult; stdcall;
begin
  Result := S_FALSE;
  while (celt > 0) and (FIndex < FCount) do
  begin
    if FConnectionPoint.FSinkList[FIndex] <> nil then Dec(celt);
    Inc(FIndex);
  end;
  if celt = 0 then Result := S_OK;
end;

function TEnumConnections2.Reset: HResult; stdcall;
begin
  FIndex := 0;
  Result := S_OK;
end;

function TEnumConnections2.Clone(out enumconn: IEnumConnections): HResult; stdcall;
begin
  try
    enumconn := TEnumConnections2.Create(FConnectionPoint, FIndex);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

{ TConnectionPoint }

constructor TConnectionPoint2.Create(Container: TConnectionPoints2;
  const IID: TGUID; Kind: TConnectionKind;
  OnConnect: TConnectEvent);
begin
  inherited Create(IUnknown(Container.FController));
  FContainer := Container;
  FContainer.FConnectionPoints.Add(Self);
  FSinkList := TList.Create;
  FIID := IID;
  FKind := Kind;
  FOnConnect := OnConnect;
end;

destructor TConnectionPoint2.Destroy;
var
  I: Integer;
begin
  if FContainer <> nil then FContainer.FConnectionPoints.Remove(Self);
  if FSinkList <> nil then
  begin
    for I := 0 to FSinkList.Count - 1 do
      if FSinkList[I] <> nil then RemoveSink(I);
    FSinkList.Free;
  end;
  inherited Destroy;
end;

function TConnectionPoint2.AddSink(const Sink: IUnknown): Integer;
var
  I: Integer;
begin
  I := 0;

  while I < FSinkList.Count do
  begin
    if FSinkList[I] = nil then
      Break
    else
      Inc(I);
  end;

  if I >= FSinkList.Count then
    FSinkList.Add(Pointer(Sink))
  else
    FSinkList[I] := Pointer(Sink);

  Sink._AddRef;
  Result := I;
end;

procedure TConnectionPoint2.RemoveSink(Cookie: Longint);
var
  Sink: Pointer;
begin
  Sink := FSinkList[Cookie];
  FSinkList[Cookie] := nil;
  IUnknown(Sink)._Release;
end;

{ TConnectionPoint.IConnectionPoint }

function TConnectionPoint2.GetConnectionInterface(out iid: TIID): HResult;
begin
  iid := FIID;
  Result := S_OK;
end;

function TConnectionPoint2.GetConnectionPointContainer(
  out cpc: IConnectionPointContainer): HResult;
begin
  cpc := IUnknown(FContainer.FController) as IConnectionPointContainer;
  Result := S_OK;
end;

function TConnectionPoint2.Advise(const unkSink: IUnknown;
  out dwCookie: Longint): HResult;
begin
  if (FKind = ckSingle) and (FSinkList.Count > 0) and
    (FSinkList[0] <> nil) then
  begin
    Result := CONNECT_E_CANNOTCONNECT;
    Exit;
  end;
  try
    if Assigned(FOnConnect) then FOnConnect(unkSink, True);
    dwCookie := AddSink(unkSink) + 1;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TConnectionPoint2.Unadvise(dwCookie: Longint): HResult;
begin
  Dec(dwCookie);
  if (dwCookie < 0) or (dwCookie >= FSinkList.Count) or
    (FSinkList[dwCookie] = nil) then
  begin
    Result := CONNECT_E_NOCONNECTION;
    Exit;
  end;
  try
    if Assigned(FOnConnect) then
      FOnConnect(IUnknown(FSinkList[dwCookie]), False);
    RemoveSink(dwCookie);
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TConnectionPoint2.EnumConnections(out enumconn: IEnumConnections): HResult;
begin
  try
    enumconn := TEnumConnections2.Create(Self, 0);
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

{ TEnumConnectionPoints2 }

type
  TEnumConnectionPoints2 = class(TContainedObject, IEnumConnectionPoints)
  private
    FContainer: TConnectionPoints2;
    FIndex: Integer;
  protected
    { IEnumConnectionPoints }
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enumconn: IEnumConnectionPoints): HResult; stdcall;
  public
    constructor Create(Container: TConnectionPoints2;
      Index: Integer);
  end;

constructor TEnumConnectionPoints2.Create(Container: TConnectionPoints2;
  Index: Integer);
begin
  inherited Create(IUnknown(Container.FController));
  FContainer := Container;
  FIndex := Index;
end;

{ TEnumConnectionPoints2.IEnumConnectionPoints }

type
  TPointerList = array[0..0] of Pointer;

function TEnumConnectionPoints2.Next(celt: Longint; out elt;
  pceltFetched: PLongint): HResult;
var
  I: Integer;
  P: Pointer;
begin
  I := 0;
  while (I < celt) and (FIndex < FContainer.FConnectionPoints.Count) do
  begin
    P := Pointer(IConnectionPoint(TConnectionPoint2(
      FContainer.FConnectionPoints[FIndex])));
    IConnectionPoint(P)._AddRef;
    TPointerList(elt)[I] := P;
    Inc(I);
    Inc(FIndex);
  end;
  if pceltFetched <> nil then pceltFetched^ := I;
  if I = celt then Result := S_OK else Result := S_FALSE;
end;

function TEnumConnectionPoints2.Skip(celt: Longint): HResult; stdcall;
begin
  if FIndex + celt <= FContainer.FConnectionPoints.Count then
  begin
    FIndex := FIndex + celt;
    Result := S_OK;
  end else
  begin
    FIndex := FContainer.FConnectionPoints.Count;
    Result := S_FALSE;
  end;
end;

function TEnumConnectionPoints2.Reset: HResult; stdcall;
begin
  FIndex := 0;
  Result := S_OK;
end;

function TEnumConnectionPoints2.Clone(
  out enumconn: IEnumConnectionPoints): HResult; stdcall;
begin
  try
    enumconn := TEnumConnectionPoints2.Create(FContainer, FIndex);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

{ TConnectionPoints2 }

constructor TConnectionPoints2.Create(const AController: IUnknown);
begin    // weak reference, don't keep the controller alive
  FController := Pointer(AController);
  FConnectionPoints := TList.Create;
end;

destructor TConnectionPoints2.Destroy;
begin
  FreeObjectList(FConnectionPoints);
  inherited Destroy;
end;

function TConnectionPoints2.CreateConnectionPoint(const IID: TGUID;
  Kind: TConnectionKind; OnConnect: TConnectEvent): TConnectionPoint2;
begin
  Result := TConnectionPoint2.Create(Self, IID, Kind, OnConnect);
end;

{ TConnectionPoints2.IConnectionPointContainer }

function TConnectionPoints2.EnumConnectionPoints(
  out enumconn: IEnumConnectionPoints): HResult;
begin
  try
    enumconn := TEnumConnectionPoints2.Create(Self, 0);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TConnectionPoints2.FindConnectionPoint(const iid: TIID;
  out cp: IConnectionPoint): HResult;
var
  I: Integer;
  ConnectionPoint: TConnectionPoint2;
begin
  for I := 0 to FConnectionPoints.Count - 1 do
  begin
    ConnectionPoint := FConnectionPoints[I];
    if IsEqualGUID(ConnectionPoint.FIID, iid) then
    begin
      cp := ConnectionPoint;
      Result := S_OK;
      Exit;
    end;
  end;
  Result := CONNECT_E_NOCONNECTION;
end;

function TConnectionPoints2.GetController: IUnknown;
begin
  Result := IUnknown(FController);
end;

{ TOleLinkStub2 }

type
  TOleLinkStub2 = class(TInterfacedObject, IUnknown, IOleLink)
  private
    Controller: IUnknown;
  public
    constructor Create(const AController: IUnknown);
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    { IOleLink }
    function SetUpdateOptions(dwUpdateOpt: Longint): HResult;
      stdcall;
    function GetUpdateOptions(out dwUpdateOpt: Longint): HResult; stdcall;
    function SetSourceMoniker(const mk: IMoniker; const clsid: TCLSID): HResult;
      stdcall;
    function GetSourceMoniker(out mk: IMoniker): HResult; stdcall;
    function SetSourceDisplayName(pszDisplayName: POleStr): HResult;
      stdcall;
    function GetSourceDisplayName(out pszDisplayName: POleStr): HResult;
      stdcall;
    function BindToSource(bindflags: Longint; const bc: IBindCtx): HResult;
      stdcall;
    function BindIfRunning: HResult; stdcall;
    function GetBoundSource(out unk: IUnknown): HResult; stdcall;
    function UnbindSource: HResult; stdcall;
    function Update(const bc: IBindCtx): HResult; stdcall;
  end;

constructor TOleLinkStub2.Create(const AController: IUnknown);
begin
  inherited Create;
  Controller := AController;
end;

{ TOleLinkStub2.IUnknown }

function TOleLinkStub2.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := Controller.QueryInterface(IID, Obj);
end;

{ TOleLinkStub2.IOleLink }

function TOleLinkStub2.SetUpdateOptions(dwUpdateOpt: Longint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub2.GetUpdateOptions(out dwUpdateOpt: Longint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub2.SetSourceMoniker(const mk: IMoniker; const clsid: TCLSID): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub2.GetSourceMoniker(out mk: IMoniker): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub2.SetSourceDisplayName(pszDisplayName: POleStr): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub2.GetSourceDisplayName(out pszDisplayName: POleStr): HResult;
begin
  pszDisplayName := nil;
  Result := E_FAIL;
end;

function TOleLinkStub2.BindToSource(bindflags: Longint; const bc: IBindCtx): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub2.BindIfRunning: HResult;
begin
  Result := S_OK;
end;

function TOleLinkStub2.GetBoundSource(out unk: IUnknown): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub2.UnbindSource: HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub2.Update(const bc: IBindCtx): HResult;
begin
  Result := E_NOTIMPL;
end;

{ TActiveXControl }

procedure TActiveXControl2.Initialize;
begin
  inherited Initialize;
  FConnectionPoints := TConnectionPoints2.Create(Self);
//  FOleLinkStub := TOleLinkStub2.Create(nil);
//  FOleLinkStub._AddRef;
  FControlFactory := Factory as TActiveXControlFactory2;
  if FControlFactory.EventTypeInfo <> nil then
    FConnectionPoints.CreateConnectionPoint(FControlFactory.EventIID,
      ckSingle, EventConnect);
  FPropertySinks := FConnectionPoints.CreateConnectionPoint(IPropertyNotifySink,
    ckMulti, nil);
  FControl := FControlFactory.WinControlClass.CreateParented(ParkingWindow);
  if csReflector in FControl.ControlStyle then
    FWinControl := TReflectorWindow.Create(ParkingWindow, FControl) else
    FWinControl := FControl;
  FControlWndProc := FControl.WindowProc;
  FControl.WindowProc := WndProc;
  InitializeControl;
end;

destructor TActiveXControl2.Destroy;
begin
  if Assigned(FControlWndProc) then FControl.WindowProc := FControlWndProc;
  FControl.Free;
  if FWinControl <> FControl then FWinControl.Free;
  FConnectionPoints.Free;
//  FOleLinkStub._Release;
//  FOleLinkStub := nil;
  inherited Destroy;
end;

function TActiveXControl2.CreateAdviseHolder: HResult;
begin
  if FOleAdviseHolder = nil then
    Result := CreateOleAdviseHolder(FOleAdviseHolder) else
    Result := S_OK;
end;

procedure TActiveXControl2.DefinePropertyPages(
  DefinePropertyPage: TDefinePropertyPage);
begin
end;

function TActiveXControl2.GetPropertyString(DispID: Integer;
  var S: string): Boolean;
begin
  Result := False;
end;

function TActiveXControl2.GetPropertyStrings(DispID: Integer;
  Strings: TStrings): Boolean;
begin
  Result := False;
end;

procedure TActiveXControl2.GetPropFromBag(const PropName: WideString;
  DispatchID: Integer; PropBag: IPropertyBag; ErrorLog: IErrorLog);
var
  PropValue: OleVariant;
begin
  //  Note: raise an EAbort exception here to stop properties from loading
  if PropBag.Read(PWideChar(PropName), PropValue, ErrorLog) = S_OK then
    ComObj2.SetDispatchPropValue(Self as IDispatch, DispatchID, PropValue);
end;

procedure TActiveXControl2.PutPropInBag(const PropName: WideString;
  DispatchID: Integer; PropBag: IPropertyBag);
begin
  PropBag.Write(PWideChar(PropName), ComObj2.GetDispatchPropValue(Self as IDispatch,
    DispatchID));
end;

procedure TActiveXControl2.GetPropertyValue(DispID, Cookie: Integer;
  var Value: OleVariant);
begin
end;

procedure TActiveXControl2.InitializeControl;
begin
end;

function TActiveXControl2.InPlaceActivate(ActivateUI: Boolean): HResult;
var
  InPlaceActivateSent: Boolean;
  ParentWindow: HWND;
  PosRect, ClipRect: TRect;
  FrameInfo: TOleInPlaceFrameInfo;
begin
  Result := S_OK;
  FWinControl.Visible := True;
  InPlaceActivateSent := False;
  if not FInPlaceActive then
    try
      if FOleClientSite = nil then OleError(E_FAIL);
      OleCheck(FOleClientSite.QueryInterface(IOleInPlaceSite, FOleInPlaceSite));
      if FOleInPlaceSite.CanInPlaceActivate <> S_OK then OleError(E_FAIL);
      OleCheck(FOleInPlaceSite.OnInPlaceActivate);
      InPlaceActivateSent := True;
      OleCheck(FOleInPlaceSite.GetWindow(ParentWindow));
      FrameInfo.cb := SizeOf(FrameInfo);
      OleCheck(FOleInPlaceSite.GetWindowContext(FOleInPlaceFrame,
        FOleInPlaceUIWindow, PosRect, ClipRect, FrameInfo));
      if FOleInPlaceFrame = nil then OleError(E_FAIL);
      with PosRect do
        FWinControl.SetBounds(Left, Top, Right - Left, Bottom - Top);
      FWinControl.ParentWindow := ParentWindow;
      FWinControl.Visible := True;
      FInPlaceActive := True;
      FOleClientSite.ShowObject;
    except
      FInPlaceActive := False;
      FOleInPlaceUIWindow := nil;
      FOleInPlaceFrame := nil;
      if InPlaceActivateSent then FOleInPlaceSite.OnInPlaceDeactivate;
      FOleInPlaceSite := nil;
      Result := HandleException;
      Exit;
    end;
  if ActivateUI and not FUIActive then
  begin
    FUIActive := True;
    FOleInPlaceSite.OnUIActivate;
    SetFocus(FWinControl.Handle);
    FOleInPlaceFrame.SetActiveObject(Self as IOleInPlaceActiveObject, nil);
    if FOleInPlaceUIWindow <> nil then
      FOleInPlaceUIWindow.SetActiveObject(Self as IOleInPlaceActiveObject, nil);
    FOleInPlaceFrame.SetBorderSpace(nil);
    if FOleInPlaceUIWindow <> nil then
      FOleInPlaceUIWindow.SetBorderSpace(nil);
  end;
end;

procedure TActiveXControl2.LoadFromStream(const Stream: IStream);
var
  OleStream: TOleStream;
begin
  OleStream := TOleStream.Create(Stream);
  try
    OleStream.ReadComponent(FControl);
  finally
    OleStream.Free;
  end;
end;

function TActiveXControl2.ObjQueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if IsEqualGuid(IID, ISimpleFrameSite) and
    ((FControlFactory.MiscStatus and OLEMISC_SIMPLEFRAME) = 0) then
    Result := E_NOINTERFACE
  else
  begin
    Result := inherited ObjQueryInterface(IID, Obj);
    if Result <> 0 then
      if IsEqualGuid(IID, IOleLink) then
      begin
        // Work around for an MS Access 97 bug that requires IOleLink
        // to be stubbed.
        Pointer(Obj) := nil;
//        IOleLink(Obj) := TOleLinkStub2.Create(Self);
      end;
  end;
end;

procedure TActiveXControl2.PerformVerb(Verb: Integer);
begin
end;

function TActiveXControl2.GetPropertyID(const PropertyName: WideString): Integer;
var
  PName: PWideChar;
begin
  PName := PWideChar(PropertyName);
  if PropertyName = '' then
    Result := DISPID_UNKNOWN else
    OleCheck(GetIDsOfNames(GUID_NULL, @PName, 1, GetThreadLocale,
      @Result));
end;

procedure TActiveXControl2.PropChanged(const PropertyName: WideString);
var
  PropID: Integer;
begin
  PropID := GetPropertyID(PropertyName);
  PropChanged(PropID);
end;

procedure TActiveXControl2.PropChanged(DispID: TDispID);
var
  Enum: IEnumConnections;
  ConnectData: TConnectData;
  Fetched: Longint;
begin
  OleCheck(FPropertySinks.EnumConnections(Enum));
  while Enum.Next(1, ConnectData, @Fetched) = S_OK do
  begin
    (ConnectData.pUnk as IPropertyNotifySink).OnChanged(DispID);
    ConnectData.pUnk := nil;
  end;
end;

function TActiveXControl2.PropRequestEdit(const PropertyName: WideString): Boolean;
var
  PropID: Integer;
begin
  PropID := GetPropertyID(PropertyName);
  Result := PropRequestEdit(PropID);
end;

function TActiveXControl2.PropRequestEdit(DispID: TDispID): Boolean;
var
  Enum: IEnumConnections;
  ConnectData: TConnectData;
  Fetched: Longint;
begin
  Result := True;
  OleCheck(FPropertySinks.EnumConnections(Enum));
  while Enum.Next(1, ConnectData, @Fetched) = S_OK do
  begin
    Result := (ConnectData.pUnk as IPropertyNotifySink).OnRequestEdit(DispID) = S_OK;
    ConnectData.pUnk := nil;
    if not Result then Exit;
  end;
end;

procedure TActiveXControl2.RecreateWnd;
var
  WasUIActive: Boolean;
  PrevWnd: HWND;
begin
  if FWinControl.HandleAllocated then
  begin
    WasUIActive := FUIActive;
    PrevWnd := Windows.GetWindow(FWinControl.Handle, GW_HWNDPREV);
    InPlaceDeactivate;
    TWinControlAccess(FWinControl).DestroyHandle;
    if InPlaceActivate(WasUIActive) = S_OK then
      SetWindowPos(FWinControl.Handle, PrevWnd, 0, 0, 0, 0,
        SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE);
  end;
end;

procedure TActiveXControl2.SaveToStream(const Stream: IStream);
var
  OleStream: TOleStream;
  Writer: TWriter;
begin
  OleStream := TOleStream.Create(Stream);
  try
    Writer := TWriter.Create(OleStream, 4096);
    try
      Writer.IgnoreChildren := True;
      Writer.WriteDescendent(FControl, nil);
    finally
      Writer.Free;
    end;
  finally
    OleStream.Free;
  end;
end;

procedure TActiveXControl2.ShowPropertyDialog;
var
  Unknown: IUnknown;
  Pages: TCAGUID;
begin
  if (FOleControlSite <> nil) and
    (FOleControlSite.ShowPropertyFrame = S_OK) then Exit;
  OleCheck(GetPages(Pages));
  try
    if Pages.cElems > 0 then
    begin
      if FOleInPlaceFrame <> nil then
        FOleInPlaceFrame.EnableModeless(False);
      try
        Unknown := Self;
        OleCheck(OleCreatePropertyFrame(GetActiveWindow, 16, 16,
          PWideChar(FAmbientDispatch.DisplayName), {!!!}
          1, @Unknown, Pages.cElems, Pages.pElems,
          GetSystemDefaultLCID, 0, nil));
      finally
        if FOleInPlaceFrame <> nil then
          FOleInPlaceFrame.EnableModeless(True);
      end;
    end;
  finally
    CoFreeMem(pages.pElems);
  end;
end;

procedure TActiveXControl2.SetInPlaceSite(const NewInPlaceSite: IOleInPlaceSite);
begin
  FOleInPlaceSite := NewInPlaceSite;
end;

procedure TActiveXControl2.StdClickEvent(Sender: TObject);
begin
  if EventSink <> nil then IStdEvents(EventSink).Click;
end;

procedure TActiveXControl2.StdDblClickEvent(Sender: TObject);
begin
  if EventSink <> nil then IStdEvents(EventSink).DblClick;
end;

procedure TActiveXControl2.StdKeyDownEvent(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if EventSink <> nil then
    IStdEvents(EventSink).KeyDown(Smallint(Key), GetEventShift(Shift));
end;

procedure TActiveXControl2.StdKeyPressEvent(Sender: TObject; var Key: Char);
var
  KeyAscii: Smallint;
begin
  if EventSink <> nil then
  begin
    KeyAscii := Ord(Key);
    IStdEvents(EventSink).KeyPress(KeyAscii);
    Key := Chr(KeyAscii);
  end;
end;

procedure TActiveXControl2.StdKeyUpEvent(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if EventSink <> nil then
    IStdEvents(EventSink).KeyUp(Smallint(Key), GetEventShift(Shift));
end;

procedure TActiveXControl2.StdMouseDownEvent(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if EventSink <> nil then
    IStdEvents(EventSink).MouseDown(GetEventButton(Button),
      GetEventShift(Shift), X, Y);
end;

procedure TActiveXControl2.StdMouseMoveEvent(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if EventSink <> nil then
    IStdEvents(EventSink).MouseMove((Byte(Shift) shr 3) and 7,
      GetEventShift(Shift), X, Y);
end;

procedure TActiveXControl2.StdMouseUpEvent(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if EventSink <> nil then
    IStdEvents(EventSink).MouseUp(GetEventButton(Button),
      GetEventShift(Shift), X, Y);
end;

procedure TActiveXControl2.ViewChanged;
begin
  if FAdviseSink <> nil then
  begin
    FAdviseSink.OnViewChange(DVASPECT_CONTENT, -1);
    if FAdviseFlags and ADVF_ONLYONCE <> 0 then FAdviseSink := nil;
  end;
end;

procedure TActiveXControl2.WndProc(var Message: TMessage);
var
  Handle: HWnd;
  FilterMessage: Boolean;
  Cookie: Longint;

  procedure ControlWndProc;
  begin
    with Message do
      if (Msg >= OCM_BASE) and (Msg < OCM_BASE + WM_USER) then
        Msg := Msg + (CN_BASE - OCM_BASE);
    FControlWndProc(Message);
    with Message do
      if (Msg >= CN_BASE) and (Msg < CN_BASE + WM_USER) then
        Msg := Msg - (CN_BASE - OCM_BASE);
  end;

begin
  with Message do
  begin
    Handle := TWinControlAccess(FControl).WindowHandle;
    FilterMessage := ((Msg < CM_BASE) or (Msg >= $C000)) and
      (FSimpleFrameSite <> nil) and FInPlaceActive;
    if FilterMessage then
      if FSimpleFrameSite.PreMessageFilter(Handle, Msg, WParam, LParam,
        Integer(Result), Cookie) = S_FALSE then Exit;
    case Msg of
      WM_SETFOCUS, WM_KILLFOCUS:
        begin
          ControlWndProc;
          if FOleControlSite <> nil then
            FOleControlSite.OnFocus(Msg = WM_SETFOCUS);
        end;
      CM_VISIBLECHANGED:
        begin
          if FControl <> FWinControl then FWinControl.Visible := FControl.Visible;
          if not FWinControl.Visible then UIDeactivate;
          ControlWndProc;
        end;
      CM_RECREATEWND:
        begin
          if FInPlaceActive and (FControl = FWinControl) then
            RecreateWnd
          else
          begin
            ControlWndProc;
            ViewChanged;
          end;
        end;
      CM_INVALIDATE,
      WM_SETTEXT:
        begin
          ControlWndProc;
          if not FInPlaceActive then ViewChanged;
        end;
      WM_NCHITTEST:
        begin
          ControlWndProc;
          if Message.Result = HTTRANSPARENT then Message.Result := HTCLIENT;
        end;
      WM_MOUSEACTIVATE:
        begin
          ControlWndProc;
          if not FUIActive and ((Message.Result = MA_ACTIVATE) or
            (Message.Result = MA_ACTIVATEANDEAT)) and (FAmbientDispatch <> nil)
            and FAmbientDispatch.UserMode then
            InPlaceActivate(True);
        end;
    else
      ControlWndProc;
    end;
    if FilterMessage then
      FSimpleFrameSite.PostMessageFilter(Handle, Msg, WParam, LParam,
        Integer(Result), Cookie);
  end;
end;

{ TActiveXControl standard properties }

function TActiveXControl2.Get_BackColor: Integer;
begin
  Result := TWinControlAccess(FControl).Color;
end;

function TActiveXControl2.Get_Caption: WideString;
begin
  Result := TWinControlAccess(FControl).Caption;
end;

function TActiveXControl2.Get_Enabled: WordBool;
begin
  Result := FControl.Enabled;
end;

function TActiveXControl2.Get_Font: Font;
begin
  GetOleFont(TWinControlAccess(FControl).Font, Result);
end;

function TActiveXControl2.Get_ForeColor: Integer;
begin
  Result := TWinControlAccess(FControl).Font.Color;
end;

function TActiveXControl2.Get_HWnd: Integer;
begin
  Result := FControl.Handle;
end;

function TActiveXControl2.Get_TabStop: WordBool;
begin
  Result := FControl.TabStop;
end;

function TActiveXControl2.Get_Text: WideString;
begin
  Result := TWinControlAccess(FControl).Text;
end;

procedure TActiveXControl2.Set_BackColor(Value: Integer);
begin
  TWinControlAccess(FControl).Color := Value;
end;

procedure TActiveXControl2.Set_Caption(const Value: WideString);
begin
  TWinControlAccess(FControl).Caption := Value;
end;

procedure TActiveXControl2.Set_Enabled(Value: WordBool);
begin
  FControl.Enabled := Value;
end;

procedure TActiveXControl2.Set_Font(const Value: Font);
begin
  SetOleFont(TWinControlAccess(FControl).Font, Value);
end;

procedure TActiveXControl2.Set_ForeColor(Value: Integer);
begin
  TWinControlAccess(FControl).Font.Color := Value;
end;

procedure TActiveXControl2.Set_TabStop(Value: WordBool);
begin
  FControl.TabStop := Value;
end;

procedure TActiveXControl2.Set_Text(const Value: WideString);
begin
  TWinControlAccess(FControl).Text := Value;
end;

{ TActiveXControl.IPersist }

function TActiveXControl2.GetClassID(out classID: TCLSID): HResult;
begin
  classID := Factory.ClassID;
  Result := S_OK;
end;

{ TActiveXControl.IPersistPropertyBag }

function TActiveXControl2.PersistPropBagInitNew: HResult;
begin
  Result := S_OK;
end;

function TActiveXControl2.PersistPropBagLoad(const pPropBag: IPropertyBag;
  const pErrorLog: IErrorLog): HResult;
var
  PropList: TStringList;
  i: Integer;
begin
  try
    Result := S_OK;
    if pPropBag = nil then
    begin
      Result := E_POINTER;
      Exit;
    end;
    PropList := TStringList.Create;
    try
      EnumDispatchProperties(Self as IDispatch, GUID_NULL, VT_EMPTY, PropList);
      for i := 0 to PropList.Count - 1 do
        try
          GetPropFromBag(PropList[i], Integer(PropList.Objects[i]),
            pPropBag, pErrorLog);
        except
          // Supress all exceptions except EAbort
          if ExceptObject is EAbort then
          begin
            Result := E_FAIL;
            Exit;
          end;
        end;
    finally
      PropList.Free;
    end;
  Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl2.PersistPropBagSave(const pPropBag: IPropertyBag;
  fClearDirty: BOOL; fSaveAllProperties: BOOL): HResult;
var
  PropList: TStringList;
  i: Integer;
begin
  try
    if pPropBag = nil then
    begin
      Result := E_POINTER;
      Exit;
    end;
    PropList := TStringList.Create;
    try
      EnumDispatchProperties(Self as IDispatch, GUID_NULL, VT_EMPTY, PropList);
      for i := 0 to PropList.Count - 1 do
        PutPropInBag(PropList[i], Integer(PropList.Objects[i]), pPropBag);
    finally
      PropList.Free;
    end;
    if fClearDirty then FIsDirty := False;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

{ TActiveXControl.IPersistStreamInit }

function TActiveXControl2.IsDirty: HResult;
begin
  if FIsDirty then Result := S_OK else Result := S_FALSE;
end;

function TActiveXControl2.PersistStreamLoad(const stm: IStream): HResult;
begin
  try
    LoadFromStream(stm);
    FIsDirty := False;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl2.PersistStreamSave(const stm: IStream;
  fClearDirty: BOOL): HResult;
begin
  try
    SaveToStream(stm);
    if fClearDirty then FIsDirty := False;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl2.GetSizeMax(out cbSize: Largeint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.InitNew: HResult;
begin
  try
    FIsDirty := False;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

{ TActiveXControl.IPersistStorage }

function TActiveXControl2.PersistStorageInitNew(const stg: IStorage): HResult;
begin
  Result := InitNew;
end;

function TActiveXControl2.PersistStorageLoad(const stg: IStorage): HResult;
var
  Stream: IStream;
begin
  try
    OleCheck(stg.OpenStream('CONTROLSAVESTREAM'#0, nil, STGM_READ +
      STGM_SHARE_EXCLUSIVE, 0, Stream));
    LoadFromStream(Stream);
    FIsDirty := False;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl2.PersistStorageSave(const stgSave: IStorage;
  fSameAsLoad: BOOL): HResult;
var
  Stream: IStream;
begin
  try
    OleCheck(stgSave.CreateStream('CONTROLSAVESTREAM'#0, STGM_WRITE +
      STGM_SHARE_EXCLUSIVE + STGM_CREATE, 0, 0, Stream));
    SaveToStream(Stream);
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl2.SaveCompleted(const stgNew: IStorage): HResult;
begin
  FIsDirty := False;
  Result := S_OK;
end;

function TActiveXControl2.HandsOffStorage: HResult;
begin
  Result := S_OK;
end;

{ TActiveXControl.IObjectSafety }

function TActiveXControl2.GetInterfaceSafetyOptions(const IID: TIID;
  pdwSupportedOptions, pdwEnabledOptions: PDWORD): HResult;
var
  Unk: IUnknown;
begin
  if (pdwSupportedOptions = nil) or (pdwEnabledOptions = nil) then
  begin
    Result := E_POINTER;
    Exit;
  end;
  Result := QueryInterface(IID, Unk);
  if Result = S_OK then
  begin
    pdwSupportedOptions^ := INTERFACESAFE_FOR_UNTRUSTED_CALLER or
      INTERFACESAFE_FOR_UNTRUSTED_DATA;
    pdwEnabledOptions^ := FObjectSafetyFlags and
      (INTERFACESAFE_FOR_UNTRUSTED_CALLER or INTERFACESAFE_FOR_UNTRUSTED_DATA);
  end
  else begin
    pdwSupportedOptions^ := 0;
    pdwEnabledOptions^ := 0;
  end;
end;

function TActiveXControl2.SetInterfaceSafetyOptions(const IID: TIID;
  dwOptionSetMask, dwEnabledOptions: DWORD): HResult;
var
  Unk: IUnknown;
begin
  Result := QueryInterface(IID, Unk);
  if Result <> S_OK then Exit;
  FObjectSafetyFlags := dwEnabledOptions and dwOptionSetMask;
end;

{ TActiveXControl.IOleObject }

function TActiveXControl2.SetClientSite(const ClientSite: IOleClientSite): HResult;
begin
  if ClientSite <> nil then
  begin
    if FOleClientSite <> nil then
    begin
      Result := E_FAIL;
      Exit;
    end;
    FOleClientSite := ClientSite;
    ClientSite.QueryInterface(IOleControlSite, FOleControlSite);
    if FControlFactory.MiscStatus and OLEMISC_SIMPLEFRAME <> 0 then
      ClientSite.QueryInterface(ISimpleFrameSite, FSimpleFrameSite);
    ClientSite.QueryInterface(IDispatch, FAmbientDispatch);
    OnAmbientPropertyChange(0);
  end else
  begin
    FAmbientDispatch := nil;
    FSimpleFrameSite := nil;
    FOleControlSite := nil;
    FOleClientSite := nil;
  end;
  Result := S_OK;
end;

function TActiveXControl2.GetClientSite(out clientSite: IOleClientSite): HResult;
begin
  ClientSite := FOleClientSite;
  Result := S_OK;
end;

function TActiveXControl2.SetHostNames(szContainerApp: POleStr;
  szContainerObj: POleStr): HResult;
begin
  Result := S_OK;
end;

function TActiveXControl2.Close(dwSaveOption: Longint): HResult;
begin
  if (dwSaveOption <> OLECLOSE_NOSAVE) and FIsDirty and
    (FOleClientSite <> nil) then FOleClientSite.SaveObject;
  if (self is TActiveFormControl2)
   then if  (TActiveFormControl2(self).Control is TActiveForm)
     then
       TActiveForm2(TActiveFormControl2(self).Control).DoDestroy;
  Result := InPlaceDeactivate;
end;

function TActiveXControl2.SetMoniker(dwWhichMoniker: Longint; const mk: IMoniker): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
  out mk: IMoniker): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.InitFromData(const dataObject: IDataObject; fCreation: BOOL;
  dwReserved: Longint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.GetClipboardData(dwReserved: Longint;
  out dataObject: IDataObject): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.DoVerb(iVerb: Longint; msg: PMsg; const activeSite: IOleClientSite;
  lindex: Longint; hwndParent: HWND; const posRect: TRect): HResult;
begin
  try
    case iVerb of
      OLEIVERB_SHOW,
      OLEIVERB_UIACTIVATE:
        Result := InPlaceActivate(True);
      OLEIVERB_INPLACEACTIVATE:
        Result := InPlaceActivate(False);
      OLEIVERB_HIDE:
        begin
          FWinControl.Visible := False;
          Result := S_OK;
        end;
      OLEIVERB_PRIMARY,
      OLEIVERB_PROPERTIES:
        begin
          ShowPropertyDialog;
          Result := S_OK;
        end;
    else
      if FControlFactory.FVerbs.IndexOfObject(TObject(iVerb)) >= 0 then
      begin
        PerformVerb(iVerb);
        Result := S_OK;
      end else
        Result := OLEOBJ_S_INVALIDVERB;
    end;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl2.EnumVerbs(out enumOleVerb: IEnumOleVerb): HResult;
begin
  Result := OleRegEnumVerbs(Factory.ClassID, enumOleVerb);
end;

function TActiveXControl2.Update: HResult;
begin
  Result := S_OK;
end;

function TActiveXControl2.IsUpToDate: HResult;
begin
  Result := S_OK;
end;

function TActiveXControl2.GetUserClassID(out clsid: TCLSID): HResult;
begin
  clsid := Factory.ClassID;
  Result := S_OK;
end;

function TActiveXControl2.GetUserType(dwFormOfType: Longint; out pszUserType: POleStr): HResult;
begin
  Result := OleRegGetUserType(Factory.ClassID, dwFormOfType, pszUserType);
end;

function TActiveXControl2.SetExtent(dwDrawAspect: Longint; const size: TPoint): HResult;
var
  W, H: Integer;
begin
  try
    if dwDrawAspect <> DVASPECT_CONTENT then OleError(DV_E_DVASPECT);
    W := MulDiv(Size.X, Screen.PixelsPerInch, 2540);
    H := MulDiv(Size.Y, Screen.PixelsPerInch, 2540);
    with FWinControl do SetBounds(Left, Top, W, H);
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl2.GetExtent(dwDrawAspect: Longint; out size: TPoint): HResult;
begin
  if dwDrawAspect <> DVASPECT_CONTENT then
  begin
    Result := DV_E_DVASPECT;
    Exit;
  end;
  Size.X := MulDiv(FWinControl.Width, 2540, Screen.PixelsPerInch);
  Size.Y := MulDiv(FWinControl.Height, 2540, Screen.PixelsPerInch);
  Result := S_OK;
end;

function TActiveXControl2.Advise(const advSink: IAdviseSink; out dwConnection: Longint): HResult;
begin
  Result := CreateAdviseHolder;
  if Result = S_OK then
    Result := FOleAdviseHolder.Advise(advSink, dwConnection);
end;

function TActiveXControl2.Unadvise(dwConnection: Longint): HResult;
begin
  Result := CreateAdviseHolder;
  if Result = S_OK then
    Result := FOleAdviseHolder.Unadvise(dwConnection);
end;

function TActiveXControl2.EnumAdvise(out enumAdvise: IEnumStatData): HResult;
begin
  Result := CreateAdviseHolder;
  if Result = S_OK then
    Result := FOleAdviseHolder.EnumAdvise(enumAdvise);
end;

function TActiveXControl2.GetMiscStatus(dwAspect: Longint; out dwStatus: Longint): HResult;
begin
  if dwAspect <> DVASPECT_CONTENT then
  begin
    Result := DV_E_DVASPECT;
    Exit;
  end;
  dwStatus := FControlFactory.FMiscStatus;
  Result := S_OK;
end;

function TActiveXControl2.SetColorScheme(const logpal: TLogPalette): HResult;
begin
  Result := E_NOTIMPL;
end;

{ TActiveXControl.IOleControl }

function TActiveXControl2.GetControlInfo(var ci: TControlInfo): HResult;
begin
  with ci do
  begin
    cb := SizeOf(ci);
    hAccel := 0;
    cAccel := 0;
    dwFlags := 0;
  end;
  Result := S_OK;
end;

function TActiveXControl2.OnMnemonic(msg: PMsg): HResult;
begin
  Result := InPlaceActivate(True);
end;

function TActiveXControl2.OnAmbientPropertyChange(dispid: TDispID): HResult;
var
  Font: TFont;
begin
  if (FWinControl <> nil) and (FAmbientDispatch <> nil) then
  begin
    try
      FWinControl.Perform(CM_PARENTCOLORCHANGED, 1, FAmbientDispatch.BackColor);
    except
    end;
    FWinControl.Perform(CM_PARENTCTL3DCHANGED, 1, 1);
    Font := TFont.Create;
    try
      Font.Color := FAmbientDispatch.ForeColor;
      SetOleFont(Font, FAmbientDispatch.Font);
      FWinControl.Perform(CM_PARENTFONTCHANGED, 1, Integer(Font));
    except
    end;
    Font.Free;
  end;
  Result := S_OK;  //OnAmbientPropChange MUST return S_OK in all cases.
end;

function TActiveXControl2.FreezeEvents(bFreeze: BOOL): HResult;
begin
  FEventsFrozen := bFreeze;
  Result := S_OK;
end;

{ TActiveXControl.IOleWindow }

function TActiveXControl2.GetWindow(out wnd: HWnd): HResult;
begin
  if FWinControl.HandleAllocated then
  begin
    wnd := FWinControl.Handle;
    Result := S_OK;
  end else
    Result := E_FAIL;
end;

function TActiveXControl2.ContextSensitiveHelp(fEnterMode: BOOL): HResult;
begin
  Result := E_NOTIMPL;
end;

{ TActiveXControl.IOleInPlaceObject }

function TActiveXControl2.InPlaceDeactivate: HResult;
begin
  if FInPlaceActive then
  begin
    FInPlaceActive := False;
    UIDeactivate;
    FWinControl.Visible := False;
    FWinControl.ParentWindow := ParkingWindow;
    FOleInPlaceUIWindow := nil;
    FOleInPlaceFrame := nil;
    FOleInPlaceSite.OnInPlaceDeactivate;
    FOleInPlaceSite := nil;
  end;
  FWinControl.Visible := False;
  Result := S_OK;
end;

function TActiveXControl2.UIDeactivate: HResult;
begin
  if FUIActive then
  begin
    FUIActive := False;
    if FOleInPlaceUIWindow <> nil then
      FOleInPlaceUIWindow.SetActiveObject(nil, nil);
    FOleInPlaceFrame.SetActiveObject(nil, nil);
    FOleInPlaceSite.OnUIDeactivate(False);
  end;
  Result := S_OK;
end;

function TActiveXControl2.SetObjectRects(const rcPosRect: TRect;
  const rcClipRect: TRect): HResult;
var
  IntersectionRect: TRect;
  NewRegion: HRGN;
begin
  try
    if (@rcPosRect = nil) or (@rcClipRect = nil) then
    begin
      Result := E_POINTER;
      Exit;
    end
    else if FWinControl.HandleAllocated then
    begin
      // The container thinks the control should clip, figure out if the control
      // really needs to clip.
      NewRegion := 0;

      if IntersectRect(IntersectionRect, rcPosRect, rcClipRect) and
         (not EqualRect(IntersectionRect, rcPosRect)) then
      begin
        OffsetRect(IntersectionRect, -rcPosRect.Left, -rcPosRect.Top);
        NewRegion := CreateRectRgnIndirect(IntersectionRect);
      end;

      // Set the control's location.
      SetWindowRgn(FWinControl.Handle, NewRegion, True);
      FWinControl.BoundsRect := rcPosRect;
    end;

    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl2.ReactivateAndUndo: HResult;
begin
  Result := E_NOTIMPL;
end;

{ TActiveXControl.IOleInPlaceActiveObject }

function TActiveXControl2.TranslateAccelerator(var msg: TMsg): HResult;
var
  Control: TWinControl;
  Form: TCustomForm;
  HWindow: THandle;
  Mask: Integer;
begin
  with Msg do
    if (Message >= WM_KEYFIRST) and (Message <= WM_KEYLAST) then
    begin
      Control := FindControl(HWnd);
      if Control = nil then
      begin
        HWindow := HWnd;
        repeat
          HWindow := GetParent(HWindow);
          if HWindow <> 0 then Control := FindControl(HWindow);
        until (HWindow = 0) or (Control <> nil);
      end;
      if Control <> nil then
      begin
        Result := S_OK;
        if (Message = WM_KEYDOWN) and (Control.Perform(CM_CHILDKEY, wParam, Integer(Control)) <> 0) then Exit;
        Mask := 0;
        case wParam of
          VK_TAB:
            Mask := DLGC_WANTTAB;
          VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_HOME, VK_END:
            Mask := DLGC_WANTARROWS;
          VK_RETURN, VK_EXECUTE, VK_ESCAPE, VK_CANCEL:
            Mask := DLGC_WANTALLKEYS;
        end;
        if (Mask <> 0) and
          ((Control.Perform(CM_WANTSPECIALKEY, wParam, 0) <> 0) or
          (Control.Perform(WM_GETDLGCODE, 0, 0) and Mask <> 0)) then
        begin
          TranslateMessage(msg);
          DispatchMessage(msg);
          Exit;
        end;
        if (Message = WM_KEYDOWN) and (Control.Parent <> nil) then
          Form := GetParentForm(Control)
        else
          Form := nil;
        if (Form <> nil) and (Form.Perform(CM_DIALOGKEY, wParam, lParam) = 1) then
          Exit;
      end;
    end;
  if FOleControlSite <> nil then
    Result := FOleControlSite.TranslateAccelerator(@msg, GetKeyModifiers)
  else
    Result := S_FALSE;
end;

function TActiveXControl2.OnFrameWindowActivate(fActivate: BOOL): HResult;
begin
  Result := InPlaceActivate(True);
end;

function TActiveXControl2.OnDocWindowActivate(fActivate: BOOL): HResult;
begin
  Result := InPlaceActivate(True);
end;

function TActiveXControl2.ResizeBorder(const rcBorder: TRect; const uiWindow: IOleInPlaceUIWindow;
  fFrameWindow: BOOL): HResult;
begin
  Result := S_OK;
end;

function TActiveXControl2.EnableModeless(fEnable: BOOL): HResult;
begin
  Result := S_OK;
end;

{ TActiveXControl.IViewObject }

function TActiveXControl2.Draw(dwDrawAspect: Longint; lindex: Longint; pvAspect: Pointer;
  ptd: PDVTargetDevice; hicTargetDev: HDC; hdcDraw: HDC;
  prcBounds: PRect; prcWBounds: PRect; fnContinue: TContinueFunc;
  dwContinue: Longint): HResult;
var
  R: TRect;
  SaveIndex: Integer;
  WasVisible: Boolean;
begin
  try
    if dwDrawAspect <> DVASPECT_CONTENT then OleError(DV_E_DVASPECT);
    WasVisible := FControl.Visible;
    try
      FControl.Visible := True;
      ShowWindow(FWinControl.Handle, 1);
      R := prcBounds^;
      LPToDP(hdcDraw, R, 2);
      SaveIndex := SaveDC(hdcDraw);
      try
        SetViewportOrgEx(hdcDraw, 0, 0, nil);
        SetWindowOrgEx(hdcDraw, 0, 0, nil);
        SetMapMode(hdcDraw, MM_TEXT);
        FControl.PaintTo(hdcDraw, R.Left, R.Top);
      finally
        RestoreDC(hdcDraw, SaveIndex);
      end;
    finally
      FControl.Visible := WasVisible;
    end;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl2.GetColorSet(dwDrawAspect: Longint; lindex: Longint;
  pvAspect: Pointer; ptd: PDVTargetDevice; hicTargetDev: HDC;
  out colorSet: PLogPalette): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.Freeze(dwDrawAspect: Longint; lindex: Longint; pvAspect: Pointer;
  out dwFreeze: Longint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.Unfreeze(dwFreeze: Longint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.SetAdvise(aspects: Longint; advf: Longint;
  const advSink: IAdviseSink): HResult;
begin
  if aspects and DVASPECT_CONTENT = 0 then
  begin
    Result := DV_E_DVASPECT;
    Exit;
  end;
  FAdviseFlags := advf;
  FAdviseSink := advSink;
  if FAdviseFlags and ADVF_PRIMEFIRST <> 0 then ViewChanged;
  Result := S_OK;
end;

function TActiveXControl2.GetAdvise(pAspects: PLongint; pAdvf: PLongint;
  out advSink: IAdviseSink): HResult;
begin
  if pAspects <> nil then pAspects^ := DVASPECT_CONTENT;
  if pAdvf <> nil then pAdvf^ := FAdviseFlags;
  if @advSink <> nil then advSink := FAdviseSink;
  Result := S_OK;
end;

{ TActiveXControl.IViewObject2 }

function TActiveXControl2.ViewObjectGetExtent(dwDrawAspect: Longint; lindex: Longint;
  ptd: PDVTargetDevice; out size: TPoint): HResult;
begin
  Result := GetExtent(dwDrawAspect, size);
end;

{ TActiveXControl.IPerPropertyBrowsing }

function TActiveXControl2.GetDisplayString(dispid: TDispID;
  out bstr: WideString): HResult;
var
  S: string;
begin
  Result := E_NOTIMPL;
  if GetPropertyString( dispid, S ) then
  begin
    bstr := S;
    Result := S_OK;
  end;
end;

function TActiveXControl2.MapPropertyToPage(dispid: TDispID;
  out clsid: TCLSID): HResult;
begin
  if @clsid <> nil then clsid := GUID_NULL;
  Result := E_NOTIMPL; {!!!}
end;

function TActiveXControl2.GetPredefinedStrings(dispid: TDispID;
  out caStringsOut: TCAPOleStr; out caCookiesOut: TCALongint): HResult;
var
  StringList: POleStrList;
  CookieList: PLongintList;
  Strings: TStringList;
  Count, I: Integer;
begin
  StringList := nil;
  CookieList := nil;
  Count := 0;
  if (@CaStringsOut = nil) or (@CaCookiesOut = nil) then
  begin
    Result := E_POINTER;
    Exit;
  end;
  caStringsOut.cElems := 0;
  caStringsOut.pElems := nil;
  caCookiesOut.cElems := 0;
  caCookiesOut.pElems := nil;

  try
    Strings := TStringList.Create;
    try
      if GetPropertyStrings(dispid, Strings) then
      begin
        Count := Strings.Count;
        StringList := CoAllocMem(Count * SizeOf(Pointer));
        CookieList := CoAllocMem(Count * SizeOf(Longint));
        for I := 0 to Count - 1 do
        begin
          StringList[I] := CoAllocString(Strings[I]);
          CookieList[I] := Longint(Strings.Objects[I]);
        end;
        caStringsOut.cElems := Count;
        caStringsOut.pElems := StringList;
        caCookiesOut.cElems := Count;
        caCookiesOut.pElems := CookieList;
        Result := S_OK;
      end else
        Result := E_NOTIMPL;
    finally
      Strings.Free;
    end;
  except
    if StringList <> nil then
      for I := 0 to Count - 1 do CoFreeMem(StringList[I]);
    CoFreeMem(CookieList);
    CoFreeMem(StringList);
    Result := HandleException;
  end;
end;

function TActiveXControl2.GetPredefinedValue(dispid: TDispID;
  dwCookie: Longint; out varOut: OleVariant): HResult;
var
  Temp: OleVariant;
begin
  GetPropertyValue(dispid, dwCookie, Temp);
  varOut := Temp;
  Result := S_OK;
end;

{ TActiveXControl.ISpecifyPropertyPages }

type
  TPropPages2 = class
  private
    FGUIDList: PGUIDList;
    FCount: Integer;
    procedure ProcessPage(const GUID: TGUID);
  end;

procedure TPropPages2.ProcessPage(const GUID: TGUID);
begin
  if FGUIDList <> nil then FGUIDList[FCount] := GUID;
  Inc(FCount);
end;

function TActiveXControl2.GetPages(out pages: TCAGUID): HResult;
var
  PropPages: TPropPages2;
begin
  try
    PropPages := TPropPages2.Create;
    try
      DefinePropertyPages(PropPages.ProcessPage);
      PropPages.FGUIDList := CoAllocMem(PropPages.FCount * SizeOf(TGUID));
      PropPages.FCount := 0;
      DefinePropertyPages(PropPages.ProcessPage);
      pages.cElems := PropPages.FCount;
      pages.pElems := PropPages.FGUIDList;
      PropPages.FGUIDList := nil;
    finally
      if PropPages.FGUIDList <> nil then CoFreeMem(PropPages.FGUIDList);
      PropPages.Free;
    end;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

{ ISimpleFrameSite }

function TActiveXControl2.PreMessageFilter(wnd: HWnd; msg, wp, lp: Integer;
 out res: Integer; out Cookie: Longint): HResult;
begin
  if FSimpleFrameSite <> nil then
    Result := FSimpleFrameSite.PreMessageFilter(wnd, msg, wp, lp, res, Cookie)
  else
    Result := S_OK;
end;

function TActiveXControl2.PostMessageFilter(wnd: HWnd; msg, wp, lp: Integer;
  out res: Integer; Cookie: Longint): HResult;
begin
  if FSimpleFrameSite <> nil then
    Result := FSimpleFrameSite.PostMessageFilter(wnd, msg, wp, lp, res, Cookie)
  else
    Result := S_OK;
end;

{ IQuickActivate }

function TActiveXControl2.QuickActivate(var qaCont: TQaContainer; var qaCtrl: TQaControl): HResult; stdcall;
var
  Connections: IConnectionPointContainer;
  EventConnection: IConnectionPoint;
  PropConnection: IConnectionPoint;
begin
   // Verify that caller allocated enough space
  if qaCtrl.cbSize < SizeOf(TQaControl) then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  // Initialize TQaControl structure
  FillChar(qaCtrl, SizeOf(TQaControl), 0);
  qaCtrl.cbSize := SizeOf(TQaControl);
  // Set ClientSite
  SetClientSite(qaCont.pClientSite);
  // Set Advise Sink
  if qaCont.pAdviseSink <> nil then
    SetAdvise(DVASPECT_CONTENT, 0, qaCont.pAdviseSink);
  // Grab ConnectionPointContainer
  Connections := Self as IConnectionPointContainer;
  // Hook up Property Notify Sink
  if qaCont.pPropertyNotifySink <> nil then
  begin
    if Connections.FindConnectionPoint(IPropertyNotifySink, EventConnection) = S_OK then
      EventConnection.Advise(qaCont.pPropertyNotifySink, qaCtrl.dwPropNotifyCookie);
  end;
  // Hook up default outgoing interface
  if qaCont.pUnkEventSink <> nil then
  begin
    if Connections.FindConnectionPoint(FControlFactory.EventIID, PropConnection) = S_OK then
      PropConnection.Advise(qaCont.pUnkEventSink, qaCtrl.dwEventCookie);
  end;
  // Give information to Container
  GetMiscStatus(DVASPECT_CONTENT, qaCtrl.dwMiscStatus);
  // Return SUCCESS
  Result := S_OK;
end;

function TActiveXControl2.SetContentExtent(const sizel: TPoint): HResult; stdcall;
begin
  Result := SetExtent(DVASPECT_CONTENT, sizel);
end;

function TActiveXControl2.GetContentExtent(out sizel: TPoint): HResult; stdcall;
begin
  Result := GetExtent(DVASPECT_CONTENT, sizel);
end;


{ IDataObject }

function TActiveXControl2.GetData(const formatetcIn: TFormatEtc;
  out medium: TStgMedium): HResult; stdcall;
var
  sizeMetric: TPoint;
  dc: HDC;
  hMF: HMetafile;
  hMem: THandle;
  pMFP: PMetafilePict;
  SaveVisible: Boolean;
  BM: TBitmap;
begin
  // Handle only MetaFile
  if (formatetcin.tymed and TYMED_MFPICT) = 0 then
  begin
    Result := DV_E_FORMATETC;
    Exit;
  end;
  // Retrieve Extent
  GetExtent(DVASPECT_CONTENT, sizeMetric);
  // Create Metafile DC and set it up
  dc := CreateMetafile(nil);
  SetWindowOrgEx(dc, 0, 0, nil);
  SetWindowExtEx(dc, sizemetric.X, sizemetric.Y, nil);
  // Have Control paint to DC and get metafile handle
  SaveVisible := FControl.Visible;
  try
    FControl.Visible := True;
    BM := TBitmap.Create;
    try
      BM.Width := FControl.Width;
      BM.Height := FControl.Height;
      FControl.PaintTo(BM.Canvas.Handle, 0, 0);
      StretchBlt(dc, 0, 0, sizeMetric.X, sizeMetric.Y,
        BM.Canvas.Handle, 0, 0, BM.Width, BM.Height, SRCCOPY);
    finally
      BM.Free;
    end;
  finally
    FControl.Visible := SaveVisible;
  end;
  hMF := CloseMetaFile(dc);
  if hMF = 0 then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;

  // Get memory handle
  hMEM := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE, sizeof(METAFILEPICT));
  if hMEM = 0 then
  begin
    DeleteMetafile(hMF);
    Result := STG_E_MEDIUMFULL;
    Exit;
  end;
  pMFP := PMetaFilePict(GlobalLock(hMEM));
  pMFP^.hMF  := hMF;
  pMFP^.mm   := MM_ANISOTROPIC;
  pMFP^.xExt := sizeMetric.X;
  pMFP^.yExt := sizeMetric.Y;
  GlobalUnlock(hMEM);

  medium.tymed := TYMED_MFPICT;
  medium.hGlobal := hMEM;
  medium.UnkForRelease := nil;

  Result := S_OK;
end;

function TActiveXControl2.GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium):
  HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.QueryGetData(const formatetc: TFormatEtc): HResult;
  stdcall;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.GetCanonicalFormatEtc(const formatetc: TFormatEtc;
  out formatetcOut: TFormatEtc): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
  fRelease: BOOL): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.EnumFormatEtc(dwDirection: Longint; out enumFormatEtc:
  IEnumFormatEtc): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl2.DAdvise(const formatetc: TFormatEtc; advf: Longint;
  const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
begin
  Result := S_OK;
  if FDataAdviseHolder = nil then
    Result := CreateDataAdviseHolder(FDataAdviseHolder);
  if Result = S_OK then
    Result := FDataAdviseHolder.Advise(Self, formatetc, advf, advSink, dwConnection);
end;

function TActiveXControl2.DUnadvise(dwConnection: Longint): HResult; stdcall;
begin
  if FDataAdviseHolder = nil then
    Result := OLE_E_NOCONNECTION
  else
    Result := FDataAdviseHolder.Unadvise(dwConnection);
end;

function TActiveXControl2.EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
  stdcall;
begin
  if FDataAdviseHolder = nil then
    Result := E_FAIL
  else
    Result := FDataAdviseHolder.EnumAdvise(enumAdvise);
end;


{ TActiveXControlFactory2 }

constructor TActiveXControlFactory2.Create(ComServer: TComServerObject;
  ActiveXControlClass: TActiveXControl2Class;
  WinControlClass: TWinControlClass; const ClassID: TGUID;
  ToolboxBitmapID: Integer; const LicStr: string; MiscStatus: Integer;
  ThreadingModel: TThreadingModel);
begin
  FWinControlClass := WinControlClass;
  inherited Create(ComServer, ActiveXControlClass, ClassID, ciMultiInstance,
    ThreadingModel);
  FMiscStatus := MiscStatus or
    OLEMISC_RECOMPOSEONRESIZE or
    OLEMISC_CANTLINKINSIDE or
    OLEMISC_INSIDEOUT or
    OLEMISC_ACTIVATEWHENVISIBLE or
    OLEMISC_SETCLIENTSITEFIRST;
  FToolboxBitmapID := ToolboxBitmapID;
  FVerbs := TStringList.Create;
  AddVerb(OLEIVERB_PRIMARY, SPropertiesVerb);
  LicString := LicStr;
  SupportsLicensing := LicStr <> '';
  FLicFileStrings := TStringList.Create;
end;

destructor TActiveXControlFactory2.Destroy;
begin
  FVerbs.Free;
  FLicFileStrings.Free;
  inherited Destroy;
end;

procedure TActiveXControlFactory2.AddVerb(Verb: Integer;
  const VerbName: string);
begin
  FVerbs.AddObject(VerbName, TObject(Verb));
end;

function TActiveXControlFactory2.GetLicenseFileName: string;
begin
  Result := ChangeFileExt(ComServer.ServerFileName, '.lic');
end;

function TActiveXControlFactory2.HasMachineLicense: Boolean;
var
  i: Integer;
begin
  Result := True;
  if not SupportsLicensing then Exit;
  if not FLicenseFileRead then
  begin
    try
      FLicFileStrings.LoadFromFile(GetLicenseFileName);
      FLicenseFileRead := True;
    except
      Result := False;
    end;
  end;
  if Result then
  begin
    i := 0;
    Result := False;
    while (i < FLicFileStrings.Count) and (not Result) do
    begin
      Result := ValidateUserLicense(FLicFileStrings[i]);
      inc(i);
    end;
  end;
end;

procedure TActiveXControlFactory2.UpdateRegistry(Register: Boolean);
var
  ClassKey: string;
  I: Integer;
begin
  ClassKey := 'CLSID\' + GUIDToString(ClassID);
  if Register then
  begin
    inherited UpdateRegistry(Register);
    CreateRegKey(ClassKey + '\MiscStatus', '', '0');
    CreateRegKey(ClassKey + '\MiscStatus\1', '', IntToStr(FMiscStatus));
    CreateRegKey(ClassKey + '\ToolboxBitmap32', '',
      ComServer.ServerFileName + ',' + IntToStr(FToolboxBitmapID));
    CreateRegKey(ClassKey + '\Control', '', '');
    CreateRegKey(ClassKey + '\Verb', '', '');
    for I := 0 to FVerbs.Count - 1 do
      CreateRegKey(ClassKey + '\Verb\' + IntToStr(Integer(FVerbs.Objects[I])),
        '', FVerbs[I] + ',0,2');
  end else
  begin
    for I := 0 to FVerbs.Count - 1 do
      DeleteRegKey(ClassKey + '\Verb\' + IntToStr(Integer(FVerbs.Objects[I])));
    DeleteRegKey(ClassKey + '\Verb');
    DeleteRegKey(ClassKey + '\Control');
    DeleteRegKey(ClassKey + '\ToolboxBitmap32');
    DeleteRegKey(ClassKey + '\MiscStatus\1');
    DeleteRegKey(ClassKey + '\MiscStatus');
    inherited UpdateRegistry(Register);
  end;
end;

{ TActiveFormControl2 }

procedure TActiveFormControl2.DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
begin
  if FControl is TActiveForm then
    TActiveForm2(FControl).DefinePropertyPages(DefinePropertyPage);
end;

procedure TActiveFormControl2.FreeOnRelease;
begin
end;

procedure TActiveFormControl2.InitializeControl;
begin
  inherited InitializeControl;
  FControl.VCLComObject := Pointer(Self as IVCLComObject);
  if FControl is TActiveForm then
  begin
    TActiveForm2(FControl).FActiveFormControl := Self;
    TActiveForm2(FControl).Initialize;
  end;
end;

function TActiveFormControl2.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
const
  INVOKE_PROPERTYSET = INVOKE_PROPERTYPUT or INVOKE_PROPERTYPUTREF;
begin
  if Flags and INVOKE_PROPERTYSET <> 0 then Flags := INVOKE_PROPERTYSET;
  Result := TAutoObjectFactory(Factory).DispTypeInfo.Invoke(Pointer(
    Integer(Control) + TAutoObjectFactory(Factory).DispIntfEntry.IOffset),
    DispID, Flags, TDispParams(Params), VarResult, ExcepInfo, ArgErr);
end;

function TActiveFormControl2.ObjQueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := S_OK;
  if IsEqualGUID(IID, IUnknown) or not Control.GetInterface(IID, Obj) then
    Result := inherited ObjQueryInterface(IID, Obj);
end;

procedure TActiveFormControl2.EventSinkChanged(const EventSink: IUnknown);
begin
  if (Control is TActiveForm) then
    TActiveForm2(Control).EventSinkChanged(EventSink);
end;

{ TActiveForm }

procedure TActiveForm2.DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
begin
end;

procedure TActiveForm2.DoDestroy;
begin
  if Assigned(OnDestroy) then
  try
    OnDestroy(Self);
    OnDestroy := nil;
  except
    Application.HandleException(Self);
  end;
end;

procedure TActiveForm2.EventSinkChanged(const EventSink: IUnknown);
begin
  if (FSinkChangeCount = 0) and (EventSink <> nil) then
    DoCreate;
  InterLockedIncrement(FSinkChangeCount);
end;

procedure TActiveForm2.Initialize;
begin
end;

{ TActiveFormFactory2 }

function TActiveFormFactory2.GetIntfEntry(Guid: TGUID): PInterfaceEntry;
begin
  Result := WinControlClass.GetInterfaceEntry(Guid);
end;

/////////////////////////////////////////////////////

{ TActiveXPropertyPage }

destructor TActiveXPropertyPage2.Destroy;
begin
  FPropertyPageImpl.FPropertyPage.Free;
  FPropertyPageImpl.Free;
  inherited Destroy;
end;

procedure TActiveXPropertyPage2.Initialize;
begin
  FPropertyPageImpl := TPropertyPageImpl2.Create(Self);
  FPropertyPageImpl.FPropertyPage := TPropertyPageClass2(Factory.ComClass).Create(nil);
  FPropertyPageImpl.InitPropertyPage;
end;

{ TActiveXPropertyPageFactory2 }

constructor TActiveXPropertyPageFactory2.Create(ComServer: TComServerObject;
  PropertyPageClass: TPropertyPageClass2; const ClassID: TGUID);
begin
  inherited Create(ComServer, TComClass(PropertyPageClass), ClassID,
    '', Format('%s property page', [PropertyPageClass.ClassName]),
    ciMultiInstance);
end;

function TActiveXPropertyPageFactory2.CreateComObject(
  const Controller: IUnknown): TComObject;
begin
  Result := TActiveXPropertyPage2.CreateFromFactory(Self, Controller);
end;


{ TPropertyPageImpl }

procedure TPropertyPageImpl2.InitPropertyPage;
begin
  FPropertyPage.FActiveXPropertyPage := Self;
  FPropertyPage.BorderStyle := bsNone;
  FPropertyPage.Position := poDesigned;
end;

procedure TPropertyPageImpl2.Modified;
begin
  if FActive then
  begin
    FModified := True;
    if FPageSite <> nil then
      FPageSite.OnStatusChange(PROPPAGESTATUS_DIRTY or PROPPAGESTATUS_VALIDATE);
  end;
end;

{ TPropertyPageImpl2.IPropertyPage }

function TPropertyPageImpl2.SetPageSite(const pageSite: IPropertyPageSite): HResult;
begin
  FPageSite := pageSite;
  Result := S_OK;
end;

function TPropertyPageImpl2.Activate(hwndParent: HWnd; const rc: TRect;
  bModal: BOOL): HResult;
begin
  try
    FPropertyPage.BoundsRect := rc;
    FPropertyPage.ParentWindow := hwndParent;
    if not VarIsNull(FPropertyPage.FOleObject) then
      FPropertyPage.UpdatePropertyPage;
    FActive:= True;
    FModified := False;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TPropertyPageImpl2.Deactivate: HResult;
begin
  try
    FActive := False;
    FPropertyPage.Hide;
    FPropertyPage.ParentWindow := 0;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TPropertyPageImpl2.GetPageInfo(out pageInfo: TPropPageInfo): HResult;
begin
  try
    FillChar(pageInfo.pszTitle, SizeOf(pageInfo) - 4, 0);
    pageInfo.pszTitle := CoAllocString(FPropertyPage.Caption);
    pageInfo.size.cx := FPropertyPage.Width;
    pageInfo.size.cy := FPropertyPage.Height;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TPropertyPageImpl2.SetObjects(cObjects: Longint;
  pUnkList: PUnknownList): HResult;
begin
  try
    FPropertyPage.FOleObject := Null;
    FPropertyPage.FOleObjects.Clear;
    if pUnkList = nil then
    begin
      Result := E_POINTER;
      Exit;
    end;
    if cObjects > 0 then
    begin
      FPropertyPage.FOleObjects.Add(pUnkList[0]);
      FPropertyPage.FOleObject := pUnkList[0] as IDispatch;
    end;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TPropertyPageImpl2.Show(nCmdShow: Integer): HResult;
begin
  try
    FPropertyPage.Visible := nCmdShow <> SW_HIDE;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TPropertyPageImpl2.Move(const rect: TRect): HResult;
begin
  try
    FPropertyPage.BoundsRect := rect;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TPropertyPageImpl2.IsPageDirty: HResult;
begin
  if FModified then Result := S_OK else Result := S_FALSE;
end;

function TPropertyPageImpl2.Apply: HResult;

  procedure NotifyContainerOfApply;
  var
    OleObject: IUnknown;
    Connections: IConnectionPointContainer;
    Connection: IConnectionPoint;
    Enum: IEnumConnections;
    ConnectData: TConnectData;
    Fetched: Longint;
  begin
    { VB seems to wait for an OnChange call along a IPropetyNotifySink before
      it will update its property inspector. }
    OleObject := IUnknown(FPropertyPage.FOleObject);
    if OleObject.QueryInterface(IConnectionPointContainer, Connections) = S_OK then
      if Connections.FindConnectionPoint(IPropertyNotifySink, Connection) = S_OK then
      begin
        OleCheck(Connection.EnumConnections(Enum));
        while Enum.Next(1, ConnectData, @Fetched) = S_OK do
        begin
          (ConnectData.pUnk as IPropertyNotifySink).OnChanged(DISPID_UNKNOWN);
          ConnectData.pUnk := nil;
        end;
      end;
  end;

begin
  try
    FPropertyPage.UpdateObject;
    FModified := False;
    NotifyContainerOfApply;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TPropertyPageImpl2.Help(pszHelpDir: POleStr): HResult;
begin
  Result := E_NOTIMPL;
end;

function TPropertyPageImpl2.TranslateAccelerator(msg: PMsg): HResult;
begin
  try
    { For some reason VB bashes WS_EX_CONTROLPARENT, set it back }
    if FPropertyPage.WindowHandle <> 0 then
    begin
      SetWindowLong(FPropertyPage.Handle, GWL_EXSTYLE,
        GetWindowLong(FPropertyPage.Handle, GWL_EXSTYLE) or
        WS_EX_CONTROLPARENT);
    end;
    {!!!}
    Result := S_FALSE;
  except
    Result := HandleException;
  end;
end;

{ TPropertyPageImpl2.IPropertyPage2 }

function TPropertyPageImpl2.EditProperty(dispid: TDispID): HResult;
begin
  Result := E_NOTIMPL; {!!!}
end;

{ TPropertyPage }

constructor TPropertyPage2.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOleObjects := TInterfaceList.Create;
end;

destructor TPropertyPage2.Destroy;
begin
  FOleObjects.Free;
  inherited Destroy;
end;

procedure TPropertyPage2.CMChanged(var Msg: TCMChanged);
begin
  Modified;
end;

procedure TPropertyPage2.Modified;
begin
  if Assigned(FActiveXPropertyPage) then FActiveXPropertyPage.Modified;
end;

procedure TPropertyPage2.UpdateObject;
begin
end;

procedure TPropertyPage2.EnumCtlProps(PropType: TGUID; PropNames: TStrings);
begin
  EnumDispatchProperties(IUnknown(FOleObject) as IDispatch, PropType, VT_EMPTY,
    PropNames);
end;

procedure TPropertyPage2.UpdatePropertyPage;
begin
end;

{ TCustomAdapter2 }

constructor TCustomAdapter2.Create;
begin
  inherited Create;
  FNotifier := TAdapterNotifier2.Create(Self);
end;

destructor TCustomAdapter2.Destroy;
begin
  ReleaseOleObject;
  inherited Destroy;
end;

procedure TCustomAdapter2.Changed;
begin
  if not Updating then ReleaseOleObject;
end;

procedure TCustomAdapter2.ConnectOleObject(OleObject: IUnknown);
begin
  if FOleObject <> nil then ReleaseOleObject;
  if OleObject <> nil then
    InterfaceConnect(OleObject, IPropertyNotifySink, FNotifier, FConnection);
  FOleObject := OleObject;
end;

procedure TCustomAdapter2.ReleaseOleObject;
begin
  InterfaceDisconnect(FOleObject, IPropertyNotifySink, FConnection);
  FOleObject := nil;
end;

{ TAdapterNotifier2 }

constructor TAdapterNotifier2.Create(Adapter: TCustomAdapter2);
begin
  inherited Create;
  FAdapter := Adapter;
end;

{ TAdapterNotifier2.IPropertyNotifySink }

function TAdapterNotifier2.OnChanged(dispid: TDispID): HResult;
begin
  try
    FAdapter.Update;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TAdapterNotifier2.OnRequestEdit(dispid: TDispID): HResult;
begin
  Result := S_OK;
end;
type
  TStringsEnumerator2 = class(TContainedObject, IEnumString)
  private
    FIndex: Integer;  // index of next unread string
    FStrings: IStrings;
  public
    constructor Create(const Strings: IStrings);
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enm: IEnumString): HResult; stdcall;
  end;

constructor TStringsEnumerator2.Create(const Strings: IStrings);
begin
  inherited Create(Strings);
  FStrings := Strings;
end;

function TStringsEnumerator2.Next(celt: Longint; out elt; pceltFetched: PLongint): HResult;
var
  I: Integer;
begin
  I := 0;
  while (I < celt) and (FIndex < FStrings.Count) do
  begin
    TPointerList(elt)[I] := PWideChar(WideString(FStrings.Item[I]));
    Inc(I);
    Inc(FIndex);
  end;
  if pceltFetched <> nil then pceltFetched^ := I;
  if I = celt then Result := S_OK else Result := S_FALSE;
end;

function TStringsEnumerator2.Skip(celt: Longint): HResult;
begin
  if (FIndex + celt) <= FStrings.Count then
  begin
    Inc(FIndex, celt);
    Result := S_OK;
  end
  else
  begin
    FIndex := FStrings.Count;
    Result := S_FALSE;
  end;
end;

function TStringsEnumerator2.Reset: HResult;
begin
  FIndex := 0;
  Result := S_OK;
end;

function TStringsEnumerator2.Clone(out enm: IEnumString): HResult;
begin
  try
    enm := TStringsEnumerator2.Create(FStrings);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

end.





