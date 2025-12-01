import 'package:flutter/material.dart';
import 'package:clover_wallet_app/models/post_model.dart';
import 'package:clover_wallet_app/services/community_api_service.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityApiService _apiService;
  List<PostModel> _posts = [];
  bool _isLoading = false;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  CommunityViewModel({required CommunityApiService apiService})
      : _apiService = apiService {
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _apiService.getPosts();
    } catch (e) {
      // print('Error loading posts: $e');
      // Keep empty list or show error state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPost(String content) async {
    try {
      final newPost = await _apiService.createPost(content);
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      // print('Error creating post: $e');
      rethrow;
    }
  }
}
