import 'package:doin_fx/core/enums.dart';
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

class _ClosedOrdersScreenState extends State<ClosedOrdersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Trigger initial load on the globally provided bloc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClosedOrdersBloc>().add(LoadClosedOrders());
    });
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerContext) {
        final bloc = innerContext.read<ClosedOrdersBloc>();
        return Scaffold(
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_animation.value),
                  child: child,
                );
              },
              child: BlocBuilder<ClosedOrdersBloc, ClosedOrdersState>(
                builder: (context, state) {
                  final currentType = state is ClosedOrdersLoaded
                      ? state.filterType
                      : ClosedOrderTypes.last24hrs;
                  final isShowAll = currentType != ClosedOrderTypes.showAll;
                  final label = isShowAll ? 'Show All' : 'Last 24 Hrs';
                  final nextType = isShowAll
                      ? ClosedOrderTypes.showAll
                      : ClosedOrderTypes.last24hrs;

                  return GestureDetector(
                    onTap: () {
                      bloc.add(LoadClosedOrders(type: nextType));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Color(0xFFFF9800),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
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
                      final isShowAll =
                          state.filterType == ClosedOrderTypes.showAll;
                      final filteredOrders =
                          isShowAll && _searchQuery.isNotEmpty
                          ? state.orders.where((o) {
                              final q = _searchQuery.toLowerCase().replaceAll(
                                '/',
                                '',
                              );
                              final s = o.symbol.toLowerCase().replaceAll(
                                '/',
                                '',
                              );
                              return s.contains(q) ||
                                  o.tradeId.toString().contains(q) ||
                                  o.type.toLowerCase().contains(q);
                            }).toList()
                          : state.orders;

                      if (state.orders.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            final bloc = context.read<ClosedOrdersBloc>();
                            final type = state.filterType;
                            bloc.add(LoadClosedOrders(type: type));
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              _ClosedOrdersInfoBanner(
                                filterType: state.filterType,
                              ),
                              if (isShowAll)
                                _buildSearchBar(
                                  _searchController,
                                  _searchQuery,
                                ),
                              if (isShowAll) _csvDownloadButton(),
                              const SizedBox(height: 200),
                              const Center(child: Text('No Closed orders')),
                            ],
                          ),
                        );
                      }

                      if (filteredOrders.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            final bloc = context.read<ClosedOrdersBloc>();
                            final type = state.filterType;
                            bloc.add(LoadClosedOrders(type: type));
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              _ClosedOrdersInfoBanner(
                                filterType: state.filterType,
                              ),
                              if (isShowAll)
                                _buildSearchBar(
                                  _searchController,
                                  _searchQuery,
                                ),
                              if (isShowAll) _csvDownloadButton(),
                              const SizedBox(height: 200),
                              const Center(child: Text('No results')),
                            ],
                          ),
                        );
                      }

                      final headerCount = 1 + (isShowAll ? 2 : 0);

                      return RefreshIndicator(
                        onRefresh: () async {
                          final bloc = context.read<ClosedOrdersBloc>();
                          final type = state.filterType;
                          bloc.add(LoadClosedOrders(type: type));
                        },
                        child: ListView.builder(
                          itemCount: filteredOrders.length + headerCount,
                          itemBuilder: (context, i) {
                            if (i == 0) {
                              return _ClosedOrdersInfoBanner(
                                filterType: state.filterType,
                              );
                            }
                            if (isShowAll && i == 1) {
                              return _buildSearchBar(
                                _searchController,
                                _searchQuery,
                              );
                            }
                            if (isShowAll && i == 2) {
                              return _csvDownloadButton();
                            }
                            final order = filteredOrders[i - headerCount];
                            return ClosedOrderRow(order: order);
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
        order.symbol.replaceAll('/', ''),
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

class _ClosedOrdersInfoBanner extends StatelessWidget {
  final ClosedOrderTypes filterType;

  const _ClosedOrdersInfoBanner({required this.filterType});

  @override
  Widget build(BuildContext context) {
    final bool isShowAll = filterType == ClosedOrderTypes.showAll;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            isShowAll
                ? 'Showing all closed positions'
                : 'Showing closed positions for the last 24 hours',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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

Widget _buildSearchBar(TextEditingController controller, String query) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search symbol or ID',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: const Icon(Icons.search, size: 22, color: Color(0xFFFF9800)),
          ),
          suffixIcon: query.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.black54,
                      ),
                    ),
                    onPressed: () {
                      controller.clear();
                    },
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    ),
  );
}

Widget _csvDownloadButton() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
    child: Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.download_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Download CSV',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
