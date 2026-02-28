import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/gym_model.dart';

class GymApi {
  final Dio _dio;

  const GymApi(this._dio);

  Future<List<GymModel>> getActiveGyms() async {
    try {
      final response = await _dio.get('/api/v1/gyms/active');
      final raw = response.data as List<dynamic>;
      return raw
          .map((item) => GymModel.fromJson(item as Map<String, dynamic>))
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
      message: error.message ?? 'Failed to fetch gyms',
    );
  }
}
