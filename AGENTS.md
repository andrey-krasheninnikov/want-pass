# Want Pass

## Project rules / Правила проекта

Read the glossary and relevant decisions before substantive changes. Preserve unrelated edits and inspect current state before changing it. Keep authorship neutral in content and metadata; never add work-provenance attribution or fabricate an author, co-author or signature. Product names are permitted when they describe the actual integration being discussed.

Перед существенными изменениями прочитайте словарь и относящиеся к задаче решения. Сохраняйте посторонние изменения и проверяйте текущее состояние до записи. Сохраняйте нейтральное авторство в тексте и метаданных; не добавляйте атрибуцию происхождения работы и не выдумывайте автора, соавтора или подпись. Названия продуктов допустимы при описании соответствующей интеграции.

The specification and 71-ticket roadmap define the implementation scope. Work through explicitly requested tracker tasks; application code, deployment and store publication remain separate tasks. Merge requires explicit authorization.

Спецификация и roadmap из 71 задачи определяют объём реализации. Выполняйте явно запрошенные задачи трекера; код приложения, развёртывание и публикация в сторах остаются отдельными задачами. Merge требует явного разрешения.

Use Flutter with want_allure, domain_error, package_context, launch_mode and talker_bloc_effects; use Rust for the backend. observatory is excluded. A released immutable Flutter UI kit is a bootstrap prerequisite. Keep authorization, validation, persistence and networking outside widgets. Never put real credentials into examples, diagnostics, fixtures or protocol errors.

Используйте Flutter с want_allure, domain_error, package_context, launch_mode и talker_bloc_effects; backend пишется на Rust. observatory исключён. Выпущенный неизменяемый Flutter UI kit является предпосылкой старта. Авторизация, валидация, хранение и сеть находятся вне виджетов. Реальные credentials не попадают в примеры, диагностику, тестовые данные и ошибки протокола.

Keep one bilingual EN/RU artifact for each document or issue. Maintain one shared status and numbering. Distinguish local checks, CI, installed runtime, physical devices and verified external state. Before each external write inspect current state; read back the result before continuing. Reconcile ambiguous writes before retrying. Do not wait for CI unless the task requires it.

Каждый документ или Issue является одним двуязычным EN/RU-материалом с общими статусом и нумерацией. Различайте локальные проверки, CI, установленный runtime, физические устройства и подтверждённое внешнее состояние. Перед внешней записью проверяйте состояние; после неё проверяйте результат. Неоднозначную запись сверяйте до повтора. Не ожидайте CI, если задача этого не требует.

## Flutter contracts / Контракты Flutter

Run verification locally on the MacBook. Do not add, trigger or use GitHub Actions for this project.

Проверки выполняются локально на MacBook. Не добавляйте, не запускайте и не используйте GitHub Actions для этого проекта.

For every Flutter application change, apply `$flutter-project-template`, `$flutter-domain-error`, `$flutter-domain-layer`, `$flutter-application-layer` and `$flutter-barrel-imports`. Read their installed `SKILL.md` files and the relevant normative references before changing code. These rules also cover internal Dart packages consumed by the application.

При каждом изменении Flutter-приложения применяйте `$flutter-project-template`, `$flutter-domain-error`, `$flutter-domain-layer`, `$flutter-application-layer` и `$flutter-barrel-imports`. До изменения кода прочитайте установленные `SKILL.md` и относящиеся к задаче нормативные контракты. Правило распространяется и на внутренние Dart-пакеты приложения.

The project explicitly uses `domain_error 5.0.3` instead of the skills' 3.x API. Preserve the error-flow, ownership, reporting and lifecycle requirements using `DomainResult<T>`, `FutureDomainResult<T>`, `Result.success/error`, `value/error` and the named capture callbacks. Do not introduce 3.x compatibility aliases, local substitutes or a silent downgrade.

Проект явно использует `domain_error 5.0.3` вместо API 3.x из навыков. Соблюдайте требования к обработке ошибок, владению, диагностике и lifecycle через `DomainResult<T>`, `FutureDomainResult<T>`, `Result.success/error`, `value/error` и именованные callbacks захвата. Не добавляйте совместимые псевдонимы 3.x, локальные подмены или скрытое понижение версии.

Register use cases and controllers as singletons through constructor injection. The composition root owns their lifecycle. Domain types are versioned; layer barrels contain exports only. Same-layer imports use the owning root layer barrel; cross-package imports use the public package entrypoint. DI registration is a standalone internal composition library exported by its own barrel; edit its inputs and regenerate it.

Регистрируйте use cases и контроллеры как singletons с constructor injection. Composition root владеет их lifecycle. Доменные типы версионируются; barrels слоёв содержат только exports. Внутри слоя импортируется его корневой barrel, между пакетами используется публичный entrypoint. Регистрация DI является отдельной внутренней библиотекой composition root и экспортируется его barrel; меняйте исходные аннотации и запускайте генерацию.

## Product UI and local security / Интерфейс и локальная безопасность

Use the released, pinned Want Allure package and its public components. Prefer Want inputs; when a required secret-input capability is absent, use Forui under WantTheme and track the missing shared component upstream. Secret fields disable autocorrection, suggestions, keyboard learning, smart substitutions and autofill unless explicitly required. Master-password fields are single-line and provide a labelled visibility toggle.

Используйте закреплённый выпущенный Want Allure и его публичные компоненты. Предпочитайте Want inputs; если нужной возможности секретного поля нет, используйте Forui под WantTheme и заведите задачу на общий компонент. Секретные поля отключают автокоррекцию, подсказки, обучение клавиатуры, умные подстановки и autofill, если они явно не нужны. Мастер-пароль вводится одной строкой; переключатель видимости имеет доступное название.

Import approved product artwork into versioned application assets. Preserve its geometry, proportions and colors. Apply product identity consistently to in-app artwork, native icons and startup screens; keep native identifiers consistent across host and test targets. Use semantic theme tokens and short task titles without repeated product names or redundant subtitles.

Переносите утверждённую графику продукта в assets приложения под контролем версий. Сохраняйте геометрию, пропорции и цвета. Применяйте идентичность продукта в интерфейсе, native icons и startup screens; согласуйте native identifiers приложения и тестовых targets. Используйте семантические токены темы и короткие заголовки действий без повторения продукта и лишних subtitle.

Multi-step setup uses visible progress, validated forward navigation and Back without regenerating recovery material. Presentation owns page and animation controllers; application scenarios own validation and persistence. Clear transient secret fields and overlays on lock, cancellation, completion and disposal. Decorative motion respects inactive-view suspension and reduced motion. An explicitly requested product flow may hide the pause control through the public released UI-kit API.

Многошаговая настройка показывает прогресс, проверяет переход вперёд и поддерживает возврат без повторной генерации материала восстановления. Presentation владеет контроллерами страниц и анимации; application-сценарии владеют валидацией и хранением. Очищайте временные секретные поля и overlays при блокировке, отмене, завершении и disposal. Декоративная анимация останавливается на неактивном экране и поддерживает reduced motion. По явному требованию продукта кнопку паузы можно скрыть через публичный API выпущенного UI-kit.

Prefer equal-width horizontal action rows, with responsive stacking when labels or text scaling need space. Keep keyboard focus, localized labels and targets of at least 44 logical pixels. Persist device appearance choices, offer them during first setup and keep compact theme/language controls accessible afterward.

Предпочитайте горизонтальные ряды кнопок равной ширины с переносом в колонку, когда подписям или увеличенному тексту нужно место. Сохраняйте клавиатурный фокус, локализованные подписи и цели минимум 44 logical pixels. Сохраняйте оформление устройства, предлагайте его при первой настройке и оставляйте компактные переключатели темы и языка доступными далее.

Rust remains authoritative for password policy, recovery confirmation, encryption and vault writes. Document format changes explicitly. Approved pre-unlock hints are bounded plaintext metadata authenticated with the encrypted file; explain that exception in the UI and keep hints out of diagnostics. Generate recovery QR locally; export only after an explicit action, use private file permissions and clear only an unchanged owned clipboard copy. Recheck session validity after asynchronous selection.

Rust остаётся источником правил пароля, подтверждения восстановления, шифрования и записи сейфа. Явно документируйте изменения формата. Согласованные подсказки до разблокировки являются ограниченными открытыми метаданными с аутентификацией в файле; объясняйте это исключение в UI и исключайте подсказки из диагностики. Создавайте recovery QR локально; экспортируйте только по явному действию, задавайте приватные права файла и очищайте только неизменённую собственную копию буфера. Повторно проверяйте актуальность сессии после асинхронного выбора.

Data-reset commands use a fixed current-application allowlist, ownership and symlink checks, and an exclusive vault lock. Validate all targets before deleting anything. Preserve old application namespaces, user exports and unknown files. Test reset logic only with disposable fixtures; never reset real data as part of verification.

Команды сброса данных используют фиксированный allowlist текущего приложения, проверку владельца и symlink, эксклюзивную блокировку сейфа. Проверяйте все цели до удаления. Сохраняйте старые namespaces приложения, пользовательские экспорты и неизвестные файлы. Проверяйте сброс только на временных fixtures; не сбрасывайте реальные данные при проверках.

## Agent skills

### Issue tracker

Specs and tickets live in GitHub Issues for andrey-krasheninnikov/want-pass.
Спецификации и задачи ведутся в GitHub Issues этого репозитория.
See / См. `docs/agents/issue-tracker.md`.

### Triage labels

Use the five canonical triage labels.
Используются пять согласованных triage-меток.
See / См. `docs/agents/triage-labels.md`.

### Domain docs

Single context: one bilingual glossary and shared ADRs.
Единый контекст: двуязычный словарь и общие ADR.
See / См. `docs/agents/domain.md`.

Setup progress uses equal full-width segments and an animated current/total counter. Separate hints from secret entry and require explicit storage acknowledgments. Back preserves recovery material; a failed word check replaces it natively and clears every phrase acknowledgment and answer. Every export channel uses identical numbered JSON. Invalid recovery input never advances. Use typed transient effects for confirmed feedback. The header padlock reflects confirmed access state and never owns access. Revision replacement and lock invalidate stale work and drain admitted exports before reporting completion. Close secret overlays when their revision ends.

Прогресс настройки использует равные сегменты на всю ширину и анимированный счётчик текущего шага. Отделяйте подсказки от ввода секрета и требуйте явного подтверждения сохранения. Возврат сохраняет материал восстановления; неверное слово заменяет его нативно и сбрасывает подтверждения фразы и ответы. Все способы экспорта используют одинаковый JSON с номерами слов. Некорректный ввод восстановления не позволяет продолжить. Подтверждённые уведомления передаются типизированными transient effects. Замок в header отражает подтверждённое состояние доступа и не управляет доступом. Смена revision и блокировка отменяют устаревшие операции и ожидают допущенные экспорты до сообщения о завершении. Закрывайте секретные overlays при окончании их revision.

Live password feedback uses a pure native policy check; it never derives keys, prepares recovery material or writes storage. Version stricter authentication contracts instead of changing legacy entrypoints. Discard stale checks after edits, dialog closure or session changes. Reveal login help only after the flow's explicit authentication-rejection threshold, and reveal a saved hint only on request. Keep validation copy in the field's accessible help; preserve visible operational errors. Decorative glow must not replace a focused control. Keep inactivity enforcement in the controller; render no access countdown. Reuse released effects, pause hidden/inactive surfaces and retain static accessibility fallbacks.

Обратная связь при вводе пароля использует чистую native-проверку политики без вычисления ключей, подготовки recovery и записи. Более строгая авторизация получает новую версию контракта; прежние entrypoints сохраняются. Отбрасывайте устаревшие проверки после изменения ввода, закрытия окна и смены сессии. Показывайте помощь входа только после заданного отказа авторизации, сохранённую подсказку открывайте по запросу. Текст валидации находится в доступной справке поля; системные ошибки остаются видимыми. Декоративное свечение не заменяет контрол с фокусом. Контроллер обеспечивает автоблокировку; отсчёт доступа в интерфейсе не показывается. Используйте выпущенные эффекты, останавливайте скрытые и неактивные поверхности, сохраняйте статичные accessibility-fallbacks.

Keep ambient logo glow subtle and static. Use a compact animated 3D padlock beside the logo, with warning/success state glow; disable decorative card hover contours while retaining keyboard focus. Secret-field postfix actions show only an icon, with transparent idle/hover/pressed surfaces and accessible targets. Live policy checks may enable positive feedback, but negative field styling starts only after submission and clears on edits. Show saved hints in a popover on request. Keep credentials rejection free of prose; render operational errors inside the active modal with an accessible announcement.

Свечение логотипа остаётся мягким и статичным. Рядом с логотипом используется компактный анимированный 3D-замок со свечением warning/success; декоративный контур карточек при наведении отключён, клавиатурный фокус сохраняется. Постфиксные действия секретного поля показывают только иконку с прозрачным фоном в обычном состоянии, при наведении и нажатии и с доступной областью нажатия. Live-проверка может включать положительную обратную связь, но красное состояние появляется только после отправки и сбрасывается при изменении ввода. Сохранённая подсказка открывается по запросу в popover. Отказ credentials не сопровождается текстом; системные ошибки выводятся внутри активного модального окна с доступным объявлением.

Vault browsing uses a full-width search/action toolbar and lazy group accordions. Search and filters execute natively while unlocked. Concealed values stay native until explicit disclosure; table projections expose only the primary login and current OTP. Treat search queries as secrets: disable keyboard learning and exclude them from diagnostics and persistence. Clear projections and discard stale reads on lock or revision change. Clipboard expiry and automatic locking remain independent of rendering. Do not show lock, unlock or copy toasts.

Просмотр сейфа использует строку поиска и действий на всю ширину и ленивые аккордеоны групп. Поиск и фильтры выполняются нативно в открытом сейфе. Скрытые значения остаются в native до явного раскрытия; таблица получает открытыми только основной логин и текущий OTP. Запрос поиска считается секретом: обучение клавиатуры отключено, запросы не попадают в диагностику и хранилище. При блокировке или смене revision очищайте проекции и отбрасывайте устаревшие чтения. Очистка буфера и автоблокировка не зависят от отрисовки. Тосты блокировки, разблокировки и копирования не показываются.

Interactive 3D controls rotate their actual mesh on drag without activating the control. Keep action and rotation gestures distinct, provide keyboard rotation, and use transparent hover surfaces while preserving visible keyboard focus.

Интерактивные 3D-контролы вращают саму модель при перетаскивании без активации действия. Разделяйте жесты действия и вращения, поддерживайте вращение с клавиатуры и прозрачный фон при наведении, сохраняя видимый клавиатурный фокус.
