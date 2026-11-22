---
status: accepted
---

# Unlock, recovery and operation confirmation / Разблокировка, recovery и подтверждение операций

A master password is the initial unlock method, with a personal recovery kit and optional device biometrics. External TOTP confirms user-selected sensitive operations and can be reset through full recovery; it is an application authorization policy, not an asserted additional encryption factor for stolen vault ciphertext. Stored third-party passkeys, external-passkey account authentication and future external-passkey vault unlock are separate capabilities; cryptographic primitives and formats require their own implementation review.

При создании сейф использует мастер-пароль с личным recovery kit и необязательной биометрией устройства. Внешний TOTP подтверждает выбранные чувствительные операции и сбрасывается полным recovery-процессом; это политика авторизации приложения, а не заявленный дополнительный фактор шифрования украденного шифротекста. Хранимые passkeys сервисов, вход внешним passkey в аккаунт и будущая разблокировка сейфа внешним passkey являются разными возможностями; криптографические примитивы и форматы требуют отдельной проверки реализации.

## Resetting local app data / Сброс локальных данных

Reset is available from General settings while the vault is unlocked. Rust verifies the current recovery phrase in word or numbered JSON form before admitting the reset. The operation holds the exclusive vault lock and deletes the active encrypted vault and local appearance preferences, including saved column widths. A durable marker records file identities so startup can resume an interrupted reset. The operation preserves user exports and files outside its fixed allowlist.

Сброс доступен в общих настройках после разблокировки сейфа. Rust подтверждает текущую фразу восстановления в виде слов или JSON с номерами. Операция удерживает эксклюзивную блокировку и удаляет активный зашифрованный сейф и настройки оформления, включая ширину колонок. Журнал фиксирует сведения о файлах, чтобы приложение могло завершить прерванный сброс при запуске. Пользовательские экспорты и файлы вне разрешённого списка сохраняются.
