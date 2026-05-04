import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExpenseInputField extends StatelessWidget {
  const ExpenseInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.autoFocus = false,
    this.keyboardType,
    this.inputFormatters,
    this.focusNode,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool autoFocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autoFocus,
          keyboardType: keyboardType ?? TextInputType.number,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
          ),
        ),
      ],
    );
  }
}
