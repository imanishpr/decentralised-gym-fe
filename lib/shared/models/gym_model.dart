class GymModel {
  final int id;
  final String name;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final String? googleMapUrl;
  final String? imageUrl;
  final double? pricePerHourInr;
  final String? activeFromTime;
  final String? activeToTime;
  final bool active;

  const GymModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.googleMapUrl,
    required this.imageUrl,
    required this.pricePerHourInr,
    required this.activeFromTime,
    required this.activeToTime,
    required this.active,
  });

  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      googleMapUrl: json['googleMapUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      pricePerHourInr: (json['pricePerHourInr'] as num?)?.toDouble(),
      activeFromTime: json['activeFromTime'] as String?,
      activeToTime: json['activeToTime'] as String?,
      active: json['active'] as bool? ?? false,
    );
  }
}
