# Issue tracker

Use GitHub Issues in andrey-krasheninnikov/want-pass through gh.
Используйте GitHub Issues в andrey-krasheninnikov/want-pass через gh.

Publish each spec and ticket as one bilingual issue.
Каждая спецификация и задача публикуется одним двуязычным Issue.

Use native blocking dependencies and reference the parent spec.
Используйте нативные блокирующие зависимости и ссылку на спецификацию.

Keep the parent issue body and state unchanged when publishing tickets.
При публикации задач не изменяйте текст и статус родительской спецификации.

Read current state before writes and read back every result.
Перед записью проверяйте текущее состояние; после записи проверяйте результат.

PRs as a request surface: no.

## Commands / Команды

Use explicit repository selection. Pass multiline publication text with --body-file, and resolve ambiguous issue/PR numbers by reading the resource type. Use database issue IDs, not issue numbers, when adding native blockers. If native dependencies are unavailable, retain explicit blocker links and report that limitation.

Указывайте репозиторий явно. Передавайте многострочный текст через --body-file, а неоднозначные номера Issue/PR проверяйте чтением типа ресурса. Нативные блокеры используют database issue ID, а не номер задачи. При недоступности нативных зависимостей сохраняйте явные ссылки на блокеры и сообщайте об ограничении.

Read an issue with `gh issue view NUMBER --repo andrey-krasheninnikov/want-pass --comments`. Create a reviewed issue with `gh issue create --repo andrey-krasheninnikov/want-pass --title TITLE --body-file BODY_FILE`. Publish approved implementation/research tickets with the `ready-for-agent` label.

Читайте задачу командой `gh issue view NUMBER --repo andrey-krasheninnikov/want-pass --comments`. Создавайте проверенную задачу командой `gh issue create --repo andrey-krasheninnikov/want-pass --title TITLE --body-file BODY_FILE`. Согласованные задачи реализации и исследования получают метку `ready-for-agent`.
