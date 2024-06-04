unit XmlDoc1C;

interface

uses
  // VCL
  SysUtils, Classes, XMLDoc, XMLIntf, DateUtils, Variants,
  // DCP
  DCPbase64,
  // This
  XmlUtils, StringUtils, GS1Util;

const
  /// ////////////////////////////////////////////////////////////////////////////
  // Day status constants

  D1C_DS_CLOSED = 1; // 1 - Закрыта
  D1C_DS_OPENED = 2; // 2 - Открыта
  D1C_DS_EXPIRED = 3; // 3 - Истекла

  /// ////////////////////////////////////////////////////////////////////////////
  // OperationType constants for method OperationFN

  D1C_FNOT_OPEN = 1; // Регистрация
  D1C_FNOT_CHANGE = 2; // Изменение параметров регистрации
  D1C_FNOT_CLOSE = 3; // Закрытие ФН

type
  IDrvFR1C30 = interface(IDispatch)
    ['{E390D34B-02C3-46C8-803C-DB8131AC5331}']
    function GetInterfaceRevision: Integer; safecall;
    function GetDescription(out DriverDescription: WideString)
      : WordBool; safecall;
    function GetLastError(out ErrorDescription: WideString): Integer; safecall;
    function GetParameters(out TableParameters: WideString): WordBool; safecall;
    function SetParameter(const Name: WideString; Value: OleVariant)
      : WordBool; safecall;
    function Open(out DeviceID: WideString): WordBool; safecall;
    function Close(const DeviceID: WideString): WordBool; safecall;
    function DeviceTest(out Description: WideString;
      out DemoModeIsActivated: WideString): WordBool; safecall;
    function GetAdditionalActions(out TableActions: WideString)
      : WordBool; safecall;
    function DoAdditionalAction(const ActionName: WideString)
      : WordBool; safecall;
    function GetDataKKT(const DeviceID: WideString;
      out TableParametersKKT: WideString): WordBool; safecall;
    function OperationFN(const DeviceID: WideString; OperationType: Integer;
      const ParametersFiscal: WideString): WordBool; safecall;
    function OpenShift(const DeviceID: WideString;
      const InputParameters: WideString; out OutputParameters: WideString)
      : WordBool; safecall;
    function CloseShift(const DeviceID: WideString;
      const InputParameters: WideString; out OutputParameters: WideString)
      : WordBool; safecall;
    function ProcessCheck(const DeviceID: WideString; Electronically: WordBool;
      const CheckPackage: WideString; out DocumentOutputParameters: WideString)
      : WordBool; safecall;
    function ProcessCorrectionCheck(const DeviceID: WideString;
      const CheckPackage: WideString; out DocumentOutputParameters: WideString)
      : WordBool; safecall;
    function CashInOutcome(const DeviceID: WideString;
      const InputParameters: WideString; Amount: Double): WordBool; safecall;
    function PrintXReport(const DeviceID: WideString;
      const InputParameters: WideString): WordBool; safecall;
    function GetCurrentStatus(const DeviceID: WideString;
      const InputParameters: WideString; out OutputParameters: WideString)
      : WordBool; safecall;
    function ReportCurrentStatusOfSettlements(const DeviceID: WideString;
      const InputParameters: WideString; out OutputParameters: WideString)
      : WordBool; safecall;
    function OpenCashDrawer(const DeviceID: WideString): WordBool; safecall;
    function GetLineLength(const DeviceID: WideString; out LineLength: Integer)
      : WordBool; safecall;
    function PrintCheckCopy(const DeviceID: WideString;
      const CheckNumber: WideString): WordBool; safecall;
    function PrintTextDocument(const DeviceID: WideString;
      const DocumentPackage: WideString): WordBool; safecall;
    function Get_sm_FormatVersion: Integer; safecall;
    procedure Set_sm_FormatVersion(Value: Integer); safecall;
    function OpenSessionRegistrationKM(const DeviceID: WideString)
      : WordBool; safecall;
    function CloseSessionRegistrationKM(const DeviceID: WideString)
      : WordBool; safecall;
    function RequestKM(const DeviceID: WideString; const RequestKM: WideString;
      out RequestKMResult: WideString): WordBool; safecall;
    function GetProcessingKMResult(const DeviceID: WideString;
      out ProcessingKMResult: WideString; out RequestStatus: Integer)
      : WordBool; safecall;
    function ConfirmKM(const DeviceID: WideString;
      const RequestGUID: WideString; ConfirmationType: Integer)
      : WordBool; safecall;
    function GetLocalizationPattern(out LocalizationPattern: WideString)
      : WordBool; safecall;
    function SetLocalization(const LanguageCode: WideString;
      const LocalizationPattern: WideString): WordBool; safecall;
    property sm_FormatVersion: Integer read Get_sm_FormatVersion
      write Set_sm_FormatVersion;
  end;

  { TParametersKKT }

  TParametersKKT = class
    // 3.3
    KKTNumber: WideString; // Регистрационный номер ККТ
    KKTSerialNumber: WideString; // Заводской номер ККТ
    FirmwareVersion: WideString; // Версия прошивки
    Fiscal: Boolean; // Признак регистрации фискального накопителя
    FFDVersionFN: WideString;
    // Версия ФФД ФН (одно из следующих значений "1.0","1.1")
    FFDVersionKKT: WideString;
    // Версия ФФД ККТ (одно из следующих значений "1.0","1.0.5","1.1")
    FNSerialNumber: WideString; // Заводской номер ФН
    DocumentNumber: WideString;
    // Номер документа регистрация фискального накопителя
    DateTime: TDateTime;
    // Дата и время операции регистрации фискального накопителя
    CompanyName: WideString; // Название организации
    CompanyINN: WideString; // ИНН организация
    SaleAddress: WideString; // Адрес проведения расчетов
    SaleLocation: WideString; // Место проведения расчетов
    TaxSystems: WideString;
    // Коды системы налогообложения через разделитель ",".
    IsOffline: Boolean; // Признак автономного режима
    IsEncrypted: Boolean; // Признак шифрование данных
    IsService: Boolean; // Признак расчетов за услуги
    IsExcisable: Boolean; // Продажа подакцизного товара
    IsGambling: Boolean; // Признак проведения азартных игр
    IsLottery: Boolean; // Признак проведения лотереи
    AgentTypes: WideString; // Коды признаков агента через разделитель ",".
    IsBlank: Boolean; // Признак формирования АС БСО
    IsAutomaticPrinter: Boolean; // Признак установки принтера в автомате
    IsAutomatic: Boolean; // Признак автоматического режима
    AutomaticNumber: WideString; // Номер автомата для автоматического режима
    OFDCompany: WideString; // Название организации ОФД
    OFDCompanyINN: WideString; // ИНН организации ОФД
    FNSURL: WideString;
    // Адрес сайта уполномоченного органа (ФНС) в сети «Интернет»
    SenderEmail: WideString; // Адрес электронной почты отправителя чека
    // 3.4
    IsOnline: Boolean; // Признак ККТ для расчетов в Интернет
    IsMarking: Boolean;
    // Признак применения при осуществлении торговли товарами, подлежащими обязательной маркировке средствами идентификации
    IsPawnshop: Boolean;
    // Признак применения при осуществлении ломбардами кредитования граждан
    IsInsurance: Boolean;
    // Признак применения при осуществлении деятельности по страхованию
    // 4.1
    IsVendingMachine: Boolean;
    // Признак применения в автоматическом торговом автомате
    IsCatering: Boolean;
    // Признак применения при оказании услуг общественного питания
    IsWholesale: Boolean;
    // Признак применения о оптовой торговле с организациями и ИП
  end;

  { TParametersFiscal }

  TParametersFiscal = class(TParametersKKT)
  public
    CashierName: WideString;
    // ФИО и должность уполномоченного лица для проведения операции
    CashierINN: WideString; // ИНН уполномоченного лица для проведения операции
    FFDVersion: WideString;
    // Версия ФФД на который регистрируется ФН (одно из следующих значений "1.0","1.0.5","1.1", "1.2")
    RegistrationLabelCodes: WideString;
    // Коды причин изменения сведений о ККТ через разделитель ".
  end;

  { TInputParametersRec }

  TInputParametersRec = record
    CashierName: WideString;
    CashierINN: WideString;
    SaleAddress: WideString;
    SaleLocation: WideString;
    PrintRequired: Boolean;
  end;

  { TOperationCountersRec }

  TOperationCountersRec = record
    CheckCount: Integer; // Количество чеков по операции данного типа
    TotalChecksAmount: Double; // Итоговая сумма чеков по операциям данного типа
    CorrectionCheckCount: Integer;
    // Количество чеков коррекции по операции данного типа
    TotalCorrectionChecksAmount: Double;
    // Итоговая сумма чеков коррекции по операциям данного типа
  end;

  { TOutputParametersRec }

  TOutputParametersRec = record
    ShiftNumber: Integer; // Номер открытой смены/Номер закрытой смены
    CheckNumber: Integer; // Номер последнего фискального документа
    ShiftClosingCheckNumber: Integer; // Номер последнего чека за смену
    DateTime: TDateTime; // Дата и время формирования фискального документа
    ShiftState: Integer;
    // Состояние смены 1 - Закрыта, 2 - Открыта, 3 - Истекла
    CountersOperationType1: TOperationCountersRec;
    // OperationCounters	Счетчики операций по типу "приход"
    CountersOperationType2: TOperationCountersRec;
    // Счетчики операций по типу "возврат прихода"
    CountersOperationType3: TOperationCountersRec;
    // Счетчики операций по типу "расход"
    CountersOperationType4: TOperationCountersRec;
    // Счетчики операций по типу "возврат расхода"
    CashBalance: Double; // Остаток наличных денежных средств в кассе
    BacklogDocumentsCounter: Integer; // Количество непереданных документов
    BacklogDocumentFirstNumber: Integer;
    // Номер первого непереданного документа
    BacklogDocumentFirstDateTime: TDateTime;
    // Дата и время первого из непереданных документов
    FNError: Boolean; // Признак необходимости срочной замены ФН
    FNOverflow: Boolean; // Признак переполнения памяти ФН
    FNFail: Boolean; // Признак исчерпания ресурса ФН
    FNValidityDate: TDateTime; // Срок действия ФН
  end;

  TDocumentOutputParametersRec = record
    ShiftNumber: Integer; // Номер открытой смены/Номер закрытой смены
    CheckNumber: Integer; // Номер фискального документа
    ShiftClosingCheckNumber: Integer; // Номер чека за смену
    AddressSiteInspections: string; // Адрес сайта проверки
    FiscalSign: string; // Фискальный признак
    DateTime: TDateTime; // Дата и время формирования документа
    MTNumber: Integer;
    // Номер документа "Уведомление о реализации МТ" в который включается данные чека.
    PrintError: Boolean; // Ошибка при печати бумажной формы чека
  end;

  TCorrectionDataRec = record
    AType: Integer; // Тип коррекции 0 - самостоятельно, 1 - по предписанию
    Description: string; // Описание коррекции
    Date: TDateTime; // Дата совершения корректируемого расчета
    Number: string; // Номер предписания налогового органа
  end;

  TAgentDataRec = record
    AgentOperation: string; // Операция платежного агента
    AgentPhone: string;
    // Телефон платежного агента. Допустимо несколько значений через разделитель ",".
    PaymentProcessorPhone: string;
    // Телефон оператора по приему платежей. Допустимо несколько значений через разделитель ",".
    AcquirerOperatorPhone: string;
    // Телефон оператора перевода. Допустимо несколько значений через разделитель ",".
    AcquirerOperatorName: string; // Наименование оператора перевода
    AcquirerOperatorAddress: string; // Адрес оператора перевода
    AcquirerOperatorINN: string; // ИНН оператора перевода
  end;

  TVendorDataRec = record
    VendorPhone: string;
    // Телефон поставщика  Допустимо несколько значений через разделитель ",".
    VendorName: string; // Наименование поставщика
    VendorINN: string; // ИНН поставщика
  end;

  TUserAttributeRec = record
    Name: string; // Имя реквизита
    Value: string; // Значение реквизита
  end;

  TProcessingKMResult = record
    RequestStatus: Integer;
    GUID: string;
    Res: Boolean;
    ResultCode: Integer;
    HasStatusInfo: Boolean;
    StatusInfo: Integer;
    HandleCode: Integer;
    isOSU: Boolean;
    MarkingType2: Integer;
  end;

  { TRequestKM }

  TRequestKM = record
    GUID: string;
    WaitForResult: Boolean;
    MarkingCode: AnsiString;
    PlannedStatus: Integer;
    Quantity: Double;
    MeasureOfQuantity: Integer;
    Numerator: Integer;
    Denominator: Integer;
    NotSendToServer: Boolean;

    HasQuantity: Boolean;
    HasMeasureOfQuantity: Boolean;
    HasFractionalQuantity: Boolean;
  end;

  { TRequestKMResult }

  TRequestKMResult = record
    Checking: Boolean;
    CheckingResult: Boolean;
  end;

  { TPayments }

  TPayments = record
    Cash: Currency;
    ElectronicPayment: Currency;
    PrePayment: Currency;
    PostPayment: Currency;
    Barter: Currency;
  end;

  { TCorrectionData }

  TCorrectionData = record
    Enabled: Boolean;
    AType: Integer; // Тип коррекции 0 - самостоятельно 1 - по предписанию
    Description: WideString; // Описание коррекции
    Date: TDateTime; // Дата совершения корректируемого расчета
    Number: WideString; // Номер предписания налогового органа
  end;

  { TAgentData }

  TAgentData = record
    Enabled: Boolean;
    AgentOperation: WideString; // Операция платежного агента 1044
    AgentPhone: WideString; // Телефон платежного агента 1073
    PaymentProcessorPhone: WideString;
    // Телефон оператора по приему платежей 1074
    AcquirerOperatorPhone: WideString; // Телефон оператора перевода 1075
    AcquirerOperatorName: WideString; // Наименование оператора перевода 1026
    AcquirerOperatorAddress: WideString; // Адрес оператора перевода 1005
    AcquirerOperatorINN: WideString; // ИНН оператора перевода 1016
  end;

  { TVendorData }

  TVendorData = record
    Enabled: Boolean;
    VendorPhone: WideString; // Телефон поставщика 1171
    VendorName: WideString; // Наименование поставщика 1225
    VendorINN: WideString; // ИНН поставщика 1226
  end;

  { TUserAttribute }

  TUserAttribute = record
    Enabled: Boolean;
    Name: string;
    Value: string;
  end;

  { TCheckCorrectionParamsRec3 }

  TCheckCorrectionParamsRec3 = record
    Id: string;
    CashierName: WideString;
    // ФИО уполномоченного лица для проведения операции 	Формирование нового чека с заданным атрибутами
    CashierVATIN: WideString;
    // ИНН уполномоченного лица для проведения операции
    CorrectionType: Integer; // Тип коррекции
    // 0 - самостоятельно
    // 1 - по предписанию
    TaxVariant: Integer; // Код системы налогообложения
    PaymentType: Integer; // Тип расчета
    // 1 - Приход
    // 2 - Возврат прихода
    // 3 - Расход
    // 4 - Возврат расхода
    CorrectionBaseName: WideString; // Наименование основания для коррекции
    CorrectionBaseDate: TDateTime; // Дата документа основания для коррекции
    CorrectionBaseNumber: WideString; // Номер документа основания для коррекции
    Sum: Currency; // Сумма расчета, указанного в чеке
    SumTAX18: Currency; // Сумма НДС чека по ставке 18%
    SumTAX10: Currency; // Сумма НДС чека по ставке 10%
    SumTAX0: Currency; // Сумма НДС чека по ставке 0%
    SumTAXNone: Currency; // Сумма НДС чека по без НДС
    SumTAX110: Currency; // Сумма НДС чека по расч. ставке 10/110
    SumTAX118: Currency; // Сумма НДС чека по расч. ставке 18/118
    Cash: Currency;
    // Сумма наличной оплаты 	Параметры закрытия чека. Чек коррекции может быть оплачен только одним видом оплаты и без сдачи.
    ElectronicPayment: Currency; // Сумма электронной оплаты
    AdvancePayment: Currency; // Сумма предоплатой (зачетом аванса)
    Credit: Currency; // Сумма постоплатой (в кредит)
    CashProvision: Currency; // Сумма встречным предоставлением
    SettlementsAddress: WideString;
    SettlementPlace: WideString;
  end;

  { TCustomerDetail }

  TCustomerDetail = record
    Enabled: Boolean;
    Info: string;
    // Наименование организации или фамилия, имя, отчество (при наличии)
    INN: string; // ИНН организации или покупателя (клиента)
    DateOfBirthEnabled: Boolean;
    DateOfBirth: TDateTime;
    // Дата рождения покупателя (клиента) в формате "DD.MM.YYYY"
    Citizenship: string;
    // Числовой код страны, гражданином которой является покупатель (клиент).
    // Код страны указывается в соответствии с Общероссийским классификатором стран мира ОКСМ.
    DocumentTypeCodeEnabled: Boolean;
    DocumentTypeCode: Integer;
    // Числовой код вида документа, удостоверяющего личность (ФФД, Таблица 116)
    DocumentData: string; // Данные документа, удостоверяющего личность
    Address: string; // Адрес покупателя (клиента)
  end;

  { TOperationalAttribute }

  TOperationalAttribute = record
    Enabled: Boolean;
    DateTime: TDateTime; // Дата, время операции
    OperationID: Integer; // Идентификатор операции
    OperationData: string; // Данные операции
  end;

  { TIndustryAttribute }

  TIndustryAttribute = record
    Enabled: Boolean;
    IdentifierFOIV: string; // Идентификатор ФОИВ
    DocumentDate: TDateTime; // Дата документа основания в формате "DD.MM.YYYY"
    DocumentNumber: string; // Номер документа основания
    AttributeValue: string; // Значение отраслевого реквизита
  end;

  { TFractionalQuantity }

  TFractionalQuantity = record
    Enabled: Boolean;
    Numerator: Integer;
    Denominator: Integer;
  end;

  { TItemCodeData }

  TItemCodeData = record
    MarkingType: Integer;
    GTIN: AnsiString;
    SerialNumber: AnsiString;
    Barcode: AnsiString;
  end;

  { TGoodCodeData }

  TGoodCodeData = record
    Enabled: Boolean;
    ItemCodeData: TItemCodeData;
    NotIdentified: AnsiString;
    // Код товара, формат которого не идентифицирован в Base64
    EAN8: AnsiString; // Код товара в формате EAN-8 в Base64
    EAN13: AnsiString; // Код товара в формате EAN-13 в Base64
    ITF14: AnsiString; // Код товара в формате ITF-14 в Base64
    GS1_0: AnsiString;
    // Код товара в формате GS1, нанесенный на товар, не подлежащий маркировке средствами идентификации в Base64
    GS1_M: AnsiString;
    // Код товара в формате GS1, нанесенный на товар, подлежащий маркировке средствами идентификации в Base64
    KMK: AnsiString;
    // Код товара в формате короткого кода маркировки, нанесенный на товар, подлежащий маркировке средствами идентификации в Base64
    MI: AnsiString; // Контрольно-идентификационный знак мехового изделия
    EGAIS20: AnsiString; // Код товара в формате ЕГАИС-2.0 в Base64
    EGAIS30: AnsiString; // Код товара в формате ЕГАИС-3.0 в Base64
    F1: AnsiString; // Код товара в формате Ф.1 в Base64
    F2: AnsiString; // Код товара в формате Ф.2 в Base64
    F3: AnsiString; // Код товара в формате Ф.3 в Base64
    F4: AnsiString; // Код товара в формате Ф.4 в Base64
    F5: AnsiString; // Код товара в формате Ф.5 в Base64
    F6: AnsiString; // Код товара в формате Ф.6 в Base64
    GTIN: AnsiString;
    // GTIN для формирования кода маркировки при продаже товаров в объемно-сортовом учете. При передаче этого поля формируется тег 2000 в Base64.
  end;

  { TDocItem }

  TDocItem = class(TCollectionItem);

  TDocItems = class(TCollection)
  private
    function GetItem(Index: Integer): TDocItem;
  public
    property Items[Index: Integer]: TDocItem read GetItem; default;
  end;

  { TFiscalString }

  TFiscalString = class(TDocItem)
  private
    FAmount: Double;
    FQuantity: Double;
    FTax: Integer;
    FPrice: Double;
    FName: WideString;
    FBarcode: WideString;
    FDepartment: Integer;
  public
    property Name: WideString read FName;
    property Barcode: WideString read FBarcode;
    property Quantity: Double read FQuantity;
    property Price: Double read FPrice;
    property Amount: Double read FAmount;
    property Tax: Integer read FTax;
    property Department: Integer read FDepartment;
  end;

  { TFiscalItem }

  TFiscalItem = class(TDocItem)
  private
    FName: WideString;
    FQuantity: Double;
    FPriceWithDiscount: Double;
    FSumWithDiscount: Double;
    FDiscountSum: Double;
    FDepartment: Integer;
    FTax: Integer;
    FTaxSumm: Double;
    FSignMethodCalculation: Integer;
    FSignCalculationObject: Integer;
    FMarking: AnsiString;
    FMarkingRaw: string;
    FAgentData: TAgentData;
    FVendorData: TVendorData;
    FAgentType: WideString;
    FCountryOfOfigin: WideString;
    FCustomsDeclaration: WideString;
    FExciseAmount: Double;
    FAdditionalAttribute: WideString;
    FMeasurementUnit: WideString;
    FIndustryAttribute: TIndustryAttribute;
    FMeasureQuantity: Integer;
    FFractionalQuantity: TFractionalQuantity;
    FGoodCodeData: TGoodCodeData;
    FMarkingCode: AnsiString;
    FMeasureOfQuantity: Integer;
  public
    property Name: WideString read FName;
    property Quantity: Double read FQuantity;
    property PriceWithDiscount: Double read FPriceWithDiscount;
    property SumWithDiscount: Double read FSumWithDiscount;
    property Tax: Integer read FTax;
    property Department: Integer read FDepartment;
    property SignMethodCalculation: Integer read FSignMethodCalculation;
    property SignCalculationObject: Integer read FSignCalculationObject;
    property DiscountSum: Double read FDiscountSum;
    property Marking: AnsiString read FMarking;
    property AgentData: TAgentData read FAgentData write FAgentData;
    property VendorData: TVendorData read FVendorData write FVendorData;
    property AgentSign: WideString read FAgentType write FAgentType;
    property CountryOfOfigin: WideString read FCountryOfOfigin
      write FCountryOfOfigin;
    property CustomsDeclaration: WideString read FCustomsDeclaration
      write FCustomsDeclaration;
    property ExciseAmount: Double read FExciseAmount write FExciseAmount;
    property AdditionalAttribute: WideString read FAdditionalAttribute
      write FAdditionalAttribute;
    property MeasurementUnit: WideString read FMeasurementUnit
      write FMeasurementUnit;
    property TaxSumm: Double read FTaxSumm;
    property MarkingRaw: string read FMarkingRaw write FMarkingRaw;

    property MeasureOfQuantity: Integer read FMeasureOfQuantity
      write FMeasureOfQuantity;
    property FractionalQuantity: TFractionalQuantity read FFractionalQuantity
      write FFractionalQuantity;
    property GoodCodeData: TGoodCodeData read FGoodCodeData write FGoodCodeData;
    property MarkingCode: AnsiString read FMarkingCode write FMarkingCode;
    property IndustryAttribute: TIndustryAttribute read FIndustryAttribute
      write FIndustryAttribute;
  end;

  { TTextItem }

  TTextItem = class(TDocItem)
  private
    FText: WideString;
  public
    property Text: WideString read FText;
  end;

  { TBarcodeItem }

  TBarcodeItem = class(TDocItem)
  private
    FBarcode: AnsiString;
    FBarcodeType: WideString;
  public
    property BarcodeType: WideString read FBarcodeType;
    property Barcode: AnsiString read FBarcode;
  end;

  { TTextDocument }

  TTextDocument = class
  private
    FItems: TDocItems;
  public
    constructor Create;
    destructor Destroy; override;
    property Items: TDocItems read FItems;
  end;

  { TReceiptRec }

  TReceiptRec = record
    Id: string;
    BPOVersion: Integer;
    DeliveryRetail: Boolean;
    SenderEmail: WideString;
    SaleAddress: WideString;
    SaleLocation: WideString;
    CustomerEmail: WideString;
    CustomerPhone: WideString;
    CustomerInfo: WideString;
    CustomerINN: WideString;
    AgentCompensation: Double;
    AgentPhone: WideString;
    CashierINN: WideString;
    AdditionalAttribute: WideString;
    CashierName: WideString;
    OperationType: Integer;
    TaxationSystem: Integer;
    FFDVersion: Integer;
    AutomatNumber: string;
    ItemNameLength: Integer;
    AgentType: WideString;
  end;

  { TReceipt }

  TReceipt = class
  private
    FItems: TDocItems;
    FParams: TReceiptRec;
    FPayments: TPayments;
    FAgentData: TAgentData;
    FVendorData: TVendorData;
    FUserAttribute: TUserAttribute;
    FCustomerDetail: TCustomerDetail;
    FCorrectionData: TCorrectionData;
    FIndustryAttribute: TIndustryAttribute;
    FOperationalAttribute: TOperationalAttribute;
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TDocItem;
    function TotalTaxSum: Currency;

    property Items: TDocItems read FItems;
    property Params: TReceiptRec read FParams;
    property Payments: TPayments read FPayments;
    property AgentData: TAgentData read FAgentData;
    property VendorData: TVendorData read FVendorData;
    property UserAttribute: TUserAttribute read FUserAttribute;
    property CorrectionData: TCorrectionData read FCorrectionData;
    property CustomerDetail: TCustomerDetail read FCustomerDetail;
    property IndustryAttribute: TIndustryAttribute read FIndustryAttribute;
    property OperationalAttribute: TOperationalAttribute
      read FOperationalAttribute;
  end;

  { TXmlDoc1C }

  TXmlDoc1C = class
  private
    class procedure LoadItems(ANode: IXMLNode; Items: TDocItems);
    class procedure LoadPositions(ANode: IXMLNode; Receipt: TReceipt);
  public
    class procedure Read(const AXML: WideString; Receipt: TReceipt); overload;
    class procedure Read(const AXML: WideString;
      Document: TTextDocument); overload;
    class function Read(const Xml: WideString): TInputParametersRec; overload;
    class procedure Read(const Xml: WideString;
      Params: TParametersKKT); overload;
    class procedure Read(const Xml: WideString;
      Params: TParametersFiscal); overload;
    class procedure Write(var XmlText: WideString;
      Params: TParametersKKT); overload;
    class procedure Write(var XmlText: WideString;
      Params: TParametersFiscal); overload;
    class procedure Write(var XmlText: WideString;
      Params: TInputParametersRec); overload;
    class procedure Write(var XmlText: WideString;
      Params: TOutputParametersRec); overload;
    class procedure Write(var XmlText: WideString;
      const P: TRequestKMResult); overload;

    class procedure Load(ANode: IXMLNode; var R: TAgentData); overload;
    class procedure Load(ANode: IXMLNode; var R: TVendorData); overload;
    class procedure Load(ANode: IXMLNode; var R: TUserAttribute); overload;
    class procedure Load(ANode: IXMLNode; var R: TCorrectionData); overload;
    class procedure Load(ANode: IXMLNode; var R: TCustomerDetail); overload;
    class procedure Load(ANode: IXMLNode;
      var R: TOperationalAttribute); overload;
    class procedure Load(ANode: IXMLNode; var R: TIndustryAttribute); overload;
    class procedure Load(ANode: IXMLNode; var R: TFractionalQuantity); overload;
    class procedure Load(ANode: IXMLNode; var R: TGoodCodeData); overload;
    class procedure Load(ANode: IXMLNode; var R: TPayments); overload;
    class procedure Load(ANode: IXMLNode; var R: TReceiptRec); overload;
    class procedure Load(ANode: IXMLNode; Item: TFiscalItem); overload;
    class procedure Load(ANode: IXMLNode; Item: TTextItem); overload;
    class procedure Load(ANode: IXMLNode; Item: TBarcodeItem); overload;
    class procedure Load(const XmlText: WideString; var R: TRequestKM);
      overload;
  end;

function To1Cbool(AValue: Boolean): WideString;

implementation

function DateTimeToXML(AValue: TDateTime): WideString;
begin
  Result := FormatDateTime('yyyy-mm-dd"T"hh:mm:ss', AValue);
end;

function To1Cbool(AValue: Boolean): WideString;
begin
  if AValue then
    Result := 'true'
  else
    Result := 'false';
end;

function DecodeBase64(const AData: AnsiString): AnsiString;
begin
  Result := Base64DecodeStr(AData);
end;

function QuantityToStr(AValue: Double): string;
var
  SaveSeparator: Char;
begin
  SaveSeparator := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    Result := SysUtils.Format('%.*f', [6, AValue]);
  finally
    FormatSettings.DecimalSeparator := SaveSeparator;
  end;
end;

procedure LoadReceiptFromXml(Receipt: TReceipt; const Xml: WideString);
var
  Reader: TXmlDoc1C;
begin
  Reader := TXmlDoc1C.Create;
  try
    Reader.Read(Xml, Receipt);
  finally
    Reader.Free;
  end;
end;

procedure LoadTextDocumentFromXml(Document: TTextDocument;
  const Xml: WideString);
var
  Reader: TXmlDoc1C;
begin
  Reader := TXmlDoc1C.Create;
  try
    Reader.Read(Xml, Document);
  finally
    Reader.Free;
  end;
end;

{ TGoodCodeData }

function GetItemCodeData(const P: TGoodCodeData): TItemCodeData;
begin
  Result.MarkingType := -1;
  Result.GTIN := '';
  Result.SerialNumber := '';
  Result.Barcode := '';

  if P.EAN8 <> '' then
  begin
    Result.MarkingType := $4508;
    Result.Barcode := P.EAN8;
    Exit;
  end;

  if P.EAN13 <> '' then
  begin
    Result.MarkingType := $450D;
    Result.Barcode := P.EAN13;
    Exit;
  end;

  if P.ITF14 <> '' then
  begin
    Result.MarkingType := $490E;
    Result.Barcode := P.ITF14;
    Exit;
  end;

  if P.GS1_M <> '' then
  begin
    Result.MarkingType := $444D;
    DecodeGS1_full(P.GS1_M, Result.GTIN, Result.SerialNumber);
    AddTrailingSpaces(Result.SerialNumber, 13);
    Exit;
  end;

  if P.MI <> '' then
  begin
    Result.MarkingType := $5246;
    Result.Barcode := P.MI;
    Exit;
  end;

  if P.EGAIS20 <> '' then
  begin
    Result.MarkingType := $C514;
    Result.Barcode := P.EGAIS20;
    Exit;
  end;

  if P.EGAIS30 <> '' then
  begin
    Result.MarkingType := $C51E;
    Result.Barcode := P.EGAIS30;
    Exit;
  end;

  if P.KMK <> '' then
  begin
    Result.MarkingType := 0;
    Result.Barcode := P.KMK;
    Exit;
  end;

  if P.NotIdentified <> '' then
  begin
    Result.MarkingType := 0;
    Result.Barcode := P.NotIdentified;
    Exit;
  end;
end;

{ TPositions1C }

constructor TReceipt.Create;
var
  GUID: TGUID;
begin
  inherited Create;
  FItems := TDocItems.Create(TDocItem);
  CreateGUID(GUID);
  FParams.Id := GUIDToString(GUID);
  FParams.DeliveryRetail := False;
  FParams.FFDVersion := 0;
end;

destructor TReceipt.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TReceipt.Add: TDocItem;
begin
  Result := TDocItem.Create(FItems);
end;

function TReceipt.TotalTaxSum: Currency;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Items.Count - 1 do
  begin
    if Items[i] is TFiscalItem then
      Result := Result + TFiscalItem(Items[i]).FTaxSumm;
  end;
end;

{ TXmlDoc1C }

class procedure TXmlDoc1C.Read(const AXML: WideString; Receipt: TReceipt);
var
  i: Integer;
  Doc: IXMLNode;
  Node: IXMLNode;
  Xml: IXMLDocument;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXML(AXML);
    Doc := Xml.ChildNodes.FindNode('CheckPackage');
    if Doc = nil then
      Exit;

    for i := 0 to Doc.ChildNodes.Count - 1 do
    begin
      Node := Doc.ChildNodes.Nodes[i];
      if Node = nil then
        Continue;

      if Node.NodeName = 'Parameters' then
      begin
        Load(Node, Receipt.FParams);
        Load(Node, Receipt.FAgentData);
        Load(Node, Receipt.FVendorData);
        Load(Node, Receipt.FUserAttribute);
        Load(Node, Receipt.FCustomerDetail);
        Load(Node, Receipt.FCorrectionData);
        Load(Node, Receipt.FIndustryAttribute);
        Load(Node, Receipt.FOperationalAttribute);
        Continue;
      end;
      if Node.NodeName = 'Positions' then
      begin
        LoadPositions(Node, Receipt);
        Continue;
      end;
      if Node.NodeName = 'Payments' then
      begin
        Load(Node, Receipt.FPayments);
        Continue;
      end;
    end;
  finally
    Xml := nil;
  end;
end;

class procedure TXmlDoc1C.Read(const AXML: WideString; Document: TTextDocument);
var
  i: Integer;
  Doc: IXMLNode;
  Node: IXMLNode;
  Xml: IXMLDocument;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXML(AXML);
    Doc := Xml.ChildNodes.FindNode('Document');
    if Doc = nil then
      Exit;

    for i := 0 to Doc.ChildNodes.Count - 1 do
    begin
      Node := Doc.ChildNodes.Nodes[i];
      if Node = nil then
        Continue;

      if Node.NodeName = 'Positions' then
      begin
        LoadItems(Node, Document.Items);
        Continue;
      end;
    end;
  finally
    Xml := nil;
  end;
end;

class procedure TXmlDoc1C.LoadItems(ANode: IXMLNode; Items: TDocItems);
var
  i: Integer;
  Node: IXMLNode;
begin
  for i := 0 to ANode.ChildNodes.Count - 1 do
  begin
    Node := ANode.ChildNodes.Nodes[i];
    if Node = nil then
      Continue;

    if Node.NodeName = 'TextString' then
    begin
      Load(Node, TTextItem.Create(Items));
      Continue;
    end;
    if Node.NodeName = 'Barcode' then
    begin
      Load(Node, TBarcodeItem.Create(Items));
      Continue;
    end;
  end;
end;

(*
  <Parameters PaymentType="1" TaxVariant="0" CashierName="Казакова Н.А."
  SenderEmail="info@1c.ru" CustomerEmail="" CustomerPhone="" AgentSign="2"
  AddressSettle="г.Москва, Дмитровское ш. д.9">
  <AgentData PayingAgentOperation="operation" PayingAgentPhone="tel"
  ReceivePaymentsOperatorPhone="tel" MoneyTransferOperatorPhone="tel"
  MoneyTransferOperatorName="name" MoneyTransferOperatorAddress="addr"/>
  <PurveyorData PurveyorPhone="12343332" PurveyorName="123fffff" PurveyorVATIN="123456789"/>
  </Parameters>
*)

class procedure TXmlDoc1C.Load(ANode: IXMLNode; var R: TReceiptRec);
begin
  R.CashierName := LoadString(ANode, 'CashierName', False);
  R.CashierINN := LoadString(ANode, 'CashierINN', False);
  R.OperationType := LoadInteger(ANode, 'OperationType', True);
  R.TaxationSystem := LoadInteger(ANode, 'TaxationSystem', True);
  R.CustomerInfo := LoadString(ANode, 'CustomerInfo', False);
  R.CustomerINN := LoadString(ANode, 'CustomerINN', False);
  R.CustomerEmail := LoadString(ANode, 'CustomerEmail', False);
  R.CustomerPhone := LoadString(ANode, 'CustomerPhone', False);
  R.SenderEmail := LoadString(ANode, 'SenderEmail', False);
  R.SaleAddress := LoadString(ANode, 'SaleAddress', False);
  R.SaleLocation := LoadString(ANode, 'SaleLocation', False);
  R.AgentType := LoadString(ANode, 'AgentType', False);
  R.AdditionalAttribute := LoadString(ANode, 'AdditionalAttribute', False);
  R.AutomatNumber := LoadString(ANode, 'AutomatNumber', False);
end;

class procedure TXmlDoc1C.LoadPositions(ANode: IXMLNode; Receipt: TReceipt);
var
  i: Integer;
  Node: IXMLNode;
  FiscalItem: TFiscalItem;
begin
  for i := 0 to ANode.ChildNodes.Count - 1 do
  begin
    Node := ANode.ChildNodes.Nodes[i];
    if Node = nil then
      Continue;

    if Node.NodeName = 'FiscalString' then
    begin
      FiscalItem := TFiscalItem.Create(Receipt.Items);
      Load(Node, FiscalItem);
      // !!!
      if Receipt.Params.ItemNameLength > 0 then
        FiscalItem.FName := Copy(FiscalItem.FName, 1,
          Receipt.Params.ItemNameLength);

      Continue;
    end;
    if Node.NodeName = 'TextString' then
    begin
      Load(Node, TTextItem.Create(Receipt.Items));
      Continue;
    end;
    if Node.NodeName = 'Barcode' then
    begin
      Load(Node, TBarcodeItem.Create(Receipt.Items));
      Continue;
    end;
  end;
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; Item: TBarcodeItem);
begin
  Item.FBarcodeType := LoadString(ANode, 'Type', True);
  if HasAttribute(ANode, 'Value') then
    Item.FBarcode := LoadString(ANode, 'Value', True);
  if HasAttribute(ANode, 'ValueBase64') then
    Item.FBarcode := DecodeBase64(LoadString(ANode, 'ValueBase64', True));
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; Item: TTextItem);
begin
  Item.FText := LoadString(ANode, 'Text', True);
end;

function TaxToInt(const ATax: WideString): Integer;
begin
  if (ATax = '18') or (ATax = '20') then
    Result := 1
  else if ATax = '10' then
    Result := 2
  else if ATax = '0' then
    Result := 3
  else if ATax = 'none' then
    Result := 4
  else if (ATax = '18/118') or (ATax = '20/120') then
    Result := 5
  else if ATax = '10/110' then
    Result := 6
  else
    raise Exception.Create('Invalid Tax Value: ' + ATax);
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; Item: TFiscalItem);
var
  T: WideString;
  Node: IXMLNode;
begin
  Item.FName := LoadString(ANode, 'Name', True);
  Item.FQuantity := LoadDouble(ANode, 'Quantity', True);
  Item.FPriceWithDiscount := LoadDouble(ANode, 'PriceWithDiscount', True);
  Item.FSumWithDiscount := LoadDouble(ANode, 'AmountWithDiscount', True);
  if ANode.Attributes['DiscountAmount'] = '' then
    Item.FDiscountSum := 0
  else
    Item.FDiscountSum := LoadDouble(ANode, 'DiscountAmount', True);

  Item.FSignMethodCalculation := LoadIntegerDef(ANode, 'PaymentMethod',
    False, 4);
  Item.FSignCalculationObject := LoadIntegerDef(ANode, 'CalculationSubject',
    False, 1);
  T := LoadString(ANode, 'VATRate', True);
  Item.FTax := TaxToInt(T);
  Item.FTaxSumm := LoadDouble(ANode, 'VATAmount', False);
  Item.FDepartment := LoadIntegerDef(ANode, 'Department', False, 0);
  Item.AgentSign := LoadString(ANode, 'CalculationAgent', False);
  Item.ExciseAmount := LoadDouble(ANode, 'ExciseAmount', False);
  Item.FCountryOfOfigin := LoadString(ANode, 'CountryOfOrigin', False);
  Item.FCustomsDeclaration := LoadString(ANode, 'CustomsDeclaration', False);
  Item.FAdditionalAttribute := LoadString(ANode, 'AdditionalAttribute', False);
  Item.FMeasurementUnit := LoadString(ANode, 'MeasurementUnit', False);
  Load(ANode, Item.FIndustryAttribute);
  Item.FMeasureOfQuantity := LoadInteger(ANode, 'MeasureOfQuantity', False);
  Load(ANode, Item.FFractionalQuantity);
  Load(ANode, Item.FGoodCodeData);
  Item.FMarkingCode := DecodeBase64(LoadString(ANode, 'MarkingCode', False));
  Load(ANode, Item.FIndustryAttribute);

  // Код маркировки
  Item.FMarking := '';
  Item.FMarkingRaw := '';
  Node := ANode.ChildNodes.FindNode('GoodCodeData');
  if Node <> nil then
  begin
    Item.FMarking := DecodeBase64(LoadString(Node, 'MarkingCode', False));
    Item.FMarkingRaw := LoadString(Node, 'MarkingCode', False);
  end;
  // Данные агента
  Item.FAgentData.Enabled := False;
  Node := ANode.ChildNodes.FindNode('AgentData');
  if Node <> nil then
  begin
    if Node.AttributeNodes.Count > 0 then
    begin
      Item.FAgentData.Enabled := True;
      Item.FAgentData.AgentOperation :=
        LoadString(Node, 'AgentOperation', False);
      Item.FAgentData.AgentPhone := LoadString(Node, 'AgentPhone', False);
      Item.FAgentData.PaymentProcessorPhone :=
        LoadString(Node, 'PaymentProcessorPhone', False);
      Item.FAgentData.AcquirerOperatorPhone :=
        LoadString(Node, 'AcquirerOperatorPhone', False);
      Item.FAgentData.AcquirerOperatorName :=
        LoadString(Node, 'AcquirerOperatorName', False);
      Item.FAgentData.AcquirerOperatorAddress :=
        LoadString(Node, 'AcquirerOperatorAddress', False);
      Item.FAgentData.AcquirerOperatorINN :=
        LoadString(Node, 'AcquirerOperatorINN', False);

      if (Item.FAgentData.AgentOperation = '') and
        (Item.FAgentData.AgentPhone = '') and
        (Item.FAgentData.PaymentProcessorPhone = '') and
        (Item.FAgentData.AcquirerOperatorPhone = '') and
        (Item.FAgentData.AcquirerOperatorName = '') and
        (Item.FAgentData.AcquirerOperatorAddress = '') and
        (Item.FAgentData.AcquirerOperatorINN = '') then
        Item.FAgentData.Enabled := False;
    end;
  end;
  // Данные поставщика
  Item.FVendorData.Enabled := False;
  Node := ANode.ChildNodes.FindNode('VendorData');
  if Node <> nil then
  begin
    if Node.AttributeNodes.Count > 0 then
    begin
      Item.FVendorData.Enabled := True;
      Item.FVendorData.VendorPhone := LoadString(Node, 'VendorPhone', False);
      Item.FVendorData.VendorName := LoadString(Node, 'VendorName', False);
      Item.FVendorData.VendorINN := LoadString(Node, 'VendorINN', False);
      if (Item.FVendorData.VendorPhone = '') and
        (Item.FVendorData.VendorName = '') and (Item.FVendorData.VendorINN = '')
      then
        Item.FVendorData.Enabled := False;
    end;
  end;
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; var R: TCorrectionData);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('CorrectionData');
  if Node = nil then
    Exit;

  R.Enabled := True;
  R.AType := LoadInteger(Node, 'Type', False);
  R.Description := LoadString(Node, 'Description', False);
  R.Date := LoadDateTime(Node, 'Date', False);
  R.Number := LoadString(Node, 'Number', False);
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; var R: TAgentData);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('AgentData');
  if Node = nil then
    Exit;

  R.Enabled := True;
  R.AgentOperation := LoadString(Node, 'AgentOperation', False);
  R.AgentPhone := LoadString(Node, 'AgentPhone', False);
  R.PaymentProcessorPhone := LoadString(Node, 'PaymentProcessorPhone', False);
  R.AcquirerOperatorPhone := LoadString(Node, 'AcquirerOperatorPhone', False);
  R.AcquirerOperatorName := LoadString(Node, 'AcquirerOperatorName', False);
  R.AcquirerOperatorAddress :=
    LoadString(Node, 'AcquirerOperatorAddress', False);
  R.AcquirerOperatorINN := LoadString(Node, 'AcquirerOperatorINN', False);
  if (R.AgentOperation = '') and (R.AgentPhone = '') and
    (R.PaymentProcessorPhone = '') and (R.AcquirerOperatorPhone = '') and
    (R.AcquirerOperatorName = '') and (R.AcquirerOperatorAddress = '') and
    (R.AcquirerOperatorINN = '') then
    R.Enabled := False;
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; var R: TVendorData);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('VendorData');
  if Node = nil then
    Exit;

  R.Enabled := True;
  R.VendorPhone := LoadString(Node, 'VendorPhone', False);
  R.VendorName := LoadString(Node, 'VendorName', False);
  R.VendorINN := LoadString(Node, 'VendorINN', False);
  if (R.VendorPhone = '') and (R.VendorName = '') and (R.VendorINN = '') then
    R.Enabled := False;
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; var R: TUserAttribute);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('UserAttribute');
  if Node = nil then
    Exit;

  R.Enabled := True;
  R.Name := LoadString(Node, 'Name', True);
  R.Value := LoadString(Node, 'Value', True);
  if (R.Name = '') and (R.Value = '') then
    R.Enabled := False;
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; var R: TCustomerDetail);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('CustomerDetail');
  if Node = nil then
    Exit;

  R.Enabled := HasAttribute(Node, 'Info') or HasAttribute(Node, 'INN') or
    HasAttribute(Node, 'DateOfBirth') or HasAttribute(Node, 'Citizenship') or
    HasAttribute(Node, 'DocumentTypeCode') or HasAttribute(Node, 'DocumentData')
    or HasAttribute(Node, 'Address');
  if not R.Enabled then
    Exit;

  R.Info := LoadString(Node, 'Info', False);
  R.INN := LoadString(Node, 'INN', False);
  R.DateOfBirthEnabled := HasAttribute(Node, 'DateOfBirth');
  if R.DateOfBirthEnabled then
    R.DateOfBirth := LoadDateTime(Node, 'DateOfBirth', False);
  R.Citizenship := LoadString(Node, 'Citizenship', False);
  R.DocumentTypeCodeEnabled := HasAttribute(Node, 'DocumentTypeCode');
  if R.DocumentTypeCodeEnabled then
    R.DocumentTypeCode := LoadInteger(Node, 'DocumentTypeCode', False);
  R.DocumentData := LoadString(Node, 'DocumentData', False);
  R.Address := LoadString(Node, 'Address', False);
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; var R: TOperationalAttribute);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('OperationalAttribute');
  if Node = nil then
    Exit;

  R.Enabled := HasAttribute(Node, 'DateTime') or
    HasAttribute(Node, 'OperationID') or HasAttribute(Node, 'OperationData');
  if not R.Enabled then
    Exit;

  R.DateTime := LoadDateTime(Node, 'DateTime', False);
  R.OperationID := LoadInteger(Node, 'OperationID', False);
  R.OperationData := LoadString(Node, 'OperationData', False);
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; var R: TIndustryAttribute);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('IndustryAttribute');
  if Node = nil then
    Exit;

  R.Enabled := HasAttribute(Node, 'IdentifierFOIV') or
    HasAttribute(Node, 'DocumentDate') or HasAttribute(Node, 'DocumentNumber')
    or HasAttribute(Node, 'AttributeValue');

  if not R.Enabled then
    Exit;

  R.IdentifierFOIV := LoadString(Node, 'IdentifierFOIV', False);
  R.DocumentDate := LoadDateTime(Node, 'DocumentDate', False);
  R.DocumentNumber := LoadString(Node, 'DocumentNumber', False);
  R.AttributeValue := LoadString(Node, 'AttributeValue', False);
  if (R.IdentifierFOIV = '') and (R.DocumentNumber = '') and
    (R.AttributeValue = '') then
    R.Enabled := False;
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; var R: TFractionalQuantity);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('FractionalQuantity');
  if Node = nil then
    Exit;

  R.Enabled := True;
  R.Numerator := LoadInteger(Node, 'Numerator', False);
  R.Denominator := LoadInteger(Node, 'Denominator', False);
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; var R: TGoodCodeData);
var
  Node: IXMLNode;
begin
  R.Enabled := False;
  Node := ANode.ChildNodes.FindNode('GoodCodeData');
  if Node = nil then
    Exit;

  R.Enabled := True;
  R.NotIdentified := DecodeBase64(LoadString(Node, 'NotIdentified', False));
  R.EAN8 := DecodeBase64(LoadString(Node, 'EAN8', False));
  R.EAN13 := DecodeBase64(LoadString(Node, 'EAN13', False));
  R.ITF14 := DecodeBase64(LoadString(Node, 'ITF14', False));
  R.GS1_0 := DecodeBase64(LoadString(Node, 'GS1.0', False));
  R.GS1_M := DecodeBase64(LoadString(Node, 'GS1.M', False));
  R.KMK := DecodeBase64(LoadString(Node, 'KMK', False));
  R.MI := LoadString(Node, 'MI', False);
  R.EGAIS20 := DecodeBase64(LoadString(Node, 'EGAIS20', False));
  R.EGAIS30 := DecodeBase64(LoadString(Node, 'EGAIS30', False));
  R.F1 := DecodeBase64(LoadString(Node, 'F1', False));
  R.F2 := DecodeBase64(LoadString(Node, 'F2', False));
  R.F3 := DecodeBase64(LoadString(Node, 'F3', False));
  R.F4 := DecodeBase64(LoadString(Node, 'F4', False));
  R.F5 := DecodeBase64(LoadString(Node, 'F5', False));
  R.F6 := DecodeBase64(LoadString(Node, 'F6', False));
  R.GTIN := DecodeBase64(LoadString(Node, 'GTIN', False));
end;

class procedure TXmlDoc1C.Load(const XmlText: WideString; var R: TRequestKM);
var
  Node: IXMLNode;
  Xml: IXMLDocument;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Xml.LoadFromXML(XmlText);
    Node := Xml.ChildNodes.FindNode('RequestKM');
    if Node = nil then
      raise Exception.Create('Wrong XML RequestKM Table');

    R.GUID := LoadString(Node, 'GUID', False);
    R.WaitForResult := LoadBool(Node, 'WaitForResult', False);
    R.MarkingCode := DecodeBase64(LoadString(Node, 'MarkingCode', True));
    R.PlannedStatus := LoadInteger(Node, 'PlannedStatus', True);
    R.HasQuantity := HasAttribute(Node, 'Quantity');
    R.Quantity := LoadDouble(Node, 'Quantity', False);
    R.HasMeasureOfQuantity := HasAttribute(Node, 'MeasureOfQuantity');
    R.MeasureOfQuantity := LoadInteger(Node, 'MeasureOfQuantity', False);
    R.NotSendToServer := LoadBool(Node, 'NotSendToServer', False);
    R.HasFractionalQuantity := False;
    Node := Node.ChildNodes.FindNode('FractionalQuantity');
    if Node <> nil then
    begin
      R.HasFractionalQuantity := True;
      R.Numerator := LoadInteger(Node, 'Numerator', False);
      R.Denominator := LoadInteger(Node, 'Denominator', False);
    end;
  finally
    Xml := nil;
  end;
end;

class procedure TXmlDoc1C.Load(ANode: IXMLNode; var R: TPayments);
begin
  R.Cash := LoadDecimal(ANode, 'Cash', False);
  R.ElectronicPayment := LoadDecimal(ANode, 'ElectronicPayment', True);
  R.PrePayment := LoadDecimal(ANode, 'PrePayment', True);
  R.PostPayment := LoadDecimal(ANode, 'PostPayment', True);
  R.Barter := LoadDecimal(ANode, 'Barter', True);
end;

(*

  function RequestKMToXML(const AGUID: string; const AWaitForResult: Boolean; const AMarkingCode: AnsiString; const APlannedStatus: Integer; const AQuantity: Double; const AMeasureOfQuantity: string; const AFractionalQuantity: Boolean; const ANumerator: Integer; const ADenominator: Integer): string;
  var
  Xml: IXMLDocument;
  Node: IXMLNode;
  begin
  Xml := TXMLDocument.Create(nil);
  try
  Xml.Active := True;
  Xml.Version := '1.0';
  Xml.Encoding := 'UTF-8';
  Xml.Options := Xml.Options + [doNodeAutoIndent];
  Node := Xml.AddChild('Parameters');

  Node.Attributes['GUID'] := AGUID;
  Node.Attributes['WaitForResult'] := To1Cbool(AWaitForResult);
  Node.Attributes['MarkingCode'] := AMarkingCode;
  Node.Attributes['PlannedStatus'] := APlannedStatus.ToString;
  Node.Attributes['Quantity'] := QuantityToStr(AQuantity);
  if AMeasureOfQuantity <> '' then
  Node.Attributes['MeasureOfQuantity'] := AMeasureOfQuantity;
  if AFractionalQuantity then
  begin
  Node := Node.AddChild('FractionalQuantity');
  Node.Attributes['Numerator'] := ANumerator.ToString;
  Node.Attributes['Denominator'] := ADenominator.ToString;
  end;
  Result := Xml.XML.Text;
  finally
  Xml := nil;
  end;
  end;

  function ProcessingKMResultToXML(const AGUID: string; const AResult: Boolean; const AResultCode: Integer; const AHasStatusInfo: Boolean; const AStatusInfo: Integer; const AHandleCode: Integer): string;
  var
  Xml: IXMLDocument;
  Node: IXMLNode;
  begin
  Xml := TXMLDocument.Create(nil);
  try
  Xml.Active := True;
  Xml.Version := '1.0';
  Xml.Encoding := 'UTF-8';
  Xml.Options := Xml.Options + [doNodeAutoIndent];
  Node := Xml.AddChild('ProcessingKMResult');
  Node.Attributes['GUID'] := AGUID;
  Node.Attributes['Result'] := To1Cbool(AResult);
  Node.Attributes['ResultCode'] := AResultCode.ToString;
  if AHasStatusInfo then
  Node.Attributes['StatusInfo'] := AStatusInfo.ToString;
  Node.Attributes['HandleCode'] := AHandleCode.ToString;
  Result := Xml.XML.Text;
  finally
  Xml := nil;
  end;
  end;

  { TRequestKM }

*)

{ TTextDocument }

constructor TTextDocument.Create;
begin
  FItems := TDocItems.Create(TDocItem);
end;

destructor TTextDocument.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

{ TDocItems }

function TDocItems.GetItem(Index: Integer): TDocItem;
begin
  Result := inherited Items[Index] as TDocItem;
end;

{ TXmlDoc1C }

class function TXmlDoc1C.Read(const Xml: WideString): TInputParametersRec;
var
  Node: IXMLNode;
  XMLDoc: IXMLDocument;
begin
  XMLDoc := TXMLDocument.Create(nil);
  try
    XMLDoc.Active := True;
    XMLDoc.Version := '1.0';
    XMLDoc.Encoding := 'UTF-8';
    XMLDoc.Options := XMLDoc.Options + [doNodeAutoIndent];
    XMLDoc.LoadFromXML(Xml);
    Node := XMLDoc.ChildNodes.FindNode('InputParameters');
    if Node = nil then
      raise Exception.Create('Wrong XML input parameters Table');

    Node := Node.ChildNodes.FindNode('Parameters');
    if Node = nil then
      raise Exception.Create('Wrong XML input parameters Table');

    Result.CashierName := LoadString(Node, 'CashierName', True);
    Result.CashierINN := LoadString(Node, 'CashierINN', False);
    Result.SaleAddress := LoadString(Node, 'SaleAddress', False);
    Result.SaleLocation := LoadString(Node, 'SaleLocation', False);
    Result.PrintRequired := LoadBool(Node, 'PrintRequired', False);
  finally
    XMLDoc := nil;
  end;
end;

class procedure TXmlDoc1C.Write(var XmlText: WideString;
  Params: TInputParametersRec);
var
  Node: IXMLNode;
  XMLDoc: IXMLDocument;
begin
  XMLDoc := TXMLDocument.Create(nil);
  try
    XMLDoc.Active := True;
    XMLDoc.Version := '1.0';
    XMLDoc.Encoding := 'UTF-8';
    XMLDoc.Options := XMLDoc.Options + [doNodeAutoIndent];
    Node := XMLDoc.AddChild('InputParameters');
    XMLDoc.DocumentElement := Node;
    Node := Node.AddChild('Parameters');
    Node.Attributes['CashierName'] := Params.CashierName;
    Node.Attributes['CashierINN'] := Params.CashierINN;
    Node.Attributes['SaleAddress'] := Params.SaleAddress;
    Node.Attributes['SaleLocation'] := Params.SaleLocation;
    Node.Attributes['PrintRequired'] := Params.PrintRequired;
    XMLDoc.SaveToXML(XmlText);
  finally
    XMLDoc := nil;
  end;
end;

class procedure TXmlDoc1C.Read(const Xml: WideString;
  Params: TParametersFiscal);
var
  Node: IXMLNode;
  XMLDoc: IXMLDocument;
begin
  XMLDoc := TXMLDocument.Create(nil);
  try
    XMLDoc.Active := True;
    XMLDoc.Version := '1.0';
    XMLDoc.Encoding := 'UTF-8';
    XMLDoc.Options := XMLDoc.Options + [doNodeAutoIndent];
    XMLDoc.LoadFromXML(Xml);
    Node := XMLDoc.ChildNodes.FindNode('ParametersFiscal');
    if Node = nil then
      raise Exception.Create('Wrong XML parameters Table');

    Params.KKTNumber := LoadString(Node, 'KKTNumber', False);
    Params.KKTSerialNumber := LoadString(Node, 'KKTSerialNumber', False);
    Params.FirmwareVersion := LoadString(Node, 'FirmwareVersion', False);
    Params.Fiscal := LoadBool(Node, 'Fiscal', False);
    Params.FFDVersionFN := LoadString(Node, 'FFDVersionFN', False);
    Params.FFDVersionKKT := LoadString(Node, 'FFDVersionKKT', False);
    Params.FNSerialNumber := LoadString(Node, 'FNSerialNumber', False);
    Params.DocumentNumber := LoadString(Node, 'DocumentNumber', False);
    Params.DateTime := LoadDateTime(Node, 'DateTime', False);
    Params.CompanyName := LoadString(Node, 'CompanyName', False);
    Params.CompanyINN := LoadString(Node, 'INN', False);
    Params.SaleAddress := LoadString(Node, 'SaleAddress', False);
    Params.SaleLocation := LoadString(Node, 'SaleLocation', False);
    Params.TaxSystems := LoadString(Node, 'TaxationSystems', False);
    Params.IsOffline := LoadBool(Node, 'IsOffline', False);
    Params.IsEncrypted := LoadBool(Node, 'IsEncrypted', False);
    Params.IsService := LoadBool(Node, 'IsService', False);
    Params.IsExcisable := LoadBool(Node, 'IsExcisable', False);
    Params.IsGambling := LoadBool(Node, 'IsGambling', False);
    Params.IsLottery := LoadBool(Node, 'IsLottery', False);
    Params.AgentTypes := LoadString(Node, 'AgentTypes', False);
    Params.IsBlank := LoadBool(Node, 'BSOSing', False);
    Params.IsAutomaticPrinter := LoadBool(Node, 'IsAutomaticPrinter', False);
    Params.IsAutomatic := LoadBool(Node, 'IsAutomatic', False);
    Params.AutomaticNumber := LoadString(Node, 'AutomaticNumber', False);
    Params.OFDCompany := LoadString(Node, 'OFDCompany', False);
    Params.OFDCompanyINN := LoadString(Node, 'OFDCompanyINN', False);
    Params.FNSURL := LoadString(Node, 'FNSURL', False);
    Params.SenderEmail := LoadString(Node, 'SenderEmail', False);

    Params.CashierName := LoadString(Node, 'CashierName', False);
    Params.CashierINN := LoadString(Node, 'CashierINN', False);
    Params.FFDVersion := LoadString(Node, 'FFDVersion', False);
    Params.RegistrationLabelCodes :=
      LoadString(Node, 'RegistrationLabelCodes', False);
  finally
    XMLDoc := nil;
  end;
end;

class procedure TXmlDoc1C.Read(const Xml: WideString; Params: TParametersKKT);
var
  Node: IXMLNode;
  XMLDoc: IXMLDocument;
begin
  XMLDoc := TXMLDocument.Create(nil);
  try
    XMLDoc.Active := True;
    XMLDoc.Version := '1.0';
    XMLDoc.Encoding := 'UTF-8';
    XMLDoc.Options := XMLDoc.Options + [doNodeAutoIndent];
    XMLDoc.LoadFromXML(Xml);
    Node := XMLDoc.ChildNodes.FindNode('Parameters');
    if Node = nil then
      raise Exception.Create('Wrong XML parameters Table');

    Params.KKTNumber := LoadString(Node, 'KKTNumber', False);
    Params.KKTSerialNumber := LoadString(Node, 'KKTSerialNumber', False);
    Params.FirmwareVersion := LoadString(Node, 'FirmwareVersion', False);
    Params.Fiscal := LoadBool(Node, 'Fiscal', False);
    Params.FFDVersionFN := LoadString(Node, 'FFDVersionFN', False);
    Params.FFDVersionKKT := LoadString(Node, 'FFDVersionKKT', False);
    Params.FNSerialNumber := LoadString(Node, 'FNSerialNumber', False);
    Params.DocumentNumber := LoadString(Node, 'DocumentNumber', False);
    Params.DateTime := LoadDateTime(Node, 'DateTime', False);
    Params.CompanyName := LoadString(Node, 'CompanyName', False);
    Params.CompanyINN := LoadString(Node, 'INN', False);
    Params.SaleAddress := LoadString(Node, 'SaleAddress', False);
    Params.SaleLocation := LoadString(Node, 'SaleLocation', False);
    Params.TaxSystems := LoadString(Node, 'TaxationSystems', False);
    Params.IsOffline := LoadBool(Node, 'IsOffline', False);
    Params.IsEncrypted := LoadBool(Node, 'IsEncrypted', False);
    Params.IsService := LoadBool(Node, 'IsService', False);
    Params.IsExcisable := LoadBool(Node, 'IsExcisable', False);
    Params.IsGambling := LoadBool(Node, 'IsGambling', False);
    Params.IsLottery := LoadBool(Node, 'IsLottery', False);
    Params.AgentTypes := LoadString(Node, 'AgentTypes', False);
    Params.IsBlank := LoadBool(Node, 'BSOSing', False);
    Params.IsAutomaticPrinter := LoadBool(Node, 'IsAutomaticPrinter', False);
    Params.IsAutomatic := LoadBool(Node, 'IsAutomatic', False);
    Params.AutomaticNumber := LoadString(Node, 'AutomaticNumber', False);
    Params.OFDCompany := LoadString(Node, 'OFDCompany', False);
    Params.OFDCompanyINN := LoadString(Node, 'OFDCompanyINN', False);
    Params.FNSURL := LoadString(Node, 'FNSURL', False);
    Params.SenderEmail := LoadString(Node, 'SenderEmail', False);
  finally
    XMLDoc := nil;
  end;
end;

class procedure TXmlDoc1C.Write(var XmlText: WideString;
  Params: TParametersFiscal);
begin

end;

class procedure TXmlDoc1C.Write(var XmlText: WideString;
  Params: TParametersKKT);
var
  i: Integer;
  Node: IXMLNode;
  Xml: IXMLDocument;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('Parameters');

    Node.Attributes['KKTNumber'] := Params.KKTNumber;
    Node.Attributes['KKTSerialNumber'] := Params.KKTSerialNumber;
    Node.Attributes['FirmwareVersion'] := Params.FirmwareVersion;
    Node.Attributes['Fiscal'] := To1Cbool(Params.Fiscal);
    Node.Attributes['FFDVersionFN'] := Params.FFDVersionFN;
    Node.Attributes['FFDVersionKKT'] := Params.FFDVersionKKT;
    Node.Attributes['FNSerialNumber'] := Params.FNSerialNumber;
    Node.Attributes['DocumentNumber'] := Params.DocumentNumber;
    Node.Attributes['DateTime'] := DateTimeToXML(Params.DateTime);
    Node.Attributes['CompanyName'] := Params.CompanyName;
    Node.Attributes['INN'] := Params.CompanyINN;
    Node.Attributes['SaleAddress'] := Params.SaleAddress;
    Node.Attributes['SaleLocation'] := Params.SaleLocation;
    Node.Attributes['TaxationSystems'] := Params.TaxSystems;
    Node.Attributes['IsOffline'] := To1Cbool(Params.IsOffline);
    Node.Attributes['IsEncrypted'] := To1Cbool(Params.IsEncrypted);
    Node.Attributes['IsService'] := To1Cbool(Params.IsService);
    Node.Attributes['IsExcisable'] := To1Cbool(Params.IsExcisable);
    Node.Attributes['IsGambling'] := To1Cbool(Params.IsGambling);
    Node.Attributes['IsLottery'] := To1Cbool(Params.IsLottery);
    Node.Attributes['AgentTypes'] := Params.AgentTypes;
    Node.Attributes['BSOSing'] := To1Cbool(Params.IsBlank);
    Node.Attributes['IsOnline'] := To1Cbool(Params.IsOnline);
    Node.Attributes['IsMarking'] := To1Cbool(Params.IsMarking);
    Node.Attributes['IsPawnshop'] := To1Cbool(Params.IsPawnshop);
    Node.Attributes['IsAssurance'] := To1Cbool(Params.IsInsurance);
    Node.Attributes['IsVendingMachine'] := To1Cbool(Params.IsVendingMachine);
    Node.Attributes['IsCateringServices'] := To1Cbool(Params.IsCatering);
    Node.Attributes['IsWholesaleTrade'] := To1Cbool(Params.IsWholesale);
    Node.Attributes['IsAutomaticPrinter'] :=
      To1Cbool(Params.IsAutomaticPrinter);
    Node.Attributes['IsAutomatic'] := To1Cbool(Params.IsAutomatic);
    Node.Attributes['AutomaticNumber'] := Params.AutomaticNumber;
    Node.Attributes['OFDCompany'] := Params.OFDCompany;
    Node.Attributes['OFDCompanyINN'] := Params.OFDCompanyINN;
    Node.Attributes['FNSURL'] := Params.FNSURL;
    Node.Attributes['SenderEmail'] := Params.SenderEmail;
    Xml.SaveToXML(XmlText);
  finally
    Xml := nil;
  end;
end;

class procedure TXmlDoc1C.Write(var XmlText: WideString;
  Params: TOutputParametersRec);
var
  Node: IXMLNode;
  Xml: IXMLDocument;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('OutputParameters').AddChild('Parameters');

    Node.Attributes['ShiftNumber'] := IntToStr(Params.ShiftNumber);
    // Integer; //Номер открытой смены/Номер закрытой смены
    Node.Attributes['CheckNumber'] := IntToStr(Params.CheckNumber);
    // Integer; // Номер последнего фискального документа
    Node.Attributes['ShiftClosingCheckNumber'] :=
      IntToStr(Params.ShiftClosingCheckNumber);
    // Integer; // Номер последнего чека за смену
    Node.Attributes['DateTime'] := DateTimeToXML(Params.DateTime);
    // TDateTime; // Дата и время формирования фискального документа
    Node.Attributes['ShiftState'] := IntToStr(Params.ShiftState);
    // Integer; //	Состояние смены 1 - Закрыта, 2 - Открыта, 3 - Истекла
    { Node.Attributes['CountersOperationType1'] := Params.; // TOperationCountersRec; // OperationCounters	Счетчики операций по типу "приход"
      Node.Attributes['CountersOperationType2'] := Params.; // TOperationCountersRec; // Счетчики операций по типу "возврат прихода"
      Node.Attributes['CountersOperationType3'] := Params.; // TOperationCountersRec; // Счетчики операций по типу "расход"
      Node.Attributes['CountersOperationType4'] := Params.; // TOperationCountersRec; // Счетчики операций по типу "возврат расхода" }
    Node.Attributes['CashBalance'] := Params.CashBalance;
    // Double; // Остаток наличных денежных средств в кассе
    Node.Attributes['BacklogDocumentsCounter'] :=
      IntToStr(Params.BacklogDocumentsCounter);
    // Integer; // Количество непереданных документов
    Node.Attributes['BacklogDocumentFirstNumber'] :=
      Params.BacklogDocumentFirstNumber;
    // Integer; // Номер первого непереданного документа
    Node.Attributes['BacklogDocumentFirstDateTime'] :=
      DateTimeToXML(Params.BacklogDocumentFirstDateTime);
    // TDateTime; // Дата и время первого из непереданных документов
    Node.Attributes['FNError'] := To1Cbool(Params.FNError);
    // Boolean; // Признак необходимости срочной замены ФН
    Node.Attributes['FNOverflow'] := To1Cbool(Params.FNOverflow);
    // Boolean; // Признак переполнения памяти ФН
    Node.Attributes['FNFail'] := To1Cbool(Params.FNFail);
    // Boolean; // Признак исчерпания ресурса ФН
    Node.Attributes['FNValidityDate'] := DateTimeToXML(Params.FNValidityDate);
    // TDateTime;
    Xml.SaveToXML(XmlText);
  finally
    Xml := nil;
  end;
end;

class procedure TXmlDoc1C.Write(var XmlText: WideString;
  const P: TRequestKMResult);
var
  Xml: IXMLDocument;
  Node: IXMLNode;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.Version := '1.0';
    Xml.Encoding := 'UTF-8';
    Xml.Options := Xml.Options + [doNodeAutoIndent];
    Node := Xml.AddChild('RequestKMResult');
    Node.Attributes['Checking'] := To1Cbool(P.Checking);
    Node.Attributes['CheckingResult'] := To1Cbool(P.CheckingResult);
    Xml.SaveToXML(XmlText);
  finally
    Xml := nil;
  end;
end;

end.
