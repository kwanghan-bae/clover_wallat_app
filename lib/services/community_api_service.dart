import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clover_wallet_app/models/post_model.dart';
import 'package:clover_wallet_app/utils/api_config.dart';

class CommunityApiService {
  Future<List<PostModel>> getPosts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.communityPrefix}/posts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => PostModel.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<PostModel> createPost(String title, String content, String author) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.communityPrefix}/posts');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'author': author,
      }),
    );

    if (response.statusCode == 201) {
      return PostModel.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create post');
    }
  }
}
