import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../providers/student_provider.dart';
import 'widgets/payment_form.dart';

class PaymentsScreen extends StatefulWidget {
  final int? studentId;
  const PaymentsScreen({super.key, this.studentId});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<StudentProvider>().fetchAll();
      await context.read<PaymentProvider>().fetchPayments(
            studentId: widget.studentId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentPvd = context.watch<PaymentProvider>();
    final studentPvd = context.watch<StudentProvider>();

    final payments = paymentPvd.items;

    if (paymentPvd.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('الدفعات')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (payments.isEmpty) {
      return  Scaffold(
        appBar: AppBar(title: Text('الدفعات')),
        body: Center(child: Text('لا توجد دفعات')),
      );
    }

    // تجميع الدفعات حسب اسم الطالب
    final grouped = <String, List<dynamic>>{};
    double totalAmount = 0;

    for (final p in payments) {
      final studentName =
          studentPvd.getById(p.student)?.name ?? 'غير معروف';
      grouped.putIfAbsent(studentName, () => []).add(p);
      totalAmount += p.amount;
    }

    final studentNames = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفعات'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'المجموع الكلي: ${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => paymentPvd.fetchPayments(
          studentId: widget.studentId,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 88, top: 8),
          itemCount: studentNames.length,
          itemBuilder: (context, index) {
            final name = studentNames[index];
            final studentPayments = grouped[name]!;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ExpansionTile(
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: studentPayments.map<Widget>((p) {
                  final month = p.date.month;
                  final year = p.date.year;
                  final paidText = p.isPaid ? 'مدفوع' : 'غير مدفوع';

                  return Dismissible(
                    key: ValueKey('pay_${p.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('حذف الدفعة؟'),
                              content: const Text(
                                  'لا يمكن التراجع عن هذا الإجراء.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('إلغاء'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('حذف'),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                    },
                    onDismissed: (_) async {
                      await context.read<PaymentProvider>().remove(p.id);
                    },
                    child: ListTile(
                      title: Text(
                          'المبلغ: ${p.amount.toStringAsFixed(2)} • شهر: $month / $year'),
                      subtitle: Text(paidText),
                      trailing: Icon(
                        p.isPaid
                            ? Icons.check_circle
                            : Icons.error_outline,
                        color: p.isPaid ? Colors.green : Colors.orange,
                      ),
                      onTap: () async {
                        final ok = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentForm(
                              initial: p,
                              fixedStudentId: p.student,
                            ),
                          ),
                        );
                        if (ok == true) {
                          await paymentPvd.fetchPayments(
                            studentId: widget.studentId,
                          );
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PaymentForm(fixedStudentId: widget.studentId),
            ),
          );
          if (ok == true) {
            await paymentPvd.fetchPayments(
              studentId: widget.studentId,
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة دفعة'),
      ),
    );
  }
}
