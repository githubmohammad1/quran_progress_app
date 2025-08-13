// lib/screens/students_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';

import 'student_form.dart';

class StudentListScreen extends StatefulWidget {
  final String? title;
  const StudentListScreen({super.key, this.title});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<StudentProvider>().fetchAll(force: true));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StudentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'قائمة الطلاب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => p.fetchAll(force: true),
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (p.isLoading) return const Center(child: CircularProgressIndicator());
          if (p.error != null) return Center(child: Text('خطأ: ${p.error}'));
          final students = p.items;
          if (students.isEmpty) return const Center(child: Text('لا يوجد طلاب'));

          return RefreshIndicator(
            onRefresh: () => p.fetchAll(force: true),
            child: ListView.separated(
              itemCount: students.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final s = students[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(_avatarChar(s.name))),
                  title: Text(s.name),
                  subtitle: Text('هاتف: ${s.phoneNumber} • عمر: ${s.age}'),
                  onTap: () async {
                    final saved = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => StudentForm(initial: s)),
                    );
                    if (saved == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم الحفظ')),
                      );
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, s.id),
                    tooltip: 'حذف',
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final saved = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const StudentForm()),
          );
          if (saved == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تمت الإضافة')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة'),
      ),
    );
  }

  String _avatarChar(String name) =>
      name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف هذا الطالب؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok == true) {
      final success = await context.read<StudentProvider>().remove(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'تم الحذف' : 'فشل الحذف')),
        );
      }
    }
  }
}
