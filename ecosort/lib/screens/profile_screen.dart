import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context) async {
    final state = context.read<AppState>();
    final controller = TextEditingController(text: state.user!.name);

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await state.updateName(name);
    }

    controller.dispose();
  }

  Future<void> _reset(BuildContext context) async {
    final state = context.read<AppState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset my progress?'),
        content: const Text(
          'This clears all your sorted items, eco points, badges and '
          'joined challenges. Your account stays.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await state.resetProgress();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress reset.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;

    if (user == null) {
      return const Center(child: Text('Please log in to view your profile.'));
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        dark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F4);

    return SafeArea(
      child: FutureBuilder<int>(
        future: DatabaseHelper.instance.itemCount(user.id!),
        builder: (context, snap) {
          final items = snap.data ?? 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: dark ? Colors.white : Colors.black,
                child: Text(
                  user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: dark ? Colors.black : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  user.email,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              Center(
                child: Text(
                  '${user.points} points · $items items · Level ${user.level}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              _tile(
                cardColor,
                Icons.edit_outlined,
                'Edit name',
                () => _editName(context),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appearance',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'auto',
                          label: Text('Auto'),
                        ),
                        ButtonSegment(
                          value: 'light',
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: 'dark',
                          label: Text('Dark'),
                        ),
                      ],
                      selected: {
                        switch (state.themeMode) {
                          ThemeMode.light => 'light',
                          ThemeMode.dark => 'dark',
                          _ => 'auto',
                        }
                      },
                      onSelectionChanged: (s) {
                        state.setThemeMode(switch (s.first) {
                          'light' => ThemeMode.light,
                          'dark' => ThemeMode.dark,
                          _ => ThemeMode.system,
                        });
                      },
                      showSelectedIcon: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _tile(
                cardColor,
                Icons.restart_alt,
                'Reset my progress',
                () => _reset(context),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: state.logout,
                  child: const Text(
                    'Log out',
                    style: TextStyle(letterSpacing: 1),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(
    Color color,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        leading: Icon(icon, size: 20),
        title: Text(label, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        onTap: onTap,
      ),
    );
  }
}
