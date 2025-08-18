import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/attendance.dart';
import '../providers/attendance_provider.dart';
import '../providers/student_provider.dart';

class AttendanceTable extends StatefulWidget {
  const AttendanceTable({super.key});

  @override
  State<AttendanceTable> createState() => _AttendanceTableState();
}

class _AttendanceTableState extends State<AttendanceTable> {
  String searchQuery = "";
  String sortColumn = "name";
  bool ascending = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<StudentProvider>().fetchAll();
      await context.read<AttendanceProvider>().fetchAttendances();
    });
  }

  void sortBy(String column) {
    setState(() {
      if (sortColumn == column) {
        ascending = !ascending;
      } else {
        sortColumn = column;
        ascending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final studentProvider = context.watch<StudentProvider>();

    if (attendanceProvider.isLoading || studentProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final attendances = attendanceProvider.items;
    final students = studentProvider.items;

    if (students.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("لا يوجد طلاب")),
      );
    }

    if (attendances.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("لا توجد بيانات حضور بعد")),
      );
    }

    // 🔹 تجميع حسب السنة → الشهر
    final Map<int, Map<int, List<DateTime>>> groupedDates = {};
    for (var a in attendances) {
      final year = a.date.year;
      final month = a.date.month;
      groupedDates.putIfAbsent(year, () => {});
      groupedDates[year]!.putIfAbsent(month, () => []);
      if (!groupedDates[year]![month]!.contains(a.date)) {
        groupedDates[year]![month]!.add(a.date);
      }
    }

    // ترتيب السنوات تنازلياً والأشهر تنازلياً
    final sortedYears = groupedDates.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text("جدول الحضور"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // مربع البحث
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "بحث عن طالب",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          ...sortedYears.map((year) {
            final monthsMap = groupedDates[year]!;
            final sortedMonths = monthsMap.keys.toList()..sort((a, b) => b.compareTo(a));

            return ExpansionTile(
              title: Text(
                year.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              children: sortedMonths.map((month) {
                final monthDates = monthsMap[month]!..sort((a, b) => a.compareTo(b));

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                        child: Text(
                          DateFormat('MMMM', 'ar').format(DateTime(year, month)),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      _buildMonthTable(
                        attendances,
                        students,
                        monthDates,
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMonthTable(List<Attendance> attendances, List students, List<DateTime> uniqueDates) {
    // فلترة الطلاب بالبحث
    var filteredStudents = students
        .where((s) => s.name.contains(searchQuery))
        .toList();

    // فرز حسب العمود المحدد
    filteredStudents.sort((a, b) {
      if (sortColumn == "name") {
        return ascending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name);
      } else if (sortColumn == "percentage") {
        double pa = _calculatePercentage(a.id, attendances, uniqueDates);
        double pb = _calculatePercentage(b.id, attendances, uniqueDates);
        return ascending ? pa.compareTo(pb) : pb.compareTo(pa);
      }
      return 0;
    });

    final tableRows = <TableRow>[];

    // الصف الأول: أزرار فرز للتاريخ والاسم والنسبة
    tableRows.add(TableRow(
      children: [
        _sortableHeader("الطالب", "name"),
        ...uniqueDates.map((date) => _headerCell(
              DateFormat('yyyy-MM-dd').format(date),
              fontSize: 11,
            )),
        _sortableHeader("النسبة", "percentage"),
      ],
    ));

    // الصف الثاني: الأيام
    tableRows.add(TableRow(
      children: [
        const SizedBox.shrink(),
        ...uniqueDates.map((date) => _headerCell(
              DateFormat('EEEE', 'ar').format(date),
              fontSize: 10,
              fontWeight: FontWeight.normal,
            )),
        const SizedBox.shrink(),
      ],
    ));

    // الصفوف: الطلاب
    for (var student in filteredStudents) {
      double percentage = _calculatePercentage(student.id, attendances, uniqueDates);
      final studentData = attendances.where((a) => a.student == student.id).toList();

      tableRows.add(TableRow(children: [
        _cell(student.name, bgColor: Colors.grey.shade200, fontWeight: FontWeight.bold),
        ...uniqueDates.map((date) {
          final record = studentData.firstWhere(
            (a) => a.date == date,
            orElse: () => Attendance.empty(),
          );
          bool? isPresent = record.isPresent;
          Color bg;
          String icon;
          if (isPresent == true) {
            bg = Colors.green.shade100;
            icon = '✅';
          } else if (isPresent == false) {
            bg = Colors.red.shade100;
            icon = '❌';
          } else {
            bg = Colors.grey.shade100;
            icon = '-';
          }
          return _cell(icon, bgColor: bg);
        }),
        _cell(
          "${percentage.toStringAsFixed(1)}%",
          bgColor: percentage >= 80
              ? Colors.green.shade100
              : percentage >= 50
                  ? Colors.yellow.shade100
                  : Colors.red.shade100,
          fontWeight: FontWeight.bold,
        ),
      ]));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade400),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows,
      ),
    );
  }

  Widget _sortableHeader(String text, String columnKey) {
    return InkWell(
      onTap: () => sortBy(columnKey),
      child: _headerCell(
        "$text ${sortColumn == columnKey ? (ascending ? '↑' : '↓') : ''}",
      ),
    );
  }

  double _calculatePercentage(
      int studentId, List<Attendance> attendances, List<DateTime> uniqueDates) {
    int totalDays = uniqueDates.length;
    int attendedDays = attendances
        .where((a) => a.student == studentId && uniqueDates.contains(a.date) && a.isPresent == true)
        .length;
    return totalDays > 0 ? (attendedDays / totalDays) * 100 : 0;
  }

  Widget _headerCell(String text,
      {double fontSize = 12, FontWeight fontWeight = FontWeight.bold}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        textAlign: TextAlign.center,
      ),
    );
  }

 Widget _cell(String text,
      {Color? bgColor, FontWeight fontWeight = FontWeight.normal}) {
    return Container(
      color: bgColor ?? Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: fontWeight),
        textAlign: TextAlign.center,
      ),
    );
  }
}