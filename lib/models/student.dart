class Student {
  final String id;
  final String name;
  final String rollNo;
  final String grade;
  final String schoolName;
  final String avatarUrl;
  final double pendingAmount;
  final double totalAmount;

  const Student({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.grade,
    required this.schoolName,
    required this.avatarUrl,
    required this.pendingAmount,
    required this.totalAmount,
  });

  double get paidAmount => totalAmount - pendingAmount;
  double get paymentProgress => totalAmount > 0 ? paidAmount / totalAmount : 0.0;

  Student copyWith({
    String? id,
    String? name,
    String? rollNo,
    String? grade,
    String? schoolName,
    String? avatarUrl,
    double? pendingAmount,
    double? totalAmount,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNo: rollNo ?? this.rollNo,
      grade: grade ?? this.grade,
      schoolName: schoolName ?? this.schoolName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
