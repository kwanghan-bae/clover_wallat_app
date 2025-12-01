import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/utils/api_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  Future<void> deleteAccount() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/me');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete account: ${response.statusCode}');
    }
  }
}
