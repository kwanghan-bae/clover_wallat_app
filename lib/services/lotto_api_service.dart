import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clover_wallet_app/models/lotto_game_model.dart';
import 'package:clover_wallet_app/models/lotto_ticket_model.dart';
import 'package:clover_wallet_app/services/auth_service.dart';
import 'package:clover_wallet_app/utils/api_config.dart';

class LottoApiService {
  Future<List<LottoGame>> getMyGames(int page, int size) async {
    final userId = await AuthService().getUserId();
    if (userId == null) throw Exception('User not logged in');
    
    // Get current session for token
    // AuthService doesn't expose token directly easily. 
    // Let's check AuthService again or use Supabase client directly.
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) throw Exception('No auth token found');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoPrefix}/games?userId=$userId&page=$page&size=$size');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      final data = decodedBody['data'];
      final content = data['content'] as List;
      return content.map((e) => LottoGame.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load games');
    }
  }

  Future<List<LottoTicket>> getMyTickets(int page, int size) async {
    final userId = await AuthService().getUserId();
    if (userId == null) throw Exception('User not logged in');

    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) throw Exception('No auth token found');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoPrefix}/tickets?userId=$userId&page=$page&size=$size');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      final data = decodedBody['data'];
      final content = data['content'] as List;
      return content.map((e) => LottoTicket.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load tickets');
    }
  }

  Future<void> saveGame(List<int> numbers) async {
    final userId = await AuthService().getUserId();
    if (userId == null) throw Exception('User not logged in');

    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) throw Exception('No auth token found');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoPrefix}/games');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'numbers': numbers,
        'extractionMethod': 'GENERATED' // Or pass from argument if needed
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save game');
    }
  }
}

