import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/utils/api_config.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> signInWithGoogle() async {
    try {
      // Use Supabase OAuth directly (works better on web)
      // This will trigger a redirect flow on web
      final bool isWeb = kIsWeb;
      final bool result = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: isWeb ? Uri.base.origin : 'io.supabase.flutterdemo://login-callback',
      );

      if (kDebugMode) {
        print('OAuth initiated successfully: $result');
      }

      return result; // Web will redirect, so this might not return immediately in the same session
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In Error Details: $e');
      }
      rethrow;
    }
  }

  // Session sync is handled by AuthStateChangeListener in main.dart or manually called after redirect
  Future<void> syncWithBackend(String jwtToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authPrefix}/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print('Backend sync failed: ${response.statusCode}');
      } else {
        print('Backend sync success');
      }
    } catch (e) {
      print('Backend sync error: $e');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}

