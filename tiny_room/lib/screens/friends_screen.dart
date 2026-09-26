import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/cloud_service.dart';
import '../state/app_services.dart';
import '../state/settings_state.dart';
import 'friend_room_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SettingsScope.strings(context);
    final cloud = AppServices.of(context).cloud;

    return Scaffold(
      appBar: AppBar(title: Text(s.friendsTitle), centerTitle: true),
      body: cloud == null
          ? _Message(icon: Icons.cloud_off, text: s.needsFirebase)
          : ListenableBuilder(
              listenable: cloud,
              builder: (context, _) {
                if (!cloud.signedIn) {
                  return _Message(
                    icon: Icons.person_outline,
                    text: s.friendsNeedAccount,
                    action: FilledButton(
                      onPressed: () =>
                          SettingsScope.of(context).setAuthSkipped(false),
                      child: Text(s.signIn),
                    ),
                  );
                }
                return _FriendsBody(cloud: cloud);
              },
            ),
    );
  }
}

class _FriendsBody extends StatefulWidget {
  final CloudService cloud;

  const _FriendsBody({required this.cloud});

  @override
  State<_FriendsBody> createState() => _FriendsBodyState();
}

class _FriendsBodyState extends State<_FriendsBody> {
  final _codeController = TextEditingController();
  late final Stream<List<FriendEntry>> _friends = widget.cloud.friends();
  bool _busy = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final s = SettingsScope.strings(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    String message;
    try {
      final result = await widget.cloud.addFriendByCode(_codeController.text);
      message = switch (result) {
        AddFriendResult.added => s.friendAdded,
        AddFriendResult.notFound => s.friendNotFound,
        AddFriendResult.self => s.friendSelf,
        AddFriendResult.already => s.friendAlready,
      };
      if (result == AddFriendResult.added) _codeController.clear();
    } catch (e) {
      message = s.networkError;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final s = SettingsScope.strings(context);
    final code = widget.cloud.profile?.friendCode ?? '…';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Миний код — найздаа илгээнэ.
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: ListTile(
            leading: const Icon(Icons.qr_code_2, size: 36),
            title: Text(s.myFriendCode),
            subtitle: Text(code,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(letterSpacing: 4)),
            trailing: IconButton(
              tooltip: s.copy,
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(s.copied)));
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(s.shareCodeHint,
              style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(height: 8),
        // Найз нэмэх
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: s.friendCodeInput,
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.person_add),
              label: Text(s.add),
              onPressed: _busy ? null : _add,
            ),
          ],
        ),
        const Divider(height: 32),
        Text(s.myFriends, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        StreamBuilder<List<FriendEntry>>(
          stream: _friends,
          builder: (context, snap) {
            if (snap.hasError) return Text(s.networkError);
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final friends = snap.data!;
            if (friends.isEmpty) return Text(s.noFriends);
            return Column(
              children: [
                for (final f in friends)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(f.name.isEmpty
                            ? '?'
                            : f.name.characters.first.toUpperCase()),
                      ),
                      title: Text(f.name),
                      subtitle: Text(s.visitRoom),
                      trailing: PopupMenuButton<String>(
                        onSelected: (_) => _confirmRemove(f),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                              value: 'remove', child: Text(s.removeFriend)),
                        ],
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FriendRoomScreen(
                              cloud: widget.cloud, friend: f),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _confirmRemove(FriendEntry f) async {
    final s = SettingsScope.strings(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.removeFriendQ(f.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.removeFriend)),
        ],
      ),
    );
    if (ok == true) await widget.cloud.removeFriend(f.uid);
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;

  const _Message({required this.icon, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
