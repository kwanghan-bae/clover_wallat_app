import 'package:clover_wallet_app/models/comment.dart';
import 'package:clover_wallet_app/models/post.dart';
import 'package:clover_wallet_app/screens/edit_post_screen.dart';
import 'package:clover_wallet_app/viewmodels/community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<void> _commentsFuture;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentsFuture = _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    await Provider.of<CommunityViewModel>(context, listen: false)
        .fetchCommentsForPost(postId: widget.post.id);
  }

  Future<void> _deletePost(BuildContext context, CommunityViewModel viewModel) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시물 삭제'),
        content: const Text('정말로 이 게시물을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      final success = await viewModel.deletePost(postId: widget.post.id);
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 성공적으로 삭제되었습니다.')),
        );
        Navigator.of(context).pop(); // Pop back to CommunityScreen
      } else if (context.mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: ${viewModel.errorMessage}')),
        );
      }
    }
  }

  Future<void> _createComment(CommunityViewModel viewModel) async {
    if (_commentController.text.isEmpty) return;

    // For now, userId is hardcoded. This should be replaced with the actual logged-in user's ID.
    const userId = 1;
    final success = await viewModel.createComment(
      postId: widget.post.id,
      userId: userId,
      content: _commentController.text,
    );

    if (context.mounted && success) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글이 성공적으로 등록되었습니다.')),
      );
    } else if (context.mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: ${viewModel.errorMessage}')),
      );
    }
  }

  Future<void> _editComment(CommunityViewModel viewModel, Comment comment) async {
    _commentController.text = comment.content; // Pre-fill with existing content
    final bool? confirmEdit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 수정'),
        content: TextField(
          controller: _commentController,
          decoration: const InputDecoration(hintText: '댓글을 수정하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('수정'),
          ),
        ],
      ),
    );

    if (confirmEdit == true && _commentController.text.isNotEmpty) {
      final success = await viewModel.updateComment(
        commentId: comment.id,
        content: _commentController.text,
        postId: widget.post.id,
      );
      if (context.mounted && success) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 성공적으로 수정되었습니다.')),
        );
      } else if (context.mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: ${viewModel.errorMessage}')),
        );
      }
    }
    _commentController.clear(); // Clear after dialog closes
  }

  Future<void> _deleteComment(BuildContext context, CommunityViewModel viewModel, Comment comment) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('정말로 이 댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      final success = await viewModel.deleteComment(commentId: comment.id, postId: widget.post.id);
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 성공적으로 삭제되었습니다.')),
        );
      } else if (context.mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: ${viewModel.errorMessage}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditPostScreen(post: widget.post),
                ),
              );
            },
          ),
          Consumer<CommunityViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                icon: viewModel.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Icon(Icons.delete),
                onPressed: viewModel.isLoading ? null : () => _deletePost(context, viewModel),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '작성자 ID: ${widget.post.userId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  widget.post.createdAt != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(widget.post.createdAt!)
                      : '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.content,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '댓글',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Consumer<CommunityViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.isLoading && viewModel.comments.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (viewModel.errorMessage != null) {
                          return Center(child: Text('댓글 로드 오류: ${viewModel.errorMessage}'));
                        }
                        if (viewModel.comments.isEmpty) {
                          return const Text('아직 댓글이 없습니다.');
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: viewModel.comments.length,
                          itemBuilder: (context, index) {
                            final comment = viewModel.comments[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(comment.content),
                                subtitle: Text('작성자 ID: ${comment.userId} - ${DateFormat('yyyy-MM-dd HH:mm').format(comment.createdAt!)}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editComment(viewModel, comment),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteComment(context, viewModel, comment),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: '댓글을 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<CommunityViewModel>(
                    builder: (context, viewModel, child) {
                      return IconButton(
                        icon: viewModel.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(),
                              )
                            : const Icon(Icons.send),
                        onPressed: viewModel.isLoading ? null : () => _createComment(viewModel),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
