import 'package:flutter/material.dart';

import '../services/cloud_service.dart';
import '../state/settings_state.dart';
import '../widgets/room_view.dart';

/// Найзын өрөөг зочлон харах (зөвхөн харах, өөрчлөх боломжгүй).
class FriendRoomScreen extends StatefulWidget {
  final CloudService cloud;
  final FriendEntry friend;

  const FriendRoomScreen(
      {super.key, required this.cloud, required this.friend});

  @override
  State<FriendRoomScreen> createState() => _FriendRoomScreenState();
}

class _FriendRoomScreenState extends State<FriendRoomScreen> {
  late Future<FriendRoom?> _room = widget.cloud.loadFriendRoom(widget.friend.uid);

  @override
  Widget build(BuildContext context) {
    final s = SettingsScope.strings(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.friendRoomTitle(widget.friend.name)),
        actions: [
          IconButton(
            tooltip: s.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _room = widget.cloud.loadFriendRoom(widget.friend.uid);
            }),
          ),
        ],
      ),
      body: FutureBuilder<FriendRoom?>(
        future: _room,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final room = snap.data;
          if (snap.hasError || room == null) {
            return Center(child: Text(s.networkError));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              RoomView(items: room.placed, emptyText: s.friendRoomEmpty),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      _Stat('⭐', 'Lv ${room.level}', s.levelLabel),
                      _Stat('🚶', '${room.todaySteps}', s.today),
                      _Stat('🔥', '${room.streak}', s.streakLabel),
                      _Stat('👣', '${room.totalSteps}', s.totalLabel),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _Stat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
