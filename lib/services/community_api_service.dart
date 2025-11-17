import 'dart:convert';
import 'package:clover_wallet_app/models/post.dart';
import 'package:http/http.dart' as http;

class CommunityApiService {
  final String _baseUrl = 'http://127.0.0.1:8080';
  final http.Client _client;

  CommunityApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Post>> getPosts() async {
    final response = await _client.get(Uri.parse('$_baseUrl/v1/community/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonData.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<Post> createPost({
    required int userId,
    required String title,
    required String content,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/v1/community/posts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 201) { // Created
      return Post.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create post.');
    }
  }

  Future<Post> updatePost({
    required int postId,
    required String title,
    required String content,
  }) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/v1/community/posts/$postId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 200) { // OK
      return Post.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update post.');
    }
  }

  Future<void> deletePost({required int postId}) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/v1/community/posts/$postId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 204) { // No Content
      throw Exception('Failed to delete post.');
    }
  }
}
