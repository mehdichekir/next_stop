import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_functions/cloud_functions.dart'; // For callable functions
import 'package:transport_app/widgets/auth-form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var isLoading = false;
  final auth = FirebaseAuth.instance;

  /// Function to handle form submission for login or signup
  void submitAuthForm(
    String email,
    String password,
    String userName,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential userCredential;
    try {
      setState(() {
        isLoading = true;
      });
      if (isLogin) {
        userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': userName,
          'email': email,
          'role': 'user', 
        });
      }
    } on PlatformException catch (err) {
      var message = 'An error occurred, Please check your credentials.';
      if (err.message != null) {
        message = err.message!;
      }
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      print(err);
    }
  }
  Future<void> requestAdminAccount(String email) async {
    try {
      setState(() {
        isLoading = true;
      });

      // Call Firebase Cloud Function to send admin request email
      final functions = FirebaseFunctions.instance;
      final callable = FirebaseFunctions.instance.httpsCallable('sendAdminRequestEmail');
      final result = await callable.call({'email': email});

      if (result.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin account request sent!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send admin account request.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (err) {
      print(err.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while sending the request.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(300),
        child: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset('assets/logo.png',height: 1000,),
              const Text('Sign In')
            ],
          ),
          backgroundColor: Colors.lightBlue,
        ),
      ) ,
      backgroundColor: Colors.white,
      body: AuthForm(
        submitAuthForm,
        isLoading,
        requestAdminAccount, 
      ),
    );
  }
}
