import 'package:flutter/material.dart';

class MarginSummaryBar extends StatefulWidget {
  final double requiredMargin;
  final double freeMargin;
  final double currentPrice;
  final String currency;

  const MarginSummaryBar({
    super.key,
    required this.requiredMargin,
    required this.freeMargin,
    required this.currentPrice,
    this.currency = 'USD',
  });

  @override
  State<MarginSummaryBar> createState() => _MarginSummaryBarState();
}

class _MarginSummaryBarState extends State<MarginSummaryBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TOP BAR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.grey.shade300,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _topItem(
                'Required Margin',
                  '\$${widget.requiredMargin.toStringAsFixed(3)}'
                    // '${widget.currency}',
              ),
              _topItem(
                'Free Margin',
                '${widget.freeMargin.toStringAsFixed(3)} ${widget.currency}',
              ),
            ],
          ),
        ),

        // BOTTOM BAR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.grey.shade200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Price:', style: TextStyle(fontSize: 12)),
              Text(
                widget.currentPrice.toStringAsFixed(5),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _topItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}