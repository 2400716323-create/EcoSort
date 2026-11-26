import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../database/database_helper.dart';
import '../state/app_state.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Challenge> _challenges = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final id = context.read<AppState>().user!.id!;
    final list = await DatabaseHelper.instance.challenges(id);
    if (mounted) setState(() => _challenges = list);
  }

  Future<void> _join(Challenge c) async {
    final id = context.read<AppState>().user!.id!;
    await DatabaseHelper.instance.joinChallenge(id, c.id);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You joined “${c.title}”.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text('Challenges',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            for (final c in _challenges)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      dark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (c.progress / c.goal).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: dark
                            ? Colors.white12
                            : const Color(0xFFE0E0E0),
                        valueColor: AlwaysStoppedAnimation(
                            dark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                        c.joined
                            ? 'Progress: ${c.progress > c.goal ? c.goal : c.progress}/${c.goal}'
                            : 'Progress: 0/${c.goal}',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 10),
                    if (c.joined)
                      OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(
                            c.progress >= c.goal
                                ? 'Completed'
                                : 'Joined',
                            style: const TextStyle(fontSize: 13)),
                      )
                    else
                      FilledButton(
                        onPressed: () => _join(c),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Join',
                            style: TextStyle(fontSize: 13)),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
