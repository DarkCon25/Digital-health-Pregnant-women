import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../models/doctor/ultrasound_image_model.dart';
import '../../services/doctor_service.dart';
import '../../widgets/doctor/doctor_screen_chrome.dart';

/// Ultrasound gallery — `ultrasound_images` collection.
class DoctorFetalImagesScreen extends StatefulWidget {
  const DoctorFetalImagesScreen({super.key});

  @override
  State<DoctorFetalImagesScreen> createState() =>
      _DoctorFetalImagesScreenState();
}

class _DoctorFetalImagesScreenState extends State<DoctorFetalImagesScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final service = context.read<DoctorService>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DoctorPageHeader(
            title: DoctorStrings.pageUltrasound,
            subtitle: DoctorStrings.ultrasoundPageSubtitle,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<UltrasoundImageModel>>(
              stream: uid.isEmpty
                  ? const Stream.empty()
                  : service.watchUltrasoundsForDoctor(uid),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data!;
                if (list.isEmpty) {
                  return DoctorSurfaceCard(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_not_supported_outlined,
                              size: 56,
                              color: DoctorColors.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            DoctorStrings.noUltrasoundFirestore,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                color: DoctorColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (_selected >= list.length) _selected = 0;
                final main = list[_selected];

                return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 200,
                child: DoctorSurfaceCard(
                  padding: EdgeInsets.zero,
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final u = list[i];
                      final label = u.sessionLabel ??
                          DateFormat.yMMMd().format(u.createdAt);
                      final sel = i == _selected;
                      return ListTile(
                        selected: sel,
                        title: Text(
                          label,
                          style: GoogleFonts.inter(
                            fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          u.patientId,
                          style: GoogleFonts.inter(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => setState(() => _selected = i),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DoctorSurfaceCard(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: main.imageUrl.isEmpty
                              ? Center(
                                  child: Text(
                                    DoctorStrings.noImageUrl,
                                    style: GoogleFonts.inter(
                                      color: DoctorColors.textSecondary,
                                    ),
                                  ),
                                )
                              : InteractiveViewer(
                                  minScale: 0.5,
                                  maxScale: 4,
                                  child: Image.network(
                                    main.imageUrl,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (_, child, prog) {
                                      if (prog == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Icon(Icons.broken_image_outlined,
                                          size: 64,
                                          color:
                                              DoctorColors.textSecondary),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: list.length.clamp(0, 16),
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final u = list[i];
                          return GestureDetector(
                            onTap: () => setState(() => _selected = i),
                            child: Container(
                              width: 96,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: i == _selected
                                      ? DoctorColors.primary
                                      : DoctorColors.cardBorder,
                                  width: i == _selected ? 2 : 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: u.imageUrl.isEmpty
                                  ? const Icon(Icons.image)
                                  : Image.network(
                                      u.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.hide_image),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
