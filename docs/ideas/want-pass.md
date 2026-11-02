# Want Pass

## Problem Statement

How can developers keep common personal and work secrets organized and readily usable without splitting passwords, OTP and developer credentials across unrelated tools?

Как разработчику упорядочить распространённые личные и рабочие секреты и удобно использовать их без разнесения паролей, OTP и credentials по разным инструментам?

## Recommended Direction

Start with a personal local vault and a cursor-adjacent macOS search widget. Separate typed cards, overlapping project/company groups and an optional environment provide explicit organization. Imports from Apple Passwords and Google Authenticator make an initial daily workflow possible; protected backup and recovery are part of that first workflow.

Начать с личного локального сейфа и поискового macOS-виджета рядом с курсором. Отдельные типизированные карточки, пересекающиеся группы проектов/компаний и необязательное окружение задают явную организацию. Импорт Apple Passwords и Google Authenticator позволяет перейти к ежедневному использованию; защищённый backup и recovery входят в первый сценарий.

The catalog direction was chosen over an account-centered bundle, a project-only workspace, context-first access, an integration-first credential service and a portability-first vault. Local organization and the widget test daily usefulness first; browser, terminal, passkey-provider and bounded MCP integrations then reuse the same policies. The central assumption is that typed forms and clear organization reduce the friction reported with existing tools; this has not yet been validated by a working application.

Выбрано направление каталога вместо объединения всего в аккаунте, только проектных пространств, контекстного доступа, первичного сервиса интеграций и акцента только на переносимости. Организация и виджет сначала проверяют ежедневную полезность; браузер, терминал, passkey provider и ограниченный MCP затем используют те же политики. Главная гипотеза состоит в том, что типовые формы и понятная организация уменьшают описанное неудобство существующих инструментов; работающее приложение её пока не подтвердило.

## Key Assumptions to Validate

- [ ] A developer can distinguish two accounts, PAT and SSH keys across projects/environments in a real create/find/copy scenario. / Разработчик различает два аккаунта, PAT и SSH-ключи между проектами/окружениями в реальном сценарии создания, поиска и копирования.
- [ ] Apple and Authenticator migration preserve supported fields and generated codes using sanitized samples. / Миграция Apple и Authenticator сохраняет поддержанные поля и коды на обезличенных образцах.
- [ ] Available immutable dependencies and native APIs support the required platform behavior. / Доступные неизменяемые зависимости и нативные API обеспечивают требуемое поведение платформ.
- [ ] Bounded integration actions provide useful automation without returning stored credentials to MCP clients. / Ограниченные действия интеграций обеспечивают полезную автоматизацию без возврата сохранённых credentials MCP-клиентам.

## MVP Scope

macOS: local encrypted vault, master password, recovery kit, optional biometrics and external-TOTP operation policy; groups, environment, built-in/custom cards, 365-day history, Apple password CSV and Authenticator QR import, encrypted backup, search widget and create hotkey.

macOS: локальный зашифрованный сейф, мастер-пароль, recovery kit, необязательные биометрия и внешний TOTP для операций; группы, окружение, встроенные/кастомные карточки, история за 365 дней, Apple CSV и Authenticator QR, зашифрованный backup, виджет и хоткей создания.

## Not Doing

Team ownership, roles, billing, cloud-only access and arbitrary MCP command execution are outside the agreed product scope. Browser/terminal integrations, sync, other platforms and passkey providers follow the first local release. This documentation delivery implements none of those application features.

Командное владение, роли, биллинг, обязательный облачный доступ и произвольные команды MCP вне согласованного объёма. Браузер/терминал, sync, другие платформы и passkey providers следуют после первого локального релиза. Текущая поставка документации не реализует эти функции приложения.

## Open Questions

Implementation research must verify a released Flutter UI kit, cryptographic format, Arc migration, Windows/Linux passkey APIs and native transport/store constraints. These are explicit prerequisites in the backlog, not unsettled product preferences.

Исследования реализации проверяют выпущенный Flutter UI kit, криптографический формат, миграцию Arc, passkey API Windows/Linux и ограничения транспорта/сторов. Это явные предпосылки backlog, а не незафиксированные продуктовые предпочтения.
