import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../shared/models/auth_response_model.dart';
import '../../../shared/models/user_model.dart';
import '../data/auth_api.dart';
import '../data/social_auth_service.dart';

class AuthState {
  final bool initialized;
  final bool loading;
  final String? errorMessage;
  final String? token;
  final UserModel? user;

  const AuthState({
    required this.initialized,
    required this.loading,
    required this.errorMessage,
    required this.token,
    required this.user,
  });

  const AuthState.initial()
      : initialized = false,
        loading = false,
        errorMessage = null,
        token = null,
        user = null;

  bool get isAuthenticated => token != null && user != null;

  AuthState copyWith({
    bool? initialized,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    String? token,
    bool clearToken = false,
    UserModel? user,
    bool clearUser = false,
  }) {
    return AuthState(
      initialized: initialized ?? this.initialized,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      token: clearToken ? null : (token ?? this.token),
      user: clearUser ? null : (user ?? this.user),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthApi _authApi;
  final SocialAuthService _socialAuthService;
  final SecureStorageService _storageService;

  AuthController({
    required AuthApi authApi,
    required SocialAuthService socialAuthService,
    required SecureStorageService storageService,
  })  : _authApi = authApi,
        _socialAuthService = socialAuthService,
        _storageService = storageService,
        super(const AuthState.initial()) {
    bootstrap();
  }

  Future<void> bootstrap() async {
    final token = await _storageService.readToken();
    final user = await _storageService.readUser();

    if (token == null || user == null) {
      state = state.copyWith(initialized: true, clearToken: true, clearUser: true);
      return;
    }

    state = state.copyWith(initialized: true, token: token, user: user, clearError: true);

    try {
      final freshUser = await _authApi.me();
      await _storageService.saveSession(token: token, user: freshUser);
      state = state.copyWith(user: freshUser, clearError: true);
    } catch (_) {
      await logout();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final auth = await _authApi.login(email: email.trim(), password: password);
      await _applySession(auth);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: _messageFromError(error),
      );
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final auth = await _authApi.signup(
        name: name.trim(),
        email: email.trim(),
        password: password,
        confirmPassword: confirmPassword,
      );
      await _applySession(auth);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: _messageFromError(error),
      );
    }
  }

  Future<void> loginWithGoogle() async {
    await _loginWithSocialProvider(() => _socialAuthService.signInWithGoogle());
  }

  Future<void> loginWithFacebook() async {
    await _loginWithSocialProvider(() => _socialAuthService.signInWithFacebook());
  }

  Future<void> loginWithTwitter() async {
    await _loginWithSocialProvider(() => _socialAuthService.signInWithTwitterPlaceholder());
  }

  Future<void> _loginWithSocialProvider(Future<SocialProfile> Function() providerCall) async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final profile = await providerCall();

      // Bridge strategy: derive deterministic password from provider identity,
      // then use existing backend /signup + /login endpoints.
      final socialPassword = 'S0c!al-${profile.provider.name}-${profile.providerUserId}';

      AuthResponseModel auth;
      try {
        auth = await _authApi.login(email: profile.email, password: socialPassword);
      } catch (error) {
        final apiError = error is ApiException ? error : const ApiException(message: 'Social login failed');
        if (apiError.statusCode == 400 || apiError.statusCode == 401 || apiError.statusCode == 404) {
          auth = await _authApi.signup(
            name: profile.name,
            email: profile.email,
            password: socialPassword,
            confirmPassword: socialPassword,
          );
        } else {
          rethrow;
        }
      }

      await _applySession(auth);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: _messageFromError(error),
      );
    }
  }

  Future<void> _applySession(AuthResponseModel auth) async {
    await _storageService.saveSession(token: auth.token, user: auth.user);
    state = state.copyWith(
      initialized: true,
      loading: false,
      clearError: true,
      token: auth.token,
      user: auth.user,
    );
  }

  Future<void> logout() async {
    await _storageService.clearSession();
    state = state.copyWith(
      initialized: true,
      loading: false,
      clearError: true,
      clearToken: true,
      clearUser: true,
    );
  }

  String _messageFromError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }
}
