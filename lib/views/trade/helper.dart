import 'package:flutter/material.dart';

void showMarketClosedPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true, // tap outside to close
    barrierColor: Colors.black.withOpacity(0.4), // dark overlay
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Market Closed!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// Optional message (you commented it in React)
              const Text(
                'The Forex market is currently closed.',
                    // '\nIt will reopen at 22:00 UTC on Sunday.',

                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 24),

              /// OK Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


bool isForexMarketOpen() {
  final now = DateTime.now().toUtc();

  final day = now.weekday;
  // Dart weekday:
  // 1 = Monday
  // 2 = Tuesday
  // ...
  // 6 = Saturday
  // 7 = Sunday

  final hour = now.hour;

  // Saturday → closed
  if (day == DateTime.saturday) return false;

  // Friday after 22:00 UTC → closed
  if (day == DateTime.friday && hour >= 22) return false;

  // Sunday before 22:00 UTC → closed
  if (day == DateTime.sunday && hour < 22) return false;

  return true;
}