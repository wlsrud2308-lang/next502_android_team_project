import 'package:flutter/material.dart';
import 'package:flutter_app/screens/detail_screen.dart'; // 본인 경로에 맞게 수정

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Next 502 Board',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
      ),
      home: const DetailScreen(postId: "123"),
    );
  }
}