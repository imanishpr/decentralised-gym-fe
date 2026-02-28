import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../models/current_gym_user_model.dart';
import '../models/owner_gym_model.dart';
import '../models/qr_batch_model.dart';
import '../models/qr_code_with_image_model.dart';

class GymOwnerApi {
  final Dio _dio;

  const GymOwnerApi(this._dio);

  Future<List<OwnerGymModel>> getManagedGyms() async {
    try {
      final response = await _dio.get('/api/v2/gym-owner/gyms');
      final raw = response.data as List<dynamic>;
      return raw
          .map((item) => OwnerGymModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<OwnerGymModel> updateGym({
    required int gymId,
    required bool active,
    required int maxDailyVisits,
    required String activeFromTime,
    required String activeToTime,
    double? latitude,
    double? longitude,
    String? googleMapUrl,
    String? imageUrl,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v2/gym-owner/gym/$gymId',
        data: {
          'active': active,
          'maxDailyVisits': maxDailyVisits,
          'activeFromTime': activeFromTime,
          'activeToTime': activeToTime,
          'latitude': latitude,
          'longitude': longitude,
          'googleMapUrl': googleMapUrl,
          'imageUrl': imageUrl,
        },
      );
      return OwnerGymModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<List<CurrentGymUserModel>> getCurrentUsersInsideGym(int gymId) async {
    try {
      final response = await _dio.get('/api/v2/gym-owner/gym/$gymId/current-users');
      final raw = response.data as List<dynamic>;
      return raw
          .map((item) => CurrentGymUserModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<QrBatchModel> createQrBatch({
    required int gymId,
    required String batchName,
    required int totalCodes,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v2/qr/batch/create',
        data: {
          'gymId': gymId,
          'batchName': batchName,
          'totalCodes': totalCodes,
        },
      );
      return QrBatchModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<QrCodeWithImageModel> generateOneQr({
    required int gymId,
    int size = 300,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v2/qr/gym/$gymId/generate-one',
        queryParameters: {'size': size},
      );
      return QrCodeWithImageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<List<QrCodeWithImageModel>> getAvailableCodesWithQr({
    required int gymId,
    int limit = 50,
    int size = 220,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v2/qr/gym/$gymId/available/with-qr',
        queryParameters: {'limit': limit, 'size': size},
      );
      final raw = response.data as List<dynamic>;
      return raw
          .map((item) => QrCodeWithImageModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
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
      message: error.message ?? 'Gym owner request failed',
    );
  }
}
