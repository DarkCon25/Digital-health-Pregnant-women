import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../services/nurse_service.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';
import '../../widgets/responsive_dashboard_shell.dart';

class ContactDoctorScreen extends StatefulWidget {
  const ContactDoctorScreen({
    super.key,
    this.patientContext,
    this.patientName,
  });

  final String? patientContext;
  final String? patientName;

  @override
  State<ContactDoctorScreen> createState() => _ContactDoctorScreenState();
}

class _ContactDoctorScreenState extends State<ContactDoctorScreen> {
  String? _doctorId;
  final _bodyCtrl = TextEditingController();

  @override
  void dispose() {
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<NurseService>();
    final pre = widget.patientContext != null
        ? 'Patient: ${widget.patientName ?? widget.patientContext}\n${widget.patientContext}\n\n'
        : '';

    return ResponsiveHorizontalSplit(
      leftWidth: 280,
      minRightWidth: 400,
      between: const VerticalDivider(width: 1),
      betweenWidth: 1,
      left: NurseSurfaceCard(
        padding: EdgeInsets.zero,
        child: StreamBuilder<QuerySnapshot>(
          stream: service.doctorsStream(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snap.data!.docs;
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Text(
                  NurseStrings.pageContactDoctor,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...docs.map((d) {
                  final m = d.data()! as Map<String, dynamic>;
                  final name =
                      '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'.trim();
                  final sel = _doctorId == d.id;
                  return ListTile(
                    selected: sel,
                    title: Text(name.isEmpty ? d.id : name),
                    subtitle: Text(m['specialty']?.toString() ?? ''),
                    onTap: () => setState(() {
                      _doctorId = d.id;
                    }),
                  );
                }),
              ],
            );
          },
        ),
      ),
      right: Padding(
        padding: const EdgeInsets.all(24),
        child: NurseSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                NurseStrings.sendMessage,
                style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyCtrl,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: NurseStrings.messageHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _doctorId == null
                    ? null
                    : () async {
                        final text = pre + _bodyCtrl.text.trim();
                        if (text.isEmpty) return;
                        await service.sendMessage(_doctorId!, text);
                        _bodyCtrl.clear();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(NurseStrings.sendMessage)),
                          );
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: NurseColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(NurseStrings.sendMessage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
