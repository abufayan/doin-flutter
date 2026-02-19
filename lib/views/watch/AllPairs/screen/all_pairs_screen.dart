import 'package:doin_fx/core/utils/symbol_icon_resolver.dart';
import 'package:doin_fx/datamodel/pair_response.dart';
import 'package:doin_fx/views/watch/AllPairs/bloc/all_pairs_bloc.dart';
import 'package:doin_fx/views/watch/FavouritePairs/bloc/favourites_bloc.dart';
import 'package:doin_fx/views/watch/FavouritePairs/bloc/favourites_state.dart';
import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllPairsScreen extends StatefulWidget {
  const AllPairsScreen({super.key});

  @override
  State<AllPairsScreen> createState() => _AllPairsScreenState();
}

class _AllPairsScreenState extends State<AllPairsScreen> {
  Set<String> _favouriteSymbols = <String>{};

  String _normalizeSymbol(String symbol) {
    return symbol.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AllPairsBloc>().add(AllPairsLoadEvent());
      context.read<FavouritesBloc>().add(
        LoadFavouritesEvent(showLoading: false),
      );
    });
  }

  List<PairItem>? _cachedPairs;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AllPairsBloc, AllPairsBlocState>(
          listenWhen: (pre, cur) => cur is AllPairsBlocActionState,
          listener: (context, state) {
            if (state is ErrorLoadingPairs) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is AllPairsFavouritesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is FavouritesAddedSuccessfully) {
              context.read<FavouritesBloc>().add(
                LoadFavouritesEvent(showLoading: false),
              );
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green, // Changed to green for success
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
        BlocListener<FavouritesBloc, FavouritesBlocState>(
          listener: (context, state) {
            if (state is FavouritesLoaded) {
              final symbols = state.originalFavourites
                  .map((item) => _normalizeSymbol(item.symbol))
                  .toSet();
              if (symbols.length != _favouriteSymbols.length ||
                  !symbols.containsAll(_favouriteSymbols)) {
                setState(() {
                  _favouriteSymbols = symbols;
                });
              }
            }
          },
        ),
      ],
      child: BlocBuilder<AllPairsBloc, AllPairsBlocState>(
        buildWhen: (pre, cur) => cur is! AllPairsBlocActionState,
        builder: (context, state) {
          // Cache pairs when loaded
          if (state is AllPairsLoaded) {
            _cachedPairs = state.pairs;
            return _buildPairsList(context, state.pairs, _favouriteSymbols);
          }

          // Show loading
          if (state is LoadingPairs) {
            return AppLoaders.listShimmer();
          }

          // Show error
          if (state is ErrorLoadingPairs) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // If we have cached pairs, show them (when in favourites state)
          if (_cachedPairs != null) {
            return _buildPairsList(context, _cachedPairs!, _favouriteSymbols);
          }

          // No data yet
          return const Center(child: Text('No data'));
        },
      ),
    );
  }

  Widget _buildPairsList(
    BuildContext context,
    List<PairItem> pairs,
    Set<String> favouriteSymbols,
  ) {
    // Group pairs by category
    final Map<String, List<PairItem>> categorizedPairs = {};

    // Add all pairs to "All Pairs" category
    categorizedPairs['All Pairs'] = pairs.where((p) => p.isActive).toList();

    // Group by other categories
    for (var pair in pairs) {
      if (!pair.isActive) continue;

      for (var category in pair.categories) {
        // Skip "All" category as we already have "All Pairs"
        if (category.toLowerCase() == 'all') continue;

        // Map category names to display names
        String displayCategory = _getDisplayCategoryName(category);

        if (!categorizedPairs.containsKey(displayCategory)) {
          categorizedPairs[displayCategory] = [];
        }

        // Add pair to category if not already added
        if (!categorizedPairs[displayCategory]!.contains(pair)) {
          categorizedPairs[displayCategory]!.add(pair);
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // 🔍 Search
          _SearchField(),

          const SizedBox(height: 16),

          // 📂 Categories
          Expanded(
            child: ListView(
              children: categorizedPairs.entries.map((entry) {
                return _CategoryTile(
                  title: entry.key,
                  icon:
                      _getCategoryIcon(category: entry.key) ??
                      Visibility(visible: false, child: Icon(Icons.category)),
                  pairs: entry.value,
                  favouriteSymbols: favouriteSymbols,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayCategoryName(String category) {
    // Map API category names to display names
    switch (category.toLowerCase()) {
      case 'populars':
        return 'Popular Pairs';
      case 'majors':
        return 'Majors';
      case 'minors':
        return 'Minors';
      case 'forex':
        return 'Forex';
      case 'metals':
        return 'Metals';
      case 'crypto':
        return 'Crypto';
      case 'indices':
        return 'Indices';
      case 'energy':
        return 'Energy';
      case 'stocks':
        return 'Stocks';
      default:
        return category;
    }
  }

  Widget? _getCategoryIcon({required String category}) {
    switch (category) {
      case 'Popular Pairs':
        return buildAllPairsIcons(asset: 'popular_pairs');
      case 'Majors':
        return buildAllPairsIcons(asset: 'majors');
      case 'Minors':
        return buildAllPairsIcons(asset: 'minors');
      case 'Forex':
        return buildAllPairsIcons(asset: 'forex');
      case 'Metals':
        return buildAllPairsIcons(asset: 'metals');
      case 'Crypto':
        return buildAllPairsIcons(asset: 'bitcoin');
      case 'Indices':
        return buildAllPairsIcons(asset: 'indices');
      case 'Energy':
        return buildAllPairsIcons(asset: 'energy');
      case 'Stocks':
        return buildAllPairsIcons(asset: 'stocks');
      case 'All Pairs':
        return Visibility(
          visible: false,
          child: buildAllPairsIcons(asset: 'popular_pairs'),
        );
      default:
        return Visibility(
          visible: false,
          child: buildAllPairsIcons(asset: 'popular_pairs'),
        );
    }
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        context.read<AllPairsBloc>().add(AllPairsSearchEvent(value));
      },
      decoration: InputDecoration(
        hintText: 'Search Instrument',
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final Widget icon;
  final List<PairItem> pairs;
  final Set<String> favouriteSymbols;

  const _CategoryTile({
    required this.title,
    required this.icon,
    required this.pairs,
    required this.favouriteSymbols,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // 🔥 removes the line
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: icon,
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          children: pairs.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'No instruments available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ]
              : pairs
                    .map(
                      (pair) => _PairItemTile(
                        pair: pair,
                        isFavourite: favouriteSymbols.contains(
                          pair.symbol.toLowerCase().replaceAll(
                            RegExp(r'[^a-z0-9]'),
                            '',
                          ),
                        ),
                      ),
                    )
                    .toList(),
        ),
      ),
    );
  }
}

class _PairItemTile extends StatelessWidget {
  final PairItem pair;
  final bool isFavourite;

  const _PairItemTile({required this.pair, required this.isFavourite});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: buildSymbolIcon(pair.symbol, size: 35),
      title: Text(
        pair.symbol.replaceAll('/', ''),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      // subtitle: Text('Spread: ${pair.spread}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // ← this is important
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 85.0),
            child: GestureDetector(
              onTap: () {
                if (isFavourite) {
                  return;
                }
                context.read<AllPairsBloc>().add(
                  AddToFavouriteEvent(pair: pair),
                );
              },
              child: SizedBox(
                width: 40,
                height: 40,
                // decoration: BoxDecoration(
                //   color: const Color(0xFFFFF3E0), // soft orange background
                //   borderRadius: BorderRadius.circular(12),
                // ),
                child: Icon(
                  isFavourite ? Icons.star : Icons.star_border,
                  color: const Color(0xFFFFA726), // soft orange star
                  size: 22,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //   decoration: BoxDecoration(
          //     color: pair.isActive ? Colors.green.shade100 : Colors.grey.shade200,
          //     borderRadius: BorderRadius.circular(4),
          //   ),
          //   child: Text(
          //     pair.isActive ? 'Active' : 'Inactive',
          //     style: TextStyle(
          //       fontSize: 10,
          //       color: pair.isActive ? Colors.green.shade700 : Colors.grey.shade700,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
