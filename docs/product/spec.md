## Problem Statement

Developers need to organize passwords, OTP and common developer credentials by project, company and environment. Splitting those values across password managers, authenticator apps and tool configuration makes daily retrieval and maintenance inconvenient. The product must make those workflows clear while keeping local access independent of a service.

Разработчикам нужно организовать пароли, OTP и распространённые credentials по проектам, компаниям и окружениям. Разнесение значений между менеджерами паролей, authenticator-приложениями и конфигами усложняет ежедневный доступ и обслуживание. Продукт должен сделать эти сценарии понятными и сохранить независимую от сервиса локальную работу.

## Solution

Build a personal encrypted local vault with typed cards, overlapping groups, optional environments and a macOS search widget first. Add verified imports and recovery, followed by cross-device encrypted sync, platform credential providers, browser autofill and authorized developer integrations. Local MCP performs bounded operations without returning stored credential values.

Сначала создать личный зашифрованный локальный сейф с типизированными карточками, пересекающимися группами, необязательными окружениями и macOS-виджетом. Добавить проверенный импорт и recovery, затем сквозную синхронизацию, провайдеры платформ, браузерное автозаполнение и разрешённые интеграции разработчика. Локальный MCP выполняет ограниченные операции без возврата сохранённых credentials.

## User Stories

1. As a project maintainer, I want to run a reproducible client and backend foundation with clear application boundaries, so that I can start from a reproducible supported stack.
   Как сопровождающий проект, я хочу запускать воспроизводимый фундамент клиента и backend с понятными границами приложения, чтобы начать с воспроизводимого поддержанного стека.

2. As a vault owner, I want to create, lock, reopen and recover an encrypted vault without registration, so that I can retain access without a service.
   Как владелец сейфа, я хочу создавать, блокировать, повторно открывать и восстанавливать зашифрованный сейф без регистрации, чтобы сохранить доступ без сервиса.

3. As a vault owner, I want to organize secrets by company, project or purpose using groups, so that I can separate project and company credentials.
   Как владелец сейфа, я хочу распределять секреты по компаниям, проектам и назначению с помощью групп, чтобы разделять credentials проектов и компаний.

4. As a vault owner, I want to create, edit and remove account cards with explicit service, groups and environment, so that I can choose the correct account and environment.
   Как владелец сейфа, я хочу создавать, изменять и удалять карточки учётных записей с явными сервисом, группами и окружением, чтобы выбирать верные аккаунт и окружение.

5. As a vault owner, I want to keep TOTP, recovery codes and reserve logins alongside account credentials, so that I can sign in and recover accounts in one place.
   Как владелец сейфа, я хочу хранить TOTP, recovery-коды и резервные логины вместе с учётной записью, чтобы входить и восстанавливать аккаунты в одном месте.

6. As a vault owner, I want to store common developer credentials in suitable structured cards, so that I can preserve each credential kind accurately.
   Как владелец сейфа, я хочу хранить распространённые credentials разработчика в подходящих структурированных карточках, чтобы точно сохранять каждый вид credentials.

7. As a vault owner, I want to add a custom service beside the built-in service catalog, so that I can organize internal and self-hosted services.
   Как владелец сейфа, я хочу добавлять собственный сервис рядом со встроенным каталогом, чтобы организовать внутренние и собственные сервисы.

8. As a vault owner, I want to define custom card types using typed fields and explicitly update existing cards, so that I can capture uncommon credentials without losing fields.
   Как владелец сейфа, я хочу определять собственные типы карточек из типизированных полей и явно обновлять существующие карточки, чтобы сохранять нестандартные credentials без потери полей.

9. As a vault owner, I want to associate one card with several explicit resources and integration methods, so that I can reuse credentials at explicit destinations.
   Как владелец сейфа, я хочу связывать одну карточку с несколькими явными ресурсами и способами интеграции, чтобы использовать credentials в явных назначениях.

10. As a vault owner, I want to inspect and restore prior secret versions from a rolling 365-day history, so that I can recover from unwanted edits.
   Как владелец сейфа, я хочу просматривать и восстанавливать предыдущие версии за последние 365 дней, чтобы восстанавливаться после нежелательных изменений.

11. As a vault owner, I want to choose which sensitive operations require a fresh external TOTP code, so that I can confirm sensitive actions separately.
   Как владелец сейфа, я хочу выбирать чувствительные операции, требующие свежий код внешнего TOTP, чтобы отдельно подтверждать чувствительные действия.

12. As a vault owner, I want to unlock a configured macOS device with available biometrics, so that I can unlock conveniently on a configured device.
   Как владелец сейфа, я хочу разблокировать настроенное macOS-устройство доступной биометрией, чтобы удобно разблокировать настроенное устройство.

13. As a vault owner, I want to open a search widget near the cursor and use the five most relevant secrets, so that I can retrieve the right value quickly.
   Как владелец сейфа, я хочу открывать поиск рядом с курсором и использовать пять наиболее подходящих секретов, чтобы быстро получать нужное значение.

14. As a vault owner, I want to open the new-secret form directly from a configurable global hotkey, so that I can save a new secret without navigating menus.
   Как владелец сейфа, я хочу открывать создание секрета отдельным настраиваемым глобальным хоткеем, чтобы сохранять новый секрет без поиска меню.

15. As a vault owner, I want to move Google Authenticator codes into the vault with a preview, so that I can stop switching authenticator apps.
   Как владелец сейфа, я хочу переносить коды Google Authenticator в сейф с предварительным просмотром, чтобы перестать переключаться между authenticator-приложениями.

16. As a vault owner, I want to import officially exported Apple passwords with a preview and duplicate handling, so that I can migrate existing Apple passwords.
   Как владелец сейфа, я хочу импортировать официально экспортированные пароли Apple с предпросмотром и обработкой дублей, чтобы перенести существующие пароли Apple.

17. As a vault owner, I want to export and restore a portable encrypted backup of the vault, so that I can recover independently from data loss.
   Как владелец сейфа, я хочу экспортировать и восстанавливать переносимую зашифрованную копию сейфа, чтобы независимо восстановиться после потери данных.

18. As a vault owner, I want to install and use the first complete local macOS release, so that I can use a verified daily workflow.
   Как владелец сейфа, я хочу устанавливать и использовать первый законченный локальный релиз macOS, чтобы использовать проверенный ежедневный сценарий.

19. As a developer, I want to authorize local tools through the same operations and policies as the application, so that I can connect tools under explicit policy.
   Как разработчик, я хочу авторизовывать локальные инструменты через те же операции и политики, что использует приложение, чтобы подключать инструменты по явной политике.

20. As a vault owner, I want to import passwords from a verified Chrome export, so that I can migrate saved Chrome accounts.
   Как владелец сейфа, я хочу импортировать пароли из проверенного экспорта Chrome, чтобы перенести аккаунты Chrome.

21. As a vault owner, I want to import passwords from a verified Firefox export, so that I can migrate saved Firefox accounts.
   Как владелец сейфа, я хочу импортировать пароли из проверенного экспорта Firefox, чтобы перенести аккаунты Firefox.

22. As a vault owner, I want to import passwords from a verified Opera export, so that I can migrate saved Opera accounts.
   Как владелец сейфа, я хочу импортировать пароли из проверенного экспорта Opera, чтобы перенести аккаунты Opera.

23. As a vault owner, I want to learn which verified route can move Arc credentials into Want Pass, so that I can avoid relying on an unverified export format.
   Как владелец сейфа, я хочу получить проверенный маршрут переноса credentials из Arc в Want Pass, чтобы не зависеть от непроверенного формата экспорта.

24. As a vault owner, I want to opt into an email and external-passkey account backed by the Rust service, so that I can keep an encrypted remote copy.
   Как владелец сейфа, я хочу подключать необязательный аккаунт с email и внешним passkey на Rust-сервисе, чтобы иметь зашифрованную удалённую копию.

25. As a vault owner, I want to enroll a new device with a trusted device or recovery kit and revoke future access, so that I can control which devices gain future access.
   Как владелец сейфа, я хочу подключать новое устройство через доверенное устройство или recovery kit и отзывать будущий доступ, чтобы контролировать будущий доступ устройств.

26. As a vault owner, I want to synchronize edits without silently losing conflicting or deleted data, so that I can preserve edits made while offline.
   Как владелец сейфа, я хочу синхронизировать изменения без незаметной потери конфликтующих или удалённых данных, чтобы сохранять изменения, сделанные без сети.

27. As a vault owner, I want to deploy and operate a personal Rust sync service instead of the hosted service, so that I can choose my own service operator.
   Как владелец сейфа, я хочу разворачивать и эксплуатировать собственный Rust-сервис вместо общего сервиса, чтобы выбирать собственного оператора сервиса.

28. As a vault owner, I want to install and use the desktop vault, widget and hotkeys on Windows, so that I can use the same vault on Windows.
   Как владелец сейфа, я хочу устанавливать и использовать настольный сейф, виджет и хоткеи на Windows, чтобы использовать тот же сейф на Windows.

29. As a vault owner, I want to install and use the desktop vault, widget and hotkeys on Linux, so that I can use the same vault on Linux.
   Как владелец сейфа, я хочу устанавливать и использовать настольный сейф, виджет и хоткеи на Linux, чтобы использовать тот же сейф на Linux.

30. As a vault owner, I want to use the vault and supported system password/OTP autofill on Android, so that I can access credentials from an Android device.
   Как владелец сейфа, я хочу использовать сейф и поддержанное системное автозаполнение паролей и OTP на Android, чтобы получать credentials с Android-устройства.

31. As a vault owner, I want to use the vault and supported system password/OTP autofill on iOS, so that I can access credentials from an iOS device.
   Как владелец сейфа, я хочу использовать сейф и поддержанное системное автозаполнение паролей и OTP на iOS, чтобы получать credentials с iOS-устройства.

32. As a vault owner, I want to use Want Pass as a passkey provider through supported macOS interfaces, so that I can authenticate with passkeys held by Want Pass.
   Как владелец сейфа, я хочу использовать Want Pass как passkey provider через поддержанные интерфейсы macOS, чтобы входить с passkeys, хранимыми Want Pass.

33. As a vault owner, I want to create and use passkeys with the system credential provider on iOS, so that I can use passkeys in supported iOS flows.
   Как владелец сейфа, я хочу создавать и использовать passkeys через системный credential provider на iOS, чтобы использовать passkeys в поддержанных сценариях iOS.

34. As a vault owner, I want to create and use passkeys with the system credential provider on Android, so that I can use passkeys in supported Android flows.
   Как владелец сейфа, я хочу создавать и использовать passkeys через системный credential provider на Android, чтобы использовать passkeys в поддержанных сценариях Android.

35. As a vault owner, I want to understand the verified passkey-provider route and limitations on Windows, so that I can know the actual Windows support boundary.
   Как владелец сейфа, я хочу получить проверенный маршрут passkey provider и его ограничения на Windows, чтобы знать реальные границы поддержки Windows.

36. As a vault owner, I want to understand the verified passkey-provider route and limitations on Linux, so that I can know the actual Linux support boundary.
   Как владелец сейфа, я хочу получить проверенный маршрут passkey provider и его ограничения на Linux, чтобы знать реальные границы поддержки Linux.

37. As a vault owner, I want to move supported credentials through the Apple system exchange flow, so that I can move supported Apple credentials safely.
   Как владелец сейфа, я хочу переносить поддержанные credentials через системный обмен Apple, чтобы безопасно переносить поддержанные credentials Apple.

38. As a vault owner, I want to move supported credentials through the Android system exchange flow, so that I can move supported Android credentials safely.
   Как владелец сейфа, я хочу переносить поддержанные credentials через системный обмен Android, чтобы безопасно переносить поддержанные credentials Android.

39. As a vault owner, I want to select matching credentials and fill supported fields in Chromium browsers, so that I can fill matching web forms without manual copying.
   Как владелец сейфа, я хочу выбирать подходящие credentials и заполнять поддержанные поля в Chromium-браузерах, чтобы заполнять подходящие веб-формы без ручного копирования.

40. As a vault owner, I want to use the shared autofill behavior in Firefox through its supported extension interfaces, so that I can use the same verified behavior in Firefox.
   Как владелец сейфа, я хочу использовать общее автозаполнение в Firefox через поддержанные интерфейсы расширения, чтобы использовать то же проверенное поведение в Firefox.

41. As a vault owner, I want to use verified Safari autofill flows on macOS and iOS, so that I can use the same verified behavior in Safari.
   Как владелец сейфа, я хочу использовать проверенное автозаполнение Safari на macOS и iOS, чтобы использовать то же проверенное поведение в Safari.

42. As a vault owner, I want to send selected current secret fields as a protected copy through AirDrop, so that I can give a recipient an independent protected copy.
   Как владелец сейфа, я хочу передавать выбранные текущие поля секрета защищённой копией через AirDrop, чтобы передавать получателю независимую защищённую копию.

43. As a vault owner, I want to transfer a protected secret copy between a verified macOS and Android pair, so that I can transfer supported copies without a cloud service.
   Как владелец сейфа, я хочу передавать защищённую копию секрета между проверенной парой macOS и Android, чтобы передавать поддержанные копии без облачного сервиса.

44. As a developer, I want to manage netrc credentials, so that I can maintain selected netrc entries safely.
   Как разработчик, я хочу управлять credentials netrc, чтобы безопасно обслуживать выбранные записи netrc.

45. As a developer, I want to manage SSH keys and profiles, so that I can connect with the correct SSH identity.
   Как разработчик, я хочу управлять SSH-ключами и профилями, чтобы подключаться с верной SSH-идентичностью.

46. As a developer, I want to manage buf profiles and credentials, so that I can maintain buf registry access.
   Как разработчик, я хочу управлять профилями и credentials buf, чтобы обслуживать доступ к buf registry.

47. As a developer, I want to manage npm profiles and credentials, so that I can maintain npm registry access.
   Как разработчик, я хочу управлять профилями и credentials npm, чтобы обслуживать доступ к npm registry.

48. As a developer, I want to manage gh/GitHub profiles and credentials, so that I can maintain GitHub access and token lifecycle.
   Как разработчик, я хочу управлять профилями и credentials gh/GitHub, чтобы обслуживать доступ GitHub и жизненный цикл токенов.

49. As a developer, I want to manage glab/GitLab profiles and credentials, so that I can maintain GitLab host access.
   Как разработчик, я хочу управлять профилями и credentials glab/GitLab, чтобы обслуживать доступ к хостам GitLab.

50. As a developer, I want to manage Firebase profiles and credentials, so that I can maintain Firebase project access.
   Как разработчик, я хочу управлять профилями и credentials Firebase, чтобы обслуживать доступ к проектам Firebase.

51. As a developer, I want to manage Cloudflare Access profiles and credentials, so that I can maintain Cloudflare Access sessions.
   Как разработчик, я хочу управлять профилями и credentials Cloudflare Access, чтобы обслуживать сессии Cloudflare Access.

52. As a developer, I want to add, edit and disconnect MCP server profiles in supported local clients, so that I can configure tools without plaintext credentials in configs.
   Как разработчик, я хочу добавлять, изменять и отключать профили MCP-серверов в поддержанных локальных клиентах, чтобы настраивать инструменты без открытых credentials в конфигах.

53. As a developer, I want to search metadata, save credentials with confirmation and request bounded actions from local MCP clients, so that I can automate permitted work without retrieving credentials.
   Как разработчик, я хочу искать метаданные, сохранять credentials с подтверждением и запрашивать ограниченные действия из локальных MCP-клиентов, чтобы автоматизировать разрешённую работу без получения credentials.

54. As a developer, I want to install portable instructions for safe Want Pass MCP use in supported clients, so that I can install consistent safe usage instructions.
   Как разработчик, я хочу устанавливать переносимые инструкции безопасной работы с Want Pass MCP в поддержанных клиентах, чтобы устанавливать согласованные безопасные инструкции.

55. As a developer, I want to know which local clients can safely use the supported Want Pass MCP operations, so that I can choose a client with verified compatibility.
   Как разработчик, я хочу знать, какие локальные клиенты безопасно используют поддержанные операции Want Pass MCP, чтобы выбирать клиент с проверенной совместимостью.

56. As a developer, I want to use Want Pass in Warp through supported MCP and CLI workflows, so that I can use credentials in supported Warp workflows.
   Как разработчик, я хочу использовать Want Pass в Warp через поддержанные MCP и CLI workflows, чтобы использовать credentials в поддержанных сценариях Warp.

57. As a vault owner, I want to search and request authorized Want Pass actions from Raycast on declared platforms, so that I can request actions from a native launcher.
   Как владелец сейфа, я хочу искать и запрашивать разрешённые действия Want Pass из Raycast на заявленных платформах, чтобы запрашивать действия из нативного launcher.

58. As a vault owner, I want to install an accepted Want Pass release through Mac App Store, so that I can install through Mac App Store.
   Как владелец сейфа, я хочу устанавливать принятый релиз Want Pass через Mac App Store, чтобы устанавливать через Mac App Store.

59. As a vault owner, I want to install an accepted Want Pass release through iOS App Store, so that I can install through iOS App Store.
   Как владелец сейфа, я хочу устанавливать принятый релиз Want Pass через iOS App Store, чтобы устанавливать через iOS App Store.

60. As a vault owner, I want to install an accepted Want Pass release through Google Play, so that I can install through Google Play.
   Как владелец сейфа, я хочу устанавливать принятый релиз Want Pass через Google Play, чтобы устанавливать через Google Play.

61. As a vault owner, I want to install an accepted Want Pass release through Microsoft Store, so that I can install through Microsoft Store.
   Как владелец сейфа, я хочу устанавливать принятый релиз Want Pass через Microsoft Store, чтобы устанавливать через Microsoft Store.

62. As a vault owner, I want to install an accepted Want Pass release through Flathub, so that I can install through Flathub.
   Как владелец сейфа, я хочу устанавливать принятый релиз Want Pass через Flathub, чтобы устанавливать через Flathub.

63. As a vault owner, I want to install an accepted Want Pass release through RuStore, so that I can install through RuStore.
   Как владелец сейфа, я хочу устанавливать принятый релиз Want Pass через RuStore, чтобы устанавливать через RuStore.

64. As a vault owner, I want to install an accepted Want Pass release through Huawei AppGallery, so that I can install through Huawei AppGallery.
   Как владелец сейфа, я хочу устанавливать принятый релиз Want Pass через Huawei AppGallery, чтобы устанавливать через Huawei AppGallery.

65. As a vault owner, I want to install an accepted Want Pass release through Samsung Galaxy Store, so that I can install through Samsung Galaxy Store.
   Как владелец сейфа, я хочу устанавливать принятый релиз Want Pass через Samsung Galaxy Store, чтобы устанавливать через Samsung Galaxy Store.

66. As a vault owner, I want to install an accepted Want Pass release through Snap Store, so that I can install through Snap Store.
   Как владелец сейфа, я хочу устанавливать принятый релиз Want Pass через Snap Store, чтобы устанавливать через Snap Store.

67. As a vault owner, I want to install an accepted Want Pass release through Homebrew, so that I can install through Homebrew.
   Как владелец сейфа, я хочу устанавливать принятый релиз Want Pass через Homebrew, чтобы устанавливать через Homebrew.

68. As a vault owner, I want to install an accepted Want Pass release through WinGet, so that I can install through WinGet.
   Как владелец сейфа, я хочу устанавливать принятый релиз Want Pass через WinGet, чтобы устанавливать через WinGet.

69. As a vault owner, I want to find the correct native installer or official store from the Want Pass website, so that I can choose an available release for my OS.
   Как владелец сейфа, я хочу находить подходящий нативный установщик или официальный магазин на сайте Want Pass, чтобы выбирать доступный релиз для своей ОС.

70. As a vault owner, I want to receive verifiable update information through the correct installation channel, so that I can upgrade through a verified channel.
   Как владелец сейфа, я хочу получать проверяемую информацию об обновлениях через правильный канал установки, чтобы обновляться через проверенный канал.

71. As a project maintainer, I want to publish and upgrade to the next immutable version across the accepted release channels, so that I can ship a new version without losing user vaults.
   Как сопровождающий проект, я хочу публиковать следующую неизменяемую версию и обновляться через принятые каналы, чтобы выпускать новую версию без потери сейфов пользователей.

## Implementation Decisions

- Flutter uses want_allure, domain_error, package_context, launch_mode and talker_bloc_effects; Rust serves the backend. observatory is excluded. Verify an immutable released UI kit before bootstrap; do not modify adjacent repositories in this delivery. / Flutter использует want_allure, domain_error, package_context, launch_mode и talker_bloc_effects; backend пишется на Rust. observatory исключён. До старта проверяется выпущенный неизменяемый UI kit; соседние репозитории в этой поставке не меняются.
- Client application operations own policies, validation, storage and integrations outside widgets. A common public operation boundary is the primary behavioral test seam; native adapters have separate smoke checks. / Операции клиента владеют политиками, валидацией, хранением и интеграциями вне виджетов. Общая граница операций является основным интерфейсом проверки поведения; нативные адаптеры имеют отдельные smoke-проверки.
- Local use needs no registration or backend. The first release is macOS with vault, widget and imports; other platforms and integrations follow in the roadmap. / Локальная работа не требует регистрации и backend. Первый релиз macOS включает сейф, виджет и импорт; остальные платформы и интеграции следуют по roadmap.
- One account card holds login/email, password, optional TOTP, recovery codes and reserve login/email. PAT and key pairs are separate cards; cards have names and descriptions, one service, zero or more groups and multiple destination bindings. / Карточка аккаунта содержит логин/email, пароль, необязательные TOTP, recovery-коды и резервный логин/email. PAT и пары ключей отдельные; у карточки есть имя, описание, один сервис, ноль или несколько групп и несколько назначений.
- Groups have name, logo and description and provide organization rather than independent keys. Removing a group preserves cards. Optional environment values are local, unit-tests, integration-tests, e2e-tests, development, stand, feature, stage, pre-release and production. / Группы имеют название, логотип и описание и организуют данные, а не задают отдельные ключи. Удаление группы сохраняет карточки. Необязательные окружения: local, unit-tests, integration-tests, e2e-tests, development, stand, feature, stage, pre-release, production.
- The service catalog includes Microsoft, Google, Apple, GitHub, GitLab, Atlassian, Jira, Confluence and Telegram; proposed additions include AWS, Azure, GCP, Cloudflare, Docker/GHCR, npm, PyPI, crates.io, Firebase, Supabase and Sentry. Custom services remain available. / Каталог включает Microsoft, Google, Apple, GitHub, GitLab, Atlassian, Jira, Confluence и Telegram; дополнительно предложены AWS, Azure, GCP, Cloudflare, Docker/GHCR, npm, PyPI, crates.io, Firebase, Supabase и Sentry. Доступны собственные сервисы.
- Type presets cover accounts, PAT, RSA/Ed25519 keys, secret keys, passphrases, recovery codes/URLs, secret Q/A, VLESS and WireGuard; additions cover GPG, certificates/private keys, OAuth credentials, DSN, kubeconfig, webhook secrets, notes and files. Passkeys require a real supported provider, not a decorative card. / Типы охватывают аккаунты, PAT, RSA/Ed25519, secret key, passphrase, recovery-коды/URL, secret Q/A, VLESS и WireGuard; дополнения включают GPG, сертификаты/закрытые ключи, OAuth credentials, DSN, kubeconfig, webhook secrets, заметки и файлы. Passkeys требуют настоящего поддержанного провайдера, а не декоративной карточки.
- Custom types use named required/optional fields of safe kinds: text, concealed value, URL, OTP, code list and file. Template edits create versions and require explicit reviewed application to existing cards. History retains prior structure. / Свои типы используют именованные обязательные/необязательные поля безопасных видов: текст, скрытое значение, URL, OTP, список кодов и файл. Изменения шаблона версионируются и применяются к существующим карточкам явно после просмотра. История сохраняет прежнюю структуру.
- A target is where credentials are used; a binding selects applicable fields and method. Examples include HTTPS apps, REST APIs, SSH hosts, Git repositories, registries, databases and Kubernetes contexts. AWS CLI, netrc and mTLS are integration channels or methods, not equivalent destination identifiers. / Назначение определяет, где используются credentials; привязка выбирает поля и метод. Примеры: HTTPS-приложения, REST API, SSH-хосты, Git-репозитории, registries, базы данных и Kubernetes-контексты. AWS CLI, netrc и mTLS являются каналами или методами, а не равноценными идентификаторами назначения.
- Encrypt all user content and metadata at rest, including names, groups, env, history and attachments. Keep values out of logs, errors, telemetry and examples. Key formats, primitives and migration require review before real-secret use. / Все пользовательские содержимое и метаданные зашифрованы на диске, включая названия, группы, env, историю и вложения. Значения отсутствуют в логах, ошибках, telemetry и примерах. Форматы ключей, примитивы и миграция проверяются до реальных секретов.
- Master password is primary; a user-held recovery kit restores access, including resetting external-TOTP policy. Biometrics unlock a configured device through protected OS storage. External-passkey account authentication, hosted passkeys and possible external-passkey vault unlock are distinct. / Мастер-пароль основной; личный recovery kit восстанавливает доступ, включая сброс внешнего TOTP. Биометрия разблокирует настроенное устройство через защищённое хранилище ОС. Сетевой вход внешним passkey, хранимые passkeys и возможная разблокировка сейфа внешним passkey различаются.
- External TOTP enrollment is optional. The user chooses reveal/copy, export, transfer, integration permission, recovery, deletion and protection operations that require a fresh code. Enforce the policy at every application entry point; it does not claim an independent encryption factor for copied ciphertext. / Внешний TOTP необязателен. Пользователь выбирает операции просмотра/копирования, экспорта, передачи, разрешений, recovery, удаления и защиты, требующие свежего кода. Политика действует на каждой точке входа и не объявляется независимым фактором шифрования скопированного шифротекста.
- History is a rolling 365 days. Restore creates a new current revision; clearing removes managed history and converges through sync. Independent exported backups are outside that deletion action. / История охватывает последние 365 дней. Восстановление создаёт новую текущую версию; очистка удаляет управляемую историю и согласуется через sync. Независимые backup-файлы вне этого действия.
- Defaults: lock after five idle minutes and on OS lock/sleep; clear copied values after 30 seconds only while still owning that clipboard content. / Defaults: блокировка через пять минут бездействия и при блокировке/сне ОС; очистка через 30 секунд только при сохранённом владении содержимым буфера.
- A configurable search hotkey opens a focused topmost widget near the cursor; show at most five query/frequency/recency matches using local metadata only. A second hotkey opens creation. Copy all for accounts means login, password and current OTP; sensitive seeds, recovery codes and private keys use explicit separate actions. / Настраиваемый хоткей открывает виджет поверх окон рядом с курсором; максимум пять результатов по запросу, частоте и давности используют только локальные метаданные. Второй хоткей открывает создание. Всё для аккаунта означает логин, пароль и текущий OTP; seed, recovery-коды и закрытые ключи требуют отдельных действий.
- Import previews supported data and duplicates before mutation. Google Authenticator QR, password CSV and system Credential Exchange have separate contracts. Never infer Arc export support or passkey/OTP CSV coverage from another browser. / Импорт показывает поддержанные данные и дубли до записи. Google Authenticator QR, CSV паролей и системный Credential Exchange имеют разные контракты. Нельзя выводить поддержку Arc или passkeys/OTP в CSV из другого браузера.
- Optional sync uses email and an external passkey; decryption enrollment needs a trusted device or recovery kit. Support our service and self-hosting. Preserve both concurrent variants, resolve explicitly and prevent automatic resurrection after deletion. / Необязательная синхронизация использует email и внешний passkey; подключение расшифрования требует доверенное устройство или recovery kit. Поддерживаются наш сервис и self-hosted. Параллельные варианты сохраняются, разрешаются явно, удаления не возвращаются автоматически.
- Sharing sends a recipient-protected independent copy of selected current fields, without history or continuing access; already received copies cannot be revoked. / Передача отправляет защищённую для получателя независимую копию выбранных текущих полей без истории и будущего доступа; уже полученную копию нельзя отозвать.
- Tool integrations support explicit profiles and officially available issuance, refresh, rotation and revocation; unsupported steps remain visible. Preview config changes, preserve unknown content and reconcile ambiguous provider writes. / Интеграции поддерживают явные профили и официально доступные выпуск, обновление, ротацию и отзыв; неподдержанные шаги видны. Изменения конфигов просматриваются, постороннее содержимое сохраняется, неоднозначные записи провайдеров сверяются.
- Local MCP returns permitted metadata and bounded action results, not credential values. Confirm storage and use through the shared policy; forbid get-secret, arbitrary execution and arbitrary destinations. Third-party servers explicitly receiving credentials are trusted recipients outside our response guarantee. / Локальный MCP возвращает разрешённые метаданные и результаты ограниченных действий, а не credentials. Сохранение и использование подтверждаются общей политикой; get-secret, произвольные команды и назначения запрещены. Сторонние серверы, явно получающие credentials, являются доверенными получателями вне гарантии наших ответов.
- Distribute safe instructions through npx skills without embedded credentials. Check named local clients and transports independently; installing instructions does not grant access or silently register MCP. / Безопасные инструкции распространяются через npx skills без credentials. Клиенты и транспорты проверяются отдельно; установка инструкций не выдаёт доступ и не регистрирует MCP незаметно.
- Warp uses confirmed MCP and workflows; Raycast uses an authorized installed local component with no direct Keychain access or decrypted-output caching. / Warp использует подтверждённые MCP и workflows; Raycast использует разрешённый установленный локальный компонент без прямого Keychain и кэширования расшифрованных ответов.
- Maintain a capability matrix for macOS, Windows, Linux, Android, iOS and target browsers. Direct and store builds may differ. Release to Mac App Store, iOS App Store, Google Play, Microsoft Store, Flathub, RuStore, AppGallery, Galaxy Store, Snap, Homebrew and WinGet through actual accepted channel checks. / Вести матрицу macOS, Windows, Linux, Android, iOS и браузеров. Прямые и магазинные сборки могут отличаться. Каналы Mac App Store, iOS App Store, Google Play, Microsoft Store, Flathub, RuStore, AppGallery, Galaxy Store, Snap, Homebrew и WinGet подтверждаются реальными принятыми публикациями.
- The web want-allure landing page suggests an OS but preserves platform choice. Direct updates verify artifacts; store versions use supported store updates. Released tags and artifacts remain immutable; repeat publication uses a new version. / Лендинг web want-allure предлагает ОС и сохраняет выбор платформ. Прямые обновления проверяют артефакты; магазинные используют поддержанные обновления магазина. Выпущенные теги и артефакты неизменяемы; повторная публикация использует новую версию.

## Testing Decisions

Use observable application operations as the main behavioral seam. There is no existing application test suite in the initial repository. Verify create/unlock/reopen, edits, group removal, type migration, restore, import preview, duplicate decisions and policy-denied operations through that shared boundary rather than widget implementation details.

Поведение проверяется через наблюдаемую границу операций приложения. В исходном репозитории нет тестов приложения. Создание, разблокировка, повторное открытие, изменения, удаление групп, миграция типов, восстановление, предпросмотр импорта, выбор дублей и отказы политик проверяются через общую границу вместо деталей виджетов.

Cryptographic and OTP implementations additionally need established vectors, wrong-key/tamper checks, nonce/key lifecycle review and interrupted-write/recovery tests. A copied encrypted vault, an untrusted sync service and a locked local interface are distinct threat cases; compromise of a running authorized OS is not promised to be solved by OTP or an instruction package.

Криптография и OTP дополнительно требуют стандартные векторы, проверки неверного ключа и подмены, проверку жизненного цикла nonce/ключей и прерванной записи/recovery. Скопированный зашифрованный сейф, недоверенный sync-сервис и закрытый локальный интерфейс являются разными угрозами; компрометация работающей авторизованной ОС не объявляется решённой OTP или пакетом инструкций.

Native smoke checks cover real permissions, biometrics, lock/sleep, clipboard ownership, hotkey conflicts, display edges, browser origin handling and credential-provider flows. Record simulated tests, installed runtime, physical-device checks, CI and accepted external publication separately. Import fixtures must be synthetic or sanitized and identify their supported source versions.

Нативные smoke-проверки охватывают реальные разрешения, биометрию, блокировку/сон, владение буфером, конфликты хоткеев, края экранов, browser origin и credential-provider сценарии. Моделирование, установленный runtime, физические устройства, CI и принятая внешняя публикация указываются отдельно. Образцы импорта являются синтетическими или обезличенными и обозначают версии источников.

## Out of Scope

This delivery publishes documentation and backlog only. It does not implement application code, install dependencies, change adjacent repositories, deploy services or publish store builds. Team ownership/roles, billing, required online use, remote/cloud MCP access, arbitrary MCP commands and revocable live sharing are outside the agreed scope.

Текущая поставка публикует только документацию и backlog. Она не реализует код, не устанавливает зависимости, не меняет соседние репозитории, не развёртывает сервисы и не публикует сборки в сторах. Командное владение/роли, биллинг, обязательная сеть, удалённый/облачный MCP, произвольные команды MCP и отзыв общего обновляемого секрета вне согласованного объёма.

## Further Notes

Implementation begins with an accessible immutable Flutter UI kit and a reviewed cryptographic design. Arc migration and Windows/Linux passkey-provider APIs require evidence before support claims. The first-release gate covers the complete local macOS workflow; research conclusions are not substituted for implemented provider support.

Реализация начинается с доступного неизменяемого Flutter UI kit и проверенного криптографического проекта. Миграция Arc и passkey-provider API Windows/Linux требуют доказательств до заявлений о поддержке. Первый релиз принимает законченный локальный macOS-сценарий; результаты исследования не подменяют реализованного провайдера.

Primary references / Первичные источники:

- [Google Authenticator transfer](https://support.google.com/accounts/answer/1066447?hl=en): QR transfer is separate from provisioning URIs. / QR-перенос отличается от provisioning URI.
- [Apple password CSV](https://support.apple.com/en-om/guide/passwords/mchl35b12625/mac) and [Apple Credential Exchange](https://developer.apple.com/videos/play/wwdc2025/279/): distinct migration routes. / Разные маршруты переноса.
- [WebAuthn PRF](https://github.com/w3c/webauthn/blob/main/explainers/prf-extension.md): key derivation is a separate capability from authentication. / Получение ключа является отдельной возможностью от аутентификации.
- [RFC 6238](https://www.rfc-editor.org/rfc/rfc6238): TOTP behavior and vectors. / Поведение и векторы TOTP.
- [Warp MCP](https://docs.warp.dev/agents/capabilities/mcp/) and [workflows](https://docs.warp.dev/terminal/entry/yaml-workflows): supported integration surfaces. / Поддержанные интерфейсы интеграции.
- [Raycast Store guidelines](https://developers.raycast.com/basics/prepare-an-extension-for-store): extension publication constraints. / Ограничения публикации расширения.
- [Skills CLI](https://github.com/vercel-labs/skills): instruction distribution and client selection. / Распространение инструкций и выбор клиентов.
- [Apple review guidelines](https://developer.apple.com/app-store/review/guidelines/): sandbox and update-channel constraints. / Ограничения sandbox и канала обновлений.
