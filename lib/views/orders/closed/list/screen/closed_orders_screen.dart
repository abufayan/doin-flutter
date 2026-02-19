import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/utils/symbol_icon_resolver.dart';
import 'package:doin_fx/views/orders/closed/list/bloc/closed_orders_bloc.dart';
import 'package:doin_fx/views/orders/datamodel/trade_order.dart';
import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:doin_fx/core/utils/nav_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ClosedOrdersScreen extends StatefulWidget {
  const ClosedOrdersScreen({super.key});

  @override
  State<ClosedOrdersScreen> createState() => _ClosedOrdersScreenState();
}

class _ClosedOrdersScreenState extends State<ClosedOrdersScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClosedOrdersBloc()..add(LoadClosedOrders()),
      // ..add(ConnectSocket()),
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // InkWell(
                //   child: _BalanceRow(),
                //   onTap: () {
                //     // showModalBottomSheet(
                //     //   context: innerContext, // ✅ CORRECT CONTEXT
                //     //   backgroundColor: Colors.transparent,
                //     //   isScrollControlled: true,
                //     //   builder: (_) {
                //     //     return BlocProvider.value(
                //     //       value: innerContext.read<PendingOrderBloc>(),
                //     //       child: const AccountSummarySheet(),
                //     //     );
                //     //   },
                //     // );
                //   },
                // ),
                Expanded(
                  child: BlocBuilder<ClosedOrdersBloc, ClosedOrdersState>(
                    builder: (context, state) {
                      if (state is Loading) {
                        return AppLoaders.listShimmer();
                      }

                      if (state is ClosedOrdersLoaded) {
                        if (state.orders.isEmpty) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              context.read<ClosedOrdersBloc>().add(
                                LoadClosedOrders(),
                              );
                            },
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 200),
                                Center(child: Text('No Closed orders')),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<ClosedOrdersBloc>().add(
                              LoadClosedOrders(),
                            );
                          },
                          child: ListView.builder(
                            itemCount: state.orders.length,
                            itemBuilder: (context, i) {
                              return ClosedOrderRow(order: state.orders[i]);
                            },
                          ),
                        );
                      }

                      if (state is Error) {
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
        },
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

class ClosedOrderRow extends StatelessWidget {
  final TradeOrder order;

  const ClosedOrderRow({super.key, required this.order});

  /// Convenience constructor for BlocBuilder
  // factory PendingOrderRow.fromModel(TradeOrder order) {
  //   return PendingOrderRow(order: order);
  // }

  @override
  Widget build(BuildContext context) {
    final pnlValue = double.tryParse(order.pnl.toString()) ?? 0.0;
    final isProfit = pnlValue >= 0;

    return ListTile(
      onTap: () {
        context.safeNavigate(() => showClosedOrderDetails(context, order));
      },
      leading: buildSymbolIcon(order.symbol, size: 35),

      title: Text(
        order.symbol,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      subtitle: Text(
        '${order.type} ${double.parse(order.lotSize).toStringAsPrecision(1)}',
        style: TextStyle(
          fontSize: 13,
          color: order.type == 'BUY' ? Colors.green : Colors.red,
        ),
      ),

      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${isProfit ? '+' : '-'}\$ ${pnlValue.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15.5,
              color: isProfit ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Text(
          //   DateFormat(
          //     'dd/MM/yyyy, HH:mm:ss',
          //   ).format(order.exitTime!.toLocal()),
          //   style: TextStyle(
          //     fontSize: 10.5,
          //     color: Colors.grey[600],
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
            Text(
            _formatDate(order.exitTime!),
            style: TextStyle(
              fontSize: 10.5,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

void showClosedOrderDetails(BuildContext context, TradeOrder order) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 DRAG HANDLE
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            /// 🔹 HEADER (existing)
            closedOrderHeader(order),

            const SizedBox(height: 16),
            const Divider(height: 1),

            const SizedBox(height: 12),

            /// 🔹 TIME SECTION
            Text(
              'Time',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            _infoRow('Open Time', _formatDate(order.entryTime)),
            _infoRow(
              'Close Time',
              order.exitTime != null ? _formatDate(order.exitTime!) : '-',
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            /// 🔹 PRICE SECTION
            Text(
              'Prices',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            _infoRow('Open Price', order.entryPrice),
            _infoRow('Close Price', order.exitPrice ?? '-'),
            _infoRow('Stop Loss', order.stopLoss ?? '-'),
            _infoRow('Take Profit', order.takeProfit ?? '-'),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            /// 🔹 COST SECTION
            Text(
              'Costs',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            _infoRow('Swap', '${order.swap} USD'),
            _infoRow('Commission', '${order.commission} USD'),

            const SizedBox(height: 4),
          ],
        ),
      );
    },
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year} '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}:'
      '${date.second.toString().padLeft(2, '0')}';
}

Widget closedOrderHeader(TradeOrder order) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      /// Position ID
      Text(
        'Position ID: ${order.tradeId}',
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),

      const SizedBox(height: 12),

      /// Main Row
      Row(
        children: [
          /// Blank circle avatar
          buildSymbolIcon(order.symbol),

          const SizedBox(width: 12),

          /// Symbol + Type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.symbol.replaceAll('/', ''),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      order.type == 'BUY'
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: order.type == 'BUY' ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    Text(
                      '${order.type.toLowerCase()} ${order.lotSize}',
                      style: TextStyle(
                        fontSize: 13,
                        color: order.type == 'BUY' ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// PNL
          Text(
            order.pnl >= 0
                ? '+\$${order.pnl.toStringAsFixed(2)}'
                : '-\$${order.pnl.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: order.pnl >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),

      const SizedBox(height: 8),

      /// Entry > Exit price
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          '${_fmt(order.entryPrice)}  >  ${_fmt(order.exitPrice)}',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ),
    ],
  );
}

String _fmt(String? price) {
  if (price == null) return '-';
  final value = double.tryParse(price);
  return value?.toStringAsFixed(2) ?? '-';
}
