import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../services/nurse_service.dart';
import '../../viewmodels/nurse/patient_monitoring_viewmodel.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';
import '../../widgets/nurse/vital_signs_widget.dart';

class PatientMonitoringScreen extends StatelessWidget {
  const PatientMonitoringScreen({
    super.key,
    required this.patientId,
    this.onBack,
  });

  final String patientId;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PatientMonitoringViewModel(
        context.read<NurseService>(),
        patientId,
      )..init(),
      child: _PatientMonitoringBody(
        onBack: onBack,
        patientId: patientId,
      ),
    );
  }
}

class _PatientMonitoringBody extends StatefulWidget {
  const _PatientMonitoringBody({
    required this.patientId,
    this.onBack,
  });

  final String patientId;
  final VoidCallback? onBack;

  @override
  State<_PatientMonitoringBody> createState() => _PatientMonitoringBodyState();
}

class _PatientMonitoringBodyState extends State<_PatientMonitoringBody> {
  late final TextEditingController _sysCtrl;
  late final TextEditingController _diaCtrl;
  late final TextEditingController _hrCtrl;
  late final TextEditingController _rrCtrl;
  late final TextEditingController _o2Ctrl;
  late final TextEditingController _tempCtrl;
  late final TextEditingController _glucoseCtrl;
  String? _syncedForPatient;

  @override
  void initState() {
    super.initState();
    _sysCtrl = TextEditingController();
    _diaCtrl = TextEditingController();
    _hrCtrl = TextEditingController();
    _rrCtrl = TextEditingController();
    _o2Ctrl = TextEditingController();
    _tempCtrl = TextEditingController();
    _glucoseCtrl = TextEditingController();
  }

  void _syncFromVm() {
    final vm = context.read<PatientMonitoringViewModel>();
    _sysCtrl.text = vm.systolic?.toString() ?? '';
    _diaCtrl.text = vm.diastolic?.toString() ?? '';
    _hrCtrl.text = vm.heartRate?.toString() ?? '';
    _rrCtrl.text = vm.respiratoryRate?.toString() ?? '';
    _o2Ctrl.text = vm.oxygenSaturation?.toString() ?? '';
    _tempCtrl.text = vm.temperature?.toString() ?? '';
    _glucoseCtrl.text = vm.glucose?.toString() ?? '';
  }

  @override
  void dispose() {
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _hrCtrl.dispose();
    _rrCtrl.dispose();
    _o2Ctrl.dispose();
    _tempCtrl.dispose();
    _glucoseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PatientMonitoringViewModel>();

    if (!vm.loading &&
        vm.patient != null &&
        _syncedForPatient != vm.patient!.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncFromVm();
        setState(() => _syncedForPatient = vm.patient!.id);
      });
    }

    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final p = vm.patient;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (widget.onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                ),
              Expanded(
                child: NursePageHeader(
                  title: NurseStrings.pageVitals,
                  subtitle: p?.fullName ?? widget.patientId,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (p != null)
            NurseSurfaceCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        NurseColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : '?',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: NurseColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.fullName,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'ID: ${p.id}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: NurseColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (vm.medical != null) ...[
            NurseSurfaceCard(
              child: VitalSignsWidget(medical: vm.medical!),
            ),
            const SizedBox(height: 16),
          ],
          NurseSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  NurseStrings.updateVitals,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _num('SYS', _sysCtrl, (v) => vm.setSystolic(v)),
                    _num('DIA', _diaCtrl, (v) => vm.setDiastolic(v)),
                    _num('HR', _hrCtrl, (v) => vm.setHeartRate(v)),
                    _num('RR', _rrCtrl, (v) => vm.setRespiratory(v)),
                    _num('SpO2', _o2Ctrl, (v) => vm.setOxygen(v)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tempCtrl,
                  decoration: InputDecoration(
                    labelText: 'Temp (C)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (s) => vm.setTemp(
                    double.tryParse(s.trim().replaceAll(',', '.')),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _glucoseCtrl,
                  decoration: InputDecoration(
                    labelText: 'Glucose',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (s) => vm.setGlucose(
                    double.tryParse(s.trim().replaceAll(',', '.')),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: vm.saving
                      ? null
                      : () async {
                          vm.setSystolic(int.tryParse(_sysCtrl.text.trim()));
                          vm.setDiastolic(int.tryParse(_diaCtrl.text.trim()));
                          vm.setHeartRate(int.tryParse(_hrCtrl.text.trim()));
                          vm.setRespiratory(int.tryParse(_rrCtrl.text.trim()));
                          vm.setOxygen(int.tryParse(_o2Ctrl.text.trim()));
                          await vm.save();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(NurseStrings.saveUpdates),
                                backgroundColor: NurseColors.success,
                              ),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: NurseColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: vm.saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          NurseStrings.saveUpdates,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _num(
    String label,
    TextEditingController c,
    void Function(int?) onParsed,
  ) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: TextInputType.number,
        onChanged: (s) => onParsed(int.tryParse(s.trim())),
      ),
    );
  }
}
