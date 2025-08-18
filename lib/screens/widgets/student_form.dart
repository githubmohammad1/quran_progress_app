// lib/screens/student_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../providers/student_provider.dart';

class StudentForm extends StatefulWidget {
  final Student? initial;
  const StudentForm({super.key, this.initial});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  String? _fatherName;
  String? _motherName;
  late int _age;
  DateTime _registrationDate = DateTime.now();
  String? _phoneNumber;
  String? _email;
  String? _address;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    if (s != null) {
      _name = s.name;
      _fatherName = s.fatherName;
      _motherName = s.motherName;
      _age = s.age;
      _registrationDate = s.registrationDate;
      _phoneNumber = s.phoneNumber;
      _email = s.email;
      _address = s.address;
    } else {
      _name = '';
      _age = 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'تعديل طالب' : 'إضافة طالب')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'اسم الطالب'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل الاسم' : null,
                  onSaved: (v) => _name = v!.trim(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _fatherName,
                  decoration: const InputDecoration(labelText: 'اسم الأب'),
                  onSaved: (v) => _fatherName = _nullable(v),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _motherName,
                  decoration: const InputDecoration(labelText: 'اسم الأم'),
                  onSaved: (v) => _motherName = _nullable(v),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _age.toString(),
                  decoration: const InputDecoration(labelText: 'العمر'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'أدخل عمرًا صحيحًا';
                    return null;
                  },
                  onSaved: (v) => _age = int.parse(v!),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('تاريخ التسجيل'),
                  subtitle: Text(_registrationDate.toIso8601String().split('T').first),
                  trailing: const Icon(Icons.date_range),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _registrationDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _registrationDate = picked);
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _phoneNumber,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  keyboardType: TextInputType.phone,
                  onSaved: (v) => _phoneNumber = _nullable(v),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _email,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (v) => _email = _nullable(v),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _address,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                  onSaved: (v) => _address = _nullable(v),
                ),
                const SizedBox(height: 16),
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

  String? _nullable(String? v) {
    if (v == null) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final p = context.read<StudentProvider>();
    final s = Student(
      id: widget.initial?.id ?? 0,
      name: _name,
      fatherName: _fatherName ?? '',
      motherName: _motherName ?? '',
      age: _age,
      registrationDate: _registrationDate,
      phoneNumber: _phoneNumber ?? '',
      email: _email ?? '',
      address: _address ?? '',
    );

    try {
      if (widget.initial == null) {
        final created = await p.create(s);
        if (created == null) throw 'فشل الإضافة';
      } else {
        final updated = await p.update(s);
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
