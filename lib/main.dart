import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/announcement_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/progress_provider.dart';
import 'screens/announcements_screen.dart';
import 'screens/attendance_take_screen.dart';
// import 'screens/attendancesScreen.dart';
import 'screens/new_table.dart';
import 'screens/payments_screen.dart';
import 'screens/progress_take_screen.dart';
import 'screens/tests_list_screen.dart';
import 'screens/widgets/flutter_chart.dart';
import 'services/api_service.dart';
import 'providers/tests_provider.dart';
import 'providers/student_provider.dart';


import 'screens/login_screen.dart';
import 'screens/parent_dashboard.dart';
import 'screens/widgets/settings_controller.dart';
// import 'screens/splash_screen.dart';
import 'screens/students_list_screen.dart';
import 'screens/teacher_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController();
  await settingsController.init();

runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsController>.value(
        value: settingsController,
      ),

      Provider<ApiService>(
        create: (_) => ApiService(
          baseUrl: 'https://mohammadpythonanywher1.pythonanywhere.com/api/v1/',
        ),
      ),

      ChangeNotifierProvider<StudentProvider>(
        create: (ctx) => StudentProvider(ctx.read<ApiService>()),
      ),
      ChangeNotifierProvider<TestsProvider>(
        create: (ctx) => TestsProvider(ctx.read<ApiService>()),
      ),
      ChangeNotifierProvider<PaymentProvider>(
        create: (ctx) => PaymentProvider(ctx.read<ApiService>()),
      ),
      ChangeNotifierProvider<AttendanceProvider>(
        create: (ctx) => AttendanceProvider(ctx.read<ApiService>()),
      ),
   ChangeNotifierProvider<ProgressProvider>(
        create: (ctx) => ProgressProvider(ctx.read<ApiService>()),
      ),
       ChangeNotifierProvider<AnnouncementProvider>(
        create: (ctx) => AnnouncementProvider(ctx.read<ApiService>()),
      ),
    ],
    child: const MyApp(),
  ),
);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدرستي',
      themeMode: settings.materialThemeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        // fontFamily: 'Roboto',
      ),
      locale: settings.materialLocale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      home: ParentDashboard(),
      routes: {
        '/parentDashboard': (_) => const ParentDashboard(),
        '/login': (_) => const LoginScreen(),
        '/recordRecitation': (_) => const ProgressTakeScreen(),
        '/recordAttendance': (_) => const AttendanceTakeScreen(),
        '/addStudent': (_) => const StudentListScreen(title: 'إضافة طالب'),
        '/addAnnouncement': (_) => const AnnouncementsScreen(),
        '/recordPayments': (_) => const PaymentsScreen(),
        '/viewStudent': (_) => const StudentListScreen(title: 'طلابنا'),
        '/teacherDashboard': (_) => const TeacherDashboard(),
        
        '/tests': (_) => const TestsListScreen(),
        '/fl_chart': (_) => AttendanceChart(data:{}),
        '/table': (_) => const AttendanceTable()
      },
    );
  }
}
//sssssssssssssssssssssssssssssssssssssssss