import 'package:flutter/material.dart';
import 'package:flutter_app/screens/movie_info.dart';

class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({super.key});

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

class _MovieHomeScreenState extends State<MovieHomeScreen> {
  int _selectedCategoryIndex = 1;

  final List<String> _categories = [
    "영화 정보",
    "해외영화",
    "국내영화",
    "자유게시판"
  ];

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
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBoxOfficeBar(),
          _buildBarCategoryNav(),
          Expanded(
            child: _buildOtherCategoryContent(),
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

  // ====================== 카테고리 바 (🔥 수정됨)
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
                print("클릭됨: $index"); // 디버깅용

                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MovieListScreen(),
                    ),
                  );
                } else {
                  setState(() => _selectedCategoryIndex = index);
                }
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

  // ====================== 나머지 콘텐츠
  Widget _buildOtherCategoryContent() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader("🔥 실시간 인기글"),
        _buildFilterChips(),
        const SizedBox(height: 10),
        _buildPostItem(context, "1", "듄: 파트2 아이맥스 명당자리 공유", "해외영화",
            "무비러버", "2시간전", 45),
        _buildPostItem(context, "2", "파묘 1000만 돌파 확정?", "국내영화",
            "스포주의", "4시간전", 128),
        _buildPostItem(context, "3", "삼체 후기 (원작 비교)", "OTT",
            "SF매니아", "10시간전", 22),
        _buildPostItem(context, "4", "이번주 개봉작 한줄평 모음", "영화뉴스",
            "시네필", "13시간전", 56),
      ],
    );
  }

  // ====================== UI 컴포넌트
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ["전체", "해외영화", "국내영화", "OTT", "기대작"];

    return SizedBox(
      height: 35,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: filters
            .map(
              (f) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(f,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              onPressed: () {},
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildPostItem(
      BuildContext context,
      String rank,
      String title,
      String category,
      String author,
      String time,
      int comments) {
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