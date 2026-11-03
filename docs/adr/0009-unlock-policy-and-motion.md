---
status: accepted
---

# Unlock policy and motion / Политика входа и анимации

The current UI uses the strict creation policy for unlocking: 15 or more Unicode scalars, at most 1024 UTF-8 bytes, an uppercase letter, a lowercase letter, an ASCII digit and punctuation or a symbol. Input is single-line and is not trimmed or normalized. A pure native V3 check supplies live feedback without KDF, storage or recovery generation. V3 unlock repeats the check. Existing V1/V2 API behavior and the V2 file format remain unchanged.

Текущий UI применяет к входу строгую политику создания: минимум 15 Unicode scalars, максимум 1024 UTF-8 байта, заглавная и строчная буквы, ASCII-цифра и знак пунктуации или символ. Ввод однострочный, без обрезания и нормализации. Чистая native-проверка V3 обеспечивает обратную связь без KDF, хранения и генерации recovery. Вход V3 повторяет проверку. Поведение API V1/V2 и формат файла V2 сохраняются.

This intentionally prevents UI login with older passwords that lack required character classes. Recovery remains the route to set a compliant password. Help actions are initially hidden and appear only after a credentials rejection for a password that passes policy. A format error does not reveal them. The hint is shown only after an explicit action. Every new dialog starts with empty input and hidden help. Validation revisions and session epochs discard stale results; secrets never enter state, effects or diagnostics.

Это намеренно запрещает вход через UI со старыми паролями без требуемых классов символов. Восстановление позволяет задать подходящий пароль. Кнопки помощи изначально скрыты и появляются только после отказа credentials для пароля, прошедшего политику. Ошибка формата их не открывает. Подсказка отображается по явному действию. Новое окно начинается с пустого поля и скрытой помощи. Revision проверки и epoch сессии отбрасывают устаревшие ответы; секреты не попадают в state, effects и диагностику.

Want Allure 1.2.1 supplies optional sphere/lightning alternation with 30-second transition starts and a 1200 ms crossfade. Inactive surfaces retain their phase, hidden effects pause, reduced motion keeps a static sphere, and high contrast hides decoration. The approved SVG rotates in the header with decorative glow and a static fallback. The countdown appears only while unlocked and reads the existing monotonic inactivity deadline; rendering never renews access. A success notice follows confirmed native unlock only.

Want Allure 1.2.1 предоставляет необязательное чередование сферы и молний: переходы начинаются каждые 30 секунд и длятся 1200 мс. Неактивный экран сохраняет фазу, скрытый эффект останавливается, reduced motion оставляет статичную сферу, high contrast скрывает декорацию. Утверждённый SVG вращается в header с декоративным свечением и статичным fallback. Таймер виден только при открытом сейфе и читает существующий монотонный срок бездействия; отрисовка не продлевает доступ. Success-уведомление следует только за подтверждённым native-входом.
