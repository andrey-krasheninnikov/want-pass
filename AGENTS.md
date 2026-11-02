# Want Pass

## Project rules / Правила проекта

Read the glossary and relevant decisions before substantive changes. Preserve unrelated edits and inspect current state before changing it. Keep authorship neutral in content and metadata; never add work-provenance attribution or fabricate an author, co-author or signature. Product names are permitted when they describe the actual integration being discussed.

Перед существенными изменениями прочитайте словарь и относящиеся к задаче решения. Сохраняйте посторонние изменения и проверяйте текущее состояние до записи. Сохраняйте нейтральное авторство в тексте и метаданных; не добавляйте атрибуцию происхождения работы и не выдумывайте автора, соавтора или подпись. Названия продуктов допустимы при описании соответствующей интеграции.

The specification and 71-ticket roadmap define the implementation scope. Work through explicitly requested tracker tasks; application code, deployment and store publication remain separate tasks. Keep the documentation PR open for review. Merge requires explicit authorization.

Спецификация и roadmap из 71 задачи определяют объём реализации. Выполняйте явно запрошенные задачи трекера; код приложения, развёртывание и публикация в сторах остаются отдельными задачами. PR документации остаётся открытым для review. Merge требует явного разрешения.

Use Flutter with want_desyst, domain_error, package_context, launch_mode and talker_bloc_effects; use Rust for the backend. observatory is excluded. A released immutable Flutter UI kit is a bootstrap prerequisite. Keep authorization, validation, persistence and networking outside widgets. Never put real credentials into examples, diagnostics, fixtures or protocol errors.

Используйте Flutter с want_desyst, domain_error, package_context, launch_mode и talker_bloc_effects; backend пишется на Rust. observatory исключён. Выпущенный неизменяемый Flutter UI kit является предпосылкой старта. Авторизация, валидация, хранение и сеть находятся вне виджетов. Реальные credentials не попадают в примеры, диагностику, тестовые данные и ошибки протокола.

Keep one bilingual EN/RU artifact for each document or issue. Maintain one shared status and numbering. Distinguish local checks, CI, installed runtime, physical devices and verified external state. Before each external write inspect current state; read back the result before continuing. Reconcile ambiguous writes before retrying. Do not wait for CI unless the task requires it.

Каждый документ или Issue является одним двуязычным EN/RU-материалом с общими статусом и нумерацией. Различайте локальные проверки, CI, установленный runtime, физические устройства и подтверждённое внешнее состояние. Перед внешней записью проверяйте состояние; после неё проверяйте результат. Неоднозначную запись сверяйте до повтора. Не ожидайте CI, если задача этого не требует.

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
