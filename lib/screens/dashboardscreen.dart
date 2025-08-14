// dashboard_screen.dart


import 'package:flutter/material.dart';

import 'app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  final String title;
  final List<Map<String, String>> actions;

  const DashboardScreen({
    super.key,
    required this.title,
    required this.actions,
  });



  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      // endDrawer: const AppDrawer(),
         appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        // اختياري: ضبط لون الأيقونات
        iconTheme: Theme.of(context).iconTheme,
        actions: const [
          // ضع أزرارك هنا إن رغبت
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final item = actions[index];
            return InkWell(
              onTap: () => _navigateTo(context, item['route']!),
              borderRadius: BorderRadius.circular(12),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      item['label']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
