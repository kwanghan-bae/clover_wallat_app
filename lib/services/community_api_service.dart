import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/models/post_model.dart';
import 'package:clover_wallet_app/models/common_response.dart';
import 'package:clover_wallet_app/utils/api_config.dart';

class CommunityApiService {
  Future<List<PostModel>> getPosts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.communityPrefix}/posts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      final commonResponse = CommonResponse<List<dynamic>>.fromJson(
        decodedBody,
        (json) => json as List<dynamic>,
      );

      if (commonResponse.isSuccess && commonResponse.data != null) {
        return commonResponse.data!
            .map((item) => PostModel.fromMap(item))
            .toList();
      } else {
        throw Exception(commonResponse.message ?? 'Failed to load posts');
      }
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  Future<PostModel> createPost(String title, String content) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.communityPrefix}/posts');
    // TODO: Add Authorization header with JWT
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        // 'userId': ... // handled by backend via JWT
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      final commonResponse = CommonResponse<Map<String, dynamic>>.fromJson(
        decodedBody,
        (json) => json as Map<String, dynamic>,
      );

      if (commonResponse.isSuccess && commonResponse.data != null) {
        return PostModel.fromMap(commonResponse.data!);
      } else {
        throw Exception(commonResponse.message ?? 'Failed to create post');
      }
    } else {
      throw Exception('Failed to create post: ${response.statusCode}');
    }
  }
}

