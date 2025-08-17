import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/test.dart';
import '../../providers/tests_provider.dart';
import '../../providers/student_provider.dart';

class TestForm extends StatefulWidget {
  final Test? initial;
  const TestForm({super.key, this.initial});

  @override
  State<TestForm> createState() => _TestFormState();
}

class _TestFormState extends State<TestForm> {
  final _formKey = GlobalKey<FormState>();

  late int _studentId;
  late int _partNumber;
  String _grade = 'جيد';
  DateTime _date = DateTime.now();
  String? _note;

  @override
  void initState() {
    super.initState();
    // تحميل قائمة الطلاب إذا لم تكن محملة
    Future.microtask(() => context.read<StudentProvider>().fetchAll());

    if (widget.initial != null) {
      final t = widget.initial!;
      _studentId = t.student;
      _partNumber = t.partNumber;
      _grade = t.grade;
      _date = t.date;
      _note = t.note;
    } else {
      _studentId = 0; // سيتم اختيار الطالب لاحقًا
      _partNumber = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final grades = const ['جيد', 'جيد جدًا', 'ممتاز'];
    final isEdit = widget.initial != null;

    final students = context.watch<StudentProvider>().items;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل اختبار' : 'إضافة اختبار'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // اختيار الطالب من القائمة
                DropdownButtonFormField<int>(
                  value: _studentId > 0 ? _studentId : null,
                  decoration: const InputDecoration(labelText: 'اسم الطالب'),
                  items: students
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ))
                      .toList(),
                  validator: (v) =>
                      v == null || v <= 0 ? 'اختر الطالب' : null,
                  onChanged: (v) => setState(() => _studentId = v ?? 0),
                ),

                const SizedBox(height: 8),

                // رقم الجزء
                TextFormField(
                  initialValue: _partNumber.toString(),
                  decoration: const InputDecoration(labelText: 'رقم الجزء'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'أدخل رقم الجزء';
                    final n = int.tryParse(v);
                    if (n == null || n <= 0) return 'رقم غير صالح';
                    return null;
                  },
                  onSaved: (v) => _partNumber = int.parse(v!),
                ),

                const SizedBox(height: 8),

                // التقدير
                DropdownButtonFormField<String>(
                  value: _grade,
                  decoration: const InputDecoration(labelText: 'التقدير'),
                  items: grades
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _grade = v ?? _grade),
                ),

                const SizedBox(height: 8),

                // التاريخ
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('التاريخ'),
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

                // ملاحظة
                TextFormField(
                  initialValue: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'ملاحظة (اختياري)'),
                  onSaved: (v) =>
                      _note = (v?.trim().isEmpty ?? true) ? null : v!.trim(),
                ),

                const SizedBox(height: 16),

                // زر الحفظ
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(isEdit ? 'حفظ' : 'إضافة'),
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

    final provider = context.read<TestsProvider>();
    final test = Test(
      id: widget.initial?.id ?? 0,
      student: _studentId,
      partNumber: _partNumber,
      grade: _grade,
      date: _date,
      note: _note,
    );

    try {
      if (widget.initial == null) {
        await provider.create(test);
      } else {
        await provider.update(test);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الحفظ: $e')),
      );
    }
  }
}
