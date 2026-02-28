import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/utils/symbol_icon_resolver.dart';
import 'package:doin_fx/views/orders/datamodel/trade_order.dart';
import 'package:doin_fx/views/orders/helper/show_snackbar.dart';
import 'package:doin_fx/views/orders/pending/detail/bloc/detail_pending_bloc.dart';
import 'package:doin_fx/views/orders/pending/list/bloc/pending_order_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class PendingDetailScreen extends StatefulWidget {
  final TradeOrder order;

  const PendingDetailScreen({super.key, required this.order});

  @override
  State<PendingDetailScreen> createState() => _PendingDetailScreenState();
}

class _PendingDetailScreenState extends State<PendingDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double? takeProfit;
  double? stopLoss;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    takeProfit = widget.order.takeProfit != null ? double.tryParse(widget.order.takeProfit!) : null;

    stopLoss = widget.order.stopLoss != null ? double.tryParse(widget.order.stopLoss!) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _topHeader(),
            _symbolHeader(),
            _tabBar(),
            Expanded(
              child: TabBarView(controller: _tabController, children: [_infoTab(), _editTab()]),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- TOP HEADER --------------------
  Widget _topHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            '\$${getIt<MyAccountService>().wallet}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
            child: Text(
              getIt<MyAccountService>().accountType == AccountType.live ? 'REAL' : 'DEMO',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- SYMBOL HEADER --------------------
  Widget _symbolHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          SizedBox(width: 8),
          buildSymbolIcon(widget.order.symbol, size: 35),
          SizedBox(width: 8),
          Text(widget.order.symbol.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Spacer(),
          Text(
            'Limit Price  > ',
            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          Text(' ${widget.order.entryPrice}', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // -------------------- TAB BAR --------------------
  Widget _tabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.orange,
      labelColor: Colors.orange,
      unselectedLabelColor: Colors.black,
      tabs: const [
        Tab(text: 'Info'),
        Tab(text: 'Edit'),
      ],
    );
  }

  // -------------------- INFO TAB --------------------
  Widget _infoTab() {
    return BlocConsumer<DetailPendingBloc, DetailPendingState>(
      listener: (BuildContext context, DetailPendingState state) {
        if (state is TradeClosed) {
          showSnackbar(context, state.message, success: true);
          context.read<PendingOrderBloc>().add(LoadPendingOrders());
          context.pop();
        }
        if (state is UpdateTradeSuccess) {
          showSnackbar(context, state.message, success: true);
          context.read<PendingOrderBloc>().add(LoadPendingOrders());
        }
        if (state is UpdateTradeError) {
          showSnackbar(context, state.message, success: false);
        }
      },
      builder: (context, state) {
        // if (state is! OpenOrdersLoaded) {
        //   return const Center(child: CircularProgressIndicator());
        // }

        final order = widget.order;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _infoRow('Created Time', DateFormat('dd/MM/yyyy, HH:mm:ss').format(order.entryTime.toUtc())),
              // _infoRow(
              //   'PNL',
              //   '${order.pnl >= 0 ? '+' : '-'}\$${order.pnl.abs().toStringAsFixed(2)}',
              //   valueColor: order.pnl >= 0 ? Colors.green : Colors.red,
              // ),
              _infoRow('Position ID', '${order.tradeId}'),
              _infoRow('Order', order.type, valueColor: order.type == 'BUY' ? Colors.green : Colors.red),
              _infoRow('Limit Price', double.parse(order.entryPrice).toStringAsFixed(2)),
              _infoRow('Lot Size', double.parse(order.lotSize).toStringAsPrecision(1)),
              // _infoRow('Swap Fee', '\$ ${order.swap}'),

              // _infoRow('Leverage', '${order.leverage}'),
              const Spacer(),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    context.read<DetailPendingBloc>().add(CloseTrade(tradeId: widget.order.tradeId.toString()));
                  },
                  child: Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value, {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  // -------------------- EDIT TAB --------------------

  // String formatPrice(double v, String symbol) {
  //   final normalized = symbol.replaceAll('/', '');

  //   if (normalized == 'XAUUSD') return v.toStringAsFixed(2);
  //   if (normalized.endsWith('JPY')) return v.toStringAsFixed(3);
  //   return v.toStringAsFixed(5);
  // }

  Widget _editTab() {
    return BlocConsumer<DetailPendingBloc, DetailPendingState>(
      listener: (BuildContext context, DetailPendingState state) {
        if (state is UpdateTradeSuccess) {
          context.read<PendingOrderBloc>().add(LoadPendingOrders());
          showSnackbar(context, state.message, success: true);
        }
        if (state is UpdateTradeError) {
          showSnackbar(context, state.message, success: false);
        }
        if (state is RemoveTpSlSuccess) {
          context.read<PendingOrderBloc>().add(LoadPendingOrders());
          showSnackbar(context, state.message, success: true);
          if (state.removedTp) {
            takeProfit = null;
            // originalTakeProfit = null;
          }
          if (state.removedSl) {
            stopLoss = null;
            // originalStopLoss = null;
          }
          setState(() {});
          // context.read<OpenOrdersBloc>().add(LoadOpenOrders());
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _stepperField(
                      label: 'Take Profit',
                      value: takeProfit,
                      onChanged: (v) => setState(() => takeProfit = v),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<DetailPendingBloc>().add(
                        RemoveTpSl(tradeId: widget.order.tradeId.toString(), removeTp: true),
                      );
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _stepperField(
                      label: 'Stop Loss',
                      value: stopLoss,
                      onChanged: (v) => setState(() => stopLoss = v),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<DetailPendingBloc>().add(
                        RemoveTpSl(tradeId: widget.order.tradeId.toString(), removeSl: true),
                      );
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  // Expanded(
                  //   child: SizedBox(
                  //     height: 48,
                  //     child: OutlinedButton(
                  //       style: OutlinedButton.styleFrom(
                  //         foregroundColor: Colors.grey,
                  //         side: const BorderSide(color: Colors.grey),
                  //       ),
                  //       onPressed: () {},
                  //       child: Text('Discard'),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 12),
                  Expanded(
                    // ✅ Add Expanded here
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {
                          context.read<DetailPendingBloc>().add(
                            UpdateTrade(
                              takeProfit: takeProfit,
                              stopLoss: stopLoss,
                              tradeId: widget.order.tradeId.toString(),
                            ),
                          );
                        },
                        child: Text('Confirm', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stepperField({required String label, required double? value, required ValueChanged<double?> onChanged}) {
    return _PendingStepperFieldWidget(
      label: label,
      value: value,
      onChanged: onChanged,
      symbol: widget.order.symbol,
      // formatPrice: formatPrice,
    );
  }
}

/// ==================== PENDING STEPPER FIELD WIDGET ====================
class _PendingStepperFieldWidget extends StatefulWidget {
  final String label;
  final double? value;
  final ValueChanged<double?> onChanged;
  final String symbol;
  final String Function(double, String)? formatPrice;

  const _PendingStepperFieldWidget({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.symbol,
    this.formatPrice,
  });

  @override
  State<_PendingStepperFieldWidget> createState() => _PendingStepperFieldWidgetState();
}

class _PendingStepperFieldWidgetState extends State<_PendingStepperFieldWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // _controller = TextEditingController(
    //   text: widget.value == null ? '' : widget.formatPrice(widget.value!, widget.symbol),
    // );
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _PendingStepperFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      // 🔥 If value is removed → ALWAYS clear
      if (widget.value == null) {
        _controller.clear();
        return;
      }

      // 🔥 Only block formatting while actively typing
      if (_focusNode.hasFocus) return;

      final newText = widget.value!.toString();

      if (_controller.text == newText) return;

      _controller.text = newText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: widget.value == null
                    ? null
                    : () {
                        final newValue = double.parse((widget.value! - 0.01).toStringAsFixed(5));

                        if (newValue >= 0.1) {
                          widget.onChanged(newValue);
                        }
                      },
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                  onChanged: (text) {
                    if (text.trim().isEmpty) {
                      widget.onChanged(null);
                      return;
                    }

                    final parsed = double.tryParse(text);
                    if (parsed != null && parsed >= 0.1) {
                      widget.onChanged(parsed);
                    }
                  },
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: widget.value == null
                    ? null
                    : () {
                        widget.onChanged(double.parse((widget.value! + 0.01).toStringAsFixed(5)));
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
