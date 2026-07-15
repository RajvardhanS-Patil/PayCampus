import 'package:flutter/foundation.dart';
import '../../models/student.dart';
import '../../models/transaction.dart';
import '../../models/reconciliation.dart';

class MockDatabase extends ChangeNotifier {
  // Singleton pattern
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal() {
    _initializeData();
  }

  // Lists
  final List<Student> _students = [];
  final List<PaymentTransaction> _transactions = [];
  final List<ReconciliationItem> _reconciliationQueue = [];

  List<Student> get students => List.unmodifiable(_students);
  List<PaymentTransaction> get transactions => List.unmodifiable(_transactions);
  List<ReconciliationItem> get reconciliationQueue => List.unmodifiable(_reconciliationQueue);

  void _initializeData() {
    // 1. Initialize Mock Students
    _students.addAll([
      const Student(
        id: "stud_1",
        name: "Rahul Sharma",
        rollNo: "GIS/2026/084",
        grade: "Grade 8-A",
        schoolName: "Greenwood International School",
        avatarUrl: "https://api.dicebear.com/7.x/adventurer/svg?seed=Rahul",
        pendingAmount: 14500.0,
        totalAmount: 45000.0,
      ),
      const Student(
        id: "stud_2",
        name: "Sneha Sharma",
        rollNo: "GIS/2026/112",
        grade: "Grade 5-B",
        schoolName: "Greenwood International School",
        avatarUrl: "https://api.dicebear.com/7.x/adventurer/svg?seed=Sneha",
        pendingAmount: 4200.0,
        totalAmount: 38000.0,
      ),
      const Student(
        id: "stud_3",
        name: "Devansh Varma",
        rollNo: "GIS/2026/015",
        grade: "Grade 11-B",
        schoolName: "Greenwood International School",
        avatarUrl: "https://api.dicebear.com/7.x/adventurer/svg?seed=Devansh",
        pendingAmount: 25000.0,
        totalAmount: 50000.0,
      ),
      const Student(
        id: "stud_4",
        name: "Prisha Mehta",
        rollNo: "GIS/2026/092",
        grade: "Grade 3-C",
        schoolName: "Greenwood International School",
        avatarUrl: "https://api.dicebear.com/7.x/adventurer/svg?seed=Prisha",
        pendingAmount: 4800.0,
        totalAmount: 30000.0,
      ),
    ]);

    // 2. Initialize Mock Transactions
    _transactions.addAll([
      PaymentTransaction(
        id: "txn_101",
        studentId: "stud_1",
        studentName: "Rahul Sharma",
        feeName: "Term 1 Tuition Fee",
        amount: 30500.0,
        date: DateTime.now().subtract(const Duration(days: 45)),
        status: "Verified",
        method: "UPI",
        utr: "UTR829402948293",
        receiptNo: "REC-2026-9024",
      ),
      PaymentTransaction(
        id: "txn_102",
        studentId: "stud_1",
        studentName: "Rahul Sharma",
        feeName: "Quarterly Exam Fee",
        amount: 1500.0,
        date: DateTime.now().subtract(const Duration(days: 12)),
        status: "Verified",
        method: "Bank Transfer",
        utr: "TXN928402948",
        receiptNo: "REC-2026-9481",
      ),
      PaymentTransaction(
        id: "txn_103",
        studentId: "stud_2",
        studentName: "Sneha Sharma",
        feeName: "Term 1 Bus Fee",
        amount: 12000.0,
        date: DateTime.now().subtract(const Duration(days: 30)),
        status: "Verified",
        method: "UPI",
        utr: "PAY9028420942",
        receiptNo: "REC-2026-9087",
      ),
    ]);

    // 3. Initialize Mock Reconciliation Items
    _reconciliationQueue.addAll([
      ReconciliationItem(
        id: "recon_01",
        studentName: "Rahul Sharma",
        grade: "Grade 8-A",
        feeName: "Term 2 Tuition Fee",
        amountExtracted: 12000.0,
        amountExpected: 12000.0,
        utrExtracted: "UTR829402948293",
        dateExtracted: DateTime.now().subtract(const Duration(minutes: 42)),
        paymentMethod: "UPI / PhonePe",
        confidenceScore: 0.98,
        imageUrl: "screenshot_phonepe_tuition.png",
        status: "Matched",
      ),
      ReconciliationItem(
        id: "recon_02",
        studentName: "Devansh Varma",
        grade: "Grade 11-B",
        feeName: "Hostel Lodging Deposit",
        amountExtracted: 24500.0,
        amountExpected: 25000.0,
        utrExtracted: "TXN9481940182",
        dateExtracted: DateTime.now().subtract(const Duration(hours: 2)),
        paymentMethod: "IMPS Bank Transfer",
        confidenceScore: 0.74,
        imageUrl: "challan_slip_hostel.png",
        status: "Processing",
      ),
      ReconciliationItem(
        id: "recon_03",
        studentName: "Prisha Mehta",
        grade: "Grade 3-C",
        feeName: "Annual Activity Fee",
        amountExtracted: 4800.0,
        amountExpected: 4800.0,
        utrExtracted: "UPI9028420942",
        dateExtracted: DateTime.now().subtract(const Duration(hours: 4)),
        paymentMethod: "Paytm UPI",
        confidenceScore: 0.95,
        imageUrl: "paytm_ss.png",
        status: "Matched",
      ),
    ]);
  }

  // API Methods
  
  // Get Student by ID
  Student? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Add / Link Student during onboarding
  void addStudent(Student student) {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
    } else {
      _students.add(student);
    }
    notifyListeners();
  }

  // Get Transaction History for a student
  List<PaymentTransaction> getTransactionsForStudent(String studentId) {
    return _transactions.where((t) => t.studentId == studentId).toList();
  }

  // Submit a receipt for reconciliation
  void submitReconciliationItem({
    required String studentId,
    required String studentName,
    required String grade,
    required String feeName,
    required double amountExtracted,
    required double amountExpected,
    required String utrExtracted,
    required String paymentMethod,
    required double confidenceScore,
    required String imageUrl,
  }) {
    final newItem = ReconciliationItem(
      id: "recon_${DateTime.now().millisecondsSinceEpoch}",
      studentName: studentName,
      grade: grade,
      feeName: feeName,
      amountExtracted: amountExtracted,
      amountExpected: amountExpected,
      utrExtracted: utrExtracted,
      dateExtracted: DateTime.now(),
      paymentMethod: paymentMethod,
      confidenceScore: confidenceScore,
      imageUrl: imageUrl,
      status: confidenceScore >= 0.9 ? "Matched" : "Processing",
    );
    _reconciliationQueue.add(newItem);

    // Also add a pending transaction for the parent dashboard
    final pendingTxn = PaymentTransaction(
      id: "txn_${DateTime.now().millisecondsSinceEpoch}",
      studentId: studentId,
      studentName: studentName,
      feeName: feeName,
      amount: amountExpected,
      date: DateTime.now(),
      status: "Processing",
      method: paymentMethod,
      utr: utrExtracted,
      receiptNo: "PND-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
    );
    _transactions.add(pendingTxn);

    notifyListeners();
  }

  // Update reconciliation item status (Verify / Reject)
  void auditReconciliationItem(String reconId, String action) {
    final index = _reconciliationQueue.indexWhere((item) => item.id == reconId);
    if (index == -1) return;

    final item = _reconciliationQueue[index];
    
    if (action == 'Approve') {
      item.status = 'Verified';
      
      // Update transaction status
      final txnIndex = _transactions.indexWhere(
        (t) => t.utr == item.utrExtracted && t.studentName == item.studentName
      );
      if (txnIndex != -1) {
        _transactions[txnIndex] = PaymentTransaction(
          id: _transactions[txnIndex].id,
          studentId: _transactions[txnIndex].studentId,
          studentName: _transactions[txnIndex].studentName,
          feeName: _transactions[txnIndex].feeName,
          amount: _transactions[txnIndex].amount,
          date: _transactions[txnIndex].date,
          status: "Verified",
          method: _transactions[txnIndex].method,
          utr: _transactions[txnIndex].utr,
          receiptNo: "REC-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}",
        );
        
        // Deduct from student's pendingAmount
        final studentIndex = _students.indexWhere((s) => s.id == _transactions[txnIndex].studentId);
        if (studentIndex != -1) {
          final student = _students[studentIndex];
          final newPending = (student.pendingAmount - _transactions[txnIndex].amount).clamp(0.0, double.infinity);
          _students[studentIndex] = student.copyWith(pendingAmount: newPending);
        }
      }
    } else if (action == 'Reject') {
      item.status = 'Rejected';
      
      // Update transaction status
      final txnIndex = _transactions.indexWhere(
        (t) => t.utr == item.utrExtracted && t.studentName == item.studentName
      );
      if (txnIndex != -1) {
        _transactions[txnIndex] = PaymentTransaction(
          id: _transactions[txnIndex].id,
          studentId: _transactions[txnIndex].studentId,
          studentName: _transactions[txnIndex].studentName,
          feeName: _transactions[txnIndex].feeName,
          amount: _transactions[txnIndex].amount,
          date: _transactions[txnIndex].date,
          status: "Rejected",
          method: _transactions[txnIndex].method,
          utr: _transactions[txnIndex].utr,
          receiptNo: _transactions[txnIndex].receiptNo,
        );
      }
    } else if (action == 'Request Proof') {
      item.status = 'Requested Proof';
    }

    // Remove from the review queue
    _reconciliationQueue.removeAt(index);
    notifyListeners();
  }

  // Create a new fee demand (applied to a specific grade or student)
  void addFeeDemand({
    required String feeName,
    required double amount,
    required String targetGrade, // e.g. "Grade 8-A" or "All"
  }) {
    for (int i = 0; i < _students.length; i++) {
      if (targetGrade == 'All' || _students[i].grade == targetGrade) {
        final student = _students[i];
        _students[i] = student.copyWith(
          pendingAmount: student.pendingAmount + amount,
          totalAmount: student.totalAmount + amount,
        );
      }
    }
    notifyListeners();
  }

  // Waive fee for a student
  void waiveFeeForStudent(String studentId, double waiverAmount) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index == -1) return;

    final student = _students[index];
    final newPending = (student.pendingAmount - waiverAmount).clamp(0.0, double.infinity);
    _students[index] = student.copyWith(pendingAmount: newPending);
    
    notifyListeners();
  }

  // Record an instant payment (e.g. verified UPI)
  void recordInstantPayment({
    required String studentId,
    required String studentName,
    required String grade,
    required String feeName,
    required double amount,
    required String utr,
    required String method,
  }) {
    final txn = PaymentTransaction(
      id: "txn_${DateTime.now().millisecondsSinceEpoch}",
      studentId: studentId,
      studentName: studentName,
      feeName: feeName,
      amount: amount,
      date: DateTime.now(),
      status: "Verified",
      method: method,
      utr: utr,
      receiptNo: "REC-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}",
    );
    _transactions.add(txn);

    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final student = _students[index];
      final newPending = (student.pendingAmount - amount).clamp(0.0, double.infinity);
      _students[index] = student.copyWith(pendingAmount: newPending);
    }
    notifyListeners();
  }
}
