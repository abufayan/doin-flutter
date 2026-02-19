import 'package:flutter/material.dart';

class AddFundField extends StatefulWidget {
  final void Function(String amount) onAddFund;

  const AddFundField({super.key, required this.onAddFund});

  @override
  State<AddFundField> createState() => _AddFundFieldState();
}

class _AddFundFieldState extends State<AddFundField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          /// 🔹 TextField
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  border: InputBorder.none,
                  isCollapsed: true,
                  focusColor: Colors.white,
                ),
              ),
            ),
          ),

          /// 🔹 Add Fund Button
          InkWell(
            onTap: () {
              final amount = _controller.text.trim();

              if (amount.isEmpty) return;

              FocusScope.of(context).unfocus();

              widget.onAddFund(amount);

              // Optional: clear after submit
              _controller.clear();
            },
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Add Fund',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
