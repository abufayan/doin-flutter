import 'package:auto_route/annotations.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

@RoutePage()
class TicketCreateScreen extends StatefulWidget {
  const TicketCreateScreen({super.key});

  @override
  State<TicketCreateScreen> createState() => _TicketCreateScreenState();
}

class _TicketCreateScreenState extends State<TicketCreateScreen> {
  final TextEditingController descriptionCtrl = TextEditingController();

  @override
  void dispose() {
    descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Help Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== HEADER =====
            const Text(
              'Kindly Provide\nDetails',
              style: TextStyle(
                fontSize: 32, // exact large header feel
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 16),

            /// ===== INFO BOX =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.orange,
                ),
              ),
              child: const Text(
                'Please fill out the form, and our support team will review your request. '
                    'We’ll get back to you shortly. Submitting this form helps us resolve '
                    'your concerns faster and ensures you receive the assistance you need.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ===== DESCRIPTION =====
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: descriptionCtrl,
                    maxLines: 6,
                    maxLength: 5000,
                    decoration: const InputDecoration(
                      hintText:
                      'Kindly provide more information on your request.',
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${descriptionCtrl.text.length} / 5000',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ===== DROPZONE =====
            DottedBorder(
              color: Colors.orange,
              strokeWidth: 1.5,
              dashPattern: const [6, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// plus button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Provide files in JPG or PDF format,\nmaximum size 10 MB.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// ===== CONFIRM BUTTON =====
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
                onPressed: () {
                  // submit
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

            const SizedBox(height: 12),

            /// ===== BACK BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE8D2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
