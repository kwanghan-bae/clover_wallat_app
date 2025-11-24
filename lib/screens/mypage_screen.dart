import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: ListView(
        children: const [
          UserAccountsDrawerHeader(
            accountName: Text('사용자'),
            accountEmail: Text('user@example.com'),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('설정'),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('앱 정보'),
          ),
        ],
      ),
    );
  }
}
