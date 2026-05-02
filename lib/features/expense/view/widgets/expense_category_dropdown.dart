import 'package:flutter/material.dart';

class ExpenseCategoryDropdown extends StatelessWidget {
  const ExpenseCategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  final String selectedCategory;
  final ValueChanged<String?> onChanged;

  static const _categories = ['Food', 'Travel', 'Bills', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          items: _categories
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
