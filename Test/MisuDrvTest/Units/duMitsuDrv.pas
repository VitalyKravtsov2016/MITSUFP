unit duMitsuDrv;

interface

uses
  // This
  Windows, ComServ, ActiveX, ComObj, Controls, SysUtils, Classes,
  // DUnit
  TestFramework,
  // This
  MitsuDrv;

type
  { TMitsuDrvTest }

  TMitsuDrvTest = class(TTestCase)
  private
    Driver: TMitsuDrv;
  protected
    procedure Setup; override;
    procedure TearDown; override;

  published
    procedure TestReadDeviceName;
  end;

implementation


{ TDriver1CstTest }

procedure TMitsuDrvTest.Setup;
begin
  Driver := TMitsuDrv.Create;
end;

procedure TMitsuDrvTest.TearDown;
begin
  Driver.Free;
end;

procedure TMitsuDrvTest.TestReadDeviceName;
var
  DeviceName: WideString;
begin
  Driver.Check(Driver.ReadDeviceName(DeviceName));
end;

initialization
  RegisterTest('', TMitsuDrvTest.Suite);

end.
