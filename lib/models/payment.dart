class Payment {
  final int id;
  final int student; // FK رقم الطالب
  final double amount;
  final DateTime date;
  final bool isPaid;

  Payment({
    required this.id,
    required this.student,
    required this.amount,
    required this.date,
    required this.isPaid,
  });

  factory Payment.fromJson(Map<String, dynamic> j) {
    final rawAmount = j['amount'];
    double parsedAmount;

    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount is String) {
      parsedAmount = double.tryParse(rawAmount) ?? 0.0;
    } else {
      parsedAmount = 0.0; // أو أي قيمة افتراضية مناسبة
    }

    return Payment(
      id: j['id'] as int,
      student: j['student'] as int,
      amount: parsedAmount, // ✅ نستخدم القيمة المحوّلة هنا
      date: DateTime.parse(j['date'] as String),
      isPaid: j['is_paid'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student': student,
      'amount': amount,
      'date': date.toIso8601String().split('T').first, // YYYY-MM-DD
      'is_paid': isPaid,
    };
  }

  Payment copyWith({
    int? id,
    int? student,
    double? amount,
    DateTime? date,
    bool? isPaid,
  }) {
    return Payment(
      id: id ?? this.id,
      student: student ?? this.student,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
