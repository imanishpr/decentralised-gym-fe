import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/streak_model.dart';

class StatsApi {
  final Dio _dio;

  const StatsApi(this._dio);

  Future<StreakModel> getMyStreak() async {
    try {
      final response = await _dio.get('/api/v1/stats/my-streak');
      return StreakModel.fromJson(response.data as Map<String, dynamic>);
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
      message: error.message ?? 'Failed to fetch streak',
    );
  }
}
