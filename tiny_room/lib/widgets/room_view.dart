import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/furniture.dart';
import '../models/placed_item.dart';
import '../state/settings_state.dart';

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
    final vibe = SettingsScope.vibe(context);
    const floorTop = 0.45; // хана 45%, шал 55%

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
              Positioned.fill(child: _gradient(vibe.wall)),
              // Шал
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: size * (1 - floorTop),
                child: _gradient(vibe.floor),
              ),
              // Хана, шалны заагт үндэсний хээ (Монгол алхан хээ / 回纹)
              if (vibe.patternColor != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: size * floorTop - size * 0.035,
                  height: size * 0.035,
                  child: CustomPaint(
                      painter: MeanderPainter(color: vibe.patternColor!)),
                ),
              // Цонх — гадаа нь тухайн улсын байгаль
              Positioned(
                left: size * 0.07,
                top: size * 0.07,
                width: size * 0.26,
                height: size * 0.22,
                child: _Window(view: vibe.windowView),
              ),
              // Хананы чимэглэл
              for (final d in vibe.decor)
                Positioned(
                  left: d.x * size - d.size * size / 2,
                  top: d.y * size,
                  child: Text(d.emoji,
                      style: TextStyle(fontSize: d.size * size)),
                ),
              if (sorted.isEmpty && emptyText.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  top: size * (floorTop + 0.12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      emptyText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black45)]),
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

  static Widget _gradient(List<Color> colors) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
      );

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

/// Цонх: цагаан хүрээ, загалмай, гадаа нь [view] (уул, бороо, хулс...).
class _Window extends StatelessWidget {
  final String view;

  const _Window({required this.view});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF81D4FA), Color(0xFFE1F5FE)],
          ),
          border: Border.all(color: Colors.white, width: w * 0.06),
          borderRadius: BorderRadius.circular(w * 0.06),
          boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black26)],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(view, style: TextStyle(fontSize: w * 0.42)),
            // Цонхны загалмай
            Container(width: w * 0.04, color: Colors.white),
            Container(height: w * 0.04, color: Colors.white),
          ],
        ),
      );
    });
  }
}

/// Давтагдах "түлхүүр" хээ — Монголын алхан хээ, Хятадын 回纹 хоёулаа
/// энэ хэлбэртэй. Нэг нүд = өндөртэйгөө тэнцүү квадрат.
class MeanderPainter extends CustomPainter {
  final Color color;

  const MeanderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.12
      ..strokeCap = StrokeCap.square;
    final path = Path();
    for (var x = 0.0; x < size.width; x += h) {
      path
        ..moveTo(x, h * 0.94)
        ..lineTo(x, h * 0.06)
        ..lineTo(x + h * 0.8, h * 0.06)
        ..lineTo(x + h * 0.8, h * 0.66)
        ..lineTo(x + h * 0.36, h * 0.66)
        ..lineTo(x + h * 0.36, h * 0.36);
    }
    path
      ..moveTo(0, h * 0.94)
      ..lineTo(size.width, h * 0.94);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MeanderPainter old) => old.color != color;
}
