import 'package:flutter/material.dart';

/// Search bar widget
class SearchBarWidget extends StatefulWidget {
  final String? hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClearButton;

  const SearchBarWidget({
    super.key,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.onClear,
    this.showClearButton = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the controller if the new initialValue is different from
    // the current controller text. This prevents overwriting user input when
    // the parent rebuilds after onChanged is called.
    if (widget.initialValue != oldWidget.initialValue) {
      final newValue = widget.initialValue ?? '';
      if (_controller.text != newValue) {
        final selection = _controller.selection;
        _controller.text = newValue;
        // Preserve cursor position if it was valid, otherwise place at end
        if (selection.isValid && selection.end <= newValue.length) {
          _controller.selection = selection;
        } else {
          _controller.selection = TextSelection.collapsed(offset: newValue.length);
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search books, authors, subjects...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: widget.showClearButton
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: widget.onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}

