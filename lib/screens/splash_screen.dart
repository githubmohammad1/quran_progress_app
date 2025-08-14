// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

import 'parent_dashboard.dart';
import 'teacher_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkCredentials();
  }

  Future<void> _checkCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');

    await Future.delayed(const Duration(seconds: 1)); // عرض دائرة التحميل

    if (!mounted) return;

    if (savedUsername != null && savedPassword != null) {
      if (savedPassword == teacherSecret) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherDashboard(
            //     title: 'لوحة تحكم المعلم',
            // actions: teacherActions,
            ),
          ),
        );
        return;
      } else if (savedPassword == parentSecret) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ParentDashboard(
              // title: 'لوحة تحكم ولي الأمر',
              // actions: parentActions,
            ),
          ),
        );
        return;
      }
    }

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
