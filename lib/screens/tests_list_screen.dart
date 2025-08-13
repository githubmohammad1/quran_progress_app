import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/test.dart';
import '../../providers/tests_provider.dart';

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
    // تحميل القائمة عند الدخول
    Future.microtask(() => context.read<TestsProvider>().fetch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الاختبارات')),
      body: Consumer<TestsProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
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
          if (provider.items.isEmpty) {
            return const Center(child: Text('لا توجد اختبارات بعد'));
          }

          return RefreshIndicator(
            onRefresh: provider.fetch,
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 88, left: 8, right: 8, top: 8),
              itemCount: provider.items.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final t = provider.items[index];
                return ListTile(
                  title: Text('طالب: ${t.student} | جزء: ${t.partNumber}'),
                  subtitle: Text('التقدير: ${t.grade} • التاريخ: ${_fmtDate(t.date)}'
                      '${t.note != null && t.note!.isNotEmpty ? ' • ملاحظة: ${t.note}' : ''}'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TestForm(initial: t)),
                    );
                    // بعد الرجوع، القائمة تكون محدّثة بواسطة المزود
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, t),
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
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TestForm()),
          );
          // بعد الرجوع، القائمة تكون محدّثة بواسطة المزود
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة'),
      ),
    );
  }

  String _fmtDate(DateTime d) => d.toIso8601String().split('T').first;

  Future<void> _confirmDelete(BuildContext context, Test t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف اختبار الجزء ${t.partNumber} للطالب ${t.student}?'),
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
