class BookingModel {
  final int id;
  final int gymId;
  final String gymName;
  final DateTime bookingDate;
  final String? startTime;
  final String? endTime;
  final int? durationHours;
  final String? note;
  final String status;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.gymId,
    required this.gymName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: (json['id'] as num).toInt(),
      gymId: (json['gymId'] as num).toInt(),
      gymName: json['gymName'] as String? ?? '',
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      durationHours: (json['durationHours'] as num?)?.toInt(),
      note: json['note'] as String?,
      status: json['status'] as String? ?? 'CREATED',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
