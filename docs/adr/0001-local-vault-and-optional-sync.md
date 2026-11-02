---
status: accepted
---

# Local vault and optional sync / Локальный сейф и необязательная синхронизация

The vault works without registration or network. Hosted and self-hosted Rust services hold encrypted user data, while clients retain decryption capability; signing into the service does not itself enroll a decrypting device. This keeps local use independent of service availability, at the cost of explicit device enrollment and user-held recovery material.

Сейф работает без регистрации и сети. Общий и собственный Rust-сервисы хранят зашифрованные пользовательские данные, а возможность расшифрования остаётся у клиентов; сетевой вход сам по себе не подключает расшифровывающее устройство. Локальное использование независимо от доступности сервиса ценой явного подключения устройств и сохраняемых пользователем данных recovery.
