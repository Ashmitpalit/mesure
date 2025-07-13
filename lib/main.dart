import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/camera_measure_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MesureApp());
}

class MesureApp extends StatelessWidget {
  const MesureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesure',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.redAccent,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/measure': (_) => const CameraMeasureScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
