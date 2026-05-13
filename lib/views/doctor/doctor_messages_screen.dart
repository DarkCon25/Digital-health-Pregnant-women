import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/admin_colors.dart';
import '../../services/doctor_service.dart';
import '../../widgets/responsive_dashboard_shell.dart';

class DoctorMessagesScreen extends StatefulWidget {
  const DoctorMessagesScreen({super.key});

  @override
  State<DoctorMessagesScreen> createState() => _DoctorMessagesScreenState();
}

class _DoctorMessagesScreenState extends State<DoctorMessagesScreen> {
  String? _selectedContactId;
  String _selectedContactName = '';
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<DoctorService>();

    return ResponsiveHorizontalSplit(
      leftWidth: 280,
      minRightWidth: 360,
      between: const VerticalDivider(width: 1, color: AdminColors.border),
      betweenWidth: 1,
      left: _buildContactsList(service),
      right: _selectedContactId == null
          ? _buildNoChatSelected()
          : _buildChatArea(service),
    );
  }

  Widget _buildContactsList(DoctorService service) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    return Container(
      color: AdminColors.cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const Divider(color: AdminColors.border, height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: service.staffContactsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AdminColors.primaryBlue),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading contacts',
                      style: GoogleFonts.inter(color: AdminColors.danger),
                    ),
                  );
                }
                final contacts = (snapshot.data?.docs ?? [])
                    .where((d) => d.id != myUid)
                    .toList();
                if (contacts.isEmpty) {
                  return Center(
                    child: Text(
                      'No contacts found',
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
                    final doc = contacts[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final fullName =
                        '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
                    final role = (data['role'] as String?) ?? '';
                    final isSelected = _selectedContactId == doc.id;
                    return _ContactTile(
                      name: fullName.isEmpty ? doc.id : fullName,
                      role: role,
                      isSelected: isSelected,
                      unreadCountStream: service.unreadCountStream(doc.id),
                      onTap: () => setState(() {
                        _selectedContactId = doc.id;
                        _selectedContactName = fullName.isEmpty ? doc.id : fullName;
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
        ],
      ),
    );
  }

  Widget _buildChatArea(DoctorService service) {
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: AdminColors.cardBg,
            border: Border(bottom: BorderSide(color: AdminColors.border)),
          ),
          child: Row(
            children: [
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
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: service.messagesForChat(_selectedContactId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AdminColors.primaryBlue),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading messages',
                    style: GoogleFonts.inter(color: AdminColors.danger),
                  ),
                );
              }
              final messages = snapshot.data?.docs ?? [];
              final sorted = [...messages]..sort((a, b) {
                final aTs =
                    (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                final bTs =
                    (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                final aMs = aTs?.millisecondsSinceEpoch ?? 0;
                final bMs = bTs?.millisecondsSinceEpoch ?? 0;
                return aMs.compareTo(bMs);
              });
              service.markMessagesAsRead(_selectedContactId!);
              _scrollToBottom();
              if (sorted.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet',
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
                  return _MessageBubble(
                    text: (data['text'] as String?) ?? '',
                    isMe: data['senderId'] == myUid,
                  );
                },
              );
            },
          ),
        ),
        _buildMessageInput(service),
      ],
    );
  }

  Widget _buildMessageInput(DoctorService service) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AdminColors.cardBg,
        border: Border(top: BorderSide(color: AdminColors.border)),
      ),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () async {
              final text = _messageCtrl.text.trim();
              if (text.isEmpty || _selectedContactId == null) return;
              _messageCtrl.clear();
              await service.sendMessage(_selectedContactId!, text);
              _scrollToBottom();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(Icons.send_rounded, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageCtrl,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: AdminColors.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AdminColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AdminColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AdminColors.primaryBlue, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onSubmitted: (text) async {
                final t = text.trim();
                if (t.isEmpty || _selectedContactId == null) return;
                _messageCtrl.clear();
                await service.sendMessage(_selectedContactId!, t);
                _scrollToBottom();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.name,
    required this.role,
    required this.isSelected,
    required this.unreadCountStream,
    required this.onTap,
  });

  final String name;
  final String role;
  final bool isSelected;
  final Stream<int> unreadCountStream;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final roleColor = role == 'doctor'
        ? AdminColors.primaryBlue
        : role == 'nurse'
            ? AdminColors.greenCard
            : AdminColors.warning;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primaryBluePale : Colors.transparent,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: AdminColors.primaryBlue, width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: roleColor.withAlpha(38),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'C',
                style: TextStyle(
                  color: roleColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    role,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<int>(
              stream: unreadCountStream,
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
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
    required this.isMe,
  });

  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        decoration: BoxDecoration(
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
