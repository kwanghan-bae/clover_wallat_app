import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:clover_wallet_app/utils/api_config.dart';

import 'package:clover_wallet_app/services/auth_service.dart';

class LottoInfoService {
  Future<Map<String, dynamic>> getNextDrawInfo() async {
    try {
      final token = await AuthService().getAccessToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/lotto-info/next-draw');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }
      }
      
      // Fallback to empty or throw
      throw Exception('Failed to load next draw info: ${response.statusCode}');
    } catch (e) {
      // Re-throw to allow UI to handle error
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDrawResult(int round) async {
    try {
      final token = await AuthService().getAccessToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/lotto-info/draw-result?round=$round');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }
      }
      
      throw Exception('Failed to load draw result');
    } catch (e) {
      // Return empty map or rethrow to handle UI side
      return {};
    }
  }
}
