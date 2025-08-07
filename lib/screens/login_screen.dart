import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = '';
  final TextEditingController teacherNameController = TextEditingController();
  final TextEditingController teacherPasswordController =
      TextEditingController();
  final TextEditingController studentNameController = TextEditingController();

  void handleLogin() {
    if (selectedRole == 'teacher') {
      // تحقق من البيانات لاحقًا
      Navigator.pushNamed(context, '/teacher');
    } else if (selectedRole == 'parent') {
      // تحقق من اسم الطالب لاحقًا
      Navigator.pushNamed(context, '/parent');
    }
  }

  Widget buildRoleButton(String label, IconData icon, String roleKey) {
    final isSelected = selectedRole == roleKey;
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        backgroundColor: isSelected ? Colors.green : null,
      ),
      onPressed: () {
        setState(() {
          selectedRole = roleKey;
        });
      },
    );
  }

  Widget buildInputFields() {
    if (selectedRole == 'teacher') {
      return Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: teacherNameController,
            decoration: InputDecoration(
              labelText: 'اسم المعلم',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: teacherPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    } else if (selectedRole == 'parent') {
      return Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: studentNameController,
            decoration: InputDecoration(
              labelText: 'اسم الطالب',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Text(
                '📖 تطبيق المسجد',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Text('👤 اختر نوع الدخول', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 30),
              buildRoleButton('دخول كولي أمر', Icons.family_restroom, 'parent'),
              const SizedBox(height: 20),
              buildRoleButton('دخول كمعلم', Icons.school, 'teacher'),
              buildInputFields(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
