/// Тавилга нээгдэх нэмэлт нөхцөл (үнээс гадна).
enum UnlockType { none, streak, totalSteps, level }

class Furniture {
  final String id;
  final String nameMn;
  final String nameEn;
  final String emoji;
  final int price;
  final UnlockType unlockType;
  final int unlockValue;

  const Furniture({
    required this.id,
    required this.nameMn,
    required this.nameEn,
    required this.emoji,
    required this.price,
    this.unlockType = UnlockType.none,
    this.unlockValue = 0,
  });

  String name(bool mongolian) => mongolian ? nameMn : nameEn;
}

/// Дэлгүүрт байгаа бүх тавилга.
/// Шинэ тавилга нэмэх бол энд нэг мөр нэмэхэд л хангалттай.
const List<Furniture> furnitureCatalog = [
  Furniture(id: 'chair', nameMn: 'Сандал', nameEn: 'Chair', emoji: '🪑', price: 100),
  Furniture(id: 'picture', nameMn: 'Зураг', nameEn: 'Picture', emoji: '🖼️', price: 120),
  Furniture(id: 'plant', nameMn: 'Ургамал', nameEn: 'Plant', emoji: '🪴', price: 150),
  Furniture(id: 'lamp', nameMn: 'Гэрэл', nameEn: 'Lamp', emoji: '💡', price: 200),
  Furniture(id: 'table', nameMn: 'Ширээ', nameEn: 'Table', emoji: '🪵', price: 250),
  Furniture(id: 'teddy', nameMn: 'Баавгай', nameEn: 'Teddy', emoji: '🧸', price: 180),
  Furniture(
    id: 'sofa',
    nameMn: 'Буйдан',
    nameEn: 'Sofa',
    emoji: '🛋️',
    price: 300,
    unlockType: UnlockType.streak,
    unlockValue: 7,
  ),
  Furniture(
    id: 'bookshelf',
    nameMn: 'Номын тавиур',
    nameEn: 'Bookshelf',
    emoji: '📚',
    price: 400,
    unlockType: UnlockType.level,
    unlockValue: 5,
  ),
  Furniture(
    id: 'bed',
    nameMn: 'Ор',
    nameEn: 'Bed',
    emoji: '🛏️',
    price: 500,
    unlockType: UnlockType.totalSteps,
    unlockValue: 50000,
  ),
  Furniture(
    id: 'aquarium',
    nameMn: 'Аквариум',
    nameEn: 'Aquarium',
    emoji: '🐠',
    price: 800,
    unlockType: UnlockType.streak,
    unlockValue: 14,
  ),
];

Furniture? furnitureById(String id) {
  for (final f in furnitureCatalog) {
    if (f.id == id) return f;
  }
  return null;
}

/// Тавилгын будах өнгөнүүд (null = анхны өнгө).
const List<int?> furniturePalette = [
  null,
  0xFFE57373, // улаан
  0xFFFFB74D, // улбар шар
  0xFFFFF176, // шар
  0xFF81C784, // ногоон
  0xFF4FC3F7, // цэнхэр
  0xFF9575CD, // ягаан-нил
  0xFFF06292, // ягаан
  0xFF8D6E63, // бор
  0xFF90A4AE, // саарал
];
