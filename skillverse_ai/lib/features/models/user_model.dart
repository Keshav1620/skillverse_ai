enum TitleRank {
  novice,
  explorer,
  practitioner,
  advanced,
  professional,
  elite,
  legend,
  mythic,
  master,
  grandmaster,
}

extension TitleRankExtension on TitleRank {
  String get displayName {
    switch (this) {
      case TitleRank.novice:
        return 'Novice';
      case TitleRank.explorer:
        return 'Explorer';
      case TitleRank.practitioner:
        return 'Practitioner';
      case TitleRank.advanced:
        return 'Advanced';
      case TitleRank.professional:
        return 'Professional';
      case TitleRank.elite:
        return 'Elite';
      case TitleRank.legend:
        return 'Legend';
      case TitleRank.mythic:
        return 'Mythic';
      case TitleRank.master:
        return 'Master';
      case TitleRank.grandmaster:
        return 'Grandmaster';
    }
  }

  String get iconEmoji {
    switch (this) {
      case TitleRank.novice:
        return '🥉';
      case TitleRank.explorer:
        return '🧭';
      case TitleRank.practitioner:
        return '⚡';
      case TitleRank.advanced:
        return '🎯';
      case TitleRank.professional:
        return '💼';
      case TitleRank.elite:
        return '🏆';
      case TitleRank.legend:
        return '🌟';
      case TitleRank.mythic:
        return '🔮';
      case TitleRank.master:
        return '👑';
      case TitleRank.grandmaster:
        return '💎';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String title;
  final TitleRank rank;
  final int level;
  final int xp;
  final int nextLevelXp;
  final int coins;
  final int diamonds;
  final int streakDays;
  final int totalSkillsMastered;
  final double globalRankPercentile;
  final List<String> unlockedSkillNodes;
  final List<int> claimedDailyDays;
  final DateTime? lastSpinTimestamp;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.title,
    required this.rank,
    required this.level,
    required this.xp,
    required this.nextLevelXp,
    required this.coins,
    required this.diamonds,
    required this.streakDays,
    required this.totalSkillsMastered,
    required this.globalRankPercentile,
    required this.unlockedSkillNodes,
    required this.claimedDailyDays,
    this.lastSpinTimestamp,
  });

  static TitleRank calculateRank(int level) {
    if (level >= 45) return TitleRank.grandmaster;
    if (level >= 40) return TitleRank.master;
    if (level >= 35) return TitleRank.mythic;
    if (level >= 30) return TitleRank.legend;
    if (level >= 25) return TitleRank.elite;
    if (level >= 20) return TitleRank.professional;
    if (level >= 15) return TitleRank.advanced;
    if (level >= 10) return TitleRank.practitioner;
    if (level >= 5) return TitleRank.explorer;
    return TitleRank.novice;
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? title,
    TitleRank? rank,
    int? level,
    int? xp,
    int? nextLevelXp,
    int? coins,
    int? diamonds,
    int? streakDays,
    int? totalSkillsMastered,
    double? globalRankPercentile,
    List<String>? unlockedSkillNodes,
    List<int>? claimedDailyDays,
    DateTime? lastSpinTimestamp,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      title: title ?? this.title,
      rank: rank ?? this.rank,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
      streakDays: streakDays ?? this.streakDays,
      totalSkillsMastered: totalSkillsMastered ?? this.totalSkillsMastered,
      globalRankPercentile: globalRankPercentile ?? this.globalRankPercentile,
      unlockedSkillNodes: unlockedSkillNodes ?? this.unlockedSkillNodes,
      claimedDailyDays: claimedDailyDays ?? this.claimedDailyDays,
      lastSpinTimestamp: lastSpinTimestamp ?? this.lastSpinTimestamp,
    );
  }
}
