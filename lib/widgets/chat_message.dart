import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? const Center(child: CircularProgressIndicator())
          : !snapshot.hasData || snapshot.data!.docs.isEmpty
              ? const Center(
                  child: Text('No messages found'),
                )
              : snapshot.hasError
                  ? const Center(
                      child: Text('Something went wrong'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        bottom: 40,
                        left: 13,
                        right: 13,
                      ),
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final loadedMessage = snapshot.data!.docs;
                        final chatMessage = snapshot.data!.docs[index].data();
                        final nextChatMessage = index + 1 < loadedMessage.length
                            ? loadedMessage[index + 1].data()
                            : null;

                        final currentMessageUserName = chatMessage['userId'];
                        final nextMessageUsername = nextChatMessage != null
                            ? nextChatMessage['userId']
                            : null;
                        final nextUserIsSame =
                            nextMessageUsername == currentMessageUserName;

                        if (nextUserIsSame) {
                          return MessageBubble.next(
                              message: chatMessage['text'],
                              isMe: authenticatedUser.uid ==
                                  currentMessageUserName);
                        } else {
                          MessageBubble.first(
                              userImage: chatMessage['userIamge'],
                              username: chatMessage['username'],
                              message: chatMessage['text'],
                              isMe: authenticatedUser.uid ==
                                  currentMessageUserName);
                        }
                      }),
    );
  }
}
