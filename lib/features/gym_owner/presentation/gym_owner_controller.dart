import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/gym_owner_api.dart';
import '../models/current_gym_user_model.dart';
import '../models/owner_gym_model.dart';

class GymOwnerState {
  final bool loading;
  final List<OwnerGymModel> gyms;
  final int? selectedGymId;
  final List<CurrentGymUserModel> currentUsers;
  final String? errorMessage;

  const GymOwnerState({
    required this.loading,
    required this.gyms,
    required this.selectedGymId,
    required this.currentUsers,
    required this.errorMessage,
  });

  const GymOwnerState.initial()
      : loading = false,
        gyms = const [],
        selectedGymId = null,
        currentUsers = const [],
        errorMessage = null;

  GymOwnerState copyWith({
    bool? loading,
    List<OwnerGymModel>? gyms,
    int? selectedGymId,
    bool clearSelection = false,
    List<CurrentGymUserModel>? currentUsers,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GymOwnerState(
      loading: loading ?? this.loading,
      gyms: gyms ?? this.gyms,
      selectedGymId: clearSelection ? null : (selectedGymId ?? this.selectedGymId),
      currentUsers: currentUsers ?? this.currentUsers,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class GymOwnerController extends StateNotifier<GymOwnerState> {
  final GymOwnerApi _api;

  GymOwnerController(this._api) : super(const GymOwnerState.initial());

  Future<void> loadManagedGyms() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final gyms = await _api.getManagedGyms();
      final selected = gyms.isEmpty
          ? null
          : (state.selectedGymId != null && gyms.any((g) => g.id == state.selectedGymId)
              ? state.selectedGymId
              : gyms.first.id);
      state = state.copyWith(
        loading: false,
        gyms: gyms,
        selectedGymId: selected,
        currentUsers: const [],
        clearError: true,
      );
      if (selected != null) {
        await loadCurrentUsers(selected);
      }
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error is ApiException ? error.message : 'Failed to load gyms',
      );
    }
  }

  Future<void> selectGym(int gymId) async {
    state = state.copyWith(selectedGymId: gymId, clearError: true);
    await loadCurrentUsers(gymId);
  }

  Future<void> loadCurrentUsers(int gymId) async {
    try {
      final users = await _api.getCurrentUsersInsideGym(gymId);
      state = state.copyWith(currentUsers: users, clearError: true);
    } catch (error) {
      state = state.copyWith(
        errorMessage: error is ApiException ? error.message : 'Failed to load current users',
      );
    }
  }

  Future<void> updateGym({
    required int gymId,
    required bool active,
    required int maxDailyVisits,
    required String activeFromTime,
    required String activeToTime,
    double? latitude,
    double? longitude,
    String? googleMapUrl,
    String? imageUrl,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final updated = await _api.updateGym(
        gymId: gymId,
        active: active,
        maxDailyVisits: maxDailyVisits,
        activeFromTime: activeFromTime,
        activeToTime: activeToTime,
        latitude: latitude,
        longitude: longitude,
        googleMapUrl: googleMapUrl,
        imageUrl: imageUrl,
      );

      final updatedGyms = state.gyms
          .map((gym) => gym.id == updated.id ? updated : gym)
          .toList(growable: false);

      state = state.copyWith(loading: false, gyms: updatedGyms, clearError: true);
      await loadCurrentUsers(gymId);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error is ApiException ? error.message : 'Failed to update gym',
      );
    }
  }
}
