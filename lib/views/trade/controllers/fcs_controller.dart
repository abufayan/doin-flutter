import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FcsChartContainer extends StatefulWidget {
  final String symbol; // e.g. XAUUSD, EURUSD

  const FcsChartContainer({super.key, required this.symbol});

  @override
  State<FcsChartContainer> createState() => _FcsChartContainerState();
}

class _FcsChartContainerState extends State<FcsChartContainer> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(false)
      ..loadHtmlString(_html(widget.symbol), baseUrl: 'https://localhost');
  }

  @override
  void didUpdateWidget(covariant FcsChartContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.symbol != widget.symbol) {
      _controller.loadHtmlString(
        _html(widget.symbol),
        baseUrl: 'https://localhost',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: WebViewWidget(
        key: ValueKey(widget.symbol), // forces rebuild per symbol
        controller: _controller,
      ),
    );
  }

  // 🔴 NOTHING BELOW THIS LINE WAS MODIFIED 🔴
  String _html(String symbol) {
    return """
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport"
        content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style> 
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      height: 100%;
      background: #ffffff;
      overflow: hidden;
    }
    #parent {
      width: 100vw;
      height: 100vh;
    }
  </style>

  <link rel="stylesheet"
    href="https://cdn.jsdelivr.net/gh/fcsapi/chart-js@latest/src/fcsapi-chart.css">
</head>

<body>
  <div id="parent">
    <div id="chart"></div>
  </div>

  <script src="https://cdn.jsdelivr.net/gh/fcsapi/chart-js@latest/src/fcsapi-chart.js"></script>

  <script>
    function resize() {
      document.getElementById('parent').style.height =
        window.innerHeight + 'px';
    }
    resize();
    window.addEventListener('resize', resize);

    const chart = new FCSAPIChart({
      container: document.getElementById('chart'),
      parentid: 'parent',

      accessKey: 'tazGE0Won8sXYWaQzcVCjaN0drdON',
      socketApiKey: 'ZxeXcXmXlHpoSn61NUhh5HBtuWTvz6P',

      symbol: 'ONA:$symbol',
      period: '1m',
      length: 500,

      displayMode: 'normal',
      theme: 'light',
      defaultChartType: 'candlestick',

      enableSidebar: true,
      enableToolbar: true,
      enableRangeSelector: true,

      enableSocket: true,
      enableCrosshair: true,
      enableGrid: true,
      
      enablePriceLine: true,
      enableAskBidLines: false,
      enableAskPriceLabels: false,
      enableBidPriceLabels: false,
      enableHighLowLabels: false,

      enableSearch: false,
      enableSettings: false,

      timezone: 'UTC',
    });
  </script>
</body>
</html>
""";
  }
}
