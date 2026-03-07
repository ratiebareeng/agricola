import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String? hint;
  final void Function(T?)? onChanged;
  final String Function(T) itemLabelBuilder;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;

  const AppDropdownField({
    super.key,
    required this.items,
    required this.itemLabelBuilder,
    this.value,
    this.hint,
    this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabelBuilder(item),
            style: const TextStyle(fontSize: 16, color: AppColors.darkGray),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.mediumGray.withAlpha(70),
          fontSize: 16,
        ),
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: AppColors.lightGray.withAlpha(30),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGray.withAlpha(50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.alertRed, width: 1.5),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.mediumGray),
      dropdownColor: AppColors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
