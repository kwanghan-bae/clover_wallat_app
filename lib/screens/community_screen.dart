import 'package:clover_wallet_app/screens/create_post_screen.dart';
import 'package:clover_wallet_app/screens/post_detail_screen.dart';
import 'package:clover_wallet_app/viewmodels/community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch posts when the screen is first loaded
    // listen: false is important inside initState
    Future.microtask(() =>
        Provider.of<CommunityViewModel>(context, listen: false).fetchPosts());
  }

  void _navigateToCreatePostScreen() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );
    // The view model will handle fetching the new posts,
    // so we don't need to check the result here.
    // The list will update automatically if the createPost call in the view model
    // triggers a fetch and notifies listeners.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CommunityViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Text('오류가 발생했습니다: ${viewModel.errorMessage}'),
            );
          }

          if (viewModel.posts.isEmpty) {
            return const Center(child: Text('게시물이 없습니다.'));
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchPosts(),
            child: ListView.builder(
              itemCount: viewModel.posts.length,
              itemBuilder: (context, index) {
                final post = viewModel.posts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(post.title),
                    subtitle: Text('작성자 ID: ${post.userId}'),
                    trailing: Text(
                      post.createdAt != null
                          ? '${post.createdAt!.month}/${post.createdAt!.day}'
                          : '',
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(post: post),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePostScreen,
        child: const Icon(Icons.edit),
        backgroundColor: Colors.green,
      ),
    );
  }
}
