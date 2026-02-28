import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/booking_model.dart';
import '../data/booking_api.dart';

class BookingState {
  final bool loading;
  final BookingModel? latestBooking;
  final List<BookingModel> bookings;
  final String? errorMessage;

  const BookingState({
    required this.loading,
    required this.latestBooking,
    required this.bookings,
    required this.errorMessage,
  });

  const BookingState.initial()
      : loading = false,
        latestBooking = null,
        bookings = const [],
        errorMessage = null;

  BookingState copyWith({
    bool? loading,
    BookingModel? latestBooking,
    List<BookingModel>? bookings,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingState(
      loading: loading ?? this.loading,
      latestBooking: latestBooking ?? this.latestBooking,
      bookings: bookings ?? this.bookings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class BookingController extends StateNotifier<BookingState> {
  final BookingApi _bookingApi;

  BookingController(this._bookingApi) : super(const BookingState.initial());

  Future<void> createBooking({
    required int gymId,
    required String bookingDate,
    required String startTime,
    required int durationHours,
    String? note,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final created = await _bookingApi.createBooking(
        gymId: gymId,
        bookingDate: bookingDate,
        startTime: startTime,
        durationHours: durationHours,
        note: note,
      );
      state = state.copyWith(loading: false, latestBooking: created, clearError: true);
      await loadMyBookings();
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error is ApiException ? error.message : 'Failed to create booking',
      );
    }
  }

  Future<void> loadMyBookings() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final items = await _bookingApi.getMyBookings();
      state = state.copyWith(loading: false, bookings: items, clearError: true);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error is ApiException ? error.message : 'Failed to load bookings',
      );
    }
  }

  Future<void> updateBooking({
    required int bookingId,
    required String bookingDate,
    required String startTime,
    required int durationHours,
    String? note,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final updated = await _bookingApi.updateBooking(
        bookingId: bookingId,
        bookingDate: bookingDate,
        startTime: startTime,
        durationHours: durationHours,
        note: note,
      );
      final mapped = state.bookings
          .map((b) => b.id == updated.id ? updated : b)
          .toList(growable: false);
      state = state.copyWith(
        loading: false,
        latestBooking: updated,
        bookings: mapped,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error is ApiException ? error.message : 'Failed to update booking',
      );
    }
  }

  Future<void> deleteBooking(int bookingId) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _bookingApi.deleteBooking(bookingId);
      final mapped = state.bookings.where((b) => b.id != bookingId).toList(growable: false);
      state = state.copyWith(loading: false, bookings: mapped, clearError: true);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error is ApiException ? error.message : 'Failed to delete booking',
      );
    }
  }
}
