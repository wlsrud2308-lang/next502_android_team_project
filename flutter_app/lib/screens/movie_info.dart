import 'package:flutter/material.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _movies = [
    {"title": "파묘", "rating": "4.8", "genre": "미스터리/공포", "year": "2024", "isFavorite": true},
    {"title": "듄: 파트2", "rating": "4.9", "genre": "액션/SF", "year": "2024", "isFavorite": false},
    {"title": "웡카", "rating": "4.2", "genre": "판타지", "year": "2024", "isFavorite": false},
    {"title": "가여운 것들", "rating": "4.0", "genre": "드라마", "year": "2024", "isFavorite": true},
    {"title": "범죄도시4", "rating": "3.5", "genre": "범죄/액션", "year": "2024", "isFavorite": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text("영화 정보", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),

          _buildInfoSummaryBar(),

          Expanded(
            child: ListView.builder(
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                return _buildMovieListItem(index, _movies[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: Colors.purpleAccent,
          decoration: InputDecoration(
            hintText: "영화 제목, 감독, 배우 검색",
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white24, size: 18),
              onPressed: () => setState(() => _searchController.clear()),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildInfoSummaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.03)),
          bottom: BorderSide(color: Colors.white.withOpacity(0.03)),
        ),
      ),
      child: Row(
        children: [
          const Text("영화 기본 정보", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
          const Spacer(),
          _buildSmallFilterText("평점순"),
          const SizedBox(width: 12),
          _buildSmallFilterText("최신순"),
        ],
      ),
    );
  }

  Widget _buildSmallFilterText(String label) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const Icon(Icons.arrow_drop_down, color: Colors.white38, size: 16),
      ],
    );
  }

  Widget _buildMovieListItem(int index, Map<String, dynamic> movie) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.02))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => movie['isFavorite'] = !movie['isFavorite']),
            child: Icon(
              movie['isFavorite'] ? Icons.star : Icons.star_border,
              color: movie['isFavorite'] ? Colors.orangeAccent : Colors.white10,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 44,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.movie_filter, color: Colors.white10, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie['title'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("${movie['genre']} · ${movie['year']}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(movie['rating'], style: const TextStyle(color: Colors.purpleAccent, fontSize: 15, fontWeight: FontWeight.bold)),
              const Text("평점", style: TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}