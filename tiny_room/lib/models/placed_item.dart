/// Өрөөнд байрлуулсан нэг тавилга.
/// [x], [y] нь 0..1 хооронд — өрөөний өргөн/өндөртэй харьцуулсан байрлал,
/// тиймээс ямар ч дэлгэцийн хэмжээнд зөв харагдана.
class PlacedItem {
  final String furnitureId;
  double x;
  double y;

  /// Эргэлт, 90° алхамтай (0, 1, 2, 3).
  int rotation;

  PlacedItem({
    required this.furnitureId,
    this.x = 0.5,
    this.y = 0.7,
    this.rotation = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': furnitureId,
        'x': x,
        'y': y,
        'r': rotation,
      };

  factory PlacedItem.fromJson(Map<String, dynamic> json) => PlacedItem(
        furnitureId: json['id'] as String,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        rotation: json['r'] as int? ?? 0,
      );
}
