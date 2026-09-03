import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class _LeaderboardUser {
  final int rank;
  final String name;
  final String xp;
  final String avatar;
  final String title;
  final String rankTitle;
  final bool isCurrentUser;

  const _LeaderboardUser({
    required this.rank,
    required this.name,
    required this.xp,
    required this.avatar,
    required this.title,
    required this.rankTitle,
    this.isCurrentUser = false,
  });
}

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  int _selectedCategory = 0; // 0: Global, 1: Country, 2: College, 3: Friends

  final Map<int, List<_LeaderboardUser>> _categoryRankings = const {
    0: [
      _LeaderboardUser(rank: 1, name: 'Elena Rostova', xp: '48,450 XP', avatar: 'https://i.pravatar.cc/150?img=47', title: 'Grandmaster', rankTitle: '💎 Grandmaster'),
      _LeaderboardUser(rank: 2, name: 'Alex Vance (You)', xp: '42,800 XP', avatar: 'https://i.pravatar.cc/150?img=11', title: 'Master', rankTitle: '👑 Master', isCurrentUser: true),
      _LeaderboardUser(rank: 3, name: 'Dmitri Petrov', xp: '38,150 XP', avatar: 'https://i.pravatar.cc/150?img=60', title: 'Mythic', rankTitle: '🔮 Mythic'),
      _LeaderboardUser(rank: 4, name: 'Sarah Jenkins', xp: '32,900 XP', avatar: 'https://i.pravatar.cc/150?img=32', title: 'Legend', rankTitle: '🌟 Legend'),
      _LeaderboardUser(rank: 5, name: 'Kenji Sato', xp: '28,400 XP', avatar: 'https://i.pravatar.cc/150?img=12', title: 'Elite', rankTitle: '🏆 Elite'),
      _LeaderboardUser(rank: 6, name: 'Maya Lin', xp: '24,200 XP', avatar: 'https://i.pravatar.cc/150?img=25', title: 'Professional', rankTitle: '💼 Professional'),
    ],
    1: [
      _LeaderboardUser(rank: 1, name: 'Arjun Mehta', xp: '45,100 XP', avatar: 'https://i.pravatar.cc/150?img=15', title: 'Grandmaster', rankTitle: '💎 Grandmaster'),
      _LeaderboardUser(rank: 2, name: 'Alex Vance (You)', xp: '42,800 XP', avatar: 'https://i.pravatar.cc/150?img=11', title: 'Master', rankTitle: '👑 Master', isCurrentUser: true),
      _LeaderboardUser(rank: 3, name: 'Priya Sharma', xp: '36,400 XP', avatar: 'https://i.pravatar.cc/150?img=38', title: 'Mythic', rankTitle: '🔮 Mythic'),
      _LeaderboardUser(rank: 4, name: 'Rohan Verma', xp: '29,800 XP', avatar: 'https://i.pravatar.cc/150?img=53', title: 'Legend', rankTitle: '🌟 Legend'),
    ],
    2: [
      _LeaderboardUser(rank: 1, name: 'Alex Vance (You)', xp: '42,800 XP', avatar: 'https://i.pravatar.cc/150?img=11', title: 'Master', rankTitle: '👑 Master', isCurrentUser: true),
      _LeaderboardUser(rank: 2, name: 'Vikram Singh', xp: '31,200 XP', avatar: 'https://i.pravatar.cc/150?img=59', title: 'Legend', rankTitle: '🌟 Legend'),
      _LeaderboardUser(rank: 3, name: 'Ananya Roy', xp: '26,500 XP', avatar: 'https://i.pravatar.cc/150?img=44', title: 'Elite', rankTitle: '🏆 Elite'),
      _LeaderboardUser(rank: 4, name: 'Kabir Patel', xp: '21,400 XP', avatar: 'https://i.pravatar.cc/150?img=68', title: 'Professional', rankTitle: '💼 Professional'),
    ],
    3: [
      _LeaderboardUser(rank: 1, name: 'Alex Vance (You)', xp: '42,800 XP', avatar: 'https://i.pravatar.cc/150?img=11', title: 'Master', rankTitle: '👑 Master', isCurrentUser: true),
      _LeaderboardUser(rank: 2, name: 'Lucas Scott', xp: '22,400 XP', avatar: 'https://i.pravatar.cc/150?img=33', title: 'Advanced', rankTitle: '🎯 Advanced'),
      _LeaderboardUser(rank: 3, name: 'Chloe Bennett', xp: '18,900 XP', avatar: 'https://i.pravatar.cc/150?img=20', title: 'Practitioner', rankTitle: '⚡ Practitioner'),
      _LeaderboardUser(rank: 4, name: 'Marcus Brody', xp: '14,200 XP', avatar: 'https://i.pravatar.cc/150?img=52', title: 'Explorer', rankTitle: '🧭 Explorer'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentList = _categoryRankings[_selectedCategory] ?? _categoryRankings[0]!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text('Olympus Standings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              const Text('Top tier biomechanics & skill champions', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 16),

              // Segment Filter Tabs (Global, Country, College, Friends)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ToggleChip(text: 'Global 🌍', isSelected: _selectedCategory == 0, onTap: () => setState(() => _selectedCategory = 0)),
                    const SizedBox(width: 8),
                    _ToggleChip(text: 'Country 🇮🇳', isSelected: _selectedCategory == 1, onTap: () => setState(() => _selectedCategory = 1)),
                    const SizedBox(width: 8),
                    _ToggleChip(text: 'College 🎓', isSelected: _selectedCategory == 2, onTap: () => setState(() => _selectedCategory = 2)),
                    const SizedBox(width: 8),
                    _ToggleChip(text: 'Friends 👥', isSelected: _selectedCategory == 3, onTap: () => setState(() => _selectedCategory = 3)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Top 3 Podium Cards
              if (currentList.length >= 3)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _PodiumCard(user: currentList[1], height: 135, crownColor: Colors.grey.shade300),
                    const SizedBox(width: 10),
                    _PodiumCard(user: currentList[0], height: 165, crownColor: Colors.amber, isFirst: true),
                    const SizedBox(width: 10),
                    _PodiumCard(user: currentList[2], height: 120, crownColor: Colors.brown.shade300),
                  ],
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 20),

              // Remaining Rank List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: currentList.length > 3 ? currentList.length - 3 : 0,
                  itemBuilder: (context, index) {
                    final user = currentList[index + 3];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GlassContainer(
                        borderColor: user.isCurrentUser ? AppColors.cyanGlow : AppColors.glassBorder,
                        backgroundColor: user.isCurrentUser ? AppColors.primaryBlue.withValues(alpha: 0.2) : null,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                '#${user.rank}',
                                style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            CircleAvatar(radius: 20, backgroundImage: NetworkImage(user.avatar)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(user.rankTitle, style: const TextStyle(color: AppColors.cyanGlow, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Text(user.xp, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cyanGlow : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.cyanGlow : AppColors.glassBorder),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final _LeaderboardUser user;
  final double height;
  final Color crownColor;
  final bool isFirst;

  const _PodiumCard({required this.user, required this.height, required this.crownColor, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        hasGlow: isFirst,
        borderColor: isFirst ? AppColors.cyanGlow : AppColors.glassBorder,
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.workspace_premium_rounded, color: crownColor, size: isFirst ? 24 : 18),
              CircleAvatar(radius: isFirst ? 22 : 18, backgroundImage: NetworkImage(user.avatar)),
              Text(user.name.split(' ').first, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(user.rankTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.cyanGlow, fontSize: 9, fontWeight: FontWeight.bold)),
              Text(user.xp, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
