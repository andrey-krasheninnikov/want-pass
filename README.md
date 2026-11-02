# want-pass
🔑 Securely manage passwords, passkeys, TOTP, recovery codes, and developer secrets with seamless integration across devices, browsers, and developer tools.

## Project status / Статус проекта

Product decisions and the implementation backlog are documented. Application features and release channels remain planned work.

Продуктовые решения и backlog реализации описаны. Функции приложения и каналы релиза остаются планируемой работой.

- [Product concept / Концепция](docs/ideas/want-pass.md)
- [Specification / Спецификация](docs/product/spec.md) ([GitHub](https://github.com/andrey-krasheninnikov/want-pass/issues/1))
- [Roadmap and issue dependencies / План и зависимости](docs/product/roadmap.md)
- [Domain glossary / Словарь](GLOSSARY.md)
- [Architecture decisions / Архитектурные решения](docs/adr/)
- [Project rules / Правила проекта](AGENTS.md)

The first target is a local macOS vault and search widget. Flutter uses want_allure, domain_error, package_context, launch_mode and talker_bloc_effects; the backend uses Rust. Later work covers Windows, Linux, Android, iOS, passkeys, encrypted sync, browser and developer-tool integrations.

Первая цель: локальный macOS-сейф и поисковый виджет. Flutter использует want_allure, domain_error, package_context, launch_mode и talker_bloc_effects; backend использует Rust. Последующие этапы охватывают Windows, Linux, Android, iOS, passkeys, зашифрованную синхронизацию, браузеры и инструменты разработчика.

## Development foundation / Фундамент разработки

The first implementation task adds a macOS application shell and a Rust health service. The client starts locally without a backend. Vault creation, encryption, credential storage and synchronization remain separate backlog tasks; this build accepts no secrets.

Первая задача реализации добавляет оболочку macOS-приложения и Rust health-сервис. Клиент запускается локально без backend. Создание сейфа, шифрование, хранение credentials и синхронизация остаются отдельными задачами; эта сборка не принимает секреты.

### Toolchains / Инструменты

Flutter 3.47.7 with Dart 3.13.5 is pinned through FVM; Rust 1.93.0 is pinned through rustup. Native macOS builds require Xcode and CocoaPods because some UI-kit plugins currently use CocoaPods. The checked local environment uses Xcode 26.2 and CocoaPods 1.16.2.

Flutter 3.47.7 с Dart 3.13.5 закреплён через FVM; Rust 1.93.0 закреплён через rustup. Нативная macOS-сборка требует Xcode и CocoaPods: часть плагинов UI kit пока использует CocoaPods. Проверенная локальная среда содержит Xcode 26.2 и CocoaPods 1.16.2.

```sh
fvm install
make bootstrap
make check
make build-macos
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

- `apps/want_pass`: launch-mode initialization, singleton startup use case/controller, allowlisted diagnostics and Want Allure presentation. Widgets do not read the package context or implement authorization/storage. / Инициализация режима запуска, singleton use case/controller запуска, разрешённые диагностические маркеры и Want Allure. Виджеты не читают package context и не реализуют авторизацию/хранение.
- `packages/pass_core`: pure Dart startup access service, versioned domain errors, package-owned context and explicit domain results. The foreground startup guard is callable without Flutter widgets or a server. / Startup access service на Dart, версионированные доменные ошибки, собственный package context и явные domain results. Проверка foreground-запуска доступна без Flutter-виджетов и сервера.
- `server`: a Rust HTTP service with a static health route and request-failure tests. / Rust HTTP-сервис со статическим health-маршрутом и проверками ошибочных запросов.

All workspace members use one committed pub lockfile; the backend and native pods have their own committed lockfiles. `want_allure 1.0.0` is a hosted immutable dependency, not an external path override. Internal workspace modules are versioned in this repository. The native bundle identifier and template app icon are development defaults, not a store submission or reserved production identity.

Все участники workspace используют один закоммиченный pub lockfile; backend и нативные pods имеют собственные lockfiles. `want_allure 1.0.0` является опубликованной неизменяемой зависимостью, а не внешней path-подменой. Внутренние модули workspace версионируются в этом репозитории. Bundle identifier и шаблонная иконка являются defaults разработки, а не публикацией в сторе или зарезервированной production-идентичностью.

Diagnostics forward only fixed event markers. Arbitrary states, effects, error objects and traces are neither formatted nor retained by the logging adapter. Framework failures render generic text. This boundary has automated checks; it is not a security review of a future encrypted vault.

Диагностика передаёт только фиксированные маркеры. Произвольные состояния, эффекты, ошибки и traces не форматируются и не сохраняются адаптером логирования. Ошибки framework показывают общий текст. Эта граница имеет автоматические проверки и не заменяет проверку безопасности будущего зашифрованного сейфа.
