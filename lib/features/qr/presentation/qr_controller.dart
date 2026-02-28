import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/scan_code_response_model.dart';
import '../data/qr_api.dart';

class QrState {
  final bool loading;
  final ScanCodeResponseModel? result;
  final String? errorMessage;

  const QrState({
    required this.loading,
    required this.result,
    required this.errorMessage,
  });

  const QrState.initial()
      : loading = false,
        result = null,
        errorMessage = null;

  QrState copyWith({
    bool? loading,
    ScanCodeResponseModel? result,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QrState(
      loading: loading ?? this.loading,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class QrController extends StateNotifier<QrState> {
  final QrApi _qrApi;

  QrController(this._qrApi) : super(const QrState.initial());

  Future<void> scanCode(String code) async {
    if (code.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Code is required');
      return;
    }

    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await _qrApi.scanCode(code.trim());
      state = state.copyWith(loading: false, result: result, clearError: true);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error is ApiException ? error.message : 'Failed to scan code',
      );
    }
  }

  void clearResult() {
    state = const QrState.initial();
  }
}
