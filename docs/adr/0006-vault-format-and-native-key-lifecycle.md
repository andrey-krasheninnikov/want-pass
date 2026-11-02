---
status: accepted
---

# Vault V1 and native key ownership / Сейф V1 и владение ключами

## Boundary / Граница

Issue #3 implements one offline vault. Flutter owns interaction and application state; a Rust library owns cryptography, encrypted persistence and key lifetime. The library is compiled through Flutter Rust Bridge 2.13.0 Native Assets, independently from the Rust sync server. No key or decrypted document crosses the bridge. Passwords and the recovery phrase necessarily pass through the UI; their Dart strings cannot be reliably zeroed.

Задача #3 реализует один офлайн-сейф. Flutter владеет взаимодействием и состоянием приложения; Rust-библиотека владеет криптографией, зашифрованным хранением и жизненным циклом ключей. Библиотека собирается через Flutter Rust Bridge 2.13.0 Native Assets независимо от Rust sync-сервера. Ключи и расшифрованный документ не пересекают bridge. Пароль и recovery-фраза неизбежно проходят через UI; надёжное обнуление Dart-строк не гарантируется.

## Threats / Угрозы

Protect a copied locked vault and detect unauthenticated changes. An authorized compromised OS, process-memory inspection, screenshots, a stolen recovery phrase, deletion and replacement with an older complete valid file are outside this guarantee. Recovery changes the current file; it cannot revoke independent old copies. File size, existence and filesystem timestamps remain observable. This PR receives source review and established-vector testing; it does not claim an external security audit.

Защищается скопированный закрытый сейф, обнаруживаются неаутентифицированные изменения. Компрометация авторизованной ОС, чтение памяти процесса, снимки экрана, кража recovery-фразы, удаление и замена целым старым исправным файлом вне этой гарантии. Recovery меняет текущий файл и не отзывает независимые старые копии. Размер, наличие файла и timestamps файловой системы остаются видимыми. PR проходит проверку исходников и стандартных векторов; внешний аудит безопасности не заявляется.

## Cryptographic contract / Криптографический контракт

V1 uses a random 32-byte data key and XChaCha20-Poly1305 with 24-byte independent random nonces and 16-byte authentication tags. Password wrapping uses Argon2id version 0x13: 65,536 KiB, three passes, four lanes, a random 16-byte salt and a 32-byte output. Parameters are an exact V1 profile, not attacker-controlled resource requests. A master password has at least 15 Unicode scalar values and at most 1,024 UTF-8 bytes. Do not trim, normalize or require character classes.

V1 использует случайный ключ данных 32 байта и XChaCha20-Poly1305 с независимыми случайными nonce 24 байта и authentication tags 16 байт. Ключ обёртки пароля получается через Argon2id версии 0x13: 65 536 KiB, три прохода, четыре lanes, случайная соль 16 байт и результат 32 байта. Параметры являются точным профилем V1, а не управляемым извне запросом ресурсов. Мастер-пароль содержит минимум 15 Unicode scalar values и максимум 1024 UTF-8 байта. Обрезание, нормализация и обязательные классы символов не применяются.

A separate random 32-byte entropy value becomes 24 English BIP39 words with checksum. BIP39 is an entropy encoding only: do not derive a wallet seed or accept a user-chosen phrase. Recover its entropy, then derive the recovery wrapping key with HKDF-SHA256, vault ID as salt and `WantPass/recovery/v1` as info. Creation and recovery commit only after the owner confirms three distinct randomly selected words. The phrase is never saved in the vault or logs and is not a backup of the file.

Отдельная случайная энтропия 32 байта кодируется 24 английскими словами BIP39 с checksum. BIP39 используется только как кодировка энтропии: wallet seed и пользовательская произвольная фраза не применяются. Из восстановленной энтропии recovery-ключ получается через HKDF-SHA256 с vault ID в качестве соли и `WantPass/recovery/v1` в качестве info. Создание и recovery записываются только после подтверждения трёх различных случайных слов. Фраза не сохраняется в сейфе или логах и не является резервной копией файла.

The canonical binary header contains only magic, format/suite/profile identifiers, random vault ID and password salt. Each key slot authenticates that header and a distinct password/recovery context. The payload authenticates the complete header including both encrypted slots. Names, groups, environments, revisions, attachments and all other user document fields belong inside the encrypted payload. V1 refuses files over 64 MiB before allocation. Exact byte layout and fixture checks live beside the codec tests.

Канонический бинарный заголовок содержит только magic, идентификаторы формата/алгоритмов/профиля, случайный vault ID и соль пароля. Каждый key slot аутентифицирует заголовок и отдельный контекст password/recovery. Payload аутентифицирует полный заголовок с обоими зашифрованными slots. Названия, группы, окружения, версии, вложения и остальные поля пользовательского документа находятся внутри шифрованного payload. V1 отвергает файлы больше 64 MiB до выделения памяти. Точная раскладка байтов и проверки образцов находятся рядом с тестами кодека.

## Lifecycle and writes / Lifecycle и запись

Native opaque resources own keys and zeroizing buffers. Explicit lock, five idle minutes, macOS lock/sleep and close invalidate pending access and clear the active document and key. An operation finishing after lock cannot re-open the session. Services and use cases retain no session; the application controller owns the resource and disposes it. Diagnostic output contains fixed allowlisted categories only.

Native opaque-ресурсы владеют ключами и обнуляемыми буферами. Явная блокировка, пять минут бездействия, lock/sleep macOS и close отменяют незавершённый доступ и очищают активные документ и ключ. Операция, завершившаяся после блокировки, не открывает сессию повторно. Сервисы и use cases не сохраняют сессию; ресурс принадлежит контроллеру приложения и освобождается им. Диагностика содержит только фиксированные разрешённые категории.

Store the fixed-name vault under Application Support in a private 0700 directory, with 0600 files. Refuse symlinks at the storage boundary. Hold an OS file lock while the resource is open. Write only ciphertext to an exclusive temporary file in the same directory, sync it, atomically publish it and sync the directory. Creation refuses an existing file. Failed authentication or unsupported format performs no write. After an ambiguous commit, inspect the actual file before any retry and preserve the pending confirmation material until the result is known.

Сейф с фиксированным именем хранится в Application Support, в каталоге 0700 с файлами 0600. На границе хранения симлинки отвергаются. Пока ресурс открыт, удерживается файловая блокировка ОС. Только шифротекст пишется в эксклюзивный временный файл того же каталога, синхронизируется, атомарно публикуется, затем синхронизируется каталог. Создание отвергает существующий файл. Ошибка аутентификации или неподдержанный формат не выполняет запись. После неоднозначного commit фактический файл сверяется до повтора; материал незавершённого подтверждения сохраняется до выяснения результата.

Recovery requires both the existing file and the phrase. It decrypts the current document, prepares a new password, data key and recovery phrase, then replaces the file only after confirmation. The old password and recovery phrase cannot open the new current file.

Recovery требует существующий файл и фразу. Процесс расшифровывает текущий документ, подготавливает новый пароль, ключ данных и recovery-фразу, затем заменяет файл только после подтверждения. Старые пароль и recovery-фраза не открывают новый текущий файл.

## Compatibility and verification / Совместимость и проверка

The empty application foundation has no previous vault format to migrate. V1 supports only its declared format, suite and payload schema. Unknown versions are rejected without rewriting. A later migration must explicitly preserve the original until a verified atomic replacement; no silent downgrade or speculative converter is included.

Исходный фундамент приложения не содержит старого формата сейфа для миграции. V1 поддерживает только заявленные формат, алгоритмы и schema payload. Неизвестные версии отвергаются без перезаписи. Будущая миграция явно сохраняет оригинал до проверенной атомарной замены; скрытого downgrade или конвертера на будущее нет.

Verify public application operations, official Argon2id/HKDF/BIP39 and published XChaCha vectors, tampering, interrupted writes, concurrent access, recovery rotation and a real macOS Flutter UI flow using disposable data. Keep local checks, native UI execution, physical OS sleep/lock, other platforms and external audit evidence separate.

Проверяются публичные операции приложения, официальные векторы Argon2id/HKDF/BIP39 и опубликованные векторы XChaCha, подмена, прерывание записи, конкурентный доступ, ротация recovery и настоящий macOS Flutter UI-сценарий на временных данных. Локальные проверки, native UI-прогон, физические sleep/lock ОС, другие платформы и внешний аудит указываются отдельно.

References / Источники: [RFC 9106](https://www.rfc-editor.org/rfc/rfc9106), [RFC 5869](https://www.rfc-editor.org/rfc/rfc5869), [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki), [XChaCha20-Poly1305](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction), [Native Assets](https://cjycode.com/flutter_rust_bridge/manual/integrate/native-assets).
