import 'package:flutter/material.dart';

/// Reusable badge for role and status indicators.
/// Matches the pill badge style used in laporan_page.dart category chips.
class FtBadge extends StatelessWidget {
  final String label;
  final Color accentColor;
  final IconData? icon;

  const FtBadge({
    super.key,
    required this.label,
    required this.accentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: accentColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
