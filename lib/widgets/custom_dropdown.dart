import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selectedItem;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  final bool showSearchBox;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    this.validator,
    this.showSearchBox = false,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure selectedItem is in the items list, otherwise set to null
    final validSelectedItem = items.contains(selectedItem) ? selectedItem : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
        ),
        initialValue: validSelectedItem,
        isExpanded: true,
        items: items.toSet().toList().map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
