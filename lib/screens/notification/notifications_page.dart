import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projet_flutter/controller/notification_controller.dart';
import 'package:projet_flutter/models/dto/notification_with_users.dart';
import 'package:projet_flutter/state/app_state.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  static const String routeName = '/notifications';

  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationController _notificationController =
      NotificationController();
  List<NotificationWithUsers> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final app = context.read<AppState>();
    final userId = app.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final notifs = await _notificationController.getUserNotifications(userId);
    // final notifs = await _notificationController.getUserNotifications(
    //   "hPilSNcM1JPdEPalsPSwhJxHOfy2",
    // );
    //if (mounted) {
    setState(() {
      _notifications = notifs;
      _isLoading = false;
    });
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Aucune notification",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final item = _notifications[index];
                final notif = item.notification;
                final sender = item.sender;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: notif.isRead ? Colors.white : const Color(0xFFE3F2FD),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1976D2),
                      child: Text(
                        sender.name.isNotEmpty
                            ? sender.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: notif.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: const Color(0xFF0D47A1),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          notif.body,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(notif.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      if (!notif.isRead) {
                        await _notificationController.markAsRead(notif.id);
                        await _loadNotifications();
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
