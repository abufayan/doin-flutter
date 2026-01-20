import 'package:doin_fx/core/utils/tradingview_symbol_mapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TradingViewContainer extends StatefulWidget {
  final String symbol;
  const TradingViewContainer({super.key, required this.symbol});

  @override
  State<TradingViewContainer> createState() => _TradingViewContainerState();
}

class _TradingViewContainerState extends State<TradingViewContainer> {
  late final WebViewController _controller;
  late String _tvSymbol;

  @override
  void initState() {
    super.initState();
    _tvSymbol = TradingViewSymbolMapper.map(widget.symbol);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(false)
      ..loadHtmlString(_htmlForSymbol(_tvSymbol));
  }

  @override
  void didUpdateWidget(covariant TradingViewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.symbol != widget.symbol) {
      final newTvSymbol = TradingViewSymbolMapper.map(widget.symbol);

      if (newTvSymbol != _tvSymbol) {
        _tvSymbol = newTvSymbol;
        _controller.loadHtmlString(_htmlForSymbol(_tvSymbol));
      }
    }
  }

  String _htmlForSymbol(String symbol) {
    return """
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      height: 100%;
      overflow: hidden;
    }
  </style>
</head>
<body>
  <div class="tradingview-widget-container" style="height:100%;width:100%;">
    <div class="tradingview-widget-container__widget"></div>

    <script type="text/javascript"
      src="https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js"
      async>
    {
      "autosize": true,
      "symbol": "$symbol",
      "interval": "D",
      "timezone": "Etc/UTC",
      "theme": "light",
      "style": "1",
      "locale": "en",
      "hide_side_toolbar": false,
      "allow_symbol_change": false
    }
    </script>
  </div>
</body>
</html>
""";
  }

  @override
  Widget build(BuildContext context) {
    print('TradingView symbol loaded: $_tvSymbol');

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
