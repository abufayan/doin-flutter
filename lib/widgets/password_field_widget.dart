import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggle;

  const PasswordField(String s, {
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}