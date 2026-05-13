import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/localization/patient_strings.dart';
import '../../core/patient_colors.dart';
import '../../viewmodels/patient/patient_locale_viewmodel.dart';
import '../../viewmodels/patient/profile_viewmodel.dart';
import '../../widgets/patient/language_switcher.dart';
import '../../widgets/patient/patient_screen_chrome.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({
    super.key,
    required this.locale,
    required this.patientId,
  });

  final String locale;
  final String patientId;

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  bool _editing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PatientProfileViewModel>();
    final localeVm = context.watch<PatientLocaleViewModel>();
    final s = PatientL10n.of(widget.locale);
    final patient = vm.patient;

    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_editing) {
      _nameCtrl = TextEditingController(text: patient?.fullName ?? '');
      _phoneCtrl = TextEditingController(text: patient?.phone ?? '');
      _addressCtrl = TextEditingController(text: patient?.address ?? '');
    }

    final initial = (patient?.fullName ?? '?').trim();
    final initChar =
        initial.isNotEmpty ? initial[0].toUpperCase() : '?';
    final email = patient?.email ?? '—';
    final phone = patient?.phone ?? '—';
    final address = patient?.address ?? '—';
    final dob = patient?.dateOfBirth;
    final dobStr = dob != null ? DateFormat('d MMM y').format(dob) : '—';
    final bloodType = patient?.bloodType ?? '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PatientPageHeader(
            title: s.profileTitle,
            subtitle: s.profileSub,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (ctx, box) {
            final wide = box.maxWidth > 900;
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 260, child: _avatarCard(initChar, s)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _editing
                            ? _editForm(s, vm)
                            : _infoCard(
                                s: s,
                                email: email,
                                phone: phone,
                                address: address,
                                dob: dobStr,
                                blood: bloodType,
                                localeVm: localeVm,
                                locale: widget.locale,
                              ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _avatarCard(initChar, s),
                      const SizedBox(height: 16),
                      _editing
                          ? _editForm(s, vm)
                          : _infoCard(
                              s: s,
                              email: email,
                              phone: phone,
                              address: address,
                              dob: dobStr,
                              blood: bloodType,
                              localeVm: localeVm,
                              locale: widget.locale,
                            ),
                    ],
                  );
          }),
          if (vm.saved) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PatientColors.successLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: PatientColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text(s.profileUpdated,
                      style: GoogleFonts.inter(
                          color: PatientColors.success,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatarCard(String initChar, PatientL10n s) {
    return PatientCard(
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [PatientColors.primary, PatientColors.primaryDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: PatientColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initChar,
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.read<PatientProfileViewModel>().patient?.fullName ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: PatientColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          StatusBadge(label: s.portalLabel, color: PatientColors.primary),
          const SizedBox(height: 20),
          // Language selector
          Text(s.languageLabel,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: PatientColors.textSecondary)),
          const SizedBox(height: 10),
          const LanguageSwitcher(),
        ],
      ),
    );
  }

  Widget _infoCard({
    required PatientL10n s,
    required String email,
    required String phone,
    required String address,
    required String dob,
    required String blood,
    required PatientLocaleViewModel localeVm,
    required String locale,
  }) {
    return PatientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                s.profileTitle,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: PatientColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(s.editProfile),
                style: TextButton.styleFrom(
                    foregroundColor: PatientColors.primary),
                onPressed: () => setState(() => _editing = true),
              ),
            ],
          ),
          const Divider(height: 24),
          _infoRow(Icons.person_outline, s.fullName,
              context.read<PatientProfileViewModel>().patient?.fullName ?? '—'),
          _infoRow(Icons.email_outlined, s.email, email),
          _infoRow(Icons.phone_outlined, s.phone, phone),
          _infoRow(Icons.home_outlined, s.address, address),
          _infoRow(Icons.cake_outlined, s.dateOfBirth, dob),
          _infoRow(Icons.water_drop_outlined, s.bloodType, blood),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: PatientColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: PatientColors.textSecondary)),
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: PatientColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editForm(PatientL10n s, PatientProfileViewModel vm) {
    return PatientCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.editProfile,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: PatientColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _field(_nameCtrl, s.fullName, Icons.person_outline),
            const SizedBox(height: 12),
            _field(_phoneCtrl, s.phone, Icons.phone_outlined),
            const SizedBox(height: 12),
            _field(_addressCtrl, s.address, Icons.home_outlined),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _editing = false),
                    child: Text(s.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PatientColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: vm.saving
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              vm.save(widget.patientId, {
                                'firstName':
                                    _nameCtrl.text.split(' ').first,
                                'lastName': _nameCtrl.text
                                    .split(' ')
                                    .skip(1)
                                    .join(' '),
                                'phone': _phoneCtrl.text,
                                'address': _addressCtrl.text,
                              });
                              setState(() => _editing = false);
                            }
                          },
                    child: vm.saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(s.saveChanges),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: PatientColors.primary, size: 18),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: PatientColors.primary),
        ),
      ),
    );
  }
}
