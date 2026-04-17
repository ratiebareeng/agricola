import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A Digital-Earth styled dropdown field that opens a modal bottom sheet
/// instead of a native overlay. Provides a clear close affordance (X icon
/// at the top of the sheet) and supports tap-outside / swipe-down dismissal.
///
/// Integrates with [Form] for validation — pass a [validator] like any
/// [FormField]-based widget.
class AppDropdownField<T> extends FormField<T> {
  AppDropdownField({
    super.key,
    required List<T> items,
    required String Function(T) itemLabelBuilder,
    T? value,
    String? hint,
    Widget? prefixIcon,
    void Function(T?)? onChanged,
    super.validator,
    String? sheetTitle,
    super.autovalidateMode,
  }) : super(
          initialValue: value,
          builder: (FormFieldState<T> state) {
            // Use the widget's current value for display; sync FormField state
            // so validation reflects the external selection.
            if (state.value != value) {
              Future.microtask(() {
                if (state.mounted) state.didChange(value);
              });
            }

            final displayLabel = value != null ? itemLabelBuilder(value as T) : null;
            final hasError = state.hasError;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final selected = await showModalBottomSheet<T>(
                  context: state.context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => _AppDropdownSheet<T>(
                    items: items,
                    itemLabelBuilder: itemLabelBuilder,
                    selectedValue: value,
                    title: sheetTitle,
                  ),
                );
                if (selected != null) {
                  state.didChange(selected);
                  onChanged?.call(selected);
                }
              },
              child: InputDecorator(
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
                    borderSide:
                        const BorderSide(color: AppColors.forestGreen, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide:
                        const BorderSide(color: AppColors.alertRed, width: 1.5),
                  ),
                  errorText: hasError ? state.errorText : null,
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.deepEmerald.withValues(alpha: 0.3),
                  ),
                ),
                isEmpty: displayLabel == null,
                child: Text(
                  displayLabel ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.deepEmerald,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        );
}

class _AppDropdownSheet<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final T? selectedValue;
  final String? title;

  const _AppDropdownSheet({
    super.key,
    required this.items,
    required this.itemLabelBuilder,
    this.selectedValue,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.deepEmerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      title ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepEmerald,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.deepEmerald.withValues(alpha: 0.4),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: AppColors.deepEmerald.withValues(alpha: 0.06),
            ),
            // Item list
            Flexible(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 24,
                  endIndent: 24,
                  color: AppColors.deepEmerald.withValues(alpha: 0.05),
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final label = itemLabelBuilder(item);
                  final isSelected = item == selectedValue;
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    title: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.forestGreen
                            : AppColors.deepEmerald,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check,
                            color: AppColors.forestGreen, size: 20)
                        : null,
                    onTap: () => Navigator.pop(context, item),
                  );
                },
              ),
            ),
            // Bottom safe-area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
