import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String symbolToSvgAsset(String symbol) {
  final normalized = symbol
      .replaceAll('/', '') // just in case "EUR/USD"
      .toUpperCase();

  print(
    'normalized  : $normalized'
    '   assets/images/pairs/$normalized.svg',
  );

  return 'assets/images/pairs/$normalized.svg';
}

Widget buildSymbolIcon(String symbol, {double size = 24}) {
  final assetPath =
      'assets/images/pairs/${symbol.replaceAll("/", "").toUpperCase()}.png';

  // debugAsset(assetPath);

  return Image.asset(
    assetPath,
    width: size,
    height: size,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
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

Widget buildAllPairsIcons({required String asset, double size = 24}) {
  final assetPath = 'assets/images/AllPairsSymbols/$asset.png';

  // debugAsset(assetPath);

  return Image.asset(
    assetPath,
    width: size,
    height: size,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
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

Future<void> debugAsset(String assetPath) async {
  try {
    await rootBundle.load(assetPath);
    debugPrint('✅ Asset FOUND');
  } catch (e) {
    debugPrint('❌ Asset NOT FOUND: $e');
  }
}
