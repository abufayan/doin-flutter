import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/core/utils/nav_utils.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/utils/symbol_icon_resolver.dart';
import 'package:doin_fx/views/orders/datamodel/trade_order.dart';
import 'package:doin_fx/views/orders/pending/list/bloc/pending_order_bloc.dart';
import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PendingOrdersScreen extends StatefulWidget {
  const PendingOrdersScreen({super.key});

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    context.read<PendingOrderBloc>().add(LoadPendingOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: BlocBuilder<PendingOrderBloc, PendingOrderState>(
              builder: (context, state) {
                if (state is Loading) {
                  return AppLoaders.listShimmer();
                }

                if (state is PendingOrdersLoaded) {
                  if (state.orders.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<PendingOrderBloc>().add(LoadPendingOrders());
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 200),
                          Center(child: Text('No Pending orders')),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PendingOrderBloc>().add(LoadPendingOrders());
                    },
                    child: ListView.builder(
                      itemCount: state.orders.length,
                      itemBuilder: (context, i) {
                        return PendingOrderRow(order: state.orders[i]);
                      },
                    ),
                  );
                }

                if (state is Error) {
                  return Center(
                    child: Text(state.message, style: const TextStyle(color: Colors.red)),
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

// class _TabItem extends StatelessWidget {
//   final String label;
//   final bool active;
//
//   const _TabItem(this.label);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: active ? Colors.orange : Colors.black,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         if (active)
//           Container(
//             margin: const EdgeInsets.only(top: 4),
//             height: 2,
//             width: 24,
//             color: Colors.orange,
//           ),
//       ],
//     );
//   }
// }

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
                  gradient: const LinearGradient(colors: [Colors.green, Colors.orange, Colors.red]),
                ),
              ),
              Positioned(
                left: 40,
                child: Container(
                  width: 10,
                  height: 14,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PendingOrderRow extends StatelessWidget {
  final TradeOrder order;

  const PendingOrderRow({super.key, required this.order});

  /// Convenience constructor for BlocBuilder
  factory PendingOrderRow.fromModel(TradeOrder order) {
    return PendingOrderRow(order: order);
  }

  @override
  Widget build(BuildContext context) {
    final pnlValue = double.tryParse(order.pnl.toString()) ?? 0.0;
    final isProfit = pnlValue >= 0;

    final formatted = DateFormat('dd/MM/yyyy, HH:mm:ss').format(order.entryTime.toLocal());

    return ListTile(
      onTap: () => context.router.safePush(PendingDetailRoute(order: order)),
      leading: buildSymbolIcon(order.symbol, size: 35),

      title: Text(order.symbol, style: const TextStyle(fontWeight: FontWeight.w600)),

      subtitle: Text(
        '${order.type} ${double.parse(order.lotSize).toStringAsPrecision(1)}',
        style: TextStyle(fontSize: 13, color: order.type == 'BUY' ? Colors.green : Colors.red),
      ),

      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 4),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Limit Price ',
                  style: const TextStyle(color: Colors.black),
                ),
                const TextSpan(
                  text: '> ',
                  style: TextStyle(color: Colors.grey, fontFamily: 'Roboto', fontSize: 18),
                ),
                TextSpan(
                  text: double.parse(order.entryPrice).toStringAsFixed(2),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),

          Text(
            DateFormat('dd/MM/yyyy, HH:mm:ss').format(order.entryTime.toLocal()),
            style: TextStyle(fontSize: 10.5, color: isProfit ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
