import 'package:flutter/material.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {'label': '📖 تسجيل تسميع الطالب', 'route': '/recordRecitation'},
      {'label': '🕋 تسجيل حضور', 'route': '/recordAttendance'},
      {'label': '📝 تسجيل اختبار', 'route': '/recordExam'},
      {'label': '➕ إضافة طالب', 'route': '/addStudent'},
      {'label': '🗑️ حذف طالب', 'route': '/deleteStudent'},
      {'label': '✏️ تعديل بيانات طالب', 'route': '/editStudent'},
      {'label': '📢 إضافة إعلان', 'route': '/addAnnouncement'},
      {'label': '💰 تسجيل الدفعات الشهرية', 'route': '/recordPayments'},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('لوحة تحكم المعلم'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // صفين
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final item = actions[index];
            return ElevatedButton(
              onPressed: () => navigateTo(context, item['route']),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(12)),
              child: Text(
                item['label'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }
}
