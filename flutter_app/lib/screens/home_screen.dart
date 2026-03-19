import 'package:flutter/material.dart';
import 'package:flutter_app/screens/edit_screen.dart';
import 'package:flutter_app/screens/movie_info.dart';
import 'package:flutter_app/service/post_service.dart';
import 'package:flutter_app/service/post_service_impl.dart';
import 'package:flutter_app/models/post_model.dart';  // 게시글 모델

class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({super.key});

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

class _MovieHomeScreenState extends State<MovieHomeScreen> {
  int _selectedCategoryIndex = 3;  // 기본적으로 자유게시판을 첫 번째로 선택
  final List<String> _categories = [
    "영화 정보",
    "해외영화",
    "국내영화",
    "자유게시판"
  ];

  late Future<List<PostDto>> _posts;  // 게시글 목록을 담을 Future

  final PostService _postService = PostServiceImpl();  // 서비스 객체

  @override
  void initState() {
    super.initState();
    _posts = fetchPosts("자유");  // 기본적으로 자유 게시판 데이터를 "자유"로 불러옴
  }

  // 게시판 카테고리 변경 시 데이터 가져오기
  Future<List<PostDto>> fetchPosts(String boardType) async {
    try {
      var posts = await _postService.getPostsByBoard(boardType);
      return posts;
    } catch (e) {
      return [];  // 오류 발생 시 빈 리스트 반환
    }
  }

  // 탭을 변경할 때마다 새로운 데이터를 가져오기
  void _changeCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      // 영화 정보 탭 클릭 시 MovieListScreen으로 이동
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MovieListScreen(), // 영화 정보 화면
          ),
        );
      } else {
        // '자유게시판'을 '자유'로 변경
        String boardType = _categories[index] == '자유게시판' ? '자유' : _categories[index].replaceAll('영화', '');
        _posts = fetchPosts(boardType);  // 새로운 Future 객체 할당
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: const Icon(Icons.movie_filter, color: Colors.purpleAccent),
        title: const Text("영화 앱"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white30),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white30),
            onPressed: () {
              // 버튼 누르면 EditProfilePage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBoxOfficeBar(),
          _buildBarCategoryNav(),
          Expanded(
            child: _buildSelectedCategoryContent(),  // 선택된 카테고리의 게시글 내용 표시
          ),
        ],
      ),
    );
  }

  // ====================== 박스오피스 바
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

  // ====================== 카테고리 바
  Widget _buildBarCategoryNav() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategoryIndex == index;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _changeCategory(index);  // 탭을 변경할 때 데이터를 갱신
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? Colors.purpleAccent
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white38,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
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

  // ====================== 선택된 카테고리 콘텐츠 (게시글 목록)
  Widget _buildSelectedCategoryContent() {
    return FutureBuilder<List<PostDto>>(
      key: ValueKey<String>(_categories[_selectedCategoryIndex]),  // key를 사용하여 새로운 Future로 강제 갱신
      future: _posts,  // _posts는 현재 선택된 카테고리에 해당하는 게시글 리스트
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('게시글 로드 실패'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('게시글이 없습니다.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var post = snapshot.data![index];
              return _buildPostItem(
                context,
                post.postId.toString(),
                post.title,
                post.category ?? '기타',
                post.authorName,
                post.createdAt,
                post.commentCnt,
              );
            },
          );
        }
      },
    );
  }

  // ====================== 게시글 아이템
  Widget _buildPostItem(
      BuildContext context,
      String rank,
      String title,
      String category,
      String author,
      String time,
      int comments,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35,
            child: Text(rank,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(category,
                        style: const TextStyle(
                            color: Colors.lightBlueAccent, fontSize: 11)),
                    const SizedBox(width: 10),
                    Text(author,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                    const SizedBox(width: 10),
                    Text(time,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text("💬 $comments",
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}