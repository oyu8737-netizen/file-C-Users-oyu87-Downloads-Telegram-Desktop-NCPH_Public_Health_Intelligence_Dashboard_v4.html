# 🏠 Tiny Room — LEVEL 1 Prototype

> Утсаа сэгсрэхэд биш, бодитоор алхахад өрөөнд чинь шинэ зүйл нэмэгддэг жижигхэн апп.

> 🔰 Код огт мэдэхгүй бол эхлээд [GUIDE_MN.md](GUIDE_MN.md)-г уншаарай — алхам бүрийг "юу хийх, яагаад" гэж тайлбарласан.

Одоогоор **fake алхам** (`+100`, `+1000`, `+5000` товч) ашиглаж тоглоомын механикийг шалгана.
LEVEL 2-т эдгээр товчийг HealthKit / Health Connect-ийн жинхэнэ алхмаар солино.

## Ажиллуулах

```bash
# Flutter суулгасны дараа (https://docs.flutter.dev/get-started/install)
cd tiny_room
flutter pub get
flutter run          # утас эсвэл emulator холбогдсон байх
flutter test         # тоглоомын логикийн тест
```

## Файлын бүтэц

```
lib/
├── main.dart                   # Апп эхлэх цэг + доод 5 таб
├── models/
│   ├── furniture.dart          # Тавилгын каталог (үнэ, нээгдэх нөхцөл)
│   └── placed_item.dart        # Өрөөнд тавьсан тавилга (x, y, rotation)
├── state/
│   └── game_state.dart         # ❤️ Гол логик: алхам → coin, streak, level, хадгалах
├── services/
│   └── step_service.dart       # LEVEL 2-т HealthKit / Health Connect холбох газар
├── widgets/
│   └── room_view.dart          # Өрөөг зурах (хана, шал, тавилга)
└── screens/
    ├── home_screen.dart        # ① Home: өрөө + алхам + coin
    ├── editor_screen.dart      # ② Room Editor: чирж зөөх, эргүүлэх
    ├── shop_screen.dart        # ③ Shop
    ├── collection_screen.dart  # ④ Collection
    └── profile_screen.dart     # ⑤ Profile: level, streak, room score
test/
├── game_state_test.dart        # coin/streak логикийн тест
└── widget_test.dart            # товч дарах → худалдах → байрлуулах
```

## Тоглоомын дүрэм

| Дүрэм | Утга |
|---|---|
| Coin | 100 алхам = 1 coin (8,000 алхам → 80 coin) |
| Incremental reward | Өчигдөр биш, **өнөөдөр шинээр нэмэгдсэн** алхамд л coin өгнө |
| Өдрийн зорилго | 5,000 алхам → streak +1 |
| Level | 10,000 алхам тутамд +1 |
| 🛋️ Буйдан | 7 хоног дараалсан streak |
| 📚 Номын тавиур | Level 5 |
| 🛏️ Ор | Нийт 50,000 алхам |
| 🐠 Аквариум | 14 хоног дараалсан streak |

Profile дээрх **"Дараагийн өдөр рүү шилжих"** товчоор streak-ийг хүлээлгүйгээр туршиж болно.

## Дараагийн алхам — LEVEL 2 (жинхэнэ алхам)

`lib/services/step_service.dart` доторх comment-ийн дагуу:

1. `pubspec.yaml`-д `health` package нэмэх
2. iOS: HealthKit capability + `NSHealthShareUsageDescription`
3. Android: `android.permission.health.READ_STEPS`
4. `game.syncTodaySteps(await HealthStepService().getTodaySteps())` дуудах

`GameState` нь зөвхөн "өнөөдрийн нийт алхам"-ыг хүлээж авдаг тул тоглоомын логик өөрчлөгдөхгүй.
