unit SMDrvFR1CLib_TLB;

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
// File generated on 01.05.2024 12:19:37 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\projects\MITSUFP\Src\MitsuDrv1C\MitsuDrv1C.tlb (1)
// LIBID: {F71B4DED-B3CC-4A90-9EB0-5362648DDDE9}
// LCID: 0
// Helpfile: 
// HelpString: SMDrvFR1C Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  SMDrvFR1CLibMajorVersion = 1;
  SMDrvFR1CLibMinorVersion = 0;

  LIBID_SMDrvFR1CLib: TGUID = '{F71B4DED-B3CC-4A90-9EB0-5362648DDDE9}';

  IID_IsmDrvFR1C: TGUID = '{FC17F072-CF8C-47EA-8C7B-8572DD59B93A}';
  CLASS_SMDrvFR1C: TGUID = '{10C59DAA-A60E-4AE1-B30F-A1B94640117F}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IsmDrvFR1C = interface;
  IsmDrvFR1CDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  SMDrvFR1C = IsmDrvFR1C;


// *********************************************************************//
// Interface: IsmDrvFR1C
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FC17F072-CF8C-47EA-8C7B-8572DD59B93A}
// *********************************************************************//
  IsmDrvFR1C = interface(IDispatch)
    ['{FC17F072-CF8C-47EA-8C7B-8572DD59B93A}']
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
    function OpenShift(const DeviceID: WideString): WordBool; safecall;
    function PrintFiscalString2(const DeviceID: WideString; const Name: WideString; 
                                Quantity: Double; Price: Double; Amount: Double; 
                                Department: Integer; Tax1: Integer; Tax2: Integer; Tax3: Integer; 
                                Tax4: Integer): WordBool; safecall;
    function ContinuePrinting(const DeviceID: WideString): WordBool; safecall;
    function CheckPrintingStatus(const DeviceID: WideString): WordBool; safecall;
  end;

// *********************************************************************//
// DispIntf:  IsmDrvFR1CDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FC17F072-CF8C-47EA-8C7B-8572DD59B93A}
// *********************************************************************//
  IsmDrvFR1CDisp = dispinterface
    ['{FC17F072-CF8C-47EA-8C7B-8572DD59B93A}']
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
    function OpenShift(const DeviceID: WideString): WordBool; dispid 222;
    function PrintFiscalString2(const DeviceID: WideString; const Name: WideString; 
                                Quantity: Double; Price: Double; Amount: Double; 
                                Department: Integer; Tax1: Integer; Tax2: Integer; Tax3: Integer; 
                                Tax4: Integer): WordBool; dispid 223;
    function ContinuePrinting(const DeviceID: WideString): WordBool; dispid 224;
    function CheckPrintingStatus(const DeviceID: WideString): WordBool; dispid 225;
  end;

// *********************************************************************//
// The Class CoSMDrvFR1C provides a Create and CreateRemote method to          
// create instances of the default interface IsmDrvFR1C exposed by              
// the CoClass SMDrvFR1C. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSMDrvFR1C = class
    class function Create: IsmDrvFR1C;
    class function CreateRemote(const MachineName: string): IsmDrvFR1C;
  end;

implementation

uses ComObj;

class function CoSMDrvFR1C.Create: IsmDrvFR1C;
begin
  Result := CreateComObject(CLASS_SMDrvFR1C) as IsmDrvFR1C;
end;

class function CoSMDrvFR1C.CreateRemote(const MachineName: string): IsmDrvFR1C;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SMDrvFR1C) as IsmDrvFR1C;
end;

end.
