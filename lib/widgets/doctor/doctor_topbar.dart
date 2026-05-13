import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../services/doctor_service.dart';

/// Top bar aligned with admin dashboard: title, search, notifications, profile.
class DoctorTopBar extends StatefulWidget implements PreferredSizeWidget {
  const DoctorTopBar({
    super.key,
    required this.title,
    required this.doctorName,
    this.specialtySubtitle,
    this.openEmergencyCount = 0,
    this.onEmergencyTap,
    this.onNotificationsTap,
    this.onSearchChanged,
  });

  final String title;
  final String doctorName;
  final String? specialtySubtitle;
  final int openEmergencyCount;
  final VoidCallback? onEmergencyTap;
  final VoidCallback? onNotificationsTap;
  final ValueChanged<String>? onSearchChanged;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  State<DoctorTopBar> createState() => _DoctorTopBarState();
}

class _DoctorTopBarState extends State<DoctorTopBar> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<DoctorService>();

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: DoctorColors.topbarBg,
        border: const Border(
          bottom: BorderSide(color: DoctorColors.cardBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: DoctorColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: _buildSearch(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.openEmergencyCount > 0 && widget.onEmergencyTap != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _EmergencyButton(
                count: widget.openEmergencyCount,
                onTap: widget.onEmergencyTap!,
              ),
            ),
          _NotificationButton(
            service: service,
            onTap: widget.onNotificationsTap,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: _ProfileBlock(
              doctorName: widget.doctorName,
              roleLine: widget.specialtySubtitle ?? DoctorStrings.doctorRoleFallback,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: DoctorColors.pageBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DoctorColors.cardBorder),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: widget.onSearchChanged,
        style: GoogleFonts.inter(fontSize: 13),
        decoration: InputDecoration(
          hintText: DoctorStrings.quickSearchHint,
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: DoctorColors.textLight,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: DoctorColors.textLight,
            size: 18,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchCtrl,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: DoctorColors.textLight,
                ),
                onPressed: () {
                  _searchCtrl.clear();
                  widget.onSearchChanged?.call('');
                },
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  const _EmergencyButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DoctorColors.critical.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: DoctorColors.critical.withValues(alpha: 0.35),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(Icons.emergency_outlined, color: DoctorColors.critical, size: 20),
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: DoctorColors.critical,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.service,
    this.onTap,
  });

  final DoctorService service;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: service.watchNotifications(limit: 40),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        final unread = docs.where((d) {
          final m = d.data() as Map<String, dynamic>?;
          return m != null && m['read'] != true;
        }).length;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DoctorColors.pageBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: DoctorColors.cardBorder),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: DoctorColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
            if (unread > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: DoctorColors.primary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({
    required this.doctorName,
    required this.roleLine,
  });

  final String doctorName;
  final String roleLine;

  @override
  Widget build(BuildContext context) {
    final initial = _initialLetter(doctorName);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                DoctorColors.primary,
                DoctorColors.primaryLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DoctorColors.textPrimary,
                ),
              ),
              Text(
                roleLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: DoctorColors.textSecondary,
                ),
              ),
              Text(
                DateFormat('EEE, dd MMM yyyy').format(DateTime.now()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: DoctorColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _initialLetter(String name) {
    final cleaned = name
        .replaceAll(DoctorStrings.doctorPrefix, '')
        .replaceAll('د. ', '')
        .replaceAll('Dr. ', '')
        .trim();
    if (cleaned.isEmpty) return '?';
    return cleaned[0].toUpperCase();
  }
}
