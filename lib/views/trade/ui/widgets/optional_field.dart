import 'package:doin_fx/views/trade/ui/widgets/step_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// OPTIONAL PRICE FIELD
class OptionalPriceField extends StatefulWidget {
  final String _name;
  final String _label;

  const OptionalPriceField(this._name, this._label, {super.key});

  @override
  State<OptionalPriceField> createState() => _OptionalPriceFieldState();
}

class _OptionalPriceFieldState extends State<OptionalPriceField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<String>(
      name: widget._name,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.numeric(),
        FormBuilderValidators.min(0),
      ]),
      builder: (field) {
        // Sync controller with field value
        if (_controller.text != field.value) {
          _controller.text = field.value ?? '';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget._label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: '0.00',
                      ),
                      onChanged: field.didChange,
                    ),
                  ),
                  StepButton(
                    icon: Icons.remove,
                    onTap: () {
                      final current = double.tryParse(field.value ?? '') ?? 0;
                      final v = (current - 0.1).clamp(0, double.infinity);
                      field.didChange(v.toStringAsFixed(2));
                    },
                  ),
                  const SizedBox(width: 6),
                  StepButton(
                    icon: Icons.add,
                    onTap: () {
                      final current = double.tryParse(field.value ?? '') ?? 0;
                      final v = current + 0.1;
                      field.didChange(v.toStringAsFixed(2));
                    },
                  ),
                ],
              ),
            ),
            if (field.errorText != null) ...[
              const SizedBox(height: 4),
              Text(field.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ],
        );
      },
    );
  }
}

