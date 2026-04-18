import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final String? initialValue;
  final int? maxLines;

  /// Hard cap enforced at the keyboard layer. Suppresses Flutter's built-in
  /// counter — use [showCounter] to re-enable a compact "n/max" display.
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCounter;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.initialValue,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.showCounter = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    Widget? resolvedSuffixIcon;
    if (widget.obscureText) {
      resolvedSuffixIcon = IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.deepEmerald.withValues(alpha: 0.3),
          size: 22,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    } else {
      resolvedSuffixIcon = widget.suffixIcon;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.deepEmerald.withValues(alpha: 0.4),
              letterSpacing: 1,
            ),
          ),
        ),
        TextFormField(
          initialValue: widget.initialValue,
          controller: widget.controller,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          style: const TextStyle(fontSize: 16, color: AppColors.deepEmerald, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            counterText: widget.showCounter ? null : '',
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.forestGreen, size: 20)
                : null,
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: AppColors.deepEmerald.withValues(alpha: 0.2),
              fontSize: 16,
            ),
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
              borderSide: const BorderSide(
                color: AppColors.alertRed,
                width: 1.5,
              ),
            ),
            suffixIcon: resolvedSuffixIcon,
          ),
        ),
      ],
    );
  }
}
