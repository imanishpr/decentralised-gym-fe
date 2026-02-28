import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/auth_response_model.dart';
import '../../../shared/models/user_model.dart';

class AuthApi {
  final Dio _dio;

  const AuthApi(this._dio);

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<AuthResponseModel> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/signup',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<UserModel> me() async {
    try {
      final response = await _dio.get('/api/v1/auth/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  ApiException _toApiException(DioException error) {
    if (error.error is ApiException) {
      return error.error as ApiException;
    }

    return ApiException(
      statusCode: error.response?.statusCode,
      message: error.message ?? 'Authentication request failed',
    );
  }
}
