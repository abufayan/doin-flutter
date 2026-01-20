import 'package:doin_fx/views/trade/ui/widgets/step_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// LOT SIZE FIELD
class LotSizeField extends StatefulWidget {
  const LotSizeField({super.key});

  @override
  State<LotSizeField> createState() => _LotSizeFieldState();
}

class _LotSizeFieldState extends State<LotSizeField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '0.01');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _parse(String value) {
    final v = double.tryParse(value);
    return v == null || v <= 0 ? 0.01 : v;
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<double>(
      name: 'lot_size',
      initialValue: 0.01,
      validator: FormBuilderValidators.required(),
      builder: (field) {
        void updateValue(double v) {
          final fixed = v.toStringAsFixed(2);
          _controller.text = fixed;
          field.didChange(double.parse(fixed));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Volume',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
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
                  StepButton(
                    icon: Icons.remove,
                    onTap: () {
                      final current = _parse(_controller.text);
                      final next = (current - 0.01).clamp(0.01, double.infinity);
                      updateValue(next);
                    },
                  ),

                  /// Editable text field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      onChanged: (value) {
                        field.didChange(_parse(value));
                      },
                      onEditingComplete: () {
                        final fixed = _parse(_controller.text).toStringAsFixed(2);
                        _controller.text = fixed;
                        field.didChange(double.parse(fixed));
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),

                  StepButton(
                    icon: Icons.add,
                    onTap: () {
                      final current = _parse(_controller.text);
                      updateValue(current + 0.01);
                    },
                  ),
                ],
              ),
            ),
            if (field.errorText != null) ...[
              const SizedBox(height: 4),
              Text(
                field.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        );
      },
    );
  }
}