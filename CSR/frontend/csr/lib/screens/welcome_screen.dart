import 'package:flutter/material.dart';
import 'package:csr/screens/login_screen.dart';
import 'package:csr/screens/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Light blue background
      body: SafeArea(
        child: Center(
          // Ensures everything is centered
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              Image.asset(
                'images/CSRlogo.jpeg', // Your updated transparent logo
                width: 200,
              ),
              Text(
                'Welcome to CSR!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800], // Accessing MaterialColor index
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Tap below to get started!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.blueGrey[600], // Accessing MaterialColor index
                    fontSize: 16,
                  ),
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen())),
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800], // Button color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              SizedBox(height: 20), // Adds space between the buttons
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen())),
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[300], // Button color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}