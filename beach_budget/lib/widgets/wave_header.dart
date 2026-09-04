import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// คลื่นทะเลซ้อนสามชั้น ใช้เป็นพื้นหลังหัวหน้าจอและหน้าล็อกอิน
class WavePainter extends CustomPainter {
  WavePainter({this.opacity = 1});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    _wave(canvas, size, Beach.foam.withOpacity(.9 * opacity), 0.55, 14, 0);
    _wave(canvas, size, Beach.lagoon.withOpacity(.55 * opacity), 0.68, 12, 1.2);
    _wave(canvas, size, Beach.sea.withOpacity(.75 * opacity), 0.82, 10, 2.4);
  }

  void _wave(Canvas canvas, Size size, Color color, double baseline,
      double amp, double phase) {
    final paint = Paint()..color = color;
    final path = Path()..moveTo(0, size.height);
    final y0 = size.height * baseline;
    path.lineTo(0, y0);
    for (double x = 0; x <= size.width; x += 4) {
      final y = y0 + math.sin((x / size.width * 2 * math.pi) + phase) * amp;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter old) => old.opacity != opacity;
}

/// หัวหน้าจอไล่สีทะเล มีคลื่นจาง ๆ ด้านล่าง
class OceanHeader extends StatelessWidget {
  const OceanHeader({
    super.key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
  });

  final Widget child;
  final double? height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(gradient: Beach.oceanGradient),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: -20,
              height: 90,
              child: CustomPaint(painter: WavePainter(opacity: .28)),
            ),
            SafeArea(
              bottom: false,
              child: Padding(padding: padding, child: child),
            ),
          ],
        ),
      ),
    );
  }
}
