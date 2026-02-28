import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/streak_model.dart';
import '../data/stats_api.dart';

class StatsState {
  final bool loading;
  final StreakModel? streak;
  final String? errorMessage;

  const StatsState({
    required this.loading,
    required this.streak,
    required this.errorMessage,
  });

  const StatsState.initial()
      : loading = false,
        streak = null,
        errorMessage = null;

  StatsState copyWith({
    bool? loading,
    StreakModel? streak,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StatsState(
      loading: loading ?? this.loading,
      streak: streak ?? this.streak,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class StatsController extends StateNotifier<StatsState> {
  final StatsApi _statsApi;

  StatsController(this._statsApi) : super(const StatsState.initial());

  Future<void> loadStreak() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final streak = await _statsApi.getMyStreak();
      state = state.copyWith(loading: false, streak: streak, clearError: true);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error is ApiException ? error.message : 'Failed to load streak',
      );
    }
  }
}
