import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Next 502',
      debugShowCheckedModeBanner: false, // 디버그 띠 제거
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 로딩 중일 때
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // 로그인 정보(snapshot.hasData)가 있으면 메인 화면으로
          if (snapshot.hasData) {
            return const MainMapScreen(); // 로그인이 된 경우 보여줄 화면
          }
          // 로그인 정보가 없으면 로그인 페이지로!
          return const LoginPage(title: "Next 502 Login");
        },
      ),
    );
  }
}

class MainMapScreen extends StatelessWidget {
  const MainMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("부산 빈티지 맵"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(), // 로그아웃 시 자동으로 로그인창 이동
          )
        ],
      ),
      body: const Center(child: Text("여기에 지도를 띄울 예정입니다!")),
    );
  }
}
