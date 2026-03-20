import 'package:flutter/material.dart';
import 'package:flutter_app/models/movie.dart';
import 'package:flutter_app/service/post_service_impl.dart';
import 'package:flutter_app/models/post_model.dart';
import 'package:dio/dio.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Future<SearchResult>? _searchResults;

  final postService = PostServiceImpl();
  final Dio dio = Dio();

  void _search() {
    String query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searchResults = _fetchSearchResults(query);
    });
  }

  // 🔹 서버에서 영화 + 게시글 통합 검색
  Future<SearchResult> _fetchSearchResults(String query) async {
    final response =
    await dio.get('http://10.0.2.2:8080/flutter/search', queryParameters: {
      'query': query,
    });

    if (response.statusCode == 200) {
      return SearchResult.fromJson(response.data);
    } else {
      throw Exception("검색 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경 흰색
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // 앱바 원본 유지
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "검색어 입력...",
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _search(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _search,
          ),
        ],
      ),
      body: _searchResults == null
          ? Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            "검색어를 입력하세요",
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      )
          : FutureBuilder<SearchResult>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.indigoAccent,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                "검색 오류",
                style: TextStyle(color: Colors.black54),
              ),
            );
          } else if (!snapshot.hasData ||
              (snapshot.data!.movies.isEmpty &&
                  snapshot.data!.posts.isEmpty)) {
            return const Center(
              child: Text(
                "검색 결과 없음",
                style: TextStyle(color: Colors.black54),
              ),
            );
          } else {
            final searchResult = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // 🔹 영화 섹션
                if (searchResult.movies.isNotEmpty) ...[
                  const Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      "영화 검색 결과",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...searchResult.movies
                      .map((movie) => _buildMovieItem(movie))
                      .toList(),
                ],

                // 🔹 게시글 섹션
                if (searchResult.posts.isNotEmpty) ...[
                  const Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      "관련 게시글",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...searchResult.posts
                      .map((post) => _buildPostItem(post))
                      .toList(),
                ],
              ],
            );
          }
        },
      ),
    );
  }

  // 🔹 영화 카드 UI
  Widget _buildMovieItem(Movie movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: movie.posterPath != null && movie.posterPath!.isNotEmpty
                ? Image.network(
              "https://image.tmdb.org/t/p/w500${movie.posterPath!}",
              width: 60,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 90,
                color: Colors.grey.shade200,
              ),
            )
                : Container(width: 60, height: 90, color: Colors.grey.shade200),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  movie.releaseDate ?? "개봉일 없음",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  movie.overview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 게시글 UI
  Widget _buildPostItem(PostDto post) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35,
            child: Text(
              post.postId.toString(),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    maxLines: 2),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      post.category ?? '기타',
                      style:
                      const TextStyle(color: Colors.blueAccent, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.authorName ?? '익명',
                      style: const TextStyle(color: Colors.black54, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.createdAt ?? '',
                      style: const TextStyle(color: Colors.black38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "💬 ${post.commentCnt}",
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// 🔹 통합 검색 결과 DTO
class SearchResult {
  final List<Movie> movies;
  final List<PostDto> posts;

  SearchResult({required this.movies, required this.posts});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      movies: (json['movies'] as List)
          .map((e) => Movie.fromJson(e))
          .toList(),
      posts: (json['posts'] as List)
          .map((e) => PostDto.fromJson(e))
          .toList(),
    );
  }
}