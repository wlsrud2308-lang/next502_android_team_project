import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/movie_list_page.dart';
import '../models/movie.dart';
import '../service/movie_service.dart';

class MovieHomeScreen extends StatefulWidget {
  const MovieHomeScreen({super.key});

  @override
  State<MovieHomeScreen> createState() => _MovieHomeScreenState();
}

class _MovieHomeScreenState extends State<MovieHomeScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    "영화 정보",
    "해외영화",
    "국내영화",
    "자유게시판"
  ];

  late Future<List<Movie>> movies;

  @override
  void initState() {
    super.initState();
    // 영화정보 탭에서는 최신영화만 가져오도록 변경
    movies = MovieService.fetchNowPlayingMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: const Icon(Icons.movie_filter, color: Colors.purpleAccent),
        title: const Text("영화 앱"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MovieListPage()),
              );
            },
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
            child: _selectedCategoryIndex == 0
                ? _buildMovieList() // 최신영화만 표시
                : _buildOtherCategoryContent(),
          ),
        ],
      ),
    );
  }

  // ====================== 최신영화 리스트
  Widget _buildMovieList() {
    return FutureBuilder<List<Movie>>(
      future: movies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("에러: ${snapshot.error}"));
        }

        final movieList = snapshot.data ?? [];
        if (movieList.isEmpty) {
          return const Center(child: Text("최신 영화 데이터가 없습니다."));
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: movieList.length,
          itemBuilder: (context, index) {
            final movie = movieList[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: movie.posterPath != null && movie.posterPath!.isNotEmpty
                    ? Image.network(
                  "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.movie),
                )
                    : const Icon(Icons.movie, size: 50),
                title: Text(
                  movie.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (movie.voteAverage != null) Text("⭐ ${movie.voteAverage}"),
                        if (movie.runtime != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text("⏱ ${movie.runtime}분"),
                          ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  // ====================== 나머지 카테고리 콘텐츠
  Widget _buildOtherCategoryContent() {
    return ListView(
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
    );
  }

  // ====================== 공통 UI
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
          border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(rate,
              style: const TextStyle(
                  fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
          Text(title,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                      fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onPressed: () {},
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, String rank, String title, String category,
      String author, String time, int comments) {
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
            child: Text(rank,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
                    maxLines: 2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(category,
                        style: const TextStyle(
                            color: Colors.lightBlueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Text(author,
                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(width: 10),
                    Text(time,
                        style: const TextStyle(color: Colors.white54, fontSize: 11)),
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
                Text(comments.toString(),
                    style: const TextStyle(
                        fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}