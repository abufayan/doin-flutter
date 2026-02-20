import 'package:flutter/material.dart';

class DoinDesign extends StatelessWidget {
  const DoinDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return                   Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFFF9800),
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/icons/d.png'),
        ),
        const SizedBox(width: 4),
        const Text(
          'Doin Fx',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }
}
