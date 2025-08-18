import 'package:flutter/material.dart';

import 'widgets/app_drawer.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> actions = [
      {'label': '📖 تسجيل تسميع الطالب', 'route': '/recordRecitation'},
      {'label': '🕋 تسجيل حضور', 'route': '/recordAttendance'},
      {'label': '📢 إضافة إعلان', 'route': '/addAnnouncement'},
      {'label': '💰 تسجيل الدفعات الشهرية', 'route': '/recordPayments'},
      {'label': '📋 قائمة الطلاب', 'route': '/viewStudent'},
      {'label': '📝 الاختبارات', 'route': '/tests'},
      {'label': '📅 جدول الحضور', 'route': '/table'},

    ];

    return Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('لوحة تحكم المعلم'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            itemCount: actions.length,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,       // عمودان
              crossAxisSpacing: 12,    // مسافة أفقية
              mainAxisSpacing: 12,     // مسافة عمودية
              childAspectRatio: 1,     // مربع
            ),
            itemBuilder: (context, index) {
              final item = actions[index];
              return GestureDetector(
                onTap: () => navigateTo(context, item['route']!),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item['label']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

  }
}
