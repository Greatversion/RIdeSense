import 'package:flutter/material.dart';
import 'dart:async';

import 'package:risesense_lite/screens/input_screen.dart'; // For setting a timer for splash duration


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Navigate to the LocationInputScreen after a delay (splash duration)
  void _navigateToHome() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LocationInputScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/logo.png', // Path to your image
          width: 200, // Adjust size as needed
          height: 200, // Adjust size as needed
        ),
      ),
    );
  }
}
