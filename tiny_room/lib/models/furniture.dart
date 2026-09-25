/// Тавилга нээгдэх нэмэлт нөхцөл (үнээс гадна).
enum UnlockType { none, streak, totalSteps, level }

class Furniture {
  final String id;
  final String name;
  final String emoji;
  final int price;
  final UnlockType unlockType;
  final int unlockValue;

  const Furniture({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    this.unlockType = UnlockType.none,
    this.unlockValue = 0,
  });

  /// Түгжээтэй үед харуулах тайлбар.
  String get requirementText {
    switch (unlockType) {
      case UnlockType.none:
        return '';
      case UnlockType.streak:
        return '$unlockValue хоног дараалан идэвхтэй';
      case UnlockType.totalSteps:
        return 'Нийт $unlockValue алхам';
      case UnlockType.level:
        return 'Level $unlockValue';
    }
  }
}

/// Дэлгүүрт байгаа бүх тавилга.
const List<Furniture> furnitureCatalog = [
  Furniture(id: 'chair', name: 'Сандал', emoji: '🪑', price: 100),
  Furniture(id: 'picture', name: 'Зураг', emoji: '🖼️', price: 120),
  Furniture(id: 'plant', name: 'Ургамал', emoji: '🪴', price: 150),
  Furniture(id: 'lamp', name: 'Гэрэл', emoji: '💡', price: 200),
  Furniture(id: 'table', name: 'Ширээ', emoji: '🪵', price: 250),
  Furniture(
    id: 'sofa',
    name: 'Буйдан',
    emoji: '🛋️',
    price: 300,
    unlockType: UnlockType.streak,
    unlockValue: 7,
  ),
  Furniture(
    id: 'bookshelf',
    name: 'Номын тавиур',
    emoji: '📚',
    price: 400,
    unlockType: UnlockType.level,
    unlockValue: 5,
  ),
  Furniture(
    id: 'bed',
    name: 'Ор',
    emoji: '🛏️',
    price: 500,
    unlockType: UnlockType.totalSteps,
    unlockValue: 50000,
  ),
  Furniture(
    id: 'aquarium',
    name: 'Аквариум',
    emoji: '🐠',
    price: 800,
    unlockType: UnlockType.streak,
    unlockValue: 14,
  ),
];

Furniture furnitureById(String id) =>
    furnitureCatalog.firstWhere((f) => f.id == id);
