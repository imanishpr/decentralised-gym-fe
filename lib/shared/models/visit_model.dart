class VisitModel {
  final int id;
  final int gymId;
  final String gymName;
  final int bookingId;
  final DateTime visitedAt;

  const VisitModel({
    required this.id,
    required this.gymId,
    required this.gymName,
    required this.bookingId,
    required this.visitedAt,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: (json['id'] as num).toInt(),
      gymId: (json['gymId'] as num).toInt(),
      gymName: json['gymName'] as String? ?? '',
      bookingId: (json['bookingId'] as num).toInt(),
      visitedAt: DateTime.parse(json['visitedAt'] as String),
    );
  }
}
