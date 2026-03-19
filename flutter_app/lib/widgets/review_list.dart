import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/review_model.dart';

class ReviewList extends StatefulWidget {
  final int movieId;
  const ReviewList({super.key, required this.movieId});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080'));
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = fetchReviews();
  }

  Future<List<Review>> fetchReviews() async {
    final res = await _dio.get("/reviews/movie/${widget.movieId}");
    return (res.data as List).map((e) => Review.fromJson(e)).toList();
  }

  void refresh() {
    setState(() {
      _reviewsFuture = fetchReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("리뷰 불러오기 실패", style: TextStyle(color: Colors.white)));
        }
        final reviews = snapshot.data!;
        if (reviews.isEmpty) {
          return const Center(child: Text("등록된 리뷰가 없습니다.", style: TextStyle(color: Colors.white)));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: reviews.map((r) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 별점
                  Row(
                    children: List.generate(5, (i) {
                      final starValue = i + 1;
                      Icon icon;
                      if (r.rating >= starValue) {
                        icon = const Icon(Icons.star, color: Colors.yellowAccent, size: 20);
                      } else if (r.rating >= starValue - 0.5) {
                        icon = const Icon(Icons.star_half, color: Colors.yellowAccent, size: 20);
                      } else {
                        icon = const Icon(Icons.star_border, color: Colors.yellowAccent, size: 20);
                      }
                      return icon;
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r.content,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.createdAt,
                    style: const TextStyle(color: Colors.white24, fontSize: 10),
                  ),
                ],
              ),
            ),
          )).toList(),
        );
      },
    );
  }
}
