import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/screens/global_post_list.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/movie_info.dart';
import 'package:flutter_app/screens/domestic_screen.dart';
import 'package:flutter_app/screens/free_screen.dart';
import 'package:flutter_app/screens/search_screen.dart';
import 'package:flutter_app/screens/edit_screen.dart';
import 'package:flutter_app/service/post_service_impl.dart';
import 'package:flutter_app/models/post_model.dart';
import 'package:flutter_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_app/widgets/popular_posts.dart';

class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({super.key});

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

class _MovieHomeScreenState extends State<MovieHomeScreen> {
  int _selectedIndex = 0; // 홈 기본 선택
  final PostServiceImpl _postService = PostServiceImpl();
  late Future<List<PostDto>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = _postService.getPopularPosts(); // 인기글 초기 로드
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;

    Widget nextScreen;

    switch (index) {
      case 0:
        nextScreen = const MovieHomeScreen(); // 홈
        break;
      case 1:
        nextScreen = const MovieListScreen(); // 영화정보
        break;
      case 2:
        nextScreen = const MovieBoardScreen(); // 해외
        break;
      case 3:
        nextScreen = const DomesticMovieBoardScreen(); // 국내
        break;
      case 4:
        nextScreen = const FreeBoardScreen(); // 자유게시판
        break;
      default:
        return;
    }

    // 현재 화면 교체, 뒤로가기는 홈으로 돌아갈 수 있음
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: const Icon(Icons.movie_filter, color: Colors.purpleAccent),
        title: const Text("영화 앱", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white30),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white30),
            onPressed: () {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage(title: "로그인")));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBoxOfficeBar(),
          Expanded(child: PopularPosts()),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildBoxOfficeBar() {
    return Container(
      height: 55,
      color: const Color(0xFF1A1A1A),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _boxOfficeTile("파묘", "45.2%"),
          _boxOfficeTile("듄: 파트2", "30.1%"),
          _boxOfficeTile("웡카", "12.5%"),
          _boxOfficeTile("가여운 것들", "5.8%"),
        ],
      ),
    );
  }

  Widget _boxOfficeTile(String title, String rate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(rate,
              style: const TextStyle(
                  fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}