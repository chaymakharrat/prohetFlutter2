import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id; // The other user's ID usually, or a unique ID
  final String peerId;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.peerId,
    required this.lastMessage,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  factory Conversation.fromMap(String id, Map<String, dynamic> data) {
    return Conversation(
      id: id,
      peerId: data['peerId'] ?? id, // Should be the document ID usually
      lastMessage: data['lastMessage'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: data['unreadCount'] ?? 0,
    );
  }
}
