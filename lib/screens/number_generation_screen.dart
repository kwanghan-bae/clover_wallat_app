import 'package:flutter/material.dart';
import 'package:clover_wallet_app/utils/theme.dart';
import 'package:clover_wallet_app/services/number_extraction_service.dart';
import 'package:clover_wallet_app/widgets/extraction_parameter_dialog.dart';
import 'package:provider/provider.dart';
import 'package:clover_wallet_app/services/lotto_api_service.dart';
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
    // 사용자 입력 필요한 경우 파라미터 다이얼로그 표시
    Map<String, dynamic>? parameters;
    if (['DREAM', 'SAJU', 'HOROSCOPE', 'PERSONAL_SIGNIFICANCE', 'COLORS_SOUNDS', 'ANIMAL_OMENS'].contains(method)) {
      parameters = await ExtractionParameterDialog.show(context, method);
      if (parameters == null) return; // 취소한 경우
    }

    setState(() {
      _selectedMethod = method;
      _generatedNumbers = [];
    });

    try {
      final service = NumberExtractionService();
      final numbers = await service.extractNumbers(method, parameters: parameters);
      setState(() {
        _generatedNumbers = numbers;
        _animationController.forward(from: 0);
      });
    } catch (e) {
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
    
    while (numbers.length < 6) {
      numbers.add(random.nextInt(45) + 1);
    }
    
    return numbers.toList()..sort();
  }

  Future<void> _saveNumbers() async {
    if (_generatedNumbers.isEmpty) return;

    try {
      await context.read<LottoApiService>().saveGame(_generatedNumbers);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('번호가 저장되었습니다! 내 로또 탭에서 확인하세요.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CloverTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('행운의 번호 추첨'),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getMethodLabel(_selectedMethod),
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _generatedNumbers.isEmpty
                      ? const Column(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 56),
                            SizedBox(height: 12),
                            Text(
                              '아래에서 생성 방식을 선택하세요!',
                              style: TextStyle(color: Colors.white70, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
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
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _getNumberColor(n),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  n.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  if (_generatedNumbers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saveNumbers,
                      icon: const Icon(Icons.save_alt_rounded),
                      label: const Text('번호 저장하기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: CloverTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Generation Methods
            const Text('추첨 방식 선택', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('다양한 방법으로 행운의 번호를 찾아보세요!', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            
            ...[ 
              _buildMethodCard(
                icon: Icons.bedtime_rounded,
                title: '꿈 해몽',
                subtitle: '밤에 꾼 꿈을 분석해요',
                color: const Color(0xFF7E57C2),
                method: 'DREAM',
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                icon: Icons.calendar_month_rounded,
                title: '사주팔자',
                subtitle: '생년월일로 행운의 숫자를',
                color: const Color(0xFFD84315),
                method: 'SAJU',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMethodCard(
                      icon: Icons.trending_up_rounded,
                      title: '통계 (HOT)',
                      subtitle: '자주 나온 번호',
                      color: const Color(0xFFEF5350),
                      method: 'STATISTICS_HOT',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMethodCard(
                      icon: Icons.trending_down_rounded,
                      title: '통계 (COLD)',
                      subtitle: '안 나온 번호',
                      color: const Color(0xFF42A5F5),
                      method: 'STATISTICS_COLD',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                icon: Icons.star_rounded,
                title: '별자리 운세',
                subtitle: '오늘의 별자리 행운',
                color: const Color(0xFFFFA726),
                method: 'HOROSCOPE',
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                icon: Icons.favorite_rounded,
                title: '의미있는 숫자',
                subtitle: '기념일, 생일 등 특별한 날',
                color: const Color(0xFFEC407A),
                method: 'PERSONAL_SIGNIFICANCE',
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                icon: Icons.eco_rounded,
                title: '자연의 패턴',
                subtitle: '피보나치, 계절의 리듬',
                color: const Color(0xFF66BB6A),
                method: 'NATURE_PATTERNS',
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                icon: Icons.auto_stories_rounded,
                title: '고대 점술',
                subtitle: '주역, 룬 등의 신비',
                color: const Color(0xFF8D6E63),
                method: 'ANCIENT_DIVINATION',
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                icon: Icons.palette_rounded,
                title: '색상 & 소리',
                subtitle: '색상 심리와 음악 주파수',
                color: const Color(0xFF26C6DA),
                method: 'COLORS_SOUNDS',
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                icon: Icons.pets_rounded,
                title: '동물 징조',
                subtitle: '동물의 신비로운 힘',
                color: const Color(0xFFAB47BC),
                method: 'ANIMAL_OMENS',
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: Colors.amber[800], size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '각 방식마다 고유한 알고리즘으로 번호를 생성합니다. 마음에 드는 방법을 선택해보세요!',
                      style: TextStyle(color: Colors.brown, fontSize: 13, height: 1.4),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: color, width: 2.5) : null,
          boxShadow: isSelected 
            ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
            : CloverTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  String _getMethodLabel(String method) {
    final labels = {
      'DREAM': '🌙 꿈 해몽',
      'SAJU': '📅 사주팔자',
      'STATISTICS_HOT': '🔥 통계 HOT',
      'STATISTICS_COLD': '❄️ 통계 COLD',
      'HOROSCOPE': '⭐ 별자리 운세',
      'PERSONAL_SIGNIFICANCE': '💝 의미있는 숫자',
      'NATURE_PATTERNS': '🌿 자연의 패턴',
      'ANCIENT_DIVINATION': '📜 고대 점술',
      'COLORS_SOUNDS': '🎨 색상 & 소리',
      'ANIMAL_OMENS': '🐾 동물 징조',
    };
    return labels[method] ?? '';
  }

  Color _getNumberColor(int number) {
    if (number <= 10) return const Color(0xFFFFA726);
    if (number <= 20) return const Color(0xFF42A5F5);
    if (number <= 30) return const Color(0xFFEF5350);
    if (number <= 40) return const Color(0xFF9E9E9E);
    return const Color(0xFF66BB6A);
  }
}
