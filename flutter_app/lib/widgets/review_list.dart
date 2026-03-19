import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/review_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewList extends StatefulWidget {
  final int movieId;
  const ReviewList({super.key, required this.movieId});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  late Future<List<Review>> _reviewsFuture;

  // 테스트용
  final int myUserNum = 1;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = fetchReviews();
  }

  Future<List<Review>> fetchReviews() async {
    try {
      final res = await _dio.get("/reviews/${widget.movieId}");
      debugPrint("리뷰 조회 주소: ${res.realUri}");
      debugPrint("리뷰 조회 응답: ${res.data}");

      return (res.data as List)
          .map((e) => Review.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint("리뷰 조회 오류: $e");
      rethrow;
    }
  }

  double getAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  Future<void> _deleteReview(int reviewId) async {
    try {
      await _dio.delete("/reviews/$reviewId");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰가 삭제되었습니다.")),
      );
      refresh();
    } on DioException catch (e) {
      debugPrint("리뷰 삭제 오류: ${e.response?.data}");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰 삭제 실패")),
      );
    }
  }

  Future<void> _updateReview(int reviewId, double rating, String content) async {
    try {
      await _dio.put(
        "/reviews/$reviewId",
        data: {
          "rating": rating,
          "content": content,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰가 수정되었습니다.")),
      );
      refresh();
    } on DioException catch (e) {
      debugPrint("리뷰 수정 오류: ${e.response?.data}");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰 수정 실패")),
      );
    }
  }

  void _showEditDialog(Review review) {
    final controller = TextEditingController(text: review.content);
    double newRating = review.rating;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141414),
          title: const Text(
            "리뷰 수정",
            style: TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingBar(
                    initialRating: newRating,
                    minRating: 0.5,
                    allowHalfRating: true,
                    itemCount: 5,
                    ratingWidget: RatingWidget(
                      full: const Icon(Icons.star, color: Colors.yellowAccent),
                      half: const Icon(Icons.star_half, color: Colors.yellowAccent),
                      empty: const Icon(Icons.star_border, color: Colors.yellowAccent),
                    ),
                    onRatingUpdate: (value) {
                      setDialogState(() {
                        newRating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "리뷰 내용을 입력하세요",
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                await _updateReview(
                  review.reviewId,
                  newRating,
                  controller.text.trim(),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
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
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                "리뷰 불러오기 실패",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final reviews = snapshot.data ?? [];
        final averageRating = getAverageRating(reviews);

        if (reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                "등록된 리뷰가 없습니다.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      "리뷰",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "평균 ${averageRating.toStringAsFixed(1)}",
                      style: const TextStyle(
                        color: Colors.yellowAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ...reviews.map(
                    (r) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.nickname.isEmpty ? "익명" : r.nickname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RatingBarIndicator(
                          rating: r.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.yellowAccent,
                          ),
                          itemCount: 5,
                          itemSize: 18,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          r.content,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          r.createdAt,
                          style: const TextStyle(
                            color: Colors.white24,
                            fontSize: 10,
                          ),
                        ),
                        if (r.userNum == myUserNum)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _showEditDialog(r),
                                child: const Text("수정"),
                              ),
                              TextButton(
                                onPressed: () => _deleteReview(r.reviewId),
                                child: const Text("삭제"),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}