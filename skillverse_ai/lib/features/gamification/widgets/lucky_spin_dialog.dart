import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/confetti_overlay.dart';
import '../../providers/app_providers.dart';

class WheelPrize {
  final String label;
  final IconData icon;
  final Color color;
  final int coins;
  final int diamonds;
  final int xp;

  const WheelPrize({
    required this.label,
    required this.icon,
    required this.color,
    required this.coins,
    required this.diamonds,
    required this.xp,
  });
}

class LuckySpinDialog extends ConsumerStatefulWidget {
  const LuckySpinDialog({super.key});

  @override
  ConsumerState<LuckySpinDialog> createState() => _LuckySpinDialogState();
}

class _LuckySpinDialogState extends ConsumerState<LuckySpinDialog> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _animation;

  bool _isSpinning = false;
  bool _showConfetti = false;
  WheelPrize? _wonPrize;
  double _targetRotation = 0;

  final List<WheelPrize> _prizes = const [
    WheelPrize(label: '+150 Coins', icon: Icons.monetization_on_rounded, color: Colors.amber, coins: 150, diamonds: 0, xp: 0),
    WheelPrize(label: '+25 Diamonds', icon: Icons.diamond_rounded, color: AppColors.cyanGlow, coins: 0, diamonds: 25, xp: 0),
    WheelPrize(label: '+500 XP', icon: Icons.bolt_rounded, color: AppColors.emeraldGreen, coins: 0, diamonds: 0, xp: 500),
    WheelPrize(label: '+300 Coins', icon: Icons.monetization_on_rounded, color: Colors.orange, coins: 300, diamonds: 0, xp: 0),
    WheelPrize(label: '+50 Diamonds', icon: Icons.diamond_rounded, color: Colors.purpleAccent, coins: 0, diamonds: 50, xp: 0),
    WheelPrize(label: '+1000 XP', icon: Icons.auto_awesome_rounded, color: AppColors.primaryBlue, coins: 0, diamonds: 0, xp: 1000),
    WheelPrize(label: '+500 Coins', icon: Icons.workspace_premium_rounded, color: Colors.amberAccent, coins: 500, diamonds: 0, xp: 0),
    WheelPrize(label: 'JACKPOT 💎', icon: Icons.stars_rounded, color: Colors.redAccent, coins: 500, diamonds: 100, xp: 1500),
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void _spin() {
    if (_isSpinning) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isSpinning = true;
      _wonPrize = null;
      _showConfetti = false;
    });

    final random = math.Random();
    final winningIndex = random.nextInt(_prizes.length);
    final sectorAngle = (math.pi * 2) / _prizes.length;

    // Calculate rotation to land on the winning sector (top indicator at 12 o'clock = -pi/2)
    final fullSpins = 5 + random.nextInt(3);
    final targetSectorAngle = (winningIndex * sectorAngle) + (sectorAngle / 2);
    _targetRotation = (fullSpins * math.pi * 2) + ((math.pi * 2) - targetSectorAngle);

    _animation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.decelerate,
    );

    _spinController.forward(from: 0).then((_) {
      final prize = _prizes[winningIndex];
      ref.read(userProvider.notifier).spinLuckyWheel(prize.coins, prize.diamonds, prize.xp);
      HapticFeedback.heavyImpact();

      setState(() {
        _isSpinning = false;
        _wonPrize = prize;
        _showConfetti = true;
      });
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiOverlay(
      isTriggered: _showConfetti,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          hasGlow: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Text('Lucky Fortune Wheel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Wheel Container with Pointer
              SizedBox(
                height: 260,
                width: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Spinning Wheel Canvas
                    AnimatedBuilder(
                      animation: _spinController,
                      builder: (context, child) {
                        final rotation = _animation.value * _targetRotation;
                        return Transform.rotate(
                          angle: rotation,
                          child: CustomPaint(
                            size: const Size(250, 250),
                            painter: _WheelPainter(prizes: _prizes),
                          ),
                        );
                      },
                    ),

                    // Center Spin Hub
                    GestureDetector(
                      onTap: _spin,
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(color: AppColors.cyanGlow.withValues(alpha: 0.5), blurRadius: 16, spreadRadius: 2),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _isSpinning ? '...' : 'SPIN',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ),
                      ),
                    ),

                    // Top Pointer Indicator (12 o'clock)
                    Positioned(
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_drop_down_rounded, color: Colors.black, size: 28),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Prize Outcome Card
              if (_wonPrize != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _wonPrize!.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _wonPrize!.color, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_wonPrize!.icon, color: _wonPrize!.color, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'YOU WON ${_wonPrize!.label}! 🎉',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              ] else ...[
                const Text(
                  'Spin to win Coins, Diamonds, and Bonus XP!',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<WheelPrize> prizes;

  _WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = (math.pi * 2) / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = (i * sweepAngle) - (math.pi / 2);
      final prize = prizes[i];

      // Sector Fill
      final sectorPaint = Paint()
        ..color = prize.color.withValues(alpha: i.isEven ? 0.35 : 0.50)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        sectorPaint,
      );

      // Border line
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}
