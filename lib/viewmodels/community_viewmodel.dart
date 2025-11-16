import 'package:clover_wallet_app/models/post.dart';
import 'package:clover_wallet_app/services/community_api_service.dart';
import 'package:flutter/material.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityApiService _apiService;

  CommunityViewModel({required CommunityApiService apiService}) : _apiService = apiService;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _apiService.getPosts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required int userId,
    required String title,
    required String content,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.createPost(
        userId: userId,
        title: title,
        content: content,
      );
      // After creating, fetch the updated list of posts
      await fetchPosts();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
