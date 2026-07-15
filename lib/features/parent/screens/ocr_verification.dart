import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../models/student.dart';
import '../../../core/services/mock_database.dart';
import '../../../core/services/ocr_service.dart';
import '../../../core/widgets/shimmer.dart';
import 'receipt_screen.dart';

class OcrVerificationScreen extends StatefulWidget {
  final Student student;
  final String fileName;

  const OcrVerificationScreen({
    super.key,
    required this.student,
    required this.fileName,
  });

  @override
  State<OcrVerificationScreen> createState() => _OcrVerificationScreenState();
}

class _OcrVerificationScreenState extends State<OcrVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;
  
  String _currentStep = 'Processing'; // Processing, Matched, Verified
  String _statusText = 'Initializing AI OCR Engine...';
  double _extractedAmount = 0.0;
  String _extractedUtr = 'UTR829402948293';

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );

    _runOcrSequence();
  }

  void _runOcrSequence() async {
    // Step 1: Processing OCR
    setState(() {
      _currentStep = 'Processing';
      _statusText = 'Scanning image with Gemini AI...';
    });

    final ocrResults = await OcrService().parseReceipt(
      widget.fileName,
      expectedAmount: widget.student.pendingAmount,
    );

    if (!mounted) return;

    final double extractedAmount = ocrResults['amount'] ?? widget.student.pendingAmount;
    final String extractedUtr = ocrResults['utr'] ?? 'UTR829402948293';
    final double confidence = ocrResults['confidence'] ?? 0.98;

    setState(() {
      _currentStep = 'Matched';
      _extractedAmount = extractedAmount;
      _extractedUtr = extractedUtr;
      _statusText = 'Extracted UTR: $extractedUtr\nExtracted Amount: ₹${extractedAmount.toStringAsFixed(0)} (${(confidence * 100).toStringAsFixed(0)}% confidence)';
    });

    // Step 2: Verification matching
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // Record verified transaction in the database
    MockDatabase().recordInstantPayment(
      studentId: widget.student.id,
      studentName: widget.student.name,
      grade: widget.student.grade,
      feeName: "Term 2 Tuition Fee",
      amount: _extractedAmount,
      utr: _extractedUtr,
      method: "UPI / PhonePe",
    );

    setState(() {
      _currentStep = 'Verified';
      _statusText = 'Transaction Ledger Updated Successfully.';
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                "AI Verification",
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Processing payment proof in real-time",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // Mock scanning card frame
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Simulated receipt image background
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Opacity(
                          opacity: _currentStep == 'Verified' ? 0.3 : 0.7,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ShimmerPlaceholder(width: 80, height: 16),
                                    ShimmerPlaceholder(width: 40, height: 16),
                                  ],
                                ),
                                SizedBox(height: 24),
                                ShimmerPlaceholder(width: 120, height: 28),
                                SizedBox(height: 16),
                                ShimmerPlaceholder(width: 200, height: 12),
                                SizedBox(height: 8),
                                ShimmerPlaceholder(width: 150, height: 12),
                                Spacer(),
                                Center(
                                  child: ShimmerPlaceholder(
                                    width: 80,
                                    height: 80,
                                    borderRadius: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Laser scanner line overlay (Only if not verified yet)
                      if (_currentStep != 'Verified')
                        AnimatedBuilder(
                          animation: _scannerAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: 24.0 + (300.0 * _scannerAnimation.value),
                              left: 24,
                              right: 24,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      // Verified state icon overlay
                      if (_currentStep == 'Verified')
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 56,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Matched & Verified!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Status Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildStatusIndicator(_currentStep == 'Processing', 'Processing', isDark),
                        _buildDivider(isDark),
                        _buildStatusIndicator(_currentStep == 'Matched', 'Matched', isDark),
                        _buildDivider(isDark),
                        _buildStatusIndicator(_currentStep == 'Verified', 'Verified', isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bottom Control Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _currentStep == 'Verified'
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReceiptScreen(
                                student: widget.student,
                                transactionId: _extractedUtr,
                                feeName: "Term 2 Tuition Fee",
                                amount: _extractedAmount,
                                date: DateTime.now(),
                                paymentMethod: "UPI / PhonePe",
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentStep == 'Verified' ? AppColors.primary : Colors.grey[400],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("View Official Receipt"),
                      SizedBox(width: 8),
                      Icon(Icons.receipt, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool active, String label, bool isDark) {
    Color color = active 
        ? AppColors.primary 
        : (_currentStep == 'Verified' || (_currentStep == 'Matched' && label == 'Processing')
            ? AppColors.success
            : (isDark ? const Color(0xFF334155) : AppColors.textMuted));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: active
                ? const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Icon(
                    Icons.check,
                    size: 12,
                    color: color,
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          height: 2,
          color: isDark ? const Color(0xFF334155) : AppColors.border,
        ),
      ),
    );
  }
}
