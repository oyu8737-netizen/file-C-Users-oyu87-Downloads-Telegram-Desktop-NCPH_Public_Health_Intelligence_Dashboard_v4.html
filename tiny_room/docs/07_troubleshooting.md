# Хичээл 7. Алдаа гарвал

[← Хичээлийн жагсаалт](README.md)

> 💬 Шийдэл олдохгүй бол алдааны мессежийг **бүтнээр нь хуулж**, эсвэл дэлгэцийн зургаа (**Windows + Shift + S** → **Ctrl + V**) Claude-д илгээгээрэй.

## PowerShell

| Алдаа | Шалтгаан | Шийдэл |
|---|---|---|
| Олон улаан мөр, `is not recognized`, `Missing ]` | Заавар файлын **тайлбарыг** хуулсан | Зөвхөн **саарал хайрцаг** доторхыг хуулна |
| `'flutter' is not recognized` | PATH тохироогүй / цонх хуучин | PowerShell-ээ хааж шинээр нээ. Болохгүй бол [Хичээл 1.1](01_computer_setup.md) скриптийг дахин |
| `^C Terminate batch job (Y/N)?` | **Ctrl+C** дарагдсан (зогсоох) | `Y` → дахин ажиллуул. Хуулахдаа хулгана ашигла |
| `A positional parameter cannot be found` | Хоёр тушаал нийлсэн | Мөр бүрийг тусад нь, эсвэл `;`-ээр тусгаарла |
| `running scripts is disabled` | Windows скрипт хориглосон | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` → `Y` |
| `git pull` дээр "would be overwritten" | Компьютер дээрх өөрчлөлт | `git stash -u` → `git pull` |

## Android Studio / утас

| Алдаа | Шалтгаан | Шийдэл |
|---|---|---|
| <a id="android-studio-админ-эрх"></a>`could not request administrative privileges` | Админ эрх олгоогүй | Файл дээр **баруун товч → Run as administrator** → **Yes**. Нууц үг асуувал: [developer.android.com/studio](https://developer.android.com/studio) → **Download options** → **.zip** хувилбарыг `C:\`-д задлаад `bin\studio64.exe` |
| `cmdline-tools component is missing` | Нэмэлт хэрэгсэл дутуу | Android Studio → **SDK Manager → SDK Tools** → ✅ Command-line Tools → Apply |
| `--licenses option is no longer needed` | Google хэрэгслээ шинэчилсэн | Алдаа биш — алгасна |
| `No devices found` | Утас/emulator холбогдоогүй | Emulator-ийг ▶ асаах, эсвэл утсаа USB-ээр холбож **Allow** |

## Firebase

| Алдаа | Шалтгаан | Шийдэл |
|---|---|---|
| `Firebase тохируулаагүй тул offline горим` | `flutterfire configure` хийгээгүй | [Хичээл 4.5](04_firebase.md) |
| `(operation-not-allowed)` | Email/Password асаагаагүй | [Хичээл 4.2](04_firebase.md) |
| `permission-denied` | Дүрэм тавиагүй / хуучин | [Хичээл 4.3](04_firebase.md) → дүрмийг **дахин Publish** |
| `unauthorized-domain` | Netlify домэйн нэмээгүй | [Хичээл 6-A2](06_share.md), эсвэл Firebase хаяг (`tiny-room-e0434.web.app`) ашигла |
| `Failed to get Firebase project` / `not authorized` | `firebase login` хийгээгүй | `firebase login` → дахин `firebase deploy` |
| Вэб хаяг дээр "Site Not Found" / Firebase-ийн өөр хуудас | Байршуулаагүй / хуучин | [Хичээл 6-A](06_share.md)-ийн нэг мөр тушаалыг ажиллуул |
| Admin статистик харагдахгүй | admins баримтын UID таараагүй | [Хичээл 4.6](04_firebase.md) — UID-ийг дахин хуулж шалга |
| `'flutterfire' / 'firebase' is not recognized` | PATH | PowerShell-ээ шинээр нээ, болохгүй бол [Хичээл 4.4](04_firebase.md) |

## Апп дотор

| Асуудал | Шийдэл |
|---|---|
| Эмодзи / хятад үсэг □ болж харагдана | Вэб хувилбар фонтоо интернэтээс татдаг — интернэтээ шалгаад `R` |
| Доод цэс алга болсон | Дээш гүйлгэхэд гарч ирнэ |
| Цэс хэт жижиг / бичиггүй | **Би → Цэсний бичиг харуулах** асаана (компьютер дээр ☰) |
| Бүгдийг эхнээс нь эхлүүлэх | **Би → Туршилт → Бүгдийг эхнээс нь** (вэб дээр) |
