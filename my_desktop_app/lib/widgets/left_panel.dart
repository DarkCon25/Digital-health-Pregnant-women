import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/colors.dart';
import '../core/constants.dart';
import 'app_logo.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientStart,
            AppColors.gradientMid,
            AppColors.gradientEnd,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // ── Decorative Circles
          const _DecorativeCircles(),

          // ── Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Logo
                const _Logo(),
                const SizedBox(height: 40),

                // ── Divider
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 36),

                // ── Headline
                Text(
                  AppConstants.appMotivation,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Description
                Text(
                  AppConstants.appDescription,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textWhiteSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),

                // ── Feature Cards
                const _FeatureCards(),
                const SizedBox(height: 32),

                // ── Divider
                Container(
                  height: 1,
                  color: AppColors.white.withOpacity(0.15),
                ),
                const SizedBox(height: 28),

                // ── Stats
                const _StatsRow(),
                const SizedBox(height: 32),

                // ── Quote
                Text(
                  AppConstants.appQuote,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textWhiteSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════
// LOGO
// ════════════════════════════════════════════════

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ اللوجو الحقيقي
        AppLogo(
          size: 80,
          isCircle: true,
          borderColor: AppColors.white.withOpacity(0.5),
          borderWidth: 2.5,
          backgroundColor: AppColors.white.withOpacity(0.1),
        ),
        const SizedBox(height: 16),

        // ── HerCare Text
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Her',
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  color: AppColors.white,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Care',
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── Tagline
        Text(
          AppConstants.appTagline,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhiteSecondary,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════
// FEATURE CARDS
// ════════════════════════════════════════════════

class _FeatureCards extends StatelessWidget {
  const _FeatureCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FeatureCard(
            icon: Icons.monitor_heart_outlined,
            title: 'Indicateurs vitaux',
            subtitle: 'Température • Tension • Glycémie',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FeatureCard(
            icon: Icons.notifications_outlined,
            title: 'Rendez-vous',
            subtitle: 'Réservation • Rappels • Notifications',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FeatureCard(
            icon: Icons.shield_outlined,
            title: "Bouton d'urgence",
            subtitle: 'Appel immédiat du médecin',
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.featureCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.featureCardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.white, size: 26),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textWhiteSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════
// STATS ROW
// ════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          value: AppConstants.stat1Value,
          label: AppConstants.stat1Label,
        ),
        _StatDivider(),
        _StatItem(
          value: AppConstants.stat2Value,
          label: AppConstants.stat2Label,
        ),
        _StatDivider(),
        _StatItem(
          value: AppConstants.stat3Value,
          label: AppConstants.stat3Label,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textWhiteSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.white.withOpacity(0.2),
    );
  }
}

// ════════════════════════════════════════════════
// DECORATIVE CIRCLES
// ════════════════════════════════════════════════

class _DecorativeCircles extends StatelessWidget {
  const _DecorativeCircles();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -80,
          bottom: 80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withOpacity(0.08),
                width: 60,
              ),
            ),
          ),
        ),
        Positioned(
          left: -60,
          top: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withOpacity(0.06),
                width: 40,
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 120,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
