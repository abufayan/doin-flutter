import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/datamodel/doposit_model.dart';
import 'package:flutter/material.dart';

class PaymentMethodCard extends StatelessWidget {
  final DepositMethodConfig method;

  const PaymentMethodCard({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (method.type == DepositMethodType.upi || method.type == DepositMethodType.usdtBep20) {
          context.router.push(DepositDetailRoute(config: method));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${method.title} method is not supported yet.')));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            // Icon box
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Image.asset(method.iconAsset, height: 36)),
            ),

            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  _info('Processing Time', method.processingTime),
                  _info('Fees', method.fees),
                  _info('Limit', method.limit),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text('$label: $value', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
    );
  }
}
