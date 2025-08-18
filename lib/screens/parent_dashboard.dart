import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/announcement_provider.dart';
import 'widgets/app_drawer.dart';


class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    // الأزرار السفلية
    final List<Map<String, String>> actions = [
      {'label': '📝 الاختبارات', 'route': '/tests'},
      {'label': '📅 جدول الحضور', 'route': '/table'},
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('📚 ولي الأمر'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // 🔹 قسم عرض الإعلانات
            SizedBox(
              height: 110,
              child: Consumer<AnnouncementProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.items.isEmpty) {
                    return const Center(child: Text('لا توجد إعلانات حالياً'));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.items.length,
                    itemBuilder: (context, index) {
                      final ad = provider.items[index];
                      return Container(
                        width: 250,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.title, // عنوان الإعلان
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                ad.content, // محتوى الإعلان
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 شبكة الأزرار
            Expanded(
              child: GridView.builder(
                itemCount: actions.length,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
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
          ],
        ),
      ),
    );
  }
}
