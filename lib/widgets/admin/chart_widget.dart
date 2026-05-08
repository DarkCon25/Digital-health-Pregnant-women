import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/admin_colors.dart';

// ============================================
// HerCare - Chart Widgets
// Widgets Graphiques
// Note: Using custom paint (no extra package needed)
// Note: Utilisation de custom paint (pas de package supplémentaire)
// ============================================

// ── Line Chart Widget ─────────────────────────
class LineChartWidget extends StatelessWidget {
  final String title;
  final List<double> data;
  final List<String> labels;

  const LineChartWidget({
    super.key,
    required this.title,
    required this.data,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Legend / Légende
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AdminColors.primaryBlue,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Patients / Patientes',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Title / Titre
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Chart
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _LineChartPainter(
                data: data,
                color: AdminColors.primaryBlue,
                fillColor: AdminColors.primaryBlue.withOpacity(0.08),
              ),
              size: Size.infinite,
            ),
          ),

          const SizedBox(height: 12),

          // ── Month Labels / Étiquettes des mois
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((label) {
              return Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AdminColors.textLight,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Line Chart Painter (Custom Paint)
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final Color fillColor;

  _LineChartPainter({
    required this.data,
    required this.color,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Find max value / Trouver la valeur maximale
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);

    // Calculate step / Calculer le pas
    final stepX = size.width / (data.length - 1);

    // Convert data to points / Convertir les données en points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height -
          ((data[i] - minValue) / (maxValue - minValue)) * size.height;
      points.add(Offset(x, y));
    }

    // Draw fill area / Dessiner la zone de remplissage
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // Draw line / Dessiner la ligne
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      // Smooth curve / Courbe lisse
      final prev = points[i - 1];
      final curr = points[i];
      final controlX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(
        controlX,
        prev.dy,
        controlX,
        curr.dy,
        curr.dx,
        curr.dy,
      );
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Draw dots on each point / Dessiner des points
    for (final point in points) {
      // White circle / Cercle blanc
      canvas.drawCircle(
        point,
        4,
        Paint()..color = Colors.white,
      );
      // Colored border / Bordure colorée
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ══════════════════════════════════════════════
// Pie Chart Widget / Widget Graphique circulaire
// ══════════════════════════════════════════════

// Data model for pie chart / Modèle de données pour graphique
class PieChartData {
  final String label;
  final double value;
  final Color color;

  const PieChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class PieChartWidget extends StatelessWidget {
  final String title;
  final List<PieChartData> data;

  const PieChartWidget({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title / Titre
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AdminColors.textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          // ── Pie Chart
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _PieChartPainter(data: data),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Legend / Légende
          Column(
            children: data.map((item) {
              // Calculate percentage / Calculer le pourcentage
              final total = data.fold(
                0.0,
                (sum, d) => sum + d.value,
              );
              final percent = (item.value / total * 100).toStringAsFixed(1);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Color dot / Point coloré
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Label
                    Expanded(
                      child: Text(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                    ),

                    // Percentage / Pourcentage
                    Text(
                      '$percent%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Pie Chart Painter
class _PieChartPainter extends CustomPainter {
  final List<PieChartData> data;

  _PieChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate total / Calculer le total
    final total = data.fold(0.0, (sum, d) => sum + d.value);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    double startAngle = -90 * (3.14159 / 180); // Start from top

    for (final item in data) {
      // Calculate sweep angle / Calculer l'angle de balayage
      final sweepAngle = (item.value / total) * 2 * 3.14159;

      // Draw arc / Dessiner l'arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()
          ..color = item.color
          ..style = PaintingStyle.fill,
      );

      // Draw white separator / Dessiner le séparateur blanc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      startAngle += sweepAngle;
    }

    // Draw white center hole / Dessiner le trou central blanc
    canvas.drawCircle(
      center,
      radius * 0.55,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
