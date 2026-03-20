import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/models/post_model.dart';
import 'package:flutter_app/screens/domestic_screen.dart';
import 'package:flutter_app/screens/edit_screen.dart';
import 'package:flutter_app/screens/free_screen.dart';
import 'package:flutter_app/screens/global_post_list.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/search_screen.dart';
import 'package:flutter_app/screens/movie_info.dart';
import 'package:flutter_app/service/post_service.dart';
import 'package:flutter_app/service/post_service_impl.dart';
import 'package:flutter_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_app/widgets/popular_posts.dart';

// RouteObserver 필요
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({super.key});

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

// RouteAware로 다른 화면에서 돌아올 때 감지
class _MovieHomeScreenState extends State<MovieHomeScreen> with RouteAware {
  int _selectedBottomIndex = 0; // 하단 네비바 선택 인덱스
  final PostService _postService = PostServiceImpl();
  late Future<List<PostDto>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = _postService.getPopularPosts(); // 초기 인기글
  }

  // RouteAware 등록
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // 다른 화면에서 돌아왔을 때
  @override
  void didPopNext() {
    setState(() {
      _posts = _postService.getPopularPosts(); // 인기글 새로고침
      _selectedBottomIndex = 0;
    });
  }

  void _onBottomNavTap(int index) {
    if (index == _selectedBottomIndex) return;

    if (index == 0) {
      // 홈 버튼 클릭 → 인기글 새로고침
      setState(() {
        _posts = _postService.getPopularPosts();
        _selectedBottomIndex = 0;
      });
    } else {
      Widget nextScreen;
      switch (index) {
        case 1:
          nextScreen = const MovieListScreen(); // 영화 정보
          break;
        case 2:
          nextScreen = const MovieBoardScreen(); // 해외 영화
          break;
        case 3:
          nextScreen = const DomesticMovieBoardScreen(); // 국내 영화
          break;
        case 4:
          nextScreen = const FreeBoardScreen(); // 자유게시판
          break;
        default:
          return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );

      setState(() {
        _selectedBottomIndex = index;
      });
    }
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white30),
            onPressed: () {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfilePage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const LoginPage(title: "로그인")),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBoxOfficeBar(),
          Expanded(child: PopularPosts()), // 항상 인기글만 표시
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedBottomIndex,
        onTap: _onBottomNavTap,
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
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(rate,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}