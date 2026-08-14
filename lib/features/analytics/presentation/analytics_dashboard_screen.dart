import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/velvet_colors.dart';
import '../../../shared_widgets/clay_card.dart';
import '../../job_tracker/presentation/providers/job_provider.dart';
import '../../project_tracker/presentation/providers/project_provider.dart';
import '../../idea_vault/presentation/providers/idea_provider.dart';
import '../../ai_agents/domain/token_optimizer.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen> {
  // Pariyojana starts with August 2026 as Month 1
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Default to current month or August 2026 if earlier
    if (now.isBefore(DateTime(2026, 8, 1))) {
      _selectedMonth = DateTime(2026, 8, 1);
    } else {
      _selectedMonth = DateTime(now.year, now.month, 1);
    }
  }

  void _prevMonth() {
    // Cannot go earlier than August 2026 (App Launch Month)
    if (_selectedMonth.year == 2026 && _selectedMonth.month <= 8) return;
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [VelvetColors.darkBg, VelvetColors.darkSurface, VelvetColors.darkBg],
            begin: Alignment.topLeft, end: Alignment.bottomRight)
        : const LinearGradient(
            colors: [VelvetColors.cream, Color(0xFFF6ECE1), Color(0xFFFFF2EE)],
            begin: Alignment.topLeft, end: Alignment.bottomRight);

    final jobs = ref.watch(jobApplicationsStreamProvider).valueOrNull ?? [];
    final projects = ref.watch(projectsStreamProvider).valueOrNull ?? [];
    final ideas = ref.watch(ideasStreamProvider).valueOrNull ?? [];

    // Funnel math
    final totalJobs = jobs.length;
    final applied = jobs.where((j) => j.status == 'Applied' || j.status == 'Shortlisted' || j.status == 'Interview' || j.status == 'Interviewing' || j.status == 'Offer' || j.status == 'Offered').length;
    final interviews = jobs.where((j) => j.status == 'Interview' || j.status == 'Interviewing' || j.status == 'Offer' || j.status == 'Offered').length;
    final offers = jobs.where((j) => j.status == 'Offer' || j.status == 'Offered').length;

    final double appRate = totalJobs == 0 ? 0 : (applied / totalJobs * 100);
    final double intRate = applied == 0 ? 0 : (interviews / applied * 100);
    final double offerRate = interviews == 0 ? 0 : (offers / interviews * 100);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: VelvetColors.cocoa),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Command Analytics',
          style: GoogleFonts.outfit(
            color: VelvetColors.cocoa,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              // Top metric badges
              Row(
                children: [
                  _buildMetricCard(context, 'Total Ideas', '${ideas.length}', Icons.lightbulb_outline, VelvetColors.coralPeach),
                  const SizedBox(width: 8),
                  _buildMetricCard(context, 'Projects', '${projects.length}', Icons.folder_open_outlined, VelvetColors.mint),
                  const SizedBox(width: 8),
                  _buildMetricCard(context, 'Applications', '$totalJobs', Icons.work_outline_outlined, VelvetColors.periwinkle),
                ],
              ),
              const SizedBox(height: 20),

              // Section 1: Month-Based Activity Calendar Heatmap
              _buildSectionHeader(context, 'Monthly Activity Heatmap 📅', 'Starting from August 2026 (Month 1)'),
              const SizedBox(height: 10),
              _buildActivityHeatmap(context, ideas, projects),

              const SizedBox(height: 24),

              // Section 2: AI Token Efficiency
              _buildSectionHeader(context, 'Token Efficiency Engine ⚡', 'Prompt compression & LRU caching telemetry'),
              const SizedBox(height: 10),
              _buildTokenSavingsCard(context),

              const SizedBox(height: 24),

              // Section 3: Job Conversion Funnel
              _buildSectionHeader(context, 'Job Hunt Conversion Funnel 🎯', 'From application to offer'),
              const SizedBox(height: 10),
              _buildFunnelCard(context, totalJobs, applied, appRate, interviews, intRate, offers, offerRate),

              const SizedBox(height: 24),

              // Section 4: Productivity Velocity Sparkline
              _buildSectionHeader(context, 'Weekly Productivity Velocity 📈', '8-week cross-workspace activity trajectory'),
              const SizedBox(height: 10),
              _buildSparklineCard(context, ideas, projects),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String val, IconData icon, Color accent) {
    return Expanded(
      child: ClayCard(
        color: VelvetColors.surface(context),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(height: 4),
            Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: VelvetColors.textPrimary(context))),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9.5, color: VelvetColors.textSecondary(context))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: VelvetColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: VelvetColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTokenSavingsCard(BuildContext context) {
    final savings = TokenOptimizer.savings;
    return ClayCard(
      color: VelvetColors.surface(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: VelvetColors.coralPeach, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Tokens Saved',
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: VelvetColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: VelvetColors.mint.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${savings.savingsPercent.toStringAsFixed(0)}% Saved',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricPill(context, '${savings.rawTokens}', 'Raw Est.'),
              _metricPill(context, '${savings.compressedTokens}', 'Compressed'),
              _metricPill(context, '${savings.tokensSaved}', 'Saved'),
              _metricPill(context, '${savings.cacheHits}', 'Cache Hits'),
            ],
          ),
          const SizedBox(height: 6),
          Text('Automatic prompt compression & LRU prompt caching active.', style: TextStyle(fontSize: 10, color: VelvetColors.textSecondary(context))),
        ],
      ),
    );
  }

  Widget _metricPill(BuildContext context, String val, String label) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
        Text(label, style: TextStyle(fontSize: 9, color: VelvetColors.textSecondary(context))),
      ],
    );
  }

  Widget _buildActivityHeatmap(BuildContext context, List<dynamic> ideas, List<dynamic> projects) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final selYear = _selectedMonth.year;
    final selMonth = _selectedMonth.month;

    // Month display calculations
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final monthName = monthNames[selMonth - 1];

    // Compute month number from August 2026 (Launch month)
    final monthNumber = ((selYear - 2026) * 12) + (selMonth - 8) + 1;
    final isAppFirstMonth = selYear == 2026 && selMonth == 8;

    // Exact days in selected month (28, 29, 30, or 31)
    final daysInMonth = DateTime(selYear, selMonth + 1, 0).day;
    // Weekday of 1st day of month (1 = Mon, 7 = Sun)
    final firstWeekday = DateTime(selYear, selMonth, 1).weekday;

    // Map day (1..daysInMonth) -> activity count
    final activityMap = <int, int>{};
    for (final idea in ideas) {
      final d = idea.createdAt as DateTime;
      if (d.year == selYear && d.month == selMonth) {
        activityMap[d.day] = (activityMap[d.day] ?? 0) + 1;
      }
    }
    for (final proj in projects) {
      final d = proj.createdAt as DateTime;
      if (d.year == selYear && d.month == selMonth) {
        activityMap[d.day] = (activityMap[d.day] ?? 0) + 1;
      }
    }

    // If viewing current month, ensure today has active count (app opened)
    if (selYear == today.year && selMonth == today.month) {
      activityMap[today.day] = (activityMap[today.day] ?? 0) + 1;
    }

    Color dayColor(int count) {
      if (count == 0) return const Color(0xFFE2D5C8);
      if (count == 1) return const Color(0xFF4ADE80);
      if (count <= 3) return const Color(0xFF22C55E);
      return const Color(0xFF16A34A);
    }

    return ClayCard(
      color: VelvetColors.surface(context),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Selector Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded,
                        color: isAppFirstMonth ? VelvetColors.textSecondary(context).withValues(alpha: 0.3) : VelvetColors.coralPeach),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: isAppFirstMonth ? null : _prevMonth,
                  ),
                  Text(
                    '$monthName $selYear',
                    style: TextStyle(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: VelvetColors.textPrimary(context),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: VelvetColors.coralPeach),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Month $monthNumber ($daysInMonth Days)',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: VelvetColors.coralPeach,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Weekday header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((wd) {
              return Expanded(
                child: Center(
                  child: Text(
                    wd,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: VelvetColors.textSecondary(context).withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 1.0,
            ),
            // total items = leading empty slots + days in month
            itemCount: (firstWeekday - 1) + daysInMonth,
            itemBuilder: (context, idx) {
              if (idx < firstWeekday - 1) {
                // Leading empty placeholder cell before 1st of month
                return const SizedBox.shrink();
              }

              final day = idx - (firstWeekday - 1) + 1;
              final count = activityMap[day] ?? 0;
              final col = dayColor(count);
              final isToday = selYear == today.year && selMonth == today.month && day == today.day;

              return Tooltip(
                message: '$day $monthName: ${count > 0 ? '$count action${count == 1 ? '' : 's'} ✅' : 'No activity'}',
                child: Container(
                  decoration: BoxDecoration(
                    color: col,
                    borderRadius: BorderRadius.circular(6),
                    border: isToday ? Border.all(color: const Color(0xFFFF6D00), width: 1.8) : null,
                    boxShadow: [
                      BoxShadow(color: col.withValues(alpha: 0.35), blurRadius: 4, offset: const Offset(0, 1)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: count > 0 ? Colors.white : const Color(0xFF8B6F5E),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Legend row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFFE2D5C8), borderRadius: BorderRadius.circular(2), border: Border.all(color: const Color(0xFFD4B8A8)))),
                const SizedBox(width: 5),
                Text('None', style: TextStyle(fontSize: 9.5, color: VelvetColors.textSecondary(context))),
              ]),
              Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF4ADE80), borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 5),
                Text('Active', style: TextStyle(fontSize: 9.5, color: VelvetColors.textSecondary(context))),
              ]),
              Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 5),
                Text('High activity 🔥', style: TextStyle(fontSize: 9.5, color: VelvetColors.textSecondary(context))),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelCard(BuildContext context, int total, int applied, double appRate, int interviews, double intRate, int offers, double offerRate) {
    return ClayCard(
      color: VelvetColors.surface(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFunnelStage(context, 'Total Tracked', '$total', 1.0, VelvetColors.periwinkle),
          _buildFunnelStage(context, 'Applied (${appRate.toStringAsFixed(0)}%)', '$applied', (applied / (total == 0 ? 1 : total)).clamp(0.1, 1.0), VelvetColors.mint),
          _buildFunnelStage(context, 'Interviews (${intRate.toStringAsFixed(0)}%)', '$interviews', (interviews / (total == 0 ? 1 : total)).clamp(0.08, 1.0), VelvetColors.coralPeach),
          _buildFunnelStage(context, 'Offers (${offerRate.toStringAsFixed(0)}%)', '$offers', (offers / (total == 0 ? 1 : total)).clamp(0.05, 1.0), Colors.amber),
        ],
      ),
    );
  }

  Widget _buildFunnelStage(BuildContext context, String label, String val, double fraction, Color col) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context))),
              Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: col)),
            ],
          ),
          const SizedBox(height: 4),
          FractionallySizedBox(
            widthFactor: fraction,
            child: Container(height: 8, decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(4))),
          ),
        ],
      ),
    );
  }

  Widget _buildSparklineCard(BuildContext context, List<dynamic> ideas, List<dynamic> projects) {
    // Build 8-week activity counts from real DB data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weeklyCounts = List<int>.filled(8, 0);
    void countItem(DateTime d) {
      final daysAgo = today.difference(DateTime(d.year, d.month, d.day)).inDays;
      final weekIdx = daysAgo ~/ 7;
      if (weekIdx >= 0 && weekIdx < 8) {
        weeklyCounts[7 - weekIdx] = weeklyCounts[7 - weekIdx] + 1;
      }
    }
    for (final i in ideas) { countItem(i.createdAt as DateTime); }
    for (final p in projects) { countItem(p.createdAt as DateTime); }

    final maxCount = weeklyCounts.reduce((a, b) => a > b ? a : b);
    final hasData = maxCount > 0;

    return ClayCard(
      color: VelvetColors.surface(context),
      padding: const EdgeInsets.all(16),
      child: hasData
          ? SizedBox(
              height: 80,
              child: CustomPaint(
                painter: _SparklinePainter(
                  color: VelvetColors.coralPeach,
                  points: weeklyCounts.map((c) => maxCount == 0 ? 0.0 : c / maxCount).toList(),
                ),
              ),
            )
          : SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  'No activity yet — create ideas or projects to see velocity',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                ),
              ),
            ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  final List<double> points;
  _SparklinePainter({required this.color, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (points.length - 1).clamp(1, 9999);
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - (points[i] * size.height * 0.85) - 4;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
