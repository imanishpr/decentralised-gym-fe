class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastVisitDate;

  const StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastVisitDate,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['lastVisitDate'] as String?;
    return StreakModel(
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastVisitDate: rawDate == null ? null : DateTime.parse(rawDate),
    );
  }
}
