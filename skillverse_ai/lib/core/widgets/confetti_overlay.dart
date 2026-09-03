import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double rotation;
  double vr;
  double opacity;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.vr,
    this.opacity = 1.0,
  });
}

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool isTriggered;

  const ConfettiOverlay({
    super.key,
    required this.child,
    required this.isTriggered,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  final List<Color> _colors = const [
    Color(0xFFFFD700), // Gold
    Color(0xFF00E5FF), // Cyan
    Color(0xFFFF00C7), // Pink
    Color(0xFF00FF66), // Emerald
    Color(0xFF9D00FF), // Purple
    Color(0xFFFF3366), // Rose
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addListener(_updateParticles);

    if (widget.isTriggered) {
      _spawnParticles();
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTriggered && !oldWidget.isTriggered) {
      _spawnParticles();
      _controller.forward(from: 0);
    }
  }

  void _spawnParticles() {
    _particles.clear();
    for (int i = 0; i < 90; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 4 + _random.nextDouble() * 12;
      _particles.add(
        ConfettiParticle(
          x: 0.5,
          y: 0.35,
          vx: math.cos(angle) * speed * 0.003,
          vy: (math.sin(angle) * speed * 0.003) - 0.008,
          size: 6 + _random.nextDouble() * 8,
          color: _colors[_random.nextInt(_colors.length)],
          rotation: _random.nextDouble() * math.pi * 2,
          vr: (_random.nextDouble() - 0.5) * 0.2,
        ),
      );
    }
  }

  void _updateParticles() {
    setState(() {
      for (final p in _particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.0004; // Gravity
        p.rotation += p.vr;
        p.opacity = (1.0 - _controller.value).clamp(0.0, 1.0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating)
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: _ConfettiPainter(particles: _particles),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final pos = Offset(p.x * size.width, p.y * size.height);
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
