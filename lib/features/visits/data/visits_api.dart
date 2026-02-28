import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/visit_model.dart';

class VisitsApi {
  final Dio _dio;

  const VisitsApi(this._dio);

  Future<List<VisitModel>> getMyVisits() async {
    try {
      final response = await _dio.get('/api/v1/visits/my-visits');
      final raw = response.data as List<dynamic>;
      return raw
          .map((item) => VisitModel.fromJson(item as Map<String, dynamic>))
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
      message: error.message ?? 'Failed to fetch visits',
    );
  }
}
