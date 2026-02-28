import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is required for Google/Facebook SDK flows.
  // If not configured yet, app still works for email/password auth.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {
    // Keep startup resilient for local backend testing.
  }

  runApp(const ProviderScope(child: GymVisitApp()));
}
