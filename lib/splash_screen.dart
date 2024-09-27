// splash_screen.dart

import 'package:flutter/material.dart';
import 'notes_list.dart'; // Import your main notes list page

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(
        Duration(seconds: 1)); // Duration for the splash screen (faster)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NotesList()), // Your main page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.yellow.shade300, // Light yellow
              Colors.yellow.shade800, // Darker yellow
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replace this with your app logo
              Image.asset('assets/logo.png', width: 250), // Use your logo image
              SizedBox(height: 20),
              SizedBox(
                width: 16, // Set the width of the loading indicator
                height: 16, // Set the height of the loading indicator
                child: CircularProgressIndicator(
                  color: Colors.black, // Black color for the loading indicator
                  strokeWidth: 1, // Adjust stroke width to make it thinner
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
