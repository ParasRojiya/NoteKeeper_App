import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notekeeper/screens/home_page.dart';
import 'package:notekeeper/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'splash_screen',
      routes: {
        'splash_screen': (context) => const SplashScreen(),
        'home_page': (context) => const HomePage(),
      },
    ),
  );
}
