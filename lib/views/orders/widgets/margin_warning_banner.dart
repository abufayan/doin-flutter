import 'package:flutter/material.dart';

class MarginWarningBanner extends StatelessWidget {
  final double marginLevel;

  const MarginWarningBanner({
    super.key,
    required this.marginLevel,
  });

  @override
  Widget build(BuildContext context) {
    if (marginLevel <= 0 || marginLevel > 200) {
      return const SizedBox.shrink();
    }

    final isDanger = marginLevel < 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDanger ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDanger ? Colors.red : Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: isDanger ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isDanger
                  ? 'Margin call risk! Please add funds or close positions.'
                  : 'Margin level is getting low. Monitor your positions.',
              style: TextStyle(
                color: isDanger ? Colors.red : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
