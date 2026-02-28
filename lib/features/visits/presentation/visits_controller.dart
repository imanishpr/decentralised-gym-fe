import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/visit_model.dart';
import '../data/visits_api.dart';

class VisitsState {
  final bool loading;
  final List<VisitModel> visits;
  final String? errorMessage;

  const VisitsState({
    required this.loading,
    required this.visits,
    required this.errorMessage,
  });

  const VisitsState.initial()
      : loading = false,
        visits = const [],
        errorMessage = null;

  VisitsState copyWith({
    bool? loading,
    List<VisitModel>? visits,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VisitsState(
      loading: loading ?? this.loading,
      visits: visits ?? this.visits,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class VisitsController extends StateNotifier<VisitsState> {
  final VisitsApi _visitsApi;

  VisitsController(this._visitsApi) : super(const VisitsState.initial());

  Future<void> loadMyVisits() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final data = await _visitsApi.getMyVisits();
      state = state.copyWith(loading: false, visits: data, clearError: true);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error is ApiException ? error.message : 'Failed to fetch visit history',
      );
    }
  }
}
