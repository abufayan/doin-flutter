import 'package:flutter/material.dart';

class DoinFxLogo extends StatelessWidget {
  final double fontSize;

  const DoinFxLogo({super.key, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    // debugAsset('assets/images/doin/doin_fx_logo.png');
    return Image.asset(
      'assets/images/doin/doin_fx_logo.png',
      width: fontSize,
      height: fontSize,
    );
  }
}
