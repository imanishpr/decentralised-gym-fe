import 'user_model.dart';

class AuthResponseModel {
  final String message;
  final String token;
  final String tokenType;
  final int expiresInSeconds;
  final UserModel user;

  const AuthResponseModel({
    required this.message,
    required this.token,
    required this.tokenType,
    required this.expiresInSeconds,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      message: json['message'] as String? ?? '',
      token: json['token'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 0,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
