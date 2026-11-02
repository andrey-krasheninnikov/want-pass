# Want Pass client / Клиент Want Pass

This development shell uses the published Want UI kit and starts without a server. It shows the future vault entry point without accepting or storing credentials.

Оболочка разработки использует опубликованный Want UI kit и запускается без сервера. Она показывает будущую точку входа в сейф, не принимая и не сохраняя credentials.

Use the pinned SDK and commands from the [repository instructions](../../README.md#development-foundation--фундамент-разработки). Run `make run` at the repository root for macOS.

Используйте закреплённый SDK и команды из [инструкций репозитория](../../README.md#development-foundation--фундамент-разработки). Для macOS выполните `make run` в корне репозитория.

The presentation layer renders startup state; the controller calls application operations in the internal Dart package. Global diagnostics forward fixed markers and discard arbitrary error/effect payloads. Native permissions, vault storage and additional platforms follow their own tickets.

Слой представления показывает состояние запуска; контроллер вызывает операции внутреннего Dart-пакета. Глобальная диагностика передаёт фиксированные маркеры и отбрасывает произвольные данные ошибок/эффектов. Нативные разрешения, хранение сейфа и дополнительные платформы выполняются отдельными задачами.
