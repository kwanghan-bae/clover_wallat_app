import 'package:flutter/material.dart';
import 'package:clover_wallet_app/models/lotto_winnings.dart';
import 'package:clover_wallet_app/services/lotto_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  Future<LottoWinnings>? _winningsFuture;

  @override
  void initState() {
    super.initState();
    _loadSavedNumbers();
  }

  @override
  void dispose() {
    for (var controller in _numberControllers) {
      controller.dispose();
    }
    _roundController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? numbersString = prefs.getString('savedLottoNumbers');
    if (numbersString != null) {
      setState(() {
        _savedNumbers = (jsonDecode(numbersString) as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });
    }
  }

  Future<void> _saveNumbersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String numbersString = jsonEncode(_savedNumbers);
    await prefs.setString('savedLottoNumbers', numbersString);
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

      _saveNumbersToPrefs(); // Save to preferences

      for (var controller in _numberControllers) {
        controller.clear();
      }
      _roundController.clear();
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('번호가 저장되었습니다!')),
      );
    }
  }

  void _checkWinnings() {
    setState(() {
      _winningsFuture = LottoApiService().checkWinnings(userId: 1); // Hardcoded user ID for now
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildManualEntryForm(),
            const SizedBox(height: 20),
            _buildWinningsCheckSection(),
            const SizedBox(height: 20),
            const Text(
              '저장된 번호 목록',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            _buildSavedNumbersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntryForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '내 로또 번호 관리',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _roundController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '회차',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return '회차를 입력해주세요.';
              if (int.tryParse(value) == null || int.parse(value) <= 0) return '유효한 회차를 입력해주세요.';
              return null;
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(6, (index) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextFormField(
                  controller: _numberControllers[index],
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(counterText: '', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '필수';
                    int? number = int.tryParse(value);
                    if (number == null || number < 1 || number > 45) return '1-45';
                    final count = _numberControllers.where((c) => c.text == value).length;
                    if (count > 1) return '중복';
                    return null;
                  },
                ),
              ),
            )),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveNumbers,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('번호 저장', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildWinningsCheckSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _checkWinnings,
          child: const Text('당첨 확인'),
        ),
        const SizedBox(height: 10),
        if (_winningsFuture != null)
          FutureBuilder<LottoWinnings>(
            future: _winningsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('오류: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final winnings = snapshot.data!;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(winnings.message, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (winnings.winningNumbers != null)
                          Text('당첨 번호: ${winnings.winningNumbers!.join(', ')}'),
                        if (winnings.userWinningTickets != null)
                          ...winnings.userWinningTickets!.map((ticket) => ListTile(
                                title: Text('${ticket.round}회차 - ${ticket.rank}'),
                                subtitle: Text('내 번호: ${ticket.userNumbers.join(', ')}\n맞춘 번호: ${ticket.matchedNumbers.join(', ')}'),
                              )),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  Widget _buildSavedNumbersList() {
    return _savedNumbers.isEmpty
        ? const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('저장된 로또 번호가 없습니다.'),
          ))
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _savedNumbers.length,
            itemBuilder: (context, index) {
              final entry = _savedNumbers[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text('${entry['round']}회차'),
                  subtitle: Text(
                    entry['numbers'].join(', '),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
  }
}
