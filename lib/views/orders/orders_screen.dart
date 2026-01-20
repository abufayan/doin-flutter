import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'open/screen/open_orders_screen.dart';


@RoutePage()
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            /// TABS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TabItem(
                    label: 'Open',
                    active: _activeIndex == 0,
                    onTap: () => setState(() => _activeIndex = 0),
                  ),
                  _TabItem(
                    label: 'Pending',
                    active: _activeIndex == 1,
                    onTap: () => setState(() => _activeIndex = 1),
                  ),
                  _TabItem(
                    label: 'Closed',
                    active: _activeIndex == 2,
                    onTap: () => setState(() => _activeIndex = 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),

            /// CONTENT
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeIndex) {
      case 0:
        return OpenTradeScreen();
      case 1:
        return const Center(child: Text('Pending Orders'));
      case 2:
        return const Center(child: Text('Closed Orders'));
      default:
        return const SizedBox();
    }
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? Colors.orange : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: active ? 24 : 0,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}



