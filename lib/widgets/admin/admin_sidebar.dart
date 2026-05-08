import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/admin_colors.dart';
import '../../core/app_strings.dart';
import '../app_logo.dart';

enum AdminPage {
  dashboard,
  doctors,
  nurses,
  patients,
  rooms,
  messages,
  accounts,
  settings,
  notifications,
}

class AdminSidebar extends StatelessWidget {
  final AdminPage currentPage;
  final Function(AdminPage) onPageChanged;
  final VoidCallback onLogout;
  final int unreadMessages;
  final int unreadNotifications;

  const AdminSidebar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
    required this.onLogout,
    this.unreadMessages = 0,
    this.unreadNotifications = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 255,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AdminColors.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  _section(AppStrings.mainMenu),
                  _item(Icons.dashboard_rounded, AppStrings.dashboard,
                      AdminPage.dashboard),
                  _item(Icons.medical_services_outlined, AppStrings.doctors,
                      AdminPage.doctors),
                  _item(Icons.local_hospital_outlined, AppStrings.nurses,
                      AdminPage.nurses),
                  _item(Icons.people_outline_rounded, AppStrings.patients,
                      AdminPage.patients),
                  _item(Icons.bed_outlined, AppStrings.rooms, AdminPage.rooms),
                  const SizedBox(height: 4),
                  _section(AppStrings.communication),
                  _item(
                    Icons.chat_bubble_outline_rounded,
                    AppStrings.messages,
                    AdminPage.messages,
                    badge: unreadMessages,
                  ),
                  _item(
                    Icons.notifications_outlined,
                    AppStrings.notifications,
                    AdminPage.notifications,
                    badge: unreadNotifications,
                  ),
                  const SizedBox(height: 4),
                  _section(AppStrings.management),
                  _item(Icons.manage_accounts_outlined, AppStrings.accounts,
                      AdminPage.accounts),
                  _item(Icons.settings_outlined, AppStrings.settings,
                      AdminPage.settings),
                ],
              ),
            ),
          ),
          _buildLogout(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: const BoxDecoration(
        color: AdminColors.sidebarHeader,
        border: Border(
          bottom: BorderSide(color: AdminColors.sidebarBorder),
        ),
      ),
      child: Row(
        children: [
          const AppLogo(size: 40, isCircle: true),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                AppStrings.adminPanel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AdminColors.sidebarText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AdminColors.sidebarText.withOpacity(0.5),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    String label,
    AdminPage page, {
    int badge = 0,
  }) {
    return _SidebarTile(
      icon: icon,
      label: label,
      isActive: currentPage == page,
      badge: badge,
      onTap: () => onPageChanged(page),
    );
  }

  Widget _buildLogout() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AdminColors.sidebarBorder),
        ),
      ),
      child: _SidebarTile(
        icon: Icons.logout_rounded,
        label: AppStrings.logout,
        isActive: false,
        badge: 0,
        onTap: onLogout,
        isLogout: true,
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int badge;
  final VoidCallback onTap;
  final bool isLogout;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.badge,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isActive
        ? AdminColors.sidebarActive
        : _hovered
            ? AdminColors.sidebarHover
            : Colors.transparent;

    final fg = widget.isLogout
        ? AdminColors.danger
        : widget.isActive
            ? Colors.white
            : AdminColors.sidebarText;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: fg, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight:
                        widget.isActive ? FontWeight.w600 : FontWeight.w400,
                    color: fg,
                  ),
                ),
              ),
              if (widget.badge > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AdminColors.danger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
