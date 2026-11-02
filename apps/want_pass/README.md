# Want Pass client / Клиент Want Pass

The development shell uses published Want Allure 1.0.0 and starts without a server. It shows the future vault entry point without accepting or storing credentials.

Оболочка разработки использует опубликованный Want Allure 1.0.0 и запускается без сервера. Она показывает будущую точку входа в сейф, не принимая и не сохраняя credentials.

Use the pinned SDK and commands from the [repository instructions](../../README.md#development-foundation--фундамент-разработки). Run `make run` at the repository root for macOS. Run `make generate` after changing DI annotations.

Используйте закреплённый SDK и команды из [инструкций репозитория](../../README.md#development-foundation--фундамент-разработки). Для macOS выполните `make run` в корне репозитория. После изменения аннотаций DI выполните `make generate`.

Presentation borrows a singleton startup controller. The controller calls a versioned use case, which consumes the internal Dart package's startup access service. Domain errors remain independent of Flutter. Package and application bootstrap reject conflicting configuration. DI awaits controller initialization; the composition root releases the controller and diagnostic handlers on a supported application exit request.

Представление использует singleton-контроллер запуска без передачи ему владения. Контроллер вызывает версионированный use case, использующий startup access service внутреннего Dart-пакета. Доменные ошибки независимы от Flutter. Bootstrap пакета и приложения отклоняет конфликтующую конфигурацию. DI ожидает инициализации контроллера; composition root освобождает контроллер и диагностические обработчики при поддержанном запросе выхода из приложения.

Diagnostics record allowlisted markers, layers and operations. Arbitrary states, effects, error objects and traces never reach the logging sink. Native permissions, vault storage and additional platforms follow their own tickets.

Диагностика записывает разрешённые маркеры, слои и операции. Произвольные состояния, эффекты, объекты ошибок и traces не передаются в логирование. Нативные разрешения, хранение сейфа и дополнительные платформы выполняются отдельными задачами.
