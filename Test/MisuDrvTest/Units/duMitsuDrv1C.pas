unit duMitsuDrv1C;

interface

uses
  // This
  Windows, ComServ, ActiveX, ComObj, SysUtils, Classes, Math,
  XMLDoc, XmlIntf,
  // DUnit
  TestFramework,
  // This
  MitsuDrv, MitsuDrv_1C, StringUtils, FFDTypes, XmlDoc1C, FileUtils, LogFile;

type
  { TMitsuDrv1CTest }

  TMitsuDrv1CTest = class(TTestCase)
  private
    Logger: ILogFile;
    Driver: TMitsuDrv1C;
    DeviceID: WideString;
    procedure OpenDevice;
  protected
    procedure Setup; override;
    procedure TearDown; override;
  published
    procedure TestXml;
    procedure TestGetInterfaceRevision;
    procedure TestGetDescription;
    procedure TestGetLastError;
    procedure TestGetParameters;
    procedure TestSetParameter;
    procedure TestOpenClose;
    procedure TestDeviceTest;
    procedure TestGetAdditionalActions;
    procedure TestDoAdditionalAction;
    procedure TestGetDataKKT;
    procedure TestOpenShift;
    procedure TestCloseShift;
    procedure TestOpenCashDrawer;
  end;

implementation

{ TDriver1CstTest }

procedure TMitsuDrv1CTest.Setup;
begin
  Logger := TLogFile.Create;
  Driver := TMitsuDrv1C.Create(Logger);
end;

procedure TMitsuDrv1CTest.TearDown;
begin
  Driver.Free;
end;

procedure TMitsuDrv1CTest.TestXml;
var
  Node: IXMLNode;
  Xml: IXMLDocument;
  XmlText: WideString;
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('DriverDescription');
    Node.Attributes['EquipmentType'] := 'Русский';
    Node.Attributes['EquipmentType2'] := 'Russian';
    Xml.SaveToFile('GetDescription.xml');
    Xml.SaveToXML(XmlText);
  finally
    Xml := nil;
  end;
end;

procedure TMitsuDrv1CTest.TestGetInterfaceRevision;
begin
  CheckEquals(4001, Driver.GetInterfaceRevision, 'InterfaceRevision');
end;

procedure TMitsuDrv1CTest.TestGetDescription;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
  Description: WideString;
begin
  CheckEquals(True, Driver.GetDescription(Description));
  WriteFileDataW('GetDescription.xml', Description);
  Xml := LoadXMLData(Description);
  Node := Xml.DocumentElement;
  CheckEquals('ККТ', Node.Attributes['EquipmentType'], 'EquipmentType');
  CheckEquals('Драйвер ККТ с передачей данных в ОФД 4.1 (Win32)',
    Node.Attributes['Name'], 'Name');
  CheckEquals('Драйвер ККТ с передачей данных в ОФД 4.1 (Win32)',
    Node.Attributes['Description'], 'Description');

  CheckEquals('true', Node.Attributes['IntegrationComponent'], 'IntegrationComponent');
  CheckEquals('true', Node.Attributes['MainDriverInstalled'], 'MainDriverInstalled');
  CheckEquals('1.2.3.4', Node.Attributes['DriverVersion'], 'DriverVersion');
  CheckEquals('1.2.3.4', Node.Attributes['IntegrationComponentVersion'], 'IntegrationComponentVersion');
  CheckEquals('http://www.vav.ru/support/download', Node.Attributes['DownloadURL'], 'DownloadURL');
  CheckEquals('', Node.Attributes['LogPath'], 'LogPath');
  CheckEquals('false', Node.Attributes['LogIsEnabled'], 'LogIsEnabled');
end;

procedure TMitsuDrv1CTest.TestGetLastError;
var
  ErrorDescription: WideString;
begin
  Driver.ResultCode := 10;
  Driver.ResultDescription := 'Ошибка';
  CheckEquals(10, Driver.GetLastError(ErrorDescription), 'GetLastError');
  CheckEquals('0Ah, Ошибка', ErrorDescription, 'ErrorDescription');
end;

procedure TMitsuDrv1CTest.TestGetParameters;
var
  Node: IXmlNode;
  Xml: IXMLDocument;
  XmlText: WideString;
begin
  CheckEquals(True, Driver.GetParameters(XmlText), 'GetParameters');
  Xml := LoadXMLData(XmlText);
  Xml.SaveToFile('GetParameters.xml');
end;

procedure TMitsuDrv1CTest.TestSetParameter;
begin

end;

procedure TMitsuDrv1CTest.TestOpenClose;
var
  DeviceID: WideString;
begin
  Driver.SetParameter('ConnectionType', ConnectionTypeSerial);
  Driver.SetParameter('Port', 'COM8');
  Driver.SetParameter('Baudrate', 115200);
  CheckEquals(True, Driver.Open(DeviceID), 'Open');

  CheckEquals('0', DeviceID, 'DeviceID');
  CheckEquals(False, Driver.Close('Test'), 'Close.1');
  CheckEquals(True, Driver.Close(DeviceID), 'Close.2');
end;

procedure TMitsuDrv1CTest.TestDeviceTest;
var
  DeviceID: WideString;
  Description: WideString;
  DemoModeIsActivated: WideString;
begin
  Driver.SetParameter('ConnectionType', ConnectionTypeSerial);
  Driver.SetParameter('Port', 'COM8');
  Driver.SetParameter('Baudrate', 115200);
  CheckEquals(True, Driver.Open(DeviceID), 'Open');

  CheckEquals(True, Driver.DeviceTest(Description, DemoModeIsActivated), 'DeviceTest');
  CheckEquals('MITSU-1-F №065001000000008', Description, 'Description');
  CheckEquals('', DemoModeIsActivated, 'DemoModeIsActivated');
end;

procedure TMitsuDrv1CTest.TestGetAdditionalActions;
var
  Actions: WideString;
  Actions2: WideString;
begin
  CheckEquals(True, Driver.GetAdditionalActions(Actions), 'GetAdditionalActions');
  //WriteFileData('AdditionalActions.xml', WideStringToAnsiString(1251, Actions));
  Actions2 := AnsiStringToWideString(1251, ReadFileData('AdditionalActions.xml'));
  CheckEquals(Actions2, Actions, 'Actions');
end;

procedure TMitsuDrv1CTest.TestDoAdditionalAction;
begin
  CheckEquals(False, Driver.DoAdditionalAction('123'), '123');
  CheckEquals(True, Driver.DoAdditionalAction('TaxReport'), 'TaxReport');
  CheckEquals(True, Driver.DoAdditionalAction('DepartmentReport'), 'DepartmentReport');
end;

procedure TMitsuDrv1CTest.OpenDevice;
begin
  Driver.SetParameter('ConnectionType', ConnectionTypeSerial);
  Driver.SetParameter('Port', 'COM8');
  Driver.SetParameter('Baudrate', 115200);
  CheckEquals(True, Driver.Open(DeviceID), 'Open');
end;

procedure TMitsuDrv1CTest.TestGetDataKKT;
var
  TableParametersKKT: WideString;
begin
  OpenDevice;
  CheckEquals(True, Driver.GetDataKKT(DeviceID, TableParametersKKT));
  WriteFileData('TableParametersKKT.xml', WideStringToAnsiString(1251, TableParametersKKT));
end;

procedure TMitsuDrv1CTest.TestOpenShift;
var
  InputXml: WideString;
  OutputXml: WideString;
  InParameters: TInputParametersRec;
begin
  OpenDevice;

  InParameters.CashierName := 'CashierName';
  InParameters.CashierINN := '505303696069';
  InParameters.SaleAddress := 'SaleAddress';
  InParameters.SaleLocation := 'SaleLocation';
  InParameters.PrintRequired := True;
  TXmlDoc1C.Write(InputXml, InParameters);
  CheckEquals(True, Driver.OpenShift(DeviceID, InputXml, OutputXml));
end;

procedure TMitsuDrv1CTest.TestCloseShift;
var
  InputXml: WideString;
  OutputXml: WideString;
  InParameters: TInputParametersRec;
begin
  OpenDevice;

  InParameters.CashierName := 'CashierName';
  InParameters.CashierINN := '505303696069';
  InParameters.SaleAddress := 'SaleAddress';
  InParameters.SaleLocation := 'SaleLocation';
  InParameters.PrintRequired := True;
  TXmlDoc1C.Write(InputXml, InParameters);
  CheckEquals(True, Driver.CloseShift(DeviceID, InputXml, OutputXml));
end;

procedure TMitsuDrv1CTest.TestOpenCashDrawer;
begin
  OpenDevice;
  CheckEquals(True, Driver.OpenCashDrawer(DeviceID), 'OpenCashDrawer');
end;

initialization

  RegisterTest('', TMitsuDrv1CTest.Suite);

end.
