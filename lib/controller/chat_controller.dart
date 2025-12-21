import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_flutter/models/chat_message.dart';
import 'package:projet_flutter/models/conversation.dart';
import 'package:projet_flutter/controller/user_controller.dart';
import 'package:projet_flutter/models/user_profile.dart';

class ChatController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UserController _userController = UserController();

  /// Envoie un message et met à jour les conversations des deux parties
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String body,
    String type = 'text',
  }) async {
    final timestamp = FieldValue.serverTimestamp();
    
    // 1. Ajouter le message dans la sous-collection du sender
    final senderMsgRef = _db
        .collection('users')
        .doc(senderId)
        .collection('conversations')
        .doc(receiverId)
        .collection('messages')
        .doc();
    
    final messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type,
      'body': body,
      'createdAt': timestamp,
      'isRead': true, // Lu par l'expéditeur
    };

    await senderMsgRef.set(messageData);

    // 2. Mettre à jour la conversation du sender
    await _db
        .collection('users')
        .doc(senderId)
        .collection('conversations')
        .doc(receiverId)
        .set({
      'peerId': receiverId,
      'lastMessage': body,
      'updatedAt': timestamp,
      'unreadCount': 0, // Pas de non-lus pour soi-même
    }, SetOptions(merge: true));

    // 3. Ajouter le message dans la sous-collection du receiver
    final receiverMsgRef = _db
        .collection('users')
        .doc(receiverId)
        .collection('conversations')
        .doc(senderId)
        .collection('messages')
        .doc(senderMsgRef.id); // Utiliser le même ID pour faciliter le suivi si besoin

    await receiverMsgRef.set({
      ...messageData,
      'isRead': false,
    });

    // 4. Mettre à jour la conversation du receiver (incrémenter unreadCount)
    final receiverConvRef = _db
        .collection('users')
        .doc(receiverId)
        .collection('conversations')
        .doc(senderId);
        
    // Transaction pour incrémenter unreadCount de manière atomique
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(receiverConvRef);
      int currentUnread = 0;
      if (snapshot.exists) {
        currentUnread = snapshot.data()?['unreadCount'] ?? 0;
      }
      transaction.set(receiverConvRef, {
        'peerId': senderId,
        'lastMessage': body,
        'updatedAt': timestamp,
        'unreadCount': currentUnread + 1,
      }, SetOptions(merge: true));
    });
  }

  /// Flux des conversations (pour la liste des chats)
  Stream<List<Conversation>> getConversationsStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Conversation.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Flux des messages d'une conversation spécifique
  Stream<List<ChatMessage>> getMessagesStream(String userId, String peerId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(peerId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Marquer les messages comme lus
  Future<void> markMessagesAsRead(String userId, String peerId) async {
    final conversationRef = _db
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(peerId);

    // 1. Reset unreadCount (set avec merge évite l'erreur not-found si nouvelle conversation)
    await conversationRef.set({'unreadCount': 0}, SetOptions(merge: true));

    // 2. Update isRead status in messages (optional, expensive if many messages)
    // On peut le faire uniquement pour les messages non lus récents
    final unreadQuery = conversationRef
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isEqualTo: peerId); // Seulement les messages reçus
    
    final snapshot = await unreadQuery.get();
    for (var doc in snapshot.docs) {
      // Batch write serait mieux ici pour la performance
      await doc.reference.update({'isRead': true});
    }
  }

  /// Helper pour récupérer le UserProfile d'un peer
  Future<UserProfile?> getUserProfile(String userId) {
    return _userController.getUserProfile(userId);
  }
}
