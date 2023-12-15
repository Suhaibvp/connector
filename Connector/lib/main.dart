import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/auth_page.dart';
import 'pages/loading_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        // Simulate an asynchronous process (e.g., initializing)
        future: Future.delayed(
            Duration(seconds: 10)), // Adjust the duration as needed
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting, show the loading screen
            return LoadingPage();
          } else {
            // After waiting, navigate to the main page
            return Authpage(); // Replace with your main page
          }
        },
      ),
    );
  }
}
