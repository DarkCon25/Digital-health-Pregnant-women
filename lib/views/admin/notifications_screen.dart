import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/admin_colors.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';

// ============================================
// HerCare - Notifications Screen
// Écran des Notifications
// ============================================

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mark all read button
              // Bouton tout marquer comme lu
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.done_all_rounded,
                  size: 16,
                ),
                label: Text(
                  'Mark all read / Tout marquer lu',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AdminColors.primaryBlue,
                ),
              ),

              // Title
              Text(
                'Notifications',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Notifications List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      color: AdminColors.primaryBlue,
                    ),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              // Empty state / État vide
              if (docs.isEmpty) {
                return _buildEmptyNotifications();
              }

              // Notifications list / Liste des notifications
              return Container(
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: docs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final doc = entry.value;
                    final data = doc.data() as Map<String, dynamic>;
                    final isLast = index == docs.length - 1;
                    final isRead = data['read'] ?? false;

                    return _NotificationItem(
                      data: data,
                      isLast: isLast,
                      isRead: isRead,
                      onTap: () {},
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Empty state widget / Widget état vide
  Widget _buildEmptyNotifications() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AdminColors.primaryBluePale,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: AdminColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AdminColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune notification pour le moment',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AdminColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// Single Notification Item
// Élément de notification unique
// ============================================
class _NotificationItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isLast;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.data,
    required this.isLast,
    required this.isRead,
    required this.onTap,
  });

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem> {
  bool _isHovered = false;

  // Get notification icon / Obtenir l'icône de notification
  IconData _getIcon(String? type) {
    switch (type) {
      case 'emergency':
        return Icons.emergency_rounded;
      case 'appointment':
        return Icons.calendar_today_rounded;
      case 'message':
        return Icons.chat_bubble_outline_rounded;
      case 'password_reset':
        return Icons.lock_reset_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  // Get notification color / Obtenir la couleur
  Color _getColor(String? type) {
    switch (type) {
      case 'emergency':
        return AdminColors.danger;
      case 'appointment':
        return AdminColors.primaryBlue;
      case 'message':
        return AdminColors.greenCard;
      case 'password_reset':
        return AdminColors.orangeCard;
      default:
        return AdminColors.purpleCard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.data['type'] as String?;
    final title = widget.data['title'] as String? ?? 'Notification';
    final body = widget.data['body'] as String? ?? '';
    final color = _getColor(type);
    final icon = _getIcon(type);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Highlight if not read / Surligner si non lu
            color: !widget.isRead
                ? AdminColors.primaryBluePale
                : _isHovered
                    ? AdminColors.pageBg
                    : AdminColors.cardBg,
            border: widget.isLast
                ? null
                : const Border(
                    bottom: BorderSide(
                      color: AdminColors.borderLight,
                    ),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Content (Right side)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row
                    Row(
                      children: [
                        // Unread dot / Point non lu
                        if (!widget.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(
                              right: 8,
                            ),
                            decoration: const BoxDecoration(
                              color: AdminColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),

                        // Title
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: widget.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Body text
                    Text(
                      body,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AdminColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Type tag / Étiquette de type
                    if (type != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── Icon (Left side)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
