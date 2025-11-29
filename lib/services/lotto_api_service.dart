import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/models/lotto_winnings.dart';
import 'package:clover_wallet_app/utils/api_config.dart';

class LottoApiService {
  Future<LottoWinnings> checkWinnings({required int userId}) async {
    // Note: This endpoint might need to be updated based on backend implementation
    // Currently pointing to /api/v1/lotto/check-winnings
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoPrefix}/check-winnings?userId=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return LottoWinnings.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('Failed to load winning data');
    }
  }
}

