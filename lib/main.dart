import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../auth/sign_in_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      title: 'Gemini',
      debugShowCheckedModeBanner: false,
      home: FirebaseInitWrapper(),
    );
  }
}

class FirebaseInitWrapper extends StatefulWidget {
  const FirebaseInitWrapper({Key? key}) : super(key: key);

  @override
  State<FirebaseInitWrapper> createState() => _FirebaseInitWrapperState();
}

class _FirebaseInitWrapperState extends State<FirebaseInitWrapper> {
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  void _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "your api key",
          authDomain: "gemini-61a9a.firebaseapp.com",
          projectId: "gemini-61a9a",
          storageBucket: "gemini-61a9a.firebasestorage.app",
          messagingSenderId: "570443986062",
          appId: "1:570443986062:web:9a1429c4f26f3ec9b445df",
          measurementId: "G-Y1X2Q4EWN2",
        ),
      );
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const Scaffold(
        body: Center(
          child: Text('Failed to initialize Firebase'),
        ),
      );
    }

    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const SignInScreen();
  }
}
