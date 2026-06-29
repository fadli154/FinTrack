import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable section header that matches the typography pattern used in
/// home_page.dart and laporan_page.dart section titles.
class FtSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const FtSectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.tertiary,
          ),
        ),
        ?trailing,
      ],
    );
  }
}
