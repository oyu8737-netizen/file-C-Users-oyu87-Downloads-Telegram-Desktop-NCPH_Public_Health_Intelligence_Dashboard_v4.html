import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/furniture.dart';
import '../state/app_services.dart';
import '../state/game_state.dart';
import '../state/settings_state.dart';
import 'collection_screen.dart';

/// Дэлгүүр ба Цуглуулга — дээд талд хоёр таб.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    final s = SettingsScope.strings(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.shopTitle),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text('🪙 ${game.coins}')),
            ),
          ],
          bottom: TabBar(tabs: [
            Tab(text: s.shopTab),
            Tab(text: s.collectionTab(game.owned.length, furnitureCatalog.length)),
          ]),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _HowToEarn(s: s),
                const SizedBox(height: 8),
                for (final f in furnitureCatalog) ...[
                  _ShopTile(furniture: f),
                  const SizedBox(height: 8),
                ],
              ],
            ),
            const CollectionGrid(),
          ],
        ),
      ),
    );
  }
}

/// Coin хэрхэн олох вэ — дүрмийг хэрэглэгчид тайлбарлана.
class _HowToEarn extends StatelessWidget {
  final S s;

  const _HowToEarn({required this.s});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: ExpansionTile(
        leading: const Text('🪙', style: TextStyle(fontSize: 24)),
        title: Text(s.howToEarn),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.ruleSteps(stepsPerCoin)),
          Text(s.ruleGoal(dailyStepGoal, goalBonusCoins)),
          Text(s.ruleStreak(streakBonusPerDay, streakBonusCap)),
        ],
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
    final s = SettingsScope.strings(context);
    final f = furniture;
    final owned = game.isOwned(f);
    final unlocked = game.isUnlocked(f);

    final Widget trailing;
    if (owned) {
      trailing = Chip(label: Text('✓ ${s.owned}'));
    } else if (!unlocked) {
      trailing = const Icon(Icons.lock_outline);
    } else {
      trailing = FilledButton(
        onPressed: game.canBuy(f)
            ? () {
                game.buy(f);
                AppServices.of(context).cloud?.logPurchase(f.id);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(s.bought(f.emoji, f.name(s.lang))),
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
        title: Text(f.name(s.lang)),
        subtitle: Text(
          unlocked ? s.coins(f.price) : '🔒 ${s.requirement(f)}',
        ),
        trailing: trailing,
      ),
    );
  }
}
