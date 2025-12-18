import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? initialValue;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 16, color: AppColors.darkGray),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.mediumGray.withAlpha(70),
              fontSize: 16,
            ),
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
              borderSide: const BorderSide(
                color: AppColors.alertRed,
                width: 1.5,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
