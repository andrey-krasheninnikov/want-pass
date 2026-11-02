# Want Pass

Personal and developer secrets, their organization and permitted use.
Личные секреты и секреты разработчика, их организация и разрешённое использование.

## Language / Термины

**Vault / Сейф**:
A personal collection of secrets and their associated organization and history.

Личная коллекция секретов вместе с их организацией и историей.

_Avoid / Не смешивать_: sync account / аккаунт синхронизации

**Secret card / Карточка секрета**:
One named set of credentials or protected information of a chosen type.

Один именованный набор credentials или защищённой информации выбранного типа.

_Avoid / Не смешивать_: service account collection / коллекция аккаунтов сервиса

**Account card / Карточка учётной записи**:
A secret card for one account, including its login, password and optional OTP or recovery information.

Карточка одного аккаунта с логином, паролем и необязательными OTP или резервными данными.

_Avoid / Не смешивать_: service / сервис

**Secret field / Поле секрета**:
A named value within a card with an explicit kind and purpose.

Именованное значение карточки с явными видом и назначением.

_Avoid / Не смешивать_: card / карточка

**Secret type / Тип секрета**:
A template describing the fields appropriate for a kind of secret card.

Шаблон полей, подходящих определённому виду карточек секрета.

_Avoid / Не смешивать_: service / сервис

**Template version / Версия шаблона**:
A particular agreed structure of a secret type, retained for cards that use it.

Определённая структура типа секрета, сохраняемая для использующих её карточек.

_Avoid / Не смешивать_: card revision / версия карточки

**Service / Сервис**:
The named product, provider or user-defined service associated with a secret.

Именованный продукт, провайдер или собственный сервис, связанный с секретом.

_Avoid / Не смешивать_: target resource / ресурс назначения

**Group / Группа**:
A named collection used to organize cards by company, project or purpose; a card may belong to several groups.

Именованная подборка карточек по компании, проекту или назначению; карточка может входить в несколько групп.

_Avoid / Не смешивать_: security boundary / граница защиты

**Environment / Окружение**:
The optional operating context of a secret, such as development or production.

Необязательный контекст использования секрета, например development или production.

_Avoid / Не смешивать_: group / группа

**Target resource / Ресурс назначения**:
The application, endpoint, host or other destination where credentials are intended to be used.

Приложение, endpoint, хост или другое назначение использования credentials.

_Avoid / Не смешивать_: authentication method / метод аутентификации

**Credential binding / Привязка credentials**:
An explicit association between a card, a target resource and the fields intended for an integration.

Явная связь карточки, ресурса назначения и полей для интеграции.

_Avoid / Не смешивать_: permission / разрешение

**Integration profile / Профиль интеграции**:
A user-selected configuration for connecting an external tool to permitted credentials and targets.

Выбранная пользователем настройка подключения внешнего инструмента к разрешённым credentials и назначениям.

_Avoid / Не смешивать_: secret type / тип секрета

**Secret revision / Версия секрета**:
A retained prior state of a card that the user can inspect or restore.

Сохранённое предыдущее состояние карточки, доступное для просмотра или восстановления.

_Avoid / Не смешивать_: template version / версия шаблона

**Recovery kit / Набор восстановления**:
User-held recovery material that restores access when ordinary unlock methods are lost.

Сохраняемые пользователем данные восстановления при потере обычных способов разблокировки.

_Avoid / Не смешивать_: service recovery codes / recovery-коды сервиса

**Operation confirmation / Подтверждение операции**:
An additional user check required by a chosen policy before a sensitive action.

Дополнительная проверка пользователя перед чувствительным действием согласно выбранной политике.

_Avoid / Не смешивать_: vault encryption / шифрование сейфа

**Trusted device / Доверенное устройство**:
An enrolled device permitted to participate in access to the synchronized vault.

Подключённое устройство, участвующее в доступе к синхронизированному сейфу.

_Avoid / Не смешивать_: signed-in session / сетевая сессия

**Sync account / Аккаунт синхронизации**:
An optional identity used with a hosted or self-hosted synchronization service.

Необязательная идентичность для общего или собственного сервиса синхронизации.

_Avoid / Не смешивать_: vault / сейф

**Transfer copy / Передаваемая копия**:
An independent copy of selected current secret fields delivered to another recipient.

Независимая копия выбранных текущих полей секрета, переданная другому получателю.

_Avoid / Не смешивать_: shared live secret / общий обновляемый секрет

**Passkey provider / Провайдер passkeys**:
The component that creates, holds and uses passkeys for relying parties through supported platform interfaces.

Компонент, создающий, хранящий и использующий passkeys для relying parties через поддержанные интерфейсы платформы.

_Avoid / Не смешивать_: external unlock passkey / внешний passkey разблокировки
