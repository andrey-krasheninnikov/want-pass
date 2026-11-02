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

The first target is a local macOS vault and search widget. Flutter uses want_desyst, domain_error, package_context, launch_mode and talker_bloc_effects; the backend uses Rust. Later work covers Windows, Linux, Android, iOS, passkeys, encrypted sync, browser and developer-tool integrations.

Первая цель: локальный macOS-сейф и поисковый виджет. Flutter использует want_desyst, domain_error, package_context, launch_mode и talker_bloc_effects; backend использует Rust. Последующие этапы охватывают Windows, Linux, Android, iOS, passkeys, зашифрованную синхронизацию, браузеры и инструменты разработчика.
