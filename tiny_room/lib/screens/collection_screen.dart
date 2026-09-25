import 'package:flutter/material.dart';

import '../models/furniture.dart';
import '../state/game_state.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('FURNITURE  ${game.owned.length}/${furnitureCatalog.length}'),
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          for (final f in furnitureCatalog)
            _CollectionCard(furniture: f, owned: game.isOwned(f)),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final Furniture furniture;
  final bool owned;

  const _CollectionCard({required this.furniture, required this.owned});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: owned ? null : Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            owned ? furniture.emoji : '🔒',
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 4),
          Text(
            owned ? '✓ ${furniture.name}' : furniture.name,
            textAlign: TextAlign.center,
            style: TextStyle(color: owned ? null : Colors.grey),
          ),
        ],
      ),
    );
  }
}
