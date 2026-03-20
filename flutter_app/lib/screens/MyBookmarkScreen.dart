import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/models/movie.dart';
import 'package:flutter_app/screens/movie_detail.dart';
import 'package:flutter_app/widgets/BookmarkButton.dart';

class MyBookmarkScreen extends StatefulWidget {
  const MyBookmarkScreen({super.key});

  @override
  State<MyBookmarkScreen> createState() => _MyBookmarkScreenState();
}

class _MyBookmarkScreenState extends State<MyBookmarkScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080'));
  List<Movie> _bookmarkedMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyBookmarks();
  }

  // 서버에서 북마크한 영화 상세 정보 목록을 가져오는 함수
  Future<void> _loadMyBookmarks() async {
    if (sessionUserNum == null) return;

    setState(() => _isLoading = true);
    try {
      // 서버 API: GET /bookmark/details/{userNum} (서버에 구현 필요)
      final response = await _dio.get('/bookmark/details/$sessionUserNum');
      print("서버 응답 데이터: ${response.data}");

      if (response.statusCode == 200) {
        final List data = response.data;
        setState(() {
          _bookmarkedMovies = data.map((e) => Movie.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint("북마크 로드 실패: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "내 북마크",
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : _bookmarkedMovies.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        itemCount: _bookmarkedMovies.length,
        itemBuilder: (context, index) => _buildMovieListItem(_bookmarkedMovies[index]),
      ),
    );
  }

  // 데이터가 없을 때 보여줄 화면
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded, size: 80, color: Colors.deepPurple.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text("아직 찜한 영화가 없어요",
              style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("마음에 드는 영화에 북마크를 눌러\n나만의 리스트를 만들어보세요!",
              textAlign: TextAlign.center, style: TextStyle(color: Colors.black38, fontSize: 14, height: 1.5)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: const Text("영화 구경하러 가기", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 리스트 아이템 (기존 MovieListScreen 스타일 유지)
  Widget _buildMovieListItem(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailScreen(movieId: movie.id)),
        ).then((_) => _loadMyBookmarks()); // 상세페이지에서 북마크 해제하고 올 수 있으니 새로고침
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1)))),
        child: Row(
          children: [
            BookmarkButton(
              movieId: movie.id,
              initialIsFavorite: true, // 이 리스트에 있다는 건 이미 북마크된 상태
            ),
            const SizedBox(width: 12),
            movie.posterPath != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                width: 44,
                height: 60,
                fit: BoxFit.cover,
                // 이미지를 불러오지 못할 때(404 등) 보여줄 아이콘
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                        width: 44,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 20, color: Colors.black26)
                    ),
              ),
            )
                : Container(
                width: 44,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.movie, size: 20, color: Colors.black26)
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                      style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(movie.releaseDate ?? "", style: const TextStyle(color: Colors.black38, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black12),
          ],
        ),
      ),
    );
  }
}