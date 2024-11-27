
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:transport_app/providers/auht_wrapper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCGQCKF0ZuOUuCgPHwXVyfTcLelowyqnvE", 
      appId: "com.example.transport_app", 
      messagingSenderId: "628109126126", 
      projectId: "transport-app-7ec0a", 
      authDomain: "transport-app-7ec0a.firebaseapp.com", 
      storageBucket: "transport-app-7ec0a.firebasestorage.app", 
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transport_app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthWrapper(),
      routes: {},
    );
  }
}


