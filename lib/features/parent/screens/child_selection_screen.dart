import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../models/student.dart';
import '../../../core/services/mock_database.dart';
import 'parent_dashboard.dart';

class ChildSelectionScreen extends StatelessWidget {
  const ChildSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Welcome back,",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Select a Child Profile",
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Access billing, fee details, and e-receipts for your children",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 40),
              
              Expanded(
                child: AnimatedBuilder(
                  animation: MockDatabase(),
                  builder: (context, _) {
                    final db = MockDatabase();
                    final parentChildren = db.students.where((s) {
                      return s.id == "stud_1" || s.id == "stud_2" || s.id.startsWith("stud_custom");
                    }).toList();

                    return ListView.builder(
                      itemCount: parentChildren.length,
                      itemBuilder: (context, index) {
                        final child = parentChildren[index];
                        return _buildChildCard(context, child, isDark);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, Student child, bool isDark) {
    final theme = Theme.of(context);
    final formattedPending = "₹${child.pendingAmount.toStringAsFixed(0)}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParentDashboard(student: child),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : AppColors.border,
              width: 1.5,
            ),
            boxShadow: isDark ? [] : AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Circular Avatar Placeholder
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        child.name[0],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${child.grade} • ${child.rollNo}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: AppColors.border, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PENDING FEES",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isDark ? const Color(0xFF64748B) : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formattedPending,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          color: child.pendingAmount > 0 ? AppColors.warning : AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: child.pendingAmount > 0 
                        ? AppColors.warning.withOpacity(0.12)
                        : AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          child.pendingAmount > 0 ? Icons.error_outline : Icons.check_circle_outline,
                          size: 14,
                          color: child.pendingAmount > 0 ? AppColors.warning : AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          child.pendingAmount > 0 ? "Fees Pending" : "Fully Paid",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: child.pendingAmount > 0 ? AppColors.warning : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
