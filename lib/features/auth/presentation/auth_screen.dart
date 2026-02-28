import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignup = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gym Visit Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_isSignup)
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (_isSignup && (value == null || value.trim().isEmpty)) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Minimum 8 characters';
                      }
                      return null;
                    },
                  ),
                  if (_isSignup) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Confirm password'),
                      validator: (value) {
                        if (_isSignup && value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: authState.loading ? null : _submitPrimaryAuth,
                    child: Text(_isSignup ? 'Sign up' : 'Login'),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: authState.loading
                  ? null
                  : () => setState(() {
                        _isSignup = !_isSignup;
                      }),
              child: Text(_isSignup ? 'Already have an account? Login' : 'No account? Sign up'),
            ),
            const Divider(height: 24),
            OutlinedButton.icon(
              onPressed: authState.loading ? null : () => ref.read(authControllerProvider.notifier).loginWithGoogle(),
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: authState.loading ? null : () => ref.read(authControllerProvider.notifier).loginWithFacebook(),
              icon: const Icon(Icons.facebook),
              label: const Text('Continue with Facebook'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: authState.loading ? null : () => ref.read(authControllerProvider.notifier).loginWithTwitter(),
              icon: const Icon(Icons.alternate_email),
              label: const Text('Continue with Twitter/X'),
            ),
            if (authState.loading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (authState.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                authState.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _submitPrimaryAuth() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSignup) {
      ref.read(authControllerProvider.notifier).signup(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          );
      return;
    }

    ref.read(authControllerProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );
  }
}
