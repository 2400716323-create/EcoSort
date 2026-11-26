import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Stylised map matching the wireframe: a light panel with pins positioned
/// from each center's coordinates and a blue dot for the user's location.
class PlaceholderMap extends StatelessWidget {
  final double userLat;
  final double userLng;
  final List<(double, double)> pins;
  final void Function(int index)? onPinTap;

  const PlaceholderMap({
    super.key,
    required this.userLat,
    required this.userLng,
    required this.pins,
    this.onPinTap,
  });

  static const _minLat = 0.285, _maxLat = 0.355;
  static const _minLng = 32.540, _maxLng = 32.625;

  Offset _project((double, double) p, Size size) {
    final x = ((p.$2 - _minLng) / (_maxLng - _minLng)).clamp(0.05, 0.95);
    final y = (1 - (p.$1 - _minLat) / (_maxLat - _minLat)).clamp(0.08, 0.92);
    return Offset(x * size.width, y * size.height);
  }

  @override
  Widget build(BuildContext context) {
    final size = const Size(400, 220);
    final projected = pins.map((p) => _project(p, size)).toList();
    final user = _project((userLat, userLng), size);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(builder: (context, box) {
      return GestureDetector(
        onTapUp: (d) {
          if (onPinTap == null) return;
          final sx = d.localPosition.dx / box.maxWidth * size.width;
          final sy = d.localPosition.dy / box.maxHeight * size.height;
          var best = -1;
          var bestDist = 30.0;
          for (var i = 0; i < projected.length; i++) {
            final dx = projected[i].dx - sx;
            final dy = projected[i].dy - sy;
            final dist = dx * dx + dy * dy;
            if (dist < bestDist * bestDist) {
              bestDist = math.sqrt(dist);
              best = i;
            }
          }
          if (best >= 0) onPinTap!(best);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(
            painter: _MapPainter(
                pins: projected,
                user: user,
                dark: dark,
                target: size),
            size: Size(box.maxWidth, box.maxHeight),
          ),
        ),
      );
    });
  }
}

class _MapPainter extends CustomPainter {
  final List<Offset> pins;
  final Offset user;
  final bool dark;
  final Size target;

  _MapPainter({
    required this.pins,
    required this.user,
    required this.dark,
    required this.target,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / target.width;
    final sy = size.height / target.height;

    final bg = Paint()
      ..color = dark ? const Color(0xFF24321F) : const Color(0xFFDCE9D5);
    canvas.drawRect(Offset.zero & size, bg);

    final road = Paint()
      ..color = (dark ? Colors.white : Colors.black).withValues(alpha: 0.07)
      ..strokeWidth = 10;
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(Offset(0, size.height * i / 4),
          Offset(size.width, size.height * i / 4), road);
      canvas.drawLine(Offset(size.width * i / 4, 0),
          Offset(size.width * i / 4, size.height), road);
    }
    final river = Paint()
      ..color = (dark ? Colors.blue : Colors.blueGrey).withValues(alpha: 0.18)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.55, size.width,
          size.height * 0.85);
    canvas.drawPath(path, river);

    for (final p in pins) {
      final c = Offset(p.dx * sx, p.dy * sy);
      canvas.drawCircle(
          Offset(c.dx, c.dy + 3), 6, Paint()..color = Colors.black26);
      canvas.drawCircle(c, 7, Paint()..color = dark ? Colors.white : Colors.black);
      canvas.drawCircle(c, 3,
          Paint()..color = dark ? Colors.black : Colors.white);
    }

    final u = Offset(user.dx * sx, user.dy * sy);
    canvas.drawCircle(u, 12,
        Paint()..color = Colors.blue.withValues(alpha: 0.25));
    canvas.drawCircle(u, 6, Paint()..color = Colors.blue);
    canvas.drawCircle(u, 6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => true;
}
