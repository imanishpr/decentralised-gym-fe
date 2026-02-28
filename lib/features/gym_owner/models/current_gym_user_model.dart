class CurrentGymUserModel {
  final int userId;
  final String userName;
  final String userEmail;
  final String lastVisitedAt;
  final String bookingStartTime;
  final String bookingEndTime;

  const CurrentGymUserModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.lastVisitedAt,
    required this.bookingStartTime,
    required this.bookingEndTime,
  });

  factory CurrentGymUserModel.fromJson(Map<String, dynamic> json) {
    return CurrentGymUserModel(
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      lastVisitedAt: json['lastVisitedAt'] as String? ?? '',
      bookingStartTime: json['bookingStartTime'] as String? ?? '-',
      bookingEndTime: json['bookingEndTime'] as String? ?? '-',
    );
  }
}
