import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://api.cloverwallet.com'; // Replace with real prod URL
    }
    
    // Android Emulator requires 10.0.2.2 to access host localhost
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    
    // iOS Simulator and Web can use localhost
    return 'http://localhost:8080';
  }

  static const String communityPrefix = '/v1/community';
  static const String lottoSpotPrefix = '/v1/lotto-spots';
  static const String lottoPrefix = '/v1/lotto';
}
