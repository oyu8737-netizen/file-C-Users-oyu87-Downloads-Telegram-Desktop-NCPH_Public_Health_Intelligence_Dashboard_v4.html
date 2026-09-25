import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/furniture.dart';
import '../models/placed_item.dart';
import '../state/game_state.dart';

/// Өрөөг зурах widget. Home дээр зөвхөн харуулна,
/// Editor дээр [editable] = true үед тавилгыг чирж зөөнө.
class RoomView extends StatelessWidget {
  final bool editable;
  final PlacedItem? selected;
  final ValueChanged<PlacedItem>? onSelect;

  const RoomView({
    super.key,
    this.editable = false,
    this.selected,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(builder: (context, box) {
          final size = box.maxWidth;
          final itemSize = size * 0.16;

          // Доор байгаа (y их) тавилга урд харагдана.
          final items = [...game.placed]..sort((a, b) => a.y.compareTo(b.y));

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
              if (items.isEmpty)
                Center(
                  child: Text(
                    editable
                        ? 'Доороос тавилга сонгож тавиарай'
                        : 'Өрөө хоосон байна.\nАлхаж coin цуглуулаарай! 🚶',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.brown),
                  ),
                ),
              for (final item in items)
                _buildItem(context, game, item, size, itemSize),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildItem(BuildContext context, GameState game, PlacedItem item,
      double size, double itemSize) {
    final f = furnitureById(item.furnitureId);
    final isSelected = editable && identical(item, selected);

    Widget child = Transform.rotate(
      angle: item.rotation * math.pi / 2,
      child: Text(f.emoji, style: TextStyle(fontSize: itemSize * 0.8)),
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

    if (editable) {
      child = GestureDetector(
        onTap: () => onSelect?.call(item),
        onPanStart: (_) => onSelect?.call(item),
        onPanUpdate: (d) => game.moveItem(
          item,
          item.x + d.delta.dx / size,
          item.y + d.delta.dy / size,
        ),
        onPanEnd: (_) => game.commit(),
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
