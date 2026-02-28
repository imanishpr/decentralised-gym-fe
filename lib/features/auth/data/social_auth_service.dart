import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/network/api_exception.dart';

enum SocialProvider { google, facebook, twitter }

class SocialProfile {
  final SocialProvider provider;
  final String providerUserId;
  final String name;
  final String email;

  const SocialProfile({
    required this.provider,
    required this.providerUserId,
    required this.name,
    required this.email,
  });
}

class SocialAuthService {
  Future<SocialProfile> signInWithGoogle() async {
    final account = await GoogleSignIn(scopes: ['email', 'profile']).signIn();
    if (account == null) {
      throw const ApiException(message: 'Google sign-in cancelled by user');
    }

    return SocialProfile(
      provider: SocialProvider.google,
      providerUserId: account.id,
      name: account.displayName ?? 'Google User',
      email: account.email,
    );
  }

  Future<SocialProfile> signInWithFacebook() async {
    final loginResult = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (loginResult.status != LoginStatus.success) {
      throw ApiException(
        message: loginResult.message ?? 'Facebook sign-in failed',
      );
    }

    final userData = await FacebookAuth.instance.getUserData(fields: 'id,name,email');
    final email = userData['email'] as String?;

    if (email == null || email.isEmpty) {
      throw const ApiException(
        message: 'Facebook account does not expose email. Add email permission first.',
      );
    }

    return SocialProfile(
      provider: SocialProvider.facebook,
      providerUserId: userData['id'] as String? ?? '',
      name: userData['name'] as String? ?? 'Facebook User',
      email: email,
    );
  }

  Future<SocialProfile> signInWithTwitterPlaceholder() {
    throw const ApiException(
      message: 'Twitter/X login placeholder. Wire OAuth provider and backend callback in next step.',
    );
  }
}
