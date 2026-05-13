import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/admin_colors.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';
import '../../widgets/responsive_dashboard_shell.dart';

// ============================================
// HerCare - Messages Screen
// Ã‰cran des Messages
// ============================================

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // Selected contact / Contact sÃ©lectionnÃ©
  String? _selectedContactId;
  String _selectedContactName = '';

  // Message input controller
  final TextEditingController _messageCtrl = TextEditingController();

  // Scroll controller for chat
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // Scroll to bottom / DÃ©filer vers le bas
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminDashboardViewModel>().service;

    return ResponsiveHorizontalSplit(
      leftWidth: 280,
      minRightWidth: 360,
      between: const VerticalDivider(
        width: 1,
        color: AdminColors.border,
      ),
      betweenWidth: 1,
      left: _buildContactsList(service),
      right: _selectedContactId == null
          ? _buildNoChatSelected()
          : _buildChatArea(service),
    );
  }

  // â”€â”€ Contacts List Panel
  Widget _buildContactsList(dynamic service) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AdminColors.cardBg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Contacts',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AdminColors.textPrimary,
              ),
            ),
          ),

          const Divider(
            color: AdminColors.border,
            height: 1,
          ),

          // Contacts Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: service.getContactsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AdminColors.primaryBlue,
                    ),
                  );
                }

                final contacts = snapshot.data?.docs ?? [];

                if (contacts.isEmpty) {
                  return Center(
                    child: Text(
                      'No contacts found\n'
                      'Aucun contact trouvÃ©',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AdminColors.textLight,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final data = contacts[index].data() as Map<String, dynamic>;
                    final contactId = contacts[index].id;
                    final fullName = '${data['firstName'] ?? ''} '
                        '${data['lastName'] ?? ''}';
                    final role = data['role'] ?? 'doctor';
                    final isSelected = _selectedContactId == contactId;

                    return _ContactTile(
                      name: fullName,
                      role: role,
                      isSelected: isSelected,
                      unreadCountStream: service.getUnreadCountStream(contactId),
                      onTap: () => setState(() {
                        _selectedContactId = contactId;
                        _selectedContactName = fullName;
                      }),
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

  // â”€â”€ No Chat Selected State
  Widget _buildNoChatSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AdminColors.primaryBluePale,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: AdminColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a contact to start chatting',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SÃ©lectionnez un contact pour commencer',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AdminColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Chat Area
  Widget _buildChatArea(dynamic service) {
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Column(
      children: [
        // â”€â”€ Chat Header
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: AdminColors.cardBg,
            border: Border(
              bottom: BorderSide(color: AdminColors.border),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AdminColors.primaryBlue.withAlpha(38),
                child: Text(
                  _selectedContactName.isNotEmpty
                      ? _selectedContactName[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    color: AdminColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name
              Text(
                _selectedContactName,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // â”€â”€ Messages List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: service.getMessagesStream(
              _selectedContactId!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AdminColors.primaryBlue,
                  ),
                );
              }

              final messages = snapshot.data?.docs ?? [];
              final sorted = [...messages]..sort((a, b) {
                final aTs = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                final bTs = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                final aMs = aTs?.millisecondsSinceEpoch ?? 0;
                final bMs = bTs?.millisecondsSinceEpoch ?? 0;
                return aMs.compareTo(bMs);
              });

              service.markMessagesAsRead(_selectedContactId!);

              // Scroll when new message arrives
              _scrollToBottom();

              if (sorted.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet / Aucun message',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AdminColors.textLight,
                    ),
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final data = sorted[index].data() as Map<String, dynamic>;
                  final isMe = data['senderId'] == myUid;

                  return _MessageBubble(
                    text: data['text'] ?? '',
                    isMe: isMe,
                  );
                },
              );
            },
          ),
        ),

        // â”€â”€ Message Input Bar
        _buildMessageInput(service),
      ],
    );
  }

  // â”€â”€ Message Input Bar
  Widget _buildMessageInput(dynamic service) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AdminColors.cardBg,
        border: Border(
          top: BorderSide(color: AdminColors.border),
        ),
      ),
      child: Row(
        children: [
          // Send Button / Bouton envoyer
          ElevatedButton(
            onPressed: () async {
              final text = _messageCtrl.text.trim();
              if (text.isEmpty) return;

              _messageCtrl.clear();

              await service.sendMessage(
                _selectedContactId!,
                text,
              );

              _scrollToBottom();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(Icons.send_rounded, size: 18),
          ),

          const SizedBox(width: 12),

          // Text Input / Champ de texte
          Expanded(
            child: TextField(
              controller: _messageCtrl,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type a message... / Ã‰crire...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AdminColors.textLight,
                ),
                filled: true,
                fillColor: AdminColors.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AdminColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AdminColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AdminColors.primaryBlue,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              // Send on Enter / Envoyer avec EntrÃ©e
              onSubmitted: (text) async {
                if (text.trim().isEmpty) return;
                _messageCtrl.clear();
                await service.sendMessage(
                  _selectedContactId!,
                  text,
                );
                _scrollToBottom();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Contact Tile Widget
// Widget Ã‰lÃ©ment de contact
// ============================================
class _ContactTile extends StatefulWidget {
  final String name;
  final String role;
  final bool isSelected;
  final VoidCallback onTap;
  final Stream<int> unreadCountStream;

  const _ContactTile({
    required this.name,
    required this.role,
    required this.isSelected,
    required this.onTap,
    required this.unreadCountStream,
  });

  @override
  State<_ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<_ContactTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final roleColor = widget.role == 'doctor'
        ? AdminColors.primaryBlue
        : AdminColors.greenCard;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AdminColors.primaryBluePale
                : _isHovered
                    ? AdminColors.pageBg
                    : Colors.transparent,
            border: widget.isSelected
                ? const Border(
                    left: BorderSide(
                      color: AdminColors.primaryBlue,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: roleColor.withAlpha(38),
                child: Text(
                  widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'C',
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Name + Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _roleLabel(widget.role),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<int>(
                stream: widget.unreadCountStream,
                builder: (context, snapshot) {
                  final unread = snapshot.data ?? 0;
                  if (unread <= 0) return const SizedBox.shrink();
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AdminColors.danger,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$unread',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'doctor':
        return 'Doctor / MÃ©decin';
      case 'nurse':
        return 'Nurse / InfirmiÃ¨re';
      case 'patient':
        return 'Patient / Patiente';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }
}

// ============================================
// Message Bubble Widget
// Widget Bulle de message
// ============================================
class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _MessageBubble({
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        decoration: BoxDecoration(
          // Blue for me / Bleu pour moi
          // White for others / Blanc pour les autres
          color: isMe ? AdminColors.primaryBlue : AdminColors.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: AdminColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isMe ? Colors.white : AdminColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
