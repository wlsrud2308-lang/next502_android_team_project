import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class MovieDetailScreen2 extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen2({super.key, required this.movieId});

  @override
  State<MovieDetailScreen2> createState() => _MovieDetailScreen2State();
}

class _MovieDetailScreen2State extends State<MovieDetailScreen2> {
  late Future<Map<String, dynamic>> movieFuture;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080', // 🔥 baseUrl 통일 추천
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  @override
  void initState() {
    super.initState();
    movieFuture = fetchMovie(widget.movieId);
  }

  // ✅ Dio API 호출
  Future<Map<String, dynamic>> fetchMovie(int movieId) async {
    try {
      final res = await _dio.get("/movies/$movieId");
      print("응답 데이터: ${res.data}");
      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      print("API 오류: $e");
      throw Exception("데이터 불러오기 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: movieFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(
              child: Text("에러 발생", style: TextStyle(color: Colors.white)),
            ),
          );
        }

        final movie = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D0D0D),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPoster(movie),
                _buildTitle(movie),
                _buildStatRow(movie),
                _buildOverview(movie),
                _buildCast(movie),
                _buildDirector(movie),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🎬 포스터
  Widget _buildPoster(Map movie) {
    final backdropPath = movie['backdropPath'] ?? movie['backdrop_path'];

    return backdropPath != null && backdropPath.toString().isNotEmpty
        ? Image.network(
      "https://image.tmdb.org/t/p/w780$backdropPath",
      height: 240,
      width: double.infinity,
      fit: BoxFit.cover,
    )
        : Container(
      height: 240,
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.movie, color: Colors.white24, size: 60),
      ),
    );
  }

  // 🎬 제목 + 개봉일
  Widget _buildTitle(Map movie) {
    final releaseDate = movie['releaseDate'] ?? movie['release_date'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie['title'] ?? "제목 없음",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            (releaseDate != null && releaseDate.toString().length >= 4)
                ? releaseDate.toString().substring(0, 4)
                : "연도 미상",
            style: const TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  // ⭐ 평점 / 상영시간 / 인기도
  Widget _buildStatRow(Map movie) {
    final voteAverage = movie['voteAverage'] ?? movie['vote_average'];
    final runtime = movie['runtime'];
    final popularity = movie['popularity'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              "평점",
              voteAverage != null ? voteAverage.toString() : "0.0",
              Colors.purpleAccent,
            ),
            _buildStatItem(
              "상영시간",
              runtime != null ? "${runtime}분" : "정보 없음",
              Colors.blueAccent,
            ),
            _buildStatItem(
              "인기도",
              popularity != null ? popularity.toString() : "0",
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white24, fontSize: 11)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // 📝 줄거리
  Widget _buildOverview(Map movie) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        movie['overview'] ?? "줄거리 정보 없음",
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
  Widget _buildCast(Map movie) {
    final castList = movie['cast'];

    if (castList == null || castList.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "출연 배우",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: castList.length,
              itemBuilder: (context, index) {
                final cast = castList[index];

                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: cast['profile_path'] != null
                            ? NetworkImage(
                            "https://image.tmdb.org/t/p/w200${cast['profile_path']}")
                            : null,
                        backgroundColor: Colors.grey[800],
                        child: cast['profile_path'] == null
                            ? const Icon(Icons.person, color: Colors.white24)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cast['name'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        cast['character_name'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirector(Map movie) {
    final crewList = movie['crew'];

    if (crewList == null) return const SizedBox();

    final director = crewList.firstWhere(
          (c) => c['job'] == 'Director',
      orElse: () => null,
    );

    if (director == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: director['profile_path'] != null
                ? NetworkImage(
                "https://image.tmdb.org/t/p/w200${director['profile_path']}")
                : null,
            backgroundColor: Colors.grey[800],
            child: director['profile_path'] == null
                ? const Icon(Icons.person, color: Colors.white24)
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "감독",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              Text(
                director['name'] ?? '',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}