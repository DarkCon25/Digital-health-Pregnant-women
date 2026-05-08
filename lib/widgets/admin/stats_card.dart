import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/admin_colors.dart';

// ============================================
// HerCare - Statistics Card Widget
// Widget Carte de statistiques
// ============================================

class StatsCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? changePercent; // Percentage change / Pourcentage de changement
  final bool isIncrease;       // True = up, False = down

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.changePercent,
    this.isIncrease = true,
  });

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit : (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding : const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color        : AdminColors.cardBg,
          borderRadius : BorderRadius.circular(16),
          // Border changes on hover / Bordure change au survol
          border: Border.all(
            color: _isHovered
                ? widget.color.withOpacity(0.4)
                : AdminColors.border,
          ),
          // Shadow changes on hover / Ombre change au survol
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.color.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _isHovered ? 24 : 8,
              offset    : const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Top Row: Icon + Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Change percentage badge
                // Badge pourcentage de changement
                if (widget.changePercent != null)
                  _ChangeBadge(
                    percent   : widget.changePercent!,
                    isIncrease: widget.isIncrease,
                  ),

                // Icon container / Conteneur icône
                Container(
                  width : 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color        : widget.color.withOpacity(0.12),
                    borderRadius : BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size : 26,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Value (big number) / Valeur (grand nombre)
            Text(
              widget.value,
              style: GoogleFonts.inter(
                fontSize  : 30,
                fontWeight: FontWeight.w800,
                color     : AdminColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            // ── Title / Titre
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize  : 14,
                fontWeight: FontWeight.w600,
                color     : AdminColors.textPrimary,
              ),
            ),

            const SizedBox(height: 2),

            // ── Subtitle / Sous-titre
            Text(
              widget.subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color   : AdminColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// Change Badge Widget (% up or down)
// Widget Badge de changement
// ============================================
class _ChangeBadge extends StatelessWidget {
  final double percent;
  final bool isIncrease;

  const _ChangeBadge({
    required this.percent,
    required this.isIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical  : 4,
      ),
      decoration: BoxDecoration(
        color        : isIncrease
            ? AdminColors.successBg
            : AdminColors.dangerBg,
        borderRadius : BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Arrow icon / Icône flèche
          Icon(
            isIncrease
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size : 13,
            color: isIncrease
                ? AdminColors.success
                : AdminColors.danger,
          ),

          const SizedBox(width: 3),

          // Percentage text / Texte pourcentage
          Text(
            '${percent.toStringAsFixed(1)}%',
            style: GoogleFonts.inter(
              fontSize  : 11,
              fontWeight: FontWeight.w700,
              color     : isIncrease
                  ? AdminColors.success
                  : AdminColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}