import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppFilterChipGroup<T> extends StatelessWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabelBuilder;
  final void Function(T, bool) onSelected;
  final int? maxSelection;

  const AppFilterChipGroup({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.itemLabelBuilder,
    required this.onSelected,
    this.maxSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((T item) {
        final isSelected = selectedItems.contains(item);
        return FilterChip(
          label: Text(itemLabelBuilder(item)),
          selected: isSelected,
          onSelected: (bool selected) {
            if (selected && maxSelection != null && selectedItems.length >= maxSelection!) {
              return;
            }
            onSelected(item, selected);
          },
          selectedColor: AppColors.green.withAlpha(50),
          checkmarkColor: AppColors.green,
          backgroundColor: AppColors.lightGray.withAlpha(50),
          side: BorderSide(
            color: isSelected ? AppColors.green : Colors.transparent,
          ),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.green : AppColors.darkGray,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
