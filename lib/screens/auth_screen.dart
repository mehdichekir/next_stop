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
  bool isLogin = false;
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
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
      ),
      backgroundColor: Colors.lightBlue,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.lightBlue,
              height: 200,
              width: double.maxFinite,
              child: Image.asset(
                'assets/logo.png',
                height: 200, // Reduced height
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                color: Colors.white,
                border: Border(
                  top: BorderSide(width: 2, color: Colors.black), // Border on top
                  left: BorderSide(width: 2, color: Colors.black), // Border on left
                  right: BorderSide(width: 2, color: Colors.black), // Border on right
                ),
              ),
              child: AuthForm(
                submitAuthForm,
                isLogin,
                requestAdminAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
