import 'dart:convert';

import 'package:clover_wallet_app/models/post.dart';
import 'package:clover_wallet_app/services/community_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'community_api_service_test.mocks.dart';

// Generate a MockClient using the Mockito package.
// Create new instances of this class in each test.
@GenerateMocks([http.Client])
void main() {
  group('CommunityApiService', () {
    late CommunityApiService apiService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      apiService = CommunityApiService(client: mockClient);
    });

    test('getPosts returns a list of Posts if the http call completes successfully', () async {
      final List<Map<String, dynamic>> mockResponse = [
        {
          'id': 1,
          'userId': 101,
          'title': 'Test Post 1',
          'content': 'This is the content of test post 1.',
          'createdAt': '2023-01-01T10:00:00',
          'updatedAt': '2023-01-01T10:00:00',
        },
        {
          'id': 2,
          'userId': 102,
          'title': 'Test Post 2',
          'content': 'This is the content of test post 2.',
          'createdAt': '2023-01-02T11:00:00',
          'updatedAt': '2023-01-02T11:00:00',
        },
      ];

      when(mockClient.get(Uri.parse('http://127.0.0.1:8080/v1/community/posts')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final posts = await apiService.getPosts();

      expect(posts, isA<List<Post>>());
      expect(posts.length, 2);
      expect(posts[0].id, 1);
      expect(posts[0].title, 'Test Post 1');
      expect(posts[1].userId, 102);
    });

    test('getPosts throws an exception if the http call completes with an error', () async {
      when(mockClient.get(Uri.parse('http://127.0.0.1:8080/v1/community/posts')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() => apiService.getPosts(), throwsException);
    });

    test('createPost returns a Post if the http call completes successfully', () async {
      final Map<String, dynamic> mockResponse = {
        'id': 3,
        'userId': 103,
        'title': 'New Post',
        'content': 'Content of new post.',
        'createdAt': '2023-01-03T12:00:00',
        'updatedAt': '2023-01-03T12:00:00',
      };

      when(mockClient.post(
        Uri.parse('http://127.0.0.1:8080/v1/community/posts'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 201));

      final post = await apiService.createPost(userId: 103, title: 'New Post', content: 'Content of new post.');

      expect(post, isA<Post>());
      expect(post.id, 3);
      expect(post.title, 'New Post');
    });

    test('createPost throws an exception if the http call completes with an error', () async {
      when(mockClient.post(
        Uri.parse('http://127.0.0.1:8080/v1/community/posts'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Bad Request', 400));

      expect(() => apiService.createPost(userId: 103, title: 'New Post', content: 'Content of new post.'), throwsException);
    });
  });
}
