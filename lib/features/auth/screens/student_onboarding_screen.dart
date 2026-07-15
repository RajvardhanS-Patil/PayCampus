import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../models/student.dart';
import '../../../core/services/mock_database.dart';
import '../../parent/screens/parent_dashboard.dart';

class StudentOnboardingScreen extends StatefulWidget {
  final String phoneNumber;

  const StudentOnboardingScreen({super.key, required this.phoneNumber});

  @override
  State<StudentOnboardingScreen> createState() => _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState extends State<StudentOnboardingScreen> {
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _divController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _divController.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    if (_nameController.text.isEmpty || _classController.text.isEmpty || _divController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all student details to link the account"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate profile creation and "Saving Login"
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      final student = Student(
        id: "stud_custom",
        name: _nameController.text,
        rollNo: "GIS/2026/001",
        grade: "Grade ${_classController.text}-${_divController.text.toUpperCase()}",
        schoolName: "Greenwood International School",
        avatarUrl: "https://api.dicebear.com/7.x/adventurer/svg?seed=${_nameController.text}",
        pendingAmount: 14500.0,
        totalAmount: 45000.0,
      );

      // Save to shared database
      MockDatabase().addStudent(student);

      setState(() {
        _isLoading = false;
      });

      // Show success and move to dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login successful! Profile created."),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 1),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ParentDashboard(student: student)),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "STEP 2: LINK PROFILE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Link Student Details",
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your ward's details to sync their fee history from the school records.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),

              _buildLabel("STUDENT NAME", theme),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: "Enter full name (as per school record)",
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("CLASS / GRADE", theme),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _classController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            hintText: "e.g. 8",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("DIVISION", theme),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _divController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            hintText: "e.g. A",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeOnboarding,
                  child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Verify & Login to Dashboard"),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Data will be synced with +91 ${widget.phoneNumber}",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
    );
  }
}
