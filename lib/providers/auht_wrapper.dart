import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transport_app/screens/choose_mean_screen.dart';
import 'package:transport_app/screens/homeScreen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); 
        } else if (snapshot.hasData) {
          final userId = snapshot.data?.uid;
          print('Logged-in User ID: $userId'); 
          return ChooseMeanScreen(userId! );
        } else {
          return HomePage();
        }
      },
    );
  }
}
