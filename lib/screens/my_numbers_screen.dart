import 'package:flutter/material.dart';

class MyNumbersScreen extends StatefulWidget {
  const MyNumbersScreen({super.key});

  @override
  State<MyNumbersScreen> createState() => _MyNumbersScreenState();
}

class _MyNumbersScreenState extends State<MyNumbersScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _numberControllers =
      List.generate(6, (_) => TextEditingController());
  final TextEditingController _roundController = TextEditingController();

  List<Map<String, dynamic>> _savedNumbers = [];

  @override
  void dispose() {
    for (var controller in _numberControllers) {
      controller.dispose();
    }
    _roundController.dispose();
    super.dispose();
  }

  void _saveNumbers() {
    if (_formKey.currentState!.validate()) {
      List<int> numbers = _numberControllers
          .map((controller) => int.parse(controller.text))
          .toList();
      int round = int.parse(_roundController.text);

      setState(() {
        _savedNumbers.add({
          'round': round,
          'numbers': numbers..sort(),
        });
      });

      // Clear input fields
      for (var controller in _numberControllers) {
        controller.clear();
      }
      _roundController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('번호가 저장되었습니다!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '내 로또 번호 관리',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _roundController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '회차',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '회차를 입력해주세요.';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return '유효한 회차를 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                      (index) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: TextFormField(
                            controller: _numberControllers[index],
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '필수';
                              }
                              int? number = int.tryParse(value);
                              if (number == null || number < 1 || number > 45) {
                                return '1-45';
                              }
                              // Check for uniqueness among entered numbers
                              List<int> currentNumbers = [];
                              for (int i = 0; i < 6; i++) {
                                if (_numberControllers[i].text.isNotEmpty) {
                                  currentNumbers.add(int.parse(_numberControllers[i].text));
                                }
                              }
                              if (currentNumbers.where((n) => n == number).length > 1) {
                                return '중복';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveNumbers,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      '번호 저장',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _savedNumbers.isEmpty
                  ? const Center(child: Text('저장된 로또 번호가 없습니다.'))
                  : ListView.builder(
                      itemCount: _savedNumbers.length,
                      itemBuilder: (context, index) {
                        final entry = _savedNumbers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text('${entry['round']}회차'),
                            subtitle: Text(
                              entry['numbers'].join(', '),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
