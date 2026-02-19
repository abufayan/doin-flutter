import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/views/orders/closed/list/screen/closed_orders_screen.dart';
import 'package:flutter/material.dart';

import 'open/screen/open_orders_list.dart';
import 'pending/list/screen/pending_orders_list.dart';

@RoutePage()
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            /// TABS - Using TabBar with TabController for swipe support
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 38, // 🔥 Reduce overall height
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFFFFA726),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,

                  // 🔥 Reduce font size slightly
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),

                  // 🔥 Reduce internal padding
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),

                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(height: 36, text: 'Open'),
                    Tab(height: 36, text: 'Pending'),
                    Tab(height: 36, text: 'Closed'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            // const Divider(height: 1),
            // const SizedBox(height: 20),

            /// CONTENT - Using TabBarView for swipe support
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  OpenTradeScreen(),
                  PendingOrdersScreen(),
                  ClosedOrdersScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
