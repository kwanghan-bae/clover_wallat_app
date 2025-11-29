import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/utils/api_config.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '846091329209-6phtprpfm4bbo93su54t4e4ips7rurs6.apps.googleusercontent.com',
  );

  Future<AuthResponse> signInWithGoogle() async {
    try {
      // 1. Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled by user');
      }

      // 2. Get Auth Details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw Exception('No Access Token found from Google Sign-In');
      }
      if (idToken == null) {
        throw Exception('No ID Token found from Google Sign-In');
      }

      // 3. Supabase Sign In
      final authResponse = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // 4. Backend Sync
      final session = authResponse.session;
      if (session != null && session.accessToken.isNotEmpty) {
        await _syncWithBackend(session.accessToken);
      } else {
        if (kDebugMode) {
          print('Warning: No session returned from Supabase');
        }
      }

      return authResponse;
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In Error Details: $e');
      }
      rethrow;
    }
  }

  Future<void> _syncWithBackend(String jwtToken) async {
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
        // Non-blocking failure? Or should we throw?
        // For now, just log it.
      }
    } catch (e) {
      print('Backend sync error: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await Supabase.instance.client.auth.signOut();
  }

  User? get currentUser => Supabase.instance.client.auth.currentUser;
}

