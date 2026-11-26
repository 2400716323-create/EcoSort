import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'centers_screen.dart';
import 'challenges_screen.dart';
import 'profile_screen.dart';
import 'sorting_screen.dart';
import 'tracker_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EcoSort',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: EcoDrawer(
        onSelect: (i) => setState(() => _index = i),
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          SortingScreen(),
          CentersScreen(),
          TrackerScreen(),
          ChallengesScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sort_outlined),
            activeIcon: Icon(Icons.sort),
            label: 'Sort',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place_outlined),
            activeIcon: Icon(Icons.place),
            label: 'Centers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Challenges',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class EcoDrawer extends StatelessWidget {
  final void Function(int tab) onSelect;

  const EcoDrawer({super.key, required this.onSelect});

  void _go(BuildContext context, int tab) {
    Navigator.pop(context);
    onSelect(tab);
  }

  void _about(BuildContext context) {
    Navigator.pop(context);

    showAboutDialog(
      context: context,
      applicationName: 'EcoSort',
      applicationIcon: const Icon(Icons.recycling, size: 40),
      applicationVersion: '1.0',
      applicationLegalese:
          'Smart Waste Management App\n'
          'Makerere University Business School\n'
          'Bachelor of Business Computing',
      children: const [
        SizedBox(height: 12),
        Text(
          'EcoSort tells you how to sort your waste, where to take it '
          'for recycling and rewards every eco-friendly action with '
          'points and badges.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: dark ? const Color(0xFF1C1C1C) : Colors.black,
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 24,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Text(
                      user != null && user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Guest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _item(context, Icons.sort, 'Sort Guide', () => _go(context, 0)),
          _item(context, Icons.place, 'Recycling Centers',
              () => _go(context, 1)),
          _item(context, Icons.show_chart, 'Eco-Tracker',
              () => _go(context, 2)),
          _item(context, Icons.emoji_events, 'Challenges',
              () => _go(context, 3)),
          _item(context, Icons.person, 'Profile & Settings',
              () => _go(context, 4)),
          _item(context, Icons.info_outline, 'About EcoSort',
              () => _about(context)),
          const Spacer(),
          const Divider(height: 1),
          _item(context, Icons.logout, 'Log out', () {
            Navigator.pop(context);
            state.logout();
          }, bottom: true),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool bottom = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(20, 0, 20, bottom ? 16 : 0),
      leading: Icon(icon, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
    );
  }
}
