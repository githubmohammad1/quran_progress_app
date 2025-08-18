import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';



class AttendanceChart extends StatelessWidget {
  final Map<String, int> data;
  const AttendanceChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('لا توجد بيانات حضور لعرضها'));
    }

    final labels = data.keys.toList();
    final values = data.values.toList();

    final barGroups = List.generate(labels.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i].toDouble(),
            color: values[i] < 20 ? Colors.red : Colors.green,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return Column(
      children: [
        const Text(
          'مخطط حضور الطلاب',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (values.reduce((a, b) => a > b ? a : b) + 5).toDouble(),
              barGroups: barGroups,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          labels[index],
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, _) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
