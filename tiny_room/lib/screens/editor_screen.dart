import 'package:flutter/material.dart';

import '../models/furniture.dart';
import '../models/placed_item.dart';
import '../state/game_state.dart';
import '../state/settings_state.dart';
import '../widgets/room_view.dart';

/// Тавилгыг өрөөнд тавих, чирж зөөх, эргүүлэх, будах, буцааж авах.
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
    final s = SettingsScope.strings(context);
    final inventory = game.inventory;
    // Сонгосон зүйл өрөөнөөс хасагдсан бол сонголтыг цуцална.
    final selected = game.placed.contains(_selected) ? _selected : null;
    final selectedF =
        selected == null ? null : furnitureById(selected.furnitureId);

    return Scaffold(
      appBar: AppBar(title: Text(s.editorTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoomView(
            items: game.placed,
            emptyText: s.editorEmpty,
            selected: selected,
            onSelect: (item) => setState(() => _selected = item),
            onMove: game.moveItem,
            onMoveEnd: game.commit,
          ),
          const SizedBox(height: 12),
          if (selected != null && selectedF != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${selectedF.emoji} ${selectedF.name(s.mn)}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  tooltip: s.rotate,
                  icon: const Icon(Icons.rotate_right),
                  onPressed: () => game.rotateItem(selected),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: s.putAway,
                  icon: const Icon(Icons.inventory_2_outlined),
                  onPressed: () {
                    game.removeFromRoom(selected);
                    setState(() => _selected = null);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(s.colorLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            _ColorPicker(
              value: selected.color,
              onChanged: (c) => game.setItemColor(selected, c),
              originalLabel: s.originalColor,
            ),
          ] else
            Text(s.editorHint, textAlign: TextAlign.center),
          const Divider(height: 32),
          Text(s.inventory, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (inventory.isEmpty)
            Text(s.inventoryEmpty)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in inventory)
                  ActionChip(
                    avatar: Text(f.emoji),
                    label: Text(f.name(s.mn)),
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

/// Өнгөний дугуй товчнууд. Эхнийх нь "анхны өнгө".
class _ColorPicker extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  final String originalLabel;

  const _ColorPicker({
    required this.value,
    required this.onChanged,
    required this.originalLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (i, c) in furniturePalette.indexed)
          Tooltip(
            key: ValueKey('color_$i'),
            message: c == null ? originalLabel : '',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onChanged(c),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c == null ? Colors.white : Color(c),
                  border: Border.all(
                    color: value == c ? Colors.deepPurple : Colors.black26,
                    width: value == c ? 3 : 1,
                  ),
                ),
                child: c == null
                    ? const Icon(Icons.format_color_reset, size: 18)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
