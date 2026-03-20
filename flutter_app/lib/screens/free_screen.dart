import 'package:flutter/material.dart';
import 'package:flutter_app/models/post_model.dart';
import 'package:flutter_app/screens/global_post_list.dart';
import 'package:flutter_app/service/post_service.dart';
import 'package:flutter_app/service/post_service_impl.dart';
import 'package:flutter_app/widgets/bottom_nav_bar.dart';
import 'detail_screen.dart';
import 'domestic_screen.dart';
import 'movie_info.dart';

class FreeBoardScreen extends StatefulWidget {
  const FreeBoardScreen({super.key});

  @override
  State<FreeBoardScreen> createState() => _FreeBoardScreen();
}

class _FreeBoardScreen extends State<FreeBoardScreen> {
  final PostService _postService = PostServiceImpl();
  late Future<List<PostDto>> _postsFuture;
  String _currentSort = "최신순";

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      _postsFuture = _postService.getPostsByBoard("자유");
    });
  }

  // 🚀 하단 네비바 클릭 핸들러 (전체 연결 버전)
  void _onBottomNavTap(int index) {
    // 1. 현재 게시판과 같은 탭을 누르면 아무것도 하지 않음
    // (해외: 2, 국내: 3, 자유: 4 등 각 파일에 맞게 수정)
    if (index == 4) return;

    if (index == 0) {
      // 2. 홈으로 갈 때 0을 반환하며 팝!
      // (홈 화면의 await Navigator.push 결과값으로 0이 전달됨)
      Navigator.pop(context, 0);
    } else {
      // 3. 다른 게시판/메뉴로 이동할 때는 화면을 즉시 교체 (Replacement)
      Widget nextScreen;
      switch (index) {
        case 1:
          nextScreen = const MovieListScreen();
          break;
        case 3:
          nextScreen = const DomesticMovieBoardScreen();
          break;
        case 2:
          nextScreen = const MovieBoardScreen();
          break;
        default:
          return;
      }

      // 현재 화면을 새 화면으로 갈아끼우기
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      ).then((value) {
        // 💡 만약 교체된 화면에서 사용자가 '홈'을 눌러 pop(0)이 발생하면,
        // 그 값을 다시 부모(진짜 홈 화면)까지 전달합니다.
        if (value != null) Navigator.pop(context, value);
      });
    }
  }

  List<PostDto> _getSortedPosts(List<PostDto> posts) {
    List<PostDto> sortedList = List.from(posts);
    if (_currentSort == "최신순") {
      sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_currentSort == "추천순") {
      sortedList.sort((a, b) => b.likeCnt.compareTo(a.likeCnt));
    } else if (_currentSort == "조회순") {
      sortedList.sort((a, b) => b.viewCnt.compareTo(a.viewCnt));
    }
    return sortedList;
  }

  Future<void> _onRefresh() async {
    _loadPosts();
    await _postsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("자유게시판", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black12, height: 1),
        ),
      ),
      body: Column(
        children: [
          _buildUtilityBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.indigoAccent,
              child: FutureBuilder<List<PostDto>>(
                future: _postsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("데이터를 불러오지 못했습니다."));
                  }
                  final rawPosts = snapshot.data ?? [];
                  if (rawPosts.isEmpty) {
                    return const Center(child: Text("게시글이 없습니다."));
                  }

                  final posts = _getSortedPosts(rawPosts);

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) => _buildEnhancedPostItem(posts[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 4,
        onTap: _onBottomNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print("글쓰기"),
        backgroundColor: const Color(0xFF2C2C2C),
        mini: true,
        child: const Icon(Icons.edit, color: Colors.white, size: 20),
      ),
    );
  } // build 메서드 끝

  // 🛠️ 여기서부터 아래 함수들은 모두 _MovieBoardScreenState 클래스 내부에 있어야 합니다.

  Widget _buildUtilityBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          _miniTab("최신순"),
          _miniTab("추천순"),
          _miniTab("조회순"),
        ],
      ),
    );
  }

  Widget _miniTab(String label) {
    bool isSelected = _currentSort == label;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _currentSort = label;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.indigoAccent : Colors.black26,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedPostItem(PostDto post) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(postId: post.postId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 45,
              child: Column(
                children: [
                  Text(
                      post.createdAt.length >= 16
                          ? post.createdAt.substring(11, 16)
                          : post.createdAt,
                      style: const TextStyle(color: Colors.black26, fontSize: 11)
                  ),
                  const SizedBox(height: 4),
                  if (post.likeCnt > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text("${post.likeCnt}",
                          style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    post.category ?? "일반",
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: post.title,
                                style: const TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 14,
                                    height: 1.3,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              if (post.commentCnt > 0)
                                TextSpan(
                                  text: "  ${post.commentCnt}",
                                  style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(post.authorName, style: const TextStyle(color: Colors.black45, fontSize: 11)),
                      const SizedBox(width: 8),
                      const Text("·", style: TextStyle(color: Colors.black12)),
                      const SizedBox(width: 8),
                      Text("조회 ${post.viewCnt}", style: const TextStyle(color: Colors.black26, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}