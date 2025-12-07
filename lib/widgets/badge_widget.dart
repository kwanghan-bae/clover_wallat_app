import 'package:flutter/material.dart';
import 'package:clover_wallet_app/models/badge_model.dart';

class BadgeWidget extends StatelessWidget {
  final List<String> badgeCodes;
  final int maxDisplay;

  const BadgeWidget({
    super.key,
    required this.badgeCodes,
    this.maxDisplay = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (badgeCodes.isEmpty) {
      return const SizedBox.shrink();
    }

    final badges = BadgeModel.fromCodes(badgeCodes);
    final displayBadges = badges.take(maxDisplay).toList();
    final remainingCount = badges.length - displayBadges.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayBadges.map((badge) => Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Tooltip(
                message: '${badge.displayName}\n${badge.description}',
                child: Text(
                  badge.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )),
        if (remainingCount > 0)
          Text(
            '+$remainingCount',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
