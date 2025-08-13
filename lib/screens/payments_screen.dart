import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../providers/student_provider.dart';
import 'payment_form.dart';

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
      // تحميل الطلاب لاستخدامهم في الفورم
      await context.read<StudentProvider>().fetchAll();
      // جلب الدفعات (يدعم التصفية بالطالب إن رغبت)
      await context.read<PaymentProvider>().fetchPayments(
            studentId: widget.studentId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final pvd = context.watch<PaymentProvider>();
    final items = pvd.items;

    return Scaffold(
      appBar: AppBar(title: const Text('الدفعات')),
      body: pvd.isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('لا توجد دفعات'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, i) {
                    final p = items[i];
                    final paidText = p.isPaid ? 'مدفوع' : 'غير مدفوع';
                    final dateText = p.date.toIso8601String().split('T').first;

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
                                content: const Text('لا يمكن التراجع عن هذا الإجراء.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('إلغاء'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, true),
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
                        title: Text('${p.amount.toStringAsFixed(2)}'),
                        subtitle: Text('$dateText • $paidText'),
                        trailing: Icon(
                          p.isPaid ? Icons.check_circle : Icons.error_outline,
                          color: p.isPaid ? Colors.green : Colors.orange,
                        ),
                        onTap: () async {
                          final ok = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentForm(
                                initial: p,
                                fixedStudentId: p.student, // يطابق الموديل الجديد
                              ),
                            ),
                          );
                          if (ok == true) {
                            await context.read<PaymentProvider>().fetchPayments(
                                  studentId: widget.studentId,
                                );
                          }
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentForm(fixedStudentId: widget.studentId),
            ),
          );
          if (ok == true) {
            await context.read<PaymentProvider>().fetchPayments(
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
