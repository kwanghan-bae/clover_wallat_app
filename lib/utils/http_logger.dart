import 'package:http/http.dart' as http;
import 'dart:convert';

/// HTTP 요청/응답을 콘솔에 로깅하는 유틸리티
class HttpLogger {
  /// 요청 로깅
  static void logRequest(String method, Uri url, Map<String, String>? headers, Object? body) {
    print('🌐 HTTP $method ${url.path}');
    print('   Full URL: $url');
    
    if (headers != null && headers.isNotEmpty) {
      // Authorization 헤더 마스킹 (보안)
      final maskedHeaders = Map<String, String>.from(headers);
      if (maskedHeaders.containsKey('Authorization')) {
        final auth = maskedHeaders['Authorization']!;
        if (auth.length > 30) {
          maskedHeaders['Authorization'] = '${auth.substring(0, 20)}...${auth.substring(auth.length - 10)}';
        }
      }
      print('   Headers: $maskedHeaders');
    }
    
    if (body != null) {
      try {
        final parsed = jsonDecode(body.toString());
        print('   Body: $parsed');
      } catch (_) {
        final preview = body.toString();
        print('   Body: ${preview.length > 100 ? '${preview.substring(0, 100)}...' : preview}');
      }
    }
  }
  
  /// 응답 로깅
  static void logResponse(http.Response response, Duration elapsed) {
    final statusEmoji = response.statusCode >= 200 && response.statusCode < 300 ? '✅' : '❌';
    print('$statusEmoji Response [${response.statusCode}] in ${elapsed.inMilliseconds}ms');
    
    if (response.body.isNotEmpty) {
      try {
        final parsed = jsonDecode(utf8.decode(response.bodyBytes));
        print('   Response Body: $parsed');
      } catch (_) {
        final bodyPreview = response.body.length > 200 
            ? '${response.body.substring(0, 200)}...' 
            : response.body;
        print('   Response Body (raw): $bodyPreview');
      }
    }
    print(''); // 가독성을 위한 빈 줄
  }
  
  /// HTTP 요청을 로깅과 함께 실행
  static Future<http.Response> loggedRequest(
    String method,
    Uri url,
    Future<http.Response> Function() requestFn,
    {Map<String, String>? headers, Object? body}
  ) async {
    final startTime = DateTime.now();
    logRequest(method, url, headers, body);
    
    try {
      final response = await requestFn();
      final elapsed = DateTime.now().difference(startTime);
      logResponse(response, elapsed);
      return response;
    } catch (e) {
      final elapsed = DateTime.now().difference(startTime);
      print('❌ Request failed in ${elapsed.inMilliseconds}ms: $e');
      print('');
      rethrow;
    }
  }
}
