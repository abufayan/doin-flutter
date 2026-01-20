
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

String symbolToSvgAsset(String symbol) {
  final normalized = symbol
      .replaceAll('/', '') // just in case "EUR/USD"
      .toUpperCase();

  print('normalized  : ${normalized}' + '   assets/images/pairs/$normalized.svg');

  return 'assets/images/pairs/$normalized.svg';
}


Widget buildSymbolIcon(
    String symbol, {
      double size = 24,
    }) {
  final assetPath =
      'assets/images/${symbol.replaceAll("/", "").toUpperCase()}.svg';

  return FutureBuilder(
    future: rootBundle.load(assetPath),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.hasData) {
        return SvgPicture.asset(
          assetPath,
          width: size,
          height: size,
        );
      }

      // fallback icon
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(
          Icons.currency_exchange,
          size: 14,
          color: Colors.grey,
        ),
      );
    },
  );
}

Future<void> debugAsset() async {
  try {
    await rootBundle.load('assets/images/pairs/XAUUSD.svg');
    debugPrint('✅ Asset FOUND');
  } catch (e) {
    debugPrint('❌ Asset NOT FOUND: $e');
  }
}