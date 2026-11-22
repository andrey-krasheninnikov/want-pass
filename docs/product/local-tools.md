# Local CLI and SSH on macOS / Локальный CLI и SSH на macOS

**1. Connect / Подключение.** Unlock Want Pass and open Integrations. The signed helper lives inside the installed app at `/Applications/Want Pass.app/Contents/Helpers/wpass`. Run it by that path or add its directory to your shell's PATH. The development app bundles its own helper and uses its own container. Neither helper can address the other channel's vault.

Откройте сейф и раздел «Интеграции». Подписанный CLI установлен внутри приложения по пути `/Applications/Want Pass.app/Contents/Helpers/wpass`. Его можно вызвать по этому пути или добавить каталог в PATH. У версии для разработки собственный CLI и контейнер.

**2. Grant a scope / Выдача разрешения.** The app shows the binding IDs of web resources. Request a scope with `wpass authorize search BINDING` or `wpass authorize store BINDING`. The approval identifies the client, action, target, fields and environment. Search checks the named card and returns its name and service when the query matches. To save an account, pipe a JSON object with string fields `name`, `login` and `password` to `wpass store BINDING`. The app confirms each write. The response reports completion. Permissions can be revoked individually and expire when the vault locks.

В приложении видны идентификаторы веб-привязок. Запросите разрешение командой `wpass authorize search BINDING` или `wpass authorize store BINDING`. В окне подтверждения указаны клиент, действие, назначение, поля и окружение. Поиск проверяет имя одной выбранной карточки и при совпадении возвращает имя и сервис. Команда `wpass store BINDING` принимает через stdin JSON со строковыми полями `name`, `login`, `password`. Каждое сохранение подтверждается в приложении. Разрешение можно отозвать отдельно, блокировка сбрасывает все разрешения сессии.

**3. SSH profiles / SSH-профили.** Choose an existing Ed25519 card or create a new key pair. Enter the host, port, SSH user, environment and an Ed25519 **server public key** obtained from the host administrator. Want Pass checks the pinned host key when signing. The profile needs a binding that permits its public and private key fields. Narrowing that binding disables the profile. Creating a profile leaves the private key in the encrypted vault. Disconnecting preserves the key card and other bindings.

Выберите карточку Ed25519 или создайте новую пару ключей. Укажите имя узла, порт, пользователя SSH, окружение и **открытый ключ сервера** Ed25519, полученный у администратора. Перед подписью проверяется этот ключ. Привязка должна разрешать оба поля пары ключей. При сужении доступа профиль отключается. Закрытый ключ остаётся в зашифрованном сейфе. Отключение профиля сохраняет карточку ключа и остальные привязки.

| Action / Действие | Command / Команда |
| --- | --- |
| Authorize the CLI and system SSH together / Разрешить CLI и системный SSH одним решением | `wpass authorize ssh PROFILE` |
| Open an interactive session / Открыть интерактивную сессию | `wpass ssh PROFILE` |
| Explicitly export the public identity / Явно экспортировать открытый ключ | `wpass public-key PROFILE > identity.pub` |
| Preview and install an alias / Посмотреть изменения и установить псевдоним | `wpass alias install PROFILE` |
| Remove just the owned block, including after disconnect / Удалить свой блок, в том числе после отключения | `wpass alias remove PROFILE` |

The combined permission is labelled **wpass + /usr/bin/ssh**. Revoking it disables both clients together. The app asks for approval before each user authentication signature and applies configured external TOTP. `wpass ssh` runs the fixed system OpenSSH executable with the profile's target. It does not write `~/.ssh/config`. The ordinary alias is a separate opt-in. The helper shows the exact delta, waits for `yes`, validates file ownership and rejects symbolic links, hard links and changed content. It keeps the bytes outside its marked block. A manually edited block requires the owner to reconcile it before the helper can change it.

Общее разрешение обозначено **wpass + /usr/bin/ssh**. Отзыв закрывает доступ обоим клиентам. Перед каждой подписью для входа приложение запрашивает согласие и при настроенной защите — внешний код TOTP. Команда `wpass ssh` запускает системный OpenSSH с адресом выбранного профиля. Файл `~/.ssh/config` меняется только при отдельной установке или удалении псевдонима. Перед записью CLI показывает точные изменения и ждёт `yes`, сверяет владельца и текущее содержимое, отклоняет символьные и жёсткие ссылки. Байты за пределами своего блока сохраняются. Если блок был изменён вручную, CLI оставляет его владельцу.

**4. Local trust / Граница доверия.** The app listens on Unix domain sockets inside a user-owned directory with mode 0700 in its container. Sockets have mode 0600. Each peer must have the same effective UID. The macOS kernel supplies its audit token. Security.framework validates the running code, identifier, path and signed image against the helper bundled with the app or the system SSH binary. The helper verifies the server against its own containing app. Another process can still invoke the signed CLI as the same user. The signature identifies the immediate process, and does not identify the editor, terminal or script that started it. Store and SSH signing retain their own approval prompts. A process with control of the user's account, debugger or application files is outside this boundary. [Apple code signing services](https://developer.apple.com/documentation/security/code-signing-services)

Приложение принимает Unix-соединения в принадлежащем пользователю каталоге своего контейнера с правами 0700. У сокетов права 0600. Проверяются UID клиента, полученный от ядра audit token, подпись запущенного кода, идентификатор, путь и соответствие комплектному CLI или системному SSH. CLI проверяет подпись приложения в ответ. Любой процесс под тем же пользователем может вызвать подписанный CLI. Подпись подтверждает непосредственный процесс. Терминал, редактор или скрипт, который его запустил, остаётся неизвестен. Сохранение и SSH-подпись требуют собственного подтверждения. Захват учётной записи ОС, программы отладки или файлов приложения находится за этой границей.

SSH signing accepts a direct OpenSSH session binding with a valid key-exchange signature from the pinned server. It verifies the session, SSH username, service, authentication message, identity key and optional host-bound field. Forwarded sessions and arbitrary signing payloads are refused. Raw private keys, shells, user-supplied commands and arbitrary URL requests have no IPC operation. Device-specific profiles and session permissions are excluded from portable backups. [OpenSSH session binding](https://github.com/openssh/openssh-portable/blob/master/PROTOCOL.agent) · [SSH public-key authentication](https://www.rfc-editor.org/rfc/rfc4252#section-7)

При подписи проверяются привязка локальной сессии OpenSSH, подпись закреплённого сервера, идентификатор сессии, пользователь, сервис, тип сообщения, открытая часть ключа и поле host-bound при его наличии. Запросы от перенаправленных сессий и подпись произвольных данных отклоняются. В IPC отсутствуют операции выдачи закрытого ключа, произвольного shell, команды или URL. Профили устройства и разрешения сессии исключаются из переносимых резервных копий.

**5. Local verification / Локальная проверка.** On a Mac with Xcode, FVM and Go, build the development app once, then run the command below from the repository root. It starts a loopback SSH server that returns a fixed message. It tests both the signed helper and the system SSH client with a temporary alias, key pair and vault.

На Mac с Xcode, FVM и Go сначала соберите приложение для разработки. Из корня репозитория запустите команду ниже. Тест проверяет подписанный CLI и системный SSH по временному псевдониму. Он создаёт отдельный сейф и пару ключей. Локальный SSH-сервер возвращает фиксированное сообщение.

```sh
python3 tool/test_wpass_ssh.py
```
