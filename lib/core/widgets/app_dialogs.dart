import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:flutter/material.dart';

class AppDialogs {
  /// Shows a premium, elegant logout confirmation dialog.
  static void showLogoutDialog(BuildContext context, {required VoidCallback onLogout}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          content: Text('Are you sure ${getIt<MyAccountService>().user!.username}, you want to sign out?', style: const TextStyle(height: 1.4)),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onLogout();
              },
              // style: ElevatedButton.styleFrom(
              //   backgroundColor: Colors.white,
              //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              // ),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
