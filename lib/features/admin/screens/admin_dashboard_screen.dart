import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../auth/screens/role_selection.dart';
import 'reconciliation_queue.dart';
import 'students_directory.dart';
import 'admin_analytics.dart';
import 'fee_builder.dart';
import 'reports_page.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildDashboardHomeTab(context),
      const ReconciliationQueueScreen(),
      const StudentsDirectoryScreen(),
      const AdminAnalyticsScreen(),
      const FeeBuilderScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: "Queue",
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: "Students",
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: "Analytics",
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: "Builder",
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHomeTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PayCampus Admin",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              "Greenwood Billing Desk",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Switch Portal",
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Grid Row 1
                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          title: "TODAY'S COLLECTION",
                          value: "₹1,24,500",
                          trend: "+14.2%",
                          isPositive: true,
                          icon: Icons.payments,
                          iconColor: AppColors.success,
                          iconBgColor: AppColors.success.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: KpiCard(
                          title: "OUTSTANDING BALANCE",
                          value: "₹8,62,400",
                          trend: "-8.4%",
                          isPositive: false,
                          icon: Icons.pending_actions,
                          iconColor: AppColors.warning,
                          iconBgColor: AppColors.warning.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // KPI Grid Row 2
                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          title: "STUDENTS PAID",
                          value: "384 / 420",
                          trend: "+2.3%",
                          isPositive: true,
                          icon: Icons.check_circle,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: KpiCard(
                          title: "PENDING DEFAULTERS",
                          value: "36",
                          trend: "-12.5%",
                          isPositive: true,
                          icon: Icons.people_outline,
                          iconColor: AppColors.error,
                          iconBgColor: AppColors.error.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Graph Card
                  _buildCollectionGraphCard(context, isDark),
                  const SizedBox(height: 24),

                  // Quick Actions Row
                  Text(
                    "Quick Actions",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionsRow(context, isDark),

                  const SizedBox(height: 24),

                  // Recent Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Recent Billing Log",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 1; // route to queue/audit log
                          });
                        },
                        child: const Text("View Audit Queue"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildActivityList(isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionGraphCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "COLLECTION TRENDS (JULY)",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark ? const Color(0xFF64748B) : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "₹4.24L total revenue collected",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Weekly View",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Custom Drawn Graph showing Collection Trends
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _CollectionGraphPainter(isDark: isDark),
            ),
          ),
          const SizedBox(height: 12),
          // Graph X-axis Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text("Week 1", textAlign: TextAlign.start, style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
              Expanded(child: Text("Week 2", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
              Expanded(child: Text("Week 3", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
              Expanded(child: Text("Week 4", textAlign: TextAlign.end, style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickActionBtn(
            context,
            label: "Send Reminders",
            icon: Icons.notifications_active_outlined,
            color: AppColors.primary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("AI Alert: Bulk outstanding fee notifications sent to 36 parents."),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          _buildQuickActionBtn(
            context,
            label: "Create Fee",
            icon: Icons.add_box_outlined,
            color: AppColors.success,
            onTap: () {
              setState(() {
                _currentIndex = 4; // route to builder tab
              });
            },
          ),
          _buildQuickActionBtn(
            context,
            label: "Audit Proofs",
            icon: Icons.fact_check_outlined,
            color: AppColors.warning,
            onTap: () {
              setState(() {
                _currentIndex = 1; // route to queue
              });
            },
          ),
          _buildQuickActionBtn(
            context,
            label: "Export Ledger",
            icon: Icons.download_outlined,
            color: AppColors.secondary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(bool isDark) {
    final activities = [
      {
        'title': 'Term 2 Fee published',
        'details': 'Grade 8 & 9 (240 students affected)',
        'time': '10 mins ago',
        'icon': Icons.publish_rounded,
        'color': AppColors.primary,
      },
      {
        'title': 'Auto-verified UTR match',
        'details': 'Rahul Sharma (Grade 8-A) • ₹14,500',
        'time': '30 mins ago',
        'icon': Icons.check_circle_outline,
        'color': AppColors.success,
      },
      {
        'title': 'Audit Flagged: Doubtful Proof',
        'details': 'Karan Gupta (Grade 10-B) • Amount mismatch 18%',
        'time': '1 hour ago',
        'icon': Icons.warning_amber_outlined,
        'color': AppColors.error,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : AppColors.border,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          final act = activities[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: (act['color'] as Color).withOpacity(0.1),
              radius: 18,
              child: Icon(act['icon'] as IconData, color: act['color'] as Color, size: 18),
            ),
            title: Text(
              act['title'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              act['details'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            trailing: Text(
              act['time'] as String,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          );
        },
      ),
    );
  }
}

// Custom Painter to draw a clean vector fintech line graph representation
class _CollectionGraphPainter extends CustomPainter {
  final bool isDark;
  _CollectionGraphPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF334155).withOpacity(0.2) : AppColors.border.withOpacity(0.5)
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    for (double i = 0; i <= size.height; i += size.height / 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Graph Line Points representing mock collection curve
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.65),
      Offset(size.width, size.height * 0.15),
    ];

    final path = Path()
      ..moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      // Draw smooth curve using cubic spline representation
      final prev = points[i - 1];
      final curr = points[i];
      final controlPoint1 = Offset(prev.dx + (curr.dx - prev.dx) / 2, prev.dy);
      final controlPoint2 = Offset(prev.dx + (curr.dx - prev.dx) / 2, curr.dy);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, curr.dx, curr.dy);
    }

    // Fill Gradient Path under the curve
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.24),
          AppColors.primary.withOpacity(0.00),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Line Paint
    final linePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Highlight Node Circles
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var point in points) {
      canvas.drawCircle(point, 5, pointPaint);
      canvas.drawCircle(point, 5, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
