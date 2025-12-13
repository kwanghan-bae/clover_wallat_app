import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://clover-wallet-api.onrender.com';
    }
    
    // Android Emulator requires 10.0.2.2 to access host localhost
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    
    // iOS Simulator and Web can use localhost
    return 'http://localhost:8080';
  }

  static const String communityPrefix = '/api/v1/community';
  static const String lottoSpotPrefix = '/api/v1/lotto-spots';
  static const String lottoPrefix = '/api/v1/lotto';
  static const String authPrefix = '/api/v1/auth';
  static const String ticketPrefix = '/api/v1/tickets';
  static const String travelPlansPrefix = '/api/v1/travel-plans';
}
