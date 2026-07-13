import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sudan_goods/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth illustration helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the recommended illustration height for auth screens.
/// Deliberately smaller than onboarding (22–28 % of screen height).
double authIllustrationHeight(BuildContext context) {
  final h = MediaQuery.sizeOf(context).height;
  if (h < 600) return h * 0.18;
  if (h < 680) return h * 0.22;
  return h * 0.26;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign-in illustration: floating shopping bag with a glowing lock badge
// ─────────────────────────────────────────────────────────────────────────────

class SignInIllustration extends StatelessWidget {
  const SignInIllustration({super.key, this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SignInPainter(),
      ),
    );
  }
}

class _SignInPainter extends CustomPainter {
  static const _orange = AppColors.primary;
  static const _deep   = Color(0xFFE85500);
  static const _accent = Color(0xFFFF7A20);
  static const _light  = Color(0xFFFFEAD4);
  static const _cream  = Color(0xFFFFF3E8);
  static const _white  = Colors.white;
  static const _dark   = Color(0xFF2D1A0E);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Ambient glow blob ──────────────────────────────────────
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.50),
      w * 0.46,
      Paint()
        ..shader = RadialGradient(
          colors: [_orange.withValues(alpha: 0.15), _accent.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: Offset(w * 0.50, h * 0.50), radius: w * 0.46)),
    );

    // ── 2. Door frame (left side) ─────────────────────────────────
    final doorFrameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.18, w * 0.50, h * 0.72),
      Radius.circular(w * 0.06),
    );
    // Frame shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.22, w * 0.50, h * 0.72),
        Radius.circular(w * 0.06),
      ),
      Paint()
        ..color = _deep.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    // Frame fill
    canvas.drawRRect(
      doorFrameRect,
      Paint()
        ..shader = LinearGradient(
          colors: [_accent, _orange, _deep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.45, 1.0],
        ).createShader(doorFrameRect.outerRect),
    );
    // Frame inner highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.18, w * 0.50, h * 0.16),
        Radius.circular(w * 0.06),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [_white.withValues(alpha: 0.30), _white.withValues(alpha: 0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(w * 0.10, h * 0.18, w * 0.50, h * 0.16)),
    );

    // ── 3. Door panel (open, swung inward — perspective trapezoid) ─
    final doorPath = Path()
      ..moveTo(w * 0.14, h * 0.22)   // top-left
      ..lineTo(w * 0.56, h * 0.22)   // top-right (hinge)
      ..lineTo(w * 0.56, h * 0.86)   // bottom-right
      ..lineTo(w * 0.14, h * 0.86)   // bottom-left
      ..close();
    // Panel shadow (depth)
    canvas.drawPath(
      doorPath,
      Paint()
        ..color = _dark.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 6),
    );
    // Panel fill — lighter gradient
    canvas.drawPath(
      doorPath,
      Paint()
        ..shader = LinearGradient(
          colors: [_light, _cream],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(w * 0.14, h * 0.22, w * 0.42, h * 0.64)),
    );
    // Panel decorative inset rectangle
    final insetRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.30, w * 0.28, h * 0.20),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(
      insetRect,
      Paint()
        ..color = _orange.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      insetRect,
      Paint()
        ..color = _orange.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012,
    );
    final insetRect2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.56, w * 0.28, h * 0.20),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(
      insetRect2,
      Paint()
        ..color = _orange.withValues(alpha: 0.10)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      insetRect2,
      Paint()
        ..color = _orange.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012,
    );

    // ── 4. Doorknob / keyhole on door ─────────────────────────────
    final knobCx = w * 0.50;
    final knobCy = h * 0.55;
    canvas.drawCircle(
      Offset(knobCx, knobCy),
      w * 0.045,
      Paint()
        ..shader = RadialGradient(
          colors: [_accent, _deep],
        ).createShader(Rect.fromCircle(center: Offset(knobCx, knobCy), radius: w * 0.045)),
    );
    canvas.drawCircle(
      Offset(knobCx, knobCy),
      w * 0.020,
      Paint()..color = _white.withValues(alpha: 0.70),
    );

    // ── 5. Person walking in (right side of door) ─────────────────
    // Legs — two rounded lines striding right→left (entering)
    final legPaint = Paint()
      ..color = _deep
      ..strokeWidth = w * 0.060
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // Back leg
    canvas.drawLine(
      Offset(w * 0.72, h * 0.62),
      Offset(w * 0.66, h * 0.88),
      legPaint,
    );
    // Front leg (striding forward)
    canvas.drawLine(
      Offset(w * 0.72, h * 0.62),
      Offset(w * 0.80, h * 0.88),
      legPaint,
    );

    // Torso
    final torsoPaint = Paint()
      ..shader = LinearGradient(
        colors: [_accent, _orange],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.64, h * 0.42, w * 0.16, h * 0.22));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.64, h * 0.42, w * 0.16, h * 0.22),
        Radius.circular(w * 0.04),
      ),
      torsoPaint,
    );

    // Arms — one extended forward (toward door)
    final armPaint = Paint()
      ..color = _accent
      ..strokeWidth = w * 0.050
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // Arm reaching forward (toward door)
    canvas.drawLine(
      Offset(w * 0.67, h * 0.48),
      Offset(w * 0.58, h * 0.56),
      armPaint,
    );
    // Arm back
    canvas.drawLine(
      Offset(w * 0.79, h * 0.48),
      Offset(w * 0.86, h * 0.58),
      armPaint,
    );

    // Head
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.36),
      w * 0.082,
      Paint()
        ..shader = RadialGradient(
          colors: [_cream, _light],
          center: const Alignment(-0.3, -0.3),
        ).createShader(
          Rect.fromCircle(center: Offset(w * 0.72, h * 0.36), radius: w * 0.082),
        ),
    );
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.36),
      w * 0.082,
      Paint()
        ..color = _accent.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.016,
    );

    // ── 6. Motion lines (person walking toward door) ──────────────
    final motionPaint = Paint()
      ..color = _orange.withValues(alpha: 0.35)
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.88, h * 0.40), Offset(w * 0.96, h * 0.40), motionPaint);
    canvas.drawLine(Offset(w * 0.90, h * 0.50), Offset(w * 0.97, h * 0.50), motionPaint);
    canvas.drawLine(Offset(w * 0.88, h * 0.60), Offset(w * 0.96, h * 0.60), motionPaint);

    // ── 7. Sparkles ───────────────────────────────────────────────
    _drawSparkle(canvas, Offset(w * 0.10, h * 0.12), w * 0.024, _accent, 0.65);
    _drawSparkle(canvas, Offset(w * 0.84, h * 0.12), w * 0.018, _orange, 0.50);
    _drawSparkle(canvas, Offset(w * 0.08, h * 0.82), w * 0.016, _deep,   0.40);
  }

  void _drawSparkle(
    Canvas canvas,
    Offset center,
    double r,
    Color color,
    double opacity,
  ) {
    final p = Paint()..color = color.withValues(alpha: opacity);
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 0.30, height: r * 1.10),
        p,
      );
      canvas.restore();
    }
    canvas.drawCircle(center, r * 0.20, Paint()..color = color.withValues(alpha: opacity));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign-up illustration: person silhouette with sparkles and a star badge
// ─────────────────────────────────────────────────────────────────────────────

class SignUpIllustration extends StatelessWidget {
  const SignUpIllustration({super.key, this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SignUpPainter(),
      ),
    );
  }
}

class _SignUpPainter extends CustomPainter {
  static const _orange  = AppColors.primary;
  static const _deep    = Color(0xFFE85500);
  static const _accent  = Color(0xFFFF7A20);
  static const _light   = Color(0xFFFFEAD4);
  static const _cream   = Color(0xFFFFF3E8);
  static const _white   = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Background blob ────────────────────────────────────────
    final blobPaint = Paint()
      ..shader = RadialGradient(
        colors: [_accent.withValues(alpha: 0.20), _orange.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.52), radius: w * 0.46));
    canvas.drawCircle(Offset(w * 0.5, h * 0.52), w * 0.46, blobPaint);

    // ── 2. Body / torso platform ──────────────────────────────────
    // Torso shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.19, h * 0.52, w * 0.62, h * 0.38),
        Radius.circular(w * 0.14),
      ),
      Paint()
        ..color = _deep.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Torso fill
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.17, h * 0.50, w * 0.66, h * 0.38),
      Radius.circular(w * 0.14),
    );
    canvas.drawRRect(
      torsoRect,
      Paint()
        ..shader = LinearGradient(
          colors: [_accent, _orange, _deep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ).createShader(torsoRect.outerRect),
    );

    // Torso highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.17, h * 0.50, w * 0.66, h * 0.14),
        Radius.circular(w * 0.14),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [_white.withValues(alpha: 0.26), _white.withValues(alpha: 0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(w * 0.17, h * 0.50, w * 0.66, h * 0.14)),
    );

    // ── 3. Head ───────────────────────────────────────────────────
    // Head shadow
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.33),
      w * 0.185,
      Paint()
        ..color = _deep.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Head fill
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.31),
      w * 0.175,
      Paint()
        ..shader = RadialGradient(
          colors: [_cream, _light],
          center: const Alignment(-0.3, -0.3),
        ).createShader(
          Rect.fromCircle(center: Offset(w * 0.50, h * 0.31), radius: w * 0.175),
        ),
    );

    // Head rim
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.31),
      w * 0.175,
      Paint()
        ..color = _accent.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.018,
    );

    // Simple face — two eyes
    final eyePaint = Paint()..color = _deep.withValues(alpha: 0.70);
    canvas.drawCircle(Offset(w * 0.435, h * 0.29), w * 0.022, eyePaint);
    canvas.drawCircle(Offset(w * 0.565, h * 0.29), w * 0.022, eyePaint);

    // Smile
    final smilePaint = Paint()
      ..color = _orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.030
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(w * 0.418, h * 0.330)
      ..quadraticBezierTo(w * 0.500, h * 0.370, w * 0.582, h * 0.330);
    canvas.drawPath(smilePath, smilePaint);

    // ── 4. Plus / add badge (top-right) ──────────────────────────
    final badgeCx = w * 0.76;
    final badgeCy = h * 0.18;
    final br = w * 0.13;

    canvas.drawCircle(
      Offset(badgeCx, badgeCy + 3),
      br,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawCircle(
      Offset(badgeCx, badgeCy),
      br,
      Paint()
        ..shader = LinearGradient(
          colors: [_accent, _orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(
          Rect.fromCircle(center: Offset(badgeCx, badgeCy), radius: br),
        ),
    );

    // + symbol
    final plusPaint = Paint()
      ..color = _white
      ..strokeWidth = w * 0.040
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(badgeCx - w * 0.065, badgeCy),
      Offset(badgeCx + w * 0.065, badgeCy),
      plusPaint,
    );
    canvas.drawLine(
      Offset(badgeCx, badgeCy - w * 0.065),
      Offset(badgeCx, badgeCy + w * 0.065),
      plusPaint,
    );

    // ── 5. Sparkles ───────────────────────────────────────────────
    _drawSparkle(canvas, Offset(w * 0.11, h * 0.20), w * 0.026, _accent, 0.65);
    _drawSparkle(canvas, Offset(w * 0.88, h * 0.55), w * 0.018, _orange, 0.50);
    _drawSparkle(canvas, Offset(w * 0.14, h * 0.78), w * 0.016, _deep,   0.40);
    _drawSparkle(canvas, Offset(w * 0.84, h * 0.15), w * 0.013, _white,  0.60);

    // ── 6. Confetti dots ──────────────────────────────────────────
    _drawDot(canvas, Offset(w * 0.22, h * 0.14), w * 0.020, _accent.withValues(alpha: 0.60));
    _drawDot(canvas, Offset(w * 0.78, h * 0.82), w * 0.016, _light.withValues(alpha: 0.80));
    _drawDot(canvas, Offset(w * 0.10, h * 0.60), w * 0.014, _orange.withValues(alpha: 0.45));
  }

  void _drawSparkle(Canvas canvas, Offset center, double r, Color color, double opacity) {
    final p = Paint()..color = color.withValues(alpha: opacity);
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 0.30, height: r * 1.10),
        p,
      );
      canvas.restore();
    }
    canvas.drawCircle(center, r * 0.20, Paint()..color = color.withValues(alpha: opacity));
  }

  void _drawDot(Canvas canvas, Offset center, double r, Color color) =>
      canvas.drawCircle(center, r, Paint()..color = color);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

