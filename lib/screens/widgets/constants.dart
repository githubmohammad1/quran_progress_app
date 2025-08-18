// constants.dart

// كلمات السر لتحديد الدور
const String teacherSecret = 'teacher123';
const String parentSecret = 'parent123';

// قوائم إجراءات المعلم
const List<Map<String, String>> teacherActions = [
  {'label': '📖 تسجيل تسميع الطالب', 'route': '/recordRecitation'},
  {'label': '🕋 تسجيل حضور', 'route': '/recordAttendance'},
  {'label': '📝 تسجيل اختبار', 'route': '/recordExam'},
  {'label': '➕ إضافة طالب', 'route': '/addStudent'},
  {'label': '🗑️ حذف طالب', 'route': '/deleteStudent'},
  {'label': '✏️ تعديل بيانات طالب', 'route': '/editStudent'},
  {'label': '📢 إضافة إعلان', 'route': '/addAnnouncement'},
  {'label': '💰 تسجيل الدفعات الشهرية', 'route': '/recordPayments'},
];

// قوائم إجراءات ولي الأمر
const List<Map<String, String>> parentActions = [
  {'label': '📄 عرض تقرير الطالب', 'route': '/viewReport'},
  {'label': '📢 الاطلاع على الإعلانات', 'route': '/viewAnnouncements'},
  {'label': '📅 جدول الحصص', 'route': '/viewSchedule'},
];
