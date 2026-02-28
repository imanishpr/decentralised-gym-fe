import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/gym_model.dart';
import '../data/gym_api.dart';

class GymListState {
  final bool loading;
  final List<GymModel> gyms;
  final String? errorMessage;

  const GymListState({
    required this.loading,
    required this.gyms,
    required this.errorMessage,
  });

  const GymListState.initial()
      : loading = false,
        gyms = const [],
        errorMessage = null;

  GymListState copyWith({
    bool? loading,
    List<GymModel>? gyms,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GymListState(
      loading: loading ?? this.loading,
      gyms: gyms ?? this.gyms,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class GymController extends StateNotifier<GymListState> {
  final GymApi _gymApi;

  GymController(this._gymApi) : super(const GymListState.initial());

  Future<void> loadGyms() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final gyms = await _gymApi.getActiveGyms();
      state = state.copyWith(loading: false, gyms: gyms, clearError: true);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error is ApiException ? error.message : 'Failed to load gyms',
      );
    }
  }
}
