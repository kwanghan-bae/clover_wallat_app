import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:js_util' as js_util;
import 'dart:html' as html;

/// HTTP 요청/응답을 콘솔에 로깅하는 유틸리티
/// 
/// 보안을 위해 프로덕션에서는 기본적으로 비활성화됨.
/// 브라우저 콘솔에서 `enableLog()` 또는 `enableLog(false)` 명령어로 토글 가능.
class HttpLogger {
  static bool _isEnabled = false;
  
  /// 로깅 활성화 여부 확인
  static bool get isEnabled => _isEnabled;
  
  /// 로깅을 활성화/비활성화
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
    print(enabled 
        ? '✅ HTTP 로깅 활성화됨 (enableLog(false)로 비활성화)' 
        : '❌ HTTP 로깅 비활성화됨 (enableLog()로 활성화)');
  }
  
  /// 브라우저 window 객체에 전역 함수 노출
  static void exposeToWindow() {
    try {
      // JavaScript에서 접근 가능한 전역 함수 등록 (dart:js_util 사용)
      js_util.setProperty(html.window, 'enableLog', js_util.allowInterop((bool enabled) {
        setEnabled(enabled);
      }));
      
      // 간편하게 파라미터 없이 호출 시 토글
      js_util.setProperty(html.window, 'toggleLog', js_util.allowInterop(() {
        setEnabled(!_isEnabled);
      }));
      
      print('🔒 디버그 모드: 콘솔에서 enableLog(true) 또는 enableLog(false) 실행 가능');
    } catch (e) {
      // Non-web platforms에서는 무시
      print('Warning: Could not expose debug functions to window: $e');
    }
  }
  
  /// 요청 로깅
  static void logRequest(String method, Uri url, Map<String, String>? headers, Object? body) {
    if (!_isEnabled) return;
    
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
    if (!_isEnabled) return;
    
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
      if (_isEnabled) {
        final elapsed = DateTime.now().difference(startTime);
        print('❌ Request failed in ${elapsed.inMilliseconds}ms: $e');
        print('');
      }
      rethrow;
    }
  }
}
