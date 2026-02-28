import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/dio_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/social_auth_service.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/bookings/data/booking_api.dart';
import 'features/bookings/presentation/booking_controller.dart';
import 'features/gyms/data/gym_api.dart';
import 'features/gyms/presentation/gym_controller.dart';
import 'features/gym_owner/data/gym_owner_api.dart';
import 'features/gym_owner/presentation/gym_owner_controller.dart';
import 'features/qr/data/qr_api.dart';
import 'features/qr/presentation/qr_controller.dart';
import 'features/stats/data/stats_api.dart';
import 'features/stats/presentation/stats_controller.dart';
import 'features/visits/data/visits_api.dart';
import 'features/visits/presentation/visits_controller.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(ref.watch(flutterSecureStorageProvider));
});

final dioProvider = Provider<Dio>((ref) {
  final client = DioClient(storageService: ref.watch(secureStorageServiceProvider));
  return client.build();
});

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(dioProvider)));
final gymApiProvider = Provider<GymApi>((ref) => GymApi(ref.watch(dioProvider)));
final gymOwnerApiProvider = Provider<GymOwnerApi>((ref) => GymOwnerApi(ref.watch(dioProvider)));
final bookingApiProvider = Provider<BookingApi>((ref) => BookingApi(ref.watch(dioProvider)));
final qrApiProvider = Provider<QrApi>((ref) => QrApi(ref.watch(dioProvider)));
final visitsApiProvider = Provider<VisitsApi>((ref) => VisitsApi(ref.watch(dioProvider)));
final statsApiProvider = Provider<StatsApi>((ref) => StatsApi(ref.watch(dioProvider)));

final socialAuthServiceProvider = Provider<SocialAuthService>((ref) => SocialAuthService());

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    authApi: ref.watch(authApiProvider),
    socialAuthService: ref.watch(socialAuthServiceProvider),
    storageService: ref.watch(secureStorageServiceProvider),
  );
});

final gymControllerProvider = StateNotifierProvider<GymController, GymListState>((ref) {
  return GymController(ref.watch(gymApiProvider));
});

final gymOwnerControllerProvider = StateNotifierProvider<GymOwnerController, GymOwnerState>((ref) {
  return GymOwnerController(ref.watch(gymOwnerApiProvider));
});

final bookingControllerProvider = StateNotifierProvider<BookingController, BookingState>((ref) {
  return BookingController(ref.watch(bookingApiProvider));
});

final qrControllerProvider = StateNotifierProvider<QrController, QrState>((ref) {
  return QrController(ref.watch(qrApiProvider));
});

final visitsControllerProvider = StateNotifierProvider<VisitsController, VisitsState>((ref) {
  return VisitsController(ref.watch(visitsApiProvider));
});

final statsControllerProvider = StateNotifierProvider<StatsController, StatsState>((ref) {
  return StatsController(ref.watch(statsApiProvider));
});
