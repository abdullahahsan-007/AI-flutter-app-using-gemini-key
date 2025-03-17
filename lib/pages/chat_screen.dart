import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/message.dart';
import '../models/messages.dart';
import '../utils/size.dart';
import '../utils/style.dart';
import 'ConversationHistoryScreen.dart';  



class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userMessage = TextEditingController();
  bool isLoading = false;

  static const apiKey = "gemini api key"; // Your Gemini API key

  final List<Message> _messages = [];

  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String userId; // User ID from Firebase Auth

  @override
  void initState() {
    super.initState();
    // Get the current user ID from Firebase Auth
    final user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;  // Use Firebase's unique user ID
    } else {
      userId = DateTime.now().millisecondsSinceEpoch.toString(); // Fallback (in case user is not logged in)
    }
  }

  void sendMessage() async {
    final message = _userMessage.text;
    _userMessage.clear();

    setState(() {
      _messages.add(Message(
        isUser: true,
        message: message,
        date: DateTime.now(),
      ));
      isLoading = true;
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _messages.add(Message(
        isUser: false,
        message: response.text ?? "",
        date: DateTime.now(),
      ));
    });

    // Save message in Firestore under the authenticated user's ID
    await _firestore.collection('conversations').doc(userId).collection('messages').add({
      'message': message,
      'sender': 'User', // Assuming the sender is the user, update as necessary
      'timestamp': FieldValue.serverTimestamp(),
    });
  
    // Save the AI response to Firestore
    await _firestore.collection('conversations').doc(userId).collection('messages').add({
      'message': response.text ?? "",
      'sender': 'AI',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void onAnimatedTextFinished() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: Text('Gemini', style: GoogleFonts.poppins(color: white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: white),
            onPressed: () {
              // Navigate to the conversation history screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConversationHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Messages(
                  isUser: message.isUser,
                  message: message.message,
                  date: DateFormat('HH:mm').format(message.date),
                  onAnimatedTextFinished: onAnimatedTextFinished,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: medium, vertical: small),
            child: Expanded(
              flex: 20,
              child: TextFormField(
                maxLines: 6,
                minLines: 1,
                controller: _userMessage,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(medium, 0, small, 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(xlarge),
                  ),
                  hintText: 'Enter prompt',
                  hintStyle: hintText,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      if (!isLoading && _userMessage.text.isNotEmpty) {
                        sendMessage();
                      }
                    },
                    child: isLoading
                        ? Container(
                      width: medium,
                      height: medium,
                      margin: const EdgeInsets.all(xsmall),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(white),
                        strokeWidth: 3,
                      ),
                    )
                        : Icon(
                      Icons.arrow_upward,
                      color: _userMessage.text.isNotEmpty ? Colors.white : const Color(0x5A6C6C65),
                    ),
                  ),
                ),
                style: promptText,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
