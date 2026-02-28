// ignore_for_file: non_constant_identifier_names

import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/utils/symbol_icon_resolver.dart';
import 'package:doin_fx/views/trade/ui/widgets/lot_field.dart';
import 'package:doin_fx/views/trade/ui/widgets/margin_summary.dart';
import 'package:doin_fx/views/trade/ui/widgets/optional_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:doin_fx/views/orders/helper/show_snackbar.dart';
import 'package:doin_fx/views/trade/bloc/trade_bloc.dart';
import 'package:doin_fx/views/trade/bloc/trade_event.dart';
import 'package:doin_fx/views/trade/bloc/trade_state.dart';

/// ======================
/// SELL POPUP
/// ======================
void showSellPopup(BuildContext context, {required String symbol}) {
  // 🔑 Initialize TradeBloc with symbol when opening popup (if not already initialized)
  final tradeBloc = context.read<TradeBloc>();
  final currentState = tradeBloc.state;

  // Only call TradeStarted if we're initializing for the first time or if symbol changed
  // if (currentState is TradeInitial || (currentState is TradeQuoteState && currentState.symbol != symbol)) {
  // tradeBloc.add(TradeStarted(symbol: symbol));
  // }

  final formKey = GlobalKey<FormBuilderState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) {
      return BlocListener<TradeBloc, TradeState>(
        listener: (ctx, state) {
          if (state is TradeSellSuccess) {
            showSnackbar(ctx, '${state.order.message}', success: true);
            Navigator.of(ctx).pop();
          }
        },
        child: FractionallySizedBox(
          heightFactor: 0.85,
          child: DefaultTabController(
            length: 3,
            child: Builder(
              builder: (context) {
                final controller = DefaultTabController.of(context);

                controller.addListener(() {
                  if (!controller.indexIsChanging) return;
                  final form = formKey.currentState;
                  if (form == null) return;

                  form.patchValue({
                    'order_type': controller.index == 0
                        ? 'market'
                        : controller.index == 1
                        ? 'limit'
                        : 'advanced',
                  });
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
                          FormBuilderField(
                            name: 'symbol',
                            initialValue: symbol,
                            builder: (_) => const SizedBox.shrink(),
                          ),
                          FormBuilderField(
                            name: 'order_type',
                            initialValue: 'market',
                            builder: (_) => const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 8),

                          // 🔹 Selected symbol header (so user always knows what they're trading)
                          Row(
                            children: [
                              buildSymbolIcon(symbol, size: 28),
                              const SizedBox(width: 10),
                              Text(symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Shared LotSizeField for all tabs
                          BlocBuilder<TradeBloc, TradeState>(
                            buildWhen: (prev, curr) => curr is TradeQuoteState,
                            builder: (context, state) {
                              if (state is! TradeQuoteState) {
                                return const SizedBox.shrink();
                              }

                              final isEth = state.symbol.contains('ETH');

                              return LotSizeField(
                                initialLot: state.lot,
                                minLot: isEth ? 0.10 : 0.01,
                                onChanged: (lot) {
                                  context.read<TradeBloc>().add(TradeLotChanged(lot: lot));
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          const TabBar(
                            tabs: [
                              Tab(text: 'Market'),
                              Tab(text: 'Limit'),
                              Tab(text: 'Pending'),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Expanded(
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: List.generate(
                                3,
                                (index) => _SellOrderFormContent(orderType: OrderType.values[index]),
                              ),
                            ),
                          ),

                          _SellSubmitButton(formKey: formKey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

/// ======================
/// SELL ORDER FORM CONTENT
/// ======================
class _SellOrderFormContent extends StatelessWidget {
  final OrderType orderType;

  const _SellOrderFormContent({required this.orderType});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // For SELL: Limit tab shows "Limit Price", Advanced shows "Sell Below"
          if (orderType != OrderType.market)
            OptionalPriceField('trigger_price', orderType == OrderType.limit ? 'Limit Price' : 'Sell Below'),

          /// 🔥 LIVE MARGIN SUMMARY
          BlocBuilder<TradeBloc, TradeState>(
            buildWhen: (p, c) => c is TradeQuoteState,
            builder: (context, state) {
              if (state is! TradeQuoteState) {
                return const SizedBox.shrink();
              }

              return MarginSummaryBar(
                requiredMargin: state.requiredMargin,
                freeMargin: state.freeMargin,
                currentPrice: state.cmp,
              );
            },
          ),

          OptionalPriceField('take_profit', 'Take Profit'),
          OptionalPriceField('stop_loss', 'Stop Loss'),
        ],
      ),
    );
  }
}

/// ======================
/// SELL SUBMIT BUTTON
/// ======================
class _SellSubmitButton extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;

  const _SellSubmitButton({required this.formKey});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradeBloc, TradeState>(
      buildWhen: (previous, current) => current is TradeQuoteState,
      builder: (context, state) {
        bool isMarginInsufficient = false;
        bool isLotInvalid = false;
        bool isSubmitting = false;
        String? errorMessage;

        if (state is TradeQuoteState) {
          isMarginInsufficient = state.requiredMargin > state.freeMargin;
          final isEth = state.symbol.contains('ETH');
          final minLot = isEth ? 0.10 : 0.01;

          isLotInvalid = state.lot < minLot;
          isSubmitting = state.isSubmitting;
          errorMessage = state.errorMessage;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              // 🔴 API error message banner
              if (errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              if (isMarginInsufficient)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Insufficient margin. Required > Free',
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              if (isLotInvalid)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Lot size must be at least 0.01',
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.red.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: (isMarginInsufficient || isLotInvalid || isSubmitting)
                      ? null
                      : () {
                          final form = formKey.currentState;
                          if (form == null) return;

                          form.save();

                          context.read<TradeBloc>().add(TradeSellPressed(data: form.value, context: context));
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('SELL', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
