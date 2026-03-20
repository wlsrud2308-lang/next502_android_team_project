import 'package:flutter/material.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/screens/movie_detail.dart';
import 'package:flutter_app/screens/global_post_list.dart';
import 'package:flutter_app/screens/domestic_screen.dart';
import 'package:flutter_app/screens/free_screen.dart';
import '../models/movie.dart';
import '../service/movie_service.dart';
import '../widgets/bottom_nav_bar.dart';

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

  final Map<int, bool> _favoriteMap = {};

  int _selectedIndex = 1; // ⭐ 영화정보 탭

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);
    try {
      final movies = await MovieService.fetchMoviesByCategory(_selectedFilter);
      setState(() => _movies = movies);
    } catch (e) {
      print('영화 데이터를 불러오는데 실패했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Movie> get _filteredMovies {
    if (_searchController.text.isEmpty) return _movies;
    final query = _searchController.text.toLowerCase();
    return _movies.where((m) => m.title.toLowerCase().contains(query)).toList();
  }

  // ⭐ 네브바 클릭 처리
  void _onNavTap(int index) {
    if (index == _selectedIndex) return;

    Widget nextScreen;

    switch (index) {
      case 0:
        nextScreen = const MovieHomeScreen();
        break;
      case 1:
        return;
      case 2:
        nextScreen = const MovieBoardScreen();
        break;
      case 3:
        nextScreen = const DomesticMovieBoardScreen();
        break;
      case 4:
        nextScreen = const FreeBoardScreen();
        break;
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "영화 정보",
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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

      // ⭐ 여기 추가된 부분
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.black, fontSize: 14),
          cursorColor: Colors.purpleAccent,
          decoration: InputDecoration(
            hintText: "영화 제목 검색",
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: Colors.black38, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.cancel, color: Colors.black38, size: 18),
              onPressed: () => setState(() => _searchController.clear()),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
          onChanged: (value) => setState(() {}),
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
          color: Colors.white70,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Text(
              "영화 기본 정보",
              style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: _selectedFilter,
              underline: const SizedBox(),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              iconEnabledColor: Colors.black54,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('전체')),
                DropdownMenuItem(value: 'popular', child: Text('인기순')),
                DropdownMenuItem(value: 'topRated', child: Text('평점순')),
                DropdownMenuItem(value: 'nowPlaying', child: Text('상영중')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFilter = value);
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
        child: Text('검색 결과가 없습니다', style: TextStyle(color: Colors.black38)),
      );
    }

    return ListView.builder(
      itemCount: _filteredMovies.length,
      itemBuilder: (context, index) => _buildMovieListItem(_filteredMovies[index]),
    );
  }

  Widget _buildMovieListItem(Movie movie) {
    final isFav = _favoriteMap[movie.id] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailScreen(movieId: movie.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _favoriteMap[movie.id] = !isFav;
                });
              },
              child: Icon(
                isFav ? Icons.star : Icons.star_border,
                color: isFav ? Colors.orangeAccent : Colors.black26,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: movie.posterPath != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.movie, color: Colors.black38),
                ),
              )
                  : const Icon(Icons.movie, color: Colors.black38),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "개봉일: ${movie.releaseDate ?? '-'}",
                    style: const TextStyle(color: Colors.black45, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (movie.voteAverage ?? 0).toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text("평점", style: TextStyle(color: Colors.black38, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}