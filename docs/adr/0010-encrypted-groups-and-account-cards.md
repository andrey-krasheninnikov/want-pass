---
status: accepted
---

# Encrypted groups and account cards / Зашифрованные группы и карточки

## Document boundary / Граница документа

Issue #4 adds groups and, by agreement, minimal account cards. Services and environments remain in #5; revision history remains in #11. Groups organize cards and do not introduce separate encryption keys or access roles. An account may have zero or several group memberships.

Задача #4 добавляет группы и согласованные минимальные карточки учётных записей. Сервисы и окружения остаются в #5, история версий — в #11. Группы организуют карточки и не создают отдельные ключи шифрования или роли доступа. Карточка может не иметь групп или входить в несколько групп.

The outer V2 container and its encrypted payload prefix remain unchanged. Document bytes now contain UTF-8 JSON with schema `1`, a monotonically increasing revision, groups and accounts. IDs are independent random 128-bit values encoded as 32 lowercase hexadecimal characters. Names are not identities; duplicate names are allowed. Memberships are sets of existing group IDs.

Внешний контейнер V2 и префикс его зашифрованного payload не меняются. Байты документа содержат UTF-8 JSON со schema `1`, возрастающим revision, группами и карточками. ID являются независимыми случайными значениями 128 бит в виде 32 строчных шестнадцатеричных символов. Названия не задают идентичность; одинаковые названия допустимы. Связи являются множествами ID существующих групп.

An empty legacy document reads as an empty schema-1 collection without rewriting the file. The first successful edit writes the structured document. Unknown schemas, unknown fields and inconsistent references fail without replacing the file. This preserves unsupported content instead of interpreting it as an empty collection.

Прежний пустой документ читается как пустая коллекция schema-1 без перезаписи файла. Структура записывается при первом успешном изменении. Неизвестные схемы, поля и несогласованные ссылки отклоняются без замены файла. Неподдержанные данные сохраняются и не трактуются как пустая коллекция.

## Publication and lifecycle / Запись и lifecycle

Rust owns the document, keys and storage. Dart receives typed groups, card summaries and explicitly requested account details; neither a key nor the complete document crosses the bridge. Names, descriptions, logos, logins, passwords and memberships remain within the encrypted payload. The approved pre-unlock hints remain the separate plaintext exception from ADR 0007.

Rust владеет документом, ключами и хранением. Dart получает типизированные группы, сводки карточек и явно запрошенные данные учётной записи; ключи и полный документ не пересекают bridge. Названия, описания, логотипы, логины, пароли и связи находятся внутри зашифрованного payload. Согласованные подсказки до входа остаются отдельным открытым исключением из ADR 0007.

Each mutation checks the expected document revision and session generation. It retains the authenticated header and both key slots, encrypts a new payload with a fresh random nonce and atomically replaces the file against its prior digest. No password derivation or recovery rotation occurs during ordinary edits. Group deletion removes only that group and its memberships in the same write.

Каждая операция изменения проверяет ожидаемый revision и generation сессии. Она сохраняет аутентифицированный header и оба key slots, шифрует новый payload со свежим случайным nonce и атомарно заменяет файл с проверкой прежнего digest. Обычное редактирование не вычисляет ключ из пароля и не меняет recovery. Удаление группы одной записью удаляет только группу и её связи.

Mutations share the native publication barrier with exports. Key invalidation does not hold the state mutex across filesystem writes. A write admitted before lock may finish before lock completion; stale work cannot publish afterward. Close retains exclusive storage ownership until admitted publications drain. A storage result with uncertain durability locks the session and requires reopening; it is never retried as a new create operation automatically.

Изменения используют общий native-барьер публикации с экспортами. Mutex состояния не удерживается во время файловой записи, чтобы не задерживать очистку ключей. Запись, допущенная до блокировки, может завершиться до окончания блокировки; устаревшая работа не публикуется позднее. Закрытие сохраняет эксклюзивное владение хранилищем до завершения допущенных публикаций. Неоднозначный результат записи блокирует сессию и требует повторного открытия; операция создания автоматически заново не выполняется.

## Inputs and display / Ввод и отображение

Names are required, trimmed on save and limited to 512 UTF-8 bytes. Descriptions are optional and limited to 16 KiB. Account login/email is required with a 4-KiB bound. Passwords are non-empty, limited to 64 KiB and are not trimmed or subjected to the master-password policy. Account-password editing requires explicit reveal and preserves line breaks in the multiline editor; the concealed view is read-only. NUL is rejected. The document allows at most 10,000 groups and 100,000 cards within the existing 64-MiB file limit.

Название обязательно, обрезается по краям при сохранении и ограничено 512 байтами UTF-8. Описание необязательно и ограничено 16 KiB. Логин/email обязателен и ограничен 4 KiB. Пароль непустой, ограничен 64 KiB, не обрезается и не проверяется правилами мастер-пароля. Для редактирования пароль карточки нужно явно раскрыть; многострочный редактор сохраняет переносы строк, скрытое поле доступно только для чтения. NUL отклоняется. Документ допускает максимум 10 000 групп и 100 000 карточек в пределах прежнего лимита файла 64 MiB.

A group uses a built-in folder, company, work, code, home or key icon, or a local PNG/JPEG. The picker bounds source files to 5 MiB and 4096 by 4096 pixels. The platform adapter normalizes the image to PNG up to 256 by 256 pixels without retaining the source path or metadata; native storage bounds the result to 512 KiB and checks its PNG header and dimensions. Decoded display images belong to their widgets and are disposed without entering the global image cache.

Группа использует встроенную иконку папки, компании, работы, кода, дома или ключа либо локальный PNG/JPEG. Исходник ограничен 5 MiB и 4096 на 4096 пикселей. Платформенный адаптер преобразует изображение в PNG до 256 на 256 пикселей без сохранения исходного пути и метаданных; native-хранилище ограничивает результат 512 KiB и проверяет PNG header и размеры. Расшифрованные изображения принадлежат виджетам и освобождаются без помещения в глобальный кэш изображений.

Editors and image selection are invalidated on lock. Password fields remain concealed by default and disable autofill, correction and keyboard learning. The released Want Input does not expose all required secret-entry controls, so credential editors use Forui under WantTheme pending [Want Allure #22](https://github.com/andrey-krasheninnikov/want-allure/issues/22). Diagnostics carry only fixed operation identifiers and error categories. Dart strings and OS input buffers cannot promise reliable memory erasure.

Блокировка закрывает редакторы и отменяет результаты выбора изображения. Поля пароля скрыты по умолчанию, отключают autofill, исправления и обучение клавиатуры. Выпущенный Want Input не предоставляет все необходимые настройки секретного ввода, поэтому credentials вводятся через Forui под WantTheme до [Want Allure #22](https://github.com/andrey-krasheninnikov/want-allure/issues/22). Диагностика содержит только фиксированные идентификаторы операций и категории ошибок. Надёжное обнуление Dart-строк и буферов ввода ОС не гарантируется.
