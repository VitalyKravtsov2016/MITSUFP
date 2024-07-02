unit MitsuLib_TLB;

// ************************************************************************ //
// WARNING
// -------
// The types declared in this file were generated from data read from a
// Type Library. If this type library is explicitly or indirectly (via
// another type library referring to this type library) re-imported, or the
// 'Refresh' command of the Type Library Editor activated while editing the
// Type Library, the contents of this file will be regenerated and all
// manual modifications will be lost.
// ************************************************************************ //

// $Rev: 98336 $
// File generated on 02.07.2024 11:26:28 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\projects\Mitsu1C\Src\MitsuDrv1C\MitsuDrv1C (1)
// LIBID: {8C69BB55-8F17-4946-A0AD-4E9DF680F85A}
// LCID: 0
// Helpfile:
// HelpString: MITSU 1-F driver for 1C
// DepndLst:
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleCtrls, Vcl.OleServer, Winapi.ActiveX;



// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  MitsuLibMajorVersion = 1;
  MitsuLibMinorVersion = 0;

  LIBID_MitsuLib: TGUID = '{8C69BB55-8F17-4946-A0AD-4E9DF680F85A}';

  IID_IMitsu1C: TGUID = '{73B0EE0E-73F2-46EA-84AA-B47700462C1F}';
  CLASS_Mitsu1C: TGUID = '{0BFF23D1-7C0E-4D32-A52B-DBA98C86F76C}';
  IID_IMitsu1C11: TGUID = '{7B5D3811-BAA3-4714-AAE5-68469572E5D2}';
  CLASS_Mitsu1C11: TGUID = '{9042D8E2-BAC1-4060-B58E-5CA5D67FE23C}';
  IID_IMitsu1C17: TGUID = '{E2A613DA-1844-42C1-9C48-4A13E6804A6C}';
  CLASS_Mitsu1C17: TGUID = '{5E687886-93E8-4761-83E6-F255E02EDF14}';
  IID_IMitsu1C22: TGUID = '{46F19A5E-6E83-4448-B94B-02D5F0F64D9F}';
  CLASS_Mitsu1C22: TGUID = '{6E7FA51F-510C-47FC-9BA5-EC5A30B490A0}';
  IID_IMitsu1C30: TGUID = '{1CD466C1-DACD-47F0-BCBC-3897881C67A9}';
  CLASS_Mitsu1C30: TGUID = '{2A26DE93-F367-4CE8-95E3-51C539978AC8}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  IMitsu1C = interface;
  IMitsu1CDisp = dispinterface;
  IMitsu1C11 = interface;
  IMitsu1C11Disp = dispinterface;
  IMitsu1C17 = interface;
  IMitsu1C17Disp = dispinterface;
  IMitsu1C22 = interface;
  IMitsu1C22Disp = dispinterface;
  IMitsu1C30 = interface;
  IMitsu1C30Disp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  Mitsu1C = IMitsu1C;
  Mitsu1C11 = IMitsu1C11;
  Mitsu1C17 = IMitsu1C17;
  Mitsu1C22 = IMitsu1C22;
  Mitsu1C30 = IMitsu1C30;


// *********************************************************************//
// Interface: IMitsu1C
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {73B0EE0E-73F2-46EA-84AA-B47700462C1F}
// *********************************************************************//
  IMitsu1C = interface(IDispatch)
    ['{73B0EE0E-73F2-46EA-84AA-B47700462C1F}']
    function GetVersion: WideString; safecall;
    function GetLastError(out ErrorDescription: WideString): Integer; safecall;
    function Close(const DeviceID: WideString): WordBool; safecall;
    function PrintXReport(const DeviceID: WideString): WordBool; safecall;
    function PrintZReport(const DeviceID: WideString): WordBool; safecall;
    function CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool; safecall;
    function OpenCheck(const DeviceID: WideString; IsFiscalCheck: WordBool;
                       IsReturnCheck: WordBool; CancelOpenedCheck: WordBool;
                       out CheckNumber: Integer; out SessionNumber: Integer): WordBool; safecall;
    function PrintFiscalString(const DeviceID: WideString; const Name: WideString;
                               Quantity: Double; Price: Double; Amount: Double;
                               Department: Integer; Tax: Single): WordBool; safecall;
    function CloseCheck(const DeviceID: WideString; Cash: Double; PayByCard: Double;
                        PayByCredit: Double): WordBool; safecall;
    function CancelCheck(const DeviceID: WideString): WordBool; safecall;
    function PrintNonFiscalString(const DeviceID: WideString; const TextString: WideString): WordBool; safecall;
    function DeviceTest(const ValuesArray: IDispatch; out AdditionalDescription: WideString): WordBool; safecall;
    function Open(const ValuesArray: IDispatch; out DeviceID: WideString): WordBool; safecall;
    function CheckPrintingStatus(const DeviceID: WideString): WordBool; safecall;
    function ContinuePrinting(const DeviceID: WideString): WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString; CashDrawerID: Integer): WordBool; safecall;
    function LoadLogo(const ValuesArray: IDispatch; const LogoFileName: WideString;
                      CenterLogo: WordBool; out LogoSize: Integer;
                      out AdditionalDescription: WideString): WordBool; safecall;
    function OpenSession(const DeviceID: WideString): WordBool; safecall;
    function DeviceControl(const DeviceID: WideString; const TxData: WideString;
                           out RxData: WideString): WordBool; safecall;
    function DeviceControlHEX(const DeviceID: WideString; const TxData: WideString;
                              out RxData: WideString): WordBool; safecall;
    function Get_DiscountOnCheck: Double; safecall;
    procedure Set_DiscountOnCheck(Value: Double); safecall;
    function Get_PayType4: Double; safecall;
    procedure Set_PayType4(Value: Double); safecall;
    property DiscountOnCheck: Double read Get_DiscountOnCheck write Set_DiscountOnCheck;
    property PayType4: Double read Get_PayType4 write Set_PayType4;
  end;

// *********************************************************************//
// DispIntf:  IMitsu1CDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {73B0EE0E-73F2-46EA-84AA-B47700462C1F}
// *********************************************************************//
  IMitsu1CDisp = dispinterface
    ['{73B0EE0E-73F2-46EA-84AA-B47700462C1F}']
    function GetVersion: WideString; dispid 201;
    function GetLastError(out ErrorDescription: WideString): Integer; dispid 202;
    function Close(const DeviceID: WideString): WordBool; dispid 204;
    function PrintXReport(const DeviceID: WideString): WordBool; dispid 205;
    function PrintZReport(const DeviceID: WideString): WordBool; dispid 206;
    function CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool; dispid 207;
    function OpenCheck(const DeviceID: WideString; IsFiscalCheck: WordBool;
                       IsReturnCheck: WordBool; CancelOpenedCheck: WordBool;
                       out CheckNumber: Integer; out SessionNumber: Integer): WordBool; dispid 208;
    function PrintFiscalString(const DeviceID: WideString; const Name: WideString;
                               Quantity: Double; Price: Double; Amount: Double;
                               Department: Integer; Tax: Single): WordBool; dispid 209;
    function CloseCheck(const DeviceID: WideString; Cash: Double; PayByCard: Double;
                        PayByCredit: Double): WordBool; dispid 210;
    function CancelCheck(const DeviceID: WideString): WordBool; dispid 211;
    function PrintNonFiscalString(const DeviceID: WideString; const TextString: WideString): WordBool; dispid 212;
    function DeviceTest(const ValuesArray: IDispatch; out AdditionalDescription: WideString): WordBool; dispid 213;
    function Open(const ValuesArray: IDispatch; out DeviceID: WideString): WordBool; dispid 203;
    function CheckPrintingStatus(const DeviceID: WideString): WordBool; dispid 214;
    function ContinuePrinting(const DeviceID: WideString): WordBool; dispid 215;
    function OpenCashDrawer(const DeviceID: WideString; CashDrawerID: Integer): WordBool; dispid 216;
    function LoadLogo(const ValuesArray: IDispatch; const LogoFileName: WideString;
                      CenterLogo: WordBool; out LogoSize: Integer;
                      out AdditionalDescription: WideString): WordBool; dispid 217;
    function OpenSession(const DeviceID: WideString): WordBool; dispid 218;
    function DeviceControl(const DeviceID: WideString; const TxData: WideString;
                           out RxData: WideString): WordBool; dispid 219;
    function DeviceControlHEX(const DeviceID: WideString; const TxData: WideString;
                              out RxData: WideString): WordBool; dispid 220;
    property DiscountOnCheck: Double dispid 221;
    property PayType4: Double dispid 222;
  end;

// *********************************************************************//
// Interface: IMitsu1C11
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7B5D3811-BAA3-4714-AAE5-68469572E5D2}
// *********************************************************************//
  IMitsu1C11 = interface(IDispatch)
    ['{7B5D3811-BAA3-4714-AAE5-68469572E5D2}']
    function GetVersion: WideString; safecall;
    function GetDescription(out Name: WideString; out Description: WideString;
                            out EquipmentType: WideString; out InterfaceRevision: Integer;
                            out IntegrationLibrary: WordBool; out MainDriverInstalled: WordBool;
                            out GetDownloadURL: WideString): WordBool; safecall;
    function GetLastError(out ErrorDescription: WideString): Integer; safecall;
    function GetParameters(out TableParameters: WideString): WordBool; safecall;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool; safecall;
    function Open(out DeviceID: WideString): WordBool; safecall;
    function Close(const DeviceID: WideString): WordBool; safecall;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool; safecall;
    function GetAdditionalActions(out TableActions: WideString): WordBool; safecall;
    function DoAdditionalAction(const ActionName: WideString): WordBool; safecall;
    function OpenCheck(const DeviceID: WideString; IsFiscalCheck: WordBool;
                       IsReturnCheck: WordBool; CancelOpenedCheck: WordBool;
                       out CheckNumber: Integer; out SessionNumber: Integer): WordBool; safecall;
    function PrintFiscalString(const DeviceID: WideString; const Name: WideString;
                               Quantity: Double; Price: Double; Amount: Double;
                               Department: Integer; Tax: Double): WordBool; safecall;
    function PrintNonFiscalString(const DeviceID: WideString; const TextString: WideString): WordBool; safecall;
    function PrintBarCode(const DeviceID: WideString; const BarcodeType: WideString;
                          const BarCode: WideString): WordBool; safecall;
    function CloseCheck(const DeviceID: WideString; Cash: Double; PayByCard: Double;
                        PayByCredit: Double; PayByCertificate: Double): WordBool; safecall;
    function CancelCheck(const DeviceID: WideString): WordBool; safecall;
    function CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool; safecall;
    function PrintXReport(const DeviceID: WideString): WordBool; safecall;
    function PrintZReport(const DeviceID: WideString): WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; safecall;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool; safecall;
    procedure SetLang(LangID: Integer); safecall;
    function OpenShift(const DeviceID: WideString): WordBool; safecall;
    function PrintFiscalString2(const DeviceID: WideString; const Name: WideString;
                                Quantity: Double; Price: Double; Amount: Double;
                                Department: Integer; Tax1: Integer; Tax2: Integer; Tax3: Integer;
                                Tax4: Integer): WordBool; safecall;
    function ContinuePrinting(const DeviceID: WideString): WordBool; safecall;
    function CheckPrintingStatus(const DeviceID: WideString): WordBool; safecall;
    function DeviceControlHEX(const DeviceID: WideString; const TxData: WideString;
                              out RxData: WideString): WordBool; safecall;
  end;

// *********************************************************************//
// DispIntf:  IMitsu1C11Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7B5D3811-BAA3-4714-AAE5-68469572E5D2}
// *********************************************************************//
  IMitsu1C11Disp = dispinterface
    ['{7B5D3811-BAA3-4714-AAE5-68469572E5D2}']
    function GetVersion: WideString; dispid 201;
    function GetDescription(out Name: WideString; out Description: WideString;
                            out EquipmentType: WideString; out InterfaceRevision: Integer;
                            out IntegrationLibrary: WordBool; out MainDriverInstalled: WordBool;
                            out GetDownloadURL: WideString): WordBool; dispid 202;
    function GetLastError(out ErrorDescription: WideString): Integer; dispid 203;
    function GetParameters(out TableParameters: WideString): WordBool; dispid 204;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool; dispid 205;
    function Open(out DeviceID: WideString): WordBool; dispid 206;
    function Close(const DeviceID: WideString): WordBool; dispid 207;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool; dispid 208;
    function GetAdditionalActions(out TableActions: WideString): WordBool; dispid 209;
    function DoAdditionalAction(const ActionName: WideString): WordBool; dispid 210;
    function OpenCheck(const DeviceID: WideString; IsFiscalCheck: WordBool;
                       IsReturnCheck: WordBool; CancelOpenedCheck: WordBool;
                       out CheckNumber: Integer; out SessionNumber: Integer): WordBool; dispid 211;
    function PrintFiscalString(const DeviceID: WideString; const Name: WideString;
                               Quantity: Double; Price: Double; Amount: Double;
                               Department: Integer; Tax: Double): WordBool; dispid 212;
    function PrintNonFiscalString(const DeviceID: WideString; const TextString: WideString): WordBool; dispid 213;
    function PrintBarCode(const DeviceID: WideString; const BarcodeType: WideString;
                          const BarCode: WideString): WordBool; dispid 214;
    function CloseCheck(const DeviceID: WideString; Cash: Double; PayByCard: Double;
                        PayByCredit: Double; PayByCertificate: Double): WordBool; dispid 215;
    function CancelCheck(const DeviceID: WideString): WordBool; dispid 216;
    function CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool; dispid 217;
    function PrintXReport(const DeviceID: WideString): WordBool; dispid 218;
    function PrintZReport(const DeviceID: WideString): WordBool; dispid 219;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; dispid 220;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool; dispid 221;
    procedure SetLang(LangID: Integer); dispid 222;
    function OpenShift(const DeviceID: WideString): WordBool; dispid 223;
    function PrintFiscalString2(const DeviceID: WideString; const Name: WideString;
                                Quantity: Double; Price: Double; Amount: Double;
                                Department: Integer; Tax1: Integer; Tax2: Integer; Tax3: Integer;
                                Tax4: Integer): WordBool; dispid 224;
    function ContinuePrinting(const DeviceID: WideString): WordBool; dispid 225;
    function CheckPrintingStatus(const DeviceID: WideString): WordBool; dispid 226;
    function DeviceControlHEX(const DeviceID: WideString; const TxData: WideString;
                              out RxData: WideString): WordBool; dispid 227;
  end;

// *********************************************************************//
// Interface: IMitsu1C17
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E2A613DA-1844-42C1-9C48-4A13E6804A6C}
// *********************************************************************//
  IMitsu1C17 = interface(IDispatch)
    ['{E2A613DA-1844-42C1-9C48-4A13E6804A6C}']
    function GetVersion: WideString; safecall;
    function GetDescription(out Name: WideString; out Description: WideString;
                            out EquipmentType: WideString; out InterfaceRevision: Integer;
                            out IntegrationLibrary: WordBool; out MainDriverInstalled: WordBool;
                            out DownloadURL: WideString): WordBool; safecall;
    function GetLastError(out ErrorDescription: WideString): Integer; safecall;
    function GetParameters(out TableParameters: WideString): WordBool; safecall;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool; safecall;
    function Open(out DeviceID: WideString): WordBool; safecall;
    function Close(const DeviceID: WideString): WordBool; safecall;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool; safecall;
    function GetAdditionalActions(out TableActions: WideString): WordBool; safecall;
    function DoAdditionalAction(const ActionName: WideString): WordBool; safecall;
    function GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool; safecall;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
                         const CashierName: WideString; const ParametersFiscal: WideString): WordBool; safecall;
    function OpenShift(const DeviceID: WideString; const CashierName: WideString;
                       out SessionNumber: Integer; out DocumentNumber: Integer): WordBool; safecall;
    function CloseShift(const DeviceID: WideString; const CashierName: WideString;
                        out SessionNumber: Integer; out DocumentNumber: Integer): WordBool; safecall;
    function ProcessCheck(const DeviceID: WideString; const CashierName: WideString;
                          Electronically: WordBool; const CheckPackage: WideString;
                          out CheckNumber: Integer; out SessionNumber: Integer;
                          out FiscalSign: WideString; out AddressSiteInspections: WideString): WordBool; safecall;
    function ProcessCorrectionCheck(const DeviceID: WideString; const CashierName: WideString;
                                    const CheckCorrectionPackage: WideString;
                                    out CheckNumber: Integer; out SessionNumber: Integer;
                                    out FiscalSign: WideString;
                                    out AddressSiteInspections: WideString): WordBool; safecall;
    function CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool; safecall;
    function GetCurrentStatus(const DeviceID: WideString; out CheckNumber: Integer;
                              out SessionNumber: Integer; out SessionState: Integer;
                              out StatusParameters: WideString): WordBool; safecall;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString): WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; safecall;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool; safecall;
    function PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool; safecall;
    procedure SetLang(LangID: Integer); safecall;
    function PrintXReport(const DeviceID: WideString): WordBool; safecall;
  end;

// *********************************************************************//
// DispIntf:  IMitsu1C17Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E2A613DA-1844-42C1-9C48-4A13E6804A6C}
// *********************************************************************//
  IMitsu1C17Disp = dispinterface
    ['{E2A613DA-1844-42C1-9C48-4A13E6804A6C}']
    function GetVersion: WideString; dispid 201;
    function GetDescription(out Name: WideString; out Description: WideString;
                            out EquipmentType: WideString; out InterfaceRevision: Integer;
                            out IntegrationLibrary: WordBool; out MainDriverInstalled: WordBool;
                            out DownloadURL: WideString): WordBool; dispid 202;
    function GetLastError(out ErrorDescription: WideString): Integer; dispid 203;
    function GetParameters(out TableParameters: WideString): WordBool; dispid 204;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool; dispid 205;
    function Open(out DeviceID: WideString): WordBool; dispid 206;
    function Close(const DeviceID: WideString): WordBool; dispid 207;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool; dispid 208;
    function GetAdditionalActions(out TableActions: WideString): WordBool; dispid 209;
    function DoAdditionalAction(const ActionName: WideString): WordBool; dispid 210;
    function GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool; dispid 211;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
                         const CashierName: WideString; const ParametersFiscal: WideString): WordBool; dispid 212;
    function OpenShift(const DeviceID: WideString; const CashierName: WideString;
                       out SessionNumber: Integer; out DocumentNumber: Integer): WordBool; dispid 213;
    function CloseShift(const DeviceID: WideString; const CashierName: WideString;
                        out SessionNumber: Integer; out DocumentNumber: Integer): WordBool; dispid 214;
    function ProcessCheck(const DeviceID: WideString; const CashierName: WideString;
                          Electronically: WordBool; const CheckPackage: WideString;
                          out CheckNumber: Integer; out SessionNumber: Integer;
                          out FiscalSign: WideString; out AddressSiteInspections: WideString): WordBool; dispid 215;
    function ProcessCorrectionCheck(const DeviceID: WideString; const CashierName: WideString;
                                    const CheckCorrectionPackage: WideString;
                                    out CheckNumber: Integer; out SessionNumber: Integer;
                                    out FiscalSign: WideString;
                                    out AddressSiteInspections: WideString): WordBool; dispid 216;
    function CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool; dispid 217;
    function GetCurrentStatus(const DeviceID: WideString; out CheckNumber: Integer;
                              out SessionNumber: Integer; out SessionState: Integer;
                              out StatusParameters: WideString): WordBool; dispid 218;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString): WordBool; dispid 219;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; dispid 220;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool; dispid 221;
    function PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool; dispid 222;
    procedure SetLang(LangID: Integer); dispid 223;
    function PrintXReport(const DeviceID: WideString): WordBool; dispid 224;
  end;

// *********************************************************************//
// Interface: IMitsu1C22
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {46F19A5E-6E83-4448-B94B-02D5F0F64D9F}
// *********************************************************************//
  IMitsu1C22 = interface(IDispatch)
    ['{46F19A5E-6E83-4448-B94B-02D5F0F64D9F}']
    function GetVersion: WideString; safecall;
    function GetDescription(out Name: WideString; out Description: WideString;
                            out EquipmentType: WideString; out InterfaceRevision: Integer;
                            out IntegrationLibrary: WordBool; out MainDriverInstalled: WordBool;
                            out DownloadURL: WideString): WordBool; safecall;
    function GetLastError(out ErrorDescription: WideString): Integer; safecall;
    function GetParameters(out TableParameters: WideString): WordBool; safecall;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool; safecall;
    function Open(out DeviceID: WideString): WordBool; safecall;
    function Close(const DeviceID: WideString): WordBool; safecall;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool; safecall;
    function GetAdditionalActions(out TableActions: WideString): WordBool; safecall;
    function DoAdditionalAction(const ActionName: WideString): WordBool; safecall;
    function GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool; safecall;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
                         const ParametersFiscal: WideString): WordBool; safecall;
    function OpenShift(const DeviceID: WideString; const InputParameters: WideString;
                       out OutputParameters: WideString; out SessionNumber: Integer;
                       out DocumentNumber: Integer): WordBool; safecall;
    function CloseShift(const DeviceID: WideString; const InputParameters: WideString;
                        out OutputParameters: WideString; out SessionNumber: Integer;
                        out DocumentNumber: Integer): WordBool; safecall;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool;
                          const CheckPackage: WideString; out CheckNumber: Integer;
                          out SessionNumber: Integer; out FiscalSign: WideString;
                          out AddressSiteInspections: WideString): WordBool; safecall;
    function ProcessCorrectionCheck(const DeviceID: WideString;
                                    const CheckCorrectionPackage: WideString;
                                    out CheckNumber: Integer; out SessionNumber: Integer;
                                    out FiscalSign: WideString;
                                    out AddressSiteInspections: WideString): WordBool; safecall;
    function PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool; safecall;
    function CashInOutcome(const DeviceID: WideString; const InputParameters: WideString;
                           Amount: Double): WordBool; safecall;
    function PrintXReport(const DeviceID: WideString; const InputParameters: WideString): WordBool; safecall;
    function GetCurrentStatus(const DeviceID: WideString; out CheckNumber: Integer;
                              out SessionNumber: Integer; out SessionState: Integer;
                              out StatusParameters: WideString): WordBool; safecall;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString;
                                              const InputParameters: WideString;
                                              out OutputParameters: WideString): WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; safecall;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool; safecall;
    procedure SetLang(LangID: Integer); safecall;
  end;

// *********************************************************************//
// DispIntf:  IMitsu1C22Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {46F19A5E-6E83-4448-B94B-02D5F0F64D9F}
// *********************************************************************//
  IMitsu1C22Disp = dispinterface
    ['{46F19A5E-6E83-4448-B94B-02D5F0F64D9F}']
    function GetVersion: WideString; dispid 201;
    function GetDescription(out Name: WideString; out Description: WideString;
                            out EquipmentType: WideString; out InterfaceRevision: Integer;
                            out IntegrationLibrary: WordBool; out MainDriverInstalled: WordBool;
                            out DownloadURL: WideString): WordBool; dispid 202;
    function GetLastError(out ErrorDescription: WideString): Integer; dispid 203;
    function GetParameters(out TableParameters: WideString): WordBool; dispid 204;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool; dispid 205;
    function Open(out DeviceID: WideString): WordBool; dispid 206;
    function Close(const DeviceID: WideString): WordBool; dispid 207;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool; dispid 208;
    function GetAdditionalActions(out TableActions: WideString): WordBool; dispid 209;
    function DoAdditionalAction(const ActionName: WideString): WordBool; dispid 210;
    function GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool; dispid 211;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
                         const ParametersFiscal: WideString): WordBool; dispid 212;
    function OpenShift(const DeviceID: WideString; const InputParameters: WideString;
                       out OutputParameters: WideString; out SessionNumber: Integer;
                       out DocumentNumber: Integer): WordBool; dispid 213;
    function CloseShift(const DeviceID: WideString; const InputParameters: WideString;
                        out OutputParameters: WideString; out SessionNumber: Integer;
                        out DocumentNumber: Integer): WordBool; dispid 214;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool;
                          const CheckPackage: WideString; out CheckNumber: Integer;
                          out SessionNumber: Integer; out FiscalSign: WideString;
                          out AddressSiteInspections: WideString): WordBool; dispid 215;
    function ProcessCorrectionCheck(const DeviceID: WideString;
                                    const CheckCorrectionPackage: WideString;
                                    out CheckNumber: Integer; out SessionNumber: Integer;
                                    out FiscalSign: WideString;
                                    out AddressSiteInspections: WideString): WordBool; dispid 216;
    function PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool; dispid 217;
    function CashInOutcome(const DeviceID: WideString; const InputParameters: WideString;
                           Amount: Double): WordBool; dispid 218;
    function PrintXReport(const DeviceID: WideString; const InputParameters: WideString): WordBool; dispid 219;
    function GetCurrentStatus(const DeviceID: WideString; out CheckNumber: Integer;
                              out SessionNumber: Integer; out SessionState: Integer;
                              out StatusParameters: WideString): WordBool; dispid 220;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString;
                                              const InputParameters: WideString;
                                              out OutputParameters: WideString): WordBool; dispid 221;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; dispid 222;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool; dispid 223;
    procedure SetLang(LangID: Integer); dispid 224;
  end;

// *********************************************************************//
// Interface: IMitsu1C30
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {1CD466C1-DACD-47F0-BCBC-3897881C67A9}
// *********************************************************************//
  IMitsu1C30 = interface(IDispatch)
    ['{1CD466C1-DACD-47F0-BCBC-3897881C67A9}']
    function GetInterfaceRevision: Integer; safecall;
    function GetDescription(out DriverDescription: WideString): WordBool; safecall;
    function GetLastError(out ErrorDescription: WideString): Integer; safecall;
    function GetParameters(out TableParameters: WideString): WordBool; safecall;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool; safecall;
    function Open(out DeviceID: WideString): WordBool; safecall;
    function Close(const DeviceID: WideString): WordBool; safecall;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool; safecall;
    function GetAdditionalActions(out TableActions: WideString): WordBool; safecall;
    function DoAdditionalAction(const ActionName: WideString): WordBool; safecall;
    function GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool; safecall;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
                         const ParametersFiscal: WideString): WordBool; safecall;
    function OpenShift(const DeviceID: WideString; const InputParameters: WideString;
                       out OutputParameters: WideString): WordBool; safecall;
    function CloseShift(const DeviceID: WideString; const InputParameters: WideString;
                        out OutputParameters: WideString): WordBool; safecall;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool;
                          const CheckPackage: WideString; out DocumentOutputParameters: WideString): WordBool; safecall;
    function ProcessCorrectionCheck(const DeviceID: WideString; const CheckPackage: WideString;
                                    out DocumentOutputParameters: WideString): WordBool; safecall;
    function CashInOutcome(const DeviceID: WideString; const InputParameters: WideString;
                           Amount: Double): WordBool; safecall;
    function PrintXReport(const DeviceID: WideString; const InputParameters: WideString): WordBool; safecall;
    function GetCurrentStatus(const DeviceID: WideString; const InputParameters: WideString;
                              out OutputParameters: WideString): WordBool; safecall;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString;
                                              const InputParameters: WideString;
                                              out OutputParameters: WideString): WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; safecall;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool; safecall;
    function PrintCheckCopy(const DeviceID: WideString; const CheckNumber: WideString): WordBool; safecall;
    function PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool; safecall;
    function Get_sm_FormatVersion: Integer; safecall;
    procedure Set_sm_FormatVersion(Value: Integer); safecall;
    function OpenSessionRegistrationKM(const DeviceID: WideString): WordBool; safecall;
    function CloseSessionRegistrationKM(const DeviceID: WideString): WordBool; safecall;
    function RequestKM(const DeviceID: WideString; const RequestKM: WideString;
                       out RequestKMResult: WideString): WordBool; safecall;
    function GetProcessingKMResult(const DeviceID: WideString; out ProcessingKMResult: WideString;
                                   out RequestStatus: Integer): WordBool; safecall;
    function ConfirmKM(const DeviceID: WideString; const RequestGUID: WideString;
                       ConfirmationType: Integer): WordBool; safecall;
    function GetLocalizationPattern(out LocalizationPattern: WideString): WordBool; safecall;
    function SetLocalization(const LanguageCode: WideString; const LocalizationPattern: WideString): WordBool; safecall;
    property sm_FormatVersion: Integer read Get_sm_FormatVersion write Set_sm_FormatVersion;
  end;

// *********************************************************************//
// DispIntf:  IMitsu1C30Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {1CD466C1-DACD-47F0-BCBC-3897881C67A9}
// *********************************************************************//
  IMitsu1C30Disp = dispinterface
    ['{1CD466C1-DACD-47F0-BCBC-3897881C67A9}']
    function GetInterfaceRevision: Integer; dispid 201;
    function GetDescription(out DriverDescription: WideString): WordBool; dispid 202;
    function GetLastError(out ErrorDescription: WideString): Integer; dispid 203;
    function GetParameters(out TableParameters: WideString): WordBool; dispid 204;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool; dispid 205;
    function Open(out DeviceID: WideString): WordBool; dispid 206;
    function Close(const DeviceID: WideString): WordBool; dispid 207;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool; dispid 208;
    function GetAdditionalActions(out TableActions: WideString): WordBool; dispid 209;
    function DoAdditionalAction(const ActionName: WideString): WordBool; dispid 210;
    function GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool; dispid 211;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
                         const ParametersFiscal: WideString): WordBool; dispid 212;
    function OpenShift(const DeviceID: WideString; const InputParameters: WideString;
                       out OutputParameters: WideString): WordBool; dispid 213;
    function CloseShift(const DeviceID: WideString; const InputParameters: WideString;
                        out OutputParameters: WideString): WordBool; dispid 214;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool;
                          const CheckPackage: WideString; out DocumentOutputParameters: WideString): WordBool; dispid 215;
    function ProcessCorrectionCheck(const DeviceID: WideString; const CheckPackage: WideString;
                                    out DocumentOutputParameters: WideString): WordBool; dispid 216;
    function CashInOutcome(const DeviceID: WideString; const InputParameters: WideString;
                           Amount: Double): WordBool; dispid 218;
    function PrintXReport(const DeviceID: WideString; const InputParameters: WideString): WordBool; dispid 219;
    function GetCurrentStatus(const DeviceID: WideString; const InputParameters: WideString;
                              out OutputParameters: WideString): WordBool; dispid 220;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString;
                                              const InputParameters: WideString;
                                              out OutputParameters: WideString): WordBool; dispid 221;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; dispid 222;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool; dispid 223;
    function PrintCheckCopy(const DeviceID: WideString; const CheckNumber: WideString): WordBool; dispid 224;
    function PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool; dispid 225;
    property sm_FormatVersion: Integer dispid 217;
    function OpenSessionRegistrationKM(const DeviceID: WideString): WordBool; dispid 226;
    function CloseSessionRegistrationKM(const DeviceID: WideString): WordBool; dispid 227;
    function RequestKM(const DeviceID: WideString; const RequestKM: WideString;
                       out RequestKMResult: WideString): WordBool; dispid 228;
    function GetProcessingKMResult(const DeviceID: WideString; out ProcessingKMResult: WideString;
                                   out RequestStatus: Integer): WordBool; dispid 229;
    function ConfirmKM(const DeviceID: WideString; const RequestGUID: WideString;
                       ConfirmationType: Integer): WordBool; dispid 230;
    function GetLocalizationPattern(out LocalizationPattern: WideString): WordBool; dispid 231;
    function SetLocalization(const LanguageCode: WideString; const LocalizationPattern: WideString): WordBool; dispid 232;
  end;

// *********************************************************************//
// The Class CoMitsu1C provides a Create and CreateRemote method to
// create instances of the default interface IMitsu1C exposed by
// the CoClass Mitsu1C. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoMitsu1C = class
    class function Create: IMitsu1C;
    class function CreateRemote(const MachineName: string): IMitsu1C;
  end;

// *********************************************************************//
// The Class CoMitsu1C11 provides a Create and CreateRemote method to
// create instances of the default interface IMitsu1C11 exposed by
// the CoClass Mitsu1C11. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoMitsu1C11 = class
    class function Create: IMitsu1C11;
    class function CreateRemote(const MachineName: string): IMitsu1C11;
  end;

// *********************************************************************//
// The Class CoMitsu1C17 provides a Create and CreateRemote method to
// create instances of the default interface IMitsu1C17 exposed by
// the CoClass Mitsu1C17. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoMitsu1C17 = class
    class function Create: IMitsu1C17;
    class function CreateRemote(const MachineName: string): IMitsu1C17;
  end;

// *********************************************************************//
// The Class CoMitsu1C22 provides a Create and CreateRemote method to
// create instances of the default interface IMitsu1C22 exposed by
// the CoClass Mitsu1C22. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoMitsu1C22 = class
    class function Create: IMitsu1C22;
    class function CreateRemote(const MachineName: string): IMitsu1C22;
  end;

implementation

uses System.Win.ComObj;

class function CoMitsu1C.Create: IMitsu1C;
begin
  Result := CreateComObject(CLASS_Mitsu1C) as IMitsu1C;
end;

class function CoMitsu1C.CreateRemote(const MachineName: string): IMitsu1C;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Mitsu1C) as IMitsu1C;
end;

class function CoMitsu1C11.Create: IMitsu1C11;
begin
  Result := CreateComObject(CLASS_Mitsu1C11) as IMitsu1C11;
end;

class function CoMitsu1C11.CreateRemote(const MachineName: string): IMitsu1C11;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Mitsu1C11) as IMitsu1C11;
end;

class function CoMitsu1C17.Create: IMitsu1C17;
begin
  Result := CreateComObject(CLASS_Mitsu1C17) as IMitsu1C17;
end;

class function CoMitsu1C17.CreateRemote(const MachineName: string): IMitsu1C17;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Mitsu1C17) as IMitsu1C17;
end;

class function CoMitsu1C22.Create: IMitsu1C22;
begin
  Result := CreateComObject(CLASS_Mitsu1C22) as IMitsu1C22;
end;

class function CoMitsu1C22.CreateRemote(const MachineName: string): IMitsu1C22;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Mitsu1C22) as IMitsu1C22;
end;

end.

