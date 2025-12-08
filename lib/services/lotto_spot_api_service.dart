import 'dart:convert';
import 'package:clover_wallet_app/models/lotto_spot_model.dart';
import 'package:clover_wallet_app/utils/api_config.dart';
import 'package:clover_wallet_app/services/api_client.dart';

class LottoSpotApiService {
  final AuthenticatedClient _client = AuthenticatedClient();

  Future<List<LottoSpot>> getLottoSpots() async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoSpotPrefix}');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => LottoSpot.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load lotto spots');
    }
  }
}
