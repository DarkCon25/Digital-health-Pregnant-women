import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../services/nurse_service.dart';

class NurseTopBar extends StatefulWidget implements PreferredSizeWidget {
  const NurseTopBar({
    super.key,
    required this.title,
    required this.nurseName,
    this.onSearchChanged,
  });

  final String title;
  final String nurseName;
  final ValueChanged<String>? onSearchChanged;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  State<NurseTopBar> createState() => _NurseTopBarState();
}

class _NurseTopBarState extends State<NurseTopBar> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<NurseService>();

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: NurseColors.topbarBg,
        border: const Border(bottom: BorderSide(color: NurseColors.cardBorder)),
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
                color: NurseColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: NurseColors.pageBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: NurseColors.cardBorder),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: widget.onSearchChanged,
                    style: GoogleFonts.inter(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: NurseStrings.searchHint,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13,
                        color: NurseColors.textLight,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: NurseColors.textLight,
                      ),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchCtrl,
                        builder: (_, v, __) {
                          if (v.text.isEmpty) return const SizedBox.shrink();
                          return IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              widget.onSearchChanged?.call('');
                            },
                          );
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          StreamBuilder<QuerySnapshot>(
            stream: service.watchNotifications(limit: 30),
            builder: (context, snap) {
              final docs = snap.data?.docs ?? [];
              final unread = docs.where((d) {
                final m = d.data() as Map<String, dynamic>?;
                return m != null && m['read'] != true;
              }).length;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: NurseColors.pageBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: NurseColors.cardBorder),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: NurseColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: NurseColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                            minWidth: 16, minHeight: 16),
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      NurseColors.primary,
                      NurseColors.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    widget.nurseName.isNotEmpty
                        ? widget.nurseName[0].toUpperCase()
                        : 'N',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.nurseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      NurseStrings.roleNurse,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: NurseColors.textSecondary,
                      ),
                    ),
                    Text(
                      DateFormat('EEE, dd MMM yyyy').format(DateTime.now()),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: NurseColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
