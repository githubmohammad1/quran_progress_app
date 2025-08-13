import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/announcement.dart';
import '../providers/announcement_provider.dart';

class AnnouncementForm extends StatefulWidget {
  final Announcement? initial;
  const AnnouncementForm({super.key, this.initial});

  @override
  State<AnnouncementForm> createState() => _AnnouncementFormState();
}

class _AnnouncementFormState extends State<AnnouncementForm> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _content;

  @override
  void initState() {
    super.initState();
    _title = widget.initial?.title ?? '';
    _content = widget.initial?.content ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final dateText = widget.initial?.date.toIso8601String().split('T').first;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'إضافة إعلان' : 'تعديل إعلان'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'أدخل العنوان' : null,
                  onSaved: (v) => _title = v!.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _content,
                  decoration: const InputDecoration(labelText: 'نص الإعلان'),
                  maxLines: 6,
                  validator: (v) => v == null || v.trim().isEmpty ? 'أدخل نص الإعلان' : null,
                  onSaved: (v) => _content = v!.trim(),
                ),
                if (dateText != null) ...[
                  const SizedBox(height: 12),
                  Text('التاريخ: $dateText', style: const TextStyle(color: Colors.grey)),
                ],
                const SizedBox(height: 20),
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

    final pvd = context.read<AnnouncementProvider>();
    final a = Announcement(
      id: widget.initial?.id ?? 0,
      title: _title,
      content: _content,
      date: widget.initial?.date ?? DateTime.now(), // للعرض فقط
    );

    try {
      if (widget.initial == null) {
        final created = await pvd.create(a);
        if (created == null) throw 'فشل الإضافة';
      } else {
        final updated = await pvd.update(a);
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
