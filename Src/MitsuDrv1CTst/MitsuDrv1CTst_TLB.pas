unit MitsuDrv1CTst_TLB;

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
// File generated on 29.04.2024 12:30:51 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\projects\MITSUFP\Src\MitsuDrv1CTst\MitsuDrv1CTst.tlb (1)
// LIBID: {4B63112D-6936-441D-8DE7-6E4B14961793}
// LCID: 0
// Helpfile: 
// HelpString: Test1Cst Library
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
  MitsuDrv1CTstMajorVersion = 1;
  MitsuDrv1CTstMinorVersion = 0;

  LIBID_MitsuDrv1CTst: TGUID = '{4B63112D-6936-441D-8DE7-6E4B14961793}';

  IID_IArray1C: TGUID = '{257B0EF4-B50F-4195-83FC-EDE6762EC643}';
  CLASS_Array1C: TGUID = '{D5C728D6-6EB8-4586-BBE5-C60685A1CC30}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IArray1C = interface;
  IArray1CDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  Array1C = IArray1C;


// *********************************************************************//
// Interface: IArray1C
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {257B0EF4-B50F-4195-83FC-EDE6762EC643}
// *********************************************************************//
  IArray1C = interface(IDispatch)
    ['{257B0EF4-B50F-4195-83FC-EDE6762EC643}']
    function Get(Index: Integer): OleVariant; safecall;
    procedure Set_(Index: Integer; Value: OleVariant); safecall;
  end;

// *********************************************************************//
// DispIntf:  IArray1CDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {257B0EF4-B50F-4195-83FC-EDE6762EC643}
// *********************************************************************//
  IArray1CDisp = dispinterface
    ['{257B0EF4-B50F-4195-83FC-EDE6762EC643}']
    function Get(Index: Integer): OleVariant; dispid 201;
    procedure Set_(Index: Integer; Value: OleVariant); dispid 202;
  end;

// *********************************************************************//
// The Class CoArray1C provides a Create and CreateRemote method to          
// create instances of the default interface IArray1C exposed by              
// the CoClass Array1C. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoArray1C = class
    class function Create: IArray1C;
    class function CreateRemote(const MachineName: string): IArray1C;
  end;

implementation

uses ComObj;

class function CoArray1C.Create: IArray1C;
begin
  Result := CreateComObject(CLASS_Array1C) as IArray1C;
end;

class function CoArray1C.CreateRemote(const MachineName: string): IArray1C;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Array1C) as IArray1C;
end;

end.
