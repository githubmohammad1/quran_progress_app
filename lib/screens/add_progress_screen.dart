import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../models/progress.dart';

class AddProgressScreen extends StatefulWidget {
  const AddProgressScreen({super.key});

  @override
  State<AddProgressScreen> createState() => _AddProgressScreenState();
}

class _AddProgressScreenState extends State<AddProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  int student = 1;
  String date = '';
  int pages = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProgressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('أضف تقدم جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'رقم الطالب'),
                keyboardType: TextInputType.number,
                onSaved: (v) => student = int.parse(v!),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'التاريخ (YYYY-MM-DD)',
                ),
                onSaved: (v) => date = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'عدد الصفحات'),
                keyboardType: TextInputType.number,
                onSaved: (v) => pages = int.parse(v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('إرسال'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    provider
                        .addProgress(
                          Progress(
                            id: 0,
                            student: student,
                            date: date,
                            pagesListened: pages,
                          ),
                        )
                        .then((_) => Navigator.pop(context));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
