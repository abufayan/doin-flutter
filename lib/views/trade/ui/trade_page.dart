// ignore_for_file: non_constant_identifier_names

import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/utils/nav_utils.dart';
import 'package:doin_fx/views/trade/controllers/fcs_controller.dart';
import 'package:doin_fx/views/trade/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:doin_fx/views/trade/bloc/trade_bloc.dart';
import 'package:doin_fx/views/trade/bloc/trade_event.dart';
import 'package:doin_fx/views/trade/bloc/trade_state.dart';
import 'package:doin_fx/views/trade/ui/widgets/buy_popup.dart';
import 'package:doin_fx/views/trade/ui/widgets/sell_popup.dart';

/// ======================
/// TRADE PAGE
/// ======================
///
@RoutePage()
class TradePage extends StatefulWidget {
  final String symbol;

  const TradePage({super.key, required this.symbol});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  @override
  void didUpdateWidget(covariant TradePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.symbol != widget.symbol) {
      // 👇 DO WHATEVER YOU DO IN initState FOR SYMBOL
      _onSymbolChanged(widget.symbol);
    }
  }

  @override
  void initState() {
    super.initState();
    _onSymbolChanged(widget.symbol);
  }

  void _onSymbolChanged(String symbol) {
    context.read<TradeBloc>().add(TradeStarted(symbol: symbol));

    // or socket subscribe
    // or chart reload
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<TradeBloc, TradeState>(
          listener: (context, state) {
            // if (state is TradeBuySuccess) {
            //   // Navigator.of(context).pop();
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       content: Text(
            //         state.order.message ?? 'Buy order placed successfully',
            //       ),
            //       backgroundColor: Colors.green,
            //       behavior: SnackBarBehavior.floating,
            //     ),
            //   );
            // }

            // if (state is TradeSellSuccess) {
            //   // Navigator.of(context).pop();
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       content: Text(
            //         state.order.message ?? 'Sell order placed successfully',
            //       ),
            //       backgroundColor: Colors.green,
            //       behavior: SnackBarBehavior.floating,
            //     ),
            //   );
            // }

            // if (state is TradeFailure) {
            //   // Navigator.of(context).pop(); // Don't pop on failure, let user retry
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       content: Text(state.message),
            //       backgroundColor: Colors.red,
            //       behavior: SnackBarBehavior.floating,
            //     ),
            //   );
            // }
          },
          buildWhen: (previous, current) => current is! TradeActionState,
          builder: (context, state) {
            return Column(
              children: [
                // const _HeaderSection(),
                Expanded(child: FcsChartContainer(symbol: widget.symbol)),
                BuySellSection(symbol: widget.symbol),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ======================
/// BUY / SELL BUTTONS
/// ======================
class BuySellSection extends StatelessWidget {
  final String symbol;

  const BuySellSection({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // 👈 less rounded
                ),
              ),
              onPressed: () {
                if (!isForexMarketOpen()) {
                  showMarketClosedPopup(context);
                  return;
                }

                context.read<TradeBloc>().add(TradeStarted(symbol: symbol));

                context.safeNavigate(() => showSellPopup(context, symbol: symbol));
              },
              child: const Text('SELL', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // 👈 less rounded
                ),
              ),

              onPressed: () {
                if (!isForexMarketOpen()) {
                  showMarketClosedPopup(context);
                  return;
                }

                context.read<TradeBloc>().add(TradeStarted(symbol: symbol));

                context.safeNavigate(() => showBuyPopup(context, symbol: symbol));
              },
              child: const Text('BUY', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

void _safePop(BuildContext context) {
  Future.delayed(const Duration(milliseconds: 100), () {
    if (context.mounted) {
      context.pop();
    }
  });
}
