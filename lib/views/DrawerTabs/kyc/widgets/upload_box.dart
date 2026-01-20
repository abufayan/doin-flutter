import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

Widget uploadBox({
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.cloud_upload),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label\nChoose or drag and drop (maximum size 6 MB)',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    ),
  );
}
