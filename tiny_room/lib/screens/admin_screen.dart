import 'package:flutter/material.dart';

import '../services/cloud_service.dart';
import '../state/settings_state.dart';
import '../widgets/bar_chart.dart';

/// Зөвхөн admin (Firestore-ийн `admins/{uid}` баримттай хүн) харна:
/// хэдэн хүн бүртгүүлсэн, өнөөдөр хэд нь идэвхтэй байсан гэх мэт.
class AdminScreen extends StatefulWidget {
  final CloudService cloud;

  const AdminScreen({super.key, required this.cloud});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<AdminStats> _stats = widget.cloud.adminStats();

  @override
  Widget build(BuildContext context) {
    final s = SettingsScope.strings(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.adminTitle),
        actions: [
          IconButton(
            tooltip: s.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                setState(() => _stats = widget.cloud.adminStats()),
          ),
        ],
      ),
      body: FutureBuilder<AdminStats>(
        future: _stats,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('${s.networkError}\n\n${snap.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          final st = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.6,
                children: [
                  _Tile(s.statTotalUsers, st.totalUsers, Icons.people),
                  _Tile(s.statActiveToday, st.activeToday, Icons.today),
                  _Tile(s.statActive7, st.active7Days, Icons.date_range),
                  _Tile(s.statNewToday, st.newToday, Icons.person_add),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Text('👣', style: TextStyle(fontSize: 24)),
                  title: Text(s.stepsCount(st.totalSteps)),
                  subtitle: Text(s.statAllSteps),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.statSignups7, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      SimpleBarChart(
                        values: [for (final e in st.signupsByDay) e.value],
                        labels: [
                          for (final e in st.signupsByDay)
                            s.weekday(DateTime.parse(e.key))
                        ],
                        tooltip: (v) => s.peopleCount(v),
                        height: 100,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(s.adminConsoleHint, style: theme.textTheme.bodySmall),
            ],
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _Tile(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            Text('$value', style: theme.textTheme.headlineMedium),
            Text(label,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
