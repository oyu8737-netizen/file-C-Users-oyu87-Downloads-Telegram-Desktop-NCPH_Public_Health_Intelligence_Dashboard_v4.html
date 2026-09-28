# Хичээл 6. Хүмүүст хуваалцах

> 🎯 **Зорилго:** Найзууд тань Tiny Room-ийг утсандаа ашигладаг болох
> ⏱ **Хугацаа:** 20 минут
> 📋 **Өмнөх нөхцөл:** [Хичээл 4](04_firebase.md) дууссан байвал сайн (эс тэгвэл account, найз ажиллахгүй)

[← Хичээлийн жагсаалт](README.md)

| Арга | Хэнд | Жинхэнэ алхам | Үнэ | Хэцүү |
|---|---|---|---|---|
| **A. Вэб холбоос** | Хэн ч (iPhone, Android, компьютер) | ❌ | Үнэгүй | ⭐ |
| **B. APK файл** | Android | ✅ | Үнэгүй | ⭐⭐ |
| **C. Апп дэлгүүр** | Хэн ч | ✅ | $25 / $99 жилд | ⭐⭐⭐ |

---

## A. Вэб холбоос

**1. Бүтээх** 💻
```powershell
cd $HOME\tiny-room-repo\tiny_room; flutter build web; explorer build
```

**2. Байршуулах** 🌐
1. **https://app.netlify.com/drop** → GitHub-аар нэвтэрнэ.
2. Нээгдсэн цонхноос **`web`** хавтсыг чирж Netlify дээр тавина.
3. `https://xxxx.netlify.app` холбоос гарна → **Site configuration → Change site name** → `tiny-room-oyu` гэх мэт.

**3. Firebase-д зөвшөөрөх** 🌐 (заавал!)
👉 https://console.firebase.google.com/project/tiny-room-e0434/authentication/settings → **Authorized domains** → **Add domain** → `tiny-room-oyu.netlify.app`

> Нэмэхгүй бол вэб дээр нэвтрэхэд `unauthorized-domain` алдаа гарна.

**4. Хуваалцах** — холбоосоо Messenger, Telegram-аар илгээнэ. Хүлээн авагч:
- **iPhone:** Safari → **⬆️ Хуваалцах → Add to Home Screen**
- **Android:** Chrome → **⋮ → Add to Home screen**

**Шинэчлэх:** 1-р алхам → Netlify → **Deploys** → шинэ `web` хавтсаа чирнэ. Холбоос өөрчлөгдөхгүй.

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
