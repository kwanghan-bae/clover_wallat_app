import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:clover_wallet_app/utils/api_config.dart';
import 'package:clover_wallet_app/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserStatsService {
  Future<Map<String, dynamic>> getUserStats() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Get user ID from AuthService
    final userId = await AuthService().getUserId();
    if (userId == null) {
      return {'totalWinnings': 0, 'roi': 0};
    }

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/$userId/stats');
      final session = Supabase.instance.client.auth.currentSession;
      final token = session?.accessToken;

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {'totalWinnings': 0, 'roi': 0};
    } catch (e) {
      // 에러 발생 시 기본값 반환 (0원, 0%)
      return {'totalWinnings': 0, 'roi': 0};
    }
  }
}
