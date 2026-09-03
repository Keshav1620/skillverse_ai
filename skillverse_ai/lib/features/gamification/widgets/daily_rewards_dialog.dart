import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/confetti_overlay.dart';
import '../../providers/app_providers.dart';

class DailyRewardDay {
  final int day;
  final int coins;
  final int diamonds;
  final String title;

  const DailyRewardDay({
    required this.day,
    required this.coins,
    required this.diamonds,
    required this.title,
  });
}

class DailyRewardsDialog extends ConsumerStatefulWidget {
  const DailyRewardsDialog({super.key});

  @override
  ConsumerState<DailyRewardsDialog> createState() => _DailyRewardsDialogState();
}

class _DailyRewardsDialogState extends ConsumerState<DailyRewardsDialog> {
  bool _showConfetti = false;

  final List<DailyRewardDay> _days = const [
    DailyRewardDay(day: 1, coins: 100, diamonds: 5, title: 'Day 1 Bonus'),
    DailyRewardDay(day: 2, coins: 150, diamonds: 10, title: 'Day 2 Streak'),
    DailyRewardDay(day: 3, coins: 200, diamonds: 15, title: 'Day 3 Boost'),
    DailyRewardDay(day: 4, coins: 250, diamonds: 20, title: 'Day 4 Surge'),
    DailyRewardDay(day: 5, coins: 350, diamonds: 25, title: 'Day 5 Power'),
    DailyRewardDay(day: 6, coins: 450, diamonds: 35, title: 'Day 6 Elite'),
    DailyRewardDay(day: 7, coins: 1000, diamonds: 100, title: 'Day 7 MEGA JACKPOT 👑'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 28),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Daily Rewards Calendar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${user.streakDays}-Day Streak Active 🔥', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 7-Day Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final reward = _days[index];
                  final isClaimed = user.claimedDailyDays.contains(reward.day);
                  final isCurrentDay = !isClaimed && (user.claimedDailyDays.length + 1 == reward.day);
                  final isMegaDay = reward.day == 7;

                  return InkWell(
                    onTap: isCurrentDay
                        ? () {
                            HapticFeedback.heavyImpact();
                            ref.read(userProvider.notifier).claimDailyReward(reward.day, reward.coins, reward.diamonds);
                            setState(() => _showConfetti = true);
                          }
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isClaimed
                            ? AppColors.surface.withValues(alpha: 0.4)
                            : (isCurrentDay
                                ? AppColors.cyanGlow.withValues(alpha: 0.25)
                                : (isMegaDay ? Colors.amber.withValues(alpha: 0.15) : AppColors.surface)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrentDay
                              ? AppColors.cyanGlow
                              : (isMegaDay ? Colors.amber : (isClaimed ? AppColors.emeraldGreen : AppColors.glassBorder)),
                          width: isCurrentDay || isMegaDay ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Day ${reward.day}',
                                style: TextStyle(
                                  color: isCurrentDay ? AppColors.cyanGlow : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              if (isClaimed)
                                const Icon(Icons.check_circle_rounded, color: AppColors.emeraldGreen, size: 14),
                            ],
                          ),
                          Icon(
                            isMegaDay ? Icons.workspace_premium_rounded : Icons.card_giftcard_rounded,
                            color: isClaimed
                                ? AppColors.textMuted
                                : (isCurrentDay ? AppColors.cyanGlow : (isMegaDay ? Colors.amber : Colors.white70)),
                            size: 24,
                          ),
                          Column(
                            children: [
                              Text(
                                '+${reward.coins} 🪙',
                                style: TextStyle(
                                  color: isClaimed ? AppColors.textMuted : Colors.amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '+${reward.diamonds} 💎',
                                style: TextStyle(
                                  color: isClaimed ? AppColors.textMuted : AppColors.cyanGlow,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate(target: isCurrentDay ? 1 : 0).shimmer(duration: 1500.ms, color: AppColors.cyanGlow),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Bottom Claim Action
              if (user.claimedDailyDays.length < 7) ...[
                const Text(
                  'Check in daily to maintain your streak and claim Mega Rewards!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
