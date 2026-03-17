import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/widgets/movie_list_page.dart';
import 'firebase_options.dart';
import 'models/tmdb_sync_page.dart';

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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 로그인 정보(snapshot.hasData)가 있으면 영화 리스트 화면으로 바로 이동
          if (snapshot.hasData) {
            return const MovieListPage();
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
          // ✅ TMDB 강제 동기화 버튼
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TMDBSyncPage()),
              );
            },
          ),

          // ✅ 영화 리스트 보기
          IconButton(
            icon: const Icon(Icons.movie),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MovieListPage()),
              );
            },
          ),

          // 로그아웃
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: const Center(child: Text("여기에 지도를 띄울 예정입니다!")),
    );
  }
}