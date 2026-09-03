import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../models/user_model.dart';
import '../providers/app_providers.dart';

class ChallengeQuest {
  final String id;
  final String title;
  final String description;
  final int currentProgress;
  final int totalProgress;
  final int coinReward;
  final int diamondReward;
  final int xpReward;
  final bool isWeekly;
  final bool isClaimed;

  const ChallengeQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.totalProgress,
    required this.coinReward,
    required this.diamondReward,
    required this.xpReward,
    required this.isWeekly,
    this.isClaimed = false,
  });
}

class AchievementsPage extends ConsumerStatefulWidget {
  const AchievementsPage({super.key});

  @override
  ConsumerState<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends ConsumerState<AchievementsPage> {
  int _selectedTab = 0; // 0: Badges, 1: Weekly Quests, 2: Monthly Quests
  bool _showConfetti = false;

  final List<ChallengeQuest> _weeklyQuests = [
    const ChallengeQuest(id: 'q_1', title: 'Pose Precision Streak', description: 'Perform 5 live camera posture tracking sessions', currentProgress: 4, totalProgress: 5, coinReward: 250, diamondReward: 15, xpReward: 500, isWeekly: true),
    const ChallengeQuest(id: 'q_2', title: 'Basketball Jump Shot Mastery', description: 'Maintain 90%+ release angle in 3 sessions', currentProgress: 3, totalProgress: 3, coinReward: 400, diamondReward: 25, xpReward: 800, isWeekly: true),
    const ChallengeQuest(id: 'q_3', title: 'Olympian Squat Form', description: 'Achieve sub-parallel depth 10 times', currentProgress: 7, totalProgress: 10, coinReward: 300, diamondReward: 20, xpReward: 600, isWeekly: true),
  ];

  final List<ChallengeQuest> _monthlyQuests = [
    const ChallengeQuest(id: 'mq_1', title: 'Zeus Grandmaster Milestone', description: 'Earn 10,000 Total XP this month', currentProgress: 7450, totalProgress: 10000, coinReward: 1500, diamondReward: 100, xpReward: 2500, isWeekly: false),
    const ChallengeQuest(id: 'mq_2', title: 'Perfect 14-Day Streak', description: 'Maintain a 14-day daily login streak', currentProgress: 14, totalProgress: 14, coinReward: 1000, diamondReward: 75, xpReward: 2000, isWeekly: false),
  ];

  @override
  Widget build(BuildContext context) {
    final achievements = ref.watch(achievementsProvider);
    final user = ref.watch(userProvider);

    return ConfettiOverlay(
      isTriggered: _showConfetti,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Achievements & Quests', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Banner
                GlassContainer(
                  hasGlow: true,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(gradient: AppColors.emeraldCyanGradient, shape: BoxShape.circle),
                        child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${user.rank.displayName} Rank ${user.rank.iconEmoji}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('Level ${user.level} • ${user.xp} / ${user.nextLevelXp} XP', style: const TextStyle(color: AppColors.cyanGlow, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Segmented Tabs
                Row(
                  children: [
                    _TabButton(text: 'Badges', isSelected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
                    const SizedBox(width: 8),
                    _TabButton(text: 'Weekly Quests', isSelected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
                    const SizedBox(width: 8),
                    _TabButton(text: 'Monthly Quests', isSelected: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2)),
                  ],
                ),

                const SizedBox(height: 20),

                // Tab 0: Badges
                if (_selectedTab == 0) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      final badge = achievements[index];
                      return GlassContainer(
                        borderColor: badge.isUnlocked ? badge.color : AppColors.glassBorder,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: badge.isUnlocked ? badge.color.withValues(alpha: 0.2) : AppColors.surface),
                              child: Icon(badge.icon, color: badge.isUnlocked ? badge.color : AppColors.textMuted, size: 28),
                            ),
                            Text(badge.title, textAlign: TextAlign.center, style: TextStyle(color: badge.isUnlocked ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(badge.isUnlocked ? 'UNLOCKED VERIFIED' : 'LOCKED', style: TextStyle(color: badge.isUnlocked ? AppColors.emeraldGreen : AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                ] else ...[
                  // Tab 1 & 2: Quests List
                  for (final quest in (_selectedTab == 1 ? _weeklyQuests : _monthlyQuests)) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(quest.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                                Text('${quest.coinReward}🪙 ${quest.diamondReward}💎', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(quest.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            const SizedBox(height: 12),

                            // Progress Bar & Claim Button
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: (quest.currentProgress / quest.totalProgress).clamp(0.0, 1.0),
                                          backgroundColor: AppColors.surface,
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyanGlow),
                                          minHeight: 6,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('${quest.currentProgress} / ${quest.totalProgress}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: quest.currentProgress >= quest.totalProgress ? AppColors.emeraldGreen : AppColors.surface,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: quest.currentProgress >= quest.totalProgress
                                      ? () {
                                          HapticFeedback.heavyImpact();
                                          ref.read(userProvider.notifier).addCoins(quest.coinReward);
                                          ref.read(userProvider.notifier).addDiamonds(quest.diamondReward);
                                          ref.read(userProvider.notifier).addXp(quest.xpReward);
                                          setState(() => _showConfetti = true);
                                        }
                                      : null,
                                  child: Text(quest.currentProgress >= quest.totalProgress ? 'CLAIM' : 'IN PROGRESS', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cyanGlow : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),
      ),
    );
  }
}
