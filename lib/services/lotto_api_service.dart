import 'dart:convert';
import 'package:clover_wallet_app/models/lotto_game_model.dart';
import 'package:clover_wallet_app/models/lotto_ticket_model.dart';
import 'package:clover_wallet_app/services/auth_service.dart';
import 'package:clover_wallet_app/utils/api_config.dart';
import 'package:clover_wallet_app/services/api_client.dart';

class LottoApiService {
  final AuthenticatedClient _client = AuthenticatedClient();

  Future<List<LottoGame>> getMyGames(int page, int size) async {
    final userId = await AuthService().getUserId();
    if (userId == null) throw Exception('User not logged in');
    
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoPrefix}/games?userId=$userId&page=$page&size=$size');
    final response = await _client.get(url);

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

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoPrefix}/tickets?userId=$userId&page=$page&size=$size');
    final response = await _client.get(url);

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

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoPrefix}/games');
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'numbers': numbers,
        'extractionMethod': 'GENERATED'
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save game');
    }
  }
}

