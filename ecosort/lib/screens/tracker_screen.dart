import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../database/database_helper.dart';
import '../state/app_state.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  Map<String, int> _byType = {};
  List<EcoBadge> _badges = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    final id = state.user!.id!;
    final db = DatabaseHelper.instance;
    final byType = await db.sortedByType(id);
    final badges = await db.badges(id);
    if (mounted) {
      setState(() {
        _byType = byType;
        _badges = badges;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final maxCount =
        _byType.values.isEmpty ? 1 : _byType.values.reduce((a, b) => a > b ? a : b);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text('My eco impact',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1C1C1C) : Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Eco points',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('${user.points}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          height: 1.1)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Level ${user.level}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: user.levelProgress / 100,
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Sorted by type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            if (_byType.isEmpty)
              const Text('Nothing sorted yet — record your first item on the '
                  'Sort screen.',
                  style: TextStyle(color: Colors.grey, fontSize: 13))
            else
              for (final e in _byType.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 70,
                          child: Text(e.key,
                              style: const TextStyle(fontSize: 13))),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: e.value / maxCount,
                            minHeight: 10,
                            backgroundColor: dark
                                ? Colors.white12
                                : const Color(0xFFEFEFEF),
                            valueColor: AlwaysStoppedAnimation(
                                dark ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${e.value}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            const SizedBox(height: 20),
            const Text('Badges',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.85,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [for (final b in _badges) _BadgeTile(badge: b)],
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () async {
                await state.resetProgress();
                await _load();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Progress reset.')));
                }
              },
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Reset my progress'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final EcoBadge badge;

  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: badge.description,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: badge.earned
                ? (dark ? Colors.white : Colors.black)
                : (dark ? const Color(0xFF2A2A2A) : const Color(0xFFE4E4E4)),
            child: Icon(
              badge.earned ? Icons.emoji_events : Icons.lock_outline,
              color: badge.earned
                  ? (dark ? Colors.black : Colors.amber.shade300)
                  : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(badge.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: badge.earned ? null : Colors.grey,
                fontWeight: badge.earned ? FontWeight.w600 : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}
