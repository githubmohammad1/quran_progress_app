import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/test.dart';
import '../../providers/tests_provider.dart';
import '../../providers/student_provider.dart';

import 'widgets/test_form.dart';

class TestsListScreen extends StatefulWidget {
  const TestsListScreen({super.key});

  @override
  State<TestsListScreen> createState() => _TestsListScreenState();
}

class _TestsListScreenState extends State<TestsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<StudentProvider>().fetchAll();
      await context.read<TestsProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الاختبارات')),
      body: Consumer2<TestsProvider, StudentProvider>(
        builder: (context, testsPvd, studentsPvd, _) {
          if (testsPvd.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (testsPvd.error != null) {
            return _buildError(testsPvd);
          }
          if (testsPvd.items.isEmpty) {
            return const Center(child: Text('لا توجد اختبارات بعد'));
          }

          // -------- التجميع حسب اسم الطالب --------
          final grouped = <String, List<Test>>{};
          for (final t in testsPvd.items) {
            final studentName = studentsPvd.getById(t.student)?.name ?? 'غير معروف';
            grouped.putIfAbsent(studentName, () => []).add(t);
          }
          final studentNames = grouped.keys.toList();

          return RefreshIndicator(
            onRefresh: testsPvd.fetch,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 88, left: 8, right: 8, top: 8),
              itemCount: studentNames.length,
              itemBuilder: (context, groupIndex) {
                final name = studentNames[groupIndex];
                final tests = grouped[name]!;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ExpansionTile(
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    children: tests.map((t) {
                      return ListTile(
                        title: Text('جزء: ${t.partNumber}'),
                        subtitle: Text(
                          'التقدير: ${t.grade} • التاريخ: ${_fmtDate(t.date)}'
                          '${t.note != null && t.note!.isNotEmpty ? ' • ملاحظة: ${t.note}' : ''}',
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TestForm(initial: t)),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(context, t, name),
                          tooltip: 'حذف',
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TestForm()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة'),
      ),
    );
  }

  Widget _buildError(TestsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: provider.fetch,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => d.toIso8601String().split('T').first;

  Future<void> _confirmDelete(BuildContext context, Test t, String studentName) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف اختبار الجزء ${t.partNumber} للطالب $studentName؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<TestsProvider>().delete(t.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الاختبار')),
        );
      }
    }
  }
}
