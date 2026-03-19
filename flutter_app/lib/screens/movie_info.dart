import 'package:flutter/material.dart';
import 'package:flutter_app/service/movie_service.dart';
import '../models/movie.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];
  String _selectedFilter = 'all'; // all, popular, topRated, nowPlaying
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final movies = await MovieService.fetchMoviesByCategory(_selectedFilter);
      setState(() {
        _movies = movies;
      });
    } catch (e) {
      print('영화 데이터를 불러오는데 실패했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Movie> get _filteredMovies {
    if (_searchController.text.isEmpty) return _movies;
    final query = _searchController.text.toLowerCase();
    return _movies.where((movie) => movie.title.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          "영화 정보",
          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildInfoSummaryBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMovieList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: Colors.purpleAccent,
          decoration: InputDecoration(
            hintText: "영화 제목 검색",
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white24, size: 18),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
              },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Text(
              "영화 기본 정보",
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: _selectedFilter,
              underline: const SizedBox(), // 테두리 제거
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white38,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('전체')),
                DropdownMenuItem(value: 'popular', child: Text('인기순')),
                DropdownMenuItem(value: 'topRated', child: Text('평점순')),
                DropdownMenuItem(value: 'nowPlaying', child: Text('상영중')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  _loadMovies();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieList() {
    if (_filteredMovies.isEmpty) {
      return const Center(
        child: Text(
          '검색 결과가 없습니다',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredMovies.length,
      itemBuilder: (context, index) {
        final movie = _filteredMovies[index];
        return _buildMovieListItem(movie);
      },
    );
  }

  Widget _buildMovieListItem(Movie movie) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.02))),
      ),
      child: Row(
        children: [
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
                Text(
                  movie.title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "평점: ${movie.voteAverage ?? '-'}  ·  개봉일: ${movie.releaseDate ?? '-'}",
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}