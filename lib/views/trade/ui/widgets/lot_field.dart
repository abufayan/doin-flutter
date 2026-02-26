import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// LOT SIZE FIELD
class LotSizeField extends StatefulWidget {
  final ValueChanged<double?>? onChanged;
  final double initialLot;
  final double minLot;

  const LotSizeField({super.key, required this.initialLot, required this.minLot, this.onChanged});

  @override
  State<LotSizeField> createState() => _LotSizeFieldState();
}

class _LotSizeFieldState extends State<LotSizeField> {
  late TextEditingController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLot.toStringAsFixed(2));

    // Delay initial sync and send initial value to Bloc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialized = true;
      // Send current field value to Bloc (in case FormBuilder restored a different value)
      final currentValue = double.tryParse(_controller.text) ?? widget.minLot;
      widget.onChanged?.call(currentValue);
    });
  }

  @override
  void didUpdateWidget(covariant LotSizeField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialLot != widget.initialLot) {
      _controller.text = widget.initialLot.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _parse(String value) {
    final v = double.tryParse(value);
    if (v == null) return widget.minLot;
    return v.clamp(widget.minLot, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<double>(
      name: 'lot_size',
      initialValue: widget.initialLot,
      builder: (field) {
        void updateValue(double v) {
          final fixed = v.toStringAsFixed(2);
          _controller.text = fixed;
          final parsed = double.parse(fixed);

          field.didChange(parsed);
          widget.onChanged?.call(parsed); // 🔥 THIS
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Volume'),
            const SizedBox(height: 6),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      final current = _parse(_controller.text);
                      updateValue((current - 0.01).clamp(widget.minLot, double.infinity));
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(border: InputBorder.none),
                      onChanged: (value) {
                        if (!_initialized) return;
                        // Send actual typed value to Bloc (don't clamp here)
                        // so button can disable for invalid values
                        final parsed = double.tryParse(value);
                        field.didChange(parsed);
                        widget.onChanged?.call(parsed); // null when empty
                      },
                      onEditingComplete: () {
                        // When user finishes editing, enforce minimum and update display
                        final parsed = _parse(_controller.text);
                        updateValue(parsed);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final current = _parse(_controller.text);
                      updateValue(current + 0.01);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
