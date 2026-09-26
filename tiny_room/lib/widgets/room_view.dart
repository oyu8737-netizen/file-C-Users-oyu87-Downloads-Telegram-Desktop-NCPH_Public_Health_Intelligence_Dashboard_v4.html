import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/furniture.dart';
import '../models/placed_item.dart';

/// Өрөөг зурах widget.
/// - Home болон найзын өрөөнд: зөвхөн харуулна.
/// - Editor дээр [onMove] өгвөл тавилгыг чирж зөөнө.
class RoomView extends StatelessWidget {
  final List<PlacedItem> items;
  final String emptyText;
  final PlacedItem? selected;
  final ValueChanged<PlacedItem>? onSelect;

  /// Чирэх үед (item, шинэ x, шинэ y).
  final void Function(PlacedItem item, double x, double y)? onMove;
  final VoidCallback? onMoveEnd;

  const RoomView({
    super.key,
    required this.items,
    this.emptyText = '',
    this.selected,
    this.onSelect,
    this.onMove,
    this.onMoveEnd,
  });

  bool get _editable => onMove != null;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(builder: (context, box) {
          final size = box.maxWidth;
          final itemSize = size * 0.16;

          // Доор байгаа (y их) тавилга урд харагдана.
          final sorted = [...items]..sort((a, b) => a.y.compareTo(b.y));

          return Stack(
            children: [
              // Хана
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFE8D6), Color(0xFFFFD6BA)],
                    ),
                  ),
                ),
              ),
              // Шал
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: size * 0.55,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFC89F7C), Color(0xFFA47551)],
                    ),
                  ),
                ),
              ),
              // Цонх
              Positioned(
                left: size * 0.08,
                top: size * 0.08,
                child: Text('🪟', style: TextStyle(fontSize: size * 0.14)),
              ),
              if (sorted.isEmpty && emptyText.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      emptyText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.brown),
                    ),
                  ),
                ),
              for (final item in sorted) _buildItem(item, size, itemSize),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildItem(PlacedItem item, double size, double itemSize) {
    final f = furnitureById(item.furnitureId);
    if (f == null) return const SizedBox.shrink();
    final isSelected = _editable && identical(item, selected);

    Widget child = FurnitureIcon(
      emoji: f.emoji,
      color: item.color,
      size: itemSize * 0.8,
      rotation: item.rotation,
    );

    child = Container(
      width: itemSize,
      height: itemSize,
      alignment: Alignment.center,
      decoration: isSelected
          ? BoxDecoration(
              border: Border.all(color: Colors.deepPurple, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white24,
            )
          : null,
      child: child,
    );

    if (_editable) {
      child = GestureDetector(
        onTap: () => onSelect?.call(item),
        onPanStart: (_) => onSelect?.call(item),
        onPanUpdate: (d) => onMove!(
          item,
          item.x + d.delta.dx / size,
          item.y + d.delta.dy / size,
        ),
        onPanEnd: (_) => onMoveEnd?.call(),
        child: child,
      );
    }

    return Positioned(
      left: item.x * size - itemSize / 2,
      top: item.y * size - itemSize / 2,
      child: child,
    );
  }
}

/// Тавилгын дүрс. [color] өгвөл тавилгыг тэр өнгөөр "будна".
///
/// Эмодзиг эхлээд хар-цагаан (гэрэл сүүдэр) болгоод, дараа нь сонгосон
/// өнгөөр үржүүлнэ — гэрэл сүүдэр нь хадгалагдаж жинхэнэ будсан юм шиг
/// харагдана. Тунгалаг хэсэг тунгалаг хэвээр үлдэнэ.
class FurnitureIcon extends StatelessWidget {
  final String emoji;
  final int? color;
  final double size;
  final int rotation;

  const FurnitureIcon({
    super.key,
    required this.emoji,
    this.color,
    required this.size,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Text(emoji, style: TextStyle(fontSize: size));
    if (color != null) {
      child = ColorFiltered(colorFilter: _tint(color!), child: child);
    }
    if (rotation != 0) {
      child = Transform.rotate(angle: rotation * math.pi / 2, child: child);
    }
    return child;
  }

  static ColorFilter _tint(int argb) {
    const k = 1.5; // тод байлгах
    final r = ((argb >> 16) & 0xFF) / 255 * k;
    final g = ((argb >> 8) & 0xFF) / 255 * k;
    final b = (argb & 0xFF) / 255 * k;
    // Гэрэлтэлт (luminance) = 0.2126 R + 0.7152 G + 0.0722 B
    List<double> row(double c) => [0.2126 * c, 0.7152 * c, 0.0722 * c, 0, 0];
    return ColorFilter.matrix([
      ...row(r),
      ...row(g),
      ...row(b),
      0, 0, 0, 1, 0, // тунгалаг байдал өөрчлөгдөхгүй
    ]);
  }
}
