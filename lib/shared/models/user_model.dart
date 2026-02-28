class UserModel {
  final int id;
  final String name;
  final String email;
  final String provider;
  final String role;
  final String providerUserId;
  final String? profileImageUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
    required this.role,
    required this.providerUserId,
    required this.profileImageUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      provider: json['provider'] as String? ?? 'LOCAL',
      role: json['role'] as String? ?? 'USER',
      providerUserId: json['providerUserId'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'provider': provider,
      'role': role,
      'providerUserId': providerUserId,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
