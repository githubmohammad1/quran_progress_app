import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/announcement_provider.dart';

import 'announcement_form.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<AnnouncementProvider>().fetchAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pvd = context.watch<AnnouncementProvider>();
    final items = pvd.items;

    return Scaffold(
      appBar: AppBar(title: const Text('الإعلانات')),
      body: pvd.isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('لا توجد إعلانات'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, i) {
                    final a = items[i];
                    final dateText = a.date.toIso8601String().split('T').first;
                    return Dismissible(
                      key: ValueKey('ann_${a.id}'),
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
                                title: const Text('حذف الإعلان؟'),
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
                        await context.read<AnnouncementProvider>().remove(a.id);
                      },
                      child: ListTile(
                        title: Text(a.title),
                        subtitle: Text(
                          '${a.content.length > 80 ? a.content.substring(0, 80) + '…' : a.content}\n$dateText',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        onTap: () async {
                          final ok = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnnouncementForm(initial: a),
                            ),
                          );
                          if (ok == true) {
                            await context.read<AnnouncementProvider>().fetchAnnouncements();
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
            MaterialPageRoute(builder: (_) => const AnnouncementForm()),
          );
          if (ok == true) {
            await context.read<AnnouncementProvider>().fetchAnnouncements();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة إعلان'),
      ),
    );
  }
}
