# Want Pass client / Клиент Want Pass

The macOS client uses published Want Allure 1.2.1 and works without a server. It creates an encrypted local vault, confirms recovery words, locks, unlocks and rotates credentials through recovery. Cards and other platforms follow separate tickets.

Клиент macOS использует опубликованный Want Allure 1.2.1 и работает без сервера. Он создаёт локальный сейф с шифрованием, проверяет recovery-слова, блокирует и разблокирует доступ, меняет credentials через recovery. Карточки и другие платформы выполняются отдельными задачами.

Use the pinned SDK and commands from the [repository instructions](../../README.md#development-foundation--фундамент-разработки). `make run` starts macOS; `make check` runs local checks; `make native-ui` verifies creation, recovery and reopening with disposable data. Run `make generate` after changing DI annotations or the Rust bridge API.

Используйте закреплённый SDK и команды из [инструкций репозитория](../../README.md#development-foundation--фундамент-разработки). `make run` запускает macOS, `make check` выполняет локальные проверки, `make native-ui` проверяет создание, recovery и повторное открытие на временных данных. После изменения аннотаций DI или Rust bridge API выполните `make generate`.

Presentation borrows singleton controllers. Versioned use cases consume access services from the internal Dart package. The vault controller owns its opaque native resource, idle timer and lock-event subscription. The composition root awaits initialization and disposes resources on supported application exit requests. Widgets hold only transient form input.

Представление использует singleton-контроллеры без передачи владения. Версионированные use cases вызывают access services внутреннего Dart-пакета. Контроллер сейфа владеет opaque native-ресурсом, idle timer и подпиской на события блокировки. Composition root ожидает инициализации и освобождает ресурсы при поддержанном запросе выхода. Виджеты удерживают только временный ввод форм.

Diagnostics record fixed categories, layers and operations. Passwords, recovery words, arbitrary states, errors and traces never reach the logging sink. See [ADR 0006](../../docs/adr/0006-vault-format-and-native-key-lifecycle.md) for format, recovery, atomic writes and memory limits.

Диагностика записывает фиксированные категории, слои и операции. Пароли, recovery-слова, произвольные состояния, ошибки и traces не передаются в логирование. Формат, recovery, атомарная запись и ограничения памяти описаны в [ADR 0006](../../docs/adr/0006-vault-format-and-native-key-lifecycle.md).
