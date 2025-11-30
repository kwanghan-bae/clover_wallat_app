import 'package:flutter/material.dart';
import 'package:clover_wallet_app/utils/theme.dart';

class ExtractionParameterDialog {
  static Future<Map<String, dynamic>?> show(BuildContext context, String method) async {
    switch (method) {
      case 'DREAM':
        return _showDreamDialog(context);
      case 'SAJU':
        return _showSajuDialog(context);
      case 'HOROSCOPE':
        return _showHoroscopeDialog(context);
      case 'PERSONAL_SIGNIFICANCE':
        return _showPersonalDialog(context);
      case 'COLORS_SOUNDS':
        return _showColorDialog(context);
      case 'ANIMAL_OMENS':
        return _showAnimalDialog(context);
      default:
        return {}; // 나머지는 파라미터 없음
    }
  }

  // 꿈 해몽
  static Future<Map<String, dynamic>?> _showDreamDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🌙', style: TextStyle(fontSize: 32)),
            SizedBox(width: 12),
            Text('어떤 꿈을 꾸셨나요?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('꿈 속의 주요 단어를 입력해주세요', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '예: 뱀, 물, 돼지, 금',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {'keyword': controller.text}),
            child: const Text('번호 생성'),
          ),
        ],
      ),
    );
  }

  // 사주팔자
  static Future<Map<String, dynamic>?> _showSajuDialog(BuildContext context) async {
    DateTime? selectedDate;
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('📅', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Text('생년월일을 알려주세요'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('사주팔자를 분석하여 행운의 번호를 찾아드립니다', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CloverTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate != null
                          ? '${selectedDate!.year}년 ${selectedDate!.month}월 ${selectedDate!.day}일'
                          : '날짜를 선택하세요',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime(1990),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            ElevatedButton(
              onPressed: selectedDate != null
                  ? () => Navigator.pop(context, {'birthdate': selectedDate!.toIso8601String()})
                  : null,
              child: const Text('번호 생성'),
            ),
          ],
        ),
      ),
    );
  }

  // 별자리
  static Future<Map<String, dynamic>?> _showHoroscopeDialog(BuildContext context) async {
    return _showSajuDialog(context); // 생년월일 동일하게 사용
  }

  // 의미있는 숫자
  static Future<Map<String, dynamic>?> _showPersonalDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('💝', style: TextStyle(fontSize: 32)),
            SizedBox(width: 12),
            Text('특별한 숫자가 있나요?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('특별한 날짜나 좋아하는 숫자를 입력하세요', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '예: 20231225, 7, 13',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {'numbers': controller.text}),
            child: const Text('번호 생성'),
          ),
        ],
      ),
    );
  }

  // 색상 & 소리
  static Future<Map<String, dynamic>?> _showColorDialog(BuildContext context) async {
    final colors = [
      {'name': '빨강', 'color': Colors.red, 'value': 'RED'},
      {'name': '파랑', 'color': Colors.blue, 'value': 'BLUE'},
      {'name': '노랑', 'color': Colors.yellow[700]!, 'value': 'YELLOW'},
      {'name': '초록', 'color': Colors.green, 'value': 'GREEN'},
      {'name': '보라', 'color': Colors.purple, 'value': 'PURPLE'},
      {'name': '주황', 'color': Colors.orange, 'value': 'ORANGE'},
    ];

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🎨', style: TextStyle(fontSize: 32)),
            SizedBox(width: 12),
            Text('좋아하는 색상은?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('색상의 에너지로 행운의 번호를 찾아드립니다', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((c) {
                return InkWell(
                  onTap: () => Navigator.pop(context, {'color': c['value']}),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: c['color'] as Color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(c['name'] as String, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        ],
      ),
    );
  }

  // 동물 징조
  static Future<Map<String, dynamic>?> _showAnimalDialog(BuildContext context) async {
    final animals = [
      {'name': '용', 'emoji': '🐉', 'value': 'DRAGON'},
      {'name': '호랑이', 'emoji': '🐯', 'value': 'TIGER'},
      {'name': '토끼', 'emoji': '🐰', 'value': 'RABBIT'},
      {'name': '뱀', 'emoji': '🐍', 'value': 'SNAKE'},
      {'name': '말', 'emoji': '🐴', 'value': 'HORSE'},
      {'name': '원숭이', 'emoji': '🐵', 'value': 'MONKEY'},
    ];

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🐾', style: TextStyle(fontSize: 32)),
            SizedBox(width: 12),
            Text('어떤 동물을 좋아하시나요?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('동물의 기운으로 행운을 불러옵니다', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: animals.map((a) {
                return InkWell(
                  onTap: () => Navigator.pop(context, {'animal': a['value']}),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(a['emoji'] as String, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(a['name'] as String, style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        ],
      ),
    );
  }
}
