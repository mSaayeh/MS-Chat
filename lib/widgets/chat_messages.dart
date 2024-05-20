import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }

        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        final chatMessages = chatSnapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(top: 30, right: 13, left: 13),
          reverse: true,
          itemCount: chatMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = chatMessages[index].data();
            final nextChatMessage = index + 1 < chatMessages.length
                ? chatMessages[index + 1].data()
                : null;

            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId = nextChatMessage?['userId'];

            final isCurrentUser = currentMessageUserId == currentUser.uid;

            if (currentMessageUserId == nextMessageUserId) {
              return MessageBubble.next(
                  message: chatMessage['text'], isMe: isCurrentUser);
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: isCurrentUser,
              );
            }
          },
        );
      },
    );
  }
}
