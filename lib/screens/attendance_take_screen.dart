import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../providers/attendance_provider.dart';
// import '../models/student.dart';
// import '../models/attendance.dart';

class AttendanceTakeScreen extends StatefulWidget {
  const AttendanceTakeScreen({super.key});

  @override
  State<AttendanceTakeScreen> createState() => _AttendanceTakeScreenState();
}

class _AttendanceTakeScreenState extends State<AttendanceTakeScreen> {
  late DateTime _date;
  late String _dayName;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _dayName = _getDayName(_date);

    Future.microtask(() async {
      // تحميل الطلاب
      await context.read<StudentProvider>().fetchAll();
      // تحميل حضور هذا اليوم (إن كان موجودًا سابقًا)
      await context.read<AttendanceProvider>().fetchAttendances(date: _date);
    });
  }

  String _getDayName(DateTime d) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[d.weekday - 1];
  }

  Future<void> _markPresent(int studentId) async {
    final pvd = context.read<AttendanceProvider>();
    final created = await pvd.markPresent(
      studentId: studentId,
      date: _date,
      dayName: _dayName,
    );
    if (!mounted) return;
    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تسجيل الحضور')),
      );
    } else {
      // نجاح
    }
  }

  Future<void> _unmarkPresent(int studentId) async {
    final pvd = context.read<AttendanceProvider>();
    final removed = await pvd.unmarkPresent(studentId: studentId, date: _date);
    if (!mounted) return;
    if (!removed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إلغاء الحضور')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().items;
    final attendancePvd = context.watch<AttendanceProvider>();
    final presentIds = attendancePvd.presentStudentIdsForDate(_date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الحضور اليومي'),
        actions: [
          // اختيار تاريخ آخر اختياريًا
          IconButton(
            tooltip: 'تغيير التاريخ',
            icon: const Icon(Icons.date_range),
            onPressed: () async {
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
                await attendancePvd.fetchAttendances(date: _date);
              }
            },
          ),
        ],
      ),
      body: attendancePvd.isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(child: Text('لا يوجد طلاب'))
              : ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, i) {
                    final s = students[i];
                    final isPresent = presentIds.contains(s.id);

                    return ListTile(
                      title: Text(s.name),
                      subtitle: Text(_date.toIso8601String().split('T').first),
                      trailing: isPresent
                          ? OutlinedButton.icon(
                              icon: const Icon(Icons.check, color: Colors.green),
                              label: const Text('حاضر', style: TextStyle(color: Colors.green)),
                              onPressed: () => _unmarkPresent(s.id), // لإلغاء الحضور عند الحاجة
                            )
                          : FilledButton.icon(
                              icon: const Icon(Icons.login),
                              label: const Text('حاضر'),
                              onPressed: () => _markPresent(s.id),
                            ),
                    );
                  },
                ),
    );
  }
}
