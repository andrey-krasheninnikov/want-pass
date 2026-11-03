# want-pass
🔑 Securely manage passwords, passkeys, TOTP, recovery codes, and developer secrets with seamless integration across devices, browsers, and developer tools.

## Project status / Статус проекта

The macOS client creates, locks, unlocks and recovers one offline encrypted vault. Secret cards, integrations, synchronization and release channels remain backlog tasks.

Клиент macOS создаёт, блокирует, разблокирует и восстанавливает один офлайн-сейф с шифрованием. Карточки секретов, интеграции, синхронизация и каналы релиза остаются задачами backlog.

- [Product concept / Концепция](docs/ideas/want-pass.md)
- [Specification / Спецификация](docs/product/spec.md) ([GitHub](https://github.com/andrey-krasheninnikov/want-pass/issues/1))
- [Roadmap and issue dependencies / План и зависимости](docs/product/roadmap.md)
- [Domain glossary / Словарь](GLOSSARY.md)
- [Architecture decisions / Архитектурные решения](docs/adr/)
- [Project rules / Правила проекта](AGENTS.md)

The first target is a local macOS vault and search widget. Flutter uses want_allure, domain_error, package_context, launch_mode and talker_bloc_effects; the backend uses Rust. Later work covers Windows, Linux, Android, iOS, passkeys, encrypted sync, browser and developer-tool integrations.

Первая цель: локальный macOS-сейф и поисковый виджет. Flutter использует want_allure, domain_error, package_context, launch_mode и talker_bloc_effects; backend использует Rust. Последующие этапы охватывают Windows, Linux, Android, iOS, passkeys, зашифрованную синхронизацию, браузеры и инструменты разработчика.

## Development foundation / Фундамент разработки

The client starts without a backend or account. The Rust library in `packages/pass_core/rust` owns the vault key and encrypted file. A separate Rust health service provides the backend foundation.

Клиент запускается без backend и аккаунта. Rust-библиотека в `packages/pass_core/rust` владеет ключом сейфа и зашифрованным файлом. Отдельный Rust health-сервис является фундаментом backend.

### Toolchains / Инструменты

Flutter 3.47.7 with Dart 3.13.5 is pinned through FVM; Rust 1.93.0 is pinned through rustup. Native macOS builds require Xcode and CocoaPods because some UI-kit plugins currently use CocoaPods. The checked local environment uses Xcode 26.2 and CocoaPods 1.16.2.

Flutter 3.47.7 с Dart 3.13.5 закреплён через FVM; Rust 1.93.0 закреплён через rustup. Нативная macOS-сборка требует Xcode и CocoaPods: часть плагинов UI kit пока использует CocoaPods. Проверенная локальная среда содержит Xcode 26.2 и CocoaPods 1.16.2.

```sh
fvm install
make bootstrap
make check
make build-macos
make native-ui
make run
```

Run the optional backend separately:

Необязательный backend запускается отдельно:

```sh
make server
curl --fail http://127.0.0.1:3000/healthz
```

The health response is `200` with `{"status":"ok"}`. Unknown routes return `404`; unsupported methods return `405`. The service binds only to loopback and does not log request data. It has no database, authentication or sync endpoints yet.

Health возвращает `200` и `{"status":"ok"}`. Неизвестные маршруты возвращают `404`, неподдержанные методы `405`. Сервис слушает только loopback и не логирует данные запросов. Базы данных, аутентификации и sync endpoints пока нет.

### Boundaries / Границы

- `apps/want_pass`: launch-mode initialization, singleton startup and vault use cases/controllers, allowlisted diagnostics and Want Allure presentation. Widgets do not read the package context or implement authorization/storage. / Инициализация режима запуска, singleton use cases/controllers запуска и сейфа, разрешённые диагностические маркеры и Want Allure. Виджеты не читают package context и не реализуют авторизацию/хранение.
- `packages/pass_core`: Dart access services, versioned domain errors, package-owned startup context and a Rust vault through Flutter Rust Bridge Native Assets. The foreground startup guard is callable without Flutter widgets or a server. / Access services на Dart, версионированные доменные ошибки, собственный startup package context и Rust-сейф через Flutter Rust Bridge Native Assets. Проверка foreground-запуска доступна без Flutter-виджетов и сервера.
- `server`: a Rust HTTP service with a static health route and request-failure tests. / Rust HTTP-сервис со статическим health-маршрутом и проверками ошибочных запросов.

All workspace members use one committed pub lockfile; the vault library, backend and native pods have their own committed lockfiles. `want_allure 1.0.0` is a hosted immutable dependency, not an external path override. Internal workspace modules are versioned in this repository. The native bundle identifier and template app icon are development defaults, not a store submission or reserved production identity.

Все участники workspace используют один закоммиченный pub lockfile; библиотека сейфа, backend и нативные pods имеют собственные lockfiles. `want_allure 1.0.0` является опубликованной неизменяемой зависимостью, а не внешней path-подменой. Внутренние модули workspace версионируются в этом репозитории. Bundle identifier и шаблонная иконка являются defaults разработки, а не публикацией в сторе или зарезервированной production-идентичностью.

Diagnostics forward only fixed event markers. Arbitrary states, effects, error objects and traces are neither formatted nor retained by the logging adapter. Framework failures render generic text. Vault-format tests include published cryptographic vectors and interrupted writes; source review does not replace an external security audit.

Диагностика передаёт только фиксированные маркеры. Произвольные состояния, эффекты, ошибки и traces не форматируются и не сохраняются адаптером логирования. Ошибки framework показывают общий текст. Тесты формата сейфа включают опубликованные криптографические векторы и прерывание записи; проверка исходников не заменяет внешний аудит безопасности.

### Local vault / Локальный сейф

Choose a master password with at least 15 Unicode scalar values and at most 1,024 UTF-8 bytes. Save the 24 English recovery words and confirm three requested words before creation completes. Recovery requires the existing vault file; it replaces the current password, data key and recovery phrase after another confirmation. Independent old copies retain their old credentials.

Выберите мастер-пароль от 15 Unicode scalar values до 1024 UTF-8 байт. Сохраните 24 английских слова восстановления и подтвердите три запрошенных слова до завершения создания. Для recovery нужен существующий файл сейфа; после повторного подтверждения заменяются текущие пароль, ключ данных и recovery-фраза. Независимые старые копии сохраняют старые credentials.

The file lives in the application's Application Support `vault/vault.wpass`. Lock is explicit, after five idle minutes, and on native macOS lock/sleep events. Passwords and displayed recovery words pass through Dart strings, whose memory cannot be reliably zeroed. The encrypted format, threat limits and native key lifecycle are defined in [ADR 0006](docs/adr/0006-vault-format-and-native-key-lifecycle.md).

Файл находится в Application Support приложения по пути `vault/vault.wpass`. Блокировка выполняется вручную, через пять минут бездействия и по нативным событиям lock/sleep macOS. Пароль и отображаемые recovery-слова проходят через Dart-строки, память которых нельзя надёжно обнулить. Формат шифрования, границы защиты и lifecycle ключей определены в [ADR 0006](docs/adr/0006-vault-format-and-native-key-lifecycle.md).

`make check` runs local Dart, Flutter and both Rust suites. `make native-ui` runs creation, recovery and reopening in two macOS application processes using a separate disposable Application Support directory; it removes that directory after reopening. An interrupted run can leave only its `integration-issue-3-local_*` fixture. Real OS lock/sleep delivery and other platforms require separate verification.

`make check` выполняет локальные Dart-, Flutter-проверки и оба набора Rust-тестов. `make native-ui` проверяет создание, recovery и повторное открытие в двух процессах macOS-приложения с отдельным временным каталогом Application Support; после повторного открытия каталог удаляется. Прерванный прогон может оставить только свой тестовый каталог `integration-issue-3-local_*`. Доставка настоящих событий lock/sleep ОС и другие платформы требуют отдельной проверки.

After changing the Rust bridge API, install `flutter_rust_bridge_codegen 2.13.0` and `cargo-expand` in a tool directory on `PATH`, then run `make generate`. The wrapper checks the bridge version, keeps diagnostics free of call arguments and applies the layer import rules. Ordinary builds use the committed bridge files and require no bridge tooling.

После изменения Rust bridge API установите `flutter_rust_bridge_codegen 2.13.0` и `cargo-expand` в каталог инструментов на `PATH`, затем выполните `make generate`. Wrapper проверяет версию bridge, исключает аргументы вызовов из диагностики и применяет правила импортов слоёв. Обычная сборка использует закоммиченные bridge-файлы и не требует инструментов bridge.
