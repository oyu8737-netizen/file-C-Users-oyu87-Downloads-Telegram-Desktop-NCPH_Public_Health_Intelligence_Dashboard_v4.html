# Хичээл 6. Хүмүүст хуваалцах

> 🎯 **Зорилго:** Найзууд тань Tiny Room-ийг утсандаа ашигладаг болох
> ⏱ **Хугацаа:** 20 минут
> 📋 **Өмнөх нөхцөл:** [Хичээл 4](04_firebase.md) дууссан байвал сайн (эс тэгвэл account, найз ажиллахгүй)

[← Хичээлийн жагсаалт](README.md)

| Арга | Хэнд | Жинхэнэ алхам | Үнэ | Хэцүү |
|---|---|---|---|---|
| **A. Вэб холбоос — Firebase** ⭐ зөвлөмж | Хэн ч (iPhone, Android, компьютер) | ❌ | Үнэгүй | ⭐ |
| A2. Вэб холбоос — Netlify | Хэн ч | ❌ | Үнэгүй | ⭐ |
| **B. APK файл** | Android | ✅ | Үнэгүй | ⭐⭐ |
| **C. Апп дэлгүүр** | Хэн ч | ✅ | $25 / $99 жилд | ⭐⭐⭐ |

---

## A. Вэб холбоос — Firebase дээр ⭐

Tiny Room таны Firebase төсөл дээр **өөрийн хаягтай** байрлана:

### 👉 https://tiny-room-e0434.web.app

**Давуу тал:** account, найз, статистик бүгд нэг дор. Домэйн зөвшөөрөх шаардлагагүй (Firebase өөрийн хаягаа автоматаар зөвшөөрдөг). Firestore дүрэм ч **хамт** байршина.

**Өмнөх нөхцөл:** [Хичээл 4](04_firebase.md)-ийн 4.3 (Firestore үүсгэх), 4.4 (хэрэгсэл), 4.5 (`firebase login` + `flutterfire configure`).

**Байршуулах / шинэчлэх** — PowerShell дээр нэг мөр:
```powershell
cd $HOME\tiny-room-repo; git stash -u; git pull; cd tiny_room; flutter pub get; flutter build web; firebase deploy --only hosting,firestore:rules
```

| Хэсэг | Юу хийнэ |
|---|---|
| `git pull` | Хамгийн сүүлийн кодыг татна |
| `flutter build web` | Вэб хувилбарыг `build\web` хавтсанд бүтээнэ |
| `firebase deploy --only hosting` | Тэр хавтсыг `tiny-room-e0434.web.app` руу байршуулна |
| `firestore:rules` | `firestore.rules` дүрмийг Firestore руу **автоматаар** тавина (гараар хуулах шаардлагагүй) |

✅ Сүүлд `Hosting URL: https://tiny-room-e0434.web.app` гэж гарвал болсон. Холбоосыг нээхэд **Tiny Room** гарна.

> Тохиргоо нь `firebase.json` болон `.firebaserc` файлд бэлэн (төсөл: `tiny-room-e0434`).
> `Error: Failed to get Firebase project` гарвал `firebase login`-оо дахин хийнэ.

**Хуваалцах** — холбоосоо Messenger, Telegram-аар илгээнэ. Хүлээн авагч:
- **iPhone:** Safari → **⬆️ Хуваалцах → Add to Home Screen**
- **Android:** Chrome → **⋮ → Add to Home screen**

---

## A2. Вэб холбоос — Netlify (өөр сонголт)

```powershell
cd $HOME\tiny-room-repo\tiny_room; flutter build web; explorer build
```
1. **https://app.netlify.com/drop** → `web` хавтсыг чирч тавина → `xxxx.netlify.app` холбоос.
2. **Заавал:** [Authentication → Settings → Authorized domains](https://console.firebase.google.com/project/tiny-room-e0434/authentication/settings) → **Add domain** → `xxxx.netlify.app` (эс тэгвэл `unauthorized-domain` алдаа).

---

## B. Android APK файл

```powershell
cd $HOME\tiny-room-repo\tiny_room; flutter build apk --release; explorer build\app\outputs\flutter-apk
```
⏳ 5–15 минут → **`app-release.apk`**

1. Файлаа Telegram / Google Drive-аар илгээнэ.
2. Хүлээн авагч файл дээр дарна → **Install unknown apps → Allow** → **Install**.

---

## C. Апп дэлгүүр

| | Google Play | App Store |
|---|---|---|
| Бүртгэл | $25 нэг удаа | $99 жил бүр |
| Компьютер | Windows болно | **Mac** заавал |
| Туршилтын тараалт | Internal testing (100 хүн) | TestFlight (10,000 хүн) |

Гаргахаас өмнө заавал:
- 📄 **Нууцлалын бодлого (Privacy Policy)** — алхам (эрүүл мэндийн өгөгдөл) ашигладаг тул
- 🗑️ **Account устгах** боломж (Apple-ийн шаардлага)
- 🩺 Google Play-д **Health Connect зөвшөөрлийн** хүсэлт

---

## ✅ Шалгах

- [ ] Найз тань холбоосоор нээж бүртгүүлсэн
- [ ] Та хоёр найзын кодоор найз болж, бие биенийхээ өрөөнд зочилсон
- [ ] Admin статистикт шинэ бүртгэл харагдсан

➡️ Асуудал гарвал: [7. Алдаа гарвал](07_troubleshooting.md)
