---
status: accepted
---

# Versioned secret cards / Версионированные карточки секретов

## Scope and format / Объём и формат

Issues #5, #6 and #7 share one card model. Every card requires a built-in service, retains template version `1` and may have an environment and several groups. IDs, rather than names or services, identify cards. The ten environments are local, unit-tests, integration-tests, e2e-tests, development, stand, feature, stage, pre-release and production. Custom services, custom types, target bindings and history remain separate roadmap tasks.

Задачи #5, #6 и #7 используют общую модель карточки. Каждая карточка требует встроенный сервис, хранит версию шаблона `1` и может иметь окружение и несколько групп. Карточку определяет ID, а не название или сервис. Доступны десять окружений: local, unit-tests, integration-tests, e2e-tests, development, stand, feature, stage, pre-release и production. Собственные сервисы и типы, привязки ресурсов и история остаются отдельными задачами roadmap.

The encrypted JSON document uses schema `2`, with revision, groups and cards. The outer V2 vault format and cryptographic profiles are unchanged. Empty document bytes read as an empty schema-2 collection. Populated schema-1 documents are rejected without rewriting them. This development release intentionally has no migration; the agreed local acceptance stand starts with a new vault. Earlier versioned content APIs retain their schema-1 contract and reject schema 2.

Зашифрованный JSON-документ использует schema `2` с revision, группами и карточками. Внешний формат сейфа V2 и криптографические профили не меняются. Пустые байты документа читаются как пустая коллекция schema-2. Заполненный schema-1 отклоняется без перезаписи. У этого выпуска для разработки намеренно нет миграции; согласованный локальный стенд приёмки начинает с нового сейфа. Прежние версионированные API содержимого сохраняют контракт schema-1 и отклоняют schema-2.

Rust owns field descriptors, validation, TOTP generation and atomic encrypted writes. Dart receives summaries, requested card fields and attachment metadata. File contents leave native storage only through explicit selection or export. Expected revisions and session generations protect reads and mutations; lock drains admitted publications before reporting completion. Unknown fields, types, services and template versions are rejected. Ordinary edits retain the key slots and use a fresh payload nonce.

Rust владеет описаниями полей, валидацией, вычислением TOTP и атомарной зашифрованной записью. Dart получает сводки, запрошенные поля карточки и метаданные файла. Содержимое файлов покидает native-хранилище только при явном выборе или экспорте. Ожидаемые revision и generation сессии защищают чтение и изменения; блокировка ждёт завершения допущенных публикаций. Неизвестные поля, типы, сервисы и версии шаблонов отклоняются. Обычные изменения сохраняют key slots и используют свежий nonce payload.

## Presets and validation / Пресеты и валидация

The 19 presets are account, PAT, RSA, Ed25519, secret key, passphrase, recovery codes, recovery URL, secret question/answer, VLESS, WireGuard, GPG, certificate/private key, OAuth, DSN, kubeconfig, webhook signing secret, secure note and file. Passkeys require their own provider and are not represented as a text preset.

Доступны 19 пресетов: учётная запись, PAT, RSA, Ed25519, secret key, passphrase, recovery codes, recovery URL, секретный вопрос/ответ, VLESS, WireGuard, GPG, сертификат/закрытый ключ, OAuth, DSN, kubeconfig, webhook signing secret, защищённая заметка и файл. Passkeys требуют собственного provider и не представлены текстовым пресетом.

RSA and Ed25519 accept matching OpenSSH pairs or PEM public SPKI plus private PKCS8 (RSA also accepts private PKCS1). Certificates accept PEM X.509 and a PEM private key; clear RSA, Ed25519 and P-256/P-384/P-521 keys are matched to the certificate public key. GPG uses ASCII-armored public/private key containers with matching primary fingerprints. A protected OpenSSH or PKCS8 container can be stored without its passphrase. Its envelope is parsed, but protected contents and correspondence hidden by encryption cannot be verified. These checks do not establish certificate trust, expiry suitability or remote credential validity.

RSA и Ed25519 принимают соответствующие пары OpenSSH либо PEM public SPKI и private PKCS8 (RSA также принимает private PKCS1). Сертификаты принимают PEM X.509 и закрытый PEM-ключ; открытые для чтения ключи RSA, Ed25519 и P-256/P-384/P-521 сопоставляются с публичным ключом сертификата. GPG использует ASCII-armored контейнеры публичного и закрытого ключей с совпадающими primary fingerprints. Защищённый контейнер OpenSSH или PKCS8 сохраняется без passphrase. Проверяется его оболочка; скрытое шифрованием содержимое и соответствие проверить нельзя. Эти проверки не устанавливают доверие сертификату, пригодность его срока действия или действительность credentials на сервере.

Recovery URLs require HTTP(S); VLESS requires a UUID, host and explicit port. DSN accepts URI form. WireGuard checks sections, key encoding, addresses and basic numeric bounds. Kubeconfig checks bounded YAML, named clusters/users/contexts and their references; aliases, anchors and unsupported tags are rejected. Commands inside stored configuration are never run. Opaque tokens, notes and passphrases retain their exact non-empty values, including line breaks and spaces. All field values reject NUL and enforce their descriptor's UTF-8 byte bound.

Recovery URL требует HTTP(S); VLESS требует UUID, хост и явный порт. DSN принимает URI. WireGuard проверяет секции, кодировку ключей, адреса и основные числовые ограничения. Kubeconfig проверяет ограниченный YAML, именованные clusters/users/contexts и их ссылки; aliases, anchors и неподдержанные tags отклоняются. Команды из сохранённых конфигураций не выполняются. Непрозрачные токены, заметки и passphrase сохраняют точные непустые значения, включая переносы строк и пробелы. Все значения отклоняют NUL и ограничены размером UTF-8 из описания поля.

## OTP and explicit disclosure / OTP и явное раскрытие

An account may contain a Base32 seed or `otpauth://totp` URI, SHA1/SHA256/SHA512, 6 to 8 digits and a period from 1 to 86,400 seconds. Defaults are SHA1, 6 digits and 30 seconds. URI parameters take precedence and are normalized into separate encrypted fields. HOTP and QR import are outside this task. Native UTC time generates the code; presentation refreshes at its deadline, masks expired codes and pauses while hidden or inactive. Refresh does not extend vault inactivity access.

Карточка аккаунта может содержать Base32 seed либо `otpauth://totp` URI, SHA1/SHA256/SHA512, от 6 до 8 цифр и период от 1 до 86 400 секунд. По умолчанию: SHA1, 6 цифр и 30 секунд. Параметры URI имеют приоритет и преобразуются в отдельные зашифрованные поля. HOTP и импорт QR не входят в задачу. Код вычисляется по native UTC-времени; интерфейс обновляет его на границе периода, скрывает истёкший код и приостанавливается в скрытом или неактивном состоянии. Обновление не продлевает доступ при бездействии.

Account copy-all contains only login, password and the current OTP, when configured. Seeds, service recovery codes, reserve logins and private keys require separate labelled actions. Credential fields start concealed where appropriate and disable keyboard learning, correction and autofill. The clipboard owner clears only an unchanged copy after 30 seconds, on lock or on replacement. OS clipboard history and Dart string memory remain outside reliable erasure guarantees.

«Скопировать всё» для аккаунта содержит только логин, пароль и текущий OTP, если он настроен. Seed, recovery-коды сервиса, резервные логины и закрытые ключи копируются отдельными подписанными действиями. Секретные поля изначально скрыты там, где это требуется, и отключают обучение клавиатуры, исправления и autofill. Владелец буфера очищает только неизменённую копию через 30 секунд, при блокировке или замене. Надёжное удаление из истории буфера ОС и памяти Dart-строк не гарантируется.

## Attachments / Файлы

A file is limited to 20 MiB and keeps only a safe basename and encrypted Base64 contents. The complete vault remains limited to 64 MiB, including encryption overhead and Base64 expansion. Two files at the maximum size fit within an otherwise small vault; a third exceeds the limit and leaves the existing file unchanged. The editor shows metadata and exports only on an explicit action, with private permissions and revision/session checks immediately before atomic publication. A late picker result after lock is discarded. Exported files become the user's responsibility.

Файл ограничен 20 MiB и хранит только безопасное имя и зашифрованное содержимое Base64. Весь сейф ограничен 64 MiB с учётом шифрования и расширения Base64. Два файла максимального размера помещаются в небольшой сейф; третий превышает лимит и оставляет существующий файл без изменений. Редактор показывает метаданные и экспортирует только по явному действию, с приватными правами и проверкой revision/сессии перед атомарной публикацией. Поздний результат выбора после блокировки отбрасывается. Экспортированные файлы находятся под ответственностью пользователя.
