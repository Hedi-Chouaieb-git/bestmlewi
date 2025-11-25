import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  bool get isLoggedIn => _client.auth.currentSession != null;
}

