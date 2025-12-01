import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/models/lotto_game_model.dart';
import 'package:clover_wallet_app/models/lotto_ticket_model.dart';
import 'package:clover_wallet_app/services/auth_service.dart';
import 'package:clover_wallet_app/utils/api_config.dart';

class LottoApiService {
  Future<List<LottoGame>> getMyGames(int page, int size) async {
    final userId = await AuthService().getUserId();
    if (userId == null) throw Exception('User not logged in');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoPrefix}/games?userId=$userId&page=$page&size=$size');
    // TODO: Add Authorization header
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      // Handle CommonResponse or Page response structure
      // Assuming CommonResponse<Page<LottoGame>>
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
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      final data = decodedBody['data'];
      final content = data['content'] as List;
      return content.map((e) => LottoTicket.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load tickets');
    }
  }
}

