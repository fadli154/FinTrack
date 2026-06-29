import 'package:fintrack/controllers/admin_controller.dart';
import 'package:fintrack/widgets/ft_badge.dart';
import 'package:fintrack/widgets/ft_section_header.dart';
import 'package:fintrack/widgets/ft_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();
    final colors = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(
      locale: Get.locale?.languageCode ?? 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Obx(() {
      if (ctrl.statsLoading.value && ctrl.usersLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: colors.surface),
        );
      }

      return RefreshIndicator(
        color: colors.surface,
        onRefresh: ctrl.loadStats,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            // ─── Page header ──────────────────────────────────────────────
            Text(
              'admin_dashboard'.tr,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                // heading: inverseSurface, matching section titles across user app
                color: colors.tertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'admin_dashboard_sub'.tr,
              style: TextStyle(
                // body/caption: tertiary with alpha — same as home_page subtitles
                color: colors.tertiary.withValues(alpha: .55),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 24),

            // ─── User stats ───────────────────────────────────────────────
            FtSectionHeader(title: 'admin_users'.tr),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FtStatCard(
                    label: 'total_users'.tr,
                    value: ctrl.totalUsers.value.toString(),
                    icon: Icons.people_outline_rounded,
                    accentColor: colors.surface, // teal
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FtStatCard(
                    label: 'active_users'.tr,
                    value: ctrl.activeUsers.value.toString(),
                    icon: Icons.check_circle_outline_rounded,
                    accentColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FtStatCard(
                    label: 'disabled_users'.tr,
                    value: ctrl.disabledUsers.value.toString(),
                    icon: Icons.block_outlined,
                    accentColor: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Transaction stats ────────────────────────────────────────
            FtSectionHeader(title: 'admin_transactions'.tr),
            const SizedBox(height: 12),

            // Big total card — matches _summaryCard from laporan_page style
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Use surface (teal) at low alpha to match user summary cards
                color: colors.surface.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: colors.surface,
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ctrl.totalTransactions.value.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.surface,
                        ),
                      ),
                      Text(
                        'total_transactions'.tr,
                        style: TextStyle(
                          color: colors.tertiary.withValues(alpha: .65),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FtStatCard(
                    label: 'income'.tr,
                    value: currency.format(ctrl.totalIncome.value),
                    icon: Icons.arrow_downward_rounded,
                    accentColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FtStatCard(
                    label: 'expense'.tr,
                    value: currency.format(ctrl.totalExpense.value),
                    icon: Icons.arrow_upward_rounded,
                    accentColor: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Recent users ──────────────────────────────────────────────
            FtSectionHeader(
              title: 'recent_users'.tr,
              trailing: TextButton(
                onPressed: () {},
                child: Text(
                  'view_all'.tr,
                  style: TextStyle(color: colors.surface),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Recent user tiles — match home_page transaction item pattern
            ...ctrl.users.take(5).map(
                  (user) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      // Match transaction card style from home_page
                      color: colors.secondary.withAlpha(50),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colors.tertiary.withValues(alpha: .1),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: user.isAdmin
                              ? Colors.amber.withValues(alpha: .2)
                              : colors.surface.withValues(alpha: .15),
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: user.isAdmin
                                  ? Colors.amber.shade700
                                  : colors.surface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  // title: uses tertiary matching home_page category text
                                  color: colors.tertiary,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  // caption: tertiary with lower alpha
                                  color: colors.tertiary.withValues(alpha: .55),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        FtBadge(
                          label: user.isAdmin
                              ? 'role_admin'.tr
                              : 'role_user'.tr,
                          accentColor: user.isAdmin
                              ? Colors.amber.shade700
                              : colors.surface,
                          icon: user.isAdmin
                              ? Icons.star_rounded
                              : Icons.person_outline,
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      );
    });
  }
}
