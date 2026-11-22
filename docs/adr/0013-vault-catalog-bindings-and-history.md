---
status: accepted
---

# Service catalog, card templates and history / Каталог сервисов, шаблоны и история

The encrypted document uses schema 3 for custom services, templates, per-card resource bindings and card history. Existing schema 2 cards retain their IDs, presets and field values. Custom services and uploaded icons live inside the vault. A service with live references can be archived or explicitly reassigned. Archived definitions remain readable from prior card versions.

Зашифрованный документ использует схему 3 для пользовательских сервисов, шаблонов, привязок ресурсов и истории. Карточки схемы 2 сохраняют ID, пресеты и значения полей. Пользовательские сервисы и загруженные иконки хранятся в сейфе. Для используемого сервиса владелец выбирает архивирование или перенос карточек. Архивное определение остаётся доступным из прежних версий.

Each custom card pins an immutable template version. Field IDs survive renaming. Adding, removing or changing a field creates a new version. A card adopts the new version after its owner reviews the changes and saves the card. Files remain in the encrypted document with their original names and bytes. A binding names a target, a usage method and the field IDs available for that use. Several bindings can share one card. The owner selects a binding when more than one applies. Tool access requires a separate grant.

У каждой пользовательской карточки закреплена неизменяемая версия шаблона. Переименование поля сохраняет его ID. Добавление, удаление или изменение поля создаёт новую версию. Чтобы применить её к существующей карточке, владелец просматривает изменения и сохраняет карточку. Вложения сохраняют исходные имена и байты в зашифрованном документе. Привязка задаёт ресурс, способ использования и ID доступных полей. Если у карточки несколько подходящих привязок, владелец выбирает одну. Доступ инструмента требует отдельного разрешения.

Rust records the previous contents when a card changes or is deleted. A historical card retains its versioned field definitions, attachment contents and resource bindings. Restoring a revision makes it current and preserves other eligible history. Oldest eligible data is newer than the UTC cutoff of 365 days. Reading filters expired revisions, and the next vault write removes them from the document. Explicit clearing applies to one card or the whole vault. Backups already exported by the owner have their own copies.

Rust сохраняет прежнее содержимое при изменении или удалении карточки. Прошлая версия сохраняет структуру полей, вложения и привязки. При восстановлении выбранная версия становится текущей, остальные доступные версии остаются в истории. Срок хранения отсчитывается по UTC. При чтении исключаются версии возрастом от 365 дней, а при следующей записи они удаляются из документа. Владелец может явно очистить историю одной карточки или всего сейфа. В уже экспортированных резервных копиях остаются собственные экземпляры данных.
