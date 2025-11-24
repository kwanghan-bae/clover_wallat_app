import 'package:flutter/material.dart';
import 'dart:math';

class NumberGenerationScreen extends StatefulWidget {
  const NumberGenerationScreen({super.key});

  @override
  State<NumberGenerationScreen> createState() => _NumberGenerationScreenState();
}

class _NumberGenerationScreenState extends State<NumberGenerationScreen> {
  List<int> _generatedNumbers = [];

  void _generateNumbers() {
    final random = Random();
    final Set<int> numbers = {};
    while (numbers.length < 6) {
      numbers.add(random.nextInt(45) + 1);
    }
    setState(() {
      _generatedNumbers = numbers.toList()..sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로또 번호 추첨'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_generatedNumbers.isNotEmpty)
              Wrap(
                spacing: 8.0,
                children: _generatedNumbers
                    .map((n) => Chip(
                          label: Text(
                            n.toString(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: _getNumberColor(n),
                          labelStyle: const TextStyle(color: Colors.white),
                        ))
                    .toList(),
              )
            else
              const Text('버튼을 눌러 번호를 생성하세요!'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _generateNumbers,
              child: const Text('번호 생성하기'),
            ),
          ],
        ),
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
}
