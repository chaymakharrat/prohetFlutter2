import 'package:projet_flutter/models/notification.dart';
import 'package:projet_flutter/models/user_profile.dart';

class NotificationWithUsers {
  final AppNotification notification;
  final UserProfile sender;
  final UserProfile receiver;

  NotificationWithUsers({
    required this.notification,
    required this.sender,
    required this.receiver,
  });
}
