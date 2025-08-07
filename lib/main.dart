import 'package:flutter/material.dart';
import 'package:quran_progress_app/screens/login_screen.dart';
import 'package:quran_progress_app/screens/parent_dashboard.dart';
import 'package:quran_progress_app/screens/teacher_dashboard.dart';

void main() {
  runApp(const MosqueApp());
}

class MosqueApp extends StatelessWidget {
  const MosqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق المسجد',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/teacher': (context) => const TeacherDashboard(),
        '/parent': (context) => const ParentDashboard(),
        // لاحقًا نضيف باقي الشاشات هنا
      },
    );
  }
}
