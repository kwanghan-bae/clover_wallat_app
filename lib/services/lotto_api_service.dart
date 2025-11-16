import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/models/lotto_winnings.dart';

class LottoApiService {
  // For Android Emulator, use 10.0.2.2 to connect to host machine's localhost
  // For iOS Simulator, 'localhost' or '127.0.0.1' works directly.
  final String _baseUrl = 'http://127.0.0.1:8080';

  Future<LottoWinnings> checkWinnings({required int userId}) async {
    final response = await http.get(Uri.parse('$_baseUrl/v1/lotto/check-winnings?userId=$userId'));

    if (response.statusCode == 200) {
      // The response body is likely UTF-8 encoded.
      // http package handles basic decoding, but for complex characters, explicit decoding is safer.
      final decodedBody = utf8.decode(response.bodyBytes);
      return LottoWinnings.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('Failed to load winning data');
    }
  }
}
