import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:clover_wallet_app/utils/api_config.dart';

class LottoInfoService {
  Future<Map<String, dynamic>> getNextDrawInfo() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/lotto-info/next-draw');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }
      }
      
      // Fallback to mock data
      return _getMockData();
    } catch (e) {
      return _getMockData();
    }
  }

  Future<Map<String, dynamic>> getDrawResult(int round) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/lotto-info/draw-result?round=$round');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
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
      // For now, returning empty map to indicate failure/no data
      return {};
    }
  }

  Map<String, dynamic> _getMockData() {
    return {
      'currentRound': 1100,
      'daysLeft': 3,
      'hoursLeft': 12,
      'minutesLeft': 30,
      'estimatedJackpot': 30000000000,
    };
  }
}
