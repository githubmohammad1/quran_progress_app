import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/student_provider.dart';

import 'attendance_form.dart';

class AttendancesScreen extends StatefulWidget {
  final int? studentId; // اختياري: عرض حضور طالب محدد
  const AttendancesScreen({super.key, this.studentId});

  @override
  State<AttendancesScreen> createState() => _AttendancesScreenState();
}

class _AttendancesScreenState extends State<AttendancesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // تحميل الطلاب لاستخدامهم في الفورم/العرض
      await context.read<StudentProvider>().fetchAll();
      await context.read<AttendanceProvider>().fetchAttendances();
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendancePvd = context.watch<AttendanceProvider>();
    final studentPvd = context.watch<StudentProvider>();

    // إن أردت الفلترة في الواجهة (بدون API)
    final items = widget.studentId == null
        ? attendancePvd.items
        : attendancePvd.items.where((a) => a.student == widget.studentId).toList();

    String studentNameOf(int studentId) {
      final i = studentPvd.items.indexWhere((s) => s.id == studentId);
      return i == -1 ? 'غير معروف' : studentPvd.items[i].name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentId == null ? 'سجل الحضور' : 'حضور الطالب'),
      ),
      body: attendancePvd.isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('لا توجد سجلات حضور'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, i) {
                    final a = items[i];
                    final dateText = a.date.toIso8601String().split('T').first;
                    final stName = studentNameOf(a.student);

                    return Dismissible(
                      key: ValueKey('att_${a.id}'),
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
                                title: const Text('حذف السجل؟'),
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
                        await context.read<AttendanceProvider>().remove(a.id);
                      },
                      child: ListTile(
                        title: Text('$dateText • ${a.dayName}'),
                        subtitle: Text(stName),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () async {
                          final ok = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AttendanceForm(
                                initial: a,
                                fixedStudentId: a.student,
                              ),
                            ),
                          );
                          if (ok == true) {
                            await context.read<AttendanceProvider>().fetchAttendances();
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
              builder: (_) => AttendanceForm(
                fixedStudentId: widget.studentId,
              ),
            ),
          );
          if (ok == true) {
            await context.read<AttendanceProvider>().fetchAttendances();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة حضور'),
      ),
    );
  }
}
