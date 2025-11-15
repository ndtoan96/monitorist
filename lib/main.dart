import 'package:flutter/material.dart';
import 'package:monitorist/edit_view.dart';
import 'package:monitorist/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitorist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      // home: const HomeView(),
      // home: EditView.editProfile(name: "Profile 1"),
      home: const EditView.newProfile(),
    );
  }
}
