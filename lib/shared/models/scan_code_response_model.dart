class ScanCodeResponseModel {
  final int visitId;
  final int bookingId;
  final int gymId;
  final String gymName;
  final DateTime visitedAt;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastVisitDate;

  const ScanCodeResponseModel({
    required this.visitId,
    required this.bookingId,
    required this.gymId,
    required this.gymName,
    required this.visitedAt,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastVisitDate,
  });

  factory ScanCodeResponseModel.fromJson(Map<String, dynamic> json) {
    final rawLastVisitDate = json['lastVisitDate'] as String?;
    return ScanCodeResponseModel(
      visitId: (json['visitId'] as num).toInt(),
      bookingId: (json['bookingId'] as num).toInt(),
      gymId: (json['gymId'] as num).toInt(),
      gymName: json['gymName'] as String? ?? '',
      visitedAt: DateTime.parse(json['visitedAt'] as String),
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      lastVisitDate: rawLastVisitDate == null ? null : DateTime.parse(rawLastVisitDate),
    );
  }
}
