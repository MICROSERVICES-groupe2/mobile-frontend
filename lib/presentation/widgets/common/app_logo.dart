import 'package:flutter/material.dart';
import '../../../design_tokens/design_tokens.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double textSize;

  const AppLogo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.textSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _DiamondLogoPainter(),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Text(
            'Bank App',
            style: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: textSize,
              fontWeight: DesignTokens.weightBold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _DiamondLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final halfW = size.width / 2;
    final halfH = size.height / 2;

    // Diamond outline points
    final top = Offset(center.dx, center.dy - halfH * 0.85);
    final right = Offset(center.dx + halfW * 0.85, center.dy);
    final bottom = Offset(center.dx, center.dy + halfH * 0.85);
    final left = Offset(center.dx - halfW * 0.85, center.dy);

    // Top triangle (gold gradient)
    final topPath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(left.dx, left.dy)
      ..close();

    final topPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [DesignTokens.gold300, DesignTokens.gold500],
      ).createShader(Rect.fromCenter(center: center, width: size.width, height: size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(topPath, topPaint);

    // Bottom triangle (white/teal subtle)
    final bottomPath = Path()
      ..moveTo(bottom.dx, bottom.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(left.dx, left.dy)
      ..close();

    final bottomPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white70, DesignTokens.teal300],
      ).createShader(Rect.fromCenter(center: center, width: size.width, height: size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(bottomPath, bottomPaint);

    // Center highlight line
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(left, right, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
