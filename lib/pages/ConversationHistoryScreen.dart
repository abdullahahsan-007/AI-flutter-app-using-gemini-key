import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConversationHistoryScreen extends StatelessWidget {
  const ConversationHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current user ID from Firebase Auth
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // If the user is not authenticated, show an error message
      return Scaffold(
        appBar: AppBar(
          title: const Text('Conversation History'),
          centerTitle: true,
        ),
        body: const Center(child: Text('User is not authenticated.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query the 'messages' sub-collection under the authenticated user's document
        stream: FirebaseFirestore.instance
            .collection('conversations') // The collection for all users
            .doc(userId) // Get the current user's document using the userId
            .collection('messages') // Query the 'messages' sub-collection for the current user
            .orderBy('timestamp', descending: true) // Order messages by timestamp
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No conversation history available.'));
          }

          final conversationDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: conversationDocs.length,
            itemBuilder: (context, index) {
              final conversation = conversationDocs[index];
              final message = conversation['message'] ?? '';
              final sender = conversation['sender'] ?? 'Unknown';
              final timestamp = (conversation['timestamp'] as Timestamp).toDate();
              final formattedTime = '${timestamp.hour}:${timestamp.minute}';

              return ListTile(
                title: Text(sender),
                subtitle: Text(message),
                trailing: Text(formattedTime),
              );
            },
          );
        },
      ),
    );
  }
}
