import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oziovariasi/screens/home_screen.dart';
import 'package:oziovariasi/screens/sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OZIOVARIASI',
            style: TextStyle(color: Colors.white)),
        centerTitle: true, // This centers the title
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 32.0),
            ToggleButtons(
              isSelected: [false, true],
              onPressed: (index) {
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                }
              },
              color: Colors.black,
              selectedColor: Colors.white,
              fillColor: Colors.black,
              borderColor: Colors.black,
              selectedBorderColor: Colors.black,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text('Sign Up'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text('Sign In'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sign In',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const SizedBox(height: 32.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                filled: true,
                fillColor: Colors.white70,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                filled: true,
                fillColor: Colors.white70,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                final password = _passwordController.text;

                if (email.isEmpty || !isValidEmail(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid email'),
                    ),
                  );
                  return;
                }

                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your password'),
                    ),
                  );
                  return;
                }

                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                } on FirebaseAuthException catch (error) {
                  if (error.code == 'user-not-found') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No user found with that email')),
                    );
                  } else if (error.code == 'wrong-password') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wrong password. Please try again.')),
                    );
                  } else {
                    setState(() {
                      _errorMessage = error.message ?? 'An error occurred';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_errorMessage),
                      ),
                    );
                  }
                } catch (error) {
                  setState(() {
                    _errorMessage = error.toString();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_errorMessage),
                    ),
                  );
                }
              },
              child: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 200.0, vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    String emailRegex =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$";
    RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }
}
