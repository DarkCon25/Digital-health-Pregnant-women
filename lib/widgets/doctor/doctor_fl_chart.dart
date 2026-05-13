import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';

/// Line chart from `pregnancy_monitoring` rows (dynamic keys).
class DoctorFlMonitoringChart extends StatelessWidget {
  const DoctorFlMonitoringChart({
    super.key,
    required this.rows,
    this.primaryKey = 'weight',
    this.secondaryKey,
    this.title = DoctorStrings.chartDefaultTitle,
    this.height = 220,
  });

  final List<Map<String, dynamic>> rows;
  final String primaryKey;
  final String? secondaryKey;
  final String title;
  final double height;

  static double? _num(Map<String, dynamic> r, String k) {
    final v = r[k];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    final spots2 = <FlSpot>[];
    for (var i = 0; i < rows.length; i++) {
      final y = _num(rows[i], primaryKey);
      if (y != null) spots.add(FlSpot(i.toDouble(), y));
      if (secondaryKey != null) {
        final y2 = _num(rows[i], secondaryKey!);
        if (y2 != null) spots2.add(FlSpot(i.toDouble(), y2));
      }
    }

    if (spots.length < 2 && spots2.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            DoctorStrings.chartNotEnoughData,
            style: GoogleFonts.inter(color: DoctorColors.textSecondary),
          ),
        ),
      );
    }

    final allY = [...spots.map((e) => e.y), ...spots2.map((e) => e.y)];
    var minY = allY.reduce((a, b) => a < b ? a : b);
    var maxY = allY.reduce((a, b) => a > b ? a : b);
    if ((maxY - minY).abs() < 1e-6) {
      minY -= 1;
      maxY += 1;
    }
    final pad = (maxY - minY) * 0.1;
    minY -= pad;
    maxY += pad;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: DoctorColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: DoctorColors.cardBorder,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, _) => Text(
                      v.toStringAsFixed(0),
                      style: GoogleFonts.inter(fontSize: 10, color: DoctorColors.textSecondary),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (x, _) {
                      final i = x.round();
                      if (i < 0 || i >= rows.length) return const SizedBox.shrink();
                      final t = rows[i]['createdAt'];
                      if (t is! Timestamp) return const SizedBox.shrink();
                      final d = t.toDate();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${d.day}/${d.month}',
                          style: GoogleFonts.inter(fontSize: 9, color: DoctorColors.textSecondary),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                if (spots.length >= 2)
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: DoctorColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: DoctorColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                if (secondaryKey != null && spots2.length >= 2)
                  LineChartBarData(
                    spots: spots2,
                    isCurved: true,
                    color: DoctorColors.accentBlue,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
