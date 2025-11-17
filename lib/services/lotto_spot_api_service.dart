import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/models/lotto_spot.dart';

class LottoSpotApiService {
  // TODO: Replace with actual backend URL
  final String _baseUrl = 'http://localhost:8080/v1/lotto-spots';

  Future<List<LottoSpot>> getAllLottoSpots() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => LottoSpot.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load lotto spots');
    }
  }

  Future<List<LottoSpot>> getLottoSpotsNearLocation(
      double latitude, double longitude, double radiusKm) async {
    final uri = Uri.parse('$_baseUrl/near-location').replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radiusKm': radiusKm.toString(),
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => LottoSpot.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load lotto spots near location');
    }
  }
}
