import 'package:doin_fx/core/utils/symbol_icon_resolver.dart';
import 'package:doin_fx/views/orders/datamodel/open_orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderRow extends StatelessWidget {
  final OpenOrder order;

  const OrderRow({
    super.key,
    required this.order,
  });

  /// Convenience constructor for BlocBuilder
  factory OrderRow.fromModel(OpenOrder order) {
    return OrderRow(order: order);
  }

  @override
  Widget build(BuildContext context) {
    final pnlValue = double.tryParse(order.pnl.toString()) ?? 0.0;
    final isProfit = pnlValue >= 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child:
        // Padding(
        //   padding: const EdgeInsets.all(4),
        //   child: SvgPicture.asset(
        //     'assets/images/pairs/XAUUSD.svg',
        //     /// 🔥 THIS PREVENTS CRASHES
        //     errorBuilder: (context, error, stackTrace) {
        //       return const Icon(
        //         Icons.currency_exchange,
        //         size: 18,
        //         color: Colors.grey,
        //       );
        //     },
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade200,
            child: Text(
              order.symbol.substring(0, 2),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),

      title: Text(
        order.symbol,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      subtitle: Text(
        '${order.type} ${double.parse(order.lotSize).toStringAsPrecision(1)}',
        style: TextStyle(fontSize: 13, color: order.type == 'BUY' ? Colors.green : Colors.red),
      ),

      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${isProfit ? '+' : '-'}\$${pnlValue.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: isProfit ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'CMP ',
                  style: const TextStyle(color: Colors.grey),
                ),
                const TextSpan(
                  text: '-> ',
                  style: TextStyle(color: Colors.grey, fontFamily: 'Roboto', fontSize: 18),

                ),
                TextSpan(
                  text: order.cmp.toString(),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
