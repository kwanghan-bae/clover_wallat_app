import 'package:flutter/material.dart';
import 'package:clover_wallet_app/utils/theme.dart';
import 'package:clover_wallet_app/services/number_extraction_service.dart';
import 'dart:math';

class NumberGenerationScreen extends StatefulWidget {
  const NumberGenerationScreen({super.key});

  @override
  State<NumberGenerationScreen> createState() => _NumberGenerationScreenState();
}

class _NumberGenerationScreenState extends State<NumberGenerationScreen> with SingleTickerProviderStateMixin {
  List<int> _generatedNumbers = [];
  String _selectedMethod = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateNumbers(String method) async {
    setState(() {
      _selectedMethod = method;
      _generatedNumbers = [];  // Clear while loading
    });

    try {
      // Try backend API first
      final service = NumberExtractionService();
      final numbers = await service.extractNumbers(method);
      setState(() {
        _generatedNumbers = numbers;
        _animationController.forward(from: 0);
      });
    } catch (e) {
      // Fallback to local generation
      final numbers = _generateByMethod(method);
      setState(() {
        _generatedNumbers = numbers;
        _animationController.forward(from: 0);
      });
    }
  }

  List<int> _generateByMethod(String method) {
    final random = Random();
    final Set<int> numbers = {};
    
    switch (method) {
      case 'AI':
        // AI 추천: 최근 당첨 번호 분석 (모의)
        while (numbers.length < 6) {
          numbers.add(random.nextInt(45) + 1);
        }
        break;
      case '통계':
        // 통계 분석: 가장 많이 나온 번호 중심 (모의)
        final frequently = [7, 11, 17, 23, 34, 43];
        numbers.addAll(frequently);
        break;
      case '운세':
        // 오늘의 운세: 생일 기반 (모의)
        final today = DateTime.now();
        final lucky = [(today.day % 45) + 1, (today.month * 3) % 45 + 1];
        numbers.addAll(lucky);
        while (numbers.length < 6) {
          numbers.add(random.nextInt(45) + 1);
        }
        break;
      case '랜덤':
      default:
        // 완전 랜덤
        while (numbers.length < 6) {
          numbers.add(random.nextInt(45) + 1);
        }
        break;
    }
    
    return numbers.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CloverTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('번호 추첨'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: CloverTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: CloverTheme.softShadow,
              ),
              child: Column(
                children: [
                  if (_selectedMethod.isNotEmpty) 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getMethodLabel(_selectedMethod),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _generatedNumbers.isEmpty
                      ? const Column(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white, size: 48),
                            SizedBox(height: 8),
                            Text(
                              '아래에서 생성 방식을 선택하세요!',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        )
                      : Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.center,
                          children: _generatedNumbers.map((n) {
                            return AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _animationController.value,
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _getNumberColor(n),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  n.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Generation Methods
            const Text('생성 방식 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildMethodCard(
                  icon: Icons.psychology_rounded,
                  title: 'AI 추천',
                  subtitle: '빅데이터 분석',
                  color: Colors.purple,
                  method: 'AI',
                ),
                _buildMethodCard(
                  icon: Icons.bar_chart_rounded,
                  title: '통계 분석',
                  subtitle: '고빈도 번호',
                  color: Colors.blue,
                  method: '통계',
                ),
                _buildMethodCard(
                  icon: Icons.stars_rounded,
                  title: '오늘의 운세',
                  subtitle: '생일 기반',
                  color: Colors.amber,
                  method: '운세',
                ),
                _buildMethodCard(
                  icon: Icons.shuffle_rounded,
                  title: '완전 랜덤',
                  subtitle: '행운을 믿어요',
                  color: Colors.green,
                  method: '랜덤',
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: CloverTheme.softShadow,
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: Colors.amber[700], size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '각 방식마다 다른 알고리즘으로 번호를 생성해요!',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String method,
  }) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: () => _generateNumbers(method),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: color, width: 2) : null,
          boxShadow: CloverTheme.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isSelected ? color : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _getMethodLabel(String method) {
    switch (method) {
      case 'AI': return '🤖 AI 추천';
      case '통계': return '📊 통계 분석';
      case '운세': return '✨ 오늘의 운세';
      case '랜덤': return '🎲 랜덤';
      default: return '';
    }
  }

  Color _getNumberColor(int number) {
    if (number <= 10) return const Color(0xFFFFA726); // Orange
    if (number <= 20) return const Color(0xFF42A5F5); // Blue
    if (number <= 30) return const Color(0xFFEF5350); // Red
    if (number <= 40) return const Color(0xFF9E9E9E); // Grey
    return const Color(0xFF66BB6A); // Green
  }
}
