import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:flutter/material.dart';

@RoutePage()
class TicketTypeScreen extends StatefulWidget {
  const TicketTypeScreen({super.key});

  @override
  State<TicketTypeScreen> createState() => _OpenTicketScreenState();
}

class _OpenTicketScreenState extends State<TicketTypeScreen> {
  String? selectedType;

  final ticketTypes = const [
    (label: 'Deposit', icon: Icons.account_balance_wallet, asset: 'deposit'),
    (
      label: 'Withdrawal',
      icon: Icons.currency_exchange,
      asset: 'moneyWithdrawl',
    ),
    (label: 'Referrals', icon: Icons.group, asset: 'employee'),
    (label: 'Trades', icon: Icons.show_chart, asset: 'trading'),
    (label: 'KYC', icon: Icons.verified_user, asset: 'searching'),
    (label: 'Others', icon: Icons.more_horiz, asset: 'more'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Help Center'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Kindly select the topic of your inquiry so we can assist you better.',
              style: TextStyle(fontSize: 17, color: Colors.black87),
            ),

            const SizedBox(height: 24),

            /// Ticket Type
            RichText(
              text: const TextSpan(
                text: 'Ticket Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// Ticket options
            ...ticketTypes.map(
              (e) => _ticketOption(
                label: e.label,
                icon: e.icon,
                assetPath: e.asset,
              ),
            ),

            const Spacer(),

            /// Confirm button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: selectedType == null
                    ? null
                    : () {
                        context.router.push(TicketCreateRoute());
                      },
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Ticket Option Tile ----------------

  Widget _ticketOption({
    required String label,
    required IconData icon,
    required String assetPath,
  }) {
    final isSelected = selectedType == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/ticketTypes/$assetPath.png',
              width: 22,
              height: 22,
              errorBuilder: (_, __, ___) => Icon(icon, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.orange : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
