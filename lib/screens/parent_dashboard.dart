import 'package:flutter/material.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📚 ولي الأمر'), centerTitle: true),
      body: Column(
        children: [
          // 🟢 الإعلانات
          Container(
            width: double.infinity,
            color: Colors.yellow[100],
            padding: EdgeInsets.all(12),
            child: Text(
              '📢 إعلان: سيتم إقامة مسابقة حفظ يوم الجمعة القادمة',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // 🕋 حضور الطلاب
                Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline),
                    title: Text('حضور الطلاب'),
                    onTap: () {
                      // TODO: الانتقال إلى شاشة عرض الحضور
                    },
                  ),
                ),

                // 📝 جدول الاختبارات
                Card(
                  child: ListTile(
                    leading: Icon(Icons.calendar_month),
                    title: Text('جدول الاختبارات'),
                    onTap: () {
                      // TODO: الانتقال إلى شاشة عرض الاختبارات
                    },
                  ),
                ),

                // 📖 جدول تسميع الطالب
                Card(
                  child: ListTile(
                    leading: Icon(Icons.menu_book),
                    title: Text('جدول تسميع الطالب'),
                    onTap: () {
                      // TODO: الانتقال إلى شاشة عرض التسميع
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
