import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Drawer(
      child: SafeArea(
        child: Center(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const ListTile(
                title: Text(
                  'الإعدادات العامة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
          
              // الثيم
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'الثيم',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              RadioListTile(
                title: const Text('اتّباع النظام'),
                value: AppThemeMode.system,
                groupValue: settings.themeMode,
                onChanged: (v) => settings.setThemeMode(v!),
              ),
              RadioListTile(
                title: const Text('فاتح'),
                value: AppThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (v) => settings.setThemeMode(v!),
              ),
              RadioListTile(
                title: const Text('داكن'),
                value: AppThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (v) => settings.setThemeMode(v!),
              ),
          
              const Divider(),
          
              // اللغة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'اللغة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              RadioListTile(
                title: const Text('افتراضي النظام'),
                value: AppLocale.system,
                groupValue: settings.locale,
                onChanged: (v) => settings.setLocale(v!),
              ),
              RadioListTile(
                title: const Text('العربية'),
                value: AppLocale.ar,
                groupValue: settings.locale,
                onChanged: (v) => settings.setLocale(v!),
              ),
              RadioListTile(
                title: const Text('English'),
                value: AppLocale.en,
                groupValue: settings.locale,
                onChanged: (v) => settings.setLocale(v!),
              ),
          
              const Divider(),
          
              // تحسينات تجربة المستخدم
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('اتجاه الكتابة (RTL/LTR)'),
                subtitle: const Text('يُحدّد تلقائيًا حسب اللغة المختارة'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الاتجاه يضبط تلقائيًا حسب اللغة'),
                    ),
                  );
                },
              ),
          
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('عن التطبيق'),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'مدرستي',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
