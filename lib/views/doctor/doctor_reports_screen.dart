import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../services/doctor_service.dart';
import '../../widgets/doctor/doctor_screen_chrome.dart';

/// Aggregated Firestore report counts (dynamic, not hard-coded).
class DoctorReportsScreen extends StatefulWidget {
  const DoctorReportsScreen({super.key});

  @override
  State<DoctorReportsScreen> createState() => _DoctorReportsScreenState();
}

class _DoctorReportsScreenState extends State<DoctorReportsScreen> {
  Map<String, int>? _counts;
  Object? _err;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() {
      _counts = null;
      _err = null;
    });
    try {
      final c = await context.read<DoctorService>().getReportCounts(uid);
      setState(() => _counts = c);
    } catch (e) {
      setState(() => _err = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DoctorPageHeader(
            title: DoctorStrings.reportsTitle,
            subtitle: DoctorStrings.reportsSubtitle,
            actions: [
              IconButton.filledTonal(
                onPressed: _reload,
                style: IconButton.styleFrom(
                  backgroundColor: DoctorColors.pageBg,
                  side: const BorderSide(color: DoctorColors.cardBorder),
                ),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_err != null)
            Text('$_err', style: GoogleFonts.inter(color: DoctorColors.critical)),
          if (_counts == null && _err == null)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_counts != null)
            Expanded(
              child: DoctorSurfaceCard(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final cols = c.maxWidth > 720 ? 2 : 1;
                    return GridView.count(
                      crossAxisCount: cols,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: cols == 2 ? 1.35 : 1.5,
                      children: [
                        _card(context, DoctorStrings.reportPatients,
                            '${_counts!['patients']}', Icons.people_outline),
                        _card(context, DoctorStrings.reportLabs,
                            '${_counts!['labTests']}', Icons.biotech_outlined),
                        _card(context, DoctorStrings.reportUltrasound,
                            '${_counts!['ultrasounds']}', Icons.image_outlined),
                        _card(context, DoctorStrings.reportIcu,
                            '${_counts!['icuCases']}', Icons.monitor_heart_outlined),
                        _card(context, DoctorStrings.reportVisits,
                            '${_counts!['consultations']}', Icons.event_note_outlined),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, String count, IconData icon) {
    return Material(
      color: DoctorColors.pageBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(DoctorStrings.reportTapHint),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DoctorColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: DoctorColors.primary, size: 32),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                count,
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: DoctorColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
