import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/waste_data.dart';
import '../state/app_state.dart';

class SortingScreen extends StatefulWidget {
  const SortingScreen({super.key});

  @override
  State<SortingScreen> createState() => _SortingScreenState();
}

class _SortingScreenState extends State<SortingScreen> {
  final _scroll = ScrollController();
  WasteType? _selected;
  bool _recorded = false;

  void _select(WasteType w) {
    setState(() {
      _selected = w;
      _recorded = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sortedIt() async {
    final messenger = ScaffoldMessenger.of(context);
    final type = _selected!.key;
    await context.read<AppState>().recordSort(type);
    if (!mounted) return;
    setState(() => _recorded = true);
    messenger.showSnackBar(SnackBar(
      content: Text('+10 eco points! $type recorded.'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF1E1E1E) : const Color(0xFFF2F2F2);
    return SafeArea(
      child: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('What are you throwing away?',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.1,
            children: [
              for (final w in wasteTypes)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selected?.key == w.key
                          ? (dark ? Colors.white : Colors.black)
                          : Colors.transparent,
                      width: 1.6,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _select(w),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Icon(w.icon, size: 26),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(w.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_selected != null) ...[
            const SizedBox(height: 20),
            _guideCard(dark),
          ],
        ],
      ),
    );
  }

  Widget _guideCard(bool dark) {
    final w = _selected!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.4 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(w.label,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: w.binColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(w.bin,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < w.steps.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor:
                        dark ? Colors.white12 : const Color(0xFFEFEFEF),
                    child: Text('${i + 1}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: dark ? Colors.white : Colors.black)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child:
                          Text(w.steps[i], style: const TextStyle(height: 1.3))),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: w.binColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 18, color: w.binColor),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(w.tip,
                        style: const TextStyle(
                            fontSize: 13, height: 1.3))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _recorded ? null : _sortedIt,
              icon: Icon(_recorded ? Icons.check : Icons.done_all),
              label: Text(_recorded ? 'Sorted — nice work!' : 'I sorted it  (+10 pts)'),
            ),
          ),
        ],
      ),
    );
  }
}
