import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String senderId;
  final String receiverId;
  final String rideId;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.rideId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "rideId": rideId,
      "type": type,
      "title": title,
      "body": body,
      "isRead": isRead,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  factory AppNotification.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      senderId: data["senderId"],
      receiverId: data["receiverId"],
      rideId: data["rideId"],
      type: data["type"],
      title: data["title"],
      body: data["body"],
      isRead: data["isRead"] ?? false,
      createdAt: (data["createdAt"] as Timestamp).toDate(),
    );
  }
}
