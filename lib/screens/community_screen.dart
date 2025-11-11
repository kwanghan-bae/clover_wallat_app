import 'package:flutter/material.dart';
import 'package:clover_wallet_app/models/post.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Dummy data for now
  final List<Post> _posts = [
    Post(
      title: '1등 당첨됐습니다!',
      author: '행운의 사나이',
      content: '오늘 아침에 확인해보니 1등에 당첨됐네요. 다들 좋은 기운 받아가세요!',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Post(
      title: '이번 주 추천 번호 공유합니다',
      author: '로또 분석가',
      content: '과거 데이터를 분석해본 결과, 이번 주에는 3, 12, 19, 21, 33, 45 번이 유력해 보입니다.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Post(
      title: '다들 어디서 로또 구매하시나요?',
      author: '초보 로또러',
      content: '유명한 명당이 따로 있나요? 아니면 그냥 집 근처에서 사시나요?',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(post.title),
              subtitle: Text('작성자: ${post.author}'),
              trailing: Text('${post.createdAt.month}/${post.createdAt.day}'),
              onTap: () {
                // TODO: Navigate to post detail screen
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to post writing screen
        },
        child: const Icon(Icons.edit),
        backgroundColor: Colors.green,
      ),
    );
  }
}
