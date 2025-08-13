class Payment {
  final int id;
  final int studentId;
  final double amount;
  final DateTime date;
  final String method;

  Payment({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.date,
    required this.method,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      studentId: json['student'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      method: json['method'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student': studentId,
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
    };
  }
}
