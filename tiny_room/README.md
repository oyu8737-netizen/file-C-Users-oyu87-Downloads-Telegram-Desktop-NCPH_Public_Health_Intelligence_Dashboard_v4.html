# 🏠 Tiny Room — v0.3

> Утсаа сэгсрэхэд биш, бодитоор алхахад өрөөнд чинь шинэ зүйл нэмэгддэг жижигхэн апп.

📚 **Хичээлүүд (монголоор): [docs/README.md](docs/README.md)** — компьютер бэлдэхээс апп хуваалцах хүртэл 7 хичээл.

## Функцүүд

| | Функц |
|---|---|
| 🚶 | Жинхэнэ алхам: iPhone → Apple Health, Android → Health Connect / утасны мэдрэгч |
| 🪙 | 100 алхам = 1 coin · өдрийн зорилго (5,000) +20 · streak bonus +5×streak (≤50) |
| 🛋️ | Дэлгүүр, цуглуулга, streak/level/алхмаар нээгдэх тавилга |
| 🎨 | Өрөө засах: чирэх, эргүүлэх, 9 өнгөөр будах |
| 📊 | Сүүлийн 7 хоногийн алхмын график, streak, level |
| 🇲🇳🇬🇧🇨🇳 | Монгол / Англи / Хятад — хэл бүр өөрийн улсын өнгө, өрөөний загвар, хээтэй |
| ☰ | Хураадаг цэс (компьютер: ☰ товч, утас: гүйлгэхэд нуугдана) |
| 👤 | Account (Firebase Auth). Аль ч төхөөрөмж дээр нэвтрэхэд өрөө, coin сэргэж, тухайн төхөөрөмжийн алхамтай нэгтгэгдэнэ |
| 👫 | Найзын кодоор найз нэмэх, найзын өрөөнд зочлох |
| 📈 | Admin: нийт/идэвхтэй/шинэ хэрэглэгч, сүүлийн бүртгэлүүд. Бүртгэл Firebase Console → Firestore → `registrations` дээр ч харагдана |

Firebase тохируулаагүй бол апп **offline горимоор** ажиллана (account, найзууд идэвхгүй).

## Ажиллуулах

```bash
cd tiny_room
flutter pub get
flutter run -d chrome   # компьютер дээр туршилт (алхам = туршилтын товч)
flutter run             # холбогдсон утсан дээр (жинхэнэ алхам)
flutter test            # 19 автомат тест
```

## Файлын бүтэц

```
lib/
├── main.dart                   # Эхлэх цэг: өгөгдөл ачаалах, Firebase, алхам, 5 таб
├── firebase_options.dart       # `flutterfire configure` автоматаар солино
├── l10n/
│   ├── strings.dart            # 🇲🇳🇬🇧🇨🇳 Бүх текст гурван хэлээр
│   └── app_lang.dart           # Хэл бүрийн улсын өнгө, цонх, чимэглэл, хээ
├── models/
│   ├── furniture.dart          # Тавилгын каталог, будах өнгөнүүд
│   └── placed_item.dart        # Өрөөнд тавьсан тавилга (x, y, эргэлт, өнгө)
├── state/
│   ├── game_state.dart         # ❤️ Гол логик: өдөр бүрийн алхам → coin, bonus, streak
│   ├── settings_state.dart     # Хэл, цэс хураасан эсэх
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
docs/                           # 📚 7 хичээл
test/                           # coin/streak/синк/UI тестүүд
```

## Firestore өгөгдлийн бүтэц

```
users/{uid}                 name, friendCode, game{…}, level, streak, todaySteps,
                            totalSteps, lastActive, createdDay
users/{uid}/friends/{fid}   name, addedAt
friendCodes/{CODE}          uid, name
registrations/{uid}         name, email, platform, createdAt, lastLoginDay ← admin
admins/{uid}                role   ← Console-оос гараар
```
