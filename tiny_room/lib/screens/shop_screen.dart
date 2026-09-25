import 'package:flutter/material.dart';

import '../models/furniture.dart';
import '../state/game_state.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SHOP'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('🪙 ${game.coins}')),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: furnitureCatalog.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => _ShopTile(furniture: furnitureCatalog[i]),
      ),
    );
  }
}

class _ShopTile extends StatelessWidget {
  final Furniture furniture;

  const _ShopTile({required this.furniture});

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    final f = furniture;
    final owned = game.isOwned(f);
    final unlocked = game.isUnlocked(f);

    final Widget trailing;
    if (owned) {
      trailing = const Chip(label: Text('✓ Байгаа'));
    } else if (!unlocked) {
      trailing = const Icon(Icons.lock_outline);
    } else {
      trailing = FilledButton(
        onPressed: game.canBuy(f)
            ? () {
                game.buy(f);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text('${f.emoji} ${f.name} авлаа! Өрөөндөө тавиарай.'),
                  ));
              }
            : null,
        child: Text('${f.price} 🪙'),
      );
    }

    return Card(
      child: ListTile(
        leading: Opacity(
          opacity: unlocked ? 1 : 0.35,
          child: Text(f.emoji, style: const TextStyle(fontSize: 32)),
        ),
        title: Text(f.name),
        subtitle: Text(
          unlocked ? '${f.price} coin' : '🔒 ${f.requirementText}',
        ),
        trailing: trailing,
      ),
    );
  }
}
