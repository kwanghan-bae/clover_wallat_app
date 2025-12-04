import 'package:flutter/material.dart';
import 'package:clover_wallet_app/models/post_model.dart';
import 'package:clover_wallet_app/services/community_api_service.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityApiService _apiService;
  List<PostModel> _posts = [];
  bool _isLoading = false;
  
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  CommunityViewModel({required CommunityApiService apiService})
      : _apiService = apiService {
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    if (_isLoading) return;
    _isLoading = true;
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final newPosts = await _apiService.getPosts(page: _currentPage, size: _pageSize);
      _posts = newPosts;
      if (newPosts.length < _pageSize) {
        _hasMore = false;
      }
    } catch (e) {
      print('Error loading posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMorePosts() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    
    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newPosts = await _apiService.getPosts(page: nextPage, size: _pageSize);
      
      if (newPosts.isNotEmpty) {
        _posts.addAll(newPosts);
        _currentPage = nextPage;
        if (newPosts.length < _pageSize) {
          _hasMore = false;
        }
      } else {
        _hasMore = false;
      }
    } catch (e) {
      print('Error loading more posts: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadPosts();
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

  Future<void> toggleLike(int postId) async {
    try {
      final updatedPost = await _apiService.likePost(postId);
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }
}
