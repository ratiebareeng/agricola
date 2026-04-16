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
            style: const TextStyle(fontSize: 16, color: AppColors.deepEmerald, fontWeight: FontWeight.w600),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.deepEmerald.withValues(alpha: 0.2),
          fontSize: 16,
        ),
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: AppColors.forestGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: AppColors.alertRed, width: 1.5),
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.deepEmerald.withValues(alpha: 0.3)),
      dropdownColor: AppColors.white,
      borderRadius: BorderRadius.circular(24),
    );
  }
}
