import 'package:flutter/material.dart';

/// Reusable search bar that matches the FinTrack input field aesthetic —
/// filled, no border, rounded corners, matching colors.secondary fill.
class FtSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const FtSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: colors.tertiary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: colors.tertiary.withValues(alpha: .45),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: colors.tertiary.withValues(alpha: .45),
        ),
        filled: true,
        fillColor: colors.secondary.withAlpha(80),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colors.tertiary.withValues(alpha: .1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colors.tertiary.withValues(alpha: .1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.surface, width: 1.5),
        ),
      ),
    );
  }
}
