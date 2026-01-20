import 'package:flutter/material.dart';

/// STEP BUTTON
class StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 36,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}