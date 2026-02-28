class OwnerGymModel {
  final int id;
  final String name;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final String? googleMapUrl;
  final String? imageUrl;
  final bool active;
  final int maxDailyVisits;
  final String activeFromTime;
  final String activeToTime;

  const OwnerGymModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.googleMapUrl,
    required this.imageUrl,
    required this.active,
    required this.maxDailyVisits,
    required this.activeFromTime,
    required this.activeToTime,
  });

  factory OwnerGymModel.fromJson(Map<String, dynamic> json) {
    return OwnerGymModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      googleMapUrl: json['googleMapUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      active: json['active'] as bool? ?? true,
      maxDailyVisits: (json['maxDailyVisits'] as num?)?.toInt() ?? 1000,
      activeFromTime: json['activeFromTime'] as String? ?? '05:00:00',
      activeToTime: json['activeToTime'] as String? ?? '23:00:00',
    );
  }
}
