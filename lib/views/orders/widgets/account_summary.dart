import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:doin_fx/views/orders/open/bloc/open_orders_bloc.dart';

class AccountSummarySheet extends StatelessWidget {
  const AccountSummarySheet({super.key});

  Color _marginLevelColor(double level) {
    if (level <= 0) return Colors.grey;
    if (level < 100) return Colors.red;
    if (level < 200) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenOrdersBloc, OpenOrdersState>(
      builder: (context, state) {
        if (state is! OpenOrdersLoaded) {
          return const SizedBox.shrink();
        }

        final isProfit = state.totalPnl >= 0;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row(
                label: 'Account Type:',
                value: 'REAL',
                valueColor: Colors.green,
                bold: true,
              ),
              const SizedBox(height: 16),

              /// 🔥 TOTAL PNL (animated)
              Row(
                children: [
                  const Text(
                    'PNL',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TweenAnimationBuilder<double>(
                    key: ValueKey(state.totalPnl),
                    tween: Tween<double>(
                      begin: state.totalPnl,
                      end: state.totalPnl,
                    ),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, _) {
                      final isProfit = value >= 0;
                      return Text(
                        '${isProfit ? '+' : '-'}\$${value.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isProfit ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 6),

              _row(
                label: 'Balance',
                value: '\$${state.balance.toStringAsFixed(2)}',
                valueColor: Colors.blue,
              ),
              _row(
                label: 'Equity',
                value: '\$${state.equity.toStringAsFixed(2)}',
                valueColor: Colors.blue,
              ),
              _row(
                label: 'Used Margin',
                value: '\$${state.usedMargin.toStringAsFixed(2)}',
                valueColor: Colors.blue,
              ),
              _row(
                label: 'Free Margin',
                value: '\$${state.freeMargin.toStringAsFixed(2)}',
                valueColor: Colors.blue,
              ),
              _row(
                label: 'Margin Level',
                value: '${state.marginLevel.toStringAsFixed(2)}%',
                valueColor: _marginLevelColor(state.marginLevel),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row({
    required String label,
    required String value,
    Color valueColor = Colors.black,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
