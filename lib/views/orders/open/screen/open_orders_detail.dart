import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/core/utils/symbol_icon_resolver.dart';
import 'package:doin_fx/views/orders/datamodel/trade_order.dart';
import 'package:doin_fx/views/orders/helper/show_snackbar.dart';
import 'package:doin_fx/views/orders/open/bloc/open_orders_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class OpenDetailScreen extends StatefulWidget implements AutoRouteWrapper {
  final TradeOrder order;

  const OpenDetailScreen({super.key, required this.order});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider.value(value: context.read<OpenOrdersBloc>(), child: this);
  }

  @override
  State<OpenDetailScreen> createState() => _OpenDetailScreenState();
}

class _OpenDetailScreenState extends State<OpenDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double? takeProfit;
  double? stopLoss;

  // Store original values for discard functionality
  double? originalTakeProfit;
  double? originalStopLoss;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    takeProfit = widget.order.takeProfit != null ? double.tryParse(widget.order.takeProfit!) : null;

    stopLoss = widget.order.stopLoss != null ? double.tryParse(widget.order.stopLoss!) : null;

    // Store original values for discard functionality
    originalTakeProfit = takeProfit;
    originalStopLoss = stopLoss;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OpenOrdersBloc, OpenOrdersState>(
      listener: (context, state) {
        // Handle discard - reset values to original
        // if (state is EditValuesReset) {
        //   setState(() {
        //     takeProfit = state.originalTakeProfit;
        //     stopLoss = state.originalStopLoss;
        //   });
        // }
      },
      child: Scaffold(
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
      ),
    );
  }

  // -------------------- TOP HEADER --------------------
  Widget _topHeader() {
    bool realAccount = getIt<MyAccountService>().accountType == AccountType.live;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${getIt<MyAccountService>().wallet}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: realAccount ? Colors.green.shade100 : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              realAccount ? 'Real' : 'Demo',
              style: TextStyle(color: realAccount ? Colors.green : Colors.blue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- SYMBOL HEADER --------------------
  Widget _symbolHeader() {
    return BlocConsumer<OpenOrdersBloc, OpenOrdersState>(
      listener: (BuildContext context, OpenOrdersState state) {
        if (state is UpdateTradeSuccess) {
          showSnackbar(context, state.message, success: true);
          //preserving original values after successful update
          {
            originalTakeProfit = takeProfit;
            originalStopLoss = stopLoss;
          }
          context.read<OpenOrdersBloc>().add(LoadOpenOrders());
        }
        if (state is RemoveTpSlSuccess) {
          context.read<OpenOrdersBloc>().add(LoadOpenOrders(showLoading: false));
          showSnackbar(context, state.message, success: true);
          if (state.removedTp) {
            takeProfit = null;
            originalTakeProfit = null;
          }
          if (state.removedSl) {
            stopLoss = null;
            originalStopLoss = null;
          }
          setState(() {});
          // context.read<OpenOrdersBloc>().add(LoadOpenOrders());
        }
        if (state is UpdateTradeError) {
          showSnackbar(context, state.message, success: false);
          context.read<OpenOrdersBloc>().add(LoadOpenOrders());
        }
        if (state is TradeClosed) {
          showSnackbar(context, state.message, success: true);
          context.read<OpenOrdersBloc>().add(LoadOpenOrders());
          context.pop();
        }
      },
      buildWhen: (context, state) => state is OpenOrdersLoaded,
      // || state is OpenOrdersLoading,
      builder: (context, state) {
        TradeOrder? order;
        // final state = context.read<OpenOrdersBloc>().state;
        if (state is OpenOrdersLoaded) {
          order = state.orders.firstWhere((o) => o.tradeId == widget.order.tradeId, orElse: () => widget.order);
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
              SizedBox(width: 8),
              SizedBox(width: 8),
              buildSymbolIcon(widget.order.symbol, size: 35),
              SizedBox(width: 8),
              Text(widget.order.symbol.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Spacer(),
              Text(
                'CMP  > ',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
              Text(' ${order?.cmp}', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
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
    return BlocBuilder<OpenOrdersBloc, OpenOrdersState>(
      builder: (context, state) {
        if (state is! OpenOrdersLoaded) {
          return AppLoaders.loadingIndicator();
        }

        final order = state.orders.firstWhere((o) => o.tradeId == widget.order.tradeId, orElse: () => widget.order);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _infoRow('Open Time', DateFormat('dd/MM/yyyy, HH:mm:ss').format(order.createdAt.toUtc())),
              _infoRow('Open Price', order.entryPrice),
              _infoRow(
                'PNL',
                '${order.pnl >= 0 ? '+' : '-'}\$${order.pnl.abs().toStringAsFixed(2)}',
                valueColor: order.pnl >= 0 ? Colors.green : Colors.red,
              ),
              _infoRow('Order', order.type, valueColor: order.type == 'BUY' ? Colors.green : Colors.red),
              _infoRow('Lot Size', double.parse(order.lotSize).toStringAsPrecision(1)),
              _infoRow('Swap Fee', '\$ ${order.swap}'),
              _infoRow('Position ID', '${order.tradeId}'),
              Visibility(visible: order.takeProfit != null, child: _infoRow('Take Profit', '${order.takeProfit}')),
              Visibility(visible: order.stopLoss != null, child: _infoRow('Stop Loss', '${order.stopLoss}')),
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
                    context.read<OpenOrdersBloc>().add(CloseTrade(tradeId: widget.order.tradeId.toString()));
                  },
                  child: Text('Close Trade', style: TextStyle(color: Colors.white)),
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

  String formatPrice(double v, String symbol) {
    final normalized = symbol.replaceAll('/', '');

    if (normalized == 'XAUUSD') return v.toStringAsFixed(2);
    if (normalized.endsWith('JPY')) return v.toStringAsFixed(3);
    return v.toStringAsFixed(5);
  }

  Widget _editTab() {
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
                  context.read<OpenOrdersBloc>().add(
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
                  context.read<OpenOrdersBloc>().add(
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
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus(); // 🔥 ADD THIS FIRST
                      // Dispatch bloc event for discard
                      // context.read<OpenOrdersBloc>().add(
                      //   ResetEditValues(
                      //     originalTakeProfit: originalTakeProfit,
                      //     originalStopLoss: originalStopLoss,
                      //   ),
                      // );
                      // Also call setState to ensure UI updates
                      setState(() {
                        takeProfit = originalTakeProfit;
                        stopLoss = originalStopLoss;
                      });
                    },
                    child: Text('Discard', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
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
                      context.read<OpenOrdersBloc>().add(
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
  }

  Widget _stepperField({required String label, required double? value, required ValueChanged<double?> onChanged}) {
    return _StepperFieldWidget(
      label: label,
      value: value,
      onChanged: onChanged,
      symbol: widget.order.symbol,
      formatPrice: formatPrice,
    );
  }
}

class _StepperFieldWidget extends StatefulWidget {
  final String label;
  final double? value;
  final ValueChanged<double?> onChanged;
  final String symbol;
  final String Function(double, String) formatPrice;

  const _StepperFieldWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.symbol,
    required this.formatPrice,
  });

  @override
  State<_StepperFieldWidget> createState() => _StepperFieldWidgetState();
}

class _StepperFieldWidgetState extends State<_StepperFieldWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();

    _controller = TextEditingController(
      text: widget.value == null ? '' : widget.formatPrice(widget.value!, widget.symbol),
    );

    _focusNode.addListener(() {
      setState(() {
        _isEditing = _focusNode.hasFocus;
      });

      // When user starts editing → show raw value
      if (_focusNode.hasFocus) {
        if (widget.value != null) {
          _controller.text = widget.value!.toString();
          _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
        }
      } else {
        // When user stops editing → format value
        if (widget.value != null) {
          final formatted = widget.formatPrice(widget.value!, widget.symbol);
          _controller.text = formatted;
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant _StepperFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      if (widget.value == null) {
        _controller.clear();
        return;
      }

      if (_isEditing) return;

      final newText = widget.formatPrice(widget.value!, widget.symbol);

      if (_controller.text == newText) return;

      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
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
              // ➖ MINUS
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: widget.value == null
                    ? null
                    : () {
                        widget.onChanged(double.parse((widget.value! - 0.01).toStringAsFixed(5)));
                      },
              ),

              // ✏️ INPUT
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
                    if (parsed != null) {
                      widget.onChanged(parsed);
                    }
                  },
                ),
              ),

              // ➕ PLUS
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
