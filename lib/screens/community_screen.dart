import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clover_wallet_app/viewmodels/community_viewmodel.dart';
import 'package:clover_wallet_app/screens/create_post_screen.dart';
import 'package:clover_wallet_app/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clover_wallet_app/widgets/badge_widget.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<CommunityViewModel>().loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CloverTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('커뮤니티'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('검색 기능은 준비 중입니다.')),
              );
            },
          ),
        ],
      ),
      body: Consumer<CommunityViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('첫 게시물을 작성해보세요!', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.posts.length + (viewModel.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == viewModel.posts.length) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                final post = viewModel.posts[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: CloverTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: CloverTheme.primaryColor.withOpacity(0.1),
                              child: const Icon(Icons.person, color: CloverTheme.primaryColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        post.authorName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 6),
                                      BadgeWidget(badgeCodes: post.authorBadges),
                                    ],
                                  ),
                                  Text(
                                    DateFormat('MM/dd HH:mm').format(post.createdAt),
                                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.more_horiz_rounded, color: Colors.grey),
                          ],
                        ),
                      ),
                      
                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.content,
                              style: TextStyle(color: Colors.grey[800], height: 1.5),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Footer (Likes & Comments)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey[100]!)),
                        ),
                        child: Row(
                          children: [
                            _buildInteractionButton(
                              icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              count: '${post.likeCount}',
                              color: post.isLiked ? Colors.red : null,
                              onTap: () {
                                context.read<CommunityViewModel>().toggleLike(post.id);
                              },
                            ),
                            const SizedBox(width: 16),
                            _buildInteractionButton(
                              icon: Icons.visibility_outlined,
                              count: '${post.viewCount}',
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Share.share('${post.authorName}님의 게시물: ${post.content}');
                              },
                              child: const Icon(Icons.share_rounded, color: Colors.grey, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: CloverTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String count,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[600]),
          const SizedBox(width: 4),
          Text(count, style: TextStyle(color: color ?? Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }
}
