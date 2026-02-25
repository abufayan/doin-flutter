import 'package:flutter/material.dart';

class DoinFxLogo extends StatelessWidget {
  final double fontSize;

  const DoinFxLogo({super.key, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    // debugAsset('assets/images/doin/doin_fx_logo.png');

    return Text(
      'Doin FX',
      style: TextStyle(color: Color(0xFFFF9800), fontWeight: FontWeight.w600),
    );

    // return Image.asset(
    //   'assets/images/doin/doin_fx_logo.png',
    //   width: fontSize,
    //   height: fontSize,
    // );
  }
}
