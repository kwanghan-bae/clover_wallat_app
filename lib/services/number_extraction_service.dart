import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:clover_wallet_app/utils/api_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NumberExtractionService {
  Future<List<int>> extractNumbers(String method) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/extraction');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'strategy': _getStrategyFromMethod(method),
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final numbers = (data['numbers'] as List).cast<int>();
      return numbers;
    } else {
      throw Exception('Failed to extract numbers');
    }
  }

  String _getStrategyFromMethod(String method) {
    switch (method) {
      case 'AI':
        return 'FREQUENCY';  // Most frequent numbers
      case '통계':
        return 'FREQUENCY';
      case '운세':
        return 'RANDOM';
      case '랜덤':
      default:
        return 'RANDOM';
    }
  }
}
