import 'package:flutter/material.dart';

void showSnackbar(
    BuildContext context,
    String message, {
      required bool success,
    }) {


  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();

  // ✅ Dismiss keyboard first
  // FocusManager.instance.primaryFocus?.unfocus();


  final Color bgColor = success
      ?  Colors.green
      :  Colors.red; // toned-down premium error red

  final IconData icon =
  success ? Icons.check_circle_rounded : Icons.error_rounded;

  messenger.showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 3),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}