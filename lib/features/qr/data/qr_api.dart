import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/scan_code_response_model.dart';

class QrApi {
  final Dio _dio;

  const QrApi(this._dio);

  Future<ScanCodeResponseModel> scanCode(String code) async {
    try {
      final response = await _dio.post(
        '/api/v1/visit-codes/scan',
        data: {'code': code},
      );
      return ScanCodeResponseModel.fromJson(response.data as Map<String, dynamic>);
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
      message: error.message ?? 'QR scan failed',
    );
  }
}
