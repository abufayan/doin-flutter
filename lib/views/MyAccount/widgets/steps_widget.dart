import 'package:flutter/material.dart';

Widget StepsCard(List<String> steps, {VoidCallback? onClose, bool withDraw = false}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      // color: const Color(0xFFD6D6D6), // light grey background
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFFF9800), // orange border
        width: 1.5,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        Row(
          children: [
             Expanded(
              child: Text(
                'Steps to ${withDraw ? 'Withdraw' : 'Deposit'}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black),
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                ),
              ),
            ),
          ],
        ),

        const Divider(height: 24, thickness: 1),

        /// Steps
        ...List.generate(steps.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Number circle
                Container(
                  height: 24,
                  width: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF9800),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// Step text
                Expanded(
                  child: Text(
                    steps[index],
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}
