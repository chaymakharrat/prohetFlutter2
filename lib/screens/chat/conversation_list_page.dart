import 'package:flutter/material.dart';
import 'package:projet_flutter/controller/chat_controller.dart';
import 'package:projet_flutter/models/conversation.dart';
import 'package:projet_flutter/models/user_profile.dart';
import 'package:projet_flutter/screens/chat/chat_details_page.dart';
import 'package:projet_flutter/state/app_state.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ConversationListPage extends StatelessWidget {
  static const String routeName = '/conversations';
  
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final currentUserId = app.currentUser?.id;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text("Connectez-vous pour voir vos messages")),
      );
    }

    final ChatController chatController = ChatController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: chatController.getConversationsStream(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Aucune conversation", 
                       style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final conversations = snapshot.data!;

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ConversationTile(
                conversation: conversation,
                chatController: chatController,
                currentUserId: currentUserId,
              );
            },
          );
        },
      ),
    );
  }
}

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final ChatController chatController;
  final String currentUserId;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.chatController,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: chatController.getUserProfile(conversation.peerId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.name ?? 'Utilisateur inconnu';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF1976D2),
            child: Text(initial, style: const TextStyle(color: Colors.white)),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            conversation.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: conversation.unreadCount > 0 ? Colors.black87 : Colors.grey,
              fontWeight: conversation.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(conversation.updatedAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (conversation.unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${conversation.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailsPage(
                  peerId: conversation.peerId,
                  peerName: name,
                  currentUserId: currentUserId,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    if (DateTime.now().difference(date).inHours < 24) {
      return DateFormat('HH:mm').format(date);
    }
    return DateFormat('dd/MM').format(date);
  }
}
