import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../widgets/review_list.dart';
import '../widgets/review_input.dart';

class MovieDetailScreen2 extends StatefulWidget {
  final int movieId;
  const MovieDetailScreen2({super.key, required this.movieId});

  @override
  State<MovieDetailScreen2> createState() => _MovieDetailScreen2State();
}

class _MovieDetailScreen2State extends State<MovieDetailScreen2> {
  late Future<Map<String, dynamic>> movieFuture;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080'));

  @override
  void initState() {
    super.initState();
    movieFuture = fetchMovie(widget.movieId);
  }

  Future<Map<String, dynamic>> fetchMovie(int movieId) async {
    final res = await _dio.get("/movies/$movieId");
    return Map<String, dynamic>.from(res.data);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: movieFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFF0D0D0D),
            body: Center(
              child: Text("영화 정보 불러오기 실패: ${snapshot.error}", style: const TextStyle(color: Colors.white)),
            ),
          );
        }

        final movie = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D0D0D),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 포스터
                movie['backdropPath'] != null
                    ? Image.network("https://image.tmdb.org/t/p/w780${movie['backdropPath']}", height: 240, width: double.infinity, fit: BoxFit.cover)
                    : Container(height: 240, color: Colors.grey[900], child: const Center(child: Icon(Icons.movie, color: Colors.white24, size: 60))),
                // 제목/연도
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie['title'] ?? "제목 없음", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        movie['releaseDate'] != null ? movie['releaseDate'].substring(0, 4) : "연도 미상",
                        style: const TextStyle(color: Colors.white38),
                      ),
                    ],
                  ),
                ),
                // 평점/상영시간/인기도
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          const Text("평점", style: TextStyle(color: Colors.white24, fontSize: 11)),
                          const SizedBox(height: 6),
                          Text(movie['voteAverage']?.toString() ?? "0.0", style: const TextStyle(color: Colors.purpleAccent, fontSize: 16, fontWeight: FontWeight.bold))
                        ]),
                        Column(children: [
                          const Text("상영시간", style: TextStyle(color: Colors.white24, fontSize: 11)),
                          const SizedBox(height: 6),
                          Text(movie['runtime'] != null ? "${movie['runtime']}분" : "정보 없음", style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold))
                        ]),
                        Column(children: [
                          const Text("인기도", style: TextStyle(color: Colors.white24, fontSize: 11)),
                          const SizedBox(height: 6),
                          Text(movie['popularity']?.toString() ?? "0", style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold))
                        ]),
                      ],
                    ),
                  ),
                ),
                // 줄거리
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(movie['overview'] ?? "줄거리 정보 없음", style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                ),
                // 배우/감독
                // ... _buildCast, _buildDirector 등 기존 로직 그대로
                const SizedBox(height: 16),
                // 리뷰 작성
                ReviewInput(
                  movieId: widget.movieId,
                  onReviewSubmitted: () {
                    setState(() {}); // 새로고침
                  },
                ),
                // 리뷰 리스트
                ReviewList(movieId: widget.movieId),
              ],
            ),
          ),
        );
      },
    );
  }
}