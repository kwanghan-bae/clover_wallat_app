import 'dart:convert';
import 'package:clover_wallet_app/models/post_model.dart';
import 'package:clover_wallet_app/models/common_response.dart';
import 'package:clover_wallet_app/utils/api_config.dart';
import 'package:clover_wallet_app/services/api_client.dart';

class CommunityApiService {
  final AuthenticatedClient _client = AuthenticatedClient();

  Future<List<PostModel>> getPosts({int page = 0, int size = 10}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.communityPrefix}/posts?page=$page&size=$size');
    
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      // Backend returns CommonResponse<Page<PostResponse>>
      // Structure: { success: true, data: { content: [...], pageable: ... }, message: ... }
      
      final commonResponse = decodedBody;
      if (commonResponse['success'] == true && commonResponse['data'] != null) {
        final data = commonResponse['data'];
        final content = data['content'] as List;
        return content.map((item) => PostModel.fromMap(item)).toList();
      } else {
        throw Exception(commonResponse['message'] ?? 'Failed to load posts');
      }
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  Future<PostModel> createPost(String content) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.communityPrefix}/posts');
    
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
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


  Future<PostModel> likePost(int postId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.communityPrefix}/posts/$postId/like');
    
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      final commonResponse = CommonResponse<Map<String, dynamic>>.fromJson(
        decodedBody,
        (json) => json as Map<String, dynamic>,
      );

      if (commonResponse.isSuccess && commonResponse.data != null) {
        return PostModel.fromMap(commonResponse.data!);
      } else {
        throw Exception(commonResponse.message ?? 'Failed to like post');
      }
    } else {
      throw Exception('Failed to like post: ${response.statusCode}');
    }
  }
}

