import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models.dart';
import '../database/database_helper.dart';
import '../widgets/placeholder_map.dart';

class CentersScreen extends StatefulWidget {
  const CentersScreen({super.key});

  @override
  State<CentersScreen> createState() => _CentersScreenState();
}

class _CentersScreenState extends State<CentersScreen> {
  List<RecyclingCenter> _centers = [];

  static const _userLat = 0.3100;
  static const _userLng = 32.5780;

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.centers().then((c) {
      if (mounted) setState(() => _centers = c);
    });
  }

  Future<void> _directions(RecyclingCenter center) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${center.lat},${center.lng}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open maps app.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('Recycling centers',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: PlaceholderMap(
              userLat: _userLat,
              userLng: _userLng,
              pins: [for (final c in _centers) (c.lat, c.lng)],
              onPinTap: (i) {
                if (i < _centers.length) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_centers[i].name)));
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          for (final c in _centers)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            '${c.name}  ·  ${c.distanceKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      SizedBox(
                        height: 34,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () => _directions(c),
                          child: const Text('Directions',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(c.hours,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final m in c.materials)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (dark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(m,
                              style: const TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
