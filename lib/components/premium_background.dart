import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Pixel-perfect Flutter port of wallpaper.html with light/dark theme support
/// 
/// Dark Target:
///  background: deep black #07080b→#111111 (145deg)
///  + teal radial glow top-left (strong, large)
///  + blue radial glow bottom-right
///  + subtle grid overlay
///  + 5 floating dust particles
/// 
/// Light Target:
///  background: light gray #F4F6F9→#FFFFFF (145deg)
///  + teal radial glow top-left (softer, larger)
///  + blue radial glow bottom-right (softer)
///  + very subtle grid overlay
///  + 5 floating dust particles (lighter)
class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    
    const integrationTestMode = bool.fromEnvironment(
      'INTEGRATION_TEST',
      defaultValue: false,
    );

    return Scaffold(
      backgroundColor: isLight ? Color(0xFFF4F6F9) : const Color(0xFF07080B),
      body: Stack(
        children: [
          // 1. Base gradient (RepaintBoundary prevents unnecessary repaints during particle animation)
          Positioned.fill(
            child: RepaintBoundary(
              child: _BaseGradient(isLight: isLight),
            ),
          ),

          // 2. Teal and Blue blurred orbs (RepaintBoundary to cache blurred rendering)
          Positioned.fill(
            child: RepaintBoundary(
              child: _OrbsOverlay(isLight: isLight),
            ),
          ),

          // 3. Grid overlay (RepaintBoundary to cache saveLayer and dstIn blend)
          Positioned.fill(
            child: RepaintBoundary(
              child: _GridOverlay(isLight: isLight),
            ),
          ),

          // 4. Floating particles
          if (!integrationTestMode)
            Positioned.fill(child: _FloatingParticles(isLight: isLight)),

          // 5. Content
          Positioned.fill(child: SafeArea(child: child)),
        ],
      ),
    );
  }
}

// ── 1. Base gradient ──────────────────────────────────────────────────────
// Dark: linear-gradient(145deg, #07080b 0%, #0b0d12 48%, #111111 100%)
// Light: linear-gradient(145deg, #F4F6F9 0%, #FFFFFF 100%)
class _BaseGradient extends StatelessWidget {
  final bool isLight;
  
  const _BaseGradient({required this.isLight});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BaseGradientPainter(isLight: isLight));
  }
}

class _BaseGradientPainter extends CustomPainter {
  final bool isLight;
  
  const _BaseGradientPainter({required this.isLight});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Linear Gradient: 145deg
    const angleRad = 145.0 * math.pi / 180.0;
    final dx = math.sin(angleRad);
    final dy = -math.cos(angleRad);
    final l = w * dx.abs() + h * dy.abs();
    final startX = w / 2 - dx * l / 2;
    final startY = h / 2 - dy * l / 2;
    final endX = w / 2 + dx * l / 2;
    final endY = h / 2 + dy * l / 2;

    final linearPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(startX, startY),
        Offset(endX, endY),
        isLight
            ? [
                const Color(0xFFF4F6F9),
                const Color(0xFFFFFFFF),
              ]
            : [
                const Color(0xFF07080B),
                const Color(0xFF0B0D12),
                const Color(0xFF111111),
              ],
        isLight ? [0.0, 1.0] : [0.0, 0.48, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), linearPaint);

    if (!isLight) {
      // 2. Radial Gradient 1: circle at 15% 18%, rgba(0, 188, 212, 0.14), transparent 24%
      final r1Cx = w * 0.15;
      final r1Cy = h * 0.18;
      final r1FarthestDist = math.sqrt((w - r1Cx) * (w - r1Cx) + (h - r1Cy) * (h - r1Cy));
      final r1Radius = r1FarthestDist * 0.24;

      final radial1Paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(r1Cx, r1Cy),
          r1Radius,
          [
            const Color(0x2400BCD4),
            Colors.transparent,
          ],
          [0.0, 1.0],
        );
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), radial1Paint);

      // 3. Radial Gradient 2: circle at 80% 18%, rgba(66, 133, 244, 0.16), transparent 22%
      final r2Cx = w * 0.80;
      final r2Cy = h * 0.18;
      final r2FarthestDist = math.sqrt(r2Cx * r2Cx + (h - r2Cy) * (h - r2Cy));
      final r2Radius = r2FarthestDist * 0.22;

      final radial2Paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(r2Cx, r2Cy),
          r2Radius,
          [
            const Color(0x294285F4),
            Colors.transparent,
          ],
          [0.0, 1.0],
        );
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), radial2Paint);

      // 4. Radial Gradient 3: circle at 50% 100%, rgba(255, 255, 255, 0.08), transparent 30%
      final r3Cx = w * 0.50;
      final r3Cy = h;
      final r3FarthestDist = math.sqrt(r3Cx * r3Cx + h * h);
      final r3Radius = r3FarthestDist * 0.30;

      final radial3Paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(r3Cx, r3Cy),
          r3Radius,
          [
            const Color(0x14FFFFFF),
            Colors.transparent,
          ],
          [0.0, 1.0],
        );
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), radial3Paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BaseGradientPainter old) => old.isLight != isLight;
}

// ── 2. Orbs Overlay (Teal & Blue Blurred Circles) ────────────────────────
// Dark CSS:
// .orb.teal: top: 9%, left: 8%, width: 280px, height: 280px, background: rgba(0, 188, 212, 0.24), filter: blur(64px), opacity: 0.55
// .orb.blue: right: 6%, bottom: 8%, width: 320px, height: 320px, background: rgba(66, 133, 244, 0.18), filter: blur(64px), opacity: 0.55
// Light: Softer orbs with reduced intensity
class _OrbsOverlay extends StatelessWidget {
  final bool isLight;
  
  const _OrbsOverlay({required this.isLight});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _OrbsPainter(isLight: isLight));
  }
}

class _OrbsPainter extends CustomPainter {
  final bool isLight;
  
  const _OrbsPainter({required this.isLight});

  @override
  void paint(Canvas canvas, Size size) {
    if (isLight) {
      // Light mode: very subtle orbs
      // Teal Orb - softer and more transparent
      final tealCx = size.width * 0.08 + 140.0;
      final tealCy = size.height * 0.09 + 140.0;
      final tealPaint = Paint()
        ..color = const Color(0x0800BCD4) // Much more subtle
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80.0);
      canvas.drawCircle(Offset(tealCx, tealCy), 140.0, tealPaint);

      // Blue Orb - softer and more transparent
      final blueCx = size.width - (size.width * 0.06 + 160.0);
      final blueCy = size.height - (size.height * 0.08 + 160.0);
      final bluePaint = Paint()
        ..color = const Color(0x064285F4) // Much more subtle
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80.0);
      canvas.drawCircle(Offset(blueCx, blueCy), 160.0, bluePaint);
    } else {
      // Dark mode: original orbs
      // Teal Orb
      final tealCx = size.width * 0.08 + 140.0;
      final tealCy = size.height * 0.09 + 140.0;
      final tealPaint = Paint()
        ..color = const Color(0x2200BCD4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 64.0);
      canvas.drawCircle(Offset(tealCx, tealCy), 140.0, tealPaint);

      // Blue Orb
      final blueCx = size.width - (size.width * 0.06 + 160.0);
      final blueCy = size.height - (size.height * 0.08 + 160.0);
      final bluePaint = Paint()
        ..color = const Color(0x194285F4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 64.0);
      canvas.drawCircle(Offset(blueCx, blueCy), 160.0, bluePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbsPainter old) => old.isLight != isLight;
}

// ── 3. Grid Overlay ───────────────────────────────────────────────────────
// Dark: CSS body::before: grid 120px rgba(255,255,255,0.03) opacity:0.28
// Light: grid 120px rgba(0,0,0,0.02) opacity:0.28
//   mask: radial-gradient(circle at center, black, transparent 82%)
class _GridOverlay extends StatelessWidget {
  final bool isLight;
  
  const _GridOverlay({required this.isLight});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter(isLight: isLight));
  }
}

class _GridPainter extends CustomPainter {
  final bool isLight;
  
  const _GridPainter({required this.isLight});

  @override
  void paint(Canvas canvas, Size size) {
    // Dark: rgba(255,255,255,0.03) * opacity(0.28) = 0.0084
    // Light: rgba(0,0,0,0.02) * opacity(0.28) = 0.0056
    final paint = Paint()
      ..color = isLight ? const Color(0x01000000) : const Color(0x03FFFFFF)
      ..strokeWidth = 1.0;

    const double step = 120.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final farthestCornerDist = math.sqrt(cx * cx + cy * cy);
    final maskR = farthestCornerDist * 0.82;

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Radial mask — fades grid to edges
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = ui.Gradient.radial(
          Offset(cx, cy),
          maskR,
          [Colors.black, Colors.transparent],
          [0.0, 1.0],
        ),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.isLight != isLight;
}

// ── 4. Floating Particles ─────────────────────────────────────────────────
class _FloatingParticles extends StatefulWidget {
  final bool isLight;
  
  const _FloatingParticles({required this.isLight});

  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 13),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(
        painter: _ParticlePainter(widget.isLight, _ctrl.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final bool isLight;
  final double t; // 0..1 over 13s

  const _ParticlePainter(this.isLight, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    const masterSec = 13.0;

    // Light mode particles - lighter and more subtle
    final particles = isLight
        ? [
            _P(rx: 0.13, ry: 0.16, sz: 8, c: const Color(0x6000BCD4), dur: 11, del: 0.0),
            _P(rx: 0.78, ry: 0.22, sz: 6, c: const Color(0x50FFFFFF), dur: 11, del: 1.2),
            _P(rx: 0.61, ry: 0.66, sz: 10, c: const Color(0x404285F4), dur: 13, del: 0.8),
            _P(rx: 0.28, ry: 0.76, sz: 6, c: const Color(0x48FFFFFF), dur: 9, del: 2.1),
            _P(rx: 0.46, ry: 0.30, sz: 5, c: const Color(0x5034A853), dur: 11, del: 1.6),
          ]
        : [
            _P(rx: 0.13, ry: 0.16, sz: 10, c: const Color(0xD100BCD4), dur: 11, del: 0.0),
            _P(rx: 0.78, ry: 0.22, sz: 7, c: const Color(0xC2FFFFFF), dur: 11, del: 1.2),
            _P(rx: 0.61, ry: 0.66, sz: 12, c: const Color(0x854285F4), dur: 13, del: 0.8),
            _P(rx: 0.28, ry: 0.76, sz: 8, c: const Color(0x94FFFFFF), dur: 9, del: 2.1),
            _P(rx: 0.46, ry: 0.30, sz: 6, c: const Color(0xA834A853), dur: 11, del: 1.6),
          ];

    for (final p in particles) {
      final absSec = t * masterSec;
      double eff = (absSec - p.del) % p.dur;
      if (eff < 0) eff += p.dur;
      final ft = eff / p.dur;

      double dx, dy, opacity;
      if (ft < 0.35) {
        final s = ft / 0.35;
        dx = ui.lerpDouble(0, 18, s)!;
        dy = ui.lerpDouble(0, -26, s)!;
        opacity = ui.lerpDouble(0.24, 0.92, s)!;
      } else if (ft < 0.70) {
        final s = (ft - 0.35) / 0.35;
        dx = ui.lerpDouble(18, -14, s)!;
        dy = ui.lerpDouble(-26, 20, s)!;
        opacity = ui.lerpDouble(0.92, 0.56, s)!;
      } else {
        final s = (ft - 0.70) / 0.30;
        dx = ui.lerpDouble(-14, 0, s)!;
        dy = ui.lerpDouble(20, 0, s)!;
        opacity = ui.lerpDouble(0.56, 0.24, s)!;
      }

      final x = p.rx * size.width + dx;
      final y = p.ry * size.height + dy;
      final r = p.sz / 2;

      final baseAlpha = p.c.a / 255.0;
      final col = p.c.withValues(alpha: baseAlpha * opacity);

      // Glow (box-shadow: 0 0 14px currentColor)
      canvas.drawCircle(
        Offset(x, y), r,
        Paint()
          ..color = col
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0),
      );
      // Dot
      canvas.drawCircle(
        Offset(x, y), r,
        Paint()..color = col,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.isLight != isLight || old.t != t;
}

class _P {
  final double rx, ry, sz, dur, del;
  final Color c;
  const _P({required this.rx, required this.ry, required this.sz,
            required this.c, required this.dur, required this.del});
}
