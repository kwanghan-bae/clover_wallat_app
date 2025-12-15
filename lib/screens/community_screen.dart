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
        title: const Text(
          '커뮤니티',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.black87),
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
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            color: CloverTheme.primaryColor,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: viewModel.posts.length + (viewModel.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                if (index == viewModel.posts.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final post = viewModel.posts[index];
                return _buildPostCard(context, post, viewModel);
              },
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: CloverTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: CloverTheme.primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          child: const Icon(Icons.edit_rounded),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CloverTheme.primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 60, color: CloverTheme.primaryColor.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          const Text(
            '아직 게시물이 없습니다',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 게시물의 주인공이 되어보세요!',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('게시물 작성하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CloverTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
              shadowColor: CloverTheme.primaryColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, dynamic post, CommunityViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 상세 페이지 이동 (추후 구현)
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: CloverTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        post.authorName.isNotEmpty ? post.authorName[0] : '?',
                        style: const TextStyle(
                          color: CloverTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  post.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (post.authorBadges != null && post.authorBadges.isNotEmpty)
                                BadgeWidget(badgeCodes: post.authorBadges),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MM/dd HH:mm').format(post.createdAt),
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.more_horiz_rounded, color: Colors.grey[300]),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Content
                Text(
                  post.content,
                  style: const TextStyle(
                    color: Colors.black87,
                    height: 1.5,
                    fontSize: 15,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Divider
                Divider(height: 1, color: Colors.grey[100]),
                
                const SizedBox(height: 12),
                
                // Footer (Actions)
                Row(
                  children: [
                    _buildActionButton(
                      icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      label: '${post.likeCount}',
                      color: post.isLiked ? Colors.redAccent : Colors.grey[500],
                      onTap: () => viewModel.toggleLike(post.id),
                    ),
                    const SizedBox(width: 20),
                    _buildActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: '${post.commentCount ?? 0}', // Assuming commentCount exists or default 0
                      color: Colors.grey[500],
                    ),
                     const SizedBox(width: 20),
                    _buildActionButton(
                      icon: Icons.visibility_outlined,
                      label: '${post.viewCount}',
                       color: Colors.grey[400],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, size: 20),
                      color: Colors.grey[400],
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                         Share.share('${post.authorName}님의 게시물: ${post.content}');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
