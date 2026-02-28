import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

class DioClient {
  final SecureStorageService storageService;

  DioClient({required this.storageService});

  Dio build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storageService.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final responseData = error.response?.data;
          final fallbackMessage = error.message ?? 'Unexpected API error';
          String message = fallbackMessage;

          if (responseData is Map<String, dynamic>) {
            final serverMessage = responseData['message'];
            if (serverMessage is String && serverMessage.isNotEmpty) {
              message = serverMessage;
            }
          }

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: ApiException(
                statusCode: error.response?.statusCode,
                message: message,
              ),
            ),
          );
        },
      ),
    );

    return dio;
  }
}
