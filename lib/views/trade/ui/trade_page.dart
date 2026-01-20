// ignore_for_file: non_constant_identifier_names

import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/views/trade/ui/widgets/lot_field.dart';
import 'package:doin_fx/views/trade/ui/widgets/margin_summary.dart';
import 'package:doin_fx/views/trade/ui/widgets/optional_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:doin_fx/views/trade/bloc/trade_bloc.dart';
import 'package:doin_fx/views/trade/bloc/trade_event.dart';
import 'package:doin_fx/views/trade/bloc/trade_state.dart';
import 'package:doin_fx/views/trade/controller.dart';

/// TRADE PAGE
@RoutePage()
class TradePage extends StatefulWidget {
  final String? symbol;
  final double? cmp;
  const TradePage({super.key, this.symbol, this.cmp});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<TradeBloc, TradeState>(
          listener: (context, state) {
            if (state is TradeBuySuccess) {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.buyOrder.message!),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is TradeBuyFailure) {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if(state is TradeSellSuccess) {
               context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.sellOrder.message!),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _HeaderSection(state: state),
                const SizedBox(height: 4),
                Expanded(
                  child: TradingViewContainer(
                    symbol: widget.symbol ?? 'XAUUSD',
                  ),
                ),
                BuySellSection(symbol: widget.symbol ?? 'XAUUSD', cmp: widget.cmp ??  0.0),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BuySellSection extends StatefulWidget {
  final String symbol;
  final double cmp;

  BuySellSection({super.key, required this.symbol, required this.cmp});

  @override
  State<BuySellSection> createState() => _BuySellSectionState();
}

class _BuySellSectionState extends State<BuySellSection> {
  @override
  Widget build(BuildContext context) {
    // const symbol = 'XAUUSD'; // replace dynamically later

    print('inside Buy Section : ${widget.symbol}');

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))) ),
              onPressed: () => showSellPopup(context, symbol: widget.symbol, cmp: widget.cmp),
              child: const Text('SELL', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0)))),
              onPressed: () => showBuyPopup(context, symbol: widget.symbol, cmp: widget.cmp),
              child: const Text('BUY', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

/// HEADER
class _HeaderSection extends StatelessWidget {
  final TradeState state;
  const _HeaderSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 12, top: 6, right: 300),
      child: Text(
        '\$2,500.46',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}



void showBuyPopup(BuildContext context, {required String symbol, required double cmp}) {
  final formKey = GlobalKey<FormBuilderState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return FractionallySizedBox(
        heightFactor: 0.85, // UI ONLY
        child: DefaultTabController(
          length: 3,
          child: Builder(
            builder: (context) {
              final controller = DefaultTabController.of(context)!;

              // 🔒 SAME LOGIC — untouched
              controller.addListener(() {
                if (!controller.indexIsChanging) return;

                final form = formKey.currentState;
                if (form == null) return;

                switch (controller.index) {
                  case 0:
                    form.patchValue({'order_type': 'market'});
                    break;
                  case 1:
                    form.patchValue({'order_type': 'limit'});
                    break;
                  case 2:
                    form.patchValue({'order_type': 'advanced'});
                    break;
                }
              });


              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: FormBuilder(
                    key: formKey,
                    child: Column(
                      children: [
                        /// 🔒 HIDDEN FIELDS — unchanged
                        FormBuilderField<String>(
                          name: 'order_type',
                          initialValue: 'market',
                          builder: (_) => const SizedBox.shrink(),
                        ),
                        FormBuilderField<String>(
                          name: 'symbol',
                          initialValue: symbol,
                          builder: (_) => const SizedBox.shrink(),
                        ),

                        const TabBar(
                          tabs: [
                            Tab(text: 'Market'),
                            Tab(text: 'Limit'),
                            Tab(text: 'Advanced'),
                          ],
                        ),
                        const SizedBox(height: 12),

                        /// ✅ ONLY THIS PART SCROLLS
                        Expanded(
                          child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              OrderFormContent(
                                orderType: OrderType.market,
                                side: TradeSide.buy,
                                cmp: cmp,
                              ),
                              OrderFormContent(
                                orderType: OrderType.limit,
                                side: TradeSide.buy,
                                cmp: cmp,
                              ),
                              OrderFormContent(
                                orderType: OrderType.advanced,
                                side: TradeSide.buy,
                                cmp: cmp,
                              ),
                            ],
                          ),
                        ),

                        /// ✅ FIXED BUY BUTTON (NO LOGIC CHANGE)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              onPressed: () {
                                final form = formKey.currentState;
                                if (form == null) return;

                                form.save();
                                final data = Map<String, dynamic>.from(
                                  form.value,
                                );

                                context.read<TradeBloc>().add(
                                  TradeBuyPressed(data: data, conext: context),
                                );
                              },
                              child: const Text(
                                'BUY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}




/// SELL POPUP (dynamic)
void showSellPopup(BuildContext context, {required String symbol, required double cmp}) {
  final formKey = GlobalKey<FormBuilderState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return FractionallySizedBox(
        heightFactor: 0.85, // UI ONLY
        child: DefaultTabController(
          length: 3,
          child: Builder(
            builder: (context) {
              final controller = DefaultTabController.of(context)!;

              // 🔒 SAME LOGIC — untouched
              controller.addListener(() {
                final index = controller.index;
                final form = formKey.currentState; 
                if (form == null) return;

                switch (index) {
                  case 0:
                    form.patchValue({'order_type': 'market'});
                    break;
                  case 1:
                    form.patchValue({'order_type': 'limit'});
                    break;
                  case 2:
                    form.patchValue({'order_type': 'advanced'});
                    break;
                }
              });

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: FormBuilder(
                    key: formKey,
                    child: Column(
                      children: [
                          /// 🔒 HIDDEN FIELDS — unchanged
                        FormBuilderField<String>(
                          name: 'order_type',
                          initialValue: 'market',
                          builder: (_) => const SizedBox.shrink(),
                        ),
                        FormBuilderField<String>(
                          name: 'symbol',
                          initialValue: symbol,
                          builder: (_) => const SizedBox.shrink(),
                        ),
                        const TabBar(
                          tabs: [
                            Tab(text: 'Market'),
                            Tab(text: 'Limit'),
                            Tab(text: 'Advanced'),
                          ],
                        ),
                        const SizedBox(height: 12),

                        /// ✅ ONLY THIS SCROLLS
                        Expanded(
                          child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              OrderFormContent(
                                  orderType: OrderType.market,
                                  side: TradeSide.sell,
                                  cmp: cmp,
                                ),
                                OrderFormContent(
                                  orderType: OrderType.limit,
                                  side: TradeSide.sell,
                                  cmp: cmp,
                                ),
                                OrderFormContent(
                                  orderType: OrderType.advanced,
                                  side: TradeSide.sell,
                                  cmp: cmp,
                                ),
                            ],
                          ),
                        ),

                        /// ✅ FIXED SELL BUTTON
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              onPressed: () {
                                final form = formKey.currentState;
                                if (form == null) return;

                                form.save();
                                final data = Map<String, dynamic>.from(
                                  form.value,
                                );

                                context.read<TradeBloc>().add(TradeSellPressed(data: data));
                              },
                              child: const Text(
                                'SELL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

class OrderFormContent extends StatelessWidget {
  final OrderType orderType;
  final TradeSide side;
  final double cmp;

  const OrderFormContent({
    super.key,
    required this.orderType,
    required this.side,
    required this.cmp,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const LotSizeField(),

          /// Show trigger price only for limit / advanced
          if (orderType != OrderType.market)
            OptionalPriceField(
              'trigger_price',
              _triggerLabel(),
            ),

          MarginSummaryBar(
            requiredMargin: 1000.1075,
            freeMargin: 1000,
            currentPrice: cmp,
          ),

          OptionalPriceField('take_profit', 'Take Profit'),
          OptionalPriceField('stop_loss', 'Stop Loss'),
        ],
      ),
    );
  }

  String _triggerLabel() {
    if (side == TradeSide.buy) {
      return orderType == OrderType.limit ? 'Buy Limit' : 'Buy Above';
    } else {
      return orderType == OrderType.limit ? 'Sell Limit' : 'Sell Below';
    }
  }
}
