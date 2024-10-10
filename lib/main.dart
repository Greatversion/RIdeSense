import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:risesense_lite/screens/map_screen.dart';
import 'package:risesense_lite/screens/splash_screen.dart';
import 'package:risesense_lite/services/provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: RideSense(),
    ),
  );
}

class RideSense extends StatelessWidget {
  const RideSense({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ridesense App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      routes: {
        MapDisplayScreen.routeName: (context) => MapDisplayScreen(),
      },
    );
  }
}
