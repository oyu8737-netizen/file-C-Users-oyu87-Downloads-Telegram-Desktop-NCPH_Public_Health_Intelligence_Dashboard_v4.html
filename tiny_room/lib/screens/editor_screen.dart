import 'package:flutter/material.dart';

import '../models/furniture.dart';
import '../models/placed_item.dart';
import '../state/game_state.dart';
import '../widgets/room_view.dart';

/// Тавилгыг өрөөнд тавих, чирж зөөх, эргүүлэх, буцааж авах.
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  PlacedItem? _selected;

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    final inventory = game.inventory;
    // Сонгосон зүйл өрөөнөөс хасагдсан бол сонголтыг цуцална.
    final selected = game.placed.contains(_selected) ? _selected : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Өрөө засах'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoomView(
            editable: true,
            selected: selected,
            onSelect: (item) => setState(() => _selected = item),
          ),
          const SizedBox(height: 12),
          if (selected != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${furnitureById(selected.furnitureId).emoji} '
                  '${furnitureById(selected.furnitureId).name}',
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  tooltip: 'Эргүүлэх',
                  icon: const Icon(Icons.rotate_right),
                  onPressed: () => game.rotateItem(selected),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Өрөөнөөс авах',
                  icon: const Icon(Icons.inventory_2_outlined),
                  onPressed: () {
                    game.removeFromRoom(selected);
                    setState(() => _selected = null);
                  },
                ),
              ],
            )
          else
            const Text(
              'Тавилга дээр дарж сонгоод, чирж зөөнө.',
              textAlign: TextAlign.center,
            ),
          const Divider(height: 32),
          Text('Миний агуулах', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (inventory.isEmpty)
            const Text('Агуулах хоосон. Дэлгүүрээс тавилга аваарай 🛒')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in inventory)
                  ActionChip(
                    avatar: Text(f.emoji),
                    label: Text(f.name),
                    onPressed: () {
                      game.placeItem(f.id);
                      setState(() => _selected = game.placed.last);
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
