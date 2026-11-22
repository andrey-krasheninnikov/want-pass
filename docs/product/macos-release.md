# Direct macOS release / Прямой релиз macOS

## Build and sign / Сборка и подпись

Run from the repository root on macOS with the pinned Flutter and Rust toolchains, Xcode, both Darwin Rust targets and a Developer ID Application identity with its private key. Xcode's Developer ID export must carry a distribution profile authorizing the production Keychain App ID. Alternatively set `WANT_PASS_DEVELOPER_PROFILE` to its local `.provisionprofile` path. The Mac uses the Keychain profile `want-pass-notary` for Apple notarization. Keep credentials in Keychain.

Выполняйте команды из корня репозитория на macOS. Нужны закреплённые версии Flutter и Rust, Xcode, обе Darwin-цели Rust и сертификат Developer ID Application с закрытым ключом. Экспорт Developer ID из Xcode должен включать профиль, разрешающий production App ID для Keychain. Можно передать путь к выданному `.provisionprofile` через `WANT_PASS_DEVELOPER_PROFILE`. Для нотарификации используется профиль Keychain `want-pass-notary`. Данные авторизации хранятся в Keychain.

```sh
make bootstrap
make check
make build-macos-production
export WANT_PASS_DEVELOPER_ID='Developer ID Application: <certificate common name> (<team identifier>)'
python3 tool/macos_release.py prepare \
  'apps/want_pass/build/macos/Build/Products/Release/Want Pass.app' \
  build/release/candidate
```

The copy in staging receives the Universal 2 `Contents/Helpers/wpass`. Before packaging, the script checks the version and build number against `pubspec.yaml`, both slices of every Mach-O, signatures, secure timestamps, hardened runtime and the App ID in the signed entitlements. For a missing profile, register the explicit App ID `foundation.want.pass` with the Apple Developer team, select the Developer ID Application certificate when generating a Developer ID distribution profile in Certificates, Identifiers & Profiles, then download it or use Xcode's Developer ID export. Set the profile path and repeat `prepare` with the same source build.

Копия приложения в staging получает Universal 2 `Contents/Helpers/wpass`. До упаковки проверяются версия и номер сборки по `pubspec.yaml`, обе архитектуры каждого Mach-O, подписи, временные метки, hardened runtime и App ID в подписанных entitlements. Если профиля ещё нет, зарегистрируйте отдельный App ID `foundation.want.pass` в своей команде Apple Developer, выберите сертификат Developer ID Application при выпуске профиля Developer ID в Certificates, Identifiers & Profiles и скачайте профиль либо экспортируйте приложение из Xcode для Developer ID. Укажите путь к профилю и повторите `prepare` с той же сборкой.

## Notarization and immutable artifact / Нотарификация и итоговый артефакт

```sh
candidate=build/release/candidate/Want-Pass-1.0.0-macOS-universal.dmg
python3 tool/macos_release.py notarize "$candidate"
python3 tool/macos_release.py finish "$candidate" build/release/v1.0.0
python3 tool/macos_release.py verify build/release/v1.0.0/Want-Pass-1.0.0-macOS-universal.dmg
(cd build/release/v1.0.0 && shasum -a 256 -c Want-Pass-1.0.0-macOS-universal.dmg.sha256)
```

Apple receives the signed DMG. The local submission receipt records the candidate SHA-256 and Apple UUID. After an interrupted wait, rerun `notarize` to resume the same job. If the initial upload has an unknown outcome, inspect `xcrun notarytool history --keychain-profile want-pass-notary`, identify the submitted file and resume with `notarize "$candidate" --submission <UUID>`. The script compares Apple's log digest with the signed candidate. For an accepted candidate, `finish` staples the ticket to a copy, validates the ticket, mounts it read-only, verifies Gatekeeper for both the image and app, then publishes the DMG and checksum together in a new directory. Publish exactly that pair to the versioned GitHub release.

В Apple отправляется подписанный DMG. Локальная квитанция содержит SHA-256 исходного DMG и UUID отправки. После прерванного ожидания повторите `notarize`, чтобы продолжить тот же запрос. При неоднозначном результате самой отправки найдите файл через `xcrun notarytool history --keychain-profile want-pass-notary` и продолжите через `notarize "$candidate" --submission <UUID>`. Скрипт сверит контрольную сумму из журнала Apple с исходным образом. Команда `finish` прикрепит билет к копии, проверит его, подключит образ только для чтения, проверит образ и приложение через Gatekeeper и запишет DMG и его контрольную сумму в новый каталог. В релиз GitHub публикуются оба файла из этого каталога.

## Development and production / Разработка и рабочий сейф

| | Development | Production |
|---|---|---|
| Application / Приложение | `Want Pass Dev.app` | `/Applications/Want Pass.app` |
| Bundle ID | `foundation.want.pass.dev` | `foundation.want.pass` |
| Keychain App ID of a provisioned build / App ID Keychain подписанной сборки | `<team>.foundation.want.pass.dev` | `<team>.foundation.want.pass` |
| Channel / Канал | `development` | `production` |

For the sandboxed application the vault path is `~/Library/Containers/<bundle-id>/Data/Library/Application Support/<bundle-id>/<channel>/vault/vault.wpass`. Appearance settings are under the same channel root. `make run` launches development. `make clean-data` addresses the development channel only. Production initializes its own vault. To transfer data explicitly use a portable backup and its source recovery phrase.

В sandbox файл сейфа находится по адресу `~/Library/Containers/<bundle-id>/Data/Library/Application Support/<bundle-id>/<channel>/vault/vault.wpass`. Рядом с каталогом `vault` лежат настройки оформления канала. `make run` запускает разработческую сборку. `make clean-data` очищает только канал разработки. У production свой сейф. Для явного переноса данных используйте копию и фразу восстановления исходного сейфа.

## Acceptance on a Mac / Приёмка на Mac

For v1.0.0, run acceptance on the MacBook and its built-in display. The next release covers installation on a clean machine and hotkeys across multiple displays. [Issue #72](https://github.com/andrey-krasheninnikov/want-pass/issues/72#issuecomment-7086440908)

Для v1.0.0 приёмка проходит на MacBook со встроенным экраном. Установка на чистой машине и проверка хоткеев на нескольких дисплеях запланированы на следующий выпуск. [Задача #72](https://github.com/andrey-krasheninnikov/want-pass/issues/72#issuecomment-7086440908)

Run the local integration checks from the repository root. They use temporary vaults and test entries. / Выполняйте локальные интеграционные проверки из корня репозитория. Они используют временные сейфы и тестовые записи.

```sh
make native-ui
python3 tool/test_macos_shortcuts.py
(cd apps/want_pass && fvm flutter test integration_test/account_import_qr_test.dart -d macos --no-pub)
(cd apps/want_pass && fvm flutter test integration_test/local_tools_ipc_test.dart -d macos --no-pub)
```

Use a disposable vault and synthetic entries for the installed-app checks. Record macOS version, architecture, application version/build and the SHA-256 of the installed DMG. Open the downloaded image through Finder, drag Want Pass into Applications, launch it, create a vault, import a sample account, search, copy one field, review history, export a backup and restore it in another disposable vault. Exercise both import strategies and one conflict. Confirm the development app can run alongside production and that its test records stay separate.

Для проверок установленного приложения используйте временный сейф и вымышленные записи. Запишите версию macOS, архитектуру, версию и номер сборки приложения, SHA-256 установленного DMG. Откройте загруженный образ в Finder, перетащите приложение в Applications и запустите. Создайте сейф, импортируйте запись, найдите и скопируйте отдельное поле, посмотрите историю, выгрузите копию и восстановите её в другом временном сейфе. Проверьте оба способа восстановления и один конфликт версий. Запустите dev рядом с production и проверьте, что у них разные записи.

Record physical Touch ID enrollment, successful unlock, cancellation, sleep and session lock on the signed application. Exercise the global hotkeys with the pointer on each attached display. Check app logs and available crash reports for the synthetic markers, verify that locking clears views and clipboard expiry preserves clipboard changes made in another app. Record which checks ran on physical hardware, the operating system and any missing device or monitor. Signature inspection, mocked biometrics and a Universal 2 binary have separate evidence from physical acceptance. [Apple notarization](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) · [Apple provisioning profiles](https://developer.apple.com/documentation/technotes/tn3125-inside-code-signing-provisioning-profiles)

Зафиксируйте подключение Touch ID, успешный вход, отмену, сон и блокировку сеанса на физическом Mac с подписанной сборкой. Проверьте глобальные хоткеи, перемещая курсор на каждый подключённый дисплей. Ищите только синтетические маркеры в логах и доступных crash reports. Убедитесь, что блокировка скрывает открытые данные, а очистка буфера по таймеру сохраняет текст, скопированный из другого приложения. Укажите, какие проверки выполнены на физическом устройстве, под какой ОС и какое оборудование отсутствовало. Подпись, mock-тесты биометрии и наличие двух архитектур подтверждаются отдельно от физической приёмки. [Нотарификация Apple](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) · [Профили Apple](https://developer.apple.com/documentation/technotes/tn3125-inside-code-signing-provisioning-profiles)
