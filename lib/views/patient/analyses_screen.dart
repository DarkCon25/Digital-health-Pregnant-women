import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/localization/patient_strings.dart';
import '../../core/patient_colors.dart';
import '../../models/patient/analysis_model.dart';
import '../../viewmodels/patient/analyses_viewmodel.dart';
import '../../widgets/patient/patient_screen_chrome.dart';

class AnalysesScreen extends StatelessWidget {
  const AnalysesScreen({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalysesViewModel>();
    final s = PatientL10n.of(locale);

    final tabs = [
      (s.tabAll, 'all'),
      (s.tabBlood, 'blood'),
      (s.tabUrine, 'urine'),
      (s.tabOther, 'other'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PatientPageHeader(title: s.analysesTitle, subtitle: s.analysesSub),
          const SizedBox(height: 20),

          // Tabs
          Wrap(
            spacing: 8,
            children: tabs.map((t) {
              final active = vm.activeTab == t.$2;
              return GestureDetector(
                onTap: () => vm.setTab(t.$2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? PatientColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? PatientColors.primary
                          : PatientColors.cardBorder,
                    ),
                  ),
                  child: Text(
                    t.$1,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? Colors.white
                          : PatientColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          if (vm.loading)
            const Center(child: CircularProgressIndicator())
          else if (vm.filtered.isEmpty)
            Center(
              child: Text(s.noAnalyses,
                  style:
                      GoogleFonts.inter(color: PatientColors.textSecondary)),
            )
          else
            PatientCard(
              padding: EdgeInsets.zero,
              child: _AnalysesTable(
                  analyses: vm.filtered, s: s, locale: locale),
            ),
          const SizedBox(height: 16),
          Text(
            s.noteConsultDoctor,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: PatientColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysesTable extends StatelessWidget {
  const _AnalysesTable({
    required this.analyses,
    required this.s,
    required this.locale,
  });

  final List<AnalysisModel> analyses;
  final PatientL10n s;
  final String locale;

  Color _statusColor(String status) {
    switch (status) {
      case 'normal':
        return PatientColors.success;
      case 'high':
        return PatientColors.warning;
      case 'critical':
        return PatientColors.critical;
      case 'low':
        return PatientColors.blue;
      default:
        return PatientColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'normal':
        return s.statusNormal;
      case 'high':
        return s.statusHigh;
      case 'critical':
        return s.statusCritical;
      case 'low':
        return s.statusLow;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: analyses.asMap().entries.map((e) {
        final idx = e.key;
        final a = e.value;
        final color = _statusColor(a.status);
        final odd = idx.isOdd;
        return Container(
          color: odd
              ? PatientColors.primaryTint.withValues(alpha: 0.4)
              : Colors.white,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Test name
                Expanded(
                  flex: 3,
                  child: Text(
                    a.testName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PatientColors.textPrimary,
                    ),
                  ),
                ),
                // Result
                Expanded(
                  flex: 2,
                  child: Text(
                    '${a.result} ${a.unit}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: PatientColors.textPrimary,
                    ),
                  ),
                ),
                // Date
                Expanded(
                  flex: 2,
                  child: Text(
                    DateFormat('d MMM y').format(a.date),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: PatientColors.textSecondary,
                    ),
                  ),
                ),
                // Status
                Expanded(
                  flex: 2,
                  child: StatusBadge(
                    label: _statusLabel(a.status),
                    color: color,
                  ),
                ),
                // File
                SizedBox(
                  width: 36,
                  child: a.fileUrl != null && a.fileUrl!.isNotEmpty
                      ? Tooltip(
                          message: s.downloadFile,
                          child: const Icon(Icons.picture_as_pdf,
                              color: PatientColors.critical, size: 20),
                        )
                      : const Icon(
                          Icons.remove,
                          size: 16,
                          color: PatientColors.textLight,
                        ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
