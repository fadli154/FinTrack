import 'package:fl_chart/fl_chart.dart';
import 'package:fintrack/controllers/admin_controller.dart';
import 'package:fintrack/widgets/ft_badge.dart';
import 'package:fintrack/widgets/ft_chart_card.dart';
import 'package:fintrack/widgets/ft_section_header.dart';
import 'package:fintrack/widgets/ft_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ─── Palette for pie/bar charts ─────────────────────────────────────────────
const _kPieColors = [
  Color(0xFF26A69A), // teal
  Color(0xFF42A5F5), // blue
  Color(0xFFAB47BC), // purple
  Color(0xFFFF7043), // deep orange
  Color(0xFFFFCA28), // amber
  Color(0xFF66BB6A), // green
];

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
        return Center(child: CircularProgressIndicator(color: colors.surface));
      }

      return RefreshIndicator(
        color: colors.surface,
        onRefresh: ctrl.loadStats,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // ─── Page Header ───────────────────────────────────────────────
            _buildHeader(context, ctrl),
            const SizedBox(height: 20),

            // ─── Summary Cards ─────────────────────────────────────────────
            FtSectionHeader(title: 'admin_users'.tr),
            const SizedBox(height: 10),
            _buildUserSummaryRow(context, ctrl),
            const SizedBox(height: 16),

            FtSectionHeader(title: 'admin_transactions'.tr),
            const SizedBox(height: 10),
            _buildTxSummaryRow(context, ctrl, currency),
            const SizedBox(height: 24),

            // ─── Charts ────────────────────────────────────────────────────
            FtSectionHeader(title: 'chart_analytics'.tr),
            const SizedBox(height: 12),

            // Row: User Status donut + User Growth line
            LayoutBuilder(builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 500;
              if (isTablet) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildUserStatusDonut(context, ctrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildUserGrowthLine(context, ctrl)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildUserStatusDonut(context, ctrl),
                  const SizedBox(height: 12),
                  _buildUserGrowthLine(context, ctrl),
                ],
              );
            }),

            const SizedBox(height: 12),

            // Income vs Expense bar chart (full width)
            _buildIncomeExpenseBar(context, ctrl),
            const SizedBox(height: 12),

            // Category Distribution pie chart (full width)
            _buildCategoryPie(context, ctrl),
            const SizedBox(height: 20),

            // ─── Recent Users ──────────────────────────────────────────────
            FtSectionHeader(
              title: 'recent_users'.tr,
              trailing: TextButton(
                onPressed: () {},
                child:
                    Text('view_all'.tr, style: TextStyle(color: colors.surface)),
              ),
            ),
            const SizedBox(height: 8),
            ...ctrl.users.take(5).map((user) => _buildUserTile(context, user)),
          ],
        ),
      );
    });
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, AdminController ctrl) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.surface.withValues(alpha: .18),
            colors.surface.withValues(alpha: .06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.surface.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: .2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.analytics_rounded, color: colors.surface, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'admin_dashboard'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.tertiary,
                  ),
                ),
                Text(
                  'admin_dashboard_sub'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.tertiary.withValues(alpha: .55),
                  ),
                ),
              ],
            ),
          ),
          if (ctrl.statsLoading.value)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.surface,
              ),
            ),
        ],
      ),
    );
  }

  // ─── Summary Rows ─────────────────────────────────────────────────────────

  Widget _buildUserSummaryRow(BuildContext context, AdminController ctrl) {
    return Row(
      children: [
        Expanded(
          child: FtStatCard(
            label: 'total_users'.tr,
            value: ctrl.totalUsers.value.toString(),
            icon: Icons.people_rounded,
            accentColor: const Color(0xFF26A69A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FtStatCard(
            label: 'active_users'.tr,
            value: ctrl.activeUsers.value.toString(),
            icon: Icons.check_circle_rounded,
            accentColor: Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FtStatCard(
            label: 'disabled_users'.tr,
            value: ctrl.disabledUsers.value.toString(),
            icon: Icons.block_rounded,
            accentColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildTxSummaryRow(
    BuildContext context,
    AdminController ctrl,
    NumberFormat currency,
  ) {
    return Column(
      children: [
        // Total transactions — full-width highlighted card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF26A69A).withValues(alpha: .12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  color: const Color(0xFF26A69A), size: 28),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ctrl.totalTransactions.value.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF26A69A),
                    ),
                  ),
                  Text(
                    'total_transactions'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF26A69A).withValues(alpha: .8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
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
      ],
    );
  }

  // ─── Charts ───────────────────────────────────────────────────────────────

  Widget _buildUserStatusDonut(
      BuildContext context, AdminController ctrl) {
    final colors = Theme.of(context).colorScheme;
    final active = ctrl.activeUsers.value.toDouble();
    final disabled = ctrl.disabledUsers.value.toDouble();
    final total = active + disabled;

    return FtChartCard(
      title: 'chart_user_status'.tr,
      subtitle: 'chart_user_status_sub'.tr,
      height: 180,
      legend: [
        FtChartLegend.item('active_users'.tr, Colors.green),
        FtChartLegend.item('disabled_users'.tr, Colors.red),
      ],
      chart: total == 0
          ? _emptyChart(context)
          : Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 45,
                    sections: [
                      PieChartSectionData(
                        value: active,
                        color: Colors.green,
                        title: active.toInt().toString(),
                        titleStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 40,
                      ),
                      PieChartSectionData(
                        value: disabled == 0 ? 0.001 : disabled,
                        color: Colors.red,
                        title: disabled == 0 ? '' : disabled.toInt().toString(),
                        titleStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 40,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      total.toInt().toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.tertiary,
                      ),
                    ),
                    Text(
                      'total_users'.tr,
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.tertiary.withValues(alpha: .5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildUserGrowthLine(BuildContext context, AdminController ctrl) {
    final colors = Theme.of(context).colorScheme;
    final data = ctrl.userGrowthData;
    final entries = data.entries.toList();

    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value.toDouble()));
    }

    final maxY = spots.isEmpty
        ? 5.0
        : (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1);

    return FtChartCard(
      title: 'chart_user_growth'.tr,
      subtitle: 'analytics_last_6_months'.tr,
      height: 180,
      chart: spots.isEmpty
          ? _emptyChart(context)
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: colors.tertiary.withValues(alpha: .08),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.tertiary.withValues(alpha: .5),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        // Show short label
                        final label = entries[idx].key.split(' ').first;
                        return Text(
                          label,
                          style: TextStyle(
                            fontSize: 9,
                            color: colors.tertiary.withValues(alpha: .55),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: colors.surface,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: colors.surface,
                        strokeColor: Colors.white,
                        strokeWidth: 1.5,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          colors.surface.withValues(alpha: .2),
                          colors.surface.withValues(alpha: 0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildIncomeExpenseBar(BuildContext context, AdminController ctrl) {
    final colors = Theme.of(context).colorScheme;
    final data = ctrl.monthlyTxData;

    final groups = <BarChartGroupData>[];
    for (int i = 0; i < data.length; i++) {
      final income = (data[i]['income'] as double?) ?? 0;
      final expense = (data[i]['expense'] as double?) ?? 0;
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: income,
              color: Colors.green,
              width: 8,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: expense,
              color: Colors.red,
              width: 8,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
          barsSpace: 3,
        ),
      );
    }

    final allAmounts = data
        .expand((m) => [(m['income'] as double), (m['expense'] as double)])
        .where((v) => v > 0);
    final maxY =
        allAmounts.isEmpty ? 100.0 : (allAmounts.reduce((a, b) => a > b ? a : b) * 1.25);

    return FtChartCard(
      title: 'chart_income_expense'.tr,
      subtitle: 'analytics_last_6_months'.tr,
      height: 220,
      legend: [
        FtChartLegend.item('income'.tr, Colors.green),
        FtChartLegend.item('expense'.tr, Colors.red),
      ],
      chart: groups.isEmpty
          ? _emptyChart(context)
          : BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: groups,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: colors.tertiary.withValues(alpha: .08),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final label =
                            (data[idx]['month'] as String).split(' ').first;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 9,
                              color: colors.tertiary.withValues(alpha: .55),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colors.secondary,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCategoryPie(BuildContext context, AdminController ctrl) {
    final colors = Theme.of(context).colorScheme;
    final data = ctrl.categoryTotals;
    final entries = data.entries.toList();

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < entries.length; i++) {
      final color = _kPieColors[i % _kPieColors.length];
      sections.add(
        PieChartSectionData(
          value: entries[i].value,
          color: color,
          title: '',
          radius: 55,
        ),
      );
    }

    return FtChartCard(
      title: 'chart_categories'.tr,
      subtitle: 'chart_categories_sub'.tr,
      height: 220,
      legend: List.generate(
        entries.length,
        (i) => FtChartLegend.item(
          entries[i].key,
          _kPieColors[i % _kPieColors.length],
        ),
      ),
      chart: sections.isEmpty
          ? _emptyChart(context)
          : Row(
              children: [
                Expanded(
                  flex: 5,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 30,
                      sections: sections,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(entries.length, (i) {
                      final color = _kPieColors[i % _kPieColors.length];
                      final pct = data.values.fold(0.0, (a, b) => a + b);
                      final percent = pct == 0
                          ? 0.0
                          : (entries[i].value / pct * 100);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                entries[i].key,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.tertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${percent.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
    );
  }

  // ─── Recent User Tile ─────────────────────────────────────────────────────

  Widget _buildUserTile(BuildContext context, dynamic user) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.secondary.withAlpha(50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.tertiary.withValues(alpha: .1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: user.isAdmin
                ? Colors.amber.withValues(alpha: .2)
                : const Color(0xFF26A69A).withValues(alpha: .15),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: user.isAdmin
                    ? Colors.amber.shade700
                    : const Color(0xFF26A69A),
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
                    color: colors.tertiary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.tertiary.withValues(alpha: .55),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          FtBadge(
            label: user.isAdmin ? 'role_admin'.tr : 'role_user'.tr,
            accentColor:
                user.isAdmin ? Colors.amber.shade700 : const Color(0xFF26A69A),
            icon: user.isAdmin ? Icons.star_rounded : Icons.person_outline,
          ),
        ],
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _emptyChart(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded,
              size: 40, color: colors.tertiary.withValues(alpha: .25)),
          const SizedBox(height: 8),
          Text(
            'no_data'.tr,
            style: TextStyle(
              color: colors.tertiary.withValues(alpha: .45),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
