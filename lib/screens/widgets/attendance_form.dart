import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/student.dart';

class AttendanceForm extends StatefulWidget {
  final Attendance? initial;
  final int? fixedStudentId; // لو جاي من صفحة طالب
  const AttendanceForm({super.key, this.initial, this.fixedStudentId});

  @override
  State<AttendanceForm> createState() => _AttendanceFormState();
}

class _AttendanceFormState extends State<AttendanceForm> {
  final _formKey = GlobalKey<FormState>();

  late int _studentId;
  DateTime _date = DateTime.now();
  String _dayName = '';

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    if (a != null) {
      _studentId = a.student;
      _date = a.date;
      _dayName = a.dayName;
    } else {
      _studentId = widget.fixedStudentId ?? 0;
      _dayName = _getDayName(_date);
    }
  }

  String _getDayName(DateTime date) {
    // ممكن لاحقًا تستخدم أسماء أيام بالعربية
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().items;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'إضافة حضور' : 'تعديل حضور'),
      ),
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
                    if (picked != null) {
                      setState(() {
                        _date = picked;
                        _dayName = _getDayName(picked);
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _dayName,
                  decoration: const InputDecoration(labelText: 'اسم اليوم'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'أدخل اسم اليوم' : null,
                  onSaved: (v) => _dayName = v!.trim(),
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

    final pvd = context.read<AttendanceProvider>();
    final attendance = Attendance(
      id: widget.initial?.id ?? 0,
      student: widget.fixedStudentId ?? _studentId,
      date: _date,
      dayName: _dayName,
    );

    try {
      if (widget.initial == null) {
        final created = await pvd.create(attendance);
        if (created == null) throw 'فشل الإضافة';
      } else {
        final updated = await pvd.update(attendance);
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
