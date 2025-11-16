import 'package:clover_wallet_app/models/post.dart';
import 'package:clover_wallet_app/services/community_api_service.dart';
import 'package:clover_wallet_app/viewmodels/community_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'community_viewmodel_test.mocks.dart';

@GenerateMocks([CommunityApiService])
void main() {
  group('CommunityViewModel', () {
    late CommunityViewModel viewModel;
    late MockCommunityApiService mockApiService;

    setUp(() {
      mockApiService = MockCommunityApiService();
      viewModel = CommunityViewModel(apiService: mockApiService);
    });

    test('initial values are correct', () {
      expect(viewModel.posts, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    group('fetchPosts', () {
      test('sets isLoading to true then false on success', () async {
        when(mockApiService.getPosts()).thenAnswer((_) async => []);

        final future = viewModel.fetchPosts();
        expect(viewModel.isLoading, isTrue);
        await future;
        expect(viewModel.isLoading, isFalse);
      });

      test('populates posts on success', () async {
        final mockPosts = [
          const Post(id: 1, userId: 1, title: 'Title 1', content: 'Content 1'),
          const Post(id: 2, userId: 2, title: 'Title 2', content: 'Content 2'),
        ];
        when(mockApiService.getPosts()).thenAnswer((_) async => mockPosts);

        await viewModel.fetchPosts();
        expect(viewModel.posts, mockPosts);
        expect(viewModel.errorMessage, isNull);
      });

      test('sets errorMessage on failure', () async {
        when(mockApiService.getPosts()).thenThrow(Exception('Failed to load'));

        await viewModel.fetchPosts();
        expect(viewModel.posts, isEmpty);
        expect(viewModel.errorMessage, 'Exception: Failed to load');
      });
    });

    group('createPost', () {
      test('sets isLoading to true then false on success', () async {
        when(mockApiService.createPost(
          userId: anyNamed('userId'),
          title: anyNamed('title'),
          content: anyNamed('content'),
        )).thenAnswer((_) async => const Post(id: 1, userId: 1, title: 'New Post', content: 'New Content'));
        when(mockApiService.getPosts()).thenAnswer((_) async => []); // Mock subsequent fetch

        final future = viewModel.createPost(userId: 1, title: 'New Post', content: 'New Content');
        expect(viewModel.isLoading, isTrue);
        await future;
        expect(viewModel.isLoading, isFalse);
      });

      test('calls apiService.createPost and apiService.getPosts on success', () async {
        const newPost = Post(id: 1, userId: 1, title: 'New Post', content: 'New Content');
        when(mockApiService.createPost(
          userId: 1,
          title: 'New Post',
          content: 'New Content',
        )).thenAnswer((_) async => newPost);
        when(mockApiService.getPosts()).thenAnswer((_) async => [newPost]);

        final success = await viewModel.createPost(userId: 1, title: 'New Post', content: 'New Content');

        expect(success, isTrue);
        verify(mockApiService.createPost(userId: 1, title: 'New Post', content: 'New Content')).called(1);
        verify(mockApiService.getPosts()).called(1); // Called after successful creation
        expect(viewModel.posts, [newPost]);
        expect(viewModel.errorMessage, isNull);
      });

      test('sets errorMessage on failure', () async {
        when(mockApiService.createPost(
          userId: anyNamed('userId'),
          title: anyNamed('title'),
          content: anyNamed('content'),
        )).thenThrow(Exception('Failed to create'));

        final success = await viewModel.createPost(userId: 1, title: 'New Post', content: 'New Content');

        expect(success, isFalse);
        expect(viewModel.posts, isEmpty);
        expect(viewModel.errorMessage, 'Exception: Failed to create');
      });
    });
  });
}
