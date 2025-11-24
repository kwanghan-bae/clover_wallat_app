import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clover_wallet_app/models/history_model.dart';
import 'package:clover_wallet_app/viewmodels/history_viewmodel.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 로또 내역'),
      ),
      body: Consumer<HistoryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.history.isEmpty) {
            return const Center(
              child: Text('저장된 로또 내역이 없습니다.'),
            );
          }
          return ListView.builder(
            itemCount: viewModel.history.length,
            itemBuilder: (context, index) {
              final item = viewModel.history[index];
              return Dismissible(
                key: Key(item.date.toString()),
                onDismissed: (direction) {
                  viewModel.deleteEntry(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('내역이 삭제되었습니다.')),
                  );
                },
                background: Container(color: Colors.red),
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.receipt),
                    title: Text('${item.round}회차'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('yyyy-MM-dd HH:mm').format(item.date)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: item.numbers
                              .map((n) => Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: _getNumberColor(n),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      n.toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getNumberColor(int number) {
    if (number <= 10) return Colors.yellow[700]!;
    if (number <= 20) return Colors.blue;
    if (number <= 30) return Colors.red;
    if (number <= 40) return Colors.grey;
    return Colors.green;
  }

  void _showAddEntryDialog(BuildContext context) {
    final roundController = TextEditingController();
    final numbersController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('로또 내역 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roundController,
                decoration: const InputDecoration(labelText: '회차'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: numbersController,
                decoration: const InputDecoration(
                    labelText: '번호 (쉼표로 구분, 예: 1,2,3,4,5,6)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final round = int.tryParse(roundController.text) ?? 0;
                final numbers = numbersController.text
                    .split(',')
                    .map((e) => int.tryParse(e.trim()) ?? 0)
                    .where((e) => e > 0 && e <= 45)
                    .toList();

                if (numbers.length == 6) {
                  context.read<HistoryViewModel>().addEntry(
                        HistoryModel(
                          round: round,
                          numbers: numbers,
                          date: DateTime.now(),
                        ),
                      );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('올바른 번호 6개를 입력해주세요.')),
                  );
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }
}
