import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clover_wallet_app/services/auth_service.dart';
import 'package:clover_wallet_app/utils/api_config.dart';

class NotificationApiService {
  Future<List<NotificationModel>> getNotifications({int page = 0, int size = 20}) async {
    final userId = await AuthService().getUserId();
    if (userId == null) throw Exception('User not logged in');

    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) throw Exception('No auth token found');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications?userId=$userId&page=$page&size=$size');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      if (decodedBody['success'] == true) {
        final List<dynamic> data = decodedBody['data'];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception(decodedBody['message'] ?? 'Failed to load notifications');
      }
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final userId = await AuthService().getUserId();
    if (userId == null) return;

    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) return;

    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/$notificationId/read?userId=$userId');
    await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<int> getUnreadCount() async {
    final userId = await AuthService().getUserId();
    if (userId == null) return 0;

    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) return 0;

    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/unread-count?userId=$userId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      if (decodedBody['success'] == true) {
        return decodedBody['data'] as int;
      }
    }
    return 0;
  }
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final String type;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.type,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      isRead: json['isRead'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
