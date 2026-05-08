import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}

class ChatContact {
  final String id;
  final String name;
  final String role;
  final String lastMessage;
  final String time;
  final int unread;
  final bool isOnline;

  ChatContact({
    required this.id,
    required this.name,
    required this.role,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.isOnline,
  });
}

class ChatViewModel extends ChangeNotifier {
  String? _selectedContactId;
  String? get selectedContactId => _selectedContactId;
  final TextEditingController messageController = TextEditingController();

  List<ChatContact> contacts = [
    ChatContact(
      id: '1',
      name: 'Dr. Ahmed Ben Ali',
      role: 'Doctor',
      lastMessage: 'Patient needs review',
      time: '10:30',
      unread: 2,
      isOnline: true,
    ),
    ChatContact(
      id: '2',
      name: 'Fatima Hamadi',
      role: 'Nurse',
      lastMessage: 'Room 205 is ready',
      time: '09:15',
      unread: 0,
      isOnline: true,
    ),
    ChatContact(
      id: '3',
      name: 'Dr. Sara Belhaj',
      role: 'Doctor',
      lastMessage: 'Meeting at 2pm',
      time: 'Yesterday',
      unread: 1,
      isOnline: false,
    ),
    ChatContact(
      id: '4',
      name: 'Dr. Youssef Murad',
      role: 'Doctor',
      lastMessage: 'Thank you for the update',
      time: 'Yesterday',
      unread: 0,
      isOnline: false,
    ),
  ];

  Map<String, List<ChatMessage>> messages = {
    '1': [
      ChatMessage(
        id: '1',
        senderId: '1',
        senderName: 'Dr. Ahmed',
        text: 'Hello, patient Mariem needs urgent review',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isMe: false,
      ),
      ChatMessage(
        id: '2',
        senderId: 'me',
        senderName: 'Me',
        text: "OK, I'll check her file now",
        timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
        isMe: true,
      ),
      ChatMessage(
        id: '3',
        senderId: '1',
        senderName: 'Dr. Ahmed',
        text: 'Thank you. Please update me.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isMe: false,
      ),
    ],
    '2': [
      ChatMessage(
        id: '1',
        senderId: '2',
        senderName: 'Fatima',
        text: 'Room 205 has been prepared',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isMe: false,
      ),
      ChatMessage(
        id: '2',
        senderId: 'me',
        senderName: 'Me',
        text: 'Great, thank you Fatima!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isMe: true,
      ),
    ],
  };

  void selectContact(String id) {
    _selectedContactId = id;
    final index = contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      final c = contacts[index];
      contacts[index] = ChatContact(
        id: c.id,
        name: c.name,
        role: c.role,
        lastMessage: c.lastMessage,
        time: c.time,
        unread: 0,
        isOnline: c.isOnline,
      );
    }
    notifyListeners();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty || _selectedContactId == null) return;
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      senderName: 'Me',
      text: text.trim(),
      timestamp: DateTime.now(),
      isMe: true,
    );
    messages[_selectedContactId!] ??= [];
    messages[_selectedContactId!]!.add(msg);
    messageController.clear();
    notifyListeners();
  }

  List<ChatMessage> getMessages(String contactId) {
    return messages[contactId] ?? [];
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
