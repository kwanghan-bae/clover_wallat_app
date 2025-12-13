import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/utils/api_config.dart';
import 'package:clover_wallet_app/models/travel_plan_model.dart';

class TravelApiService {
  String get baseUrl => '${ApiConfig.baseUrl}${ApiConfig.travelPlansPrefix}';

  Future<List<TravelPlanModel>> getAllTravelPlans() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((plan) => TravelPlanModel.fromMap(plan)).toList();
      } else {
        throw Exception('Failed to load travel plans');
      }
    } catch (e) {
      print('Error fetching travel plans: $e');
      return [];
    }
  }

  Future<TravelPlanModel?> getTravelPlanById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return TravelPlanModel.fromMap(responseData['data']);
        }
        return null;
      } else {
        throw Exception('Failed to load travel plan');
      }
    } catch (e) {
      print('Error fetching travel plan: $e');
      return null;
    }
  }

  Future<List<TravelPlanModel>> getTravelPlansByTheme(String theme) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/theme/$theme'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((plan) => TravelPlanModel.fromMap(plan)).toList();
      } else {
        throw Exception('Failed to load travel plans by theme');
      }
    } catch (e) {
      print('Error fetching travel plans by theme: $e');
      return [];
    }
  }
}
