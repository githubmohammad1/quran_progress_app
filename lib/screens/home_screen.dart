import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_progress_app/sendApiReques.dart';
import '../providers/progress_provider.dart';
// import 'add_progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('تقدم الاستماع')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.items.length,
              itemBuilder: (_, i) {
                final p = provider.items[i];
                return ListTile(
                  title: Text('Student ${p.student} – ${p.date}'),
                  subtitle: Text('Pages: ${p.pagesListened}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await sendMultipartRequest(
            url: 'http://127.0.0.1:8000/api/v1/students/',
            method: 'POST',
            token: '096a21d2781f7f1c1ed2a576c58beda455d20237',
            body: {
              'name': 'محمد',
              'father_name': 'أحمد',
              'mother_name': 'فاطمة',
              'age': '15',
              'registration_date': '2025-08-05',
              'phone_number': '0551234567',
              'email': 'mohammad@example.com',
              'address': 'الرياض',
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
