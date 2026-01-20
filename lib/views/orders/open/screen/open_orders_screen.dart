import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/views/orders/widgets/account_summary.dart';
import 'package:doin_fx/views/orders/widgets/order_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doin_fx/views/orders/widgets/margin_warning_banner.dart';

import '../bloc/open_orders_bloc.dart';

class OpenTradeScreen extends StatefulWidget {
  const OpenTradeScreen({super.key});

  @override
  State<OpenTradeScreen> createState() => _OpenTradeScreenState();
}

class _OpenTradeScreenState extends State<OpenTradeScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OpenOrdersBloc()..add(LoadOpenOrders())..add(ConnectSocket()),
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                    child: _BalanceRow(),
                    onTap: () {
                      showModalBottomSheet(
                        context: innerContext, // ✅ CORRECT CONTEXT
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) {
                          return BlocProvider.value(
                            value: innerContext.read<OpenOrdersBloc>(),
                            child: const AccountSummarySheet(),
                          );
                        },
                      );
                    },
                ),
                const SizedBox(height: 12),
                _AccountLevel(),
                const SizedBox(height: 12),
                _TotalPnlCard(),
                const SizedBox(height: 8),
                BlocBuilder<OpenOrdersBloc, OpenOrdersState>(
                  builder: (context, state) {
                    if (state is! OpenOrdersLoaded) {
                      return const SizedBox.shrink();
                    }

                    return MarginWarningBanner(
                      marginLevel: state.marginLevel,
                    );
                  },
                ),
            Expanded(
              child: BlocBuilder<OpenOrdersBloc, OpenOrdersState>(
                builder: (context, state) {
                  if (state is OpenOrdersLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is OpenOrdersLoaded) {
                    if (state.orders.isEmpty) {
                      return const Center(
                        child: Text('No open orders'),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.orders.length,
                      itemBuilder: (context, i) {
                        return OrderRow(order: state.orders[i]);
                      },
                    );
                  }

                  if (state is OpenOrdersError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  // Initial / fallback
                  return const SizedBox.shrink();
                },
              ),
            ),
              ],
            ),
          );
        }
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            '\$ ${getIt<MyAccountService>().wallet}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.keyboard_arrow_down),
          const Spacer(),
        ],
      ),
    );
  }
}


class _TabItem extends StatelessWidget {
  final String label;
  final bool active;

  const _TabItem(this.label, {this.active = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.orange : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (active)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 2,
            width: 24,
            color: Colors.orange,
          ),
      ],
    );
  }
}

class _AccountLevel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account Level'),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.orange, Colors.red],
                  ),
                ),
              ),
              Positioned(
                left: 40,
                child: Container(
                  width: 10,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalPnlCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpenOrdersBloc, OpenOrdersState>(
      builder: (context, state) {
        double totalPnl = 0.0;

        if (state is OpenOrdersLoaded) {
          totalPnl = state.totalPnl;
        }

        final isProfit = totalPnl >= 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total PNL', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${isProfit ? '+' : '-'}\$${totalPnl.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isProfit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Close ▼',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

