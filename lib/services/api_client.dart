import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/services/auth_service.dart';
import 'package:clover_wallet_app/utils/http_logger.dart';

class AuthenticatedClient {
  final AuthService _authService = AuthService();
  
  // Helper to get token and retry on 401
  Future<http.Response> _sendRequest(
    String method,
    Uri url,
    Future<http.Response> Function(String?) requestFn,
    {Map<String, String>? headers, Object? body}
  ) async {
    String? token = await _authService.getAccessToken();
    
    var response = await HttpLogger.loggedRequest(
      method,
      url,
      () => requestFn(token),
      headers: _mergeHeaders(headers, token),
      body: body,
    );
    
    if (response.statusCode == 401) {
      print('⚠️  401 Unauthorized - Attempting token refresh...');
      
      final newToken = await _authService.refreshAccessToken();
      if (newToken != null) {
        print('✅ Token refreshed - Retrying request...');
        response = await HttpLogger.loggedRequest(
          method,
          url,
          () => requestFn(newToken),
          headers: _mergeHeaders(headers, newToken),
          body: body,
        );
      }
      
      if (response.statusCode == 401) {
        print('❌ Still 401 after refresh - Forcing logout');
        await _authService.signOut();
      }
    }
    
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
      headers: headers,
    );
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    return _sendRequest(
      'POST',
      url,
      (token) => http.post(url, headers: _mergeHeaders(headers, token), body: body),
      headers: headers,
      body: body,
    );
  }

  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
    return _sendRequest(
      'PUT',
      url,
      (token) => http.put(url, headers: _mergeHeaders(headers, token), body: body),
      headers: headers,
      body: body,
    );
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body}) async {
    return _sendRequest(
      'DELETE',
      url,
      (token) => http.delete(url, headers: _mergeHeaders(headers, token), body: body),
      headers: headers,
      body: body,
    );
  }
}
