# 🏠 Tiny Room — v0.2

> Утсаа сэгсрэхэд биш, бодитоор алхахад өрөөнд чинь шинэ зүйл нэмэгддэг жижигхэн апп.

📘 **Заавар (монголоор):**
- [GUIDE_MN.md](GUIDE_MN.md) — компьютерээ бэлдэх, код хэрхэн зохион байгуулагдсан бэ (эхлэгчид)
- [GUIDE_FIREBASE_MN.md](GUIDE_FIREBASE_MN.md) — **v0.2-ын шинэ функцүүд**, account/найзууд/статистикийг асаах, утсан дээр жинхэнэ алхам тоолуулах

## Функцүүд

| | Функц |
|---|---|
| 🚶 | Жинхэнэ алхам: iPhone → Apple Health, Android → Health Connect / утасны мэдрэгч |
| 🪙 | 100 алхам = 1 coin · өдрийн зорилго (5,000) +20 · streak bonus +5×streak (≤50) |
| 🛋️ | Дэлгүүр, цуглуулга, streak/level/алхмаар нээгдэх тавилга |
| 🎨 | Өрөө засах: чирэх, эргүүлэх, 9 өнгөөр будах |
| 📊 | Сүүлийн 7 хоногийн алхмын график, streak, level |
| 🇲🇳🇬🇧 | Монгол / Англи хэл |
| 👤 | Account (Firebase Auth), өрөө cloud-д хадгалагдана |
| 👫 | Найзын кодоор найз нэмэх, найзын өрөөнд зочлох |
| 📈 | Admin: нийт/идэвхтэй/шинэ хэрэглэгч, 7 хоногийн бүртгэл + Firebase Analytics |

Firebase тохируулаагүй бол апп **offline горимоор** ажиллана (account, найзууд идэвхгүй).

## Ажиллуулах

```bash
cd tiny_room
flutter pub get
flutter run -d chrome   # компьютер дээр туршилт (алхам = туршилтын товч)
flutter run             # холбогдсон утсан дээр (жинхэнэ алхам)
flutter test            # 15 автомат тест
```

## Файлын бүтэц

```
lib/
├── main.dart                   # Эхлэх цэг: өгөгдөл ачаалах, Firebase, алхам, 5 таб
├── firebase_options.dart       # `flutterfire configure` автоматаар солино
├── l10n/strings.dart           # 🇲🇳🇬🇧 Бүх текст хоёр хэлээр
├── models/
│   ├── furniture.dart          # Тавилгын каталог, будах өнгөнүүд
│   └── placed_item.dart        # Өрөөнд тавьсан тавилга (x, y, эргэлт, өнгө)
├── state/
│   ├── game_state.dart         # ❤️ Гол логик: өдөр бүрийн алхам → coin, bonus, streak
│   ├── settings_state.dart     # Хэл
│   └── app_services.dart       # Дэлгэцүүд Firebase/алхамд хандах
├── services/
│   ├── step_service.dart       # HealthKit / Health Connect / мэдрэгч → GameState
│   ├── cloud_service.dart      # Firebase: account, найзууд, admin статистик
│   └── sync_service.dart       # Утас ↔ cloud автомат синк
├── widgets/
│   ├── room_view.dart          # Өрөө зурах, тавилга будах
│   └── bar_chart.dart          # 7 хоногийн график
└── screens/
    ├── auth_screen.dart        # Нэвтрэх / бүртгүүлэх
    ├── home_screen.dart        # Гэр: өрөө, алхам, алхам холбох
    ├── editor_screen.dart      # Өрөө засах, будах
    ├── shop_screen.dart        # Дэлгүүр + Цуглуулга
    ├── collection_screen.dart
    ├── friends_screen.dart     # Найзын код, найзууд
    ├── friend_room_screen.dart # Найзын өрөөнд зочлох
    ├── profile_screen.dart     # Level, график, хэл, account
    └── admin_screen.dart       # Хэрэглэгчийн статистик
firestore.rules                 # Firestore хамгаалалтын дүрэм
test/                           # coin/streak/синк/UI тестүүд
```

## Firestore өгөгдлийн бүтэц

```
users/{uid}                 name, friendCode, game{…}, level, streak, todaySteps,
                            totalSteps, lastActive, createdDay
users/{uid}/friends/{fid}   name, addedAt
friendCodes/{CODE}          uid, name
admins/{uid}                role   ← Console-оос гараар
```
