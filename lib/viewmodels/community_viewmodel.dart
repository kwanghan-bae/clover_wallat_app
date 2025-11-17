import 'package:clover_wallet_app/models/comment.dart';
import 'package:clover_wallet_app/models/post.dart';
import 'package:clover_wallet_app/services/community_api_service.dart';
import 'package:flutter/material.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityApiService _apiService;

  CommunityViewModel({required CommunityApiService apiService}) : _apiService = apiService;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  List<Comment> _comments = [];
  List<Comment> get comments => _comments;

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

  Future<bool> updatePost({
    required int postId,
    required String title,
    required String content,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.updatePost(
        postId: postId,
        title: title,
        content: content,
      );
      await fetchPosts(); // Refresh the list after update
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost({required int postId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deletePost(postId: postId);
      await fetchPosts(); // Refresh the list after delete
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCommentsForPost({required int postId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await _apiService.getCommentsForPost(postId: postId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createComment({
    required int postId,
    required int userId,
    required String content,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.createComment(
        postId: postId,
        userId: userId,
        content: content,
      );
      await fetchCommentsForPost(postId: postId); // Refresh comments after creation
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateComment({
    required int commentId,
    required String content,
    required int postId, // Need postId to refresh comments
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.updateComment(
        commentId: commentId,
        content: content,
      );
      await fetchCommentsForPost(postId: postId); // Refresh comments after update
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteComment({
    required int commentId,
    required int postId, // Need postId to refresh comments
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteComment(commentId: commentId);
      await fetchCommentsForPost(postId: postId); // Refresh comments after deletion
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
