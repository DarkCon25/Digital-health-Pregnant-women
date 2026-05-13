import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/localization/patient_strings.dart';
import '../../core/patient_colors.dart';
import '../../models/patient/fetal_image_model.dart';
import '../../services/patient_service.dart';
import '../../widgets/patient/fetal_image_card.dart';
import '../../widgets/patient/patient_screen_chrome.dart';

class FetalImagesScreen extends StatelessWidget {
  const FetalImagesScreen({
    super.key,
    required this.locale,
    required this.patientId,
  });

  final String locale;
  final String patientId;

  @override
  Widget build(BuildContext context) {
    final svc = context.read<PatientService>();
    final s = PatientL10n.of(locale);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PatientPageHeader(
            title: s.fetalImagesTitle,
            subtitle: s.fetalImagesSub,
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<FetalImageModel>>(
            stream: svc.watchFetalImages(patientId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final images = snap.data ?? [];
              if (images.isEmpty) {
                return Center(
                  child: Text(
                    s.noFetalImages,
                    style: GoogleFonts.inter(
                        color: PatientColors.textSecondary),
                  ),
                );
              }
              // Group by week
              final groups = <int, List<FetalImageModel>>{};
              for (final img in images) {
                groups.putIfAbsent(img.weekNumber, () => []).add(img);
              }
              final sortedWeeks = groups.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...sortedWeeks.map((week) {
                    final imgs = groups[week]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 4),
                          child: Text(
                            'Week $week',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: PatientColors.primary,
                            ),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: imgs.length,
                          itemBuilder: (_, i) => FetalImageCard(
                            img: imgs[i],
                            onTap: () => _showFullscreen(context, imgs[i], s),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),
                  Text(
                    s.noteImagesInfo,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: PatientColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showFullscreen(
      BuildContext context, FetalImageModel img, PatientL10n s) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            if (img.imageUrl.isNotEmpty)
              Center(
                child: InteractiveViewer(
                  child: Image.network(img.imageUrl),
                ),
              )
            else
              const Center(
                child: Icon(
                  Icons.child_care,
                  size: 120,
                  color: Colors.white24,
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Week ${img.weekNumber}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    DateFormat('d MMMM y').format(img.date),
                    style: GoogleFonts.inter(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
