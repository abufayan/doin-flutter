import 'package:flutter/material.dart';

class DoinFxLogo extends StatelessWidget {
  final double fontSize;

  const DoinFxLogo({
    super.key,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
          'Doin FX',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        );
  }
}
