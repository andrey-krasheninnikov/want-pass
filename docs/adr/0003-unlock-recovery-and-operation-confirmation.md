---
status: accepted
---

# Unlock, recovery and operation confirmation / Разблокировка, recovery и подтверждение операций

A master password is the initial unlock method, with a personal recovery kit and optional device biometrics. External TOTP confirms user-selected sensitive operations and can be reset through full recovery; it is an application authorization policy, not an asserted additional encryption factor for stolen vault ciphertext. Stored third-party passkeys, external-passkey account authentication and future external-passkey vault unlock are separate capabilities; cryptographic primitives and formats require their own implementation review.

При создании сейф использует мастер-пароль с личным recovery kit и необязательной биометрией устройства. Внешний TOTP подтверждает выбранные чувствительные операции и сбрасывается полным recovery-процессом; это политика авторизации приложения, а не заявленный дополнительный фактор шифрования украденного шифротекста. Хранимые passkeys сервисов, вход внешним passkey в аккаунт и будущая разблокировка сейфа внешним passkey являются разными возможностями; криптографические примитивы и форматы требуют отдельной проверки реализации.
