import 'package:flutter/material.dart';

Widget NoteCard(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8D7DA), // light brown/grey background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Left label + divider
          Row(
            children: [
              const Text(
                'Note:',
                style: TextStyle(
                  color: Color(0xFFB00000),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFB00000),
              ),
            ],
          ),

          const SizedBox(width: 12),

          /// Note text
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFB00000),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
