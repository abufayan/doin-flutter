import 'package:doin_fx/core/utils/symbol_icon_resolver.dart';
import 'package:doin_fx/datamodel/pair_response.dart';
import 'package:doin_fx/views/home/bloc/home_bloc.dart';
import 'package:doin_fx/views/home/bloc/home_event.dart';
import 'package:doin_fx/views/orders/helper/show_snackbar.dart';
import 'package:doin_fx/views/trade/bloc/trade_event.dart';
import 'package:doin_fx/views/trade/helper.dart';
import 'package:doin_fx/views/watch/FavouritePairs/bloc/favourites_bloc.dart';
import 'package:doin_fx/views/watch/FavouritePairs/bloc/favourites_state.dart';
import 'package:doin_fx/views/trade/bloc/trade_bloc.dart';
import 'package:doin_fx/views/trade/bloc/trade_state.dart';
import 'package:doin_fx/views/trade/ui/widgets/buy_popup.dart';
import 'package:doin_fx/views/trade/ui/widgets/sell_popup.dart';
import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:doin_fx/core/utils/nav_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavouritesBloc>().add(LoadFavouritesEvent());
    });
  }

  Future<void> _refreshFavourites() async {
    context.read<FavouritesBloc>().add(LoadFavouritesEvent());
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TradeBloc, TradeState>(
      listener: (c, s) {},
      child: BlocConsumer<FavouritesBloc, FavouritesBlocState>(
        listener: (BuildContext context, FavouritesBlocState state) {
          if (state is SuccessfulllyRemovedFromFavourites) {
            showSnackbar(context, state.message, success: true);
            context.read<FavouritesBloc>().add(LoadFavouritesEvent(showLoading: false));
          }
        },
        buildWhen: (previous, current) =>
            current is FavouritesLoading || current is FavouritesLoaded || current is FavouritesError,
        builder: (context, state) {
          if (state is FavouritesLoading) {
            return AppLoaders.listShimmer();
          }

          if (state is FavouritesError) {
            return _FavouritesError(message: state.message, onRetry: _refreshFavourites);
          }

          if (state is FavouritesLoaded) {
            if (state.favourites.isEmpty) {
              return _FavouritesEmpty(refresh: _refreshFavourites);
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    onChanged: (value) {
                      context.read<FavouritesBloc>().add(FavouritesSearchEvent(value));
                    },
                    decoration: InputDecoration(
                      hintText: 'Search Favourites',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshFavourites,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.favourites.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return _FavouriteRow(item: state.favourites[index]);
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return _FavouritesEmpty(refresh: _refreshFavourites);
        },
      ),
    );
  }
}

class _FavouriteRow extends StatefulWidget {
  final FavouriteItem item;

  const _FavouriteRow({required this.item});

  @override
  State<_FavouriteRow> createState() => _FavouriteRowState();
}

class _FavouriteRowState extends State<_FavouriteRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // FLAG / ICON
                // CircleAvatar(
                //   radius: 16,
                //   backgroundColor: Colors.grey.shade200,
                //   child: Text(
                //     widget.item.symbol.substring(0, 2),
                //     style: const TextStyle(
                //       fontWeight: FontWeight.bold,
                //       fontSize: 11,
                //     ),
                //   ),
                // ),
                buildSymbolIcon(widget.item.symbol, size: 35),
                const SizedBox(width: 10),

                // SYMBOL + META
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.symbol, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      // Row(
                      //   children: [
                      //     const Text(
                      //       '+0.53%',
                      //       style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                      //     ),
                      //     const SizedBox(width: 8),
                      //     Text('1.5', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      //   ],
                      // ),
                    ],
                  ),
                ),

                Visibility(
                  visible: _expanded,
                  child: Row(
                    children: [
                      _ActionButton(
                        label: 'B',
                        color: Colors.green,
                        symbol: widget.item.symbol,
                        onTap: () {
                          if (!isForexMarketOpen()) {
                            showMarketClosedPopup(context);
                            return;
                          }

                          final tradeBloc = context.read<TradeBloc>();
                          tradeBloc.add(TradeStarted(symbol: widget.item.symbol));

                          context.safeNavigate(() => showBuyPopup(context, symbol: widget.item.symbol));
                        },
                      ),
                      const SizedBox(width: 6),
                      _ActionButton(
                        label: 'S',
                        color: Colors.red,
                        symbol: widget.item.symbol,
                        onTap: () {
                          if (!isForexMarketOpen()) {
                            showMarketClosedPopup(context);
                            return;
                          }

                          final tradeBloc = context.read<TradeBloc>();
                          tradeBloc.add(TradeStarted(symbol: widget.item.symbol));

                          context.safeNavigate(() => showSellPopup(context, symbol: widget.item.symbol));
                        },
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          context.safeNavigate(() {
                            context.read<HomeBloc>().add(SelectTradeSymbol(widget.item.symbol));
                          });
                        },
                        icon: Image.asset('assets/images/favouriteRowIcons/statistic.png'),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Image.asset('assets/images/favouriteRowIcons/remove.png'),
                        color: Colors.grey.shade700,
                        onPressed: () {
                          context.read<FavouritesBloc>().add(RemoveFromFavourites(symbol: widget.item.symbol));
                        },
                      ),
                    ],
                  ),
                ),

                // PRICE + TRAILING AREA
                Visibility(
                  visible: !_expanded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 25.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text('CMP -> '),
                            Text(
                              '${widget.item.cmp}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          children: [
                            const TextSpan(
                              text: 'L: ',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                            ),
                            TextSpan(text: widget.item.low.toStringAsFixed(5)),
                            const TextSpan(text: '   '),
                            const TextSpan(
                              text: 'H: ',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
                            ),
                            TextSpan(text: widget.item.high.toStringAsFixed(5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final String symbol;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.color, required this.symbol, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

class _FavouritesEmpty extends StatelessWidget {
  final RefreshCallback refresh;

  const _FavouritesEmpty({required this.refresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('No favourite pairs yet', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavouritesError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _FavouritesError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
