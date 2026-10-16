import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Screens/splash_screen.dart';
import 'notifications/noti.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseApi firebaseApi = FirebaseApi();
    await firebaseApi.initialize();
  } catch (e) {
    debugPrint('Firebase initialization caught: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ABR Greens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
