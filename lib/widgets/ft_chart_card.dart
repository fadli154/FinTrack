import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable chart container card.
/// Wraps any chart widget with a titled card, matching the FinTrack design system.
class FtChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget chart;
  final double height;
  final List<FtLegendItem>? legend;

  const FtChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.subtitle,
    this.height = 220,
    this.legend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.secondary.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.tertiary.withValues(alpha: .1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.tertiary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.tertiary.withValues(alpha: .55),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ─── Chart body ───────────────────────────────────────────────
          SizedBox(height: height, child: chart),

          // ─── Legend ───────────────────────────────────────────────────
          if (legend != null && legend!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: legend!
                  .map((item) => _buildLegendChip(context, item))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendChip(BuildContext context, FtLegendItem item) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 11,
            color: colors.tertiary.withValues(alpha: .7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class FtLegendItem {
  final String label;
  final Color color;
  const FtLegendItem(this.label, this.color);
}

/// Factory helper to create legend items cleanly.
class FtChartLegend {
  static FtLegendItem item(String label, Color color) =>
      FtLegendItem(label, color);
}
