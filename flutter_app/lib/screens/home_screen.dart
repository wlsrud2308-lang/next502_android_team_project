import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() => runApp(const MovieApp());

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      home: const MovieHomeScreen(),
    );
  }
}

class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({super.key});

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

class _MovieHomeScreenState extends State<MovieHomeScreen> {
  int _selectedCategoryIndex = 1;
  final List<String> _categories = ["영화 정보", "해외영화", "국내영화", "OTT", "블루레이", "자유게시판"];


  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: const Icon(Icons.movie_filter, color: Colors.purpleAccent),
        actions: [
          //  상단에 API 통신 테스트용 초록색 새로고침(Sync) 버튼을 배치
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.greenAccent),
            onPressed: () {},
          ),
          // 종료
          IconButton(icon: const Icon(Icons.search, color: Colors.white30), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.white30), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildBoxOfficeBar(),
          _buildBarCategoryNav(),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
              ),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSectionHeader("🔥 실시간 인기글"),
                  _buildFilterChips(),
                  const SizedBox(height: 10),
                  _buildPostItem(context, "1", "듄: 파트2 아이맥스 용산 명당자리 공유합니다", "해외영화", "무비러버", "2시간전", 45),
                  _buildPostItem(context, "2", "파묘 1000만 돌파 확정! 장재현 감독의 힘인가요?", "국내영화", "스포주의", "4시간전", 128),
                  _buildPostItem(context, "3", "넷플릭스 '삼체' 원작 소설이랑 비교해본 후기", "OTT", "SF매니아", "10시간전", 22),
                  _buildPostItem(context, "4", "이번주 개봉 영화 평론가 한줄평 싹 모아드림", "영화뉴스", "시네필", "13시간전", 56),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () {
          print("게시판 글쓰기 버튼 클릭됨!");
        },
        child: const Icon(Icons.edit, color: Colors.white),
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
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.purpleAccent : Colors.transparent,
                    width: 3,
                  ),
                ),
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
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
        children: filters.map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ActionChip(
            label: Text(f, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onPressed: () {},
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, String rank, String title, String category, String author, String time, int comments) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35,
            child: Text(rank, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(category, style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Text(author, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(width: 10),
                    Text(time, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                const Icon(Icons.comment, size: 14, color: Colors.white70),
                Text(comments.toString(), style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}