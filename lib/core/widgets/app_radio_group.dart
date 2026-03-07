import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppRadioGroup<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final String Function(T) itemLabelBuilder;
  final void Function(T) onSelected;

  const AppRadioGroup({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.itemLabelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((T item) {
        final isSelected = selectedItem == item;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            itemLabelBuilder(item),
            style: TextStyle(
              color: isSelected ? AppColors.green : AppColors.darkGray,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          leading: Radio<T>(
            value: item,
            groupValue: selectedItem,
            onChanged: (T? value) {
              if (value != null) onSelected(value);
            },
            activeColor: AppColors.green,
          ),
          onTap: () => onSelected(item),
        );
      }).toList(),
    );
  }
}
