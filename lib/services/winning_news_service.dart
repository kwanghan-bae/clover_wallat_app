import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:clover_wallet_app/utils/api_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WinningNewsService {
  Future<List<Map<String, dynamic>>> getRecentWinningNews() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/winning-news/recent');
      final session = Supabase.instance.client.auth.currentSession;
      final token = session?.accessToken;

      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
