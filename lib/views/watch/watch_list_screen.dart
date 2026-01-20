import 'package:doin_fx/views/watch/FavouritePairs/bloc/favourites_bloc.dart';
import 'package:doin_fx/views/watch/AllPairs/screen/all_pairs_screen.dart';
import 'package:doin_fx/views/watch/FavouritePairs/screen/favourites_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WatchListScreen extends StatefulWidget {
  const WatchListScreen({super.key});

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Favourites'),
                Tab(text: 'ALL'),
              ],
            ),
          ),
        ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FavouritesScreen(),
          AllPairsScreen(),
        ],
      ),
    );
  }
}
