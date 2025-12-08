import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/utils/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'userId';

  Future<bool> signInWithGoogle() async {
    try {
      final bool isWeb = kIsWeb;
      final bool result = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: isWeb ? Uri.base.origin : 'io.supabase.flutterdemo://login-callback',
      );

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In Error Details: $e');
      }
      rethrow;
    }
  }

  // Called after Supabase auth is successful
  Future<void> syncWithBackend(String supabaseJwtToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authPrefix}/login');
    try {
      if (kDebugMode) {
        print('Logging in to backend: $url');
      }
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $supabaseJwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        
        // Handle standard CommonResponse structure if used, or direct DTO
        // Assuming CommonResponse<LoginResponse> based on AuthController
        final data = body['data'] ?? body; 
        
        final String accessToken = data['accessToken'];
        final String refreshToken = data['refreshToken'];
        final Map<String, dynamic> user = data['user'];
        final int userId = user['id'];

        await _saveTokens(accessToken, refreshToken);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_userIdKey, userId);
        
        if (kDebugMode) {
          print('Backend login success. UserId: $userId');
        }
      } else {
        throw Exception('Backend login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Backend login error: $e');
      }
      rethrow;
    }
  }
  
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    if (kIsWeb) {
      // On web, secure storage might not be persistent across sessions depending on implementation
      // For now using secure storage plugin which handles web via shared_preferences with encryption if possible
      // or falling back to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
    } else {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }
  
  Future<String?> getAccessToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    }
    return await _storage.read(key: _accessTokenKey);
  }
  
  Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    }
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return null;
      
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authPrefix}/refresh');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final data = body['data'] ?? body;
        final newAccessToken = data['accessToken'];
        // Note: If backend implements rotation, we might get a new refresh token too
        
        if (kIsWeb) {
           final prefs = await SharedPreferences.getInstance();
           await prefs.setString(_accessTokenKey, newAccessToken);
        } else {
           await _storage.write(key: _accessTokenKey, value: newAccessToken);
        }
        
        return newAccessToken;
      } else {
        // Refresh failed, assume logout
        await signOut();
        return null;
      }
    } catch (e) {
      print('Token refresh failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      // Call backend logout
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      
      if (accessToken != null && refreshToken != null) {
        final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authPrefix}/logout');
        await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      }
    } catch (e) {
      // Ignore errors during logout
    } finally {
      await _supabase.auth.signOut();
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_accessTokenKey);
        await prefs.remove(_refreshTokenKey);
        await prefs.remove(_userIdKey);
      } else {
        await _storage.delete(key: _accessTokenKey);
        await _storage.delete(key: _refreshTokenKey);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
    }
  }

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}

