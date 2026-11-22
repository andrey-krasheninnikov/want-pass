# want-pass
🔑 Securely manage passwords, passkeys, TOTP, recovery codes, and developer secrets with seamless integration across devices, browsers, and developer tools.

## Project status / Статус проекта

Want Pass stores groups, secret cards, custom services, types and card history in an encrypted vault on the Mac. Import and backup recovery run locally.

Want Pass хранит группы, карточки секретов, пользовательские сервисы, типы и историю изменений в зашифрованном сейфе на Mac. Импорт и восстановление копии работают локально.

- [Product concept / Концепция](docs/ideas/want-pass.md)
- [Specification / Спецификация](docs/product/spec.md) ([GitHub](https://github.com/andrey-krasheninnikov/want-pass/issues/1))
- [Roadmap and issue dependencies / План и зависимости](docs/product/roadmap.md)
- [Domain glossary / Словарь](GLOSSARY.md)
- [macOS build and release / Сборка и выпуск macOS](docs/product/macos-release.md)
- [Account import / Импорт учётных записей](docs/product/account-import.md)
- [Portable backups / Переносимые копии](docs/product/portable-backup.md)
- [Architecture decisions / Архитектурные решения](docs/adr/)
- [Project rules / Правила проекта](AGENTS.md)

The desktop client uses Flutter, Want Allure and a Rust vault. The optional Rust backend has a separate lifecycle.

Клиент написан на Flutter и использует Want Allure. Сейф работает на Rust. Дополнительный Rust-сервер запускается отдельно.

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

The workspace uses one committed pub lockfile. Rust and CocoaPods have separate lockfiles. The app pins the released `want_allure 1.2.2` package.

В workspace один общий pub lockfile. У Rust и CocoaPods свои lockfiles. Приложение использует выпущенный пакет `want_allure 1.2.2`.

Diagnostics forward only fixed event markers. Arbitrary states, effects, error objects and traces are neither formatted nor retained by the logging adapter. Framework failures render generic text. Vault-format tests include published cryptographic vectors and interrupted writes; source review does not replace an external security audit.

Диагностика передаёт только фиксированные маркеры. Произвольные состояния, эффекты, ошибки и traces не форматируются и не сохраняются адаптером логирования. Ошибки framework показывают общий текст. Тесты формата сейфа включают опубликованные криптографические векторы и прерывание записи; проверка исходников не заменяет внешний аудит безопасности.

### Local vault / Локальный сейф

The setup wizard starts with system/light/dark theme and Russian/English language controls. It uses Want Allure 1.2.2, a rotating 3D Want Pass logo, a native branded icon and splash screen, and a sphere/lightning background that alternates every 30 seconds. Decorative motion respects reduced motion and inactive views. Device preferences persist and remain editable in the header.

Мастер настройки начинается с выбора системной/светлой/тёмной темы и русского/английского языка. Используются Want Allure 1.2.2, вращающийся 3D-логотип Want Pass, фирменные native icon и splash screen. Фоновая сфера и молнии сменяют друг друга каждые 30 секунд. Декоративная анимация поддерживает reduced motion и остановку неактивного экрана. Оформление устройства сохраняется и меняется в header.

Choose a master password with at least 15 Unicode scalars, an uppercase letter, lowercase letter, ASCII digit and special character; the maximum is 1,024 UTF-8 bytes. The editor is single-line, with a visibility toggle. Optional hints are stored openly and shown before unlock. Save the 24 recovery words through JSON, clipboard or local QR and complete three separate word checks. These exports grant access to the existing vault file; they cannot restore a deleted file.

Выберите мастер-пароль минимум из 15 Unicode scalars, с заглавной и строчной буквами, ASCII-цифрой и спецсимволом; максимум 1024 UTF-8 байта. Однострочное поле поддерживает показ и скрытие. Необязательные подсказки хранятся открыто и видны до разблокировки. Сохраните 24 recovery-слова через JSON, буфер обмена или локальный QR и пройдите три отдельных проверки слов. Экспорт даёт доступ к существующему файлу сейфа и не восстанавливает удалённый файл.

The production bundle is `foundation.want.pass` and the development bundle is `foundation.want.pass.dev`. Each uses its own macOS Application Support directory. Their vault files are `production/vault/vault.wpass` and `development/vault/vault.wpass` respectively. Want Pass locks after five idle minutes, when macOS sleeps or locks, or when the owner locks it. Dart strings containing passwords and recovery words have no reliable memory-erasure guarantee. [Vault format](docs/adr/0006-vault-format-and-native-key-lifecycle.md) · [Pre-unlock hints](docs/adr/0007-vault-v2-hints-and-setup.md)

У релизного приложения bundle ID `foundation.want.pass`, у приложения для разработки — `foundation.want.pass.dev`. Каждая сборка использует свой каталог Application Support. Относительные пути к сейфам — `production/vault/vault.wpass` и `development/vault/vault.wpass`. Сейф блокируется вручную, через пять минут бездействия, при блокировке macOS или переходе в сон. Dart не гарантирует обнуление строк с паролями и словами восстановления. [Формат сейфа](docs/adr/0006-vault-format-and-native-key-lifecycle.md) · [Подсказки до входа](docs/adr/0007-vault-v2-hints-and-setup.md)

During setup, save the recovery words and then confirm three different positions. A wrong answer takes you back to the same phrase. Download, copy and QR use the same numbered JSON. For recovery, enter the words manually or paste the phrase or numbered JSON.

Во время настройки сохраните фразу восстановления и подтвердите слова на трёх разных позициях. Ошибка возвращает к той же фразе. Скачивание, копирование и QR используют один JSON с пронумерованными словами. При восстановлении слова можно ввести вручную, вставить текстом или в формате JSON.

The password field offers a saved hint and recovery in its help popover. On supported Macs, enable Touch ID in General settings after unlocking with the master password.

Справка поля пароля открывает сохранённую подсказку и восстановление доступа. На совместимом Mac можно включить Touch ID в общих настройках после входа с мастер-паролем.

To erase the development vault and appearance preferences, quit **Want Pass Dev** and run `make clean-data`. Run `make run` to start a new development vault. Production uses a separate bundle and directory. Existing files from older development builds stay in their original location.

Чтобы удалить сейф и настройки оформления разработки, закройте **Want Pass Dev** и выполните `make clean-data`. Команда `make run` откроет новый тестовый стенд. У production отдельные приложение и каталог. Файлы прежних сборок разработки остаются на своих местах.

`make check` runs local Dart, Flutter and both Rust suites. `make native-ui` runs creation, group/card editing, recovery and reopening in two macOS application processes using a separate disposable Application Support directory; it removes that directory after reopening. An interrupted run can leave only its `integration-issue-3-local_*` fixture. Real OS lock/sleep delivery and other platforms require separate verification.

`make check` выполняет локальные Dart-, Flutter-проверки и оба набора Rust-тестов. `make native-ui` проверяет создание, редактирование групп и карточек, recovery и повторное открытие в двух процессах macOS-приложения с отдельным временным каталогом Application Support; после повторного открытия каталог удаляется. Прерванный прогон может оставить только свой тестовый каталог `integration-issue-3-local_*`. Доставка настоящих событий lock/sleep ОС и другие платформы требуют отдельной проверки.

After changing the Rust bridge API, install `flutter_rust_bridge_codegen 2.13.0` and `cargo-expand` in a tool directory on `PATH`, then run `make generate`. The wrapper checks the bridge version, keeps diagnostics free of call arguments and applies the layer import rules. Ordinary builds use the committed bridge files and require no bridge tooling.

После изменения Rust bridge API установите `flutter_rust_bridge_codegen 2.13.0` и `cargo-expand` в каталог инструментов на `PATH`, затем выполните `make generate`. Wrapper проверяет версию bridge, исключает аргументы вызовов из диагностики и применяет правила импортов слоёв. Обычная сборка использует закоммиченные bridge-файлы и не требует инструментов bridge.

## Groups and cards / Группы и карточки

Choose a built-in or custom service and card type. A card can belong to several groups and can specify an environment and resource bindings. Accounts support TOTP, recovery codes and alternate logins. Copy all includes the login, password and current OTP. The size limit is 20 MiB per attachment and 64 MiB for the encrypted vault.

Укажите встроенный или собственный сервис и тип карточки. Карточку можно добавить в несколько групп, назначить ей окружение и ресурсы. Учётные записи поддерживают TOTP, коды восстановления и запасные логины. Действие «Скопировать всё» копирует логин, пароль и текущий OTP. Лимит вложения — 20 МиБ, зашифрованного сейфа — 64 МиБ.

The current reader supports card schemas 2 and 3. Keep the backup file and the 24-word phrase used when you exported it. During restore, select full replacement or merge. With merge, choose the local version, the incoming version or both for each conflict.

Клиент читает карточки схем 2 и 3. Сохраните файл копии и фразу из 24 слов, действовавшую на момент экспорта. При восстановлении выберите полную замену или объединение. При объединении для каждого конфликта можно оставить локальную версию, входящую или обе.

See / См. [ADR 0011](docs/adr/0011-versioned-secret-cards.md) for supported formats and limits; [ADR 0010](docs/adr/0010-encrypted-groups-and-account-cards.md) for groups and the earlier document contract.
