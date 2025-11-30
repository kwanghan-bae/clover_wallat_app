import 'package:flutter/material.dart';
import 'package:clover_wallet_app/utils/theme.dart';

class ExtractionMethodSelectionDialog extends StatelessWidget {
  const ExtractionMethodSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '어떤 방식으로 번호를 선택하셨나요?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '당첨 시 해당 방식의 뱃지를 획득합니다!',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildMethodOption(context, '🌙', '꿈 해몽', 'DREAM'),
                _buildMethodOption(context, '📅', '사주팔자', 'SAJU'),
                _buildMethodOption(context, '🔥', '통계 HOT', 'STATISTICS_HOT'),
                _buildMethodOption(context, '❄️', '통계 COLD', 'STATISTICS_COLD'),
                _buildMethodOption(context, '⭐', '별자리', 'HOROSCOPE'),
                _buildMethodOption(context, '💝', '의미있는 숫자', 'PERSONAL_SIGNIFICANCE'),
                _buildMethodOption(context, '🌿', '자연의 패턴', 'NATURE_PATTERNS'),
                _buildMethodOption(context, '📜', '고대 점술', 'ANCIENT_DIVINATION'),
                _buildMethodOption(context, '🎨', '색상&소리', 'COLORS_SOUNDS'),
                _buildMethodOption(context, '🐾', '동물 징조', 'ANIMAL_OMENS'),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('모르겠어요 / 기억 안남'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(BuildContext context, String emoji, String label, String method) {
    return InkWell(
      onTap: () => Navigator.pop(context, method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
