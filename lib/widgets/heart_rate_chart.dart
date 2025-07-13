import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HeartRateChart extends StatelessWidget {
  final List<FlSpot> data;

  const HeartRateChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 50,
        maxY: 150,
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            color: Colors.redAccent,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false),
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}
