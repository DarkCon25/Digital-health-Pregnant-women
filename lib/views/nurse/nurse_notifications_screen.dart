import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../services/nurse_service.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';

class NurseNotificationsScreen extends StatelessWidget {
  const NurseNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<NurseService>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NursePageHeader(
            title: NurseStrings.pageNotifications,
            subtitle: NurseStrings.reportsSub,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: service.watchNotifications(limit: 60),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      NurseStrings.noNotifications,
                      style: GoogleFonts.inter(color: NurseColors.textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    final m = d.data()! as Map<String, dynamic>;
                    final read = m['read'] == true;
                    final note =
                        m['note']?.toString() ?? m['type']?.toString() ?? '';
                    final created = m['createdAt'];
                    String time = '';
                    if (created is Timestamp) {
                      time = DateFormat.yMMMd().add_Hm().format(created.toDate());
                    }
                    return NurseSurfaceCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            color: read
                                ? NurseColors.textSecondary
                                : NurseColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (time.isNotEmpty)
                                  Text(
                                    time,
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
