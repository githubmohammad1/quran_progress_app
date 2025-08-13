import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/payment.dart';
import '../providers/payment_provider.dart';
import '../providers/student_provider.dart';
import '../models/student.dart';

class PaymentForm extends StatefulWidget {
  final Payment? initial;
  final int? fixedStudentId;
  const PaymentForm({super.key, this.initial, this.fixedStudentId});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();

  late int _studentId;
  late double _amount;
  DateTime _date = DateTime.now();
  bool _isPaid = true;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    if (p != null) {
      _studentId = p.student;
      _amount = p.amount;
      _date = p.date;
      _isPaid = p.isPaid;
    } else {
      _studentId = widget.fixedStudentId ?? 0;
      _amount = 0;
      _isPaid = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().items;

    return Scaffold(
      appBar: AppBar(title: Text(widget.initial == null ? 'إضافة دفعة' : 'تعديل دفعة')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                if (widget.fixedStudentId == null)
                  DropdownButtonFormField<int>(
                    value: _studentId == 0 ? null : _studentId,
                    decoration: const InputDecoration(labelText: 'الطالب'),
                    items: students.map((Student s) {
                      return DropdownMenuItem<int>(
                        value: s.id,
                        child: Text(s.name),
                      );
                    }).toList(),
                    validator: (v) => (v == null || v == 0) ? 'اختر الطالب' : null,
                    onChanged: (v) => _studentId = v ?? 0,
                  ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _amount == 0 ? '' : _amount.toString(),
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final n = double.tryParse(v?.trim() ?? '');
                    if (n == null || n <= 0) return 'أدخل مبلغًا صحيحًا';
                    return null;
                  },
                  onSaved: (v) => _amount = double.parse(v!.trim()),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('تاريخ الدفع'),
                  subtitle: Text(_date.toIso8601String().split('T').first),
                  trailing: const Icon(Icons.date_range),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('مدفوع'),
                  value: _isPaid,
                  onChanged: (v) => setState(() => _isPaid = v),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(widget.initial == null ? 'إضافة' : 'حفظ'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final pvd = context.read<PaymentProvider>();
    final payment = Payment(
      id: widget.initial?.id ?? 0,
      student: widget.fixedStudentId ?? _studentId,
      amount: _amount,
      date: _date,
      isPaid: _isPaid,
    );

    try {
      if (widget.initial == null) {
        final created = await pvd.create(payment);
        if (created == null) throw 'فشل الإضافة';
      } else {
        final updated = await pvd.update(payment);
        if (updated == null) throw 'فشل الحفظ';
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }
}
