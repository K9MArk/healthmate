import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StepsLineChart extends StatelessWidget {
  final List<String> labels; // e.g. ['Mon', 'Tue', 'Wed', ...]
  final List<double> values; // e.g. [5000, 7200, 6500, ...]

  const StepsLineChart({super.key, required this.labels, required this.values});

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty || values.isEmpty || labels.length != values.length) {
      return const Center(
        child: Text(
          'Not enough data to show chart',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final spots = <FlSpot>[];
    double maxY = 0;

    for (var i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
      if (values[i] > maxY) maxY = values[i];
    }

    // Add some headroom on top
    maxY = maxY == 0 ? 1 : maxY * 1.2;

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              top: BorderSide.none,
              right: BorderSide.none,
              left: BorderSide(color: Colors.grey),
              bottom: BorderSide(color: Colors.grey),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      labels[index],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
