import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message, {required bool success}) {
  final messenger = ScaffoldMessenger.of(context);

  // 🔥 Clear previous snackbars
  messenger.clearSnackBars();


  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: Colors.white, fontSize: 16))),
        ],
      ),
      backgroundColor: success ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(16),
      duration: Duration(seconds: 3),
    ),
  );
}