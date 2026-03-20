import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../widgets/review_input.dart';
import '../widgets/review_list.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<Map<String, dynamic>> movieFuture;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080'));

  // 1. 로그인한 사용자의 user_num을 저장할 변수
  int? _myUserNum;

  @override
  void initState() {
    super.initState();
    movieFuture = fetchMovie(widget.movieId);
    _loadUserInfo(); // 2. 페이지 시작 시 유저 정보 불러오기
  }

  // 3. 서버에서 내 정보를 가져오는 함수 추가
  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final idToken = await user.getIdToken();
        // 서버의 내 정보 조회 API (경로를 서버 설정에 맞춰 확인하세요)
        final res = await _dio.get(
          "/users/me",
          options: Options(headers: {"Authorization": "Bearer $idToken"}),
        );

        if (mounted) {
          setState(() {
            // 서버 응답 데이터에서 user_num 추출
            _myUserNum = res.data['user_num'];
          });
        }
      } catch (e) {
        debugPrint("유저 정보 로드 실패: $e");
      }
    }
  }

  Future<Map<String, dynamic>> fetchMovie(int movieId) async {
    final res = await _dio.get("/movies/$movieId");
    return Map<String, dynamic>.from(res.data);
  }

  void refreshReviews() {
    setState(() {});
  }

  // ================= 배우 =================
  Widget _buildCast(Map movie) {
    final castList = movie['cast'];
    if (castList == null || castList.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "출연 배우",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                            ? NetworkImage("https://image.tmdb.org/t/p/w200${cast['profile_path']}")
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
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        cast['character'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
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

  // ================= 감독 =================
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
                ? NetworkImage("https://image.tmdb.org/t/p/w200${director['profile_path']}")
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
              const Text("감독", style: TextStyle(color: Colors.white38, fontSize: 12)),
              Text(
                director['name'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
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
              child: Text(
                "영화 정보 불러오기 실패: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final movie = snapshot.data!;
        final backdropPath = movie['backdropPath'] ?? movie['backdrop_path'];
        final posterPath = movie['posterPath'] ?? movie['poster_path'];
        final releaseDate = movie['releaseDate'] ?? movie['release_date'];
        final voteAverage = movie['voteAverage'] ?? movie['vote_average'];

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
                // 포스터 이미지
                backdropPath != null
                    ? Image.network(
                  "https://image.tmdb.org/t/p/w780$backdropPath",
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : posterPath != null
                    ? Image.network(
                  "https://image.tmdb.org/t/p/w780$posterPath",
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
                ),
                // 제목 + 날짜 전체
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie['title'] ?? "제목 없음",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        releaseDate ?? "날짜 미상",
                        style: const TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                // 평점 / 상영시간 / 인기도
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text("평점", style: TextStyle(color: Colors.white24, fontSize: 11)),
                            const SizedBox(height: 6),
                            Text(
                              voteAverage != null ? voteAverage.toString() : "0.0",
                              style: const TextStyle(
                                  color: Colors.purpleAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("상영시간", style: TextStyle(color: Colors.white24, fontSize: 11)),
                            const SizedBox(height: 6),
                            Text(
                              movie['runtime'] != null ? "${movie['runtime']}분" : "정보 없음",
                              style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("인기도", style: TextStyle(color: Colors.white24, fontSize: 11)),
                            const SizedBox(height: 6),
                            Text(
                              movie['popularity']?.toString() ?? "0",
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 줄거리
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    movie['overview'] ?? "줄거리 정보 없음",
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                ),
                // 배우 / 감독
                _buildCast(movie),
                _buildDirector(movie),
                const SizedBox(height: 16),
                // 리뷰 작성
                if (_myUserNum != null)
                  ReviewInput(
                    userNum: _myUserNum!,
                    movieId: widget.movieId,
                    onReviewSubmitted: refreshReviews,
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        "로그인 정보를 확인 중이거나 로그인이 필요합니다.",
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
                  ),
                // 리뷰 리스트
                ReviewList(
                  key: ValueKey("review_list_${DateTime.now().millisecondsSinceEpoch}"),
                  movieId: widget.movieId,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}