import 'package:flutter/material.dart';

class HotspotScreen extends StatelessWidget {
  const HotspotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로또 명당 찾기'),
      ),
      body: const Center(
        child: Text('지도 및 명당 리스트가 여기에 표시됩니다.'),
      ),
    );
  }
}
