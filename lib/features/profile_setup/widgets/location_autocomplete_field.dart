import 'dart:async';

import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/profile_setup/services/location_search_service.dart';
import 'package:flutter/material.dart';

class LocationAutocompleteField extends StatefulWidget {
  final String? initialValue;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;
  final IconData prefixIcon;

  const LocationAutocompleteField({
    super.key,
    this.initialValue,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.validator,
    this.prefixIcon = Icons.location_on_outlined,
  });

  @override
  State<LocationAutocompleteField> createState() => _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  late final TextEditingController _controller;
  final _formFieldKey = GlobalKey<FormFieldState<String>>();
  List<LocationSuggestion> _suggestions = [];
  bool _loading = false;
  bool _showSuggestions = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(LocationAutocompleteField old) {
    super.didUpdateWidget(old);
    // Sync controller when an external source (e.g. map picker) changes the value.
    if (widget.initialValue != old.initialValue &&
        widget.initialValue != null &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue!;
      _formFieldKey.currentState?.didChange(widget.initialValue);
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _formFieldKey.currentState?.didChange(value);
    widget.onChanged(value);
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _loading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(value.trim()));
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _showSuggestions = true;
    });
    try {
      final results = await LocationSearchService.search(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _select(LocationSuggestion suggestion) {
    _controller.text = suggestion.shortName;
    _formFieldKey.currentState?.didChange(suggestion.shortName);
    widget.onChanged(suggestion.shortName);
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _formFieldKey,
      initialValue: widget.initialValue ?? '',
      validator: widget.validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              onChanged: _onTextChanged,
              decoration: InputDecoration(
                labelText: widget.label.isEmpty ? null : widget.label,
                hintText: widget.hint,
                prefixIcon: Icon(widget.prefixIcon, size: 20, color: Colors.grey[600]),
                suffixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _controller.clear();
                              _formFieldKey.currentState?.didChange('');
                              widget.onChanged('');
                              setState(() {
                                _suggestions = [];
                                _showSuggestions = false;
                              });
                            },
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: field.hasError ? Colors.red : Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: field.hasError ? Colors.red : AppColors.green,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (_showSuggestions && (_loading || _suggestions.isNotEmpty))
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: _loading && _suggestions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text('Searching...', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[100]),
                        itemBuilder: (context, i) {
                          final s = _suggestions[i];
                          return InkWell(
                            onTap: () => _select(s),
                            borderRadius: i == 0
                                ? const BorderRadius.vertical(top: Radius.circular(12))
                                : i == _suggestions.length - 1
                                    ? const BorderRadius.vertical(bottom: Radius.circular(12))
                                    : BorderRadius.zero,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 16, color: AppColors.green),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.shortName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (s.displayName != s.shortName)
                                          Text(
                                            s.displayName,
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        );
      },
    );
  }
}
