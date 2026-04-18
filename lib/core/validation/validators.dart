import 'package:agricola/core/validation/field_limits.dart';
import 'package:flutter/services.dart';

/// Reusable form validators. Pair with `AppTextField(inputFormatters:)` caps.
///
/// Error strings are plain English for now; swap to translation keys once the
/// validation-specific keys are added to agricola_core.

// --- Input formatters -------------------------------------------------------

/// Digits only, capped at [kBotswanaPhoneLength].
final List<TextInputFormatter> botswanaPhoneFormatters = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(kBotswanaPhoneLength),
];

/// Integer quantities (e.g. kg as whole numbers where appropriate).
final List<TextInputFormatter> integerQuantityFormatters = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(kMaxQuantityDigits),
];

/// Decimal quantities / prices — digits with optional single decimal point,
/// max two fractional digits.
List<TextInputFormatter> decimalFormatters({int maxDigits = kMaxUnitPriceDigits}) => [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  _SingleDecimalFormatter(),
  LengthLimitingTextInputFormatter(maxDigits + 1), // + 1 for the dot
];

/// Fixed character cap for plain text.
List<TextInputFormatter> textLengthFormatters(int maxLength) => [
  LengthLimitingTextInputFormatter(maxLength),
];

class _SingleDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final firstDot = text.indexOf('.');
    if (firstDot == -1) return newValue;
    final extraDot = text.indexOf('.', firstDot + 1);
    if (extraDot != -1) return oldValue;
    final fractional = text.substring(firstDot + 1);
    if (fractional.length > 2) return oldValue;
    return newValue;
  }
}

// --- Validators -------------------------------------------------------------

/// Botswana mobile: 8 digits, starts with 7.
String? validateBotswanaPhone(String? value, {bool required = false}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return required ? 'Phone number is required' : null;
  if (trimmed.length != kBotswanaPhoneLength) {
    return 'Phone must be $kBotswanaPhoneLength digits';
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
    return 'Phone must contain digits only';
  }
  if (!trimmed.startsWith('7')) {
    return 'Botswana mobile numbers start with 7';
  }
  return null;
}

String? validateRequired(String? value, {String fieldLabel = 'This field'}) {
  if (value == null || value.trim().isEmpty) return '$fieldLabel is required';
  return null;
}

String? validateMaxLength(String? value, int max, {String fieldLabel = 'Value'}) {
  if (value == null) return null;
  if (value.length > max) return '$fieldLabel must be $max characters or fewer';
  return null;
}

/// Positive, finite quantity ≤ [kMaxQuantity].
String? validatePositiveQuantity(String? value, {bool required = true}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return required ? 'Quantity is required' : null;
  final parsed = double.tryParse(trimmed);
  if (parsed == null || !parsed.isFinite) return 'Enter a valid number';
  if (parsed <= 0) return 'Must be greater than 0';
  if (parsed > kMaxQuantity) {
    return 'Must be ${kMaxQuantity.toStringAsFixed(0)} or less';
  }
  return null;
}

/// Non-negative, finite price ≤ [kMaxUnitPrice].
/// Set [allowZero] = false for "must be > 0" contexts (purchase price, offer).
String? validatePrice(
  String? value, {
  bool required = true,
  bool allowZero = true,
  double max = kMaxUnitPrice,
}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return required ? 'Price is required' : null;
  final parsed = double.tryParse(trimmed);
  if (parsed == null || !parsed.isFinite) return 'Enter a valid price';
  if (allowZero ? parsed < 0 : parsed <= 0) {
    return allowZero ? 'Price cannot be negative' : 'Must be greater than 0';
  }
  if (parsed > max) return 'Must be ${max.toStringAsFixed(0)} or less';
  return null;
}

/// Loss/shrinkage percentages and amounts — non-negative, finite, capped.
String? validateLossAmount(String? value, {bool required = false}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return required ? 'Required' : null;
  final parsed = double.tryParse(trimmed);
  if (parsed == null || !parsed.isFinite) return 'Enter a valid number';
  if (parsed < 0) return 'Cannot be negative';
  if (parsed > kMaxQuantity) {
    return 'Must be ${kMaxQuantity.toStringAsFixed(0)} or less';
  }
  return null;
}

String? validateEmail(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Email is required';
  if (trimmed.length > kMaxEmail) return 'Email is too long';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < kMinPassword) {
    return 'Password must be at least $kMinPassword characters';
  }
  if (value.length > kMaxPassword) {
    return 'Password must be $kMaxPassword characters or fewer';
  }
  return null;
}
