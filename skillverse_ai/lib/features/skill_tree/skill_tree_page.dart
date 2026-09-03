import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../providers/app_providers.dart';

class SkillTreeNode {
  final String id;
  final String title;
  final String category;
  final String description;
  final IconData icon;
  final int tier;
  final int coinCost;
  final int diamondCost;
  final String statBoost;
  final List<String> prerequisites;

  const SkillTreeNode({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.tier,
    required this.coinCost,
    required this.diamondCost,
    required this.statBoost,
    this.prerequisites = const [],
  });
}

class SkillTreePage extends ConsumerStatefulWidget {
  const SkillTreePage({super.key});

  @override
  ConsumerState<SkillTreePage> createState() => _SkillTreePageState();
}

class _SkillTreePageState extends ConsumerState<SkillTreePage> {
  bool _showConfetti = false;

  final List<SkillTreeNode> _nodes = const [
    // Tier 1
    SkillTreeNode(
      id: 'node_1',
      title: 'Postural Spine Baseline',
      category: 'Core Biomechanics',
      description: 'Establishes vertical spine alignment baseline across all posture tracking.',
      icon: Icons.accessibility_new_rounded,
      tier: 1,
      coinCost: 200,
      diamondCost: 0,
      statBoost: '+10% Spine Balance Precision',
    ),
    SkillTreeNode(
      id: 'node_2',
      title: 'Limb Symmetry Calibration',
      category: 'Symmetry',
      description: 'Calibrates left/right leg and arm flex ratio balance.',
      icon: Icons.unfold_more_rounded,
      tier: 1,
      coinCost: 350,
      diamondCost: 10,
      statBoost: '+15% Bilateral Symmetry',
    ),
    SkillTreeNode(
      id: 'node_3',
      title: 'Zeus Release Alignment',
      category: 'Basketball Shot',
      description: 'Locks elbow extension vector at optimal 165° release trajectory.',
      icon: Icons.sports_basketball_rounded,
      tier: 2,
      coinCost: 500,
      diamondCost: 25,
      statBoost: '+20% Jump Shot Accuracy',
      prerequisites: ['node_1'],
    ),
    SkillTreeNode(
      id: 'node_4',
      title: 'Hercules Squat Depth Hinge',
      category: 'Powerlifting',
      description: 'Tracks sub-parallel hip hinge angle with valgus knee guard.',
      icon: Icons.fitness_center_rounded,
      tier: 2,
      coinCost: 650,
      diamondCost: 30,
      statBoost: '+25% Squat Force Output',
      prerequisites: ['node_2'],
    ),
    SkillTreeNode(
      id: 'node_5',
      title: 'Explosive Vertical Takeoff',
      category: 'Sprint & Jump',
      description: 'Analyzes knee crouch dip and ankle push acceleration.',
      icon: Icons.bolt_rounded,
      tier: 3,
      coinCost: 1000,
      diamondCost: 50,
      statBoost: '+30% Vertical Leap Power',
      prerequisites: ['node_3', 'node_4'],
    ),
    SkillTreeNode(
      id: 'node_6',
      title: 'Olympian Grandmaster Telemetry',
      category: 'Mastery',
      description: 'Unlocks 3D Holographic Ghost Skeleton and master telemetry HUD.',
      icon: Icons.stars_rounded,
      tier: 4,
      coinCost: 2000,
      diamondCost: 100,
      statBoost: '+50% All Telemetry XP',
      prerequisites: ['node_5'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return ConfettiOverlay(
      isTriggered: _showConfetti,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Skill Progression Tree', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Text('${user.coins} 🪙', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 8),
                  Text('${user.diamonds} 💎', style: const TextStyle(color: AppColors.cyanGlow, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                GlassContainer(
                  hasGlow: true,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.account_tree_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user.unlockedSkillNodes.length} of ${_nodes.length} Skill Nodes Unlocked',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Unlock skill nodes with Coins & Diamonds to gain permanent stat boosts!',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Skill Tree Tiers
                for (int tier = 1; tier <= 4; tier++) ...[
                  Text(
                    'TIER $tier MASTERY',
                    style: const TextStyle(color: AppColors.cyanGlow, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _nodes.where((n) => n.tier == tier).length,
                    itemBuilder: (context, index) {
                      final node = _nodes.where((n) => n.tier == tier).toList()[index];
                      final isUnlocked = user.unlockedSkillNodes.contains(node.id);
                      final isAvailable = !isUnlocked && node.prerequisites.every((pre) => user.unlockedSkillNodes.contains(pre));

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassContainer(
                          borderColor: isUnlocked
                              ? AppColors.emeraldGreen
                              : (isAvailable ? AppColors.cyanGlow : AppColors.glassBorder),
                          backgroundColor: isUnlocked
                              ? AppColors.emeraldGreen.withValues(alpha: 0.1)
                              : (isAvailable ? AppColors.primaryBlue.withValues(alpha: 0.15) : null),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isUnlocked
                                      ? AppColors.emeraldGreen.withValues(alpha: 0.2)
                                      : (isAvailable ? AppColors.cyanGlow.withValues(alpha: 0.2) : AppColors.surface),
                                  border: Border.all(
                                    color: isUnlocked
                                        ? AppColors.emeraldGreen
                                        : (isAvailable ? AppColors.cyanGlow : AppColors.glassBorder),
                                  ),
                                ),
                                child: Icon(
                                  node.icon,
                                  color: isUnlocked
                                      ? AppColors.emeraldGreen
                                      : (isAvailable ? AppColors.cyanGlow : AppColors.textMuted),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          node.title,
                                          style: TextStyle(
                                            color: isUnlocked || isAvailable ? Colors.white : AppColors.textMuted,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (isUnlocked) ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.check_circle_rounded, color: AppColors.emeraldGreen, size: 14),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      node.description,
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        node.statBoost,
                                        style: const TextStyle(color: AppColors.cyanGlow, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (isUnlocked)
                                const Text('UNLOCKED', style: TextStyle(color: AppColors.emeraldGreen, fontWeight: FontWeight.bold, fontSize: 11))
                              else if (isAvailable)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.cyanGlow,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    final success = ref.read(userProvider.notifier).unlockSkillNode(node.id, node.coinCost, node.diamondCost);
                                    if (success) {
                                      HapticFeedback.heavyImpact();
                                      setState(() => _showConfetti = true);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Not enough Coins or Diamonds!')),
                                      );
                                    }
                                  },
                                  child: Text('${node.coinCost}🪙 ${node.diamondCost}💎', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                )
                              else
                                const Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
