# Gym Visit Flutter (Phase 1)

Flutter mobile client for your Spring Boot backend.

## Tech
- Flutter 4+ (Dart 3.5+)
- Riverpod for state management
- Dio for API calls
- GoRouter for navigation
- Flutter Secure Storage for JWT token persistence
- mobile_scanner for QR scanning
- Firebase + Google Sign-In + Facebook Auth

## Backend URLs used
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/signup`
- `GET /api/v1/auth/me`
- `GET /api/v1/gyms/active`
- `POST /api/v1/bookings/create`
- `GET /api/v1/bookings/my-bookings`
- `POST /api/v1/visit-codes/scan`
- `GET /api/v1/visits/my-visits`
- `GET /api/v1/stats/my-streak`

## Run
1. Install Flutter SDK and ensure `flutter` is on `PATH`.
2. In this folder run:
   - `flutter pub get`
   - `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8090`

Use this base URL by platform:
- Android emulator: `http://10.0.2.2:8090`
- iOS simulator: `http://localhost:8090`
- Physical device: `http://<your-laptop-ip>:8090`

## Social login setup
1. Add Firebase app files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
2. Configure Google and Facebook auth providers in Firebase Console.
3. For Facebook, add app id/client token in native configs.
4. Twitter/X button is a placeholder intentionally.

## Folder structure
- `lib/features/auth`
- `lib/features/gyms`
- `lib/features/bookings`
- `lib/features/qr`
- `lib/features/visits`
- `lib/features/stats`
- `lib/core` (router/network/storage/config)
- `lib/shared/models`
