---
status: accepted
---

# Cards, groups and template versions / Карточки, группы и версии шаблонов

One card represents one credential set; an account card can include its password, TOTP and recovery data, while PAT and SSH key sets remain separate cards. Groups are overlapping organizational collections rather than cryptographic boundaries; environment is a separate optional property. Type changes are versioned and applied to existing cards explicitly, preserving older structures and history instead of silently mutating saved values.

Одна карточка представляет один набор credentials; карточка аккаунта может включать пароль, TOTP и recovery-данные, а PAT и наборы SSH-ключей остаются отдельными карточками. Группы являются пересекающимися организационными подборками, а не криптографическими границами; окружение задаётся отдельно. Изменения типов версионируются и применяются к существующим карточкам явно, сохраняя прежнюю структуру и историю вместо незаметного изменения значений.
