import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:clover_wallet_app/utils/api_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NumberExtractionService {
  Future<List<int>> extractNumbers(String method, {Map<String, dynamic>? parameters}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/extraction');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;

    // 요청 바디 구성
    final requestBody = <String, dynamic>{
      'strategy': method,
    };

    // 파라미터 추가
    if (parameters != null) {
      if (parameters.containsKey('keyword')) requestBody['dreamKeyword'] = parameters['keyword'];
      if (parameters.containsKey('birthdate')) requestBody['birthDate'] = parameters['birthdate'];
      if (parameters.containsKey('numbers')) requestBody['personalKeywords'] = [parameters['numbers']];
      if (parameters.containsKey('color')) requestBody['colorKeyword'] = parameters['color'];
      if (parameters.containsKey('animal')) requestBody['animalKeyword'] = parameters['animal'];
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final numbers = (data['numbers'] as List).cast<int>();
      return numbers;
    } else {
      throw Exception('Failed to extract numbers');
    }
  }
}
