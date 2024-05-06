unit DrvFR1CLib_TLB;

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

// PASTLWTR : 1.2
// File generated on 29.04.2024 14:46:38 from Type Library described below.

// ************************************************************************  //
// Type Lib: DrvFR1CLib.tlb (1)
// LIBID: {332C8050-469C-4B4D-A192-68CD3CB252BA}
// LCID: 0
// Helpfile: 
// HelpString: SHTRIH-M: DrvFR
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  DrvFR1CLibMajorVersion = 5;
  DrvFR1CLibMinorVersion = 17;

  LIBID_DrvFR1CLib: TGUID = '{332C8050-469C-4B4D-A192-68CD3CB252BA}';

  IID_IDrvFR1C: TGUID = '{241707F7-BF29-4858-8FF8-B2502344EBE5}';
  CLASS_DrvFR1C: TGUID = '{129C1D7A-384D-4CD6-9F28-7CF321FF9D04}';
  IID_IDrvFR1C11: TGUID = '{9941F158-93F5-4DA2-A333-BB4937B58E05}';
  CLASS_DrvFR1C11: TGUID = '{44809D9F-9A23-4CDD-A4CC-39A052C3BDFB}';
  IID_IDrvFR1C17: TGUID = '{135578E8-34E8-440C-AFEC-993C33CC9153}';
  CLASS_DrvFR1C17: TGUID = '{6A751D33-0AAB-4339-BCC4-8056B3FC87F4}';
  IID_IDrvFR1C22: TGUID = '{DFD84A0D-EFCF-4805-B8CF-125F2996576A}';
  CLASS_DrvFR1C22: TGUID = '{E5903D73-66CC-42D7-9647-DBD2C837D8A7}';
  IID_IDrvFR1C30: TGUID = '{E390D34B-02C3-46C8-803C-DB8131AC5331}';
  CLASS_DrvFR1C30: TGUID = '{32D32C7A-CEF9-4AC5-8953-3D6DF81ABBD6}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IDrvFR1C = interface;
  IDrvFR1CDisp = dispinterface;
  IDrvFR1C11 = interface;
  IDrvFR1C11Disp = dispinterface;
  IDrvFR1C17 = interface;
  IDrvFR1C17Disp = dispinterface;
  IDrvFR1C22 = interface;
  IDrvFR1C22Disp = dispinterface;
  IDrvFR1C30 = interface;
  IDrvFR1C30Disp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  DrvFR1C = IDrvFR1C;
  DrvFR1C11 = IDrvFR1C11;
  DrvFR1C17 = IDrvFR1C17;
  DrvFR1C22 = IDrvFR1C22;
  DrvFR1C30 = IDrvFR1C30;


// *********************************************************************//
// Interface: IDrvFR1C
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {241707F7-BF29-4858-8FF8-B2502344EBE5}
// *********************************************************************//
  IDrvFR1C = interface(IDispatch)
    ['{241707F7-BF29-4858-8FF8-B2502344EBE5}']
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
// DispIntf:  IDrvFR1CDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {241707F7-BF29-4858-8FF8-B2502344EBE5}
// *********************************************************************//
  IDrvFR1CDisp = dispinterface
    ['{241707F7-BF29-4858-8FF8-B2502344EBE5}']
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
// Interface: IDrvFR1C11
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9941F158-93F5-4DA2-A333-BB4937B58E05}
// *********************************************************************//
  IDrvFR1C11 = interface(IDispatch)
    ['{9941F158-93F5-4DA2-A333-BB4937B58E05}']
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
// DispIntf:  IDrvFR1C11Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9941F158-93F5-4DA2-A333-BB4937B58E05}
// *********************************************************************//
  IDrvFR1C11Disp = dispinterface
    ['{9941F158-93F5-4DA2-A333-BB4937B58E05}']
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
// Interface: IDrvFR1C17
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {135578E8-34E8-440C-AFEC-993C33CC9153}
// *********************************************************************//
  IDrvFR1C17 = interface(IDispatch)
    ['{135578E8-34E8-440C-AFEC-993C33CC9153}']
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
// DispIntf:  IDrvFR1C17Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {135578E8-34E8-440C-AFEC-993C33CC9153}
// *********************************************************************//
  IDrvFR1C17Disp = dispinterface
    ['{135578E8-34E8-440C-AFEC-993C33CC9153}']
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
// Interface: IDrvFR1C22
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {DFD84A0D-EFCF-4805-B8CF-125F2996576A}
// *********************************************************************//
  IDrvFR1C22 = interface(IDispatch)
    ['{DFD84A0D-EFCF-4805-B8CF-125F2996576A}']
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
// DispIntf:  IDrvFR1C22Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {DFD84A0D-EFCF-4805-B8CF-125F2996576A}
// *********************************************************************//
  IDrvFR1C22Disp = dispinterface
    ['{DFD84A0D-EFCF-4805-B8CF-125F2996576A}']
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
// Interface: IDrvFR1C30
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E390D34B-02C3-46C8-803C-DB8131AC5331}
// *********************************************************************//
  IDrvFR1C30 = interface(IDispatch)
    ['{E390D34B-02C3-46C8-803C-DB8131AC5331}']
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
// DispIntf:  IDrvFR1C30Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E390D34B-02C3-46C8-803C-DB8131AC5331}
// *********************************************************************//
  IDrvFR1C30Disp = dispinterface
    ['{E390D34B-02C3-46C8-803C-DB8131AC5331}']
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
// OLE Control Proxy class declaration
// Control Name     : TDrvFR1C
// Help String      : Драйвер ФР 1С
// Default Interface: IDrvFR1C
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  TDrvFR1C = class(TOleControl)
  private
    FIntf: IDrvFR1C;
    function  GetControlInterface: IDrvFR1C;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function GetVersion: WideString;
    function GetLastError(out ErrorDescription: WideString): Integer;
    function Close(const DeviceID: WideString): WordBool;
    function PrintXReport(const DeviceID: WideString): WordBool;
    function PrintZReport(const DeviceID: WideString): WordBool;
    function CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool;
    function OpenCheck(const DeviceID: WideString; IsFiscalCheck: WordBool; 
                       IsReturnCheck: WordBool; CancelOpenedCheck: WordBool; 
                       out CheckNumber: Integer; out SessionNumber: Integer): WordBool;
    function PrintFiscalString(const DeviceID: WideString; const Name: WideString; 
                               Quantity: Double; Price: Double; Amount: Double; 
                               Department: Integer; Tax: Single): WordBool;
    function CloseCheck(const DeviceID: WideString; Cash: Double; PayByCard: Double; 
                        PayByCredit: Double): WordBool;
    function CancelCheck(const DeviceID: WideString): WordBool;
    function PrintNonFiscalString(const DeviceID: WideString; const TextString: WideString): WordBool;
    function DeviceTest(const ValuesArray: IDispatch; out AdditionalDescription: WideString): WordBool;
    function Open(const ValuesArray: IDispatch; out DeviceID: WideString): WordBool;
    function CheckPrintingStatus(const DeviceID: WideString): WordBool;
    function ContinuePrinting(const DeviceID: WideString): WordBool;
    function OpenCashDrawer(const DeviceID: WideString; CashDrawerID: Integer): WordBool;
    function LoadLogo(const ValuesArray: IDispatch; const LogoFileName: WideString; 
                      CenterLogo: WordBool; out LogoSize: Integer; 
                      out AdditionalDescription: WideString): WordBool;
    function OpenSession(const DeviceID: WideString): WordBool;
    function DeviceControl(const DeviceID: WideString; const TxData: WideString; 
                           out RxData: WideString): WordBool;
    function DeviceControlHEX(const DeviceID: WideString; const TxData: WideString; 
                              out RxData: WideString): WordBool;
    property  ControlInterface: IDrvFR1C read GetControlInterface;
    property  DefaultInterface: IDrvFR1C read GetControlInterface;
  published
    property Anchors;
    property DiscountOnCheck: Double index 221 read GetDoubleProp write SetDoubleProp stored False;
    property PayType4: Double index 222 read GetDoubleProp write SetDoubleProp stored False;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TDrvFR1C11
// Help String      : DrvFR1C11 Object
// Default Interface: IDrvFR1C11
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  TDrvFR1C11 = class(TOleControl)
  private
    FIntf: IDrvFR1C11;
    function  GetControlInterface: IDrvFR1C11;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function GetVersion: WideString;
    function GetDescription(out Name: WideString; out Description: WideString; 
                            out EquipmentType: WideString; out InterfaceRevision: Integer; 
                            out IntegrationLibrary: WordBool; out MainDriverInstalled: WordBool; 
                            out GetDownloadURL: WideString): WordBool;
    function GetLastError(out ErrorDescription: WideString): Integer;
    function GetParameters(out TableParameters: WideString): WordBool;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool;
    function Open(out DeviceID: WideString): WordBool;
    function Close(const DeviceID: WideString): WordBool;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool;
    function GetAdditionalActions(out TableActions: WideString): WordBool;
    function DoAdditionalAction(const ActionName: WideString): WordBool;
    function OpenCheck(const DeviceID: WideString; IsFiscalCheck: WordBool; 
                       IsReturnCheck: WordBool; CancelOpenedCheck: WordBool; 
                       out CheckNumber: Integer; out SessionNumber: Integer): WordBool;
    function PrintFiscalString(const DeviceID: WideString; const Name: WideString; 
                               Quantity: Double; Price: Double; Amount: Double; 
                               Department: Integer; Tax: Double): WordBool;
    function PrintNonFiscalString(const DeviceID: WideString; const TextString: WideString): WordBool;
    function PrintBarCode(const DeviceID: WideString; const BarcodeType: WideString; 
                          const BarCode: WideString): WordBool;
    function CloseCheck(const DeviceID: WideString; Cash: Double; PayByCard: Double; 
                        PayByCredit: Double; PayByCertificate: Double): WordBool;
    function CancelCheck(const DeviceID: WideString): WordBool;
    function CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool;
    function PrintXReport(const DeviceID: WideString): WordBool;
    function PrintZReport(const DeviceID: WideString): WordBool;
    function OpenCashDrawer(const DeviceID: WideString): WordBool;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool;
    procedure SetLang(LangID: Integer);
    function OpenShift(const DeviceID: WideString): WordBool;
    function PrintFiscalString2(const DeviceID: WideString; const Name: WideString; 
                                Quantity: Double; Price: Double; Amount: Double; 
                                Department: Integer; Tax1: Integer; Tax2: Integer; Tax3: Integer; 
                                Tax4: Integer): WordBool;
    function ContinuePrinting(const DeviceID: WideString): WordBool;
    function CheckPrintingStatus(const DeviceID: WideString): WordBool;
    function DeviceControlHEX(const DeviceID: WideString; const TxData: WideString; 
                              out RxData: WideString): WordBool;
    property  ControlInterface: IDrvFR1C11 read GetControlInterface;
    property  DefaultInterface: IDrvFR1C11 read GetControlInterface;
  published
    property Anchors;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TDrvFR1C17
// Help String      : DrvFR1C17 Control
// Default Interface: IDrvFR1C17
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  TDrvFR1C17 = class(TOleControl)
  private
    FIntf: IDrvFR1C17;
    function  GetControlInterface: IDrvFR1C17;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function GetVersion: WideString;
    function GetDescription(out Name: WideString; out Description: WideString; 
                            out EquipmentType: WideString; out InterfaceRevision: Integer; 
                            out IntegrationLibrary: WordBool; out MainDriverInstalled: WordBool; 
                            out DownloadURL: WideString): WordBool;
    function GetLastError(out ErrorDescription: WideString): Integer;
    function GetParameters(out TableParameters: WideString): WordBool;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool;
    function Open(out DeviceID: WideString): WordBool;
    function Close(const DeviceID: WideString): WordBool;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool;
    function GetAdditionalActions(out TableActions: WideString): WordBool;
    function DoAdditionalAction(const ActionName: WideString): WordBool;
    function GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool;
    function OperationFN(const DeviceID: WideString; OperationType: Integer; 
                         const CashierName: WideString; const ParametersFiscal: WideString): WordBool;
    function OpenShift(const DeviceID: WideString; const CashierName: WideString; 
                       out SessionNumber: Integer; out DocumentNumber: Integer): WordBool;
    function CloseShift(const DeviceID: WideString; const CashierName: WideString; 
                        out SessionNumber: Integer; out DocumentNumber: Integer): WordBool;
    function ProcessCheck(const DeviceID: WideString; const CashierName: WideString; 
                          Electronically: WordBool; const CheckPackage: WideString; 
                          out CheckNumber: Integer; out SessionNumber: Integer; 
                          out FiscalSign: WideString; out AddressSiteInspections: WideString): WordBool;
    function ProcessCorrectionCheck(const DeviceID: WideString; const CashierName: WideString; 
                                    const CheckCorrectionPackage: WideString; 
                                    out CheckNumber: Integer; out SessionNumber: Integer; 
                                    out FiscalSign: WideString; 
                                    out AddressSiteInspections: WideString): WordBool;
    function CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool;
    function GetCurrentStatus(const DeviceID: WideString; out CheckNumber: Integer; 
                              out SessionNumber: Integer; out SessionState: Integer; 
                              out StatusParameters: WideString): WordBool;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString): WordBool;
    function OpenCashDrawer(const DeviceID: WideString): WordBool;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool;
    function PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool;
    procedure SetLang(LangID: Integer);
    function PrintXReport(const DeviceID: WideString): WordBool;
    property  ControlInterface: IDrvFR1C17 read GetControlInterface;
    property  DefaultInterface: IDrvFR1C17 read GetControlInterface;
  published
    property Anchors;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TDrvFR1C22
// Help String      : DrvFR1C22 Object
// Default Interface: IDrvFR1C22
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  TDrvFR1C22 = class(TOleControl)
  private
    FIntf: IDrvFR1C22;
    function  GetControlInterface: IDrvFR1C22;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function GetVersion: WideString;
    function GetDescription(out Name: WideString; out Description: WideString; 
                            out EquipmentType: WideString; out InterfaceRevision: Integer; 
                            out IntegrationLibrary: WordBool; out MainDriverInstalled: WordBool; 
                            out DownloadURL: WideString): WordBool;
    function GetLastError(out ErrorDescription: WideString): Integer;
    function GetParameters(out TableParameters: WideString): WordBool;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool;
    function Open(out DeviceID: WideString): WordBool;
    function Close(const DeviceID: WideString): WordBool;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool;
    function GetAdditionalActions(out TableActions: WideString): WordBool;
    function DoAdditionalAction(const ActionName: WideString): WordBool;
    function GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool;
    function OperationFN(const DeviceID: WideString; OperationType: Integer; 
                         const ParametersFiscal: WideString): WordBool;
    function OpenShift(const DeviceID: WideString; const InputParameters: WideString; 
                       out OutputParameters: WideString; out SessionNumber: Integer; 
                       out DocumentNumber: Integer): WordBool;
    function CloseShift(const DeviceID: WideString; const InputParameters: WideString; 
                        out OutputParameters: WideString; out SessionNumber: Integer; 
                        out DocumentNumber: Integer): WordBool;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool; 
                          const CheckPackage: WideString; out CheckNumber: Integer; 
                          out SessionNumber: Integer; out FiscalSign: WideString; 
                          out AddressSiteInspections: WideString): WordBool;
    function ProcessCorrectionCheck(const DeviceID: WideString; 
                                    const CheckCorrectionPackage: WideString; 
                                    out CheckNumber: Integer; out SessionNumber: Integer; 
                                    out FiscalSign: WideString; 
                                    out AddressSiteInspections: WideString): WordBool;
    function PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool;
    function CashInOutcome(const DeviceID: WideString; const InputParameters: WideString; 
                           Amount: Double): WordBool;
    function PrintXReport(const DeviceID: WideString; const InputParameters: WideString): WordBool;
    function GetCurrentStatus(const DeviceID: WideString; out CheckNumber: Integer; 
                              out SessionNumber: Integer; out SessionState: Integer; 
                              out StatusParameters: WideString): WordBool;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString; 
                                              const InputParameters: WideString; 
                                              out OutputParameters: WideString): WordBool;
    function OpenCashDrawer(const DeviceID: WideString): WordBool;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool;
    procedure SetLang(LangID: Integer);
    property  ControlInterface: IDrvFR1C22 read GetControlInterface;
    property  DefaultInterface: IDrvFR1C22 read GetControlInterface;
  published
    property Anchors;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TDrvFR1C30
// Help String      : 
// Default Interface: IDrvFR1C30
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TDrvFR1C30 = class(TOleControl)
  private
    FIntf: IDrvFR1C30;
    function  GetControlInterface: IDrvFR1C30;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function GetInterfaceRevision: Integer;
    function GetDescription(out DriverDescription: WideString): WordBool;
    function GetLastError(out ErrorDescription: WideString): Integer;
    function GetParameters(out TableParameters: WideString): WordBool;
    function SetParameter(const Name: WideString; Value: OleVariant): WordBool;
    function Open(out DeviceID: WideString): WordBool;
    function Close(const DeviceID: WideString): WordBool;
    function DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool;
    function GetAdditionalActions(out TableActions: WideString): WordBool;
    function DoAdditionalAction(const ActionName: WideString): WordBool;
    function GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool;
    function OperationFN(const DeviceID: WideString; OperationType: Integer; 
                         const ParametersFiscal: WideString): WordBool;
    function OpenShift(const DeviceID: WideString; const InputParameters: WideString; 
                       out OutputParameters: WideString): WordBool;
    function CloseShift(const DeviceID: WideString; const InputParameters: WideString; 
                        out OutputParameters: WideString): WordBool;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool; 
                          const CheckPackage: WideString; out DocumentOutputParameters: WideString): WordBool;
    function ProcessCorrectionCheck(const DeviceID: WideString; const CheckPackage: WideString; 
                                    out DocumentOutputParameters: WideString): WordBool;
    function CashInOutcome(const DeviceID: WideString; const InputParameters: WideString; 
                           Amount: Double): WordBool;
    function PrintXReport(const DeviceID: WideString; const InputParameters: WideString): WordBool;
    function GetCurrentStatus(const DeviceID: WideString; const InputParameters: WideString; 
                              out OutputParameters: WideString): WordBool;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString; 
                                              const InputParameters: WideString; 
                                              out OutputParameters: WideString): WordBool;
    function OpenCashDrawer(const DeviceID: WideString): WordBool;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool;
    function PrintCheckCopy(const DeviceID: WideString; const CheckNumber: WideString): WordBool;
    function PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool;
    function OpenSessionRegistrationKM(const DeviceID: WideString): WordBool;
    function CloseSessionRegistrationKM(const DeviceID: WideString): WordBool;
    function RequestKM(const DeviceID: WideString; const RequestKM: WideString; 
                       out RequestKMResult: WideString): WordBool;
    function GetProcessingKMResult(const DeviceID: WideString; out ProcessingKMResult: WideString; 
                                   out RequestStatus: Integer): WordBool;
    function ConfirmKM(const DeviceID: WideString; const RequestGUID: WideString; 
                       ConfirmationType: Integer): WordBool;
    function GetLocalizationPattern(out LocalizationPattern: WideString): WordBool;
    function SetLocalization(const LanguageCode: WideString; const LocalizationPattern: WideString): WordBool;
    property  ControlInterface: IDrvFR1C30 read GetControlInterface;
    property  DefaultInterface: IDrvFR1C30 read GetControlInterface;
  published
    property Anchors;
    property sm_FormatVersion: Integer index 217 read GetIntegerProp write SetIntegerProp stored False;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'Servers';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TDrvFR1C.InitControlData;
const
  CControlData: TControlData2 = (
    ClassID: '{129C1D7A-384D-4CD6-9F28-7CF321FF9D04}';
    EventIID: '';
    EventCount: 0;
    EventDispIDs: nil;
    LicenseKey: nil (*HR:$00000000*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
end;

procedure TDrvFR1C.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IDrvFR1C;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TDrvFR1C.GetControlInterface: IDrvFR1C;
begin
  CreateControl;
  Result := FIntf;
end;

function TDrvFR1C.GetVersion: WideString;
begin
  Result := DefaultInterface.GetVersion;
end;

function TDrvFR1C.GetLastError(out ErrorDescription: WideString): Integer;
begin
  Result := DefaultInterface.GetLastError(ErrorDescription);
end;

function TDrvFR1C.Close(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.Close(DeviceID);
end;

function TDrvFR1C.PrintXReport(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.PrintXReport(DeviceID);
end;

function TDrvFR1C.PrintZReport(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.PrintZReport(DeviceID);
end;

function TDrvFR1C.CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool;
begin
  Result := DefaultInterface.CashInOutcome(DeviceID, Amount);
end;

function TDrvFR1C.OpenCheck(const DeviceID: WideString; IsFiscalCheck: WordBool; 
                            IsReturnCheck: WordBool; CancelOpenedCheck: WordBool; 
                            out CheckNumber: Integer; out SessionNumber: Integer): WordBool;
begin
  Result := DefaultInterface.OpenCheck(DeviceID, IsFiscalCheck, IsReturnCheck, CancelOpenedCheck, 
                                       CheckNumber, SessionNumber);
end;

function TDrvFR1C.PrintFiscalString(const DeviceID: WideString; const Name: WideString; 
                                    Quantity: Double; Price: Double; Amount: Double; 
                                    Department: Integer; Tax: Single): WordBool;
begin
  Result := DefaultInterface.PrintFiscalString(DeviceID, Name, Quantity, Price, Amount, Department, 
                                               Tax);
end;

function TDrvFR1C.CloseCheck(const DeviceID: WideString; Cash: Double; PayByCard: Double; 
                             PayByCredit: Double): WordBool;
begin
  Result := DefaultInterface.CloseCheck(DeviceID, Cash, PayByCard, PayByCredit);
end;

function TDrvFR1C.CancelCheck(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.CancelCheck(DeviceID);
end;

function TDrvFR1C.PrintNonFiscalString(const DeviceID: WideString; const TextString: WideString): WordBool;
begin
  Result := DefaultInterface.PrintNonFiscalString(DeviceID, TextString);
end;

function TDrvFR1C.DeviceTest(const ValuesArray: IDispatch; out AdditionalDescription: WideString): WordBool;
begin
  Result := DefaultInterface.DeviceTest(ValuesArray, AdditionalDescription);
end;

function TDrvFR1C.Open(const ValuesArray: IDispatch; out DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.Open(ValuesArray, DeviceID);
end;

function TDrvFR1C.CheckPrintingStatus(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.CheckPrintingStatus(DeviceID);
end;

function TDrvFR1C.ContinuePrinting(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.ContinuePrinting(DeviceID);
end;

function TDrvFR1C.OpenCashDrawer(const DeviceID: WideString; CashDrawerID: Integer): WordBool;
begin
  Result := DefaultInterface.OpenCashDrawer(DeviceID, CashDrawerID);
end;

function TDrvFR1C.LoadLogo(const ValuesArray: IDispatch; const LogoFileName: WideString; 
                           CenterLogo: WordBool; out LogoSize: Integer; 
                           out AdditionalDescription: WideString): WordBool;
begin
  Result := DefaultInterface.LoadLogo(ValuesArray, LogoFileName, CenterLogo, LogoSize, 
                                      AdditionalDescription);
end;

function TDrvFR1C.OpenSession(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.OpenSession(DeviceID);
end;

function TDrvFR1C.DeviceControl(const DeviceID: WideString; const TxData: WideString; 
                                out RxData: WideString): WordBool;
begin
  Result := DefaultInterface.DeviceControl(DeviceID, TxData, RxData);
end;

function TDrvFR1C.DeviceControlHEX(const DeviceID: WideString; const TxData: WideString; 
                                   out RxData: WideString): WordBool;
begin
  Result := DefaultInterface.DeviceControlHEX(DeviceID, TxData, RxData);
end;

procedure TDrvFR1C11.InitControlData;
const
  CControlData: TControlData2 = (
    ClassID: '{44809D9F-9A23-4CDD-A4CC-39A052C3BDFB}';
    EventIID: '';
    EventCount: 0;
    EventDispIDs: nil;
    LicenseKey: nil (*HR:$00000000*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
end;

procedure TDrvFR1C11.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IDrvFR1C11;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TDrvFR1C11.GetControlInterface: IDrvFR1C11;
begin
  CreateControl;
  Result := FIntf;
end;

function TDrvFR1C11.GetVersion: WideString;
begin
  Result := DefaultInterface.GetVersion;
end;

function TDrvFR1C11.GetDescription(out Name: WideString; out Description: WideString; 
                                   out EquipmentType: WideString; out InterfaceRevision: Integer; 
                                   out IntegrationLibrary: WordBool; 
                                   out MainDriverInstalled: WordBool; out GetDownloadURL: WideString): WordBool;
begin
  Result := DefaultInterface.GetDescription(Name, Description, EquipmentType, InterfaceRevision, 
                                            IntegrationLibrary, MainDriverInstalled, GetDownloadURL);
end;

function TDrvFR1C11.GetLastError(out ErrorDescription: WideString): Integer;
begin
  Result := DefaultInterface.GetLastError(ErrorDescription);
end;

function TDrvFR1C11.GetParameters(out TableParameters: WideString): WordBool;
begin
  Result := DefaultInterface.GetParameters(TableParameters);
end;

function TDrvFR1C11.SetParameter(const Name: WideString; Value: OleVariant): WordBool;
begin
  Result := DefaultInterface.SetParameter(Name, Value);
end;

function TDrvFR1C11.Open(out DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.Open(DeviceID);
end;

function TDrvFR1C11.Close(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.Close(DeviceID);
end;

function TDrvFR1C11.DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool;
begin
  Result := DefaultInterface.DeviceTest(Description, DemoModeIsActivated);
end;

function TDrvFR1C11.GetAdditionalActions(out TableActions: WideString): WordBool;
begin
  Result := DefaultInterface.GetAdditionalActions(TableActions);
end;

function TDrvFR1C11.DoAdditionalAction(const ActionName: WideString): WordBool;
begin
  Result := DefaultInterface.DoAdditionalAction(ActionName);
end;

function TDrvFR1C11.OpenCheck(const DeviceID: WideString; IsFiscalCheck: WordBool; 
                              IsReturnCheck: WordBool; CancelOpenedCheck: WordBool; 
                              out CheckNumber: Integer; out SessionNumber: Integer): WordBool;
begin
  Result := DefaultInterface.OpenCheck(DeviceID, IsFiscalCheck, IsReturnCheck, CancelOpenedCheck, 
                                       CheckNumber, SessionNumber);
end;

function TDrvFR1C11.PrintFiscalString(const DeviceID: WideString; const Name: WideString; 
                                      Quantity: Double; Price: Double; Amount: Double; 
                                      Department: Integer; Tax: Double): WordBool;
begin
  Result := DefaultInterface.PrintFiscalString(DeviceID, Name, Quantity, Price, Amount, Department, 
                                               Tax);
end;

function TDrvFR1C11.PrintNonFiscalString(const DeviceID: WideString; const TextString: WideString): WordBool;
begin
  Result := DefaultInterface.PrintNonFiscalString(DeviceID, TextString);
end;

function TDrvFR1C11.PrintBarCode(const DeviceID: WideString; const BarcodeType: WideString; 
                                 const BarCode: WideString): WordBool;
begin
  Result := DefaultInterface.PrintBarCode(DeviceID, BarcodeType, BarCode);
end;

function TDrvFR1C11.CloseCheck(const DeviceID: WideString; Cash: Double; PayByCard: Double; 
                               PayByCredit: Double; PayByCertificate: Double): WordBool;
begin
  Result := DefaultInterface.CloseCheck(DeviceID, Cash, PayByCard, PayByCredit, PayByCertificate);
end;

function TDrvFR1C11.CancelCheck(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.CancelCheck(DeviceID);
end;

function TDrvFR1C11.CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool;
begin
  Result := DefaultInterface.CashInOutcome(DeviceID, Amount);
end;

function TDrvFR1C11.PrintXReport(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.PrintXReport(DeviceID);
end;

function TDrvFR1C11.PrintZReport(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.PrintZReport(DeviceID);
end;

function TDrvFR1C11.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.OpenCashDrawer(DeviceID);
end;

function TDrvFR1C11.GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool;
begin
  Result := DefaultInterface.GetLineLength(DeviceID, LineLength);
end;

procedure TDrvFR1C11.SetLang(LangID: Integer);
begin
  DefaultInterface.SetLang(LangID);
end;

function TDrvFR1C11.OpenShift(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.OpenShift(DeviceID);
end;

function TDrvFR1C11.PrintFiscalString2(const DeviceID: WideString; const Name: WideString; 
                                       Quantity: Double; Price: Double; Amount: Double; 
                                       Department: Integer; Tax1: Integer; Tax2: Integer; 
                                       Tax3: Integer; Tax4: Integer): WordBool;
begin
  Result := DefaultInterface.PrintFiscalString2(DeviceID, Name, Quantity, Price, Amount, 
                                                Department, Tax1, Tax2, Tax3, Tax4);
end;

function TDrvFR1C11.ContinuePrinting(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.ContinuePrinting(DeviceID);
end;

function TDrvFR1C11.CheckPrintingStatus(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.CheckPrintingStatus(DeviceID);
end;

function TDrvFR1C11.DeviceControlHEX(const DeviceID: WideString; const TxData: WideString; 
                                     out RxData: WideString): WordBool;
begin
  Result := DefaultInterface.DeviceControlHEX(DeviceID, TxData, RxData);
end;

procedure TDrvFR1C17.InitControlData;
const
  CControlData: TControlData2 = (
    ClassID: '{6A751D33-0AAB-4339-BCC4-8056B3FC87F4}';
    EventIID: '';
    EventCount: 0;
    EventDispIDs: nil;
    LicenseKey: nil (*HR:$00000000*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
end;

procedure TDrvFR1C17.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IDrvFR1C17;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TDrvFR1C17.GetControlInterface: IDrvFR1C17;
begin
  CreateControl;
  Result := FIntf;
end;

function TDrvFR1C17.GetVersion: WideString;
begin
  Result := DefaultInterface.GetVersion;
end;

function TDrvFR1C17.GetDescription(out Name: WideString; out Description: WideString; 
                                   out EquipmentType: WideString; out InterfaceRevision: Integer; 
                                   out IntegrationLibrary: WordBool; 
                                   out MainDriverInstalled: WordBool; out DownloadURL: WideString): WordBool;
begin
  Result := DefaultInterface.GetDescription(Name, Description, EquipmentType, InterfaceRevision, 
                                            IntegrationLibrary, MainDriverInstalled, DownloadURL);
end;

function TDrvFR1C17.GetLastError(out ErrorDescription: WideString): Integer;
begin
  Result := DefaultInterface.GetLastError(ErrorDescription);
end;

function TDrvFR1C17.GetParameters(out TableParameters: WideString): WordBool;
begin
  Result := DefaultInterface.GetParameters(TableParameters);
end;

function TDrvFR1C17.SetParameter(const Name: WideString; Value: OleVariant): WordBool;
begin
  Result := DefaultInterface.SetParameter(Name, Value);
end;

function TDrvFR1C17.Open(out DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.Open(DeviceID);
end;

function TDrvFR1C17.Close(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.Close(DeviceID);
end;

function TDrvFR1C17.DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool;
begin
  Result := DefaultInterface.DeviceTest(Description, DemoModeIsActivated);
end;

function TDrvFR1C17.GetAdditionalActions(out TableActions: WideString): WordBool;
begin
  Result := DefaultInterface.GetAdditionalActions(TableActions);
end;

function TDrvFR1C17.DoAdditionalAction(const ActionName: WideString): WordBool;
begin
  Result := DefaultInterface.DoAdditionalAction(ActionName);
end;

function TDrvFR1C17.GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool;
begin
  Result := DefaultInterface.GetDataKKT(DeviceID, TableParametersKKT);
end;

function TDrvFR1C17.OperationFN(const DeviceID: WideString; OperationType: Integer; 
                                const CashierName: WideString; const ParametersFiscal: WideString): WordBool;
begin
  Result := DefaultInterface.OperationFN(DeviceID, OperationType, CashierName, ParametersFiscal);
end;

function TDrvFR1C17.OpenShift(const DeviceID: WideString; const CashierName: WideString; 
                              out SessionNumber: Integer; out DocumentNumber: Integer): WordBool;
begin
  Result := DefaultInterface.OpenShift(DeviceID, CashierName, SessionNumber, DocumentNumber);
end;

function TDrvFR1C17.CloseShift(const DeviceID: WideString; const CashierName: WideString; 
                               out SessionNumber: Integer; out DocumentNumber: Integer): WordBool;
begin
  Result := DefaultInterface.CloseShift(DeviceID, CashierName, SessionNumber, DocumentNumber);
end;

function TDrvFR1C17.ProcessCheck(const DeviceID: WideString; const CashierName: WideString; 
                                 Electronically: WordBool; const CheckPackage: WideString; 
                                 out CheckNumber: Integer; out SessionNumber: Integer; 
                                 out FiscalSign: WideString; out AddressSiteInspections: WideString): WordBool;
begin
  Result := DefaultInterface.ProcessCheck(DeviceID, CashierName, Electronically, CheckPackage, 
                                          CheckNumber, SessionNumber, FiscalSign, 
                                          AddressSiteInspections);
end;

function TDrvFR1C17.ProcessCorrectionCheck(const DeviceID: WideString; 
                                           const CashierName: WideString; 
                                           const CheckCorrectionPackage: WideString; 
                                           out CheckNumber: Integer; out SessionNumber: Integer; 
                                           out FiscalSign: WideString; 
                                           out AddressSiteInspections: WideString): WordBool;
begin
  Result := DefaultInterface.ProcessCorrectionCheck(DeviceID, CashierName, CheckCorrectionPackage, 
                                                    CheckNumber, SessionNumber, FiscalSign, 
                                                    AddressSiteInspections);
end;

function TDrvFR1C17.CashInOutcome(const DeviceID: WideString; Amount: Double): WordBool;
begin
  Result := DefaultInterface.CashInOutcome(DeviceID, Amount);
end;

function TDrvFR1C17.GetCurrentStatus(const DeviceID: WideString; out CheckNumber: Integer; 
                                     out SessionNumber: Integer; out SessionState: Integer; 
                                     out StatusParameters: WideString): WordBool;
begin
  Result := DefaultInterface.GetCurrentStatus(DeviceID, CheckNumber, SessionNumber, SessionState, 
                                              StatusParameters);
end;

function TDrvFR1C17.ReportCurrentStatusOfSettlements(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.ReportCurrentStatusOfSettlements(DeviceID);
end;

function TDrvFR1C17.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.OpenCashDrawer(DeviceID);
end;

function TDrvFR1C17.GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool;
begin
  Result := DefaultInterface.GetLineLength(DeviceID, LineLength);
end;

function TDrvFR1C17.PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool;
begin
  Result := DefaultInterface.PrintTextDocument(DeviceID, DocumentPackage);
end;

procedure TDrvFR1C17.SetLang(LangID: Integer);
begin
  DefaultInterface.SetLang(LangID);
end;

function TDrvFR1C17.PrintXReport(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.PrintXReport(DeviceID);
end;

procedure TDrvFR1C22.InitControlData;
const
  CControlData: TControlData2 = (
    ClassID: '{E5903D73-66CC-42D7-9647-DBD2C837D8A7}';
    EventIID: '';
    EventCount: 0;
    EventDispIDs: nil;
    LicenseKey: nil (*HR:$00000000*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
end;

procedure TDrvFR1C22.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IDrvFR1C22;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TDrvFR1C22.GetControlInterface: IDrvFR1C22;
begin
  CreateControl;
  Result := FIntf;
end;

function TDrvFR1C22.GetVersion: WideString;
begin
  Result := DefaultInterface.GetVersion;
end;

function TDrvFR1C22.GetDescription(out Name: WideString; out Description: WideString; 
                                   out EquipmentType: WideString; out InterfaceRevision: Integer; 
                                   out IntegrationLibrary: WordBool; 
                                   out MainDriverInstalled: WordBool; out DownloadURL: WideString): WordBool;
begin
  Result := DefaultInterface.GetDescription(Name, Description, EquipmentType, InterfaceRevision, 
                                            IntegrationLibrary, MainDriverInstalled, DownloadURL);
end;

function TDrvFR1C22.GetLastError(out ErrorDescription: WideString): Integer;
begin
  Result := DefaultInterface.GetLastError(ErrorDescription);
end;

function TDrvFR1C22.GetParameters(out TableParameters: WideString): WordBool;
begin
  Result := DefaultInterface.GetParameters(TableParameters);
end;

function TDrvFR1C22.SetParameter(const Name: WideString; Value: OleVariant): WordBool;
begin
  Result := DefaultInterface.SetParameter(Name, Value);
end;

function TDrvFR1C22.Open(out DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.Open(DeviceID);
end;

function TDrvFR1C22.Close(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.Close(DeviceID);
end;

function TDrvFR1C22.DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool;
begin
  Result := DefaultInterface.DeviceTest(Description, DemoModeIsActivated);
end;

function TDrvFR1C22.GetAdditionalActions(out TableActions: WideString): WordBool;
begin
  Result := DefaultInterface.GetAdditionalActions(TableActions);
end;

function TDrvFR1C22.DoAdditionalAction(const ActionName: WideString): WordBool;
begin
  Result := DefaultInterface.DoAdditionalAction(ActionName);
end;

function TDrvFR1C22.GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool;
begin
  Result := DefaultInterface.GetDataKKT(DeviceID, TableParametersKKT);
end;

function TDrvFR1C22.OperationFN(const DeviceID: WideString; OperationType: Integer; 
                                const ParametersFiscal: WideString): WordBool;
begin
  Result := DefaultInterface.OperationFN(DeviceID, OperationType, ParametersFiscal);
end;

function TDrvFR1C22.OpenShift(const DeviceID: WideString; const InputParameters: WideString; 
                              out OutputParameters: WideString; out SessionNumber: Integer; 
                              out DocumentNumber: Integer): WordBool;
begin
  Result := DefaultInterface.OpenShift(DeviceID, InputParameters, OutputParameters, SessionNumber, 
                                       DocumentNumber);
end;

function TDrvFR1C22.CloseShift(const DeviceID: WideString; const InputParameters: WideString; 
                               out OutputParameters: WideString; out SessionNumber: Integer; 
                               out DocumentNumber: Integer): WordBool;
begin
  Result := DefaultInterface.CloseShift(DeviceID, InputParameters, OutputParameters, SessionNumber, 
                                        DocumentNumber);
end;

function TDrvFR1C22.ProcessCheck(const DeviceID: WideString; Electronically: WordBool; 
                                 const CheckPackage: WideString; out CheckNumber: Integer; 
                                 out SessionNumber: Integer; out FiscalSign: WideString; 
                                 out AddressSiteInspections: WideString): WordBool;
begin
  Result := DefaultInterface.ProcessCheck(DeviceID, Electronically, CheckPackage, CheckNumber, 
                                          SessionNumber, FiscalSign, AddressSiteInspections);
end;

function TDrvFR1C22.ProcessCorrectionCheck(const DeviceID: WideString; 
                                           const CheckCorrectionPackage: WideString; 
                                           out CheckNumber: Integer; out SessionNumber: Integer; 
                                           out FiscalSign: WideString; 
                                           out AddressSiteInspections: WideString): WordBool;
begin
  Result := DefaultInterface.ProcessCorrectionCheck(DeviceID, CheckCorrectionPackage, CheckNumber, 
                                                    SessionNumber, FiscalSign, 
                                                    AddressSiteInspections);
end;

function TDrvFR1C22.PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool;
begin
  Result := DefaultInterface.PrintTextDocument(DeviceID, DocumentPackage);
end;

function TDrvFR1C22.CashInOutcome(const DeviceID: WideString; const InputParameters: WideString; 
                                  Amount: Double): WordBool;
begin
  Result := DefaultInterface.CashInOutcome(DeviceID, InputParameters, Amount);
end;

function TDrvFR1C22.PrintXReport(const DeviceID: WideString; const InputParameters: WideString): WordBool;
begin
  Result := DefaultInterface.PrintXReport(DeviceID, InputParameters);
end;

function TDrvFR1C22.GetCurrentStatus(const DeviceID: WideString; out CheckNumber: Integer; 
                                     out SessionNumber: Integer; out SessionState: Integer; 
                                     out StatusParameters: WideString): WordBool;
begin
  Result := DefaultInterface.GetCurrentStatus(DeviceID, CheckNumber, SessionNumber, SessionState, 
                                              StatusParameters);
end;

function TDrvFR1C22.ReportCurrentStatusOfSettlements(const DeviceID: WideString; 
                                                     const InputParameters: WideString; 
                                                     out OutputParameters: WideString): WordBool;
begin
  Result := DefaultInterface.ReportCurrentStatusOfSettlements(DeviceID, InputParameters, 
                                                              OutputParameters);
end;

function TDrvFR1C22.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.OpenCashDrawer(DeviceID);
end;

function TDrvFR1C22.GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool;
begin
  Result := DefaultInterface.GetLineLength(DeviceID, LineLength);
end;

procedure TDrvFR1C22.SetLang(LangID: Integer);
begin
  DefaultInterface.SetLang(LangID);
end;

procedure TDrvFR1C30.InitControlData;
const
  CControlData: TControlData2 = (
    ClassID: '{32D32C7A-CEF9-4AC5-8953-3D6DF81ABBD6}';
    EventIID: '';
    EventCount: 0;
    EventDispIDs: nil;
    LicenseKey: nil (*HR:$00000000*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
end;

procedure TDrvFR1C30.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IDrvFR1C30;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TDrvFR1C30.GetControlInterface: IDrvFR1C30;
begin
  CreateControl;
  Result := FIntf;
end;

function TDrvFR1C30.GetInterfaceRevision: Integer;
begin
  Result := DefaultInterface.GetInterfaceRevision;
end;

function TDrvFR1C30.GetDescription(out DriverDescription: WideString): WordBool;
begin
  Result := DefaultInterface.GetDescription(DriverDescription);
end;

function TDrvFR1C30.GetLastError(out ErrorDescription: WideString): Integer;
begin
  Result := DefaultInterface.GetLastError(ErrorDescription);
end;

function TDrvFR1C30.GetParameters(out TableParameters: WideString): WordBool;
begin
  Result := DefaultInterface.GetParameters(TableParameters);
end;

function TDrvFR1C30.SetParameter(const Name: WideString; Value: OleVariant): WordBool;
begin
  Result := DefaultInterface.SetParameter(Name, Value);
end;

function TDrvFR1C30.Open(out DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.Open(DeviceID);
end;

function TDrvFR1C30.Close(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.Close(DeviceID);
end;

function TDrvFR1C30.DeviceTest(out Description: WideString; out DemoModeIsActivated: WideString): WordBool;
begin
  Result := DefaultInterface.DeviceTest(Description, DemoModeIsActivated);
end;

function TDrvFR1C30.GetAdditionalActions(out TableActions: WideString): WordBool;
begin
  Result := DefaultInterface.GetAdditionalActions(TableActions);
end;

function TDrvFR1C30.DoAdditionalAction(const ActionName: WideString): WordBool;
begin
  Result := DefaultInterface.DoAdditionalAction(ActionName);
end;

function TDrvFR1C30.GetDataKKT(const DeviceID: WideString; out TableParametersKKT: WideString): WordBool;
begin
  Result := DefaultInterface.GetDataKKT(DeviceID, TableParametersKKT);
end;

function TDrvFR1C30.OperationFN(const DeviceID: WideString; OperationType: Integer; 
                                const ParametersFiscal: WideString): WordBool;
begin
  Result := DefaultInterface.OperationFN(DeviceID, OperationType, ParametersFiscal);
end;

function TDrvFR1C30.OpenShift(const DeviceID: WideString; const InputParameters: WideString; 
                              out OutputParameters: WideString): WordBool;
begin
  Result := DefaultInterface.OpenShift(DeviceID, InputParameters, OutputParameters);
end;

function TDrvFR1C30.CloseShift(const DeviceID: WideString; const InputParameters: WideString; 
                               out OutputParameters: WideString): WordBool;
begin
  Result := DefaultInterface.CloseShift(DeviceID, InputParameters, OutputParameters);
end;

function TDrvFR1C30.ProcessCheck(const DeviceID: WideString; Electronically: WordBool; 
                                 const CheckPackage: WideString; 
                                 out DocumentOutputParameters: WideString): WordBool;
begin
  Result := DefaultInterface.ProcessCheck(DeviceID, Electronically, CheckPackage, 
                                          DocumentOutputParameters);
end;

function TDrvFR1C30.ProcessCorrectionCheck(const DeviceID: WideString; 
                                           const CheckPackage: WideString; 
                                           out DocumentOutputParameters: WideString): WordBool;
begin
  Result := DefaultInterface.ProcessCorrectionCheck(DeviceID, CheckPackage, DocumentOutputParameters);
end;

function TDrvFR1C30.CashInOutcome(const DeviceID: WideString; const InputParameters: WideString; 
                                  Amount: Double): WordBool;
begin
  Result := DefaultInterface.CashInOutcome(DeviceID, InputParameters, Amount);
end;

function TDrvFR1C30.PrintXReport(const DeviceID: WideString; const InputParameters: WideString): WordBool;
begin
  Result := DefaultInterface.PrintXReport(DeviceID, InputParameters);
end;

function TDrvFR1C30.GetCurrentStatus(const DeviceID: WideString; const InputParameters: WideString; 
                                     out OutputParameters: WideString): WordBool;
begin
  Result := DefaultInterface.GetCurrentStatus(DeviceID, InputParameters, OutputParameters);
end;

function TDrvFR1C30.ReportCurrentStatusOfSettlements(const DeviceID: WideString; 
                                                     const InputParameters: WideString; 
                                                     out OutputParameters: WideString): WordBool;
begin
  Result := DefaultInterface.ReportCurrentStatusOfSettlements(DeviceID, InputParameters, 
                                                              OutputParameters);
end;

function TDrvFR1C30.OpenCashDrawer(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.OpenCashDrawer(DeviceID);
end;

function TDrvFR1C30.GetLineLength(const DeviceID: WideString; out LineLength: Integer): WordBool;
begin
  Result := DefaultInterface.GetLineLength(DeviceID, LineLength);
end;

function TDrvFR1C30.PrintCheckCopy(const DeviceID: WideString; const CheckNumber: WideString): WordBool;
begin
  Result := DefaultInterface.PrintCheckCopy(DeviceID, CheckNumber);
end;

function TDrvFR1C30.PrintTextDocument(const DeviceID: WideString; const DocumentPackage: WideString): WordBool;
begin
  Result := DefaultInterface.PrintTextDocument(DeviceID, DocumentPackage);
end;

function TDrvFR1C30.OpenSessionRegistrationKM(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.OpenSessionRegistrationKM(DeviceID);
end;

function TDrvFR1C30.CloseSessionRegistrationKM(const DeviceID: WideString): WordBool;
begin
  Result := DefaultInterface.CloseSessionRegistrationKM(DeviceID);
end;

function TDrvFR1C30.RequestKM(const DeviceID: WideString; const RequestKM: WideString; 
                              out RequestKMResult: WideString): WordBool;
begin
  Result := DefaultInterface.RequestKM(DeviceID, RequestKM, RequestKMResult);
end;

function TDrvFR1C30.GetProcessingKMResult(const DeviceID: WideString; 
                                          out ProcessingKMResult: WideString; 
                                          out RequestStatus: Integer): WordBool;
begin
  Result := DefaultInterface.GetProcessingKMResult(DeviceID, ProcessingKMResult, RequestStatus);
end;

function TDrvFR1C30.ConfirmKM(const DeviceID: WideString; const RequestGUID: WideString; 
                              ConfirmationType: Integer): WordBool;
begin
  Result := DefaultInterface.ConfirmKM(DeviceID, RequestGUID, ConfirmationType);
end;

function TDrvFR1C30.GetLocalizationPattern(out LocalizationPattern: WideString): WordBool;
begin
  Result := DefaultInterface.GetLocalizationPattern(LocalizationPattern);
end;

function TDrvFR1C30.SetLocalization(const LanguageCode: WideString; 
                                    const LocalizationPattern: WideString): WordBool;
begin
  Result := DefaultInterface.SetLocalization(LanguageCode, LocalizationPattern);
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TDrvFR1C, TDrvFR1C11, TDrvFR1C17, TDrvFR1C22, 
    TDrvFR1C30]);
end;

end.
