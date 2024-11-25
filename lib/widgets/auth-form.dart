import 'package:flutter/material.dart';
 import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
class AuthForm extends StatefulWidget {
  final bool isLoading;
  final void Function(
    String email,
    String password,
    String username,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;
  final Future<void> Function(String email) requestAdminFn;

  const AuthForm(this.submitFn, this.isLoading, this.requestAdminFn);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final formKey = GlobalKey<FormState>();
  var isLogin = true;
  String userEmail = '';
  String userName = '';
  String userPassword = '';
  final emailController = TextEditingController();

  void trySubmit() {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      formKey.currentState!.save();
      widget.submitFn(
        userEmail.trim(),
        userPassword.trim(),
        userName.trim(),
        isLogin,
        context,
      );
    }
  }
 

Future<void> sendAdminRequestEmail(String email,String password,String name) async {
  final smtpServer = SmtpServer(
    'smtp.office365.com',
    port: 587, 
    username: 'mahdi.chekir@supcom.tn',
    password: 'mehdiB2002', 
  );

  // Construct the email
  final message = Message()
    ..from = Address('mahdi.chekir@supcom.tn', 'Transport App')
    ..recipients.add('mahdi.chekir@supcom.tn')
    ..headers = {'reply-to': email}
    ..subject = 'Admin Account Request'
    ..text = 'A user with the email $email has requested an admin account.'
    ..html = '''
      <p>A user with the email <b>$email</b> has requested an admin account.</p>
    <a href="mailto:$email?subject=AdminRequestConfirmed&body=Hi $name ,Your admin request was Confirmed.
      You can now login as admin in our platform using your credentiels:
      emailAdress : $email
      password : $password">Send Email</a>
      ''';

  try {
    await send(message, smtpServer);
    print('Email sent successfully!');
  } catch (e) {
    print('Failed to send email: $e');
    throw Exception('Failed to send email.');
  }
}





  void requestAdminAccount() async {
  final emailController = TextEditingController();
  final passwordController=TextEditingController();
  final nameController = TextEditingController();

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Request Admin Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email Adress'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          
            ],
          ),
        ),
        
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              final password = passwordController.text.trim();
              final name=nameController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid email address!'),
                  ),
                );
                return;
              }
              Navigator.of(ctx).pop();
              try {
                await sendAdminRequestEmail(email,password,name);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Admin account request sent successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to send admin account request.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Request'),
          ),
        ],
      );
    },
  );
}




@override
void dispose() {
  emailController.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(isLogin?'Login':'Signup',style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),),
        SizedBox(height: 5,),
        const Text('Please Enter Your Credentials Below'),
        Container(
            margin: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        key: const ValueKey('email'),
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid Email Address';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                             InputDecoration(labelText: 'Email Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0)
                            )),
                        onSaved: (value) {
                          userEmail = value!;
                        },
                      ),
                      const SizedBox(height: 16,),
                      if (!isLogin)
                        TextFormField(
                          key: const ValueKey('username'),
                          validator: (value) {
                            if (value!.isEmpty || value.length < 4) {
                              return 'Username must be at least 4 characters long';
                            }
                            return null;
                          },
                          decoration:  InputDecoration(labelText: 'Username',
                           border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0)
                            )),
                          onSaved: (value) {
                            userName = value!;
                          },
                        ),
                        if(!isLogin)
                        const SizedBox(height: 16,),
                      TextFormField(
                        key: const ValueKey('password'),
                        validator: (value) {
                          if (value!.isEmpty || value.length < 7) {
                            return 'Password must be at least 7 characters long';
                          }
                          return null;
                        },
                        decoration:  InputDecoration(labelText: 'Password',
                         border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0)
                            )),
                        obscureText: true,
                        onSaved: (value) {
                          userPassword = value!;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (widget.isLoading)
                        const CircularProgressIndicator(),
                      if (!widget.isLoading)
                        TextButton(
                          onPressed: trySubmit,
                          child: Text(isLogin ? 'Login' : 'Sign Up'),
                        ),
                      if (!widget.isLoading)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                          child: Text(
                            isLogin ? 'Create New Account' : 'Login Instead',
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (!widget.isLoading)
                        ElevatedButton(
                          onPressed: requestAdminAccount,
                          child: const Text('Request Admin Account'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    
  }
}
