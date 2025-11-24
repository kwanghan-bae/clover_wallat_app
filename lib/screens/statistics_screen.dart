import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clover_wallet_app/viewmodels/statistics_viewmodel.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('번호 분석'),
      ),
      body: Consumer<StatisticsViewModel>(
        builder: (context, viewModel, child) {
          final mostFrequent = viewModel.mostFrequentNumbers;
          final leastFrequent = viewModel.leastFrequentNumbers;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionTitle('가장 많이 나온 번호 (내 기록)'),
              _buildNumberList(mostFrequent, Colors.red),
              const SizedBox(height: 24),
              _buildSectionTitle('가장 적게 나온 번호 (내 기록)'),
              _buildNumberList(leastFrequent, Colors.blue),
              const SizedBox(height: 24),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '더 많은 데이터가 쌓이면 정확한 분석이 가능합니다.\n꾸준히 기록해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNumberList(List<MapEntry<int, int>> numbers, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: numbers.map((entry) {
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entry.key.toString(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${entry.value}회'),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
