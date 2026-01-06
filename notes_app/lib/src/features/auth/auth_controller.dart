import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthController(client);
});

class AuthController {
  AuthController(this._client);

  final SupabaseClient _client;

  Future<String?> signUp(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    try {
      await _client.auth.signUp(
        email: trimmedEmail,
        password: trimmedPassword,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> signIn(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    try {
      await _client.auth.signInWithPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> signOut() => _client.auth.signOut();
}


