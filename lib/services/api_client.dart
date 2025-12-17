import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/services/auth_service.dart';
import 'dart:convert';

class AuthenticatedClient {
  final AuthService _authService = AuthService();
  
  // Log request details
  void _logRequest(String method, Uri url, Map<String, String>? headers, Object? body) {
    print('🌐 HTTP $method ${url.path}');
    print('   Full URL: $url');
    if (headers != null && headers.isNotEmpty) {
      // Mask Authorization header for security
      final maskedHeaders = Map<String, String>.from(headers);
      if (maskedHeaders.containsKey('Authorization')) {
        final auth = maskedHeaders['Authorization']!;
        maskedHeaders['Authorization'] = '${auth.substring(0, 20)}...${auth.substring(auth.length - 10)}';
      }
      print('   Headers: $maskedHeaders');
    }
    if (body != null) {
      try {
        final parsed = jsonDecode(body.toString());
        print('   Body: $parsed');
      } catch (_) {
        print('   Body: ${body.toString().substring(0, body.toString().length > 100 ? 100 : body.toString().length)}');
      }
    }
  }
  
  // Log response details
  void _logResponse(http.Response response, Duration elapsed) {
    final statusEmoji = response.statusCode >= 200 && response.statusCode < 300 ? '✅' : '❌';
    print('$statusEmoji Response [${response.statusCode}] in ${elapsed.inMilliseconds}ms');
    
    if (response.headers.isNotEmpty) {
      print('   Response Headers: ${response.headers}');
    }
    
    if (response.body.isNotEmpty) {
      try {
        final parsed = jsonDecode(utf8.decode(response.bodyBytes));
        print('   Response Body: $parsed');
      } catch (_) {
        final bodyPreview = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
        print('   Response Body (raw): $bodyPreview');
      }
    }
  }
  
  // Helper to get token and retry on 401
  Future<http.Response> _sendRequest(
    String method,
    Uri url,
    Future<http.Response> Function(String?) requestFn,
    {Map<String, String>? headers, Object? body}
  ) async {
    final startTime = DateTime.now();
    
    _logRequest(method, url, headers, body);
    
    String? token = await _authService.getAccessToken();
    var response = await requestFn(token);
    
    final elapsed = DateTime.now().difference(startTime);
    _logResponse(response, elapsed);
    
    if (response.statusCode == 401) {
      print('⚠️  401 Unauthorized - Attempting token refresh...');
      
      // Try refresh
      final newToken = await _authService.refreshAccessToken();
      if (newToken != null) {
        print('✅ Token refreshed - Retrying request...');
        // Retry with new token
        final retryStart = DateTime.now();
        response = await requestFn(newToken);
        final retryElapsed = DateTime.now().difference(retryStart);
        _logResponse(response, retryElapsed);
      }
      
      // If still 401 after retry (or if refresh failed/returned null), force logout
      if (response.statusCode == 401) {
        print('❌ Still 401 after refresh - Forcing logout');
        await _authService.signOut();
      }
    }
    
    print(''); // Empty line for readability
    return response;
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers, String? token) {
    final Map<String, String> merged = headers ?? {};
    if (token != null) {
      merged['Authorization'] = 'Bearer $token';
    }
    return merged;
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return _sendRequest(
      'GET',
      url,
      (token) => http.get(url, headers: _mergeHeaders(headers, token)),
      headers: _mergeHeaders(headers, null),
    );
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    return _sendRequest(
      'POST',
      url,
      (token) => http.post(url, headers: _mergeHeaders(headers, token), body: body),
      headers: _mergeHeaders(headers, null),
      body: body,
    );
  }

  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
    return _sendRequest(
      'PUT',
      url,
      (token) => http.put(url, headers: _mergeHeaders(headers, token), body: body),
      headers: _mergeHeaders(headers, null),
      body: body,
    );
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body}) async {
    return _sendRequest(
      'DELETE',
      url,
      (token) => http.delete(url, headers: _mergeHeaders(headers, token), body: body),
      headers: _mergeHeaders(headers, null),
      body: body,
    );
  }
}
