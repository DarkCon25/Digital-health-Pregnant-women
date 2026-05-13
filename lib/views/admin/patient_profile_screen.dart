import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/admin_colors.dart';

class PatientProfileScreen extends StatelessWidget {
  final String patientId;
  const PatientProfileScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.pageBg,
      appBar: AppBar(
        title: const Text('Patient Medical File'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(patientId)
            .snapshots(),
        builder: (context, patientSnap) {
          if (!patientSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final patient = patientSnap.data!.data() as Map<String, dynamic>? ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('General Info'),
                _card(
                  children: [
                    _row('File Number', patient['fileNumber'] ?? patientId),
                    _row('Name', '${patient['firstName'] ?? ''} ${patient['lastName'] ?? ''}'),
                    _row('Age', '${patient['age'] ?? '-'}'),
                    _row('Blood Type', '${patient['bloodType'] ?? '-'}'),
                    _row('Address', '${patient['address'] ?? '-'}'),
                    _row('Phone', '${patient['phone'] ?? '-'}'),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionTitle('Pregnancy Monitoring'),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pregnancy_monitoring')
                      .where('patientId', isEqualTo: patientId)
                      .orderBy('createdAt', descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, monitorSnap) {
                    final monitor = monitorSnap.data?.docs.isNotEmpty == true
                        ? monitorSnap.data!.docs.first.data() as Map<String, dynamic>
                        : <String, dynamic>{};
                    return _card(
                      children: [
                        _row('Blood Pressure', '${monitor['bloodPressure'] ?? '-'}'),
                        _row('Sugar Level', '${monitor['sugarLevel'] ?? '-'}'),
                        _row('Temperature', '${monitor['temperature'] ?? '-'}'),
                        _row('Heartbeat', '${monitor['heartbeat'] ?? '-'}'),
                        _row('Fetal Growth', '${monitor['fetalGrowth'] ?? '-'}'),
                        _row('Weight', '${monitor['weight'] ?? '-'}'),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
      );

  Widget _card({required List<Widget> children}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AdminColors.border),
        ),
        child: Column(children: children),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Text(value, style: GoogleFonts.inter(color: AdminColors.textSecondary)),
            ),
          ],
        ),
      );
}
