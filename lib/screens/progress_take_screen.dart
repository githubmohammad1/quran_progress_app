import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/student.dart';

class ProgressTakeScreen extends StatefulWidget {
  const ProgressTakeScreen({super.key});

  @override
  State<ProgressTakeScreen> createState() => _ProgressTakeScreenState();
}

class _ProgressTakeScreenState extends State<ProgressTakeScreen> {
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<StudentProvider>().fetchAll();
      await context.read<ProgressProvider>().fetchProgress(date: _date);
      await context.read<AttendanceProvider>().fetchAttendances(date: _date);
    });
  }

  // ---------- Actions ----------
  Future<void> _markProgress(int studentId, int pages) async {
    final created = await context.read<ProgressProvider>().markProgress(
          studentId: studentId,
          date: _date,
          pages: pages,
        );
    if (!mounted) return;
    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل التسميع لهذا الطالب اليوم بالفعل')),
      );
    }
  }

  Future<void> _removeProgress(int studentId) async {
    final ok = await context
        .read<ProgressProvider>()
        .removeByStudentAndDate(studentId, _date);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حذف التسميع')),
      );
    }
  }

  Future<void> _markAttendance(int studentId) async {
    final dayName = _getDayName(_date);
    await context.read<AttendanceProvider>().markPresent(
          studentId: studentId,
          date: _date,
          dayName: dayName,
        );
  }

  String _getDayName(DateTime date) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[date.weekday - 1];
  }

  void _pickPagesAndMark(int studentId) async {
    final pages = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => const _PagesPicker(),
    );
    if (pages != null) {
      await _markProgress(studentId, pages);
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().items;
    final progPvd = context.watch<ProgressProvider>();
    final attPvd = context.watch<AttendanceProvider>();

    final recordedProgress = progPvd.recordedStudentIdsForDate(_date);
    final presentAttendance = attPvd.presentStudentIdsForDate(_date);

    // Stats
    final dateStr = _date.toIso8601String().split('T').first;
    final totalPresent = presentAttendance.length;
    final totalPages = progPvd.items
        .where((p) => p.date.toIso8601String().split('T').first == dateStr)
        .fold<int>(0, (sum, p) => sum + p.pagesListened);
    final totalListenedStudents = recordedProgress.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل التسميع'),
        actions: [
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
                setState(() => _date = picked);
                await progPvd.fetchProgress(date: _date);
                await attPvd.fetchAttendances(date: _date);
              }
            },
          ),
        ],
      ),
      body: progPvd.isLoading || attPvd.isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(child: Text('لا يوجد طلاب'))
              : Column(
                  children: [
                    // Stats bar
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      color: Colors.blueGrey.shade50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatCard(label: 'الحاضرين', value: '$totalPresent', color: Colors.green),
                          _StatCard(label: 'إجمالي الصفحات', value: '$totalPages', color: Colors.blue),
                          _StatCard(label: 'طلاب سمعوا', value: '$totalListenedStudents', color: Colors.orange),
                        ],
                      ),
                    ),
                    const Divider(height: 0),
                    // List
                    Expanded(
                      child: ListView.separated(
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const Divider(height: 0),
                        itemBuilder: (context, i) {
                          final s = students[i];
                          final isProgressRecorded = recordedProgress.contains(s.id);
                          final isPresent = presentAttendance.contains(s.id);

                          return ListTile(
                            title: Text(s.name),
                            subtitle: Row(
                              children: [
                                Text(dateStr),
                                const SizedBox(width: 16),
                                isPresent
                                    ? const Text('✅ حاضر', style: TextStyle(color: Colors.green))
                                    : TextButton(
                                        onPressed: () => _markAttendance(s.id),
                                        child: const Text('تسجيل حضور'),
                                      ),
                              ],
                            ),
                            trailing: isProgressRecorded
                                ? OutlinedButton.icon(
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    label: const Text('مُسجَّل', style: TextStyle(color: Colors.green)),
                                    onPressed: () => _removeProgress(s.id),
                                  )
                                : FilledButton.icon(
                                    icon: const Icon(Icons.library_books),
                                    label: const Text('تسميع'),
                                    onPressed: () => _pickPagesAndMark(s.id),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _PagesPicker extends StatelessWidget {
  const _PagesPicker({super.key});

  @override
  Widget build(BuildContext context) {
    const pages = [1, 2, 3, 4, 5];
    return SafeArea(
      child: Wrap(
        children: [
          const ListTile(
            title: Text('اختر عدد الصفحات المسموعة'),
          ),
          for (final p in pages)
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: Text('$p صفحة'),
              onTap: () => Navigator.pop<int>(context, p),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
