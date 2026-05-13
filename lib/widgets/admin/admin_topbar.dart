import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/admin_colors.dart';
import '../../core/app_strings.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AdminTopbar extends StatefulWidget {
  final String pageTitle;
  final VoidCallback onNotificationTap;
  final int unreadCount; // ✅ عدد الإشعارات غير المقروءة

  const AdminTopbar({
    super.key,
    required this.pageTitle,
    required this.onNotificationTap,
    this.unreadCount = 0,
  });

  @override
  State<AdminTopbar> createState() => _AdminTopbarState();
}

class _AdminTopbarState extends State<AdminTopbar> {
  // ✅ Controller محفوظ
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        final name = vm.currentUser?.fullName ?? 'Admin';

        return Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AdminColors.topbarBg,
            border: const Border(
              bottom: BorderSide(color: AdminColors.border),
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
                  widget.pageTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: _buildSearch(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildNotifBtn(),
              const SizedBox(width: 8),
              Flexible(
                child: _buildProfile(name),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Search ───────────────────────────────────────
  Widget _buildSearch() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: AdminColors.pageBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.border),
      ),
      child: TextField(
        controller: _searchCtrl,
        style: GoogleFonts.inter(fontSize: 13),
        decoration: InputDecoration(
          hintText: AppStrings.searchPlaceholder,
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: AdminColors.textLight,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AdminColors.textLight,
            size: 18,
          ),
          // ✅ زر مسح النص
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchCtrl,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AdminColors.textLight,
                ),
                onPressed: () => _searchCtrl.clear(),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  // ── Notification Button ──────────────────────────
  Widget _buildNotifBtn() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: widget.onNotificationTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AdminColors.pageBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AdminColors.border),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AdminColors.textSecondary,
              size: 20,
            ),
          ),
        ),

        // ✅ Red dot فقط عند وجود إشعارات
        if (widget.unreadCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AdminColors.danger,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                widget.unreadCount > 99 ? '99+' : widget.unreadCount.toString(),
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
  }

  // ── Profile ──────────────────────────────────────
  Widget _buildProfile(String name) {
    // ✅ أول حرف من الاسم كـ Avatar
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'A';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AdminColors.primaryBlue,
                AdminColors.primaryBlueLight,
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
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.textPrimary,
                ),
              ),
              Text(
                AppStrings.systemAdmin,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AdminColors.textSecondary,
                ),
              ),
              Text(
                DateFormat('EEE, dd MMM yyyy').format(DateTime.now()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AdminColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
