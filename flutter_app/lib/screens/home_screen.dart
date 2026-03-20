import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/screens/edit_screen.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/movie_info.dart';
import 'package:flutter_app/screens/search_screen.dart';
import 'package:flutter_app/service/post_service.dart';
import 'package:flutter_app/service/post_service_impl.dart';
import 'package:flutter_app/models/post_model.dart';
import 'package:flutter_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_app/widgets/popular_posts.dart';

import 'global_post_list.dart';


class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({super.key});

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

class _MovieHomeScreenState extends State<MovieHomeScreen> {
  int _selectedCategoryIndex = 0;
  int _selectedBottomIndex = 0; // ← 하단 네비바 선택 인덱스
  final List<String> _categories = [
    "인기글",
    "영화 정보",
    "해외영화",
    "국내영화",
    "자유게시판",
  ];

  late Future<List<PostDto>> _posts;
  final PostService _postService = PostServiceImpl();

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    if (_selectedCategoryIndex == 0) {
      _posts = fetchPopularPosts();
    } else {
      String boardType = _categories[_selectedCategoryIndex] == '자유게시판'
          ? '자유'
          : _categories[_selectedCategoryIndex].replaceAll('영화', '');
      _posts = fetchPosts(boardType);
    }
  }

  Future<List<PostDto>> fetchPosts(String boardType) async {
    try {
      var posts = await _postService.getPostsByBoard(boardType);
      return posts;
    } catch (e) {
      return [];
    }
  }

  Future<List<PostDto>> fetchPopularPosts() async {
    try {
      var posts = await _postService.getPopularPosts();
      return posts;
    } catch (e) {
      return [];
    }
  }

  // 🚀 카테고리 클릭 핸들러 수정
  void _changeCategory(int index) {
    String categoryName = _categories[index];

    if (categoryName == "영화 정보") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MovieListScreen()),
      );
    }
    else if (categoryName == "해외영화") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MovieBoardScreen()),
      );

    }

    setState(() {
      _selectedCategoryIndex = index;
      if (categoryName == "인기글") {
        _posts = fetchPopularPosts();
      } else {
        String boardType = categoryName == '자유게시판'
            ? '자유'
            : categoryName.replaceAll('영화', '');
        _posts = fetchPosts(boardType);
      }
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedBottomIndex = index;
      _changeCategory(index); // 하단 네비바와 기존 카테고리 연동
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: const Icon(Icons.movie_filter, color: Colors.purpleAccent),
        title: const Text("영화 앱", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white30),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white30),
            onPressed: () {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(title: "로그인")));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBoxOfficeBar(),
          _buildBarCategoryNav(),
          Expanded(child: _buildSelectedCategoryContent()),
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
      decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(rate, style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBarCategoryNav() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategoryIndex == index;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _changeCategory(index),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isSelected ? Colors.purpleAccent : Colors.transparent, width: 3)),
                ),
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white38,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedCategoryContent() {
    if (_selectedCategoryIndex == 0) {
      return const PopularPosts();
    } else {
      return _buildPostList();
    }
  }

  Widget _buildPostList() {
    return FutureBuilder<List<PostDto>>(
      key: ValueKey<String>(_categories[_selectedCategoryIndex]),
      future: _posts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('게시글이 없습니다.', style: TextStyle(color: Colors.white54)));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var post = snapshot.data![index];
              return _buildPostItem(post);
            },
          );
        }
      },
    );
  }

  Widget _buildPostItem(PostDto post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35,
            child: Text(
              post.postId.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(post.category ?? '기타', style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 11)),
                    const SizedBox(width: 10),
                    Text(post.authorName, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(width: 10),
                    Text(post.createdAt, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text("💬 ${post.commentCnt}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}