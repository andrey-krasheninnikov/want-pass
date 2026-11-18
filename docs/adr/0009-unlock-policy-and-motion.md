---
status: accepted
---

# Unlock policy and motion / Политика входа и анимации

The current UI uses the strict creation policy for unlocking: 15 or more Unicode scalars, at most 1024 UTF-8 bytes, an uppercase letter, a lowercase letter, an ASCII digit and punctuation or a symbol. Input is single-line and is not trimmed or normalized. A pure native V3 check supplies live feedback without KDF, storage or recovery generation. V3 unlock repeats the check. Existing V1/V2 API behavior and the V2 file format remain unchanged.

Текущий UI применяет к входу строгую политику создания: минимум 15 Unicode scalars, максимум 1024 UTF-8 байта, заглавная и строчная буквы, ASCII-цифра и знак пунктуации или символ. Ввод однострочный, без обрезания и нормализации. Чистая native-проверка V3 обеспечивает обратную связь без KDF, хранения и генерации recovery. Вход V3 повторяет проверку. Поведение API V1/V2 и формат файла V2 сохраняются.

Older passwords can fail the current UI policy. Recovery lets the owner set a compliant password. The locked password field opens a popover with the saved hint or a message that no hint exists, the password rules and a Recovery action. Incorrect credentials mark the field after submission without adding controls or shifting the submit button. Editing clears the rejection style. Operational errors are announced inside the form. Validation revisions and session epochs discard stale results. Password values stay out of state, effects and diagnostics.

Прежние пароли могут не соответствовать текущей политике входа. Восстановление позволяет задать подходящий пароль. Кнопка в поле пароля открывает подсказку или сообщение, что она не добавлена. В том же окне доступны требования к паролю и кнопка восстановления. После неверного пароля поле подсвечивается, а кнопка входа остаётся на месте. Изменение ввода снимает подсветку. Системные ошибки объявляются внутри формы. Версия проверки и сессия отбрасывают устаревшие ответы. Значения паролей не попадают в состояние, эффекты и диагностику.

Want Allure 1.2.1 supplies optional sphere/lightning alternation with 30-second transition starts and a 1200 ms crossfade. Inactive surfaces retain their phase, hidden effects pause, reduced motion keeps a static sphere, and high contrast hides decoration. The approved SVG rotates in the header with the shared subtle ambient glow and a static fallback. Animated decorative outlines surround only the circular safe; cards have no hover contour. The valid-password action fades in a soft static halo. Secret postfix icons have transparent surfaces in every interaction state, with labelled 44-pixel targets and keyboard focus. The countdown appears only while unlocked and reads the existing monotonic inactivity deadline; rendering never renews access. A success notice follows confirmed native unlock only.

Want Allure 1.2.1 предоставляет необязательное чередование сферы и молний: переходы начинаются каждые 30 секунд и длятся 1200 мс. Неактивный экран сохраняет фазу, скрытый эффект останавливается, reduced motion оставляет статичную сферу, high contrast скрывает декорацию. Утверждённый SVG вращается в header с общим мягким свечением и статичным fallback. Анимированная декоративная обводка окружает только круглый замок; карточки не показывают hover-контур. При подходящем пароле плавно появляется мягкое статичное свечение кнопки. Постфиксные иконки остаются прозрачными во всех состояниях, с подписанными целями 44 пикселя и клавиатурным фокусом. Таймер виден только при открытом сейфе и читает существующий монотонный срок бездействия; отрисовка не продлевает доступ. Success-уведомление следует только за подтверждённым native-входом.

## Current browsing interaction / Текущий просмотр сейфа

The header now uses a 3D padlock with an animated shackle and warning/success glow. Dragging rotates the complete mesh without activating the action; hover has no background. Its state follows confirmed access; reduced motion uses static endpoints. The inactivity deadline remains enforced without a visible countdown. Lock, unlock and copy actions show no toast. This interaction supersedes the circular-safe, countdown and unlock-notice requirements above. The password policy and help behavior remain unchanged.

В header используется 3D-замок с анимацией дужки и свечением warning/success. Перетаскивание вращает всю модель без активации действия; фон при наведении отсутствует. Его состояние следует подтверждённому доступу; reduced motion оставляет статичные конечные состояния. Срок бездействия применяется без видимого отсчёта. Блокировка, разблокировка и копирование не показывают тост. Это взаимодействие заменяет описанные выше требования к круглому замку, отсчёту и уведомлению входа. Политика пароля и поведение помощи сохраняются.

## Inline access and quiet workspace / Встроенный вход и спокойная рабочая область

The locked screen now places the master-password form directly over a local fragment shader showing fine luminous threads. Shader failure uses a static Canvas illustration; reduced motion freezes decoration, high contrast hides it, and inactive views pause it. The unlocked workspace uses a plain theme background. Setup and recovery retain the sphere/lightning treatment. This supersedes the modal unlock and shared browsing background above. Hint disclosure still requires an explicit press. The help button is available from the start.

Заблокированный экран размещает форму мастер-пароля поверх локального fragment shader с тонкими светящимися нитями. При ошибке шейдера используется статичная иллюстрация Canvas; reduced motion останавливает декорацию, high contrast скрывает её, неактивный экран приостанавливает анимацию. Открытая рабочая область использует обычный фон темы. Настройка и восстановление сохраняют сферу и молнии. Это заменяет описанные выше модальный вход и общий фон просмотра. Подсказка раскрывается по нажатию. Кнопка помощи доступна сразу.


## Setup feedback and motion / Обратная связь и анимации настройки

The setup checklist displays the flags from the same Rust policy used to validate the master password. A single visibility control operates both fields. Continue requires a passing report for the current input and an exact match. The loading logo hands off to a short Flutter animation that expands a copy of the scarab silhouette. Confirmed setup plays a short success animation before showing the vault. Incoming transitions leave no outgoing sensitive screen alive on lock. Reduced motion skips decorative movement.

Список требований показывает результат той же проверки Rust, которая применяется к мастер-паролю. Один переключатель управляет видимостью обоих полей. Для продолжения нужны успешная проверка текущего ввода и точное совпадение полей. После загрузки Flutter показывает короткую волну в форме жука. После подтверждённой настройки сначала появляется анимация успеха, затем сейф. При блокировке прежний экран с секретами сразу удаляется. Reduced motion отключает декоративное движение.
