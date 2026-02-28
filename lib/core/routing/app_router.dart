import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/bookings/presentation/booking_screen.dart';
import '../../features/bookings/presentation/my_bookings_screen.dart';
import '../../features/gyms/presentation/gym_list_screen.dart';
import '../../features/gym_owner/presentation/gym_owner_dashboard_screen.dart';
import '../../features/gym_owner/presentation/qr_manager_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/qr/presentation/qr_scanner_screen.dart';
import '../../features/stats/presentation/streak_screen.dart';
import '../../features/visits/presentation/visit_history_screen.dart';
import '../../providers.dart';
import '../../shared/models/gym_model.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      final path = state.uri.path;
      final initialized = authState.initialized;
      final isAuthenticated = authState.isAuthenticated;
      final role = authState.user?.role.toUpperCase();
      final isOwnerFlow = role == 'ADMIN' || role == 'GYM_OWNER';

      if (!initialized) {
        return path == '/splash' ? null : '/splash';
      }

      if (!isAuthenticated) {
        return path == '/auth' ? null : '/auth';
      }

      if (path == '/splash' || path == '/auth') {
        return isOwnerFlow ? '/owner' : '/gyms';
      }

      if (isOwnerFlow && !path.startsWith('/owner') && path != '/profile') {
        return '/owner';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/gyms',
        builder: (context, state) => const GymListScreen(),
      ),
      GoRoute(
        path: '/owner',
        builder: (context, state) => const GymOwnerDashboardScreen(),
      ),
      GoRoute(
        path: '/owner/qr',
        builder: (context, state) => const QrManagerScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final gym = state.extra;
          if (gym is! GymModel) {
            return const _RouteErrorScreen(message: 'Missing gym data for booking route');
          }
          return BookingScreen(gym: gym);
        },
      ),
      GoRoute(
        path: '/my-bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/visits',
        builder: (context, state) => const VisitHistoryScreen(),
      ),
      GoRoute(
        path: '/streak',
        builder: (context, state) => const StreakScreen(),
      ),
    ],
  );
});

class _RouteErrorScreen extends StatelessWidget {
  final String message;

  const _RouteErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}
