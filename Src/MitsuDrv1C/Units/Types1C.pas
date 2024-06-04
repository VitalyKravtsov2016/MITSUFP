unit Types1C;

interface

resourcestring
  SInvalidParam = 'Некорректное значение параметра';
  SErrorParameterRead = 'Не удается прочитать параметр из массива значений';
  SReceiptClosedOperationInvalid = 'Чек закрыт - операция невозможна';
  SReceiptOpenedOperationInvalid = 'Чек открыт - операция невозможна';
  SLockedInvalidTaxPassword = 'Принтер заблокирован после ввода неправильного '
    + 'пароля налогового инспектора';
  STechnologicalResetMode =
    'Принтер находится в режиме технологического обнуления';

  SDeviceNotActive = 'Устройство с таким ИДУстройства не подключено';
  SNoPaper = 'Нет бумаги';
  STaxEnabledReading = 'Чтение настройки "Начисление налогов"';
  SField = 'Поле';
  SValue = 'значение';

  SWriteTaxEnabled = 'Запись настройки "Начисление налогов" = 0;  Поле %d';
  SInvalidUserPassword = 'Неверный пароль пользователя';
  SInvalidAdminPassword = 'Неверный пароль администратора';
  SInvalidPropValue = 'Некорректное значение в свойстве "%s"';
  SInvalidTaxRate = 'Неверная налоговая ставка';
  SParamsReadError = 'Ошибка чтения параметров';
  SParamsWriteError = 'Ошибка записи параметров';
  SReceiptCancelled = 'Чек аннулирован';
  SDeviceName1C = 'Устройство 1С';
  SValuesArrayWriteError = 'Не удалось записать в "МассивЗначений" значение';
  SInvalidLogoHeight = 'Недопустимое значение размера логотипа';
  SInvalidLogoNotSupported =
    'Печать логотипа не поддерживается данной моделью оборудования';
  SNonfiscalDocumentName = 'Нефискальный документ';
  SInvalidOperationInNonfiscalDocument =
    'Открыт нефискальный чек - операция невозможна';
  SInvalidDiscountAmount = 'Величина скидки превышает сумму регистрации';
  SPrintInProgress = 'Печать предыдущего документа не завершена';
  SLogoLoadSuccessful = 'Загрузка выполнена успешно';

implementation

end.
