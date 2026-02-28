import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/booking_model.dart';

class BookingApi {
  final Dio _dio;

  const BookingApi(this._dio);

  Future<BookingModel> createBooking({
    required int gymId,
    required String bookingDate,
    required String startTime,
    required int durationHours,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/bookings/create',
        data: {
          'gymId': gymId,
          'bookingDate': bookingDate,
          'startTime': startTime,
          'durationHours': durationHours,
          'note': note,
        },
      );
      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await _dio.get('/api/v1/bookings/my-bookings');
      final raw = response.data as List<dynamic>;
      return raw
          .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<BookingModel> updateBooking({
    required int bookingId,
    required String bookingDate,
    required String startTime,
    required int durationHours,
    String? note,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/bookings/$bookingId',
        data: {
          'bookingDate': bookingDate,
          'startTime': startTime,
          'durationHours': durationHours,
          'note': note,
        },
      );
      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<void> deleteBooking(int bookingId) async {
    try {
      await _dio.delete('/api/v1/bookings/$bookingId');
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
      message: error.message ?? 'Booking request failed',
    );
  }
}
