import 'package:doin_fx/datamodel/pair_response.dart';
import 'package:doin_fx/views/watch/AllPairs/bloc/all_pairs_bloc.dart';
import 'package:doin_fx/views/watch/FavouritePairs/bloc/favourites_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllPairsScreen extends StatefulWidget {
  const AllPairsScreen({super.key});

  @override
  State<AllPairsScreen> createState() => _AllPairsScreenState();
}

class _AllPairsScreenState extends State<AllPairsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AllPairsBloc>().add(AllPairsLoadEvent());
    });
  }

  // List<PairItem>? _cachedPairs;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AllPairsBloc, AllPairsBlocState>(
      listenWhen: (pre, cur) => cur is AllPairsBlocActionState,
      // Only listen for errors from the all-pairs load
      // listenWhen: (previous, current) => current is AllPairsBlocActionState,

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
        if (state is FavouritesAddedSuccessfully) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<AllPairsBloc, AllPairsBlocState>(
        buildWhen: (pre, cur) => cur is! AllPairsBlocActionState  ,
        builder: (context, state) {
          // Cache pairs when loaded
          if (state is AllPairsLoaded) {
            // _cachedPairs = state.pairs;
            return _buildPairsList(context, state.pairs);
          }

          // Show loading
          if (state is LoadingPairs) {
            return const Center(child: CircularProgressIndicator());
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
          // if (_cachedPairs != null) {
          //   return _buildPairsList(context, _cachedPairs!);
          // }

          // No data yet
          return const Center(child: Text('No data'));
        },
      ),
    );
  }

  Widget _buildPairsList(BuildContext context, List<PairItem> pairs) {
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
                  icon: _getCategoryIcon(entry.key),
                  pairs: entry.value,
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Popular Pairs':
        return Icons.star;
      case 'Majors':
        return Icons.bar_chart;
      case 'Minors':
        return Icons.show_chart;
      case 'Forex':
        return Icons.currency_exchange;
      case 'Metals':
        return Icons.diamond;
      case 'Crypto':
        return Icons.currency_bitcoin;
      case 'Indices':
        return Icons.trending_up;
      case 'Energy':
        return Icons.local_gas_station;
      case 'Stocks':
        return Icons.business;
      case 'All Pairs':
        return Icons.list;
      default:
        return Icons.category;
    }
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
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
  final IconData icon;
  final List<PairItem> pairs;

  const _CategoryTile({
    required this.title,
    required this.icon,
    required this.pairs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(icon, size: 20),
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
            : pairs.map((pair) => _PairItemTile(pair: pair)).toList(),
      ),
    );
  }
}

class _PairItemTile extends StatelessWidget {
  final PairItem pair;

  const _PairItemTile({required this.pair});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        pair.symbol,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'Spread: ${pair.spread}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // ← this is important
        children: [
          GestureDetector(
            onTap: () {
              context.read<AllPairsBloc>().add(AddToFavouriteEvent(pair: pair));
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.favorite, color: Colors.red, size: 20),
            ),
          ),
          SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: pair.isActive
                  ? Colors.green.shade100
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              pair.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 10,
                color: pair.isActive
                    ? Colors.green.shade700
                    : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
