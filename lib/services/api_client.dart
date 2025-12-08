import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/services/auth_service.dart';

class AuthenticatedClient {
  final AuthService _authService = AuthService();
  
  // Helper to get token and retry on 401
  Future<http.Response> _sendRequest(Future<http.Response> Function(String?) requestFn) async {
    String? token = await _authService.getAccessToken();
    var response = await requestFn(token);
    
    if (response.statusCode == 401) {
      // Try refresh
      final newToken = await _authService.refreshAccessToken();
      if (newToken != null) {
        // Retry with new token
        response = await requestFn(newToken);
      }
    }
    return response;
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers, String? token) {
    final Map<String, String> merged = headers ?? {};
    if (token != null) {
      merged['Authorization'] = 'Bearer $token';
    }
    // Ensure JSON content type if not present (optional, but good for API)
    // merged.putIfAbsent('Content-Type', () => 'application/json');
    return merged;
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return _sendRequest((token) => http.get(url, headers: _mergeHeaders(headers, token)));
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    return _sendRequest((token) => http.post(url, headers: _mergeHeaders(headers, token), body: body));
  }

  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
    return _sendRequest((token) => http.put(url, headers: _mergeHeaders(headers, token), body: body));
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body}) async {
    return _sendRequest((token) => http.delete(url, headers: _mergeHeaders(headers, token), body: body));
  }
}
