import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/core/utils/nav_utils.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/utils/symbol_icon_resolver.dart';
import 'package:doin_fx/views/orders/datamodel/trade_order.dart';
import 'package:doin_fx/views/orders/widgets/account_summary.dart';
import 'package:flutter/material.dart';
import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/open_orders_bloc.dart';

@RoutePage()
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

    final bloc = context.read<OpenOrdersBloc>();
    bloc.add(LoadOpenOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerContext) {
        return BlocConsumer<OpenOrdersBloc, OpenOrdersState>(
          listenWhen: (prev, cur) => cur is OpenOrdersActionState,
          buildWhen: (prev, cur) => cur is! OpenOrdersActionState,
          listener: (context, state) {
            if (state is ActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }

            if (state is OpenOrdersError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }

            if (state is CloseTradeError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
              context.read<OpenOrdersBloc>().add(LoadOpenOrders(showLoading: false));
            }

            if (state is CloseTradeSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            }
          },
          builder: (summaryContext, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<OpenOrdersBloc>().add(LoadOpenOrders());
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      child: _BalanceRow(),
                      onTap: () {
                        context.safeNavigate(() {
                          showModalBottomSheet(
                            context: summaryContext, // ✅ CORRECT CONTEXT
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) {
                              return BlocProvider.value(
                                value: innerContext.read<OpenOrdersBloc>(),
                                child: const AccountSummarySheet(),
                              );
                            },
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (state is OpenOrdersLoaded) ...[
                      _AccountLevel(accountLevel: state.accountLevel),
                      const SizedBox(height: 12),
                    ],
                    if (state is OpenOrdersLoading) ...[_AccountLevel(accountLevel: 0.0), const SizedBox(height: 12)],
                    const SizedBox(height: 12),
                    _TotalPnlCard(),
                    const SizedBox(height: 8),
                    // BlocBuilder<OpenOrdersBloc, OpenOrdersState>(
                    //   builder: (context, state) {
                    //     if (state is! OpenOrdersLoaded) {
                    //       return const SizedBox.shrink();
                    //     }
                    //
                    //     // return MarginWarningBanner(
                    //     //   marginLevel: state.marginLevel,
                    //     // );
                    //   },
                    // ),
                    Expanded(
                      child: BlocBuilder<OpenOrdersBloc, OpenOrdersState>(
                        buildWhen: (prev, cur) => cur is! OpenOrdersActionState,
                        builder: (context, state) {
                          if (state is OpenOrdersLoading) {
                            return AppLoaders.listShimmer();
                          }

                          if (state is OpenOrdersLoaded) {
                            if (state.orders.isEmpty) {
                              return ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [const Center(child: Text('No open orders'))],
                              );
                            }

                            return ListView.builder(
                              itemCount: state.orders.length,
                              itemBuilder: (context, i) {
                                return _OpenOrderRow(order: state.orders[i]);
                              },
                            );
                          }

                          if (state is OpenOrdersError) {
                            return Center(
                              child: Text(state.message, style: const TextStyle(color: Colors.red)),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
  final double accountLevel; // percentage

  const _AccountLevel({required this.accountLevel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account Level', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),

          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;

              // Clamp margin level between 0–100
              final clampedLevel = accountLevel.clamp(0, 100);

              // Convert percentage to pixel position
              final indicatorPosition = (clampedLevel / 100) * barWidth;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Gradient bar
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(colors: [Colors.red, Colors.orange, Colors.green]),
                    ),
                  ),

                  // Indicator
                  Positioned(
                    left: indicatorPosition - 5, // center indicator
                    top: -4,
                    child: Container(
                      width: 7,
                      height: 16,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 6),
          // Text(
          //   '${marginLevel.toStringAsFixed(1)}%',
          //   style: const TextStyle(fontSize: 12, color: Colors.grey),
          // ),
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
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
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
                PopupMenuButton<String>(
                  offset: const Offset(0, 46),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.white,
                  onSelected: (value) {
                    final bloc = context.read<OpenOrdersBloc>();

                    switch (value) {
                      case 'close_all':
                        bloc.add(CloseAllTrades());
                        break;
                      case 'close_profit':
                        bloc.add(CloseAllProfitTrades());
                        break;
                      case 'close_loss':
                        bloc.add(CloseAllLossTrades());
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    _buildMenuItem(value: 'close_all', icon: Icons.close_fullscreen_rounded, text: 'Close All'),
                    _buildMenuItem(
                      value: 'close_profit',
                      icon: Icons.trending_up_rounded,
                      text: 'Close Profit Trades',
                      iconColor: Colors.green,
                    ),
                    _buildMenuItem(
                      value: 'close_loss',
                      icon: Icons.trending_down_rounded,
                      text: 'Close Loss Trades',
                      iconColor: Colors.red,
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFFF8C00)]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8C00).withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Close',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
                      ],
                    ),
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

class _OpenOrderRow extends StatelessWidget {
  final TradeOrder order;

  const _OpenOrderRow({required this.order});

  /// Convenience constructor for BlocBuilder
  factory _OpenOrderRow.fromModel(TradeOrder order) {
    return _OpenOrderRow(order: order);
  }

  @override
  Widget build(BuildContext context) {
    final pnlValue = double.tryParse(order.pnl.toString()) ?? 0.0;
    final isProfit = pnlValue >= 0;

    return ListTile(
      onTap: () => context.router.safePush(OpenDetailRoute(order: order)),
      leading: buildSymbolIcon(order.symbol, size: 35),

      title: Text(order.symbol.replaceAll('/', ''), style: const TextStyle(fontWeight: FontWeight.w600)),

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
            style: TextStyle(fontSize: 15.5, color: isProfit ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
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

PopupMenuItem<String> _buildMenuItem({
  required String value,
  required IconData icon,
  required String text,
  Color iconColor = Colors.black87,
}) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
